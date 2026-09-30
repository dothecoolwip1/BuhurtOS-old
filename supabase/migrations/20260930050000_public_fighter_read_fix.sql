-- Fix anonymous public fighter directory reads.
--
-- The public fighter query exposes verified state and historically filtered
-- active/unmerged rows directly. RLS already restricts anon reads to active,
-- unmerged fighter identities whose profile_visibility is public.
--
-- Keep these narrowly scoped column grants in sync with the public directory
-- query. Private fighter profile data remains in separate protected tables.

grant select (verified_at, deleted_at, merged_into_identity_id)
  on table public.fighter_identities
  to anon;
