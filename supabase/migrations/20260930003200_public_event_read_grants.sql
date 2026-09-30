-- Public event pages use the anon Supabase client. RLS already limits visible rows,
-- but PostgREST also requires table-level SELECT privileges before RLS is evaluated.
grant select on table public.events to anon;
grant select on table public.announcements to anon;
grant select on table public.fight_cards to anon;
grant select on table public.event_divisions to anon;
grant select on table public.competition_divisions to anon;
grant select on table public.matches to anon;
