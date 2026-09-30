-- Registration access: who may register for an event without a signup code, permission requests,
-- event-specific grants and in-app notifications.
--
-- Two separate authorities (kept separate on purpose):
--   * Signup-code ISSUANCE stays with private.can_manage_event_signups / can_participate_in_event_admin (unchanged),
--     so legitimate host-team and organization members can still hand out event codes.
--   * Permission-request APPROVAL is narrower: private.can_review_registration_access.
-- Eligibility is computed here, in one function, never in the client.

-- ---------------------------------------------------------------------------
-- Canonical host team: the events.host_team_id column first, then the legacy public_links key.
-- ---------------------------------------------------------------------------
create or replace function private.event_host_team(p_event uuid)
returns uuid
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    e.host_team_id,
    case when (e.public_links->>'host_team_id') ~* '^[0-9a-f-]{36}$' then (e.public_links->>'host_team_id')::uuid end
  )
  from public.events e
  where e.id = p_event;
$$;

-- Keep the existing helper name working; it now delegates to the canonical one.
create or replace function private.event_host_team_id(p_event_id uuid)
returns uuid
language sql stable security definer set search_path = ''
as $$ select private.event_host_team(p_event_id); $$;

-- ---------------------------------------------------------------------------
-- Event configuration
-- ---------------------------------------------------------------------------
alter table public.events
  add column if not exists registration_access_scope text not null default 'invite_only';

do $$ begin
  alter table public.events
    add constraint events_registration_access_scope_check
    check (registration_access_scope in ('invite_only','host_team','organization','organization_tree','open'));
exception when duplicate_object then null;
end $$;

comment on column public.events.registration_access_scope is
  'Who may register without a signup code: invite_only (code always), host_team, organization, organization_tree (organization and everything it governs), open (any signed-in fighter).';

grant select (registration_access_scope) on public.events to authenticated;

-- ---------------------------------------------------------------------------
-- Tables (no direct client access except reading one's own notifications)
-- ---------------------------------------------------------------------------
create table if not exists public.event_registration_access_requests (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  fighter_identity_id uuid references public.fighter_identities(id) on delete set null,
  team_id uuid references public.teams(id) on delete set null,
  organization_id uuid references public.organizations(id) on delete set null,
  reason text,
  status text not null default 'pending' check (status in ('pending','approved','denied','cancelled')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  review_notes text,
  eligibility_snapshot jsonb not null default '{}'::jsonb
);

create unique index if not exists event_registration_access_requests_one_pending
  on public.event_registration_access_requests(event_id, user_id) where status = 'pending';
create index if not exists event_registration_access_requests_event_idx
  on public.event_registration_access_requests(event_id, created_at desc);

-- Event-specific registration access. It grants nothing else: no membership, no role, no other event.
create table if not exists public.event_registration_access_grants (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  fighter_identity_id uuid references public.fighter_identities(id) on delete set null,
  request_id uuid references public.event_registration_access_requests(id) on delete set null,
  granted_by uuid references auth.users(id) on delete set null,
  granted_at timestamptz not null default now(),
  revoked_at timestamptz
);
create unique index if not exists event_registration_access_grants_one_active
  on public.event_registration_access_grants(event_id, user_id) where revoked_at is null;

create table if not exists public.app_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  link text,
  event_id uuid references public.events(id) on delete cascade,
  team_id uuid references public.teams(id) on delete set null,
  fighter_identity_id uuid references public.fighter_identities(id) on delete set null,
  request_id uuid references public.event_registration_access_requests(id) on delete cascade,
  dedupe_key text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index if not exists app_notifications_dedupe on public.app_notifications(user_id, dedupe_key) where dedupe_key is not null;
create index if not exists app_notifications_user_idx on public.app_notifications(user_id, created_at desc);

alter table public.event_registration_access_requests enable row level security;
alter table public.event_registration_access_grants enable row level security;
alter table public.app_notifications enable row level security;

revoke all on public.event_registration_access_requests from anon, authenticated;
revoke all on public.event_registration_access_grants from anon, authenticated;
revoke all on public.app_notifications from anon, authenticated;
grant all on public.event_registration_access_requests, public.event_registration_access_grants, public.app_notifications to service_role;
grant select on public.app_notifications to authenticated;

drop policy if exists event_registration_access_requests_no_direct on public.event_registration_access_requests;
create policy event_registration_access_requests_no_direct on public.event_registration_access_requests
  for all to anon, authenticated using (false) with check (false);
drop policy if exists event_registration_access_grants_no_direct on public.event_registration_access_grants;
create policy event_registration_access_grants_no_direct on public.event_registration_access_grants
  for all to anon, authenticated using (false) with check (false);
drop policy if exists app_notifications_read_own on public.app_notifications;
create policy app_notifications_read_own on public.app_notifications
  for select to authenticated using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Authorities
-- ---------------------------------------------------------------------------
-- Organizations that govern (or are) the event's organization.
create or replace function private.event_governing_organizations(p_event uuid)
returns table (organization_id uuid)
language sql stable security definer set search_path = ''
as $$
  with recursive g(id) as (
    select e.organization_id from public.events e where e.id = p_event
    union
    select r.parent_organization_id
      from public.organization_relationships r
      join g on g.id = r.child_organization_id
     where r.relationship_kind = 'governs' and r.ends_on is null
  )
  select id from g;
$$;

-- Approval authority: platform admin, organization admin (event organization or an ancestor), event organizer,
-- host-team admin or captain. Plain team members and organization staff may issue codes but cannot approve requests.
create or replace function private.can_review_registration_access(p_user uuid, p_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_user is not null and (
    private.is_platform_admin(p_user)
    or exists (
      select 1 from public.organization_memberships om
       where om.user_id = p_user and om.role = 'organization_admin'
         and om.organization_id in (select organization_id from private.event_governing_organizations(p_event))
    )
    or exists (
      select 1 from public.event_memberships em
       where em.event_id = p_event and em.user_id = p_user and em.role = 'event_organizer'
    )
    or exists (
      select 1 from public.team_memberships tm
       where tm.team_id = private.event_host_team(p_event) and tm.user_id = p_user
         and tm.role in ('team_admin','captain') and tm.ends_on is null
    )
  );
$$;

-- Changing who may register is a configuration decision: platform admin, organization admin or event organizer only.
create or replace function private.can_configure_event_registration(p_user uuid, p_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_user is not null and (
    private.is_platform_admin(p_user)
    or exists (
      select 1 from public.organization_memberships om
       where om.user_id = p_user and om.role = 'organization_admin'
         and om.organization_id in (select organization_id from private.event_governing_organizations(p_event))
    )
    or exists (
      select 1 from public.event_memberships em
       where em.event_id = p_event and em.user_id = p_user and em.role = 'event_organizer'
    )
  );
$$;

-- ---------------------------------------------------------------------------
-- Eligibility (the single definition of "registered fighter")
--   authenticated account -> linked fighter identity -> active membership/affiliation -> inside the event's scope
-- ---------------------------------------------------------------------------
create or replace function private.active_team_ids_for_identity(p_identity uuid, p_user uuid)
returns table (team_id uuid)
language sql stable security definer set search_path = ''
as $$
  select tm.team_id
    from public.team_memberships tm
   where p_identity is not null
     and (tm.user_id = p_user or tm.fighter_identity_id = p_identity)
     and tm.starts_on <= current_date
     and (tm.ends_on is null or tm.ends_on >= current_date)
  union
  select fa.team_id
    from public.fighter_affiliations fa
   where p_identity is not null
     and fa.identity_id = p_identity
     and fa.team_id is not null
     and fa.starts_on <= current_date
     and (fa.ends_on is null or fa.ends_on >= current_date);
$$;

create or replace function private.registration_eligibility(p_user uuid, p_event uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_event public.events%rowtype;
  v_identity uuid;
  v_team uuid;
  v_team_org uuid;
  v_request public.event_registration_access_requests%rowtype;
  v_has_membership boolean;
  v_scope text;
  function_result jsonb;
begin
  select * into v_event from public.events where id = p_event;
  if v_event.id is null then
    return jsonb_build_object('state', 'error', 'scope', null);
  end if;
  v_scope := v_event.registration_access_scope;

  if v_event.status not in ('published', 'live')
     or (v_event.registration_closes_at is not null and v_event.registration_closes_at < now()) then
    return jsonb_build_object('state', 'registration_closed', 'scope', v_scope);
  end if;

  if p_user is null then
    return jsonb_build_object('state', 'code_required', 'scope', v_scope);
  end if;

  if exists (
    select 1 from public.fighter_event_signups s
     where s.event_id = p_event and s.submitted_by_user_id = p_user and s.status not in ('archived', 'declined')
  ) then
    return jsonb_build_object('state', 'already_registered', 'scope', v_scope);
  end if;

  if exists (
    select 1 from public.event_registration_access_grants g
     where g.event_id = p_event and g.user_id = p_user and g.revoked_at is null
  ) then
    return jsonb_build_object('state', 'permission_granted', 'scope', v_scope);
  end if;

  v_identity := private.self_identity(p_user);

  -- First active team that sits inside the event's configured scope.
  select t.id, t.organization_id into v_team, v_team_org
    from public.teams t
   where t.deleted_at is null
     and t.id in (select a.team_id from private.active_team_ids_for_identity(v_identity, p_user) a)
     and (
       (v_scope = 'host_team' and t.id = private.event_host_team(p_event))
       or (v_scope = 'organization' and t.organization_id = v_event.organization_id)
       or (v_scope = 'organization_tree' and (
             t.organization_id = v_event.organization_id
             or private.organization_reaches(v_event.organization_id, t.organization_id)))
     )
   order by t.name
   limit 1;

  if v_team is not null then
    return jsonb_build_object('state', 'eligible', 'scope', v_scope, 'team_id', v_team, 'organization_id', v_team_org,
                              'fighter_identity_id', v_identity);
  end if;

  if v_scope = 'open' and v_identity is not null then
    return jsonb_build_object('state', 'eligible', 'scope', v_scope, 'fighter_identity_id', v_identity);
  end if;

  select * into v_request
    from public.event_registration_access_requests r
   where r.event_id = p_event and r.user_id = p_user
   order by (r.status = 'pending') desc, r.created_at desc
   limit 1;
  if v_request.id is not null and v_request.status = 'pending' then
    return jsonb_build_object('state', 'permission_requested', 'scope', v_scope, 'request_id', v_request.id);
  end if;
  if v_request.id is not null and v_request.status = 'denied' then
    return jsonb_build_object('state', 'denied', 'scope', v_scope, 'request_id', v_request.id);
  end if;

  if v_scope = 'invite_only' then
    return jsonb_build_object('state', 'code_required', 'scope', v_scope);
  end if;

  select exists (select 1 from private.active_team_ids_for_identity(v_identity, p_user)) into v_has_membership;
  if v_identity is null or not v_has_membership then
    return jsonb_build_object('state', 'membership_unverified', 'scope', v_scope, 'fighter_identity_id', v_identity);
  end if;

  return jsonb_build_object('state', 'code_required', 'scope', v_scope, 'fighter_identity_id', v_identity);
end;
$$;

-- ---------------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------------
create or replace function private.notify_user(
  p_user uuid, p_kind text, p_title text, p_body text, p_link text,
  p_event uuid, p_team uuid, p_identity uuid, p_request uuid, p_dedupe text
) returns void
language sql security definer set search_path = ''
as $$
  insert into public.app_notifications(user_id, kind, title, body, link, event_id, team_id, fighter_identity_id, request_id, dedupe_key)
  values (p_user, p_kind, p_title, p_body, p_link, p_event, p_team, p_identity, p_request, p_dedupe)
  on conflict (user_id, dedupe_key) where dedupe_key is not null do nothing;
$$;

-- Who is told about a request: organizers, host-team leaders and organization admins of the event chain.
-- Platform admins are told only when nobody else can act, to avoid noise.
create or replace function private.registration_request_recipients(p_event uuid, p_exclude uuid)
returns table (user_id uuid)
language sql stable security definer set search_path = ''
as $$
  with direct as (
    select em.user_id from public.event_memberships em where em.event_id = p_event and em.role = 'event_organizer'
    union
    select tm.user_id from public.team_memberships tm
     where tm.team_id = private.event_host_team(p_event) and tm.role in ('team_admin', 'captain') and tm.ends_on is null
    union
    select om.user_id from public.organization_memberships om
     where om.role = 'organization_admin'
       and om.organization_id in (select organization_id from private.event_governing_organizations(p_event))
  ), chosen as (
    select d.user_id from direct d where d.user_id <> p_exclude
  )
  select c.user_id from chosen c
  union
  select pm.user_id from public.platform_memberships pm
   where pm.role = 'platform_super_admin' and pm.user_id <> p_exclude
     and not exists (select 1 from chosen);
$$;

-- ---------------------------------------------------------------------------
-- RPC implementations
-- ---------------------------------------------------------------------------
create or replace function private.get_event_registration_access(p_event uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$ select private.registration_eligibility(auth.uid(), p_event); $$;

create or replace function private.request_event_registration_access(p_event uuid, p_reason text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_state jsonb;
  v_name text;
  v_event_name text;
  v_identity uuid;
  v_team uuid;
  v_org uuid;
  v_id uuid;
  v_recipient uuid;
begin
  if v_actor is null then raise exception 'Sign in to request access'; end if;
  if char_length(coalesce(p_reason, '')) > 1000 then raise exception 'Keep the reason under 1000 characters'; end if;

  v_state := private.registration_eligibility(v_actor, p_event);
  if v_state->>'state' in ('eligible', 'permission_granted', 'already_registered') then
    raise exception 'You can already register for this event';
  end if;
  if v_state->>'state' = 'registration_closed' then raise exception 'Registration is not open for this event'; end if;
  if v_state->>'state' = 'permission_requested' then return (v_state->>'request_id')::uuid; end if;
  if v_state->>'state' = 'error' then raise exception 'Event not found'; end if;

  v_identity := private.self_identity(v_actor);
  select t.id, t.organization_id into v_team, v_org
    from public.teams t
   where t.deleted_at is null and t.id in (select a.team_id from private.active_team_ids_for_identity(v_identity, v_actor) a)
   order by t.name limit 1;

  insert into public.event_registration_access_requests(event_id, user_id, fighter_identity_id, team_id, organization_id, reason, eligibility_snapshot)
  values (p_event, v_actor, v_identity, v_team, v_org, nullif(trim(p_reason), ''), v_state)
  on conflict (event_id, user_id) where status = 'pending' do nothing
  returning id into v_id;

  if v_id is null then
    select id into v_id from public.event_registration_access_requests
     where event_id = p_event and user_id = v_actor and status = 'pending';
    return v_id;
  end if;

  select e.name into v_event_name from public.events e where e.id = p_event;
  v_name := coalesce(private.profile_label(v_actor), 'A fighter');

  for v_recipient in select r.user_id from private.registration_request_recipients(p_event, v_actor) r loop
    perform private.notify_user(
      v_recipient, 'registration_access_request', 'Registration access request',
      v_name || ' wants to register for ' || coalesce(v_event_name, 'an event') || '.',
      '/admin/events/signups?event=' || p_event::text,
      p_event, v_team, v_identity, v_id, 'reg-request-' || v_id::text);
  end loop;

  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, p_event, 'event_registration_access_requests', v_id, 'request_event_registration_access',
          jsonb_build_object('teamId', v_team, 'state', v_state->>'state'));
  return v_id;
end;
$$;

create or replace function private.review_event_registration_access_request(p_request uuid, p_decision text, p_notes text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_req public.event_registration_access_requests%rowtype;
  v_event_name text;
begin
  if p_decision not in ('approved', 'denied') then raise exception 'Decision must be approved or denied'; end if;
  select * into v_req from public.event_registration_access_requests where id = p_request for update;
  if v_req.id is null then raise exception 'Request not found'; end if;
  if not private.can_review_registration_access(v_actor, v_req.event_id) then
    raise exception 'You are not allowed to review registration access for this event';
  end if;
  if v_req.status <> 'pending' then raise exception 'This request has already been reviewed'; end if;

  update public.event_registration_access_requests
     set status = p_decision, reviewed_at = now(), reviewed_by = v_actor, review_notes = nullif(trim(p_notes), '')
   where id = p_request;

  if p_decision = 'approved' then
    insert into public.event_registration_access_grants(event_id, user_id, fighter_identity_id, request_id, granted_by)
    values (v_req.event_id, v_req.user_id, v_req.fighter_identity_id, v_req.id, v_actor)
    on conflict (event_id, user_id) where revoked_at is null do nothing;
  end if;

  select e.name into v_event_name from public.events e where e.id = v_req.event_id;
  perform private.notify_user(
    v_req.user_id, 'registration_access_' || p_decision,
    case when p_decision = 'approved' then 'Registration access approved' else 'Registration access not approved' end,
    case when p_decision = 'approved'
         then 'You can now register for ' || coalesce(v_event_name, 'the event') || '.'
         else 'Your request for ' || coalesce(v_event_name, 'the event') || ' was not approved. You can still register with a signup code or contact the organizer.' end,
    '/events/' || v_req.event_id::text, v_req.event_id, v_req.team_id, v_req.fighter_identity_id, v_req.id,
    'reg-review-' || v_req.id::text);

  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, v_req.event_id, 'event_registration_access_requests', v_req.id, 'review_event_registration_access_request',
          jsonb_build_object('decision', p_decision));
end;
$$;

create or replace function private.list_event_registration_access_requests(p_event uuid)
returns table (
  id uuid, user_id uuid, fighter_name text, team_id uuid, team_name text, organization_name text, reason text, status text,
  created_at timestamptz, reviewed_at timestamptz, review_notes text, eligibility_snapshot jsonb
)
language sql stable security definer set search_path = ''
as $$
  select r.id, r.user_id, private.profile_label(r.user_id), r.team_id, t.name, o.name, r.reason, r.status,
         r.created_at, r.reviewed_at, r.review_notes, r.eligibility_snapshot
    from public.event_registration_access_requests r
    left join public.teams t on t.id = r.team_id
    left join public.organizations o on o.id = r.organization_id
   where r.event_id = p_event
     and private.can_review_registration_access(auth.uid(), p_event)
   order by (r.status = 'pending') desc, r.created_at desc;
$$;

create or replace function private.set_event_registration_access_scope(p_event uuid, p_scope text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if p_scope not in ('invite_only', 'host_team', 'organization', 'organization_tree', 'open') then
    raise exception 'Unknown registration access scope';
  end if;
  if not private.can_configure_event_registration(auth.uid(), p_event) then
    raise exception 'You are not allowed to change registration access for this event';
  end if;
  update public.events set registration_access_scope = p_scope where id = p_event;
  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (auth.uid(), p_event, 'events', p_event, 'set_event_registration_access_scope', jsonb_build_object('scope', p_scope));
end;
$$;

create or replace function private.list_my_notifications(p_limit integer)
returns setof public.app_notifications
language sql stable security definer set search_path = ''
as $$
  select n.* from public.app_notifications n
   where n.user_id = auth.uid()
   order by n.created_at desc
   limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;

create or replace function private.count_my_unread_notifications()
returns integer
language sql stable security definer set search_path = ''
as $$
  select count(*)::integer from public.app_notifications n where n.user_id = auth.uid() and n.read_at is null;
$$;

create or replace function private.mark_notification_read(p_id uuid)
returns void
language sql security definer set search_path = ''
as $$
  update public.app_notifications set read_at = coalesce(read_at, now()) where id = p_id and user_id = auth.uid();
$$;

create or replace function private.mark_all_notifications_read()
returns void
language sql security definer set search_path = ''
as $$
  update public.app_notifications set read_at = now() where user_id = auth.uid() and read_at is null;
$$;

-- Code-less signup: allowed only when the server says the caller is eligible or has been granted access.
-- The anonymous code path is unchanged.
create or replace function private.submit_event_fighter_signup(
  p_event uuid,p_code text,p_display_name text,p_email text,p_phone text default null,
  p_team_name text default null,p_experience_years numeric default null,
  p_fighting_categories text[] default '{}',p_armor_status text default null,
  p_attendance_notes text default null,p_emergency_contact text default null,
  p_additional_notes text default null,p_consent boolean default false
) returns uuid
language plpgsql security definer
set search_path=''
as $$
declare
  v_code public.event_signup_codes%rowtype;
  v_check jsonb;
  v_state text;
  v_id uuid;
begin
  if nullif(trim(coalesce(p_code, '')), '') is null then
    v_state := private.registration_eligibility(auth.uid(), p_event)->>'state';
    if v_state = 'already_registered' then raise exception 'You have already submitted a signup for this event'; end if;
    if v_state not in ('eligible', 'permission_granted') then
      raise exception 'A signup code is required for this event';
    end if;
  else
    v_check:=private.validate_event_signup_code(p_event,p_code);
    if coalesce((v_check->>'valid')::boolean,false) is false then
      raise exception '%',coalesce(v_check->>'message','Invalid signup code');
    end if;
    select * into v_code
    from public.event_signup_codes
    where event_id=p_event
      and code_hash=extensions.digest(upper(trim(p_code)),'sha256');
  end if;
  if not p_consent then raise exception 'Consent is required'; end if;
  if char_length(trim(coalesce(p_display_name,'')))<2 then raise exception 'Name is required'; end if;
  if char_length(trim(coalesce(p_email,'')))<3 then raise exception 'Email is required'; end if;

  insert into public.fighter_event_signups(
    event_id,signup_code_id,display_name,email,phone,team_name,experience_years,
    fighting_categories,armor_status,attendance_notes,emergency_contact,
    additional_notes,consent_acknowledged,submitted_by_user_id,status
  ) values (
    p_event,v_code.id,trim(p_display_name),lower(trim(p_email)),nullif(trim(p_phone),''),
    nullif(trim(p_team_name),''),p_experience_years,coalesce(p_fighting_categories,'{}'),
    nullif(trim(p_armor_status),''),nullif(trim(p_attendance_notes),''),
    nullif(trim(p_emergency_contact),''),nullif(trim(p_additional_notes),''),
    p_consent,auth.uid(),'new'
  ) returning id into v_id;

  return v_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants and public wrappers (authenticated only; the anonymous signup surface is unchanged)
-- ---------------------------------------------------------------------------
revoke all on function private.event_host_team(uuid) from public, anon, authenticated;
revoke all on function private.event_governing_organizations(uuid) from public, anon, authenticated;
revoke all on function private.can_review_registration_access(uuid, uuid) from public, anon, authenticated;
revoke all on function private.can_configure_event_registration(uuid, uuid) from public, anon, authenticated;
revoke all on function private.active_team_ids_for_identity(uuid, uuid) from public, anon, authenticated;
revoke all on function private.registration_eligibility(uuid, uuid) from public, anon, authenticated;
revoke all on function private.notify_user(uuid, text, text, text, text, uuid, uuid, uuid, uuid, text) from public, anon, authenticated;
revoke all on function private.registration_request_recipients(uuid, uuid) from public, anon, authenticated;

grant execute on function private.event_host_team(uuid) to authenticated;
grant execute on function private.event_governing_organizations(uuid) to authenticated;
grant execute on function private.can_review_registration_access(uuid, uuid) to authenticated;
grant execute on function private.can_configure_event_registration(uuid, uuid) to authenticated;
grant execute on function private.active_team_ids_for_identity(uuid, uuid) to authenticated;
grant execute on function private.registration_eligibility(uuid, uuid) to authenticated;

revoke all on function private.get_event_registration_access(uuid) from public, anon, authenticated;
revoke all on function private.request_event_registration_access(uuid, text) from public, anon, authenticated;
revoke all on function private.review_event_registration_access_request(uuid, text, text) from public, anon, authenticated;
revoke all on function private.list_event_registration_access_requests(uuid) from public, anon, authenticated;
revoke all on function private.set_event_registration_access_scope(uuid, text) from public, anon, authenticated;
revoke all on function private.list_my_notifications(integer) from public, anon, authenticated;
revoke all on function private.count_my_unread_notifications() from public, anon, authenticated;
revoke all on function private.mark_notification_read(uuid) from public, anon, authenticated;
revoke all on function private.mark_all_notifications_read() from public, anon, authenticated;
grant execute on function private.get_event_registration_access(uuid) to authenticated;
grant execute on function private.request_event_registration_access(uuid, text) to authenticated;
grant execute on function private.review_event_registration_access_request(uuid, text, text) to authenticated;
grant execute on function private.list_event_registration_access_requests(uuid) to authenticated;
grant execute on function private.set_event_registration_access_scope(uuid, text) to authenticated;
grant execute on function private.list_my_notifications(integer) to authenticated;
grant execute on function private.count_my_unread_notifications() to authenticated;
grant execute on function private.mark_notification_read(uuid) to authenticated;
grant execute on function private.mark_all_notifications_read() to authenticated;

create or replace function public.get_event_registration_access(p_event uuid)
returns jsonb language sql stable security invoker set search_path = ''
as $$ select private.get_event_registration_access(p_event); $$;

create or replace function public.request_event_registration_access(p_event uuid, p_reason text default null)
returns uuid language sql security invoker set search_path = ''
as $$ select private.request_event_registration_access(p_event, p_reason); $$;

create or replace function public.review_event_registration_access_request(p_request uuid, p_decision text, p_notes text default null)
returns void language sql security invoker set search_path = ''
as $$ select private.review_event_registration_access_request(p_request, p_decision, p_notes); $$;

create or replace function public.list_event_registration_access_requests(p_event uuid)
returns table (
  id uuid, user_id uuid, fighter_name text, team_id uuid, team_name text, organization_name text, reason text, status text,
  created_at timestamptz, reviewed_at timestamptz, review_notes text, eligibility_snapshot jsonb
)
language sql stable security invoker set search_path = ''
as $$ select * from private.list_event_registration_access_requests(p_event); $$;

create or replace function public.set_event_registration_access_scope(p_event uuid, p_scope text)
returns void language sql security invoker set search_path = ''
as $$ select private.set_event_registration_access_scope(p_event, p_scope); $$;

create or replace function public.list_my_notifications(p_limit integer default 30)
returns setof public.app_notifications language sql stable security invoker set search_path = ''
as $$ select * from private.list_my_notifications(p_limit); $$;

create or replace function public.count_my_unread_notifications()
returns integer language sql stable security invoker set search_path = ''
as $$ select private.count_my_unread_notifications(); $$;

create or replace function public.mark_notification_read(p_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.mark_notification_read(p_id); $$;

create or replace function public.mark_all_notifications_read()
returns void language sql security invoker set search_path = ''
as $$ select private.mark_all_notifications_read(); $$;

revoke all on function public.get_event_registration_access(uuid) from public, anon;
revoke all on function public.request_event_registration_access(uuid, text) from public, anon;
revoke all on function public.review_event_registration_access_request(uuid, text, text) from public, anon;
revoke all on function public.list_event_registration_access_requests(uuid) from public, anon;
revoke all on function public.set_event_registration_access_scope(uuid, text) from public, anon;
revoke all on function public.list_my_notifications(integer) from public, anon;
revoke all on function public.count_my_unread_notifications() from public, anon;
revoke all on function public.mark_notification_read(uuid) from public, anon;
revoke all on function public.mark_all_notifications_read() from public, anon;
grant execute on function public.get_event_registration_access(uuid) to authenticated;
grant execute on function public.request_event_registration_access(uuid, text) to authenticated;
grant execute on function public.review_event_registration_access_request(uuid, text, text) to authenticated;
grant execute on function public.list_event_registration_access_requests(uuid) to authenticated;
grant execute on function public.set_event_registration_access_scope(uuid, text) to authenticated;
grant execute on function public.list_my_notifications(integer) to authenticated;
grant execute on function public.count_my_unread_notifications() to authenticated;
grant execute on function public.mark_notification_read(uuid) to authenticated;
grant execute on function public.mark_all_notifications_read() to authenticated;

notify pgrst, 'reload schema';
