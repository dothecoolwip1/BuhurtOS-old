# BuhurtOS Handoff

## Owner console and logout repair, September 30

The owner console now separates overview, organizations, events, and people;
shows organization scope; provides shortcut cards and responsive navigation.
Sign out is in the header on mobile and desktop, handles request errors, and
ends the current Supabase session. Session-generation guards prevent pending
account/event reads from restoring signed-out state; private event state clears
on SIGNED_OUT. No database schema or authorization policies changed.

Validation: 78 unit tests, TypeScript, production build, and navigation audit
passed locally. Browser verification was attempted but this execution environment
blocks Chromium startup (socket operation not permitted); visual and authenticated
browser verification remain outstanding. Hosted deployment status must be checked
against the resulting commit, not inferred from the local build.

Last updated: 2026-09-29

## Current handoff: Pack 1 release baseline

The new master execution plan in `docs/BUHURTOS_MASTER_EXECUTION_PLAN.txt` is
authoritative. Pack 1 is complete through implementation checkpoint
`0fe40cae77da55d1eec65908bc1411b2715079c5`.

The release baseline now has one gated GitHub Actions workflow, clean TypeScript,
unit/build checks, route and dead-control auditing, replayable Supabase migrations,
pgTAP coverage, a GitHub Pages deploy gate, explicit public load-error states, and
mobile-safe public team deep links.

Hosted backend source of truth:

* Supabase organization: `vbxznwtocyorcfghzdfo`
* Supabase project: `tapfpboszgoftbwcwsmn`
* Pack 1 hosted ACL migration: `20260930042147_pack1_public_event_privilege_hardening`
* Anonymous `events.notes` access was rechecked after the migration and is denied.
* Public event description and registration fields remain anonymously readable.
* Production data was not reset or deleted.

Do not resume an older historical pack from the provenance notes below. The next
master-plan pack is Pack 2 and should only begin when explicitly requested.

## Resume here

The historical checkpoint below is superseded. Current `main` includes Round 17
Pack 7 tournament generation (`7b9a736`), Round 18 Pack 4 data layer
(`ff82c3f`), and Round 18 UI/workflow completion (`901257c`). The next pending
release adds secure fighter-avatar storage. Its local verification must never be
mistaken for hosted Supabase/Edge verification. The dedicated Supabase organization is `vbxznwtocyorcfghzdfo` (BuhurtOS) and the active hosted project is `tapfpboszgoftbwcwsmn`; only this BuhurtOS backend may be used. The Northborn/Mallard/Reavers project remains prohibited.

Pack 6 is complete and merged to `main` in PR #10.

Verified Pack 6 implementation head: `789cca1daf8208a6732863409639546744acf52e`.

Successful Pack 6 verification workflow: `36080004581`.

Pack 6 merge commit: `c6bbd937ed9a08592ca633325a848e2e765f4382`.

That workflow passed both required jobs: frontend typecheck/tests/production build and a clean Supabase rebuild with all pgTAP database tests.

### Current state: Rounds 7–16 on `main`

The head of `main` is `c4d1f6f`. Ten rounds are pushed on top of the Pack 6 checkpoint:

**Round 7 — discipline, suspensions, and offline hardening (`27566ef`):**

* Forward migration `supabase/migrations/20260930010000_discipline_suspensions.sql` — `disciplinary_cards` + `suspensions` tables, guarded `issue_discipline_card` / `issue_suspension` / `revoke_suspension` RPCs, additive `prevent_clearance_while_suspended` trigger on `event_roster_entries`, RLS read scoping, audit triggers, `discipline_write` policy removed, deliberate anon/authenticated SELECT grants on `suspensions`. The `issue_suspension` RPC carries a test-only trailing `p_id` so the suite can seed a deterministic suspension id referenced by non-privileged roles.
* pgTAP suite `supabase/tests/database/discipline_suspensions.test.sql` — 27 assertions, green under the local replay harness.
* Offline-queue hardening in `src/lib/offlineQueue.ts` + `tests/offlineQueue.test.ts`: 30s stale-`syncing` repair, auto-retry capped at 8 attempts with exponential backoff, manual retry resets the counter, per-process in-flight flush guard.
* Discipline UI rewrite in `src/pages/DisciplinePage.tsx` (RPC-based card issuance, suspensions issue/list/revoke panel, demo-mode fallback), `Suspension` in `src/types.ts`, and CSS for `.susp-dot` / `.field-hint` / `.ghost` in `src/styles.css`.
* First CI database run exposed a stale `mega4_release_hardening.test.sql` assertion (direct `disciplinary_cards` inserts). `3b52176` flipped it to the RPC-only contract (RLS-blocked, sqlstate 42501).

**Round 8 — public spectator surface disambiguation (`c7fab9c`):**

* The persistent `DemoNotice` banner has since been removed at the owner’s direction. Sample-only scoreboard/status labels remain where needed to avoid presenting preview values as live results.
* Preview/live wording remains separated so demo-only content is not mistaken for tournament records.

**Round 9 — Long Axe competition format (`e3fe92d`):**

* Added `long_axe` to `competitionFormats.ts` as a `verified` BI duel preset (`duel()` scoring; scoring deferred to the sourced ruleset). Asserted in `tests/governance.test.ts`.

**Round 10 — federation hierarchy (`b4b3795`, workflow `36534422890` green):**

* `supabase/migrations/20261001000000_federation_hierarchy.sql` — `organization_kind`/`country_code` on organizations; `organization_relationships` (governs/recognizes/affiliate) with active window, generated `organization_id` org-context mirror, public reads, RPC-only writes. Guarded `upsert_organization_relationship` / `end_organization_relationship` RPCs enforce bilateral admin consent, active-org residency, active-duplicate refusal, end/reopen lifecycle, and cycle protection; `organization_ancestors` exposes chains; anon revoked from write RPCs; writes audit-captured.
* `supabase/tests/database/federation_hierarchy.test.sql` — 34 assertions (schema, ACLs, role-gated writes, RLS-blocked direct writes, lifecycle, cycles, audit, public reads).

**Round 11 — broader exports (`5e67501`, workflow `36535409276` green):**

* `export.ts` shares one `csv()` routine (commas/quotes/newline escaping) across standings, matches/order of play, discipline cards, suspensions, and roster-report builders, plus an `htmlTable` helper. BracketPage wires `matchesCsv` (Export CSV) and a printable order of play; DisciplinePage exports cards + suspensions CSV and a combined printable report; RosterPage exports the registration report CSV and a printable compliance report.
* `tests/export.test.ts` — 6 assertions; full suite 42/42, typecheck and production build clean; buttons verified in-browser on the ops pages.

**Round 12 — audit completeness (`de109b9`, workflow `36536214636` green):**

* `supabase/migrations/20261002000000_audit_completeness.sql` — the shared `audit_change` trigger (→ `public.audit_log`) is wired onto brackets, organizations, seasons, events, rulesets, ruleset_sources, event_ruleset_snapshots, and profiles. Announcements and event_registrations were already audited (operational hardening) and gain regression guards. Org scope resolves from the row's `organization_id`, falling back to the owning event; org-less rows (organizations themselves, profiles, ruleset_sources) stay platform-admin-visible only.
* `supabase/tests/database/audit_completeness.test.sql` — 26 assertions (trigger presence, insert/update/delete capture, event-derived org scope, unscoped-row behavior).

Local verification on the corrected head: `npm run typecheck` clean, `npm test` 42/42, production build clean, in-browser DOM assertions confirm the Export/Print buttons on the ops pages, and the full 10-suite pgTAP replay is green with real role switching + RLS semantics. **CI is green on the combined head `de109b9`: workflow `36536214636` passed the frontend job, the authoritative pgTAP database job (10 suites), and the GitHub Pages deploy (site live at <https://dothecoolwip1.github.io/BuhurtOS/>).**

**Round 13 — embeddable widgets + fuller public profiles (`a71c1d0`, validated on combined head `b61dccd`):**

* Chrome-free standings widget at `#/widget/standings` rendered straight from the live event board — `computeEventStandings` over real AppState, DEMO DATA badge in demo builds, public-mode read in Supabase mode, no site chrome. `src/lib/embed.ts` (`widgetEmbedCode`/`widgetStandingsUrl`) builds the widget URL + escaped iframe snippet; StandingsPage gains an Embed widget control with a copy button, visible snippet, and preview link.
* `DemoFighter` gains weight class, experience level/years, socials, tournament history; `DemoTeam` gains socials and season results. FighterProfilePage renders Tournament history / Profile / Socials panels; TeamPage renders Season results / Socials. `tests/embed.test.ts` — 7 assertions; full suite 49/49, typecheck/build clean; verified in-browser.

**Round 14 — Marathon verified flow (`b61dccd`, workflow `36537529093` green):**

* `competitionFormats.ts` promotes `marathon` from `custom_template` to `verified` (Long Axe precedent): a first-class verified endurance category with `duel(1)` scoring deferred to the sourced ruleset. `governance.test.ts` asserts marathon is in `verifiedCompetitionFormats` and not an organization template.
* With this, the planned product gap list is closed; the remaining matrix items are roadmap-only (see `docs/COMPLETION_MATRIX.md`).

**Round 15 — team standings board + fight-card-level exports (`7f67eab`, validated on combined head `c4d1f6f`):**

* `computeTeamStandings` in `src/lib/standings.ts` rolls finalized cross-team fighter bouts up per team (3/1/0; differential → points-for → wins → name; distinct-fighter count). Intra-team, unaffiliated/individual, non-finalized and `bye` bouts earn no points. `StandingsPage` gains a Fighters/Teams toggle (Teams renders only when the event has teams) with team CSV + printable board; the embeddable widget stays fighter-only.
* `supabase/migrations/20261003000000_event_teams_public_read.sql` — security-definer `public.event_teams(event)` returns the distinct teams referenced by an event roster (id, name, city/region), execute granted to anon/authenticated, so public team names resolve without exposing the org-wide team catalog. Demo snapshot derives the same from `demoEventTeams`.
* `fightCardCsv`/`FightCardExportView` in `src/lib/export.ts` wire fight-card-level CSV (card metadata + matches table) to the ops active-field header ("Export card CSV", "Print / PDF") and each field row on `EventManagementPage`.
* `tests/standings.test.ts` (6) + `tests/export.test.ts` additions; `supabase/tests/database/event_teams_public_read.test.sql`; verified in-browser (toggle empty state → populated board, both CSV downloads).

**Round 16 — flexible organization relationship kinds (`c4d1f6f`, workflow `36567325902` green):**

* `supabase/migrations/20261004000000_flexible_org_relationship_kinds.sql` adds `sanctioned` and `predecessor` to `organization_relationship_kind` (order `governs, recognizes, affiliate, sanctioned, predecessor`). No RPC change was needed — the guarded upsert/end functions take the enum type, so bilateral consent, active-duplicate refusal, lifecycle and cycle protection apply to all kinds; `organization_ancestors` walks them.
* `federation_hierarchy.test.sql` pins the enum order and proves create/duplicate/cycle/ancestor behavior for both kinds. Full 11-suite pgTAP replay green locally.

**CI is green on the combined head `c4d1f6f`: workflow `36567325902` passed the frontend job, the authoritative pgTAP database job (11 suites), and the GitHub Pages deploy (site live at <https://dothecoolwip1.github.io/BuhurtOS/>).** The Round 15 head `7f67eab` was superseded by the immediate Round 16 push, so its CI evidence is this combined-head run.

**pgTAP error-pattern lesson:** the supabase-bundled pgTAP does not treat `%` as a wildcard in `throws_ok` errmsg, and it does not ship `throws_like` at all. `throws_ok` matches the errmsg argument against the **verbatim full `MESSAGE_TEXT`**. Discipline assertions now pass exact messages (e.g. `Not authorized to revoke suspensions`, `Fighter is under an active suspension until 2026-10-01`). Keep new `throws_ok` message arguments verbatim and full — never partial substrings or `%` wrappers.

Do not apply BuhurtOS migrations to the currently connected Supabase project unless it is independently confirmed to be a dedicated BuhurtOS project. The project inspected during Pack 2 contains Northborn, Mallard, and Reavers data and is not the BuhurtOS target.

## This round — files to know

Rounds 15 + 16 (team standings + fight-card exports, flexible org relationships):

* `src/lib/standings.ts` (`computeTeamStandings`, `TeamStandingRow`)
* `src/lib/export.ts` (`fightCardCsv`, `FightCardExportView`, `teamStandingsCsv`)
* `src/pages/StandingsPage.tsx` (Fighters/Teams toggle, team CSV + print)
* `src/pages/OpsPage.tsx` (active-field "Export card CSV" / "Print / PDF")
* `src/pages/EventManagementPage.tsx` (per-field `CSV` in `field-row-actions`)
* `src/data/demo.ts` (`demoEventTeams`), `src/lib/repository.ts` (`EventSnapshot.teams` → `event_teams` RPC), `src/features/AppState.tsx` (`teams`)
* `supabase/migrations/20261003000000_event_teams_public_read.sql`
* `supabase/migrations/20261004000000_flexible_org_relationship_kinds.sql`
* `supabase/tests/database/event_teams_public_read.test.sql`
* `supabase/tests/database/federation_hierarchy.test.sql` (extended)
* `tests/standings.test.ts`, `tests/export.test.ts`

Round 14 (Marathon verified flow):

* `src/lib/competitionFormats.ts`
* `tests/governance.test.ts`

Round 13 (embeddable widgets + fuller public profiles):

* `src/lib/embed.ts`
* `src/pages/StandingsWidgetPage.tsx`
* `src/pages/StandingsPage.tsx`, `src/pages/FighterProfilePage.tsx`, `src/pages/TeamPage.tsx`
* `src/data/showcase.ts`, `src/App.tsx`, `src/styles.css`
* `tests/embed.test.ts`

Round 12 (audit completeness):

* `supabase/migrations/20261002000000_audit_completeness.sql`
* `supabase/tests/database/audit_completeness.test.sql`

Round 11 (broader exports):

* `src/lib/export.ts`
* `src/pages/BracketPage.tsx`, `src/pages/DisciplinePage.tsx`, `src/pages/RosterPage.tsx`
* `tests/export.test.ts`

Round 10 (federation hierarchy):

* `supabase/migrations/20261001000000_federation_hierarchy.sql`
* `supabase/tests/database/federation_hierarchy.test.sql`

Round 9 (Long Axe):

* `src/lib/competitionFormats.ts` (`long_axe` preset)
* `tests/governance.test.ts` (verified-formats assertion)

Round 7 (discipline + suspensions + offline):

* `supabase/migrations/20260930010000_discipline_suspensions.sql`
* `supabase/tests/database/discipline_suspensions.test.sql`
* `supabase/tests/database/mega4_release_hardening.test.sql` (updated assertion)
* `src/pages/DisciplinePage.tsx`
* `src/types.ts` (`Suspension`, `DisciplineCard`)
* `src/lib/offlineQueue.ts`
* `tests/offlineQueue.test.ts`

Round 8 (public-surface disambiguation):

* `src/components/ShowcaseShell.tsx`
* `src/pages/ShowcasePublicPage.tsx`
* `src/pages/ShowcaseDashboard.tsx`
* `src/pages/ShowcaseEventPage.tsx`
* `src/pages/ShowcaseEventsPage.tsx`
* `src/pages/MarketingHome.tsx`
* `src/styles.css` (`.demo-notice*`, `.show-demo-pill`, `.show-demo-dot`)

## This round — rules that must remain

* `public.event_teams(uuid)` must stay a read-only security-definer helper scoped to a single event roster. Do not broaden it to the org-wide team catalog or add data beyond id/name/location; its whole purpose is to publish only teams the event already exposes.
* Team standings (`computeTeamStandings`) score finalized cross-team fighter bouts only. Intra-team, unaffiliated/individual, non-finalized and `bye` bouts must never earn team points; keep the 3/1/0 plus differential → points-for → wins → name ordering.
* Organization relationship kinds are extended forward-only (`alter type ... add value`, never removing/reordering existing labels), and the guarded `upsert_organization_relationship` / `end_organization_relationship` RPCs stay the only write path. Every kind must keep bilateral admin consent, active-duplicate refusal, cycle protection and audit capture.
* Fight-card CSV (`fightCardCsv`) and team-standings CSV (`teamStandingsCsv`) stay pure builders in `src/lib/export.ts`; pages only wire them to download/print actions.
* Discipline and suspension writes happen only through the guarded RPCs. The old `discipline_write` policy was dropped; direct browser inserts into `disciplinary_cards` must never be re-enabled.
* Active suspensions block competition clearance in the data layer (`prevent_clearance_while_suspended`), not only in the UI. Do not weaken the trigger or the clearance RPC.
* `revoke_suspension` authorizes against the target row before mutating (`Not authorized` for unauthorized callers holding a valid id).
* The `p_id` parameter on `issue_suspension` exists only for deterministic test seeding (`coalesce(p_id, gen_random_uuid())`). Do not add UI reliance on it.
* `suspensions` remains SELECT-only via RLS plus anon/authenticated read grants; direct writes stay RPC-only.
* Keep the offline queue fail-safe: conflicts require a human retry/discard, stale `syncing` is repaired after 30s, auto-retry is capped (8) with backoff, and manual retry resets the counter.
* Showcase surfaces must not present sample values as verified live tournament results. Keep sample-only scoreboards/statuses explicitly labeled where they remain; the persistent `DemoNotice` banner is intentionally removed.

## Pack 6 files to know

Event and registration workflows:

* `src/lib/eventAdmin.ts`
* `src/lib/registration.ts`
* `src/features/AppState.tsx`
* `src/lib/compliance.ts`
* `src/pages/EventManagementPage.tsx`
* `src/pages/RegistrationPage.tsx`
* `src/pages/RosterPage.tsx`
* `src/pages/PublicPage.tsx`
* `src/types.ts`

Database and tests:

* `supabase/migrations/20260925003000_pack6_events_registration.sql`
* `supabase/tests/database/pack6_events_registration.test.sql`
* `tests/pack6EventsRegistration.test.ts`

## Pack 6 rules that must remain

* Event registration must use governed event divisions and locked competition context when formal divisions exist.
* Missing eligibility facts must remain needs-review rather than silently qualifying an entrant.
* Ineligible or needs-review entrants cannot be approved without the required explicit organizer review path.
* Event and division capacity must be enforced in PostgreSQL under concurrency, not only in the UI.
* Duplicate active registrations must remain database-protected.
* Registration approval, physical check-in, individual clearances, and final marshal competition clearance must remain separate states.
* Revoking a required physical clearance must revoke final competition clearance.
* Withdrawal must preserve registration history while preventing further competition.
* Registration contacts, emergency details, youth facts, waiver information, organizer notes, and account identifiers must not become spectator data.
* Organizer mutations must remain guarded, auditable, organization-scoped, and stale-write aware.
* Do not enable paid registration until a real payment provider and verified webhook are implemented.

## Pack 5 files to know

Governance and frontend workflows:

* `src/lib/governance.ts`
* `src/lib/rulesetAdmin.ts`
* `src/lib/competitionFormats.ts`
* `src/pages/RulesetsPage.tsx` (ruleset workbench)
* `src/pages/GovernancePage.tsx` (governance hierarchy view)
* `src/pages/SetupPage.tsx` (organization + season lifecycle setup)
* `src/pages/AdminPage.tsx` (event setup / organizer tools)
* `src/types.ts`

Database and tests:

* `supabase/migrations/20260924153000_pack5_rulesets_divisions_seasons.sql`
* `supabase/tests/database/pack5_rulesets_divisions_seasons.test.sql`
* `tests/governance.test.ts`
* `tests/rulesets.test.ts` (includes permission-scoping coverage)

## Pack 5 rules that must remain

* Published and retired ruleset versions are historical records and must not be rewritten in place.
* Event competition history must use immutable ruleset and division snapshots.
* Out-of-window rule use requires an explicit audited exception.
* Missing eligibility facts must not silently qualify a fighter.
* Season boundaries and lifecycle guards must not be bypassed by direct browser writes.
* Generated brackets must use the selected event division's locked scoring policy.
* Organization-defined competition templates must not be presented as source-verified official categories unless a sourced ruleset defines them.
* Cross-organization writes remain protected by server authorization and RLS.

## Mega Pack 4 files to know

Release hardening and tests:

* `supabase/migrations/20260924060000_mega4_release_hardening.sql`
* `supabase/tests/database/mega4_release_hardening.test.sql`
* `tests/offlineQueue.test.ts`
* `tests/releaseHardening.test.ts`
* `docs/MEGA_PACK_4_RELEASE.md`

Field reliability and public registration:

* `src/features/AppState.tsx`
* `src/lib/eventAdmin.ts`
* `src/lib/registration.ts`
* `src/lib/offlineQueue.ts`
* `supabase/functions/upload-waiver/index.ts`
* `supabase/functions/create-registration-checkout/index.ts`

Release and PWA:

* `public/sw.js`
* `public/manifest.webmanifest`
* `src/App.tsx`
* `vite.config.ts`
* `.github/workflows/pages.yml`
* `package-lock.json`

## Pack 3 files to know

Database and security:

* `supabase/migrations/20260924043000_pack3_fighter_identities.sql`
* `supabase/tests/database/fighter_identities_pack3.test.sql`
* `supabase/tests/database/identity_workflows.test.sql`

Frontend identity workflows:

* `src/lib/fighterIdentity.ts`
* `src/pages/IdentityPage.tsx`
* `src/pages/IdentityReviewPage.tsx`
* `src/pages/FoundationPage.tsx`
* `src/lib/identityAdmin.ts`
* `src/types.ts`
* `src/App.tsx`
* `src/components/Layout.tsx`
* `tests/fighterIdentity.test.ts`

## Identity model after Pack 3

A fighter identity is a permanent sporting record. Its UUID is not a login ID, team ID, club ID, or organization ID.

`fighter_identity_accounts` links authenticated accounts to a fighter identity as either self or guardian. The legacy `fighter_identities.user_id` field remains for compatibility, but Pack 3 ownership and permission checks use the account-link model. Trusted legacy writes synchronize into account links automatically.

Public sporting data stays on `fighter_identities`. Legal name, birth date, contact information, emergency contacts, guardian details, and guardian consent are stored separately in `fighter_identity_private_profiles`.

Anonymous users can read only active identities explicitly marked public. Authenticated members can read member-visible identities, their own controlled identities, or identities within their administrative scope. Platform administrators can inspect archived merged identities for provenance. Private administrative profile data has no anonymous access.

## Claim workflow

Users should search for an existing historical identity before creating a new one.

A normal claim is pending until reviewed. If a different account already controls the same self identity, the new self claim is automatically disputed. Organization-scoped administrators can handle normal claims for identities they administer. Disputed ownership requires platform administrator review.

Rejected claimants can dispute a decision with a reason. Approved ownership changes revoke superseded self links rather than deleting them. Claim versions reject stale concurrent actions.

## Duplicate and merge workflow

Duplicate suggestions are advisory only. There is no automatic merge.

An organization administrator may request a merge only when both identities are represented in an organization that administrator controls. A platform super administrator other than the requester must perform the final approval.

The merge transaction refuses to proceed if either identity changed after the request or if the identities have different active verified self owners.

Successful merges:

* Keep the canonical identity active.
* Archive the duplicate identity with a canonical pointer.
* Preserve previous names as aliases.
* Carry account links and affiliation history forward.
* Preserve completed event roster references on their original fighter rows.
* Archive duplicate organization fighter rows with canonical fighter pointers when both records exist in the same organization.
* Record audit and merge-review provenance.

Do not reintroduce the old direct `merge_fighters` browser RPC. Authenticated execution is intentionally revoked.

## Affiliation history

Use `create_fighter_affiliation` and `end_fighter_affiliation` through the client helpers rather than writing `fighter_affiliations` directly.

A new open primary affiliation closes the previous open primary affiliation on the prior day. Historical periods remain stored. Current fighter team assignment follows the active primary affiliation.

## Mega Pack 4 operational rules that must remain

* Do not cache Supabase Data API responses or authorization-bearing requests in the service worker.
* Do not replace guarded live-operation RPCs with direct last-write-wins browser updates.
* Do not silently resolve offline conflicts. A person must retry or discard conflicted work.
* Do not expose organization-admin controls that RLS does not authorize, or widen RLS without a matching application permission.
* Do not claim paid registration is operational until a payment provider and verified webhook are configured.
* Keep waiver files private and require the registration capability token for public upload.
* Keep production source maps disabled unless a deliberate protected error-reporting workflow requires them.

## Concurrency and privacy rules that must remain

* Public profile updates require the current `profile_revision`.
* Private profile updates require the current private-profile revision.
* Claim review and dispute actions require the current claim version.
* Merge requests snapshot both identity revisions.
* Stale writes fail instead of last-write-wins overwrites.
* Recorded youth profiles cannot become public without verified guardian consent.
* Anonymous clients must never receive account UUIDs, legal names, birth dates, contact details, emergency contacts, or guardian details.
* Frontend visibility is not an authorization boundary.

## Verification commands

Run from the repository root:

```text
npm ci
npm run typecheck
npm test
npx vite build --mode github-pages
supabase start
supabase db reset
supabase test db
```

Local SQL validation without Docker uses the replay harness: fresh DB → `supabase_minimal_fixture.sql` → all migrations → `pgtap_shim.sql` role switching → suite via `run_suites.ps1` (see the workspace temp folder, not the repo). The CI `database` job remains authoritative.

GitHub Actions workflow `35954642255` passed both jobs on Pack 3 implementation head `2ffab73e9e403ab8c0325ef18a441ed5fe09319e` before merge. Mega Pack 4 workflow `35999176785` passed both jobs on implementation head `07107630551711945284cabfac3de1c3ca86cc58`. Round 7 head `27566ef` passed the frontend job on workflow `36531121109` but its database job failed on the stale `mega4_release_hardening` discipline assertion (corrected in `3b52176`); the discipline suite's error-pattern semantics were corrected in `435b140`/`187862c`; the combined head `187862c` passed **workflow `36533390822` green end-to-end**, Round 10 (federation hierarchy, head `b4b3795`) passed **workflow `36534422890` green end-to-end**, Round 11 (broader exports, head `5e67501`) passed **workflow `36535409276` green end-to-end**, Round 12 (audit completeness, head `de109b9`) passed **workflow `36536214636` green end-to-end**, and Rounds 13 + 14 (widgets/public profiles + Marathon, combined head `b61dccd`) passed **workflow `36537529093` green end-to-end** (frontend job, pgTAP database job with 10 suites from Round 12 on, and GitHub Pages deploy each time; the docs-only heads `f4b7844` and `d1be2f0` passed workflows `36535061871` and `36535932022`; the Round 13 head `a71c1d0` was superseded by the Round 14 push and its evidence is the combined-head run), and Rounds 15 + 16 (team standings + fight-card exports, flexible org relationships, combined head `c4d1f6f`) passed **workflow `36567325902` green end-to-end** (frontend job, pgTAP database job now covering 11 suites, and Pages deploy).

The Pack 3 database suite contains 49 identity-specific assertions in addition to the earlier Pack 1 and Pack 2 database suites. It covers public and private access, profile concurrency, youth privacy, claim approval, rejection and disputes, unauthorized edits, affiliation transitions, duplicate suggestions, merge preservation, conflicting owners, rollback, and auditing.

## Hosted checks still pending

A dedicated BuhurtOS Supabase project is still required before any remote migration or Auth/Storage verification. Keep these unverified until that project exists:

1. Apply all migrations to an isolated BuhurtOS project.
2. Run Supabase security advisors against that project.
3. Verify real account signup, verification, password recovery, refresh, and expired-session behavior.
4. Verify identity RLS through the hosted Data API using isolated fighter, guardian, organization-admin, and platform-admin accounts.
5. Verify youth private-profile access and guardian consent through real hosted sessions.
6. Verify merge and claim RPCs through hosted JWTs.
7. Verify private waiver Storage behavior.
8. Deploy and verify the existing event-member Edge Function.
9. Deploy and verify `upload-waiver` and private waiver replacement behavior.
10. Deploy and verify `create-registration-checkout`.
11. Connect and verify a real payment provider plus webhook before enabling paid checkout.
12. Perform real multi-device offline/reconnect conflict testing.

## Next session

Read `BUHURTOS_PLAN.md`, `BUHURTOS_STATUS.md`, `docs/COMPLETION_MATRIX.md`, and this handoff before continuing.

Treat Pack 6 implementation head `789cca1daf8208a6732863409639546744acf52e`, workflow `36080004581`, and merge commit `c6bbd937ed9a08592ca633325a848e2e765f4382` as the verified events-and-registration checkpoint. Treat Rounds 7–16 (head `c4d1f6f`, described at the top of this handoff) as the current checkpoint, verified green by workflow `36567325902`.

**The planned product gap list is closed, including the last three flagged items.** Rounds 13–14 cleared the widgets/public-profiles and Marathon frontier items; Round 15 added the team standings board and fight-card-level exports; Round 16 added the `sanctioned`/`predecessor` organization relationship kinds. Roadmap-only work remains as noted in `docs/COMPLETION_MATRIX.md` (e.g., org-level federation admin UI, production-verified livestream embedding, profile photo upload flow).

Before any hosted production claim, create and select a dedicated project inside Supabase organization `vbxznwtocyorcfghzdfo` (BuhurtOS), then complete the hosted verification checklist. Do not use the Northborn/Mallard/Reavers project as a BuhurtOS target.

The separate branch `pack4-organizations-clubs-teams` and closed draft PR #7 contain preserved feature work that is not part of the verified Pack 5 line unless deliberately reviewed and integrated later.


## Dedicated hosted Supabase

BuhurtOS is now deployed to the dedicated Supabase project `tapfpboszgoftbwcwsmn` in organization `vbxznwtocyorcfghzdfo`. Use this project exclusively for BuhurtOS. Never apply BuhurtOS migrations or functions to the Northborn/Mallard/Reavers project.

All repository migrations plus the hosted privilege-hardening and waiver-policy follow-up migrations are applied. The four Edge Functions are active, both storage buckets are private, Realtime publication is configured, RLS is enabled on every public table, and production GitHub Pages builds use the modern public publishable key. Secret/service-role credentials remain server-side only.

The hosted access hardening intentionally makes new Data API exposure opt-in for objects created by the repository migration role. Keep explicit GRANT statements beside RLS policies in future migrations.

## HACSA teams and BI marshal reference checkpoint

PR #12 on `feature/hacsa-bi-marshal-reference` is the HACSA-first team-source and BI marshal-reference work. Team facts shown on `/teams` and `/teams/:teamId` now come from the HACSA public team directory snapshot verified 2026-09-29; missing roster, member count, founding year or competition history is deliberately left blank rather than fabricated. BI Teams and BI Official Ranking are the next enrichment sources.

BI rules are available at `/rules` and `/ops/marshal-reference`. The live Marshal Console links the active match to `/ops/marshal-reference?format=<category>`, so the reference opens on the applicable fight family. Keep the source/version/section provenance visible when extending the corpus. The current indexed fight corpus is Buhurt Rules 26.4.1, Buhurt Regulations 26.4, Duels Rules 26.4, Duels Regulations 26.4, Outrance Rules and Regulations 26.4, and Weapons / Shield Chart 26.2.1.

When adding BI Teams and rankings, reconcile them into source-aware records instead of silently overwriting HACSA facts. Preserve the source priority and add field-level provenance where sources disagree.
