begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- BI is imported into the hosted project rather than seeded by migrations, so a replay has no BI row. Provide one.
insert into public.organizations (id, name, short_name, kind)
  select '2d37d0f8-14e4-5b11-8c6e-0c03f98a26d1', 'Buhurt International', 'BI', 'international_federation'
  where not exists (select 1 from public.organizations where short_name = 'BI');
update public.organizations set featured = true, featured_order = 1 where short_name = 'BI';

-- Featured is configuration, not data removal.
select is((select count(*)::integer from public.organizations where short_name in ('BI','HACSA') and featured), 2,
  'BI and HACSA are configured as featured organizations');

set local role anon;

select is((select array_agg(organization_short_name order by featured_order) from public.public_featured_organizations()),
  array['BI','HACSA'], 'anonymous visitors see BI then HACSA as featured, in configured order');

select ok((select count(*) from public.public_featured_teams()) between 1 and 40,
  'the featured team list is small and public');

select ok(not exists (select 1 from public.public_featured_teams() where organization_short_name <> 'HACSA'),
  'the featured team list holds only configured teams, never the whole worldwide directory');

select ok((select count(*) from public.public_team_directory_v3()) >= (select count(*) from public.public_featured_teams()),
  'the full directory is still available and is a superset of the featured list');

select throws_ok($$update public.organizations set featured = false$$, '42501', null,
  'anonymous visitors cannot change prominence');

reset role;
select * from finish();
rollback;
