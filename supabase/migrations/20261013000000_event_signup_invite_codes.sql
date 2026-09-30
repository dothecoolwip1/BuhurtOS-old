-- Invite-only event fighter signup codes and hierarchical review authority.

alter table public.fighter_event_signups
  add column if not exists signup_code_id uuid;

create table if not exists public.event_signup_codes (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  code_hash bytea not null unique,
  code_prefix text not null,
  label text not null,
  max_uses integer not null default 1 check (max_uses > 0 and max_uses <= 500),
  expires_at timestamptz,
  disabled_at timestamptz,
  disabled_by uuid references auth.users(id) on delete set null,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

do $$ begin
  alter table public.fighter_event_signups
    add constraint fighter_event_signups_signup_code_fk
    foreign key (signup_code_id) references public.event_signup_codes(id) on delete set null;
exception when duplicate_object then null;
end $$;

create index if not exists event_signup_codes_event_idx on public.event_signup_codes(event_id,created_at desc);
create index if not exists fighter_event_signups_code_idx on public.fighter_event_signups(signup_code_id);

alter table public.event_signup_codes enable row level security;
revoke all on public.event_signup_codes from anon,authenticated;
grant all on public.event_signup_codes to service_role;

drop policy if exists event_signup_codes_no_direct_client_access on public.event_signup_codes;
create policy event_signup_codes_no_direct_client_access
on public.event_signup_codes for all
to anon,authenticated
using(false) with check(false);

create or replace function private.event_host_team_id(p_event_id uuid)
returns uuid
language sql stable security definer
set search_path=''
as $$
  select case
    when (e.public_links->>'host_team_id') ~* '^[0-9a-f-]{36}$'
      then (e.public_links->>'host_team_id')::uuid
    else null
  end
  from public.events e
  where e.id=p_event_id;
$$;

create or replace function private.can_participate_in_event_admin(p_user uuid,p_event uuid)
returns boolean
language sql stable security definer
set search_path=''
as $$
  with recursive event_org as (
    select e.organization_id
    from public.events e
    where e.id=p_event
  ),
  governing_orgs(id) as (
    select organization_id from event_org
    union
    select r.parent_organization_id
    from public.organization_relationships r
    join governing_orgs g on g.id=r.child_organization_id
    where r.relationship_kind='governs'
      and r.ends_on is null
  )
  select
    private.is_platform_admin(p_user)
    or exists(
      select 1
      from public.organization_memberships om
      where om.user_id=p_user
        and om.organization_id in (select id from governing_orgs)
    )
    or exists(
      select 1
      from public.team_memberships tm
      where tm.team_id=private.event_host_team_id(p_event)
        and tm.user_id=p_user
        and tm.ends_on is null
    )
    or exists(
      select 1
      from public.event_memberships em
      where em.event_id=p_event and em.user_id=p_user
    );
$$;

create or replace function private.can_manage_event_signups(check_user uuid,check_event uuid)
returns boolean
language sql stable security definer
set search_path=''
as $$
  select private.can_participate_in_event_admin(check_user,check_event);
$$;

create or replace function private.event_signup_code_prefix(p_event uuid)
returns text
language plpgsql stable security definer
set search_path=''
as $$
declare
  v_name text;
  v_year text;
  v_initials text;
begin
  select e.name,to_char(e.starts_at,'YY') into v_name,v_year
  from public.events e where e.id=p_event;

  if v_name is null then raise exception 'Event not found'; end if;

  select upper(string_agg(left(word,1),''))
    into v_initials
  from (
    select word
    from regexp_split_to_table(regexp_replace(v_name,'[^A-Za-z0-9 ]','','g'),'\s+') as word
    where length(word)>0
    limit 5
  ) q;

  if coalesce(v_initials,'')='' then v_initials:='EVENT'; end if;
  return left(v_initials,5)||v_year;
end;
$$;

create or replace function private.create_event_signup_code(
  p_event uuid,
  p_label text default null,
  p_max_uses integer default 1,
  p_expires_at timestamptz default null
) returns text
language plpgsql security definer
set search_path=''
as $$
declare
  v_actor uuid:=auth.uid();
  v_code text;
  v_prefix text;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.can_participate_in_event_admin(v_actor,p_event) then
    raise exception 'You are not allowed to create signup codes for this event';
  end if;
  if p_max_uses is null or p_max_uses<1 or p_max_uses>500 then
    raise exception 'Max uses must be between 1 and 500';
  end if;
  if p_expires_at is not null and p_expires_at<=now() then
    raise exception 'Expiration must be in the future';
  end if;

  v_prefix:=private.event_signup_code_prefix(p_event);
  v_code:=v_prefix||'-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,6));

  insert into public.event_signup_codes(
    event_id,code_hash,code_prefix,label,max_uses,expires_at,created_by
  ) values (
    p_event,extensions.digest(upper(v_code),'sha256'),v_prefix,
    coalesce(nullif(trim(p_label),''),'Fighter signup'),p_max_uses,p_expires_at,v_actor
  );

  return v_code;
end;
$$;

create or replace function private.validate_event_signup_code(p_event uuid,p_code text)
returns jsonb
language plpgsql stable security definer
set search_path=''
as $$
declare
  v_row public.event_signup_codes%rowtype;
  v_used integer;
begin
  select * into v_row
  from public.event_signup_codes
  where event_id=p_event
    and code_hash=extensions.digest(upper(trim(coalesce(p_code,''))),'sha256');

  if v_row.id is null then return jsonb_build_object('valid',false,'message','Code not recognized for this event'); end if;
  if v_row.disabled_at is not null then return jsonb_build_object('valid',false,'message','This signup code is disabled'); end if;
  if v_row.expires_at is not null and v_row.expires_at<=now() then return jsonb_build_object('valid',false,'message','This signup code has expired'); end if;

  select count(*) into v_used
  from public.fighter_event_signups s
  where s.signup_code_id=v_row.id and s.status<>'archived';

  if v_used>=v_row.max_uses then return jsonb_build_object('valid',false,'message','This signup code has reached its use limit'); end if;
  return jsonb_build_object('valid',true,'label',v_row.label,'prefix',v_row.code_prefix);
end;
$$;

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
  v_id uuid;
begin
  v_check:=private.validate_event_signup_code(p_event,p_code);
  if coalesce((v_check->>'valid')::boolean,false) is false then
    raise exception '%',coalesce(v_check->>'message','Invalid signup code');
  end if;
  if not p_consent then raise exception 'Consent is required'; end if;
  if char_length(trim(coalesce(p_display_name,'')))<2 then raise exception 'Name is required'; end if;
  if char_length(trim(coalesce(p_email,'')))<3 then raise exception 'Email is required'; end if;

  select * into v_code
  from public.event_signup_codes
  where event_id=p_event
    and code_hash=extensions.digest(upper(trim(p_code)),'sha256');

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

create or replace function private.list_event_signup_codes(p_event uuid)
returns table(
  id uuid,label text,code_prefix text,max_uses integer,uses bigint,
  expires_at timestamptz,disabled_at timestamptz,created_at timestamptz
)
language sql stable security definer
set search_path=''
as $$
  select c.id,c.label,c.code_prefix,c.max_uses,
         count(s.id) filter(where s.status<>'archived') as uses,
         c.expires_at,c.disabled_at,c.created_at
  from public.event_signup_codes c
  left join public.fighter_event_signups s on s.signup_code_id=c.id
  where c.event_id=p_event
    and private.can_participate_in_event_admin(auth.uid(),p_event)
  group by c.id
  order by c.created_at desc;
$$;

create or replace function private.disable_event_signup_code(p_code_id uuid)
returns void
language plpgsql security definer
set search_path=''
as $$
declare
  v_event uuid;
begin
  select event_id into v_event from public.event_signup_codes where id=p_code_id;
  if v_event is null then raise exception 'Signup code not found'; end if;
  if not private.can_participate_in_event_admin(auth.uid(),v_event) then
    raise exception 'You cannot manage this event signup code';
  end if;

  update public.event_signup_codes
  set disabled_at=coalesce(disabled_at,now()),
      disabled_by=auth.uid(),
      updated_at=now()
  where id=p_code_id;
end;
$$;

revoke insert on public.fighter_event_signups from anon,authenticated;

grant usage on schema private to anon,authenticated;
grant execute on function private.validate_event_signup_code(uuid,text) to anon,authenticated;
grant execute on function private.submit_event_fighter_signup(uuid,text,text,text,text,text,numeric,text[],text,text,text,text,boolean) to anon,authenticated;
grant execute on function private.create_event_signup_code(uuid,text,integer,timestamptz) to authenticated;
grant execute on function private.list_event_signup_codes(uuid) to authenticated;
grant execute on function private.disable_event_signup_code(uuid) to authenticated;
grant execute on function private.can_participate_in_event_admin(uuid,uuid) to authenticated;
grant execute on function private.can_manage_event_signups(uuid,uuid) to authenticated;

create or replace function public.validate_event_signup_code(p_event uuid,p_code text)
returns jsonb language sql security invoker set search_path=''
as $$ select private.validate_event_signup_code(p_event,p_code); $$;

create or replace function public.submit_event_fighter_signup(
  p_event uuid,p_code text,p_display_name text,p_email text,p_phone text default null,
  p_team_name text default null,p_experience_years numeric default null,
  p_fighting_categories text[] default '{}',p_armor_status text default null,
  p_attendance_notes text default null,p_emergency_contact text default null,
  p_additional_notes text default null,p_consent boolean default false
) returns uuid language sql security invoker set search_path=''
as $$ select private.submit_event_fighter_signup(
  p_event,p_code,p_display_name,p_email,p_phone,p_team_name,p_experience_years,
  p_fighting_categories,p_armor_status,p_attendance_notes,p_emergency_contact,p_additional_notes,p_consent
); $$;

create or replace function public.create_event_signup_code(
  p_event uuid,p_label text default null,p_max_uses integer default 1,p_expires_at timestamptz default null
) returns text language sql security invoker set search_path=''
as $$ select private.create_event_signup_code(p_event,p_label,p_max_uses,p_expires_at); $$;

create or replace function public.list_event_signup_codes(p_event uuid)
returns table(id uuid,label text,code_prefix text,max_uses integer,uses bigint,expires_at timestamptz,disabled_at timestamptz,created_at timestamptz)
language sql security invoker set search_path=''
as $$ select * from private.list_event_signup_codes(p_event); $$;

create or replace function public.disable_event_signup_code(p_code_id uuid)
returns void language sql security invoker set search_path=''
as $$ select private.disable_event_signup_code(p_code_id); $$;

revoke all on function public.validate_event_signup_code(uuid,text) from public;
revoke all on function public.submit_event_fighter_signup(uuid,text,text,text,text,text,numeric,text[],text,text,text,text,boolean) from public;
revoke all on function public.create_event_signup_code(uuid,text,integer,timestamptz) from public;
revoke all on function public.list_event_signup_codes(uuid) from public;
revoke all on function public.disable_event_signup_code(uuid) from public;

grant execute on function public.validate_event_signup_code(uuid,text) to anon,authenticated;
grant execute on function public.submit_event_fighter_signup(uuid,text,text,text,text,text,numeric,text[],text,text,text,text,boolean) to anon,authenticated;
grant execute on function public.create_event_signup_code(uuid,text,integer,timestamptz) to authenticated;
grant execute on function public.list_event_signup_codes(uuid) to authenticated;
grant execute on function public.disable_event_signup_code(uuid) to authenticated;
