-- Anonymous visitors never see account identifiers (auth user ids), while public rows stay public.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

select is(has_table_privilege('anon', 'public.team_memberships', 'SELECT'), false, 'anon has no access to team_memberships');
select is((select count(*)::integer from pg_policy where polrelid = 'public.team_memberships'::regclass and 'anon'::regrole = any (polroles)), 0, 'no policy grants anon access to team_memberships');

select is(has_column_privilege('anon', 'public.announcements', 'created_by', 'SELECT'), false, 'anon cannot read announcements.created_by');
select is(has_column_privilege('anon', 'public.announcements', 'title', 'SELECT'), true, 'anon can still read announcement titles');
select is(has_column_privilege('anon', 'public.fight_cards', 'created_by', 'SELECT'), false, 'anon cannot read fight_cards.created_by');
select is(has_column_privilege('anon', 'public.fight_cards', 'last_edited_by', 'SELECT'), false, 'anon cannot read fight_cards.last_edited_by');
select is(has_column_privilege('anon', 'public.fight_cards', 'name', 'SELECT'), true, 'anon can still read fight card names');
select is(has_column_privilege('anon', 'public.organization_relationships', 'created_by', 'SELECT'), false, 'anon cannot read organization_relationships.created_by');
select is(has_column_privilege('anon', 'public.organization_relationships', 'parent_organization_id', 'SELECT'), true, 'the public hierarchy stays public');
select is(has_column_privilege('anon', 'public.team_canonical_links', 'created_by', 'SELECT'), false, 'anon cannot read team_canonical_links.created_by');
select is(has_column_privilege('anon', 'public.team_canonical_links', 'canonical_team_id', 'SELECT'), true, 'alias resolution stays public');

-- No table anywhere in public exposes a created_by / user_id style column to anon.
select is(
  (select count(*)::integer
     from pg_attribute a
     join pg_class c on c.oid = a.attrelid
     join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind in ('r','v','m')
      and a.attname in ('user_id','created_by','last_edited_by','reviewed_by','submitted_by_user_id')
      and a.attnum > 0 and not a.attisdropped
      and has_column_privilege('anon', a.attrelid, a.attnum, 'SELECT')),
  0, 'anon can read no account-identifier column in any public table');

-- The public roster is served by a function, not by table access.
select ok(has_function_privilege('anon', 'public.public_team_roster(uuid)', 'EXECUTE'), 'the public roster function is still callable by anon');

select * from finish();
rollback;
