do $$ begin
  create type public.delegated_access_scope as enum ('organization','club','team');
exception when duplicate_object then null;
end $$;

create table if not exists public.delegated_access_codes (
  id uuid primary key default gen_random_uuid(),
  code_hash bytea not null unique,
  code_prefix text not null,
  label text not null,
  target_scope public.delegated_access_scope not null,
  organization_id uuid references public.organizations(id) on delete cascade,
  club_id uuid references public.clubs(id) on delete cascade,
  team_id uuid references public.teams(id) on delete cascade,
  organization_role public.organization_role,
  club_role public.club_role,
  team_role public.team_role,
  max_uses integer not null default 1 check (max_uses > 0),
  expires_at timestamptz,
  disabled_at timestamptz,
  disabled_by uuid references auth.users(id),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint delegated_access_codes_target_check check (
    (target_scope='organization' and organization_id is not null and club_id is null and team_id is null and organization_role is not null and club_role is null and team_role is null)
    or
    (target_scope='club' and organization_id is null and club_id is not null and team_id is null and organization_role is null and club_role is not null and team_role is null)
    or
    (target_scope='team' and organization_id is null and club_id is null and team_id is not null and organization_role is null and club_role is null and team_role is not null)
  )
);

create table if not exists public.delegated_access_code_redemptions (
  id uuid primary key default gen_random_uuid(),
  access_code_id uuid not null references public.delegated_access_codes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  revoked_at timestamptz,
  revoked_by uuid references auth.users(id),
  unique(access_code_id,user_id)
);

create index if not exists delegated_access_codes_creator_idx on public.delegated_access_codes(created_by);
create index if not exists delegated_access_codes_org_idx on public.delegated_access_codes(organization_id);
create index if not exists delegated_access_codes_club_idx on public.delegated_access_codes(club_id);
create index if not exists delegated_access_codes_team_idx on public.delegated_access_codes(team_id);
create index if not exists delegated_access_redemptions_user_idx on public.delegated_access_code_redemptions(user_id);

alter table public.delegated_access_codes enable row level security;
alter table public.delegated_access_code_redemptions enable row level security;

revoke all on public.delegated_access_codes from anon, authenticated;
revoke all on public.delegated_access_code_redemptions from anon, authenticated;
grant all on public.delegated_access_codes to service_role;
grant all on public.delegated_access_code_redemptions to service_role;

drop policy if exists delegated_access_codes_no_direct_client_access on public.delegated_access_codes;
create policy delegated_access_codes_no_direct_client_access
on public.delegated_access_codes for all
to anon, authenticated using (false) with check (false);

drop policy if exists delegated_access_redemptions_no_direct_client_access on public.delegated_access_code_redemptions;
create policy delegated_access_redemptions_no_direct_client_access
on public.delegated_access_code_redemptions for all
to anon, authenticated using (false) with check (false);

create or replace function private.can_issue_delegated_access_code(
  p_actor uuid,
  p_scope public.delegated_access_scope,
  p_target uuid,
  p_role text
) returns boolean
language plpgsql
stable security definer
set search_path=''
as $$
declare
  v_org uuid;
  v_club uuid;
begin
  if p_actor is null then return false; end if;
  if private.is_platform_admin(p_actor) then return true; end if;

  if p_scope='organization' then
    if p_role not in ('organization_admin','organization_staff') then return false; end if;

    if p_role='organization_staff'
      and private.has_org_role(p_actor,p_target,array['organization_admin']::public.organization_role[]) then
      return true;
    end if;

    return exists(
      select 1
      from public.organization_relationships r
      where r.parent_organization_id in (
        select om.organization_id
        from public.organization_memberships om
        where om.user_id=p_actor and om.role='organization_admin'
      )
      and r.child_organization_id=p_target
      and r.relationship_kind='governs'
      and r.ends_on is null
    );
  end if;

  if p_scope='club' then
    select organization_id into v_org
    from public.clubs
    where id=p_target and deleted_at is null and is_active;

    if v_org is null then return false; end if;
    return private.has_org_role(p_actor,v_org,array['organization_admin']::public.organization_role[]);
  end if;

  if p_scope='team' then
    select organization_id,club_id into v_org,v_club
    from public.teams
    where id=p_target and deleted_at is null and is_active and status='active';

    if v_org is null then return false; end if;

    if private.has_org_role(p_actor,v_org,array['organization_admin']::public.organization_role[]) then
      return true;
    end if;

    if v_club is not null and exists(
      select 1 from public.club_memberships cm
      where cm.club_id=v_club and cm.user_id=p_actor and cm.role='club_admin' and cm.ends_on is null
    ) then
      return true;
    end if;

    if exists(
      select 1 from public.team_memberships tm
      where tm.team_id=p_target and tm.user_id=p_actor and tm.role='team_admin' and tm.ends_on is null
    ) then
      return p_role in ('captain','coach','fighter','support');
    end if;
  end if;

  return false;
end;
$$;

create or replace function private.create_delegated_access_code(
  p_scope public.delegated_access_scope,
  p_target uuid,
  p_role text,
  p_label text default null,
  p_max_uses integer default 1,
  p_expires_at timestamptz default null
) returns text
language plpgsql
security definer
set search_path=''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_code text;
  v_hash bytea;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_max_uses is null or p_max_uses < 1 or p_max_uses > 500 then
    raise exception 'Max uses must be between 1 and 500';
  end if;
  if p_expires_at is not null and p_expires_at <= now() then
    raise exception 'Expiration must be in the future';
  end if;
  if not private.can_issue_delegated_access_code(v_actor,p_scope,p_target,p_role) then
    raise exception 'You cannot issue that access level for this group';
  end if;

  v_code := 'BO-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  v_hash := extensions.digest(v_code,'sha256');

  insert into public.delegated_access_codes(
    code_hash,code_prefix,label,target_scope,
    organization_id,club_id,team_id,
    organization_role,club_role,team_role,
    max_uses,expires_at,created_by
  )
  values(
    v_hash,left(v_code,7),coalesce(nullif(trim(p_label),''),p_scope::text || ' access'),
    p_scope,
    case when p_scope='organization' then p_target end,
    case when p_scope='club' then p_target end,
    case when p_scope='team' then p_target end,
    case when p_scope='organization' then p_role::public.organization_role end,
    case when p_scope='club' then p_role::public.club_role end,
    case when p_scope='team' then p_role::public.team_role end,
    p_max_uses,p_expires_at,v_actor
  );

  return v_code;
end;
$$;

create or replace function private.redeem_delegated_access_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_user uuid := (select auth.uid());
  v_normalized text := upper(trim(coalesce(p_code,'')));
  v_code public.delegated_access_codes%rowtype;
  v_used integer;
  v_name text;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if v_normalized='' then raise exception 'Access code is required'; end if;
  if not exists(select 1 from public.profiles where id=v_user) then
    raise exception 'Account profile not found';
  end if;

  select * into v_code
  from public.delegated_access_codes
  where code_hash=extensions.digest(v_normalized,'sha256');

  if v_code.id is null then raise exception 'Access code not recognized'; end if;
  if v_code.disabled_at is not null then raise exception 'This access code is disabled'; end if;
  if v_code.expires_at is not null and v_code.expires_at <= now() then raise exception 'This access code has expired'; end if;

  select count(*) into v_used
  from public.delegated_access_code_redemptions
  where access_code_id=v_code.id and revoked_at is null;

  if v_used >= v_code.max_uses then raise exception 'This access code has reached its use limit'; end if;

  if exists(
    select 1 from public.delegated_access_code_redemptions
    where access_code_id=v_code.id and user_id=v_user
  ) then
    raise exception 'This account has already used this access code';
  end if;

  if v_code.target_scope='organization' then
    insert into public.organization_memberships(organization_id,user_id,role)
    values(v_code.organization_id,v_user,v_code.organization_role)
    on conflict(organization_id,user_id,role) do nothing;
    select name into v_name from public.organizations where id=v_code.organization_id;
  elsif v_code.target_scope='club' then
    insert into public.club_memberships(club_id,user_id,role,display_name,created_by,last_edited_by)
    values(v_code.club_id,v_user,v_code.club_role,private.profile_label(v_user),v_code.created_by,v_code.created_by)
    on conflict do nothing;
    select name into v_name from public.clubs where id=v_code.club_id;
  else
    insert into public.team_memberships(team_id,user_id,role,display_name,created_by,last_edited_by)
    values(v_code.team_id,v_user,v_code.team_role,private.profile_label(v_user),v_code.created_by,v_code.created_by)
    on conflict do nothing;
    select name into v_name from public.teams where id=v_code.team_id;
  end if;

  insert into public.delegated_access_code_redemptions(access_code_id,user_id)
  values(v_code.id,v_user);

  return jsonb_build_object(
    'scope',v_code.target_scope,
    'targetId',coalesce(v_code.organization_id,v_code.club_id,v_code.team_id),
    'targetName',v_name,
    'role',coalesce(v_code.organization_role::text,v_code.club_role::text,v_code.team_role::text)
  );
end;
$$;

create or replace function private.list_delegated_access_targets()
returns table(scope text,target_id uuid,target_name text,role text)
language sql
stable security definer
set search_path=''
as $$
  with actor as (select auth.uid() as uid)
  select 'organization',o.id,o.name,r.role
  from public.organizations o
  cross join actor
  cross join lateral (values ('organization_admin'),('organization_staff')) r(role)
  where o.status='active'
    and private.can_issue_delegated_access_code(actor.uid,'organization',o.id,r.role)

  union all

  select 'club',c.id,c.name,r.role
  from public.clubs c
  cross join actor
  cross join lateral (values ('club_admin'),('coach'),('member')) r(role)
  where c.deleted_at is null and c.is_active
    and private.can_issue_delegated_access_code(actor.uid,'club',c.id,r.role)

  union all

  select 'team',t.id,t.name,r.role
  from public.teams t
  cross join actor
  cross join lateral (values ('team_admin'),('captain'),('coach'),('fighter'),('support')) r(role)
  where t.deleted_at is null and t.is_active and t.status='active'
    and private.can_issue_delegated_access_code(actor.uid,'team',t.id,r.role)

  order by 1,3,4;
$$;

create or replace function private.list_delegated_access_codes()
returns table(
  id uuid,code_prefix text,label text,target_scope text,target_id uuid,target_name text,role text,
  max_uses integer,active_uses bigint,expires_at timestamptz,disabled_at timestamptz,created_by uuid,created_at timestamptz
)
language sql
stable security definer
set search_path=''
as $$
  select
    c.id,c.code_prefix,c.label,c.target_scope::text,
    coalesce(c.organization_id,c.club_id,c.team_id),
    coalesce(o.name,cl.name,t.name),
    coalesce(c.organization_role::text,c.club_role::text,c.team_role::text),
    c.max_uses,
    count(r.id) filter(where r.revoked_at is null),
    c.expires_at,c.disabled_at,c.created_by,c.created_at
  from public.delegated_access_codes c
  left join public.organizations o on o.id=c.organization_id
  left join public.clubs cl on cl.id=c.club_id
  left join public.teams t on t.id=c.team_id
  left join public.delegated_access_code_redemptions r on r.access_code_id=c.id
  where c.created_by=auth.uid() or private.is_platform_admin(auth.uid())
  group by c.id,o.name,cl.name,t.name
  order by c.created_at desc;
$$;

create or replace function private.disable_delegated_access_code(p_id uuid)
returns void
language plpgsql
security definer
set search_path=''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;

  update public.delegated_access_codes
  set disabled_at=coalesce(disabled_at,now()),
      disabled_by=case when disabled_at is null then v_actor else disabled_by end,
      updated_at=now()
  where id=p_id
    and (created_by=v_actor or private.is_platform_admin(v_actor));

  if not found then raise exception 'Access code not found or not manageable'; end if;
end;
$$;

create or replace function private.has_buhurtos_access(p_user_id uuid)
returns boolean
language sql
stable security definer
set search_path=''
as $$
  select
    private.is_platform_super_admin(p_user_id)
    or exists(select 1 from public.platform_memberships pm where pm.user_id=p_user_id)
    or exists(select 1 from public.access_code_redemptions r where r.user_id=p_user_id and r.revoked_at is null)
    or exists(select 1 from public.delegated_access_code_redemptions r where r.user_id=p_user_id and r.revoked_at is null);
$$;

create or replace function public.create_delegated_access_code(
  p_scope public.delegated_access_scope,
  p_target uuid,
  p_role text,
  p_label text default null,
  p_max_uses integer default 1,
  p_expires_at timestamptz default null
) returns text
language sql security definer set search_path=''
as $$ select private.create_delegated_access_code(p_scope,p_target,p_role,p_label,p_max_uses,p_expires_at); $$;

create or replace function public.redeem_delegated_access_code(p_code text)
returns jsonb
language sql security definer set search_path=''
as $$ select private.redeem_delegated_access_code(p_code); $$;

create or replace function public.list_delegated_access_targets()
returns table(scope text,target_id uuid,target_name text,role text)
language sql security definer set search_path=''
as $$ select * from private.list_delegated_access_targets(); $$;

create or replace function public.list_delegated_access_codes()
returns table(
  id uuid,code_prefix text,label text,target_scope text,target_id uuid,target_name text,role text,
  max_uses integer,active_uses bigint,expires_at timestamptz,disabled_at timestamptz,created_by uuid,created_at timestamptz
)
language sql security definer set search_path=''
as $$ select * from private.list_delegated_access_codes(); $$;

create or replace function public.disable_delegated_access_code(p_id uuid)
returns void
language sql security definer set search_path=''
as $$ select private.disable_delegated_access_code(p_id); $$;

revoke all on function public.create_delegated_access_code(public.delegated_access_scope,uuid,text,text,integer,timestamptz) from public,anon;
revoke all on function public.redeem_delegated_access_code(text) from public,anon;
revoke all on function public.list_delegated_access_targets() from public,anon;
revoke all on function public.list_delegated_access_codes() from public,anon;
revoke all on function public.disable_delegated_access_code(uuid) from public,anon;

grant execute on function public.create_delegated_access_code(public.delegated_access_scope,uuid,text,text,integer,timestamptz) to authenticated;
grant execute on function public.redeem_delegated_access_code(text) to authenticated;
grant execute on function public.list_delegated_access_targets() to authenticated;
grant execute on function public.list_delegated_access_codes() to authenticated;
grant execute on function public.disable_delegated_access_code(uuid) to authenticated;


-- Harden public RPC wrappers: invoker wrappers call only the explicitly granted,
-- auth-checking private functions. The private schema is not exposed by PostgREST.
grant usage on schema private to authenticated;
grant execute on function private.create_delegated_access_code(public.delegated_access_scope,uuid,text,text,integer,timestamptz) to authenticated;
grant execute on function private.redeem_delegated_access_code(text) to authenticated;
grant execute on function private.list_delegated_access_targets() to authenticated;
grant execute on function private.list_delegated_access_codes() to authenticated;
grant execute on function private.disable_delegated_access_code(uuid) to authenticated;

create or replace function public.create_delegated_access_code(
  p_scope public.delegated_access_scope,
  p_target uuid,
  p_role text,
  p_label text default null,
  p_max_uses integer default 1,
  p_expires_at timestamptz default null
) returns text
language sql security invoker set search_path=''
as $$ select private.create_delegated_access_code(p_scope,p_target,p_role,p_label,p_max_uses,p_expires_at); $$;

create or replace function public.redeem_delegated_access_code(p_code text)
returns jsonb
language sql security invoker set search_path=''
as $$ select private.redeem_delegated_access_code(p_code); $$;

create or replace function public.list_delegated_access_targets()
returns table(scope text,target_id uuid,target_name text,role text)
language sql security invoker set search_path=''
as $$ select * from private.list_delegated_access_targets(); $$;

create or replace function public.list_delegated_access_codes()
returns table(
  id uuid,code_prefix text,label text,target_scope text,target_id uuid,target_name text,role text,
  max_uses integer,active_uses bigint,expires_at timestamptz,disabled_at timestamptz,created_by uuid,created_at timestamptz
)
language sql security invoker set search_path=''
as $$ select * from private.list_delegated_access_codes(); $$;

create or replace function public.disable_delegated_access_code(p_id uuid)
returns void
language sql security invoker set search_path=''
as $$ select private.disable_delegated_access_code(p_id); $$;
