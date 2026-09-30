# BuhurtOS Product Context

Permanent reference for anyone (human or AI) changing BuhurtOS. Read it with `BUHURTOS_STATUS.md`,
`BUHURTOS_HANDOFF.md` and `COMPLETION_MATRIX.md`. It describes intent; it is **not** a claim that every
capability exists. Always distinguish: planned, implemented, deployed, connected to the live backend, verified in use.

## What it is
A connected platform for organizing, participating in and following armored combat (buhurt). It must serve
experienced participants and stay understandable to someone who has never heard of the sport. It connects
organizations, clubs, teams, fighters, events, competition operations, results, rankings and rules, combining a public
discovery site with practical tools for the people who take part in and run the sport.

## Why
Information and administration are fragmented across websites, social media, chats, spreadsheets and separate
tournament tools. BuhurtOS reduces that fragmentation and administrative repetition, and must be useful to individual
teams and organizers **before** whole governing organizations adopt it.

## Who it serves
Public visitors/spectators; fighters; captains and team administrators; event organizers; marshals, scorekeepers and
officials; organization administrators; the platform owner. One person can hold several roles. Accounts are personal;
permissions are scoped to the organizations, teams and events someone is authorized to manage.

## Organizations, geography, governance
International scope. Buhurt International (BI) and HACSA are important initial sources and communities, not owners of
the platform. Never imply BI or HACSA endorsement, adoption or partnership. Support independent teams, other rulesets and
overlapping relationships. Example chain BI → HACSA → Red Deer Reavers → a fighter illustrates relationships, not a rigid
hierarchy; do not assert governance without evidence. **Red Deer Reavers is a team, never an organization.** Geography and
governance are separate; browsing by continent/country/province must not imply membership or verified governing bodies.

## Public information vs private control
Published teams, public rosters, sporting profiles, approximate locations, events, results, rankings and rules are
viewable without signing in; viewing never grants editing. A public fighter record or imported roster entry is not an
account; never create fake accounts. Publishing a team record does not mean the team joined or claimed BuhurtOS.
Authorization is enforced in the backend/database, not by hiding controls.

## Events are broader than tournaments
Tournaments, practices/training, demonstrations/exhibitions, clinics, gatherings/meetings, fundraisers/community events.
Show only the modules an event needs. Separate official results, imported external results, demonstrations and unverified
information; never blend them into misleading statistics.

## Sporting information and rules
Use real, traceable data; keep source attribution; distinguish imported facts from facts maintained in BuhurtOS. Never
invent rosters, records, locations, affiliations or rankings. Preserve source disagreements and support reconciliation.
Rules must be findable during competition by format and ruleset, with versions and sources clear.

## Direction
Organizations/clubs/teams; accounts vs public sporting identities; memberships and scoped permissions; geographic
discovery and team map; events, calendars, registration; tournament and officiating workflows; records, statistics,
rankings; searchable rules; public event/spectator views; embeds; delegated management and verified claims.
BuhurtOS must work before BI or HACSA adopts it. Initial access is owner-controlled through invitation codes; public
viewing stays open while editing/administration is controlled. Claims, invitations and codes must never let someone grant
themselves authority over an existing organization, team, event or person.

## Cost
Free until operating costs or features force otherwise; any charge would only cover maintenance/operation. Do not invent
subscriptions, premium tiers or monetization without an explicit owner decision.

## Project and release
Repository `dothecoolwip1/BuhurtOS`. Dedicated Supabase project `tapfpboszgoftbwcwsmn` **only** (never Northborn,
Mallard or other projects). Preserve working functionality and other contributors' work. The November 1, 2026 release is a
**proof release**: coherent, credible, useful, honest data; not the final form. Prioritize stability, clear navigation,
real data, complete workflows, mobile usability and security over disconnected features. A pack-numbered commit does not
prove the pack is complete.

## Experience principles (from the navigation redesign)
* Three connected areas: **Public site**, **My workspace** (`#/me`), **Administration** (`#/admin`).
* Organize around tasks, not tables or build order. Plain labels; no "Ops", "Foundation" or "Identity" jargon.
* Every page answers: where am I, what matters, what can I do next.
* Scope (which organization/team/event) is always visible and changes only explicitly.
* Mobile is primary: deliberate primary destinations, reliable menus, safe areas, no horizontal scrolling.
* Status never relies on color alone; visible focus; persistent labels.
* Loading failures are shown as failures, never as empty data.
