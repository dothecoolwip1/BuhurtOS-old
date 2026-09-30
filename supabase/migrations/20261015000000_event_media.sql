-- Pack 5: durable event media (posters) in Supabase Storage.
-- The bucket is public-read because posters are public marketing images.
-- Writes are limited to people who administer the event (platform admins,
-- event members, host-team members, and the event's governing organizations).
-- Object paths are "<event_id>/<file name>".

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'event-media',
  'event-media',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

-- Resolves the event id from the first path segment without ever raising on malformed paths.
create or replace function private.event_media_event_id(p_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when split_part(p_name, '/', 1) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
      then split_part(p_name, '/', 1)::uuid
    else null
  end
$$;

create or replace function private.can_manage_event_media(p_user uuid, p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_user is not null
    and private.event_media_event_id(p_name) is not null
    and private.can_participate_in_event_admin(p_user, private.event_media_event_id(p_name))
$$;

grant execute on function private.event_media_event_id(text) to authenticated;
grant execute on function private.can_manage_event_media(uuid, text) to authenticated;

drop policy if exists event_media_public_read on storage.objects;
create policy event_media_public_read
on storage.objects for select
to anon, authenticated
using (bucket_id = 'event-media');

drop policy if exists event_media_admin_insert on storage.objects;
create policy event_media_admin_insert
on storage.objects for insert
to authenticated
with check (bucket_id = 'event-media' and private.can_manage_event_media(auth.uid(), name));

drop policy if exists event_media_admin_update on storage.objects;
create policy event_media_admin_update
on storage.objects for update
to authenticated
using (bucket_id = 'event-media' and private.can_manage_event_media(auth.uid(), name))
with check (bucket_id = 'event-media' and private.can_manage_event_media(auth.uid(), name));

drop policy if exists event_media_admin_delete on storage.objects;
create policy event_media_admin_delete
on storage.objects for delete
to authenticated
using (bucket_id = 'event-media' and private.can_manage_event_media(auth.uid(), name));

-- Records (or clears) the poster reference on the event row.
create or replace function public.set_event_image(p_event uuid, p_path text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.can_participate_in_event_admin(v_actor, p_event) then
    raise exception 'You are not allowed to change media for this event';
  end if;
  if p_path is not null and (
    split_part(p_path, '/', 1) <> p_event::text
    or p_path !~ '^[0-9a-f-]{36}/[A-Za-z0-9._-]{1,120}$'
  ) then
    raise exception 'Invalid event media path';
  end if;

  update public.events set image_path = p_path where id = p_event;
  if not found then raise exception 'Event not found'; end if;
end;
$$;

revoke all on function public.set_event_image(uuid, text) from public;
revoke all on function public.set_event_image(uuid, text) from anon;
grant execute on function public.set_event_image(uuid, text) to authenticated;
