-- Complete hosted default-privilege hardening for both Supabase object
-- creation roles. Older projects can retain broad defaults for both postgres
-- and supabase_admin, including TRUNCATE/REFERENCES/TRIGGER on tables and
-- EXECUTE on functions.

alter default privileges for role postgres in schema public
  revoke all privileges on tables from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke all privileges on sequences from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke all privileges on functions from public, anon, authenticated, service_role;

alter default privileges for role supabase_admin in schema public
  revoke all privileges on tables from anon, authenticated, service_role;
alter default privileges for role supabase_admin in schema public
  revoke all privileges on sequences from anon, authenticated, service_role;
alter default privileges for role supabase_admin in schema public
  revoke all privileges on functions from public, anon, authenticated, service_role;
