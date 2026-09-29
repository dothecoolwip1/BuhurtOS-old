-- Public organization data is exposed through narrow, security-definer
-- catalog functions rather than direct table grants.

create function public.public_team(p_team_id uuid)
returns table (
  id uuid,
  organization_id uuid,
  club_id uuid,
  name text,
  short_name text,
  city_or_region text,
  public_description text,
  website_url text
)
language sql
stable
security definer
set search_path=''
as $$
  select t.id,t.organization_id,t.club_id,t.name,t.short_name,t.city_or_region,
         t.public_description,t.website_url
  from public.teams t
  where t.id=p_team_id
    and t.visibility='public'
    and t.is_active
    and t.deleted_at is null;
$$;

create function public.public_club(p_club_id uuid)
returns table (
  id uuid,
  organization_id uuid,
  name text,
  short_name text,
  region text,
  public_description text,
  logo_path text,
  website_url text
)
language sql
stable
security definer
set search_path=''
as $$
  select c.id,c.organization_id,c.name,c.short_name,c.region,c.public_description,
         c.logo_path,c.website_url
  from public.clubs c
  where c.id=p_club_id
    and c.visibility='public'
    and c.deleted_at is null;
$$;

revoke all on function public.public_team(uuid) from public;
revoke all on function public.public_club(uuid) from public;
grant execute on function public.public_team(uuid) to anon,authenticated;
grant execute on function public.public_club(uuid) to anon,authenticated;
