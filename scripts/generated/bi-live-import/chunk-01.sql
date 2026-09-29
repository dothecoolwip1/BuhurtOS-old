begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='(a)''wesome-(o)''possums' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-(a)''wesome-(o)''possums' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Awesome Possums','Columbia',true,'active','public','bi-(a)''wesome-(o)''possums','NA','North America','US','United States','palmettoknights@gmail.com','https://linktr.ee/palmettoknights','https://static.wixstatic.com/media/7b5505_b018c05010724614b417c9b8e67cf7e5~mv2.png','South Eastern USA longest running club. Founders of the Dragon''s Cup and Carolina Carnage setting the standard for quality tournaments. ''Wesome ''Possums is the newest team to be built from our club. Mostly a bunch of new comers to the sport pushing for the opportunity to fight.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','(a)''wesome-(o)''possums','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','Awesome Possums','Columbia','palmettoknights@gmail.com','https://linktr.ee/palmettoknights',20,'{"biCollectionId":"0b0fb0a1-09c1-4dad-a610-4c51a799b5e4","teamName":"Awesome Possums","club":"Palmetto Knights","gender":"Male","captain":"Reid Weston","conference":"North America","country":"United States","city":"Columbia","teamInfo":"South Eastern USA longest running club. Founders of the Dragon''s Cup and Carolina Carnage setting the standard for quality tournaments. ''Wesome ''Possums is the newest team to be built from our club. Mostly a bunch of new comers to the sport pushing for the opportunity to fight.","trainingInfo":"We have open practices in Irmo South Carolina on almost every sunday. Other area practices are always in the works.","trainingLocation":{"city":"Irmo","location":{"latitude":34.0926557,"longitude":-81.17912079999999},"streetAddress":{"apt":"","formattedAddressLine":"7507 Eastview Dr","name":"Eastview Drive","number":"7507"},"formatted":"7507 Eastview Dr, Irmo, SC 29063, USA","country":"US","postalCode":"29063","subdivision":"SC"},"websiteFacebookUrl":"https://linktr.ee/palmettoknights","teamEmail":"palmettoknights@gmail.com","teamLogo":"wix:image://v1/7b5505_b018c05010724614b417c9b8e67cf7e5~mv2.png/shield.png#originWidth=2550&originHeight=2550","logoUrl":"https://static.wixstatic.com/media/7b5505_b018c05010724614b417c9b8e67cf7e5~mv2.png","rank5v5":17,"averagePoints5v5":0.75,"points5v5":2.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":15},{"_id":"2","points":1,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":6},{"_id":"3","points":0,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":6},{"_id":"4","points":1.25,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":13}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":17},{"_id":"2","points":0,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":6},{"_id":"3","points":3,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":8},{"_id":"4","points":1,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":6}]},"2025":{"tournaments":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":23},{"_id":"2","points":1,"Tournament":"Tournament of Legends 2025","date":"2025-04-26","category":"5vs5","place":4},{"_id":"3","points":0,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":13},{"_id":"4","points":0,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":11}],"points12v12":0,"averagePoints5v5":0.33,"rank5v5":20,"remainingTokens":5,"points5v5":1}},"members":["Logan Dumont","Kai Yamada","Reid Weston","Brant Hale","Duncan Drebenstedt","Alan Dugger","James Davis","Alexander Jung","Sawyer Hipp","Brent Kitchen","Jay Tablas","Zachary Griffith","Yddryk Zadok"],"sourceCreatedAt":"2023-07-10T16:55:07.061Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Awesome Possums',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Columbia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'palmettoknights@gmail.com'),
 website_url=coalesce(t.website_url,'https://linktr.ee/palmettoknights'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7b5505_b018c05010724614b417c9b8e67cf7e5~mv2.png'),
 public_description=coalesce(t.public_description,'South Eastern USA longest running club. Founders of the Dragon''s Cup and Carolina Carnage setting the standard for quality tournaments. ''Wesome ''Possums is the newest team to be built from our club. Mostly a bunch of new comers to the sport pushing for the opportunity to fight.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Dumont','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kai Yamada','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Reid Weston','captain','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brant Hale','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Duncan Drebenstedt','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alan Dugger','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Jung','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sawyer Hipp','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brent Kitchen','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jay Tablas','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Griffith','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yddryk Zadok','fighter','bi_teams','https://www.buhurtinternational.com/team/(a)''wesome-(o)''possums','(a)''wesome-(o)''possums',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='1316-mfc' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-1316-mfc' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'1316 MFC','Galway',true,'active','public','bi-1316-mfc','EU','Europe','IE','Ireland','barryflannery739@gmail.com','https://www.facebook.com/1316mfc/','https://static.wixstatic.com/media/3647d8_3b9a81ae3d52439abf04fff563aa6f2e~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','1316-mfc','https://www.buhurtinternational.com/team/1316-mfc','1316 MFC','Galway','barryflannery739@gmail.com','https://www.facebook.com/1316mfc/',20,'{"biCollectionId":"8f2046db-0f1a-4437-bce2-ac7544ef0cd6","teamName":"1316 MFC","club":null,"gender":"Male","captain":"Barry Flannery","conference":"Europe","country":"Ireland","city":"Galway","teamInfo":"","trainingInfo":"Contact our social media is usually the best way to arrange it. We have many fighters from other clubs on the island attend regularly and can cater for begginers","trainingLocation":{"formatted":"2 Caheroyan Cresent"},"websiteFacebookUrl":"https://www.facebook.com/1316mfc/","teamEmail":"barryflannery739@gmail.com","teamLogo":"wix:image://v1/3647d8_3b9a81ae3d52439abf04fff563aa6f2e~mv2.jpeg/received_1350033479171868.jpeg#originWidth=2025&originHeight=1712","logoUrl":"https://static.wixstatic.com/media/3647d8_3b9a81ae3d52439abf04fff563aa6f2e~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Barry Flannery","Warren Hurst","John van den Hof","Julian Angelozzi","Eoin McDonagh","Noel monaghan","Adrien Biencourt","Kyle De Souza Wearen"],"sourceCreatedAt":"2024-01-02T01:58:32.113Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('1316 MFC',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Galway',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Ireland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'barryflannery739@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/1316mfc/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3647d8_3b9a81ae3d52439abf04fff563aa6f2e~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Barry Flannery','captain','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Warren Hurst','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John van den Hof','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Angelozzi','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eoin McDonagh','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noel monaghan','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrien Biencourt','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle De Souza Wearen','fighter','bi_teams','https://www.buhurtinternational.com/team/1316-mfc','1316-mfc',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='13th-legion' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-13th-legion' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'13th Legion','Salt Lake City',true,'active','public','bi-13th-legion','NA','North America','US','United States','events@legion13.org',NULL,'https://static.wixstatic.com/media/50f711_f69b808c1a964cfcafc7a089debfd387~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','13th-legion','https://www.buhurtinternational.com/team/13th-legion','13th Legion','Salt Lake City','events@legion13.org',NULL,20,'{"biCollectionId":"7810f0e7-ec43-4e63-ba66-9b59f631bd54","teamName":"13th Legion","club":null,"gender":"Male","captain":"Alexander Whitelock","conference":"North America","country":"United States","city":"Salt Lake City","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"events@legion13.org","teamLogo":"wix:image://v1/50f711_f69b808c1a964cfcafc7a089debfd387~mv2.png/13thLegion.png#originWidth=512&originHeight=512","logoUrl":"https://static.wixstatic.com/media/50f711_f69b808c1a964cfcafc7a089debfd387~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Alexander Whitelock"],"sourceCreatedAt":"2025-10-15T17:53:25.487Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('13th Legion',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Salt Lake City',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'events@legion13.org'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/50f711_f69b808c1a964cfcafc7a089debfd387~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Whitelock','captain','bi_teams','https://www.buhurtinternational.com/team/13th-legion','13th-legion',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='admorsus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-admorsus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Admorsus','Labergement Saint Marie / Lyon ',true,'active','public','bi-admorsus','EU','Europe','FR','France','julie.filliol@hotmail.com',NULL,'https://static.wixstatic.com/media/93965b_2a8d48db33b846a5a80f8a203b318b93~mv2.jpeg','are an alliance of a lot of French teams')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','admorsus','https://www.buhurtinternational.com/team/admorsus','Admorsus','Labergement Saint Marie / Lyon ','julie.filliol@hotmail.com',NULL,20,'{"biCollectionId":"7980ed5d-af39-4e9b-85e5-7ec8a68e34e3","teamName":"Admorsus","club":null,"gender":"Female","captain":"Julie Filliol","conference":"Europe","country":"France","city":"Labergement Saint Marie / Lyon ","teamInfo":"are an alliance of a lot of French teams","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"julie.filliol@hotmail.com","teamLogo":"wix:image://v1/93965b_2a8d48db33b846a5a80f8a203b318b93~mv2.jpeg/2b84f3d8131114100bb3def0c57bc965.jpeg#originWidth=3508&originHeight=2480","logoUrl":"https://static.wixstatic.com/media/93965b_2a8d48db33b846a5a80f8a203b318b93~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Julie Filliol","LOPEZ Jessie","Justine Jaworek","Kenza Hmaiss","Brouard Ylane","Camille Cordel","Huet amelie","Tatiana SCHIELE","Tiphaine SOTO"],"sourceCreatedAt":"2026-04-21T06:58:59.807Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Admorsus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Labergement Saint Marie / Lyon ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'julie.filliol@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/93965b_2a8d48db33b846a5a80f8a203b318b93~mv2.jpeg'),
 public_description=coalesce(t.public_description,'are an alliance of a lot of French teams'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julie Filliol','captain','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LOPEZ Jessie','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justine Jaworek','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kenza Hmaiss','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brouard Ylane','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Camille Cordel','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Huet amelie','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tatiana SCHIELE','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tiphaine SOTO','fighter','bi_teams','https://www.buhurtinternational.com/team/admorsus','admorsus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='adversum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-adversum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Adversum',NULL,true,'active','public','bi-adversum','EU','Europe','GB','United Kingdom','committee.cmfg@gmail.com',NULL,'https://static.wixstatic.com/media/d96556_c559713385534667a0478be6c0aa6f4d~mv2.png','Adversum is an all-female team covering the area of East Anglia. We train regularly in both Cambridge and Norwich.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','adversum','https://www.buhurtinternational.com/team/adversum','Adversum',NULL,'committee.cmfg@gmail.com',NULL,20,'{"biCollectionId":"a716a4b5-7dfa-4e88-8eef-d538cdc0aa1d","teamName":"Adversum","club":null,"gender":"Female","captain":"Meriel Rodgers","conference":"Europe","country":"United Kingdom","city":null,"teamInfo":"Adversum is an all-female team covering the area of East Anglia. We train regularly in both Cambridge and Norwich.","trainingInfo":"If you would like to attend training with us, please get in contact with one of our branches: Cambridge: cmfg.uk Norwich: norwichmc.wixsite.com/nmac","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"committee.cmfg@gmail.com","teamLogo":"wix:image://v1/d96556_c559713385534667a0478be6c0aa6f4d~mv2.png/Adversum%20Logo%20No%20Text.PNG#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/d96556_c559713385534667a0478be6c0aa6f4d~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Meriel Rodgers","Rebecca Olivia Irvine","Isabella Blackley","Kayleigh Joanna Bernard"],"sourceCreatedAt":"2026-07-05T18:26:17.481Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Adversum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'committee.cmfg@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d96556_c559713385534667a0478be6c0aa6f4d~mv2.png'),
 public_description=coalesce(t.public_description,'Adversum is an all-female team covering the area of East Anglia. We train regularly in both Cambridge and Norwich.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Meriel Rodgers','captain','bi_teams','https://www.buhurtinternational.com/team/adversum','adversum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebecca Olivia Irvine','fighter','bi_teams','https://www.buhurtinternational.com/team/adversum','adversum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isabella Blackley','fighter','bi_teams','https://www.buhurtinternational.com/team/adversum','adversum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayleigh Joanna Bernard','fighter','bi_teams','https://www.buhurtinternational.com/team/adversum','adversum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='akerbeltz' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-akerbeltz' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Akerbeltz','Euskal Herria',true,'active','public','bi-akerbeltz','EU','Europe','FR','France','contact.akbtz.behourd@gmail.com',NULL,'https://static.wixstatic.com/media/2b6e34_46f47cf081454335920d36fe923c340c~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','akerbeltz','https://www.buhurtinternational.com/team/akerbeltz','Akerbeltz','Euskal Herria','contact.akbtz.behourd@gmail.com',NULL,20,'{"biCollectionId":"e6632d68-2613-4bfd-a752-cb5de21b2142","teamName":"Akerbeltz","club":null,"gender":"Male","captain":"Fauxtin Rouyre","conference":"Europe","country":"France","city":"Euskal Herria","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"contact.akbtz.behourd@gmail.com","teamLogo":"wix:image://v1/2b6e34_46f47cf081454335920d36fe923c340c~mv2.jpg/IMG-20241010-WA0007(1).jpg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/2b6e34_46f47cf081454335920d36fe923c340c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Fauxtin ROUYRE","PAUTHE Walfroy","VERTUT Johan","Simons Jean","Pierre HOEGELI","Alain Bes"],"sourceCreatedAt":"2026-04-09T13:10:45.987Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Akerbeltz',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Euskal Herria',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'contact.akbtz.behourd@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2b6e34_46f47cf081454335920d36fe923c340c~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fauxtin ROUYRE','captain','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PAUTHE Walfroy','fighter','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VERTUT Johan','fighter','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simons Jean','fighter','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pierre HOEGELI','fighter','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alain Bes','fighter','bi_teams','https://www.buhurtinternational.com/team/akerbeltz','akerbeltz',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='akron-hedge-knights-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-akron-hedge-knights-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Akron Hedge Knights','Akron Ohio',true,'active','public','bi-akron-hedge-knights-','NA','North America','US','United States','theakronhedgeknights@gmail.com','https://www.facebook.com/share/g/1XaFwzZSoU/','https://static.wixstatic.com/media/f5390f_b56f076f9f94451991bf1c2114a74f21~mv2.jpeg','Started in 2021 we are northeast Ohio first armored combat team.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','akron-hedge-knights-','https://www.buhurtinternational.com/team/akron-hedge-knights-','Akron Hedge Knights','Akron Ohio','theakronhedgeknights@gmail.com','https://www.facebook.com/share/g/1XaFwzZSoU/',20,'{"biCollectionId":"e0f2e9f4-2592-4d42-898b-03849d92ad53","teamName":"Akron Hedge Knights","club":null,"gender":"Male","captain":"Craig Nihart ","conference":"North America","country":"United States","city":"Akron Ohio","teamInfo":"Started in 2021 we are northeast Ohio first armored combat team.","trainingInfo":"New members are always welcome. We practice Tuesdays a Thursdays starting at 730pm. You only need to wear a protective cup and some comfortable clothes for working out.","trainingLocation":{"subdivisions":[{"code":"OH","name":"Ohio","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Portage County","name":"Portage County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Kent","name":"Kent","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Kent","location":{"latitude":41.1555843,"longitude":-81.31752829999999},"streetAddress":{"apt":"","formattedAddressLine":"2108 OH-59","name":"Ohio 59","number":"2108"},"formatted":"2108 OH-59, Kent, OH 44240, USA","country":"US","postalCode":"44240-7142","subdivision":"OH"},"websiteFacebookUrl":"https://www.facebook.com/share/g/1XaFwzZSoU/","teamEmail":"theakronhedgeknights@gmail.com","teamLogo":"wix:image://v1/f5390f_b56f076f9f94451991bf1c2114a74f21~mv2.jpeg/received_1538289933608382.jpeg#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/f5390f_b56f076f9f94451991bf1c2114a74f21~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":9},{"_id":"2","points":0,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":18}],"eventsHistory":{"2024":{},"2025":{"points12v12":1,"points5v5":0,"remainingTokens":8,"tournaments":[{"_id":"1","points":0,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":14},{"_id":"2","points":1,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":6}]}},"members":["Craig Nihart","Christopher garbrandt","Robert Forgues","Chris hudson","Sean Brandt","George Dalton Hehn"],"sourceCreatedAt":"2025-04-26T13:05:56.670Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Akron Hedge Knights',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Akron Ohio',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'theakronhedgeknights@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/g/1XaFwzZSoU/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f5390f_b56f076f9f94451991bf1c2114a74f21~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Started in 2021 we are northeast Ohio first armored combat team.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Craig Nihart','captain','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher garbrandt','fighter','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Forgues','fighter','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris hudson','fighter','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'George Dalton Hehn','fighter','bi_teams','https://www.buhurtinternational.com/team/akron-hedge-knights-','akron-hedge-knights-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='anima-belli' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-anima-belli' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Anima Belli','Herencia',true,'active','public','bi-anima-belli','EU','Europe','ES','Spain','animabelli.club@gmail.com',NULL,'https://static.wixstatic.com/media/b36739_0e180355e863435e8e0ecf36adbe18d8~mv2.png','ANIMA BELLI Excita Spiritum Pugnadi 🏁 Especialistas en Combate Singular y Formación Integral Somos Anima Belli , club deportivo con base en Herencia (Ciudad Real, España) , dedicados al alto rendimiento en duelos y Profight . Nuestra metodología se centra en: Técnica especializada con todas las armas (espadas, hachas, escudos). Dominio del grappling y lucha cuerpo a cuerpo . Preparación física adaptada al combate real . 🛡️ Formación Completa para Melee Aunque nuestra especialidad es el combate singular, desarrollamos luchadores versátiles y técnicos para competir en melee, con: Estrategias de grupo y coordinación. Adaptación a diferentes reglamentos y escenarios. Entrenamientos diseñados para competidores serios. 🔥 Nuestro Enfoque Técnica depurada : Trabajo integro en modalidades de duelos y mma. Intensidad competitiva : Entrenamientos exigentes para resultados reales. Comunidad de guerreros : Ambiente serio pero cercano. 📅 Horarios de Entrenamiento Martes y Jueves: 19:30 - 21:30 Sábados: 9:00 - 13:00 📍 Camino Quero 13 , Herencia (Ciudad Real) 📩 Contacto Instagram: @anima_belli ✉️ animabelli.club@gmail.com 🌍 Club registrado en Buhurt International.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','anima-belli','https://www.buhurtinternational.com/team/anima-belli','Anima Belli','Herencia','animabelli.club@gmail.com',NULL,20,'{"biCollectionId":"ca2cc2cf-aac3-4988-8708-96506b2cee52","teamName":"Anima Belli","club":null,"gender":"Male","captain":"Mario Fernandez","conference":"Europe","country":"Spain","city":"Herencia","teamInfo":"ANIMA BELLI Excita Spiritum Pugnadi 🏁 Especialistas en Combate Singular y Formación Integral Somos Anima Belli , club deportivo con base en Herencia (Ciudad Real, España) , dedicados al alto rendimiento en duelos y Profight . Nuestra metodología se centra en: Técnica especializada con todas las armas (espadas, hachas, escudos). Dominio del grappling y lucha cuerpo a cuerpo . Preparación física adaptada al combate real . 🛡️ Formación Completa para Melee Aunque nuestra especialidad es el combate singular, desarrollamos luchadores versátiles y técnicos para competir en melee, con: Estrategias de grupo y coordinación. Adaptación a diferentes reglamentos y escenarios. Entrenamientos diseñados para competidores serios. 🔥 Nuestro Enfoque Técnica depurada : Trabajo integro en modalidades de duelos y mma. Intensidad competitiva : Entrenamientos exigentes para resultados reales. Comunidad de guerreros : Ambiente serio pero cercano. 📅 Horarios de Entrenamiento Martes y Jueves: 19:30 - 21:30 Sábados: 9:00 - 13:00 📍 Camino Quero 13 , Herencia (Ciudad Real) 📩 Contacto Instagram: @anima_belli ✉️ animabelli.club@gmail.com 🌍 Club registrado en Buhurt International.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"CM","name":"Castilla-La Mancha","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"CR","name":"Ciudad Real","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Herencia","name":"Herencia","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"ES","name":"Spain","type":"COUNTRY"}],"city":"Herencia","location":{"latitude":39.3744301,"longitude":-3.352057},"streetAddress":{"apt":"","formattedAddressLine":"Cam. Quero, 13","name":"Camino Quero","number":"13"},"formatted":"Cam. Quero, 13, 13640 Herencia, Ciudad Real, Spain","country":"ES","postalCode":"13640","subdivision":"CM"},"websiteFacebookUrl":null,"teamEmail":"animabelli.club@gmail.com","teamLogo":"wix:image://v1/b36739_0e180355e863435e8e0ecf36adbe18d8~mv2.png/LOGO_ANIMA-BELLI_2048x2048.png#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/b36739_0e180355e863435e8e0ecf36adbe18d8~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Mario Fernandez","Mario Fernández Martín de Ruedas","Diego Privado Ferrer","Sergio Díaz","Silvia Montes Rubia","Sercas","David Jimenez Nuñez","Javier Aguilera Santos","Adrián de la Fuente Ramos","Adrian Fernandez De Jesus"],"sourceCreatedAt":"2025-03-25T18:55:13.780Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Anima Belli',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Herencia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'animabelli.club@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b36739_0e180355e863435e8e0ecf36adbe18d8~mv2.png'),
 public_description=coalesce(t.public_description,'ANIMA BELLI Excita Spiritum Pugnadi 🏁 Especialistas en Combate Singular y Formación Integral Somos Anima Belli , club deportivo con base en Herencia (Ciudad Real, España) , dedicados al alto rendimiento en duelos y Profight . Nuestra metodología se centra en: Técnica especializada con todas las armas (espadas, hachas, escudos). Dominio del grappling y lucha cuerpo a cuerpo . Preparación física adaptada al combate real . 🛡️ Formación Completa para Melee Aunque nuestra especialidad es el combate singular, desarrollamos luchadores versátiles y técnicos para competir en melee, con: Estrategias de grupo y coordinación. Adaptación a diferentes reglamentos y escenarios. Entrenamientos diseñados para competidores serios. 🔥 Nuestro Enfoque Técnica depurada : Trabajo integro en modalidades de duelos y mma. Intensidad competitiva : Entrenamientos exigentes para resultados reales. Comunidad de guerreros : Ambiente serio pero cercano. 📅 Horarios de Entrenamiento Martes y Jueves: 19:30 - 21:30 Sábados: 9:00 - 13:00 📍 Camino Quero 13 , Herencia (Ciudad Real) 📩 Contacto Instagram: @anima_belli ✉️ animabelli.club@gmail.com 🌍 Club registrado en Buhurt International.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mario Fernandez','captain','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mario Fernández Martín de Ruedas','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Diego Privado Ferrer','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio Díaz','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silvia Montes Rubia','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sercas','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Jimenez Nuñez','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Javier Aguilera Santos','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrián de la Fuente Ramos','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Fernandez De Jesus','fighter','bi_teams','https://www.buhurtinternational.com/team/anima-belli','anima-belli',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='aquila-ferox' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-aquila-ferox' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Aquila Ferox','Genova',true,'active','public','bi-aquila-ferox','EU','Europe','IT','Italy','asdquilaferox@gmail.com',NULL,'https://static.wixstatic.com/media/5d01cf_bfd16228c80b4ff8ab94f6a3a4bae1a8~mv2.jpeg','🛡️ʙᴜʜᴜʀᴛ ᴀᴄᴄᴀᴅᴇᴍʏ - ᴍᴇᴅɪᴇᴠᴀʟ ꜰɪɢʜᴛ ᴄʟᴜʙ 🏕️ᴍᴇᴅɪᴇᴠᴀʟ ʜɪꜱᴛᴏʀɪᴄᴀʟ ʀᴇᴇɴᴀᴄᴛᴍᴇɴᴛ ɢʀᴏᴜᴘ 📍ɢᴇɴᴏᴠᴀ & ᴘᴀᴅᴏᴠᴀ - ɪᴛᴀʟʏ 📲ꜰɪɢʜᴛ ᴡɪᴛʜ ᴜꜱ:3478216117')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','aquila-ferox','https://www.buhurtinternational.com/team/aquila-ferox','Aquila Ferox','Genova','asdquilaferox@gmail.com',NULL,20,'{"biCollectionId":"5822a531-2ffc-44a7-9988-ffdd8081ccfc","teamName":"Aquila Ferox","club":null,"gender":"Male","captain":"davide pagiaro","conference":"Europe","country":"Italy","city":"Genova","teamInfo":"🛡️ʙᴜʜᴜʀᴛ ᴀᴄᴄᴀᴅᴇᴍʏ - ᴍᴇᴅɪᴇᴠᴀʟ ꜰɪɢʜᴛ ᴄʟᴜʙ 🏕️ᴍᴇᴅɪᴇᴠᴀʟ ʜɪꜱᴛᴏʀɪᴄᴀʟ ʀᴇᴇɴᴀᴄᴛᴍᴇɴᴛ ɢʀᴏᴜᴘ 📍ɢᴇɴᴏᴠᴀ & ᴘᴀᴅᴏᴠᴀ - ɪᴛᴀʟʏ 📲ꜰɪɢʜᴛ ᴡɪᴛʜ ᴜꜱ:3478216117","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Liguria","name":"Liguria","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"GE","name":"Città Metropolitana di Genova","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Genova","name":"Genova","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IT","name":"Italy","type":"COUNTRY"}],"city":"Genova","location":{"latitude":44.4058778,"longitude":8.9335251},"streetAddress":{"apt":"","formattedAddressLine":"Vico delle Carabaghe","name":"Vico delle Carabaghe","number":""},"formatted":"Vico delle Carabaghe, 16123 Genova GE, Italy","country":"IT","postalCode":"16123","subdivision":"42"},"websiteFacebookUrl":null,"teamEmail":"asdquilaferox@gmail.com","teamLogo":"wix:image://v1/5d01cf_bfd16228c80b4ff8ab94f6a3a4bae1a8~mv2.jpeg/WhatsApp%20Image%202026-09-16%20at%2023.52.20.jpeg#originWidth=1170&originHeight=1170","logoUrl":"https://static.wixstatic.com/media/5d01cf_bfd16228c80b4ff8ab94f6a3a4bae1a8~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["DAVIDE PAGIARO","Francesca Mazzoni"],"sourceCreatedAt":"2026-09-17T08:55:03.164Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Aquila Ferox',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Genova',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'asdquilaferox@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5d01cf_bfd16228c80b4ff8ab94f6a3a4bae1a8~mv2.jpeg'),
 public_description=coalesce(t.public_description,'🛡️ʙᴜʜᴜʀᴛ ᴀᴄᴄᴀᴅᴇᴍʏ - ᴍᴇᴅɪᴇᴠᴀʟ ꜰɪɢʜᴛ ᴄʟᴜʙ 🏕️ᴍᴇᴅɪᴇᴠᴀʟ ʜɪꜱᴛᴏʀɪᴄᴀʟ ʀᴇᴇɴᴀᴄᴛᴍᴇɴᴛ ɢʀᴏᴜᴘ 📍ɢᴇɴᴏᴠᴀ & ᴘᴀᴅᴏᴠᴀ - ɪᴛᴀʟʏ 📲ꜰɪɢʜᴛ ᴡɪᴛʜ ᴜꜱ:3478216117'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'DAVIDE PAGIARO','captain','bi_teams','https://www.buhurtinternational.com/team/aquila-ferox','aquila-ferox',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesca Mazzoni','fighter','bi_teams','https://www.buhurtinternational.com/team/aquila-ferox','aquila-ferox',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ar-groaz-du' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ar-groaz-du' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ar Groaz Du',NULL,true,'active','public','bi-ar-groaz-du','EU','Europe','FR','France','argroazdu@gmail.com','https://www.argroazdu.com','https://static.wixstatic.com/media/c64c01_a45d24e8181540089e42fc6bb43e598b~mv2.jpg','French team from Bretagne')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ar-groaz-du','https://www.buhurtinternational.com/team/ar-groaz-du','Ar Groaz Du',NULL,'argroazdu@gmail.com','https://www.argroazdu.com',20,'{"biCollectionId":"721cd18c-8a93-45a6-bc7b-47bd38e638b9","teamName":"Ar Groaz Du","club":null,"gender":"Male","captain":"LE BRAS Mael","conference":"Europe","country":"France","city":null,"teamInfo":"French team from Bretagne","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.argroazdu.com","teamEmail":"argroazdu@gmail.com","teamLogo":"wix:image://v1/c64c01_a45d24e8181540089e42fc6bb43e598b~mv2.jpg/image0.jpg#originWidth=304&originHeight=362","logoUrl":"https://static.wixstatic.com/media/c64c01_a45d24e8181540089e42fc6bb43e598b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":4,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":4}]}},"members":["LE BRAS Mael","Coutellier Thomas","Lallement Tanguy","Le gleut","Yohann Lallier","Reunavot Sylvain","Tangi Le Gac","Théo duquenne","Mael Le Bras","Johnathane Shannon"],"sourceCreatedAt":"2025-04-19T08:49:46.415Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ar Groaz Du',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'argroazdu@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.argroazdu.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c64c01_a45d24e8181540089e42fc6bb43e598b~mv2.jpg'),
 public_description=coalesce(t.public_description,'French team from Bretagne'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LE BRAS Mael','captain','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Coutellier Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lallement Tanguy','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Le gleut','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yohann Lallier','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Reunavot Sylvain','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tangi Le Gac','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Théo duquenne','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mael Le Bras','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johnathane Shannon','fighter','bi_teams','https://www.buhurtinternational.com/team/ar-groaz-du','ar-groaz-du',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ardents' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ardents' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ardents','LIMOGES',true,'active','public','bi-ardents','EU','Europe','FR','France','ardent.buhurt@hotmail.com','https://www.facebook.com/profile.php?id=100086147957923','https://static.wixstatic.com/media/fc880c_040544c539e84f1196c3edc9767f5b74~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ardents','https://www.buhurtinternational.com/team/ardents','Ardents','LIMOGES','ardent.buhurt@hotmail.com','https://www.facebook.com/profile.php?id=100086147957923',20,'{"biCollectionId":"9e77d1e3-67df-442a-8d9e-616dbe0d2073","teamName":"Ardents","club":null,"gender":"Male","captain":"matthieu leyrisse","conference":"Europe","country":"France","city":"LIMOGES","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100086147957923","teamEmail":"ardent.buhurt@hotmail.com","teamLogo":"wix:image://v1/fc880c_040544c539e84f1196c3edc9767f5b74~mv2.png/ardentfede.png#originWidth=323&originHeight=346","logoUrl":"https://static.wixstatic.com/media/fc880c_040544c539e84f1196c3edc9767f5b74~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Goblet Richard","Tristan Charuel","Naoj","Tanguy Tchiko","Cristofer pinto","Goetz Frederic","matthieu leyrisse"],"sourceCreatedAt":"2023-09-19T20:30:51.482Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ardents',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('LIMOGES',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ardent.buhurt@hotmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100086147957923'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/fc880c_040544c539e84f1196c3edc9767f5b74~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Goblet Richard','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tristan Charuel','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Naoj','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tanguy Tchiko','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cristofer pinto','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Goetz Frederic','fighter','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'matthieu leyrisse','captain','bi_teams','https://www.buhurtinternational.com/team/ardents','ardents',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='argentum-combate-historico-medieval' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-argentum-combate-historico-medieval' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Argentum Combate Historico Medieval','Tucumán',true,'active','public','bi-argentum-combate-historico-medieval','SA','South America','AR','Argentina','javierargentumemperador@gmail.com','https://www.facebook.com/profile.php?id=61550924982831','https://static.wixstatic.com/media/bd6e99_22991a8d2b52421a9a283f94824a850e~mv2.jpg','Club de combate medieval basados en artes marciales Lugar de entrenamiento : Parque 9 de Julio frente al Garden - Martes y Jueves (19 a 21 ) dias sabados y domingo a definir lugar y horarios / cualquier duda (3813395863)')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','argentum-combate-historico-medieval','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','Argentum Combate Historico Medieval','Tucumán','javierargentumemperador@gmail.com','https://www.facebook.com/profile.php?id=61550924982831',20,'{"biCollectionId":"e7e7fefe-aaf7-45c5-9584-e20765b1a845","teamName":"Argentum Combate Historico Medieval","club":null,"gender":"Male","captain":"Nicolas Emperador","conference":"South America","country":"Argentina","city":"Tucumán","teamInfo":"Club de combate medieval basados en artes marciales Lugar de entrenamiento : Parque 9 de Julio frente al Garden - Martes y Jueves (19 a 21 ) dias sabados y domingo a definir lugar y horarios / cualquier duda (3813395863)","trainingInfo":"","trainingLocation":{"city":"San Miguel de Tucumán","location":{"latitude":-26.82862,"longitude":-65.19131399999999},"streetAddress":{"apt":"","formattedAddressLine":"Parque 9 de Julio","name":"Avenida Soldati","number":"SN"},"formatted":"Av. Soldati SN, San Miguel de Tucumán, Tucumán, Argentina","country":"AR"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61550924982831","teamEmail":"javierargentumemperador@gmail.com","teamLogo":"wix:image://v1/bd6e99_22991a8d2b52421a9a283f94824a850e~mv2.jpg/ArgentumOriginalConLetra2.jpg#originWidth=3065&originHeight=2774","logoUrl":"https://static.wixstatic.com/media/bd6e99_22991a8d2b52421a9a283f94824a850e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Nicolas Emperador","Javier Emperador","Pascual Ramon Trejo","Damian Dobroniche","Leonardo Coronel Garcia","Iris Luz Romero Albuixech"],"sourceCreatedAt":"2023-09-13T16:57:09.458Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Argentum Combate Historico Medieval',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tucumán',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'javierargentumemperador@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61550924982831'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bd6e99_22991a8d2b52421a9a283f94824a850e~mv2.jpg'),
 public_description=coalesce(t.public_description,'Club de combate medieval basados en artes marciales Lugar de entrenamiento : Parque 9 de Julio frente al Garden - Martes y Jueves (19 a 21 ) dias sabados y domingo a definir lugar y horarios / cualquier duda (3813395863)'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicolas Emperador','captain','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Javier Emperador','fighter','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pascual Ramon Trejo','fighter','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damian Dobroniche','fighter','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Coronel Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iris Luz Romero Albuixech','fighter','bi_teams','https://www.buhurtinternational.com/team/argentum-combate-historico-medieval','argentum-combate-historico-medieval',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='arma-flandriae' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-arma-flandriae' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Arma Flandriae','Lille',true,'active','public','bi-arma-flandriae','EU','Europe','FR','France','hdf.behourd@gmail.com','https://www.facebook.com/profile.php?id=61558635533030','https://static.wixstatic.com/media/a6804c_4cea42f29f5c420ea2d3bdabb78ab314~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','arma-flandriae','https://www.buhurtinternational.com/team/arma-flandriae','Arma Flandriae','Lille','hdf.behourd@gmail.com','https://www.facebook.com/profile.php?id=61558635533030',20,'{"biCollectionId":"66beb73a-ac58-431b-887d-9428147cf91f","teamName":"Arma Flandriae","club":null,"gender":"Male","captain":"Nicolas WARNIER","conference":"Europe","country":"France","city":"Lille","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Hauts-de-France","name":"Hauts-de-France","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Nord","name":"Nord","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Seclin","name":"Seclin","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Seclin","location":{"latitude":50.550567,"longitude":3.0474},"streetAddress":{"apt":"","formattedAddressLine":"257 Rue de l''Industrie","name":"Rue de l''Industrie","number":"257"},"formatted":"257 Rue de l''Industrie, 59113 Seclin, France","country":"FR","postalCode":"59113","subdivision":"HDF"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61558635533030","teamEmail":"hdf.behourd@gmail.com","teamLogo":"wix:image://v1/a6804c_4cea42f29f5c420ea2d3bdabb78ab314~mv2.jpg/e905b5cc-05c0-4fc0-aa84-fa5743bdbf28.jpg#originWidth=516&originHeight=599","logoUrl":"https://static.wixstatic.com/media/a6804c_4cea42f29f5c420ea2d3bdabb78ab314~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":5}]}},"members":["Olivier Le Cocq","Valentin Grazillier","Fourrier Sacha","Gauthier Fontorbes","Dangreau Thomas","TATINCLAUX Théo","Nicolas Warnier","Paolo Bonfante","Raphael szymanek","Petit arnaud","Laloyaux Loïc","Jonathan Peres","Théo Codron"],"sourceCreatedAt":"2025-03-23T18:52:48.617Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Arma Flandriae',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lille',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hdf.behourd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61558635533030'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a6804c_4cea42f29f5c420ea2d3bdabb78ab314~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olivier Le Cocq','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valentin Grazillier','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fourrier Sacha','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gauthier Fontorbes','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dangreau Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'TATINCLAUX Théo','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicolas Warnier','captain','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paolo Bonfante','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raphael szymanek','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petit arnaud','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laloyaux Loïc','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Peres','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Théo Codron','fighter','bi_teams','https://www.buhurtinternational.com/team/arma-flandriae','arma-flandriae',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='armis-nostrum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-armis-nostrum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Armis Nostrum','Óbidos',true,'active','public','bi-armis-nostrum','EU','Europe','PT','Portugal','armisnostrum@gmail.com','https://www.facebook.com/profile.php?id=100057087413523','https://static.wixstatic.com/media/6a99ac_cf53492f54cb407b923dceef4f78563c~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','armis-nostrum','https://www.buhurtinternational.com/team/armis-nostrum','Armis Nostrum','Óbidos','armisnostrum@gmail.com','https://www.facebook.com/profile.php?id=100057087413523',20,'{"biCollectionId":"ee91033e-4d06-47a2-b46b-1316d3400720","teamName":"Armis Nostrum","club":null,"gender":"Male","captain":"Orlando Silva","conference":"Europe","country":"Portugal","city":"Óbidos","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100057087413523","teamEmail":"armisnostrum@gmail.com","teamLogo":"wix:image://v1/6a99ac_cf53492f54cb407b923dceef4f78563c~mv2.jpg/Logo%20armis%20Nostrum%20atual.jpg#originWidth=960&originHeight=956","logoUrl":"https://static.wixstatic.com/media/6a99ac_cf53492f54cb407b923dceef4f78563c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Torneio Medieval de Pirescoxe 2026","date":"2026-05-02","category":"5vs5","place":4}],"eventsHistory":{},"members":["Orlando Silva","Orlando Augusto Luís da Silva","Kostiantyn Slabko","Kayo Pantoja","Serhiy Boychenko","Martim Silva Bulhões","Leonardo Santos Gomes","Igor Kashporov","Andrej Quint Russo"],"sourceCreatedAt":"2026-03-31T11:48:30.318Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Armis Nostrum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Óbidos',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Portugal',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'armisnostrum@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100057087413523'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6a99ac_cf53492f54cb407b923dceef4f78563c~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orlando Silva','captain','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orlando Augusto Luís da Silva','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kostiantyn Slabko','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayo Pantoja','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Serhiy Boychenko','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martim Silva Bulhões','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Santos Gomes','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Igor Kashporov','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrej Quint Russo','fighter','bi_teams','https://www.buhurtinternational.com/team/armis-nostrum','armis-nostrum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='armoured-combat-gloucester' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-armoured-combat-gloucester' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Armoured Combat Gloucester','Gloucester ',true,'active','public','bi-armoured-combat-gloucester','EU','Europe','GB','United Kingdom','Info@amouredcombat.co.uk','https://www.armouredcombat.co.uk/','https://static.wixstatic.com/media/72d24e_1b6e4220d4d04e64b74bfa6690651de3~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','armoured-combat-gloucester','https://www.buhurtinternational.com/team/armoured-combat-gloucester','Armoured Combat Gloucester','Gloucester ','Info@amouredcombat.co.uk','https://www.armouredcombat.co.uk/',20,'{"biCollectionId":"50306ef2-fbd5-48f6-913c-4c9180dbf532","teamName":"Armoured Combat Gloucester","club":"Armoured Combat Gloucester ","gender":"Male","captain":"Kiran Emery ","conference":"Europe","country":"United Kingdom","city":"Gloucester ","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.armouredcombat.co.uk/","teamEmail":"Info@amouredcombat.co.uk","teamLogo":"wix:image://v1/72d24e_1b6e4220d4d04e64b74bfa6690651de3~mv2.png/acg%20logo%20a3%20png.png#originWidth=3508&originHeight=4961","logoUrl":"https://static.wixstatic.com/media/72d24e_1b6e4220d4d04e64b74bfa6690651de3~mv2.png","rank5v5":3,"averagePoints5v5":6.67,"points5v5":21,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":9},{"_id":"2","points":9,"Tournament":"Torneio Medieval de Pirescoxe 2026","date":"2026-05-02","category":"5vs5","place":1},{"_id":"3","points":1,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":9},{"_id":"4","points":8,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":6},{"_id":"2","points":4,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":6},{"_id":"3","points":4,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":6},{"_id":"4","points":2,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":8}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":6},{"_id":"2","points":4,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":6},{"_id":"3","points":3,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":7}],"points12v12":0,"averagePoints5v5":3.67,"rank5v5":9,"remainingTokens":9,"points5v5":11}},"members":["Joshua Hoadley","Richard Reilly","Jack Larner","Sonny Chappell","Laco Kaplan","Aaron whatley","Matt Adams","Saul Morgan","Kiran Emery","Tom Morris","Tom Cornwall","Mr Eduards D Kudrjavcevs","John Davies","Miguel Pereira Matias","Gary Lennon","Ryan Daubney"],"sourceCreatedAt":"2023-08-30T17:07:11.871Z","sourceUpdatedAt":"2026-09-26T08:43:37.106Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Armoured Combat Gloucester',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Gloucester ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Info@amouredcombat.co.uk'),
 website_url=coalesce(t.website_url,'https://www.armouredcombat.co.uk/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/72d24e_1b6e4220d4d04e64b74bfa6690651de3~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Hoadley','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Reilly','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Larner','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sonny Chappell','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laco Kaplan','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron whatley','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matt Adams','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Saul Morgan','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kiran Emery','captain','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tom Morris','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tom Cornwall','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mr Eduards D Kudrjavcevs','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Davies','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel Pereira Matias','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gary Lennon','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Daubney','fighter','bi_teams','https://www.buhurtinternational.com/team/armoured-combat-gloucester','armoured-combat-gloucester',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='aros-buhurt-club' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-aros-buhurt-club' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Aros Buhurt Club','Århus',true,'active','public','bi-aros-buhurt-club','EU','Europe','DK','Denmark','info@aros-buhurt-club.dk','http://www.aros-buhurt-club.dk','https://static.wixstatic.com/media/f0a4e7_2ed2f12097b24e1dbe586c273958518e~mv2.jpg','Aarhus is known for its fine and well-documented Viking history. Aarhus has for many years and still is a mecca for Viking markets, meetings and battles. As a result, the focus on the Middle Ages has been a bit in the background in Aarhus. This is something Aros Buhurt Club would like to correct. Now there will be a serious club that can interact with the other nearby Buhurt clubs.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','aros-buhurt-club','https://www.buhurtinternational.com/team/aros-buhurt-club','Aros Buhurt Club','Århus','info@aros-buhurt-club.dk','http://www.aros-buhurt-club.dk',20,'{"biCollectionId":"620a496e-c56f-43f9-8beb-ee329d5ffc71","teamName":"Aros Buhurt Club","club":null,"gender":"Male","captain":"Orla Møller","conference":"Europe","country":"Denmark","city":"Århus","teamInfo":"Aarhus is known for its fine and well-documented Viking history. Aarhus has for many years and still is a mecca for Viking markets, meetings and battles. As a result, the focus on the Middle Ages has been a bit in the background in Aarhus. This is something Aros Buhurt Club would like to correct. Now there will be a serious club that can interact with the other nearby Buhurt clubs.","trainingInfo":"We are a young team that wants to be one of the leaders in Denmark and at the same time compete in Europe. We take it seriously and always have respect for our colleagues and opponents The is room for everyone but make no mistanke our first team want to be at the top, see you in the list...","trainingLocation":{"subdivisions":[{"code":"Viby J","name":"Viby J","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"DK","name":"Denmark","type":"COUNTRY"}],"city":"Viby J","location":{"latitude":56.1284672,"longitude":10.1134119},"streetAddress":{"apt":"","formattedAddressLine":"Ormslevvej 287","name":"Ormslevvej","number":"287"},"formatted":"Ormslevvej 287, 8260 Viby J, Denmark","country":"DK","postalCode":"8260"},"websiteFacebookUrl":"http://www.aros-buhurt-club.dk","teamEmail":"info@aros-buhurt-club.dk","teamLogo":"wix:image://v1/f0a4e7_2ed2f12097b24e1dbe586c273958518e~mv2.jpg/logo_01.JPG#originWidth=79&originHeight=88","logoUrl":"https://static.wixstatic.com/media/f0a4e7_2ed2f12097b24e1dbe586c273958518e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Orla Møller","Martin Wiegand","Stefan Sørensen","Aaron Kash","Rasmus Allermann","Tia Rosenkrantz"],"sourceCreatedAt":"2025-03-06T14:39:11.615Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Aros Buhurt Club',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Århus',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DK',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Denmark',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@aros-buhurt-club.dk'),
 website_url=coalesce(t.website_url,'http://www.aros-buhurt-club.dk'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f0a4e7_2ed2f12097b24e1dbe586c273958518e~mv2.jpg'),
 public_description=coalesce(t.public_description,'Aarhus is known for its fine and well-documented Viking history. Aarhus has for many years and still is a mecca for Viking markets, meetings and battles. As a result, the focus on the Middle Ages has been a bit in the background in Aarhus. This is something Aros Buhurt Club would like to correct. Now there will be a serious club that can interact with the other nearby Buhurt clubs.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orla Møller','captain','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Wiegand','fighter','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stefan Sørensen','fighter','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron Kash','fighter','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rasmus Allermann','fighter','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tia Rosenkrantz','fighter','bi_teams','https://www.buhurtinternational.com/team/aros-buhurt-club','aros-buhurt-club',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='arverni-legion' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-arverni-legion' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Arverni Legion','Foothills county',true,'active','public','bi-arverni-legion','NA','North America','CA','Canada','Arverni_Legion@outlook.com','https://www.arvernilegion.com/?fbclid=IwVERDUAO22rJleHRuA2FlbQIxMABzcnRjBmFwcF9pZAwzNTA2ODU1MzE3MjgAAR4hm7Olf4iWW6iPt8eV_tkUMpHyXdRhdUWq5dzNsXHRNTfiRHkCXR48tutWMg_aem_sB006HhgjkODvkLY999Mvw','https://static.wixstatic.com/media/bffd7c_92ea1612e17848ad9ad2b5ef517b25eb~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','arverni-legion','https://www.buhurtinternational.com/team/arverni-legion','Arverni Legion','Foothills county','Arverni_Legion@outlook.com','https://www.arvernilegion.com/?fbclid=IwVERDUAO22rJleHRuA2FlbQIxMABzcnRjBmFwcF9pZAwzNTA2ODU1MzE3MjgAAR4hm7Olf4iWW6iPt8eV_tkUMpHyXdRhdUWq5dzNsXHRNTfiRHkCXR48tutWMg_aem_sB006HhgjkODvkLY999Mvw',20,'{"biCollectionId":"fa1bd9a0-c002-476b-a332-48536427f2fc","teamName":"Arverni Legion","club":null,"gender":"Male","captain":"Warren Neilson","conference":"North America","country":"Canada","city":"Foothills county","teamInfo":"","trainingInfo":"Send a message on Facebook and we can hook you up with the details.","trainingLocation":null,"websiteFacebookUrl":"https://www.arvernilegion.com/?fbclid=IwVERDUAO22rJleHRuA2FlbQIxMABzcnRjBmFwcF9pZAwzNTA2ODU1MzE3MjgAAR4hm7Olf4iWW6iPt8eV_tkUMpHyXdRhdUWq5dzNsXHRNTfiRHkCXR48tutWMg_aem_sB006HhgjkODvkLY999Mvw","teamEmail":"Arverni_Legion@outlook.com","teamLogo":"wix:image://v1/bffd7c_92ea1612e17848ad9ad2b5ef517b25eb~mv2.jpeg/Messenger_creation_6553651374663348.jpeg#originWidth=1170&originHeight=899","logoUrl":"https://static.wixstatic.com/media/bffd7c_92ea1612e17848ad9ad2b5ef517b25eb~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Coulee Clash 2026","date":"2026-05-30","category":"3vs3","place":2}],"eventsHistory":{},"members":["Warren Neilson"],"sourceCreatedAt":"2025-12-23T02:19:59.968Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Arverni Legion',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Foothills county',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Arverni_Legion@outlook.com'),
 website_url=coalesce(t.website_url,'https://www.arvernilegion.com/?fbclid=IwVERDUAO22rJleHRuA2FlbQIxMABzcnRjBmFwcF9pZAwzNTA2ODU1MzE3MjgAAR4hm7Olf4iWW6iPt8eV_tkUMpHyXdRhdUWq5dzNsXHRNTfiRHkCXR48tutWMg_aem_sB006HhgjkODvkLY999Mvw'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bffd7c_92ea1612e17848ad9ad2b5ef517b25eb~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Warren Neilson','captain','bi_teams','https://www.buhurtinternational.com/team/arverni-legion','arverni-legion',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='athena''s-wrath-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-athena''s-wrath-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Athena''s Wrath','Portland',true,'active','public','bi-athena''s-wrath-','NA','North America','US','United States','belindaqualls@gmail.com','https://www.facebook.com/profile.php?id=61556691366231','https://static.wixstatic.com/media/d9f88b_99b8cf34eff0493fad036fb953beb42c~mv2.png','We are a Unites States west coast team with members across several states.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','athena''s-wrath-','https://www.buhurtinternational.com/team/athena''s-wrath-','Athena''s Wrath','Portland','belindaqualls@gmail.com','https://www.facebook.com/profile.php?id=61556691366231',20,'{"biCollectionId":"45e7eb6f-31e3-4a3b-a496-c0882431087d","teamName":"Athena''s Wrath","club":null,"gender":"Female","captain":"Rashelle Hams","conference":"North America","country":"United States","city":"Portland","teamInfo":"We are a Unites States west coast team with members across several states.","trainingInfo":"email: iamrashelle@yahoo.com","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61556691366231","teamEmail":"belindaqualls@gmail.com","teamLogo":"wix:image://v1/d9f88b_99b8cf34eff0493fad036fb953beb42c~mv2.png/462636587_1248895189654765_8370934317220862456_n.png#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/d9f88b_99b8cf34eff0493fad036fb953beb42c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":2,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":2},{"_id":"2","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"12vs12","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":0,"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":7}]}},"members":["Brendalee Brown","Rashelle Hams","KRIS FULLER","Ryker Lindley"],"sourceCreatedAt":"2024-12-01T23:52:27.260Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Athena''s Wrath',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Portland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'belindaqualls@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61556691366231'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d9f88b_99b8cf34eff0493fad036fb953beb42c~mv2.png'),
 public_description=coalesce(t.public_description,'We are a Unites States west coast team with members across several states.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brendalee Brown','fighter','bi_teams','https://www.buhurtinternational.com/team/athena''s-wrath-','athena''s-wrath-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rashelle Hams','captain','bi_teams','https://www.buhurtinternational.com/team/athena''s-wrath-','athena''s-wrath-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'KRIS FULLER','fighter','bi_teams','https://www.buhurtinternational.com/team/athena''s-wrath-','athena''s-wrath-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryker Lindley','fighter','bi_teams','https://www.buhurtinternational.com/team/athena''s-wrath-','athena''s-wrath-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='atlanta-valor' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-atlanta-valor' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Atlanta Valor','Atlanta, GA',true,'active','public','bi-atlanta-valor','NA','North America','US','United States','atlanta.vanguards@gmail.com','https://www.facebook.com/groups/736364014485567','https://static.wixstatic.com/media/d70539_a1ac64f2cf8848d6b0fcbee0ab844e16~mv2.png','We are Atlanta&#x27;s local armored combat team. We are relatively small, but growing, and always open to new members!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','atlanta-valor','https://www.buhurtinternational.com/team/atlanta-valor','Atlanta Valor','Atlanta, GA','atlanta.vanguards@gmail.com','https://www.facebook.com/groups/736364014485567',20,'{"biCollectionId":"93bb7e73-2605-4e7b-baee-5a93d8377e67","teamName":"Atlanta Valor","club":null,"gender":"Male","captain":"Trevor Crow","conference":"North America","country":"United States","city":"Atlanta, GA","teamInfo":"We are Atlanta&#x27;s local armored combat team. We are relatively small, but growing, and always open to new members!","trainingInfo":"For new members, please reach out via FB messenger or the FB group page for access to our Discord, where we communicate most of our events and practices. If you have soft kit or armor, that&#x27;s ideal, but we do have supplies for newbies to use during training, including a small amount of loaner armor.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/736364014485567","teamEmail":"atlanta.vanguards@gmail.com","teamLogo":"wix:image://v1/d70539_a1ac64f2cf8848d6b0fcbee0ab844e16~mv2.png/AV%20Logo_Shield.png#originWidth=2172&originHeight=2476","logoUrl":"https://static.wixstatic.com/media/d70539_a1ac64f2cf8848d6b0fcbee0ab844e16~mv2.png","rank5v5":18,"averagePoints5v5":0.33,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":16},{"_id":"2","points":0,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":8},{"_id":"3","points":1,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":5}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":9,"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":18}]}},"members":["Sean Murray","Jake Krantz","Trevor Crow","Benjamin H Baldwin","Blake Mauldin","Nathan A Renaud","Trent Thomas Weekes","Logan Jacob Smith","Christopher Boyd","Michael Mendenhall"],"sourceCreatedAt":"2024-07-15T00:19:23.775Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Atlanta Valor',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Atlanta, GA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'atlanta.vanguards@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/736364014485567'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d70539_a1ac64f2cf8848d6b0fcbee0ab844e16~mv2.png'),
 public_description=coalesce(t.public_description,'We are Atlanta&#x27;s local armored combat team. We are relatively small, but growing, and always open to new members!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Murray','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Krantz','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Trevor Crow','captain','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin H Baldwin','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blake Mauldin','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan A Renaud','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Trent Thomas Weekes','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Jacob Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Boyd','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Mendenhall','fighter','bi_teams','https://www.buhurtinternational.com/team/atlanta-valor','atlanta-valor',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='auckland-armoured-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-auckland-armoured-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Auckland Armoured Combat','Auckland',true,'active','public','bi-auckland-armoured-combat','OC','Oceania','NZ','New Zealand','auckland.armoured.combat@gmail.com','https://www.facebook.com/dreadnoughtsbuhurt/','https://static.wixstatic.com/media/e27186_0057e14e95f74b369746419b2d66a85d~mv2.jpg','North Shore, Auckland based team. We train Buhurt, Profight and Duels (all categories) If you are interested, please see this interview we recently did: Kiwi knights do medieval battle in niche sport of buhurt | RNZ News')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','auckland-armoured-combat','https://www.buhurtinternational.com/team/auckland-armoured-combat','Auckland Armoured Combat','Auckland','auckland.armoured.combat@gmail.com','https://www.facebook.com/dreadnoughtsbuhurt/',20,'{"biCollectionId":"5df0cd6f-0edc-4e66-a966-e8643b544438","teamName":"Auckland Armoured Combat","club":null,"gender":"Male","captain":"Colm O''Brien","conference":"APAC","country":"New Zealand","city":"Auckland","teamInfo":"North Shore, Auckland based team. We train Buhurt, Profight and Duels (all categories) If you are interested, please see this interview we recently did: Kiwi knights do medieval battle in niche sport of buhurt | RNZ News","trainingInfo":"New members welcome, please message the facebook/ instagram or send us an email. We train Mondays and Wednsdays 7pm in Shane Cameron Fitness No equipment needed, softkit is provided. Please wear gym clothes. All welcome","trainingLocation":{"subdivisions":[{"code":"Auckland","name":"Auckland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Auckland","name":"Auckland","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"NZ","name":"New Zealand","type":"COUNTRY"}],"city":"Auckland","location":{"latitude":-36.8107324,"longitude":174.742522},"streetAddress":{"apt":"","formattedAddressLine":"Onewa Road","name":"Onewa Road","number":""},"formatted":"Onewa Road, Northcote, Auckland, New Zealand","country":"NZ","subdivision":"AUK"},"websiteFacebookUrl":"https://www.facebook.com/dreadnoughtsbuhurt/","teamEmail":"auckland.armoured.combat@gmail.com","teamLogo":"wix:image://v1/e27186_0057e14e95f74b369746419b2d66a85d~mv2.jpg/images.jpg#originWidth=225&originHeight=225","logoUrl":"https://static.wixstatic.com/media/e27186_0057e14e95f74b369746419b2d66a85d~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":6}]},"2025":{"remainingTokens":10}},"members":["Colm O''Brien","Benoit Delville","Ethan Wilson","Ben Cave","Llewelyn Yearbury-Murphy","Shilong Ding","Eli Braddock"],"sourceCreatedAt":"2024-06-11T09:37:15.970Z","sourceUpdatedAt":"2026-09-29T01:57:33.602Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Auckland Armoured Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Auckland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'auckland.armoured.combat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/dreadnoughtsbuhurt/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e27186_0057e14e95f74b369746419b2d66a85d~mv2.jpg'),
 public_description=coalesce(t.public_description,'North Shore, Auckland based team. We train Buhurt, Profight and Duels (all categories) If you are interested, please see this interview we recently did: Kiwi knights do medieval battle in niche sport of buhurt | RNZ News'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colm O''Brien','captain','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benoit Delville','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Wilson','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Cave','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Llewelyn Yearbury-Murphy','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shilong Ding','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eli Braddock','fighter','bi_teams','https://www.buhurtinternational.com/team/auckland-armoured-combat','auckland-armoured-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='auckland-man-o’-war' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-auckland-man-o’-war' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Auckland Man O’ War','Auckland',true,'active','public','bi-auckland-man-o’-war','OC','Oceania','NZ','New Zealand','devonsgs@gmail.com',NULL,'https://static.wixstatic.com/media/bb6828_d67f21532e2e44c5a55744abf8e04e5a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','auckland-man-o’-war','https://www.buhurtinternational.com/team/auckland-man-o%E2%80%99-war','Auckland Man O’ War','Auckland','devonsgs@gmail.com',NULL,20,'{"biCollectionId":"bd266876-a255-4f67-a7b1-90dee8b7ddaa","teamName":"Auckland Man O’ War","club":null,"gender":"Female","captain":"Devon Hansen","conference":"APAC","country":"New Zealand","city":"Auckland","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"devonsgs@gmail.com","teamLogo":"wix:image://v1/bb6828_d67f21532e2e44c5a55744abf8e04e5a~mv2.png/Man%20o%20war%20logo.png#originWidth=500&originHeight=500","logoUrl":"https://static.wixstatic.com/media/bb6828_d67f21532e2e44c5a55744abf8e04e5a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Devon Hansen"],"sourceCreatedAt":"2025-02-02T07:46:51.495Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Auckland Man O’ War',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Auckland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'devonsgs@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bb6828_d67f21532e2e44c5a55744abf8e04e5a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Devon Hansen','captain','bi_teams','https://www.buhurtinternational.com/team/auckland-man-o%E2%80%99-war','auckland-man-o’-war',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='auream-excubitores' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-auream-excubitores' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Auream Excubitores','Wavre',true,'active','public','bi-auream-excubitores','EU','Europe','BE','Belgium','aureambehourd@gmail.com','https://www.facebook.com/p/Auream-Excubitores-B%C3%A9hourd-Charleroi-100063470323976/?locale=fr_FR','https://static.wixstatic.com/media/de3c7d_647b41d67b5a497d8c2442cdaa3023ee~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','auream-excubitores','https://www.buhurtinternational.com/team/auream-excubitores','Auream Excubitores','Wavre','aureambehourd@gmail.com','https://www.facebook.com/p/Auream-Excubitores-B%C3%A9hourd-Charleroi-100063470323976/?locale=fr_FR',20,'{"biCollectionId":"ec39c660-5c10-44c8-9e5e-4c4a12984539","teamName":"Auream Excubitores","club":null,"gender":"Male","captain":"Bjorn van Wienen","conference":"Europe","country":"Belgium","city":"Wavre","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/p/Auream-Excubitores-B%C3%A9hourd-Charleroi-100063470323976/?locale=fr_FR","teamEmail":"aureambehourd@gmail.com","teamLogo":"wix:image://v1/de3c7d_647b41d67b5a497d8c2442cdaa3023ee~mv2.png/logo%20carr%C3%A9.png#originWidth=3356&originHeight=3355","logoUrl":"https://static.wixstatic.com/media/de3c7d_647b41d67b5a497d8c2442cdaa3023ee~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Van Caneghem Yannick","Bjorn van Wienen","Frédérick LAMBERT","Christophe Delinte","Thomas FERNANDEZ LISON","Tudor Craciunescu"],"sourceCreatedAt":"2026-01-26T10:10:04.142Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Auream Excubitores',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wavre',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Belgium',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'aureambehourd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/p/Auream-Excubitores-B%C3%A9hourd-Charleroi-100063470323976/?locale=fr_FR'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/de3c7d_647b41d67b5a497d8c2442cdaa3023ee~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Van Caneghem Yannick','fighter','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bjorn van Wienen','captain','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frédérick LAMBERT','fighter','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christophe Delinte','fighter','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas FERNANDEZ LISON','fighter','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tudor Craciunescu','fighter','bi_teams','https://www.buhurtinternational.com/team/auream-excubitores','auream-excubitores',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='austin-blood-guard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-austin-blood-guard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Austin Blood Guard','Austin',true,'active','public','bi-austin-blood-guard','NA','North America','US','United States','bradyawells5@yahoo.com','https://www.facebook.com/AustinBloodGuard/','https://static.wixstatic.com/media/1f3011_674fedb80fab43c3ae243266b9ed5ef7~mv2.png','We are a medieval combat team based in Austin, Texas, competing in the international sport, buhurt (full-contact armored combat). We compete in multiple formats and with multiple organizations as well as boutique, one off events.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','austin-blood-guard','https://www.buhurtinternational.com/team/austin-blood-guard','Austin Blood Guard','Austin','bradyawells5@yahoo.com','https://www.facebook.com/AustinBloodGuard/',20,'{"biCollectionId":"b6d4de50-1e69-4404-80a3-f10c4b3c6512","teamName":"Austin Blood Guard","club":null,"gender":"Male","captain":"Brady Wells","conference":"North America","country":"United States","city":"Austin","teamInfo":"We are a medieval combat team based in Austin, Texas, competing in the international sport, buhurt (full-contact armored combat). We compete in multiple formats and with multiple organizations as well as boutique, one off events.","trainingInfo":"Contact Zachary Warden or Brady Wells on facebook, or reach out to the Facebook or Instagram pages directly! Practice multiple times a week for melees, duels, and profights/outrance.","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/AustinBloodGuard/","teamEmail":"bradyawells5@yahoo.com","teamLogo":"wix:image://v1/1f3011_674fedb80fab43c3ae243266b9ed5ef7~mv2.png/BLOOD4DABLOODGUARD.png#originWidth=1290&originHeight=1720","logoUrl":"https://static.wixstatic.com/media/1f3011_674fedb80fab43c3ae243266b9ed5ef7~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":7}],"eventsHistory":{},"members":["Josh Riddle","Brady Wells","Danny Lackowski","Henry Mario Quijano-Hall","Ruston Thompson","Bryan Allred","Zachary T Warden"],"sourceCreatedAt":"2026-04-04T23:05:26.409Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Austin Blood Guard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Austin',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bradyawells5@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/AustinBloodGuard/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/1f3011_674fedb80fab43c3ae243266b9ed5ef7~mv2.png'),
 public_description=coalesce(t.public_description,'We are a medieval combat team based in Austin, Texas, competing in the international sport, buhurt (full-contact armored combat). We compete in multiple formats and with multiple organizations as well as boutique, one off events.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Riddle','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brady Wells','captain','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danny Lackowski','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henry Mario Quijano-Hall','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ruston Thompson','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryan Allred','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary T Warden','fighter','bi_teams','https://www.buhurtinternational.com/team/austin-blood-guard','austin-blood-guard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bande-nere-2' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bande-nere-2' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Bande Nere 2',NULL,true,'active','public','bi-bande-nere-2','EU','Europe','FR','France','dimitriultima@hotmail.fr',NULL,'https://static.wixstatic.com/media/488a13_eaff0f4d508c41cbbdd4d1ca2abec79e~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bande-nere-2','https://www.buhurtinternational.com/team/bande-nere-2','Bande Nere 2',NULL,'dimitriultima@hotmail.fr',NULL,20,'{"biCollectionId":"b24ac7a0-f51c-4fff-94a7-75a8390d2993","teamName":"Bande Nere 2","club":null,"gender":"Male","captain":"Dimitri Jacquet","conference":"Europe","country":"France","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"dimitriultima@hotmail.fr","teamLogo":"wix:image://v1/488a13_eaff0f4d508c41cbbdd4d1ca2abec79e~mv2.jpeg/IMG_1275.jpeg#originWidth=900&originHeight=994","logoUrl":"https://static.wixstatic.com/media/488a13_eaff0f4d508c41cbbdd4d1ca2abec79e~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":5}},"members":["Tristan Charuel","Alberto Piazza","Dimitri Jacquet","Enrico bernardeschi","Frederic Goetz","Simone ilario Bernardeschi","Vincent Vermeille"],"sourceCreatedAt":"2025-02-15T17:06:41.599Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Bande Nere 2',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'dimitriultima@hotmail.fr'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/488a13_eaff0f4d508c41cbbdd4d1ca2abec79e~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tristan Charuel','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Piazza','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dimitri Jacquet','captain','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Enrico bernardeschi','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frederic Goetz','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simone ilario Bernardeschi','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Vermeille','fighter','bi_teams','https://www.buhurtinternational.com/team/bande-nere-2','bande-nere-2',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='banished' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-banished' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Banished','Kansas City',true,'active','public','bi-banished','NA','North America','US','United States','kcarmored@gmail.com','https://www.kcac-banished.com/','https://static.wixstatic.com/media/765df7_4beaef1213d24392ac63fb9aaeff5467~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','banished','https://www.buhurtinternational.com/team/banished','Banished','Kansas City','kcarmored@gmail.com','https://www.kcac-banished.com/',20,'{"biCollectionId":"cf5f1c81-aaf2-4c9b-b61f-fda8b551cb69","teamName":"Banished","club":null,"gender":"Male","captain":"Bryan Clement","conference":"North America","country":"United States","city":"Kansas City","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.kcac-banished.com/","teamEmail":"kcarmored@gmail.com","teamLogo":"wix:image://v1/765df7_4beaef1213d24392ac63fb9aaeff5467~mv2.png/Untitled_Artwork_7_Copy_Copy_Copy.png#originWidth=2100&originHeight=2100","logoUrl":"https://static.wixstatic.com/media/765df7_4beaef1213d24392ac63fb9aaeff5467~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Bryan Clement","Dawson Grey Friend","Ethan Lowe","John kemper","Joshua L Williams","Justin MacRae","Wolfe Luse"],"sourceCreatedAt":"2026-06-08T12:54:14.573Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Banished',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Kansas City',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'kcarmored@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.kcac-banished.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/765df7_4beaef1213d24392ac63fb9aaeff5467~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryan Clement','captain','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dawson Grey Friend','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Lowe','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John kemper','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua L Williams','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin MacRae','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wolfe Luse','fighter','bi_teams','https://www.buhurtinternational.com/team/banished','banished',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='barbarians-ice' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-barbarians-ice' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Barbarians Ice','Cincinnati',true,'active','public','bi-barbarians-ice','NA','North America','US','United States','Chris@CincinnatiBarbarians.com','https://www.facebook.com/CincinnatiBarbarians','https://static.wixstatic.com/media/a40a2c_8ca82d76aa7546eb863a502d7752ba59~mv2.jpg','Cincinnati Barbarians Second Team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','barbarians-ice','https://www.buhurtinternational.com/team/barbarians-ice','Barbarians Ice','Cincinnati','Chris@CincinnatiBarbarians.com','https://www.facebook.com/CincinnatiBarbarians',20,'{"biCollectionId":"3e6cfd9f-8a51-45d8-8015-7620856babbb","teamName":"Barbarians Ice","club":null,"gender":"Male","captain":"Chris Rack","conference":"North America","country":"United States","city":"Cincinnati","teamInfo":"Cincinnati Barbarians Second Team","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/CincinnatiBarbarians","teamEmail":"Chris@CincinnatiBarbarians.com","teamLogo":"wix:image://v1/a40a2c_8ca82d76aa7546eb863a502d7752ba59~mv2.jpg/boars%20head.jpg#originWidth=1249&originHeight=1798","logoUrl":"https://static.wixstatic.com/media/a40a2c_8ca82d76aa7546eb863a502d7752ba59~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":9,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":3},{"_id":"2","points":0,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":17}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":7}},"members":["Chris Rack","Carson Rolph","Christopher Nettle","Christopher Milesky","Zachary Eggeman","Richard Smithmeyer","Regan smith","Brandon Chadwell","Donald Kay","Justin brown","Craig Casteel","William Leshley"],"sourceCreatedAt":"2025-08-01T16:20:17.784Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Barbarians Ice',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cincinnati',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Chris@CincinnatiBarbarians.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/CincinnatiBarbarians'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a40a2c_8ca82d76aa7546eb863a502d7752ba59~mv2.jpg'),
 public_description=coalesce(t.public_description,'Cincinnati Barbarians Second Team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris Rack','captain','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carson Rolph','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Nettle','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Milesky','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Eggeman','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Smithmeyer','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Regan smith','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Chadwell','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Donald Kay','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin brown','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Craig Casteel','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Leshley','fighter','bi_teams','https://www.buhurtinternational.com/team/barbarians-ice','barbarians-ice',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='basilisk' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-basilisk' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Basilisk','Piacenza ',true,'active','public','bi-basilisk','EU','Europe','IT','Italy','teambasilisk.buhurt@gmail.com','https://www.facebook.com/TheMarvelousChickenYard','https://static.wixstatic.com/media/2b0b26_a4b4705adced43c2b3861ca1a1eab719~mv2.jpg','The Marvelous Chicken Yard of Violence™')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','basilisk','https://www.buhurtinternational.com/team/basilisk','Basilisk','Piacenza ','teambasilisk.buhurt@gmail.com','https://www.facebook.com/TheMarvelousChickenYard',20,'{"biCollectionId":"680c551e-95f5-4960-a64a-ed6272ee7e19","teamName":"Basilisk","club":null,"gender":"Male","captain":"Matteo Visconti","conference":"Europe","country":"Italy","city":"Piacenza ","teamInfo":"The Marvelous Chicken Yard of Violence™","trainingInfo":"Feel free to message us on facebook and Instagram to come and train with us!","trainingLocation":{"subdivisions":[{"code":"Emilia-Romagna","name":"Emilia-Romagna","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"PC","name":"Provincia di Piacenza","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Caorso","name":"Caorso","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IT","name":"Italy","type":"COUNTRY"}],"city":"Caorso","location":{"latitude":45.0492838,"longitude":9.8734547},"streetAddress":{"apt":"","formattedAddressLine":"Via Bernardino Mandelli","name":"Via Bernardino Mandelli","number":""},"formatted":"Via Bernardino Mandelli, 29012 Caorso PC, Italy","country":"IT","postalCode":"29012","subdivision":"45"},"websiteFacebookUrl":"https://www.facebook.com/TheMarvelousChickenYard","teamEmail":"teambasilisk.buhurt@gmail.com","teamLogo":"wix:image://v1/2b0b26_a4b4705adced43c2b3861ca1a1eab719~mv2.jpg/IMG_20240212_113710.jpg#originWidth=1080&originHeight=1069","logoUrl":"https://static.wixstatic.com/media/2b0b26_a4b4705adced43c2b3861ca1a1eab719~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":9}]},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":6},{"_id":"2","points":0,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":8}]}},"members":["Matteo Visconti","Derek Paraboschi","Fabio Vernini","Giulio Castruccio","Michele Schillani","Pietro Alzapiedi","Riccardo Caprioli"],"sourceCreatedAt":"2024-02-12T10:39:11.120Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Basilisk',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Piacenza ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'teambasilisk.buhurt@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TheMarvelousChickenYard'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2b0b26_a4b4705adced43c2b3861ca1a1eab719~mv2.jpg'),
 public_description=coalesce(t.public_description,'The Marvelous Chicken Yard of Violence™'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matteo Visconti','captain','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derek Paraboschi','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabio Vernini','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Giulio Castruccio','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michele Schillani','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pietro Alzapiedi','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Riccardo Caprioli','fighter','bi_teams','https://www.buhurtinternational.com/team/basilisk','basilisk',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bastion' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bastion' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Bastion','Augusta, GA',true,'active','public','bi-bastion','NA','North America','US','United States','bastionarmoredfighting@gmail.com','https://www.facebook.com/share/JcbQ1QKQwteL4B7X/?mibextid=qi2Omg','https://static.wixstatic.com/media/7b15f2_97a31f21be714576af67842ea30c1ff5~mv2.png','Bastion Armored Fighting is an amateur martial arts/sports team, competing in Armored Fighting (HMB, AMCF, and Bohurt League). We operate in the CSRA region of Georgia and South Carolina. Many of our members are veterans, first responders, and educators.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bastion','https://www.buhurtinternational.com/team/bastion','Bastion','Augusta, GA','bastionarmoredfighting@gmail.com','https://www.facebook.com/share/JcbQ1QKQwteL4B7X/?mibextid=qi2Omg',20,'{"biCollectionId":"2e5df477-1d82-4a6c-a358-182361b2d927","teamName":"Bastion","club":null,"gender":"Male","captain":"Gregory Clayton Thomas","conference":"North America","country":"United States","city":"Augusta, GA","teamInfo":"Bastion Armored Fighting is an amateur martial arts/sports team, competing in Armored Fighting (HMB, AMCF, and Bohurt League). We operate in the CSRA region of Georgia and South Carolina. Many of our members are veterans, first responders, and educators.","trainingInfo":"Check out our Facebook for up to date info!","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/JcbQ1QKQwteL4B7X/?mibextid=qi2Omg","teamEmail":"bastionarmoredfighting@gmail.com","teamLogo":"wix:image://v1/7b15f2_97a31f21be714576af67842ea30c1ff5~mv2.png/received_801391421348884-transformed.png#originWidth=1950&originHeight=1950","logoUrl":"https://static.wixstatic.com/media/7b15f2_97a31f21be714576af67842ea30c1ff5~mv2.png","rank5v5":11,"averagePoints5v5":5.17,"points5v5":15.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":9},{"_id":"2","points":6,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":3},{"_id":"3","points":8,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"Grapes of Wrath 2024","date":"2024-05-18","category":"5vs5","place":2},{"_id":"2","points":12,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":6,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":8},{"_id":"2","points":10,"Tournament":"Tournament of Legends 2025","date":"2025-04-26","category":"5vs5","place":1},{"_id":"3","points":7,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":3}],"points12v12":0,"averagePoints5v5":7.67,"rank5v5":7,"remainingTokens":7,"points5v5":23}},"members":["Gregory Clayton Thomas","Gregory Thomas","Jeffrey Souter","Alex Moore","Blade Brooks","Michael Goulart","Dillon Typhair","Kyler Christian","Travis Goldie","Mason Mcnay"],"sourceCreatedAt":"2024-06-30T01:38:53.699Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Bastion',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Augusta, GA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bastionarmoredfighting@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/JcbQ1QKQwteL4B7X/?mibextid=qi2Omg'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7b15f2_97a31f21be714576af67842ea30c1ff5~mv2.png'),
 public_description=coalesce(t.public_description,'Bastion Armored Fighting is an amateur martial arts/sports team, competing in Armored Fighting (HMB, AMCF, and Bohurt League). We operate in the CSRA region of Georgia and South Carolina. Many of our members are veterans, first responders, and educators.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Clayton Thomas','captain','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeffrey Souter','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blade Brooks','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Goulart','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dillon Typhair','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyler Christian','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Travis Goldie','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mason Mcnay','fighter','bi_teams','https://www.buhurtinternational.com/team/bastion','bastion',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='beasts-blood-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-beasts-blood-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Beasts Blood','Brisbane',true,'active','public','bi-beasts-blood-','OC','Oceania','AU','Australia','battle@beasts.org.au',NULL,'https://static.wixstatic.com/media/71e23d_5cba440c1a3c4340a3a71cb42ad00958~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','beasts-blood-','https://www.buhurtinternational.com/team/beasts-blood-','Beasts Blood','Brisbane','battle@beasts.org.au',NULL,20,'{"biCollectionId":"31e697b2-864a-498f-b4af-ad9bdd10abb5","teamName":"Beasts Blood","club":null,"gender":"Male","captain":"Harry Bredhauer","conference":"APAC","country":"Australia","city":"Brisbane","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"QLD","name":"Queensland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Brisbane","name":"Brisbane City","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Albion","name":"Albion","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Albion","location":{"latitude":-27.431492,"longitude":153.0395262},"streetAddress":{"apt":"6","formattedAddressLine":"6/39 Corunna St","name":"Corunna Street","number":"39"},"formatted":"6/39 Corunna St, Albion QLD 4010, Australia","country":"AU","postalCode":"4010","subdivision":"QLD"},"websiteFacebookUrl":null,"teamEmail":"battle@beasts.org.au","teamLogo":"wix:image://v1/71e23d_5cba440c1a3c4340a3a71cb42ad00958~mv2.jpg/320697875_1176107250001904_4424694731480314677_n.jpg#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/71e23d_5cba440c1a3c4340a3a71cb42ad00958~mv2.jpg","rank5v5":5,"averagePoints5v5":4,"points5v5":12,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":4},{"_id":"2","points":7,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":2},{"_id":"3","points":2,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":5}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":6},{"_id":"2","points":9,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":2},{"_id":"3","points":4.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":6}],"points12v12":0,"averagePoints5v5":5.83,"rank5v5":3,"remainingTokens":8,"points5v5":17.5}},"members":["Harry bredhauer","Charles Walsh","James Betheras","Mario Brändli","James Goodwin","Alexander Stallard","Owen Heanue","Ethan","Steven Padget","Jaxon Harris"],"sourceCreatedAt":"2025-05-23T08:45:12.459Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Beasts Blood',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brisbane',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'battle@beasts.org.au'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/71e23d_5cba440c1a3c4340a3a71cb42ad00958~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Harry bredhauer','captain','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charles Walsh','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Betheras','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mario Brändli','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Goodwin','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Stallard','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Owen Heanue','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Padget','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaxon Harris','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts-blood-','beasts-blood-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='beasts(m)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-beasts(m)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Beasts(m)','Brisbane',true,'active','public','bi-beasts(m)','OC','Oceania','AU','Australia','battle@beasts.org.au','https://www.beasts.org.au','https://static.wixstatic.com/media/718dcd_c7cd1dcbf9af4b7187acbc0ba3775ed9~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','beasts(m)','https://www.buhurtinternational.com/team/beasts(m)','Beasts(m)','Brisbane','battle@beasts.org.au','https://www.beasts.org.au',20,'{"biCollectionId":"2d6ed1c3-c855-4b19-ab35-7e8aad912cc7","teamName":"Beasts(m)","club":null,"gender":"Male","captain":"Colin Campbell","conference":"APAC","country":"Australia","city":"Brisbane","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.beasts.org.au","teamEmail":"battle@beasts.org.au","teamLogo":"wix:image://v1/718dcd_c7cd1dcbf9af4b7187acbc0ba3775ed9~mv2.jpg/Beast1.jpg#originWidth=1490&originHeight=1798","logoUrl":"https://static.wixstatic.com/media/718dcd_c7cd1dcbf9af4b7187acbc0ba3775ed9~mv2.jpg","rank5v5":2,"averagePoints5v5":9,"points5v5":27,"rank12v12":null,"points12v12":10,"tournamentsJoined":[{"_id":"1","points":12,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":2},{"_id":"2","points":10,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"12vs12","place":1},{"_id":"3","points":3,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":5},{"_id":"4","points":12,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":10,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"5vs5","place":2},{"_id":"2","points":8,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"12vs12","place":1},{"_id":"3","points":13,"Tournament":"Winterfest 2024","date":"2024-07-06","category":"5vs5","place":1},{"_id":"4","points":10,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":2},{"_id":"5","points":9,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":2}]},"2025":{"points12v12":9,"points5v5":44.5,"remainingTokens":6,"tournaments":[{"_id":"1","points":28,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":1},{"_id":"2","points":9,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"12vs12","place":1},{"_id":"3","points":16.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":1}]}},"members":["Harrison Milne","Nicholas Donnan","Colin Campbell","Brendan J Toft","Jordan Alston","Samuel Wride","Cahill Lachlan Ross","Michael Steer","PHILIP RAMSKILL"],"sourceCreatedAt":"2023-08-27T00:26:42.629Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Beasts(m)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brisbane',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'battle@beasts.org.au'),
 website_url=coalesce(t.website_url,'https://www.beasts.org.au'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/718dcd_c7cd1dcbf9af4b7187acbc0ba3775ed9~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Harrison Milne','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Donnan','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colin Campbell','captain','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brendan J Toft','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Alston','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Wride','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cahill Lachlan Ross','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Steer','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PHILIP RAMSKILL','fighter','bi_teams','https://www.buhurtinternational.com/team/beasts(m)','beasts(m)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='blood-griffins' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-blood-griffins' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Blood Griffins','München, Boppard ',true,'active','public','bi-blood-griffins','EU','Europe','DE','Germany','drachensatai@web.de','https://www.facebook.com/groups/233747777275147','https://static.wixstatic.com/media/7e1e6b_a8376dfdd631499085e379d3a7977d3b~mv2.jpg','Boppard, Koblenz, München, Bonn, Aachen,')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','blood-griffins','https://www.buhurtinternational.com/team/blood-griffins','Blood Griffins','München, Boppard ','drachensatai@web.de','https://www.facebook.com/groups/233747777275147',20,'{"biCollectionId":"e56fc253-b1be-4ec4-ad7c-b35a38cca5c2","teamName":"Blood Griffins","club":null,"gender":"Female","captain":"Verena Scheidacker","conference":"Europe","country":"Germany","city":"München, Boppard ","teamInfo":"Boppard, Koblenz, München, Bonn, Aachen,","trainingInfo":"Mixed team from Germany and Austria.","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/groups/233747777275147","teamEmail":"drachensatai@web.de","teamLogo":"wix:image://v1/7e1e6b_a8376dfdd631499085e379d3a7977d3b~mv2.jpg/23843131_1560400644047804_7995596938997383740_n.jpg#originWidth=789&originHeight=839","logoUrl":"https://static.wixstatic.com/media/7e1e6b_a8376dfdd631499085e379d3a7977d3b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Verena Scheidacker","Verena Herbst","Jasmin Lara Baumgartner","Heidi Gallrapp","Irene Parlow","Katharina Rother","Melanie Gras","Fabienne Ramsak","Olga Reinartz","Yumna Wanli"],"sourceCreatedAt":"2023-08-28T05:53:28.283Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Blood Griffins',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('München, Boppard ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'drachensatai@web.de'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/233747777275147'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7e1e6b_a8376dfdd631499085e379d3a7977d3b~mv2.jpg'),
 public_description=coalesce(t.public_description,'Boppard, Koblenz, München, Bonn, Aachen,'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Verena Scheidacker','captain','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Verena Herbst','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jasmin Lara Baumgartner','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heidi Gallrapp','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Irene Parlow','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Katharina Rother','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Melanie Gras','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabienne Ramsak','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olga Reinartz','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yumna Wanli','fighter','bi_teams','https://www.buhurtinternational.com/team/blood-griffins','blood-griffins',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bloodhounds' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bloodhounds' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Bloodhounds','Princeton',true,'active','public','bi-bloodhounds','NA','North America','US','United States','jessiebartlett13@gmail.com',NULL,'https://static.wixstatic.com/media/2dfdfd_ebc26e34b1114278b89c8f1082694513~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bloodhounds','https://www.buhurtinternational.com/team/bloodhounds','Bloodhounds','Princeton','jessiebartlett13@gmail.com',NULL,20,'{"biCollectionId":"ac7f02b6-6d44-4a45-81bd-de8ae6d7021e","teamName":"Bloodhounds","club":null,"gender":"Female","captain":"Jessica Kraft","conference":"North America","country":"United States","city":"Princeton","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"jessiebartlett13@gmail.com","teamLogo":"wix:image://v1/2dfdfd_ebc26e34b1114278b89c8f1082694513~mv2.jpeg/IMG_1960.jpeg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/2dfdfd_ebc26e34b1114278b89c8f1082694513~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Jessica Kraft","Jennifer Rose","Elizabeth McKenna","Veronica Alzira Rezende","Jessica Johnson","Remi Sowemimo-Coker","Trista Eudaily"],"sourceCreatedAt":"2026-09-15T20:19:15.943Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Bloodhounds',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Princeton',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jessiebartlett13@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2dfdfd_ebc26e34b1114278b89c8f1082694513~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jessica Kraft','captain','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jennifer Rose','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elizabeth McKenna','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Veronica Alzira Rezende','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jessica Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Remi Sowemimo-Coker','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Trista Eudaily','fighter','bi_teams','https://www.buhurtinternational.com/team/bloodhounds','bloodhounds',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bmc-banshees' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bmc-banshees' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'BMC Banshees','Birmingham',true,'active','public','bi-bmc-banshees','EU','Europe','GB','United Kingdom','chloedavies700@gmail.com','https://www.facebook.com/BirminghamMedievalCombat','https://static.wixstatic.com/media/2eb991_af7fb9a97ae849d788e79f082ae6f4c9~mv2.png','Birmingham Medieval Combat is home to armoured combat sports in the West Midlands and now proudly home to BMC Banshees, the first women&#x27;s team in the region.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bmc-banshees','https://www.buhurtinternational.com/team/bmc-banshees','BMC Banshees','Birmingham','chloedavies700@gmail.com','https://www.facebook.com/BirminghamMedievalCombat',20,'{"biCollectionId":"cd52dc91-9a9e-4cf0-91f7-371511eef964","teamName":"BMC Banshees","club":null,"gender":"Female","captain":"Chloé Davies","conference":"Europe","country":"United Kingdom","city":"Birmingham","teamInfo":"Birmingham Medieval Combat is home to armoured combat sports in the West Midlands and now proudly home to BMC Banshees, the first women&#x27;s team in the region.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/BirminghamMedievalCombat","teamEmail":"chloedavies700@gmail.com","teamLogo":"wix:image://v1/2eb991_af7fb9a97ae849d788e79f082ae6f4c9~mv2.png/Untitled%20design%20(1).png#originWidth=1000&originHeight=1000","logoUrl":"https://static.wixstatic.com/media/2eb991_af7fb9a97ae849d788e79f082ae6f4c9~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Chloé Davies","Sara Mulligan","Sarah Routledge","Helen Richards"],"sourceCreatedAt":"2026-05-27T20:19:42.291Z","sourceUpdatedAt":"2026-09-28T16:53:01.226Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('BMC Banshees',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Birmingham',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'chloedavies700@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/BirminghamMedievalCombat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2eb991_af7fb9a97ae849d788e79f082ae6f4c9~mv2.png'),
 public_description=coalesce(t.public_description,'Birmingham Medieval Combat is home to armoured combat sports in the West Midlands and now proudly home to BMC Banshees, the first women&#x27;s team in the region.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chloé Davies','captain','bi_teams','https://www.buhurtinternational.com/team/bmc-banshees','bmc-banshees',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sara Mulligan','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-banshees','bmc-banshees',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarah Routledge','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-banshees','bmc-banshees',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Helen Richards','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-banshees','bmc-banshees',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bmc-vanguard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bmc-vanguard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'BMC Vanguard','Birmingham',true,'active','public','bi-bmc-vanguard','EU','Europe','GB','United Kingdom','rob.moose.morris@gmail.com','https://www.facebook.com/BirminghamMedievalCombat','https://static.wixstatic.com/media/ed3f25_ee1a9c9132e94dd7b085e825c9941fd9~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bmc-vanguard','https://www.buhurtinternational.com/team/bmc-vanguard','BMC Vanguard','Birmingham','rob.moose.morris@gmail.com','https://www.facebook.com/BirminghamMedievalCombat',20,'{"biCollectionId":"4872049b-6f10-40e9-8535-b1bce9f3185c","teamName":"BMC Vanguard","club":null,"gender":"Male","captain":"Rob Morris","conference":"Europe","country":"United Kingdom","city":"Birmingham","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/BirminghamMedievalCombat","teamEmail":"rob.moose.morris@gmail.com","teamLogo":"wix:image://v1/ed3f25_ee1a9c9132e94dd7b085e825c9941fd9~mv2.jpg/306097679_540307584561887_7731242204218869802_n.jpg#originWidth=915&originHeight=915","logoUrl":"https://static.wixstatic.com/media/ed3f25_ee1a9c9132e94dd7b085e825c9941fd9~mv2.jpg","rank5v5":7,"averagePoints5v5":4.33,"points5v5":13,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":11},{"_id":"2","points":0,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":8},{"_id":"3","points":8,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":2},{"_id":"4","points":3,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":8},{"_id":"2","points":0,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":10},{"_id":"3","points":0,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":10}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":4},{"_id":"2","points":3,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"12vs12","place":3},{"_id":"3","points":4,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":5},{"_id":"4","points":4,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":5}],"points12v12":3,"averagePoints5v5":4,"rank5v5":8,"remainingTokens":10,"points5v5":12}},"members":["Rob Morris","Alexander D Fairfield","Nigel Goddard","Robert Atkinson","Alexander Moore","Dom Spens"],"sourceCreatedAt":"2024-01-10T22:11:17.721Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('BMC Vanguard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Birmingham',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'rob.moose.morris@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/BirminghamMedievalCombat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ed3f25_ee1a9c9132e94dd7b085e825c9941fd9~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rob Morris','captain','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander D Fairfield','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nigel Goddard','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Atkinson','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dom Spens','fighter','bi_teams','https://www.buhurtinternational.com/team/bmc-vanguard','bmc-vanguard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='bober-krv' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-bober-krv' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'BOBER KRV','Warsaw',true,'active','public','bi-bober-krv','EU','Europe','PL','Poland','aznar_1990@o2.pl',NULL,'https://static.wixstatic.com/media/9529a3_01998f605615404fbed3b9534fea982e~mv2.png','Nom nom nom')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','bober-krv','https://www.buhurtinternational.com/team/bober-krv','BOBER KRV','Warsaw','aznar_1990@o2.pl',NULL,20,'{"biCollectionId":"0eee1be2-8472-4664-a674-86b812e0ad05","teamName":"BOBER KRV","club":null,"gender":"Male","captain":"Alejandro Blausz","conference":"Europe","country":"Poland","city":"Warsaw","teamInfo":"Nom nom nom","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"PL","name":"Poland","type":"COUNTRY"}],"location":{"latitude":51.919438,"longitude":19.145136},"streetAddress":{"apt":"","formattedAddressLine":"Poland","name":"","number":""},"formatted":"Poland","country":"PL"},"websiteFacebookUrl":null,"teamEmail":"aznar_1990@o2.pl","teamLogo":"wix:image://v1/9529a3_01998f605615404fbed3b9534fea982e~mv2.png/bober%20kwadrat.PNG#originWidth=459&originHeight=479","logoUrl":"https://static.wixstatic.com/media/9529a3_01998f605615404fbed3b9534fea982e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":8,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":7},{"_id":"2","points":7,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":3}],"eventsHistory":{},"members":["Alejandro Blausz","Michał Wszołek"],"sourceCreatedAt":"2026-01-21T21:30:11.203Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('BOBER KRV',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Warsaw',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'aznar_1990@o2.pl'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9529a3_01998f605615404fbed3b9534fea982e~mv2.png'),
 public_description=coalesce(t.public_description,'Nom nom nom'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alejandro Blausz','captain','bi_teams','https://www.buhurtinternational.com/team/bober-krv','bober-krv',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michał Wszołek','fighter','bi_teams','https://www.buhurtinternational.com/team/bober-krv','bober-krv',now());
end $$;
commit;
