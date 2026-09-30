-- Event competitions: a tournament inside an event, source-backed BI reference data, and who may change what.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select v.id::uuid,'authenticated','authenticated',v.email,'',timezone('utc',now()),'{}',('{"display_name":"'||v.name||'"}')::jsonb,timezone('utc',now()),timezone('utc',now())
from (values
  ('71000000-0000-0000-0000-000000000001','ec-admin@buhurtos.test','Comp Org Admin'),
  ('71000000-0000-0000-0000-000000000002','ec-other@buhurtos.test','Other Org Admin')
) as v(id,email,name);

insert into public.organizations(id,name,short_name,region,status) values
 ('71000000-0000-0000-0000-000000000010','EC Org','ECO','Test','active'),
 ('71000000-0000-0000-0000-000000000011','EC Other Org','ECX','Test','active');
insert into public.organization_memberships(organization_id,user_id,role) values
 ('71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000001','organization_admin'),
 ('71000000-0000-0000-0000-000000000011','71000000-0000-0000-0000-000000000002','organization_admin');
insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('71000000-0000-0000-0000-000000000020','71000000-0000-0000-0000-000000000010','EC Season','2026-01-01','2026-12-31','active');
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at) values
 ('71000000-0000-0000-0000-000000000030','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','EC Open','Ranch','2026-11-14T16:00:00Z','2026-11-15T23:00:00Z','custom','no_standings','published','UTC',now()),
 ('71000000-0000-0000-0000-000000000031','71000000-0000-0000-0000-000000000010','71000000-0000-0000-0000-000000000020','EC Draft','Ranch','2026-12-14T16:00:00Z','2026-12-15T23:00:00Z','custom','no_standings','draft','UTC',null);

create temp table t_ids(name text primary key, id uuid);
grant all on t_ids to public;

-- Reference data is seeded from the verified BI documents, and is public.
select ok((select count(*) from public.competition_categories where authority='bi') >= 9, 'BI categories are seeded');
select is((select lead_days from public.ruleset_tier_requirements where authority='bi' and tier='classic'), 45, 'Classic tournaments must be submitted 45 days ahead');
select is((select lead_days from public.ruleset_tier_requirements where authority='bi' and tier='conference'), 120, 'Conference tournaments must be submitted 120 days ahead');
select is((select (requirements->>'sourcesDisagree')::boolean from public.ruleset_tier_requirements where authority='bi' and tier='regional'), true,
  'the conflict between League Structure and Tournament Structure point values is recorded, not hidden');
select is((select count(*)::integer from public.tournament_format_templates where authority='bi' and min_entrants=12 and max_entrants=16), 4,
  'twelve to sixteen entrants offer four structures');
select is((select recommended from public.tournament_format_templates where option_key='pools_12_16_three_se'), false,
  'the document''s not-recommended six-team bracket is marked so');
select is((select jsonb_array_length(steps) from public.tiebreak_policies where authority='bi'), 4, 'the BI tiebreak policy has four ordered steps');

set local role anon;
select ok((select count(*) from public.competition_categories) > 0, 'anonymous visitors can read categories');
select ok((select count(*) from public.rule_documents where family='tournament') >= 2, 'anonymous visitors can read rule document metadata');
select throws_ok($$insert into public.competition_categories(authority,league,key,display_name) values ('x','buhurt','hack','Hack')$$, '42501', null,
  'anonymous visitors cannot write categories');
reset role;

-- One event, several independent competitions, including the same category at two tiers.
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);
insert into t_ids values ('d1', public.upsert_event_competition('71000000-0000-0000-0000-000000000030', null,
  jsonb_build_object('name','Men''s 5v5 Classic D1','league','buhurt','tier','classic','tierClassification','division_1','classification','men',
    'categoryId',(select id from public.competition_categories where authority='bi' and key='5v5'),'rulesVersion','v2026.1','ranked',true,'entrantCap',8)));
insert into t_ids values ('d2', public.upsert_event_competition('71000000-0000-0000-0000-000000000030', null,
  jsonb_build_object('name','Men''s 5v5 Classic D2','league','buhurt','tier','classic','tierClassification','division_2','classification','men',
    'categoryId',(select id from public.competition_categories where authority='bi' and key='5v5'),'rulesVersion','v2026.1','ranked',false)));
insert into t_ids values ('src', public.upsert_event_competition('71000000-0000-0000-0000-000000000030', null,
  jsonb_build_object('name','Women''s Longsword Source','league','duels','tier','source','classification','women',
    'categoryId',(select id from public.competition_categories where authority='bi' and key='longsword'))));
select is((select count(*)::integer from public.event_competitions where event_id='71000000-0000-0000-0000-000000000030'), 3,
  'one event holds three competitions, two of them the same category at different tiers');

select lives_ok($$select public.upsert_event_competition('71000000-0000-0000-0000-000000000030',(select id from t_ids where name='d1'),
  '{"formatSelection":{"rulesVersion":"Jan 2026","entrantCount":8,"optionKey":"rr_6_12","override":false}}'::jsonb)$$, 'a competition records its own format selection');
select is((select format_selection->>'optionKey' from public.event_competitions where id=(select id from t_ids where name='d1')), 'rr_6_12', 'the selection is stored');
select is((select format_selection from public.event_competitions where id=(select id from t_ids where name='d2')), '{}'::jsonb, 'the sibling competition is unaffected');
select is((select ranked from public.event_competitions where id=(select id from t_ids where name='d2')), false, 'each competition has its own ranked setting');

-- Organizers can add a draft competition; the public never sees a draft event's competitions.
insert into t_ids values ('draft', public.upsert_event_competition('71000000-0000-0000-0000-000000000031', null, '{"name":"Hidden","league":"duels"}'::jsonb));

-- An organization administrator of another organization cannot manage this event.
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000002',true);
select throws_ok($$select public.upsert_event_competition('71000000-0000-0000-0000-000000000030', null, '{"name":"Nope","league":"buhurt"}'::jsonb)$$,
  'P0001','You are not allowed to manage competitions for this event','an unrelated organization admin cannot add competitions');
select throws_ok($$select public.delete_event_competition((select id from t_ids where name='src'))$$,
  'P0001','You are not allowed to manage competitions for this event','an unrelated organization admin cannot delete competitions');
reset role;

set local role anon;
select is((select count(*)::integer from public.event_competitions where event_id='71000000-0000-0000-0000-000000000030'), 3, 'anonymous visitors see a published event''s competitions');
select is((select count(*)::integer from public.event_competitions where event_id='71000000-0000-0000-0000-000000000031'), 0, 'anonymous visitors do not see a draft event''s competitions');
select throws_ok($$insert into public.event_competitions(event_id,name,league) values ('71000000-0000-0000-0000-000000000030','Hack','buhurt')$$, '42501', null,
  'anonymous visitors cannot write competitions');
reset role;

-- Organization-defined categories live beside the BI ones.
set local role authenticated;
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);
select lives_ok($$select public.upsert_competition_category('71000000-0000-0000-0000-000000000010','10v10','10v10 Melee','buhurt',10,false,true)$$, 'an organization admin can add a category');
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000002',true);
select throws_ok($$select public.upsert_competition_category('71000000-0000-0000-0000-000000000010','sneaky','Sneaky','buhurt',5,false,true)$$,
  'P0001','You are not allowed to manage categories for this organization','another organization''s admin cannot add categories');
select set_config('request.jwt.claim.sub','71000000-0000-0000-0000-000000000001',true);
select lives_ok($$select public.delete_event_competition((select id from t_ids where name='src'))$$, 'an organizer can delete a competition that has no bracket');
reset role;

-- Existing division and bracket tables gained only a nullable link.
select has_column('public','event_divisions','competition_id','event_divisions links to a competition');
select has_column('public','brackets','competition_id','brackets link to a competition');
select col_is_null('public','brackets','competition_id','the bracket link is optional, so existing flows are unchanged');

select * from finish();
rollback;
