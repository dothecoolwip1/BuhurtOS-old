-- Event media: poster alt text, and who may change the poster.
--
-- Authority: until now anyone counted by can_participate_in_event_admin could replace the poster, including plain
-- host-team fighters (that helper is deliberately broad because it also governs signup-code issuance). Poster and media
-- changes are now limited to platform admins, organization admins of the event's organization chain, event organizers,
-- and host-team admins or captains. Signup-code issuance is NOT changed.

alter table public.events add column if not exists image_alt text;
do $$ begin
  alter table public.events add constraint events_image_alt_length check (image_alt is null or char_length(image_alt) <= 300);
exception when duplicate_object then null;
end $$;
comment on column public.events.image_alt is 'Text alternative for the event poster, shown to people who cannot see the image. Falls back to "<event name> poster" when empty.';
grant select (image_alt) on public.events to anon, authenticated;

create or replace function private.can_manage_event_media_for_event(p_user uuid, p_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_user is not null and (
    private.can_manage_event_setup(p_user, p_event)
    or exists (
      select 1 from public.team_memberships tm
       where tm.team_id = private.event_host_team(p_event) and tm.user_id = p_user
         and tm.role in ('team_admin', 'captain') and tm.ends_on is null
    )
  );
$$;
revoke all on function private.can_manage_event_media_for_event(uuid, uuid) from public, anon, authenticated;
grant execute on function private.can_manage_event_media_for_event(uuid, uuid) to authenticated;

-- Storage policies call this by object name; it now uses the narrower authority.
create or replace function private.can_manage_event_media(p_user uuid, p_name text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_user is not null
    and private.event_media_event_id(p_name) is not null
    and private.can_manage_event_media_for_event(p_user, private.event_media_event_id(p_name))
$$;

create or replace function public.set_event_image(p_event uuid, p_path text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.can_manage_event_media_for_event(v_actor, p_event) then
    raise exception 'You are not allowed to change media for this event';
  end if;
  if p_path is not null and (
    split_part(p_path, '/', 1) <> p_event::text
    or p_path !~ '^[0-9a-f-]{36}/[A-Za-z0-9._-]{1,120}$'
  ) then
    raise exception 'Invalid event media path';
  end if;

  -- Removing the poster also clears its description so a stale one never describes a different image.
  update public.events set image_path = p_path, image_alt = case when p_path is null then null else image_alt end where id = p_event;
  if not found then raise exception 'Event not found'; end if;
  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, p_event, 'events', p_event, case when p_path is null then 'remove_event_image' else 'set_event_image' end, jsonb_build_object('path', p_path));
end;
$$;

create or replace function public.set_event_image_alt(p_event uuid, p_alt text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_alt text := nullif(trim(coalesce(p_alt, '')), '');
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.can_manage_event_media_for_event(v_actor, p_event) then
    raise exception 'You are not allowed to change media for this event';
  end if;
  if v_alt is not null and char_length(v_alt) > 300 then raise exception 'Keep the description under 300 characters'; end if;
  if not exists (select 1 from public.events where id = p_event and image_path is not null) then
    raise exception 'Add a poster before describing it';
  end if;
  update public.events set image_alt = v_alt where id = p_event;
  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, p_event, 'events', p_event, 'set_event_image_alt', jsonb_build_object('hasAlt', v_alt is not null));
end;
$$;

revoke all on function public.set_event_image_alt(uuid, text) from public, anon;
grant execute on function public.set_event_image_alt(uuid, text) to authenticated;
revoke all on function public.set_event_image(uuid, text) from public, anon;
grant execute on function public.set_event_image(uuid, text) to authenticated;

notify pgrst, 'reload schema';
