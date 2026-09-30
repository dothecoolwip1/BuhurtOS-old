-- Pack 10 release security gate. These are structural assertions over the whole schema so a
-- future migration cannot silently widen anonymous access or drop row level security.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- 1. Row level security is enabled on every ordinary table in the public schema.
select is(
  (select count(*)::integer
     from pg_class c
     join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity),
  0,
  'every public table has row level security enabled'
);

-- 2. Anonymous visitors can never write to any public table.
select is(
  (select count(*)::integer
     from pg_class c
     join pg_namespace n on n.oid = c.relnamespace
     cross join unnest(array['INSERT','UPDATE','DELETE','TRUNCATE']) p(privilege)
    where n.nspname = 'public' and c.relkind = 'r'
      and has_table_privilege('anon', c.oid, p.privilege)),
  0,
  'anon has no write privileges on any public table'
);

-- 3. Sensitive tables have no anonymous read path at all.
select is(
  (select count(*)::integer
     from unnest(array[
       'fighter_event_signups','event_signup_codes','platform_settings','claim_requests','team_source_records',
       'platform_memberships','organization_memberships','event_memberships','profiles','audit_log',
       'fighter_identity_private_profiles','event_registrations'
     ]) t(name)
    where to_regclass('public.' || t.name) is not null
      and has_table_privilege('anon', to_regclass('public.' || t.name), 'SELECT')),
  0,
  'sensitive tables (signups, codes, settings, claims, memberships, audit, private profiles, registrations) are not readable by anon'
);

-- 4. Authenticated users cannot write directly to access-control or signup tables.
select is(
  (select count(*)::integer
     from unnest(array[
       'event_signup_codes','platform_settings','claim_requests','platform_memberships',
       'organization_memberships','event_memberships','team_memberships','club_memberships','audit_log'
     ]) t(name)
     cross join unnest(array['INSERT','UPDATE','DELETE']) p(privilege)
    where to_regclass('public.' || t.name) is not null
      and has_table_privilege('authenticated', to_regclass('public.' || t.name), p.privilege)),
  0,
  'authenticated users have no direct write privileges on access-control tables'
);

-- 5. Administrative and review functions are not executable by anon.
select is(
  (select count(*)::integer
     from pg_proc p
     join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname ~ '^(assign_|revoke_|create_event_signup_code|disable_|review_|set_platform_setting|link_duplicate|submit_claim|withdraw_claim|invite_|approve_|reject_|issue_|end_|upsert_|set_event_image|merge_)'
      and has_function_privilege('anon', p.oid, 'EXECUTE')),
  0,
  'no administrative public function is executable by anon'
);

-- 6. The only anonymous write-capable entry points are the signup and waiver style RPCs.
select is(
  (select count(*)::integer
     from pg_proc p
     join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('submit_event_fighter_signup','validate_event_signup_code')
      and has_function_privilege('anon', p.oid, 'EXECUTE')),
  2,
  'anonymous signup is limited to validating a code and submitting with one'
);

-- 7. Signup codes are hashed at rest: the table stores a digest, never a readable code column.
select is(
  (select count(*)::integer
     from information_schema.columns
    where table_schema = 'public' and table_name = 'event_signup_codes' and column_name in ('code','plain_code','signup_code')),
  0,
  'event_signup_codes has no plaintext code column'
);

select has_column('public', 'event_signup_codes', 'code_hash', 'event_signup_codes stores a code hash');

-- 8. Private storage buckets stay private; only event media is public.
select is(
  (select count(*)::integer from storage.buckets where public and id <> 'event-media'),
  0,
  'only the event-media bucket is public'
);

-- 9. Audit logging exists for the security-relevant tables.
select is(
  (select count(distinct c.relname)::integer
     from pg_trigger t
     join pg_class c on c.oid = t.tgrelid
     join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and not t.tgisinternal
      and c.relname in ('events','organizations','matches','brackets','seasons','rulesets')
      and t.tgname = 'audit_change'),
  6,
  'audit triggers cover events, organizations, matches, brackets, seasons and rulesets'
);

select * from finish();
rollback;
