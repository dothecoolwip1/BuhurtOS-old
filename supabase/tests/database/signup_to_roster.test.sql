-- Accepted interest-form signups can be added to the roster by event leaders only.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select v.id::uuid,'authenticated','authenticated',v.email,'',now(),'{}',('{"display_name":"'||v.name||'"}')::jsonb,now(),now()
from (values
  ('75000000-0000-0000-0000-000000000001','sr-orgadmin@buhurtos.test','Org Admin'),
  ('75000000-0000-0000-0000-000000000002','sr-fighter@buhurtos.test','Host Fighter'),
  ('75000000-0000-0000-0000-000000000003','sr-captain@buhurtos.test','Host Captain'),
  ('75000000-0000-0000-0000-000000000004','sr-otheradmin@buhurtos.test','Other Admin')
) as v(id,email,name);
insert into public.organizations(id,name,short_name,region,status) values
 ('75000000-0000-0000-0000-000000000010','SR Org','SRO','Test','active'),
 ('75000000-0000-0000-0000-000000000011','SR Other','SRX','Test','active');
insert into public.organization_memberships(organization_id,user_id,role) values
 ('75000000-0000-0000-0000-000000000010','75000000-0000-0000-0000-000000000001','organization_admin'),
 ('75000000-0000-0000-0000-000000000011','75000000-0000-0000-0000-000000000004','organization_admin');
insert into public.teams(id,organization_id,name,city_or_region) values ('75000000-0000-0000-0000-000000000020','75000000-0000-0000-0000-000000000010','SR Host','Test');
insert into public.team_memberships(team_id,user_id,role,display_name) values
 ('75000000-0000-0000-0000-000000000020','75000000-0000-0000-0000-000000000002','fighter','Host Fighter'),
 ('75000000-0000-0000-0000-000000000020','75000000-0000-0000-0000-000000000003','captain','Host Captain');
insert into public.seasons(id,organization_id,name,starts_at,ends_at,status) values ('75000000-0000-0000-0000-000000000030','75000000-0000-0000-0000-000000000010','SR Season',now()-interval '30 days',now()+interval '300 days','active');
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,host_team_id) values
 ('75000000-0000-0000-0000-000000000040','75000000-0000-0000-0000-000000000010','75000000-0000-0000-0000-000000000030','SR Open','Ranch',now()+interval '30 days',now()+interval '31 days','custom','no_standings','published','UTC',now(),'75000000-0000-0000-0000-000000000020');
insert into public.fighter_event_signups(id,event_id,display_name,email,fighting_categories,armor_status,consent_acknowledged,status) values
 ('75000000-0000-0000-0000-000000000050','75000000-0000-0000-0000-000000000040','Pending Person','p@example.com','{5v5}','Full kit',true,'new'),
 ('75000000-0000-0000-0000-000000000051','75000000-0000-0000-0000-000000000040','Accepted Person','a@example.com','{longsword}','Full kit',true,'confirmed');

create temp table t_ids(name text primary key, id uuid);
grant all on t_ids to public;

set local role authenticated;
select set_config('request.jwt.claim.sub','75000000-0000-0000-0000-000000000002',true);
select throws_ok($$select public.add_signup_to_roster('75000000-0000-0000-0000-000000000051')$$, 'P0001','Only event organizers and team leaders can add signups to the roster','a plain host-team fighter cannot add anyone to the roster');
select set_config('request.jwt.claim.sub','75000000-0000-0000-0000-000000000004',true);
select throws_ok($$select public.add_signup_to_roster('75000000-0000-0000-0000-000000000051')$$, 'P0001','Only event organizers and team leaders can add signups to the roster','an unrelated organization admin cannot');
select set_config('request.jwt.claim.sub','75000000-0000-0000-0000-000000000003',true);
select throws_ok($$select public.add_signup_to_roster('75000000-0000-0000-0000-000000000050')$$, 'P0001','Accept the signup first, then add it to the roster','a signup that has not been accepted cannot be added');
insert into t_ids values ('entry', public.add_signup_to_roster('75000000-0000-0000-0000-000000000051'));
select ok((select id from t_ids where name='entry') is not null, 'a host-team captain adds an accepted signup to the roster');
select is(public.add_signup_to_roster('75000000-0000-0000-0000-000000000051'), (select id from t_ids where name='entry'), 'adding twice returns the same roster entry (no duplicates)');
reset role;

select is((select count(*)::integer from public.event_roster_entries where event_id='75000000-0000-0000-0000-000000000040'), 1, 'exactly one roster entry exists');
select is((select entry_type::text from public.event_roster_entries where id=(select id from t_ids where name='entry')), 'guest_fighter', 'the entrant is a guest fighter until linked to an account');
select is((select display_name from public.event_roster_entries where id=(select id from t_ids where name='entry')), 'Accepted Person', 'the name carries over');
select is((select (checked_in or armor_cleared or medical_cleared or waiver_confirmed or weigh_in_cleared or competition_cleared) from public.event_roster_entries where id=(select id from t_ids where name='entry')), false, 'nothing is cleared automatically: check-in and every clearance start false');
select is((select roster_entry_id from public.fighter_event_signups where id='75000000-0000-0000-0000-000000000051'), (select id from t_ids where name='entry'), 'the signup remembers its roster entry');
select ok(exists(select 1 from public.audit_log where action='add_signup_to_roster' and record_id='75000000-0000-0000-0000-000000000051'), 'the action is audited');

set local role anon;
select throws_ok($$select public.add_signup_to_roster('75000000-0000-0000-0000-000000000051')$$, '42501', null, 'anonymous visitors cannot call it');
reset role;

update public.events set status='cancelled' where id='75000000-0000-0000-0000-000000000040';
insert into public.fighter_event_signups(id,event_id,display_name,email,consent_acknowledged,status) values ('75000000-0000-0000-0000-000000000052','75000000-0000-0000-0000-000000000040','Late Person','l@example.com',true,'confirmed');
set local role authenticated;
select set_config('request.jwt.claim.sub','75000000-0000-0000-0000-000000000001',true);
select throws_ok($$select public.add_signup_to_roster('75000000-0000-0000-0000-000000000052')$$, 'P0001','This event is no longer taking entrants','a cancelled event takes no new entrants');
reset role;

select * from finish();
rollback;
