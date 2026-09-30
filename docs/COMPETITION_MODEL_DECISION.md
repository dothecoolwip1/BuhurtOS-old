# Competition model decision (M4 prerequisite gate)

Date: 2026-09-30. Question: do `competition_divisions` / `event_divisions` / `brackets` already model BI's independent
"tournament within an event", or do we need a separate layer?

## Evidence (hosted project and migrations)

| Table | What it is | Key constraints |
|---|---|---|
| `competition_divisions` | A reusable, versioned, **organization-owned catalog entry**: slug, version, `supersedes_division_id`, weight/age/experience eligibility, `competition_format_id`, `team_size`, `ruleset_id` | unique `(coalesce(organization_id,0), slug, version)` |
| `event_divisions` | Link of one catalog division to one event, with `ruleset_id`, `registration_limit`, `is_registration_open`, snapshots | **`unique (event_id, division_id)`**, FK `division_id -> competition_divisions` |
| `brackets` | Generated bracket/pools for an event | `division_id -> competition_divisions` (the **catalog** row, not the event's row) |
| `event_registrations` | Entries | `event_division_id`, `division_id` |

Hosted data: 0 rows in `competition_divisions`, `event_divisions`, `brackets`, `matches`, `event_registrations`. No backfill is needed in production.

## What BI requires (League Structure v2026.1, Tournament Structure Jan 2026)

A BI **event** holds several **tournaments**, each with its own league (Buhurt / Duels / Outrance-Profights), tier (Exhibition,
Source, Classic with Division 1 / Division 2 / Open, Regional, Conference), category and gender classification, ranked or not,
entrant minimums and caps, lead-time/approval requirements, ruleset version, a selected structure (pools/round robin/bracket),
and its own results. The League Structure's own example: "Men's 5s can be Classic, while the Women's 5s can be Source" at one
event, or an Exhibition 5s plus a Women's Classic Longsword.

## Mismatches

1. **Tier and classification are per-event facts, not catalog facts.** The catalog division has no league, tier, classification
   or ranked flag. Putting them on `event_divisions` would work only if one catalog division appears once per event.
2. **`unique (event_id, division_id)` forbids two tournaments of the same category at one event** (for example Classic Division 1
   5v5 and Classic Division 2 5v5, or a men's and a women's 5v5 if the catalog does not split them). BI explicitly allows this.
3. **`brackets.division_id` points at the catalog**, so two competitions built on the same catalog division cannot be told apart.
4. `event_divisions` exists to manage **registration into a division**; it has no place for the format selection, organizer
   override, approval record or status lifecycle of a tournament.

## Decision

Introduce the smallest correct layer, `event_competitions`, and **do not overload "division"**:

* `event_competitions` = one tournament inside one event (league, tier, tier classification, classification, category, ranked,
  entrant cap, ruleset authority and document version, recorded format selection, external approval record, status).
* `event_divisions.competition_id` and `brackets.competition_id` are **nullable** links. Existing IDs, rows, RLS and flows are
  untouched; events that never use competitions behave exactly as before.
* `competition_divisions` stays what it is: a reusable eligibility/format catalog.
* Categories, tier requirements, structure templates, tiebreak policies and rule-document metadata become data
  (`competition_categories`, `ruleset_tier_requirements`, `tournament_format_templates`, `tiebreak_policies`,
  `rule_documents`), seeded only from the verified BI documents, so organizations can add their own without code changes.

## Source notes and open conflicts (do not hide them)

* League Structure gives tier point values of 50% / 100% / 150% / 200% (Source / Classic / Regional / Conference); Tournament
  Structure §4.2 gives multipliers 0.5 / 1 / 1.25 / 1.5. They disagree for Regional and Conference. Both are stored with their
  sources and `sources_disagree = true`; BuhurtOS does not pick one.
* Tournament Structure entrant ranges overlap at 6, 12, 16 and 20; both option sets are offered at those counts.
* Categories seeded are the ones BuhurtOS already treats as verified BI formats (3v3, 5v5, 12v12, Longsword, Sword & Buckler,
  Sword & Shield, Polearm, Long Axe, Outrance). Marathon is left out because the League Structure does not place it in a
  league. Gender/classification is chosen per competition, as the League Structure defines men's and women's requirements
  per category.
* Marshal, Regulations and Authenticity documents are Google Drive files that could not be read as text. They are recorded as
  source links with versions taken from the existing marshal reference where known; nothing from them is invented.
