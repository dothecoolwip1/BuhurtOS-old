# BuhurtOS November 1 readiness

Checked 2026-10-01. This replaces the 2026-09-30 version, several claims of which were stale (it said the Rumble had no poster and
that registration had no codes or eligibility). The authoritative status table is the top of `BUHURTOS_STATUS.md`.

**How to read "verified".** Each row says where it was proven. The levels are: *pgTAP / unit* (CI), *hosted DB boundary*
(real hosted schema and real Rumble/HACSA/Reavers records, test identities inside a transaction that was rolled back, nothing
persisted), *production, anonymous* (real browser or HTTP against the live site and backend), *production, signed in* (a real
account in a real browser). **No row is "production, signed in".** I do not create accounts, and the local Supabase stack
needs Docker, which is not available here.

## Scenarios from the release acceptance test

| Scenario | State | Evidence |
|---|---|---|
| A. Public visitor: home, BI and HACSA, teams, Reavers, events, Rumble, rankings, rules | Verified, production anonymous | Real browser on the deployed site at 360 px: home leads with BI and HACSA (3 data requests, no directory fetch); Teams opens on Featured with Red Deer Reavers first and loads all 354 teams only on request; search finds worldwide teams; the old `/teams/reavers` address redirects to the canonical team; the Rumble page and its poster load; rules search finds tiers, structure guidance, the tiebreak order and documents, each labeled by kind |
| B. Rumble fighter signup | Server behavior verified; UI verified signed out | Hosted DB boundary: 35 scenarios pass (wrong code refused, valid code accepted, eligible fighter registers with no code, out-of-scope and unverifiable fighters need a code or a request, request/approve/deny/notify, no extra roles, closed, already registered, revoked membership). Real browser, signed out: the dialog reads "Enter your event registration code" and a wrong code is recoverable. The signed-in dialog states are unit-tested copy only |
| C. Organizer reviews requests and signups | DB boundary verified; UI not walked | Reviewer authority and unrelated-admin refusal verified on hosted; the organizer queue UI has not been used with a real session |
| D. Platform super admin | Not verified | Needs a signed-in walk |
| E. Non-competitive event | Unit-tested; not created on production | Setup guide and new-event flow skip tournament steps (11 tests) |
| F. Embeds | Verified earlier (2026-09-30); standings widget now states its tiebreak basis | Not re-run in this pass |
| G. Mobile | Verified | 360, 390, 412, 768 px and desktop: no horizontal overflow on any checked route; touch targets fixed where found (see `RELEASE_USABILITY_TEST.md`) |
| H. Performance | Verified | Home 3 data requests; Featured teams one small request; the 354-team directory loads only for the BI, HACSA and Worldwide tabs or a search |

## Red Deer Rumble: actual hosted state (2026-10-01)

| Field | Value |
|---|---|
| Status | published |
| Dates | Nov 14 to Nov 16 2026 UTC (America/Edmonton), Horse in Hand Ranch, Blackfalds, Alberta |
| Host team and organization | Red Deer Reavers (canonical), HACSA |
| Category | `custom` (legacy label); shows as "Custom" |
| Poster | attached and publicly loads; poster description not written, so the page announces "Red Deer Rumble poster" |
| Registration | `registration_open = false`; no opens or closes dates; no capacity |
| **Registration access scope** | **`invite_only`**: everyone needs a signup code, including Reavers fighters |
| Ruleset | none assigned |
| Competitions, divisions | 0 and 0 |
| Event roles (organizers, marshals) | none recorded |
| Signup codes, signups, access requests | 0, 0, 0 |
| Announcements | 1 |
| Schedule | public page states "to be announced" (`schedule_tba`) |

### Owner decisions still needed (not made by me)

1. **Who may register without a code.** Today `invite_only`. Setting "Organization and its teams and clubs" (Fighter signups, "Who can register
   without a code") lets a fighter with a linked BuhurtOS fighter profile and an active membership on any HACSA team register with no code;
   everyone else still uses a code or asks permission. Only the owner, an organization admin or an event organizer can change it. Hosted has
   one fighter identity, so today this would affect at most that one person; it matters once more fighters link their profiles.
2. **Category.** Set the Rumble to "Tournament" if it is one; it shows "Custom" today. (Changing it also enables competition steps.)
3. **Registration window.** Decide when registration opens and closes (BI Tournament Structure asks registration to close at least 15 days before
   the event: Oct 30 2026 at the latest).
4. **Poster description.** Optional but recommended: write one in Event settings.
5. **Competitions and divisions.** Create the real ones once they are known; none were invented.

## Security posture (hosted, 2026-10-01)

* Advisors reviewed in context: the warnings are intentional public RPCs, row-level-secured tables visible to GraphQL, and leaked-password
  protection (a dashboard toggle, off; owner decision).
* **Fixed this pass:** hosted still let anonymous visitors read `team_memberships` including account ids, and creator columns on five public
  tables. Repository migration `20261011` had already revoked it; hosted had drifted. Corrected by `20261022` and proven with pgTAP.
* Poster and media changes are limited to platform admins, organization admins of the event's chain, event organizers and host-team admins or
  captains. Previously a plain host-team fighter could replace the poster.

## Known drift risk

Hosted migration names do not all match the repository's (some were applied by hand). The repository is the intent; a clean replay is what CI
proves. When touching privileges, query hosted directly after applying (`has_table_privilege`, `has_column_privilege`), as this pass did.

## Time bombs

Several pgTAP fixtures use 2026 season dates ending 2026-12-31. They will fail after that date regardless of code. Fixtures should use dates
relative to `now()`; `discipline_suspensions` was fixed this pass because it expired at 2026-10-01T00:00Z.
