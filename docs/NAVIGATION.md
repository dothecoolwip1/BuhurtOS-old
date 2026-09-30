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
