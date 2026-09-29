-- Hosted Supabase privilege hardening.
--
-- Older Supabase projects can retain legacy default privileges that grant broad
-- Data API access to newly created public tables and functions. BuhurtOS uses
-- explicit grants plus RLS, so make future exposure opt-in and remove legacy
-- inherited write privileges from RPC-only tables.

alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke execute on functions from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke usage, select on sequences from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke execute on functions from public;

-- Membership records are authenticated-only reads. All writes go through
-- guarded RPCs.
revoke all privileges on table public.club_memberships from anon, authenticated;
revoke all privileges on table public.team_memberships from anon, authenticated;
revoke all privileges on table public.membership_requests from anon, authenticated;

grant select on table public.club_memberships to authenticated;
grant select on table public.team_memberships to authenticated;
grant select on table public.membership_requests to authenticated;

-- Suspensions are private to authorized authenticated readers and RPC-only for
-- writes.
revoke all privileges on table public.suspensions from anon, authenticated;
grant select on table public.suspensions to authenticated;

-- Federation relationships are public sporting/governance facts but remain
-- RPC-only for writes.
revoke all privileges on table public.organization_relationships from anon, authenticated;
grant select on table public.organization_relationships to anon, authenticated;

-- Published rulesets are public. Authenticated ruleset administration keeps
-- the direct mutations already governed by RLS.
revoke all privileges on table public.rulesets from anon, authenticated;
grant select on table public.rulesets to anon, authenticated;
grant insert, update, delete on table public.rulesets to authenticated;
