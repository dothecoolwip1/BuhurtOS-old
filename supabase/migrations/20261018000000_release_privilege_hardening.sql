-- Pack 10 release hardening, found by supabase/tests/database/release_security_gate.test.sql.
-- Row level security already blocked these paths over the Data API; this removes the table
-- privileges themselves so a future policy mistake cannot expose signup contact details or
-- let clients rewrite the audit trail (TRUNCATE is not subject to RLS at all).

-- Anonymous visitors never touch fighter signups directly; they use the validated signup RPCs.
revoke all on table public.fighter_event_signups from anon;

-- The audit log is append-only for clients: some guarded RPCs run as the caller and append their own
-- audit row (INSERT stays, gated by RLS), but no client may rewrite, delete or truncate history.
revoke insert on table public.audit_log from anon;
revoke update, delete, truncate, references, trigger on table public.audit_log from anon, authenticated;

-- No client role needs TRUNCATE, REFERENCES or TRIGGER on any public table, and anonymous
-- visitors never write directly. Sweep every ordinary table so new tables cannot regress this.
do $$
declare
  r record;
begin
  for r in
    select c.relname
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r'
  loop
    execute format('revoke truncate, references, trigger on table public.%I from anon, authenticated', r.relname);
    execute format('revoke insert, update, delete on table public.%I from anon', r.relname);
  end loop;
end $$;
