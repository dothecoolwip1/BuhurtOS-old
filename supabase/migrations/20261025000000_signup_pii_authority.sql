-- Signup submissions contain personal data (name, email, phone, emergency contact, notes). They must be readable and
-- changeable only by event leaders, not by every member of the host team.
--
-- Found by a permission attack pass against the real hosted schema: a plain host-team fighter could read, update and
-- delete every signup submission, because the policies reuse private.can_manage_event_signups, which delegated to the
-- broad "event participant" helper that also (intentionally) governs signup-CODE issuance.
--
-- Event leader = platform admin, organization admin of the event's organization chain, event organizer, or host-team
-- admin or captain. One definition, used for signup review and for event media.
-- Signup-code issuance (create / list / disable) is NOT changed: host-team and organization members can still give out codes.

create or replace function private.is_event_leader(p_user uuid, p_event uuid)
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
revoke all on function private.is_event_leader(uuid, uuid) from public, anon, authenticated;
grant execute on function private.is_event_leader(uuid, uuid) to authenticated;

-- Signup submissions: select, update and delete policies call this.
create or replace function private.can_manage_event_signups(check_user uuid, check_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$ select private.is_event_leader(check_user, check_event); $$;

-- Media authority is the same set of people; keep one definition.
create or replace function private.can_manage_event_media_for_event(p_user uuid, p_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$ select private.is_event_leader(p_user, p_event); $$;

notify pgrst, 'reload schema';
