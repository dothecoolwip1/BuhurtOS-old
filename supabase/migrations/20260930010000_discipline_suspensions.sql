-- Forward-only hardening for discipline workflows (Phase 2).
--
-- 1) Discipline cards: writes move to a guarded RPC (server-authorized,
--    audit-stamped) instead of direct table writes from browser clients.
--    Reads keep the existing `discipline_read` policy.
-- 2) Suspensions: proper audited records scoped to an organization with
--    optional event/season links, plus data-layer enforcement that a fighter
--    under an active suspension cannot receive competition clearance.

-- ===========================================================================
-- 1. Guarded discipline card issuance
-- ===========================================================================

create or replace function private.issue_discipline_card(
  p_roster_entry_id uuid,
  p_color public.disciplinary_color,
  p_reason text,
  p_notes text default null,
  p_match_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_entry public.event_roster_entries%rowtype;
  v_season_id uuid;
  v_id uuid;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;

  select * into v_entry
  from public.event_roster_entries
  where id = p_roster_entry_id;
  if not found then
    raise exception 'Roster entry not found';
  end if;

  if not (
    private.is_platform_admin(v_actor)
    or private.has_org_role(v_actor, v_entry.organization_id, array['organization_admin']::public.organization_role[])
    or private.has_event_role(v_actor, v_entry.event_id, array['event_organizer','field_marshal']::public.event_role[])
  ) then
    raise exception 'Not authorized to issue discipline cards';
  end if;

  if p_color is null or p_color not in ('yellow'::public.disciplinary_color, 'red'::public.disciplinary_color) then
    raise exception 'Invalid card color';
  end if;
  if p_reason is null or length(btrim(p_reason)) = 0 then
    raise exception 'Card reason is required';
  end if;

  if p_match_id is not null then
    if not exists (
      select 1 from public.matches m
      where m.id = p_match_id and m.event_id = v_entry.event_id
    ) then
      raise exception 'Match does not belong to the roster entry''s event';
    end if;
  end if;

  select season_id into v_season_id from public.events where id = v_entry.event_id;

  insert into public.disciplinary_cards (
    organization_id, season_id, event_id, match_id, fighter_id, roster_entry_id,
    color, card_reason, notes, issued_by, issued_at
  )
  values (
    v_entry.organization_id,
    v_season_id,
    v_entry.event_id,
    p_match_id,
    v_entry.fighter_id,
    v_entry.id,
    p_color,
    btrim(p_reason),
    p_notes,
    v_actor,
    timezone('utc', now())
  )
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.issue_discipline_card(
  p_roster_entry_id uuid,
  p_color public.disciplinary_color,
  p_reason text,
  p_notes text default null,
  p_match_id uuid default null
)
returns uuid
language sql
security invoker
set search_path = ''
as $$
  select private.issue_discipline_card(p_roster_entry_id, p_color, p_reason, p_notes, p_match_id);
$$;

revoke all on function public.issue_discipline_card(uuid,public.disciplinary_color,text,text,uuid) from public, anon;
grant execute on function public.issue_discipline_card(uuid,public.disciplinary_color,text,text,uuid) to authenticated;

-- Browser clients must go through the RPC; no more direct inserts/updates.
drop policy if exists discipline_write on public.disciplinary_cards;

-- ===========================================================================
-- 2. Suspensions
-- ===========================================================================

create table public.suspensions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  fighter_id uuid not null references public.fighters(id) on delete cascade,
  event_id uuid references public.events(id) on delete cascade,
  season_id uuid references public.seasons(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reason text not null,
  notes text,
  issued_by uuid not null,
  revoked_by uuid,
  revoked_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  last_edited_by uuid,
  constraint suspensions_valid_window check (ends_at > starts_at),
  constraint suspensions_revoked_consistency check (
    (revoked_at is null and revoked_by is null)
    or (revoked_at is not null and revoked_by is not null)
  )
);

comment on table public.suspensions is
  'Organization-level fighter suspensions. event_id/season_id are optional scopes; '
  'NULL event/season means the suspension applies to every event of the organization.';

create index suspensions_active_fighter_idx on public.suspensions (fighter_id, starts_at, ends_at) where revoked_at is null;
create index suspensions_org_idx on public.suspensions (organization_id);

alter table public.suspensions enable row level security;
grant select on public.suspensions to authenticated;
grant select on public.suspensions to anon;

create policy suspensions_org_staff_read
on public.suspensions for select to authenticated
using (
  private.is_platform_admin((select auth.uid()))
  or private.has_org_role(
    (select auth.uid()),
    organization_id,
    array['organization_admin','organization_staff']::public.organization_role[]
  )
  or (
    event_id is not null
    and private.has_event_role(
      (select auth.uid()),
      event_id,
      array['event_organizer','field_marshal','assistant_marshal']::public.event_role[]
    )
  )
);

-- Fighters can see suspensions that cover their own identity.
create policy suspensions_fighter_self_read
on public.suspensions for select to authenticated
using (
  exists (
    select 1
    from public.fighters f
    join public.fighter_identity_accounts a on a.identity_id = f.identity_id
    where f.id = suspensions.fighter_id
      and a.user_id = (select auth.uid())
      and a.revoked_at is null
  )
);

create trigger suspensions_updated
before update on public.suspensions
for each row execute function public.set_updated_at();

create trigger audit_change
after insert or update or delete on public.suspensions
for each row execute function private.capture_audit_change();

-- ===========================================================================
-- 3. Suspension enforcement at the data layer
-- ===========================================================================

create or replace function private.issue_suspension(
  p_organization_id uuid,
  p_fighter_id uuid,
  p_starts_at timestamptz,
  p_ends_at timestamptz,
  p_reason text,
  p_notes text default null,
  p_event_id uuid default null,
  p_season_id uuid default null,
  p_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_id uuid;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;

  if not (
    private.is_platform_admin(v_actor)
    or private.has_org_role(v_actor, p_organization_id, array['organization_admin','organization_staff']::public.organization_role[])
  ) then
    raise exception 'Not authorized to issue suspensions';
  end if;

  if p_ends_at <= p_starts_at then
    raise exception 'Suspension end must be after its start';
  end if;
  if p_reason is null or length(btrim(p_reason)) = 0 then
    raise exception 'Suspension reason is required';
  end if;
  if not exists (select 1 from public.fighters where id = p_fighter_id and deleted_at is null) then
    raise exception 'Fighter not found';
  end if;
  if p_event_id is not null and not exists (
    select 1 from public.events where id = p_event_id and organization_id = p_organization_id
  ) then
    raise exception 'Event does not belong to this organization';
  end if;
  if p_season_id is not null and not exists (
    select 1 from public.seasons where id = p_season_id and organization_id = p_organization_id
  ) then
    raise exception 'Season does not belong to this organization';
  end if;

  insert into public.suspensions (
    id, organization_id, fighter_id, event_id, season_id,
    starts_at, ends_at, reason, notes, issued_by, last_edited_by
  )
  values (
    coalesce(p_id, gen_random_uuid()),
    p_organization_id, p_fighter_id, p_event_id, p_season_id,
    p_starts_at, p_ends_at, btrim(p_reason), p_notes, v_actor, v_actor
  )
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.issue_suspension(
  p_organization_id uuid,
  p_fighter_id uuid,
  p_starts_at timestamptz,
  p_ends_at timestamptz,
  p_reason text,
  p_notes text default null,
  p_event_id uuid default null,
  p_season_id uuid default null,
  p_id uuid default null
)
returns uuid
language sql
security invoker
set search_path = ''
as $$
  select private.issue_suspension(
    p_organization_id, p_fighter_id, p_starts_at, p_ends_at, p_reason,
    p_notes, p_event_id, p_season_id, p_id
  );
$$;

revoke all on function public.issue_suspension(uuid,uuid,timestamptz,timestamptz,text,text,uuid,uuid,uuid) from public, anon;
grant execute on function public.issue_suspension(uuid,uuid,timestamptz,timestamptz,text,text,uuid,uuid,uuid) to authenticated;

create or replace function private.revoke_suspension(p_suspension_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_org uuid;
  v_revoked_at timestamptz;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;

  -- Authorize before any state reveals so callers cannot probe whether a
  -- suspension exists or is revoked (read scoping is enforced by RLS).
  select organization_id, revoked_at into v_org, v_revoked_at
  from public.suspensions
  where id = p_suspension_id;
  if v_org is null then
    raise exception 'Suspension not found';
  end if;
  if v_revoked_at is not null then
    raise exception 'Suspension is already revoked';
  end if;

  if not (
    private.is_platform_admin(v_actor)
    or private.has_org_role(v_actor, v_org, array['organization_admin','organization_staff']::public.organization_role[])
  ) then
    raise exception 'Not authorized to revoke suspensions';
  end if;

  update public.suspensions
  set revoked_at = timezone('utc', now()),
      revoked_by = v_actor,
      last_edited_by = v_actor
  where id = p_suspension_id;
end;
$$;

create or replace function public.revoke_suspension(p_suspension_id uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.revoke_suspension(p_suspension_id);
$$;

revoke all on function public.revoke_suspension(uuid) from public, anon;
grant execute on function public.revoke_suspension(uuid) to authenticated;

-- A fighter under an active suspension cannot be granted competition
-- clearance in any event the suspension covers. Fires on every update of
-- competition_cleared regardless of which path performs it.
create or replace function private.prevent_clearance_while_suspended()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_suspension public.suspensions%rowtype;
  v_season_id uuid;
begin
  if NEW.competition_cleared is true then
    select season_id into v_season_id from public.events where id = NEW.event_id;

    select * into v_suspension
    from public.suspensions s
    where s.fighter_id = NEW.fighter_id
      and s.revoked_at is null
      and (s.event_id is null or s.event_id = NEW.event_id)
      and (s.season_id is null or s.season_id = v_season_id)
      and s.starts_at <= timezone('utc', now())
      and s.ends_at > timezone('utc', now())
    limit 1;

    if v_suspension.id is not null then
      raise exception 'Fighter is under an active suspension until %',
        to_char(v_suspension.ends_at at time zone 'UTC', 'YYYY-MM-DD');
    end if;
  end if;

  return NEW;
end;
$$;

create trigger prevent_clearance_while_suspended
before update of competition_cleared on public.event_roster_entries
for each row execute function private.prevent_clearance_while_suspended();