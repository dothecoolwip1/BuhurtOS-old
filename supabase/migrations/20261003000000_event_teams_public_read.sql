-- Public read surface for team names referenced by an event's roster.
--
-- The public board already publishes each roster entry's team_id, but the
-- teams table itself sits behind org-scoped RLS. This security-definer
-- helper discloses only the names/locations of teams that actually field
-- entries at a given event, so team standings and public schedule surfaces
-- can resolve names without leaking the org-wide team catalog.

create or replace function public.event_teams(p_event_id uuid)
returns table (
  id uuid,
  name text,
  city_or_region text
)
language sql
security definer
set search_path = ''
as $$
  select distinct t.id, t.name, t.city_or_region
  from public.event_roster_entries re
  join public.teams t on t.id = re.team_id
  where re.event_id = p_event_id
    and re.team_id is not null
  order by t.name;
$$;

revoke all on function public.event_teams(uuid) from public;
grant execute on function public.event_teams(uuid) to anon, authenticated;

comment on function public.event_teams(uuid) is
  'Resolves the name and location of each team that fields a roster entry at '
  'the given event. Scoped to the event roster: public viewers see only teams '
  'the event already publishes.';