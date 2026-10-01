# BuhurtOS Public Data Contract v1 and Embeds

GitHub Pages cannot serve literal `/api/v1` HTTP routes, so v1 is a **versioned service layer** in
`src/lib/publicApiV1.ts`. Every payload is an explicit whitelist DTO built from public read paths
only (public RPCs and published events). Raw table rows are never part of the contract, and
`resolveApiV1(path, query)` maps the conceptual routes below to the same service functions so a
real HTTP edge can adopt the contract unchanged later.

| Conceptual route | Service function | DTO |
| --- | --- | --- |
| `/api/v1/organizations` | `listOrganizations()` | `OrganizationDTO[]` |
| `/api/v1/teams/{slug}` | `getTeam(slug)` | `TeamDTO` |
| `/api/v1/teams/{slug}/stats` | `getTeamStats(slug)` | `TeamStatsDTO` (official record is `null` until finalized matches exist) |
| `/api/v1/events` | `listEvents(filters)` | `EventDTO[]` |
| `/api/v1/events/{id-or-slug}` | `getEvent(idOrSlug)` | `EventDTO` |
| `/api/v1/calendar` | `calendar(filters)` | `CalendarDTO` (`version: "v1"`) |

Privacy rules enforced by the mappers (and covered by `tests/pack8Embeds.test.ts`):

* Team DTOs never include contact email, contact URLs or map coordinates.
* Event DTOs expose only `facebook`, `website` and `livestream` links, and only when they are
  `http(s)` URLs. Other `public_links` keys (host team ids, internal flags, tokens) are dropped.
* `EventDTO.imageAlt` (additive, v1-compatible) carries the organizer-written poster description, or `<event name> poster` when none was written. It is present only when the event has a poster.
* Stats come from the canonical layer (`official_team_stats`): finalized, valid results only.

## Iframe embeds

Embeds are chrome-free public routes (no sign-in, public data only, responsive, light/dark/auto
theme, optional accent color, "Powered by BuhurtOS"). Base URL: `https://dothecoolwip1.github.io/BuhurtOS/`.

| Widget | URL |
| --- | --- |
| Upcoming events / agenda | `#/embed/events?org=HACSA&limit=10&theme=auto&accent=d9680c` (`when=past`, `category=`, `team=` also supported) |
| Team card and stats | `#/embed/team/{team-slug}` e.g. `red-deer-reavers` |
| Event card | `#/embed/event/{event-id-or-slug}` |
| Standings and results | `#/embed/standings/{event-id-or-slug}` (explicit event, independent of any selected event) |

Use the **Widgets** page (`#/embed-builder`) to pick a widget, preview it, and copy the iframe code.

## Calendar feed

Static hosting cannot serve a live `.ics` URL. The Events page offers **Add to calendar (.ics)**,
generated client-side from the same `EventDTO`s (`src/lib/ics.ts`). A subscribable feed needs an
HTTP edge (for example a Supabase Edge Function) that calls `calendar()` and `buildIcs()`.
