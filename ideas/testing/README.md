# BuhurtOS UI mock-up (ideas/testing)

A clickable, front-end-only design mock-up for the new BuhurtOS interface (see `docs/FRONTEND_REDESIGN_PLAN.md`).
Nothing here talks to Supabase. **Every team, fighter, event, score and rule text is invented sample data** and the page says so.

Open `index.html` in a browser. No build step, no install.

## What to look at
| Page | Address | What it shows |
| --- | --- | --- |
| Home | `#home` | Live fight card, the three fighting styles, upcoming events, standings, teams |
| Events | `#events` | Calendar filtered by format, with tier and format chips |
| Event hub | `#event` | Live fields, Competitions (one event, many competitions), per-competition bracket / pools / profight card, schedule, entrants, info |
| Formats | `#formats` | Group fight, duels and profight: scoring zones, list sizes, weight classes, 10-point must; tournament tiers, structure advisor by entrant count, league points calculator, tiebreaks, cards, season |
| Teams | `#teams`, `#team` | Directory with generated heraldic crests; team page with roster and recent fights |
| Fighter | `#fighter` | Record by category, fight history with source labels |
| Rankings | `#rankings` | Category switcher, movement, points |
| Rules | `#rules` | Live search over paraphrased rules, filtered by format, each with document, version and section |
| Marshal | `#marshal` | Phone-first scoring for three formats: group fight (tap fighters out), duel (strike points, win by 2) and profight (10-point must) |

Light and dark themes (button in the top bar), phone bottom bar under 980px.

## Design direction
Heat-tempered steel: blued-steel and brass on cool steel greys, condensed display type (Big Shoulders Display), Instrument Sans
for text, IBM Plex Mono for scores and times. The signature is the temper band (straw > bronze > purple > blue, the colours
steel turns when heat-treated), used on the live card, active tabs and the hero headline.

## Where the content comes from
Teams, fighters, events, scores and rankings are invented sample data. The **rules, formats, tiers, scoring, weight classes,
points and tiebreaks** are taken from Buhurt International documents supplied by the owner (Buhurt Rules V.26.4.1, Duels rules
V.26.4, Outrance Rules and Regulations V.26.4, League Structure V2026.1, Tournament Structure and Formats Jan 2026,
Buhurt/Duels/Weapons Regulations tables of contents) and are paraphrased with the document and section on each item. This does
not imply endorsement by Buhurt International.

Known gaps and conflicts, kept visible in the mock-up:
* League Structure §2.3 (Regional 150%, Conference 200%) and §3.3.2 plus Tournament Structure §4.2 (x1.25, x1.5) disagree.
* The Regulations files were page images, so Buhurt Regulations §4 (round and match structure for group fights), weapon and
  shield charts and armour requirements were not read. They are not shown.
* The duel regulations list a Triathlon category with no rules in the files provided.
