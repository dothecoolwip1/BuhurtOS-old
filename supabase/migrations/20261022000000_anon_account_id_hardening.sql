-- Anonymous visitors must never read account identifiers (auth user ids).
--
-- 1. public.team_memberships: 20261011 already revoked anonymous access and dropped the anon roster policy, but the
--    hosted project still had both (it was configured by hand). This makes that state explicit and idempotent everywhere.
--    The public roster is served by public_team_roster(); nothing needs direct table access.
-- 2. Tables that are public on purpose keep their rows public but stop exposing who created or edited them: anonymous
--    SELECT becomes column-level and omits every account-identifier column. Signed-in roles are unchanged.
--    Columns added later are NOT visible to anonymous visitors until someone grants them deliberately.

drop policy if exists team_memberships_anon_public_roster_read on public.team_memberships;
revoke all on public.team_memberships from anon;

do $$
declare
  t text;
  visible_columns text;
begin
  foreach t in array array[
    'organization_relationships', 'announcements', 'fight_cards', 'team_canonical_links',
    'competition_divisions', 'event_divisions', 'event_competitions', 'matches', 'ruleset_sources', 'rulesets'
  ] loop
    select string_agg(quote_ident(a.attname), ', ' order by a.attnum)
      into visible_columns
      from pg_attribute a
     where a.attrelid = ('public.' || quote_ident(t))::regclass
       and a.attnum > 0
       and not a.attisdropped
       and a.attname not in ('user_id', 'created_by', 'last_edited_by', 'reviewed_by', 'submitted_by_user_id');
    execute format('revoke select on public.%I from anon', t);
    execute format('grant select (%s) on public.%I to anon', visible_columns, t);
  end loop;
end $$;

notify pgrst, 'reload schema';
