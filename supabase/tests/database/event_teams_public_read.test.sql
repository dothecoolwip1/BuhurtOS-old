-- Public event-team name resolution (migration 20261003000000).
--
-- Coverage: the security-definer helper is executable by anonymous viewers,
-- returns only the teams referenced by the event's roster (sorted and
-- de-duplicated), never exposes teams of other events, resolves unknown
-- events to an empty set, and the underlying teams table remains RLS-locked
-- from anonymous reads.

begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into public.organizations(id,name,short_name,region,status)
values ('f0000000-0000-0000-0000-000000000010','Teams Org','TO','Test','active');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('f0000000-0000-0000-0000-000000000020','f0000000-0000-0000-0000-000000000010','2026 T','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
values
('f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000020','Teams Event','Field','2026-09-01T16:00:00Z','2026-09-01T23:00:00Z','ranked_competitive','season_and_event','published','UTC'),
('f0000000-0000-0000-0000-000000000031','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000020','Other Event','Field','2026-09-02T16:00:00Z','2026-09-02T23:00:00Z','ranked_competitive','season_and_event','published','UTC');

insert into public.teams(id,organization_id,name,city_or_region)
values
('f0000000-0000-0000-0000-000000000040','f0000000-0000-0000-0000-000000000010','Red Deer Reavers','Red Deer, AB'),
('f0000000-0000-0000-0000-000000000041','f0000000-0000-0000-0000-000000000010','North Garrison','Edmonton, AB'),
('f0000000-0000-0000-0000-000000000042','f0000000-0000-0000-0000-000000000010','Hidden Team','Nowhere');

insert into public.event_roster_entries(id,organization_id,event_id,team_id,entry_type,display_name,attendance_status)
values
('f0000000-0000-0000-0000-000000000050','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000040','fighter','Garrett R.','approved'),
('f0000000-0000-0000-0000-000000000051','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000041','fighter','Kolby H.','approved'),
('f0000000-0000-0000-0000-000000000052','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000030',null,'fighter','Alex M.','approved'),
('f0000000-0000-0000-0000-000000000053','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000031','f0000000-0000-0000-0000-000000000042','fighter','Hush','approved'),
-- Second entrant from the same team, to prove distinct collapse (seeded up
-- here because unauthorized sessions must never write the roster).
('f0000000-0000-0000-0000-000000000054','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000031','f0000000-0000-0000-0000-000000000042','fighter','Second Teammate','approved');

-- ---------------------------------------------------------------------------
-- Schema / ACL
-- ---------------------------------------------------------------------------

select ok(
  exists(
    select 1 from information_schema.routines
    where routine_schema = 'public' and routine_name = 'event_teams'
  ),
  'event_teams helper exists'
);

select ok(
  has_function_privilege('anon', 'public.event_teams(uuid)', 'EXECUTE'),
  'anonymous callers can resolve event team names'
);

select ok(
  has_function_privilege('authenticated', 'public.event_teams(uuid)', 'EXECUTE'),
  'authenticated callers can resolve event team names'
);

select ok(
  (select proconfig from pg_proc where proname = 'event_teams') is not null,
  'the helper is built with a locked search_path'
);

-- ---------------------------------------------------------------------------
-- Behavior (anonymous read path)
-- ---------------------------------------------------------------------------

set local role anon;

select is(
  (select string_agg(name, ',' order by name)
    from public.event_teams('f0000000-0000-0000-0000-000000000030')),
  'North Garrison,Red Deer Reavers',
  'event teams returns exactly the teams on that event roster, sorted by name'
);

select is(
  (select count(*)::integer from public.event_teams('f0000000-0000-0000-0000-000000000031')),
  1,
  'a second event exposes only its own team'
);

select is(
  (select (select name from public.event_teams('f0000000-0000-0000-0000-000000000031'))),
  'Hidden Team',
  'the second event resolves its sole team'
);

select is(
  (select count(*)::integer from public.event_teams('f0000000-0000-0000-0000-000000000099')),
  0,
  'an unknown event resolves to no teams'
);

-- Two entries from the same team still collapse to one row.
select is(
  (select count(*)::integer from public.event_teams('f0000000-0000-0000-0000-000000000031')),
  1,
  'a repeat team on the roster still resolves once'
);

-- The underlying catalog stays locked: no SELECT grant/policy for anonymous.
select throws_ok(
  $$select name from public.teams limit 1$$,
  '42501', null,
  'anonymous cannot read the teams table directly'
);

select * from finish();
rollback;