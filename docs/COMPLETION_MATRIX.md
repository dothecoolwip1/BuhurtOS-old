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
| Governing body / federation → org → season → event → fight card → pool/bracket → match | 🟡 | Org/season/event/card/pool/match on `main`; **federation layer only on branch** `pack4-organizations-clubs-teams` (org-parent relationships). Federation-agnostic data (rulesets/divisions sourced from BI/IMCF/HACSA as seed, never hard-coded root) is on `main` (Pack 5). |
| Teams, fighters, ghost/guest/mercenary | ✅ | `teams`, `fighters`, `event_roster_entries.entry_type`, ghost fighter creation in `AdminPage`/`FoundationPage` |
| Match participants, team lineups, rounds | ✅ | `match_participants`, `match_rounds`, team lineups |
| Discipline records + suspensions | ✅ | NEW this round: `disciplinary_cards` + `suspensions`, guarded RPCs, data-layer enforcement |
| Fight notes | ✅ | `NotesPage` + `notes` table + RLS |
| Announcements | ✅ | `EventManagementPage` create/list + `announcements` table |
| Registrations, waivers | ✅ | Pack 6 registration + waiver Upload/Storage |
| Payments | ⛔ | fail-closed; requires provider |
| Audit records | 🟡 | `audit_log`; gaps below |
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
| **Long Axe** | ❌ | absent from `competitionFormats.ts` (only marketing copy on `ShowcaseRulesPage`); add as sourced/verified format entry |
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
| **Marathon** | 🟡 | present as `custom_template` (endurance), not a built-in verified flow |

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
| Fighter + team profiles | 🟡 | public/private fighter profiles exist; team profile fields basic |
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
| Team and/or fighter standings per ruleset | 🟡 | fighter standings present; team-standings mode not fully surfaced |
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
| Read-only fighter/team/event info | 🟡 | public fighter profiles partial (identity public fields) |
| Shareable public links | ✅ | `share.ts` |
| Embeddable widgets | ❌ | not started |
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
| (Org/team admin panel) | 🟡 | only on branch `pack4-organizations-clubs-teams`, not merged |

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
| CSV exports | ✅ | `export.ts` (standings CSV; roster/card/registration CSV helpers) |
| PDF / printable reports | ❌ | not started (browser-print path only) |
| Event results / standings / rosters / fight cards / brackets / discipline exports | 🟡 | CSV available for standings; others partial |
| Registration/admin reports | ❌ | not started |
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
| Bracket creation/changes | ❌ | not audited |
| Discipline (cards + suspensions) | ✅ | NEW: `audit_change` trigger on both tables; suites verify |
| Registration decisions | ✅ | Pack 6 |
| Event membership/role changes | ✅ | Pack 2 |
| Announcements | ❌ | not audited |
| Important administrative changes | 🟡 | org/season/events/rulesets/profiles/registrations NOT yet audited (15 of 34 public tables have triggers) |

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
| Org-controlled team creation / captains / team administration | 🟡 | modeled (`teams`, memberships); full org→team admin UI only on branch `pack4-organizations-clubs-teams` |
| Captain invite existing members / no-account invites | 🟡 | existing-account assignment works (`invite-event-member`); no-account invite links not built |
| Captain temporary/pending members, remove members, roles | 🟡 | roster management partial |
| Team membership requests / affiliation confirm/reject | 🟡 | affiliation workflow exists; request flow partial |
| Team tournament lineups | ✅ | lineups in match participants |
| Guest/mercenary for an event | ✅ | entry types |
| Member self-service profile | ✅ | IdentityPage (display, legal, nickname, region, bio, socials, achievements, experience, visibility) |
| Profile photos upload/replace/reorder/remove | 🟡 | photo fields modeled; upload flow partial |
| Public fighter profile (photo, record, season record, tournament history, podiums, upcoming events) | 🟡 | identity public fields; career-record surface partial |
| Federation hierarchy (intl → national → regional → local → team → captain → fighter) | 🟡 | organizations are tenants; parent-org hierarchy only on branch `pack4-organizations-clubs-teams` |
| Federation-agnostic (no hard-coded BI/IMCF/HACSA root) | ✅ | verified: BI/IMCF/HACSA appear only as seed/demo data source; rulesets/divisions are governed entities |
| Governing-body capabilities (create subordinate orgs, sanction, publish rulesets, official records, discipline jurisdiction) | 🟡 | rulesets publication + sanctioned divisions exist; org-level federation admin only on branch |
| Ruleset inheritance (parent → addendum → event config) | ✅ | Pack 5 inheritance with cycle checks + event snapshots |
| Sanctioning and event authority (governing body, sanctioning org, host, classification) | 🟡 | event divisions/snapshots modeled; sanctioning-org UI partial |
| Flexible org relationships (affiliated/sanctioned/recognized/member/regional/national/predecessor) | ❌ | relationship table only on branch `pack4-organizations-clubs-teams` |
| Historical organizations (inactive status preserved) | ✅ | `org_status` lifecycle; archived events/history preserved |

---

## Round notes (this update)

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

1. **Federation hierarchy on main** — port org/governing-body relationships from
   branch `pack4-organizations-clubs-teams`.
2. **Long Axe** — add as a competition format in `competitionFormats.ts`.
3. **Broader exports** — PDF/printable + discipline/registration reports.
4. **Audit completeness** — add triggers for brackets, announcements,
   orgs/seasons/events/rulesets/profiles/registrations.
5. **Embeddable widgets + fuller public fighter/team profiles.**
6. **Marathon** — productize the custom template into a verified flow.