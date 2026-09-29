-- Members need to read the club/team record that their membership authorizes.
-- These are additive SELECT policies; existing organization and event policies
-- remain unchanged.

create policy clubs_pack4_member_read
  on public.clubs
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.club_memberships membership
      where membership.club_id=clubs.id
        and membership.user_id=(select auth.uid())
        and membership.ends_on is null
    )
  );

create policy teams_pack4_member_read
  on public.teams
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.team_memberships membership
      where membership.team_id=teams.id
        and membership.user_id=(select auth.uid())
        and membership.ends_on is null
    )
    or exists (
      select 1
      from public.club_memberships membership
      where membership.club_id=teams.club_id
        and membership.user_id=(select auth.uid())
        and membership.ends_on is null
    )
  );
