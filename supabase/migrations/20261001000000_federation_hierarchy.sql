-- Forward-only federation hierarchy (organizations ↔ governing bodies).
--
-- Scoped port of the org/governing-body relationship model from the Pack 4
-- design (branch pack4-organizations-clubs-teams) onto the current main:
--   * organizations gain a `kind` (federation role) and `country_code`;
--   * `organization_relationships` model directed governing links with an
--     active window; reads are public, writes are RPC-only;
--   * guarded upsert/end RPCs enforce bilateral admin consent, active-org
--     residency, an active-duplicate rule, and hierarchy cycle protection.
--
-- Club/team memberships and invitation UIs from the Pack 4 branch are NOT
-- ported here; they remain out of scope for this increment.

-- ===========================================================================
-- 1. Organization federation metadata
-- ===========================================================================

create type public.organization_kind as enum (
  'international_federation',
  'national_federation',
  'regional_organization',
  'local_organization',
  'independent_organization'
);

alter table public.organizations
  add column kind public.organization_kind not null default 'independent_organization',
  add column country_code text;

comment on column public.organizations.kind is
  'Role of the organization in the federation hierarchy; governs how parent/child relationships are interpreted.';
comment on column public.organizations.country_code is
  'ISO 3166-1 alpha-2 country code, used for federation/registry lookups.';

create type public.organization_relationship_kind as enum ('governs', 'recognizes', 'affiliate');

-- ===========================================================================
-- 2. Organization relationships (directed, with an active window)
-- ===========================================================================

create table public.organization_relationships (
  id uuid primary key default gen_random_uuid(),
  parent_organization_id uuid not null references public.organizations(id) on delete restrict,
  child_organization_id uuid not null references public.organizations(id) on delete restrict,
  -- Mirrors the parent so org-scoped audit/reporting needs no second source
  -- of truth (capture_audit_change resolves org context from organization_id).
  organization_id uuid generated always as (parent_organization_id) stored,
  relationship_kind public.organization_relationship_kind not null default 'governs',
  starts_on date not null default current_date,
  ends_on date,
  notes text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  last_edited_by uuid references public.profiles(id),
  check (parent_organization_id <> child_organization_id),
  check (ends_on is null or ends_on >= starts_on)
);

comment on table public.organization_relationships is
  'Directed federation relationships between organizations (a parent governs/recognizes/affiliates a child). '
  'Reads are public; writes are RPC-only with bilateral admin consent and cycle protection.';

create unique index organization_relationships_active_unique_idx
  on public.organization_relationships (parent_organization_id, child_organization_id, relationship_kind)
  where ends_on is null;

create index organization_relationships_parent_active_idx
  on public.organization_relationships (parent_organization_id)
  where ends_on is null;

create index organization_relationships_child_active_idx
  on public.organization_relationships (child_organization_id)
  where ends_on is null;

alter table public.organization_relationships enable row level security;

grant select on public.organization_relationships to anon, authenticated;

create policy organization_relationships_public_read
  on public.organization_relationships for select to anon, authenticated
  using (true);

create trigger organization_relationships_updated
  before update on public.organization_relationships
  for each row execute function public.set_updated_at();

create trigger organization_relationships_audit
  after insert or update or delete on public.organization_relationships
  for each row execute function private.capture_audit_change();

-- ===========================================================================
-- 3. Guarded relationship RPCs
-- ===========================================================================

create or replace function private.upsert_organization_relationship(
  p_parent_organization_id uuid,
  p_child_organization_id uuid,
  p_relationship_kind public.organization_relationship_kind,
  p_starts_on date default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_parent_active boolean;
  v_child_active boolean;
  v_existing uuid;
  v_result uuid;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;

  if p_parent_organization_id = p_child_organization_id then
    raise exception 'An organization cannot relate to itself';
  end if;

  select exists(
    select 1 from public.organizations
    where id = p_parent_organization_id and status = 'active'
  ) into v_parent_active;

  select exists(
    select 1 from public.organizations
    where id = p_child_organization_id and status = 'active'
  ) into v_child_active;

  if not (v_parent_active and v_child_active) then
    raise exception 'Both organizations must be active';
  end if;

  -- Bilateral consent: both organizations' administrators must agree on the
  -- relationship (the child cannot be bound into a hierarchy unilaterally).
  if not (
    private.is_platform_admin(v_actor)
    or (
      private.has_org_role(
        v_actor, p_parent_organization_id,
        array['organization_admin']::public.organization_role[]
      )
      and private.has_org_role(
        v_actor, p_child_organization_id,
        array['organization_admin']::public.organization_role[]
      )
    )
  ) then
    raise exception 'Administrator access to both organizations is required';
  end if;

  -- Cycle guard: adding parent -> child would close a cycle exactly when the
  -- child already sits among the parent's governing ancestors (directly or
  -- transitively through active relationships).
  if exists (
    with recursive ancestors as (
      select r.parent_organization_id
      from public.organization_relationships r
      where r.child_organization_id = p_parent_organization_id
        and r.ends_on is null
      union all
      select r.parent_organization_id
      from public.organization_relationships r
      join ancestors a on r.child_organization_id = a.parent_organization_id
      where r.ends_on is null
    )
    select 1 from ancestors where parent_organization_id = p_child_organization_id
  ) then
    raise exception 'Organization hierarchy cycle detected';
  end if;

  -- Active duplicate is refused; an ended record is reopened instead.
  select id into v_existing
  from public.organization_relationships
  where parent_organization_id = p_parent_organization_id
    and child_organization_id = p_child_organization_id
    and relationship_kind = p_relationship_kind
    and ends_on is null
  limit 1;

  if v_existing is not null then
    raise exception 'That organization relationship is already active';
  end if;

  select id into v_existing
  from public.organization_relationships
  where parent_organization_id = p_parent_organization_id
    and child_organization_id = p_child_organization_id
    and relationship_kind = p_relationship_kind
  order by ends_on desc nulls last, created_at desc
  limit 1;

  if v_existing is null then
    insert into public.organization_relationships (
      parent_organization_id,
      child_organization_id,
      relationship_kind,
      starts_on,
      notes,
      created_by
    ) values (
      p_parent_organization_id,
      p_child_organization_id,
      p_relationship_kind,
      coalesce(p_starts_on, current_date),
      p_notes,
      v_actor
    )
    returning id into v_result;
  else
    update public.organization_relationships
      set ends_on = null,
          starts_on = coalesce(p_starts_on, current_date),
          notes = p_notes,
          last_edited_by = v_actor
    where id = v_existing
    returning id into v_result;
  end if;

  return v_result;
end;
$$;

create or replace function private.end_organization_relationship(
  p_relationship_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_row public.organization_relationships%rowtype;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;

  select * into v_row
  from public.organization_relationships
  where id = p_relationship_id and ends_on is null;

  if not found then
    raise exception 'Active organization relationship not found';
  end if;

  -- The governing body may dissolve the relationship; a member organization
  -- cannot unilaterally end a link its parent administers.
  if not (
    private.is_platform_admin(v_actor)
    or private.has_org_role(
      v_actor,
      v_row.parent_organization_id,
      array['organization_admin']::public.organization_role[]
    )
  ) then
    raise exception 'Organization administrator access required';
  end if;

  update public.organization_relationships
    set ends_on = current_date,
        last_edited_by = v_actor
  where id = v_row.id;

  return v_row.id;
end;
$$;

-- ===========================================================================
-- 4. Public surfaces (thin security-definer wrappers + read helper)
-- ===========================================================================

create or replace function public.upsert_organization_relationship(
  p_parent_organization_id uuid,
  p_child_organization_id uuid,
  p_relationship_kind public.organization_relationship_kind,
  p_starts_on date default null,
  p_notes text default null
)
returns uuid
language sql
security definer
set search_path = ''
as $$
  select private.upsert_organization_relationship(
    p_parent_organization_id,
    p_child_organization_id,
    p_relationship_kind,
    p_starts_on,
    p_notes
  );
$$;

create or replace function public.end_organization_relationship(
  p_relationship_id uuid
)
returns uuid
language sql
security definer
set search_path = ''
as $$
  select private.end_organization_relationship(p_relationship_id);
$$;

create or replace function public.organization_ancestors(p_organization_id uuid)
returns table (
  ancestor_organization_id uuid,
  relationship_kind public.organization_relationship_kind,
  hops integer
)
language sql
security definer
set search_path = ''
as $$
  with recursive chain as (
    select r.parent_organization_id as ancestor_organization_id,
           r.relationship_kind,
           1 as hops
    from public.organization_relationships r
    where r.child_organization_id = p_organization_id
      and r.ends_on is null
    union all
    select r.parent_organization_id,
           r.relationship_kind,
           c.hops + 1
    from public.organization_relationships r
    join chain c on r.child_organization_id = c.ancestor_organization_id
    where r.ends_on is null
  )
  select ancestor_organization_id, relationship_kind, hops
  from chain
  where hops <= 50
  order by hops;
$$;

-- Relationship writes are authenticated-only; anonymous callers are revoked.
-- The ancestors read helper stays caller-visible (public federation data).
revoke all on function public.upsert_organization_relationship(
  uuid, uuid, public.organization_relationship_kind, date, text
) from public, anon;
grant execute on function public.upsert_organization_relationship(
  uuid, uuid, public.organization_relationship_kind, date, text
) to authenticated;

revoke all on function public.end_organization_relationship(uuid) from public, anon;
grant execute on function public.end_organization_relationship(uuid) to authenticated;