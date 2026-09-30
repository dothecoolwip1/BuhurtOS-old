# BuhurtOS November 1 readiness (checked 2026-09-30)

Measured against the acceptance test in `BUHURTOS_NOV1_RELEASE_BLUEPRINT.txt` section 37. "Verified" means I ran it, and the evidence column says how.
Code state: `22a2eff` (CI green: navigation audit, typecheck, 253 tests, build, clean database replay with pgTAP, deploy).

I cannot sign in to real accounts, so every signed-in scenario below needs a person to walk it once before the release. Steps are listed.

| Scenario | State | Evidence |
|---|---|---|
| A. Public visitor (home, organizations, teams, filters, Red Deer Reavers, fighters, events, Rumble, rankings, rules) | Verified | A local build pointed at the production backend (read-only) loaded every page with no error or 404. `#/teams/red-deer-reavers` resolves by slug. Request counts per page: home 2, teams 1, team page 5, fighters 2, others 0 extra |
| B. Rumble fighter signup | Partly | Wrong code gives "Code not recognized for this event" on production. A valid code, the form and the confirmation are untested because **no signup codes exist yet** (0 codes, 0 signups) |
| C. Reavers/HACSA user reviews signups | Not verified | Needs a signed-in walk (steps below) |
| D. Platform super admin | Not verified | Needs a signed-in walk (steps below) |
| E. Non-competitive event | Code-level only | Unit tests show gatherings and meetings hide divisions, fight cards and standings. Not created on production |
| F. Embeds | Verified | `/embed/events`, `/embed/event/<id or slug>`, `/embed/team/red-deer-reavers`, `/embed/standings/<event>` render real data with "Powered by BuhurtOS" |
| G. Mobile 360 | Verified | 10 public routes at 360 px: no horizontal scroll. 375 px checked earlier. 390 and 412 not re-run |
| H. Performance | Mostly | Public pages make 0 to 5 data requests. Map still loads lazily. No full-directory load for detail pages |

## Data the owner needs to set (I have not changed production data)

1. **Red Deer Rumble is categorized "Custom".** It is a tournament, so set its category to Tournament in Event settings. Custom shows a generic label on the events list, embeds and event page.
2. **No poster.** Upload one in Event settings.
3. **Registration is closed** and the page says "Registration is not open". Decide when to open it.
4. **No divisions, schedule or announcements.** The page says "To be announced" for each, which is correct for unknown facts.
5. **Create the first signup code** (Fighter signups) so scenario B can be tested end to end.
6. **Supabase Auth: leaked-password protection is off.** This is a dashboard setting, and it may depend on the plan.

## Signed-in walk-through (about 20 minutes, use real accounts on production)

C. As a Reavers or HACSA member: open Rumble fighter signups, create a code, sign out, submit a signup with it on your phone, sign back in, accept or deny it. Confirm a different account without event access sees nothing.
D. As platform admin: Platform Control, then create a test organization, team and event, then create a role code and redeem it with a second account. Delete or archive the test records afterwards.
E. Create a "Gathering" event. Confirm it appears under Events with the right label and no bracket, standings or fight card sections.

## Security advisor review (hosted, 2026-09-30)

Nothing new to fix. The warnings are the intended public RPCs and row-level-secured tables being visible to GraphQL, plus two tables with row security on and no policy (`team_public_roster_sources`, `team_source_records`), which is deliberate: they are read only through the public functions. Do not revoke grants from this list without checking each one, since the public pages depend on them.

## Deferred on purpose (per the blueprint)

Static ICS subscription URLs (the site is static hosting; the event page offers a file download), Cloudflare migration, PostHog, Sentry, Capacitor, global search, QR codes.
