-- BI public directory enrichment: reproducible schema for live source-backed team profiles.
alter table public.teams add column if not exists public_latitude double precision;
alter table public.teams add column if not exists public_longitude double precision;

comment on column public.teams.public_latitude is 'Approximate public map latitude only; never a private street/home location.';
comment on column public.teams.public_longitude is 'Approximate public map longitude only; never a private street/home location.';

create table if not exists public.team_public_roster_sources (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  display_name text not null,
  role text not null default 'fighter' check (role in ('captain','fighter','coach','support')),
  source_kind text not null,
  source_url text not null,
  source_record_key text,
  verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (team_id, display_name, source_kind)
);

alter table public.team_public_roster_sources enable row level security;
revoke all on public.team_public_roster_sources from anon, authenticated;
grant all on public.team_public_roster_sources to service_role;

-- Public consumers only use curated SECURITY DEFINER functions. Do not expose raw membership rows.
drop policy if exists "team_memberships_anon_public_roster_read" on public.team_memberships;
revoke select on public.team_memberships from anon;

create or replace function public.public_team_map()
returns table(
  team_id uuid,
  directory_slug text,
  team_name text,
  organization_short_name text,
  city_or_region text,
  continent_code text,
  continent_name text,
  country_code text,
  country_name text,
  admin_area_code text,
  admin_area_name text,
  public_latitude double precision,
  public_longitude double precision
)
language sql
stable
security definer
set search_path = public
as $$
  select t.id,t.directory_slug,t.name,o.short_name,t.city_or_region,
         t.continent_code,t.continent_name,t.country_code,t.country_name,
         t.admin_area_code,t.admin_area_name,t.public_latitude,t.public_longitude
  from public.teams t
  join public.organizations o on o.id=t.organization_id
  where t.deleted_at is null
    and t.visibility='public'
    and t.public_latitude is not null
    and t.public_longitude is not null
  order by t.name;
$$;
revoke all on function public.public_team_map() from public;
grant execute on function public.public_team_map() to anon,authenticated;

create or replace function public.public_team_directory_all()
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
  public_latitude double precision,
  public_longitude double precision,
  source_kind text,
  source_url text,
  source_contact_url text,
  source_verified_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select t.id,t.directory_slug,t.organization_id,o.name,o.short_name,t.name,t.city_or_region,
         t.continent_code,t.continent_name,t.country_code,t.country_name,t.admin_area_code,t.admin_area_name,
         t.public_contact_email,t.website_url,t.public_latitude,t.public_longitude,
         s.source_kind::text,s.source_url,s.source_contact_url,s.verified_at
  from public.teams t
  join public.organizations o on o.id=t.organization_id
  left join lateral (
    select sr.source_kind,sr.source_url,sr.source_contact_url,sr.verified_at
    from public.team_source_records sr
    where sr.team_id=t.id
    order by sr.source_priority asc,sr.verified_at desc nulls last
    limit 1
  ) s on true
  where t.deleted_at is null and t.visibility='public'
  order by coalesce(t.country_name,''),coalesce(t.admin_area_name,''),t.name;
$$;
revoke all on function public.public_team_directory_all() from public;
grant execute on function public.public_team_directory_all() to anon,authenticated;

drop function if exists public.public_team_roster(uuid);
create function public.public_team_roster(p_team_id uuid)
returns table(
  identity_id uuid,
  display_name text,
  nickname text,
  avatar_path text,
  bio text,
  public_region text,
  role text,
  source_kind text
)
language sql
stable
security definer
set search_path = public
as $$
  select fi.id,fi.display_name,fi.nickname,fi.avatar_path,fi.bio,fi.public_region,tm.role::text,'buhurtos'::text
  from public.team_memberships tm
  join public.fighter_identities fi on fi.id=tm.fighter_identity_id
  join public.teams t on t.id=tm.team_id
  where tm.team_id=p_team_id
    and tm.ends_on is null
    and t.deleted_at is null
    and t.visibility='public'
    and fi.deleted_at is null
    and fi.merged_into_identity_id is null
    and fi.profile_visibility='public'
  union all
  select null::uuid,r.display_name,null::text,null::text,null::text,null::text,r.role,r.source_kind
  from public.team_public_roster_sources r
  join public.teams t on t.id=r.team_id
  where r.team_id=p_team_id
    and t.deleted_at is null
    and t.visibility='public'
    and not exists (
      select 1
      from public.team_memberships tm
      join public.fighter_identities fi on fi.id=tm.fighter_identity_id
      where tm.team_id=p_team_id
        and tm.ends_on is null
        and lower(fi.display_name)=lower(r.display_name)
    )
  order by 2;
$$;
revoke all on function public.public_team_roster(uuid) from public;
grant execute on function public.public_team_roster(uuid) to anon,authenticated;

create or replace function public.public_team_directory_v2()
returns table(
  id uuid,directory_slug text,organization_id uuid,organization_name text,organization_short_name text,team_name text,
  city_or_region text,continent_code text,continent_name text,country_code text,country_name text,admin_area_code text,admin_area_name text,
  public_contact_email text,website_url text,logo_path text,public_description text,
  public_latitude double precision,public_longitude double precision,
  captain text,rank_5v5 numeric,average_points_5v5 numeric,points_5v5 numeric,rank_12v12 numeric,points_12v12 numeric,
  source_kind text,source_url text,source_contact_url text,source_verified_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select t.id,t.directory_slug,t.organization_id,o.name,o.short_name,t.name,t.city_or_region,
         t.continent_code,t.continent_name,t.country_code,t.country_name,t.admin_area_code,t.admin_area_name,
         t.public_contact_email,t.website_url,t.logo_path,t.public_description,t.public_latitude,t.public_longitude,
         bi.source_payload->>'captain',
         nullif(bi.source_payload->>'rank5v5','')::numeric,
         nullif(bi.source_payload->>'averagePoints5v5','')::numeric,
         nullif(bi.source_payload->>'points5v5','')::numeric,
         nullif(bi.source_payload->>'rank12v12','')::numeric,
         nullif(bi.source_payload->>'points12v12','')::numeric,
         p.source_kind::text,p.source_url,p.source_contact_url,p.verified_at
  from public.teams t
  join public.organizations o on o.id=t.organization_id
  left join lateral (
    select sr.source_kind,sr.source_url,sr.source_contact_url,sr.verified_at
    from public.team_source_records sr
    where sr.team_id=t.id
    order by sr.source_priority asc,sr.verified_at desc nulls last
    limit 1
  ) p on true
  left join lateral (
    select sr.source_payload
    from public.team_source_records sr
    where sr.team_id=t.id and sr.source_kind='bi_teams'
    limit 1
  ) bi on true
  where t.deleted_at is null and t.visibility='public'
  order by coalesce(t.country_name,''),coalesce(t.admin_area_name,''),t.name;
$$;
revoke all on function public.public_team_directory_v2() from public;
grant execute on function public.public_team_directory_v2() to anon,authenticated;

create or replace function public.public_team_detail(p_team_id uuid)
returns table(
  team_id uuid,logo_path text,public_description text,captain text,club text,gender text,conference text,country text,city text,
  training_info text,training_location jsonb,website_url text,public_contact_email text,
  rank_5v5 numeric,average_points_5v5 numeric,points_5v5 numeric,rank_12v12 numeric,points_12v12 numeric,
  tournaments_joined jsonb,events_history jsonb,source_url text,source_verified_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select t.id,t.logo_path,t.public_description,
         bi.source_payload->>'captain',bi.source_payload->>'club',bi.source_payload->>'gender',
         bi.source_payload->>'conference',coalesce(bi.source_payload->>'country',t.country_name),
         coalesce(bi.source_payload->>'city',t.city_or_region),
         bi.source_payload->>'trainingInfo',bi.source_payload->'trainingLocation',
         t.website_url,t.public_contact_email,
         nullif(bi.source_payload->>'rank5v5','')::numeric,
         nullif(bi.source_payload->>'averagePoints5v5','')::numeric,
         nullif(bi.source_payload->>'points5v5','')::numeric,
         nullif(bi.source_payload->>'rank12v12','')::numeric,
         nullif(bi.source_payload->>'points12v12','')::numeric,
         coalesce(bi.source_payload->'tournamentsJoined','[]'::jsonb),
         coalesce(bi.source_payload->'eventsHistory','{}'::jsonb),
         bi.source_url,bi.verified_at
  from public.teams t
  left join public.team_source_records bi on bi.team_id=t.id and bi.source_kind='bi_teams'
  where t.id=p_team_id
    and t.deleted_at is null
    and t.visibility='public'
  limit 1;
$$;
revoke all on function public.public_team_detail(uuid) from public;
grant execute on function public.public_team_detail(uuid) to anon,authenticated;
