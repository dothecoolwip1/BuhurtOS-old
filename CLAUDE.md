# BuhurtOS — permanent project rules

Read first: `docs/PRODUCT_CONTEXT.md`, then `docs/BUHURTOS_STATUS.md`, `docs/BUHURTOS_HANDOFF.md`, `docs/COMPLETION_MATRIX.md`, `docs/NAVIGATION.md`.

- Stack: React + TypeScript + Vite, Supabase (Postgres, RLS). Hosted project `tapfpboszgoftbwcwsmn` ONLY.
- Permissions are enforced in the database (RLS / RPCs), never by hiding UI. New tables need RLS plus explicit grants; `supabase/tests/database/release_security_gate.test.sql` must stay green.
- Never delete worldwide/BI/HACSA team data. "Featured" is display priority only, never endorsement.
- Red Deer Reavers is a team, not an organization. Never invent rosters, records, rules or categories; cite sources.
- Release gate: `npm run typecheck`, `npx vitest run`, `npm run build`, `npm run audit:navigation`, CI green on the exact SHA.
- Hosted migrations are applied only after local replay passes, one at a time, with `list_migrations` evidence.
- Image transformations are NOT enabled on the hosted project; use original storage URLs.
