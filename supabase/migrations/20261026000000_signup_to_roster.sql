-- Interest-form signups can become roster entries.
--
-- Found by a dry run of a miniature event: the roster was fed only by formal registrations (which need divisions) or by hand-added
-- ghost fighters, so an organizer had to retype every accepted signup. This lets an event leader add an ACCEPTED signup to the
-- roster in one step, using the same roster-entry shape that formal registration approval produces. The entrant starts with every
-- check-in and clearance flag false; nothing is cleared automatically.

alter table public.fighter_event_signups
  add column if not exists roster_entry_id uuid references public.event_roster_entries(id) on delete set null;

create unique index if not exists fighter_event_signups_roster_entry_uidx
  on public.fighter_event_signups(roster_entry_id) where roster_entry_id is not null;

create or replace function private.add_signup_to_roster(p_signup uuid)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_signup public.fighter_event_signups%rowtype;
  v_event public.events%rowtype;
  v_roster uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  select * into v_signup from public.fighter_event_signups where id = p_signup for update;
  if v_signup.id is null then raise exception 'Signup not found'; end if;
  if not private.is_event_leader(v_actor, v_signup.event_id) then
    raise exception 'Only event organizers and team leaders can add signups to the roster';
  end if;
  if v_signup.roster_entry_id is not null then return v_signup.roster_entry_id; end if;
  if v_signup.status <> 'confirmed' then raise exception 'Accept the signup first, then add it to the roster'; end if;

  select * into v_event from public.events where id = v_signup.event_id;
  if v_event.status in ('cancelled', 'archived', 'completed') then raise exception 'This event is no longer taking entrants'; end if;

  insert into public.event_roster_entries(
    organization_id, event_id, entry_type, display_name,
    checked_in, armor_cleared, medical_cleared, waiver_confirmed, weigh_in_cleared,
    attendance_status, metadata, created_by, last_edited_by, competition_cleared)
  values (
    v_event.organization_id, v_event.id, 'guest_fighter', v_signup.display_name,
    false, false, false, false, false,
    'approved',
    jsonb_build_object('signupId', v_signup.id, 'teamName', v_signup.team_name, 'categories', v_signup.fighting_categories, 'armorStatus', v_signup.armor_status),
    v_actor, v_actor, false)
  returning id into v_roster;

  update public.fighter_event_signups set roster_entry_id = v_roster, reviewed_by = coalesce(reviewed_by, v_actor) where id = p_signup;

  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, v_event.id, 'fighter_event_signups', p_signup, 'add_signup_to_roster', jsonb_build_object('rosterEntryId', v_roster));
  return v_roster;
end;
$$;

revoke all on function private.add_signup_to_roster(uuid) from public, anon, authenticated;
grant execute on function private.add_signup_to_roster(uuid) to authenticated;

create or replace function public.add_signup_to_roster(p_signup uuid)
returns uuid language sql security invoker set search_path = ''
as $$ select private.add_signup_to_roster(p_signup); $$;
revoke all on function public.add_signup_to_roster(uuid) from public, anon;
grant execute on function public.add_signup_to_roster(uuid) to authenticated;

notify pgrst, 'reload schema';
