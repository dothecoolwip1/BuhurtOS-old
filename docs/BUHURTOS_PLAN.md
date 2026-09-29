# BuhurtOS Build Plan

Last updated: 2026-09-29

## Recovery provenance

The original checkpoint documents were missing from `main` when Pack 2 began. This plan was reconstructed from the current repository, README, migration history, tests, and recent Git history. It is intentionally conservative and does not claim work that is not present in the repository.

Pack 1 evidence includes these completed commits:

* `8353463de61f46a03c88f0463368015eaaf9c461` completed the Pack 1 identity and database foundation.
* `6099f90f0bda96557d9f00eb8b05f63adda36393` completed Pack 1 identity CRUD and workflow tests.
* `ef5a8c72785e94cbf1717f58fbc4a7591d08048b` hardened anonymous privileges.
* `c0313e009636e03da45508cfb6be72a02f058bdf` completed audit actor stamping.
* `90dad7a0554fe8c911b64b3d6ac55bff608e3dc6` completed organization and season lifecycle administration.
* `32240b2d6b8130a317ce5815a09e6d52d1bcac11` added the deterministic dependency lockfile and is the Pack 2 base commit.

## Pack 1: Foundation and identity

Status: completed before this checkpoint reconstruction.

Repository evidence shows:

* PostgreSQL and Supabase foundation schema.
* Organizations, seasons, events, teams, fighters, canonical fighter identities, clubs, affiliations, competition divisions, and event divisions.
* Audit stamping and soft deletion support for applicable foundation records.
* Ruleset administration and inheritance.
* First-run setup for organization, season, and event creation.
* RLS and Data API privilege hardening for Pack 1 tables.
* pgTAP identity workflow coverage and frontend quality checks.

Do not replace or redesign these foundations while completing Pack 2 unless a security defect requires a targeted change.

## Pack 2: Accounts and permissions

Status: completed and merged to `main` in PR #4. Final Pack 2 head `bef3d41c7fd509269535f13a85b2555961edd483` passed the combined frontend and local Supabase CI workflow.

Scope is deliberately limited to account and access control work:

* Account creation using Supabase Auth.
* Email verification and verification resend.
* Password sign-in and sign-out.
* Password recovery and password update.
* Existing-account magic-link sign-in without implicit account creation.
* Session restoration, refresh, expiry, and signed-out states.
* Internal-only return paths to prevent open redirects.
* Organization, event, official, team captain, fighter, and public access boundaries.
* Server-enforced role assignment and revocation.
* Protection against self-escalation and reopening the first-admin bootstrap.
* RLS protection for private account, membership, operational, and storage records.
* Deliberately limited public event and roster columns.
* Separation of the anonymous public data client from the authenticated operations client.
* Direct authorization tests for unrelated organizations, revoked memberships, anonymous users, ordinary members, administrators, officials, fighters, and missing identity context.
* No automatic invitation email delivery in this pack. Event access assignment only targets an existing BuhurtOS account.

Pack 2 is complete only when both GitHub Actions jobs pass on the final Pack 2 head:

1. Typecheck, tests and production build.
2. Rebuild and test Supabase schema.

Any hosted Supabase deployment or email delivery check that cannot be performed against a dedicated BuhurtOS project must remain explicitly unverified.

## Pack 3: Fighter identities

Status: completed and merged to `main` in PR #6. Implementation head `2ffab73e9e403ab8c0325ef18a441ed5fe09319e` passed GitHub Actions workflow `35954642255` before merge commit `e6fde086939f3c4e74353affb5a82a4aa1977a45`.

Scope completed:

* Permanent fighter identity IDs independent from login accounts, names, teams, clubs, and organizations.
* Authenticated self and guardian account links separated from the sporting identity.
* Public, members-only, and private profile visibility enforced by row-level security and column grants.
* Separate private administrative profiles for legal name, birth date, contact, emergency, and guardian information.
* Youth public-profile protection requiring verified guardian consent when a recorded birth date identifies the fighter as under 18.
* Optimistic public and private profile revisions that reject stale-device overwrites.
* Historical display-name aliases and duplicate suggestions without automatic merging.
* Existing-record claim workflows with approval, rejection, cancellation, dispute escalation, and audited ownership transfer.
* Merge requests separated from merge approval. A platform super administrator other than the requester performs the final review.
* Transactional merge conflict checks for changed revisions and conflicting verified owners.
* Historical roster and result references preserved instead of rewritten during identity merges.
* Archived duplicate identities and organization fighter rows retained with canonical provenance.
* Dated team, club, independent, mercenary, and guest affiliation history.
* Direct browser writes removed from identity and affiliation mutation paths in favor of authorized RPCs.
* Compatibility synchronization for trusted legacy `fighter_identities.user_id` ownership records.
* Self-service fighter identity UI and administrator claim/merge review UI.
* Pack 3 unit and pgTAP coverage, including 49 identity-specific database assertions plus the preserved Pack 1 and Pack 2 suites.

Pack 3 verification requires both repository CI jobs:

1. Typecheck, tests and production build.
2. Clean Supabase startup, database reset from all migrations, and all pgTAP database tests.

Hosted Supabase application remains intentionally unverified until a dedicated BuhurtOS Supabase project exists.

## Mega Pack 4: Production hardening and release readiness

Status: implementation complete in pull request #8. Verified implementation head `07107630551711945284cabfac3de1c3ca86cc58` passed GitHub Actions workflow `35999176785`, including typecheck, all frontend tests, production build, a clean Supabase rebuild from every migration, and all pgTAP suites.

Scope completed:

* Hardened the service worker so private or cross-origin authenticated API responses are not cached.
* Aligned organization-administrator RLS writes with the permissions exposed by secured operations screens.
* Added optimistic concurrency guards for event settings, roster clearances, tournament fields, registration review, and fight-card ordering.
* Preserved explicit conflict resolution for offline reconnects instead of last-write-wins behavior.
* Added token-protected private waiver upload with validation, safe replacement, and audit logging.
* Added a fail-closed registration checkout endpoint. Paid registration checkout remains unavailable until a real payment provider and verified webhook are configured.
* Removed or replaced showcase controls that appeared functional but did not perform real work.
* Added offline failure/conflict and scoring/stream abuse regression coverage.
* Added deterministic dependency installation with a committed lockfile and `npm ci`.
* Added route-level code splitting, disabled production source maps, and reduced the initial minified JavaScript bundle from about 510 kB to about 312 kB.
* Added installable PWA icons, manifest metadata, and targeted accessibility improvements.
* Documented hosted-production dependencies in `docs/MEGA_PACK_4_RELEASE.md`.

Mega Pack 4 local verification is complete. Hosted production verification remains intentionally separate because no dedicated BuhurtOS Supabase project has been confirmed.

## Pack 5: Rulesets, divisions and seasons

Status: completed and merged to `main` in PR #9. Verified implementation head `d357c6414edeabc2f0034c420207ca1d29fa36ae` passed GitHub Actions workflow `36069252396` before merge commit `178874356d4a8c4076d1deaa3ffd742d6490f515`.

Scope completed:

* Governed ruleset lifecycle covering draft, review, publish, and retire.
* Immutable published and retired ruleset versions with same-organization inheritance and cycle protection.
* Public source provenance separated from private drafting evidence.
* Separate eligibility, scoring, tournament, and ranking policy domains.
* Effective windows plus explicit audited event exceptions.
* Immutable event ruleset snapshots containing resolved policy, inheritance, and provenance.
* Versioned competition divisions with age, weight, experience, team-size, declaration, and custom eligibility constraints.
* Explainable eligibility decisions that return needs-review when required facts are missing.
* Governed event-division assignment with immutable division and ruleset snapshots.
* Season date boundaries, default published rulesets, ranking policy, guarded lifecycle, and event-boundary enforcement.
* New-event inheritance of season defaults with snapshot locking before governed competition.
* Brackets and matches retain division and ruleset snapshot references.
* Generated competition uses the locked division ruleset scoring, and conflicting scoring overrides are rejected.
* Approved policy exceptions are immutable and revocations are audited.
* PostgreSQL validation rejects malformed eligibility and invalid scoring configuration.
* RLS and explicit Data API grants protect new Pack 5 tables and cross-organization writes.
* Current source-backed competition formats are distinguished from configurable organization templates.
* Frontend and pgTAP regression coverage for lifecycle transitions, snapshots, RLS, conflicts, exceptions, scoring, eligibility, and historical preservation.

Pack 5 verification requires both repository CI jobs:

1. Typecheck, tests and production build.
2. Clean Supabase startup, database reset from all migrations, and all pgTAP database tests.

Workflow `36069252396` passed both jobs on the verified implementation head. Hosted Supabase verification remains separate until a dedicated BuhurtOS project is selected.

## Pack 6: Events and registration

Status: complete and merged to `main` in PR #10.

Verified Pack 6 implementation head: `789cca1daf8208a6732863409639546744acf52e`.

Successful Pack 6 verification workflow: `36080004581`.

Pack 6 merge commit: `c6bbd937ed9a08592ca633325a848e2e765f4382`.

Scope:

* Govern the event lifecycle from draft through published, closed, cancelled, and archived states.
* Store and validate venue, timezone, event dates, registration window, capacity, divisions, and locked ruleset context.
* Support individual and team registration without duplicating fighter identities or exposing private account data.
* Evaluate configured division eligibility and preserve an explainable eligibility decision for organizer review.
* Support approval, rejection, waitlist, withdrawal, and organizer-controlled roster changes.
* Keep registration approval, physical check-in, and competition clearance as separate states.
* Enforce registration deadlines, capacity, duplicate-entry rules, and concurrent overbooking protection in PostgreSQL.
* Protect youth details, contact details, emergency contacts, waiver records, and organizer notes from public access.
* Expose a deliberate public event view that contains only spectator-safe event and registration information.
* Keep organizer mutations server-authorized, auditable, concurrency-safe, and protected by RLS and explicit grants.
* Test unrelated organizations, ordinary members, organizers, fighters, anonymous users, deadlines, capacity, duplicate submissions, concurrent edits, withdrawals, cancellation, and historical preservation.
* Do not expand payment processing in this pack. Existing paid registration behavior remains fail closed until a real provider and verified webhook exist.

Pack 6 completion verification passed both required repository CI jobs on the final implementation head:

1. Typecheck, tests and production build.
2. Clean Supabase startup, database reset from all migrations, and all pgTAP database tests.

Workflow `36080004581` passed both jobs before PR #10 was merged.

## Round 7: Discipline, suspensions, and offline hardening

Status: pushed as `27566ef`. CI frontend job green on `36531121109`; the database job failed on a stale `mega4_release_hardening` assertion (direct discipline-card writes now RPC-only) and was corrected in `3b52176` — the combined head with Round 8 is re-verifying in CI.

Scope:

* Governed `disciplinary_cards` (yellow/red, reason required, season + event scoped) with RPC-only writes; the old direct-write policy is removed.
* Governed `suspensions` with organization/event/season scoping, issue and revoke RPCs, and RLS read scoping for staff, officials, and the fighter themself.
* Additive data-layer enforcement: an active suspension blocks `event_roster_entries` competition clearance on every path, guarded RPC included.
* Discipline UI: RPC-based card issuance, season history list, suspensions issue/list/revoke panel.
* Offline queue hardening: 30s stale-`syncing` repair, 8-attempt capped auto-retry with exponential backoff, manual retry reset, per-process flush guard.
* Frontend coverage for the queue hardening and a 27-assertion pgTAP suite for the discipline/suspensions data layer.

Verification completed locally before commit: typecheck clean, 36/36 frontend tests, all 18 migrations replay on a fresh database, discipline suite green under the role-switching harness. The first CI database run exposed a stale `mega4_release_hardening.test.sql` assertion (direct `disciplinary_cards` writes no longer permitted); `3b52176` flipped it to the RPC-only contract (RLS-blocked, 42501) and the full 8-suite local replay is green.

## Round 8: Public spectator surface disambiguation

Status: pushed as `c7fab9c`; CI confirmed green on the combined head (workflow `36533390822` on `187862c`, including the GitHub Pages deploy).

Scope:

* `DemoNotice` banner ("Interactive demo — sample data only") on every showcase route via `ShowcaseShell` plus the standalone `/public` server-rendered page; CTA opens the real `/#/live` board.
* All LIVE claims retitled to DEMO/SAMPLE across the public hero, event statusbar, dashboard panel, and marketing mockup; fake clocks/scoreboards labelled SAMPLE; spectator preview nav `Live Now ●` → `Public Arena ◎`.
* Sample-data disclaimer replaces "Powered by live tournament data"; live board remains the primary spectator CTA.

Verification: production build clean, 36/36 frontend tests, in-browser DOM assertions across `/`, `/public`, `/home`, `/events/fall-open`, `/rankings` confirm demo markers and no live claims, and the authoritative CI run is green on `187862c` (workflow `36533390822`).

## Round 9: Long Axe competition format

Status: pushed as `e3fe92d`; included in the green workflow `36533390822`.

Scope:

* Add `long_axe` to `competitionFormats.ts` as a `verified` BI duel preset (`duel()` scoring; exact scoring deferred to the selected sourced ruleset, matching the contract of `longsword`/`polearm`).
* Assert `long_axe` in the verified-formats list in `tests/governance.test.ts`; drop Long Axe from the remaining-gaps lists in the matrix and handoff.

Verification: governance tests 6/6, typecheck clean, production build clean, CI green end-to-end on `187862c`.

## Round 10: Federation hierarchy

Status: pushed as `b4b3795`; workflow `36534422890` green end-to-end.

Scope:

* Port the Pack 4 org/governing-body relationship model to main
  (`20261001000000_federation_hierarchy.sql`): `organization_kind` +
  `country_code` on organizations; `organization_relationships` with an
  active window, generated org-context mirror, public reads, RPC-only writes.
* Guarded `upsert`/`end` RPCs: bilateral admin consent, active-org residency,
  active-duplicate refusal, end/reopen lifecycle, hierarchy cycle protection;
  `organization_ancestors` read helper; anon revoked from write RPCs.

Verification: 34-assertion `federation_hierarchy.test.sql` green on the local
9-suite replay and under real pgTAP in CI; frontend job + deploy green.

## Round 11: Broader exports

Status: pushed as `5e67501`; workflow `36535409276` green end-to-end.

Scope:

* One shared `csv()` routine (commas/quotes/newline escaping) in `export.ts`
  across standings, matches/order of play, discipline cards, suspensions, and
  roster-report builders, plus an `htmlTable` helper for printable reports.
* Wire exports into the ops pages: BracketPage (order-of-play CSV + printable),
  DisciplinePage (cards + suspensions CSV + combined printable report),
  RosterPage (registration report CSV + printable compliance report).

Verification: `tests/export.test.ts` (6 assertions), full suite 42/42,
typecheck and production build clean; buttons verified in-browser.

## Later packs

Later product work should start from the Round 11 checkpoint. Preserve the completed identity, authorization, release hardening, governance, division, season, event lifecycle, registration, eligibility, capacity, withdrawal, clearance, privacy, concurrency, discipline, suspension, offline-queue, public-surface-disambiguation, Long-Axe, federation-hierarchy, and exports foundations unless a targeted defect requires change.

Before starting a later pack:

* Read `BUHURTOS_STATUS.md`.
* Read `BUHURTOS_HANDOFF.md`.
* Read `docs/COMPLETION_MATRIX.md` for the per-requirement source-of-truth status and the ranked list of remaining product gaps.
* Confirm the latest CI run is green on `main`.
* Confirm a dedicated BuhurtOS Supabase project is selected before applying migrations remotely.
