-- Public planned schedule (migration 20261019000000).
--
-- Coverage: anonymous callers get the planned slots of a published event joined to real bouts and fields; unpublished events,
-- cancelled bouts, slots pointing at another event's bouts and malformed times yield nothing; bracket metadata stays unreadable.

begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into public.organizations(id,name,short_name,region,status)
values ('a1000000-0000-0000-0000-000000000010','Schedule Org','SO','Test','active');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000010','2026 S','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at)
values
('a1000000-0000-0000-0000-000000000030','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','Public Event','Field','2026-09-01T16:00:00Z','2026-09-01T23:00:00Z','tournament','event_only','published','America/Edmonton',timezone('utc',now())),
('a1000000-0000-0000-0000-000000000031','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','Draft Event','Field','2026-09-02T16:00:00Z','2026-09-02T23:00:00Z','tournament','event_only','draft','America/Edmonton',null);

insert into public.fight_cards(id,event_id,name,list_name,status,sort_order)
values
('a1000000-0000-0000-0000-000000000040','a1000000-0000-0000-0000-000000000030','Ring 1','Ring 1','live',1),
('a1000000-0000-0000-0000-000000000041','a1000000-0000-0000-0000-000000000031','Hidden Ring','Hidden Ring','live',1);

insert into public.brackets(id,event_id,name,format,category,generation_state,generation_method,published_at,metadata)
values
('a1000000-0000-0000-0000-000000000050','a1000000-0000-0000-0000-000000000030','Public Bracket','single_elimination','Longsword','published','manual',timezone('utc',now()),
 jsonb_build_object('drawSecret','do-not-leak','schedule',jsonb_build_object('slots',jsonb_build_array(
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000060','startsAt','2026-09-01T16:00:00Z','endsAt','2026-09-01T16:06:00Z','order',1),
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000061','startsAt','2026-09-01T16:10:00Z','endsAt','2026-09-01T16:16:00Z','order',2),
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000062','startsAt','2026-09-01T16:20:00Z','endsAt','2026-09-01T16:26:00Z','order',3),
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000063','startsAt','not a time','endsAt','2026-09-01T16:36:00Z','order',4),
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000064','startsAt','2026-09-01T16:40:00Z','endsAt','2026-09-01T16:46:00Z','order',5))))),
('a1000000-0000-0000-0000-000000000051','a1000000-0000-0000-0000-000000000031','Draft Bracket','single_elimination','Longsword','published','manual',timezone('utc',now()),
 jsonb_build_object('schedule',jsonb_build_object('slots',jsonb_build_array(
   jsonb_build_object('matchId','a1000000-0000-0000-0000-000000000065','startsAt','2026-09-02T16:00:00Z','endsAt','2026-09-02T16:06:00Z','order',1)))));

insert into public.matches(id,organization_id,season_id,event_id,fight_card_id,bracket_id,label,category,match_type,scoring_config,status,stage,scheduled_order)
values
('a1000000-0000-0000-0000-000000000060','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000030','a1000000-0000-0000-0000-000000000040','a1000000-0000-0000-0000-000000000050','Bout 1','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','scheduled','bracket',1),
('a1000000-0000-0000-0000-000000000061','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000030',null,'a1000000-0000-0000-0000-000000000050','Bout 2','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','scheduled','bracket',2),
('a1000000-0000-0000-0000-000000000062','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000030',null,'a1000000-0000-0000-0000-000000000050','Cancelled bout','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','cancelled','bracket',3),
('a1000000-0000-0000-0000-000000000063','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000030',null,'a1000000-0000-0000-0000-000000000050','Bad time bout','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','scheduled','bracket',4),
('a1000000-0000-0000-0000-000000000064','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000031',null,null,'Other event bout','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','scheduled','bracket',5),
('a1000000-0000-0000-0000-000000000065','a1000000-0000-0000-0000-000000000010','a1000000-0000-0000-0000-000000000020','a1000000-0000-0000-0000-000000000031',null,'a1000000-0000-0000-0000-000000000051','Draft bout','Longsword','longsword','{"kind":"duel","roundsRequired":3,"allowDrawRound":false}','scheduled','bracket',1);

select ok(has_function_privilege('anon', 'public.public_event_schedule(uuid)', 'EXECUTE'), 'anonymous visitors can read the public schedule');

set local role anon;

select is((select count(*)::integer from public.public_event_schedule('a1000000-0000-0000-0000-000000000030')), 2,
  'only real, non-cancelled bouts of this event with valid times are returned');
select is((select string_agg(match_id::text, ',' order by sort_order) from public.public_event_schedule('a1000000-0000-0000-0000-000000000030')),
  'a1000000-0000-0000-0000-000000000060,a1000000-0000-0000-0000-000000000061', 'slots come back in planned order');
select is((select area_name from public.public_event_schedule('a1000000-0000-0000-0000-000000000030') where match_id = 'a1000000-0000-0000-0000-000000000060'),
  'Ring 1', 'the field name is resolved');
select is((select area_name from public.public_event_schedule('a1000000-0000-0000-0000-000000000030') where match_id = 'a1000000-0000-0000-0000-000000000061'),
  null, 'a bout without a field has no area name');
select is((select count(*)::integer from public.public_event_schedule('a1000000-0000-0000-0000-000000000031')), 0,
  'an unpublished event exposes no schedule');
select is((select count(*)::integer from public.public_event_schedule('00000000-0000-0000-0000-000000000000')), 0,
  'an unknown event exposes no schedule');

select throws_ok($$select metadata from public.brackets$$, '42501', null, 'bracket metadata itself remains unreadable to anonymous visitors');

reset role;
select * from finish();
rollback;
