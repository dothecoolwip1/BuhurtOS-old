# Release usability acceptance test

Goal: a person with **no prior BuhurtOS knowledge**, with no instructions, can discover BI and HACSA, find Red Deer Reavers,
find Red Deer Rumble and its poster, understand how registration works, reach the next action when access is unavailable,
and find a rule during an active fight.

Two parts. **Part A is automated and has been run.** **Part B is a human observation and has NOT been done**: it needs a real
newcomer and, for steps 4 to 6, accounts. Nothing in Part A should be read as a substitute for Part B.

## Part A: scripted walkthrough (re-run 2026-10-01 on the deployed site and the live backend)

| # | Task a newcomer has | Result | Evidence |
|---|---|---|---|
| 1 | Discover BI and HACSA from the home page | Pass | Home leads with the "Buhurt International" and "Historical Armored Combat Sports Association" cards; 3 data requests, none the worldwide directory |
| 2 | Find Red Deer Reavers | Pass | Teams opens on **Featured** with Red Deer Reavers first of 10; its page opens; the old address `/teams/reavers` now redirects to it (production) |
| 3 | Find Red Deer Rumble and see its poster | Pass | Events card and event page show the poster (1164x1600 loaded) at 360 px; text alternative is the fallback "Red Deer Rumble poster" until an organizer writes one |
| 4 | Understand how registration works | Pass (signed out) | "Fighter interest form" opens "Enter your event registration code.", says who to ask, has a code field, and offers a **Sign in button** (previously an inline link under 24 px tall) explaining a host-organization member may not need a code |
| 5 | Recover from a dead end | Pass | A wrong code says "Code not recognized for this event", keeps the field, and the dialog closes |
| 6 | Worldwide is reachable but secondary | Pass | "All worldwide teams" loads 354 on demand; searching from Featured finds a non-BI/HACSA team; a direct worldwide team URL opens |
| 7 | Find a rule or tournament requirement | Pass | Rules search: fight rules (indexed sections) plus a separate "NOT FIGHT RULES" group for tier requirements, structure guidance, tiebreak order and official documents, each labeled with source and version. Quick searches added: classic, pools, tiebreak |

### Responsive and touch checks (real browser)

Widths 360, 390, 412, 768 and desktop. Public routes (sign-in, home, teams, team, events, Rumble, rules x2, registration dialog) and signed-in routes in
demo mode (My workspace, notifications, My teams, Administration, setup guide, competitions tab, signups, new event, bracket, sign-in).

* No horizontal overflow on any route at any width; the registration dialog fits at 360 px with its close control reachable.
* Touch targets under 36 px found and fixed: breadcrumb links (16 px), the dialog's inline sign-in link (21 px, now a button), the registration-access
  dropdown (25 px), links inside empty-state text (21 px). Re-run against the final build: 360 px and 390 px (11 signed-in and sign-in routes each), 412 px and
  768 px (9 routes each), desktop (10 routes, flagging anything under 28 px) all report no overflow and no small targets. Inline links inside long
  paragraphs (an email address, "Source ↗") are left as text links.
* Visual finding fixed: the sidebar highlighted two entries for one page ("Set up my event" and "Event setup guide"); a destination under "Start here" is no
  longer listed twice. In demo mode the setup guide says it needs a connected backend instead of offering a retry that cannot work.

### Not covered by Part A (needs an account)

The signed-in states of the registration dialog (eligible, permission request, pending, denied, closed, already registered), the organizer review queue, the
notification bell and list, the setup guide against the real Rumble, and the competitions panel with real data. The server decisions behind them are covered by
35 scenarios on the real hosted schema (see `NOV1_READINESS.md`), pgTAP and unit tests, but **no one has clicked through them with a real session**.

## Part B: for the owner, with a real newcomer (about 15 minutes). NOT DONE.

Give someone who has never seen BuhurtOS a phone and say only: "Find out whether you could fight at the Red Deer Rumble."
Do not help. Watch, and write down where they hesitate.

1. Do they reach the event without asking where to click? (Expected: Home "Show me real events" or Events.)
2. Do they understand from the page what they would need to register? (Expected: a signup code, or an account that may not need one.)
3. Signed out with no code: do they know what to do next? (Expected: ask the organizers, or press Sign in.)
4. Signed in as a Reavers fighter **after** you set the event's access to "Organization and its teams and clubs" in Fighter signups: do they reach the form
   with no code? If their fighter profile is not linked to a team membership, do they get "Request permission"?
5. As organizer, open Fighter signups: does the request appear, and does the bell show a count?
6. As organizer, open **Event setup guide** for Red Deer Rumble: does it say 3 of 9 complete and lead you to Registration?
7. Ask them to find what a Classic tournament requires. Do they find it from Rules, and do they understand it is not a fight rule?

Failures are fixed, not documented away. Record the date, the device and the person's exact words at each hesitation.
