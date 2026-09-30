-- Pack 7 canonical stats, provenance and source reconciliation (migration 20261017000000).
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (
  id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
('71000000-0000-0000-0000-000000000001','authenticated','authenticated','stats-super@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Stats Super"}',timezone('utc',now()),timezone('utc',now())),
('71000000-0000-0000-0000-000000000002','authenticated','authenticated','stats-admin@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Stats Admin"}',timezone('utc',now()),timezone('utc',now()));

insert into public.platform_memberships(user_id, role)
values ('71000000-0000-0000-0000-000000000001', 'platform_super_admin');

insert into public.organizations(id,name,short_name,region,status)
values ('71000000-0000-0000-0000-000000000010','Stats Org','SO','Test','active');

insert into public.organization_memberships(organization_id,user_id,role)
values ('71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000002','organization_admin');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000010','Stats Season','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at)
values
('71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','Public Stats Event','Field','2026-06-01T16:00:00Z','2026-06-01T23:00:00Z','tournament','season_and_event','published','UTC',now()),
('71000000-0000-0000-0000-000000000031','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','Draft Stats Event','Field','2026-07-01T16:00:00Z','2026-07-01T23:00:00Z','tournament','season_and_event','draft','UTC',null);

insert into public.teams(id,organization_id,name,city_or_region,visibility)
values
('71000000-0000-0000-0000-000000000040','71000000-0000-0000-0000-000000000010','Team Alpha','Red Deer','public'),
('71000000-0000-0000-0000-000000000041','71000000-0000-0000-0000-000000000010','Team Bravo','Calgary','public'),
('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000010','Alpha (BI duplicate)','Red Deer, AB','public');

insert into public.event_roster_entries(id,organization_id,event_id,team_id,entry_type,display_name,attendance_status)
values
('71000000-0000-0000-0000-000000000050','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000040','fighter','Alpha One','approved'),
('71000000-0000-0000-0000-000000000051','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000041','fighter','Bravo One','approved'),
('71000000-0000-0000-0000-000000000052','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000040','fighter','Alpha Two','approved'),
('71000000-0000-0000-0000-000000000053','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000042','fighter','Duplicate One','approved'),
('71000000-0000-0000-0000-000000000054','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000031','71000000-0000-0000-0000-000000000040','fighter','Draft Alpha','approved'),
('71000000-0000-0000-0000-000000000055','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000031','71000000-0000-0000-0000-000000000041','fighter','Draft Bravo','approved');

-- m1 A beats B 5-3 (counts) | m2 B beats A 4-2 (counts) | m3 completed, not finalized (excluded)
-- m4 finalized bye (excluded) | m5 intra-team A v A (official result, no team stats)
-- m6 finalized draw 1-1 (counts) | m7 finalized but in a draft event (excluded)
-- m8 finalized with no recorded winnerSide (excluded) | m9 alias team C beats B (counts after linking)
insert into public.matches(id,organization_id,season_id,event_id,label,category,match_type,status,result_summary,finalized_at)
values
('71000000-0000-0000-0000-000000000060','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m1','duel','duel','finalized','{"winnerSide":1,"side1Total":5,"side2Total":3,"resultType":"points"}',now()),
('71000000-0000-0000-0000-000000000061','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m2','duel','duel','finalized','{"winnerSide":2,"side1Total":2,"side2Total":4,"resultType":"points"}',now()),
('71000000-0000-0000-0000-000000000062','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m3','duel','duel','completed','{"winnerSide":1,"side1Total":9,"side2Total":0,"resultType":"points"}',null),
('71000000-0000-0000-0000-000000000063','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m4','duel','duel','finalized','{"winnerSide":1,"side1Total":0,"side2Total":0,"resultType":"bye"}',now()),
('71000000-0000-0000-0000-000000000064','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m5','duel','duel','finalized','{"winnerSide":1,"side1Total":3,"side2Total":1,"resultType":"points"}',now()),
('71000000-0000-0000-0000-000000000065','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m6','duel','duel','finalized','{"winnerSide":null,"side1Total":1,"side2Total":1,"resultType":"draw"}',now()),
('71000000-0000-0000-0000-000000000066','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000031','m7','duel','duel','finalized','{"winnerSide":1,"side1Total":5,"side2Total":0,"resultType":"points"}',now()),
('71000000-0000-0000-0000-000000000067','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m8','duel','duel','finalized','{}',now()),
('71000000-0000-0000-0000-000000000068','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','m9','melee','melee','finalized','{"winnerSide":1,"side1Total":6,"side2Total":2,"resultType":"points"}',now());

-- side 1 / side 2 roster entries per match
insert into public.match_participants(match_id,roster_entry_id,side_index)
values
('71000000-0000-0000-0000-000000000060','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000060','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000061','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000061','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000062','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000062','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000063','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000063','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000064','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000064','71000000-0000-0000-0000-000000000052',2),
('71000000-0000-0000-0000-000000000065','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000065','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000066','71000000-0000-0000-0000-000000000054',1),('71000000-0000-0000-0000-000000000066','71000000-0000-0000-0000-000000000055',2),
('71000000-0000-0000-0000-000000000067','71000000-0000-0000-0000-000000000050',1),('71000000-0000-0000-0000-000000000067','71000000-0000-0000-0000-000000000051',2),
('71000000-0000-0000-0000-000000000068','71000000-0000-0000-0000-000000000053',1),('71000000-0000-0000-0000-000000000068','71000000-0000-0000-0000-000000000051',2);

insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_priority,verified_at)
values
('71000000-0000-0000-0000-000000000040','hacsa','pack7-alpha','https://example.test/hacsa/alpha','Team Alpha',1,'2026-09-29T00:00:00Z'),
('71000000-0000-0000-0000-000000000042','bi_teams','pack7-alpha-bi','https://example.test/bi/alpha','Alpha Buhurt',2,'2026-09-28T00:00:00Z');

-- Anonymous spectators read official stats; only finalized valid results count.
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  (select matches from public.official_team_stats('71000000-0000-0000-0000-000000000040')),
  3,
  'team Alpha has 3 official matches (non-finalized, byes, draft events, missing winners and intra-team bouts excluded)'
);
select is(
  (select wins || '-' || losses || '-' || draws from public.official_team_stats('71000000-0000-0000-0000-000000000040')),
  '1-1-1',
  'team Alpha record is 1 win, 1 loss, 1 draw'
);
select is(
  (select points_for || '/' || points_against from public.official_team_stats('71000000-0000-0000-0000-000000000040')),
  '8/8',
  'points for and against come only from official results'
);
select is(
  (select events from public.official_team_stats('71000000-0000-0000-0000-000000000040')),
  1,
  'event history counts only public events'
);
select is(
  (select wins || '-' || losses || '-' || draws from public.official_team_stats('71000000-0000-0000-0000-000000000041')),
  '1-2-1',
  'team Bravo sees the same official bouts from the other side, including the bout against the duplicate Alpha row'
);

select is(
  (select finalized_matches from public.official_event_stats('71000000-0000-0000-0000-000000000030')),
  7,
  'event stats count finalized matches'
);
select is(
  (select official_results from public.official_event_stats('71000000-0000-0000-0000-000000000030')),
  5,
  'only valid finalized two-sided results are official'
);
select is(
  (select completed_matches from public.official_event_stats('71000000-0000-0000-0000-000000000030')),
  8,
  'completed includes finalized and completed matches'
);
select is(
  (select formats from public.official_event_stats('71000000-0000-0000-0000-000000000030')),
  array['duel','melee'],
  'event formats come from official results'
);
select is(
  (select participants from public.official_event_stats('71000000-0000-0000-0000-000000000031')),
  0,
  'draft events expose no stats to the public'
);

select is(
  (select count(*)::integer from public.official_match_provenance('71000000-0000-0000-0000-000000000060')),
  1,
  'a finalized public match exposes native provenance'
);
select is(
  (select count(*)::integer from public.official_match_provenance('71000000-0000-0000-0000-000000000062')),
  0,
  'a non-finalized match exposes no provenance'
);

-- Canonical links are controlled by platform super administrators only.
select throws_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000040','same team')$$,
  '42501', null,
  'anonymous users cannot link teams'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000002',true);

select throws_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000040','same team')$$,
  'P0001', 'Only platform super administrators can link duplicate teams',
  'organization administrators cannot link teams'
);
select throws_ok(
  $$insert into public.team_canonical_links(alias_team_id,canonical_team_id,reason) values ('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000040','direct')$$,
  '42501', null,
  'direct link writes are blocked'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);

select throws_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000042','self')$$,
  'P0001', 'A team cannot be linked to itself',
  'a team cannot alias itself'
);
select throws_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000040','')$$,
  'P0001', 'A reason is required',
  'links need a reason'
);
select lives_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000042','71000000-0000-0000-0000-000000000040','Same team listed by HACSA and BI')$$,
  'super administrators can link a duplicate team to its canonical record'
);
select throws_ok(
  $$select public.link_duplicate_team('71000000-0000-0000-0000-000000000040','71000000-0000-0000-0000-000000000042','reverse')$$,
  'P0001', 'The canonical team is itself an alias',
  'links cannot form cycles'
);

reset role;
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  public.resolve_canonical_team('71000000-0000-0000-0000-000000000042'),
  '71000000-0000-0000-0000-000000000040'::uuid,
  'an alias resolves to its canonical team'
);
select is(
  public.resolve_canonical_team('71000000-0000-0000-0000-000000000040'),
  '71000000-0000-0000-0000-000000000040'::uuid,
  'a canonical team resolves to itself'
);
select is(
  (select matches from public.official_team_stats('71000000-0000-0000-0000-000000000040')),
  4,
  'the canonical team now includes the alias official record'
);
select is(
  (select wins || '-' || losses || '-' || draws from public.official_team_stats('71000000-0000-0000-0000-000000000042')),
  '2-1-1',
  'asking for the alias returns the same canonical stats'
);

select is(
  (select count(*)::integer from public.public_team_provenance('71000000-0000-0000-0000-000000000040')),
  2,
  'provenance keeps every source record, including the alias source'
);
select is(
  (select string_agg(source_kind || ':' || is_alias::text, ',' order by source_priority) from public.public_team_provenance('71000000-0000-0000-0000-000000000040')),
  'hacsa:false,bi_teams:true',
  'provenance shows source kind, priority order and alias status'
);
select is(
  (select source_team_name from public.public_team_provenance('71000000-0000-0000-0000-000000000042') where source_kind = 'bi_teams'),
  'Alpha Buhurt',
  'conflicting source names are preserved, never overwritten'
);

select throws_ok(
  $$select * from public.team_source_records$$,
  '42501', null,
  'raw source records remain private to anonymous users'
);

reset role;
select * from finish();
rollback;
