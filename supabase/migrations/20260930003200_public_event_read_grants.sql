-- Public event pages use the anonymous Supabase client. RLS limits visible rows,
-- and explicit column grants keep private operational fields out of the Data API.
revoke select on table public.events from anon;
grant select (
  id, organization_id, season_id, name, venue, starts_at, ends_at,
  organizer_name, event_type, standings_mode, status, timezone,
  livestream_url, registration_open, registration_fee_cents, currency,
  ruleset_id, ruleset_snapshot_id, public_description, public_links,
  registration_opens_at, registration_closes_at, registration_capacity,
  waitlist_enabled, published_at, cancelled_at
) on public.events to anon;

revoke select on table public.announcements from anon;
grant select (
  id, event_id, title, body, is_public, scheduled_for, created_at
) on public.announcements to anon;

revoke select on table public.fight_cards from anon;
grant select (
  id, event_id, name, list_name, status, sort_order
) on public.fight_cards to anon;

revoke select on table public.event_divisions from anon;
grant select (
  id, event_id, division_id, division_snapshot, registration_limit,
  is_registration_open, created_at
) on public.event_divisions to anon;

revoke select on table public.competition_divisions from anon;
grant select (
  id, name
) on public.competition_divisions to anon;

revoke select on table public.matches from anon;
grant select (
  id, organization_id, season_id, event_id, fight_card_id, bracket_id,
  division_id, ruleset_snapshot_id, label, category, match_type,
  scoring_config, status, stage, scheduled_order, bracket_round, bracket_slot,
  winner_advances_to_match_id, winner_advances_to_slot,
  loser_advances_to_match_id, loser_advances_to_slot,
  started_at, completed_at, finalized_at, result_summary
) on public.matches to anon;
