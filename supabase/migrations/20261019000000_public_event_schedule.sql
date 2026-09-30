-- Public planned schedule for published events.
--
-- Organizers save planned bout times in brackets.metadata.schedule when they publish a tournament. Anonymous visitors cannot
-- read the brackets table (select is revoked), so this function exposes only what a spectator needs: which bout, which field
-- and the planned start and end. It returns nothing for events that are not public, nothing for cancelled bouts, and never
-- exposes bracket metadata itself (seeding, draw codes, warnings).

create or replace function public.public_event_schedule(p_event_id uuid)
returns table (
  match_id uuid,
  area_id uuid,
  area_name text,
  starts_at timestamptz,
  ends_at timestamptz,
  sort_order integer
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    m.id,
    m.fight_card_id,
    fc.name,
    (slot.value->>'startsAt')::timestamptz,
    (slot.value->>'endsAt')::timestamptz,
    coalesce((slot.value->>'order')::integer, m.scheduled_order)
  from public.brackets b
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(b.metadata->'schedule'->'slots') = 'array' then b.metadata->'schedule'->'slots' else '[]'::jsonb end
  ) as slot(value)
  join public.matches m
    on m.id::text = slot.value->>'matchId'
   and m.event_id = b.event_id
  left join public.fight_cards fc
    on fc.id = m.fight_card_id
   and fc.event_id = b.event_id
   and fc.status::text <> 'archived'
  where b.event_id = p_event_id
    and b.generation_state = 'published'
    and private.event_is_public(p_event_id)
    and m.status::text <> 'cancelled'
    and slot.value->>'startsAt' ~ '^\d{4}-\d{2}-\d{2}T'
    and slot.value->>'endsAt' ~ '^\d{4}-\d{2}-\d{2}T'
  order by 6, 4;
$$;

revoke all on function public.public_event_schedule(uuid) from public;
grant execute on function public.public_event_schedule(uuid) to anon, authenticated;

comment on function public.public_event_schedule(uuid) is
  'Planned bout times for a published event. Planned, not live: times do not move as bouts run.';
