-- One-time owner cleanup for project tapfpboszgoftbwcwsmn (BuhurtOS). NOT applied automatically.
-- Run it in the Supabase SQL editor after reading it. It runs as a single transaction block.
--
-- What it does
--  1. Keeps ONE team: "Red Deer Reavers" (the native record that owns /teams/red-deer-reavers and hosts the Rumble).
--  2. Moves the HACSA + BI source records and public roster names from the duplicate "Reavers" row onto it,
--     and copies the duplicate's public website, logo, map pin and listed contact email where the native row is empty.
--  3. Retires the duplicate row reversibly (soft delete: deleted_at set, status archived) and links it as an alias.
--  4. Sets events.host_team_id for the Red Deer Rumble.
--  5. garrettrobson95@gmail.com  -> platform admin only (ends its Red Deer Reavers team_admin period, removes event organizer rows).
--  6. dothecoolwip@gmail.com     -> fighting + Reavers account: removes the test HACSA organization_admin role (revokes
--     the redemption, disables the test code) and adds a Red Deer Reavers membership (role: fighter) linked to the
--     "Dad Bod" fighter profile so it appears on the public Reavers roster.
--
-- Leaves alone: "Portland Reavers" (a different BI team).
--
-- To undo step 3:  update public.teams set deleted_at = null, is_active = true, status = 'active', visibility = 'public'
--                  where id = '2f2c7b31-e9b6-5e6f-84da-0e95626fbf7c';
--                  (and delete from public.team_canonical_links where alias_team_id = that id)

do $$
declare
  v_alias uuid := '2f2c7b31-e9b6-5e6f-84da-0e95626fbf7c';   -- "Reavers" (HACSA/BI listing)
  v_canon uuid := 'e8a655d9-7292-4ee5-b46b-11e80fd57a99';   -- "Red Deer Reavers" (keep)
  v_admin uuid := '5c9787ed-5911-4d8b-a3c5-460ddea6b17c';   -- garrettrobson95@gmail.com
  v_fighter uuid := '048fcefc-29c3-4886-9b8a-83fd9e6b5d10'; -- dothecoolwip@gmail.com
  v_identity uuid := 'e2ef71b4-94d4-43cf-b1fb-ac034b08fdf5'; -- public fighter profile "The Dad Bod"
begin
  update public.team_source_records set team_id = v_canon where team_id = v_alias;
  update public.team_public_roster_sources set team_id = v_canon where team_id = v_alias;

  update public.teams c set
    public_contact_email = coalesce(c.public_contact_email, a.public_contact_email),
    website_url = coalesce(c.website_url, a.website_url),
    public_latitude = coalesce(c.public_latitude, a.public_latitude),
    public_longitude = coalesce(c.public_longitude, a.public_longitude),
    logo_path = coalesce(c.logo_path, a.logo_path),
    country_name = coalesce(c.country_name, a.country_name),
    admin_area_name = coalesce(c.admin_area_name, a.admin_area_name),
    continent_name = coalesce(c.continent_name, a.continent_name)
  from public.teams a where c.id = v_canon and a.id = v_alias;

  insert into public.team_canonical_links(alias_team_id, canonical_team_id, reason)
  values (v_alias, v_canon, 'Duplicate listing of Red Deer Reavers; owner chose the native record as the only team.')
  on conflict (alias_team_id) do nothing;
  update public.teams set deleted_at = now(), is_active = false, status = 'archived', visibility = 'private' where id = v_alias;

  update public.events set host_team_id = v_canon where id = '6028e471-a95c-4d8a-8101-1f168bc68c8b';

  update public.team_memberships set ends_on = current_date where user_id = v_admin and team_id = v_canon and ends_on is null;
  delete from public.event_memberships where user_id = v_admin;

  update public.delegated_access_code_redemptions set revoked_at = now() where user_id = v_fighter and revoked_at is null;
  update public.delegated_access_codes set disabled_at = coalesce(disabled_at, now()) where id = '9c0e0675-6d07-4bd8-8be7-b2848ee032a2';
  delete from public.organization_memberships where user_id = v_fighter;
  insert into public.team_memberships(team_id, user_id, fighter_identity_id, role, display_name)
  values (v_canon, v_fighter, v_identity, 'fighter', 'Garrett Robson');

  insert into public.audit_log(actor_user_id, table_name, record_id, action, payload)
  values (v_admin, 'teams', v_alias, 'owner_consolidated_red_deer_reavers',
    jsonb_build_object('canonical', v_canon, 'fighterAccount', v_fighter, 'adminAccount', v_admin));
end $$;
