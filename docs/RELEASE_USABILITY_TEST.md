# Release usability acceptance test

Goal: a person with **no prior BuhurtOS knowledge**, with no instructions, can discover BI and HACSA, find Red Deer Reavers,
find Red Deer Rumble and its poster, understand how registration works, and reach a next action from every dead end.

Two parts. **Part A** is a scripted walkthrough I ran in a real browser against the production backend (read-only, public
pages only). **Part B** needs a real newcomer and a signed-in account; I cannot do it, so it is written as a procedure.

## Part A: scripted walkthrough (2026-09-30)

Build: local production build pointed at the hosted backend (`tapfpboszgoftbwcwsmn`), phone width 360 px.

| # | Task a newcomer has | Result | Evidence |
|---|---|---|---|
| 1 | Discover BI and HACSA from the home page | Pass | Home leads with "Buhurt International" and "Historical Armored Combat Sports Association" cards; 3 data requests, none of them the worldwide directory |
| 2 | Find Red Deer Reavers | Pass | Teams opens on **Featured**; Red Deer Reavers is the first of 10 cards; `#/teams/red-deer-reavers` opens its page; no horizontal scroll, 0 tap targets under 36 px |
| 3 | Find Red Deer Rumble and see its poster | Pass | Events list card shows the poster (1164x1600 loaded, anchored to its top); event page hero loads at 360 px |
| 4 | Understand how registration works | Pass | "Fighter interest form" opens "Enter your event registration code." with who to ask, a code field, and "Have a BuhurtOS account? Sign in — if you belong to the host organization you may not need a code." |
| 5 | Recover from a dead end | Pass | A wrong code says "Code not recognized for this event", keeps the code field, and the dialog can be closed |
| 6 | Worldwide is reachable but secondary | Pass | "All worldwide teams" tab loads 354 teams on demand; searching from Featured finds a non-BI/HACSA team; a direct worldwide team URL opens |

Not covered by Part A (needs an account): the signed-in states of registration (eligible, permission request, pending,
denied), the organizer review queue, notifications, and the event setup guide against the real Rumble. Those are covered by
pgTAP (server decisions), unit tests (copy, checklist logic with the Rumble's real facts) and demo-mode checks only.

## Part B: for the owner, with a real newcomer (about 15 minutes)

Give someone who has never seen BuhurtOS a phone and say only: "Find out whether you could fight at the Red Deer Rumble."
Do not help. Watch, and write down where they hesitate.

1. Do they reach the event without asking where to click? (Expected: via Home "Show me real events" or Events.)
2. Do they understand from the page what they would need to register? (Expected: a signup code, or an account that may not need one.)
3. Signed out with no code: do they know what to do next? (Expected: ask the organizers, or sign in.)
4. Signed in as a Reavers fighter **after** you set the event's registration access to "Organization and its teams and clubs"
   in Fighter signups: do they reach the form with no code? If their fighter profile is not linked to a team membership,
   do they get "Request permission"?
5. As organizer, open Fighter signups: does the request appear, and did you get a notification bell count?
6. As organizer, open **Event setup guide** for Red Deer Rumble: does it say 3 of 9 complete and lead you to Registration?

Failures are fixed, not documented away. Record the date, the device and the person's exact words at each hesitation.
