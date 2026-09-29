-- Federation hierarchy (forward migration 20261001000000).
--
-- Coverage: organization kinds + country metadata; the public-read
-- organization_relationships model with a generated org-context mirror;
-- bilateral-admin-console permission checks on the guarded upsert RPC;
-- cycle protection, active-duplicate refusal, reopen-after-end; the guarded
-- end RPC (parent admin only); RLS/privilege blocking of direct writes;
-- anonymous execution revocation on the write RPCs; the ancestor read
-- helper; write audit.

begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

insert into auth.users (
  id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
('f0000000-0000-0000-0000-000000000001','authenticated','authenticated','fed-officer@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Federation Officer"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000002','authenticated','authenticated','fed-regional@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Regional Admin"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000003','authenticated','authenticated','fed-staff@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Federation Staff"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000004','authenticated','authenticated','fed-independent@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Independent Admin"}',timezone('utc',now()),timezone('utc',now())),
('f0000000-0000-0000-0000-000000000005','authenticated','authenticated','fed-owner@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Platform Owner"}',timezone('utc',now()),timezone('utc',now()));

insert into public.organizations(id,name,short_name,region,status)
values
('f0000000-0000-0000-0000-000000000010','Federation Alpha','FA','Test','active'),
('f0000000-0000-0000-0000-000000000011','Regional Beta','RB','Test','active'),
('f0000000-0000-0000-0000-000000000012','Local Gamma','LG','Test','active'),
('f0000000-0000-0000-0000-000000000013','Independent Delta','ID','Test','active'),
('f0000000-0000-0000-0000-000000000014','Inactive Echo','IE','Test','inactive'),
('f0000000-0000-0000-0000-000000000015','Heritage League','HL','Test','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000011','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000012','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000013','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000015','f0000000-0000-0000-0000-000000000001','organization_admin'),
('f0000000-0000-0000-0000-000000000011','f0000000-0000-0000-0000-000000000002','organization_admin'),
('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000003','organization_staff'),
('f0000000-0000-0000-0000-000000000013','f0000000-0000-0000-0000-000000000004','organization_admin');

insert into public.platform_memberships(user_id,role)
values ('f0000000-0000-0000-0000-000000000005','platform_super_admin');

-- ---------------------------------------------------------------------------
-- Schema
-- ---------------------------------------------------------------------------

select ok(
  exists(
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'organization_relationships'
  ),
  'organization_relationships table exists'
);

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum e
    join pg_type t on e.enumtypid = t.oid
    where t.typname = 'organization_relationship_kind'),
  'governs,recognizes,affiliate,sanctioned,predecessor',
  'relationship kinds cover governing, recognition, affiliation, sanctioning and lineage'
);

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum e
    join pg_type t on e.enumtypid = t.oid
    where t.typname = 'organization_kind'),
  'international_federation,national_federation,regional_organization,local_organization,independent_organization',
  'organization kinds cover federation roles top-down'
);

select is(
  (select column_default from information_schema.columns
    where table_schema = 'public' and table_name = 'organizations' and column_name = 'kind'),
  '''independent_organization''::organization_kind',
  'organizations.kind defaults to independent (existing rows stay valid)'
);

select is(
  (select is_generated from information_schema.columns
    where table_schema = 'public' and table_name = 'organization_relationships' and column_name = 'organization_id'),
  'ALWAYS',
  'relationship organization_id mirrors the parent as a generated column for org-scoped audit'
);

-- Execute ACL: anonymous is revoked from both write RPCs but keeps the read helper.
select ok(
  not has_function_privilege('anon','public.upsert_organization_relationship(uuid,uuid,public.organization_relationship_kind,date,text)','EXECUTE'),
  'anonymous cannot execute upsert_organization_relationship'
);
select ok(
  not has_function_privilege('anon','public.end_organization_relationship(uuid)','EXECUTE'),
  'anonymous cannot execute end_organization_relationship'
);
select ok(
  has_function_privilege('anon','public.organization_ancestors(uuid)','EXECUTE'),
  'anonymous can execute the organization_ancestors read helper'
);

-- Missing actor claim is refused first (runs without any JWT claim set).
select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000012','governs')$$,
  null, 'Authentication required',
  'a relationship write without an actor claim is refused'
);

-- Anonymous sees an empty relationship set (public reads).
set local role anon;
select is(
  (select count(*)::integer from public.organization_relationships),
  0,
  'anonymous can read the empty relationship set'
);

-- ---------------------------------------------------------------------------
-- Federation officer creates the hierarchy
-- ---------------------------------------------------------------------------

set local role authenticated;
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000011','governs')$$,
  'federation officer (admin of both orgs) creates a governing relationship'
);

select is(
  (select relationship_kind::text from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000010'
      and child_organization_id='f0000000-0000-0000-0000-000000000011'),
  'governs',
  'governs relationship recorded'
);

select is(
  (select organization_id::text from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000010'
      and child_organization_id='f0000000-0000-0000-0000-000000000011'),
  'f0000000-0000-0000-0000-000000000010',
  'generated org-context mirror equals the parent id'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000011','governs')$$,
  null, 'That organization relationship is already active',
  'an active duplicate relationship is refused'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000010','governs')$$,
  null, 'An organization cannot relate to itself',
  'a relationship to yourself is refused'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000014','governs')$$,
  null, 'Both organizations must be active',
  'an inactive organization cannot join the hierarchy'
);

select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000011','f0000000-0000-0000-0000-000000000012','governs')$$,
  'federation officer extends the chain one level'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000012','f0000000-0000-0000-0000-000000000010','governs')$$,
  null, 'Organization hierarchy cycle detected',
  'a relation that would close a cycle is refused'
);

select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000013','affiliate')$$,
  'a second relationship kind (affiliate) is allowed for the same parent'
);

select is(
  (select count(*)::integer from public.organization_relationships where ends_on is null),
  3,
  'three active relationships exist after chain + affiliate creation'
);

select is(
  (select string_agg(ancestor_organization_id::text || ':' || relationship_kind::text, ',' order by hops)
    from public.organization_ancestors('f0000000-0000-0000-0000-000000000012')),
  'f0000000-0000-0000-0000-000000000011:governs,f0000000-0000-0000-0000-000000000010:governs',
  'the ancestor chain for Local Gamma is Beta then Alpha'
);

-- ---------------------------------------------------------------------------
-- Bilateral consent and child-side limits
-- ---------------------------------------------------------------------------

-- Regional admin: administers the child but not the parent — consent is incomplete.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000002',true);
select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000012','governs')$$,
  null, 'Administrator access to both organizations is required',
  'single-side admin (child only) cannot bind the relationship'
);

-- Federation staff: not an administrator anywhere.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000003',true);
select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000011','affiliate')$$,
  null, 'Administrator access to both organizations is required',
  'organization staff cannot create relationships'
);

-- Direct table writes remain blocked (no write grants/policies).
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);
select throws_ok(
  $$insert into public.organization_relationships(parent_organization_id,child_organization_id,relationship_kind)
    values ('f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000013','recognizes')$$,
  '42501', null,
  'direct organization_relationships writes are refused (RPC only)'
);

-- ---------------------------------------------------------------------------
-- Ending and reopening relationships
-- ---------------------------------------------------------------------------

-- The child's own admin cannot end a link its parent administers.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000004',true);
select throws_ok(
  $$select public.end_organization_relationship(
    (select id from public.organization_relationships
      where parent_organization_id='f0000000-0000-0000-0000-000000000010'
        and child_organization_id='f0000000-0000-0000-0000-000000000013'
        and relationship_kind='affiliate' and ends_on is null))$$,
  null, 'Organization administrator access required',
  'the child-side admin cannot end a parent-administered relationship'
);

-- The parent-side admin can end it; a second end is refused; upsert reopens.
select pg_catalog.set_config('request.jwt.claim.sub','f0000000-0000-0000-0000-000000000001',true);
select lives_ok(
  $$select public.end_organization_relationship(
    (select id from public.organization_relationships
      where parent_organization_id='f0000000-0000-0000-0000-000000000010'
        and child_organization_id='f0000000-0000-0000-0000-000000000013'
        and relationship_kind='affiliate' and ends_on is null))$$,
  'parent-side admin ends the affiliate relationship'
);

select is(
  (select count(*)::integer from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000010'
      and child_organization_id='f0000000-0000-0000-0000-000000000013'
      and relationship_kind='affiliate' and ends_on is not null),
  1,
  'the ended affiliate relationship carries an ends_on date'
);

select throws_ok(
  $$select public.end_organization_relationship((
    select id from public.organization_relationships
      where parent_organization_id='f0000000-0000-0000-0000-000000000010'
        and child_organization_id='f0000000-0000-0000-0000-000000000013'
        and relationship_kind='affiliate' and ends_on is not null))$$,
  null, 'Active organization relationship not found',
  'ending an already-ended relationship is refused'
);

select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000013','affiliate')$$,
  'upsert reopens an ended relationship instead of creating a duplicate'
);

select is(
  (select count(*)::integer from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000010'
      and child_organization_id='f0000000-0000-0000-0000-000000000013'
      and relationship_kind='affiliate' and ends_on is null),
  1,
  'exactly one active affiliate relationship after reopen'
);

-- ---------------------------------------------------------------------------
-- Flexible relationship kinds (sanctioned + predecessor)
-- ---------------------------------------------------------------------------

-- A sanctioning relationship between two organizations the officer administers.
select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000013','sanctioned')$$,
  'federation officer records a sanctioned relationship'
);

select is(
  (select relationship_kind::text from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000010'
      and child_organization_id='f0000000-0000-0000-0000-000000000013'
      and relationship_kind='sanctioned'),
  'sanctioned',
  'sanctioned relationship recorded'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000010','f0000000-0000-0000-0000-000000000013','sanctioned')$$,
  null, 'That organization relationship is already active',
  'the active-duplicate rule applies to sanctioned relationships'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000012','f0000000-0000-0000-0000-000000000010','sanctioned')$$,
  null, 'Organization hierarchy cycle detected',
  'the cycle guard applies to sanctioned relationships too'
);

-- A lineage link from an established organization to a younger one that is
-- not part of the governing chain (013 -> 015), so the chain stays acyclic.
select lives_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000013','f0000000-0000-0000-0000-000000000015','predecessor')$$,
  'federation officer records a predecessor lineage link'
);

select is(
  (select relationship_kind::text from public.organization_relationships
    where parent_organization_id='f0000000-0000-0000-0000-000000000013'
      and child_organization_id='f0000000-0000-0000-0000-000000000015'
      and relationship_kind='predecessor'),
  'predecessor',
  'predecessor relationship recorded'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000013','f0000000-0000-0000-0000-000000000015','predecessor')$$,
  null, 'That organization relationship is already active',
  'the active-duplicate rule applies to predecessor relationships'
);

select throws_ok(
  $$select public.upsert_organization_relationship(
    'f0000000-0000-0000-0000-000000000015','f0000000-0000-0000-0000-000000000013','predecessor')$$,
  null, 'Organization hierarchy cycle detected',
  'a predecessor link back down the chain is refused by the cycle guard'
);

-- The ancestor helper surfaces both new kinds with their own direction.
select ok(
  exists(
    select 1 from public.organization_ancestors('f0000000-0000-0000-0000-000000000013')
    where relationship_kind = 'sanctioned'
  ),
  'the sanctioning body appears among the sanctioned organization ancestors'
);

select ok(
  exists(
    select 1 from public.organization_ancestors('f0000000-0000-0000-0000-000000000015')
    where relationship_kind = 'predecessor'
  ),
  'the predecessor appears among the successor ancestors'
);

-- ---------------------------------------------------------------------------
-- Audit and public reads
-- ---------------------------------------------------------------------------

select is(
  (select count(*)::integer from public.audit_log
    where table_name='organization_relationships' and action='insert'),
  5,
  'relationship creation is written to the audit log (five creates)'
);

select ok(
  exists(
    select 1 from public.audit_log
    where table_name='organization_relationships' and action='update'
  ),
  'relationship endings/reopens are audited as updates'
);

set local role anon;
select is(
  (select count(*)::integer from public.organization_ancestors('f0000000-0000-0000-0000-000000000012')),
  2,
  'anonymous can read the ancestor chain (public federation data)'
);

select is(
  (select count(*)::integer from public.organization_relationships),
  5,
  'anonymous can read the full public relationship set'
);

select * from finish();
rollback;