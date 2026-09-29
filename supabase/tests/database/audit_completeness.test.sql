-- Audit completeness (forward migration 20261002000000).
--
-- Coverage: the remaining core-entity audit gap (brackets, organizations,
-- seasons, events, rulesets, ruleset_sources, event_ruleset_snapshots,
-- profiles) now carries the shared audit_change trigger; writes on each strip
-- into public.audit_log with the right action and org scope; announcements and
-- event_registrations (already audited by operational hardening) are guarded by
-- regression checks; org-unscoped rows (organizations themselves, profiles,
-- ruleset_sources) are recorded with organization_id NULL.

begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into auth.users (
  id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
('f0000000-0000-0000-0000-000000000001','authenticated','authenticated','audit-owner@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Audit Owner"}',timezone('utc',now()),timezone('utc',now()));

-- The auth.users insert creates the matching profile row through
-- private.handle_new_auth_user(); that insert is what the audit assertions
-- below verify (no explicit profile insert needed).

insert into public.organizations(id,name,short_name,region,status)
values ('f0000000-0000-0000-0000-000000000010','Audit Org','AO','Test','active');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('f0000000-0000-0000-0000-000000000020','f0000000-0000-0000-0000-000000000010','2026 Disc','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone)
values ('f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000020','Audit Event','Field','2026-09-01T16:00:00Z','2026-09-01T23:00:00Z','ranked_competitive','season_and_event','published','UTC');

insert into public.brackets(id,event_id,name,format,category)
values ('f0000000-0000-0000-0000-000000000040','f0000000-0000-0000-0000-000000000030','Audit Bracket','single_elimination','longsword');

insert into public.rulesets(id,organization_id,name,short_name)
values ('f0000000-0000-0000-0000-000000000050','f0000000-0000-0000-0000-000000000010','Audit Ruleset','AR');

insert into public.ruleset_sources(id,ruleset_id,label)
values ('f0000000-0000-0000-0000-000000000060','f0000000-0000-0000-0000-000000000050','BI 2026 source');

insert into public.event_ruleset_snapshots(id,event_id,ruleset_id,ruleset_name,ruleset_short_name,ruleset_version,resolved_settings)
values ('f0000000-0000-0000-0000-000000000070','f0000000-0000-0000-0000-000000000030','f0000000-0000-0000-0000-000000000050','Audit Ruleset','AR','1.0','{}'::jsonb);

-- ---------------------------------------------------------------------------
-- Trigger presence
-- ---------------------------------------------------------------------------

select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.brackets'::regclass),
  'brackets carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.organizations'::regclass),
  'organizations carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.seasons'::regclass),
  'seasons carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.events'::regclass),
  'events carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.rulesets'::regclass),
  'rulesets carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.ruleset_sources'::regclass),
  'ruleset_sources carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.event_ruleset_snapshots'::regclass),
  'event_ruleset_snapshots carries the audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.profiles'::regclass),
  'profiles carries the audit_change trigger'
);

-- Regression: previously-covered tables keep their trigger untouched.
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.announcements'::regclass),
  'announcements keeps its existing audit_change trigger'
);
select ok(
  exists(select 1 from pg_trigger where tgname='audit_change' and tgrelid='public.event_registrations'::regclass),
  'event_registrations keeps its existing audit_change trigger'
);

-- ---------------------------------------------------------------------------
-- Writes are captured with the right action
-- ---------------------------------------------------------------------------

select is(
  (select count(*)::integer from public.audit_log where table_name='profiles' and action='insert'),
  1,
  'profile creation is audited'
);
select is(
  (
    select count(*)::integer
    from public.audit_log
    where table_name='organizations'
      and action='insert'
      and record_id='f0000000-0000-0000-0000-000000000010'
  ),
  1,
  'organization creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='seasons' and action='insert'),
  1,
  'season creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='events' and action='insert'),
  1,
  'event creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='brackets' and action='insert'),
  1,
  'bracket creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='rulesets' and action='insert'),
  1,
  'ruleset creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='ruleset_sources' and action='insert'),
  1,
  'ruleset source creation is audited'
);
select is(
  (select count(*)::integer from public.audit_log where table_name='event_ruleset_snapshots' and action='insert'),
  1,
  'event ruleset snapshot creation is audited'
);

update public.organizations set short_name='AOO' where id='f0000000-0000-0000-0000-000000000010';
select ok(
  exists(
    select 1 from public.audit_log
    where table_name='organizations' and action='update' and record_id='f0000000-0000-0000-0000-000000000010'
  ),
  'organization edits are audited as updates'
);

select throws_ok(
  $$delete from public.brackets where id='f0000000-0000-0000-0000-000000000040'$$,
  'P0001',
  'Published tournament structures are historical records and cannot be deleted',
  'published bracket deletion is blocked by the immutability guard'
);

-- ---------------------------------------------------------------------------
-- Org scoping
-- ---------------------------------------------------------------------------

select is(
  (select organization_id::text from public.audit_log where table_name='seasons' and action='insert' limit 1),
  'f0000000-0000-0000-0000-000000000010',
  'season audit rows carry their organization'
);
select is(
  (select organization_id::text from public.audit_log where table_name='brackets' and action='insert' limit 1),
  'f0000000-0000-0000-0000-000000000010',
  'bracket audit rows resolve org scope through their event'
);
select is(
  (select organization_id::text from public.audit_log where table_name='event_ruleset_snapshots' and action='insert' limit 1),
  'f0000000-0000-0000-0000-000000000010',
  'event ruleset snapshot audit rows resolve org scope through their event'
);
select ok(
  (
    select organization_id
    from public.audit_log
    where table_name='organizations'
      and action='insert'
      and record_id='f0000000-0000-0000-0000-000000000010'
  ) is null,
  'organization audit rows are recorded without a parent org scope'
);
select ok(
  (select organization_id from public.audit_log where table_name='profiles' and action='insert' limit 1) is null,
  'profile audit rows are recorded without an org scope'
);
select ok(
  (select organization_id from public.audit_log where table_name='ruleset_sources' and action='insert' limit 1) is null,
  'ruleset source audit rows are recorded without an org scope'
);

select * from finish();
rollback;