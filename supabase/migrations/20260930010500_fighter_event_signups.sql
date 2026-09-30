create table if not exists public.fighter_event_signups (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  display_name text not null,
  email text not null,
  phone text,
  team_name text,
  experience_years numeric(5,2),
  fighting_categories text[] not null default '{}',
  armor_status text,
  attendance_notes text,
  emergency_contact text,
  additional_notes text,
  consent_acknowledged boolean not null default false,
  submitted_by_user_id uuid references auth.users(id) on delete set null,
  status text not null default 'new' check (status in ('new','contacted','confirmed','declined','archived')),
  organizer_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz
);

create index if not exists fighter_event_signups_event_idx
  on public.fighter_event_signups(event_id, created_at desc);

create index if not exists fighter_event_signups_email_idx
  on public.fighter_event_signups(lower(email));

alter table public.fighter_event_signups enable row level security;

grant insert on public.fighter_event_signups to anon, authenticated;
grant select, update, delete on public.fighter_event_signups to authenticated;

create or replace function private.can_manage_event_signups(check_user uuid, check_event uuid)
returns boolean
language sql
stable
security definer
set search_path=''
as $$
  select exists(
    select 1
    from public.events e
    where e.id=check_event
      and (
        private.is_platform_admin(check_user)
        or private.has_org_role(check_user,e.organization_id,array['organization_admin','organization_staff']::public.organization_role[])
        or private.has_event_role(check_user,e.id,array['event_organizer']::public.event_role[])
      )
  );
$$;

grant usage on schema private to authenticated;
grant execute on function private.can_manage_event_signups(uuid,uuid) to authenticated;

drop policy if exists fighter_event_signups_public_insert on public.fighter_event_signups;
create policy fighter_event_signups_public_insert
on public.fighter_event_signups
for insert
to anon, authenticated
with check (
  consent_acknowledged = true
  and exists(
    select 1 from public.events e
    where e.id=event_id
      and e.status in ('published','live')
      and e.published_at is not null
  )
  and char_length(trim(display_name)) between 2 and 120
  and char_length(trim(email)) between 3 and 254
);

drop policy if exists fighter_event_signups_manager_select on public.fighter_event_signups;
create policy fighter_event_signups_manager_select
on public.fighter_event_signups
for select
to authenticated
using (private.can_manage_event_signups(auth.uid(),event_id));

drop policy if exists fighter_event_signups_manager_update on public.fighter_event_signups;
create policy fighter_event_signups_manager_update
on public.fighter_event_signups
for update
to authenticated
using (private.can_manage_event_signups(auth.uid(),event_id))
with check (private.can_manage_event_signups(auth.uid(),event_id));

drop policy if exists fighter_event_signups_manager_delete on public.fighter_event_signups;
create policy fighter_event_signups_manager_delete
on public.fighter_event_signups
for delete
to authenticated
using (private.can_manage_event_signups(auth.uid(),event_id));
