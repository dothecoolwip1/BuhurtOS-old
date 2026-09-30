-- Pack 7: canonical statistics, provenance and source reconciliation.
-- * Only finalized, non-bye, two-sided results feed official native stats.
-- * Duplicate team rows created by different sources are linked to one canonical team
--   instead of being merged or overwritten; every source record is kept.
-- * Public provenance exposes source facts side by side so conflicts stay visible.

create table if not exists public.team_canonical_links (
  alias_team_id uuid primary key references public.teams(id) on delete cascade,
  canonical_team_id uuid not null references public.teams(id) on delete cascade,
  reason text not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  check (alias_team_id <> canonical_team_id)
);

create index if not exists team_canonical_links_canonical_idx on public.team_canonical_links(canonical_team_id);

alter table public.team_canonical_links enable row level security;
revoke all on public.team_canonical_links from anon, authenticated;
grant select on public.team_canonical_links to anon, authenticated;
grant all on public.team_canonical_links to service_role;

drop policy if exists team_canonical_links_public_read on public.team_canonical_links;
create policy team_canonical_links_public_read
on public.team_canonical_links for select
to anon, authenticated
using (true);

-- Links a duplicate team to its canonical record. Depth is kept at one so resolution never loops.
create or replace function public.link_duplicate_team(p_alias uuid, p_canonical uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = ''
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

  insert into public.team_canonical_links(alias_team_id, canonical_team_id, reason, created_by)
  values (p_alias, p_canonical, trim(p_reason), v_actor)
  on conflict (alias_team_id) do update
    set canonical_team_id = excluded.canonical_team_id, reason = excluded.reason, created_by = excluded.created_by;

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_actor, 'team_canonical_links', p_alias, 'link_duplicate_team',
          jsonb_build_object('canonicalTeamId', p_canonical, 'reason', trim(p_reason)));
end;
$$;

create or replace function public.resolve_canonical_team(p_team_id uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select canonical_team_id from public.team_canonical_links where alias_team_id = p_team_id), p_team_id)
$$;

revoke all on function public.link_duplicate_team(uuid, uuid, text) from public, anon;
grant execute on function public.link_duplicate_team(uuid, uuid, text) to authenticated;
revoke all on function public.resolve_canonical_team(uuid) from public;
grant execute on function public.resolve_canonical_team(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Public provenance: every source record for a public team (and its aliases).
-- ---------------------------------------------------------------------------

create or replace function public.public_team_provenance(p_team_id uuid)
returns table(
  team_id uuid,
  source_kind text,
  source_record_key text,
  source_url text,
  source_team_name text,
  source_location text,
  source_website_url text,
  source_priority smallint,
  verified_at timestamptz,
  last_synced_at timestamptz,
  is_alias boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select sr.team_id, sr.source_kind, sr.source_record_key, sr.source_url, sr.source_team_name,
         sr.source_location, sr.source_website_url, sr.source_priority, sr.verified_at, sr.last_synced_at,
         sr.team_id <> public.resolve_canonical_team(p_team_id)
  from public.team_source_records sr
  join public.teams t on t.id = sr.team_id
  where t.deleted_at is null
    and t.visibility = 'public'
    and (sr.team_id = public.resolve_canonical_team(p_team_id)
         or sr.team_id in (select l.alias_team_id from public.team_canonical_links l where l.canonical_team_id = public.resolve_canonical_team(p_team_id)))
  order by sr.source_priority asc, sr.verified_at desc nulls last
$$;

revoke all on function public.public_team_provenance(uuid) from public;
grant execute on function public.public_team_provenance(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Official native stats. One definition of "counts": status finalized, a recorded
-- winnerSide, not a bye, two real (non-placeholder) sides, in a public event.
-- ---------------------------------------------------------------------------

create or replace function private.official_match_sides()
returns table(match_id uuid, event_id uuid, category text, rs jsonb, finalized_at timestamptz, team1 uuid, team2 uuid)
language sql
stable
security definer
set search_path = ''
as $$
  select m.id, m.event_id, m.category, m.result_summary, m.finalized_at,
         max(case when mp.side_index = 1 then re.team_id::text end)::uuid,
         max(case when mp.side_index = 2 then re.team_id::text end)::uuid
  from public.matches m
  join public.match_participants mp on mp.match_id = m.id and not mp.is_placeholder
  join public.event_roster_entries re on re.id = mp.roster_entry_id
  where m.status = 'finalized'
    and m.result_summary ? 'winnerSide'
    and coalesce(m.result_summary ->> 'resultType', '') <> 'bye'
    and private.event_is_public(m.event_id)
  group by m.id
  having count(*) = 2
$$;

create or replace function public.official_team_stats(p_team_id uuid)
returns table(
  matches integer, wins integer, losses integer, draws integer,
  points_for integer, points_against integer, events integer
)
language sql
stable
security definer
set search_path = ''
as $$
  with ids as (
    select public.resolve_canonical_team(p_team_id) as id
    union
    select l.alias_team_id from public.team_canonical_links l where l.canonical_team_id = public.resolve_canonical_team(p_team_id)
  ),
  mine as (
    select s.*,
           (s.team1 in (select id from ids)) as is_side1
    from private.official_match_sides() s
    where s.team1 is distinct from s.team2
      and (s.team1 in (select id from ids) or s.team2 in (select id from ids))
  )
  select
    count(*)::integer,
    count(*) filter (where (rs ->> 'winnerSide') = case when is_side1 then '1' else '2' end)::integer,
    count(*) filter (where (rs ->> 'winnerSide') = case when is_side1 then '2' else '1' end)::integer,
    count(*) filter (where (rs ->> 'winnerSide') is null)::integer,
    coalesce(sum(coalesce((rs ->> case when is_side1 then 'side1Total' else 'side2Total' end)::numeric, 0)), 0)::integer,
    coalesce(sum(coalesce((rs ->> case when is_side1 then 'side2Total' else 'side1Total' end)::numeric, 0)), 0)::integer,
    count(distinct event_id)::integer
  from mine
$$;

create or replace function public.official_event_stats(p_event_id uuid)
returns table(
  participants integer, teams integer, matches integer,
  completed_matches integer, finalized_matches integer, official_results integer, formats text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select count(*)::integer from public.event_roster_entries re where re.event_id = p_event_id and re.entry_type = 'fighter' and private.event_is_public(p_event_id)),
    (select count(distinct re.team_id)::integer from public.event_roster_entries re where re.event_id = p_event_id and re.team_id is not null and private.event_is_public(p_event_id)),
    (select count(*)::integer from public.matches m where m.event_id = p_event_id and m.status <> 'cancelled' and private.event_is_public(p_event_id)),
    (select count(*)::integer from public.matches m where m.event_id = p_event_id and m.status in ('completed', 'finalized', 'forfeit') and private.event_is_public(p_event_id)),
    (select count(*)::integer from public.matches m where m.event_id = p_event_id and m.status = 'finalized' and private.event_is_public(p_event_id)),
    (select count(*)::integer from private.official_match_sides() s where s.event_id = p_event_id),
    coalesce((select array_agg(distinct s.category order by s.category) from private.official_match_sides() s where s.event_id = p_event_id), '{}'::text[])
$$;

-- Native result provenance: which event, which ruleset snapshot, when finalized, and whether an audit trail exists.
create or replace function public.official_match_provenance(p_match_id uuid)
returns table(match_id uuid, event_id uuid, ruleset_snapshot_id uuid, finalized_at timestamptz, audit_recorded boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select m.id, m.event_id, m.ruleset_snapshot_id, m.finalized_at,
         exists (select 1 from public.audit_log a where a.table_name = 'matches' and a.record_id = m.id)
  from public.matches m
  where m.id = p_match_id
    and m.status = 'finalized'
    and private.event_is_public(m.event_id)
$$;

revoke all on function private.official_match_sides() from public, anon, authenticated;
revoke all on function public.official_team_stats(uuid) from public;
revoke all on function public.official_event_stats(uuid) from public;
revoke all on function public.official_match_provenance(uuid) from public;
grant execute on function public.official_team_stats(uuid) to anon, authenticated;
grant execute on function public.official_event_stats(uuid) to anon, authenticated;
grant execute on function public.official_match_provenance(uuid) to anon, authenticated;
