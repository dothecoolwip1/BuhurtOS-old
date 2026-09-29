begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='desdichado-medieval-fight-club' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-desdichado-medieval-fight-club' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Desdichado Medieval Fight Club','Váralja',true,'active','public','bi-desdichado-medieval-fight-club','EU','Europe','HU','Hungary','desdichadomfc@gmail.com','https://desdichado.webnode.hu/','https://static.wixstatic.com/media/eb1c1e_24fc35d6116c4496a7bd2a89b9cf6caf~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','desdichado-medieval-fight-club','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','Desdichado Medieval Fight Club','Váralja','desdichadomfc@gmail.com','https://desdichado.webnode.hu/',20,'{"biCollectionId":"2a04028a-dff9-4c70-8fec-744fefc5c20d","teamName":"Desdichado Medieval Fight Club","club":null,"gender":"Male","captain":"Árvai Zoltán","conference":"Europe","country":"Hungary","city":"Váralja","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://desdichado.webnode.hu/","teamEmail":"desdichadomfc@gmail.com","teamLogo":"wix:image://v1/eb1c1e_24fc35d6116c4496a7bd2a89b9cf6caf~mv2.png/logoszines.png#originWidth=911&originHeight=1017","logoUrl":"https://static.wixstatic.com/media/eb1c1e_24fc35d6116c4496a7bd2a89b9cf6caf~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Valley of Warriors Buhurt Tournament 2026","date":"2026-06-06","category":"5vs5","place":4},{"_id":"2","points":2,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Valley of Warriors Buhurt Tournament 2024","date":"2024-06-15","category":"3vs3","place":5},{"_id":"2","points":3,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":6}]},"2025":{"tournaments":[{"_id":"1","points":3,"Tournament":"Valley of Warriors Buhurt Tournament 2025","date":"2025-06-07","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":6},{"_id":"3","points":1,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":6}],"points12v12":0,"averagePoints5v5":2,"rank5v5":12,"remainingTokens":10,"points5v5":6}},"members":["Árvai Zoltán","Árvai Csanád Zoltán","Arvai Zoltán","Gábor Varga","Ivan Džakić","Mladen Ursus Orlandini","Pulay Krisztian","Soós Barnabás","Tóth Tamás","Peter Vladov"],"sourceCreatedAt":"2023-09-06T20:06:08.457Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Desdichado Medieval Fight Club',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Váralja',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('HU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Hungary',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'desdichadomfc@gmail.com'),
 website_url=coalesce(t.website_url,'https://desdichado.webnode.hu/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/eb1c1e_24fc35d6116c4496a7bd2a89b9cf6caf~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Árvai Zoltán','captain','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Árvai Csanád Zoltán','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arvai Zoltán','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gábor Varga','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Džakić','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mladen Ursus Orlandini','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pulay Krisztian','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Soós Barnabás','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tóth Tamás','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Peter Vladov','fighter','bi_teams','https://www.buhurtinternational.com/team/desdichado-medieval-fight-club','desdichado-medieval-fight-club',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='detroit-fight-club' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-detroit-fight-club' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'DFC Dire Wolves','Metro Detroit ',true,'active','public','bi-detroit-fight-club','NA','North America','US','United States','DetroitFightClubLLC@gmail.com','http://Detroitfight.club','https://static.wixstatic.com/media/5f0ca8_ad3f017f2bcf49a28bb1bb312ad4eb20~mv2.png','The premier mens team of Detroit Fight Club.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','detroit-fight-club','https://www.buhurtinternational.com/team/detroit-fight-club','DFC Dire Wolves','Metro Detroit ','DetroitFightClubLLC@gmail.com','http://Detroitfight.club',20,'{"biCollectionId":"97c644ca-4fdd-4395-a6f0-6baf93af82ac","teamName":"DFC Dire Wolves","club":null,"gender":"Male","captain":"Aaron Roumaya","conference":"North America","country":"United States","city":"Metro Detroit ","teamInfo":"The premier mens team of Detroit Fight Club.","trainingInfo":"Register on Detroitfight.club/try !","trainingLocation":{"subdivisions":[{"code":"MI","name":"Michigan","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Oakland County","name":"Oakland County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Southfield","name":"Southfield","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Southfield","location":{"latitude":42.4535018,"longitude":-83.2776071},"streetAddress":{"apt":"","formattedAddressLine":"22222 Telegraph Rd","name":"Telegraph Road","number":"22222"},"formatted":"22222 Telegraph Rd, Southfield, MI 48033, USA","country":"US","postalCode":"48033","subdivision":"MI"},"websiteFacebookUrl":"http://Detroitfight.club","teamEmail":"DetroitFightClubLLC@gmail.com","teamLogo":"wix:image://v1/5f0ca8_ad3f017f2bcf49a28bb1bb312ad4eb20~mv2.png/wolfquick.png#originWidth=725&originHeight=784","logoUrl":"https://static.wixstatic.com/media/5f0ca8_ad3f017f2bcf49a28bb1bb312ad4eb20~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":8.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":8},{"_id":"2","points":6.25,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":19}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":16},{"_id":"2","points":0,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":12},{"_id":"3","points":3,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":8},{"_id":"4","points":0,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":7},{"_id":"5","points":2,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":5}],"points12v12":0,"averagePoints5v5":2.33,"rank5v5":16,"remainingTokens":9,"points5v5":7}},"members":["Gage Zurawski","Aaron Roumaya","Jeremy M Fry","Boris Tuman","Mario Aguilar","Kyle Wychuyse","Richard Cornejo","Alexander Kizy","Richard Elswick"],"sourceCreatedAt":"2024-06-28T18:55:26.183Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('DFC Dire Wolves',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Metro Detroit ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'DetroitFightClubLLC@gmail.com'),
 website_url=coalesce(t.website_url,'http://Detroitfight.club'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5f0ca8_ad3f017f2bcf49a28bb1bb312ad4eb20~mv2.png'),
 public_description=coalesce(t.public_description,'The premier mens team of Detroit Fight Club.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gage Zurawski','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron Roumaya','captain','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeremy M Fry','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Boris Tuman','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mario Aguilar','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Wychuyse','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Cornejo','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Kizy','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Elswick','fighter','bi_teams','https://www.buhurtinternational.com/team/detroit-fight-club','detroit-fight-club',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dfc-marauders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dfc-marauders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'DFC Marauders','Metro Detroit ',true,'active','public','bi-dfc-marauders','NA','North America','US','United States','team@detroitfight.club','https://Detroitfight.club','https://static.wixstatic.com/media/3d400a_55b0f70496e7497c91e50ade90bf74a9~mv2.jpeg','More to come')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dfc-marauders','https://www.buhurtinternational.com/team/dfc-marauders','DFC Marauders','Metro Detroit ','team@detroitfight.club','https://Detroitfight.club',20,'{"biCollectionId":"7da42d42-f5b7-4162-b901-4eaffbffb823","teamName":"DFC Marauders","club":null,"gender":"Male","captain":"TBD","conference":"North America","country":"United States","city":"Metro Detroit ","teamInfo":"More to come","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"MI","name":"Michigan","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Oakland County","name":"Oakland County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Southfield","name":"Southfield","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Southfield","location":{"latitude":42.4535592,"longitude":-83.2773382},"streetAddress":{"apt":"","formattedAddressLine":"22222 Telegraph Rd","name":"Telegraph Road","number":"22222"},"formatted":"22222 Telegraph Rd, Southfield, MI 48033, USA","country":"US","postalCode":"48033","subdivision":"MI"},"websiteFacebookUrl":"https://Detroitfight.club","teamEmail":"team@detroitfight.club","teamLogo":"wix:image://v1/3d400a_55b0f70496e7497c91e50ade90bf74a9~mv2.jpeg/r4trpfeqjm7f1.jpeg#originWidth=1588&originHeight=1588","logoUrl":"https://static.wixstatic.com/media/3d400a_55b0f70496e7497c91e50ade90bf74a9~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":5}],"eventsHistory":{},"members":["TBD","Baker Noori","Benjamin Brooke","Kolby Cortis","Luke Shaw","Doug Johnson","Jalen Covington","Scott Griffith","Jason Frye","Ricardo Irizarry","Jordan taylor rank","Michael Clayton","Raquiem Ali"],"sourceCreatedAt":"2026-08-04T20:50:29.217Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('DFC Marauders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Metro Detroit ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'team@detroitfight.club'),
 website_url=coalesce(t.website_url,'https://Detroitfight.club'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3d400a_55b0f70496e7497c91e50ade90bf74a9~mv2.jpeg'),
 public_description=coalesce(t.public_description,'More to come'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'TBD','captain','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Baker Noori','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Brooke','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kolby Cortis','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Shaw','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Doug Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jalen Covington','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott Griffith','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Frye','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ricardo Irizarry','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan taylor rank','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Clayton','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raquiem Ali','fighter','bi_teams','https://www.buhurtinternational.com/team/dfc-marauders','dfc-marauders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='diex-aie' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-diex-aie' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'DIEX AIE','NORMANDIE',true,'active','public','bi-diex-aie','EU','Europe','FR','France',' normandie.behourd@gmail.com','https://www.facebook.com/DiexAieNormandieBehourd','https://static.wixstatic.com/media/83e3bb_c5585cae780b44f8a6c2b2069240f27f~mv2.webp',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','diex-aie','https://www.buhurtinternational.com/team/diex-aie','DIEX AIE','NORMANDIE',' normandie.behourd@gmail.com','https://www.facebook.com/DiexAieNormandieBehourd',20,'{"biCollectionId":"9c7fffb6-767e-45e6-8f8b-b215a2c5079a","teamName":"DIEX AIE","club":null,"gender":"Male","captain":"Romain Crespeau","conference":"Europe","country":"France","city":"NORMANDIE","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/DiexAieNormandieBehourd","teamEmail":" normandie.behourd@gmail.com","teamLogo":"wix:image://v1/83e3bb_c5585cae780b44f8a6c2b2069240f27f~mv2.webp/diex-aie.webp#originWidth=1080&originHeight=706","logoUrl":"https://static.wixstatic.com/media/83e3bb_c5585cae780b44f8a6c2b2069240f27f~mv2.webp","rank5v5":null,"averagePoints5v5":null,"points5v5":10,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":10,"Tournament":"Jan van Brabant 2026","date":"2026-05-16","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":8,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":2},{"_id":"2","points":2,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":6},{"_id":"3","points":3,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":8}],"points12v12":0,"averagePoints5v5":4.33,"rank5v5":7,"remainingTokens":10,"points5v5":13}},"members":["Romain Crespeau","Klein Adrien","Jeremy Charles","Etienne HUSSON","Balloche Lucas","Flahaut Alexis","Binet","Thomas Chauvin","Paul-Henri Gautheret"],"sourceCreatedAt":"2024-03-31T12:14:10.005Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('DIEX AIE',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('NORMANDIE',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,' normandie.behourd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/DiexAieNormandieBehourd'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/83e3bb_c5585cae780b44f8a6c2b2069240f27f~mv2.webp'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Romain Crespeau','captain','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Klein Adrien','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeremy Charles','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Etienne HUSSON','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Balloche Lucas','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Flahaut Alexis','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Binet','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Chauvin','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul-Henri Gautheret','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie','diex-aie',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='diex-aie-secondus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-diex-aie-secondus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'DIEX AIE SECONDUS','ROUEN',true,'active','public','bi-diex-aie-secondus','EU','Europe','FR','France','dupuis.benjamin1@gmail.com','https://www.facebook.com/DiexAieNormandieBehourd','https://static.wixstatic.com/media/20f9b6_ff26827781464b39aa9d1497c25bd7aa~mv2.jpg','Team 2 of the french buhurt club: DIEX AIE Normandie béhourd')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','diex-aie-secondus','https://www.buhurtinternational.com/team/diex-aie-secondus','DIEX AIE SECONDUS','ROUEN','dupuis.benjamin1@gmail.com','https://www.facebook.com/DiexAieNormandieBehourd',20,'{"biCollectionId":"f15fc52b-3f3b-4834-8669-8bf7a20e12f0","teamName":"DIEX AIE SECONDUS","club":null,"gender":"Male","captain":"Maximilien ANGER","conference":"Europe","country":"France","city":"ROUEN","teamInfo":"Team 2 of the french buhurt club: DIEX AIE Normandie béhourd","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/DiexAieNormandieBehourd","teamEmail":"dupuis.benjamin1@gmail.com","teamLogo":"wix:image://v1/20f9b6_ff26827781464b39aa9d1497c25bd7aa~mv2.jpg/Secondus.jpg#originWidth=1970&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/20f9b6_ff26827781464b39aa9d1497c25bd7aa~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Maximilien ANGER","Benjamin Dupuis","Valentin Mattei","GUY Paul-André","Damien Saint gilles","Noam Ait Khedache","Bruno DOMENZI","Nathan Paré","Bastien Grandcamp","Emmanuel Gien"],"sourceCreatedAt":"2024-04-28T20:31:52.461Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('DIEX AIE SECONDUS',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('ROUEN',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'dupuis.benjamin1@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/DiexAieNormandieBehourd'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/20f9b6_ff26827781464b39aa9d1497c25bd7aa~mv2.jpg'),
 public_description=coalesce(t.public_description,'Team 2 of the french buhurt club: DIEX AIE Normandie béhourd'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maximilien ANGER','captain','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Dupuis','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valentin Mattei','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GUY Paul-André','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damien Saint gilles','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noam Ait Khedache','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruno DOMENZI','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Paré','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bastien Grandcamp','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emmanuel Gien','fighter','bi_teams','https://www.buhurtinternational.com/team/diex-aie-secondus','diex-aie-secondus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dominus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dominus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dominus','Yamhill',true,'active','public','bi-dominus','NA','North America','US','United States','Dominus','https://www.facebook.com/profile.php/?id=100091911506500','https://static.wixstatic.com/media/9729cc_f79844b7352148c384cc0a25d1784696~mv2.jpeg','A pretty good team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dominus','https://www.buhurtinternational.com/team/dominus','Dominus','Yamhill','Dominus','https://www.facebook.com/profile.php/?id=100091911506500',20,'{"biCollectionId":"4ade4560-7420-40f1-bba1-7804a2205576","teamName":"Dominus","club":null,"gender":"Male","captain":"Joseph Brandt","conference":"North America","country":"United States","city":"Yamhill","teamInfo":"A pretty good team","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php/?id=100091911506500","teamEmail":"Dominus","teamLogo":"wix:image://v1/9729cc_f79844b7352148c384cc0a25d1784696~mv2.jpeg/received_1429777814601600.jpeg#originWidth=1750&originHeight=2336","logoUrl":"https://static.wixstatic.com/media/9729cc_f79844b7352148c384cc0a25d1784696~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":30,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":1},{"_id":"2","points":21,"Tournament":"Pacific Cup 2024","date":"2024-06-14","category":"5vs5","place":1},{"_id":"3","points":0,"Tournament":"Rise of an Empire 2024","date":"2024-08-30","category":"5vs5","place":4},{"_id":"4","points":11,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":1}]},"2025":{"points12v12":0,"points5v5":24,"remainingTokens":4,"tournaments":[{"_id":"1","points":24,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":1}]}},"members":["Joseph Brandt","Craig Ivey","Matthew Creedican","Daniel Krug"],"sourceCreatedAt":"2024-04-02T16:20:06.651Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dominus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Yamhill',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Dominus'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php/?id=100091911506500'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9729cc_f79844b7352148c384cc0a25d1784696~mv2.jpeg'),
 public_description=coalesce(t.public_description,'A pretty good team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Brandt','captain','bi_teams','https://www.buhurtinternational.com/team/dominus','dominus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Craig Ivey','fighter','bi_teams','https://www.buhurtinternational.com/team/dominus','dominus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Creedican','fighter','bi_teams','https://www.buhurtinternational.com/team/dominus','dominus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Krug','fighter','bi_teams','https://www.buhurtinternational.com/team/dominus','dominus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='draconis-armatus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-draconis-armatus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Draconis Armatus','Zaragoza',true,'active','public','bi-draconis-armatus','EU','Europe','ES','Spain','zaragozamedievalcombat@gmail.com',NULL,'https://static.wixstatic.com/media/affb48_27f1886ee4394366a4c7dd70a04a5333~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','draconis-armatus','https://www.buhurtinternational.com/team/draconis-armatus','Draconis Armatus','Zaragoza','zaragozamedievalcombat@gmail.com',NULL,20,'{"biCollectionId":"4f3e5f78-dc46-44a3-be39-a90c4f600657","teamName":"Draconis Armatus","club":null,"gender":"Male","captain":"Blocau David Milo","conference":"Europe","country":"Spain","city":"Zaragoza","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"zaragozamedievalcombat@gmail.com","teamLogo":"wix:image://v1/affb48_27f1886ee4394366a4c7dd70a04a5333~mv2.png/Logo%20en%20alta%20calidad%20(png).png#originWidth=9000&originHeight=9000","logoUrl":"https://static.wixstatic.com/media/affb48_27f1886ee4394366a4c7dd70a04a5333~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":5}]}},"members":["Blocau David Milo","Javier Azcona Ruiz","Sergio López Equiza","Cesar Rubio Garcia","David Ubide Alaiz","David Milo Blocau","Alejandro Gutierrez Gutierrez","Jerome Hidalgo Sanz","Joonas Lammasniemi","Matti Schadrin"],"sourceCreatedAt":"2024-09-06T20:35:09.543Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Draconis Armatus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Zaragoza',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'zaragozamedievalcombat@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/affb48_27f1886ee4394366a4c7dd70a04a5333~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blocau David Milo','captain','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Javier Azcona Ruiz','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio López Equiza','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cesar Rubio Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Ubide Alaiz','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Milo Blocau','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alejandro Gutierrez Gutierrez','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerome Hidalgo Sanz','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joonas Lammasniemi','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matti Schadrin','fighter','bi_teams','https://www.buhurtinternational.com/team/draconis-armatus','draconis-armatus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dragonas' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dragonas' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dragonas','Mar del Plata',true,'active','public','bi-dragonas','SA','South America','AR','Argentina','sofia.giampietro96@gmail.com','https://www.facebook.com/DragonesAtlanticos/?locale=es_LA','https://static.wixstatic.com/media/e667eb_7bdf4b53a27e41a3ac1c1b58e92e4efd~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dragonas','https://www.buhurtinternational.com/team/dragonas','Dragonas','Mar del Plata','sofia.giampietro96@gmail.com','https://www.facebook.com/DragonesAtlanticos/?locale=es_LA',20,'{"biCollectionId":"0a796e33-b978-41f9-9c43-de68a1aa9540","teamName":"Dragonas","club":null,"gender":"Female","captain":"Sofia Giampietro","conference":"South America","country":"Argentina","city":"Mar del Plata","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/DragonesAtlanticos/?locale=es_LA","teamEmail":"sofia.giampietro96@gmail.com","teamLogo":"wix:image://v1/e667eb_7bdf4b53a27e41a3ac1c1b58e92e4efd~mv2.jpg/Dragones.jpg#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/e667eb_7bdf4b53a27e41a3ac1c1b58e92e4efd~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Sofia Giampietro","Sofia","Andrea Teves","Luisina Sühs","dalila sedem","Fabiana Rosa Maria Campos"],"sourceCreatedAt":"2024-02-24T21:34:28.532Z","sourceUpdatedAt":"2026-09-24T18:21:42.905Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dragonas',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mar del Plata',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'sofia.giampietro96@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/DragonesAtlanticos/?locale=es_LA'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e667eb_7bdf4b53a27e41a3ac1c1b58e92e4efd~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sofia Giampietro','captain','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sofia','fighter','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrea Teves','fighter','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luisina Sühs','fighter','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'dalila sedem','fighter','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabiana Rosa Maria Campos','fighter','bi_teams','https://www.buhurtinternational.com/team/dragonas','dragonas',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dragones-atlánticos' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dragones-atlánticos' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dragones Atlánticos','Mar del Plata',true,'active','public','bi-dragones-atlánticos','SA','South America','AR','Argentina','manumoron98@gmail.com','https://m.facebook.com/DragonesAtlanticos/?locale=cx_PH','https://static.wixstatic.com/media/e667eb_4f1641f9097643369538080b44d12659~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dragones-atlánticos','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','Dragones Atlánticos','Mar del Plata','manumoron98@gmail.com','https://m.facebook.com/DragonesAtlanticos/?locale=cx_PH',20,'{"biCollectionId":"9b21b527-d877-4fc8-93ad-62eed92a6ec9","teamName":"Dragones Atlánticos","club":"Dragones Atlánticos","gender":"Male","captain":"Manuel Morón","conference":"South America","country":"Argentina","city":"Mar del Plata","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://m.facebook.com/DragonesAtlanticos/?locale=cx_PH","teamEmail":"manumoron98@gmail.com","teamLogo":"wix:image://v1/e667eb_4f1641f9097643369538080b44d12659~mv2.jpg/aaa.jpg#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/e667eb_4f1641f9097643369538080b44d12659~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Copa Centinela 2024","date":"2024-05-04","category":"5vs5","place":2}]},"2025":{"remainingTokens":10}},"members":["Manuel Morón","David Ezequiel Perez","Marcos Andres Castaño","Ignacio Villalobo","Ignacio Montrasi","Aquiles german ibañez","pablo german bracciale sauro","Gabriel Franchini"],"sourceCreatedAt":"2024-02-09T15:37:35.773Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dragones Atlánticos',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mar del Plata',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'manumoron98@gmail.com'),
 website_url=coalesce(t.website_url,'https://m.facebook.com/DragonesAtlanticos/?locale=cx_PH'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e667eb_4f1641f9097643369538080b44d12659~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Manuel Morón','captain','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Ezequiel Perez','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Andres Castaño','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ignacio Villalobo','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ignacio Montrasi','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aquiles german ibañez','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'pablo german bracciale sauro','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Franchini','fighter','bi_teams','https://www.buhurtinternational.com/team/dragones-atl%C3%A1nticos','dragones-atlánticos',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='draig' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-draig' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Draig','Cardiff ',true,'active','public','bi-draig','EU','Europe','GB','United Kingdom','Medievalcombatwales@gmail.com','https://medievalcombatwales.co.uk','https://static.wixstatic.com/media/1ea5cb_6890dd4af8324f61a69c8e4448d8ad71~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','draig','https://www.buhurtinternational.com/team/draig','Draig','Cardiff ','Medievalcombatwales@gmail.com','https://medievalcombatwales.co.uk',20,'{"biCollectionId":"bae406c0-a252-4653-a5ab-5e5f4874011e","teamName":"Draig","club":null,"gender":"Male","captain":"Dai \"the Dwarf \" Watkins","conference":"Europe","country":"United Kingdom","city":"Cardiff ","teamInfo":"","trainingInfo":"","trainingLocation":{"city":"Graig","location":{"latitude":51.5979757,"longitude":-3.3425697},"streetAddress":{"apt":"Graig Chapel","formattedAddressLine":"EGH Judo","name":"Rickards Street","number":""},"formatted":"Graig Chapel, Rickards St, Graig, Pontypridd CF37 1RD, UK","country":"GB","postalCode":"CF37 1RD"},"websiteFacebookUrl":"https://medievalcombatwales.co.uk","teamEmail":"Medievalcombatwales@gmail.com","teamLogo":"wix:image://v1/1ea5cb_6890dd4af8324f61a69c8e4448d8ad71~mv2.png/inbound4682309087781031743.png#originWidth=1080&originHeight=1972","logoUrl":"https://static.wixstatic.com/media/1ea5cb_6890dd4af8324f61a69c8e4448d8ad71~mv2.png","rank5v5":11,"averagePoints5v5":0.75,"points5v5":2.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":13},{"_id":"2","points":1.25,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":7},{"_id":"3","points":0,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":10}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":10},{"_id":"2","points":0,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":11}]},"2025":{"tournaments":[{"_id":"1","points":1,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":11},{"_id":"2","points":1,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":12},{"_id":"3","points":1,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":12}],"points12v12":0,"averagePoints5v5":1,"rank5v5":14,"remainingTokens":8,"points5v5":3}},"members":["Dai \"the Dwarf \" Watkins","Christopher sparrow","Adam Davies","Matthew Francis","Thomas Lloyd Smith","Ethan Thomas James Ironborne","Joel Thomas","Zack Morgan","Dannie Terry","Tomos Havard","Kaine Stuart","Callum Williams","Cory Edwards","Dai \"The Dwarf” Watkins","Mike McDonnell","Simon hunt","Rorie Lee Wathan"],"sourceCreatedAt":"2023-09-03T14:14:44.049Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Draig',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cardiff ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Medievalcombatwales@gmail.com'),
 website_url=coalesce(t.website_url,'https://medievalcombatwales.co.uk'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/1ea5cb_6890dd4af8324f61a69c8e4448d8ad71~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dai "the Dwarf " Watkins','captain','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher sparrow','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Davies','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Francis','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Lloyd Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Thomas James Ironborne','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joel Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zack Morgan','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dannie Terry','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomos Havard','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kaine Stuart','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Callum Williams','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cory Edwards','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dai "The Dwarf” Watkins','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mike McDonnell','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon hunt','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rorie Lee Wathan','fighter','bi_teams','https://www.buhurtinternational.com/team/draig','draig',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='east-anglia-armoured-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-east-anglia-armoured-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'East Anglia Armoured Combat','East Anglia',true,'active','public','bi-east-anglia-armoured-combat','EU','Europe','GB','United Kingdom','east.anglia.armoured.combat@gmail.com',NULL,'https://static.wixstatic.com/media/66a094_211d4d55e23a4506ac4e5e29a17488a7~mv2.jpg','A coalition force formed out of the Cambridge Medieval Fighters Guild and Norwich Medieval Armored Combat.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','east-anglia-armoured-combat','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','East Anglia Armoured Combat','East Anglia','east.anglia.armoured.combat@gmail.com',NULL,20,'{"biCollectionId":"978a8e9e-fe56-45d0-a83f-d8d5f193b706","teamName":"East Anglia Armoured Combat","club":null,"gender":"Male","captain":"Jack Gale","conference":"Europe","country":"United Kingdom","city":"East Anglia","teamInfo":"A coalition force formed out of the Cambridge Medieval Fighters Guild and Norwich Medieval Armored Combat.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"east.anglia.armoured.combat@gmail.com","teamLogo":"wix:image://v1/66a094_211d4d55e23a4506ac4e5e29a17488a7~mv2.jpg/IMG-20260411-WA0000.jpg#originWidth=693&originHeight=693","logoUrl":"https://static.wixstatic.com/media/66a094_211d4d55e23a4506ac4e5e29a17488a7~mv2.jpg","rank5v5":10,"averagePoints5v5":2,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":7},{"_id":"2","points":2,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":5},{"_id":"3","points":1,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":8}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["Jack Gale","Jordan Wright","William Evans","Ben Alan Laker","Mark Shepherd","Tom Andrews","Sebastien Claus","John Bernard","Luke Daly","James Derrick","Luke Oakman","Bear Wright"],"sourceCreatedAt":"2025-09-11T13:09:34.267Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('East Anglia Armoured Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('East Anglia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'east.anglia.armoured.combat@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/66a094_211d4d55e23a4506ac4e5e29a17488a7~mv2.jpg'),
 public_description=coalesce(t.public_description,'A coalition force formed out of the Cambridge Medieval Fighters Guild and Norwich Medieval Armored Combat.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Gale','captain','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Wright','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Alan Laker','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark Shepherd','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tom Andrews','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastien Claus','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Bernard','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Daly','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Derrick','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Oakman','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bear Wright','fighter','bi_teams','https://www.buhurtinternational.com/team/east-anglia-armoured-combat','east-anglia-armoured-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='eiserne-biber' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-eiserne-biber' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Eiserne Biber','Koblenz/Dresden',true,'active','public','bi-eiserne-biber','EU','Europe','DE','Germany','mildesandrea@gmail.com','https://www.facebook.com/profile.php?id=61552143123445','https://static.wixstatic.com/media/c4aa9b_61df1d012f2544678bd71c3e13657f73~mv2.jpg','We formed as a team in August of 2025. We are eager to start competing!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','eiserne-biber','https://www.buhurtinternational.com/team/eiserne-biber','Eiserne Biber','Koblenz/Dresden','mildesandrea@gmail.com','https://www.facebook.com/profile.php?id=61552143123445',20,'{"biCollectionId":"3b874051-4ac8-4ea1-ad9b-6a26e601d249","teamName":"Eiserne Biber","club":null,"gender":"Female","captain":"Lisa von Ehr","conference":"Europe","country":"Germany","city":"Koblenz/Dresden","teamInfo":"We formed as a team in August of 2025. We are eager to start competing!","trainingInfo":"Feel free to contact us if you are interested in joining us or just training. We will talk about the details then.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61552143123445","teamEmail":"mildesandrea@gmail.com","teamLogo":"wix:image://v1/c4aa9b_61df1d012f2544678bd71c3e13657f73~mv2.jpg/IMG-20250827-WA0008.jpg#originWidth=751&originHeight=751","logoUrl":"https://static.wixstatic.com/media/c4aa9b_61df1d012f2544678bd71c3e13657f73~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Andrea Mildes","Tina John","Alina Buschhaus","Theresa Beckert","Miriam Westermeier","Lisa von Ehr"],"sourceCreatedAt":"2026-02-12T14:24:44.248Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Eiserne Biber',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Koblenz/Dresden',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mildesandrea@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61552143123445'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c4aa9b_61df1d012f2544678bd71c3e13657f73~mv2.jpg'),
 public_description=coalesce(t.public_description,'We formed as a team in August of 2025. We are eager to start competing!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrea Mildes','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tina John','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alina Buschhaus','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Theresa Beckert','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miriam Westermeier','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lisa von Ehr','captain','bi_teams','https://www.buhurtinternational.com/team/eiserne-biber','eiserne-biber',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='eiserne-löwen' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-eiserne-löwen' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Eiserne Löwen','Dresden',true,'active','public','bi-eiserne-löwen','EU','Europe','DE','Germany','eiserne.loewen.dresden@gmail.com','https://www.facebook.com/profile.php?id=61552143123445','https://static.wixstatic.com/media/4d863d_40c3f3ac8738408c80baeb360502b51c~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','eiserne-löwen','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','Eiserne Löwen','Dresden','eiserne.loewen.dresden@gmail.com','https://www.facebook.com/profile.php?id=61552143123445',20,'{"biCollectionId":"22cc0c53-5a33-47cc-a211-71d1496cd39a","teamName":"Eiserne Löwen","club":null,"gender":"Male","captain":"Gregor Porzig","conference":"Europe","country":"Germany","city":"Dresden","teamInfo":"","trainingInfo":"Wir haben verschiedene Trainigsstandorte in Deutschland. Schreibt uns einfach an und wir leiten Euch weiter.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61552143123445","teamEmail":"eiserne.loewen.dresden@gmail.com","teamLogo":"wix:image://v1/4d863d_40c3f3ac8738408c80baeb360502b51c~mv2.jpeg/WhatsApp%20Image%202023-09-21%20at%2016.50.44.jpeg#originWidth=1280&originHeight=1280","logoUrl":"https://static.wixstatic.com/media/4d863d_40c3f3ac8738408c80baeb360502b51c~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":11}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":9},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":5}]},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":10}]}},"members":["Marko Legler","Johnny Kahl","Dario Aurelius Demmig","Gregor Porzig","Pascal Bruckner","Frank von Ehr","DENIS FISCHER","David Martin","Mayers Moritz","Hermann Jaenicke","Dirk Wiesenthal"],"sourceCreatedAt":"2024-02-18T12:42:09.304Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Eiserne Löwen',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dresden',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'eiserne.loewen.dresden@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61552143123445'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4d863d_40c3f3ac8738408c80baeb360502b51c~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marko Legler','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johnny Kahl','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dario Aurelius Demmig','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregor Porzig','captain','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pascal Bruckner','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frank von Ehr','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'DENIS FISCHER','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Martin','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mayers Moritz','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hermann Jaenicke','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dirk Wiesenthal','fighter','bi_teams','https://www.buhurtinternational.com/team/eiserne-l%C3%B6wen','eiserne-löwen',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='exactor-mortis' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-exactor-mortis' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'EXACTOR MORTIS','REIMS ',true,'active','public','bi-exactor-mortis','EU','Europe','FR','France','medievalesemb@gmail.com',NULL,'https://static.wixstatic.com/media/e09ac1_97cf3896b0784a1d84ff7e0013b847ae~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','exactor-mortis','https://www.buhurtinternational.com/team/exactor-mortis','EXACTOR MORTIS','REIMS ','medievalesemb@gmail.com',NULL,20,'{"biCollectionId":"07254a0c-6710-4a1b-a27e-380ffcc09667","teamName":"EXACTOR MORTIS","club":null,"gender":"Male","captain":"Jérémy Fahys ","conference":"Europe","country":"France","city":"REIMS ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"medievalesemb@gmail.com","teamLogo":"wix:image://v1/e09ac1_97cf3896b0784a1d84ff7e0013b847ae~mv2.jpeg/IMG_5687.jpeg#originWidth=702&originHeight=878","logoUrl":"https://static.wixstatic.com/media/e09ac1_97cf3896b0784a1d84ff7e0013b847ae~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Jérémy Fahys","Guillaume Defaux","BERTIN JULES","Benjamin CLOEREC","Lamiche Eliott","Puault Pierre","THIBAULT MARTIN","Priol Jérémy","Falque Sébastien"],"sourceCreatedAt":"2026-03-24T07:44:59.249Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('EXACTOR MORTIS',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('REIMS ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'medievalesemb@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e09ac1_97cf3896b0784a1d84ff7e0013b847ae~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jérémy Fahys','captain','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume Defaux','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BERTIN JULES','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin CLOEREC','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lamiche Eliott','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Puault Pierre','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'THIBAULT MARTIN','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Priol Jérémy','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Falque Sébastien','fighter','bi_teams','https://www.buhurtinternational.com/team/exactor-mortis','exactor-mortis',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='executioners' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-executioners' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Executioners',NULL,true,'active','public','bi-executioners','NA','North America','US','United States','JustArandomEmailForUserNotReplyingToMe@gmail.com','https://www.theknightshall.com','https://static.wixstatic.com/media/23f8ed_921a6950d6484e02a0559694a4e01e2d~mv2.jpeg','Celebrating 10 years of swinging axes!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','executioners','https://www.buhurtinternational.com/team/executioners','Executioners',NULL,'JustArandomEmailForUserNotReplyingToMe@gmail.com','https://www.theknightshall.com',20,'{"biCollectionId":"acbcca9e-1d99-401a-9891-463bd78c5a1e","teamName":"Executioners","club":null,"gender":"Male","captain":"Catlin Brooks","conference":"North America","country":"United States","city":null,"teamInfo":"Celebrating 10 years of swinging axes!","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"NH","name":"New Hampshire","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Hillsborough County","name":"Hillsborough County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Nashua","name":"Nashua","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Nashua","location":{"latitude":42.7500551,"longitude":-71.4675863},"streetAddress":{"apt":"","formattedAddressLine":"55 Lake St","name":"Lake Street","number":"55"},"formatted":"55 Lake St, Nashua, NH 03060, USA","country":"US","postalCode":"03060","subdivision":"NH"},"websiteFacebookUrl":"https://www.theknightshall.com","teamEmail":"JustArandomEmailForUserNotReplyingToMe@gmail.com","teamLogo":"wix:image://v1/23f8ed_921a6950d6484e02a0559694a4e01e2d~mv2.jpeg/C4974D9E-F3A0-4BB5-A369-726E3581A409.jpeg#originWidth=522&originHeight=522","logoUrl":"https://static.wixstatic.com/media/23f8ed_921a6950d6484e02a0559694a4e01e2d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":12,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":12,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":18,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":3},{"_id":"2","points":12,"Tournament":"Grapes of Wrath 2024","date":"2024-05-18","category":"5vs5","place":1},{"_id":"3","points":0,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":7},{"_id":"4","points":8,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3},{"_id":"5","points":9,"Tournament":"Blood & Steel 7 2024","date":"2024-10-19","category":"5vs5","place":1},{"_id":"6","points":12,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":1}]},"2025":{"points12v12":0,"points5v5":12,"remainingTokens":10,"tournaments":[{"_id":"1","points":12,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":2}]}},"members":["Catlin Brooks","Charles Goodwin","Dustin Brooks","Evan Ringo","Josh Kearney","Jean-sébastien drapeau","Joseph E Baker","Paul Friedel"],"sourceCreatedAt":"2024-03-30T15:21:33.454Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Executioners',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'JustArandomEmailForUserNotReplyingToMe@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.theknightshall.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/23f8ed_921a6950d6484e02a0559694a4e01e2d~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Celebrating 10 years of swinging axes!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Catlin Brooks','captain','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charles Goodwin','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dustin Brooks','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan Ringo','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Kearney','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean-sébastien drapeau','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph E Baker','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Friedel','fighter','bi_teams','https://www.buhurtinternational.com/team/executioners','executioners',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='exiles' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-exiles' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Exiles','Philadelphia',true,'active','public','bi-exiles','NA','North America','US','United States','corben.waters@gmail.com',NULL,'https://static.wixstatic.com/media/e4dfa1_534cf5df8a4540d0bfc14a42a6ce067c~mv2.png','The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition. Every member of The Exiles is here to push limits—physically, tactically, and mentally. This isn’t a social club. This is a battlefield brotherhood built on sweat, bruises, and loyalty. Whether you&#x27;re a seasoned fighter or a dedicated recruit, you’ll find a team that values grit, discipline, and dedication above all else. We’re not here to chase glory—we’re here to earn it.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','exiles','https://www.buhurtinternational.com/team/exiles','Exiles','Philadelphia','corben.waters@gmail.com',NULL,20,'{"biCollectionId":"7208bebb-ca70-48b2-939d-13d5d3e86ab0","teamName":"Exiles","club":null,"gender":"Male","captain":"Corben Waters","conference":"North America","country":"United States","city":"Philadelphia","teamInfo":"The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition. Every member of The Exiles is here to push limits—physically, tactically, and mentally. This isn’t a social club. This is a battlefield brotherhood built on sweat, bruises, and loyalty. Whether you&#x27;re a seasoned fighter or a dedicated recruit, you’ll find a team that values grit, discipline, and dedication above all else. We’re not here to chase glory—we’re here to earn it.","trainingInfo":"Interested in joining The Exiles? We’re looking for recruits who want more than a hobby—this is a competitive team built for people ready to train, improve, and fight. Whether you have armor or not, whether you’re experienced or just getting started, we’ll meet you where you are and push you to grow. Age and fitness level aren’t barriers—commitment is. We provide structured training, sparring, and full support to get you ready for competition. You’ll get guidance on equipment, gear loaners while you build your kit, and access to experienced fighters who’ve been in the list. We ask a lot from our team—but we give everything you need to succeed. Ready to step in? Contact team captains Corben Waters or Paul Meffany to find out how to get started.","trainingLocation":{"subdivisions":[{"code":"MD","name":"Maryland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Cecil County","name":"Cecil County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Elkton","name":"Elkton","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Elkton","location":{"latitude":39.6073457,"longitude":-75.8339685},"streetAddress":{"apt":"b","formattedAddressLine":"109 N Bridge St b","name":"North Bridge Street","number":"109"},"formatted":"109 N Bridge St b, Elkton, MD 21921, USA","country":"US","postalCode":"21921-5326","subdivision":"MD"},"websiteFacebookUrl":null,"teamEmail":"corben.waters@gmail.com","teamLogo":"wix:image://v1/e4dfa1_534cf5df8a4540d0bfc14a42a6ce067c~mv2.png/Final%20Exiles%20Logo%20No%20BG%20Large-min%20-%20square.png#originWidth=4096&originHeight=4096","logoUrl":"https://static.wixstatic.com/media/e4dfa1_534cf5df8a4540d0bfc14a42a6ce067c~mv2.png","rank5v5":12,"averagePoints5v5":4.75,"points5v5":14.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":11,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":2},{"_id":"2","points":2,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":4},{"_id":"3","points":1.25,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":12}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":4,"tournaments":[{"_id":"1","points":0,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":6},{"_id":"2","points":0,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":10}]}},"members":["Corben Waters","Corben Shane Waters","Shayne Linzy","Corey Maher","John Slensby","Andrew Charles Arena","Ryan Krauss","Andrew Campbell"],"sourceCreatedAt":"2025-08-19T21:34:23.274Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Exiles',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Philadelphia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'corben.waters@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e4dfa1_534cf5df8a4540d0bfc14a42a6ce067c~mv2.png'),
 public_description=coalesce(t.public_description,'The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition. Every member of The Exiles is here to push limits—physically, tactically, and mentally. This isn’t a social club. This is a battlefield brotherhood built on sweat, bruises, and loyalty. Whether you&#x27;re a seasoned fighter or a dedicated recruit, you’ll find a team that values grit, discipline, and dedication above all else. We’re not here to chase glory—we’re here to earn it.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corben Waters','captain','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corben Shane Waters','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shayne Linzy','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corey Maher','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Slensby','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Charles Arena','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Krauss','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Campbell','fighter','bi_teams','https://www.buhurtinternational.com/team/exiles','exiles',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='faucons-noirs' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-faucons-noirs' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Faucons Noirs','Montbazon',true,'active','public','bi-faucons-noirs','EU','Europe','FR','France','faucon-touraine-behourd@hotmail.com',NULL,'https://static.wixstatic.com/media/2b92a4_5310e3fb046b446dbafed85ecee4d29e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','faucons-noirs','https://www.buhurtinternational.com/team/faucons-noirs','Faucons Noirs','Montbazon','faucon-touraine-behourd@hotmail.com',NULL,20,'{"biCollectionId":"13f71013-8686-44cc-9017-9eef7496f9f8","teamName":"Faucons Noirs","club":null,"gender":"Male","captain":"Tommy MORIN","conference":"Europe","country":"France","city":"Montbazon","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"faucon-touraine-behourd@hotmail.com","teamLogo":"wix:image://v1/2b92a4_5310e3fb046b446dbafed85ecee4d29e~mv2.png/Logo%20Faucons.png#originWidth=598&originHeight=598","logoUrl":"https://static.wixstatic.com/media/2b92a4_5310e3fb046b446dbafed85ecee4d29e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":7,"tournaments":[{"_id":"1","points":1,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":5},{"_id":"2","points":0,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":9}]}},"members":["Tommy MORIN","Blondeau Alexandre","Desannaux Kylian","Philippe Breton","Hamidou Samy","FLAVIEN DELECLUSE"],"sourceCreatedAt":"2024-06-29T18:13:36.330Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Faucons Noirs',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Montbazon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'faucon-touraine-behourd@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2b92a4_5310e3fb046b446dbafed85ecee4d29e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tommy MORIN','captain','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blondeau Alexandre','fighter','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Desannaux Kylian','fighter','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Philippe Breton','fighter','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hamidou Samy','fighter','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'FLAVIEN DELECLUSE','fighter','bi_teams','https://www.buhurtinternational.com/team/faucons-noirs','faucons-noirs',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ferox' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ferox' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ferox','Mühlhausen/Thüringen',true,'active','public','bi-ferox','EU','Europe','DE','Germany','info@swaiut-toringi.de','https://www.facebook.com/profile.php?id=100063792661005','https://static.wixstatic.com/media/59fd9b_a5e2cc8ef6714506bef55bb7005f1f8e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ferox','https://www.buhurtinternational.com/team/ferox','Ferox','Mühlhausen/Thüringen','info@swaiut-toringi.de','https://www.facebook.com/profile.php?id=100063792661005',20,'{"biCollectionId":"b6d19149-4271-4526-b33c-14bdedd47abe","teamName":"Ferox","club":"Swaiut Toringi e.V.","gender":"Male","captain":"Roland Göbel","conference":"Europe","country":"Germany","city":"Mühlhausen/Thüringen","teamInfo":"","trainingInfo":"","trainingLocation":{"city":"Mühlhausen/Thüringen","location":{"latitude":51.2156883,"longitude":10.4846397},"streetAddress":{"apt":"","formattedAddressLine":"Sondershäuser Landstraße 29B","name":"Sondershäuser Landstraße","number":"29B"},"formatted":"Sondershäuser Landstraße 29B, 99974 Mühlhausen/Thüringen, Germany","country":"DE","postalCode":"99974","subdivision":"TH"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100063792661005","teamEmail":"info@swaiut-toringi.de","teamLogo":"wix:image://v1/59fd9b_a5e2cc8ef6714506bef55bb7005f1f8e~mv2.png/Wappen%20mit%20Banner%20klein.png#originWidth=591&originHeight=591","logoUrl":"https://static.wixstatic.com/media/59fd9b_a5e2cc8ef6714506bef55bb7005f1f8e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":16}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":3},{"_id":"2","points":6,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":8}]}},"members":["Roland Göbel","Erik Aschenbach","Malte Janßen","Andreas Blechner","Morris Schäffner","Nick Steinbrück","Niklas Lipphardt","Kai Knobelsdorff","Thomas Holtmann","Christian Kilp"],"sourceCreatedAt":"2023-08-09T14:04:25.083Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ferox',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mühlhausen/Thüringen',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@swaiut-toringi.de'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100063792661005'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/59fd9b_a5e2cc8ef6714506bef55bb7005f1f8e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roland Göbel','captain','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erik Aschenbach','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Malte Janßen','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas Blechner','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Morris Schäffner','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nick Steinbrück','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niklas Lipphardt','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kai Knobelsdorff','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Holtmann','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christian Kilp','fighter','bi_teams','https://www.buhurtinternational.com/team/ferox','ferox',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ferreus-lupus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ferreus-lupus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ferreus Lupus','Budapest',true,'active','public','bi-ferreus-lupus','EU','Europe','HU','Hungary','ujvariadam91@gmail.com','https://www.facebook.com/FerreusLupus','https://static.wixstatic.com/media/8d17af_af9b95aa4e194e79b8b196f26639e60b~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ferreus-lupus','https://www.buhurtinternational.com/team/ferreus-lupus','Ferreus Lupus','Budapest','ujvariadam91@gmail.com','https://www.facebook.com/FerreusLupus',20,'{"biCollectionId":"4c047745-42ba-45ac-a4c0-edfe440d2320","teamName":"Ferreus Lupus","club":null,"gender":"Male","captain":"Ujvári Ádám","conference":"Europe","country":"Hungary","city":"Budapest","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/FerreusLupus","teamEmail":"ujvariadam91@gmail.com","teamLogo":"wix:image://v1/8d17af_af9b95aa4e194e79b8b196f26639e60b~mv2.jpg/309577408_546479130615960_820901051612861951_n.jpg#originWidth=1058&originHeight=1052","logoUrl":"https://static.wixstatic.com/media/8d17af_af9b95aa4e194e79b8b196f26639e60b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":15,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":7,"Tournament":"Valley of Warriors Buhurt Tournament 2026","date":"2026-06-06","category":"5vs5","place":2},{"_id":"2","points":8,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0.5,"Tournament":"Valley of Warriors Buhurt Tournament 2024","date":"2024-06-15","category":"3vs3","place":6},{"_id":"2","points":8,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":18,"remainingTokens":10,"tournaments":[{"_id":"1","points":9,"Tournament":"Valley of Warriors Buhurt Tournament 2025","date":"2025-06-07","category":"5vs5","place":1},{"_id":"2","points":9,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":2}]}},"members":["Ujvári Ádám","Istvan Marosi","Baranyi Martin","Dmitry Golivets","Dmitry Zarutsky","Denys Bidukha","Adam Banyai","Kristóf Lengyel","Aron Zsolt Kristóf","Zoltán Ábrahám","Gergely Tompits","Benjamin Bus","Kristóf Imre"],"sourceCreatedAt":"2024-06-14T18:25:41.430Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ferreus Lupus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Budapest',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('HU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Hungary',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ujvariadam91@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/FerreusLupus'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8d17af_af9b95aa4e194e79b8b196f26639e60b~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ujvári Ádám','captain','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Istvan Marosi','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Baranyi Martin','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dmitry Golivets','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dmitry Zarutsky','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Denys Bidukha','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Banyai','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kristóf Lengyel','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aron Zsolt Kristóf','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zoltán Ábrahám','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gergely Tompits','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Bus','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kristóf Imre','fighter','bi_teams','https://www.buhurtinternational.com/team/ferreus-lupus','ferreus-lupus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='firestone-phoenixes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-firestone-phoenixes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Firestone Phoenixes',NULL,true,'active','public','bi-firestone-phoenixes','NA','North America','US','United States','firestonephoenixes@gmail.com','https://www.facebook.com/profile.php?id=61577047925573','https://static.wixstatic.com/media/68c055_904b573926e04d00b2f31633799adf91~mv2.jpg','We are a femme team based out of Northeast Ohio!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','firestone-phoenixes','https://www.buhurtinternational.com/team/firestone-phoenixes','Firestone Phoenixes',NULL,'firestonephoenixes@gmail.com','https://www.facebook.com/profile.php?id=61577047925573',20,'{"biCollectionId":"ad2c73f3-81ae-45b0-8adf-843050af550d","teamName":"Firestone Phoenixes","club":null,"gender":"Female","captain":"Kira Dawes","conference":"North America","country":"United States","city":null,"teamInfo":"We are a femme team based out of Northeast Ohio!","trainingInfo":"We have team practices on Mondays and then the club we train with has full practice on Tuesdays and Thursdays in Akron, OH. Check us out on Facebook or our website for practice schedules and updates, all skill levels welcome!","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61577047925573","teamEmail":"firestonephoenixes@gmail.com","teamLogo":"wix:image://v1/68c055_904b573926e04d00b2f31633799adf91~mv2.jpg/Phoenix%20logo.jpg#originWidth=438&originHeight=438","logoUrl":"https://static.wixstatic.com/media/68c055_904b573926e04d00b2f31633799adf91~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"3vs3","place":3}],"eventsHistory":{},"members":["Brooke Lyons","Chelsea R Brandt","Jessica Pantoja","Courtney Prillaman","Kira Dawes"],"sourceCreatedAt":"2026-04-07T21:29:00.677Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Firestone Phoenixes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'firestonephoenixes@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61577047925573'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/68c055_904b573926e04d00b2f31633799adf91~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a femme team based out of Northeast Ohio!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brooke Lyons','fighter','bi_teams','https://www.buhurtinternational.com/team/firestone-phoenixes','firestone-phoenixes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chelsea R Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/firestone-phoenixes','firestone-phoenixes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jessica Pantoja','fighter','bi_teams','https://www.buhurtinternational.com/team/firestone-phoenixes','firestone-phoenixes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Courtney Prillaman','fighter','bi_teams','https://www.buhurtinternational.com/team/firestone-phoenixes','firestone-phoenixes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kira Dawes','captain','bi_teams','https://www.buhurtinternational.com/team/firestone-phoenixes','firestone-phoenixes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='florida-men' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-florida-men' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Florida Men','Florida',true,'active','public','bi-florida-men','NA','North America','US','United States','stephengallagan@gmail.com',NULL,'https://static.wixstatic.com/media/924c2b_120509e6339d487381da65bb71acf0c4~mv2.png','The Florida Men is a joint effort by all the teams in Florida')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','florida-men','https://www.buhurtinternational.com/team/florida-men','Florida Men','Florida','stephengallagan@gmail.com',NULL,20,'{"biCollectionId":"d298f864-7132-48c0-aa35-99333bc0e50d","teamName":"Florida Men","club":"Florida Men","gender":"Male","captain":"Stephen Gallagan","conference":"North America","country":"United States","city":"Florida","teamInfo":"The Florida Men is a joint effort by all the teams in Florida","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"stephengallagan@gmail.com","teamLogo":"wix:image://v1/924c2b_120509e6339d487381da65bb71acf0c4~mv2.png/FLorida%20Men%20logo%20shield.png#originWidth=3000&originHeight=3500","logoUrl":"https://static.wixstatic.com/media/924c2b_120509e6339d487381da65bb71acf0c4~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":12}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":14}]},"2025":{"points12v12":0,"points5v5":4,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":13}]}},"members":["Derrick Flitcroft","Stephen Gallagan","Colin Kendall Brady","Jason Poyen","Kenneth R Thompson Jr","Vincent Calianno","Shaun Marshall","Scott Rabinowitz","Steven Maximillian Griffin","James William Armstrong Jr","David kempton"],"sourceCreatedAt":"2024-07-01T22:55:37.026Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Florida Men',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Florida',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'stephengallagan@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/924c2b_120509e6339d487381da65bb71acf0c4~mv2.png'),
 public_description=coalesce(t.public_description,'The Florida Men is a joint effort by all the teams in Florida'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derrick Flitcroft','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephen Gallagan','captain','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colin Kendall Brady','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Poyen','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kenneth R Thompson Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Calianno','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shaun Marshall','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott Rabinowitz','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Maximillian Griffin','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James William Armstrong Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David kempton','fighter','bi_teams','https://www.buhurtinternational.com/team/florida-men','florida-men',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='fragarach-amoured-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-fragarach-amoured-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Fragarach Amoured Combat','Dublin ',true,'active','public','bi-fragarach-amoured-combat','EU','Europe','IE','Ireland','fragaracharmouredcombat@gmail.com','https://www.facebook.com/profile.php?id=100083444102679','https://static.wixstatic.com/media/2a8f8a_35258295577f4ab79512335221f22c0b~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','fragarach-amoured-combat','https://www.buhurtinternational.com/team/fragarach-amoured-combat','Fragarach Amoured Combat','Dublin ','fragaracharmouredcombat@gmail.com','https://www.facebook.com/profile.php?id=100083444102679',20,'{"biCollectionId":"b7ca4ecb-dc9c-4515-9291-c0e7cd070677","teamName":"Fragarach Amoured Combat","club":"Fragarach Armoured Combat","gender":"Male","captain":"Petr Schukin","conference":"Europe","country":"Ireland","city":"Dublin ","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"D","name":"County Dublin","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"IE","name":"Ireland","type":"COUNTRY"}],"city":"Stoneybatter","location":{"latitude":53.3532231,"longitude":-6.28878},"streetAddress":{"apt":"","formattedAddressLine":"45a Ben Edair Rd","name":"Ben Edair Road","number":"45a"},"formatted":"45a Ben Edair Rd, Stoneybatter, Dublin 7, D07 YE30, Ireland","country":"IE","postalCode":"D07 YE30"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100083444102679","teamEmail":"fragaracharmouredcombat@gmail.com","teamLogo":"wix:image://v1/2a8f8a_35258295577f4ab79512335221f22c0b~mv2.jpg/Fragarach%20Logo.jpg#originWidth=96&originHeight=96","logoUrl":"https://static.wixstatic.com/media/2a8f8a_35258295577f4ab79512335221f22c0b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":12}]}},"members":["Petr Schukin","Petr Shchukin","Dylan Nolan","Patrick Moore","Thomas Leigh","David Maher","Jack O''Leary","Josh Gaynor"],"sourceCreatedAt":"2024-01-08T18:22:30.297Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Fragarach Amoured Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dublin ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Ireland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'fragaracharmouredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100083444102679'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2a8f8a_35258295577f4ab79512335221f22c0b~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petr Schukin','captain','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petr Shchukin','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Nolan','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patrick Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Leigh','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Maher','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack O''Leary','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Gaynor','fighter','bi_teams','https://www.buhurtinternational.com/team/fragarach-amoured-combat','fragarach-amoured-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='free-fighters' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-free-fighters' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Free Fighters','İstanbul',true,'active','public','bi-free-fighters','AS','Asia','TR','Turkey','burakmono@gmail.com','https://www.facebook.com/profile.php?id=100083200431923','https://static.wixstatic.com/media/61d527_d607dc8dc06f4622894210b5fc5d461b~mv2.png','The only Buhurt team in Turkey, active since 2016. Participated in 2 BotN&#x27;s as the National Team and 150 vs 150.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','free-fighters','https://www.buhurtinternational.com/team/free-fighters','Free Fighters','İstanbul','burakmono@gmail.com','https://www.facebook.com/profile.php?id=100083200431923',20,'{"biCollectionId":"fbdc8859-7dfc-4061-bbb0-ba3773c32228","teamName":"Free Fighters","club":"Free Fighters Guild","gender":"Male","captain":"Burak Yarar","conference":"Europe","country":"Turkey","city":"İstanbul","teamInfo":"The only Buhurt team in Turkey, active since 2016. Participated in 2 BotN&#x27;s as the National Team and 150 vs 150.","trainingInfo":"","trainingLocation":{"formatted":"Rıhtım Caddesi Iskele Sokak no 50 daire 1 Kadıkoy İstanbul"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100083200431923","teamEmail":"burakmono@gmail.com","teamLogo":"wix:image://v1/61d527_d607dc8dc06f4622894210b5fc5d461b~mv2.png/IMG-4814.PNG#originWidth=1479&originHeight=3578","logoUrl":"https://static.wixstatic.com/media/61d527_d607dc8dc06f4622894210b5fc5d461b~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Burak Yarar","Gökhan Seçkin","Emre Tunca","Aleksandr","Ateş Erdoğan","Kaan Ünal","Orkan Berkay Özen","EVGENII ASTAFEV"],"sourceCreatedAt":"2023-07-23T16:47:40.653Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Free Fighters',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('İstanbul',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('AS',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Asia',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('TR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Turkey',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'burakmono@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100083200431923'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/61d527_d607dc8dc06f4622894210b5fc5d461b~mv2.png'),
 public_description=coalesce(t.public_description,'The only Buhurt team in Turkey, active since 2016. Participated in 2 BotN&#x27;s as the National Team and 150 vs 150.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Burak Yarar','captain','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gökhan Seçkin','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emre Tunca','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksandr','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ateş Erdoğan','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kaan Ünal','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orkan Berkay Özen','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'EVGENII ASTAFEV','fighter','bi_teams','https://www.buhurtinternational.com/team/free-fighters','free-fighters',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='glasgow-sword-breakers-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-glasgow-sword-breakers-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Glasgow Sword Breakers','Glasgow ',true,'active','public','bi-glasgow-sword-breakers-','EU','Europe','GB','United Kingdom','glasgowswordbreakers@gmail.com','https://www.facebook.com/share/1A81Hbuc86/','https://static.wixstatic.com/media/798857_6b6205ffe1084ea39505fde05b5272ff~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','glasgow-sword-breakers-','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','Glasgow Sword Breakers','Glasgow ','glasgowswordbreakers@gmail.com','https://www.facebook.com/share/1A81Hbuc86/',20,'{"biCollectionId":"b061285e-b9a5-42f8-8ba5-c7d543e3ab77","teamName":"Glasgow Sword Breakers","club":null,"gender":"Male","captain":"Rory McDowell ","conference":"Europe","country":"United Kingdom","city":"Glasgow ","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"The Griphouse, 10 Possil Rd, Glasgow G4 9SY, UK"},"websiteFacebookUrl":"https://www.facebook.com/share/1A81Hbuc86/","teamEmail":"glasgowswordbreakers@gmail.com","teamLogo":"wix:image://v1/798857_6b6205ffe1084ea39505fde05b5272ff~mv2.jpeg/Messenger_creation_0c4db1ca-038a-4ad9-a72d-acb1773d14c0.jpeg#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/798857_6b6205ffe1084ea39505fde05b5272ff~mv2.jpeg","rank5v5":6,"averagePoints5v5":4.5,"points5v5":13.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":5},{"_id":"2","points":7.5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":3},{"_id":"3","points":0,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":11},{"_id":"4","points":2,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":6}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":9},{"_id":"2","points":0,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":14},{"_id":"3","points":3,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":9}],"points12v12":0,"averagePoints5v5":1.67,"rank5v5":13,"remainingTokens":10,"points5v5":5}},"members":["Stewart Airey","Rory McDowell","Colin Jarvis","Harry Grisdale","Dan Wright","Gordon Dale","Craig Easton","Andrew Bogle","Vyom Gera","Scott Airey"],"sourceCreatedAt":"2025-03-14T17:33:35.567Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Glasgow Sword Breakers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Glasgow ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'glasgowswordbreakers@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1A81Hbuc86/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/798857_6b6205ffe1084ea39505fde05b5272ff~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stewart Airey','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rory McDowell','captain','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colin Jarvis','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Harry Grisdale','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dan Wright','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gordon Dale','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Craig Easton','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Bogle','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vyom Gera','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott Airey','fighter','bi_teams','https://www.buhurtinternational.com/team/glasgow-sword-breakers-','glasgow-sword-breakers-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='graoully' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-graoully' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Graoully','METZ',true,'active','public','bi-graoully','EU','Europe','FR','France','metzbehourd57@gmail.com','https://www.facebook.com/MetzBehourdGraoully','https://static.wixstatic.com/media/893ef8_c0d00e97868d48649c89c3458b2954b5~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','graoully','https://www.buhurtinternational.com/team/graoully','Graoully','METZ','metzbehourd57@gmail.com','https://www.facebook.com/MetzBehourdGraoully',20,'{"biCollectionId":"e65b991d-a2c0-43ff-80c8-598dbf9c3e51","teamName":"Graoully","club":"METZ Béhourd","gender":"Male","captain":"LOYS Adam","conference":"Europe","country":"France","city":"METZ","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Grand Est","name":"Grand Est","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Moselle","name":"Moselle","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Marly","name":"Marly","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Marly","location":{"latitude":49.06472,"longitude":6.1483591},"streetAddress":{"apt":"","formattedAddressLine":"Marly","name":"","number":""},"formatted":"57155 Marly, France","country":"FR","postalCode":"57155","subdivision":"HDF"},"websiteFacebookUrl":"https://www.facebook.com/MetzBehourdGraoully","teamEmail":"metzbehourd57@gmail.com","teamLogo":"wix:image://v1/893ef8_c0d00e97868d48649c89c3458b2954b5~mv2.jpeg/Messenger_creation_72eb2c31-418e-4449-b880-e7ec68cfaa95.jpeg#originWidth=1962&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/893ef8_c0d00e97868d48649c89c3458b2954b5~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":23,"remainingTokens":10,"tournaments":[{"_id":"1","points":10,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":2},{"_id":"2","points":13,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":1}]}},"members":["LOYS Adam","PEIFFERT François-Xavier","Iallonardo Vincent","Florian Potaufeux","Noah Drouhin","Hector Saint-Palais","Thomas BAILLARD--HAMILA","Fischer Esteban","Renaud MARTIN","FISCHER Nicolas","Fages Dorian","Luc Rebaudengo"],"sourceCreatedAt":"2023-09-03T11:38:07.725Z","sourceUpdatedAt":"2026-09-29T05:17:35.064Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Graoully',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('METZ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'metzbehourd57@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MetzBehourdGraoully'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/893ef8_c0d00e97868d48649c89c3458b2954b5~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LOYS Adam','captain','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PEIFFERT François-Xavier','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iallonardo Vincent','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Florian Potaufeux','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noah Drouhin','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hector Saint-Palais','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas BAILLARD--HAMILA','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fischer Esteban','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Renaud MARTIN','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'FISCHER Nicolas','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fages Dorian','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luc Rebaudengo','fighter','bi_teams','https://www.buhurtinternational.com/team/graoully','graoully',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='green-bastards' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-green-bastards' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Green Bastards','Ghent',true,'active','public','bi-green-bastards','EU','Europe','BE','Belgium','pascal.buyse@gmail.com',NULL,'https://static.wixstatic.com/media/ae4673_3c7944adfa6140bc982a5d38232409e3~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','green-bastards','https://www.buhurtinternational.com/team/green-bastards','Green Bastards','Ghent','pascal.buyse@gmail.com',NULL,20,'{"biCollectionId":"ea8e8418-ed62-4a24-9700-992ef2de0f57","teamName":"Green Bastards","club":null,"gender":"Male","captain":"Andreas De Coninck","conference":"Europe","country":"Belgium","city":"Ghent","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"pascal.buyse@gmail.com","teamLogo":"wix:image://v1/ae4673_3c7944adfa6140bc982a5d38232409e3~mv2.png/schildhalf.png#originWidth=1516&originHeight=1785","logoUrl":"https://static.wixstatic.com/media/ae4673_3c7944adfa6140bc982a5d38232409e3~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":4,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Jan van Brabant 2026","date":"2026-05-16","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":6,"tournaments":[{"_id":"1","points":1,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":6}]}},"members":["Pascal Buyse","Arno De Thaey","Indy Waelbroeck","Andreas De Coninck","Viktor hombeck","Jahdai Seelt","Seppe Jamaer","Quentin Radermacher","Armin Osmanovic"],"sourceCreatedAt":"2025-02-16T11:38:48.717Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Green Bastards',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ghent',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Belgium',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'pascal.buyse@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ae4673_3c7944adfa6140bc982a5d38232409e3~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pascal Buyse','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arno De Thaey','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Indy Waelbroeck','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas De Coninck','captain','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Viktor hombeck','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jahdai Seelt','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Seppe Jamaer','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quentin Radermacher','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Armin Osmanovic','fighter','bi_teams','https://www.buhurtinternational.com/team/green-bastards','green-bastards',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='grifas-valherjes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-grifas-valherjes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Grifas Valherjes','Capital Federal',true,'active','public','bi-grifas-valherjes','SA','South America','AR','Argentina','rominagolluscio@gmail.com','https://www.facebook.com/ValherjesHMB/?locale=es_LA','https://static.wixstatic.com/media/74a5f2_071cd92571e04af197cdb9ab33a87149~mv2.png','Somos un grupo de chicas que amamos este deporte y dejamos todo !!!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','grifas-valherjes','https://www.buhurtinternational.com/team/grifas-valherjes','Grifas Valherjes','Capital Federal','rominagolluscio@gmail.com','https://www.facebook.com/ValherjesHMB/?locale=es_LA',20,'{"biCollectionId":"335de295-09f1-4020-85cd-2fdccfcba048","teamName":"Grifas Valherjes","club":null,"gender":"Female","captain":"Romina Estefanía Golluscio","conference":"South America","country":"Argentina","city":"Capital Federal","teamInfo":"Somos un grupo de chicas que amamos este deporte y dejamos todo !!!","trainingInfo":"Nos encanta intercambiar enseñanzas con diferentes clubes!!! Siempre estamos dispuestas a recibir personas nuevas!!!","trainingLocation":{"city":"Buenos Aires","location":{"latitude":-34.6316055,"longitude":-58.3997262},"streetAddress":{"apt":"","formattedAddressLine":"Av. Brasil 2548","name":"Avenida Brasil","number":"2548"},"formatted":"Av. Brasil 2548, C1260AAU CABA, Argentina","country":"AR","postalCode":"C1260-AAU"},"websiteFacebookUrl":"https://www.facebook.com/ValherjesHMB/?locale=es_LA","teamEmail":"rominagolluscio@gmail.com","teamLogo":"wix:image://v1/74a5f2_071cd92571e04af197cdb9ab33a87149~mv2.png/escudo_valherjes.png#originWidth=683&originHeight=960","logoUrl":"https://static.wixstatic.com/media/74a5f2_071cd92571e04af197cdb9ab33a87149~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Sabrina Noelia Piuma","Romina Estefanía Golluscio","Leila Sofia Gálvez Aidar","Ana Carina Taborda","Sofía Reifschneider","Silvina Gisele Mangone","Emmanuelle Pellisa","Daiana Maria Heisele"],"sourceCreatedAt":"2023-09-05T21:54:05.987Z","sourceUpdatedAt":"2026-09-24T18:21:42.905Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Grifas Valherjes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Capital Federal',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'rominagolluscio@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ValherjesHMB/?locale=es_LA'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/74a5f2_071cd92571e04af197cdb9ab33a87149~mv2.png'),
 public_description=coalesce(t.public_description,'Somos un grupo de chicas que amamos este deporte y dejamos todo !!!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sabrina Noelia Piuma','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Romina Estefanía Golluscio','captain','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leila Sofia Gálvez Aidar','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ana Carina Taborda','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sofía Reifschneider','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silvina Gisele Mangone','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emmanuelle Pellisa','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daiana Maria Heisele','fighter','bi_teams','https://www.buhurtinternational.com/team/grifas-valherjes','grifas-valherjes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='grimaldi-milites' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-grimaldi-milites' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Grimaldi Milites','Monaco',true,'active','public','bi-grimaldi-milites','EU','Europe',NULL,'Monaco','grimaldimilites@gmail.com','https://www.facebook.com/profile.php?id=100057546874391','https://static.wixstatic.com/media/24a46a_8dde799aa2064e60902b45a8467aea6e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','grimaldi-milites','https://www.buhurtinternational.com/team/grimaldi-milites','Grimaldi Milites','Monaco','grimaldimilites@gmail.com','https://www.facebook.com/profile.php?id=100057546874391',20,'{"biCollectionId":"408a8f20-873e-45c3-b32d-c317ecd5ed84","teamName":"Grimaldi Milites","club":null,"gender":"Male","captain":"Pierre Casiraghi","conference":"Europe","country":"Monaco","city":"Monaco","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100057546874391","teamEmail":"grimaldimilites@gmail.com","teamLogo":"wix:image://v1/24a46a_8dde799aa2064e60902b45a8467aea6e~mv2.png/Logo%20Grimaldi%20Milites%202020.png#originWidth=3600&originHeight=3600","logoUrl":"https://static.wixstatic.com/media/24a46a_8dde799aa2064e60902b45a8467aea6e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Pierre Casiraghi","Antoine LUTZ","Loïc PILLON","Emilien BONNABEL","Philippe REBAUDENGO","Uatini Jean Yves","Tolstopyatenko","Cédric PILLON","FIGLIUZZI Romain","Giancarlo Bizzio","Thomas Darvaux","Brillat Christophe","Audiffren Vincent","Beulaguet vincent","Maxence VALLAT","Stephane Brianti"],"sourceCreatedAt":"2023-08-31T07:47:01.459Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Grimaldi Milites',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Monaco',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce(NULL,t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Monaco',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'grimaldimilites@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100057546874391'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/24a46a_8dde799aa2064e60902b45a8467aea6e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pierre Casiraghi','captain','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antoine LUTZ','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Loïc PILLON','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emilien BONNABEL','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Philippe REBAUDENGO','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Uatini Jean Yves','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tolstopyatenko','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cédric PILLON','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'FIGLIUZZI Romain','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Giancarlo Bizzio','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Darvaux','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brillat Christophe','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Audiffren Vincent','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Beulaguet vincent','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxence VALLAT','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephane Brianti','fighter','bi_teams','https://www.buhurtinternational.com/team/grimaldi-milites','grimaldi-milites',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='guarda-de-são-jorge' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-guarda-de-são-jorge' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Guarda de São Jorge','São Paulo',true,'active','public','bi-guarda-de-são-jorge','SA','South America','BR','Brazil','mundomedievaloficial@gmail.com',NULL,'https://static.wixstatic.com/media/57b909_f13ce7ba4ea94f0db3c001775ab683ca~mv2.png','Equipe criada em 2024, parte do clube Dragões da Independência LEMA: "caritas perpetua, infinito animo" Gritos de guerra: "Aqui é Leste!!!"')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','guarda-de-são-jorge','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','Guarda de São Jorge','São Paulo','mundomedievaloficial@gmail.com',NULL,20,'{"biCollectionId":"b1b1d0cf-2310-4527-bcea-c86019a5aaf8","teamName":"Guarda de São Jorge","club":null,"gender":"Male","captain":"Monalisa Lobo","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"Equipe criada em 2024, parte do clube Dragões da Independência LEMA: \"caritas perpetua, infinito animo\" Gritos de guerra: \"Aqui é Leste!!!\"","trainingInfo":"Treine gratuitamente conosco!","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"mundomedievaloficial@gmail.com","teamLogo":"wix:image://v1/57b909_f13ce7ba4ea94f0db3c001775ab683ca~mv2.png/Guarda%20de%20S%C3%A3o%20Jorge.png#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/57b909_f13ce7ba4ea94f0db3c001775ab683ca~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":8}},"members":["Monalisa Lobo","Fabiano Gabriel Fernandes Bento","Gustavo \"Muralha\"","Guilherme Pereira Barbosa","Leonardo Morelli de Paula Santos","William \"O Gago\"","Matheus Bessa Borges","Daniel Ichiro Chiba Abdala"],"sourceCreatedAt":"2025-03-05T18:32:40.342Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Guarda de São Jorge',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mundomedievaloficial@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/57b909_f13ce7ba4ea94f0db3c001775ab683ca~mv2.png'),
 public_description=coalesce(t.public_description,'Equipe criada em 2024, parte do clube Dragões da Independência LEMA: "caritas perpetua, infinito animo" Gritos de guerra: "Aqui é Leste!!!"'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Monalisa Lobo','captain','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabiano Gabriel Fernandes Bento','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gustavo "Muralha"','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guilherme Pereira Barbosa','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Morelli de Paula Santos','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William "O Gago"','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matheus Bessa Borges','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Ichiro Chiba Abdala','fighter','bi_teams','https://www.buhurtinternational.com/team/guarda-de-s%C3%A3o-jorge','guarda-de-são-jorge',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='guàrdia-del-mar' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-guàrdia-del-mar' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'GUÀRDIA DEL MAR','PALMA',true,'active','public','bi-guàrdia-del-mar','EU','Europe','ES','Spain','buhurtguardiadelmarmallorca@gmail.com','https://www.facebook.com/guardiadelmarlcm','https://static.wixstatic.com/media/96d6c9_7c2c65bef6f7406cacf50a7d35975e15~mv2.jpeg','BORN IN MALLORCA IN 2013, WE HAD A TIME OF INACTIVITY. BUT NOW WE HAVE A REBIRTH AND CONTINUE WORKING TO TAKE THE SPORT TO OUR HOME.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','guàrdia-del-mar','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','GUÀRDIA DEL MAR','PALMA','buhurtguardiadelmarmallorca@gmail.com','https://www.facebook.com/guardiadelmarlcm',20,'{"biCollectionId":"2e38eb0d-911b-40b2-a115-a107e224d760","teamName":"GUÀRDIA DEL MAR","club":null,"gender":"Male","captain":"MARTÌ ARBONA","conference":"Europe","country":"Spain","city":"PALMA","teamInfo":"BORN IN MALLORCA IN 2013, WE HAD A TIME OF INACTIVITY. BUT NOW WE HAVE A REBIRTH AND CONTINUE WORKING TO TAKE THE SPORT TO OUR HOME.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/guardiadelmarlcm","teamEmail":"buhurtguardiadelmarmallorca@gmail.com","teamLogo":"wix:image://v1/96d6c9_7c2c65bef6f7406cacf50a7d35975e15~mv2.jpeg/WhatsApp%20Image%202023-04-22%20at%2021.06.40.jpeg#originWidth=696&originHeight=645","logoUrl":"https://static.wixstatic.com/media/96d6c9_7c2c65bef6f7406cacf50a7d35975e15~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["MARTÌ ARBONA","Jaume Servera Catell","Jaume Pere Arbona Sampol","Daniel López Forteza","Daniel Marquez Morgado"],"sourceCreatedAt":"2023-09-28T20:32:40.138Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('GUÀRDIA DEL MAR',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('PALMA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'buhurtguardiadelmarmallorca@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/guardiadelmarlcm'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/96d6c9_7c2c65bef6f7406cacf50a7d35975e15~mv2.jpeg'),
 public_description=coalesce(t.public_description,'BORN IN MALLORCA IN 2013, WE HAD A TIME OF INACTIVITY. BUT NOW WE HAVE A REBIRTH AND CONTINUE WORKING TO TAKE THE SPORT TO OUR HOME.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MARTÌ ARBONA','captain','bi_teams','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','guàrdia-del-mar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaume Servera Catell','fighter','bi_teams','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','guàrdia-del-mar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaume Pere Arbona Sampol','fighter','bi_teams','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','guàrdia-del-mar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel López Forteza','fighter','bi_teams','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','guàrdia-del-mar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Marquez Morgado','fighter','bi_teams','https://www.buhurtinternational.com/team/gu%C3%A0rdia-del-mar','guàrdia-del-mar',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='half-ton' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-half-ton' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Half-Ton','Shanghai',true,'active','public','bi-half-ton','AS','Asia Pacific',NULL,'China','bigcatpeng@qq.com','https://www.facebook.com/TeamHalfTon','https://static.wixstatic.com/media/5fcd6b_a3adc7fffbd94b0abbb25a95ea34fd1f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','half-ton','https://www.buhurtinternational.com/team/half-ton','Half-Ton','Shanghai','bigcatpeng@qq.com','https://www.facebook.com/TeamHalfTon',20,'{"biCollectionId":"d1aea38b-6aa7-496c-8bd7-6a082e18491b","teamName":"Half-Ton","club":null,"gender":"Male","captain":"Gao Peng","conference":"APAC","country":"China","city":"Shanghai","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"Tongxiang, Jiaxing, Zhejiang, China"},"websiteFacebookUrl":"https://www.facebook.com/TeamHalfTon","teamEmail":"bigcatpeng@qq.com","teamLogo":"wix:image://v1/5fcd6b_a3adc7fffbd94b0abbb25a95ea34fd1f~mv2.png/%E5%8D%8A%E5%90%A8%E9%98%9F%E6%95%B4%E5%90%88%E7%89%88%E7%BA%B9%E7%AB%A02026%E4%B8%8A%E8%89%B2%E4%BC%98%E5%8C%96-PNG%E6%8A%A0%E5%9B%BE%E7%89%88.png#originWidth=2880&originHeight=2880","logoUrl":"https://static.wixstatic.com/media/5fcd6b_a3adc7fffbd94b0abbb25a95ea34fd1f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Gao Peng","Guoji Xu","Fenghao Jin","Yicheng Zhang","Pengcheng Zhong","Ben Zheng","Di  Miao","Yi Zou"],"sourceCreatedAt":"2024-01-24T03:44:32.508Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Half-Ton',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Shanghai',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('AS',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Asia Pacific',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce(NULL,t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('China',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bigcatpeng@qq.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TeamHalfTon'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5fcd6b_a3adc7fffbd94b0abbb25a95ea34fd1f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gao Peng','captain','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guoji Xu','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fenghao Jin','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yicheng Zhang','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pengcheng Zhong','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Zheng','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Di  Miao','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yi Zou','fighter','bi_teams','https://www.buhurtinternational.com/team/half-ton','half-ton',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='harpias-combate-medieval' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-harpias-combate-medieval' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Harpias Combate Medieval','BUENOS AIRES',true,'active','public','bi-harpias-combate-medieval','SA','South America','AR','Argentina','newberycombatemedieval','https://linktr.ee/Newbery_Medieval','https://static.wixstatic.com/media/1d9532_94958cbbafcb4f77b2cf4c9db3b2a984~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','harpias-combate-medieval','https://www.buhurtinternational.com/team/harpias-combate-medieval','Harpias Combate Medieval','BUENOS AIRES','newberycombatemedieval','https://linktr.ee/Newbery_Medieval',20,'{"biCollectionId":"5f3da938-ef4e-409c-b446-e4df5500beed","teamName":"Harpias Combate Medieval","club":"NEWBERY COMBATE MEDIEVAL","gender":"Female","captain":"MARIANO OZÓN","conference":"South America","country":"Argentina","city":"BUENOS AIRES","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://linktr.ee/Newbery_Medieval","teamEmail":"newberycombatemedieval","teamLogo":"wix:image://v1/1d9532_94958cbbafcb4f77b2cf4c9db3b2a984~mv2.jpg/50116073_2567828576565828_8293718273917190144_n.jpg#originWidth=1499&originHeight=1513","logoUrl":"https://static.wixstatic.com/media/1d9532_94958cbbafcb4f77b2cf4c9db3b2a984~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["MARIANO OZÓN","CAROLINA ELÍAS PICABEA","cabral yamila alejandra","Melisa Recalde","Mariel Luna","Griselda Lucía duarte"],"sourceCreatedAt":"2023-08-01T21:53:05.992Z","sourceUpdatedAt":"2026-09-24T18:21:42.905Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Harpias Combate Medieval',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('BUENOS AIRES',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'newberycombatemedieval'),
 website_url=coalesce(t.website_url,'https://linktr.ee/Newbery_Medieval'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/1d9532_94958cbbafcb4f77b2cf4c9db3b2a984~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MARIANO OZÓN','captain','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'CAROLINA ELÍAS PICABEA','fighter','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'cabral yamila alejandra','fighter','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Melisa Recalde','fighter','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariel Luna','fighter','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Griselda Lucía duarte','fighter','bi_teams','https://www.buhurtinternational.com/team/harpias-combate-medieval','harpias-combate-medieval',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='havoc-blood-claws' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-havoc-blood-claws' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Havoc Blood Claws','Western Sydney',true,'active','public','bi-havoc-blood-claws','OC','Oceania','AU','Australia','markchenoweth@live.com','https://www.facebook.com/teamhavocAMC','https://static.wixstatic.com/media/542163_bf66746ed7344cb197e2d3bd68ba6c9b~mv2.jpg','"Cry Havoc and let slip the dogs of war" Team Havoc&#x27;s underdog team.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','havoc-blood-claws','https://www.buhurtinternational.com/team/havoc-blood-claws','Havoc Blood Claws','Western Sydney','markchenoweth@live.com','https://www.facebook.com/teamhavocAMC',20,'{"biCollectionId":"985fb0ba-fad7-4d0a-8847-cbbaa3d2c166","teamName":"Havoc Blood Claws","club":null,"gender":"Male","captain":"David Carroll","conference":"APAC","country":"Australia","city":"Western Sydney","teamInfo":"\"Cry Havoc and let slip the dogs of war\" Team Havoc&#x27;s underdog team.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"NSW","name":"New South Wales","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Camden","name":"Camden Council","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Leppington","name":"Leppington","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Leppington","location":{"latitude":-33.9606874,"longitude":150.8187542},"streetAddress":{"apt":"","formattedAddressLine":"23 Cowpasture Rd","name":"Cowpasture Road","number":"23"},"formatted":"23 Cowpasture Rd, Leppington NSW 2179, Australia","country":"AU","postalCode":"2179","subdivision":"NSW"},"websiteFacebookUrl":"https://www.facebook.com/teamhavocAMC","teamEmail":"markchenoweth@live.com","teamLogo":"wix:image://v1/542163_bf66746ed7344cb197e2d3bd68ba6c9b~mv2.jpg/bloodclaws.jpg#originWidth=5224&originHeight=4960","logoUrl":"https://static.wixstatic.com/media/542163_bf66746ed7344cb197e2d3bd68ba6c9b~mv2.jpg","rank5v5":11,"averagePoints5v5":0.67,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":13},{"_id":"2","points":2,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":7},{"_id":"3","points":0,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":11}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":4.5,"remainingTokens":7,"tournaments":[{"_id":"1","points":0,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":3},{"_id":"2","points":4.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":5}]}},"members":["David Carroll","Ethan Speechley","Ethan Jones","Ali Orfali","Eithan Clifford","Johnson Shu","Abdul Rahman Mourad","Maxamillian Tolputt","Liam marks"],"sourceCreatedAt":"2025-05-05T09:34:47.905Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Havoc Blood Claws',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Western Sydney',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'markchenoweth@live.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/teamhavocAMC'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/542163_bf66746ed7344cb197e2d3bd68ba6c9b~mv2.jpg'),
 public_description=coalesce(t.public_description,'"Cry Havoc and let slip the dogs of war" Team Havoc&#x27;s underdog team.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Carroll','captain','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Speechley','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Jones','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ali Orfali','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eithan Clifford','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johnson Shu','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Abdul Rahman Mourad','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxamillian Tolputt','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam marks','fighter','bi_teams','https://www.buhurtinternational.com/team/havoc-blood-claws','havoc-blood-claws',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hell''s-belles' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hell''s-belles' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Hell''s Belles','Surry',true,'active','public','bi-hell''s-belles','NA','North America','US','United States','spencer.tdow@gmail.com',NULL,'https://static.wixstatic.com/media/f8d554_8db6834cc50c402ead9e1ef24e0142a7~mv2.png','Gals team with the Tidewater Dogs of War, out of Tidewater Virginia.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hell''s-belles','https://www.buhurtinternational.com/team/hell''s-belles','Hell''s Belles','Surry','spencer.tdow@gmail.com',NULL,20,'{"biCollectionId":"2097c0a3-9688-4af4-97d9-535ba503122d","teamName":"Hell''s Belles","club":null,"gender":"Female","captain":"Spencer Siebeck","conference":"North America","country":"United States","city":"Surry","teamInfo":"Gals team with the Tidewater Dogs of War, out of Tidewater Virginia.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"spencer.tdow@gmail.com","teamLogo":"wix:image://v1/f8d554_8db6834cc50c402ead9e1ef24e0142a7~mv2.png/Hell''s%20Belle''s%20Herladry.png#originWidth=1626&originHeight=1756","logoUrl":"https://static.wixstatic.com/media/f8d554_8db6834cc50c402ead9e1ef24e0142a7~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":5,"tournaments":[{"_id":"1","points":2,"Tournament":"War in the North 2025","date":"2025-10-18","category":"5vs5","place":3}]}},"members":["SPENCER SIEBECK"],"sourceCreatedAt":"2025-09-12T18:58:37.894Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Hell''s Belles',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Surry',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'spencer.tdow@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f8d554_8db6834cc50c402ead9e1ef24e0142a7~mv2.png'),
 public_description=coalesce(t.public_description,'Gals team with the Tidewater Dogs of War, out of Tidewater Virginia.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'SPENCER SIEBECK','captain','bi_teams','https://www.buhurtinternational.com/team/hell''s-belles','hell''s-belles',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hellhounds' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hellhounds' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Hellhounds','Adelaide',true,'active','public','bi-hellhounds','OC','Oceania','AU','Australia','warhoundsac@gmail.com',NULL,'https://static.wixstatic.com/media/262004_28c8195ba21747aba5923a57f4a14f73~mv2.png','We are the Femme team of Warhounds AC from Adelaide, South Australia!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hellhounds','https://www.buhurtinternational.com/team/hellhounds','Hellhounds','Adelaide','warhoundsac@gmail.com',NULL,20,'{"biCollectionId":"083a159c-4130-4605-808c-a338d9d3ca20","teamName":"Hellhounds","club":null,"gender":"Female","captain":"Alex Dickerson","conference":"APAC","country":"Australia","city":"Adelaide","teamInfo":"We are the Femme team of Warhounds AC from Adelaide, South Australia!","trainingInfo":"If you want to join our Femmes Team, contact the Warhounds Facebook, Instagram, or even the Hellhounds Instagram!","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"warhoundsac@gmail.com","teamLogo":"wix:image://v1/262004_28c8195ba21747aba5923a57f4a14f73~mv2.png/Hellhounds%20w-BG%20ver1~2.PNG#originWidth=2876&originHeight=2878","logoUrl":"https://static.wixstatic.com/media/262004_28c8195ba21747aba5923a57f4a14f73~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"Tournament":"Legends of Steel 2026","_id":"1","category":"3vs3","date":"2026-05-23"}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Clarissa Kent","Charlotte Chamberlain","Emma-Kate","Alex Dickerson"],"sourceCreatedAt":"2025-01-16T03:05:30.927Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Hellhounds',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Adelaide',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'warhoundsac@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/262004_28c8195ba21747aba5923a57f4a14f73~mv2.png'),
 public_description=coalesce(t.public_description,'We are the Femme team of Warhounds AC from Adelaide, South Australia!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Clarissa Kent','fighter','bi_teams','https://www.buhurtinternational.com/team/hellhounds','hellhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charlotte Chamberlain','fighter','bi_teams','https://www.buhurtinternational.com/team/hellhounds','hellhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emma-Kate','fighter','bi_teams','https://www.buhurtinternational.com/team/hellhounds','hellhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Dickerson','captain','bi_teams','https://www.buhurtinternational.com/team/hellhounds','hellhounds',now());
end $$;
commit;
