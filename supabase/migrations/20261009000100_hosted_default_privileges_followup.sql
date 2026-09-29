-- Complete hosted default-privilege hardening for objects created by the
-- repository migration role (postgres).
--
-- PostgreSQL's built-in default EXECUTE for PUBLIC is global, so it must be
-- revoked without IN SCHEMA. Schema-specific revokes alone cannot override
-- that global default.

alter default privileges for role postgres in schema public
  revoke all privileges on tables from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke all privileges on sequences from anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  revoke all privileges on functions from anon, authenticated, service_role;

alter default privileges for role postgres
  revoke execute on functions from public;
