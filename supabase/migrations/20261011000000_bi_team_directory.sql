-- Buhurt International source-backed team directory.
-- Source family: https://www.buhurtinternational.com/teams
-- Verified 2026-09-29. Ranking-page ingestion is intentionally deferred to
-- the next step; ranking values below come only from BI Teams directory cards.

alter table public.team_source_records
  add column if not exists source_evidence_kind text,
  add column if not exists source_conference text,
  add column if not exists source_captain text,
  add column if not exists source_gender text,
  add column if not exists source_continent_code text,
  add column if not exists source_continent_name text,
  add column if not exists source_country_code text,
  add column if not exists source_country_name text,
  add column if not exists source_admin_area_code text,
  add column if not exists source_admin_area_name text,
  add column if not exists source_rank_5v5 integer,
  add column if not exists source_average_points_5v5 numeric,
  add column if not exists source_total_points_5v5 numeric,
  add column if not exists source_rank_12v12 integer,
  add column if not exists source_average_points_12v12 numeric,
  add column if not exists source_total_points_12v12 numeric;

create table if not exists public.team_directory_memberships (
  team_id uuid not null,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  source_kind text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (organization_id, team_id, source_kind),
  foreign key (team_id, source_kind)
    references public.team_source_records(team_id, source_kind)
    on delete cascade
);

alter table public.team_directory_memberships enable row level security;
revoke all privileges on table public.team_directory_memberships from anon, authenticated;
grant all privileges on table public.team_directory_memberships to service_role;

create index if not exists team_directory_memberships_team_idx
  on public.team_directory_memberships(team_id);
create index if not exists team_directory_memberships_org_idx
  on public.team_directory_memberships(organization_id, source_kind)
  where is_active;

-- Backfill explicit source geography for the HACSA records created in Step 1.
update public.team_source_records s
set
  source_evidence_kind = coalesce(s.source_evidence_kind, 'current_directory'),
  source_continent_code = coalesce(s.source_continent_code, t.continent_code),
  source_continent_name = coalesce(s.source_continent_name, t.continent_name),
  source_country_code = coalesce(s.source_country_code, t.country_code),
  source_country_name = coalesce(s.source_country_name, t.country_name),
  source_admin_area_code = coalesce(s.source_admin_area_code, t.admin_area_code),
  source_admin_area_name = coalesce(s.source_admin_area_name, t.admin_area_name)
from public.teams t
where s.team_id=t.id and s.source_kind='hacsa';

insert into public.team_directory_memberships(team_id,organization_id,source_kind)
select s.team_id,t.organization_id,'hacsa'
from public.team_source_records s
join public.teams t on t.id=s.team_id
where s.source_kind='hacsa'
on conflict (organization_id,team_id,source_kind) do update
set is_active=true,updated_at=timezone('utc',now());

insert into public.organizations(
  id,name,short_name,region,description,status,kind,visibility,website_url
)
values(
  '7b46825b-ae7a-5cd3-9324-591946162ee3',
  'Buhurt International',
  'BI',
  'International',
  'International armored combat organization represented in BuhurtOS from Buhurt International public sources.',
  'active',
  'international_federation',
  'public',
  'https://www.buhurtinternational.com'
)
on conflict (id) do update set
  name=excluded.name,
  short_name=excluded.short_name,
  region=excluded.region,
  description=excluded.description,
  status=excluded.status,
  kind=excluded.kind,
  visibility=excluded.visibility,
  website_url=excluded.website_url,
  updated_at=timezone('utc',now());

create temporary table _bi_team_seed(
  slug text primary key,
  team_name text not null,
  conference text,
  country_code text not null,
  country_name text not null,
  continent_code text not null,
  continent_name text not null,
  source_location text,
  admin_area_code text,
  admin_area_name text,
  captain text,
  evidence_kind text not null,
  source_url text not null,
  rank_5v5 integer,
  average_5v5 numeric,
  total_5v5 numeric,
  rank_12v12 integer,
  average_12v12 numeric,
  total_12v12 numeric
) on commit drop;

insert into _bi_team_seed values
  ('knyaz-usa','Knyaz USA','North America','US','United States','NA','North America','Warren',null,null,'Andrew McCabe','current_directory','https://www.buhurtinternational.com/teams',1,18.08,54.25,null,null,6),
  ('white-company-m','White Company (m)','Europe','GB','United Kingdom','EU','Europe','Nottingham',null,null,'Daniel Winter','current_directory','https://www.buhurtinternational.com/teams',1,14.42,63.25,null,null,0),
  ('dragoons','Dragoons','North America','US','United States','NA','North America','Dallas, Texas','TX','Texas','Vincent Verheyden','current_directory','https://www.buhurtinternational.com/teams',2,14.08,42.25,null,null,0),
  ('invicta','Invicta','Europe','GB','United Kingdom','EU','Europe','London',null,null,'Rowland Longley','current_directory','https://www.buhurtinternational.com/teams',2,13.5,45.5,null,null,0),
  ('team-kraken','Team Kraken','APAC','AU','Australia','OC','Oceania','Melbourne','VIC','Victoria','Jake Taylor','current_directory','https://www.buhurtinternational.com/teams',1,12.67,38,null,null,0),
  ('pale-tempest','Pale Tempest','North America','US','United States','NA','North America',null,null,null,'Kyle James Olson','current_directory','https://www.buhurtinternational.com/teams',3,12,44,null,null,0),
  ('company-of-the-bear','Company of the Bear','North America','US','United States','NA','North America','Dublin, CA','CA','California','Colton "Zayl" hall','current_directory','https://www.buhurtinternational.com/teams',4,11.42,41.25,null,null,0),
  ('soldados','Soldados','North America','US','United States','NA','North America','Santa Barbara','CA','California','Mark Sanders','current_directory','https://www.buhurtinternational.com/teams',4,11.42,34.25,null,null,0),
  ('twin-cities-wyverns','Twin Cities Wyverns','North America','US','United States','NA','North America','Minneapolis','MN','Minnesota','Linden Holt','current_directory','https://www.buhurtinternational.com/teams',5,11,43.5,null,null,0),
  ('ordo-draconis','Ordo Draconis','North America','US','United States','NA','North America','San Diego','CA','California','Alexander Casillas','current_directory','https://www.buhurtinternational.com/teams',6,9.33,33.75,null,null,0),
  ('vagabonds','Vagabonds','North America','US','United States','NA','North America','Seattle, Washington','WA','Washington','Johny Porter','current_directory','https://www.buhurtinternational.com/teams',7,9.08,27.25,null,null,0),
  ('beastsm','Beasts(m)','APAC','AU','Australia','OC','Oceania','Brisbane','QLD','Queensland','Colin Campbell','current_directory','https://www.buhurtinternational.com/teams',2,9,27,null,null,10),
  ('team-havoc','Team Havoc','APAC','AU','Australia','OC','Oceania','Sydney','NSW','New South Wales','Mark O’Connor','current_directory','https://www.buhurtinternational.com/teams',3,8,26,null,null,1),
  ('order-of-the-silver-rose','Order of the Silver Rose','North America','US','United States','NA','North America','Salt Lake City','UT','Utah','Trevor Hutton','team_profile','https://www.buhurtinternational.com/team/order-of-the-silver-rose',null,null,null,null,null,null),
  ('mamanci','Mamánci','Europe','CZ','Czech Republic','EU','Europe','České Budějovice',null,null,'Vojtěch Pecha','team_profile','https://www.buhurtinternational.com/team/mam%C3%A1nci',null,null,null,null,null,null),
  ('the-forsaken','The Forsaken','North America','US','United States','NA','North America','York','PA','Pennsylvania','Drew Shipley','team_profile','https://www.buhurtinternational.com/team/the-forsaken',null,null,null,null,null,null),
  ('mfc-slezsko','MFC Slezsko','Europe','CZ','Czech Republic','EU','Europe','Ostrava',null,null,'Dalibor Bonček','team_profile','https://www.buhurtinternational.com/team/mfc-slezsko',null,null,null,null,null,null),
  ('iron-lions-vanguard','Iron Lions Vanguard','North America','US','United States','NA','North America','Fairfax, VA','VA','Virginia','Kevin Leclerc','team_profile','https://www.buhurtinternational.com/team/iron-lions-vanguard',null,null,null,null,null,null),
  ('atlanta-valor','Atlanta Valor','North America','US','United States','NA','North America','Atlanta','GA','Georgia','Trevor Crow','team_profile','https://www.buhurtinternational.com/team/atlanta-valor',null,null,null,null,null,null),
  ('warwolves','Warwolves','APAC','AU','Australia','OC','Oceania','Ballarat/Adelaide',null,null,'Daniel Cooper','team_profile','https://www.buhurtinternational.com/team/warwolves',null,null,null,null,null,null),
  ('ferreus-lupus','Ferreus Lupus','Europe','HU','Hungary','EU','Europe','Budapest',null,null,'Ujvári Ádám','team_profile','https://www.buhurtinternational.com/team/ferreus-lupus',null,null,null,null,null,null),
  ('ruhrpott-knights','Ruhrpott Knights','Europe','DE','Germany','EU','Europe','Duisburg',null,null,'Dennis Schürfeld','team_profile','https://www.buhurtinternational.com/team/ruhrpott-knights',null,null,null,null,null,null),
  ('river-sirens','River Sirens','North America','US','United States','NA','North America','Cincinnati','OH','Ohio','Jordan Shelton','team_profile','https://www.buhurtinternational.com/team/river-sirens',null,null,null,null,null,null),
  ('victrix','VICTRIX','Europe','ES','Spain','EU','Europe','Valencia',null,null,'Fernando Jose Minguet Gimeno','team_profile','https://www.buhurtinternational.com/team/victrix',null,null,null,null,null,null),
  ('akron-hedge-knights','Akron Hedge Knights','North America','US','United States','NA','North America','Akron Ohio','OH','Ohio','Craig Nihart','team_profile','https://www.buhurtinternational.com/team/akron-hedge-knights-',null,null,null,null,null,null),
  ('norsemen','Norsemen','Europe','NO','Norway','EU','Europe','OSLO',null,null,'Anders Gjestad Rugsveen','team_profile','https://www.buhurtinternational.com/team/norsemen',null,null,null,null,null,null),
  ('zitadelle-e-v','Zitadelle e.V.','Europe','DE','Germany','EU','Europe','Weilburg',null,null,'Marcel Jost','team_profile','https://www.buhurtinternational.com/team/zitadelle-e.v.',null,null,null,null,null,null),
  ('nassauer-lowen','Nassauer Löwen','Europe','DE','Germany','EU','Europe','Hessen','HE','Hesse','Mike Rusitschka','team_profile','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen',null,null,null,null,null,null),
  ('crimson-tulips','Crimson Tulips','North America','CA','Canada','NA','North America','Eastern Canada',null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/anne-von-wesselborg',null,null,null,null,null,null),
  ('ostlander','Ostlander','Europe','FR','France','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/amiot-luc',null,null,null,null,null,null),
  ('west-australian-berserkers','West Australian Berserkers','APAC','AU','Australia','OC','Oceania','Western Australia','WA','Western Australia',null,'licensed_fighter','https://www.buhurtinternational.com/fighter/luke-durber',null,null,null,null,null,null),
  ('isca','ISCA','Europe','GB','United Kingdom','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/simon-smite',null,null,null,null,null,null),
  ('mfc-vysocina','MFC Vysočina','Europe','CZ','Czech Republic','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/viktor-vacek',null,null,null,null,null,null),
  ('pikarti','Pikarti','Europe','CZ','Czech Republic','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/jakub-pazdera',null,null,null,null,null,null),
  ('team-vultures','Team Vultures','APAC','AU','Australia','OC','Oceania',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/darren-birch',null,null,null,null,null,null),
  ('tavastia-armigeri','Tavastia Armigeri','Eastern Europe','FI','Finland','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/juuso-sistonen',null,null,null,null,null,null),
  ('legenda-polnocy','Legenda Północy','Europe','PL','Poland','EU','Europe',null,null,null,null,'licensed_fighter','https://www.buhurtinternational.com/fighter/kacper-nowi%C5%84ski',null,null,null,null,null,null),
  ('illawarra-manticore-medieval-combat-inc','Illawarra Manticore Medieval Combat Inc',null,'AU','Australia','OC','Oceania',null,null,null,null,'licensed_fighters_directory','https://www.buhurtinternational.com/fighters',null,null,null,null,null,null),
  ('aros-buhurt-club','Aros Buhurt Club',null,'US','United States','NA','North America',null,null,null,null,'licensed_fighters_directory','https://www.buhurtinternational.com/fighters',null,null,null,null,null,null),
  ('the-new-order','The New Order',null,'US','United States','NA','North America','Central Iowa','IA','Iowa','Zachary Shadu','licensed_fighters_directory','https://www.buhurtinternational.com/fighters',null,null,null,null,null,null),
  ('twin-cites-wyverns-b-side','Twin Cites Wyverns B-Side',null,'US','United States','NA','North America',null,null,null,null,'licensed_fighters_directory','https://www.buhurtinternational.com/fighters',null,null,null,null,null,null),
  ('dfc-dire-wolves','DFC Dire Wolves',null,'US','United States','NA','North America',null,null,null,null,'licensed_fighters_directory','https://www.buhurtinternational.com/fighters',null,null,null,null,null,null),
  ('knyaz-uk-women','Knyaz UK Women','Europe','GB','United Kingdom','EU','Europe',null,null,null,null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('diex-aie','Diex Aïe','Europe','FR','France','EU','Europe','Normandy','NOR','Normandy',null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('graoully','Graoully','Europe','FR','France','EU','Europe','Metz',null,null,null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('pale-horse','Pale Horse','North America','US','United States','NA','North America','South Jersey','NJ','New Jersey',null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('carcassonne-warriors','Carcassonne Warriors','Europe','FR','France','EU','Europe','Carcassonne',null,null,null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('les-lys-de-france','Les Lys de France','Europe','FR','France','EU','Europe',null,null,null,null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null),
  ('les-comtois','Les Comtois','Europe','FR','France','EU','Europe','Franche-Comté','BFC','Bourgogne-Franche-Comté',null,'team_profile_article','https://www.buhurtinternational.com/blogs/categories/teams-profiles',null,null,null,null,null,null);

insert into public.teams(
  organization_id,name,city_or_region,is_active,status,visibility,
  public_description,directory_slug,continent_code,continent_name,country_code,
  country_name,admin_area_code,admin_area_name
)
select
  '7b46825b-ae7a-5cd3-9324-591946162ee3',
  s.team_name,s.source_location,true,'active','public',
  'Buhurt International source-backed team record.',
  s.slug,s.continent_code,s.continent_name,s.country_code,s.country_name,
  s.admin_area_code,s.admin_area_name
from _bi_team_seed s
on conflict (directory_slug) where directory_slug is not null do update set
  name=excluded.name,
  city_or_region=excluded.city_or_region,
  is_active=true,
  status='active',
  visibility='public',
  public_description=excluded.public_description,
  continent_code=excluded.continent_code,
  continent_name=excluded.continent_name,
  country_code=excluded.country_code,
  country_name=excluded.country_name,
  admin_area_code=excluded.admin_area_code,
  admin_area_name=excluded.admin_area_name,
  updated_at=timezone('utc',now());

insert into public.team_source_records(
  team_id,source_kind,source_record_key,source_url,source_team_name,source_location,
  source_priority,source_payload,verified_at,source_evidence_kind,source_conference,
  source_captain,source_continent_code,source_continent_name,source_country_code,
  source_country_name,source_admin_area_code,source_admin_area_name,
  source_rank_5v5,source_average_points_5v5,source_total_points_5v5,
  source_rank_12v12,source_average_points_12v12,source_total_points_12v12
)
select
  t.id,'bi_teams',s.slug,s.source_url,s.team_name,s.source_location,
  2,
  jsonb_build_object(
    'evidence_kind',s.evidence_kind,
    'source_family','Buhurt International Teams',
    'ranking_source_imported',false
  ),
  '2026-09-29T00:00:00Z',
  s.evidence_kind,s.conference,s.captain,s.continent_code,s.continent_name,
  s.country_code,s.country_name,s.admin_area_code,s.admin_area_name,
  s.rank_5v5,s.average_5v5,s.total_5v5,s.rank_12v12,s.average_12v12,s.total_12v12
from _bi_team_seed s
join public.teams t on t.directory_slug=s.slug
on conflict (source_kind,source_record_key) do update set
  team_id=excluded.team_id,
  source_url=excluded.source_url,
  source_team_name=excluded.source_team_name,
  source_location=excluded.source_location,
  source_priority=excluded.source_priority,
  source_payload=excluded.source_payload,
  verified_at=excluded.verified_at,
  source_evidence_kind=excluded.source_evidence_kind,
  source_conference=excluded.source_conference,
  source_captain=excluded.source_captain,
  source_continent_code=excluded.source_continent_code,
  source_continent_name=excluded.source_continent_name,
  source_country_code=excluded.source_country_code,
  source_country_name=excluded.source_country_name,
  source_admin_area_code=excluded.source_admin_area_code,
  source_admin_area_name=excluded.source_admin_area_name,
  source_rank_5v5=excluded.source_rank_5v5,
  source_average_points_5v5=excluded.source_average_points_5v5,
  source_total_points_5v5=excluded.source_total_points_5v5,
  source_rank_12v12=excluded.source_rank_12v12,
  source_average_points_12v12=excluded.source_average_points_12v12,
  source_total_points_12v12=excluded.source_total_points_12v12,
  last_synced_at=timezone('utc',now()),
  updated_at=timezone('utc',now());

insert into public.team_directory_memberships(team_id,organization_id,source_kind)
select
  t.id,'7b46825b-ae7a-5cd3-9324-591946162ee3','bi_teams'
from _bi_team_seed s
join public.teams t on t.directory_slug=s.slug
on conflict (organization_id,team_id,source_kind) do update
set is_active=true,updated_at=timezone('utc',now());

drop function if exists public.public_team_directory(text,text,text,text,text);

create function public.public_team_directory(
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
  source_verified_at timestamptz,
  source_evidence_kind text,
  source_conference text,
  source_captain text,
  source_rank_5v5 integer,
  source_average_points_5v5 numeric,
  source_total_points_5v5 numeric,
  source_rank_12v12 integer,
  source_average_points_12v12 numeric,
  source_total_points_12v12 numeric
)
language sql
stable
security definer
set search_path=''
as $$
  select
    t.id,
    t.directory_slug,
    o.id,
    o.name,
    o.short_name,
    src.source_team_name,
    coalesce(src.source_location,t.city_or_region),
    coalesce(src.source_continent_code,t.continent_code),
    coalesce(src.source_continent_name,t.continent_name),
    coalesce(src.source_country_code,t.country_code),
    coalesce(src.source_country_name,t.country_name),
    coalesce(src.source_admin_area_code,t.admin_area_code),
    coalesce(src.source_admin_area_name,t.admin_area_name),
    coalesce(src.source_contact_email,t.public_contact_email),
    coalesce(src.source_website_url,t.website_url),
    src.source_kind,
    src.source_url,
    src.source_contact_url,
    src.verified_at,
    src.source_evidence_kind,
    src.source_conference,
    src.source_captain,
    src.source_rank_5v5,
    src.source_average_points_5v5,
    src.source_total_points_5v5,
    src.source_rank_12v12,
    src.source_average_points_12v12,
    src.source_total_points_12v12
  from public.team_directory_memberships dm
  join public.teams t on t.id=dm.team_id
  join public.organizations o on o.id=dm.organization_id
  join public.team_source_records src
    on src.team_id=dm.team_id and src.source_kind=dm.source_kind
  where dm.is_active
    and t.visibility='public'
    and t.is_active
    and t.deleted_at is null
    and o.visibility='public'
    and o.status='active'
    and (p_organization_short_name is null or lower(o.short_name)=lower(p_organization_short_name))
    and (p_continent_code is null or coalesce(src.source_continent_code,t.continent_code)=p_continent_code)
    and (p_country_code is null or coalesce(src.source_country_code,t.country_code)=p_country_code)
    and (p_admin_area_code is null or coalesce(src.source_admin_area_code,t.admin_area_code)=p_admin_area_code)
    and (p_team_slug is null or t.directory_slug=p_team_slug)
  order by o.short_name,
    coalesce(src.source_continent_name,t.continent_name),
    coalesce(src.source_country_name,t.country_name),
    coalesce(src.source_admin_area_name,t.admin_area_name),
    coalesce(src.source_location,t.city_or_region),
    src.source_team_name;
$$;

revoke all on function public.public_team_directory(text,text,text,text,text) from public;
grant execute on function public.public_team_directory(text,text,text,text,text) to anon,authenticated;
