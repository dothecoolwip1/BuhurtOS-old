-- Pack 6: centralized platform configuration, adoption switches and claim-ready records.
-- Launch behavior is preserved by the defaults: public viewing stays open and
-- event creation keeps following the existing organization-administrator policy.

create table if not exists public.platform_settings (
  key text primary key,
  value jsonb not null,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.platform_settings enable row level security;
revoke all on public.platform_settings from anon, authenticated;
grant all on public.platform_settings to service_role;

drop policy if exists platform_settings_no_direct_client_access on public.platform_settings;
create policy platform_settings_no_direct_client_access
on public.platform_settings for all
to anon, authenticated
using (false) with check (false);

create or replace function private.platform_setting_is_valid(p_key text, p_value jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case p_key
    when 'account_registration_mode' then jsonb_typeof(p_value) = 'string' and (p_value #>> '{}') in ('disabled', 'invite_only', 'open')
    when 'event_creation_mode' then jsonb_typeof(p_value) = 'string' and (p_value #>> '{}') in ('platform_only', 'approved_organizers', 'organization_members', 'open')
    when 'organization_claims_enabled' then jsonb_typeof(p_value) = 'boolean'
    when 'team_claims_enabled' then jsonb_typeof(p_value) = 'boolean'
    when 'fighter_claims_enabled' then jsonb_typeof(p_value) = 'boolean'
    when 'event_claims_enabled' then jsonb_typeof(p_value) = 'boolean'
    else false
  end
$$;

insert into public.platform_settings(key, value) values
  ('account_registration_mode', '"open"'::jsonb),
  ('event_creation_mode', '"approved_organizers"'::jsonb),
  ('organization_claims_enabled', 'false'::jsonb),
  ('team_claims_enabled', 'false'::jsonb),
  ('fighter_claims_enabled', 'false'::jsonb),
  ('event_claims_enabled', 'false'::jsonb)
on conflict (key) do nothing;

-- One read path for every consumer. Contains no secrets, so anonymous viewers may read it.
create or replace function public.get_platform_config()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_object_agg(key, value), '{}'::jsonb) from public.platform_settings
$$;

create or replace function public.set_platform_setting(p_key text, p_value jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_old jsonb;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.is_platform_super_admin(v_actor) then
    raise exception 'Only platform super administrators can change platform settings';
  end if;
  if not private.platform_setting_is_valid(p_key, p_value) then
    raise exception 'Invalid platform setting';
  end if;

  select value into v_old from public.platform_settings where key = p_key;

  insert into public.platform_settings(key, value, updated_by, updated_at)
  values (p_key, p_value, v_actor, timezone('utc', now()))
  on conflict (key) do update
    set value = excluded.value, updated_by = excluded.updated_by, updated_at = excluded.updated_at;

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_actor, 'platform_settings', v_actor, 'set_platform_setting',
          jsonb_build_object('key', p_key, 'old', v_old, 'new', p_value));

  return public.get_platform_config();
end;
$$;

revoke all on function public.get_platform_config() from public;
revoke all on function public.set_platform_setting(text, jsonb) from public, anon;
grant execute on function public.get_platform_config() to anon, authenticated;
grant execute on function public.set_platform_setting(text, jsonb) to authenticated;

create or replace function private.platform_setting_text(p_key text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select value #>> '{}' from public.platform_settings where key = p_key
$$;

grant execute on function private.platform_setting_text(text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Event creation mode, enforced server-side.
-- platform_only narrows creation to platform super administrators. The wider
-- modes admit additional members through the additive policy below.
-- ---------------------------------------------------------------------------

create or replace function private.enforce_event_creation_mode()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  -- System contexts (migrations, service role) have no end-user identity.
  if v_actor is null then return new; end if;
  if coalesce(private.platform_setting_text('event_creation_mode'), 'approved_organizers') = 'platform_only'
     and not private.is_platform_super_admin(v_actor) then
    raise exception 'Event creation is currently limited to platform administrators';
  end if;
  return new;
end;
$$;

drop trigger if exists enforce_event_creation_mode on public.events;
create trigger enforce_event_creation_mode
  before insert on public.events
  for each row execute function private.enforce_event_creation_mode();

drop policy if exists events_insert_by_platform_mode on public.events;
create policy events_insert_by_platform_mode
on public.events for insert
to authenticated
with check (
  status = 'draft'
  and private.platform_setting_text('event_creation_mode') in ('organization_members', 'open')
  and exists (
    select 1 from public.organization_memberships om
    where om.organization_id = events.organization_id
      and om.user_id = (select auth.uid())
  )
);

-- ---------------------------------------------------------------------------
-- Claim-ready records: request and platform review only. Approval records the
-- decision; roles are still granted through the existing guarded role RPCs.
-- ---------------------------------------------------------------------------

do $$ begin
  create type public.claim_entity_type as enum ('organization', 'team', 'fighter', 'event');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.claim_request_status as enum ('pending', 'approved', 'rejected', 'withdrawn');
exception when duplicate_object then null; end $$;

create table if not exists public.claim_requests (
  id uuid primary key default gen_random_uuid(),
  entity_type public.claim_entity_type not null,
  entity_id uuid not null,
  requested_by uuid not null references auth.users(id) on delete cascade,
  message text not null default '',
  status public.claim_request_status not null default 'pending',
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (char_length(message) <= 2000)
);

create unique index if not exists claim_requests_pending_unique_idx
  on public.claim_requests(entity_type, entity_id, requested_by)
  where status = 'pending';
create index if not exists claim_requests_entity_idx on public.claim_requests(entity_type, entity_id);

alter table public.claim_requests enable row level security;
revoke all on public.claim_requests from anon, authenticated;
grant select on public.claim_requests to authenticated;
grant all on public.claim_requests to service_role;

drop policy if exists claim_requests_read on public.claim_requests;
create policy claim_requests_read
on public.claim_requests for select
to authenticated
using (requested_by = (select auth.uid()) or private.is_platform_super_admin((select auth.uid())));

create or replace function public.submit_claim_request(p_entity_type public.claim_entity_type, p_entity_id uuid, p_message text default '')
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_enabled boolean;
  v_exists boolean;
  v_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;

  select coalesce((value #>> '{}')::boolean, false) into v_enabled
  from public.platform_settings
  where key = p_entity_type::text || '_claims_enabled';
  if not coalesce(v_enabled, false) then
    raise exception 'Claims are not enabled for this kind of record';
  end if;

  v_exists := case p_entity_type
    when 'organization' then exists (select 1 from public.organizations where id = p_entity_id)
    when 'team' then exists (select 1 from public.teams where id = p_entity_id)
    when 'fighter' then exists (select 1 from public.fighter_identities where id = p_entity_id)
    when 'event' then exists (select 1 from public.events where id = p_entity_id)
  end;
  if not coalesce(v_exists, false) then raise exception 'Record not found'; end if;

  insert into public.claim_requests(entity_type, entity_id, requested_by, message)
  values (p_entity_type, p_entity_id, v_actor, left(coalesce(p_message, ''), 2000))
  returning id into v_id;

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_actor, 'claim_requests', v_id, 'submit_claim_request',
          jsonb_build_object('entityType', p_entity_type, 'entityId', p_entity_id));
  return v_id;
end;
$$;

create or replace function public.withdraw_claim_request(p_claim uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  update public.claim_requests
     set status = 'withdrawn', updated_at = timezone('utc', now())
   where id = p_claim and requested_by = v_actor and status = 'pending';
  if not found then raise exception 'No pending claim request to withdraw'; end if;
end;
$$;

create or replace function public.review_claim_request(p_claim uuid, p_decision text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.is_platform_super_admin(v_actor) then
    raise exception 'Only platform super administrators can review claims';
  end if;
  if p_decision not in ('approved', 'rejected') then
    raise exception 'Decision must be approved or rejected';
  end if;

  update public.claim_requests
     set status = p_decision::public.claim_request_status,
         reviewed_by = v_actor,
         reviewed_at = timezone('utc', now()),
         review_note = nullif(trim(coalesce(p_note, '')), ''),
         updated_at = timezone('utc', now())
   where id = p_claim and status = 'pending';
  if not found then raise exception 'No pending claim request found'; end if;

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_actor, 'claim_requests', p_claim, 'review_claim_request', jsonb_build_object('decision', p_decision));
end;
$$;

revoke all on function public.submit_claim_request(public.claim_entity_type, uuid, text) from public, anon;
revoke all on function public.withdraw_claim_request(uuid) from public, anon;
revoke all on function public.review_claim_request(uuid, text, text) from public, anon;
grant execute on function public.submit_claim_request(public.claim_entity_type, uuid, text) to authenticated;
grant execute on function public.withdraw_claim_request(uuid) to authenticated;
grant execute on function public.review_claim_request(uuid, text, text) to authenticated;
