-- Duplicate-team reconciliation keeps old public addresses working.
-- When a duplicate team is linked to its canonical team, the alias's public slug is remembered so a link someone already
-- shared (/teams/<old-slug>) resolves to the canonical team instead of a dead page. The alias team row, its source records
-- and history are untouched.

alter table public.team_canonical_links add column if not exists alias_slug text;

update public.team_canonical_links l
   set alias_slug = t.directory_slug
  from public.teams t
 where t.id = l.alias_team_id and l.alias_slug is null;

create unique index if not exists team_canonical_links_alias_slug_idx
  on public.team_canonical_links (alias_slug) where alias_slug is not null;

create or replace function public.link_duplicate_team(p_alias uuid, p_canonical uuid, p_reason text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.is_platform_super_admin(v_actor) then
    raise exception 'Only platform super administrators can link duplicate teams';
  end if;
  if p_alias = p_canonical then raise exception 'A team cannot be linked to itself'; end if;
  if char_length(trim(coalesce(p_reason, ''))) < 3 then raise exception 'A reason is required'; end if;
  if not exists (select 1 from public.teams where id = p_alias) or not exists (select 1 from public.teams where id = p_canonical) then
    raise exception 'Team not found';
  end if;
  if exists (select 1 from public.team_canonical_links where alias_team_id = p_canonical) then
    raise exception 'The canonical team is itself an alias';
  end if;
  if exists (select 1 from public.team_canonical_links where canonical_team_id = p_alias) then
    raise exception 'The alias team already has aliases of its own';
  end if;

  insert into public.team_canonical_links(alias_team_id, canonical_team_id, reason, created_by, alias_slug)
  values (p_alias, p_canonical, trim(p_reason), v_actor, (select directory_slug from public.teams where id = p_alias))
  on conflict (alias_team_id) do update
    set canonical_team_id = excluded.canonical_team_id, reason = excluded.reason, created_by = excluded.created_by,
        alias_slug = excluded.alias_slug;

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_actor, 'team_canonical_links', p_alias, 'link_duplicate_team',
          jsonb_build_object('canonicalTeamId', p_canonical, 'reason', trim(p_reason)));
end;
$$;

-- Public: the canonical team's slug for an old alias slug, or null. Reveals only a slug that is already public.
create or replace function public.resolve_team_alias_slug(p_slug text)
returns text
language sql stable security definer set search_path = ''
as $$
  select c.directory_slug
    from public.team_canonical_links l
    join public.teams c on c.id = l.canonical_team_id
   where l.alias_slug = p_slug
     and c.deleted_at is null and c.visibility = 'public' and c.is_active and c.status = 'active'
   limit 1;
$$;
revoke all on function public.resolve_team_alias_slug(text) from public;
grant execute on function public.resolve_team_alias_slug(text) to anon, authenticated;

notify pgrst, 'reload schema';
