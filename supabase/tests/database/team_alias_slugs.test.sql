-- Reconciled duplicate teams keep their old public address working.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
 ('73000000-0000-0000-0000-000000000001','authenticated','authenticated','ta-super@buhurtos.test','',now(),'{}','{"display_name":"Alias Super"}',now(),now()),
 ('73000000-0000-0000-0000-000000000002','authenticated','authenticated','ta-user@buhurtos.test','',now(),'{}','{"display_name":"Alias User"}',now(),now());
insert into public.platform_memberships(user_id,role) values ('73000000-0000-0000-0000-000000000001','platform_super_admin');
insert into public.organizations(id,name,short_name,region,status) values ('73000000-0000-0000-0000-000000000010','TA Org','TAO','Test','active');
insert into public.teams(id,organization_id,name,city_or_region,directory_slug,visibility,is_active,status) values
 ('73000000-0000-0000-0000-000000000020','73000000-0000-0000-0000-000000000010','Alias Reavers','Test','alias-reavers','public',true,'active'),
 ('73000000-0000-0000-0000-000000000021','73000000-0000-0000-0000-000000000010','Canonical Reavers','Test','canonical-reavers','public',true,'active');

select is(public.resolve_team_alias_slug('alias-reavers'), null, 'before linking, an address is not an alias');

set local role authenticated;
select set_config('request.jwt.claim.sub','73000000-0000-0000-0000-000000000002',true);
select throws_ok($$select public.link_duplicate_team('73000000-0000-0000-0000-000000000020','73000000-0000-0000-0000-000000000021','Duplicate listing')$$,
  'P0001','Only platform super administrators can link duplicate teams','an ordinary user cannot link duplicate teams');
select set_config('request.jwt.claim.sub','73000000-0000-0000-0000-000000000001',true);
select lives_ok($$select public.link_duplicate_team('73000000-0000-0000-0000-000000000020','73000000-0000-0000-0000-000000000021','Duplicate listing')$$, 'a platform admin links the duplicate');
reset role;

select is((select alias_slug from public.team_canonical_links where alias_team_id='73000000-0000-0000-0000-000000000020'), 'alias-reavers', 'the alias address is remembered');
select ok(exists(select 1 from public.teams where id='73000000-0000-0000-0000-000000000020'), 'the alias team row is preserved, not deleted');

set local role anon;
select is(public.resolve_team_alias_slug('alias-reavers'), 'canonical-reavers', 'anonymous visitors following the old address are sent to the canonical team');
select is(public.resolve_team_alias_slug('no-such-team'), null, 'an unknown address resolves to nothing');
select is(has_column_privilege('anon','public.team_canonical_links','created_by','SELECT'), false, 'anonymous visitors still cannot read who linked the teams');
reset role;

-- A canonical team that is not public never leaks its slug through the resolver.
update public.teams set visibility = 'private' where id = '73000000-0000-0000-0000-000000000021';
set local role anon;
select is(public.resolve_team_alias_slug('alias-reavers'), null, 'a non-public canonical team is not revealed');
reset role;

select * from finish();
rollback;
