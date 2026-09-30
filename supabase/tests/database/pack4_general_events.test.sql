-- Pack 4 general event model (migration 20261014000000).
begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into public.organizations(id,name,short_name,region,status)
values ('f4000000-0000-0000-0000-000000000010','Events Org','EO','Test','active');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('f4000000-0000-0000-0000-000000000020','f4000000-0000-0000-0000-000000000010','2026 E','2026-01-01','2026-12-31','active');

insert into public.teams(id,organization_id,name,city_or_region)
values ('f4000000-0000-0000-0000-000000000040','f4000000-0000-0000-0000-000000000010','Host Team','Red Deer');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,host_team_id,notes)
values
('f4000000-0000-0000-0000-000000000030','f4000000-0000-0000-0000-000000000010','f4000000-0000-0000-0000-000000000020','Spring AGM','Hall','2026-05-01T16:00:00Z','2026-05-01T18:00:00Z','meeting_agm','no_standings','published','UTC',now(),'f4000000-0000-0000-0000-000000000040','private note'),
('f4000000-0000-0000-0000-000000000031','f4000000-0000-0000-0000-000000000010','f4000000-0000-0000-0000-000000000020','Legacy Competitive','Field','2026-06-01T16:00:00Z','2026-06-01T23:00:00Z','ranked_competitive','season_and_event','published','UTC',now(),null,null),
('f4000000-0000-0000-0000-000000000032','f4000000-0000-0000-0000-000000000010','f4000000-0000-0000-0000-000000000020','Draft Social','Pub','2026-07-01T16:00:00Z','2026-07-01T23:00:00Z','gathering_social','no_standings','draft','UTC',null,null,null);

select ok(
  (select count(*) = 9 from pg_enum e join pg_type t on t.oid = e.enumtypid
    where t.typname = 'event_type'
      and e.enumlabel in ('tournament','demo','training','clinic_workshop','recruitment','fundraiser','gathering_social','meeting_agm','community_appearance')),
  'all nine new event categories exist'
);

select ok(
  (select count(*) = 5 from pg_enum e join pg_type t on t.oid = e.enumtypid
    where t.typname = 'event_type'
      and e.enumlabel in ('ranked_competitive','demo_fun','exhibition','clinic_training','custom')),
  'legacy event_type labels are preserved'
);

select is(
  (select event_type::text from public.events where id = 'f4000000-0000-0000-0000-000000000031'),
  'ranked_competitive',
  'existing event rows keep their legacy type'
);

select is(
  (select slug from public.events where id = 'f4000000-0000-0000-0000-000000000030'),
  'spring-agm-f4000000',
  'new events receive a stable slug automatically'
);

select throws_ok(
  $$update public.events set slug = 'Bad Slug' where id = 'f4000000-0000-0000-0000-000000000030'$$,
  '23514', null,
  'slug format is enforced'
);

select throws_ok(
  $$update public.events set slug = 'legacy-competitive-f4000000' where id = 'f4000000-0000-0000-0000-000000000030'$$,
  '23505', null,
  'slugs are unique'
);

select is(public.event_type_is_competitive('tournament'), true, 'tournament is competitive');
select is(public.event_type_is_competitive('ranked_competitive'), true, 'legacy ranked_competitive is competitive');
select is(public.event_type_is_competitive('meeting_agm'), false, 'meeting is not competitive');
select is(public.event_type_is_competitive('gathering_social'), false, 'gathering is not competitive');

reset role;
set local role anon;

select is(
  (select count(*)::integer from public.events where id in ('f4000000-0000-0000-0000-000000000030','f4000000-0000-0000-0000-000000000031','f4000000-0000-0000-0000-000000000032')),
  2,
  'anonymous viewers see published events only, including new categories'
);

select is(
  (select host_team_id::text from public.events where id = 'f4000000-0000-0000-0000-000000000030'),
  'f4000000-0000-0000-0000-000000000040',
  'anonymous viewers can read the host team and slug columns'
);

select throws_ok(
  $$select notes from public.events limit 1$$,
  '42501', null,
  'private event notes stay hidden from anonymous viewers'
);

reset role;
select * from finish();
rollback;
