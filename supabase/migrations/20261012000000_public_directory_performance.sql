-- Public directory performance and stable Red Deer Reavers routing.

update public.teams
set directory_slug='red-deer-reavers',
    updated_at=now()
where id='e8a655d9-7292-4ee5-b46b-11e80fd57a99'
  and directory_slug is distinct from 'red-deer-reavers';

create or replace function public.public_team_directory_v3(
  p_organization_short_name text default null,
  p_continent_code text default null,
  p_country_code text default null,
  p_admin_area_code text default null,
  p_team_slug text default null
)
returns table(
  id uuid,
  directory_slug text,
  organization_id uuid,
  organization_name text,
  organization_short_name text,
  team_name text,
  city_or_region text,
  continent_code text,
  continent_name text,
  country_code text,
  country_name text,
  admin_area_code text,
  admin_area_name text,
  public_contact_email text,
  website_url text,
  logo_path text,
  public_description text,
  public_latitude double precision,
  public_longitude double precision,
  captain text,
  rank_5v5 numeric,
  average_points_5v5 numeric,
  points_5v5 numeric,
  rank_12v12 numeric,
  points_12v12 numeric,
  source_kind text,
  source_url text,
  source_contact_url text,
  source_verified_at timestamptz
)
language sql
stable
security definer
set search_path='public'
as $$
  select *
  from public.public_team_directory_v2() d
  where (p_organization_short_name is null or lower(d.organization_short_name)=lower(p_organization_short_name))
    and (p_continent_code is null or d.continent_code=p_continent_code)
    and (p_country_code is null or d.country_code=p_country_code)
    and (p_admin_area_code is null or d.admin_area_code=p_admin_area_code)
    and (p_team_slug is null or d.directory_slug=p_team_slug or d.id::text=p_team_slug);
$$;

revoke all on function public.public_team_directory_v3(text,text,text,text,text) from public;
grant execute on function public.public_team_directory_v3(text,text,text,text,text) to anon,authenticated;

create or replace function public.public_organization_directory_summary()
returns table(
  organization_id uuid,
  organization_name text,
  organization_short_name text,
  region text,
  kind text,
  website_url text,
  description text,
  team_count bigint,
  roster_count bigint,
  country_count bigint
)
language sql
stable
security definer
set search_path='public'
as $$
  with public_teams as (
    select t.id,t.organization_id,t.country_code
    from public.teams t
    where t.deleted_at is null
      and t.visibility='public'
      and t.is_active
      and t.status='active'
  ),
  roster_totals as (
    select pt.organization_id,count(*)::bigint as roster_count
    from public_teams pt
    join public.team_public_roster_sources r on r.team_id=pt.id
    group by pt.organization_id
  ),
  live_members as (
    select pt.organization_id,count(*)::bigint as live_count
    from public_teams pt
    join public.team_memberships tm on tm.team_id=pt.id and tm.ends_on is null
    join public.fighter_identities fi on fi.id=tm.fighter_identity_id
      and fi.deleted_at is null
      and fi.merged_into_identity_id is null
      and fi.profile_visibility='public'
    group by pt.organization_id
  )
  select
    o.id,
    o.name,
    o.short_name,
    o.region,
    o.kind::text,
    o.website_url,
    o.description,
    count(pt.id)::bigint as team_count,
    coalesce(rt.roster_count,0)+coalesce(lm.live_count,0) as roster_count,
    count(distinct nullif(pt.country_code,''))::bigint as country_count
  from public.organizations o
  join public_teams pt on pt.organization_id=o.id
  left join roster_totals rt on rt.organization_id=o.id
  left join live_members lm on lm.organization_id=o.id
  where o.status='active'
    and o.visibility='public'
  group by o.id,rt.roster_count,lm.live_count
  order by o.name;
$$;

revoke all on function public.public_organization_directory_summary() from public;
grant execute on function public.public_organization_directory_summary() to anon,authenticated;

create index if not exists teams_public_directory_filter_idx
  on public.teams(organization_id,continent_code,country_code,admin_area_code,directory_slug)
  where deleted_at is null and visibility='public' and is_active and status='active';

create index if not exists team_public_roster_sources_team_idx
  on public.team_public_roster_sources(team_id);

create index if not exists team_memberships_public_team_idx
  on public.team_memberships(team_id)
  where ends_on is null;


-- Keep newly added public RPCs as invoker endpoints. The aggregate implementation
-- lives in the private schema so the public API does not add new SECURITY DEFINER warnings.
create or replace function public.public_team_directory_v3(
  p_organization_short_name text default null,
  p_continent_code text default null,
  p_country_code text default null,
  p_admin_area_code text default null,
  p_team_slug text default null
)
returns table(
  id uuid,directory_slug text,organization_id uuid,organization_name text,organization_short_name text,
  team_name text,city_or_region text,continent_code text,continent_name text,country_code text,country_name text,
  admin_area_code text,admin_area_name text,public_contact_email text,website_url text,logo_path text,
  public_description text,public_latitude double precision,public_longitude double precision,captain text,
  rank_5v5 numeric,average_points_5v5 numeric,points_5v5 numeric,rank_12v12 numeric,points_12v12 numeric,
  source_kind text,source_url text,source_contact_url text,source_verified_at timestamptz
)
language sql stable security invoker set search_path='public'
as $$
  select *
  from public.public_team_directory_v2() d
  where (p_organization_short_name is null or lower(d.organization_short_name)=lower(p_organization_short_name))
    and (p_continent_code is null or d.continent_code=p_continent_code)
    and (p_country_code is null or d.country_code=p_country_code)
    and (p_admin_area_code is null or d.admin_area_code=p_admin_area_code)
    and (p_team_slug is null or d.directory_slug=p_team_slug or d.id::text=p_team_slug);
$$;

create or replace function private.public_organization_directory_summary()
returns table(
  organization_id uuid,organization_name text,organization_short_name text,region text,kind text,
  website_url text,description text,team_count bigint,roster_count bigint,country_count bigint
)
language sql stable security definer set search_path=''
as $$
  with public_teams as (
    select t.id,t.organization_id,t.country_code
    from public.teams t
    where t.deleted_at is null and t.visibility='public' and t.is_active and t.status='active'
  ),
  roster_totals as (
    select pt.organization_id,count(*)::bigint as roster_count
    from public_teams pt
    join public.team_public_roster_sources r on r.team_id=pt.id
    group by pt.organization_id
  ),
  live_members as (
    select pt.organization_id,count(*)::bigint as live_count
    from public_teams pt
    join public.team_memberships tm on tm.team_id=pt.id and tm.ends_on is null
    join public.fighter_identities fi on fi.id=tm.fighter_identity_id
      and fi.deleted_at is null
      and fi.merged_into_identity_id is null
      and fi.profile_visibility='public'
    group by pt.organization_id
  )
  select o.id,o.name,o.short_name,o.region,o.kind::text,o.website_url,o.description,
         count(pt.id)::bigint,
         coalesce(rt.roster_count,0)+coalesce(lm.live_count,0),
         count(distinct nullif(pt.country_code,''))::bigint
  from public.organizations o
  join public_teams pt on pt.organization_id=o.id
  left join roster_totals rt on rt.organization_id=o.id
  left join live_members lm on lm.organization_id=o.id
  where o.status='active' and o.visibility='public'
  group by o.id,rt.roster_count,lm.live_count
  order by o.name;
$$;

grant usage on schema private to anon,authenticated;
grant execute on function private.public_organization_directory_summary() to anon,authenticated;

create or replace function public.public_organization_directory_summary()
returns table(
  organization_id uuid,organization_name text,organization_short_name text,region text,kind text,
  website_url text,description text,team_count bigint,roster_count bigint,country_count bigint
)
language sql stable security invoker set search_path=''
as $$ select * from private.public_organization_directory_summary(); $$;
