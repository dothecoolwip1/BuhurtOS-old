-- Discipline and suspensions (forward migration 20260930010000).
--
-- Coverage: guarded discipline card issuance (authz + reason required),
-- suspension lifecycle (issue/revoke, authz), data-layer enforcement that an
-- active suspension blocks competition clearance through every path, read
-- scoping (staff / fighter self / anonymity), write-policy removal, and audit.

begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into auth.users (
  id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
('f0000000-0000-0000-0000-000000000001','authenticated','authenticated','disc-admin@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Org Admin"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000002','authenticated','authenticated','disc-staff@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Org Staff"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000003','authenticated','authenticated','disc-fighter@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Fighter"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000004','authenticated','authenticated','disc-other-org@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Other Org Admin"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000005','authenticated','authenticated','disc-owner@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Platform Owner"}',timezone('utc',now()),timezone('utc',now()));

insert into public.organizations(id,name,short_name,region,status)
values
('f0000000-0000-0000-0000-000000000010','Disc Org A','DA','Test','active'),
('f0000000-0000-0000-0000-000000000011','Disc Org B','DB','Test','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000002','organization_staff'),
('f0000000-0000-0000-0000-000000000011','f0000000-0000-0000-0000-000000000004','organization_admin');

insert into public.platform_memberships(user_id,role)
values ('f0000000-0000-0000-0000-000000000005','platform_super_admin');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('f0000000-0000-0000-0000-000000000020','f0000000-0000-0000-0000-000000000010','2026 Disc','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
values ('f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000020','Disc Event','Field','2026-09-01T16:00:00Z','2026-09-01T23:00:00Z','ranked_competitive','season_and_event','published','UTC');

insert into public.fighter_identities(id,user_id,display_name)
values ('f0000000-0000-0000-0000-000000000040','f0000000-0000-0000-0000-000000000003','Disc Fighter');

insert into public.fighters(id,organization_id,identity_id,name)
values ('f0000000-0000-0000-0000-000000000041','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000040','Disc Fighter');

-- The fighter identity insert auto-links the fighter's own account row
-- (identity_id, user_id, relationship='self'), so no explicit account insert.

insert into public.event_roster_entries(id,organization_id,event_id,fighter_id,entry_type,display_name,attendance_status,checked_in,armor_cleared,medical_cleared,waiver_confirmed,weigh_in_cleared)
values
('f0000000-0000-0000-0000-000000000050','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000041','fighter','Disc Fighter','approved',true,true,true,true,true),
('f0000000-0000-0000-0000-000000000051','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000041','fighter','Disc Fighter Two','approved',true,true,true,true,true);

-- The suite references the suspension by the deterministic id passed to the
-- issue RPC below.

-- ---------------------------------------------------------------------------
-- Guarded discipline card issuance
-- ---------------------------------------------------------------------------

set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$select public.issue_discipline_card('f0000000-0000-0000-0000-000000000050','yellow','Catching kicks')$$,
  'organization admin can issue a yellow card through the guarded RPC'
);

select is(
  (select count(*)::integer from public.disciplinary_cards where roster_entry_id='f0000000-0000-0000-0000-000000000050'),
  1,
  'issued card is persisted'
);

select is(
  (select issued_by from public.disciplinary_cards where roster_entry_id='f0000000-0000-0000-0000-000000000050'),
  'f0000000-0000-0000-0000-000000000001'::uuid,
  'card is stamped with the issuing actor'
);

select throws_ok(
  $$select public.issue_discipline_card('f0000000-0000-0000-0000-000000000050','yellow', null)$$,
  null, 'Card reason is required',
  'a reason is required to issue a card'
);

-- ---------------------------------------------------------------------------
-- Suspension lifecycle: issue / revoke / authz
-- ---------------------------------------------------------------------------

-- Seeded with a deterministic id so every later check (including checks that
-- run as roles without RLS visibility of the row) can reference it directly.
select lives_ok(
  $$select public.issue_suspension(
    'f0000000-0000-0000-0000-000000000010',
    'f0000000-0000-0000-0000-000000000041',
    '2026-08-01T00:00:00Z','2026-10-01T00:00:00Z',
    'Striking downed opponent',
    'appeal window open',
    'f0000000-0000-0000-0000-000000000030',
    null,
    'f0000000-0000-0000-0000-000000000060')$$,
  'organization admin can issue a suspension scoped to an event'
);

select is(
  (select count(*)::integer from public.suspensions where organization_id='f0000000-0000-0000-0000-000000000010'),
  1,
  'issued suspension is persisted'
);

select throws_ok(
  $$select public.issue_suspension(
    'f0000000-0000-0000-0000-000000000010',
    'f0000000-0000-0000-0000-000000000041',
    '2026-10-01T00:00:00Z','2026-08-01T00:00:00Z',
    'backwards')$$,
  null, 'after its start',
  'a suspension must end after it starts'
);

-- Organization staff cannot issue discipline cards (admin or event organizer/
-- marshal required).
set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000002',true);
select throws_ok(
  $$select public.issue_discipline_card('f0000000-0000-0000-0000-000000000050','red','smack')$$,
  null, 'Not authorized',
  'organization staff cannot issue discipline cards (admin or event organizer/marshal required)'
);

-- ---------------------------------------------------------------------------
-- Enforcement: an active suspension blocks competition clearance on every path
-- ---------------------------------------------------------------------------

-- The clearance RPC authorizes the caller itself, so it must run as the org admin.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);

-- Via the guarded RPC.
select throws_ok(
  $$select public.set_roster_competition_clearance_guarded(
      'f0000000-0000-0000-0000-000000000051',
      (select updated_at from public.event_roster_entries where id='f0000000-0000-0000-0000-000000000051'),
      true)$$,
  null, 'active suspension',
  'guarded clearance RPC refuses a suspended fighter'
);

-- Via a direct table write (data-layer trigger).
select throws_ok(
  $$update public.event_roster_entries set competition_cleared=true where id='f0000000-0000-0000-0000-000000000051'$$,
  null, 'active suspension',
  'direct competition_cleared writes are refused by the enforcement trigger'
);

select is(
  (select competition_cleared from public.event_roster_entries where id='f0000000-0000-0000-0000-000000000051'),
  false,
  'roster entry was not cleared while suspended'
);

-- Revoke, then clearance succeeds.
-- An admin of another organization cannot revoke. The RPC authorizes against
-- the suspension's row before mutating, so this throws despite the caller
-- never having RLS visibility of the row.
set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000004',true);
select throws_ok(
  $$select public.revoke_suspension('f0000000-0000-0000-0000-000000000060')$$,
  null, 'Not authorized',
  'an admin of another organization cannot revoke suspensions'
);

-- The org admin can revoke.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);
select lives_ok(
  $$select public.revoke_suspension('f0000000-0000-0000-0000-000000000060')$$,
  'organization admin can revoke a suspension'
);

select is(
  (select revoked_at is not null from public.suspensions where fighter_id='f0000000-0000-0000-0000-000000000041'),
  true,
  'revoked suspension is stamped'
);

select lives_ok(
  $$select public.set_roster_competition_clearance_guarded(
      'f0000000-0000-0000-0000-000000000051',
      (select updated_at from public.event_roster_entries where id='f0000000-0000-0000-0000-000000000051'),
      true)$$,
  'clearance succeeds after the suspension is revoked'
);

-- ---------------------------------------------------------------------------
-- Authorization across the read and write surface
-- ---------------------------------------------------------------------------

-- The fighter can see suspensions covering their own identity.
set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000003',true);
select is(
  (select count(*)::integer from public.suspensions where fighter_id='f0000000-0000-0000-0000-000000000041'),
  1,
  'fighters can read suspensions covering their own identity'
);

-- The existing discipline_read policy lets fighters/team captains read cards
-- for events they belong to, so no denial is asserted for the fighter here;
-- the meaningful read denials are checked as an admin of another organization.
set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000004',true);
select is(
  (select count(*)::integer from public.suspensions where organization_id='f0000000-0000-0000-0000-000000000010'),
  0,
  'an admin of another organization cannot read suspensions'
);
select is(
  (select count(*)::integer from public.disciplinary_cards where roster_entry_id='f0000000-0000-0000-0000-000000000050'),
  0,
  'an admin of another organization cannot read discipline cards'
);

select throws_ok(
  $$select public.issue_suspension(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000041',
    '2026-08-01T00:00:00Z','2026-10-01T00:00:00Z','sneaky')$$,
  null, 'Not authorized',
  'an admin of another organization cannot issue suspensions'
);

-- Anonymous spectators must not see or write suspensions.
set local role anon;
select is(
  (select count(*)::integer from public.suspensions),
  0,
  'anonymous users cannot read suspensions'
);

select throws_ok(
  $$insert into public.suspensions(organization_id,fighter_id,starts_at,ends_at,reason,issued_by)
    values ('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000041','2026-08-01','2026-10-01','x','f0000000-0000-0000-0000-000000000001')$$,
  '42501', null,
  'anonymous users cannot insert suspensions'
);

-- Authenticated users cannot write suspensions directly anymore: the write
-- path exists only through the guarded RPC.
set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);
select throws_ok(
  $$insert into public.suspensions(organization_id,fighter_id,starts_at,ends_at,reason,issued_by)
    values ('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000041','2026-08-01','2026-10-01','x','f0000000-0000-0000-0000-000000000001')$$,
  '42501', null,
  'authenticated users cannot write suspensions directly (RPC only)'
);

select throws_ok(
  $$insert into public.disciplinary_cards(organization_id,season_id,event_id,roster_entry_id,fighter_id,color,card_reason,notes,issued_by,issued_at)
    values ('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000020','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000050','f0000000-0000-0000-0000-000000000041','yellow','x','x','f0000000-0000-0000-0000-000000000001',timezone('utc',now()))$$,
  '42501', null,
  'discipline cards can no longer be inserted directly (RPC only)'
);

-- Audit: issuing a suspension is captured.
select is(
  (select count(*)::integer from public.audit_log where table_name='suspensions' and action='insert'),
  1,
  'suspension issuance is written to the audit log'
);

-- Execute grants: anonymous is revoked from every new RPC.
select ok(
  not has_function_privilege('anon','public.issue_discipline_card(uuid,public.disciplinary_color,text,text,uuid)','EXECUTE'),
  'anonymous cannot execute issue_discipline_card'
);
select ok(
  not has_function_privilege('anon','public.issue_suspension(uuid,uuid,timestamptz,timestamptz,text,text,uuid,uuid,uuid)','EXECUTE'),
  'anonymous cannot execute issue_suspension'
);
select ok(
  not has_function_privilege('anon','public.revoke_suspension(uuid)','EXECUTE'),
  'anonymous cannot execute revoke_suspension'
);

select * from finish();
rollback;
