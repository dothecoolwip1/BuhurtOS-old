-- Registration access: server-side eligibility, request permission, review, notifications.
-- Also proves code ISSUANCE authority and request APPROVAL authority are separate.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select v.id::uuid,'authenticated','authenticated',v.email,'',timezone('utc',now()),'{}',('{"display_name":"'||v.name||'"}')::jsonb,timezone('utc',now()),timezone('utc',now())
from (values
  ('70000000-0000-0000-0000-000000000001','ra-orgadmin@buhurtos.test','Parent Org Admin'),
  ('70000000-0000-0000-0000-000000000002','ra-tree@buhurtos.test','Tree Fighter'),
  ('70000000-0000-0000-0000-000000000003','ra-unrelated@buhurtos.test','Unrelated Fighter'),
  ('70000000-0000-0000-0000-000000000004','ra-unverified@buhurtos.test','Unverified Fighter'),
  ('70000000-0000-0000-0000-000000000005','ra-otheradmin@buhurtos.test','Other Org Admin'),
  ('70000000-0000-0000-0000-000000000006','ra-hostmember@buhurtos.test','Host Team Fighter'),
  ('70000000-0000-0000-0000-000000000007','ra-captain@buhurtos.test','Host Captain')
) as v(id,email,name);

insert into public.organizations(id,name,short_name,region,status) values
 ('70000000-0000-0000-0000-000000000010','RA Parent','RAP','Test','active'),
 ('70000000-0000-0000-0000-000000000011','RA Child','RAC','Test','active'),
 ('70000000-0000-0000-0000-000000000012','RA Unrelated','RAU','Test','active');
insert into public.organization_relationships(parent_organization_id,child_organization_id,relationship_kind)
values ('70000000-0000-0000-0000-000000000010','70000000-0000-0000-0000-000000000011','governs');
insert into public.organization_memberships(organization_id,user_id,role) values
 ('70000000-0000-0000-0000-000000000010','70000000-0000-0000-0000-000000000001','organization_admin'),
 ('70000000-0000-0000-0000-000000000012','70000000-0000-0000-0000-000000000005','organization_admin');

insert into public.teams(id,organization_id,name,city_or_region) values
 ('70000000-0000-0000-0000-000000000020','70000000-0000-0000-0000-000000000011','RA Child Team','Test'),
 ('70000000-0000-0000-0000-000000000021','70000000-0000-0000-0000-000000000012','RA Unrelated Team','Test');

insert into public.fighter_identities(id,display_name,profile_visibility,user_id,profile_revision) values
 ('70000000-0000-0000-0000-000000000030','Tree Fighter','public',null,1),
 ('70000000-0000-0000-0000-000000000031','Unrelated Fighter','public',null,1),
 ('70000000-0000-0000-0000-000000000033','Host Team Fighter','public',null,1);
insert into public.fighter_identity_accounts(identity_id,user_id,relationship) values
 ('70000000-0000-0000-0000-000000000030','70000000-0000-0000-0000-000000000002','self'),
 ('70000000-0000-0000-0000-000000000031','70000000-0000-0000-0000-000000000003','self'),
 ('70000000-0000-0000-0000-000000000033','70000000-0000-0000-0000-000000000006','self');
insert into public.team_memberships(team_id,user_id,fighter_identity_id,role,display_name) values
 ('70000000-0000-0000-0000-000000000020','70000000-0000-0000-0000-000000000002','70000000-0000-0000-0000-000000000030','fighter','Tree Fighter'),
 ('70000000-0000-0000-0000-000000000021','70000000-0000-0000-0000-000000000003','70000000-0000-0000-0000-000000000031','fighter','Unrelated Fighter'),
 ('70000000-0000-0000-0000-000000000020','70000000-0000-0000-0000-000000000006','70000000-0000-0000-0000-000000000033','fighter','Host Team Fighter'),
 ('70000000-0000-0000-0000-000000000020','70000000-0000-0000-0000-000000000007',null,'captain','Host Captain');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('70000000-0000-0000-0000-000000000040','70000000-0000-0000-0000-000000000010','RA Season','2026-01-01','2026-12-31','active');
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,host_team_id,registration_access_scope)
values ('70000000-0000-0000-0000-000000000050','70000000-0000-0000-0000-000000000010','70000000-0000-0000-0000-000000000040','RA Rumble','Ranch','2026-11-14T16:00:00Z','2026-11-15T23:00:00Z','custom','no_standings','published','UTC',now(),'70000000-0000-0000-0000-000000000020','organization_tree');

create temp table t_ids(name text primary key, id uuid);
grant all on t_ids to public;

-- Helper: state as a given user.
create or replace function pg_temp.state_for(p_user uuid) returns text language plpgsql as $$
declare r text;
begin
  perform set_config('request.jwt.claim.sub', p_user::text, true);
  select public.get_event_registration_access('70000000-0000-0000-0000-000000000050')->>'state' into r;
  return r;
end $$;
grant execute on function pg_temp.state_for(uuid) to public;

-- 1. Eligible fighter inside the organization tree needs no code.
set local role authenticated;
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000002'), 'eligible',
  'a fighter on a team inside the event organization tree is eligible without a code');

select lives_ok(
  $$select public.submit_event_fighter_signup('70000000-0000-0000-0000-000000000050',null,'Tree Fighter','tree@example.com',null,'RA Child Team',null,'{}',null,null,null,null,true)$$,
  'an eligible fighter can submit a signup with no code');
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000002'), 'already_registered',
  'after signing up the fighter is reported as already registered');

-- 2. Unrelated fighter (has identity and a team, but outside the tree): code required, and no bypass.
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000003'), 'code_required',
  'a fighter outside the organization tree needs a code');
select throws_ok(
  $$select public.submit_event_fighter_signup('70000000-0000-0000-0000-000000000050',null,'Unrelated Fighter','u@example.com',null,null,null,'{}',null,null,null,null,true)$$,
  'P0001','A signup code is required for this event','code-less signup is refused for an ineligible fighter');

-- 3. Account with no fighter identity: cannot verify -> request permission.
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000004'), 'membership_unverified',
  'an account with no linked fighter identity cannot be verified');

-- 4. Request permission: persistent, deduplicated, notifies administrators.
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000004',true);
insert into t_ids values ('req', public.request_event_registration_access('70000000-0000-0000-0000-000000000050','I fight for the Reavers'));
select is(public.request_event_registration_access('70000000-0000-0000-0000-000000000050','again'), (select id from t_ids where name='req'),
  'a second request returns the existing pending request (no duplicates)');
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000004'), 'permission_requested', 'state becomes permission_requested');
reset role;

select is((select count(*)::integer from public.event_registration_access_requests where event_id='70000000-0000-0000-0000-000000000050' and user_id='70000000-0000-0000-0000-000000000004'),
  1, 'exactly one request row exists');
select ok(exists(select 1 from public.app_notifications where user_id='70000000-0000-0000-0000-000000000001' and request_id=(select id from t_ids where name='req') and read_at is null),
  'the organization administrator was notified (unread)');
select ok(exists(select 1 from public.app_notifications where user_id='70000000-0000-0000-0000-000000000007' and request_id=(select id from t_ids where name='req')),
  'the host-team captain was notified');
select ok(not exists(select 1 from public.app_notifications where user_id='70000000-0000-0000-0000-000000000005'),
  'an unrelated organization administrator was not notified');
select ok(not exists(select 1 from public.app_notifications where user_id='70000000-0000-0000-0000-000000000004'),
  'the requester is not notified of their own request');

-- 5. Authority: unrelated admin and plain host-team fighter cannot review; signup-code issuance stays separate.
set local role authenticated;
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000005',true);
select throws_ok(
  $$select public.review_event_registration_access_request((select id from t_ids where name='req'),'approved',null)$$,
  'P0001','You are not allowed to review registration access for this event','an unrelated organization admin cannot review');
select is((select count(*)::integer from public.list_event_registration_access_requests('70000000-0000-0000-0000-000000000050')), 0,
  'an unrelated admin sees no requests');

select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000006',true);
select throws_ok(
  $$select public.review_event_registration_access_request((select id from t_ids where name='req'),'approved',null)$$,
  'P0001','You are not allowed to review registration access for this event','a plain host-team fighter cannot approve requests');
select lives_ok(
  $$select public.create_event_signup_code('70000000-0000-0000-0000-000000000050','Team code',2,null)$$,
  'a host-team member can still issue signup codes (issuance authority is unchanged)');

-- 6. Approval by the captain: grants event-specific access only.
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000007',true);
select lives_ok(
  $$select public.review_event_registration_access_request((select id from t_ids where name='req'),'approved','Welcome')$$,
  'the host-team captain can approve');
reset role;

select is((select count(*)::integer from public.event_registration_access_grants where event_id='70000000-0000-0000-0000-000000000050' and user_id='70000000-0000-0000-0000-000000000004' and revoked_at is null),
  1, 'approval created an event-specific grant');
select is((select count(*)::integer from public.team_memberships where user_id='70000000-0000-0000-0000-000000000004'), 0,
  'approval did not create a team membership');
select is((select count(*)::integer from public.organization_memberships where user_id='70000000-0000-0000-0000-000000000004'), 0,
  'approval did not create an organization membership');
select is((select count(*)::integer from public.event_memberships where user_id='70000000-0000-0000-0000-000000000004'), 0,
  'approval did not create an event role');
select ok(exists(select 1 from public.app_notifications where user_id='70000000-0000-0000-0000-000000000004' and kind='registration_access_approved'),
  'the fighter was notified of the approval');

set local role authenticated;
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000004'), 'permission_granted', 'the approved fighter may now register');
select lives_ok(
  $$select public.submit_event_fighter_signup('70000000-0000-0000-0000-000000000050',null,'Unverified Fighter','unv@example.com',null,null,null,'{}',null,null,null,null,true)$$,
  'the approved fighter can submit without a code');
reset role;

-- The grant is for this event only.
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,registration_access_scope)
values ('70000000-0000-0000-0000-000000000051','70000000-0000-0000-0000-000000000010','70000000-0000-0000-0000-000000000040','RA Other Event','Ranch','2026-12-14T16:00:00Z','2026-12-15T23:00:00Z','custom','no_standings','published','UTC',now(),'organization_tree');
set local role authenticated;
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000004',true);
select is(public.get_event_registration_access('70000000-0000-0000-0000-000000000051')->>'state', 'membership_unverified',
  'the grant does not carry over to other events');

-- 7. Denial leaves the code flow available.
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000003',true);
select public.request_event_registration_access('70000000-0000-0000-0000-000000000051','please');
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000001',true);
select lives_ok(
  $$select public.review_event_registration_access_request((select id from public.list_event_registration_access_requests('70000000-0000-0000-0000-000000000051') limit 1),'denied','Not this time')$$,
  'an organization admin can deny');
select is(pg_temp.state_for('70000000-0000-0000-0000-000000000003'), 'denied', 'a denied fighter is reported as denied');
select throws_ok(
  $$select public.submit_event_fighter_signup('70000000-0000-0000-0000-000000000051',null,'Unrelated Fighter','u@example.com',null,null,null,'{}',null,null,null,null,true)$$,
  'P0001','A signup code is required for this event','denial keeps registration unavailable without a code');
reset role;

-- 8. Anonymous visitors: the eligibility function is not callable, the code flow is unchanged.
set local role anon;
select throws_ok($$select public.get_event_registration_access('70000000-0000-0000-0000-000000000050')$$, '42501', null,
  'anonymous visitors cannot call the eligibility function');
select throws_ok($$select public.request_event_registration_access('70000000-0000-0000-0000-000000000050','x')$$, '42501', null,
  'anonymous visitors cannot request access');
select throws_ok(
  $$select public.submit_event_fighter_signup('70000000-0000-0000-0000-000000000050',null,'Anon','a@example.com',null,null,null,'{}',null,null,null,null,true)$$,
  'P0001','A signup code is required for this event','anonymous code-less signup is refused');
reset role;

-- Notifications are private to their owner.
set local role authenticated;
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000005',true);
select is((select count(*)::integer from public.app_notifications), 0, 'a user cannot read other people''s notifications');
select set_config('request.jwt.claim.sub','70000000-0000-0000-0000-000000000001',true);
select ok(public.count_my_unread_notifications() >= 1, 'the organization admin has an unread count');
select lives_ok($$select public.mark_all_notifications_read()$$, 'notifications can be marked read');
select is(public.count_my_unread_notifications(), 0, 'unread count clears');
reset role;

select * from finish();
rollback;
