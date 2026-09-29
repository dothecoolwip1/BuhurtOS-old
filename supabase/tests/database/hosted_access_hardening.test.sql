-- Hosted Supabase privilege hardening regression checks.
begin;
create extension if not exists pgtap with schema extensions;

select plan(28);

select ok(not has_table_privilege('anon','public.club_memberships','SELECT'),
  'anonymous cannot discover club memberships');
select ok(not has_table_privilege('anon','public.team_memberships','SELECT'),
  'anonymous cannot discover team memberships');
select ok(not has_table_privilege('anon','public.membership_requests','SELECT'),
  'anonymous cannot discover membership requests');
select ok(not has_table_privilege('anon','public.suspensions','SELECT'),
  'anonymous cannot discover suspensions');

select ok(has_table_privilege('authenticated','public.club_memberships','SELECT'),
  'authenticated users can read club memberships subject to RLS');
select ok(not has_table_privilege('authenticated','public.club_memberships','INSERT'),
  'club membership writes are RPC-only');
select ok(has_table_privilege('authenticated','public.team_memberships','SELECT'),
  'authenticated users can read team memberships subject to RLS');
select ok(not has_table_privilege('authenticated','public.team_memberships','INSERT'),
  'team membership writes are RPC-only');
select ok(has_table_privilege('authenticated','public.membership_requests','SELECT'),
  'authenticated users can read membership requests subject to RLS');
select ok(not has_table_privilege('authenticated','public.membership_requests','INSERT'),
  'membership request writes are RPC-only');

select ok(has_table_privilege('anon','public.organization_relationships','SELECT'),
  'federation relationships remain publicly readable');
select ok(not has_table_privilege('anon','public.organization_relationships','INSERT'),
  'anonymous cannot write federation relationships');
select ok(has_table_privilege('authenticated','public.organization_relationships','SELECT'),
  'authenticated users can read federation relationships');
select ok(not has_table_privilege('authenticated','public.organization_relationships','INSERT'),
  'federation relationship writes are RPC-only');

select ok(has_table_privilege('anon','public.rulesets','SELECT'),
  'published rulesets remain publicly readable subject to RLS');
select ok(not has_table_privilege('anon','public.rulesets','INSERT'),
  'anonymous cannot write rulesets');
select ok(has_table_privilege('authenticated','public.rulesets','SELECT'),
  'authenticated users can read rulesets');
select ok(has_table_privilege('authenticated','public.rulesets','INSERT'),
  'authenticated ruleset administration keeps guarded direct inserts');

select ok(has_table_privilege('authenticated','public.suspensions','SELECT'),
  'authenticated suspension reads remain available subject to RLS');
select ok(not has_table_privilege('authenticated','public.suspensions','INSERT'),
  'suspension writes remain RPC-only');

create table public.__buhurtos_default_acl_probe(id integer);
select ok(not has_table_privilege('anon','public.__buhurtos_default_acl_probe','SELECT'),
  'new public tables are not auto-exposed to anon');
select ok(not has_table_privilege('authenticated','public.__buhurtos_default_acl_probe','SELECT'),
  'new public tables are not auto-exposed to authenticated');
select ok(not has_table_privilege('service_role','public.__buhurtos_default_acl_probe','SELECT'),
  'new public tables require explicit service-role grants');

create function public.__buhurtos_default_acl_probe_fn() returns integer
language sql
as $$ select 1 $$;
select ok(not has_function_privilege('anon','public.__buhurtos_default_acl_probe_fn()','EXECUTE'),
  'new public functions are not auto-executable by anon');
select ok(not has_function_privilege('authenticated','public.__buhurtos_default_acl_probe_fn()','EXECUTE'),
  'new public functions are not auto-executable by authenticated');

create sequence public.__buhurtos_default_acl_probe_seq;
select ok(not has_sequence_privilege('anon','public.__buhurtos_default_acl_probe_seq','USAGE'),
  'new public sequences are not auto-usable by anon');
select ok(not has_sequence_privilege('authenticated','public.__buhurtos_default_acl_probe_seq','USAGE'),
  'new public sequences are not auto-usable by authenticated');

select ok(
  position(
    'objects.name'
    in (select qual from pg_policies where schemaname='storage' and tablename='objects' and policyname='waiver_staff_read')
  ) > 0,
  'waiver staff policy compares against the storage object path'
);

select * from finish();
rollback;
