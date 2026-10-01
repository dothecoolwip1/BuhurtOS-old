# BuhurtOS Navigation and Information Architecture

Source of truth in code: `src/lib/navigation.ts` (every shell renders from it). Product intent: `docs/PRODUCT_CONTEXT.md`.

## Three connected areas

| Area | Who | Address | Shell |
| --- | --- | --- | --- |
| **Public site** | Anyone, no account | `#/public`, `#/teams`, `#/events` … | `ShowcaseShell` |
| **My workspace** | Any signed-in person | `#/me/…` | `WorkspaceShell` (`AppShell`) |
| **Administration** | People with a role to manage something | `#/admin/…` | `AdminShell` (`AppShell`) |

The top bar of every area has the same **area switcher** (Workspace and Administration appear only when they apply) and an
**account menu** (who you are, area links, sign out). On phones the switcher and every destination live in the menu sheet, with
a four-item bottom bar for everyday destinations. Each signed-in page shows a **breadcrumb** and an explicit **scope bar**
(Event / Organization / Platform / Personal) stating what a change will affect. Event pages add a numbered **workflow**
(Settings → Signups → Roster → Bracket → Run → Results).

## Public site

Discover · Teams · Events · Fighters · Rankings · Rules · Organizations. Secondary: "Put BuhurtOS on your website" (embed builder).
Filters live in the address bar, detail pages have breadcrumbs, and the list breadcrumb returns to the filters last used.

## My workspace (`#/me`)

| Page | Purpose |
| --- | --- |
| Home `/me` | Your roles in plain language (from the live role tables), with the link that matches each role |
| My fighter profile `/me/profile` | The real profile editor (formerly "My Fighter Identity") |
| My teams `/me/teams` | Teams/clubs you belong to and the tools your role allows; never assumes a team |
| Join with a code `/me/join` | Redeem an invitation or access code |

## Administration (`#/admin`) — visible entries depend on your roles

| Section | Pages |
| --- | --- |
| Overview | `/admin` needs-attention list (new signups, pending claims, unsynced device changes; failures shown as failures) and every tool you may use |
| Events & competition | Seasons & new events · Event settings · Fighter signups · Roster & check-in · Bracket & schedule · Run fights · Results & standings · Discipline · Fight notes · More tools: Bracket tools, All seasons & events |
| Organizations & teams | Organizations · Add teams & clubs (owner) · Teams, clubs & members (organization admins, team admins, captains, club admins) |
| People & access | Accounts & early access (owner) · Access codes · Invitations · Fighter identity review |
| Rules & structure | Rules reference · Rulesets · More tools: Fighters & divisions |
| Platform | Platform settings (owner) · More tools: Offline sync |

Menus hide what you cannot use; the database still enforces every permission. A page your role does not cover explains that in place.

## Where the old features went (old `/ops` links still work)

| Old | New | | Old | New |
| --- | --- | --- | --- | --- |
| `/ops/login` | `/sign-in` | | `/ops/identity` | `/me/profile` |
| `/ops` (Marshal Console) | `/admin/events/run` | | `/ops/access` | `/me/join` |
| `/ops/roster` | `/admin/events/roster` | | `/team-hq` | `/me/teams` |
| `/ops/bracket` | `/admin/events/bracket` | | `/ops/governance` | `/admin/organizations/manage` |
| `/ops/standings` | `/admin/events/results` | | `/ops/platform` (owner console) | `/admin`, `/admin/organizations`, `/admin/teams`, `/admin/events/all`, `/admin/settings` |
| `/ops/manage` | `/admin/events/manage` | | `/ops/access-admin` | `/admin/people/accounts` |
| `/ops/signups` | `/admin/events/signups` | | `/ops/codes` | `/admin/people/codes` |
| `/ops/admin` | `/admin/events/tools` | | `/ops/invite` | `/admin/people/invite` |
| `/ops/discipline` | `/admin/events/discipline` | | `/ops/identity-review` | `/admin/people/identity-review` |
| `/ops/notes` | `/admin/events/notes` | | `/ops/foundation` | `/admin/rules/divisions` |
| `/ops/setup` | `/admin/events/setup` | | `/ops/rulesets` | `/admin/rules/rulesets` |
| `/ops/marshal-reference` | `/admin/rules/reference` | | `/ops/sync` | `/admin/system/sync` |

Query strings (event ids, invitation tokens) are preserved. After signing in, a person lands on the page they asked for, otherwise on My workspace.

## What was removed

* The `/me` "profile preview" that showed a sample fighter with disabled inputs (it was fake content).
* The `/team-hq` redirect that sent everybody to the Red Deer Reavers page regardless of who they were.
* The owner/non-owner split sidebars and the flat list of ~18 jargon-named links.

## Verification log (2026-09-30)

Real browser, desktop and mobile. Public pages against the hosted backend (real data); signed-in areas in **demo mode** because
creating real accounts on the hosted project is not something automation should do. Demo mode shows the owner with sample data.

* Overflow and tap-target audit at 360, 390, 412, 768 and 1024px: public home, organizations, organization detail, teams, team detail,
  fighters, events, event detail, rankings, rules, sign-in, embed builder, and all 28 workspace/administration routes. Final run: no horizontal
  overflow and no controls under 36px (native checkboxes inside full-width tiles excepted).
* Mobile menu: opens, scrolls, closes on Escape / overlay / navigation, restores focus, locks background scroll, has a close button.
* Protected pages while signed out: `/admin`, `/me/teams`, old `/ops/manage?event=…`, old `/ops/invite?token=…` and `/team-hq` all reach sign-in
  and preserve the destination.
* Journey: teams filtered by country and region → open a team → breadcrumb returns to the same filtered list → browser back/forward behave.
* Journey: events list shows category and whether registration is open; the event page explains registration and TBA details; a bad signup code
  is refused with a clear message.

## Not verified (limits of this pass)

* Real signed-in sessions, sign-out then refresh, multi-role scope switching and permission-failure screens were exercised through unit tests
  (`tests/navigation.test.ts`: menu gating for owner, captain, organizer, marshal, anonymous) and demo mode only, not with real hosted accounts.
* Screenshots of signed-in pages (`docs/screenshots/*-demo.jpg`) show sample data.
* Fighter detail pages: the hosted project currently has no public BuhurtOS fighter identities, so the "open a fighter" step of that journey was
  covered only by the empty-state and code path.

## Update: owner tools (2026-09-30, after first real use)

* **Teams & rosters** (`/admin/teams`) lists every team you can see, with search and an organization filter; **Manage roster** (`/admin/teams/:id`) shows members, lets you invite (creates a link to send), change roles, remove people (history is kept), answer applications, and lists the public BI/HACSA roster for reference (those names are not accounts). Permissions are still enforced by the database functions.
* **Organizations** now lists all organizations at the top. **Create teams & clubs** moved to `/admin/teams/new` under More tools.
* Invitation links now open in My workspace (`/me/invite?token=…`); the page no longer needs a current event. Old links redirect.
* Role codes vs early access codes are explained on their pages; only a code's first characters are stored, so a lost code is disabled and re-created.
* Roles refresh immediately after redeeming a code, accepting an invitation or changing a roster (previously the workspace kept showing stale roles).
* Fighter photos: public pages request a short-lived signed URL from the `fighter-avatar` function, which no longer requires a gateway JWT for anonymous reads (uploads/removals still require the identity's owner).

## Update: role-aware navigation, notifications and the setup guide (2026-10-01)

* **Start here** leads My workspace and the Administration sidebar. Tasks come from `src/lib/journeys.ts`: one task per role in turn (platform owner,
  organization admin, event organizer, captain or team admin, marshal, fighter), most responsible first, at most six, no destination twice. A destination
  shown under Start here is not repeated lower in the sidebar, so one page never has two highlighted entries. Menus only reorder: the database still
  enforces access.
* **Phone bottom bar in My workspace** is chosen by role: Home, then My event (organizers) or My team (captains) or Events, then Profile, then Alerts.
* **Notifications** (`/me/notifications`) and a bell with an unread count in the account area. Requests and answers about registration access arrive here.
* **Event setup guide** (`/admin/events/guide?event=<id>`): nine steps with real progress for any event, new or existing; "could not check" is shown when a
  lookup fails, never "none"; tournament-only steps are skipped for non-tournaments. A two-step **New event** flow (Basics, then purpose) creates the draft
  and lands in the guide. Event settings links to the guide and accepts `?tab=competitions`.
* **Teams** opens on Featured; tabs for Buhurt International, HACSA and All worldwide teams; the full directory loads only for those tabs or a search.
  `/teams/<old-slug>` redirects to the canonical team when the team was reconciled as a duplicate.
* **Rules** search also returns tournament reference material (tier requirements, structure guidance, tiebreak order, official documents) in a separate group,
  each result labeled with its kind, source and version.

## Update: one event workspace (2026-10-01, `aafe1fc`)

* Inside any event page (`/admin/events/*` except new events and all-events), a single **event header** shows the event, date, venue, public or draft state,
  registration state, setup progress ("Setup 3 of 9"), the next setup step, and **View public page**. Tabs under it: Overview (setup guide), Details,
  Registration, Roster, Schedule, Run fights, Results, and More (discipline, notes, build tournament). The sidebar no longer repeats those tools while
  you are inside an event. The event picker is "Change event" in the header. Component: `src/components/EventHeader.tsx`.
* Public navigation is six items: Home, Teams, Events, Fighters, Rankings, Rules. Organizations moved to the menu's secondary links.
* "Manage event" on the public event page appears only for people who can manage that event (it was shown to every signed-in visitor).
* Label changes: Event setup guide to Event overview, Event settings to Event details, Fighter signups to Registration, My fighter profile to My profile;
  sections are Events, Teams & organizations, People & access, Rules.
* Verified: typecheck, 346 tests, build, navigation audit, CI green, live site shows the six-item public navigation. The event header was exercised in
  demo mode on desktop and at 390px (no horizontal overflow). **Not verified with a real signed-in session**: the setup progress pills and "Next" button
  need a connected backend and a signed-in account.

## Update: phone event workspace (2026-10-01)

Mobile changes (verified in the demo build at 390px by DOM measurement and the browser; not yet with a real signed-in session):
* Inside an event the page opens with a compact sticky event bar (name, date, status chips, a 44px ⋯ menu holding View public page and Change event) instead of
  breadcrumbs plus a four-row header; the tab row is replaced by an event bottom bar: Overview, Signups, Roster, Run, Menu. Schedule, Results, Details and the
  rest are under Menu > "This event".
* **Run fights** leads with a Current fight panel (who is fighting, field, a 56px Enter score button, then On deck and In the hole). The old hero and strip
  are hidden on phones. The panel appears first on the screen; before the change, about 650px of header chrome came before any fight.
* **Scoring** uses 48px minus and plus controls per fighter with names above each score, and the dialog's actions stick to the bottom with safe-area padding.
* **Roster and check-in** rows collapse to a 92px summary (name, team, cleared state, "n/5 checks") and expand on tap; 16 entries went from 5,700px to about 2,100px.
* Not done in this pass: registration review rows, filter sheets, searchable pickers, bracket round navigation, destructive-action placement audit, keyboard
  testing, and widths 360, 375, 412, 430 and 768.
