-- Pack 1 release hardening applied to the dedicated hosted BuhurtOS project.
-- Keep public event reads useful while preventing anonymous access to private
-- operational fields such as notes, custom rules, audit actors, and timestamps.
revoke select on table public.events from anon;

grant select (
  id, organization_id, season_id, name, venue, starts_at, ends_at,
  organizer_name, event_type, standings_mode, status, timezone,
  livestream_url, registration_open, registration_fee_cents, currency,
  ruleset_id, ruleset_snapshot_id, public_description, public_links,
  registration_opens_at, registration_closes_at, registration_capacity,
  waitlist_enabled, published_at, cancelled_at
) on public.events to anon;
