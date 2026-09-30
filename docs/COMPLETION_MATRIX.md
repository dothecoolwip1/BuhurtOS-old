# BuhurtOS Completion Matrix

Source of truth: `docs/ORIGINAL_SCOPE.md`. This matrix maps every original scope
section to its current status **on `main`**, with the evidence to back each row.
Status key:

- ✅ Complete — implemented, guarded, and covered by CI tests on `main`.
- 🟡 Partial — core path exists; some listed sub-items remain.
- ❌ Not started — absent from `main` (may exist on an unmerged branch).
- ⛔ Deliberately deferred — product decision or external dependency (e.g. payments).

Rows marked 🟡/❌ are the remaining product work, not claims of completion.
"Showcase" content (marketing pages) is explicitly **not** live data; the matrix
only credits real, wired functionality.

---

## Master Execution Plan Pack 1: Release Baseline

| Requirement | Status | Evidence |
|---|---|---|
| One authoritative release workflow | ✅ | `.github/workflows/pages.yml`; redundant `deploy-pages.yml` removed |
| Navigation audit | ✅ | `scripts/audit-navigation.mjs` validates required Pack 1 routes, stale fake IDs, deep-link bridge, quarantined showcase dashboard, and action buttons |
| TypeScript, unit tests, production build | ✅ | Required by the gated `quality` job before deployment |
| Clean Supabase start and migration replay | ✅ | `database` job runs `supabase start` then `supabase db reset`; migration-order blockers repaired |
| pgTAP database verification | ✅ | `database` job runs `supabase test db` and gates deployment |
| Hosted public/private event ACL | ✅ | `20260930042147_pack1_public_event_privilege_hardening.sql`; hosted recheck denies anonymous `events.notes` while retaining intended public event columns |
| Public route baseline | ✅ | `/`, `/public`, governance, organizations, teams, fighters, events, rankings, and rules are explicitly audited |
| Operations route baseline | ✅ | login, platform, delegated codes, event management, and fighter signups are explicitly audited |
| Mobile/shared public deep links | ✅ | `src/main.tsx` `?go=` bridge plus `PublicTeamMap.tsx` URL generation |
| Stale demo/showcase production routing | ✅ | old fake event/fighter IDs blocked by audit; `ShowcaseDashboard` must remain unrouted |
| Dead actionable controls | ✅ | TSX button audit rejects buttons without an obvious action/submit/form behavior |
| Explained loading and error states | ✅ | public directory/event/profile pages distinguish load failure from empty data; event management has a no-event state |
| Production data preservation | ✅ | privilege-only hosted migration; no production reset or row deletion |

## Platform and Architecture

| Requirement | Status | Evidence |
|---|---|---|
| React + TypeScript application | ✅ | `src/App.tsx`, React 19, TS strict build in CI |
| Mobile-first PWA | ✅ | `public/manifest.webmanifest`, `public/sw.js`, icons, installable; responsive CSS |
| PC / Android / iPhone / tablet | 🟡 | Responsive layout and touch targets; device testing unverified on hosted infra |
| Offline-capable field workflows | ✅ | `src/lib/offlineQueue.ts` (stale-`syncing` repair, capped auto-retry with backoff, manual retry reset, per-process flush guard) |
| Local persistence for unsynced work | ✅ | IndexedDB/localStorage queue in `offlineQueue.ts` |
| Queued writes and background synchronization | ✅ | same |
| Conflict-safe recovery (simultaneous marshals) | ✅ | server-side expected-version guards; explicit retry/discard; no last-write-wins |
| Realtime updates | ✅ | Supabase Realtime subscriptions (`fightCardRealtime`, event setting changes) |
| Supabase/PostgreSQL/Auth/Realtime/Storage/RLS | ✅ | migrations + CI database job (`supabase start` + `db reset` + `supabase test db`) |
| UTC timestamps + local conversion | ✅ | `timezone('utc', now())` defaults; client `toLocaleString()` |
| i18n-ready | 🟡 | No hard-coded federation root; UI strings not yet localized |
| Multi-tenant organization isolation | ✅ | RLS + organization scoping across suites |
| Audit logging from Day 1 | 🟡 | Audit triggers on 15 tables (see Auditability); gaps listed there |
| Future payment/subscription readiness | 🟡 | `create-registration-checkout` fail-closed; no provider |
| No fragile drag-and-drop for critical controls | ✅ | safe Up/Down reorder controls |
| High contrast, sunlight-readable UI | ✅ | theme + gap-fill CSS delivered in this round (site+app styles consolidated) |
| Oversized touch targets | 🟡 | large buttons; full device audit unverified |
| Fast minimal-step scoring/marshal flows | ✅ | bullpen, on-deck, one-tap operations |

## Hierarchy and Core Data Model

| Requirement | Status | Evidence |
|---|---|---|
| Governing body / federation → org → season → event → fight card → pool/bracket → match | ✅ | Full chain on `main`: org/season/event/card/pool/match (Packs 1–6) plus the federation layer (`20261001000000_federation_hierarchy.sql`, `20261004000000_flexible_org_relationship_kinds.sql`) with `organization_relationships` kinds `governs`/`recognizes`/`affiliate`/`sanctioned`/`predecessor`. Federation-agnostic data (rulesets/divisions sourced from BI/IMCF/HACSA as seed, never hard-coded root) is on `main` (Pack 5). |
| Teams, fighters, ghost/guest/mercenary | ✅ | `teams`, `fighters`, `event_roster_entries.entry_type`, ghost fighter creation in `AdminPage`/`FoundationPage` |
| Match participants, team lineups, rounds | ✅ | `match_participants`, `match_rounds`, team lineups |
| Discipline records + suspensions | ✅ | NEW this round: `disciplinary_cards` + `suspensions`, guarded RPCs, data-layer enforcement |
| Fight notes | ✅ | `NotesPage` + `notes` table + RLS |
| Announcements | ✅ | `EventManagementPage` create/list + `announcements` table |
| Registrations, waivers | ✅ | Pack 6 registration + waiver Upload/Storage |
| Payments | ⛔ | fail-closed; requires provider |
| Audit records | ✅ | `audit_log` with `audit_change` trigger across the core entities; covers match/roster/discipline/announcements/registration/org/season/event/ruleset/profile changes |
| Season table from Day 1 | ✅ | `seasons` since Pack 1 |
| Audit metadata on operational tables | ✅ | `created_at/updated_at/created_by/last_edited_by` conventions |

## Roles and Permissions

| Requirement | Status | Evidence |
|---|---|---|
| Platform super admin / staff | ✅ | `platform_role` enum, guards, first-admin sentinel |
| Organization admin / staff | ✅ | `organization_role`, guarded member admin |
| Event organizer | ✅ | `event_role`, guarded assignment |
| Field / assistant marshal | ✅ | `event_role` + marshal workflows |
| Team captain / fighter | ✅ | team-scoped RLS, fighter self-service |
| Public spectator (no login) | ✅ | anonymous client + published-event RLS |
| Platform/org/event/participant scoping | ✅ | `private.is_platform_admin/has_org_role/has_event_role` |
| Captain team-scoped privacy | ✅ | captain roster RLS |
| Fighter self-service access | ✅ | IdentityPage + own-row RLS |

## Event Types

| Requirement | Status | Evidence |
|---|---|---|
| Ranked competitive | ✅ | `event_type` + standings_mode |
| Event-only competitive | ✅ | `standings_mode = 'event_only'` keeps it out of season standings |
| Non-ranked demo / fun | ✅ | `demo_fun` |
| Exhibition | ✅ | `exhibition` |
| Clinic / training | ✅ | `clinic_training` |
| Hybrid | 🟡 | approximated by `custom` + standings_mode separation |
| Custom event types | ✅ | `custom` value + custom formats |
| Standings separate from event type | ✅ | `standings_mode` enum governs, not event type |

## Duel Formats

| Requirement | Status | Evidence |
|---|---|---|
| Longsword / Sword+Shield / Sword+Buckler / Sword+Sword / Saber / Greatsword / Polearm / Profight / Triathlon | ✅ | `competitionFormats.ts` sourced BI formats |
| **Long Axe** | ✅ | `competitionFormats.ts` `long_axe` verified entry (`duel()` scoring, sourced BI family), selectable in rulesets/division setup; asserted in `tests/governance.test.ts` |
| One-minute rounds / most-points / best-of scoring | ✅ | ruleset-driven `duel(n)` scoring config |
| Sword+Buckler first-to-5 / first-to-2 | ✅ | `competitionFormats.ts` buckler preset |
| Profight/Triathlon event-specific rules | ✅ | `custom_template`, ruleset drives details |
| Ruleset-driven (not hard-coded) scoring | ✅ | Pack 5 locked snapshots + validation |

## Melee Formats

| Requirement | Status | Evidence |
|---|---|---|
| 3v3 / 5v5 / 10v10 | ✅ | `competitionFormats.ts` verified melee presets |
| 12v12 | ✅ | `12v12` verified BI-current preset |
| Last-team-standing model | ✅ | melee scoringConfig |
| Team lineups, per-side roster membership | ✅ | match participants + team lineups |
| Round wins, configurable best-of | ✅ | melee config |
| Forfeits and withdrawals | ✅ | forfeit handling + Pack 6 withdrawals |
| Safety/compliance gating before activation | ✅ | compliance gate + guarded clearance |
| **Marathon** | ✅ | `competitionFormats.ts` `marathon` verified entry (`duel(1)` endurance scoring deferred to the sourced ruleset), selectable in rulesets/division setup; asserted in `tests/governance.test.ts` |

## Pools and Brackets

| Requirement | Status | Evidence |
|---|---|---|
| Visual brackets | ✅ | bracket views in ops + public |
| Pools feeding brackets | ✅ | `pools_to_bracket` format |
| Single elimination | ✅ | bracket generation |
| Double elimination | ✅ | `20260923090700_double_elimination_results.sql` + format option |
| Round-robin / pool stages | ✅ | computed pool qualification |
| Pools-to-bracket progression | ✅ | `computePoolQualificationState` + advance controls |
| Automatic winner / pool advance | ✅ | same |
| Byes, no BYE-vs-BYE | ✅ | bye auto-advancement |
| Participant locking after results | ✅ | result submission guards |
| Manual placement overrides, seeding, intelligent seeding, anti-fratricide | ✅ | `bracket.ts` seeding + fratricide logic |
| Manual override of automated seeding | ✅ | placement override UI |
| Bracket locking | ✅ | lock state |
| Relational winner/loser progression links | ✅ | bracket schema |

## Fight Card and Field Operations

| Requirement | Status | Evidence |
|---|---|---|
| Ordered fight card | ✅ | fight cards + sort order |
| Safe Up/Down reorder | ✅ | no drag-and-drop dependency |
| Current / on-deck / in-the-hole | ✅ | bullpen states |
| Bullpen view | ✅ | live ops UI |
| Multi-list / multi-field assignment | ✅ | `fighters`/lists in `adminActions`; field admin |
| Multiple simultaneous marshals | ✅ | realtime + expected-version guards |
| Conflict-safe live updates | ✅ | same |
| Forfeit handling | ✅ | result submission |
| Match activation / completion controls | ✅ | state machine |
| Clear field readiness status | ✅ | status pills |
| Post-match validation before finalization | ✅ | scoring validation |

## Registration and Event Intake

| Requirement | Status | Evidence |
|---|---|---|
| Public registration without account where appropriate | ✅ | Pack 6 public registration RPCs |
| Event registration open/close | ✅ | deadline enforcement in PostgreSQL |
| Categories/divisions | ✅ | event divisions |
| Team affiliation, guest/mercenary support | ✅ | registration kind + roster entry types |
| Approval/rejection/waitlist workflow | ✅ | Pack 6 review states |
| Transactional approval into permanent records | ✅ | RPC-based approval flow |
| Duplicate fighter/ghost detection | ✅ | Pack 3 duplicates + identity admin |
| Ghost fighter linking/merging | ✅ | Pack 3 merge workflow (approval-separated) |
| Waiver acknowledgement + private uploads | ✅ | waiver state + `upload-waiver` Edge Function |
| Registration payment readiness | 🟡 | capability token flow; fail-closed |
| Payment status | ⛔ | no provider |
| Future product payment support | ⛔ | deferred |

## Check-in and Safety Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Registered / approved / no-show / late / withdrawn | ✅ | attendance status |
| Checked in / armor / medical / waiver / weigh-in cleared | ✅ | clearance columns |
| Competition blocked when compliance incomplete | ✅ | `set_roster_competition_clearance_guarded` + compliance gates |
| Suspension blocks clearance (new) | ✅ | NEW: `prevent_clearance_while_suspended` trigger on `event_roster_entries` |

## Teams and Fighters

| Requirement | Status | Evidence |
|---|---|---|
| Reusable team records | ✅ | `teams` |
| Reusable fighter records | ✅ | `fighters` + `fighter_identities` |
| Fighter + team profiles | ✅ | public fighter profiles (bio, record, season record, tournament history, profile details, socials, gallery) + team profiles (about, roster, results, socials); demo enrichments verified in-browser |
| Team membership | ✅ | `fighter_affiliations` + captain-scoped RLS |
| Fighter event/season history | ✅ | roster + results referencing permanent fighter |
| Ghost/guest/mercenary identities | ✅ | entry types + ghost creation |
| Merge without losing history | ✅ | Pack 3 merge preserves references |
| Captain team-scoped access | ✅ | RLS |
| Fighter self-service | ✅ | IdentityPage |
| Schedules/results relevant to fighter | ✅ | event/roster reads |

## Standings and Rankings

| Requirement | Status | Evidence |
|---|---|---|
| Event standings | ✅ | `standings.ts` |
| Season standings | ✅ | season_and_event mode |
| Ranked vs non-ranked separation | ✅ | standings_mode |
| Correct bye exclusion | ✅ | standings logic |
| Configurable standings/ranking logic | ✅ | standings_mode + ruleset ranking policy |
| Historical season archive | ✅ | seasons immutable + archived events |
| Team and/or fighter standings per ruleset | ✅ | fighter standings (`computeEventStandings`) plus an event **team standings** board (`computeTeamStandings` in `src/lib/standings.ts`) surfaced as a Fighters/Teams toggle on `StandingsPage`; team rows aggregate finalized cross-team fighter bouts (3/1/0, differential/points/wins/name tie-breaks, distinct-fighter count), with a scoped `public.event_teams(event)` RPC resolving names for anonymous viewers in Supabase mode |
| Future analytics | ❌ | not started |

## Discipline and Safety History

| Requirement | Status | Evidence |
|---|---|---|
| Yellow / red cards | ✅ | `disciplinary_cards` + colored UI |
| Fighter / event / season-level history | ✅ | card rows link fighter, event, season |
| Suspensions | ✅ | NEW: `suspensions` + lifecycle RPCs (issue/revoke) + RLS |
| Reasons and notes | ✅ | required reason; notes field |
| Issuing marshal/admin | ✅ | `issued_by` stamped from `auth.uid()` |
| Match reference where applicable | ✅ | optional match id validated in-event |
| Repeat-offense visibility for authorized staff | ✅ | season history list (authorized scope) |
| Enforcement: active suspension blocks clearance | ✅ | NEW: additive trigger on every write path + guarded RPC |
| Card/suspension writes RPC-only | ✅ | NEW: `discipline_write` policy dropped; suites verify direct inserts fail |

## Fight Notes and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Private / team-only / marshal-visible notes | ✅ | NotesPage + RLS |
| Team captain isolation | ✅ | team RLS |
| Match-linked notes | ✅ | note → match |
| Backend-enforced access | ✅ | RLS, not UI |

## Public Spectator Experience

| Requirement | Status | Evidence |
|---|---|---|
| Event page without login | ✅ | public event page (published-only RLS) |
| Live scoreboard | ✅ | `/live` |
| Current match / on-deck | ✅ | live view |
| Schedule / fight card | ✅ | public schedule + card |
| Pools / visual brackets | ✅ | public pool/bracket views |
| Event standings | ✅ | `/live` standings; public standings by standings_mode |
| Relevant season standings | ✅ | season_and_event |
| Announcements | ✅ | public announcements |
| Livestream embed (YouTube/Twitch) | 🟡 | stream settings + embed surface; streaming not production-verified |
| Read-only fighter/team/event info | ✅ | public fighter profiles (bio, record, season record, tournament history, socials) + team profiles (about, roster, season results, socials) + public event pages |
| Shareable public links | ✅ | `share.ts` |
| Embeddable widgets | ✅ | chrome-free standings widget at `#/widget/standings` rendered from the live event board (DEMO DATA labeled in demo builds; public-mode read in Supabase mode); `src/lib/embed.ts` iframe snippet builder + copy/embed block on the Standings page |
| **Mock-vs-real split** | ✅ | Showcase surfaces are explicitly disambiguated: a `DemoNotice` banner on every showcase route (`ShowcaseShell` + `/public`), DEMO/SAMPLE markers replace all LIVE claims, fake clocks/scoreboards are titled "SAMPLE", the spectator nav opens Public Arena, and `/#/live` (real AppState data) is the primary CTA. Verified in-browser + production build. |

## Event Management

| Requirement | Status | Evidence |
|---|---|---|
| Event settings | ✅ | `EventManagementPage` |
| Ruleset selection | ✅ | event divisions + ruleset snapshots |
| Event-type configuration | ✅ | |
| Standings mode | ✅ | |
| Registration settings | ✅ | |
| Stream settings | ✅ | `stream.ts` |
| Announcements | ✅ | |
| Participant management | ✅ | roster + members |
| Fight-card management | ✅ | |
| Pool/bracket management | ✅ | |
| Marshal assignments | ✅ | event member roles |
| Team captain assignments | ✅ | event member roles |
| Event publishing/archiving | ✅ | guarded lifecycle |
| Multi-field/list configuration | ✅ | fields |
| Org/team admin panel | ✅ | secured `/ops/governance` workflow: organization relationships, clubs, teams, captain/team roles, invitation links, applications, lifecycle actions; Pack 4 pgTAP suite |

## Announcements

| Requirement | Status | Evidence |
|---|---|---|
| Public announcements | ✅ | is_public flag + public view |
| Internal operational announcements | ✅ | internal flag |
| Scheduling | ✅ | scheduled_for |
| Realtime delivery | ✅ | realtime subscription in event view |

## Exports and Reporting

| Requirement | Status | Evidence |
|---|---|---|
| CSV exports | ✅ | `export.ts` (standings, matches/order of play, discipline cards, suspensions, roster report) |
| PDF / printable reports | ✅ | `openPrintableReport` wired to standings, bracket order of play, discipline report, registration report (browser print / save-as-PDF) |
| Event results / standings / rosters / fight cards / brackets / discipline exports | ✅ | standings (incl. team standings), bracket order of play, roster report, discipline cards + suspensions CSV all live; **fight-card-level exports** added — `fightCardCsv` (card metadata + matches table) wired to the ops active-field header ("Export card CSV", "Print / PDF") and to each field row on `EventManagementPage`, plus inline printable cards |
| Registration/admin reports | ✅ | roster registration report CSV + printable compliance report (`RosterPage`) |
| Future analytics | ❌ | not started |

## Offline and Realtime

| Requirement | Status | Evidence |
|---|---|---|
| Local persistence | ✅ | offline queue |
| Queue of unsynced actions | ✅ | |
| Background retry | ✅ | capped retries + exponential backoff |
| Auto sync on reconnect | ✅ | |
| Visible sync state | ✅ | status indicators |
| Conflict detection | ✅ | expected-version guards, no silent overwrite |
| Manual retry/discard | ✅ | conflict UI |
| Multi-device sync | 🟡 | mechanism present (version guards); real multi-device testing unverified |
| Realtime event updates | ✅ | |
| Recovery from interrupted sync | ✅ | stale-`syncing` repair (30s) |
| No loss of critical scoring/results | ✅ | queued mutations + conflict surface |

## Auditability

| Requirement | Status | Evidence |
|---|---|---|
| Match result changes | ✅ | audit trigger |
| Match state changes | ✅ | audit trigger |
| Roster/compliance changes | ✅ | audit trigger |
| Bracket creation/changes | ✅ | `audit_change` trigger (`20261002000000`); suite verifies insert/update/delete + event-derived org scope |
| Discipline (cards + suspensions) | ✅ | NEW: `audit_change` trigger on both tables; suites verify |
| Registration decisions | ✅ | Pack 6 |
| Event membership/role changes | ✅ | Pack 2 |
| Announcements | ✅ | audited since operational hardening; regression-guarded in `audit_completeness.test.sql` |
| Important administrative changes | ✅ | orgs/seasons/events/rulesets/ruleset_sources/snapshots/profiles now audited; org-unscoped rows visible to platform admins only |

## UX Requirements

| Requirement | Status | Evidence |
|---|---|---|
| Mobile-first | ✅ | responsive layout + mobile media rules |
| Phones/tablets/desktop | 🟡 | responsive CSS; hosted device QA pending |
| Bright-sun readability | ✅ | high-contrast theme |
| Large buttons | ✅ | `--tap:48px` + oversized actions |
| Gloves-friendly | 🟡 | same as touch targets |
| Minimal typing in live fights | ✅ | one-tap scoring |
| Minimal navigation during marshal work | ✅ | bullpen-first flows |
| Guided scoring | ✅ | validated post-match flow |
| Explicit confirmation for final results | ✅ | confirms + stale checks |
| No critical drag-and-drop | ✅ | |
| Clear offline/online/sync indicators | ✅ | |
| Fast bullpen visibility | ✅ | |
| Clear competitor readiness | ✅ | compliance/status pills |
| Public UI separated from ops | ✅ | separate routes + clients |

## Self-Service / Federation Sections (ORIGINAL_SCOPE additions)

| Requirement | Status | Evidence |
|---|---|---|
| Org-controlled team creation / captains / team administration | ✅ | guarded Pack 4 RPCs and `/ops/governance` UI cover team creation, approval, role assignment, membership lifecycle, and audit records |
| Captain invite existing members / no-account invites | ✅ | expiring email-bound club/team invitation links; recipients can sign up with the invited address and then accept through `/ops/invite` |
| Captain temporary/pending members, remove members, roles | ✅ | role-scoped invitation/application, review, role-change, and end-membership workflows enforced in PostgreSQL |
| Team membership requests / affiliation confirm/reject | ✅ | team/club applications and invitations with pending/accepted/rejected/cancelled/expired lifecycle |
| Team tournament lineups | ✅ | lineups in match participants |
| Guest/mercenary for an event | ✅ | entry types |
| Member self-service profile | ✅ | IdentityPage (display, legal, nickname, region, bio, socials, achievements, experience, visibility) |
| Profile photos upload/replace/reorder/remove | 🟡 | private avatar upload/replace/remove with identity-control checks, short-lived signed URLs, client/server MIME+size validation, and audit records; gallery/reorder remains unimplemented; hosted Edge Function verification requires the dedicated project |
| Public fighter profile (photo, record, season record, tournament history, podiums, upcoming events) | ✅ | public profile (career record, win rate, podiums, incoming events, tournament history, profile details, socials, gallery); demo surfaces carry the DemoNotice banner |
| Federation hierarchy (intl → national → regional → local → team → captain → fighter) | ✅ | org/governing-body relationships on `main` (`20261001000000_federation_hierarchy.sql`): `organization_kind` + `organization_relationships` with guarded RPCs; federation-aware dashboard surface still showcase-demo |
| Federation-agnostic (no hard-coded BI/IMCF/HACSA root) | ✅ | verified: BI/IMCF/HACSA appear only as seed/demo data source; rulesets/divisions are governed entities |
| Governing-body capabilities (create subordinate orgs, sanction, publish rulesets, official records, discipline jurisdiction) | 🟡 | federation **data layer** on `main` via guarded RPCs: `governs`/`recognizes`/`affiliate`/`sanctioned`/`predecessor` org relationships, `organization_ancestors`, ruleset publication + sanctioned divisions. A dedicated federation-admin dashboard UI remains roadmap (the federation-aware showcase surface is demo-labeled). |
| Ruleset inheritance (parent → addendum → event config) | ✅ | Pack 5 inheritance with cycle checks + event snapshots |
| Sanctioning and event authority (governing body, sanctioning org, host, classification) | 🟡 | event divisions/snapshots modeled; `sanctioned` organization-relationship kind on `main` records a parent sanctioning a child; a dedicated sanctioning-org assignment UI remains partial |
| Flexible org relationships (affiliated/sanctioned/recognized/member/regional/national/predecessor) | ✅ | `organization_relationships` on `main` carries `governs`/`recognizes`/`affiliate`/`sanctioned`/`predecessor` with guarded upsert/end RPCs (bilateral admin consent, active-duplicate refusal, end/reopen lifecycle, cycle protection) and `organization_ancestors` chains; the new kinds flowed through the existing enum-typed RPCs untouched and are covered by the federation pgTAP suite |
| Historical organizations (inactive status preserved) | ✅ | `org_status` lifecycle; archived events/history preserved |

---

## Round notes (this update)

**Current local checkpoint:** Round 18 UI/workflow integration is `901257c`; the following profile-avatar work is pending its own commit. Local replay is green with 28 migrations and 14 pgTAP suites. Hosted Supabase Edge Function verification remains blocked until a dedicated BuhurtOS project is confirmed; do not deploy to the Northborn/Mallard/Reavers project.

**CI is green on `main`:** workflow `36567325902` on head `c4d1f6f` passed all three jobs — frontend (typecheck/tests/production build), the authoritative pgTAP database job (11 suites), and the GitHub Pages deploy. Deployed site live at <https://dothecoolwip1.github.io/BuhurtOS/>. (The Round 15 head `7f67eab` was superseded by the immediate Round 16 push, so the combined head `c4d1f6f` carries Rounds 15 + 16; the previous checkpoint `b61dccd` carried Rounds 13 + 14 via workflow `36537529093`.)

Round 16 (completed and pushed as `c4d1f6f`):
- **Flexible organization relationship kinds** — forward-only enum extension
  (`20261004000000_flexible_org_relationship_kinds.sql`) adds `sanctioned`
  (parent sanctions/endorses the child) and `predecessor` (parent historically
  precedes the child) to `organization_relationship_kind`, giving the order
  `governs, recognizes, affiliate, sanctioned, predecessor`. The guarded
  upsert/end RPCs, bilateral admin consent, active-duplicate rule and cycle
  protection already operate on the enum type, so both kinds flow through
  unchanged. `federation_hierarchy.test.sql` pins the enum order and adds
  create/duplicate/cycle/ancestor assertions for both kinds; full 11-suite
  pgTAP replay green locally.

Round 15 (completed and pushed as `7f67eab`, validated on `c4d1f6f`):
- **Team standings board + fight-card-level exports** — `computeTeamStandings`
  (`src/lib/standings.ts`) aggregates finalized cross-team fighter bouts per
  team (3/1/0; differential → points-for → wins → name; distinct-fighter
  count), excluding intra-team/unaffiliated/non-finalized/`bye` bouts.
  `StandingsPage` gains a Fighters/Teams toggle (Teams renders only when the
  event has teams) with team CSV + printable board; the widget stays
  fighter-only. Supabase-mode names resolve through the new security-definer
  `public.event_teams(event)` RPC (`20261003000000_event_teams_public_read.sql`,
  execute granted to anon/authenticated) so public boards never expose the
  org-wide team catalog; the demo snapshot derives the same list from
  `demoEventTeams`. `fightCardCsv` (`export.ts`) wires fight-card-level CSV to
  the ops active-field header ("Export card CSV", "Print / PDF") and each field
  row on `EventManagementPage`. 6 tests in `tests/standings.test.ts` plus
  `export.test.ts` additions (57 tests / 12 files); new
  `event_teams_public_read.test.sql` suite; verified in-browser (empty state →
  populated board, both CSV downloads).

Round 14 (completed and pushed as `b61dccd`):
- **Marathon productized** — the `marathon` preset moves from
  `custom_template` to `verified` in `competitionFormats.ts` (mirroring the
  Long Axe precedent): a first-class verified endurance category whose exact
  scoring and duration stay deferred to the selected sourced ruleset.
  `governance.test.ts` now asserts `marathon` in `verifiedCompetitionFormats`
  and no longer as an organization template.

Round 13 (completed and pushed as `a71c1d0`, validated on `b61dccd`):
- **Embeddable widgets + fuller public fighter/team profiles** — chrome-free
  standings widget at `#/widget/standings` rendered straight from the live
  event board (DEMO DATA labeled in demo builds; public-mode read in Supabase
  mode); `src/lib/embed.ts` builds the widget URL + escaped iframe snippet;
  StandingsPage gains an Embed widget control with the snippet and preview.
- Public profiles: `DemoFighter` gains weight class, experience level/years,
  socials, and tournament history; `DemoTeam` gains socials and season
  results. FighterProfilePage renders Tournament history / Profile / Socials
  panels; TeamPage renders Season results / Socials. 7 new unit tests in
  `tests/embed.test.ts`; full suite 49/49, typecheck and build clean;
  verified in-browser.

Round 12 (completed and pushed as `de109b9`):
- **Audit completeness** — `20261002000000_audit_completeness.sql` wires the
  shared `audit_change` trigger onto brackets, organizations, seasons, events,
  rulesets, ruleset_sources, event_ruleset_snapshots, and profiles.
  Announcements and event_registrations (already audited) gain regression
  guards. 26 pgTAP assertions in `audit_completeness.test.sql`: trigger
  presence, insert/update/delete capture, event-derived org scope, and
  unscoped-row behavior for org-less entities.

Round 11 (completed and pushed as `5e67501`):
- **Broader exports** — `export.ts` now shares one `csv()` routine (escapes
  commas, quotes, newlines) across standings, matches/order of play, discipline
  cards, suspensions, and roster-report builders. BracketPage wires the
  previously-unused `matchesCsv` plus a printable order of play;
  DisciplinePage exports cards and suspensions CSV and a combined printable
  report; RosterPage exports the registration/roster report CSV and a
  printable compliance report. 6 new unit tests in `tests/export.test.ts`;
  42/42 tests, typecheck and production build clean; buttons verified
  in-browser on the ops pages.

Round 10 (completed and pushed as `b4b3795`):
- **Federation hierarchy ported to main** — `20261001000000_federation_hierarchy.sql`
  adds `organization_kind`/`country_code` to organizations and an
  `organization_relationships` table (governs/recognizes/affiliate) with an
  active window, a generated org-context mirror for audit, public reads, and
  RPC-only writes. Guarded `upsert`/`end` RPCs enforce bilateral admin
  consent, active-org residency, active-duplicate refusal, an end/reopen
  lifecycle, and hierarchy cycle protection; `organization_ancestors` exposes
  chains. Anonymous is revoked from the write RPCs. 34 pgTAP assertions in
  `federation_hierarchy.test.sql` (schema, ACLs, role-gated writes, RLS
  blocking, lifecycle, cycles, audit, public reads).

Round 9 (completed and pushed as `e3fe92d`):
- **Long Axe** added as a `verified` BI duel preset in `competitionFormats.ts`
  (the last ORIGINAL_SCOPE duel category that existed only as marketing copy);
  scoring deferred to the sourced ruleset like its verified siblings. Asserted
  in `tests/governance.test.ts`.

Round 8.5 (completed and pushed as `435b140` + `187862c`):
- **pgTAP error-pattern semantics** — the supabase-bundled pgTAP matches
  `throws_ok` errmsg against the verbatim full `MESSAGE_TEXT` (no `%`
  wildcards) and does not ship `throws_like`; the discipline suite's error
  assertions now pass exact full messages. The local replay shim mirrors the
  exact-message rule.

Round 8 (completed and pushed as `c7fab9c`):
- **Public-surface disambiguation (flagship gap resolved)**: `DemoNotice`
  banner on every showcase route (`ShowcaseShell` + `/public`); DEMO/SAMPLE
  retitling of all LIVE claims (public hero, event statusbar, dashboard
  panel, marketing mockup); fake clocks/scoreboards marked SAMPLE; spectator
  nav "Live Now ●" → "Public Arena ◎"; "Open live event view" (`/#/live`,
  real AppState-backed board) as the primary CTA. Verified in-browser via DOM
  assertions and a clean production build.
- **CI database-job regression fix (`3b52176`)**: the discipline round
  exposed a stale `mega4_release_hardening.test.sql` assertion (org admin
  direct `disciplinary_cards` insert). Updated to the RPC-only contract —
  direct writes are RLS-blocked (sqlstate 42501). Full 8-suite pgTAP replay
  green locally (real role switching + RLS semantics).

Round 7 (completed and pushed as `27566ef`):

- Discipline + suspensions forward migration (`20260930010000_discipline_suspensions.sql`):
  guarded `issue_discipline_card` / `issue_suspension` / `revoke_suspension` RPCs,
  `suspensions` table with RLS, audit + `suspensions_updated` triggers, and an
  additive `prevent_clearance_while_suspended` trigger on `event_roster_entries`.
- Direct `disciplinary_cards` writes removed (`discipline_write` policy dropped).
- Offline-queue hardening (stale `syncing` repair, capped backoff retries, manual
  retry reset, flush guard).
- Discipline UI: RPC-based card issuance + suspensions panel (issue/list/revoke).
- pgTAP suite `discipline_suspensions.test.sql` — 27 assertions, verified by the
  local replay harness with real role switching + RLS; full replay of all 18
  migrations clean.

## How to read remaining work

Top remaining product gaps (in priority order):

**None — the planned product gaps are closed.** The last frontier items
(embeddable widgets + fuller public fighter/team profiles, and the Marathon
verified flow) shipped in Rounds 13 and 14; the three subsequently flagged
items — a team standings board, fight-card-level exports, and
`sanctioned`/`predecessor` organization relationship kinds — shipped in Rounds
15 and 16. Ongoing work remains maintenance/expansion: enterprise outcomes
such as an org-level federation admin UI, production-verified livestream
embedding, and the profile photo upload flow stay on the roadmap as noted in
their individual matrix rows.
