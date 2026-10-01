# BuhurtOS UI mock-up (ideas/testing)

A clickable, front-end-only design mock-up for the new BuhurtOS interface (see `docs/FRONTEND_REDESIGN_PLAN.md`).
Nothing here talks to Supabase. **Every team, fighter, event, score and rule text is invented sample data** and the page says so.

Open `index.html` in a browser. No build step, no install.

## What to look at
| Page | Address | What it shows |
| --- | --- | --- |
| Home | `#home` | Live fight card, upcoming events, standings, teams |
| Event hub | `#event` | Live fields (now / on deck / next), bracket, schedule, teams, info |
| Teams | `#teams`, `#team` | Directory with generated heraldic crests; team page with roster and recent fights |
| Fighter | `#fighter` | Record by category, fight history with source labels |
| Rankings | `#rankings` | Category switcher, movement, points |
| Rules | `#rules` | Live search with highlighted matches, section and version on every result |
| Marshal | `#marshal` | Phone-first scoring: tap fighters out, confirm the round |

Light and dark themes (button in the top bar), phone bottom bar under 980px.

## Design direction
Heat-tempered steel: blued-steel and brass on cool steel greys, condensed display type (Big Shoulders Display), Instrument Sans
for text, IBM Plex Mono for scores and times. The signature is the temper band (straw > bronze > purple > blue, the colours
steel turns when heat-treated), used on the live card, active tabs and the hero headline.
