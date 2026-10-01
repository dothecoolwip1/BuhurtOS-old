# BuhurtOS Frontend Redesign Plan

Status: proposal for owner decision (2026-10-01). Nothing here is implemented.

## 1. Research and its limits

The three sites you named (`buhurt-ranking.com`, the Smoothcomp IMC bracket page, `armoredmma.com`) are **blocked by this
session's network proxy**, so I could not open them. What follows is from search-result snippets and Smoothcomp's public
knowledge base. Treat it as directional. Before design starts, someone should spend 30 minutes screenshotting those three
sites on a phone and a laptop and adding the screenshots to `docs/research/`.

| Reference | What it does well (from available evidence) | What to take |
| --- | --- | --- |
| **buhurt-ranking.com** | Entity-centric: separate `fighters`, `team_details`, `club_details`, `tournament_details` pages. Fighter profiles carry win rate, match history, team. Rankings by category (5v5 teams, Profight heavy/light, weapons). | The data model and the "every noun is a page, every page links to every related noun" pattern. Not the visual style. |
| **Smoothcomp** (IMC bracket page) | Brackets and schedule are one area. Mat view: divisions on the left, that mat's matches on the right. In the app you swipe between brackets; live countdowns to your next match; follow athletes and get notifications. | Mat/ring view, "my next fight", follow, swipe between brackets, schedule that updates live. This is the core spectator and competitor experience. |
| **armoredmma.com / AMMA app** | Promotion-style: fighter profiles, fight history, rankings, event pages, highlights, app for fans. Entertainment-first. | Hero-led fighter and event pages, strong imagery. Do not copy the pay-per-view/fan-rewards model. |
| **Challonge / start.gg** (search) | Easy bracket creation, but reviewers call mobile "functional but secondary" and cluttered. Mobile-first tools (Score7, Brakto) win on scoring on a phone. | Be mobile-first for scoring and bracket viewing; that is a real gap in the field. |

## 2. Diagnosis of the current UI

From the code and screenshots in `docs/screenshots/`:

* It is built around **our data structure**, not around what a person came to do. Seven top-level sections (Discover, Teams,
  Events, Fighters, Rankings, Rules, Organizations) plus a separate Workspace and a 28-route Administration area. Three shells.
* The public pages are dark panels with small uppercase labels ("PUBLIC TEAM PROFILE", "READ ONLY"), mostly text, no imagery,
  and many stat tiles showing `0` or `—` (Red Deer Reavers shows roster 0, rank —, points —, captain —). Empty data is the
  main thing visitors see, because the hosted project has little real data. A redesign cannot fix thin data; the design must
  make thin data look intentional (see section 6).
* The events page for a platform with one published event is a filter bar plus one card. Empty states carry the page.
* Admin is a long list of jargon-adjacent tools. The event workspace was already patched twice (header, then a phone bottom bar).
  That is the "stacked workarounds" CLAUDE.md warns about.
* Technical: hash routing (`#/…`), a 1,941-line single stylesheet, 191-line `App.tsx` route table, no component library, no design tokens beyond CSS.

I have not been able to see the live site myself in this session beyond three screenshots, so the above is a code and
screenshot read, not a user-tested finding.

## 3. Do we restart? Recommendation: new frontend, keep the backend and the logic

**Keep (do not rewrite):**
* Supabase schema, RLS, RPCs, edge functions, pgTAP gate. This is where the hard, correct work is, and CLAUDE.md requires it.
* The framework-free logic in `src/lib/` (bracket, standings, tiebreak, scoring, registration, permissions, friendlyError,
  eventMedia, journeys). About 35 files talk to Supabase and most of the rest is pure TypeScript with 346 unit tests.
  Move these into a `packages/core` (or keep `src/lib`) and the new UI imports them.

**Replace:** every file in `src/pages`, `src/components`, `src/styles.css`, the three shells, and the router.

**Language/framework: stay on TypeScript, change the framework.** You said I may change the development language. I
recommend against changing language: TypeScript is what lets the new UI share the 346 tested helpers and generated Supabase
types. The real choice is framework:

| Option | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| **A. Next.js (App Router) + React + Tailwind + shadcn/ui** | Real URLs and server rendering: shareable event/fighter/team links with proper previews (Discord, Facebook, iMessage) and SEO, which matters for a public sport directory. Largest ecosystem; shadcn gives accessible components fast. Can reuse all `src/lib`. | Needs a Node host (Vercel/Cloudflare) instead of GitHub Pages; more moving parts. | **Recommended** |
| B. Stay Vite SPA, adopt Tailwind + shadcn/ui, switch to browser router | Smallest change; keeps GitHub Pages hosting. | Still client-rendered: link previews and search indexing stay weak. | Fallback if hosting must stay static |
| C. SvelteKit / Astro | Lighter, nicer output. | Throws away React knowledge and any reuse of components; no real gain for this product. | No |
| D. Flutter / React Native app | Native feel, push notifications. | Large cost; the web covers the need. A PWA already exists. | Later, if at all |

Decision needed from you: **A or B** (hosting is the deciding factor).

## 4. New information architecture

Organize by the job the visitor has, not by table. Five top-level destinations, same on phone (bottom bar) and desktop (top bar):

1. **Home**: what's on now, what's next, search.
2. **Events**: list and calendar. Each event page is a hub (see 5).
3. **Fighters & Teams**: one directory with tabs and one search box (Fighters / Teams / Organizations); map view for teams.
4. **Rankings**: by category and ruleset, with source and "as of" date visible.
5. **Rules**: searchable, by ruleset and version.

Signed-in people get a **My BuhurtOS** button (not a separate shell): my next fight, my team, my signups, notifications.
Organizers and admins get a **Manage** button on the specific event/team/org they control. Management is a mode of the same
page (an edit rail on the object), not a 28-route second site. Permissions stay enforced by the database; the UI only offers
the entry points.

## 5. Key screens (build these first, in this order)

1. **Event hub**: one page with tabs *Overview · Schedule · Brackets · Fighters · Results · Rules · Stream*. Phone: swipe
   between brackets (Smoothcomp pattern). Ring/field view: current fight, on deck, in the hole. "Follow a fighter or team"
   and a live "my next fight" strip. Share links for each bracket.
2. **Bracket and schedule viewer** (the thing competitors and spectators actually open on the day): readable on a 360px phone,
   zoomable on a laptop, live updates through the existing realtime layer.
3. **Fighter profile**: hero header, team, record, match history, source attribution on every record. Imported vs. BuhurtOS
   facts labelled as the product rules require.
4. **Team page**: hero, roster, upcoming events, results, map location. Never shows a stat tile that is empty.
5. **Scorekeeper/marshal screen**: phone-first, large controls, offline-tolerant (reuse `offlineQueue`). Rebuild from the
   current Run fights panel.
6. **Event creation and registration admin**: one guided flow reusing the setup-guide logic.
7. Rankings, Rules, home, search, sign-in, workspace.

## 6. Design direction

* **Content first, chrome second.** Large type, one accent, generous space, photos and logos where we have them
  (original storage URLs only; image transformations are off). Light and dark themes via tokens.
* **No fake data and no zeros.** If we have no ranking, hide the tile or show one honest line ("No ranking published; source
  BI") with a link to contribute data. Thin data is the launch reality; design for it.
* Status always has text plus icon, never color alone. Visible focus. 44px touch targets. All of this is already a product
  rule; the design system encodes it once instead of per page.
* Design tokens + a small component set: Card, Tabs, Table, Badge, Sheet, Combobox, BracketView, MatchCard, EmptyState,
  FieldStatus. Document in a living `/design` page (Storybook optional).
* Remove jargon labels ("PUBLIC TEAM PROFILE", "READ ONLY").

## 7. Phased delivery

Release rules in CLAUDE.md still apply to every phase (typecheck, vitest, build, navigation audit, CI green on exact SHA).

| Phase | Output | Rough size |
| --- | --- | --- |
| 0. Decisions + research | Owner picks A/B; screenshots of the 3 reference sites; 3 to 5 people from the community shown a clickable mock | 2 to 3 days |
| 1. Design system and shell | Tokens, components, new layout, routing, `core` package extracted, new app deployed beside the old one (`/next`) | 1 week |
| 2. Public read paths | Home, Events + event hub, bracket viewer, fighters/teams, rankings, rules, search | 2 weeks |
| 3. Signed-in basics | Sign-in, My BuhurtOS, registration, notifications | 1 week |
| 4. Manage mode | Event setup, roster/check-in, scoring screen, results, team and org management | 2 to 3 weeks |
| 5. Cutover | Redirect old URLs, retire the old frontend, update docs | 2 to 3 days |

The Nov 1, 2026 proof release is about a month away. **Recommendation: do not cut over before Nov 1.** Ship the current app for
the Red Deer Rumble, and build the new frontend in parallel on `/next`, starting with the event hub and bracket viewer, which
could be used at the Rumble itself if ready. Rewriting everything first would put the release at risk.

## 8. Risks

* **Data is thin.** A better UI over an almost empty directory still feels empty. Importing real, sourced BI/HACSA results is
  as important as the redesign.
* Signed-in flows are still not verified against real accounts (see `BUHURTOS_STATUS.md`). Rebuilding them multiplies that gap.
  Fix: create two throwaway accounts so I can drive the UI end to end in the new build.
* Moving off GitHub Pages (option A) means a new deploy pipeline and CORS/auth redirect changes in Supabase.
* Scope: Manage mode is most of the existing 28 admin routes. Cut or merge pages rather than port them 1:1.

## 9. Questions for you

1. Option A (Next.js, needs Node hosting) or B (stay static)?
2. Is the main audience on the day of an event (competitors/spectators using phones) or the year-round directory/rankings?
   This sets what is built first; I assumed event day.
3. Anything on the three reference sites you specifically love or hate? I could not view them.
4. May I build the new frontend alongside the old one, with the old one staying live until Phase 5?
