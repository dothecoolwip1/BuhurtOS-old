# BuhurtOS Handoff

Last updated: 2026-09-29

## Resume here

Pack 6 is complete and merged to `main` in PR #10.

Verified Pack 6 implementation head: `789cca1daf8208a6732863409639546744acf52e`.

Successful Pack 6 verification workflow: `36080004581`.

Pack 6 merge commit: `c6bbd937ed9a08592ca633325a848e2e765f4382`.

That workflow passed both required jobs: frontend typecheck/tests/production build and a clean Supabase rebuild with all pgTAP database tests.

### Current round: discipline, suspensions, and offline hardening (committed locally)

The head of `main` is `91a473c` ("fix: ship operational UI styles... and fix the CI npm cache path"). On top of that head the following unmerged work is implemented and **verified locally**:

* Forward migration `supabase/migrations/20260930010000_discipline_suspensions.sql` — `disciplinary_cards` + `suspensions` tables, guarded `issue_discipline_card` / `issue_suspension` / `revoke_suspension` RPCs, additive `prevent_clearance_while_suspended` trigger on `event_roster_entries`, RLS read scoping, audit triggers, `discipline_write` policy removed, deliberate anon/authenticated SELECT grants on `suspensions`. The `issue_suspension` RPC carries a test-only trailing `p_id` so the suite can seed a deterministic suspension id referenced by non-privileged roles.
* pgTAP suite `supabase/tests/database/discipline_suspensions.test.sql` — 27 assertions, green under the local replay harness (fresh DB → fixture → all 18 migrations → suite with real role switching and genuine RLS semantics).
* Offline-queue hardening in `src/lib/offlineQueue.ts` + `tests/offlineQueue.test.ts`: 30s stale-`syncing` repair, auto-retry capped at 8 attempts with exponential backoff, manual retry resets the counter, per-process in-flight flush guard. Frontend suites pass 36/36.
* Discipline UI rewrite in `src/pages/DisciplinePage.tsx` (RPC-based card issuance, suspensions issue/list/revoke panel, demo-mode fallback), `Suspension` in `src/types.ts`, and CSS for `.susp-dot` / `.field-hint` / `.ghost` in `src/styles.css`.

Locally verified before commit: `npm run typecheck` clean, `npm test` 36/36, all 18 migrations replay from scratch, and the discipline suite green. **The CI (`pages` + `database`) run for this commit is the authoritative pgTAP verification and must be confirmed green after push.**

Do not apply BuhurtOS migrations to the currently connected Supabase project unless it is independently confirmed to be a dedicated BuhurtOS project. The project inspected during Pack 2 contains Northborn, Mallard, and Reavers data and is not the BuhurtOS target.

## This round — files to know

Discipline and suspensions:

* `supabase/migrations/20260930010000_discipline_suspensions.sql`
* `supabase/tests/database/discipline_suspensions.test.sql`
* `src/pages/DisciplinePage.tsx`
* `src/types.ts` (`Suspension`, `DisciplineCard`)

Offline hardening:

* `src/lib/offlineQueue.ts`
* `tests/offlineQueue.test.ts`

## This round — rules that must remain

* Discipline and suspension writes happen only through the guarded RPCs. The old `discipline_write` policy was dropped; direct browser inserts into `disciplinary_cards` must never be re-enabled.
* Active suspensions block competition clearance in the data layer (`prevent_clearance_while_suspended`), not only in the UI. Do not weaken the trigger or the clearance RPC.
* `revoke_suspension` authorizes against the target row before mutating (`Not authorized` for unauthorized callers holding a valid id).
* The `p_id` parameter on `issue_suspension` exists only for deterministic test seeding (`coalesce(p_id, gen_random_uuid())`). Do not add UI reliance on it.
* `suspensions` remains SELECT-only via RLS plus anon/authenticated read grants; direct writes stay RPC-only.
* Keep the offline queue fail-safe: conflicts require a human retry/discard, stale `syncing` is repaired after 30s, auto-retry is capped (8) with backoff, and manual retry resets the counter.

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

GitHub Actions workflow `35954642255` passed both jobs on Pack 3 implementation head `2ffab73e9e403ab8c0325ef18a441ed5fe09319e` before merge. Mega Pack 4 workflow `35999176785` passed both jobs on implementation head `07107630551711945284cabfac3de1c3ca86cc58`. The current round's local verification (typecheck, 36/36 frontend tests, 18-migration replay, 27-assertion discipline suite with genuine role/RLS semantics) is complete; its CI workflow run is pending until the round is pushed.

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

Treat Pack 6 implementation head `789cca1daf8208a6732863409639546744acf52e`, workflow `36080004581`, and merge commit `c6bbd937ed9a08592ca633325a848e2e765f4382` as the verified events-and-registration checkpoint. Treat the discipline/suspensions/offline round described at the top of this handoff as the current verified-local checkpoint; confirm its CI run is green before moving on.

Top remaining product gaps (priority order, full detail in `docs/COMPLETION_MATRIX.md`):

1. Public spectator surface disambiguation — remove mock/showcase-vs-real ambiguity on public pages so showcase content can never masquerade as live event data.
2. Federation hierarchy — port org/governing-body relationships from branch `pack4-organizations-clubs-teams`.
3. Long Axe — add as a competition format in `competitionFormats.ts`.
4. Broader exports (PDF/printable + discipline/registration reports).
5. Audit completeness (brackets, announcements, orgs/seasons/events/rulesets/profiles/registrations).
6. Embeddable widgets + fuller public fighter/team profiles.
7. Marathon — productize the `custom_template` into a verified flow.

Before any hosted production claim, select a dedicated BuhurtOS Supabase project and complete the existing hosted verification checklist. Do not use the Northborn/Mallard/Reavers project as a BuhurtOS target.

The separate branch `pack4-organizations-clubs-teams` and closed draft PR #7 contain preserved feature work that is not part of the verified Pack 5 line unless deliberately reviewed and integrated later.
