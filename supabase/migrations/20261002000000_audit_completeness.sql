-- Forward-only audit coverage for the remaining core entities.
--
-- The shared audit pipeline (private.capture_audit_change -> public.audit_log)
-- already covers event_roster_entries, matches, disciplinary_cards, fight_notes,
-- announcements, event_memberships, event_registrations (operational hardening),
-- fighter_identities, clubs, fighter_affiliations, competition_divisions,
-- event_divisions, fighters, teams (identity foundation), fight_cards (security
-- hardening), suspensions (discipline), and organization_relationships
-- (federation). This increment wires the same trigger onto the rest of the
-- core gap list: brackets, organizations, seasons, events, rulesets,
-- ruleset_sources, event_ruleset_snapshots, and profiles.
--
-- Org scoping: capture_audit_change resolves a row's organization from its
-- organization_id, falling back to the owning event's organization_id. Rows
-- whose own organization cannot be derived (organizations themselves, profiles,
-- ruleset_sources) are recorded with organization_id NULL and stay visible only
-- to platform administrators through the audit_staff_read policy.

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'brackets',
    'organizations',
    'seasons',
    'events',
    'rulesets',
    'ruleset_sources',
    'event_ruleset_snapshots',
    'profiles'
  ]
  loop
    execute format('drop trigger if exists audit_change on public.%I', v_table);
    execute format(
      'create trigger audit_change after insert or update or delete on public.%I for each row execute function private.capture_audit_change()',
      v_table
    );
  end loop;
end;
$$;