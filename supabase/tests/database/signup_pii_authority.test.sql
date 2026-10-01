-- Signup submissions hold personal data: only event leaders may read or change them. Code issuance stays broad on purpose.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select v.id::uuid,'authenticated','authenticated',v.email,'',now(),'{}',('{"display_name":"'||v.name||'"}')::jsonb,now(),now()
from (values
  ('74000000-0000-0000-0000-000000000001','sp-orgadmin@buhurtos.test','Org Admin'),
  ('74000000-0000-0000-0000-000000000002','sp-fighter@buhurtos.test','Host Fighter'),
  ('74000000-0000-0000-0000-000000000003','sp-captain@buhurtos.test','Host Captain'),
  ('74000000-0000-0000-0000-000000000004','sp-otheradmin@buhurtos.test','Other Admin'),
  ('74000000-0000-0000-0000-000000000005','sp-organizer@buhurtos.test','Organizer'),
  ('74000000-0000-0000-0000-000000000006','sp-former@buhurtos.test','Former Captain')
) as v(id,email,name);
insert into public.organizations(id,name,short_name,region,status) values
 ('74000000-0000-0000-0000-000000000010','SP Org','SPO','Test','active'),
 ('74000000-0000-0000-0000-000000000011','SP Other','SPX','Test','active');
insert into public.organization_memberships(organization_id,user_id,role) values
 ('74000000-0000-0000-0000-000000000010','74000000-0000-0000-0000-000000000001','organization_admin'),
 ('74000000-0000-0000-0000-000000000011','74000000-0000-0000-0000-000000000004','organization_admin');
insert into public.teams(id,organization_id,name,city_or_region) values ('74000000-0000-0000-0000-000000000020','74000000-0000-0000-0000-000000000010','SP Host','Test');
insert into public.team_memberships(team_id,user_id,role,display_name) values
 ('74000000-0000-0000-0000-000000000020','74000000-0000-0000-0000-000000000002','fighter','Host Fighter'),
 ('74000000-0000-0000-0000-000000000020','74000000-0000-0000-0000-000000000003','captain','Host Captain');
insert into public.team_memberships(team_id,user_id,role,display_name,starts_on,ends_on) values
 ('74000000-0000-0000-0000-000000000020','74000000-0000-0000-0000-000000000006','captain','Former',current_date-30,current_date-1);
insert into public.seasons(id,organization_id,name,starts_at,ends_at,status) values ('74000000-0000-0000-0000-000000000030','74000000-0000-0000-0000-000000000010','SP Season',now()-interval '30 days',now()+interval '300 days','active');
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,host_team_id) values
 ('74000000-0000-0000-0000-000000000040','74000000-0000-0000-0000-000000000010','74000000-0000-0000-0000-000000000030','SP Open','Ranch',now()+interval '30 days',now()+interval '31 days','custom','no_standings','published','UTC',now(),'74000000-0000-0000-0000-000000000020');
insert into public.event_memberships(event_id,user_id,role) values ('74000000-0000-0000-0000-000000000040','74000000-0000-0000-0000-000000000005','event_organizer');

create temp table t_code(code text);
grant all on t_code to public;

-- The org admin issues a code; a visitor signs up with sensitive details.
set local role authenticated;
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000001',true);
insert into t_code select public.create_event_signup_code('74000000-0000-0000-0000-000000000040','sp',2,null);
reset role;
set local role anon;
select lives_ok($$select public.submit_event_fighter_signup('74000000-0000-0000-0000-000000000040',(select code from t_code),'Sensitive Person','s@example.com','555-0199',null,null,'{}',null,null,'Emergency: Jane 555-0111','private note',true)$$, 'a visitor with a code can sign up');
reset role;

-- A plain host-team fighter: may still hand out codes, may not see or change signups.
set local role authenticated;
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000002',true);
select is((select count(*)::integer from public.fighter_event_signups), 0, 'a plain host-team fighter cannot read signup submissions');
select is((select count(*)::integer from public.fighter_event_signups where emergency_contact is not null), 0, 'a plain host-team fighter cannot read emergency contacts');
select lives_ok($$select public.create_event_signup_code('74000000-0000-0000-0000-000000000040','fighter code',1,null)$$, 'a plain host-team fighter can still issue a signup code (owner-intended)');
select is((select count(*)::integer from public.list_event_signup_codes('74000000-0000-0000-0000-000000000040')), 2, 'and can still see the event''s codes');
update public.fighter_event_signups set status='confirmed';
reset role;
select is((select status from public.fighter_event_signups limit 1), 'new', 'a plain host-team fighter cannot accept someone''s signup');
set local role authenticated;
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000002',true);
delete from public.fighter_event_signups;
reset role;
select is((select count(*)::integer from public.fighter_event_signups), 1, 'a plain host-team fighter cannot delete signups');

-- Event leaders can.
set local role authenticated;
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000003',true);
select is((select count(*)::integer from public.fighter_event_signups), 1, 'a host-team captain can read signups');
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000001',true);
select is((select count(*)::integer from public.fighter_event_signups), 1, 'an organization admin can read signups');
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000005',true);
select is((select count(*)::integer from public.fighter_event_signups), 1, 'an event organizer can read signups');
update public.fighter_event_signups set status='confirmed';
reset role;
select is((select status from public.fighter_event_signups limit 1), 'confirmed', 'an event organizer can review a signup');

-- Everyone else cannot.
set local role authenticated;
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000004',true);
select is((select count(*)::integer from public.fighter_event_signups), 0, 'an unrelated organization admin cannot read signups');
select set_config('request.jwt.claim.sub','74000000-0000-0000-0000-000000000006',true);
select is((select count(*)::integer from public.fighter_event_signups), 0, 'a former captain cannot read signups');
reset role;
set local role anon;
select throws_ok($$select count(*) from public.fighter_event_signups$$, '42501', null, 'anonymous visitors cannot read signups');
reset role;

select * from finish();
rollback;
