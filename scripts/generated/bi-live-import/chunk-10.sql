begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vagabonds-errant' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vagabonds-errant' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vagabonds Errant','Seattle, WA',true,'active','public','bi-vagabonds-errant','NA','North America','US','United States','yorkmanuel77@gmail.com','https://www.facebook.com/share/1FPg2K8jmQ/?mibextid=wwXIfr','https://static.wixstatic.com/media/279b8e_8ea0b5cddd954d619583244dd47aa1ce~mv2.png','Vagabonds Errant is the secondary team to the Vagabonds, which Johny Porter also captains.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vagabonds-errant','https://www.buhurtinternational.com/team/vagabonds-errant','Vagabonds Errant','Seattle, WA','yorkmanuel77@gmail.com','https://www.facebook.com/share/1FPg2K8jmQ/?mibextid=wwXIfr',20,'{"biCollectionId":"59bc5949-69a2-497b-8262-aa0307c32c3a","teamName":"Vagabonds Errant","club":null,"gender":"Male","captain":"Johny Porter","conference":"North America","country":"United States","city":"Seattle, WA","teamInfo":"Vagabonds Errant is the secondary team to the Vagabonds, which Johny Porter also captains.","trainingInfo":"We are a roaming warband, a brotherhood of vagabonds who trade comfort for combat: no banners to hide behind, only strength, grit, and steel. When we step into the lyst, we come like a prairie tempest: sudden, violent, and unstoppable.","trainingLocation":{"subdivisions":[{"code":"WA","name":"Washington","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"King County","name":"King County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Seattle","name":"Seattle","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"Highline","name":"Highline","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Seattle","location":{"latitude":47.5115141,"longitude":-122.3146924},"streetAddress":{"apt":"","formattedAddressLine":"1418 S 103rd St","name":"South 103rd Street","number":"1418"},"formatted":"1418 S 103rd St, Seattle, WA 98168, USA","country":"US","postalCode":"98168-1622","subdivision":"WA"},"websiteFacebookUrl":"https://www.facebook.com/share/1FPg2K8jmQ/?mibextid=wwXIfr","teamEmail":"yorkmanuel77@gmail.com","teamLogo":"wix:image://v1/279b8e_8ea0b5cddd954d619583244dd47aa1ce~mv2.png/Vagabond%20Errant%20Logo.png#originWidth=483&originHeight=576","logoUrl":"https://static.wixstatic.com/media/279b8e_8ea0b5cddd954d619583244dd47aa1ce~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":6},{"_id":"2","points":1,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":5}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Johny Porter","Alex gleckl","Kyle Lawrence","Jeffrey Bugh","Hunter Rhoades","Quentin Salinas"],"sourceCreatedAt":"2025-10-09T01:48:26.927Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vagabonds Errant',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Seattle, WA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'yorkmanuel77@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1FPg2K8jmQ/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/279b8e_8ea0b5cddd954d619583244dd47aa1ce~mv2.png'),
 public_description=coalesce(t.public_description,'Vagabonds Errant is the secondary team to the Vagabonds, which Johny Porter also captains.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johny Porter','captain','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex gleckl','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Lawrence','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeffrey Bugh','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hunter Rhoades','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quentin Salinas','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-errant','vagabonds-errant',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vagabonds-vanguard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vagabonds-vanguard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vagabonds Vanguard','Seattle',true,'active','public','bi-vagabonds-vanguard','NA','North America','US','United States','johnyporter101@gmail.com',NULL,'https://static.wixstatic.com/media/6dda3d_24af6e654cfb434082d13e7547cf6269~mv2.png','the 3rd tournament roster for the Vagabonds')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vagabonds-vanguard','https://www.buhurtinternational.com/team/vagabonds-vanguard','Vagabonds Vanguard','Seattle','johnyporter101@gmail.com',NULL,20,'{"biCollectionId":"80e661cb-87c6-4e44-8477-be5d50ac6cc4","teamName":"Vagabonds Vanguard","club":null,"gender":"Male","captain":"Johny Porter","conference":"North America","country":"United States","city":"Seattle","teamInfo":"the 3rd tournament roster for the Vagabonds","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"johnyporter101@gmail.com","teamLogo":"wix:image://v1/6dda3d_24af6e654cfb434082d13e7547cf6269~mv2.png/carnage%20patch.png#originWidth=264&originHeight=248","logoUrl":"https://static.wixstatic.com/media/6dda3d_24af6e654cfb434082d13e7547cf6269~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":6}],"eventsHistory":{},"members":["Johny Porter","Joseph R Corbitt","Spencer Mason","Benjamin David Mulkey","Kendall Jackson","Jonathan Tillmon","Lonnie Bryant","RICHARD RAFAEL MARQUEZ","Kenon Jeffers"],"sourceCreatedAt":"2026-08-18T23:57:07.877Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vagabonds Vanguard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Seattle',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'johnyporter101@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6dda3d_24af6e654cfb434082d13e7547cf6269~mv2.png'),
 public_description=coalesce(t.public_description,'the 3rd tournament roster for the Vagabonds'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johny Porter','captain','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph R Corbitt','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Spencer Mason','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin David Mulkey','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kendall Jackson','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Tillmon','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lonnie Bryant','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'RICHARD RAFAEL MARQUEZ','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kenon Jeffers','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds-vanguard','vagabonds-vanguard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='valentia-regnum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-valentia-regnum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'VALENTIA REGNUM','Valencia',true,'active','public','bi-valentia-regnum','EU','Europe','ES','Spain','morkdam@hotmail.com',NULL,'https://static.wixstatic.com/media/c9a20d_f8e058be1af2485ba479837ae58e2e43~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','valentia-regnum','https://www.buhurtinternational.com/team/valentia-regnum','VALENTIA REGNUM','Valencia','morkdam@hotmail.com',NULL,20,'{"biCollectionId":"1639e1c0-b25f-4b88-8a87-1bf320586fa5","teamName":"VALENTIA REGNUM","club":null,"gender":"Female","captain":"YVONNE WIDIN","conference":"Europe","country":"Spain","city":"Valencia","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"morkdam@hotmail.com","teamLogo":"wix:image://v1/c9a20d_f8e058be1af2485ba479837ae58e2e43~mv2.png/Captura%20de%20pantalla%202025-08-29%20001736.png#originWidth=160&originHeight=170","logoUrl":"https://static.wixstatic.com/media/c9a20d_f8e058be1af2485ba479837ae58e2e43~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":6}},"members":["Yvonne Widin"],"sourceCreatedAt":"2025-08-28T22:18:56.143Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('VALENTIA REGNUM',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Valencia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'morkdam@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c9a20d_f8e058be1af2485ba479837ae58e2e43~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yvonne Widin','captain','bi_teams','https://www.buhurtinternational.com/team/valentia-regnum','valentia-regnum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='valherjes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-valherjes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Valherjes','Buenos Aires',true,'active','public','bi-valherjes','SA','South America','AR','Argentina','hmb.valherjes@gmail.com','https://www.facebook.com/ValherjesCombateMedieval','https://static.wixstatic.com/media/e251ae_ecaadd9a0f4145c69b0a7aefd7cbf7fd~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','valherjes','https://www.buhurtinternational.com/team/valherjes','Valherjes','Buenos Aires','hmb.valherjes@gmail.com','https://www.facebook.com/ValherjesCombateMedieval',20,'{"biCollectionId":"4f8cde9f-3566-4bef-8c4e-059302687391","teamName":"Valherjes","club":null,"gender":"Male","captain":"Marcos Villani","conference":"South America","country":"Argentina","city":"Buenos Aires","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/ValherjesCombateMedieval","teamEmail":"hmb.valherjes@gmail.com","teamLogo":"wix:image://v1/e251ae_ecaadd9a0f4145c69b0a7aefd7cbf7fd~mv2.png/logo%20cuadrado%20fondo%20transparente.png#originWidth=1125&originHeight=1125","logoUrl":"https://static.wixstatic.com/media/e251ae_ecaadd9a0f4145c69b0a7aefd7cbf7fd~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":12,"Tournament":"Copa Centinela 2024","date":"2024-05-04","category":"5vs5","place":1}]},"2025":{"remainingTokens":10}},"members":["Marcos Villani","Pablo Andres Villani","Alejandro Pellicciotta","Nazareno GIL","Ariel noguera","Emiliano Hernán Vallejos","ALCIDES HECTOR FERNANDEZ","Franco Vazquez"],"sourceCreatedAt":"2023-09-13T15:08:55.230Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Valherjes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Buenos Aires',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hmb.valherjes@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ValherjesCombateMedieval'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e251ae_ecaadd9a0f4145c69b0a7aefd7cbf7fd~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Villani','captain','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pablo Andres Villani','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alejandro Pellicciotta','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nazareno GIL','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ariel noguera','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emiliano Hernán Vallejos','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'ALCIDES HECTOR FERNANDEZ','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Franco Vazquez','fighter','bi_teams','https://www.buhurtinternational.com/team/valherjes','valherjes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vandals' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vandals' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vandals','Boston',true,'active','public','bi-vandals','NA','North America','US','United States','mrie.brooks1@gmail.com',NULL,'https://static.wixstatic.com/media/7c3845_f724ba6089f54793ad3796fae62b1bf8~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vandals','https://www.buhurtinternational.com/team/vandals','Vandals','Boston','mrie.brooks1@gmail.com',NULL,20,'{"biCollectionId":"1a562a86-bab1-4698-b6da-748d3e5ce3b8","teamName":"Vandals","club":null,"gender":"Female","captain":"Amari Brooks","conference":"North America","country":"United States","city":"Boston","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"mrie.brooks1@gmail.com","teamLogo":"wix:image://v1/7c3845_f724ba6089f54793ad3796fae62b1bf8~mv2.jpg/vndl.jpg#originWidth=900&originHeight=900","logoUrl":"https://static.wixstatic.com/media/7c3845_f724ba6089f54793ad3796fae62b1bf8~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":5},{"_id":"2","points":2,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":4,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":5}]}},"members":["Amari Brooks","Colton kilcoyne","Meaghan Slottje","Julie Jacob","Emma Kennedy","Pasha Isley","Megan Ganley"],"sourceCreatedAt":"2024-02-23T14:31:05.386Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vandals',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Boston',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mrie.brooks1@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7c3845_f724ba6089f54793ad3796fae62b1bf8~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amari Brooks','captain','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colton kilcoyne','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Meaghan Slottje','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julie Jacob','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emma Kennedy','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pasha Isley','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Megan Ganley','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals','vandals',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vandals-ii' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vandals-ii' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Steel Coven','Greensboro',true,'active','public','bi-vandals-ii','NA','North America','US','United States','itsjocey@gmail.com',NULL,'https://static.wixstatic.com/media/7dcd33_ef69d020e83846109444a5965b1a5ba8~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vandals-ii','https://www.buhurtinternational.com/team/vandals-ii','Steel Coven','Greensboro','itsjocey@gmail.com',NULL,20,'{"biCollectionId":"d8565f0d-f0e2-4001-aee4-e053bdcb6d69","teamName":"Steel Coven","club":null,"gender":"Female","captain":"Jocelyn Wright","conference":"North America","country":"United States","city":"Greensboro","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"itsjocey@gmail.com","teamLogo":"wix:image://v1/7dcd33_ef69d020e83846109444a5965b1a5ba8~mv2.png/IMG_3738.png#originWidth=3199&originHeight=3239","logoUrl":"https://static.wixstatic.com/media/7dcd33_ef69d020e83846109444a5965b1a5ba8~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":5,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"3vs3","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2}]},"2025":{"remainingTokens":10}},"members":["Stephanie Kight","Jocelyn Wright","Aja Rhianna"],"sourceCreatedAt":"2024-08-01T20:50:52.614Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Steel Coven',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Greensboro',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'itsjocey@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7dcd33_ef69d020e83846109444a5965b1a5ba8~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephanie Kight','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals-ii','vandals-ii',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jocelyn Wright','captain','bi_teams','https://www.buhurtinternational.com/team/vandals-ii','vandals-ii',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aja Rhianna','fighter','bi_teams','https://www.buhurtinternational.com/team/vandals-ii','vandals-ii',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vespera' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vespera' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vespera',NULL,true,'active','public','bi-vespera','EU','Europe','FR','France','louisehullin@hotmail.fr',NULL,'https://static.wixstatic.com/media/252214_0cc80118f53442bf8fc2d27388c5be5f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vespera','https://www.buhurtinternational.com/team/vespera','Vespera',NULL,'louisehullin@hotmail.fr',NULL,20,'{"biCollectionId":"389fca4a-d43b-4bef-8f7d-6b7e6c36345b","teamName":"Vespera","club":null,"gender":"Female","captain":"Louise HULLIN","conference":"Europe","country":"France","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"louisehullin@hotmail.fr","teamLogo":"wix:image://v1/252214_0cc80118f53442bf8fc2d27388c5be5f~mv2.png/VESPERA.png#originWidth=1715&originHeight=1545","logoUrl":"https://static.wixstatic.com/media/252214_0cc80118f53442bf8fc2d27388c5be5f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":5,"remainingTokens":8,"tournaments":[{"_id":"1","points":8,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"3vs3","place":1},{"_id":"2","points":5,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":2}]}},"members":["Camille Medjkouh boulain","Pinja Laaksonen","Maïwenn FONTAINE","LOUISE HULLIN","Tinja Sarkanen","Sarianne Mentula","Lyse LECLERCQ","Elora Carteret","Laurine André"],"sourceCreatedAt":"2025-03-11T14:22:00.367Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vespera',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'louisehullin@hotmail.fr'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/252214_0cc80118f53442bf8fc2d27388c5be5f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Camille Medjkouh boulain','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pinja Laaksonen','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maïwenn FONTAINE','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LOUISE HULLIN','captain','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tinja Sarkanen','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarianne Mentula','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lyse LECLERCQ','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elora Carteret','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laurine André','fighter','bi_teams','https://www.buhurtinternational.com/team/vespera','vespera',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='victoriam' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-victoriam' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Victoriam','Cleveland',true,'active','public','bi-victoriam','NA','North America','US','United States','victoriamarmoredcombat@gmail.com','https://www.rustbeltarmoredcombat.com/','https://static.wixstatic.com/media/961a49_cc18cbe5e8b542739fa3c20a5b8062e8~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','victoriam','https://www.buhurtinternational.com/team/victoriam','Victoriam','Cleveland','victoriamarmoredcombat@gmail.com','https://www.rustbeltarmoredcombat.com/',20,'{"biCollectionId":"a4d4306f-bcc7-4bff-a0e9-685ae9deb7fb","teamName":"Victoriam","club":null,"gender":"Male","captain":"Brandon Miller","conference":"North America","country":"United States","city":"Cleveland","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.rustbeltarmoredcombat.com/","teamEmail":"victoriamarmoredcombat@gmail.com","teamLogo":"wix:image://v1/961a49_cc18cbe5e8b542739fa3c20a5b8062e8~mv2.jpg/Victoriam%20Logo%20White.jpg#originWidth=1536&originHeight=1536","logoUrl":"https://static.wixstatic.com/media/961a49_cc18cbe5e8b542739fa3c20a5b8062e8~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":2.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":7}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Brandon Miller","Alexander Rohrbaugh","Fred Prillaman","Matthew Biondi","Steve O''Donnell","KEVIN RILEY","Patrick Cooper","Christopher Schindler","Nicholas Robert von Haase","Jordan Louk","Ian Martin"],"sourceCreatedAt":"2025-08-01T04:11:35.247Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Victoriam',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cleveland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'victoriamarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.rustbeltarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/961a49_cc18cbe5e8b542739fa3c20a5b8062e8~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Miller','captain','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Rohrbaugh','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fred Prillaman','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Biondi','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steve O''Donnell','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'KEVIN RILEY','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patrick Cooper','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Schindler','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Robert von Haase','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Louk','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Martin','fighter','bi_teams','https://www.buhurtinternational.com/team/victoriam','victoriam',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='victrix' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-victrix' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'VICTRIX','Valencia',true,'active','public','bi-victrix','EU','Europe','ES','Spain','valentiavictrix@gmail.com','https://www.valentiavictrix.es/','https://static.wixstatic.com/media/e2b7e7_b1e31414006545e7b201345f73101da2~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','victrix','https://www.buhurtinternational.com/team/victrix','VICTRIX','Valencia','valentiavictrix@gmail.com','https://www.valentiavictrix.es/',20,'{"biCollectionId":"b584cfae-df36-45e0-890d-723249dd350f","teamName":"VICTRIX","club":null,"gender":"Male","captain":"Fernando Jose Minguet Gimeno","conference":"Europe","country":"Spain","city":"Valencia","teamInfo":"","trainingInfo":"We&#x27;re allways open for new buhurt entusiasts! Come and join us. All you need is sportive clothes, water and powerwill","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.valentiavictrix.es/","teamEmail":"valentiavictrix@gmail.com","teamLogo":"wix:image://v1/e2b7e7_b1e31414006545e7b201345f73101da2~mv2.png/vv%20logo.png#originWidth=687&originHeight=706","logoUrl":"https://static.wixstatic.com/media/e2b7e7_b1e31414006545e7b201345f73101da2~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":11,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":7,"remainingTokens":10,"tournaments":[{"_id":"1","points":7,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":3}]}},"members":["Fernando Jose Minguet Gimeno","Marcos Jorge Guardia","Víctor Jorge Guardia","Ciprian Octavian Manea","Víctor Benet","Pascual Fernandez Calvo","Juan Santiago Glasman Alvarez","Ivan Varenikov","Aarón llobell ivars","Miguel Angel Mota Castellar"],"sourceCreatedAt":"2024-08-10T10:18:57.739Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('VICTRIX',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Valencia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'valentiavictrix@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.valentiavictrix.es/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e2b7e7_b1e31414006545e7b201345f73101da2~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fernando Jose Minguet Gimeno','captain','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Jorge Guardia','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Víctor Jorge Guardia','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ciprian Octavian Manea','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Víctor Benet','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pascual Fernandez Calvo','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juan Santiago Glasman Alvarez','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Varenikov','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aarón llobell ivars','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel Angel Mota Castellar','fighter','bi_teams','https://www.buhurtinternational.com/team/victrix','victrix',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vienna-basilisks' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vienna-basilisks' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vienna Basilisks','Vienna',true,'active','public','bi-vienna-basilisks','EU','Europe','AT','Austria','lukas.froehling@live.de','https://www.vgvk.at/','https://static.wixstatic.com/media/b7aaf8_a1f5a381a22742908fca719bd69205fd~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vienna-basilisks','https://www.buhurtinternational.com/team/vienna-basilisks','Vienna Basilisks','Vienna','lukas.froehling@live.de','https://www.vgvk.at/',20,'{"biCollectionId":"2f460663-68e6-4edc-82af-b19f778f9514","teamName":"Vienna Basilisks","club":null,"gender":"Male","captain":"Amelie Öhlinger","conference":"Europe","country":"Austria","city":"Vienna","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.vgvk.at/","teamEmail":"lukas.froehling@live.de","teamLogo":"wix:image://v1/b7aaf8_a1f5a381a22742908fca719bd69205fd~mv2.png/Screenshot%202026-06-10%20231833.png#originWidth=744&originHeight=739","logoUrl":"https://static.wixstatic.com/media/b7aaf8_a1f5a381a22742908fca719bd69205fd~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Amelie Öhlinger","Danny Haraldson","Sebastian Pinter","Matthias Gorr","Julian Tielsch"],"sourceCreatedAt":"2026-06-10T21:26:11.098Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vienna Basilisks',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Vienna',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Austria',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lukas.froehling@live.de'),
 website_url=coalesce(t.website_url,'https://www.vgvk.at/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b7aaf8_a1f5a381a22742908fca719bd69205fd~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amelie Öhlinger','captain','bi_teams','https://www.buhurtinternational.com/team/vienna-basilisks','vienna-basilisks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danny Haraldson','fighter','bi_teams','https://www.buhurtinternational.com/team/vienna-basilisks','vienna-basilisks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Pinter','fighter','bi_teams','https://www.buhurtinternational.com/team/vienna-basilisks','vienna-basilisks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthias Gorr','fighter','bi_teams','https://www.buhurtinternational.com/team/vienna-basilisks','vienna-basilisks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Tielsch','fighter','bi_teams','https://www.buhurtinternational.com/team/vienna-basilisks','vienna-basilisks',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vk-salzburg-innagebirg' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vk-salzburg-innagebirg' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'VK Salzburg Innagebirg','Schwarzach im Pongau',true,'active','public','bi-vk-salzburg-innagebirg','EU','Europe','AT','Austria','dani.salzburg-innagebirg@gmx.at','https://www.danisans-taekwondo.at/','https://static.wixstatic.com/media/ade209_c82b2a7bd6094a49a8b151eadbdc81e5~mv2.jpg','Est. 2015 Armored Combat Austria 1vs1 only Based in Salzburg 🥇14 🥈22 🥉11 Contact via dani.salzburg-innagebirg@gmx.at 00436608006081')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vk-salzburg-innagebirg','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','VK Salzburg Innagebirg','Schwarzach im Pongau','dani.salzburg-innagebirg@gmx.at','https://www.danisans-taekwondo.at/',20,'{"biCollectionId":"d9be7b70-5cb4-43fc-99d8-bed62b11cc40","teamName":"VK Salzburg Innagebirg","club":"Vk Salzburg Innagebirg ","gender":"Male","captain":"Daniel Lechner","conference":"Europe","country":"Austria","city":"Schwarzach im Pongau","teamInfo":"Est. 2015 Armored Combat Austria 1vs1 only Based in Salzburg 🥇14 🥈22 🥉11 Contact via dani.salzburg-innagebirg@gmx.at 00436608006081","trainingInfo":"Est. 2015 Armored Combat Austria 1vs1 only Based in Salzburg 🥇14 🥈22 🥉11 Contact via dani.salzburg-innagebirg@gmx.at 00436608006081","trainingLocation":{"city":"Schwarzach im Pongau","location":{"latitude":47.29320569999999,"longitude":13.1455481},"streetAddress":{"apt":"","formattedAddressLine":"Schwarzach im Pongau","name":"","number":""},"formatted":"Schwarzach im Pongau, 5620, Austria","country":"AT","postalCode":"5620"},"websiteFacebookUrl":"https://www.danisans-taekwondo.at/","teamEmail":"dani.salzburg-innagebirg@gmx.at","teamLogo":"wix:image://v1/ade209_c82b2a7bd6094a49a8b151eadbdc81e5~mv2.jpg/LOGO%20NEU.jpg#originWidth=1080&originHeight=1801","logoUrl":"https://static.wixstatic.com/media/ade209_c82b2a7bd6094a49a8b151eadbdc81e5~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Daniel Lechner","Tobias Esser","Adrian Wanke","Markus Sommerer-Hinterbichler","Gian Schnee"],"sourceCreatedAt":"2023-09-10T08:16:44.241Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('VK Salzburg Innagebirg',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Schwarzach im Pongau',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Austria',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'dani.salzburg-innagebirg@gmx.at'),
 website_url=coalesce(t.website_url,'https://www.danisans-taekwondo.at/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ade209_c82b2a7bd6094a49a8b151eadbdc81e5~mv2.jpg'),
 public_description=coalesce(t.public_description,'Est. 2015 Armored Combat Austria 1vs1 only Based in Salzburg 🥇14 🥈22 🥉11 Contact via dani.salzburg-innagebirg@gmx.at 00436608006081'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Lechner','captain','bi_teams','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','vk-salzburg-innagebirg',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tobias Esser','fighter','bi_teams','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','vk-salzburg-innagebirg',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Wanke','fighter','bi_teams','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','vk-salzburg-innagebirg',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Markus Sommerer-Hinterbichler','fighter','bi_teams','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','vk-salzburg-innagebirg',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gian Schnee','fighter','bi_teams','https://www.buhurtinternational.com/team/vk-salzburg-innagebirg','vk-salzburg-innagebirg',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vmvk-alpenkrieger' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vmvk-alpenkrieger' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'VMVK Alpenkrieger','Bayerisch Gmain',true,'active','public','bi-vmvk-alpenkrieger','EU','Europe','DE','Germany','Zulualpha24@gmail.com','https://www.facebook.com/profile.php?id=100063596502003','https://static.wixstatic.com/media/0d931c_bceea7b33c42411a88a78ac8a2f869de~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vmvk-alpenkrieger','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','VMVK Alpenkrieger','Bayerisch Gmain','Zulualpha24@gmail.com','https://www.facebook.com/profile.php?id=100063596502003',20,'{"biCollectionId":"a8ab7ee4-42c8-45f3-aea0-d83c3fb35738","teamName":"VMVK Alpenkrieger","club":null,"gender":"Male","captain":"Christoph Wallner","conference":"Europe","country":"Germany","city":"Bayerisch Gmain","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100063596502003","teamEmail":"Zulualpha24@gmail.com","teamLogo":"wix:image://v1/0d931c_bceea7b33c42411a88a78ac8a2f869de~mv2.jpg/Logo_jpeg_weiss%20(4).jpg#originWidth=846&originHeight=973","logoUrl":"https://static.wixstatic.com/media/0d931c_bceea7b33c42411a88a78ac8a2f869de~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Christoph Wallner","Fleischmann Gerhard","Johannes Forstner","Paul Mühlthaler","Dominik Krenn","Michael Weitgasser","Florian Strele","Simon Härtinger","Alexander Franz","Michael Mraulak","Andrii Maslak","Dominic Moser","EUGENE RIABENKO"],"sourceCreatedAt":"2023-08-06T10:57:40.700Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('VMVK Alpenkrieger',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Bayerisch Gmain',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Zulualpha24@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100063596502003'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/0d931c_bceea7b33c42411a88a78ac8a2f869de~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christoph Wallner','captain','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fleischmann Gerhard','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johannes Forstner','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Mühlthaler','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Krenn','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Weitgasser','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Florian Strele','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Härtinger','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Franz','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Mraulak','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrii Maslak','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominic Moser','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'EUGENE RIABENKO','fighter','bi_teams','https://www.buhurtinternational.com/team/vmvk-alpenkrieger','vmvk-alpenkrieger',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wa-destriers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wa-destriers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'WA Destriers','Perth',true,'active','public','bi-wa-destriers','OC','Oceania','AU','Australia','berserkerswa@gmail.com',NULL,'https://static.wixstatic.com/media/32d034_b4a3ab1fc373445d8f775e5fc6643396~mv2.jpg','The first female team in Western Australia! Here we embrace everyone from all levels of experience and skill levels, and work on growing confidence and empowering those that enter the list!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wa-destriers','https://www.buhurtinternational.com/team/wa-destriers','WA Destriers','Perth','berserkerswa@gmail.com',NULL,20,'{"biCollectionId":"fa33a302-429d-471d-aca3-fb8e22e7b9ff","teamName":"WA Destriers","club":null,"gender":"Female","captain":"Sharni Evans","conference":"APAC","country":"Australia","city":"Perth","teamInfo":"The first female team in Western Australia! Here we embrace everyone from all levels of experience and skill levels, and work on growing confidence and empowering those that enter the list!","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"berserkerswa@gmail.com","teamLogo":"wix:image://v1/32d034_b4a3ab1fc373445d8f775e5fc6643396~mv2.jpg/Screenshot_20260203_204458_Instagram.jpg#originWidth=1079&originHeight=1302","logoUrl":"https://static.wixstatic.com/media/32d034_b4a3ab1fc373445d8f775e5fc6643396~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Sharni Evans"],"sourceCreatedAt":"2026-02-03T12:52:30.137Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('WA Destriers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Perth',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'berserkerswa@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/32d034_b4a3ab1fc373445d8f775e5fc6643396~mv2.jpg'),
 public_description=coalesce(t.public_description,'The first female team in Western Australia! Here we embrace everyone from all levels of experience and skill levels, and work on growing confidence and empowering those that enter the list!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sharni Evans','captain','bi_teams','https://www.buhurtinternational.com/team/wa-destriers','wa-destriers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='war-badgers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-war-badgers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'War Badgers','São Paulo',true,'active','public','bi-war-badgers','SA','South America','BR','Brazil','warbadgers@gmail.com','https://www.instagram.com/warbadgers_hmb?stkn=MXQ3ZW1nczVmNnp0','https://static.wixstatic.com/media/cee7a1_35e2270c14fd40dd872c51b73e1ae3a8~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','war-badgers','https://www.buhurtinternational.com/team/war-badgers','War Badgers','São Paulo','warbadgers@gmail.com','https://www.instagram.com/warbadgers_hmb?stkn=MXQ3ZW1nczVmNnp0',20,'{"biCollectionId":"c255ff48-d4f9-4a23-bb72-345b5fa20fa3","teamName":"War Badgers","club":null,"gender":"Male","captain":"Júnior Salgueiro","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/warbadgers_hmb?stkn=MXQ3ZW1nczVmNnp0","teamEmail":"warbadgers@gmail.com","teamLogo":"wix:image://v1/cee7a1_35e2270c14fd40dd872c51b73e1ae3a8~mv2.jpeg/WARBADGERS.jpeg#originWidth=640&originHeight=640","logoUrl":"https://static.wixstatic.com/media/cee7a1_35e2270c14fd40dd872c51b73e1ae3a8~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Júnior Salgueiro","Ernesto Brodella Sampaio","KASSYO FELIPE SOARES PANTOJA"],"sourceCreatedAt":"2026-09-17T19:07:52.223Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('War Badgers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'warbadgers@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/warbadgers_hmb?stkn=MXQ3ZW1nczVmNnp0'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cee7a1_35e2270c14fd40dd872c51b73e1ae3a8~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Júnior Salgueiro','captain','bi_teams','https://www.buhurtinternational.com/team/war-badgers','war-badgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ernesto Brodella Sampaio','fighter','bi_teams','https://www.buhurtinternational.com/team/war-badgers','war-badgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'KASSYO FELIPE SOARES PANTOJA','fighter','bi_teams','https://www.buhurtinternational.com/team/war-badgers','war-badgers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wardens' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wardens' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wardens','Colorado Springs ',true,'active','public','bi-wardens','NA','North America','US','United States','coloradoarmoredcombat@gmail.com','https://www.facebook.com/groups/thecoloradowardens','https://static.wixstatic.com/media/59ad73_f18d1fcb19114897b06b4b7305536a2d~mv2.jpeg','We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wardens','https://www.buhurtinternational.com/team/wardens','Wardens','Colorado Springs ','coloradoarmoredcombat@gmail.com','https://www.facebook.com/groups/thecoloradowardens',20,'{"biCollectionId":"157e64b4-8cca-401b-ba69-78b7ec3ad214","teamName":"Wardens","club":null,"gender":"Male","captain":"Ryan Schulman ","conference":"North America","country":"United States","city":"Colorado Springs ","teamInfo":"We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/thecoloradowardens","teamEmail":"coloradoarmoredcombat@gmail.com","teamLogo":"wix:image://v1/59ad73_f18d1fcb19114897b06b4b7305536a2d~mv2.jpeg/8430EDA4-C575-43A6-A0B2-999C9548CA7E.jpeg#originWidth=749&originHeight=898","logoUrl":"https://static.wixstatic.com/media/59ad73_f18d1fcb19114897b06b4b7305536a2d~mv2.jpeg","rank5v5":8,"averagePoints5v5":8.33,"points5v5":25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":7,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":3},{"_id":"2","points":8,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":3},{"_id":"3","points":10,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":2}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":24,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":2},{"_id":"2","points":3,"Tournament":"Colorado Classic 3 2025","date":"2025-06-07","category":"5vs5","place":3},{"_id":"3","points":5,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":3}],"points12v12":0,"averagePoints5v5":10.67,"rank5v5":4,"remainingTokens":10,"points5v5":32}},"members":["Emerson Moore","Ryan Schulman","Gregory Fisher","Jeff von Lexa","Paxton Lee Smith","Benjamin Splitter","Garret Skovgard","Nathaniel DeLaCruz","Donald Wesley Björnsson","Thomas Shepherd","Ryan Endicott","Andrew Solaire","Hunter Hutchins","Kade Graner"],"sourceCreatedAt":"2024-06-29T17:41:11.134Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wardens',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Colorado Springs ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'coloradoarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/thecoloradowardens'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/59ad73_f18d1fcb19114897b06b4b7305536a2d~mv2.jpeg'),
 public_description=coalesce(t.public_description,'We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emerson Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Schulman','captain','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Fisher','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeff von Lexa','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paxton Lee Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Splitter','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Garret Skovgard','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathaniel DeLaCruz','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Donald Wesley Björnsson','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Shepherd','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Endicott','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Solaire','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hunter Hutchins','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kade Graner','fighter','bi_teams','https://www.buhurtinternational.com/team/wardens','wardens',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wards' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wards' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wards','Colorado Springs, CO',true,'active','public','bi-wards','NA','North America','US','United States','ColoradoWards@swiftluna.com',NULL,'https://static.wixstatic.com/media/47823a_434c505517ba47a081b8659e0c112b43~mv2.png','We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wards','https://www.buhurtinternational.com/team/wards','Wards','Colorado Springs, CO','ColoradoWards@swiftluna.com',NULL,20,'{"biCollectionId":"bbfa7c82-56a3-431d-a0e6-86ce01cdf52e","teamName":"Wards","club":null,"gender":"Male","captain":"Dan Shepherd","conference":"North America","country":"United States","city":"Colorado Springs, CO","teamInfo":"We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"ColoradoWards@swiftluna.com","teamLogo":"wix:image://v1/47823a_434c505517ba47a081b8659e0c112b43~mv2.png/att.rsR-7suTunFaZLzwQsnAuCLny9yZ3P3so13j2VbKF-s.png#originWidth=1707&originHeight=1707","logoUrl":"https://static.wixstatic.com/media/47823a_434c505517ba47a081b8659e0c112b43~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":7},{"_id":"2","points":0,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":6}],"eventsHistory":{},"members":["Dan Shepherd","Tyler Truster Boothe","Scottie Carder","Dan Bourque","Carl Cherne","Ronny Glenn Summerlin","Patrick Mullen","Spencer Ghattas","Dylan Tatum"],"sourceCreatedAt":"2026-02-23T00:33:16.048Z","sourceUpdatedAt":"2026-09-29T14:04:01.370Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wards',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Colorado Springs, CO',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ColoradoWards@swiftluna.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/47823a_434c505517ba47a081b8659e0c112b43~mv2.png'),
 public_description=coalesce(t.public_description,'We represent Southern Wyoming and all of Colorado including, Fort Collins, Denver and Colorado Springs.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dan Shepherd','captain','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Truster Boothe','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scottie Carder','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dan Bourque','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carl Cherne','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ronny Glenn Summerlin','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patrick Mullen','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Spencer Ghattas','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Tatum','fighter','bi_teams','https://www.buhurtinternational.com/team/wards','wards',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='warhounds-armoured-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-warhounds-armoured-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Warhounds Armoured Combat','Adelaide',true,'active','public','bi-warhounds-armoured-combat','OC','Oceania','AU','Australia','warhoundsac@gmail.com','https://www.facebook.com/WarhoundsAC','https://static.wixstatic.com/media/c0c816_2b1b8f958cad4a789e42aa8a7f7d9811~mv2.png','Across the globe, men and women are gearing up in full armour, wielding swords, maces, axes and polearms to take part in the worlds most exciting sport, Armoured Combat! Here in Australia, Warhounds AC are training hard and getting ready to take the fight to other teams interstate and worldwide in full contact medieval combat! Do you have what it takes to join us?')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','warhounds-armoured-combat','https://www.buhurtinternational.com/team/warhounds-armoured-combat','Warhounds Armoured Combat','Adelaide','warhoundsac@gmail.com','https://www.facebook.com/WarhoundsAC',20,'{"biCollectionId":"c25724df-1761-4043-98fc-d890e9e67b23","teamName":"Warhounds Armoured Combat","club":null,"gender":"Male","captain":"Joshua Langtree","conference":"APAC","country":"Australia","city":"Adelaide","teamInfo":"Across the globe, men and women are gearing up in full armour, wielding swords, maces, axes and polearms to take part in the worlds most exciting sport, Armoured Combat! Here in Australia, Warhounds AC are training hard and getting ready to take the fight to other teams interstate and worldwide in full contact medieval combat! Do you have what it takes to join us?","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"SA","name":"South Australia","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Port Adelaide Enfield","name":"City of Port Adelaide Enfield","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Wingfield","name":"Wingfield","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Wingfield","location":{"latitude":-34.8481991,"longitude":138.5569145},"streetAddress":{"apt":"","formattedAddressLine":"19 Penley Ave","name":"Penley Avenue","number":"19"},"formatted":"19 Penley Ave, Wingfield SA 5013, Australia","country":"AU","postalCode":"5013","subdivision":"SA"},"websiteFacebookUrl":"https://www.facebook.com/WarhoundsAC","teamEmail":"warhoundsac@gmail.com","teamLogo":"wix:image://v1/c0c816_2b1b8f958cad4a789e42aa8a7f7d9811~mv2.png/IMG_0595.PNG#originWidth=2439&originHeight=2063","logoUrl":"https://static.wixstatic.com/media/c0c816_2b1b8f958cad4a789e42aa8a7f7d9811~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"SA Buhurt Cup (Adelaide Medieval Fair) 2026","date":"2026-04-04","category":"5vs5","place":4},{"_id":"2","points":0,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":7}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"Barossa - SA Cup 2024","date":"2024-08-17","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":19.5,"remainingTokens":9,"tournaments":[{"_id":"1","points":19.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":2}]}},"members":["Alexander Joshua Webster (Sassy)","Liam Moore","Jarrod Salter","Rory Ellis","Zane Sweeney-Stokes","Justin zollo","Josh \"Shanty\" Shenton","Joshua Langtree","Joe Pratt","Jacob Jenkins","James Knight"],"sourceCreatedAt":"2024-07-28T02:00:12.422Z","sourceUpdatedAt":"2026-09-27T12:57:01.673Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Warhounds Armoured Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Adelaide',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'warhoundsac@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WarhoundsAC'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c0c816_2b1b8f958cad4a789e42aa8a7f7d9811~mv2.png'),
 public_description=coalesce(t.public_description,'Across the globe, men and women are gearing up in full armour, wielding swords, maces, axes and polearms to take part in the worlds most exciting sport, Armoured Combat! Here in Australia, Warhounds AC are training hard and getting ready to take the fight to other teams interstate and worldwide in full contact medieval combat! Do you have what it takes to join us?'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Joshua Webster (Sassy)','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jarrod Salter','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rory Ellis','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zane Sweeney-Stokes','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin zollo','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh "Shanty" Shenton','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Langtree','captain','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joe Pratt','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Jenkins','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Knight','fighter','bi_teams','https://www.buhurtinternational.com/team/warhounds-armoured-combat','warhounds-armoured-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='warlords' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-warlords' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dragoons','Dallas, Texas',true,'active','public','bi-warlords','NA','North America','US','United States','Vincentverheyden@gmail.com',NULL,'https://static.wixstatic.com/media/9252c9_d8e7be39770f4ef69af437c68bf1649c~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','warlords','https://www.buhurtinternational.com/team/warlords','Dragoons','Dallas, Texas','Vincentverheyden@gmail.com',NULL,20,'{"biCollectionId":"581a29e5-f725-4719-97c7-ba1193f8e511","teamName":"Dragoons","club":null,"gender":"Male","captain":"Vincent Verheyden","conference":"North America","country":"United States","city":"Dallas, Texas","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"Vincentverheyden@gmail.com","teamLogo":"wix:image://v1/9252c9_d8e7be39770f4ef69af437c68bf1649c~mv2.jpeg/Messenger_creation_E02203E0-E62C-4E5F-8DED-C32800C0AC9C.jpeg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/9252c9_d8e7be39770f4ef69af437c68bf1649c~mv2.jpeg","rank5v5":2,"averagePoints5v5":14.08,"points5v5":42.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":18,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":2},{"_id":"2","points":11.25,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":3},{"_id":"3","points":13,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":26,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":1},{"_id":"2","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":9},{"_id":"3","points":24,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":1},{"_id":"4","points":28,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":1},{"_id":"5","points":5,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":12,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":3},{"_id":"2","points":12,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":2},{"_id":"3","points":13,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2025","date":"2025-06-28","category":"5vs5","place":2},{"_id":"4","points":3,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":4},{"_id":"5","points":14,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":1}],"points12v12":15,"averagePoints5v5":13,"rank5v5":2,"remainingTokens":8,"points5v5":39}},"members":["Vincent Verheyden","Brett Skinner","Sean Hanson","Michael Johnson","Adam Harrigan","Austin ponticelli","Charlie Brumfield","Bhwoah Jue Scarlett","ETHAN ASHER FORBES","Dondre Cyrus","Thomas Cromer","Grant Colby"],"sourceCreatedAt":"2024-02-27T17:22:57.788Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dragoons',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dallas, Texas',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Vincentverheyden@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9252c9_d8e7be39770f4ef69af437c68bf1649c~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Verheyden','captain','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brett Skinner','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Hanson','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Harrigan','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Austin ponticelli','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charlie Brumfield','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bhwoah Jue Scarlett','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'ETHAN ASHER FORBES','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dondre Cyrus','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Cromer','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Grant Colby','fighter','bi_teams','https://www.buhurtinternational.com/team/warlords','warlords',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='warmińska-dzika-kompania' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-warmińska-dzika-kompania' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Warmińska Dzika Kompania','Olsztyn',true,'active','public','bi-warmińska-dzika-kompania','EU','Europe','PL','Poland','warminskadzikakompania@gmail.com','https://www.facebook.com/WDKOlsztyn','https://static.wixstatic.com/media/dbd025_64f2a65b156c49fdb76eabae8e70c57c~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','warmińska-dzika-kompania','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','Warmińska Dzika Kompania','Olsztyn','warminskadzikakompania@gmail.com','https://www.facebook.com/WDKOlsztyn',20,'{"biCollectionId":"a8c121c2-f7d2-4b8d-bb00-08cf48b7a6fb","teamName":"Warmińska Dzika Kompania","club":null,"gender":"Male","captain":"Przemysław Wachowiak","conference":"Europe","country":"Poland","city":"Olsztyn","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/WDKOlsztyn","teamEmail":"warminskadzikakompania@gmail.com","teamLogo":"wix:image://v1/dbd025_64f2a65b156c49fdb76eabae8e70c57c~mv2.jpg/460429765_1868734710282430_2864468802305805294_n.jpg#originWidth=828&originHeight=529","logoUrl":"https://static.wixstatic.com/media/dbd025_64f2a65b156c49fdb76eabae8e70c57c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Przemysław Wachowiak","Krzysztof Pakalski","Adrian Witkowski","Rafał Wolfigiel","Wiktor Balec","Pawel Luks","Piotr Mikolajczyk","Jendrik Heintorf"],"sourceCreatedAt":"2025-07-14T20:06:18.487Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Warmińska Dzika Kompania',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Olsztyn',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'warminskadzikakompania@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WDKOlsztyn'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/dbd025_64f2a65b156c49fdb76eabae8e70c57c~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Przemysław Wachowiak','captain','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Krzysztof Pakalski','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Witkowski','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafał Wolfigiel','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wiktor Balec','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pawel Luks','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Piotr Mikolajczyk','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jendrik Heintorf','fighter','bi_teams','https://www.buhurtinternational.com/team/warmi%C5%84ska-dzika-kompania','warmińska-dzika-kompania',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='warpigs' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-warpigs' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Warpigs','Sacramento ',true,'active','public','bi-warpigs','NA','North America','US','United States','Sacramentosiegewarpigs@gmail.com','www.facebook.com/SACSIEGE?mibextid=LQQJ4d','https://static.wixstatic.com/media/753946_d96699158ca4454093a8da0273061b2d~mv2.jpeg','Sacramento CA based Buhurt team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','warpigs','https://www.buhurtinternational.com/team/warpigs','Warpigs','Sacramento ','Sacramentosiegewarpigs@gmail.com','www.facebook.com/SACSIEGE?mibextid=LQQJ4d',20,'{"biCollectionId":"653b59ad-efd0-4645-ad25-011e9dedb8b9","teamName":"Warpigs","club":"Warpigs ","gender":"Male","captain":"Santos Sanchez","conference":"North America","country":"United States","city":"Sacramento ","teamInfo":"Sacramento CA based Buhurt team","trainingInfo":"Bring work out attire, water, groin protection and good attitude ready to work.","trainingLocation":null,"websiteFacebookUrl":"www.facebook.com/SACSIEGE?mibextid=LQQJ4d","teamEmail":"Sacramentosiegewarpigs@gmail.com","teamLogo":"wix:image://v1/753946_d96699158ca4454093a8da0273061b2d~mv2.jpeg/IMG_4444.jpeg#originWidth=782&originHeight=782","logoUrl":"https://static.wixstatic.com/media/753946_d96699158ca4454093a8da0273061b2d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":7},{"_id":"2","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":4},{"_id":"3","points":9,"Tournament":"Ventura Melee Megabowl 2024","date":"14-04-2024","category":"5vs5","place":2},{"_id":"4","points":9,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":4},{"_id":"5","points":12,"Tournament":"Pacific Cup 2024","date":"2024-06-14","category":"5vs5","place":3},{"_id":"6","points":9,"Tournament":"Rise of an Empire 2024","date":"2024-08-30","category":"5vs5","place":1},{"_id":"7","points":10,"Tournament":"California Classic 2024","date":"2024-09-21","category":"5vs5","place":2},{"_id":"8","points":0,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":6}]},"2025":{"remainingTokens":10}},"members":["Forrest Yeh","Shaun Magallanes","Roy Chavez","Logan Ballanger","Santos Sanchez","Christopher \"Xar\" Sanchez","Ronin Sato","Joseph Roland Cadieux"],"sourceCreatedAt":"2023-06-27T03:21:18.796Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Warpigs',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sacramento ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Sacramentosiegewarpigs@gmail.com'),
 website_url=coalesce(t.website_url,'www.facebook.com/SACSIEGE?mibextid=LQQJ4d'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/753946_d96699158ca4454093a8da0273061b2d~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Sacramento CA based Buhurt team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Forrest Yeh','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shaun Magallanes','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roy Chavez','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Ballanger','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Santos Sanchez','captain','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher "Xar" Sanchez','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ronin Sato','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Roland Cadieux','fighter','bi_teams','https://www.buhurtinternational.com/team/warpigs','warpigs',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='warwolves' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-warwolves' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Warwolves','Ballarat/Adelaide',true,'active','public','bi-warwolves','OC','Oceania','AU','Australia','thewesternwolves@gmail.com','https://www.facebook.com/westernwolvesballarat','https://static.wixstatic.com/media/106935_b595a0c5a10c486aa7b3e218c9684a46~mv2.png','We are HUNGRY. Our team is made from the competitive-minded fighters from our two mother teams, Warhounds AC in Adelaide, South Australia, and the Western Wolves - Ballarat Medieval Combat, in Ballarat, Victoria. Our clubs share a combined vision and work together to refine our training methods and processes. We will be the best, and we&#x27;ll get there together.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','warwolves','https://www.buhurtinternational.com/team/warwolves','Warwolves','Ballarat/Adelaide','thewesternwolves@gmail.com','https://www.facebook.com/westernwolvesballarat',20,'{"biCollectionId":"11e59409-f078-4968-ab07-cb392cf9ade5","teamName":"Warwolves","club":"Ballarat Medieval Combat","gender":"Male","captain":"Daniel Cooper","conference":"APAC","country":"Australia","city":"Ballarat/Adelaide","teamInfo":"We are HUNGRY. Our team is made from the competitive-minded fighters from our two mother teams, Warhounds AC in Adelaide, South Australia, and the Western Wolves - Ballarat Medieval Combat, in Ballarat, Victoria. Our clubs share a combined vision and work together to refine our training methods and processes. We will be the best, and we&#x27;ll get there together.","trainingInfo":"Both of our gyms are very open to new members! We also have our 2 local-level teams so you can get into the fighting for a fun time without necessarily making buhurt your entire life. As much as we would love that, we know it&#x27;s not everyone&#x27;s gig. On facebook message our pages to get in touch with us at our locations! Ballarat: https://www.facebook.com/westernwolvesballarat Adelaide: https://www.facebook.com/WarhoundsAC","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/westernwolvesballarat","teamEmail":"thewesternwolves@gmail.com","teamLogo":"wix:image://v1/106935_b595a0c5a10c486aa7b3e218c9684a46~mv2.png/Warwolves%20v1.PNG#originWidth=2876&originHeight=3520","logoUrl":"https://static.wixstatic.com/media/106935_b595a0c5a10c486aa7b3e218c9684a46~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":13.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4.5,"Tournament":"SA Buhurt Cup (Adelaide Medieval Fair) 2026","date":"2026-04-04","category":"5vs5","place":1},{"_id":"2","points":9,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"Winterfest 2024","date":"2024-07-06","category":"5vs5","place":4},{"_id":"2","points":13,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":1},{"_id":"3","points":6,"Tournament":"Barossa - SA Cup 2024","date":"2024-08-17","category":"5vs5","place":1},{"_id":"4","points":4.5,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":5}]},"2025":{"points12v12":0,"points5v5":7.5,"remainingTokens":8,"tournaments":[{"_id":"1","points":7.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":3}]}},"members":["Daniel Cooper","Cody Hunt","Chad Huxtable","Samuel Missen","Jarrod Salter","Codi Crenshaw","Jack \"Ming\" Shaw","Dylan \"Dinky\" Di","Noah Richmond","Tynan Crawford","Jordan Bloffwitch","Rik Murtagh","Max Cleghorn","Christopher Attwood-Mitchell","Connor Buteux"],"sourceCreatedAt":"2023-09-05T13:51:35.941Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Warwolves',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ballarat/Adelaide',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'thewesternwolves@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/westernwolvesballarat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/106935_b595a0c5a10c486aa7b3e218c9684a46~mv2.png'),
 public_description=coalesce(t.public_description,'We are HUNGRY. Our team is made from the competitive-minded fighters from our two mother teams, Warhounds AC in Adelaide, South Australia, and the Western Wolves - Ballarat Medieval Combat, in Ballarat, Victoria. Our clubs share a combined vision and work together to refine our training methods and processes. We will be the best, and we&#x27;ll get there together.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Cooper','captain','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cody Hunt','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chad Huxtable','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Missen','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jarrod Salter','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Codi Crenshaw','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack "Ming" Shaw','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan "Dinky" Di','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noah Richmond','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tynan Crawford','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Bloffwitch','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rik Murtagh','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Max Cleghorn','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Attwood-Mitchell','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Connor Buteux','fighter','bi_teams','https://www.buhurtinternational.com/team/warwolves','warwolves',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wendigo-nb2' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wendigo-nb2' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wendigo NB2',NULL,true,'active','public','bi-wendigo-nb2','NA','North America','CA','Canada','northbloodcanada@gmail.com',NULL,'https://static.wixstatic.com/media/c8bfeb_31d057dbffa148e7a56d8172eaaa998d~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wendigo-nb2','https://www.buhurtinternational.com/team/wendigo-nb2','Wendigo NB2',NULL,'northbloodcanada@gmail.com',NULL,20,'{"biCollectionId":"2a438b0a-0c8e-42c6-9e09-86672f33291e","teamName":"Wendigo NB2","club":null,"gender":"Male","captain":"Land Pearson","conference":"North America","country":"Canada","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"northbloodcanada@gmail.com","teamLogo":"wix:image://v1/c8bfeb_31d057dbffa148e7a56d8172eaaa998d~mv2.jpeg/IMG_1248.jpeg#originWidth=806&originHeight=1090","logoUrl":"https://static.wixstatic.com/media/c8bfeb_31d057dbffa148e7a56d8172eaaa998d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":4,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":11}]}},"members":["Land Pearson","Land North Pearson","Evan Corrigan","Michael Grenon","Jean-Christophe St-Amand","Jean-Luc Savard"],"sourceCreatedAt":"2024-07-13T14:18:02.221Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wendigo NB2',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'northbloodcanada@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c8bfeb_31d057dbffa148e7a56d8172eaaa998d~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Land Pearson','captain','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Land North Pearson','fighter','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan Corrigan','fighter','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Grenon','fighter','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean-Christophe St-Amand','fighter','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean-Luc Savard','fighter','bi_teams','https://www.buhurtinternational.com/team/wendigo-nb2','wendigo-nb2',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='west-australian-berserkers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-west-australian-berserkers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'West Australian Berserkers','Perth',true,'active','public','bi-west-australian-berserkers','OC','Oceania','AU','Australia','berserkerswa@gmail.com','https://www.facebook.com/WABerserkers','https://static.wixstatic.com/media/00e8ce_6dd56ed0d7d6450691c9bf1b1a96d3a5~mv2.png','The ‘West Australian Berserkers’ are a armoured combat team whose sole purpose is to provide capable, dedicated, well equipped fighters, male and female, for the national team of Australia to compete at Tournaments such as the IMCF and the HMBIA world championship, ‘Battle of the Nations’, from Western Australia. Led by experienced fighters, who need to have participated in the BOTN in order to be part of the council, fighters are initiated, trained, supported and guided, in order to prepare them for potential selection for the national team, Understanding that there is no guarantee of selection, and that the personal abilities, equipment level, and ability to attend the international events of the aspirant are the only deciding factor. Even veterans have no right to be on the national team, and must try out as decided by the national team guidelines The Berserkers are proud members and supporters of the Australian Medieval Combat federation')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','west-australian-berserkers','https://www.buhurtinternational.com/team/west-australian-berserkers','West Australian Berserkers','Perth','berserkerswa@gmail.com','https://www.facebook.com/WABerserkers',20,'{"biCollectionId":"c3053a26-fd0d-4ea6-95e5-1e6a853e89b5","teamName":"West Australian Berserkers","club":"Berserkers","gender":"Male","captain":"James payne","conference":"APAC","country":"Australia","city":"Perth","teamInfo":"The ‘West Australian Berserkers’ are a armoured combat team whose sole purpose is to provide capable, dedicated, well equipped fighters, male and female, for the national team of Australia to compete at Tournaments such as the IMCF and the HMBIA world championship, ‘Battle of the Nations’, from Western Australia. Led by experienced fighters, who need to have participated in the BOTN in order to be part of the council, fighters are initiated, trained, supported and guided, in order to prepare them for potential selection for the national team, Understanding that there is no guarantee of selection, and that the personal abilities, equipment level, and ability to attend the international events of the aspirant are the only deciding factor. Even veterans have no right to be on the national team, and must try out as decided by the national team guidelines The Berserkers are proud members and supporters of the Australian Medieval Combat federation","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/WABerserkers","teamEmail":"berserkerswa@gmail.com","teamLogo":"wix:image://v1/00e8ce_6dd56ed0d7d6450691c9bf1b1a96d3a5~mv2.png/berserkers%20bear.png#originWidth=258&originHeight=258","logoUrl":"https://static.wixstatic.com/media/00e8ce_6dd56ed0d7d6450691c9bf1b1a96d3a5~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":8},{"_id":"2","points":3,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"5vs5","place":4},{"_id":"3","points":7.5,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":7}]},"2025":{"points12v12":0,"points5v5":16.5,"remainingTokens":9,"tournaments":[{"_id":"1","points":16.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":3}]}},"members":["James Payne","Peter Breese","Scott Hunter","Dyllan Shaw","Timothy luke Zaborskis","Jordan Davis","William James Howell","Jacob Kestel"],"sourceCreatedAt":"2023-08-28T08:58:00.922Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('West Australian Berserkers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Perth',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'berserkerswa@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WABerserkers'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/00e8ce_6dd56ed0d7d6450691c9bf1b1a96d3a5~mv2.png'),
 public_description=coalesce(t.public_description,'The ‘West Australian Berserkers’ are a armoured combat team whose sole purpose is to provide capable, dedicated, well equipped fighters, male and female, for the national team of Australia to compete at Tournaments such as the IMCF and the HMBIA world championship, ‘Battle of the Nations’, from Western Australia. Led by experienced fighters, who need to have participated in the BOTN in order to be part of the council, fighters are initiated, trained, supported and guided, in order to prepare them for potential selection for the national team, Understanding that there is no guarantee of selection, and that the personal abilities, equipment level, and ability to attend the international events of the aspirant are the only deciding factor. Even veterans have no right to be on the national team, and must try out as decided by the national team guidelines The Berserkers are proud members and supporters of the Australian Medieval Combat federation'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Payne','captain','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Peter Breese','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott Hunter','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dyllan Shaw','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy luke Zaborskis','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William James Howell','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Kestel','fighter','bi_teams','https://www.buhurtinternational.com/team/west-australian-berserkers','west-australian-berserkers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='western-wolves' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-western-wolves' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Western Wolves','Ballarat',true,'active','public','bi-western-wolves','OC','Oceania','AU','Australia','thewesternwolves@gmail.com','https://thewesternwolves.com','https://static.wixstatic.com/media/cb8212_7d9944f8b6594619ac9042bb2909711a~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','western-wolves','https://www.buhurtinternational.com/team/western-wolves','Western Wolves','Ballarat','thewesternwolves@gmail.com','https://thewesternwolves.com',20,'{"biCollectionId":"03b38aa2-ede6-4065-8b3e-59a39b658bde","teamName":"Western Wolves","club":null,"gender":"Male","captain":"Codi Crenshaw","conference":"APAC","country":"Australia","city":"Ballarat","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://thewesternwolves.com","teamEmail":"thewesternwolves@gmail.com","teamLogo":"wix:image://v1/cb8212_7d9944f8b6594619ac9042bb2909711a~mv2.jpeg/IMG_3577.jpeg#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/cb8212_7d9944f8b6594619ac9042bb2909711a~mv2.jpeg","rank5v5":4,"averagePoints5v5":5,"points5v5":18,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"SA Buhurt Cup (Adelaide Medieval Fair) 2026","date":"2026-04-04","category":"5vs5","place":2},{"_id":"2","points":7,"Tournament":"Axefest 3 (Melbourne Renfair tournament) 2026","date":"2026-05-16","category":"5vs5","place":2},{"_id":"3","points":3,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":4},{"_id":"4","points":5,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":18,"remainingTokens":10,"tournaments":[{"_id":"1","points":18,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":2},{"_id":"2","points":0,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":13}]}},"members":["Codi Crenshaw","Samuel Morris","Connor Birch","Alistair Kent","Christopher Fogwill","Zachary Fitzpatrick","Simon Keefe","Thomas Byrne","Nicholas Patrick O''Meara","Christopher Biagi"],"sourceCreatedAt":"2024-07-12T10:06:22.802Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Western Wolves',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ballarat',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'thewesternwolves@gmail.com'),
 website_url=coalesce(t.website_url,'https://thewesternwolves.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cb8212_7d9944f8b6594619ac9042bb2909711a~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Codi Crenshaw','captain','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Morris','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Connor Birch','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alistair Kent','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Fogwill','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Fitzpatrick','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Keefe','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Byrne','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Patrick O''Meara','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Biagi','fighter','bi_teams','https://www.buhurtinternational.com/team/western-wolves','western-wolves',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='white-company-(m)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-white-company-(m)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'White Company (m)','Nottingham',true,'active','public','bi-white-company-(m)','EU','Europe','GB','United Kingdom','Whitecompanymedieval@gmail.com','https://www.facebook.com/WhiteCompanyMedieval','https://static.wixstatic.com/media/f9d650_6479781bc960490995de95a45b3e7f20~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','white-company-(m)','https://www.buhurtinternational.com/team/white-company-(m)','White Company (m)','Nottingham','Whitecompanymedieval@gmail.com','https://www.facebook.com/WhiteCompanyMedieval',20,'{"biCollectionId":"1c27dc82-d3c9-497b-8f74-306738e9ff91","teamName":"White Company (m)","club":null,"gender":"Male","captain":"Daniel Winter","conference":"Europe","country":"United Kingdom","city":"Nottingham","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"Phoenix Mills, Nottingham Rd, Long Eaton, Nottingham NG10 2AA, UK"},"websiteFacebookUrl":"https://www.facebook.com/WhiteCompanyMedieval","teamEmail":"Whitecompanymedieval@gmail.com","teamLogo":"wix:image://v1/f9d650_6479781bc960490995de95a45b3e7f20~mv2.jpg/THEWHITEBADGE%20%5BConverted%5D.jpg#originWidth=600&originHeight=581","logoUrl":"https://static.wixstatic.com/media/f9d650_6479781bc960490995de95a45b3e7f20~mv2.jpg","rank5v5":1,"averagePoints5v5":14.42,"points5v5":63.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":16,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":1},{"_id":"2","points":16.25,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":1},{"_id":"3","points":11,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":2},{"_id":"4","points":10,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":1},{"_id":"5","points":10,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":13,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":1},{"_id":"2","points":8,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"12vs12","place":1},{"_id":"3","points":15,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":1},{"_id":"4","points":15,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":1},{"_id":"5","points":8,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"12vs12","place":1},{"_id":"6","points":34,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":1},{"_id":"7","points":16,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":1},{"_id":"8","points":15,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":1},{"_id":"9","points":16.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":16,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":1},{"_id":"2","points":9,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"12vs12","place":1},{"_id":"3","points":8,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"12vs12","place":1},{"_id":"4","points":16,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":1},{"_id":"5","points":13,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":1},{"_id":"6","points":9,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":3},{"_id":"7","points":13,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":1}],"points12v12":17,"averagePoints5v5":15,"rank5v5":1,"remainingTokens":10,"points5v5":67}},"members":["Oliver Faulkner","James Raymer","Cai Robinson","Matthew Dods","Oleh Boikov","Christopher Burton","Domonic Mehew","Thomas Pithie","Luke Williams","Daniel Winter","Joe Partridge","Martin Gill","Nikki barnes","Jake Bennett","Sean Gough","Emil Guz"],"sourceCreatedAt":"2023-09-02T23:10:59.424Z","sourceUpdatedAt":"2026-09-28T13:48:34.170Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('White Company (m)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nottingham',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Whitecompanymedieval@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WhiteCompanyMedieval'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f9d650_6479781bc960490995de95a45b3e7f20~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oliver Faulkner','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Raymer','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cai Robinson','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Dods','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oleh Boikov','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Burton','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Domonic Mehew','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Pithie','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Williams','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Winter','captain','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joe Partridge','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Gill','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nikki barnes','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Bennett','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Gough','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emil Guz','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(m)','white-company-(m)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='white-company-(w)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-white-company-(w)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'White Company (w)','Nottingham',true,'active','public','bi-white-company-(w)','EU','Europe','GB','United Kingdom','jenny@thinky.de','https://www.facebook.com/WhiteCompanyMedieval','https://static.wixstatic.com/media/9a5937_a11a820d175e481293b59162997dbc51~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','white-company-(w)','https://www.buhurtinternational.com/team/white-company-(w)','White Company (w)','Nottingham','jenny@thinky.de','https://www.facebook.com/WhiteCompanyMedieval',20,'{"biCollectionId":"589b157c-57f2-44ec-9628-a10828de1543","teamName":"White Company (w)","club":null,"gender":"Female","captain":"Jenny Häbry","conference":"Europe","country":"United Kingdom","city":"Nottingham","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"England","name":"England","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Nottingham","name":"Nottingham","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Nottingham","name":"Nottingham","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"GB","name":"United Kingdom","type":"COUNTRY"}],"city":"Nottingham","location":{"latitude":52.9540223,"longitude":-1.1549892},"streetAddress":{"apt":"","formattedAddressLine":"Nottingham","name":"","number":""},"formatted":"Nottingham, UK","country":"GB"},"websiteFacebookUrl":"https://www.facebook.com/WhiteCompanyMedieval","teamEmail":"jenny@thinky.de","teamLogo":"wix:image://v1/9a5937_a11a820d175e481293b59162997dbc51~mv2.png/White%20company%20logo.png#originWidth=590&originHeight=590","logoUrl":"https://static.wixstatic.com/media/9a5937_a11a820d175e481293b59162997dbc51~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":8.75,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":8.75,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":1},{"_id":"2","points":5,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":2},{"_id":"3","points":6,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"12vs12","place":2},{"_id":"4","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3},{"_id":"5","points":2,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":5,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":2},{"_id":"2","points":7,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":1},{"_id":"3","points":8,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":6.67,"rank5v5":1,"remainingTokens":10,"points5v5":20}},"members":["Abigail Tobin","Alice Langton","Celia Rocton","Jenny Häbry","Rebecca Worsley","Ailish Gray","Ira Bolshakova","Rachael Stansby","Paris La Bouchardiere","Stephanie Shepherd"],"sourceCreatedAt":"2024-01-20T15:33:58.899Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('White Company (w)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nottingham',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jenny@thinky.de'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WhiteCompanyMedieval'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9a5937_a11a820d175e481293b59162997dbc51~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Abigail Tobin','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alice Langton','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Celia Rocton','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jenny Häbry','captain','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebecca Worsley','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ailish Gray','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ira Bolshakova','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachael Stansby','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paris La Bouchardiere','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephanie Shepherd','fighter','bi_teams','https://www.buhurtinternational.com/team/white-company-(w)','white-company-(w)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wichita-bison' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wichita-bison' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wichita Bison','Wichita',true,'active','public','bi-wichita-bison','NA','North America','US','United States','twvlamis@gmail.com','https://www.facebook.com/Wichitabison','https://static.wixstatic.com/media/ed39be_27486680b1df4a5880ef3e113434ea87~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wichita-bison','https://www.buhurtinternational.com/team/wichita-bison','Wichita Bison','Wichita','twvlamis@gmail.com','https://www.facebook.com/Wichitabison',20,'{"biCollectionId":"755513c9-69b7-4223-91a6-564db206fd88","teamName":"Wichita Bison","club":null,"gender":"Male","captain":"Ted Vlamis","conference":"North America","country":"United States","city":"Wichita","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/Wichitabison","teamEmail":"twvlamis@gmail.com","teamLogo":"wix:image://v1/ed39be_27486680b1df4a5880ef3e113434ea87~mv2.jpg/Bison%20logo.jpg#originWidth=550&originHeight=554","logoUrl":"https://static.wixstatic.com/media/ed39be_27486680b1df4a5880ef3e113434ea87~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":5}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2025","date":"2025-06-28","category":"5vs5","place":5}]}},"members":["Ted Vlamis","Gage Stolzenburg","Michael Carrigan","Tyler Joel Sisseck","Theodore Whitt","Paris Robertson","Tyler Boor","Brennan Staggers"],"sourceCreatedAt":"2025-06-05T22:31:23.407Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wichita Bison',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wichita',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'twvlamis@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/Wichitabison'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ed39be_27486680b1df4a5880ef3e113434ea87~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ted Vlamis','captain','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gage Stolzenburg','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Carrigan','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Joel Sisseck','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Theodore Whitt','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paris Robertson','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Boor','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brennan Staggers','fighter','bi_teams','https://www.buhurtinternational.com/team/wichita-bison','wichita-bison',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wild-wyverns' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wild-wyverns' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wild Wyverns (f)','Brisbane',true,'active','public','bi-wild-wyverns','OC','Oceania','AU','Australia','info@wildwyverns.com.au','http://wildwyverns.com.au','https://static.wixstatic.com/media/0a255f_2b078a9e22574781b4afbf9924bf9c5c~mv2.png','Fierce, fearless, and forged in steel — the Wild Wyverns femmes bring unmatched strength, unity, and heart to the buhurt field.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wild-wyverns','https://www.buhurtinternational.com/team/wild-wyverns','Wild Wyverns (f)','Brisbane','info@wildwyverns.com.au','http://wildwyverns.com.au',20,'{"biCollectionId":"e258dcde-0110-46e0-b891-d4b4141119fb","teamName":"Wild Wyverns (f)","club":null,"gender":"Female","captain":"Gabby Kennett","conference":"APAC","country":"Australia","city":"Brisbane","teamInfo":"Fierce, fearless, and forged in steel — the Wild Wyverns femmes bring unmatched strength, unity, and heart to the buhurt field.","trainingInfo":"Welcome! The Wild Wyverns femmes team is open to women and gender-diverse individuals aged 18+ who are ready to challenge themselves in the intense, full-contact sport of medieval armoured combat. No experience is needed — we’ll teach you everything from the ground up. We focus on building strength, confidence, and teamwork in a supportive and empowering environment. Whether you&#x27;re here to compete or just want to try something bold and different, you’ll be training with a crew that’s got your back!","trainingLocation":{"subdivisions":[{"code":"QLD","name":"Queensland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Logan","name":"Logan City","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Springwood","name":"Springwood","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Springwood","location":{"latitude":-27.6250439,"longitude":153.1301851},"streetAddress":{"apt":"","formattedAddressLine":"7 Watland St","name":"Watland Street","number":"7"},"formatted":"7 Watland St, Springwood QLD 4127, Australia","country":"AU","postalCode":"4127","subdivision":"QLD"},"websiteFacebookUrl":"http://wildwyverns.com.au","teamEmail":"info@wildwyverns.com.au","teamLogo":"wix:image://v1/0a255f_2b078a9e22574781b4afbf9924bf9c5c~mv2.png/WWAC%20Womens%20Logo.png#originWidth=3375&originHeight=3375","logoUrl":"https://static.wixstatic.com/media/0a255f_2b078a9e22574781b4afbf9924bf9c5c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"3vs3","place":3},{"_id":"2","points":0,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":3.5,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"3vs3","place":2},{"_id":"2","points":0.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":7}]}},"members":["Gabby Kennett","Gabrielle Kennett","Sarah Elizabeth Piatti","Tara Nehring","Shanika Haylock-Mitchell","Patricia Marshall","Anna Cox","Hannah Seach","Isla Alexis Dumay","Richelle Hamment"],"sourceCreatedAt":"2025-05-04T04:59:12.254Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wild Wyverns (f)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brisbane',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@wildwyverns.com.au'),
 website_url=coalesce(t.website_url,'http://wildwyverns.com.au'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/0a255f_2b078a9e22574781b4afbf9924bf9c5c~mv2.png'),
 public_description=coalesce(t.public_description,'Fierce, fearless, and forged in steel — the Wild Wyverns femmes bring unmatched strength, unity, and heart to the buhurt field.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabby Kennett','captain','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabrielle Kennett','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarah Elizabeth Piatti','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tara Nehring','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shanika Haylock-Mitchell','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patricia Marshall','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anna Cox','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hannah Seach','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isla Alexis Dumay','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richelle Hamment','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns','wild-wyverns',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wild-wyverns-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wild-wyverns-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wild Wyverns (m)','Brisbane',true,'active','public','bi-wild-wyverns-','OC','Oceania','AU','Australia','info@wildwyverns.com.au','https://www.wildwyverns.com.au/','https://static.wixstatic.com/media/87a57f_bdd0b4c20f934bd79f09096b43a67c03~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wild-wyverns-','https://www.buhurtinternational.com/team/wild-wyverns-','Wild Wyverns (m)','Brisbane','info@wildwyverns.com.au','https://www.wildwyverns.com.au/',20,'{"biCollectionId":"8b0c6f08-5d74-4f6f-8a12-71f5350e96f7","teamName":"Wild Wyverns (m)","club":null,"gender":"Male","captain":"Mason Brown","conference":"APAC","country":"Australia","city":"Brisbane","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.wildwyverns.com.au/","teamEmail":"info@wildwyverns.com.au","teamLogo":"wix:image://v1/87a57f_bdd0b4c20f934bd79f09096b43a67c03~mv2.png/WWAC%20Logo.png#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/87a57f_bdd0b4c20f934bd79f09096b43a67c03~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":12},{"_id":"2","points":1,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":8}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":8,"tournaments":[{"_id":"1","points":0,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":10}]}},"members":["Mason Brown","Daniel Rust","Jacob Gregory Woodland","Dylan McNamara","Martin Blak","Storm Simpson","Andrew Harper","Rafael Miguel Galo Garcia","Hugh Perry","Luke Piatti","Malcolm Purnell","Zachary eades","Ethan Kelly"],"sourceCreatedAt":"2025-05-06T10:47:19.245Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wild Wyverns (m)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brisbane',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@wildwyverns.com.au'),
 website_url=coalesce(t.website_url,'https://www.wildwyverns.com.au/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/87a57f_bdd0b4c20f934bd79f09096b43a67c03~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mason Brown','captain','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Rust','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Gregory Woodland','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan McNamara','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Blak','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Storm Simpson','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Harper','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafael Miguel Galo Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hugh Perry','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Piatti','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Malcolm Purnell','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary eades','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Kelly','fighter','bi_teams','https://www.buhurtinternational.com/team/wild-wyverns-','wild-wyverns-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wyoming-free-company-f' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wyoming-free-company-f' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wyoming Free Company (f)','Cheyenne',true,'active','public','bi-wyoming-free-company-f','NA','North America','US','United States','wyomingfreecompany@gmail.com',NULL,'https://static.wixstatic.com/media/a79b76_bd28d0bbabb54d1f91244b367c8f4249~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wyoming-free-company-f','https://www.buhurtinternational.com/team/wyoming-free-company-f','Wyoming Free Company (f)','Cheyenne','wyomingfreecompany@gmail.com',NULL,20,'{"biCollectionId":"59e80780-8af9-44ad-9147-203aef9a7083","teamName":"Wyoming Free Company (f)","club":null,"gender":"Female","captain":"Samantha Robbins","conference":"North America","country":"United States","city":"Cheyenne","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"WY","name":"Wyoming","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Laramie County","name":"Laramie County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Cheyenne","name":"Cheyenne","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Cheyenne","location":{"latitude":41.1347435,"longitude":-104.8211901},"streetAddress":{"apt":"","formattedAddressLine":"Cheyenne","name":"","number":""},"formatted":"Cheyenne, WY, USA","country":"US","subdivision":"WY"},"websiteFacebookUrl":null,"teamEmail":"wyomingfreecompany@gmail.com","teamLogo":"wix:image://v1/a79b76_bd28d0bbabb54d1f91244b367c8f4249~mv2.png/Bazaart_A64168F6-2F80-489D-9306-ACB47A74265B.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/a79b76_bd28d0bbabb54d1f91244b367c8f4249~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Samantha Robbins"],"sourceCreatedAt":"2026-09-01T03:18:11.266Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wyoming Free Company (f)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cheyenne',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wyomingfreecompany@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a79b76_bd28d0bbabb54d1f91244b367c8f4249~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samantha Robbins','captain','bi_teams','https://www.buhurtinternational.com/team/wyoming-free-company-f','wyoming-free-company-f',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='wyoming-free-company-m' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-wyoming-free-company-m' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Wyoming Free Company (m)','Cheyenne',true,'active','public','bi-wyoming-free-company-m','NA','North America','US','United States','wyomingfreecompany@gmail.com',NULL,'https://static.wixstatic.com/media/a79b76_7496ac2e61e44947adaa0664efb75740~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','wyoming-free-company-m','https://www.buhurtinternational.com/team/wyoming-free-company-m','Wyoming Free Company (m)','Cheyenne','wyomingfreecompany@gmail.com',NULL,20,'{"biCollectionId":"eabd54d9-07c9-47a2-81e0-498007d947dc","teamName":"Wyoming Free Company (m)","club":null,"gender":"Male","captain":"Samantha Robbins","conference":"North America","country":"United States","city":"Cheyenne","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"WY","name":"Wyoming","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Laramie County","name":"Laramie County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Cheyenne","name":"Cheyenne","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Cheyenne","location":{"latitude":41.1347435,"longitude":-104.8211901},"streetAddress":{"apt":"","formattedAddressLine":"Cheyenne","name":"","number":""},"formatted":"Cheyenne, WY, USA","country":"US","subdivision":"WY"},"websiteFacebookUrl":null,"teamEmail":"wyomingfreecompany@gmail.com","teamLogo":"wix:image://v1/a79b76_7496ac2e61e44947adaa0664efb75740~mv2.png/Bazaart_A64168F6-2F80-489D-9306-ACB47A74265B.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/a79b76_7496ac2e61e44947adaa0664efb75740~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Samantha Robbins"],"sourceCreatedAt":"2026-09-01T03:16:43.934Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Wyoming Free Company (m)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cheyenne',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wyomingfreecompany@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a79b76_7496ac2e61e44947adaa0664efb75740~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samantha Robbins','captain','bi_teams','https://www.buhurtinternational.com/team/wyoming-free-company-m','wyoming-free-company-m',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='yunque-&-martillo' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-yunque-&-martillo' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Yunque & Martillo','Rosario',true,'active','public','bi-yunque-&-martillo','SA','South America','AR','Argentina','yunqueymartillobr@gamil.com','https://www.facebook.com/profile.php?id=100049475028355','https://static.wixstatic.com/media/4973b5_d260ce08196543d09c1a6b1a6ea3200a~mv2.png','Practicamos y entrenamos diversas formas de combate armado y a mano vacia. Participamos deeventos de combate medieval y otros deportes de combate')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','yunque-&-martillo','https://www.buhurtinternational.com/team/yunque-%26-martillo','Yunque & Martillo','Rosario','yunqueymartillobr@gamil.com','https://www.facebook.com/profile.php?id=100049475028355',20,'{"biCollectionId":"7622d78c-f264-428f-a639-359f69211947","teamName":"Yunque & Martillo","club":"Yunque & Martillo - CLub de Combate","gender":"Male","captain":"Gabriel Oscar Paolucci","conference":"South America","country":"Argentina","city":"Rosario","teamInfo":"Practicamos y entrenamos diversas formas de combate armado y a mano vacia. Participamos deeventos de combate medieval y otros deportes de combate","trainingInfo":"","trainingLocation":{"city":"Rosario","location":{"latitude":-32.9587022,"longitude":-60.69304159999999},"streetAddress":{"apt":"","formattedAddressLine":"Rosario","name":"","number":""},"formatted":"Rosario, Santa Fe Province, Argentina","country":"AR"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100049475028355","teamEmail":"yunqueymartillobr@gamil.com","teamLogo":"wix:image://v1/4973b5_d260ce08196543d09c1a6b1a6ea3200a~mv2.png/heraldicacaes.png#originWidth=2308&originHeight=2364","logoUrl":"https://static.wixstatic.com/media/4973b5_d260ce08196543d09c1a6b1a6ea3200a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Gabriel Oscar Paolucci","Omar Prado","Sebastian Muñoz","Julián Matías Cecchini","Pablo Vilaplana","Hernán Agustín Quevedo","Javier Alejo Ruiz Silva","joel","Alberto Nicolás Ferroni"],"sourceCreatedAt":"2023-09-13T14:32:17.726Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Yunque & Martillo',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Rosario',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'yunqueymartillobr@gamil.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100049475028355'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4973b5_d260ce08196543d09c1a6b1a6ea3200a~mv2.png'),
 public_description=coalesce(t.public_description,'Practicamos y entrenamos diversas formas de combate armado y a mano vacia. Participamos deeventos de combate medieval y otros deportes de combate'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Oscar Paolucci','captain','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Omar Prado','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Muñoz','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julián Matías Cecchini','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pablo Vilaplana','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hernán Agustín Quevedo','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Javier Alejo Ruiz Silva','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'joel','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Nicolás Ferroni','fighter','bi_teams','https://www.buhurtinternational.com/team/yunque-%26-martillo','yunque-&-martillo',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='zitadelle-e.v.' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-zitadelle-e.v.' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Zitadelle e.V.','Weilburg',true,'active','public','bi-zitadelle-e.v.','EU','Europe','DE','Germany','zitadelle.e.v@gmail.com','www.zitadelle.net','https://static.wixstatic.com/media/2fcc57_815783cb318545b4bea787e475928712~mv2.jpeg','Proud to be the oldest, officiall registered club in Germany.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','zitadelle-e.v.','https://www.buhurtinternational.com/team/zitadelle-e.v.','Zitadelle e.V.','Weilburg','zitadelle.e.v@gmail.com','www.zitadelle.net',20,'{"biCollectionId":"83462dd9-c26b-4f5e-b858-1471027dc6b2","teamName":"Zitadelle e.V.","club":"Zitadelle","gender":"Male","captain":"Marcel Jost","conference":"Europe","country":"Germany","city":"Weilburg","teamInfo":"Proud to be the oldest, officiall registered club in Germany.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"HE","name":"Hessen","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"GI","name":"Giessen","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Weilburg","name":"Weilburg","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"DE","name":"Germany","type":"COUNTRY"}],"city":"Weilburg","location":{"latitude":50.4859255,"longitude":8.2722569},"streetAddress":{"apt":"","formattedAddressLine":"Weilburg","name":"","number":""},"formatted":"35781 Weilburg, Germany","country":"DE","postalCode":"35781","subdivision":"HE"},"websiteFacebookUrl":"www.zitadelle.net","teamEmail":"zitadelle.e.v@gmail.com","teamLogo":"wix:image://v1/2fcc57_815783cb318545b4bea787e475928712~mv2.jpeg/IMG_9892.jpeg#originWidth=750&originHeight=754","logoUrl":"https://static.wixstatic.com/media/2fcc57_815783cb318545b4bea787e475928712~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":14}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":8},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":7}]}},"members":["Marcel Jost","Alexander Carl Harrer","Michael Friedrich","Dennis Hoersch","Sascha Geisel","Eric Bochert","Joe Hillemann","Philipp Schmück","Julian Knackstedt","Nils Malsy","Julian Gorr","Kai Tengler","Christopher Arnold","Dean Aleksander Weyand","Tim Ostelmann"],"sourceCreatedAt":"2024-06-26T17:13:38.363Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Zitadelle e.V.',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Weilburg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'zitadelle.e.v@gmail.com'),
 website_url=coalesce(t.website_url,'www.zitadelle.net'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2fcc57_815783cb318545b4bea787e475928712~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Proud to be the oldest, officiall registered club in Germany.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcel Jost','captain','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Carl Harrer','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Friedrich','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Hoersch','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sascha Geisel','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric Bochert','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joe Hillemann','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Philipp Schmück','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Knackstedt','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nils Malsy','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Gorr','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kai Tengler','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Arnold','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dean Aleksander Weyand','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim Ostelmann','fighter','bi_teams','https://www.buhurtinternational.com/team/zitadelle-e.v.','zitadelle-e.v.',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='zona-sur' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-zona-sur' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Zona Sur','Andalucía',true,'active','public','bi-zona-sur','EU','Europe','ES','Spain','lsierrasalinas@hotmail.com','https://www.zonasur.club/','https://static.wixstatic.com/media/661d09_01c91a0210e44b98b2714d0f653e27c4~mv2.jpg','Equipo de Bohurt localizado en el Sur de España.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','zona-sur','https://www.buhurtinternational.com/team/zona-sur','Zona Sur','Andalucía','lsierrasalinas@hotmail.com','https://www.zonasur.club/',20,'{"biCollectionId":"f7632bfb-318c-4df9-928a-56c66df8ba91","teamName":"Zona Sur","club":null,"gender":"Male","captain":"Luis Sierra","conference":"Europe","country":"Spain","city":"Andalucía","teamInfo":"Equipo de Bohurt localizado en el Sur de España.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.zonasur.club/","teamEmail":"lsierrasalinas@hotmail.com","teamLogo":"wix:image://v1/661d09_01c91a0210e44b98b2714d0f653e27c4~mv2.jpg/Logo%20Zona%20Sur.jpg#originWidth=1772&originHeight=1772","logoUrl":"https://static.wixstatic.com/media/661d09_01c91a0210e44b98b2714d0f653e27c4~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":7,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":7,"Tournament":"Torneio Medieval de Pirescoxe 2026","date":"2026-05-02","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":5}]},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":10,"tournaments":[{"_id":"1","points":9,"Tournament":"Torneio Medieval de Pirescoxe 2025","date":"2025-05-03","category":"5vs5","place":1},{"_id":"2","points":1,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":7}]}},"members":["Luis Sierra","Luis Sierra Salinas","Juanma Ruiz","Miguel Ángel Gómez Municio","Manuel casas abad","Sergio Sanchez Berlanga","Rafael I. Maldonado","Antonio Madrid Diez","Dario Mayoral Sánchez","Jose Vaquero Marín","Lucas Aníbal Guido","Roberto Espejo","Mariano Horacio Ahumada","Rafael Robles Laguna","Fernando Bermudez","Jose Zumárraga","JOSE LUIS ARMARIO ANDRADES"],"sourceCreatedAt":"2023-09-22T11:09:36.510Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Zona Sur',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Andalucía',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lsierrasalinas@hotmail.com'),
 website_url=coalesce(t.website_url,'https://www.zonasur.club/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/661d09_01c91a0210e44b98b2714d0f653e27c4~mv2.jpg'),
 public_description=coalesce(t.public_description,'Equipo de Bohurt localizado en el Sur de España.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Sierra','captain','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Sierra Salinas','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juanma Ruiz','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel Ángel Gómez Municio','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Manuel casas abad','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio Sanchez Berlanga','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafael I. Maldonado','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antonio Madrid Diez','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dario Mayoral Sánchez','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Vaquero Marín','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Aníbal Guido','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roberto Espejo','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariano Horacio Ahumada','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafael Robles Laguna','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fernando Bermudez','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Zumárraga','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JOSE LUIS ARMARIO ANDRADES','fighter','bi_teams','https://www.buhurtinternational.com/team/zona-sur','zona-sur',now());
end $$;
commit;
