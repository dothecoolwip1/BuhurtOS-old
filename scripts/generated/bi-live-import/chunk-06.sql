begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='manticore' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-manticore' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Manticore','Łódź / Kraków',true,'active','public','bi-manticore','EU','Europe','PL','Poland','anna.mocko96@gmail.com',NULL,'https://static.wixstatic.com/media/4922bd_d4d9b6ed3ee84d66aa1c07d50aadb476~mv2.png','Manticore is a new female Buhurt team originating from Poland. It was formed on February 12th, 2026, connecting women from all over the country, with the main training facilities located in Łódź (connected to male team KS Rycerz) and Kraków (connected to male team Sierotki/KFC Buhurt). While the girls train in their own facilities on a daily basis, they get together for team training once a month.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','manticore','https://www.buhurtinternational.com/team/manticore','Manticore','Łódź / Kraków','anna.mocko96@gmail.com',NULL,20,'{"biCollectionId":"c8b3132f-f340-49bb-b5b6-375e81ebc47d","teamName":"Manticore","club":null,"gender":"Female","captain":"Anna Blausz","conference":"Europe","country":"Poland","city":"Łódź / Kraków","teamInfo":"Manticore is a new female Buhurt team originating from Poland. It was formed on February 12th, 2026, connecting women from all over the country, with the main training facilities located in Łódź (connected to male team KS Rycerz) and Kraków (connected to male team Sierotki/KFC Buhurt). While the girls train in their own facilities on a daily basis, they get together for team training once a month.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"anna.mocko96@gmail.com","teamLogo":"wix:image://v1/4922bd_d4d9b6ed3ee84d66aa1c07d50aadb476~mv2.png/manticore2.png#originWidth=1614&originHeight=1555","logoUrl":"https://static.wixstatic.com/media/4922bd_d4d9b6ed3ee84d66aa1c07d50aadb476~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Anna Blausz","Izabella Maziarz","Kateryna Umiarova","Agnieszka Skrobacz","Paulina Pajak","Ruslana Lahutina","Barbara Glowienka","Anna Łazowska Czubak","Kateřina Ambrozová"],"sourceCreatedAt":"2026-03-23T11:58:01.580Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Manticore',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Łódź / Kraków',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'anna.mocko96@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4922bd_d4d9b6ed3ee84d66aa1c07d50aadb476~mv2.png'),
 public_description=coalesce(t.public_description,'Manticore is a new female Buhurt team originating from Poland. It was formed on February 12th, 2026, connecting women from all over the country, with the main training facilities located in Łódź (connected to male team KS Rycerz) and Kraków (connected to male team Sierotki/KFC Buhurt). While the girls train in their own facilities on a daily basis, they get together for team training once a month.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anna Blausz','captain','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Izabella Maziarz','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kateryna Umiarova','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Agnieszka Skrobacz','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paulina Pajak','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ruslana Lahutina','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Barbara Glowienka','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anna Łazowska Czubak','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kateřina Ambrozová','fighter','bi_teams','https://www.buhurtinternational.com/team/manticore','manticore',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='manticores' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-manticores' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Manticores','San Luis Obispo',true,'active','public','bi-manticores','NA','North America','US','United States','theslomanticores@gmail.com','https://m.facebook.com/groups/4946212498742225/?ref=share&mibextid=wwXIfr','https://static.wixstatic.com/media/a4734f_705c7909a1534d6c8fc9c2139dc1b27d~mv2.jpeg','Anyone in San Luis Obispo county can contact us to get started. Our practice facility is in Morro Bay.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','manticores','https://www.buhurtinternational.com/team/manticores','Manticores','San Luis Obispo','theslomanticores@gmail.com','https://m.facebook.com/groups/4946212498742225/?ref=share&mibextid=wwXIfr',20,'{"biCollectionId":"dc68ea94-85e2-47f8-8b8a-7554d7ccd63f","teamName":"Manticores","club":null,"gender":"Male","captain":"Joshua Scardine","conference":"North America","country":"United States","city":"San Luis Obispo","teamInfo":"Anyone in San Luis Obispo county can contact us to get started. Our practice facility is in Morro Bay.","trainingInfo":"Anyone in San Luis Obispo County can contact us on Facebook or Instagram to get started. Our practice facility is in Morro Bay and we practice twice per week on Thursdays and Sundays.","trainingLocation":{"formatted":"Contact for address"},"websiteFacebookUrl":"https://m.facebook.com/groups/4946212498742225/?ref=share&mibextid=wwXIfr","teamEmail":"theslomanticores@gmail.com","teamLogo":"wix:image://v1/a4734f_705c7909a1534d6c8fc9c2139dc1b27d~mv2.jpeg/IMG_7531.jpeg#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/a4734f_705c7909a1534d6c8fc9c2139dc1b27d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":6},{"_id":"2","points":0,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":10}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":1,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":5},{"_id":"2","points":0,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":7},{"_id":"3","points":0,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":8}],"points12v12":0,"averagePoints5v5":0.33,"rank5v5":20,"remainingTokens":0,"points5v5":1}},"members":["Joshua Scardine","Quaid Birchell","Adam Chavarria","Xander Bissell","Dylan Valette","Isaac Blaise Minarik","Brian Murray","James kennard","Maxwell Collins","Ruben martinez"],"sourceCreatedAt":"2025-02-25T05:57:32.448Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Manticores',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('San Luis Obispo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'theslomanticores@gmail.com'),
 website_url=coalesce(t.website_url,'https://m.facebook.com/groups/4946212498742225/?ref=share&mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a4734f_705c7909a1534d6c8fc9c2139dc1b27d~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Anyone in San Luis Obispo county can contact us to get started. Our practice facility is in Morro Bay.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Scardine','captain','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quaid Birchell','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Chavarria','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Xander Bissell','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Valette','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isaac Blaise Minarik','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Murray','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James kennard','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxwell Collins','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ruben martinez','fighter','bi_teams','https://www.buhurtinternational.com/team/manticores','manticores',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='martel' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-martel' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Martel','Paris',true,'active','public','bi-martel','EU','Europe','FR','France','francemedieval@gmail.com',NULL,'https://static.wixstatic.com/media/65e678_e3e022c39474417c87a07d2568fbb4e5~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','martel','https://www.buhurtinternational.com/team/martel','Martel','Paris','francemedieval@gmail.com',NULL,20,'{"biCollectionId":"ecc6bcf0-744d-4e32-8504-7d2cfb0d26a4","teamName":"Martel","club":null,"gender":"Male","captain":"Christopher Pinto","conference":"Europe","country":"France","city":"Paris","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"francemedieval@gmail.com","teamLogo":"wix:image://v1/65e678_e3e022c39474417c87a07d2568fbb4e5~mv2.jpg/logo%20martel.jpg#originWidth=582&originHeight=582","logoUrl":"https://static.wixstatic.com/media/65e678_e3e022c39474417c87a07d2568fbb4e5~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":7,"remainingTokens":"10","tournaments":[{"_id":"1","points":7,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":3}]}},"members":["Christopher Pinto","Hubert Lartigue","Bertrand Ribet","Matthieu VANHEMS","Maximilien HAMON-RAHUEL","Guillaume Boulay","Tanguy PIEGAY","Romain Coupiac"],"sourceCreatedAt":"2025-04-30T10:31:08.626Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Martel',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Paris',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'francemedieval@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/65e678_e3e022c39474417c87a07d2568fbb4e5~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Pinto','captain','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hubert Lartigue','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bertrand Ribet','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthieu VANHEMS','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maximilien HAMON-RAHUEL','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume Boulay','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tanguy PIEGAY','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Romain Coupiac','fighter','bi_teams','https://www.buhurtinternational.com/team/martel','martel',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='masnada' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-masnada' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Masnada','Köln',true,'active','public','bi-masnada','EU','Europe','DE','Germany','kilianpoten@googlemail.com','https://instagram.com/masnada_buhurt','https://static.wixstatic.com/media/2a514f_caaba67f0f9e411f8294e7764b7bf782~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','masnada','https://www.buhurtinternational.com/team/masnada','Masnada','Köln','kilianpoten@googlemail.com','https://instagram.com/masnada_buhurt',20,'{"biCollectionId":"32a9ec86-fb93-4c7b-97e8-f9d253d9ab43","teamName":"Masnada","club":null,"gender":"Male","captain":"Kilian Poten","conference":"Europe","country":"Germany","city":"Köln","teamInfo":"","trainingInfo":"Bring padding and armor,if you already got some, but you don&#x27;t need anything if you don&#x27;t have it!we are more than happy to help out if possible","trainingLocation":{"subdivisions":[{"code":"NRW","name":"North Rhine-Westphalia","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Düsseldorf","name":"Düsseldorf","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Xanten","name":"Xanten","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"DE","name":"Germany","type":"COUNTRY"}],"city":"Xanten","location":{"latitude":51.65710809999999,"longitude":6.4486504},"streetAddress":{"apt":"","formattedAddressLine":"Xanten","name":"","number":""},"formatted":"46509 Xanten, Germany","country":"DE","postalCode":"46509","subdivision":"NRW"},"websiteFacebookUrl":"https://instagram.com/masnada_buhurt","teamEmail":"kilianpoten@googlemail.com","teamLogo":"wix:image://v1/2a514f_caaba67f0f9e411f8294e7764b7bf782~mv2.jpeg/IMG_3146.jpeg#originWidth=1200&originHeight=1270","logoUrl":"https://static.wixstatic.com/media/2a514f_caaba67f0f9e411f8294e7764b7bf782~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":6},{"_id":"2","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":5}]},"2025":{"remainingTokens":10}},"members":["Kilian Poten","Luca Schneevoigt","Shuyue Gong","Marcel Mausberg","Amin Budzhelida","Torben Stoffels"],"sourceCreatedAt":"2023-12-12T17:13:10.921Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Masnada',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Köln',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'kilianpoten@googlemail.com'),
 website_url=coalesce(t.website_url,'https://instagram.com/masnada_buhurt'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2a514f_caaba67f0f9e411f8294e7764b7bf782~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kilian Poten','captain','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Schneevoigt','fighter','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shuyue Gong','fighter','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcel Mausberg','fighter','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amin Budzhelida','fighter','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Torben Stoffels','fighter','bi_teams','https://www.buhurtinternational.com/team/masnada','masnada',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='matagots' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-matagots' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Matagots','N/a',true,'active','public','bi-matagots','NA','North America','US','United States','matagotfightclub@gmail.com','https://www.instagram.com/teammatagot?igsi=aXd0aDl1aDFyOWVo','https://static.wixstatic.com/media/397388_5f421bf41b0d4786b4bd9fcecb92e25e~mv2.jpeg','We are a nationwide team of fighters who came together partially because we lack full teams in our areas and also because we have been fighting together as the USA women&#x27;s team representatives for many years! We are a wonderful blend of veterans and new blood. We believe in the constant goals for self and team improvement as melee fighters, profighters, and duelists. Let&#x27;s Matagot!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','matagots','https://www.buhurtinternational.com/team/matagots','Matagots','N/a','matagotfightclub@gmail.com','https://www.instagram.com/teammatagot?igsi=aXd0aDl1aDFyOWVo',20,'{"biCollectionId":"4bf89c6b-25b2-44d1-9e61-6b42bc2df506","teamName":"Matagots","club":null,"gender":"Female","captain":"Katherine Herzog","conference":"North America","country":"United States","city":"N/a","teamInfo":"We are a nationwide team of fighters who came together partially because we lack full teams in our areas and also because we have been fighting together as the USA women&#x27;s team representatives for many years! We are a wonderful blend of veterans and new blood. We believe in the constant goals for self and team improvement as melee fighters, profighters, and duelists. Let&#x27;s Matagot!","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/teammatagot?igsi=aXd0aDl1aDFyOWVo","teamEmail":"matagotfightclub@gmail.com","teamLogo":"wix:image://v1/397388_5f421bf41b0d4786b4bd9fcecb92e25e~mv2.jpeg/IMG_8521.jpeg#originWidth=545&originHeight=600","logoUrl":"https://static.wixstatic.com/media/397388_5f421bf41b0d4786b4bd9fcecb92e25e~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":2},{"_id":"2","points":0,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"3vs3","place":1},{"_id":"3","points":3,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":26,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":1},{"_id":"2","points":6,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":3},{"_id":"3","points":5,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":2},{"_id":"4","points":3,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":3}],"points12v12":0,"averagePoints5v5":12.33,"rank5v5":1,"remainingTokens":9,"points5v5":40}},"members":["Katherine Herzog","Kathryn MacQueen","Ashley Shadu Fry","Fran Walker","Shoshana Shellans","Shelby Golden","Carissa Walrath","Kelsey Gentry"],"sourceCreatedAt":"2024-09-18T16:41:28.362Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Matagots',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('N/a',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'matagotfightclub@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/teammatagot?igsi=aXd0aDl1aDFyOWVo'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/397388_5f421bf41b0d4786b4bd9fcecb92e25e~mv2.jpeg'),
 public_description=coalesce(t.public_description,'We are a nationwide team of fighters who came together partially because we lack full teams in our areas and also because we have been fighting together as the USA women&#x27;s team representatives for many years! We are a wonderful blend of veterans and new blood. We believe in the constant goals for self and team improvement as melee fighters, profighters, and duelists. Let&#x27;s Matagot!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Katherine Herzog','captain','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kathryn MacQueen','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ashley Shadu Fry','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fran Walker','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shoshana Shellans','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shelby Golden','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carissa Walrath','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kelsey Gentry','fighter','bi_teams','https://www.buhurtinternational.com/team/matagots','matagots',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mcm' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mcm' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'MCM','Prien a. Chiemsee',true,'active','public','bi-mcm','EU','Europe','AT','Austria','wernerstocker64@gmx.de',NULL,'https://static.wixstatic.com/media/749d07_046542c6b56245dc9b1a6ef507b25713~mv2.jpg','Hello, i&#x27;am emergency medic and ex fighter and work for the last years by us on Event for the fighter as special combat medic We&#x27;ve a instutution for Medival Combat Medics and woudsupport your event. You can ask the Night marshall Nadine Nickel. She now my work. regards Werner')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mcm','https://www.buhurtinternational.com/team/mcm','MCM','Prien a. Chiemsee','wernerstocker64@gmx.de',NULL,20,'{"biCollectionId":"d35702f8-d939-48ba-9be4-a5166b21c042","teamName":"MCM","club":null,"gender":"Male","captain":"Werner Stocker","conference":"Europe","country":"Austria","city":"Prien a. Chiemsee","teamInfo":"Hello, i&#x27;am emergency medic and ex fighter and work for the last years by us on Event for the fighter as special combat medic We&#x27;ve a instutution for Medival Combat Medics and woudsupport your event. You can ask the Night marshall Nadine Nickel. She now my work. regards Werner","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"wernerstocker64@gmx.de","teamLogo":"wix:image://v1/749d07_046542c6b56245dc9b1a6ef507b25713~mv2.jpg/540274441_3293810484107018_8641300517908968905_n.jpg#originWidth=526&originHeight=682","logoUrl":"https://static.wixstatic.com/media/749d07_046542c6b56245dc9b1a6ef507b25713~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Werner Stocker"],"sourceCreatedAt":"2026-02-27T15:07:05.876Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('MCM',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Prien a. Chiemsee',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Austria',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wernerstocker64@gmx.de'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/749d07_046542c6b56245dc9b1a6ef507b25713~mv2.jpg'),
 public_description=coalesce(t.public_description,'Hello, i&#x27;am emergency medic and ex fighter and work for the last years by us on Event for the fighter as special combat medic We&#x27;ve a instutution for Medival Combat Medics and woudsupport your event. You can ask the Night marshall Nadine Nickel. She now my work. regards Werner'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Werner Stocker','captain','bi_teams','https://www.buhurtinternational.com/team/mcm','mcm',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mcs-satakunta' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mcs-satakunta' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'MCS Satakunta','Pori',true,'active','public','bi-mcs-satakunta','EU','Europe','FI','Finland','mcssatakunta@gmail.com','https://www.facebook.com/MCSSatakunta','https://static.wixstatic.com/media/865a1c_29d7ce665af240ddbc434eff7e6a0589~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mcs-satakunta','https://www.buhurtinternational.com/team/mcs-satakunta','MCS Satakunta','Pori','mcssatakunta@gmail.com','https://www.facebook.com/MCSSatakunta',20,'{"biCollectionId":"22f43ec7-7ac9-4cbc-8423-781910fa3574","teamName":"MCS Satakunta","club":null,"gender":"Male","captain":"Timo Laakso","conference":"Europe","country":"Finland","city":"Pori","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/MCSSatakunta","teamEmail":"mcssatakunta@gmail.com","teamLogo":"wix:image://v1/865a1c_29d7ce665af240ddbc434eff7e6a0589~mv2.png/MCS_logo.png#originWidth=1920&originHeight=1920","logoUrl":"https://static.wixstatic.com/media/865a1c_29d7ce665af240ddbc434eff7e6a0589~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":2}]},"2025":{"remainingTokens":10}},"members":["Timo Laakso","Kristian jalo","Jani Lahtimo","Teemu Laiho","Jani Kormu","Aleksi Annaniemi","Matti Peltonen","Joona Hämäläinen","Sasu Silvennoinen"],"sourceCreatedAt":"2023-07-02T20:08:00.817Z","sourceUpdatedAt":"2026-09-29T07:14:54.459Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('MCS Satakunta',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Pori',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mcssatakunta@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MCSSatakunta'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/865a1c_29d7ce665af240ddbc434eff7e6a0589~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timo Laakso','captain','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kristian jalo','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jani Lahtimo','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Teemu Laiho','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jani Kormu','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksi Annaniemi','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matti Peltonen','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joona Hämäläinen','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sasu Silvennoinen','fighter','bi_teams','https://www.buhurtinternational.com/team/mcs-satakunta','mcs-satakunta',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='medieval-combat-school-"leonid"' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-medieval-combat-school-"leonid"' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Castrum Pestis','Rīga',true,'active','public','bi-medieval-combat-school-"leonid"','EU','Europe','LV','Latvia','maksims.sirotkins@gmail.com',NULL,'https://static.wixstatic.com/media/e7cf83_2abab71d84354c4485c45c290e47d19a~mv2.png','aaa')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','medieval-combat-school-"leonid"','https://www.buhurtinternational.com/team/medieval-combat-school-%22leonid%22','Castrum Pestis','Rīga','maksims.sirotkins@gmail.com',NULL,20,'{"biCollectionId":"585bf90d-60d2-4a6d-a766-01f3f740ae06","teamName":"Castrum Pestis","club":null,"gender":"Male","captain":"Maksims Sirotkins","conference":"Europe","country":"Latvia","city":"Rīga","teamInfo":"aaa","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Rīga","name":"Rīga","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"LV","name":"Latvia","type":"COUNTRY"}],"city":"Rīga","location":{"latitude":57.0362035,"longitude":24.0980508},"streetAddress":{"apt":"","formattedAddressLine":"A. Dombrovska iela 74","name":"Augusta Dombrovska iela","number":"74"},"formatted":"A. Dombrovska iela 74, Ziemeļu rajons, Rīga, LV-1015, Latvia","country":"LV","postalCode":"1015"},"websiteFacebookUrl":null,"teamEmail":"maksims.sirotkins@gmail.com","teamLogo":"wix:image://v1/e7cf83_2abab71d84354c4485c45c290e47d19a~mv2.png/team_logo_square.png#originWidth=512&originHeight=512","logoUrl":"https://static.wixstatic.com/media/e7cf83_2abab71d84354c4485c45c290e47d19a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Maksims Sirotkins"],"sourceCreatedAt":"2026-03-23T10:01:49.152Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Castrum Pestis',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Rīga',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('LV',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Latvia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'maksims.sirotkins@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e7cf83_2abab71d84354c4485c45c290e47d19a~mv2.png'),
 public_description=coalesce(t.public_description,'aaa'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maksims Sirotkins','captain','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-school-%22leonid%22','medieval-combat-school-"leonid"',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='medieval-combat-union-pyhra' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-medieval-combat-union-pyhra' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Medieval Combat UNION Pyhra','Racking',true,'active','public','bi-medieval-combat-union-pyhra','EU','Europe','AT','Austria','mcu-pyhra@gmx.at','https://www.facebook.com/profile.php?id=61570102778727','https://static.wixstatic.com/media/b7aaf8_e64ba9e679bd408989da0d74fa654bed~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','medieval-combat-union-pyhra','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','Medieval Combat UNION Pyhra','Racking','mcu-pyhra@gmx.at','https://www.facebook.com/profile.php?id=61570102778727',20,'{"biCollectionId":"f5bededf-ae47-4a78-847f-73df158b4d53","teamName":"Medieval Combat UNION Pyhra","club":null,"gender":"Male","captain":"Mst. Gregor Handl","conference":"Europe","country":"Austria","city":"Racking","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61570102778727","teamEmail":"mcu-pyhra@gmx.at","teamLogo":"wix:image://v1/b7aaf8_e64ba9e679bd408989da0d74fa654bed~mv2.jpeg/WhatsApp%20Image%202026-06-29%20at%2022.08.23.jpeg#originWidth=500&originHeight=500","logoUrl":"https://static.wixstatic.com/media/b7aaf8_e64ba9e679bd408989da0d74fa654bed~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Mst. Gregor Handl","Wolfgang Rank","Sary Dominik","Bernhard Riener","Max Fröhling","Max Höller"],"sourceCreatedAt":"2026-08-03T12:59:29.379Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Medieval Combat UNION Pyhra',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Racking',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Austria',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mcu-pyhra@gmx.at'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61570102778727'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b7aaf8_e64ba9e679bd408989da0d74fa654bed~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mst. Gregor Handl','captain','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wolfgang Rank','fighter','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sary Dominik','fighter','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bernhard Riener','fighter','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Max Fröhling','fighter','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Max Höller','fighter','bi_teams','https://www.buhurtinternational.com/team/medieval-combat-union-pyhra','medieval-combat-union-pyhra',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mfc-draco' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mfc-draco' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'MFC Draco','Sibiu',true,'active','public','bi-mfc-draco','EU','Europe','RO','Romania','horatiulutic94@gmail.com','https://www.facebook.com/profile.php?id=61573598948512','https://static.wixstatic.com/media/b5d7ff_1a35059d07714088ab1f657c3e1189c5~mv2.jpg','MFC Draco is a Romanian Buhurt team centered in the city of Sibiu with fighters from all over Transylvania and the rest of Romania.The team is part of the Reenactment group The Company of the Dragon.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mfc-draco','https://www.buhurtinternational.com/team/mfc-draco','MFC Draco','Sibiu','horatiulutic94@gmail.com','https://www.facebook.com/profile.php?id=61573598948512',20,'{"biCollectionId":"df30fb7e-f834-4bc5-9d9f-c3f6845e303f","teamName":"MFC Draco","club":null,"gender":"Male","captain":"Horatiu Lutic","conference":"Europe","country":"Romania","city":"Sibiu","teamInfo":"MFC Draco is a Romanian Buhurt team centered in the city of Sibiu with fighters from all over Transylvania and the rest of Romania.The team is part of the Reenactment group The Company of the Dragon.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61573598948512","teamEmail":"horatiulutic94@gmail.com","teamLogo":"wix:image://v1/b5d7ff_1a35059d07714088ab1f657c3e1189c5~mv2.jpg/Picture1.jpg#originWidth=552&originHeight=552","logoUrl":"https://static.wixstatic.com/media/b5d7ff_1a35059d07714088ab1f657c3e1189c5~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":4,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Valley of Warriors Buhurt Tournament 2025","date":"2025-06-07","category":"5vs5","place":4},{"_id":"2","points":0,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":7}]}},"members":["Horatiu Lutic","Paul Rahaian","Murgoi Ioan-Delian","Puicar Cristian Calin","MIHAI IONITA","Sebastian Drăgușin","Csonta András","Alpár Péter"],"sourceCreatedAt":"2025-04-14T17:11:11.309Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('MFC Draco',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sibiu',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('RO',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Romania',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'horatiulutic94@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61573598948512'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b5d7ff_1a35059d07714088ab1f657c3e1189c5~mv2.jpg'),
 public_description=coalesce(t.public_description,'MFC Draco is a Romanian Buhurt team centered in the city of Sibiu with fighters from all over Transylvania and the rest of Romania.The team is part of the Reenactment group The Company of the Dragon.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Horatiu Lutic','captain','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Rahaian','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Murgoi Ioan-Delian','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Puicar Cristian Calin','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MIHAI IONITA','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Drăgușin','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Csonta András','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alpár Péter','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-draco','mfc-draco',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mfc-slezsko' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mfc-slezsko' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'MFC Slezsko','Ostrava ',true,'active','public','bi-mfc-slezsko','EU','Europe','CZ','Czech Republic','boncekd@gmail.com','https://www.facebook.com/bojovyserm','https://static.wixstatic.com/media/7c393c_d396ba6783e142a68a8e704da4b68b4c~mv2.webp',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mfc-slezsko','https://www.buhurtinternational.com/team/mfc-slezsko','MFC Slezsko','Ostrava ','boncekd@gmail.com','https://www.facebook.com/bojovyserm',20,'{"biCollectionId":"6b7907a8-c33b-4838-b463-f1985533bff8","teamName":"MFC Slezsko","club":null,"gender":"Male","captain":"Dalibor Bonček","conference":"Europe","country":"Czech Republic","city":"Ostrava ","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Moravskoslezský kraj","name":"Moravskoslezský kraj","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Ostrava-město","name":"Ostrava-město","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"CZ","name":"Czechia","type":"COUNTRY"}],"city":"Moravská Ostrava a Přívoz","location":{"latitude":49.853794,"longitude":18.2756524},"streetAddress":{"apt":"595","formattedAddressLine":"Fügnerova 595/1","name":"Fügnerova","number":"1"},"formatted":"Fügnerova 595/1, 702 00 Moravská Ostrava a Přívoz, Czechia","country":"CZ","postalCode":"702 00","subdivision":"MO"},"websiteFacebookUrl":"https://www.facebook.com/bojovyserm","teamEmail":"boncekd@gmail.com","teamLogo":"wix:image://v1/7c393c_d396ba6783e142a68a8e704da4b68b4c~mv2.webp/IMG_20240101_190246_151.webp#originWidth=935&originHeight=935","logoUrl":"https://static.wixstatic.com/media/7c393c_d396ba6783e142a68a8e704da4b68b4c~mv2.webp","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["Dalibor Bonček","Jan Růžička","Tomas Holub","Vojtech Kasper","Oleksii obaraz","Jiri Seber"],"sourceCreatedAt":"2024-07-24T13:19:39.900Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('MFC Slezsko',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ostrava ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'boncekd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/bojovyserm'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7c393c_d396ba6783e142a68a8e704da4b68b4c~mv2.webp'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dalibor Bonček','captain','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Růžička','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomas Holub','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vojtech Kasper','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oleksii obaraz','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jiri Seber','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-slezsko','mfc-slezsko',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mfc-vysocina' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mfc-vysocina' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'MFC Vysocina','Heraltice',true,'active','public','bi-mfc-vysocina','EU','Europe','CZ','Czech Republic','	t.samec18@seznam.cz','https://www.facebook.com/MFCVysocina','https://static.wixstatic.com/media/cbac14_e2e4811e976b4967bb174ee22c04e356~mv2.jpg','Pro více informací nás kontaktujte na Facebooku nebo Instagramu. For more informations please contact us on Facebook or Instagram.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mfc-vysocina','https://www.buhurtinternational.com/team/mfc-vysocina','MFC Vysocina','Heraltice','	t.samec18@seznam.cz','https://www.facebook.com/MFCVysocina',20,'{"biCollectionId":"83b4752b-8721-447f-abf4-a10ab3e17d5e","teamName":"MFC Vysocina","club":null,"gender":"Male","captain":"Tomáš Samec","conference":"Europe","country":"Czech Republic","city":"Heraltice","teamInfo":"Pro více informací nás kontaktujte na Facebooku nebo Instagramu. For more informations please contact us on Facebook or Instagram.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/MFCVysocina","teamEmail":"\tt.samec18@seznam.cz","teamLogo":"wix:image://v1/cbac14_e2e4811e976b4967bb174ee22c04e356~mv2.jpg/mfc%20logo.jpg#originWidth=576&originHeight=576","logoUrl":"https://static.wixstatic.com/media/cbac14_e2e4811e976b4967bb174ee22c04e356~mv2.jpg","rank5v5":7,"averagePoints5v5":4.33,"points5v5":13,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":7},{"_id":"2","points":0,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":9},{"_id":"3","points":11,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":11,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":2},{"_id":"2","points":6,"Tournament":"Valley of Warriors Buhurt Tournament 2024","date":"2024-06-15","category":"3vs3","place":1},{"_id":"3","points":4,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":5},{"_id":"4","points":6,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":6},{"_id":"2","points":3,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":5},{"_id":"3","points":3,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":2.67,"rank5v5":11,"remainingTokens":10,"points5v5":8}},"members":["Josef Pohl","Tomáš Samec","MARTIN ŠPAČEK","Miroslav Svoboda","Martin dymanus","Viktor Vacek","David Samec","Vesely Ivo","Jan Havlíček","Martin Špaček JR","Jakub Kocourek","Dávid Olexa","Tristan Souchon","Mariusz Orawski","Michal Gašparík","Jan Jiří Krupička"],"sourceCreatedAt":"2023-08-06T17:02:37.457Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('MFC Vysocina',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Heraltice',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'	t.samec18@seznam.cz'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MFCVysocina'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cbac14_e2e4811e976b4967bb174ee22c04e356~mv2.jpg'),
 public_description=coalesce(t.public_description,'Pro více informací nás kontaktujte na Facebooku nebo Instagramu. For more informations please contact us on Facebook or Instagram.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josef Pohl','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomáš Samec','captain','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MARTIN ŠPAČEK','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miroslav Svoboda','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin dymanus','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Viktor Vacek','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Samec','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vesely Ivo','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Havlíček','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Špaček JR','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Kocourek','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dávid Olexa','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tristan Souchon','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariusz Orawski','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michal Gašparík','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Jiří Krupička','fighter','bi_teams','https://www.buhurtinternational.com/team/mfc-vysocina','mfc-vysocina',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mid-north-coast-crusaders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mid-north-coast-crusaders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Mid North Coast Crusaders','Port Macquarie',true,'active','public','bi-mid-north-coast-crusaders','OC','Oceania','AU','Australia','midnorthcoastcrusaders@gmail.com','https://www.facebook.com/MidNorthCoastCrusaders','https://static.wixstatic.com/media/01571b_5ae6bed249954782951ecafe6dffd86d~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mid-north-coast-crusaders','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','Mid North Coast Crusaders','Port Macquarie','midnorthcoastcrusaders@gmail.com','https://www.facebook.com/MidNorthCoastCrusaders',20,'{"biCollectionId":"710497e6-7387-4b43-9eac-c57f839ef0f3","teamName":"Mid North Coast Crusaders","club":null,"gender":"Male","captain":"John Cierpiatka","conference":"APAC","country":"Australia","city":"Port Macquarie","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/MidNorthCoastCrusaders","teamEmail":"midnorthcoastcrusaders@gmail.com","teamLogo":"wix:image://v1/01571b_5ae6bed249954782951ecafe6dffd86d~mv2.png/Crusaders800p.png#originWidth=750&originHeight=800","logoUrl":"https://static.wixstatic.com/media/01571b_5ae6bed249954782951ecafe6dffd86d~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["John Cierpiatka","Eric Waters","Mitchell Baxter","Rhiona Groombridge","Brandon Robbins"],"sourceCreatedAt":"2023-10-31T01:34:19.211Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Mid North Coast Crusaders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Port Macquarie',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'midnorthcoastcrusaders@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MidNorthCoastCrusaders'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/01571b_5ae6bed249954782951ecafe6dffd86d~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Cierpiatka','captain','bi_teams','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','mid-north-coast-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric Waters','fighter','bi_teams','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','mid-north-coast-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mitchell Baxter','fighter','bi_teams','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','mid-north-coast-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rhiona Groombridge','fighter','bi_teams','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','mid-north-coast-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Robbins','fighter','bi_teams','https://www.buhurtinternational.com/team/mid-north-coast-crusaders','mid-north-coast-crusaders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='milwaukee-iron-stags' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-milwaukee-iron-stags' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Milwaukee Iron Stags','Milwaukee',true,'active','public','bi-milwaukee-iron-stags','NA','North America','US','United States','marshcelt@gmail.com','https://www.facebook.com/MilwaukeeIronStags/','https://static.wixstatic.com/media/88bcd8_5f13e2348b70453fb6230a40db923fff~mv2.png','The team was founded in 2021 In Milwaukee, Wisconsin.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','milwaukee-iron-stags','https://www.buhurtinternational.com/team/milwaukee-iron-stags','Milwaukee Iron Stags','Milwaukee','marshcelt@gmail.com','https://www.facebook.com/MilwaukeeIronStags/',20,'{"biCollectionId":"9d77f4b2-840c-410c-92ce-51f33f7235b8","teamName":"Milwaukee Iron Stags","club":null,"gender":"Male","captain":"Jedidiah Zabel","conference":"North America","country":"United States","city":"Milwaukee","teamInfo":"The team was founded in 2021 In Milwaukee, Wisconsin.","trainingInfo":"We operate out of WIsconsin Medival Combat Center, where we train several times a week","trainingLocation":{"formatted":"230 E Lincoln Ave, Milwaukee, WI 53207"},"websiteFacebookUrl":"https://www.facebook.com/MilwaukeeIronStags/","teamEmail":"marshcelt@gmail.com","teamLogo":"wix:image://v1/88bcd8_5f13e2348b70453fb6230a40db923fff~mv2.png/MilwaukeeIronStag_bg.png#originWidth=3808&originHeight=3897","logoUrl":"https://static.wixstatic.com/media/88bcd8_5f13e2348b70453fb6230a40db923fff~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":4,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":6},{"_id":"2","points":2,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":"10","tournaments":[{"_id":"1","points":0,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":15},{"_id":"2","points":3,"Tournament":"Cream City Clash 3 2025","date":"2025-08-30","category":"5vs5","place":3},{"_id":"3","points":0,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":7}]}},"members":["Jedidiah Zabel","Jacob Kotten","Spencer Gorman","Nathan Schulte","Anthony Balistreri","Joshua Jirik","Leonid Bortsov","Nicholas Stenz","Steven Donne","Tyler Jeffrey Gren","Pietro Norante","Jarrod Lewis"],"sourceCreatedAt":"2025-04-27T02:23:20.632Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Milwaukee Iron Stags',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Milwaukee',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'marshcelt@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MilwaukeeIronStags/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/88bcd8_5f13e2348b70453fb6230a40db923fff~mv2.png'),
 public_description=coalesce(t.public_description,'The team was founded in 2021 In Milwaukee, Wisconsin.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jedidiah Zabel','captain','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Kotten','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Spencer Gorman','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Schulte','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anthony Balistreri','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Jirik','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonid Bortsov','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Stenz','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Donne','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Jeffrey Gren','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pietro Norante','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jarrod Lewis','fighter','bi_teams','https://www.buhurtinternational.com/team/milwaukee-iron-stags','milwaukee-iron-stags',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='moldova-team' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-moldova-team' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Moldova Team',NULL,true,'active','public','bi-moldova-team','EU','Europe','MD','Moldova','moldova.buhurt.team@gmail.com','https://www.facebook.com/bastion.moldova','https://static.wixstatic.com/media/28dae5_f683155cb7594d339b93f016ee6acc2a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','moldova-team','https://www.buhurtinternational.com/team/moldova-team','Moldova Team',NULL,'moldova.buhurt.team@gmail.com','https://www.facebook.com/bastion.moldova',20,'{"biCollectionId":"7b57987c-0566-4e29-8906-74f04e895c86","teamName":"Moldova Team","club":null,"gender":"Male","captain":"Nikolai Ivashchenko","conference":"Europe","country":"Moldova","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"moldova.buhurt.team@gmail.com"},"websiteFacebookUrl":"https://www.facebook.com/bastion.moldova","teamEmail":"moldova.buhurt.team@gmail.com","teamLogo":"wix:image://v1/28dae5_f683155cb7594d339b93f016ee6acc2a~mv2.png/Image_Editor.png#originWidth=214&originHeight=214","logoUrl":"https://static.wixstatic.com/media/28dae5_f683155cb7594d339b93f016ee6acc2a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":8}},"members":["Nikolai Ivashchenko","Croitor Artiom","Ian Prjibilski","Ecaterina Obadă","TIMERCAN NICOLAI","Pogreban Serghei","Valentina De Francesco","Moldovan Evghenii","Alexandru Tulushniuc"],"sourceCreatedAt":"2025-04-08T20:30:34.150Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Moldova Team',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('MD',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Moldova',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'moldova.buhurt.team@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/bastion.moldova'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/28dae5_f683155cb7594d339b93f016ee6acc2a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nikolai Ivashchenko','captain','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Croitor Artiom','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Prjibilski','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ecaterina Obadă','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'TIMERCAN NICOLAI','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pogreban Serghei','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valentina De Francesco','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Moldovan Evghenii','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandru Tulushniuc','fighter','bi_teams','https://www.buhurtinternational.com/team/moldova-team','moldova-team',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='moncton-marauders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-moncton-marauders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Moncton Marauders','Moncton',true,'active','public','bi-moncton-marauders','NA','North America','CA','Canada','monctonmarauders@outlook.com','https://www.facebook.com/share/16mNDwbes1/?mibextid=wwXIfr','https://static.wixstatic.com/media/c8bfeb_acb3639281054eb7bb765da9bf3b594d~mv2.jpeg','Eastern Canada team New-Brunswick')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','moncton-marauders','https://www.buhurtinternational.com/team/moncton-marauders','Moncton Marauders','Moncton','monctonmarauders@outlook.com','https://www.facebook.com/share/16mNDwbes1/?mibextid=wwXIfr',20,'{"biCollectionId":"90481b8b-8829-4e03-9ab2-304a6e22f344","teamName":"Moncton Marauders","club":null,"gender":"Male","captain":"Ryan Coombs","conference":"North America","country":"Canada","city":"Moncton","teamInfo":"Eastern Canada team New-Brunswick","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/16mNDwbes1/?mibextid=wwXIfr","teamEmail":"monctonmarauders@outlook.com","teamLogo":"wix:image://v1/c8bfeb_acb3639281054eb7bb765da9bf3b594d~mv2.jpeg/IMG_0343.jpeg#originWidth=1038&originHeight=1038","logoUrl":"https://static.wixstatic.com/media/c8bfeb_acb3639281054eb7bb765da9bf3b594d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":10}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":10,"tournaments":[{"_id":"1","points":3,"Tournament":"Eastern War Tide 2025","date":"2025-09-27","category":"5vs5","place":1}]}},"members":["Justin Gray","Nathan Roy Christison","Noble Doiron","Pierre Dion","Samuel Pelletier","Colin O''Neil","Ryan coombs","Samuel Turgeon","Daniel Leclair","Justin Daniel Hayter","Raul Felix"],"sourceCreatedAt":"2025-06-17T16:17:43.650Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Moncton Marauders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Moncton',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'monctonmarauders@outlook.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/16mNDwbes1/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c8bfeb_acb3639281054eb7bb765da9bf3b594d~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Eastern Canada team New-Brunswick'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin Gray','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Roy Christison','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noble Doiron','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pierre Dion','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Pelletier','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colin O''Neil','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan coombs','captain','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Turgeon','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Leclair','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin Daniel Hayter','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raul Felix','fighter','bi_teams','https://www.buhurtinternational.com/team/moncton-marauders','moncton-marauders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='na-bánánaigh' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-na-bánánaigh' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Na Bánánaigh',NULL,true,'active','public','bi-na-bánánaigh','EU','Europe','IE','Ireland','nabananaigh@gmail.com','https://www.instagram.com/na_bananaigh/','https://static.wixstatic.com/media/d5135f_afe0212af7e54d9ebdb8a8f279f96b61~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','na-bánánaigh','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','Na Bánánaigh',NULL,'nabananaigh@gmail.com','https://www.instagram.com/na_bananaigh/',20,'{"biCollectionId":"38a52a73-9e1a-4b02-85fa-a2707c260896","teamName":"Na Bánánaigh","club":null,"gender":"Female","captain":"Muireann Costello","conference":"Europe","country":"Ireland","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/na_bananaigh/","teamEmail":"nabananaigh@gmail.com","teamLogo":"wix:image://v1/d5135f_afe0212af7e54d9ebdb8a8f279f96b61~mv2.jpg/496632410_24441513922104497_2589369225536501454_n.jpg#originWidth=1448&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/d5135f_afe0212af7e54d9ebdb8a8f279f96b61~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":5}],"eventsHistory":{},"members":["Muireann Costello","Maedbh Duignan","Ellen Twomey","Erin Volya","Dorcas Oyewande","Rebeca Palos"],"sourceCreatedAt":"2026-02-03T15:56:35.304Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Na Bánánaigh',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Ireland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nabananaigh@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/na_bananaigh/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d5135f_afe0212af7e54d9ebdb8a8f279f96b61~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Muireann Costello','captain','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maedbh Duignan','fighter','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ellen Twomey','fighter','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erin Volya','fighter','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dorcas Oyewande','fighter','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebeca Palos','fighter','bi_teams','https://www.buhurtinternational.com/team/na-b%C3%A1n%C3%A1naigh','na-bánánaigh',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='nassauer-löwen' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-nassauer-löwen' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Nassauer Löwen','Hessen ',true,'active','public','bi-nassauer-löwen','EU','Europe','DE','Germany','Nassauer-Loewen@gmx.de','https://www.facebook.com/share/g/NKwuj3F8ZMHwBJNN/','https://static.wixstatic.com/media/739b7f_9798ba03f20b40c3ac3174dc26a16ce1~mv2.png','Das Team ist über ganz Deutschland verteilt und hat somit verschiedene Training-Spots -- Hessen- Idstein im Taunus -- Hessen- Greifenstein LDK -- Baden-Württemberg Leonberg')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','nassauer-löwen','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','Nassauer Löwen','Hessen ','Nassauer-Loewen@gmx.de','https://www.facebook.com/share/g/NKwuj3F8ZMHwBJNN/',20,'{"biCollectionId":"b4fc9e9d-31d3-49f9-aea3-2a5dab37318d","teamName":"Nassauer Löwen","club":null,"gender":"Male","captain":"Mike Rusitschka","conference":"Europe","country":"Germany","city":"Hessen ","teamInfo":"Das Team ist über ganz Deutschland verteilt und hat somit verschiedene Training-Spots -- Hessen- Idstein im Taunus -- Hessen- Greifenstein LDK -- Baden-Württemberg Leonberg","trainingInfo":"","trainingLocation":{"formatted":"Diverse Trainingsorte abhängig vom Wetter "},"websiteFacebookUrl":"https://www.facebook.com/share/g/NKwuj3F8ZMHwBJNN/","teamEmail":"Nassauer-Loewen@gmx.de","teamLogo":"wix:image://v1/739b7f_9798ba03f20b40c3ac3174dc26a16ce1~mv2.png/Nassau.png#originWidth=905&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/739b7f_9798ba03f20b40c3ac3174dc26a16ce1~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":5}]},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":9,"tournaments":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":9}]}},"members":["Mike Rusitschka","Jonas Kasza","Dirk Merkel","Jens Ramsak","Manuel Menzel"],"sourceCreatedAt":"2024-08-07T06:15:44.134Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Nassauer Löwen',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hessen ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Nassauer-Loewen@gmx.de'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/g/NKwuj3F8ZMHwBJNN/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/739b7f_9798ba03f20b40c3ac3174dc26a16ce1~mv2.png'),
 public_description=coalesce(t.public_description,'Das Team ist über ganz Deutschland verteilt und hat somit verschiedene Training-Spots -- Hessen- Idstein im Taunus -- Hessen- Greifenstein LDK -- Baden-Württemberg Leonberg'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mike Rusitschka','captain','bi_teams','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','nassauer-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonas Kasza','fighter','bi_teams','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','nassauer-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dirk Merkel','fighter','bi_teams','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','nassauer-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jens Ramsak','fighter','bi_teams','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','nassauer-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Manuel Menzel','fighter','bi_teams','https://www.buhurtinternational.com/team/nassauer-l%C3%B6wen','nassauer-löwen',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='new-order' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-new-order' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'New Order','Florianópolis ',true,'active','public','bi-new-order','SA','South America','BR','Brazil','newordervideos@gmail.cok','https://www.newordermedieval.com.br/','https://static.wixstatic.com/media/2c3ca6_0530f6512bc9476fbb91deef7652aaaf~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','new-order','https://www.buhurtinternational.com/team/new-order','New Order','Florianópolis ','newordervideos@gmail.cok','https://www.newordermedieval.com.br/',20,'{"biCollectionId":"68d1a765-b720-45f3-862a-9c00186bdf54","teamName":"New Order","club":null,"gender":"Male","captain":"Michel P Machado","conference":"South America","country":"Brazil","city":"Florianópolis ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.newordermedieval.com.br/","teamEmail":"newordervideos@gmail.cok","teamLogo":"wix:image://v1/2c3ca6_0530f6512bc9476fbb91deef7652aaaf~mv2.jpeg/IMG_3136.jpeg#originWidth=422&originHeight=422","logoUrl":"https://static.wixstatic.com/media/2c3ca6_0530f6512bc9476fbb91deef7652aaaf~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":5}]},"2025":{"remainingTokens":10}},"members":["Vitor Freitas Fermiano","Tadeu Barreto Baumgärtel","Michel P Machado","Lucas Villalva Machado","Anderson Henrique Pires","Nathan Sherer"],"sourceCreatedAt":"2023-06-26T21:37:59.130Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('New Order',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Florianópolis ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'newordervideos@gmail.cok'),
 website_url=coalesce(t.website_url,'https://www.newordermedieval.com.br/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2c3ca6_0530f6512bc9476fbb91deef7652aaaf~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vitor Freitas Fermiano','fighter','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tadeu Barreto Baumgärtel','fighter','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michel P Machado','captain','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Villalva Machado','fighter','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anderson Henrique Pires','fighter','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Sherer','fighter','bi_teams','https://www.buhurtinternational.com/team/new-order','new-order',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='new-orleans-storm-riders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-new-orleans-storm-riders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'New Orleans Storm Riders','New Orleans',true,'active','public','bi-new-orleans-storm-riders','NA','North America','US','United States','nola.armor@gmail.com','https://www.facebook.com/share/16pJVMkmzL/','https://static.wixstatic.com/media/41721e_35682be1515b4df9b10f2bc786027c1f~mv2.jpg','We&#x27;re the buhurt outfit for the GNO area! New Orleans, Metairie, Kenner, the Westbank, a little bit of the Northshore (i.e. Slidell).')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','new-orleans-storm-riders','https://www.buhurtinternational.com/team/new-orleans-storm-riders','New Orleans Storm Riders','New Orleans','nola.armor@gmail.com','https://www.facebook.com/share/16pJVMkmzL/',20,'{"biCollectionId":"78dfcf55-231c-4bc7-bfa3-dac0b1bab3ae","teamName":"New Orleans Storm Riders","club":null,"gender":"Male","captain":"Jonathan Hinnen","conference":"North America","country":"United States","city":"New Orleans","teamInfo":"We&#x27;re the buhurt outfit for the GNO area! New Orleans, Metairie, Kenner, the Westbank, a little bit of the Northshore (i.e. Slidell).","trainingInfo":"Heyo! All ya need for your first practice is an open mind and an open heart. And don&#x27;t be a douche.","trainingLocation":{"subdivisions":[{"code":"LA","name":"Louisiana","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Orleans Parish","name":"Orleans Parish","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"New Orleans","name":"New Orleans","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"West Riverside","name":"West Riverside","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"New Orleans","location":{"latitude":29.9174173,"longitude":-90.10631},"streetAddress":{"apt":"","formattedAddressLine":"4818 Annunciation St","name":"Annunciation Street","number":"4818"},"formatted":"4818 Annunciation St, New Orleans, LA 70115, USA","country":"US","postalCode":"70115","subdivision":"LA"},"websiteFacebookUrl":"https://www.facebook.com/share/16pJVMkmzL/","teamEmail":"nola.armor@gmail.com","teamLogo":"wix:image://v1/41721e_35682be1515b4df9b10f2bc786027c1f~mv2.jpg/IMG_20250721_201021.jpg#originWidth=1077&originHeight=999","logoUrl":"https://static.wixstatic.com/media/41721e_35682be1515b4df9b10f2bc786027c1f~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":12}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Jonathan Hinnen","Collin Sly","James Soderquist","Ian Adams","Sebastien Ratard"],"sourceCreatedAt":"2025-08-23T02:02:56.036Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('New Orleans Storm Riders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('New Orleans',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nola.armor@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/16pJVMkmzL/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/41721e_35682be1515b4df9b10f2bc786027c1f~mv2.jpg'),
 public_description=coalesce(t.public_description,'We&#x27;re the buhurt outfit for the GNO area! New Orleans, Metairie, Kenner, the Westbank, a little bit of the Northshore (i.e. Slidell).'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Hinnen','captain','bi_teams','https://www.buhurtinternational.com/team/new-orleans-storm-riders','new-orleans-storm-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Collin Sly','fighter','bi_teams','https://www.buhurtinternational.com/team/new-orleans-storm-riders','new-orleans-storm-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Soderquist','fighter','bi_teams','https://www.buhurtinternational.com/team/new-orleans-storm-riders','new-orleans-storm-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Adams','fighter','bi_teams','https://www.buhurtinternational.com/team/new-orleans-storm-riders','new-orleans-storm-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastien Ratard','fighter','bi_teams','https://www.buhurtinternational.com/team/new-orleans-storm-riders','new-orleans-storm-riders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='newbery-fox' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-newbery-fox' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Newbery Fox','Buenos aires',true,'active','public','bi-newbery-fox','SA','South America','AR','Argentina','newberycombatemedieval@gmail.com',NULL,'https://static.wixstatic.com/media/915450_0500dfb28d904a0e8e841f97e36abc4a~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','newbery-fox','https://www.buhurtinternational.com/team/newbery-fox','Newbery Fox','Buenos aires','newberycombatemedieval@gmail.com',NULL,20,'{"biCollectionId":"1299df8f-b755-4259-8020-e8fa7d4564a8","teamName":"Newbery Fox","club":null,"gender":"Male","captain":"Facundo Zorzoli","conference":"South America","country":"Argentina","city":"Buenos aires","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"newberycombatemedieval@gmail.com","teamLogo":"wix:image://v1/915450_0500dfb28d904a0e8e841f97e36abc4a~mv2.jpg/IMG-20250921-WA0003.jpg#originWidth=726&originHeight=728","logoUrl":"https://static.wixstatic.com/media/915450_0500dfb28d904a0e8e841f97e36abc4a~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Miguel pedrola","Facundo Zorzoli","Mariano  kordesch","Gonzalo Lifrieri"],"sourceCreatedAt":"2025-09-21T16:09:23.438Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Newbery Fox',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Buenos aires',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'newberycombatemedieval@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/915450_0500dfb28d904a0e8e841f97e36abc4a~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel pedrola','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-fox','newbery-fox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Facundo Zorzoli','captain','bi_teams','https://www.buhurtinternational.com/team/newbery-fox','newbery-fox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariano  kordesch','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-fox','newbery-fox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gonzalo Lifrieri','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-fox','newbery-fox',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='newbery-harpías' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-newbery-harpías' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Newbery Harpías',NULL,true,'active','public','bi-newbery-harpías','SA','South America','AR','Argentina','newberycombatemedieval@gmail.com',NULL,'https://static.wixstatic.com/media/893006_d204db28be3240b7aa3fd9a3f0cdd7de~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','newbery-harpías','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','Newbery Harpías',NULL,'newberycombatemedieval@gmail.com',NULL,20,'{"biCollectionId":"bf0a889d-7aae-4998-b9c4-cc730a68cb75","teamName":"Newbery Harpías","club":null,"gender":"Female","captain":"Carolina Soledad Elias Picabea","conference":"South America","country":"Argentina","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"newberycombatemedieval@gmail.com","teamLogo":"wix:image://v1/893006_d204db28be3240b7aa3fd9a3f0cdd7de~mv2.jpg/IMG-20250921-WA0009.jpg#originWidth=726&originHeight=728","logoUrl":"https://static.wixstatic.com/media/893006_d204db28be3240b7aa3fd9a3f0cdd7de~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Carolina Soledad Elias Picabea","Mariel Natalia","MelisaRecalde","Nadia Kerzman","Nadia Belen Verbes","Sabrina Arias"],"sourceCreatedAt":"2025-09-21T16:25:31.661Z","sourceUpdatedAt":"2026-09-24T18:21:42.905Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Newbery Harpías',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'newberycombatemedieval@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/893006_d204db28be3240b7aa3fd9a3f0cdd7de~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carolina Soledad Elias Picabea','captain','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariel Natalia','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MelisaRecalde','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nadia Kerzman','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nadia Belen Verbes','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sabrina Arias','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-harp%C3%ADas','newbery-harpías',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='newbery-vulpes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-newbery-vulpes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Newbery Vulpes','Ciudad Autonoma de Buenos Aires',true,'active','public','bi-newbery-vulpes','SA','South America','AR','Argentina','newberycombatemedieval@gmail.com','https://m.facebook.com/espadasrojascombatemedieval/','https://static.wixstatic.com/media/f11091_9f3396a70f1a45b2a685d767ff6978e6~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','newbery-vulpes','https://www.buhurtinternational.com/team/newbery-vulpes','Newbery Vulpes','Ciudad Autonoma de Buenos Aires','newberycombatemedieval@gmail.com','https://m.facebook.com/espadasrojascombatemedieval/',20,'{"biCollectionId":"2a16dbaf-38ba-4d00-a6dc-9b2bd8a382b7","teamName":"Newbery Vulpes","club":null,"gender":"Male","captain":"Julian Perfetti","conference":"South America","country":"Argentina","city":"Ciudad Autonoma de Buenos Aires","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://m.facebook.com/espadasrojascombatemedieval/","teamEmail":"newberycombatemedieval@gmail.com","teamLogo":"wix:image://v1/f11091_9f3396a70f1a45b2a685d767ff6978e6~mv2.jpg/IMG-20250921-WA0021.jpg#originWidth=726&originHeight=728","logoUrl":"https://static.wixstatic.com/media/f11091_9f3396a70f1a45b2a685d767ff6978e6~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Julian Perfetti","Patricio Alejandro Castagnet","ELIAN BERTONERI","Matias Nahuel De Lisio"],"sourceCreatedAt":"2025-09-21T16:06:00.837Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Newbery Vulpes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ciudad Autonoma de Buenos Aires',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'newberycombatemedieval@gmail.com'),
 website_url=coalesce(t.website_url,'https://m.facebook.com/espadasrojascombatemedieval/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f11091_9f3396a70f1a45b2a685d767ff6978e6~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Perfetti','captain','bi_teams','https://www.buhurtinternational.com/team/newbery-vulpes','newbery-vulpes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patricio Alejandro Castagnet','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-vulpes','newbery-vulpes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'ELIAN BERTONERI','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-vulpes','newbery-vulpes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matias Nahuel De Lisio','fighter','bi_teams','https://www.buhurtinternational.com/team/newbery-vulpes','newbery-vulpes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='nexus-medieval-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-nexus-medieval-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'NEXUS MEDIEVAL COMBAT',NULL,true,'active','public','bi-nexus-medieval-combat','EU','Europe','ES','Spain','nexusglobalcombat@gmail.com',NULL,'https://static.wixstatic.com/media/456192_69d996cfdc934a63a539242afdd8bcbe~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','nexus-medieval-combat','https://www.buhurtinternational.com/team/nexus-medieval-combat','NEXUS MEDIEVAL COMBAT',NULL,'nexusglobalcombat@gmail.com',NULL,20,'{"biCollectionId":"214ed03e-2bdf-49d8-8b26-d5050a4c51f4","teamName":"NEXUS MEDIEVAL COMBAT","club":null,"gender":"Male","captain":"ADRIAN LOPEZ SALAS","conference":"Europe","country":"Spain","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"nexusglobalcombat@gmail.com","teamLogo":"wix:image://v1/456192_69d996cfdc934a63a539242afdd8bcbe~mv2.jpg/photo.jpg#originWidth=640&originHeight=640","logoUrl":"https://static.wixstatic.com/media/456192_69d996cfdc934a63a539242afdd8bcbe~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["ADRIAN LOPEZ SALAS","Adrián López Salas","Alberto Prada Sanchez","Llanos Palacios Aparicio","RAUL PALACIOS GONZALEZ","Silvia Ramos García"],"sourceCreatedAt":"2026-08-24T19:13:33.932Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('NEXUS MEDIEVAL COMBAT',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nexusglobalcombat@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/456192_69d996cfdc934a63a539242afdd8bcbe~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'ADRIAN LOPEZ SALAS','captain','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrián López Salas','fighter','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Prada Sanchez','fighter','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Llanos Palacios Aparicio','fighter','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'RAUL PALACIOS GONZALEZ','fighter','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silvia Ramos García','fighter','bi_teams','https://www.buhurtinternational.com/team/nexus-medieval-combat','nexus-medieval-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='nomads-armored-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-nomads-armored-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Nomads Armored Combat','Utah',true,'active','public','bi-nomads-armored-combat','NA','North America','US','United States','nomadsarmoredcombat@gmail.com','http://nomadsarmoredcombat.com/','https://static.wixstatic.com/media/5b2430_0fc52e2c13c140ad9a265874dd89aefa~mv2.png','We are a team that loves to roam, and will fight anywhere the lyst takes us. We want to learn from the best to be the best!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','nomads-armored-combat','https://www.buhurtinternational.com/team/nomads-armored-combat','Nomads Armored Combat','Utah','nomadsarmoredcombat@gmail.com','http://nomadsarmoredcombat.com/',20,'{"biCollectionId":"cb72c173-89a1-4e01-b4e0-d08c88b0c471","teamName":"Nomads Armored Combat","club":null,"gender":"Female","captain":null,"conference":"North America","country":"United States","city":"Utah","teamInfo":"We are a team that loves to roam, and will fight anywhere the lyst takes us. We want to learn from the best to be the best!","trainingInfo":"We are recruiting! Come join us for a practice. Bring workout clothes, water or other hydrating beverages, and a willingness to learn and make friends. We will handle everything else!","trainingLocation":null,"websiteFacebookUrl":"http://nomadsarmoredcombat.com/","teamEmail":"nomadsarmoredcombat@gmail.com","teamLogo":"wix:image://v1/5b2430_0fc52e2c13c140ad9a265874dd89aefa~mv2.png/NomadLogoOffical.png#originWidth=2550&originHeight=3300","logoUrl":"https://static.wixstatic.com/media/5b2430_0fc52e2c13c140ad9a265874dd89aefa~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Geneal Bringman"],"sourceCreatedAt":"2025-11-04T05:45:29.567Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Nomads Armored Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Utah',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nomadsarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'http://nomadsarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5b2430_0fc52e2c13c140ad9a265874dd89aefa~mv2.png'),
 public_description=coalesce(t.public_description,'We are a team that loves to roam, and will fight anywhere the lyst takes us. We want to learn from the best to be the best!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Geneal Bringman','fighter','bi_teams','https://www.buhurtinternational.com/team/nomads-armored-combat','nomads-armored-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='norsemen' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-norsemen' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Norsemen','OSLO',true,'active','public','bi-norsemen','EU','Europe','NO','Norway','norsemen@buhurt.no',NULL,'https://static.wixstatic.com/media/b6ba0e_5ccc3eb1a81143039b2a100b0fb205c2~mv2.jpg','Norwegian team &lt;3')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','norsemen','https://www.buhurtinternational.com/team/norsemen','Norsemen','OSLO','norsemen@buhurt.no',NULL,20,'{"biCollectionId":"3513ef44-444b-4bbb-b3e1-53ba03d81798","teamName":"Norsemen","club":null,"gender":"Male","captain":"Anders Gjestad Rugsveen","conference":"Europe","country":"Norway","city":"OSLO","teamInfo":"Norwegian team &lt;3","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Akershus","name":"Akershus","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Lillestrøm","name":"Lillestrøm","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"NO","name":"Norway","type":"COUNTRY"}],"city":"Frogner","location":{"latitude":60.0238068,"longitude":11.0893603},"streetAddress":{"apt":"","formattedAddressLine":"Trimlåven Treningssenter","name":"Trondheimsveien","number":"296"},"formatted":"Trondheimsveien 296, 2016 Frogner, Norway","country":"NO","postalCode":"2016","subdivision":"03"},"websiteFacebookUrl":null,"teamEmail":"norsemen@buhurt.no","teamLogo":"wix:image://v1/b6ba0e_5ccc3eb1a81143039b2a100b0fb205c2~mv2.jpg/norsemenlogo.jpg#originWidth=828&originHeight=810","logoUrl":"https://static.wixstatic.com/media/b6ba0e_5ccc3eb1a81143039b2a100b0fb205c2~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":7}]},"2025":{"remainingTokens":10}},"members":["Anders Gjestad Rugsveen","Josh Anderson","Nick Møller Pedersen","Olav Ramage","Jesper Marinus Millinge","Sivert Wisth","Sigurd Bredal Jenssen","Magnus Flattum Hansen","Orla Møller","Matt Duncan","Stark Norton","Karl Espe"],"sourceCreatedAt":"2024-06-26T19:26:36.610Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Norsemen',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('OSLO',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NO',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Norway',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'norsemen@buhurt.no'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b6ba0e_5ccc3eb1a81143039b2a100b0fb205c2~mv2.jpg'),
 public_description=coalesce(t.public_description,'Norwegian team &lt;3'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anders Gjestad Rugsveen','captain','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Anderson','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nick Møller Pedersen','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olav Ramage','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesper Marinus Millinge','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sivert Wisth','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sigurd Bredal Jenssen','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Magnus Flattum Hansen','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orla Møller','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matt Duncan','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stark Norton','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karl Espe','fighter','bi_teams','https://www.buhurtinternational.com/team/norsemen','norsemen',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='north-ga-crusaders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-north-ga-crusaders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'North GA Crusaders','Woodstock',true,'active','public','bi-north-ga-crusaders','NA','North America','US','United States','northgacrusaders@gmail.com','https://linktr.ee/NorthGACrusaders','https://static.wixstatic.com/media/2db313_841f52a57b62457f8b1c154bea4852c2~mv2.png','About the Team The North GA Crusaders are a competitive Buhurt team proudly representing North Georgia in the world of full-contact medieval combat. Built on brotherhood, discipline, and a relentless drive to compete, we train to fight hard, grow together, and represent our community on the national stage. Whether you’re an experienced fighter or ready to step into armor for the first time, the Crusaders are always looking for those willing to answer the call. Faith. Strength. Brotherhood. Fide Fortes.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','north-ga-crusaders','https://www.buhurtinternational.com/team/north-ga-crusaders','North GA Crusaders','Woodstock','northgacrusaders@gmail.com','https://linktr.ee/NorthGACrusaders',20,'{"biCollectionId":"ba5bce8b-0b43-4009-9a98-712b5f09da7a","teamName":"North GA Crusaders","club":null,"gender":"Male","captain":"Corbin Hall","conference":"North America","country":"United States","city":"Woodstock","teamInfo":"About the Team The North GA Crusaders are a competitive Buhurt team proudly representing North Georgia in the world of full-contact medieval combat. Built on brotherhood, discipline, and a relentless drive to compete, we train to fight hard, grow together, and represent our community on the national stage. Whether you’re an experienced fighter or ready to step into armor for the first time, the Crusaders are always looking for those willing to answer the call. Faith. Strength. Brotherhood. Fide Fortes.","trainingInfo":"First Practice No equipment needed for your first practice! Just come ready to learn, work, and sweat. Wear shorts, a T-shirt, and running shoes , bring plenty of water, and be prepared to take in a lot of information as we introduce you to the fundamentals of Buhurt. Come ready to move. We’ll handle the rest.","trainingLocation":{"subdivisions":[{"code":"GA","name":"Georgia","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Cherokee County","name":"Cherokee County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Woodstock","name":"Woodstock","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Woodstock","location":{"latitude":34.1141894,"longitude":-84.4935069},"streetAddress":{"apt":"","formattedAddressLine":"JJ Biello Park","name":"Druw Cameron Court","number":"610"},"formatted":"610 Druw Cameron Ct, Woodstock, GA 30188, USA","country":"US","postalCode":"30188","subdivision":"GA"},"websiteFacebookUrl":"https://linktr.ee/NorthGACrusaders","teamEmail":"northgacrusaders@gmail.com","teamLogo":"wix:image://v1/2db313_841f52a57b62457f8b1c154bea4852c2~mv2.png/1%201%20Squared%20Brand%20Logo.png#originWidth=1254&originHeight=1254","logoUrl":"https://static.wixstatic.com/media/2db313_841f52a57b62457f8b1c154bea4852c2~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Corbin Hall","Corbin Sky Hall","Austin Solomon","Stone Shallat"],"sourceCreatedAt":"2026-08-07T14:35:40.674Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('North GA Crusaders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Woodstock',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'northgacrusaders@gmail.com'),
 website_url=coalesce(t.website_url,'https://linktr.ee/NorthGACrusaders'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2db313_841f52a57b62457f8b1c154bea4852c2~mv2.png'),
 public_description=coalesce(t.public_description,'About the Team The North GA Crusaders are a competitive Buhurt team proudly representing North Georgia in the world of full-contact medieval combat. Built on brotherhood, discipline, and a relentless drive to compete, we train to fight hard, grow together, and represent our community on the national stage. Whether you’re an experienced fighter or ready to step into armor for the first time, the Crusaders are always looking for those willing to answer the call. Faith. Strength. Brotherhood. Fide Fortes.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corbin Hall','captain','bi_teams','https://www.buhurtinternational.com/team/north-ga-crusaders','north-ga-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corbin Sky Hall','fighter','bi_teams','https://www.buhurtinternational.com/team/north-ga-crusaders','north-ga-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Austin Solomon','fighter','bi_teams','https://www.buhurtinternational.com/team/north-ga-crusaders','north-ga-crusaders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stone Shallat','fighter','bi_teams','https://www.buhurtinternational.com/team/north-ga-crusaders','north-ga-crusaders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='northblood' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-northblood' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Scallagrims','Toronto',true,'active','public','bi-northblood','NA','North America','CA','Canada','northbloodcanada@gmail.com',NULL,'https://static.wixstatic.com/media/0000cf_40a72c06d4064668b5859d5430d38958~mv2.png','Elite club from Canada')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','northblood','https://www.buhurtinternational.com/team/northblood','Scallagrims','Toronto','northbloodcanada@gmail.com',NULL,20,'{"biCollectionId":"d0358c40-79b3-4d77-bd20-e0989a976c17","teamName":"Scallagrims","club":null,"gender":"Male","captain":"Joshua Russell Friars","conference":"North America","country":"Canada","city":"Toronto","teamInfo":"Elite club from Canada","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"northbloodcanada@gmail.com","teamLogo":"wix:image://v1/0000cf_40a72c06d4064668b5859d5430d38958~mv2.png/scallagrims%20logo%20best%20HD.png#originWidth=1386&originHeight=1338","logoUrl":"https://static.wixstatic.com/media/0000cf_40a72c06d4064668b5859d5430d38958~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":10}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":9,"tournaments":[{"_id":"1","points":2,"Tournament":"Eastern War Tide 2025","date":"2025-09-27","category":"5vs5","place":2}]}},"members":["Alexander Rosenthal-Rashi","Grygoriy Polovyy","Adam Jeremy Clark","Joshua Russell Friars","Talon mathers","Kirk Sinclair","germain kierdorf"],"sourceCreatedAt":"2024-06-24T23:22:47.511Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Scallagrims',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Toronto',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'northbloodcanada@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/0000cf_40a72c06d4064668b5859d5430d38958~mv2.png'),
 public_description=coalesce(t.public_description,'Elite club from Canada'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Rosenthal-Rashi','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Grygoriy Polovyy','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Jeremy Clark','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Russell Friars','captain','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Talon mathers','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kirk Sinclair','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'germain kierdorf','fighter','bi_teams','https://www.buhurtinternational.com/team/northblood','northblood',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='nyc-armored-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-nyc-armored-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Plague Rats','New York City',true,'active','public','bi-nyc-armored-combat','NA','North America','US','United States','nycarmoredcombat@gmail.com','https://nycarmoredcombat.com/','https://static.wixstatic.com/media/35ca85_6087841944ba419bbc7046f98836e5f0~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','nyc-armored-combat','https://www.buhurtinternational.com/team/nyc-armored-combat','Plague Rats','New York City','nycarmoredcombat@gmail.com','https://nycarmoredcombat.com/',20,'{"biCollectionId":"8a467436-54a7-4511-abc8-1f9113c68d2b","teamName":"Plague Rats","club":null,"gender":"Male","captain":"Marco Damiano","conference":"North America","country":"United States","city":"New York City","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://nycarmoredcombat.com/","teamEmail":"nycarmoredcombat@gmail.com","teamLogo":"wix:image://v1/35ca85_6087841944ba419bbc7046f98836e5f0~mv2.jpg/d2650a4d-01f4-42a4-9185-393c61501833.jpg#originWidth=699&originHeight=800","logoUrl":"https://static.wixstatic.com/media/35ca85_6087841944ba419bbc7046f98836e5f0~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":11}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":5},{"_id":"2","points":1.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":13},{"_id":"3","points":0,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":23},{"_id":"4","points":6,"Tournament":"Blood & Steel 7 2024","date":"2024-10-19","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":14},{"_id":"2","points":3,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":7},{"_id":"3","points":1.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":12},{"_id":"4","points":1.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":5},{"_id":"5","points":1,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":5},{"_id":"6","points":2,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":6}],"points12v12":1.5,"averagePoints5v5":2.33,"rank5v5":16,"remainingTokens":9,"points5v5":9.5}},"members":["Marco Damiano","Joseph Damiano","Isaac Solomon","Omar megahed","Ryan Howard","Charlie Siebert","Jose Abraham Diaz Raitz","Gabriel Orellana","Alessandro Grille","Eric Hiller","Christopher Cooper"],"sourceCreatedAt":"2024-02-15T02:55:49.898Z","sourceUpdatedAt":"2026-09-26T01:50:42.637Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Plague Rats',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('New York City',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nycarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://nycarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/35ca85_6087841944ba419bbc7046f98836e5f0~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco Damiano','captain','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Damiano','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isaac Solomon','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Omar megahed','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Howard','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charlie Siebert','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Abraham Diaz Raitz','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Orellana','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alessandro Grille','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric Hiller','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Cooper','fighter','bi_teams','https://www.buhurtinternational.com/team/nyc-armored-combat','nyc-armored-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='oklahoma-city-red-dirt-reapers-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-oklahoma-city-red-dirt-reapers-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Oklahoma City Red Dirt Reapers ',NULL,true,'active','public','bi-oklahoma-city-red-dirt-reapers-','NA','North America','US','United States','matthewnothstine@yahoo.com',NULL,'https://static.wixstatic.com/media/9eb525_d6685582782f4909a39469eb1b43093a~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','oklahoma-city-red-dirt-reapers-','https://www.buhurtinternational.com/team/oklahoma-city-red-dirt-reapers-','Oklahoma City Red Dirt Reapers ',NULL,'matthewnothstine@yahoo.com',NULL,20,'{"biCollectionId":"89926dc6-b10d-4cc1-80d4-21f3fe4b30a3","teamName":"Oklahoma City Red Dirt Reapers ","club":null,"gender":"Male","captain":"Matthew Nothstine ","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"matthewnothstine@yahoo.com","teamLogo":"wix:image://v1/9eb525_d6685582782f4909a39469eb1b43093a~mv2.jpeg/received_1007110431364155.jpeg#originWidth=4000&originHeight=2334","logoUrl":"https://static.wixstatic.com/media/9eb525_d6685582782f4909a39469eb1b43093a~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Matthew Nothstine","Taylor Burrows","Bull Eston Barrow Jr","Michael Holmstrom"],"sourceCreatedAt":"2025-06-18T19:16:21.791Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Oklahoma City Red Dirt Reapers ',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'matthewnothstine@yahoo.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9eb525_d6685582782f4909a39469eb1b43093a~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Nothstine','captain','bi_teams','https://www.buhurtinternational.com/team/oklahoma-city-red-dirt-reapers-','oklahoma-city-red-dirt-reapers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taylor Burrows','fighter','bi_teams','https://www.buhurtinternational.com/team/oklahoma-city-red-dirt-reapers-','oklahoma-city-red-dirt-reapers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bull Eston Barrow Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/oklahoma-city-red-dirt-reapers-','oklahoma-city-red-dirt-reapers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Holmstrom','fighter','bi_teams','https://www.buhurtinternational.com/team/oklahoma-city-red-dirt-reapers-','oklahoma-city-red-dirt-reapers-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='old-mates' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-old-mates' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Old Mates','Sydney',true,'active','public','bi-old-mates','OC','Oceania','AU','Australia','teamhavocamcf@gmail.com',NULL,'https://static.wixstatic.com/media/5d39a4_a52326f3935f4060aff72a4dd42952e0~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','old-mates','https://www.buhurtinternational.com/team/old-mates','Old Mates','Sydney','teamhavocamcf@gmail.com',NULL,20,'{"biCollectionId":"ae3f9bca-78ad-4b30-a770-349cae477b99","teamName":"Old Mates","club":null,"gender":"Male","captain":"Simon Hand","conference":"APAC","country":"Australia","city":"Sydney","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"teamhavocamcf@gmail.com","teamLogo":"wix:image://v1/5d39a4_a52326f3935f4060aff72a4dd42952e0~mv2.jpeg/IMG_1818.jpeg#originWidth=1160&originHeight=1641","logoUrl":"https://static.wixstatic.com/media/5d39a4_a52326f3935f4060aff72a4dd42952e0~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":11}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":0,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":13},{"_id":"2","points":1,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":6},{"_id":"3","points":12,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":4.33,"rank5v5":4,"remainingTokens":6,"points5v5":13}},"members":["Adam Miller","Andrew Dolmah","Simon Hand","Luke Vairy"],"sourceCreatedAt":"2024-09-05T13:07:52.778Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Old Mates',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sydney',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'teamhavocamcf@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5d39a4_a52326f3935f4060aff72a4dd42952e0~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Miller','fighter','bi_teams','https://www.buhurtinternational.com/team/old-mates','old-mates',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Dolmah','fighter','bi_teams','https://www.buhurtinternational.com/team/old-mates','old-mates',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Hand','captain','bi_teams','https://www.buhurtinternational.com/team/old-mates','old-mates',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Vairy','fighter','bi_teams','https://www.buhurtinternational.com/team/old-mates','old-mates',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='omaha-hell-hounds' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-omaha-hell-hounds' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Omaha Hell Hounds','Omaha',true,'active','public','bi-omaha-hell-hounds','NA','North America','US','United States','omahahellhounds@gmail.com',NULL,'https://static.wixstatic.com/media/155aae_04d4cb334f964061b4c308a59adfb309~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','omaha-hell-hounds','https://www.buhurtinternational.com/team/omaha-hell-hounds','Omaha Hell Hounds','Omaha','omahahellhounds@gmail.com',NULL,20,'{"biCollectionId":"6b5fb404-9290-433d-b84d-8bdf97061f52","teamName":"Omaha Hell Hounds","club":null,"gender":"Male","captain":"Caleb Ortman","conference":"North America","country":"United States","city":"Omaha","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"omahahellhounds@gmail.com","teamLogo":"wix:image://v1/155aae_04d4cb334f964061b4c308a59adfb309~mv2.jpg/Screenshot_20250731_220749_Firefox.jpg#originWidth=1079&originHeight=952","logoUrl":"https://static.wixstatic.com/media/155aae_04d4cb334f964061b4c308a59adfb309~mv2.jpg","rank5v5":16,"averagePoints5v5":1,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":8},{"_id":"2","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":5},{"_id":"3","points":0,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":16},{"_id":"4","points":1,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":6}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":9,"remainingTokens":8,"tournaments":[{"_id":"1","points":9,"Tournament":"Cream City Clash 3 2025","date":"2025-08-30","category":"5vs5","place":1}]}},"members":["Alex Kerwin","Brandon Riggle","Caleb Ortman","Jeremiah Johnson","Nicholas Aaron Madison","Alexander Garver","Ayden Evans","Matthew Bles","Muhammadkhon Nasimov","Dave Rosser","Benjamin Splitter","Andrew Iamelli","Jack Dennerlein","Andrew Spanjers"],"sourceCreatedAt":"2025-08-01T03:11:14.563Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Omaha Hell Hounds',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Omaha',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'omahahellhounds@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/155aae_04d4cb334f964061b4c308a59adfb309~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Kerwin','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Riggle','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caleb Ortman','captain','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeremiah Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Aaron Madison','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Garver','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ayden Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Bles','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Muhammadkhon Nasimov','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dave Rosser','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Splitter','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Iamelli','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Dennerlein','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Spanjers','fighter','bi_teams','https://www.buhurtinternational.com/team/omaha-hell-hounds','omaha-hell-hounds',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='one-eyed-one--horned-flying-purple-people-eaters' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-one-eyed-one--horned-flying-purple-people-eaters' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Purple People Eaters','Irmo',true,'active','public','bi-one-eyed-one--horned-flying-purple-people-eaters','NA','North America','US','United States','elfmaiden111@gmail.com',NULL,'https://static.wixstatic.com/media/573e9e_d2ba50a98ae14183aa60ba4871de41e1~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','one-eyed-one--horned-flying-purple-people-eaters','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','Purple People Eaters','Irmo','elfmaiden111@gmail.com',NULL,20,'{"biCollectionId":"7227b168-821c-4280-ae15-c6f6553e1172","teamName":"Purple People Eaters","club":null,"gender":"Female","captain":"Christine Napolitano","conference":"North America","country":"United States","city":"Irmo","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"elfmaiden111@gmail.com","teamLogo":"wix:image://v1/573e9e_d2ba50a98ae14183aa60ba4871de41e1~mv2.jpeg/Messenger_creation_84AD5612-E36E-4BBC-97AE-A2AAA2FDCE28.jpeg#originWidth=2100&originHeight=1500","logoUrl":"https://static.wixstatic.com/media/573e9e_d2ba50a98ae14183aa60ba4871de41e1~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":2}],"eventsHistory":{},"members":["Christine Napolitano","Hunter Crawley","Katie Bowman","Elyce Ellington","Leandra Dawson van Veen","Rachael Elizabeth Arndt","Rachael Chae"],"sourceCreatedAt":"2026-02-10T23:28:03.057Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Purple People Eaters',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Irmo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'elfmaiden111@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/573e9e_d2ba50a98ae14183aa60ba4871de41e1~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christine Napolitano','captain','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hunter Crawley','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Katie Bowman','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elyce Ellington','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leandra Dawson van Veen','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachael Elizabeth Arndt','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachael Chae','fighter','bi_teams','https://www.buhurtinternational.com/team/one-eyed-one--horned-flying-purple-people-eaters','one-eyed-one--horned-flying-purple-people-eaters',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='order-of-the-black-bear' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-order-of-the-black-bear' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Order of the Black Bear','Birmingham/Auburn AL',true,'active','public','bi-order-of-the-black-bear','NA','North America','US','United States','orderoftheblackbear@gmail.com','https://www.instagram.com/orderoftheblackbear/','https://static.wixstatic.com/media/8cc3b6_7fcd0afa1ec841b4be0c76fe70c9064c~mv2.png','Order of the Black Bear was founded in mid 2025 and functions out of central Alabama')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','order-of-the-black-bear','https://www.buhurtinternational.com/team/order-of-the-black-bear','Order of the Black Bear','Birmingham/Auburn AL','orderoftheblackbear@gmail.com','https://www.instagram.com/orderoftheblackbear/',20,'{"biCollectionId":"16a8f026-f510-43eb-98f9-362eff1425ff","teamName":"Order of the Black Bear","club":null,"gender":"Male","captain":"Gabriel Cooper","conference":"North America","country":"United States","city":"Birmingham/Auburn AL","teamInfo":"Order of the Black Bear was founded in mid 2025 and functions out of central Alabama","trainingInfo":"All you need for your first time training is a mouthguard, cup, water, athletic wear, and a positive attitude!","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/orderoftheblackbear/","teamEmail":"orderoftheblackbear@gmail.com","teamLogo":"wix:image://v1/8cc3b6_7fcd0afa1ec841b4be0c76fe70c9064c~mv2.png/logo%20resize.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/8cc3b6_7fcd0afa1ec841b4be0c76fe70c9064c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Gabriel Cooper","Christopher Boyd","Phillip Le","Robert Eric White"],"sourceCreatedAt":"2026-02-14T22:39:47.084Z","sourceUpdatedAt":"2026-09-29T20:13:51.835Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Order of the Black Bear',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Birmingham/Auburn AL',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'orderoftheblackbear@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/orderoftheblackbear/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8cc3b6_7fcd0afa1ec841b4be0c76fe70c9064c~mv2.png'),
 public_description=coalesce(t.public_description,'Order of the Black Bear was founded in mid 2025 and functions out of central Alabama'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Cooper','captain','bi_teams','https://www.buhurtinternational.com/team/order-of-the-black-bear','order-of-the-black-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Boyd','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-black-bear','order-of-the-black-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Phillip Le','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-black-bear','order-of-the-black-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Eric White','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-black-bear','order-of-the-black-bear',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='order-of-the-gauntlet-and-rose' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-order-of-the-gauntlet-and-rose' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Order of the Gauntlet and Rose','Fresno',true,'active','public','bi-order-of-the-gauntlet-and-rose','NA','North America','US','United States','orderofthegauntletandrose@gmail.com','https://www.facebook.com/groups/687576738097779/','https://static.wixstatic.com/media/121df1_d7f90e2ec6eb4b3bbe8df0d32ba8ccf4~mv2.png','Fresno based Buhurt team that trains in the Madera Ranchos area.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','order-of-the-gauntlet-and-rose','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','Order of the Gauntlet and Rose','Fresno','orderofthegauntletandrose@gmail.com','https://www.facebook.com/groups/687576738097779/',20,'{"biCollectionId":"9c9237ec-d4d0-4045-9e69-7794b7481044","teamName":"Order of the Gauntlet and Rose","club":null,"gender":"Male","captain":"Darrian Dukes","conference":"North America","country":"United States","city":"Fresno","teamInfo":"Fresno based Buhurt team that trains in the Madera Ranchos area.","trainingInfo":"Bring work out attire, water, groin protection and good attitude, ready to work.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/687576738097779/","teamEmail":"orderofthegauntletandrose@gmail.com","teamLogo":"wix:image://v1/121df1_d7f90e2ec6eb4b3bbe8df0d32ba8ccf4~mv2.png/Order%20of%20the.png.PNG#originWidth=3864&originHeight=3864","logoUrl":"https://static.wixstatic.com/media/121df1_d7f90e2ec6eb4b3bbe8df0d32ba8ccf4~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":6}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":18},{"_id":"2","points":0,"Tournament":"Ventura Melee Megabowl 2024","date":"14-04-2024","category":"5vs5","place":7},{"_id":"3","points":0,"Tournament":"California Classic 2024","date":"2024-09-21","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":9,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":2},{"_id":"2","points":12,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":1},{"_id":"3","points":6,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":3}],"points12v12":0,"averagePoints5v5":9,"rank5v5":5,"remainingTokens":0,"points5v5":27}},"members":["Darrian Dukes","Dylan Sweeney","Isaac Ellis","WESLEY J SUDWEEKS","Eric Tafoya","Cade Zimmerman","Mark Jackson"],"sourceCreatedAt":"2023-07-23T03:32:06.181Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Order of the Gauntlet and Rose',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Fresno',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'orderofthegauntletandrose@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/687576738097779/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/121df1_d7f90e2ec6eb4b3bbe8df0d32ba8ccf4~mv2.png'),
 public_description=coalesce(t.public_description,'Fresno based Buhurt team that trains in the Madera Ranchos area.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Darrian Dukes','captain','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Sweeney','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isaac Ellis','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'WESLEY J SUDWEEKS','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric Tafoya','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cade Zimmerman','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark Jackson','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-gauntlet-and-rose','order-of-the-gauntlet-and-rose',now());
end $$;
commit;
