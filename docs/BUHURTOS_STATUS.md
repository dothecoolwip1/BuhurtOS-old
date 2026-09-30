# BuhurtOS Status

Last updated: 2026-09-30

## Current state (single table, 2026-09-30)

Base: `de6f251`. Tested and deployed code: `54cd7b0` (CI on the exact SHA passed: navigation audit, typecheck, vitest, build, clean `supabase start` + reset + pgTAP, then Pages deploy). The hosted bundle was fetched afterwards and contains the new 404 page. No database migration was needed or applied for this round. This documentation-only commit follows it.

| Area | Implemented | Tested locally | Deployed | Verified on hosted | Deferred / not verified |
|---|---|---|---|---|---|
| Scope: organization tools work without an event (explicit, permission-filtered org picker) | yes | unit tests (selectable orgs, resolution, links) | yes | bundle only | no signed-in hosted run |
| Scope: event chosen once, kept on every event task, event picker, stale-response guard | yes | unit tests + demo-mode browser | yes | bundle only | rapid-switch race not behaviorally tested |
| Event detail shows poster, host, slug (shared mapper, narrow missing-column fallback) | yes | loader test with stubbed client | yes | not checked against live rows | |
| Detail pages reset on param change, distinct error vs not-found, retry | yes (event, team, fighter, team manage) | source/markup only | yes | no | no DOM-level transition test |
| Stats failures distinguished from 'unavailable' | yes | unit | yes | no | |
| Homepage sections independent with retry | yes | typecheck, build | yes | no | |
| Event-timezone dates and month grouping | yes | unit incl. far zone and midnight crossing | yes | no | other pages still use device time for admin-only timestamps |
| Interest form vs registration wording; setup categories | yes | updated tests | yes | no | |
| Sign-in: real form, Enter, help on codes; platform-config failures shown | yes | source/unit | yes | no | no real sign-in attempted |
| Registration-mode switch described as not server-enforced | yes (copy) | unit | yes | n/a | enforcement would need an auth hook; not built |
| Rankings scoped by source, URL state, repaired stale URLs | yes | unit | yes | no | no ranking data in demo build |
| Rules URL state, button semantics, coverage note | yes | browser (demo build) | yes | no | |
| Team page source wording, map retry, reset filters | yes | typecheck | yes | no | |
| Menu sheet focus trap + inert background | yes | browser (demo build, mobile) | yes | no | screen-reader pass not done |
| Route error boundary, explanatory 404 | yes | markup | yes | bundle only | |

## Tournament planning (added 2026-09-30)

| Capability | Implemented | Tested locally | Deployed | Notes |
|---|---|---|---|---|
| Structure advice by field size and format family, fit-the-day check | yes | unit + render tests | yes | Bout lengths are editable estimates, not ruleset values |
| Snake pool draw, recorded random draw by default | yes | unit | yes | Replays from the saved draw code |
| Schedule planner (areas, rest, breaks, event timezone) | yes | unit + demo browser run | yes | Saved with the bracket metadata; no database change |
| Automatic playoff scheduling after pools | yes | unit + demo browser run | yes | Starts at planned pool finish or now, whichever is later |
| Optional third-place match | yes | unit | yes | Single elimination and pool playoffs, four or more competitors |
| Order of play, pools, bracket views; find fighter or team; copy, print by area, calendar export | yes | unit + demo browser run | yes | Planned times only |
| Public schedule with times | no | | | Anonymous users cannot read bracket metadata (select revoked); needs a reviewed database function |
| Editing saved times after publishing | no | | | Needs a database function |
| Verified on hosted with real signed-in accounts | no | | | Only the demo build was exercised end to end |

## Honest list of what is unverified

* No signed-in flow was exercised on the hosted site; I cannot create or sign in to real accounts. Signed-in behavior was checked in demo mode and unit tests only.
* Live-data pages (events, teams, rankings) were not re-inspected against production rows this round.
* Hosted security advisors were not re-run; do not revoke grants from advisor output without checking the contextual reviews.
* Deferred from the request: a full audit of every owner-console repeated-copy section, avatar/logo fallbacks everywhere, PWA update-versus-queued-work test, BI snapshot workflow deploy-path check, screenshots at all five widths.

## Master Execution Plan Pack 1 complete

Pack 1, **Stability, CI, Routing and Release Baseline**, is complete on the current
release line. The implementation checkpoint before this documentation update is
`0fe40cae77da55d1eec65908bc1411b2715079c5`.

Current release facts:

* The dedicated hosted Supabase project is `tapfpboszgoftbwcwsmn` in the BuhurtOS organization `vbxznwtocyorcfghzdfo`. The older shared Northborn/Mallard/Reavers backend remains prohibited.
* `.github/workflows/pages.yml` is the single authoritative CI and GitHub Pages release workflow. The redundant standalone Pages workflow was removed.
* CI requires the navigation audit, TypeScript, unit tests, production build, a clean local Supabase start, full migration replay, pgTAP database tests, and only then the Pages deployment.
* The Pack 1 route audit covers the public hub, organizations, teams, fighters, events, rankings, rules, login, platform controls, delegated codes, event management, and fighter signups.
* Public team deep links retain the `?go=` bridge into HashRouter so shared/mobile links resolve correctly under the GitHub Pages base path.
* Stale showcase dashboard routing and known fake demo IDs are quarantined by the navigation audit.
* Public directory pages now distinguish load failures from legitimate empty results, and event management no longer renders a blank state when no event is selected.
* Clean replay blockers in the delegated-access migration were made replay-safe without resetting production data.
* Hosted anonymous event privileges were hardened with migration `20260930042147_pack1_public_event_privilege_hardening.sql`. Public event fields remain readable while private `events.notes` is not anonymously selectable.
* Red Deer Reavers remains a team. No organization was created for it during this pack.
* No production rows were deleted, reset, or replaced during Pack 1.

## Current recovery point

The historical Pack 2–16 notes below are preserved for provenance but are not the
current implementation head. `main` includes Pack 7 tournament generation and
Pack 4 organization/team/captain membership workflows through `901257c`.
Profile-avatar storage work follows as a separate, locally verified release.

BuhurtOS must use only the dedicated Supabase organization `vbxznwtocyorcfghzdfo` (BuhurtOS) and hosted project `tapfpboszgoftbwcwsmn`. The older Northborn/Mallard/Reavers Supabase project remains prohibited.

Repository: `dothecoolwip1/BuhurtOS`

Base branch: `main`

Pack 2 branch: `pack2-accounts-permissions` (merged)

Pack 2 pull request: #4, `Complete Pack 2 accounts and permissions` (merged)

Pack 2 base commit: `32240b2d6b8130a317ce5815a09e6d52d1bcac11`

Pack 3 branch: `pack3-fighter-identities` (merged)

Pack 3 pull request: #6, `Complete Pack 3 fighter identities` (merged)

Pack 3 verified implementation head: `2ffab73e9e403ab8c0325ef18a441ed5fe09319e`

Pack 3 merge commit: `e6fde086939f3c4e74353affb5a82a4aa1977a45`

Pack 3 successful pre-merge workflow: `35954642255`

Mega Pack 4 branch: `mega4-production-hardening`

Mega Pack 4 pull request: #8, `Mega Pack 4: production hardening and release readiness`

Mega Pack 4 verified implementation head: `07107630551711945284cabfac3de1c3ca86cc58`

Mega Pack 4 successful verification workflow: `35999176785`

The original `BUHURTOS_PLAN.md`, `BUHURTOS_STATUS.md`, and `BUHURTOS_HANDOFF.md` files were absent from `main` at the start of Pack 2. These files were reconstructed from repository evidence rather than guessed historical content.

## Completed before Pack 2

Pack 1 foundation work is present and must be preserved:

* Canonical identity, clubs, affiliations, divisions, organization, season, event, team, and fighter foundations.
* Ruleset administration.
* Audit actor stamping.
* Anonymous privilege hardening.
* Organization and season lifecycle administration.
* Frontend and pgTAP coverage associated with those foundations.

## Pack 2 completed and merged

Account lifecycle:

* Password sign-in and sign-out.
* Self-service signup with display-name profile bootstrap.
* Verification redirect and verification resend.
* Password recovery and new-password update.
* Magic-link sign-in configured not to create unknown users.
* PKCE Auth flow for browser callbacks.
* Safe internal return paths restricted to `/ops`.
* Distinct loading, verification, recovery, success, failure, signed-out, and session-ended states.
* Auth context refresh on operational reload so revoked memberships do not remain trusted in client state.

Authorization:

* Direct writes to platform, organization, and event membership tables are removed from the authenticated browser role.
* Role changes go through server-authorized functions.
* Organization administrators can manage staff but cannot promote organization administrators.
* Event organizers can manage lower event roles but cannot mint another organizer or mutate their own event role.
* Organization or platform administrators can assign event organizers.
* Platform administrator role operations reject self-mutation and protect the last super administrator.
* The first-super-admin bootstrap now records a permanent sentinel and cannot reopen if membership rows are later removed.
* Role assignment and revocation are audited.

Public and private data:

* Public requests use a separate anonymous Supabase client rather than inheriting the signed-in account token.
* Anonymous event, fight-card, bracket, match, announcement, and roster access is controlled by published-event RLS.
* Anonymous grants expose only deliberate public event and roster columns.
* Private event notes, clearance flags, metadata, account profiles, membership tables, fighter account links, and affiliation records are not anonymously readable.
* Authenticated private event access is scoped by organization and event membership.
* Fighter roster access is limited to the fighter's own row.
* Team captain roster access is limited to that captain's team.
* Officials and authorized administrators retain operational roster access.
* Waiver storage remains private and has no anonymous object policy.

Existing-account event assignment:

* The previously referenced `invite-event-member` function is now implemented.
* It performs authenticated caller verification.
* Email-to-account lookup uses the Supabase service role only inside the Edge Function runtime.
* Final role assignment is still authorized by the caller's JWT through the database RPC.
* It sends no invitation email. Unknown users are told to create and verify their own BuhurtOS account first.

## Pack 3 completed and merged

Permanent fighter identity:

* Fighter identity IDs remain stable across login changes, name changes, team changes, and organization changes.
* Login ownership is represented by `fighter_identity_accounts` rather than using frontend-visible fields as an authorization boundary.
* Self and guardian relationships can be verified independently.
* Historical aliases are retained for renamed fighters.
* Trusted legacy `fighter_identities.user_id` records synchronize into the Pack 3 account-link model for backward compatibility.

Profile privacy and youth handling:

* Public sporting fields and private administrative fields are stored separately.
* Anonymous reads are limited to deliberately public active fighter identities and deliberately public aliases.
* Private legal, birth, contact, emergency, and guardian details have no anonymous grants.
* Recorded youth profiles cannot be made public without guardian consent recorded by a verified guardian or platform administrator.
* Public and private profile writes use revision checks so stale clients fail instead of silently overwriting newer changes.
* Platform administrators can inspect archived identity provenance after merges; ordinary and public reads cannot.

Claims and disputes:

* Signed-in users can search only claimable identity summaries.
* Self and guardian claims are explicit records with versions and audit history.
* A competing self claim becomes disputed rather than displacing the current owner.
* Normal claims can be reviewed by an appropriately scoped identity administrator.
* Disputed ownership requires platform administrator resolution.
* Rejected claims can be challenged with a dispute reason.
* Superseded account links are revoked rather than deleted.

Duplicate handling and merges:

* Duplicate detection returns review suggestions based on normalized names, aliases, and nicknames and never merges automatically.
* Organization administrators can request a merge only when both identities are within an organization they administer.
* Final merge approval requires a different platform super administrator.
* Merge reviews snapshot profile revisions and reject concurrent edits.
* Different verified self owners block the merge transaction.
* Historical event roster references remain on their original fighter rows.
* Duplicate organization fighter rows and identity rows are archived with canonical pointers rather than deleted.
* Alias, affiliation, account-link, audit, and provenance data are retained.

Affiliation history:

* Affiliation creation and ending now use authorized RPCs.
* Starting a new open primary affiliation closes the prior primary period without deleting it.
* Current fighter team membership follows the active primary affiliation while dated history remains intact.

UI:

* `/ops/identity` provides fighter self-service creation, public profile editing, private detail editing, claim search, and claim history.
* `/ops/identity-review` provides administrator claim review, duplicate suggestions, merge requests, and platform merge review.
* The older foundation merge control now requests review rather than executing a direct merge.

## Mega Pack 4 implementation complete

Production security and privacy:

* The PWA service worker caches only same-origin application navigation and static assets and excludes authorization-bearing requests.
* Organization-administrator operational writes are aligned between application permissions and RLS.
* Public waiver upload is implemented as a token-protected Edge Function using private Storage.
* Registration checkout validates the registration capability token and fails closed when no payment provider exists.
* Production source maps are disabled.

Concurrency and field reliability:

* Event settings, roster clearances, field configuration, registration review, and fight-card reorder operations use server-side expected-version guards.
* Existing match-status and result-submission concurrency guards remain in place.
* Offline mutations preserve their base version and surface conflicts for explicit retry or discard.
* Event-setting changes are included in realtime subscriptions.

Release UX and performance:

* Misleading showcase-only controls were replaced by working search, share, export, navigation, or explicit read-only states.
* Route-level code splitting reduced the initial minified JavaScript bundle from about 510 kB to about 312 kB.
* The PWA now includes 192px and 512px icons and updated install metadata.
* Score-dialog controls include accessible labels and live validation messaging.

Verification:

* Implementation head `07107630551711945284cabfac3de1c3ca86cc58` passed GitHub Actions workflow `35999176785`.
* The frontend job passed TypeScript, unit/regression tests, and the production Vite build.
* The database job started local Supabase, rebuilt the schema from all migrations, and passed all pgTAP suites including Mega Pack 4 concurrency and RLS abuse tests.

## Pack 5 completed and merged

Governed rulesets:

* Rulesets move through draft, review, published, and retired states.
* Published and retired versions are historical records and cannot be silently rewritten.
* Parent inheritance is restricted to valid same-organization chains and protects against cycles.
* Effective settings are snapshotted for events so later ruleset versions do not rewrite historical competition.
* Eligibility, scoring, tournament, and ranking policy are modeled as separate domains.
* Public provenance is retained separately from internal drafting notes.
* Out-of-window use requires an explicit audited event exception.
* Approved exception details are immutable; revocation is explicit and audited.

Divisions and eligibility:

* Competition divisions are versioned and can express age, weight, experience, team-size, declaration, and custom requirements.
* Missing required facts produce a needs-review result rather than a silent pass.
* Event divisions capture immutable division and effective-ruleset snapshots.
* Current source-backed BI format classifications are distinguished from organization-defined configurable templates.

Seasons and competition history:

* Seasons have enforced boundaries, default published rulesets, ranking policy, and guarded lifecycle transitions.
* New events can inherit the season default, but governed competition locks an immutable snapshot.
* Brackets and matches retain their division and ruleset snapshot references.
* Bracket generation uses the selected event division's locked scoring policy.
* Database validation rejects scoring overrides that contradict the locked ruleset.

Security and verification:

* Pack 5 tables and mutations are protected by RLS plus explicit Data API grants.
* Cross-organization mutation attempts are filtered or rejected without changing protected records.
* Invalid scoring and malformed eligibility configuration are rejected at the PostgreSQL boundary.
* Verified implementation head `d357c6414edeabc2f0034c420207ca1d29fa36ae` passed GitHub Actions workflow `36069252396`.
* The frontend job passed TypeScript, all unit/regression tests, and the production Vite build.
* The database job rebuilt Supabase from every migration and passed all pgTAP suites.
* PR #9 merged Pack 5 to `main` as `178874356d4a8c4076d1deaa3ffd742d6490f515`.

## Pack 6 completed and merged

Events and registration:

* Events now carry governed venue, timezone, dates, registration windows, capacity, waitlist behavior, public description, publication provenance, lifecycle timestamps, divisions, and locked ruleset context.
* Event lifecycle changes are guarded server-side through draft, published, live/closed where applicable, cancelled, completed, and archived history rather than relying on frontend controls.
* Individual and team registrations use formal event divisions and preserve registration kind, roster size, eligibility decisions, eligibility reasons, and the locked competition context used to evaluate them.
* Registration approval does not invent permanent fighter identities from submitted display text.
* Approval, rejection, waitlisting, withdrawal, physical check-in, equipment/medical/waiver/weigh-in clearance, and final competition clearance remain separate states.
* Team roster changes recalculate eligibility before approval.
* Withdrawals preserve history and remove affected roster entries from active competition.

Capacity, concurrency, and privacy:

* PostgreSQL enforces registration deadlines, duplicate active entries, event and division capacity, and waitlist behavior.
* Registration and approval paths use row locks plus transaction advisory locking to prevent concurrent overbooking.
* Guarded organizer writes reject stale record versions instead of silently overwriting another device or staff member.
* Cross-organization registration review is denied.
* Anonymous spectators can read published event and event-division information without receiving private registration contacts, emergency details, waiver state, organizer notes, youth facts, or account identifiers.
* Public registration writes go through governed RPCs; direct anonymous registration-table inserts are not permitted.
* Registration and roster mutations are audited.
* Existing paid registration behavior remains fail closed; Pack 6 did not add a payment provider.

Verification:

* Verified implementation head `789cca1daf8208a6732863409639546744acf52e` passed GitHub Actions workflow `36080004581`.
* The frontend job passed TypeScript, unit/regression tests, and the production Vite build.
* The database job started local Supabase, rebuilt the schema from every migration, and passed all pgTAP suites.
* Pack 6 database coverage includes deadlines, duplicate submissions, eligibility and needs-review handling, team roster changes, cross-organization denial, stale reviews, capacity, waitlists, withdrawal capability tokens, separate physical and final marshal clearance, cancellation, archiving, and historical immutability.
* PR #10 merged Pack 6 to `main` as `c6bbd937ed9a08592ca633325a848e2e765f4382`.

## Round 7: Discipline, suspensions, and offline hardening (pushed as `27566ef`)

Discipline and suspensions data layer:

* `disciplinary_cards` and `suspensions` are new governed tables. Card and suspension writes are RPC-only; the previous `discipline_write` policy on `disciplinary_cards` was dropped so direct browser inserts fail.
* `issue_discipline_card` authorizes platform admins / organization admins / event organizers / field marshals and requires a reason.
* `issue_suspension` supports organization, event, season, and combined scoping with validity checks (suspension must end after it starts) and deterministic test seeding through an optional trailing `p_id`.
* `revoke_suspension` authorizes against the target row before mutating and gives a distinct error for nonexistent suspensions.
* `prevent_clearance_while_suspended`, an additive enforcement trigger on `event_roster_entries`, blocks competition clearance while an active suspension covers the entry on every write path, guarded RPC included.
* `suspensions` has RLS read policies (org staff/admins, event-role holders, fighter self-read) plus deliberate anon/authenticated SELECT grants so anonymous-access assertions exercise RLS rather than failing at the ACL layer.
* Audit triggers cover cards and suspensions, and `set_updated_at` is maintained.

UI:

* `DisciplinePage` now issues cards through `issue_discipline_card` (no direct inserts), lists season history, and adds a suspensions panel: issue (with duration), list with live status (`active`/`upcoming`/`revoked`/`expired`), and revoke. Demo mode falls back to localStorage with an explicit demo message.

Offline queue hardening:

* A mutation left in `syncing` for over 30 seconds (tab close, reload, crash) is repaired back to `queued` on the next flush instead of stranding forever.
* Automatic retries are capped at 8 attempts with exponential backoff (1s doubling, 60s ceiling); conflicts always require human decision; manual retry resets the attempt counter and backoff.
* A per-process in-flight guard prevents concurrent flushes racing over the same IndexedDB items.

Round 7 verification:

* Local: `npm run typecheck` clean; `npm test` 36/36; all 18 migrations replay cleanly on a fresh database; `discipline_suspensions.test.sql` passes 27 assertions under the replay harness with genuine role switching and RLS semantics.
* The first CI run for the round exposed a real regression: the pre-existing `mega4_release_hardening.test.sql` still asserted that an organization admin could insert straight into `disciplinary_cards`, contradicting the intentional RPC-only policy. Fixed in `3b52176` by flipping that assertion to the new contract (direct writes RLS-blocked, sqlstate 42501). The local 8-suite replay (every database suite, real role switching + RLS) is green on the corrected head.

## Round 8: Public spectator surface disambiguation (pushed as `c7fab9c`)

The flagship product gap from the completion matrix: showcase surfaces could masquerade as live tournament data.

* The former persistent `DemoNotice` banner has been removed from all showcase and public routes at the owner’s direction. Sample-only scoreboards and preview labels remain explicitly marked where needed.
* Every LIVE claim retitled to DEMO/SAMPLE: public hero "LIVE FROM SPRINGBROOK" → "DEMO PREVIEW · SAMPLE DATA"; red `● LIVE` pills → amber `● DEMO`; fake `00:42` clocks → `SAMPLE`; event statusbar "LIVE EVENT — HACSA SANCTIONED" → "DEMO EVENT · SAMPLE DATA"; dashboard "Live tournament / All reporting" → "Tournament preview / Sample data"; marketing mockup badge `LIVE` → `DEMO`.
* Spectator preview nav `Live Now ●` → `Public Arena ◎`; the live board `/#/live` (real AppState-backed data) is the primary CTA on the public hero and dashboard.
* Footer claim "Powered by live tournament data" replaced with a sample-data disclaimer.
* Verified: production build clean, `npm test` 36/36, and in-browser DOM assertions on `/`, `/public`, `/home`, `/events/fall-open`, `/rankings` confirming demo markers present and live claims absent.
* CI confirmed green on the combined Round 7+8 head: workflow `36533390822` (on `187862c`) passed the frontend job, the authoritative pgTAP database job, and the GitHub Pages deploy. The deployed site is live at <https://dothecoolwip1.github.io/BuhurtOS/>.

**Database-suite robustness note:** the discipline suite originally used `%...%` error patterns for `throws_ok`, which the supabase-bundled pgTAP does not treat as wildcards, and the bundled variant does not ship `throws_like` at all. Fixed in `3b52176`/`435b140`/`187862c`: assertions now pass the verbatim full `MESSAGE_TEXT` (e.g. `Not authorized to revoke suspensions`, `Fighter is under an active suspension until 2026-10-01`) to `throws_ok`, which is what real pgTAP requires. The local replay shim enforces the same exact-message semantics so this class of mismatch no longer passes locally.

## Round 9: Long Axe competition format (pushed as `e3fe92d`)

* Long Axe was the one ORIGINAL_SCOPE duel category absent from `competitionFormats.ts` (only marketing copy existed). Added `long_axe` as a `verified` BI duel preset (`duel()` scoring, exact scoring deferred to the selected sourced ruleset — same contract as its verified siblings), selectable in ruleset/division setup.
* Asserted in `tests/governance.test.ts` (the verified-formats list now includes `long_axe`); governance tests 6/6, typecheck clean, production build clean, and the final CI run on `187862c` (workflow `36533390822`) was green end-to-end including the deploy job.

## Round 10: Federation hierarchy (pushed as `b4b3795`, workflow `36534422890` green)

* Scoped port of the Pack 4 org/governing-body model onto main, `20261001000000_federation_hierarchy.sql`: organizations gain `kind` (international_federation → national_federation → regional_organization → local_organization → independent_organization) + `country_code`; `organization_relationships` model directed governing links (`governs`/`recognizes`/`affiliate`) with an active window, an `organization_id` generated mirror for org-scoped audit, public reads, and RPC-only writes.
* Guarded RPCs: `upsert_organization_relationship` (bilateral admin consent, active-org residency, active-duplicate refusal, hierarchy cycle protection, end/reopen lifecycle) and `end_organization_relationship` (parent-side admin only). `organization_ancestors` exposes the governing chain. Anonymous is revoked from the write RPCs; every write is audit-captured.
* `supabase/tests/database/federation_hierarchy.test.sql` — 34 assertions (schema, ACLs, role-gated writes, RLS-blocked direct writes, lifecycle, cycles, audit, public reads), green on the local 9-suite replay and under real pgTAP in CI (workflow `36534422890`).
* The frontend GovernancePage remains an honest showcase of the governance model; federation-aware dashboard UI is future work.

## Round 11: Broader exports (pushed as `5e67501`, workflow `36535409276` green)

* `export.ts` now shares one `csv()` routine (escapes commas, quotes, newlines) across standings, matches/order of play, discipline cards, suspensions, and roster-report builders, plus an `htmlTable` helper for printable reports.
* BracketPage wires the previously-unused `matchesCsv` (Export CSV) and a printable order of play; DisciplinePage exports cards and suspensions CSV plus a combined printable report; RosterPage exports the registration/roster report CSV and a printable compliance report.
* `tests/export.test.ts` — 6 assertions (header/row shape, CSV escaping, boolean to yes/no, enum label normalization), full suite 42/42, typecheck and production build clean; Export/Print buttons verified in-browser on the ops pages.

## Round 12: Audit completeness (pushed as `de109b9`, workflow `36536214636` green)

* `20261002000000_audit_completeness.sql` wires the shared `audit_change` trigger (→ `public.audit_log`) onto the remaining gap-listed core entities: brackets, organizations, seasons, events, rulesets, ruleset_sources, event_ruleset_snapshots, and profiles. Announcements and event_registrations were already covered (operational hardening) and now carry regression guards.
* Org scoping: rows inherit their org from `organization_id`, falling back to the owning event's `organization_id`; org-less rows (organizations themselves, profiles, ruleset_sources) are recorded with `organization_id` NULL and stay platform-admin-visible only.
* `supabase/tests/database/audit_completeness.test.sql` — 26 assertions (trigger presence incl. regression guards, insert/update/delete capture, event-derived org scope, unscoped-row behavior), green on the local 10-suite replay and under real pgTAP in CI (workflow `36536214636`).

## Round 13: Embeddable widgets + fuller public profiles (pushed as `a71c1d0`, combined green on `b61dccd` via workflow `36537529093`)

* Chrome-free standings widget at `#/widget/standings` rendered straight from the live event board (`computeEventStandings` over AppState): DEMO DATA badge in demo builds, public-mode read in Supabase mode, no site chrome. `src/lib/embed.ts` builds the widget URL and an escaped iframe snippet (`widgetEmbedCode`/`widgetStandingsUrl`); StandingsPage gains an Embed widget control (copy button + visible snippet + preview link). 7 new unit tests in `tests/embed.test.ts`.
* Deeper public profiles with honest demo content: `DemoFighter` gains weight class, experience level + years, socials, and tournament history; `DemoTeam` gains socials and season results (forming teams stay silent). FighterProfilePage renders Tournament history / Profile / Socials panels; TeamPage renders Season results / Socials. Verified in-browser on the preview surfaces.

## Round 14: Marathon verified flow (pushed as `b61dccd`, workflow `36537529093` green)

* `marathon` promoted from `custom_template` to `verified` in `competitionFormats.ts`, mirroring the Long Axe precedent: a first-class verified endurance category whose exact scoring and duration are deferred to the selected sourced ruleset version (`duel(1)` single-round endurance scoring config). Selectable in ruleset/division setup.
* `tests/governance.test.ts` now asserts `marathon` in `verifiedCompetitionFormats` and that it is no longer presented as an organization template. Full suite 49/49, typecheck and build clean; frontend job unaffected on the database side.

With Rounds 13 and 14, the planned product gap list (widgets + profiles, Marathon) is closed; the matrix marks the remaining items as ongoing/roadmap work.

## Round 15: Team standings board + fight-card-level exports (pushed as `7f67eab`, workflow `36567325902` green)

* Event **team standings** — `computeTeamStandings` in `src/lib/standings.ts` aggregates finalized cross-team fighter bouts per team (3/1/0; differential → points-for → wins → name tie-breaks; a "Fighters" count of distinct roster entries that actually competed). Intra-team, unaffiliated/individual, non-finalized and `bye` bouts earn no team points. `StandingsPage` gains a Fighters/Teams toggle (Teams only renders when the event has teams) with team CSV export + printable board; the embeddable widget stays fighter-only.
* `public.event_teams(event)` security-definer helper (`20261003000000_event_teams_public_read.sql`, execute granted to anon/authenticated) resolves the names/locations of teams already referenced by an event roster, so the public/team board works in Supabase mode without exposing the org-wide team catalog. Demo snapshot (`demoEventTeams`) derives the same list from demo roster team ids.
* **Fight-card-level exports** — `fightCardCsv` (card metadata + matches table) added to `export.ts` with `FightCardExportView`; wired to the ops active-field header ("Export card CSV", "Print / PDF") and to each field row on `EventManagementPage` (per-field `CSV`), alongside an inline printable fight card.
* Verification: 6 new assertions in `tests/standings.test.ts` plus `export.test.ts` additions (57 tests / 12 files), typecheck and production build clean; new `event_teams_public_read.test.sql` pgTAP suite; in-browser checks confirmed the Teams toggle honest empty state, then a finalized cross-team bout populating the board (Reavers 3 pts / North Garrison 0), the ops `field-1.csv` download contents, and the manage-page per-field CSV download.

## Round 16: Flexible organization relationship kinds (pushed as `c4d1f6f`, workflow `36567325902` green)

* Forward-only enum extension (`20261004000000_flexible_org_relationship_kinds.sql`) adds `sanctioned` (parent sanctions/endorses the child) and `predecessor` (parent historically precedes the child) to `organization_relationship_kind`, giving the order `governs, recognizes, affiliate, sanctioned, predecessor`.
* No RPC changes were needed: the guarded `upsert_organization_relationship` / `end_organization_relationship` functions take the enum type, so bilateral admin consent, the active-duplicate rule, the end/reopen lifecycle and cycle protection apply to every kind. `organization_ancestors` walks all kinds.
* Verification: `federation_hierarchy.test.sql` now pins the enum order and adds create/duplicate/cycle/ancestor assertions for both kinds (predecessor pair seeded on a fresh org so the existing ancestor-chain counts stay intact); full 11-suite pgTAP replay green locally, CI green end-to-end.

With Rounds 15 and 16, the last three flagged items (team standings, fight-card-level exports, `sanctioned`/`predecessor` org relationships) are closed.

## Verification status

Verified in GitHub Actions on an earlier Pack 2 branch head:

* TypeScript typecheck passed.
* Existing frontend/unit tests passed.
* Production Vite build passed.

Added for final Pack 2 verification:

* `tests/auth.test.ts` covers safe redirects and signed-out versus expired-session messaging.
* `supabase/tests/database/accounts_permissions.test.sql` performs direct anonymous and authenticated access attempts across two unrelated organizations and includes revoked membership and self-escalation cases.
* The repository CI rebuilds local Supabase from all migrations and runs pgTAP tests.

Final Pack 2 head `bef3d41c7fd509269535f13a85b2555961edd483` passed GitHub Actions workflow run `35945001693`. Pack 3 implementation head `2ffab73e9e403ab8c0325ef18a441ed5fe09319e` then passed GitHub Actions workflow run `35954642255`, including frontend checks, a clean rebuild through the Pack 3 migration, and all database tests. PR #6 merged that verified implementation as `e6fde086939f3c4e74353affb5a82a4aa1977a45`. Mega Pack 4 implementation head `07107630551711945284cabfac3de1c3ca86cc58` passed workflow `35999176785` with frontend, production-build, clean-migration, and pgTAP verification. Pack 5 implementation head `d357c6414edeabc2f0034c420207ca1d29fa36ae` passed workflow `36069252396` with the same frontend and clean-database verification, then merged in PR #9 as `178874356d4a8c4076d1deaa3ffd742d6490f515`. Pack 6 implementation head `789cca1daf8208a6732863409639546744acf52e` passed workflow `36080004581`, including the clean Supabase rebuild and pgTAP suites, then merged in PR #10 as `c6bbd937ed9a08592ca633325a848e2e765f4382`. Round 7 (discipline/suspensions/offline, head `27566ef`) passed the frontend job on workflow `36531121109` but its database job failed on a stale `mega4_release_hardening` assertion (direct discipline-card writes no longer allowed); the assertion was corrected in `3b52176`. Two further database-suite rounds fixed the discipline suite's error-pattern semantics (real pgTAP requires verbatim MESSAGE_TEXT; `throws_like` is not shipped). The combined Rounds 7–9 head `187862c` passed workflow `36533390822` green end-to-end, Round 10 (federation hierarchy) passed **workflow `36534422890` green on `b4b3795`**, Round 11 (broader exports) passed **workflow `36535409276` green on `5e67501`**, Round 12 (audit completeness) passed **workflow `36536214636` green on `de109b9`**, and Rounds 13 + 14 (widgets/public profiles, Marathon) passed **workflow `36537529093` green on the combined head `b61dccd`** — each covering the frontend job, the authoritative pgTAP database job (10 suites from Round 12 on), and the GitHub Pages deploy (site live at <https://dothecoolwip1.github.io/BuhurtOS/>); the docs-only heads `f4b7844` and `d1be2f0` passed workflows `36535061871` and `36535932022`. The Round 13 head `a71c1d0` alone was superseded by the immediate Round 14 push, so its CI evidence is the combined-head run `36537529093`. Rounds 15 + 16 (team standings + fight-card-level exports, flexible org relationships, combined head `c4d1f6f`) passed **workflow `36567325902` green end-to-end**, now covering the frontend job, the authoritative pgTAP database job (11 suites), and the GitHub Pages deploy.

## Explicitly unverified infrastructure

A connected Supabase project was inspected during Pack 2 and was identified as a different Northborn/Mallard/Reavers database, not a dedicated BuhurtOS database. No BuhurtOS migration was applied to it.

Until a dedicated BuhurtOS project is available, these remain unverified:

* Remote migration application.
* Hosted Auth redirect allowlist configuration.
* Real verification-email delivery.
* Real password-recovery email delivery.
* Deployed `invite-event-member` Edge Function behavior.
* Hosted JWT expiry and refresh behavior through the Supabase gateway.
* Hosted waiver Storage behavior.
* Deployed `upload-waiver` behavior.
* Deployed `create-registration-checkout` behavior.
* Real payment-provider checkout and webhook reconciliation.
* Real multi-device reconnect behavior on hosted infrastructure.

These are infrastructure verification items, not claims of successful production deployment.


## Hosted BuhurtOS Supabase deployment

The dedicated hosted backend is now project `tapfpboszgoftbwcwsmn` named **BuhurtOS** inside Supabase organization `vbxznwtocyorcfghzdfo`. This project is the only permitted hosted Supabase target for BuhurtOS. The Northborn/Mallard/Reavers project remains prohibited.

Hosted deployment completed on 2026-09-29:

* Restored the dedicated project and verified it was empty before deployment.
* Applied all 28 repository migrations in order, then applied three forward hosted follow-up migrations: access hardening, default-ACL hardening, and the waiver storage-policy correction.
* Verified all 41 public tables have RLS enabled.
* Removed legacy automatic anonymous/authenticated write grants from membership, suspension, federation-relationship, and ruleset surfaces according to their intended access models.
* Disabled automatic Data API grants for future objects created by the repository migration role. Live probes confirm new tables, sequences, and functions are not automatically available to `anon`, `authenticated`, or `service_role`.
* Deployed all four Edge Functions: `upload-waiver`, `create-registration-checkout`, `fighter-avatar`, and `invite-event-member`.
* Verified the `waivers` and `fighter-avatars` buckets are private with the intended size/MIME restrictions.
* Verified `events`, `matches`, `fight_cards`, `event_roster_entries`, and `announcements` are in the Realtime publication.
* Generated hosted TypeScript schema types successfully.
* Security Advisor warnings remaining are deliberate API visibility / SECURITY DEFINER warnings for RLS-backed public sporting data and guarded public helper functions; accidental anonymous membership/suspension visibility was removed.

GitHub Pages production builds are configured to use the project URL and modern publishable key. No service-role or secret key is stored in GitHub.

## Source-backed HACSA teams and BI marshal reference

Implementation branch `feature/hacsa-bi-marshal-reference` replaces fabricated showcase team facts with the 10 public teams currently listed by HACSA, verified 2026-09-29. HACSA is source priority 1; BI Teams and BI Official Ranking are explicitly staged as the next team sources.

The public and operations rule views now use a source-backed BI marshal reference covering the current core fight corpus: Buhurt Rules 26.4.1, Buhurt Regulations 26.4, Duels Rules 26.4, Duels Regulations 26.4, Outrance Rules and Regulations 26.4, and Weapons / Shield Chart 26.2.1. Indexed entries retain document/version/section provenance and can be filtered by fight format or searched by situation. The Marshal Console passes the active match category directly to the reference through the “Rules for this fight” link.

`tests/marshalReference.test.ts` verifies HACSA source provenance, match-category mapping, family isolation and BI source integrity. The first PR run passed TypeScript, Vitest and production build before the explicit numbered-subrule expansion; the current PR head must remain green before merge.

## November 1 Master Plan progress

* **Pack 1** complete (stability, CI, routing, release baseline).
* **Pack 2** complete (public experience, shared states, lazy map, mobile) — merged `63eb038`, CI green.
* **Pack 3** complete: teams gain a region filter and a stable `red-deer-reavers` slug in the offline fallback (UUID/legacy id lookup preserved); rankings page is now source-backed with 5v5/12v12 categories, organization/country filters and per-row provenance (`src/lib/rankings.ts`); organization pages show active governing relationships, published events and a source/independence note. Regression tests in `tests/pack3Directory.test.ts` (rankings never invent ranks, Reavers slug, fighter privacy select lists). No database migration was needed.
* **Pack 4** complete: general event model. Forward-only migration `20261014000000_general_event_model.sql` adds nine event categories (tournament, demo, training, clinic_workshop, recruitment, fundraiser, gathering_social, meeting_agm, community_appearance) while preserving every legacy `event_type` label and row, plus a stable `slug`, optional `host_team_id` and `image_path` with anon column grants. `src/lib/eventCategories.ts` maps legacy values, gates competition modules (divisions, schedule, fight areas, standings, fighter signup) by category/data, and powers the public events directory (upcoming/past, category/organization/host-team filters, month agenda, category badges, per-event CTA). The public frontend selects the new columns with a fallback to legacy columns, so it works before the migration is applied to the hosted project. Tests: `tests/pack4Events.test.ts` (including server-rendered proof that noncompetitive events render no standings/brackets/fight cards) and `supabase/tests/database/pack4_general_events.test.sql`. **The migration must still be applied to hosted project `tapfpboszgoftbwcwsmn`.**
* **Pack 5 (partial, media + public Rumble page)**: migration `20261015000000_event_media.sql` adds a public-read `event-media` Storage bucket (5 MB, jpeg/png/webp), organizer-only write policies scoped to `<event_id>/…` paths via `private.can_manage_event_media`, and a guarded `set_event_image` RPC. `EventMediaPanel` (Event management → settings) uploads with client-side resize/WebP optimization, replaces and removes; the public event page renders a desktop hero and mobile-sized rendition only when a real poster is stored (no poster is invented). Real record verified: Red Deer Rumble `6028e471-a95c-4d8a-8101-1f168bc68c8b`, Nov 14–15 2026, Horse in Hand Ranch, host Red Deer Reavers, type `custom`, schedule TBA; the page shows honest "To be announced" rows and only activates competition modules when real data exists. Tests: `tests/pack5EventMedia.test.ts`, `supabase/tests/database/pack5_event_media.test.sql`. The supplied Rumble poster image was not available in this session, so none was uploaded. **Migrations 20261014/20261015 still need applying to the hosted project.**
* **Pack 5 signup verification**: `supabase/tests/database/pack5_signup_codes.test.sql` proves at database level that codes are event-recognizable (`RDR26-XXXXXX`) and stored only as SHA-256 hashes, anonymous users can validate and submit with a valid code but cannot read submissions, unrelated authenticated users cannot read or disable, authorized event-hierarchy users can read/list/disable, and expired / disabled / max-use codes are rejected. CI green on `8915afc`. The accept/deny/organizer-notes review workflow was not re-verified in this pass.
* **Pack 6** complete: migration `20261016000000_platform_configuration.sql` adds the centralized `platform_settings` layer (`account_registration_mode`, `event_creation_mode`, four `*_claims_enabled` flags) behind `get_platform_config()` (public read) and `set_platform_setting()` (super admin only, validated, audited). `event_creation_mode = platform_only` is enforced by a database trigger; `organization_members`/`open` add a draft-only insert policy for organization members. `claim_requests` with `submit_claim_request` / `withdraw_claim_request` / `review_claim_request` make existing organizations, teams, fighters and events claimable without recreation (approval records the decision; roles are still granted through the existing guarded RPCs; no claim UI beyond platform review). Frontend: `src/lib/platformConfig.ts` is the only place modes are interpreted; the owner console gains a "Platform settings" tab and the login page respects registration mode (server-side enforcement of registration needs a Supabase Auth hook and is not claimed). Defaults preserve launch behavior. Tests: `supabase/tests/database/pack6_platform_configuration.test.sql`, `tests/pack6PlatformConfig.test.ts`. **Migration must be applied to the hosted project.**
* **Pack 7** complete: one statistics/provenance foundation. `src/lib/canonicalStats.ts` defines what an official result is (finalized, recorded winner, not a bye, two real sides) and derives team, fighter (linked identities only) and event stats plus native result provenance (event, ruleset snapshot, finalization time, audit flag) and source reconciliation (`reconcileTeamRecords`: explicit links first, normalized name+country otherwise; highest-priority source is shown, disagreements are reported as conflicts and never overwritten). Migration `20261017000000_canonical_stats_provenance.sql` adds `team_canonical_links` (+ `link_duplicate_team` for super admins, `resolve_canonical_team`), `public_team_provenance`, `official_team_stats`, `official_event_stats` and `official_match_provenance` using the same official-result definition in SQL. Team pages show the native record and sources/provenance panels; event pages show official results only when finalized results exist. Tests: `tests/pack7CanonicalStats.test.ts`, `supabase/tests/database/pack7_canonical_stats.test.sql`. **Migration must be applied to the hosted project; until then the pages simply omit the new panels.**
* **Pack 8** complete: versioned public data contract (`src/lib/publicApiV1.ts`, documented in `docs/PUBLIC_API_V1.md`) with whitelist DTOs for organizations, teams, team stats, events and calendar, and `resolveApiV1` mapping the conceptual `/api/v1/*` routes. Four iframe embeds under `#/embed/...` (events agenda with organization/team/category filters, team card + stats, event card, standings for an explicit event id) with light/dark/auto theme, accent color, "Powered by BuhurtOS", and clear empty/error states, plus an Embed Builder at `#/embed-builder` (widget, organization/team/event, theme, height, preview, copy iframe code) and a client-side `.ics` download on the Events page. Verified by pasting generated iframes into a plain standalone HTML page served locally against the hosted backend: real Red Deer Rumble and Reavers data render at desktop and 375px widths; invalid team/event ids show "Not available"; private fields never enter widget payloads (tested). Also fixed a pre-existing public-data bug: the event snapshot query embedded `match_participants` ambiguously (two foreign keys to `matches`), which made every public snapshot load fail against the hosted database; it now uses `match_participants!match_participants_match_id_fkey`. Tests: `tests/pack8Embeds.test.ts`.
* **Pack 9** complete (Android proof deliberately skipped): mobile audit run programmatically against the hosted-data build at 360, 390, 412, 768 and 1024px across public home, organizations, organization detail, teams, team detail, fighters, events, event detail, rankings, rules, login and the embed builder. Fixed `/teams` (127px horizontal overflow from the three filter selects), rules pill overflow, explain-card links squeezed to 32px, sub-36px tap targets (search, link buttons, rule tabs, "Open source", agenda links) and iOS input zoom (16px form text); final run shows no horizontal overflow and no small targets at any width. The owner console, event management and fighter-signup admin require sign-in and were not measurable in this pass. PWA: separate `any`/`maskable` icons; `sw.js` now precaches the full built asset list (injected by `scripts/swPrecachePlugin.mjs`, per-build cache name, old caches dropped), a new worker waits until the visitor taps "Reload to update" (`UpdateBanner`), stale lazy-chunk failures after a deploy trigger one guarded reload, and the worker still never caches cross-origin (Supabase) or Authorization-bearing requests; verified by running the built worker in a Node sandbox (68 assets precached, policy and skip-waiting behavior correct). Realtime: topic helpers (`event:`/`field:`/`match:`), bursts coalesced into one refresh. The offline queue is unchanged (its 8 existing tests cover queue, backoff, conflict-retained, stale-syncing repair and single-flight). Tests: `tests/pack9Pwa.test.ts`. Capacitor/Android was not attempted (no Android SDK here); it remains optional.
* **Pack 10** complete (release freeze): security gate (`supabase/tests/database/release_security_gate.test.sql`) found leftover table privileges (anonymous UPDATE/DELETE/TRUNCATE and SELECT on `fighter_event_signups`, client write and TRUNCATE on `audit_log`), fixed by migration `20261018000000_release_privilege_hardening.sql` (guarded RPCs that append their own audit row keep INSERT). Also: legacy `/about` page with invented fighter/rank/match content now redirects to the public home; organization relationship names resolve through the public directory RPC (anonymous visitors cannot read the organizations table); global focus rings, reduced-motion support and accessible embed accent contrast; event probing remembers a backend without the general-event columns; CI now surfaces failing pgTAP assertions as annotations.

## November 1 release candidate summary (Packs 1–10)

Release candidate head: `2ccab64` on `main`. Its CI workflow is green end to end (navigation audit, TypeScript, 142 unit tests, production build, clean Supabase rebuild from every migration, all pgTAP suites including the new release security gate, and the GitHub Pages deploy). Site: <https://dothecoolwip1.github.io/BuhurtOS/>.

### What is live
* Public site: home, organizations (with published events and active governing links), teams (search, organization/country/region filters, map, stable `red-deer-reavers` slug with UUID fallback), team profiles, fighters, events directory (categories, upcoming/past, organization/host-team filters, month agenda, `.ics` download), event pages (competition modules only when they apply), source-backed rankings (5v5/12v12 with provenance), BI rules reference, and the `#/embed-builder` page.
* Iframe embeds: `#/embed/events`, `#/embed/team/{slug}`, `#/embed/event/{id}`, `#/embed/standings/{id}`; versioned public data contract in `src/lib/publicApiV1.ts` (`docs/PUBLIC_API_V1.md`).
* Real proof event: Red Deer Rumble (`6028e471-a95c-4d8a-8101-1f168bc68c8b`), Nov 14–15 2026, Horse in Hand Ranch, Blackfalds, Alberta, host Red Deer Reavers; unknown details show "To be announced"; invite-code signup validates codes on the live backend.
* PWA: installable manifest, full-asset precache, visitor-controlled updates, no caching of Supabase or authenticated traffic.

### What is verified
* CI gates above on every pack, each deployed separately.
* Database (pgTAP): general event model, event media storage policies, signup codes (hashed, anonymous submit, no anonymous/unrelated reads, expired/disabled/max-use), platform settings and claim records, canonical stats and provenance, and the release security gate (RLS on every public table, no anonymous writes, sensitive tables unreadable by anon, no client TRUNCATE, append-only audit history, administrative functions not executable by anon, only `event-media` bucket public).
* Browser, against the hosted backend: embeds pasted into a plain HTML page (desktop and 375px), invalid team/event ids, real Rumble and Reavers data, public-page overflow/tap-target audit at 360/390/412/768/1024px, bad-code signup flow, structural accessibility scan (labels, names, alt text, one h1 per route), request counts.
* Secret scan: no keys in the repository; the only credential in CI config is the public publishable key; service-role keys are read from environment inside Edge Functions.

### Hosted project: migrations still to apply (security-relevant, do this first)
The deployed site degrades gracefully without them, but the hosted project `tapfpboszgoftbwcwsmn` does not yet have these forward-only migrations:

1. `20261014000000_general_event_model.sql` (event categories, slug, host team, image path)
2. `20261015000000_event_media.sql` (poster bucket and policies)
3. `20261016000000_platform_configuration.sql` (platform settings, event-creation mode, claim records)
4. `20261017000000_canonical_stats_provenance.sql` (official stats, provenance, canonical team links)
5. `20261018000000_release_privilege_hardening.sql` (revokes leftover table privileges found by the release gate)

Apply with `supabase link --project-ref tapfpboszgoftbwcwsmn` then `supabase db push`, then re-run the Supabase security advisor. Only the BuhurtOS project may be used.

### Intentionally deferred
Capacitor/Android proof, PowerSync, MapLibre rewrite, Lit/web-component embeds, AI rulings, payment provider and webhook (paid registration still fails closed), subscribable live `.ics` URLs (needs an HTTP edge), server-side enforcement of `account_registration_mode` (needs a Supabase Auth hook; the setting currently drives the login UI only), claim submission UI (records and platform review exist).

### Known non-blocking limitations
* The HACSA directory lists the Reavers twice ("Reavers" and "Red Deer Reavers"). After migration 4 is applied, link them with `select public.link_duplicate_team('<alias id>', '<canonical id>', 'Same team listed twice');` as a platform super administrator.
* No Rumble poster is stored: the supplied image was not available in this session. Upload it from Event management, Settings, Event poster once migration 2 is applied.
* The Supabase security advisor could not be run from this session (the Supabase connector needs authorization); the repository-level gate above is the substitute.
* Owner console, event management and fighter-signup admin pages need sign-in and were not included in the automated mobile audit; the signup review (accept/deny/notes) UI was not re-verified end to end in this pass.
* The Rumble page shows its real "Main List" fight area in draft status.

### Next priorities after launch
Apply and verify the five migrations on the hosted project; run the security advisor; link duplicate team rows; upload the Rumble poster; audit the signed-in admin pages on phones; end-to-end test organizer code creation and signup review with real accounts; enable claims when ready; add the Auth hook for registration modes; add a calendar feed edge function; consider the Android proof.

## Navigation and experience redesign (2026-09-30)

The owner rejected the old navigation, so the signed-in experience was rebuilt around three connected areas: **Public site**, **My workspace** (`#/me`) and **Administration** (`#/admin`). Full map, route mapping, verification log and limits: `docs/NAVIGATION.md`; product intent: `docs/PRODUCT_CONTEXT.md`.

* One navigation model (`src/lib/navigation.ts`), one shared shell (`src/components/chrome.tsx`), an account layer for every area (`src/features/Account.tsx`), a workspace (`WorkspaceHome`, `WorkspaceTeams`, real profile editor, join with a code) and an administration overview with live needs-attention checks (`AdminHome`).
* Old `/ops/*` and `/team-hq` URLs redirect with query strings and invitation tokens preserved; `/ops/login` is now `/sign-in`; the default landing after sign-in is My workspace.
* Removed the fake `/me` preview and the `/team-hq` redirect to the Reavers page. Permission failures now explain themselves instead of silently redirecting.
* Public filters live in the URL, detail pages have breadcrumbs that return to the last filtered list, and the events list shows registration status.
* Tests: `tests/navigation.test.ts` (every menu destination is a real route, every legacy URL maps to a real destination, menu gating per role, breadcrumbs, scope, remembered filters).
* No new backend changes were needed; hosted migrations 20261014–20261018 remain applied (verified via the Supabase connector). Not verified with real signed-in hosted accounts (see `docs/NAVIGATION.md`).
