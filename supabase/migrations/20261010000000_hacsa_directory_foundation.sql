-- HACSA directory and geographic hierarchy foundation.
-- Live source verified 2026-09-29: https://www.hacsacanada.com/teams
--
-- Directory hierarchy is organization/source -> continent -> country ->
-- state/province -> canonical team. Source records preserve the exact published
-- values so later BI imports can enrich the same canonical teams without
-- overwriting HACSA facts.

alter table public.teams
  add column if not exists directory_slug text,
  add column if not exists continent_code text,
  add column if not exists continent_name text,
  add column if not exists country_code text,
  add column if not exists country_name text,
  add column if not exists admin_area_code text,
  add column if not exists admin_area_name text;

create unique index if not exists teams_directory_slug_key
  on public.teams(directory_slug)
  where directory_slug is not null;

create index if not exists teams_directory_geography_idx
  on public.teams(organization_id, continent_code, country_code, admin_area_code, city_or_region)
  where deleted_at is null;

create table if not exists public.team_source_records (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  source_kind text not null check (source_kind in ('hacsa','bi_teams','bi_ranking')),
  source_record_key text not null,
  source_url text not null,
  source_team_name text not null,
  source_location text,
  source_contact_email text,
  source_website_url text,
  source_contact_url text,
  source_priority smallint not null default 100 check (source_priority > 0),
  source_payload jsonb not null default '{}'::jsonb,
  verified_at timestamptz not null,
  last_synced_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (source_kind, source_record_key),
  unique (team_id, source_kind)
);

alter table public.team_source_records enable row level security;

revoke all privileges on table public.team_source_records from anon, authenticated;
grant all privileges on table public.team_source_records to service_role;

create index if not exists team_source_records_team_id_idx
  on public.team_source_records(team_id);

create index if not exists team_source_records_source_kind_idx
  on public.team_source_records(source_kind, source_priority, source_team_name);

insert into public.organizations (
  id, name, short_name, region, description, status, kind, country_code,
  visibility, website_url
)
values (
  '46b106c2-59d3-5053-9ecc-aa71778a581e',
  'Historical Armored Combat Sports Association',
  'HACSA',
  'Canada',
  'Canadian armored combat association represented in BuhurtOS from HACSA public sources.',
  'active',
  'national_federation',
  'CA',
  'public',
  'https://www.hacsacanada.com'
)
on conflict (id) do update set
  name = excluded.name,
  short_name = excluded.short_name,
  region = excluded.region,
  description = excluded.description,
  status = excluded.status,
  kind = excluded.kind,
  country_code = excluded.country_code,
  visibility = excluded.visibility,
  website_url = excluded.website_url,
  updated_at = timezone('utc', now());

insert into public.teams (
  id, organization_id, name, city_or_region, is_active, status, visibility,
  public_description, website_url, public_contact_email, directory_slug,
  continent_code, continent_name, country_code, country_name, admin_area_code, admin_area_name
)
values
  ('5d10339e-5f1f-5eaf-bd3b-be347e4d7e02','46b106c2-59d3-5053-9ecc-aa71778a581e','The Company of the Silver Gryphons','Calgary (North)',true,'active','public','Current public HACSA team listing.',null,'SilverGryphons@hacsacanada.com','silver-gryphons','NA','North America','CA','Canada','AB','Alberta'),
  ('a650266e-ec13-5f28-b49c-9d714e922b3a','46b106c2-59d3-5053-9ecc-aa71778a581e','Horde','Drayton Valley',true,'active','public','Current public HACSA team listing.',null,'brozell.br@gmail.com','horde','NA','North America','CA','Canada','AB','Alberta'),
  ('bb951b9b-37db-5552-9583-c03e7e4dd6df','46b106c2-59d3-5053-9ecc-aa71778a581e','The Crimson Blades','West Edmonton',true,'active','public','Current public HACSA team listing.',null,'info@hacsacanada.com','crimson-blades','NA','North America','CA','Canada','AB','Alberta'),
  ('c635864d-1912-5f79-8313-bbb221d1ce57','46b106c2-59d3-5053-9ecc-aa71778a581e','The Company of the Black Spears','Lethbridge',true,'active','public','Current public HACSA team listing.',null,'lethbridgeblackspears@gmail.com','black-spears','NA','North America','CA','Canada','AB','Alberta'),
  ('93a5985b-c896-5c47-b298-6770fb49db83','46b106c2-59d3-5053-9ecc-aa71778a581e','Mace Company Manitoba','Winnipeg',true,'active','public','Current public HACSA team listing.','https://macecompany.ca','macecompanymanitoba@gmail.com','mace-company-manitoba','NA','North America','CA','Canada','MB','Manitoba'),
  ('2f2c7b31-e9b6-5e6f-84da-0e95626fbf7c','46b106c2-59d3-5053-9ecc-aa71778a581e','Reavers','Red Deer',true,'active','public','Current public HACSA team listing.',null,'kedrixx.streit@gmail.com','reavers','NA','North America','CA','Canada','AB','Alberta'),
  ('37f2d522-716a-5eae-b134-7621a107edde','46b106c2-59d3-5053-9ecc-aa71778a581e','The Oath Bearers','Regina',true,'active','public','Current public HACSA team listing.',null,'Duster18@hotmail.com','oath-bearers','NA','North America','CA','Canada','SK','Saskatchewan'),
  ('2a3bea9c-6fc1-5b38-8658-fea020b5fd3c','46b106c2-59d3-5053-9ecc-aa71778a581e','Vanguard','Vancouver',true,'active','public','Current public HACSA team listing.',null,'vancityvanguard@gmail.com','vanguard','NA','North America','CA','Canada','BC','British Columbia'),
  ('d11952da-9e05-5628-a6ff-858d4328d4e7','46b106c2-59d3-5053-9ecc-aa71778a581e','Strathcona Warhorse','East Edmonton',true,'active','public','Current public HACSA team listing.',null,'strathconawarhorse@gmail.com','strathcona-warhorse','NA','North America','CA','Canada','AB','Alberta'),
  ('d753ed37-a6f6-5e2c-a14c-ff95eb3105f8','46b106c2-59d3-5053-9ecc-aa71778a581e','Arverni Legion','Alberta Foothills',true,'active','public','Current public HACSA team listing.',null,'Arverni_legion@outlook.com','arverni-legion','NA','North America','CA','Canada','AB','Alberta')
on conflict (id) do update set
  organization_id = excluded.organization_id,
  name = excluded.name,
  city_or_region = excluded.city_or_region,
  is_active = excluded.is_active,
  status = excluded.status,
  visibility = excluded.visibility,
  public_description = excluded.public_description,
  website_url = excluded.website_url,
  public_contact_email = excluded.public_contact_email,
  directory_slug = excluded.directory_slug,
  continent_code = excluded.continent_code,
  continent_name = excluded.continent_name,
  country_code = excluded.country_code,
  country_name = excluded.country_name,
  admin_area_code = excluded.admin_area_code,
  admin_area_name = excluded.admin_area_name,
  updated_at = timezone('utc', now());

insert into public.team_source_records (
  team_id, source_kind, source_record_key, source_url, source_team_name,
  source_location, source_contact_email, source_website_url, source_contact_url,
  source_priority, source_payload, verified_at
)
values
  ('5d10339e-5f1f-5eaf-bd3b-be347e4d7e02','hacsa','silver-gryphons','https://www.hacsacanada.com/teams','The Company of the Silver Gryphons','Calgary (North)','SilverGryphons@hacsacanada.com',null,'https://www.facebook.com/mike.diaz.779',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('a650266e-ec13-5f28-b49c-9d714e922b3a','hacsa','horde','https://www.hacsacanada.com/teams','Horde','Drayton Valley','brozell.br@gmail.com',null,'https://m.me/.billy.rozell',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('bb951b9b-37db-5552-9583-c03e7e4dd6df','hacsa','crimson-blades','https://www.hacsacanada.com/teams','The Crimson Blades','West Edmonton','info@hacsacanada.com',null,'https://m.me/.george.soika',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('c635864d-1912-5f79-8313-bbb221d1ce57','hacsa','black-spears','https://www.hacsacanada.com/teams','The Company of the Black Spears','Lethbridge','lethbridgeblackspears@gmail.com',null,'https://m.me/.brian.boisson.9',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('93a5985b-c896-5c47-b298-6770fb49db83','hacsa','mace-company-manitoba','https://www.hacsacanada.com/teams','Mace Company Manitoba','Winnipeg','macecompanymanitoba@gmail.com','https://macecompany.ca','https://www.facebook.com/profile.php?id=61586808193807',1,'{"normalized_province":"Manitoba","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('2f2c7b31-e9b6-5e6f-84da-0e95626fbf7c','hacsa','reavers','https://www.hacsacanada.com/teams','Reavers','Red Deer','kedrixx.streit@gmail.com',null,'https://www.facebook.com/profile.php?id=100081119922743&mibextid=ZbWKwL',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('37f2d522-716a-5eae-b134-7621a107edde','hacsa','oath-bearers','https://www.hacsacanada.com/teams','The Oath Bearers','Regina','Duster18@hotmail.com',null,'https://m.me/.patrick.c.depaulo',1,'{"normalized_province":"Saskatchewan","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('2a3bea9c-6fc1-5b38-8658-fea020b5fd3c','hacsa','vanguard','https://www.hacsacanada.com/teams','Vanguard','Vancouver','vancityvanguard@gmail.com',null,'https://m.me/.josh.caldwellmaki',1,'{"normalized_province":"British Columbia","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('d11952da-9e05-5628-a6ff-858d4328d4e7','hacsa','strathcona-warhorse','https://www.hacsacanada.com/teams','Strathcona Warhorse','East Edmonton','strathconawarhorse@gmail.com',null,'https://www.facebook.com/profile.php?id=100009466462258&mibextid=ZbWKwL',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z'),
  ('d753ed37-a6f6-5e2c-a14c-ff95eb3105f8','hacsa','arverni-legion','https://www.hacsacanada.com/teams','Arverni Legion','Alberta Foothills','Arverni_legion@outlook.com',null,'https://m.me/.rneilson31',1,'{"normalized_province":"Alberta","normalized_country":"Canada","normalized_continent":"North America"}','2026-09-29T00:00:00Z')
on conflict (source_kind, source_record_key) do update set
  team_id = excluded.team_id,
  source_url = excluded.source_url,
  source_team_name = excluded.source_team_name,
  source_location = excluded.source_location,
  source_contact_email = excluded.source_contact_email,
  source_website_url = excluded.source_website_url,
  source_contact_url = excluded.source_contact_url,
  source_priority = excluded.source_priority,
  source_payload = excluded.source_payload,
  verified_at = excluded.verified_at,
  last_synced_at = timezone('utc', now()),
  updated_at = timezone('utc', now());

create or replace function public.public_team_directory(
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
  source_kind text,
  source_url text,
  source_contact_url text,
  source_verified_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    t.id,
    t.directory_slug,
    o.id,
    o.name,
    o.short_name,
    t.name,
    t.city_or_region,
    t.continent_code,
    t.continent_name,
    t.country_code,
    t.country_name,
    t.admin_area_code,
    t.admin_area_name,
    coalesce(src.source_contact_email, t.public_contact_email),
    coalesce(src.source_website_url, t.website_url),
    src.source_kind,
    src.source_url,
    src.source_contact_url,
    src.verified_at
  from public.teams t
  join public.organizations o on o.id = t.organization_id
  left join lateral (
    select s.*
    from public.team_source_records s
    where s.team_id = t.id
    order by s.source_priority asc, s.verified_at desc
    limit 1
  ) src on true
  where t.visibility = 'public'
    and t.is_active
    and t.deleted_at is null
    and o.visibility = 'public'
    and o.status = 'active'
    and (p_organization_short_name is null or lower(o.short_name) = lower(p_organization_short_name))
    and (p_continent_code is null or t.continent_code = p_continent_code)
    and (p_country_code is null or t.country_code = p_country_code)
    and (p_admin_area_code is null or t.admin_area_code = p_admin_area_code)
    and (p_team_slug is null or t.directory_slug = p_team_slug)
  order by o.short_name, t.continent_code, t.country_code, t.admin_area_name, t.city_or_region, t.name;
$$;

revoke all on function public.public_team_directory(text,text,text,text,text) from public;
grant execute on function public.public_team_directory(text,text,text,text,text) to anon, authenticated;
