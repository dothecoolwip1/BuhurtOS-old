-- Pack 6 platform configuration, adoption switches, event creation mode and claim records
-- (migration 20261016000000).
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

create temp table t_ids(name text primary key, id uuid);
grant all on t_ids to public;

insert into auth.users (
  id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
('69000000-0000-0000-0000-000000000001','authenticated','authenticated','cfg-super@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Super"}',timezone('utc',now()),timezone('utc',now())),
('69000000-0000-0000-0000-000000000002','authenticated','authenticated','cfg-admin-a@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Admin A"}',timezone('utc',now()),timezone('utc',now())),
('69000000-0000-0000-0000-000000000003','authenticated','authenticated','cfg-admin-b@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Admin B"}',timezone('utc',now()),timezone('utc',now())),
('69000000-0000-0000-0000-000000000004','authenticated','authenticated','cfg-staff-a@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Staff A"}',timezone('utc',now()),timezone('utc',now()));

insert into public.platform_memberships(user_id, role)
values ('69000000-0000-0000-0000-000000000001', 'platform_super_admin');

insert into public.organizations(id,name,short_name,region,status)
values
('69000000-0000-0000-0000-000000000010','Config Org A','CA','Test','active'),
('6a000000-0000-0000-0000-000000000010','Config Org B','CB','Test','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000002','organization_admin'),
('6a000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000003','organization_admin'),
('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000004','organization_staff');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('69000000-0000-0000-0000-000000000020','69000000-0000-0000-0000-000000000010','Config Season','2026-01-01','2026-12-31','active');

insert into public.teams(id,organization_id,name,city_or_region)
values ('69000000-0000-0000-0000-000000000040','69000000-0000-0000-0000-000000000010','Claimable Team','Somewhere');

-- Defaults preserve launch behavior and are readable without an account.
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  public.get_platform_config() ->> 'account_registration_mode', 'open',
  'registration mode defaults to open (existing behavior)'
);
select is(
  public.get_platform_config() ->> 'event_creation_mode', 'approved_organizers',
  'event creation defaults to approved organizers'
);
select is(
  (public.get_platform_config() ->> 'team_claims_enabled')::boolean, false,
  'claims are disabled by default'
);

select throws_ok(
  $$select * from public.platform_settings$$,
  '42501', null,
  'anonymous users cannot read the settings table directly'
);
select throws_ok(
  $$select public.set_platform_setting('event_creation_mode','"open"'::jsonb)$$,
  '42501', null,
  'anonymous users cannot change settings'
);

-- Only super administrators change settings.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000002',true);

select throws_ok(
  $$select public.set_platform_setting('event_creation_mode','"open"'::jsonb)$$,
  'P0001', 'Only platform super administrators can change platform settings',
  'organization administrators cannot change platform settings'
);
select throws_ok(
  $$update public.platform_settings set value = '"open"'::jsonb where key = 'event_creation_mode'$$,
  '42501', null,
  'direct writes to platform settings are blocked'
);

-- Event creation under the default mode follows the existing organization-admin rule.
select lives_ok(
  $$insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000030','69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Admin Event','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  'organization administrators can create events in their own organization'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000004',true);

select throws_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Staff Event','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  '42501', null,
  'organization staff cannot create events under the default mode'
);

-- Super administrator tightens, then loosens, event creation.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000001',true);

select throws_ok(
  $$select public.set_platform_setting('event_creation_mode','"everyone"'::jsonb)$$,
  'P0001', 'Invalid platform setting',
  'invalid mode values are rejected'
);
select throws_ok(
  $$select public.set_platform_setting('not_a_setting','true'::jsonb)$$,
  'P0001', 'Invalid platform setting',
  'unknown keys are rejected'
);
select throws_ok(
  $$select public.set_platform_setting('team_claims_enabled','"yes"'::jsonb)$$,
  'P0001', 'Invalid platform setting',
  'flags must be booleans'
);
select is(
  (select public.set_platform_setting('event_creation_mode','"platform_only"'::jsonb) ->> 'event_creation_mode'),
  'platform_only',
  'super administrators can switch event creation to platform only'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000002',true);

select throws_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Blocked Event','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  'P0001', 'Event creation is currently limited to platform administrators',
  'platform-only mode is enforced by the database, not the UI'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Platform Event','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  'platform super administrators can still create events in platform-only mode'
);

select is(
  (select public.set_platform_setting('event_creation_mode','"organization_members"'::jsonb) ->> 'event_creation_mode'),
  'organization_members',
  'super administrators can open event creation to organization members'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000004',true);

select lives_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Member Draft','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  'organization members can create draft events once the mode allows it'
);

select throws_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Member Published','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','published','UTC')$$,
  null, null,
  'members still cannot create published events directly'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000003',true);

select throws_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Cross Org Draft','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  '42501', null,
  'members of an unrelated organization cannot create events here'
);

-- Revoked membership loses the capability immediately.
reset role;
delete from public.organization_memberships
 where organization_id = '69000000-0000-0000-0000-000000000010'
   and user_id = '69000000-0000-0000-0000-000000000004';

set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000004',true);

select throws_ok(
  $$insert into public.events(organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
    values ('69000000-0000-0000-0000-000000000010','69000000-0000-0000-0000-000000000020','Revoked Draft','Hall','2026-11-14T16:00:00Z','2026-11-15T16:00:00Z','tournament','season_and_event','draft','UTC')$$,
  '42501', null,
  'a revoked membership can no longer create events'
);

-- Claim-ready records.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000003',true);

select throws_ok(
  $$select public.submit_claim_request('team','69000000-0000-0000-0000-000000000040','Our team')$$,
  'P0001', 'Claims are not enabled for this kind of record',
  'claims are refused while the switch is off'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000001',true);
select is(
  (select (public.set_platform_setting('team_claims_enabled','true'::jsonb) ->> 'team_claims_enabled')::boolean),
  true,
  'super administrators can enable team claims'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000003',true);

select throws_ok(
  $$select public.submit_claim_request('team','69000000-0000-0000-0000-0000000000ff','Ghost team')$$,
  'P0001', 'Record not found',
  'claims require an existing record'
);

insert into t_ids
select 'claim', public.submit_claim_request('team','69000000-0000-0000-0000-000000000040','Our team');

select ok((select id is not null from t_ids where name = 'claim'), 'an existing team can be claimed without recreating it');

select throws_ok(
  $$select public.submit_claim_request('team','69000000-0000-0000-0000-000000000040','Again')$$,
  '23505', null,
  'one pending claim per requester and record'
);

select throws_ok(
  $$insert into public.claim_requests(entity_type,entity_id,requested_by) values ('team','69000000-0000-0000-0000-000000000040','69000000-0000-0000-0000-000000000003')$$,
  '42501', null,
  'direct claim inserts are blocked'
);

select is(
  (select count(*)::integer from public.claim_requests),
  1,
  'requesters can read their own claim'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000002',true);

select is(
  (select count(*)::integer from public.claim_requests),
  0,
  'other users cannot see someone else claim'
);

select throws_ok(
  format($$select public.withdraw_claim_request(%L::uuid)$$, (select id from t_ids where name = 'claim')),
  'P0001', 'No pending claim request to withdraw',
  'only the requester can withdraw a claim'
);

select throws_ok(
  format($$select public.review_claim_request(%L::uuid,'approved','sure')$$, (select id from t_ids where name = 'claim')),
  'P0001', 'Only platform super administrators can review claims',
  'organization administrators cannot review claims'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','69000000-0000-0000-0000-000000000001',true);

select throws_ok(
  format($$select public.review_claim_request(%L::uuid,'maybe',null)$$, (select id from t_ids where name = 'claim')),
  'P0001', 'Decision must be approved or rejected',
  'review decisions are validated'
);

select lives_ok(
  format($$select public.review_claim_request(%L::uuid,'approved','Verified with the team captain')$$, (select id from t_ids where name = 'claim')),
  'platform super administrators can approve a claim'
);

select is(
  (select status::text from public.claim_requests where id = (select id from t_ids where name = 'claim')),
  'approved',
  'the decision is recorded'
);

select throws_ok(
  format($$select public.review_claim_request(%L::uuid,'rejected',null)$$, (select id from t_ids where name = 'claim')),
  'P0001', 'No pending claim request found',
  'a decided claim cannot be re-reviewed'
);

reset role;
select * from finish();
rollback;
