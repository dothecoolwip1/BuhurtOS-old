create table if not exists public.access_codes (
  id uuid primary key default gen_random_uuid(),
  code_hash bytea not null unique,
  code_prefix text not null,
  label text not null,
  notes text,
  max_uses integer check (max_uses is null or max_uses > 0),
  expires_at timestamptz,
  disabled_at timestamptz,
  disabled_by uuid references auth.users(id),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.access_code_redemptions (
  id uuid primary key default gen_random_uuid(),
  access_code_id uuid not null references public.access_codes(id) on delete restrict,
  user_id uuid not null references auth.users(id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  revoked_at timestamptz,
  revoked_by uuid references auth.users(id),
  unique(access_code_id, user_id)
);

create index if not exists access_code_redemptions_user_idx on public.access_code_redemptions(user_id);
create index if not exists access_code_redemptions_code_idx on public.access_code_redemptions(access_code_id);

alter table public.access_codes enable row level security;
alter table public.access_code_redemptions enable row level security;

revoke all on table public.access_codes from anon, authenticated;
revoke all on table public.access_code_redemptions from anon, authenticated;
grant all on table public.access_codes to service_role;
grant all on table public.access_code_redemptions to service_role;

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated, service_role;

create or replace function private.is_platform_super_admin(p_user_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = p_user_id
      and pm.role = 'platform_super_admin'::public.platform_role
  );
$$;
revoke all on function private.is_platform_super_admin(uuid) from public, anon;
grant execute on function private.is_platform_super_admin(uuid) to authenticated, service_role;

create or replace function private.has_buhurtos_access(p_user_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select private.is_platform_super_admin(p_user_id)
    or exists (
      select 1 from public.platform_memberships pm
      where pm.user_id = p_user_id
        and pm.role = 'platform_staff'::public.platform_role
    )
    or exists (
      select 1
      from public.access_code_redemptions r
      join public.access_codes c on c.id = r.access_code_id
      where r.user_id = p_user_id
        and r.revoked_at is null
        and c.disabled_at is null
        and (c.expires_at is null or c.expires_at > now())
    );
$$;
revoke all on function private.has_buhurtos_access(uuid) from public, anon;
grant execute on function private.has_buhurtos_access(uuid) to authenticated, service_role;

create or replace function public.has_buhurtos_access()
returns boolean language sql stable security invoker set search_path = ''
as $$
  select case
    when (select auth.uid()) is null then false
    else private.has_buhurtos_access((select auth.uid()))
  end;
$$;
revoke all on function public.has_buhurtos_access() from public, anon;
grant execute on function public.has_buhurtos_access() to authenticated;

create or replace function private.redeem_buhurtos_access_code(p_user_id uuid, p_code text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  v_code public.access_codes%rowtype;
  v_use_count integer;
  v_existing public.access_code_redemptions%rowtype;
begin
  if p_user_id is null then raise exception 'Sign in before redeeming an access code.'; end if;
  if p_code is null or length(trim(p_code)) < 6 then raise exception 'Enter a valid BuhurtOS access code.'; end if;

  select c.* into v_code
  from public.access_codes c
  where c.code_hash = extensions.digest(upper(trim(p_code)), 'sha256')
  for update;

  if not found then raise exception 'That access code is not valid.'; end if;
  if v_code.disabled_at is not null then raise exception 'That access code has been disabled.'; end if;
  if v_code.expires_at is not null and v_code.expires_at <= now() then raise exception 'That access code has expired.'; end if;

  select r.* into v_existing
  from public.access_code_redemptions r
  where r.access_code_id = v_code.id and r.user_id = p_user_id;

  if found then
    if v_existing.revoked_at is null then
      return jsonb_build_object('ok', true, 'already_redeemed', true, 'label', v_code.label);
    end if;
    raise exception 'Access previously granted by this code was revoked. Ask for a new code.';
  end if;

  if v_code.max_uses is not null then
    select count(*)::integer into v_use_count
    from public.access_code_redemptions r
    where r.access_code_id = v_code.id and r.revoked_at is null;
    if v_use_count >= v_code.max_uses then raise exception 'That access code has reached its usage limit.'; end if;
  end if;

  insert into public.access_code_redemptions(access_code_id, user_id)
  values (v_code.id, p_user_id);

  return jsonb_build_object('ok', true, 'already_redeemed', false, 'label', v_code.label);
end;
$$;
revoke all on function private.redeem_buhurtos_access_code(uuid,text) from public, anon;
grant execute on function private.redeem_buhurtos_access_code(uuid,text) to authenticated, service_role;

create or replace function public.redeem_buhurtos_access_code(p_code text)
returns jsonb language sql security invoker set search_path = ''
as $$ select private.redeem_buhurtos_access_code((select auth.uid()), p_code); $$;
revoke all on function public.redeem_buhurtos_access_code(text) from public, anon;
grant execute on function public.redeem_buhurtos_access_code(text) to authenticated;

create or replace function private.create_buhurtos_access_code(
  p_user_id uuid, p_label text, p_max_uses integer, p_expires_at timestamptz, p_notes text
)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  v_plain text;
  v_hash bytea;
  v_id uuid;
  v_prefix text;
begin
  if not private.is_platform_super_admin(p_user_id) then raise exception 'Platform super admin access is required.'; end if;
  if p_label is null or length(trim(p_label)) < 2 then raise exception 'Enter a label for this access code.'; end if;
  if p_max_uses is not null and p_max_uses < 1 then raise exception 'Maximum uses must be at least 1.'; end if;
  if p_expires_at is not null and p_expires_at <= now() then raise exception 'Expiration must be in the future.'; end if;

  loop
    v_plain := 'BO-' || upper(substr(encode(extensions.gen_random_bytes(8), 'hex'), 1, 12));
    v_hash := extensions.digest(v_plain, 'sha256');
    exit when not exists (select 1 from public.access_codes where code_hash = v_hash);
  end loop;

  v_prefix := left(v_plain, 7);
  insert into public.access_codes(code_hash, code_prefix, label, notes, max_uses, expires_at, created_by)
  values (v_hash, v_prefix, trim(p_label), nullif(trim(p_notes), ''), p_max_uses, p_expires_at, p_user_id)
  returning id into v_id;

  return jsonb_build_object('id', v_id, 'code', v_plain, 'label', trim(p_label), 'max_uses', p_max_uses, 'expires_at', p_expires_at);
end;
$$;
revoke all on function private.create_buhurtos_access_code(uuid,text,integer,timestamptz,text) from public, anon;
grant execute on function private.create_buhurtos_access_code(uuid,text,integer,timestamptz,text) to authenticated, service_role;

create or replace function public.create_buhurtos_access_code(
  p_label text, p_max_uses integer default null, p_expires_at timestamptz default null, p_notes text default null
)
returns jsonb language sql security invoker set search_path = ''
as $$ select private.create_buhurtos_access_code((select auth.uid()), p_label, p_max_uses, p_expires_at, p_notes); $$;
revoke all on function public.create_buhurtos_access_code(text,integer,timestamptz,text) from public, anon;
grant execute on function public.create_buhurtos_access_code(text,integer,timestamptz,text) to authenticated;

create or replace function private.list_buhurtos_access_codes(p_user_id uuid)
returns table (
  id uuid, code_prefix text, label text, notes text, max_uses integer, active_uses bigint,
  total_redemptions bigint, expires_at timestamptz, disabled_at timestamptz, created_at timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select c.id, c.code_prefix, c.label, c.notes, c.max_uses,
    count(r.id) filter (where r.revoked_at is null) as active_uses,
    count(r.id) as total_redemptions,
    c.expires_at, c.disabled_at, c.created_at
  from public.access_codes c
  left join public.access_code_redemptions r on r.access_code_id = c.id
  where private.is_platform_super_admin(p_user_id)
  group by c.id, c.code_prefix, c.label, c.notes, c.max_uses, c.expires_at, c.disabled_at, c.created_at
  order by c.created_at desc;
$$;
revoke all on function private.list_buhurtos_access_codes(uuid) from public, anon;
grant execute on function private.list_buhurtos_access_codes(uuid) to authenticated, service_role;

create or replace function public.list_buhurtos_access_codes()
returns table (
  id uuid, code_prefix text, label text, notes text, max_uses integer, active_uses bigint,
  total_redemptions bigint, expires_at timestamptz, disabled_at timestamptz, created_at timestamptz
)
language sql stable security invoker set search_path = ''
as $$ select * from private.list_buhurtos_access_codes((select auth.uid())); $$;
revoke all on function public.list_buhurtos_access_codes() from public, anon;
grant execute on function public.list_buhurtos_access_codes() to authenticated;

create or replace function private.revoke_buhurtos_access_code(p_user_id uuid, p_code_id uuid)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_platform_super_admin(p_user_id) then raise exception 'Platform super admin access is required.'; end if;
  update public.access_codes
  set disabled_at = coalesce(disabled_at, now()), disabled_by = coalesce(disabled_by, p_user_id), updated_at = now()
  where id = p_code_id;
  if not found then raise exception 'Access code not found.'; end if;
end;
$$;
revoke all on function private.revoke_buhurtos_access_code(uuid,uuid) from public, anon;
grant execute on function private.revoke_buhurtos_access_code(uuid,uuid) to authenticated, service_role;

create or replace function public.revoke_buhurtos_access_code(p_code_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.revoke_buhurtos_access_code((select auth.uid()), p_code_id); $$;
revoke all on function public.revoke_buhurtos_access_code(uuid) from public, anon;
grant execute on function public.revoke_buhurtos_access_code(uuid) to authenticated;

create or replace function private.revoke_buhurtos_user_access(p_admin_id uuid, p_user_id uuid)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_platform_super_admin(p_admin_id) then raise exception 'Platform super admin access is required.'; end if;
  update public.access_code_redemptions set revoked_at = now(), revoked_by = p_admin_id
  where user_id = p_user_id and revoked_at is null;
end;
$$;
revoke all on function private.revoke_buhurtos_user_access(uuid,uuid) from public, anon;
grant execute on function private.revoke_buhurtos_user_access(uuid,uuid) to authenticated, service_role;

create or replace function public.revoke_buhurtos_user_access(p_user_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.revoke_buhurtos_user_access((select auth.uid()), p_user_id); $$;
revoke all on function public.revoke_buhurtos_user_access(uuid) from public, anon;
grant execute on function public.revoke_buhurtos_user_access(uuid) to authenticated;

create or replace function private.list_buhurtos_access_users(p_admin_id uuid)
returns table (
  user_id uuid, display_email text, code_label text, redeemed_at timestamptz, revoked_at timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select r.user_id, coalesce(u.email, 'Account')::text, c.label, r.redeemed_at, r.revoked_at
  from public.access_code_redemptions r
  join public.access_codes c on c.id = r.access_code_id
  left join auth.users u on u.id = r.user_id
  where private.is_platform_super_admin(p_admin_id)
  order by r.redeemed_at desc;
$$;
revoke all on function private.list_buhurtos_access_users(uuid) from public, anon;
grant execute on function private.list_buhurtos_access_users(uuid) to authenticated, service_role;

create or replace function public.list_buhurtos_access_users()
returns table (
  user_id uuid, display_email text, code_label text, redeemed_at timestamptz, revoked_at timestamptz
)
language sql stable security invoker set search_path = ''
as $$ select * from private.list_buhurtos_access_users((select auth.uid())); $$;
revoke all on function public.list_buhurtos_access_users() from public, anon;
grant execute on function public.list_buhurtos_access_users() to authenticated;
