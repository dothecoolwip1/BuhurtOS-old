-- Public prominence: which organizations and teams BuhurtOS chooses to emphasize on the public site.
-- DISPLAY PRIORITY ONLY. It never affects permissions, data ownership, ranking authority, existence or
-- public accessibility, and it does not mean an organization endorsed or partnered with BuhurtOS.

alter table public.organizations
  add column if not exists featured boolean not null default false,
  add column if not exists featured_order integer;
alter table public.teams
  add column if not exists featured boolean not null default false,
  add column if not exists featured_order integer;

comment on column public.organizations.featured is 'Display priority only: BuhurtOS is emphasizing this organization in the current release. Not an endorsement.';
comment on column public.teams.featured is 'Display priority only: shown on the featured teams view. Not an endorsement or verification.';

-- Not granted to anon/authenticated directly (default privileges are revoked); exposed through the functions below.

update public.organizations set featured = true, featured_order = 1 where short_name = 'BI';
update public.organizations set featured = true, featured_order = 2 where short_name = 'HACSA';

-- Feature the HACSA teams. The imported duplicate "Reavers" row is left out until the owner links it to Red Deer Reavers.
update public.teams t
   set featured = true,
       featured_order = case when t.directory_slug = 'red-deer-reavers' then 1 else 10 end
  from public.organizations o
 where o.id = t.organization_id and o.short_name = 'HACSA' and t.deleted_at is null and t.directory_slug <> 'reavers';

create or replace function private.public_featured_organizations()
returns table (organization_id uuid, organization_short_name text, featured_order integer)
language sql stable security definer set search_path = ''
as $$
  select o.id, o.short_name, o.featured_order
    from public.organizations o
   where o.featured
   order by o.featured_order nulls last, o.name;
$$;

create or replace function public.public_featured_organizations()
returns table (organization_id uuid, organization_short_name text, featured_order integer)
language sql stable set search_path = ''
as $$ select * from private.public_featured_organizations(); $$;

create or replace function private.public_featured_team_ids()
returns table (team_id uuid, featured_order integer)
language sql stable security definer set search_path = ''
as $$
  select t.id, t.featured_order
    from public.teams t
   where t.featured and t.deleted_at is null and t.visibility = 'public' and t.is_active and t.status = 'active';
$$;

-- Same row shape as public_team_directory_v3, restricted to featured teams.
create or replace function public.public_featured_teams()
returns table (
  id uuid, directory_slug text, organization_id uuid, organization_name text, organization_short_name text, team_name text,
  city_or_region text, continent_code text, continent_name text, country_code text, country_name text, admin_area_code text,
  admin_area_name text, public_contact_email text, website_url text, logo_path text, public_description text,
  public_latitude double precision, public_longitude double precision, captain text, rank_5v5 numeric, average_points_5v5 numeric,
  points_5v5 numeric, rank_12v12 numeric, points_12v12 numeric, source_kind text, source_url text, source_contact_url text,
  source_verified_at timestamp with time zone
)
language sql stable set search_path = public
as $$
  select d.*
    from public.public_team_directory_v2() d
    join private.public_featured_team_ids() f on f.team_id = d.id
   order by f.featured_order nulls last, d.team_name;
$$;

revoke all on function private.public_featured_organizations() from public, anon, authenticated;
revoke all on function private.public_featured_team_ids() from public, anon, authenticated;
grant execute on function private.public_featured_organizations() to anon, authenticated;
grant execute on function private.public_featured_team_ids() to anon, authenticated;
revoke all on function public.public_featured_organizations() from public;
revoke all on function public.public_featured_teams() from public;
grant execute on function public.public_featured_organizations() to anon, authenticated;
grant execute on function public.public_featured_teams() to anon, authenticated;

notify pgrst, 'reload schema';
