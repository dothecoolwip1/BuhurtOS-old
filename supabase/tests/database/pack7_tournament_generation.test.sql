begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (
  id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
('71000000-0000-0000-0000-000000000001','authenticated','authenticated','pack7-admin@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Pack 7 Admin"}',timezone('utc',now()),timezone('utc',now())),
('72000000-0000-0000-0000-000000000001','authenticated','authenticated','pack7-other@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Pack 7 Other"}',timezone('utc',now()),timezone('utc',now()));

insert into public.organizations(id,name,short_name,region,status)
values
('71000000-0000-0000-0000-000000000010','Pack Seven Org','P7','Test','active'),
('72000000-0000-0000-0000-000000000010','Other Pack Seven Org','P7O','Other','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000001','organization_admin'),
('72000000-0000-0000-0000-000000000010','72000000-0000-0000-0000-000000000001','organization_admin');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values
('71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000010','Pack 7 Season',timezone('utc',now())-interval '1 year',timezone('utc',now())+interval '1 year','active');

insert into public.events(
  id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone
) values (
  '71000000-0000-0000-0000-000000000030',
  '71000000-0000-0000-0000-000000000010',
  '71000000-0000-0000-0000-000000000020',
  'Pack 7 Tournament','Arena',
  timezone('utc',now())+interval '30 days',timezone('utc',now())+interval '31 days',
  'ranked_competitive','season_and_event','draft','UTC'
);

insert into public.event_memberships(event_id,user_id,role)
values('71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000001','event_organizer');

insert into public.event_roster_entries(
  id,organization_id,event_id,entry_type,display_name,
  checked_in,armor_cleared,medical_cleared,waiver_confirmed,weigh_in_cleared,
  competition_cleared,attendance_status,metadata
) values
('71000000-0000-0000-0000-000000000101','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','fighter','Alpha',true,true,true,true,true,true,'approved','{}'),
('71000000-0000-0000-0000-000000000102','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','fighter','Bravo',true,true,true,true,true,true,'approved','{}'),
('71000000-0000-0000-0000-000000000103','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000030','fighter','Withdrawn',true,true,true,true,true,true,'approved','{}');

set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$select public.save_bracket_plan(
    '{
      "id":"71000000-0000-0000-0000-000000000200",
      "eventId":"71000000-0000-0000-0000-000000000030",
      "fightCardId":"",
      "divisionId":"",
      "name":"Pack 7 Published Draw",
      "format":"single_elimination",
      "category":"Longsword",
      "metadata":{
        "generationHash":"abc12345",
        "generationConfig":{
          "seedMethod":"manual",
          "seedValues":{
            "71000000-0000-0000-0000-000000000101":1,
            "71000000-0000-0000-0000-000000000102":2
          },
          "entrantSeeds":[
            {"rosterEntryId":"71000000-0000-0000-0000-000000000101","seed":1},
            {"rosterEntryId":"71000000-0000-0000-0000-000000000102","seed":2}
          ]
        },
        "tiebreakPolicy":["standing_points","wins","head_to_head","differential","points_for","seed"]
      }
    }'::jsonb,
    '[
      {
        "id":"71000000-0000-0000-0000-000000000201",
        "fightCardId":"",
        "label":"Final",
        "category":"Longsword",
        "matchType":"longsword",
        "scoringConfig":{"kind":"duel","roundsRequired":1,"allowDrawRound":false},
        "status":"scheduled",
        "stage":"final",
        "scheduledOrder":1,
        "bracketRound":1,
        "bracketSlot":"1-1",
        "participants":[
          {"rosterEntryId":"71000000-0000-0000-0000-000000000101","sideIndex":1,"seed":1},
          {"rosterEntryId":"71000000-0000-0000-0000-000000000102","sideIndex":2,"seed":2}
        ]
      }
    ]'::jsonb
  )$$,
  'organizer can publish a validated tournament plan'
);

select is(
  (select generation_method from public.brackets where id='71000000-0000-0000-0000-000000000200'),
  'manual',
  'published bracket stores its seeding method'
);

select is(
  (select generation_hash from public.brackets where id='71000000-0000-0000-0000-000000000200'),
  'abc12345',
  'published bracket stores its generation hash'
);

select is(
  (select tiebreak_policy->>2 from public.brackets where id='71000000-0000-0000-0000-000000000200'),
  'head_to_head',
  'published bracket stores the explicit tiebreak order'
);

select ok(
  (select published_at is not null from public.brackets where id='71000000-0000-0000-0000-000000000200'),
  'published generation receives publication provenance'
);

select throws_ok(
  $$update public.brackets
    set name='Silent Rewrite'
    where id='71000000-0000-0000-0000-000000000200'$$,
  'P0001',
  'Published tournament structures are immutable; create a replacement bracket instead',
  'published tournament metadata cannot be rewritten in place'
);

select throws_ok(
  $$delete from public.brackets
    where id='71000000-0000-0000-0000-000000000200'$$,
  'P0001',
  'Published tournament structures are historical records and cannot be deleted',
  'published tournament history cannot be deleted'
);

select throws_ok(
  $$select public.save_bracket_plan(
    '{"id":"71000000-0000-0000-0000-000000000200","eventId":"71000000-0000-0000-0000-000000000030","fightCardId":"","divisionId":"","name":"Replacement","format":"single_elimination","category":"Longsword","metadata":{}}'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000202","label":"Final","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"final","scheduledOrder":1,"participants":[]}]'::jsonb
  )$$,
  'P0001',
  'Bracket ID already exists; published brackets cannot be regenerated in place',
  'repeated generation cannot replace an existing bracket ID'
);

select throws_ok(
  $$select public.save_bracket_plan(
    '{"id":"71000000-0000-0000-0000-000000000210","eventId":"71000000-0000-0000-0000-000000000030","fightCardId":"","divisionId":"","name":"Bad Dependency","format":"single_elimination","category":"Longsword","metadata":{}}'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000211","label":"Opening","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"bracket","scheduledOrder":1,"winnerAdvancesToMatchId":"71000000-0000-0000-0000-000000000299","winnerAdvancesToSlot":1,"participants":[]}]'::jsonb
  )$$,
  'P0001',
  'Winner advancement references a missing match',
  'invalid advancement dependency is rejected before publication'
);

select throws_ok(
  $$select public.save_bracket_plan(
    '{"id":"71000000-0000-0000-0000-000000000220","eventId":"71000000-0000-0000-0000-000000000030","fightCardId":"","divisionId":"","name":"Duplicate Entrant","format":"single_elimination","category":"Longsword","metadata":{}}'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000221","label":"Final","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"final","scheduledOrder":1,"participants":[{"rosterEntryId":"71000000-0000-0000-0000-000000000101","sideIndex":1},{"rosterEntryId":"71000000-0000-0000-0000-000000000101","sideIndex":2}]}]'::jsonb
  )$$,
  'P0001',
  'A match cannot contain the same competitor on both sides',
  'a competitor cannot occupy both sides of one match'
);

select throws_ok(
  $$select public.save_bracket_plan(
    '{"id":"71000000-0000-0000-0000-000000000230","eventId":"71000000-0000-0000-0000-000000000030","fightCardId":"","divisionId":"","name":"Unrecorded Random","format":"single_elimination","category":"Longsword","metadata":{"generationConfig":{"seedMethod":"random"}}}'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000231","label":"Final","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"final","scheduledOrder":1,"participants":[]}]'::jsonb
  )$$,
  'P0001',
  'Random tournament generation requires a recorded seed',
  'random publication is rejected unless its seed is recorded'
);

select lives_ok(
  $$select public.save_bracket_plan(
    '{
      "id":"71000000-0000-0000-0000-000000000250",
      "eventId":"71000000-0000-0000-0000-000000000030",
      "fightCardId":"",
      "divisionId":"",
      "name":"Pack 7 Replacement Draw",
      "format":"single_elimination",
      "category":"Longsword",
      "metadata":{
        "supersedesBracketId":"71000000-0000-0000-0000-000000000200",
        "generationHash":"replacement1",
        "generationConfig":{"seedMethod":"manual"}
      }
    }'::jsonb,
    '[
      {
        "id":"71000000-0000-0000-0000-000000000251",
        "label":"Replacement Final",
        "category":"Longsword",
        "matchType":"longsword",
        "scoringConfig":{"kind":"duel","roundsRequired":1,"allowDrawRound":false},
        "status":"scheduled",
        "stage":"final",
        "scheduledOrder":1,
        "participants":[
          {"rosterEntryId":"71000000-0000-0000-0000-000000000101","sideIndex":1,"seed":1},
          {"rosterEntryId":"71000000-0000-0000-0000-000000000102","sideIndex":2,"seed":2}
        ]
      }
    ]'::jsonb
  )$$,
  'an unstarted published draw can be safely replaced without deleting history'
);

select is(
  (select generation_state from public.brackets where id='71000000-0000-0000-0000-000000000200'),
  'superseded',
  'replaced draw is retained as superseded history'
);

select is(
  (select status::text from public.matches where id='71000000-0000-0000-0000-000000000201'),
  'cancelled',
  'unstarted matches from the superseded draw are closed'
);

update public.matches
set status='active'
where id='71000000-0000-0000-0000-000000000251';

select throws_ok(
  $$select public.save_bracket_plan(
    '{
      "id":"71000000-0000-0000-0000-000000000260",
      "eventId":"71000000-0000-0000-0000-000000000030",
      "fightCardId":"",
      "divisionId":"",
      "name":"Forbidden Rewrite",
      "format":"single_elimination",
      "category":"Longsword",
      "metadata":{"supersedesBracketId":"71000000-0000-0000-0000-000000000250"}
    }'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000261","label":"Final","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"final","scheduledOrder":1,"participants":[]}]'::jsonb
  )$$,
  'P0001',
  'Tournament has recorded competition and cannot be regenerated',
  'regeneration is blocked after real competition has started'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000001',true);

select throws_ok(
  $$select public.save_bracket_plan(
    '{"id":"71000000-0000-0000-0000-000000000240","eventId":"71000000-0000-0000-0000-000000000030","fightCardId":"","divisionId":"","name":"Cross Org","format":"single_elimination","category":"Longsword","metadata":{}}'::jsonb,
    '[{"id":"71000000-0000-0000-0000-000000000241","label":"Final","category":"Longsword","matchType":"longsword","scoringConfig":{"kind":"duel","roundsRequired":1},"status":"scheduled","stage":"final","scheduledOrder":1,"participants":[]}]'::jsonb
  )$$,
  'P0001',
  'Event not found',
  'administrator from another organization cannot see or publish another organization tournament'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);
select set_config(
  'pack7.bravo_updated',
  (select updated_at::text from public.event_roster_entries where id='71000000-0000-0000-0000-000000000102'),
  false
);

select throws_ok(
  $$select public.set_tournament_disqualification_guarded(
    '71000000-0000-0000-0000-000000000102',
    current_setting('pack7.bravo_updated')::timestamptz,
    true,
    null
  )$$,
  'P0001',
  'Disqualification reason is required',
  'tournament disqualification requires an auditable reason'
);

select lives_ok(
  $$select public.set_tournament_disqualification_guarded(
    '71000000-0000-0000-0000-000000000102',
    current_setting('pack7.bravo_updated')::timestamptz,
    true,
    'unsafe conduct'
  )$$,
  'authorized marshal scope can disqualify an entrant'
);

select ok(
  (select metadata->>'tournamentDisqualified'='true' and not competition_cleared
   from public.event_roster_entries where id='71000000-0000-0000-0000-000000000102'),
  'disqualification is explicit and revokes final competition clearance'
);

select throws_ok(
  $$select public.set_tournament_disqualification_guarded(
    '71000000-0000-0000-0000-000000000102',
    '2000-01-01T00:00:00Z'::timestamptz,
    false,
    null
  )$,
  'P0001',
  'Roster entry changed on another device',
  'stale disqualification changes are rejected'
);

select lives_ok(
  format(
    'select public.set_tournament_disqualification_guarded(%L::uuid,%L::timestamptz,false,null)',
    '71000000-0000-0000-0000-000000000102',
    (select updated_at::text from public.event_roster_entries where id='71000000-0000-0000-0000-000000000102')
  ),
  'disqualification can be cleared without restoring competition clearance'
);

select ok(
  (select metadata->>'tournamentDisqualified'='false' and not competition_cleared
   from public.event_roster_entries where id='71000000-0000-0000-0000-000000000102'),
  'clearing DQ still requires a fresh final competition clearance'
);

reset role;

insert into public.brackets(
  id,event_id,name,format,category,generation_state,generation_method,published_at
) values (
  '71000000-0000-0000-0000-000000000300',
  '71000000-0000-0000-0000-000000000030',
  'Walkover Bracket','double_elimination','Longsword','published','manual',timezone('utc',now())
);

insert into public.matches(
  id,organization_id,season_id,event_id,bracket_id,label,category,match_type,
  scoring_config,status,stage,scheduled_order,bracket_round,bracket_slot
) values
('71000000-0000-0000-0000-000000000302','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000300','Winner Target','Longsword','longsword','{"kind":"duel","roundsRequired":1,"requireReasonOnForfeit":true}','scheduled','bracket',2,2,'2-1'),
('71000000-0000-0000-0000-000000000303','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000300','Lower Target','Longsword','longsword','{"kind":"duel","roundsRequired":1,"requireReasonOnForfeit":true}','scheduled','bracket',3,2,'L1-1');

insert into public.matches(
  id,organization_id,season_id,event_id,bracket_id,label,category,match_type,
  scoring_config,status,stage,scheduled_order,bracket_round,bracket_slot,
  winner_advances_to_match_id,winner_advances_to_slot,loser_advances_to_match_id,loser_advances_to_slot
) values (
  '71000000-0000-0000-0000-000000000301',
  '71000000-0000-0000-0000-000000000010',
  '71000000-0000-0000-0000-000000000020',
  '71000000-0000-0000-0000-000000000030',
  '71000000-0000-0000-0000-000000000300',
  'Walkover Opening','Longsword','longsword',
  '{"kind":"duel","roundsRequired":1,"requireReasonOnForfeit":true}',
  'active','bracket',1,1,'1-1',
  '71000000-0000-0000-0000-000000000302',1,
  '71000000-0000-0000-0000-000000000303',1
);

insert into public.match_participants(match_id,roster_entry_id,side_index,seed,is_placeholder)
values
('71000000-0000-0000-0000-000000000301','71000000-0000-0000-0000-000000000101',1,1,false),
('71000000-0000-0000-0000-000000000301','71000000-0000-0000-0000-000000000103',2,2,false);

update public.event_roster_entries
set attendance_status='withdrawn'
where id='71000000-0000-0000-0000-000000000103';

set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$select public.submit_match_result(
    '71000000-0000-0000-0000-000000000301',
    '[]'::jsonb,
    2,
    'competitor withdrew',
    'active'
  )$$,
  'withdrawn competitor can be recorded as a walkover without blocking the result'
);

select is(
  (select result_summary->>'resultType' from public.matches where id='71000000-0000-0000-0000-000000000301'),
  'forfeit',
  'walkover is preserved as a forfeit result'
);

select is(
  (select count(*)::integer from public.match_participants where match_id='71000000-0000-0000-0000-000000000302' and roster_entry_id='71000000-0000-0000-0000-000000000101'),
  1,
  'available walkover winner advances'
);

select is(
  (select count(*)::integer from public.match_participants where match_id='71000000-0000-0000-0000-000000000303'),
  0,
  'withdrawn walkover loser is not advanced into the lower bracket'
);

select throws_ok(
  $select public.submit_match_result(
    '71000000-0000-0000-0000-000000000301',
    '[]'::jsonb,
    2,
    'duplicate progression attempt',
    'active'
  )$,
  'P0001',
  'Match changed since it was loaded',
  'a repeated stale progression attempt cannot advance the bracket twice'
);

select * from finish();
rollback;
