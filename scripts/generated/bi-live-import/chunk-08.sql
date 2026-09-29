begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ruthless-rabbits' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ruthless-rabbits' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ruthless Rabbits','Croydon',true,'active','public','bi-ruthless-rabbits','OC','Oceania','AU','Australia','ruthlessrabbitsbuhurt@gmail.com','https://ruthlessrabbitsbuhurt.com/','https://static.wixstatic.com/media/374375_a111cc14492d4c46b17240d6a862c759~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ruthless-rabbits','https://www.buhurtinternational.com/team/ruthless-rabbits','Ruthless Rabbits','Croydon','ruthlessrabbitsbuhurt@gmail.com','https://ruthlessrabbitsbuhurt.com/',20,'{"biCollectionId":"a3ade6a9-5625-4cda-bbf3-7591e0b2bdca","teamName":"Ruthless Rabbits","club":null,"gender":"Male","captain":"Reece Wiley Oughtred","conference":"APAC","country":"Australia","city":"Croydon","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"VIC","name":"Victoria","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Maroondah","name":"Maroondah City","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Croydon","name":"Croydon","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Croydon","location":{"latitude":-37.7947003,"longitude":145.2859497},"streetAddress":{"apt":"","formattedAddressLine":"16-18 Windsor Rd","name":"Windsor Road","number":"16-18"},"formatted":"16-18 Windsor Rd, Croydon VIC 3136, Australia","country":"AU","postalCode":"3136","subdivision":"VIC"},"websiteFacebookUrl":"https://ruthlessrabbitsbuhurt.com/","teamEmail":"ruthlessrabbitsbuhurt@gmail.com","teamLogo":"wix:image://v1/374375_a111cc14492d4c46b17240d6a862c759~mv2.png/Ruth%20Less%20Final%20SHR%20(1).png#originWidth=2471&originHeight=3009","logoUrl":"https://static.wixstatic.com/media/374375_a111cc14492d4c46b17240d6a862c759~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Axefest 3 (Melbourne Renfair tournament) 2026","date":"2026-05-16","category":"5vs5","place":4},{"_id":"2","points":1,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":6}],"eventsHistory":{},"members":["Jonathon Lyons","Punitha Manchanayake","Dylan T Morris","Reece Wiley Oughtred","Jake Timpano","Joshua Gordon","Harvey Paul Sloan","Jesse Templeton","Mitchell Coombes","James Ross"],"sourceCreatedAt":"2026-04-26T11:41:25.873Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ruthless Rabbits',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Croydon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ruthlessrabbitsbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,'https://ruthlessrabbitsbuhurt.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/374375_a111cc14492d4c46b17240d6a862c759~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathon Lyons','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Punitha Manchanayake','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan T Morris','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Reece Wiley Oughtred','captain','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Timpano','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Gordon','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Harvey Paul Sloan','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesse Templeton','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mitchell Coombes','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Ross','fighter','bi_teams','https://www.buhurtinternational.com/team/ruthless-rabbits','ruthless-rabbits',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='s.a.w.' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-s.a.w.' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'S.A.W.','Spain',true,'active','public','bi-s.a.w.','EU','Europe','ES','Spain','yvonne.p.widin@gmail.com',NULL,'https://static.wixstatic.com/media/c9a20d_dae1331acff3489ab54e5cea97c567bf~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','s.a.w.','https://www.buhurtinternational.com/team/s.a.w.','S.A.W.','Spain','yvonne.p.widin@gmail.com',NULL,20,'{"biCollectionId":"301939cb-6838-40d3-bbe3-ceb5bbbbfce0","teamName":"S.A.W.","club":null,"gender":"Female","captain":"Yvonne Widin","conference":"Europe","country":"Spain","city":"Spain","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"yvonne.p.widin@gmail.com","teamLogo":"wix:image://v1/c9a20d_dae1331acff3489ab54e5cea97c567bf~mv2.jpeg/IMG_8086.jpeg#originWidth=926&originHeight=913","logoUrl":"https://static.wixstatic.com/media/c9a20d_dae1331acff3489ab54e5cea97c567bf~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["Yvonne Widin"],"sourceCreatedAt":"2024-09-03T10:29:14.482Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('S.A.W.',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Spain',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'yvonne.p.widin@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c9a20d_dae1331acff3489ab54e5cea97c567bf~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yvonne Widin','captain','bi_teams','https://www.buhurtinternational.com/team/s.a.w.','s.a.w.',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='säbelrassler' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-säbelrassler' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Säbelrassler','Winterthur',true,'active','public','bi-säbelrassler','EU','Europe','CH','Switzerland','info@saebelrassler.ch','https://www.saebelrassler.ch/','https://static.wixstatic.com/media/8e5f21_b98d3d8a1942416499a30a665df253f8~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','säbelrassler','https://www.buhurtinternational.com/team/s%C3%A4belrassler','Säbelrassler','Winterthur','info@saebelrassler.ch','https://www.saebelrassler.ch/',20,'{"biCollectionId":"1da4aac8-f1f9-4831-b351-e0825da98862","teamName":"Säbelrassler","club":null,"gender":"Male","captain":"sandro kaempf","conference":"Europe","country":"Switzerland","city":"Winterthur","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"ZH","name":"Zürich","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Bezirk Winterthur","name":"Bezirk Winterthur","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Winterthur","name":"Winterthur","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"CH","name":"Switzerland","type":"COUNTRY"}],"city":"Winterthur","location":{"latitude":47.5104607,"longitude":8.7614966},"streetAddress":{"apt":"","formattedAddressLine":"Hegmattenstrasse 24","name":"Hegmattenstrasse","number":"24"},"formatted":"Hegmattenstrasse 24, 8404 Winterthur, Switzerland","country":"CH","postalCode":"8404","subdivision":"ZH"},"websiteFacebookUrl":"https://www.saebelrassler.ch/","teamEmail":"info@saebelrassler.ch","teamLogo":"wix:image://v1/8e5f21_b98d3d8a1942416499a30a665df253f8~mv2.jpg/05a5e884-8f1a-4b02-adbd-e2e95647dc6b.jpg#originWidth=2560&originHeight=762","logoUrl":"https://static.wixstatic.com/media/8e5f21_b98d3d8a1942416499a30a665df253f8~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":10,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":6},{"_id":"2","points":8,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":3}],"eventsHistory":{},"members":["sandro kaempf","Sandro Kämpf","Sandro Fankhauser","Christoph Stutz","Michael Strasser","Arvid Gahsche","Sebastian Jakob Hug","Silas Schilling","Roland Schmid","Pierre Bienger","Tim Löbbecke","Christian Hensen","Joshua Zumstein"],"sourceCreatedAt":"2026-01-09T11:25:58.481Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Säbelrassler',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Winterthur',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CH',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Switzerland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@saebelrassler.ch'),
 website_url=coalesce(t.website_url,'https://www.saebelrassler.ch/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8e5f21_b98d3d8a1942416499a30a665df253f8~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'sandro kaempf','captain','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sandro Kämpf','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sandro Fankhauser','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christoph Stutz','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Strasser','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arvid Gahsche','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Jakob Hug','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silas Schilling','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roland Schmid','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pierre Bienger','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim Löbbecke','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christian Hensen','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Zumstein','fighter','bi_teams','https://www.buhurtinternational.com/team/s%C3%A4belrassler','säbelrassler',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sala-de-armas-carranza' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sala-de-armas-carranza' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sala de Armas Carranza','Madrid',true,'active','public','bi-sala-de-armas-carranza','EU','Europe','ES','Spain','rodrigo.gonzalezayala@gmail.com','https://salacarranza.com','https://static.wixstatic.com/media/a47fb6_bbf022ea7b4444208d27899b150e5f29~mv2.png','We are a HEMA and Buhurt Duels located in Madrid, Spain.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sala-de-armas-carranza','https://www.buhurtinternational.com/team/sala-de-armas-carranza','Sala de Armas Carranza','Madrid','rodrigo.gonzalezayala@gmail.com','https://salacarranza.com',20,'{"biCollectionId":"6d4aad58-baba-4349-aa3b-b38f74076ef6","teamName":"Sala de Armas Carranza","club":null,"gender":"Male","captain":"Rodrigo Gonzalez Ayala","conference":"Europe","country":"Spain","city":"Madrid","teamInfo":"We are a HEMA and Buhurt Duels located in Madrid, Spain.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"MD","name":"Comunidad de Madrid","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"M","name":"Madrid","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Madrid","name":"Madrid","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"ES","name":"Spain","type":"COUNTRY"}],"city":"Madrid","location":{"latitude":40.4380287,"longitude":-3.6440079},"streetAddress":{"apt":"","formattedAddressLine":"C. de Virgen de Lluc, 73","name":"Calle de Virgen de Lluc","number":"73"},"formatted":"C. de Virgen de Lluc, 73, Cdad. Lineal, 28027 Madrid, Spain","country":"ES","postalCode":"28027","subdivision":"MD"},"websiteFacebookUrl":"https://salacarranza.com","teamEmail":"rodrigo.gonzalezayala@gmail.com","teamLogo":"wix:image://v1/a47fb6_bbf022ea7b4444208d27899b150e5f29~mv2.png/logo.png#originWidth=968&originHeight=975","logoUrl":"https://static.wixstatic.com/media/a47fb6_bbf022ea7b4444208d27899b150e5f29~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Rodrigo Gonzalez Ayala","RODRIGO BECERRA ROJO","Borja Uría Linacero","Sheng-Nong Tran Quyen","Jesús García Razquin","Pablo García Téllez","Jose Diez","Luis Garcia de la Cruz Garcia","Luis Manuel García Simón","Daniel Arribas","Alberto González Meléndez","Jose Maria Gutierrez Laso"],"sourceCreatedAt":"2024-05-18T14:21:24.242Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sala de Armas Carranza',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Madrid',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'rodrigo.gonzalezayala@gmail.com'),
 website_url=coalesce(t.website_url,'https://salacarranza.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a47fb6_bbf022ea7b4444208d27899b150e5f29~mv2.png'),
 public_description=coalesce(t.public_description,'We are a HEMA and Buhurt Duels located in Madrid, Spain.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rodrigo Gonzalez Ayala','captain','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'RODRIGO BECERRA ROJO','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Borja Uría Linacero','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sheng-Nong Tran Quyen','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesús García Razquin','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pablo García Téllez','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Diez','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Garcia de la Cruz Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Manuel García Simón','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Arribas','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto González Meléndez','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Maria Gutierrez Laso','fighter','bi_teams','https://www.buhurtinternational.com/team/sala-de-armas-carranza','sala-de-armas-carranza',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='san-giorgio-fight-team' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-san-giorgio-fight-team' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'SAN GIORGIO FIGHT TEAM','Genova',true,'active','public','bi-san-giorgio-fight-team','EU','Europe','IT','Italy','sangiorgiofightteam@gmail.com','https://www.facebook.com/share/wW9zPiCFnExwJidv/','https://static.wixstatic.com/media/3c08e6_c661cad00a8c4d7187ff3954146b70d1~mv2.png','SAN GIORGIO F.T. Il San Giorgio F.T. nasce nel 2012 come squadra sportiva di scherma storica e combattimento medievale, iscritta allo CSEN (Centro Sportivo Educativo Nazionale), ente riconosciuto dal CONI. Il San Giorgio combatte in armatura con i colori di Genova ed orgogliosamente li porta nel mondo medievale. Nel suo palmares ha numerosi tornei italiani ed europei vinti, cinque partecipazioni ai Campionati Mondiali di combattimento medievale nelle categorie del 1 contro 1 e del Massivall Battle (5 contro 5 e 21 contro 21), durante i quali ha stabilito il record di piazzamento tra le squadre italiane e la partecipazione a prestigiosi tornei internazionali come la Dinamo Cup, che si svolge ogni anno a Mosca. Parallelamente al lavoro sportivo che riguarda i combattimenti in armatura, svolge attività culturali legate al medioevo. Tante sono le partecipazioni a rievocazioni storiche in giro per l&#x27;Italia e numerose le collaborazioni con enti museali e scuole, in cui sono stati proposti e realizzati laboratori divulgativi e visite guidate. Per quanto riguarda l&#x27;equipaggiamento e le armature abbiamo come riferimento tre periodi storici differenti: • dall&#x27;inizio del 1200 fino al 1350 • 1400 • fine 1500 Il nostro gruppo conta una decina di combattenti in armatura, più un&#x27;altra decina di persone tra uomini e donne, in abito storico. Le principali attività sono: combattimento sportivo, combattimento scenico (show fighting), spettacolo e intrattenimento teatrale, laboratori a tema medievale (di tipo scolastico o divulgativo) e ricostruzione storica (sia degli abiti e delle armature che della vita comune o dei combattimenti). Ogni anno partecipiamo a numerosi eventi e iniziative cittadine con la partecipazione del comune di Genova e la regione, in particolare quest&#x27;anno con il programma Genova 2024 l&#x27;associazione é stata coinvolta a numerose manifestazioni sia di carattere storico che di carattere sportivo. Contatti: Mail: sangiorgiofightteam@gmail.com Numero +39 345 444 7053')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','san-giorgio-fight-team','https://www.buhurtinternational.com/team/san-giorgio-fight-team','SAN GIORGIO FIGHT TEAM','Genova','sangiorgiofightteam@gmail.com','https://www.facebook.com/share/wW9zPiCFnExwJidv/',20,'{"biCollectionId":"5d172ad7-9820-4ca9-96f5-56dd785fed50","teamName":"SAN GIORGIO FIGHT TEAM","club":null,"gender":"Male","captain":"Alberto Piazza","conference":"Europe","country":"Italy","city":"Genova","teamInfo":"SAN GIORGIO F.T. Il San Giorgio F.T. nasce nel 2012 come squadra sportiva di scherma storica e combattimento medievale, iscritta allo CSEN (Centro Sportivo Educativo Nazionale), ente riconosciuto dal CONI. Il San Giorgio combatte in armatura con i colori di Genova ed orgogliosamente li porta nel mondo medievale. Nel suo palmares ha numerosi tornei italiani ed europei vinti, cinque partecipazioni ai Campionati Mondiali di combattimento medievale nelle categorie del 1 contro 1 e del Massivall Battle (5 contro 5 e 21 contro 21), durante i quali ha stabilito il record di piazzamento tra le squadre italiane e la partecipazione a prestigiosi tornei internazionali come la Dinamo Cup, che si svolge ogni anno a Mosca. Parallelamente al lavoro sportivo che riguarda i combattimenti in armatura, svolge attività culturali legate al medioevo. Tante sono le partecipazioni a rievocazioni storiche in giro per l&#x27;Italia e numerose le collaborazioni con enti museali e scuole, in cui sono stati proposti e realizzati laboratori divulgativi e visite guidate. Per quanto riguarda l&#x27;equipaggiamento e le armature abbiamo come riferimento tre periodi storici differenti: • dall&#x27;inizio del 1200 fino al 1350 • 1400 • fine 1500 Il nostro gruppo conta una decina di combattenti in armatura, più un&#x27;altra decina di persone tra uomini e donne, in abito storico. Le principali attività sono: combattimento sportivo, combattimento scenico (show fighting), spettacolo e intrattenimento teatrale, laboratori a tema medievale (di tipo scolastico o divulgativo) e ricostruzione storica (sia degli abiti e delle armature che della vita comune o dei combattimenti). Ogni anno partecipiamo a numerosi eventi e iniziative cittadine con la partecipazione del comune di Genova e la regione, in particolare quest&#x27;anno con il programma Genova 2024 l&#x27;associazione é stata coinvolta a numerose manifestazioni sia di carattere storico che di carattere sportivo. Contatti: Mail: sangiorgiofightteam@gmail.com Numero +39 345 444 7053","trainingInfo":"Se anche tu voi imparare a combattere e vestire i colori del San Giorgio e della Nazionale Italiana di combattimento medievale vieni a conoscerci! ⚔️ Fight with us !!! 🌐 Visita il sito: https://san-giorgio-fight-team.super.site/ 🇮🇹 Contatta il nostro responsabile : +39 345 444 7053 📨 Oppure Scrivici: sangiorgiofightteam@gmail.com 📷 E metti like sulle nostre pagine Instagram","trainingLocation":{"subdivisions":[{"code":"Liguria","name":"Liguria","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"GE","name":"Città Metropolitana di Genova","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Genova","name":"Genova","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IT","name":"Italy","type":"COUNTRY"}],"city":"Genova","location":{"latitude":44.4058778,"longitude":8.933525099999999},"streetAddress":{"apt":"","formattedAddressLine":"Vico delle Carabaghe","name":"Vico delle Carabaghe","number":""},"formatted":"Vico delle Carabaghe, 16123 Genova GE, Italy","country":"IT","postalCode":"16123","subdivision":"42"},"websiteFacebookUrl":"https://www.facebook.com/share/wW9zPiCFnExwJidv/","teamEmail":"sangiorgiofightteam@gmail.com","teamLogo":"wix:image://v1/3c08e6_c661cad00a8c4d7187ff3954146b70d1~mv2.png/file_00000000cd187243a10c803744f04042.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/3c08e6_c661cad00a8c4d7187ff3954146b70d1~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":8,"tournaments":[{"_id":"1","points":1,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":7}]}},"members":["Alberto Piazza","Alberto Ponte","Stefano Vittoria","Ivan Tiscornia","Umberto Argentano","Marco Vircillo","Pietro Mameli","Riccardo Sghedoni","Damiano Di Palma","Roberto Carrieri","Francesco Fariello"],"sourceCreatedAt":"2024-10-11T08:34:04.235Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('SAN GIORGIO FIGHT TEAM',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Genova',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'sangiorgiofightteam@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/wW9zPiCFnExwJidv/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3c08e6_c661cad00a8c4d7187ff3954146b70d1~mv2.png'),
 public_description=coalesce(t.public_description,'SAN GIORGIO F.T. Il San Giorgio F.T. nasce nel 2012 come squadra sportiva di scherma storica e combattimento medievale, iscritta allo CSEN (Centro Sportivo Educativo Nazionale), ente riconosciuto dal CONI. Il San Giorgio combatte in armatura con i colori di Genova ed orgogliosamente li porta nel mondo medievale. Nel suo palmares ha numerosi tornei italiani ed europei vinti, cinque partecipazioni ai Campionati Mondiali di combattimento medievale nelle categorie del 1 contro 1 e del Massivall Battle (5 contro 5 e 21 contro 21), durante i quali ha stabilito il record di piazzamento tra le squadre italiane e la partecipazione a prestigiosi tornei internazionali come la Dinamo Cup, che si svolge ogni anno a Mosca. Parallelamente al lavoro sportivo che riguarda i combattimenti in armatura, svolge attività culturali legate al medioevo. Tante sono le partecipazioni a rievocazioni storiche in giro per l&#x27;Italia e numerose le collaborazioni con enti museali e scuole, in cui sono stati proposti e realizzati laboratori divulgativi e visite guidate. Per quanto riguarda l&#x27;equipaggiamento e le armature abbiamo come riferimento tre periodi storici differenti: • dall&#x27;inizio del 1200 fino al 1350 • 1400 • fine 1500 Il nostro gruppo conta una decina di combattenti in armatura, più un&#x27;altra decina di persone tra uomini e donne, in abito storico. Le principali attività sono: combattimento sportivo, combattimento scenico (show fighting), spettacolo e intrattenimento teatrale, laboratori a tema medievale (di tipo scolastico o divulgativo) e ricostruzione storica (sia degli abiti e delle armature che della vita comune o dei combattimenti). Ogni anno partecipiamo a numerosi eventi e iniziative cittadine con la partecipazione del comune di Genova e la regione, in particolare quest&#x27;anno con il programma Genova 2024 l&#x27;associazione é stata coinvolta a numerose manifestazioni sia di carattere storico che di carattere sportivo. Contatti: Mail: sangiorgiofightteam@gmail.com Numero +39 345 444 7053'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Piazza','captain','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Ponte','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stefano Vittoria','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Tiscornia','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Umberto Argentano','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco Vircillo','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pietro Mameli','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Riccardo Sghedoni','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damiano Di Palma','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roberto Carrieri','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesco Fariello','fighter','bi_teams','https://www.buhurtinternational.com/team/san-giorgio-fight-team','san-giorgio-fight-team',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='san-jacinto-knights' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-san-jacinto-knights' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'San Jacinto Knights','Houston',true,'active','public','bi-san-jacinto-knights','NA','North America','US','United States','Coxr48@gmail.com',NULL,'https://static.wixstatic.com/media/220486_86b84ca4e45e47f781f6a5c17491ca0e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','san-jacinto-knights','https://www.buhurtinternational.com/team/san-jacinto-knights','San Jacinto Knights','Houston','Coxr48@gmail.com',NULL,20,'{"biCollectionId":"1b149cf7-e033-4114-aab8-bea4ec63a4ea","teamName":"San Jacinto Knights","club":null,"gender":"Male","captain":"Tanner Cox","conference":"North America","country":"United States","city":"Houston","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"6245 Brookhill Dr unit 4, Houston, TX 77087"},"websiteFacebookUrl":null,"teamEmail":"Coxr48@gmail.com","teamLogo":"wix:image://v1/220486_86b84ca4e45e47f781f6a5c17491ca0e~mv2.png/Malteserkreuz.svg.png#originWidth=440&originHeight=440","logoUrl":"https://static.wixstatic.com/media/220486_86b84ca4e45e47f781f6a5c17491ca0e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Tanner Cox","Dylan Tatum","Thomas J Tice","Sam Thompson","NICHOLAS DAHL","Jacob Nickell","Taylor vance jones"],"sourceCreatedAt":"2024-07-13T01:06:21.924Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('San Jacinto Knights',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Houston',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Coxr48@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/220486_86b84ca4e45e47f781f6a5c17491ca0e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tanner Cox','captain','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Tatum','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas J Tice','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sam Thompson','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'NICHOLAS DAHL','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Nickell','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taylor vance jones','fighter','bi_teams','https://www.buhurtinternational.com/team/san-jacinto-knights','san-jacinto-knights',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sanctis-draconis-petrocoria' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sanctis-draconis-petrocoria' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sanctis Draconis Petrocoria','Grignols',true,'active','public','bi-sanctis-draconis-petrocoria','EU','Europe','FR','France','sanctisdraconispetrocoria@gmail.com','https://www.sanctisdraconispetrocoria.com/','https://static.wixstatic.com/media/7afbc5_448b248953834270a812facb57b4ca79~mv2.png','[FR] - Sanctis Draconis Petrocoria est une équipe de combattants médiévaux de Dordogne ayant pour but de participer aux tournois de Béhourd et Pro-fight. [EN] - Sanctis Draconis Petrocoria is a team of medieval fighters from Dordogne (FRANCE) aiming to participate in the Buhurt and Pro-fight tournaments.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sanctis-draconis-petrocoria','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','Sanctis Draconis Petrocoria','Grignols','sanctisdraconispetrocoria@gmail.com','https://www.sanctisdraconispetrocoria.com/',20,'{"biCollectionId":"bdc11e68-891b-4e26-ab77-87e706824b63","teamName":"Sanctis Draconis Petrocoria","club":null,"gender":"Male","captain":"Guillaume LEYMARIE","conference":"Europe","country":"France","city":"Grignols","teamInfo":"[FR] - Sanctis Draconis Petrocoria est une équipe de combattants médiévaux de Dordogne ayant pour but de participer aux tournois de Béhourd et Pro-fight. [EN] - Sanctis Draconis Petrocoria is a team of medieval fighters from Dordogne (FRANCE) aiming to participate in the Buhurt and Pro-fight tournaments.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Nouvelle-Aquitaine","name":"Nouvelle-Aquitaine","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Dordogne","name":"Dordogne","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Grignols","name":"Grignols","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Grignols","location":{"latitude":45.083183,"longitude":0.53955},"streetAddress":{"apt":"","formattedAddressLine":"Grignols","name":"","number":""},"formatted":"24110 Grignols, France","country":"FR","postalCode":"24110","subdivision":"NAQ"},"websiteFacebookUrl":"https://www.sanctisdraconispetrocoria.com/","teamEmail":"sanctisdraconispetrocoria@gmail.com","teamLogo":"wix:image://v1/7afbc5_448b248953834270a812facb57b4ca79~mv2.png/470372942244037-transformed%201.png#originWidth=474&originHeight=592","logoUrl":"https://static.wixstatic.com/media/7afbc5_448b248953834270a812facb57b4ca79~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Guillaume LEYMARIE","Guillaume dessommes","Ludovic CHALMET","Sciacca bastien","Leymarie guillaume","legeay jimmy","Jerome Coulonnier","Tom TILLIER","PASQUET Quentin","Otynshinov Rakhim"],"sourceCreatedAt":"2024-06-29T14:46:35.460Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sanctis Draconis Petrocoria',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Grignols',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'sanctisdraconispetrocoria@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.sanctisdraconispetrocoria.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7afbc5_448b248953834270a812facb57b4ca79~mv2.png'),
 public_description=coalesce(t.public_description,'[FR] - Sanctis Draconis Petrocoria est une équipe de combattants médiévaux de Dordogne ayant pour but de participer aux tournois de Béhourd et Pro-fight. [EN] - Sanctis Draconis Petrocoria is a team of medieval fighters from Dordogne (FRANCE) aiming to participate in the Buhurt and Pro-fight tournaments.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume LEYMARIE','captain','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume dessommes','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ludovic CHALMET','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sciacca bastien','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leymarie guillaume','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'legeay jimmy','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerome Coulonnier','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tom TILLIER','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PASQUET Quentin','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Otynshinov Rakhim','fighter','bi_teams','https://www.buhurtinternational.com/team/sanctis-draconis-petrocoria','sanctis-draconis-petrocoria',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='santau' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-santau' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'SANTAU','Condove',true,'active','public','bi-santau','EU','Europe','IT','Italy','lucadavi.blondie@gmail.com',NULL,'https://static.wixstatic.com/media/26fa3b_6e4731c0f872484695fa090eae632f1b~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','santau','https://www.buhurtinternational.com/team/santau','SANTAU','Condove','lucadavi.blondie@gmail.com',NULL,20,'{"biCollectionId":"2bbc6e6b-f45b-4801-bbaa-63acb7e71a3e","teamName":"SANTAU","club":null,"gender":"Male","captain":"Luca Davi","conference":"Europe","country":"Italy","city":"Condove","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"lucadavi.blondie@gmail.com","teamLogo":"wix:image://v1/26fa3b_6e4731c0f872484695fa090eae632f1b~mv2.jpg/Screenshot_20241006_073631_com_android_chrome_ChromeTabbedActivity.jpg#originWidth=679&originHeight=631","logoUrl":"https://static.wixstatic.com/media/26fa3b_6e4731c0f872484695fa090eae632f1b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":12}]},"2025":{"remainingTokens":10}},"members":["Luca Davi"],"sourceCreatedAt":"2024-10-13T11:44:31.172Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('SANTAU',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Condove',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lucadavi.blondie@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/26fa3b_6e4731c0f872484695fa090eae632f1b~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Davi','captain','bi_teams','https://www.buhurtinternational.com/team/santau','santau',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='scania-jacks' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-scania-jacks' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Scania Jacks','Klippan',true,'active','public','bi-scania-jacks','EU','Europe','SE','Sweden','Loke88juul@gmail.com','https://www.facebook.com/ScaniaJacks/','https://static.wixstatic.com/media/90b050_38edcc152d4543da828347f84999eece~mv2.jpg','Scania Jacks is a Swedish buhurt club statione in Klippan municipality. The club has been active since 2015. With members competitions in both IMCF and BofN. But as of now 2025 the team&#x27;s focus is to compete in BI with a focus of 5vs5.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','scania-jacks','https://www.buhurtinternational.com/team/scania-jacks','Scania Jacks','Klippan','Loke88juul@gmail.com','https://www.facebook.com/ScaniaJacks/',20,'{"biCollectionId":"31b26213-6087-4d87-b3b9-bba7ed7debc9","teamName":"Scania Jacks","club":null,"gender":"Male","captain":"Loke Juul","conference":"Europe","country":"Sweden","city":"Klippan","teamInfo":"Scania Jacks is a Swedish buhurt club statione in Klippan municipality. The club has been active since 2015. With members competitions in both IMCF and BofN. But as of now 2025 the team&#x27;s focus is to compete in BI with a focus of 5vs5.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/ScaniaJacks/","teamEmail":"Loke88juul@gmail.com","teamLogo":"wix:image://v1/90b050_38edcc152d4543da828347f84999eece~mv2.jpg/307995356_472877168216999_472153207406119085_n.jpg#originWidth=816&originHeight=816","logoUrl":"https://static.wixstatic.com/media/90b050_38edcc152d4543da828347f84999eece~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Loke Juul","Jonathan fjeldly","Hampus Lilja","Robbin","Sebastian Jönsson","Oernulf Isaksen","Erik Lundh","Joakim Nilsson","Johan Lundh"],"sourceCreatedAt":"2023-12-28T16:38:07.332Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Scania Jacks',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Klippan',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('SE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Sweden',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Loke88juul@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ScaniaJacks/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/90b050_38edcc152d4543da828347f84999eece~mv2.jpg'),
 public_description=coalesce(t.public_description,'Scania Jacks is a Swedish buhurt club statione in Klippan municipality. The club has been active since 2015. With members competitions in both IMCF and BofN. But as of now 2025 the team&#x27;s focus is to compete in BI with a focus of 5vs5.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Loke Juul','captain','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan fjeldly','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hampus Lilja','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robbin','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Jönsson','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oernulf Isaksen','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erik Lundh','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joakim Nilsson','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johan Lundh','fighter','bi_teams','https://www.buhurtinternational.com/team/scania-jacks','scania-jacks',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='scania-jacquettes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-scania-jacquettes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Scania Jacquettes',NULL,true,'active','public','bi-scania-jacquettes','EU','Europe','SE','Sweden','exploringbuhurt@gmail.com',NULL,'https://static.wixstatic.com/media/b8ff0e_07b72f6e5b0b4a8296321cb578beef6b~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','scania-jacquettes','https://www.buhurtinternational.com/team/scania-jacquettes','Scania Jacquettes',NULL,'exploringbuhurt@gmail.com',NULL,20,'{"biCollectionId":"30af2ccd-06f5-42e9-b9a9-7b458195ec95","teamName":"Scania Jacquettes","club":null,"gender":"Female","captain":"Hannah Dahlgren","conference":"Europe","country":"Sweden","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"exploringbuhurt@gmail.com","teamLogo":"wix:image://v1/b8ff0e_07b72f6e5b0b4a8296321cb578beef6b~mv2.png/2_20260324_174426_0001.png#originWidth=6250&originHeight=5106","logoUrl":"https://static.wixstatic.com/media/b8ff0e_07b72f6e5b0b4a8296321cb578beef6b~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Hannah Dahlgren"],"sourceCreatedAt":"2026-04-03T18:48:54.606Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Scania Jacquettes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('SE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Sweden',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'exploringbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b8ff0e_07b72f6e5b0b4a8296321cb578beef6b~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hannah Dahlgren','captain','bi_teams','https://www.buhurtinternational.com/team/scania-jacquettes','scania-jacquettes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='scarlet-tempest' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-scarlet-tempest' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Scarlet Tempest','Missoula',true,'active','public','bi-scarlet-tempest','NA','North America','US','United States','markigracecrowe@gmail.com',NULL,'https://static.wixstatic.com/media/fcaeda_dd50eab9b4414e0cac7531d2d3b0297c~mv2.png','Ladies team counterpart to Pale Tempest')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','scarlet-tempest','https://www.buhurtinternational.com/team/scarlet-tempest','Scarlet Tempest','Missoula','markigracecrowe@gmail.com',NULL,20,'{"biCollectionId":"d829b229-f75e-4b22-987d-bbb8534d1c9c","teamName":"Scarlet Tempest","club":null,"gender":"Female","captain":"Eliza Barton","conference":"North America","country":"United States","city":"Missoula","teamInfo":"Ladies team counterpart to Pale Tempest","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"markigracecrowe@gmail.com","teamLogo":"wix:image://v1/fcaeda_dd50eab9b4414e0cac7531d2d3b0297c~mv2.png/mornt-3.png#originWidth=2000&originHeight=2000","logoUrl":"https://static.wixstatic.com/media/fcaeda_dd50eab9b4414e0cac7531d2d3b0297c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Melicia Alice Clark","Marki Olson","Jennelle Brunner","Ashley Hansen","Kyla Hiser","Jenni Young","Elisa Elder","Eliza Barton"],"sourceCreatedAt":"2026-05-31T22:17:49.250Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Scarlet Tempest',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Missoula',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'markigracecrowe@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/fcaeda_dd50eab9b4414e0cac7531d2d3b0297c~mv2.png'),
 public_description=coalesce(t.public_description,'Ladies team counterpart to Pale Tempest'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Melicia Alice Clark','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marki Olson','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jennelle Brunner','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ashley Hansen','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyla Hiser','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jenni Young','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elisa Elder','fighter','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eliza Barton','captain','bi_teams','https://www.buhurtinternational.com/team/scarlet-tempest','scarlet-tempest',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='schwarzkittel' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-schwarzkittel' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Schwarzkittel','Mitterteich / Bayern',true,'active','public','bi-schwarzkittel','EU','Europe','DE','Germany','Schwarzkittel@mein.gmx','https://linktr.ee/schwarzkittel.buhurt','https://static.wixstatic.com/media/b19213_c307b84d17974422b043ee98da8f140c~mv2.jpg','We are a new Team from Germany in North Bavaria')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','schwarzkittel','https://www.buhurtinternational.com/team/schwarzkittel','Schwarzkittel','Mitterteich / Bayern','Schwarzkittel@mein.gmx','https://linktr.ee/schwarzkittel.buhurt',20,'{"biCollectionId":"098f5f80-1c1d-4666-a056-0aac3c8b55ed","teamName":"Schwarzkittel","club":null,"gender":"Male","captain":"Dennis Otte","conference":"Europe","country":"Germany","city":"Mitterteich / Bayern","teamInfo":"We are a new Team from Germany in North Bavaria","trainingInfo":"First Location (Summer) is in 95666 Mitterteich / north Bavaria Second Location (Summer) is in 72218 Wildberg / Baden - Württemberg near Calw First Location (Winter) is in 95676 Wiesau / north Bavaria","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://linktr.ee/schwarzkittel.buhurt","teamEmail":"Schwarzkittel@mein.gmx","teamLogo":"wix:image://v1/b19213_c307b84d17974422b043ee98da8f140c~mv2.jpg/IMG_20251204_122006.jpg#originWidth=2047&originHeight=2369","logoUrl":"https://static.wixstatic.com/media/b19213_c307b84d17974422b043ee98da8f140c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":15}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Dennis Otte","Otte Dennis","Sven Zunke","Alexander Röthel","Niklas Lumpe","Lennart Reich","Paul (Schlesier) von Alt Tarnowitz","Nico Wenger","Philipp Ott","Heis Dominik","Raphael Sperber","Lucas Raithel","Sebastian Fröhler"],"sourceCreatedAt":"2025-12-02T09:38:05.156Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Schwarzkittel',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mitterteich / Bayern',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Schwarzkittel@mein.gmx'),
 website_url=coalesce(t.website_url,'https://linktr.ee/schwarzkittel.buhurt'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b19213_c307b84d17974422b043ee98da8f140c~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a new Team from Germany in North Bavaria'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Otte','captain','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Otte Dennis','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sven Zunke','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Röthel','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niklas Lumpe','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lennart Reich','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul (Schlesier) von Alt Tarnowitz','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nico Wenger','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Philipp Ott','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heis Dominik','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raphael Sperber','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Raithel','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Fröhler','fighter','bi_teams','https://www.buhurtinternational.com/team/schwarzkittel','schwarzkittel',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sentinels' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sentinels' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sentinels','New york city',true,'active','public','bi-sentinels','NA','North America','US','United States','nycarmoredcombat@gmail.com','https://nycarmoredcombat.com/','https://static.wixstatic.com/media/752be7_235047dba19d42dba32dccf8f1327a7e~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sentinels','https://www.buhurtinternational.com/team/sentinels','Sentinels','New york city','nycarmoredcombat@gmail.com','https://nycarmoredcombat.com/',20,'{"biCollectionId":"e9d9e1ab-ed04-4923-a329-3e949064586e","teamName":"Sentinels","club":null,"gender":"Male","captain":"Khaldwn El-fares","conference":"North America","country":"United States","city":"New york city","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://nycarmoredcombat.com/","teamEmail":"nycarmoredcombat@gmail.com","teamLogo":"wix:image://v1/752be7_235047dba19d42dba32dccf8f1327a7e~mv2.jpeg/fc30bae6-2046-47b2-af81-d0e088403f33.jpeg#originWidth=810&originHeight=918","logoUrl":"https://static.wixstatic.com/media/752be7_235047dba19d42dba32dccf8f1327a7e~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":11}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Khaldwn El-fares","Khaldwn El -fares","Collin Busch","Robert Dionisio","Zachary Hogan","Nicholas Volpe","Andres Enciso Oddy","Erie Agustin Jr","Robert Boudreaux","Michael Stewart"],"sourceCreatedAt":"2025-11-17T18:45:12.139Z","sourceUpdatedAt":"2026-09-29T16:28:30.613Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sentinels',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('New york city',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nycarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://nycarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/752be7_235047dba19d42dba32dccf8f1327a7e~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Khaldwn El-fares','captain','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Khaldwn El -fares','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Collin Busch','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Dionisio','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Hogan','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Volpe','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andres Enciso Oddy','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erie Agustin Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Boudreaux','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Stewart','fighter','bi_teams','https://www.buhurtinternational.com/team/sentinels','sentinels',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sentinels-of-eagle' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sentinels-of-eagle' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sentinels of Eagle','Berlin',true,'active','public','bi-sentinels-of-eagle','EU','Europe','DE','Germany','buhurtberbra@gmail.com','https://www.facebook.com/groups/1164488502497327','https://static.wixstatic.com/media/9db223_8064b74aeee24f54971558cf3bdfb15e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sentinels-of-eagle','https://www.buhurtinternational.com/team/sentinels-of-eagle','Sentinels of Eagle','Berlin','buhurtberbra@gmail.com','https://www.facebook.com/groups/1164488502497327',20,'{"biCollectionId":"89412882-ae6c-4c10-a98b-a1a4d23a3801","teamName":"Sentinels of Eagle","club":null,"gender":"Male","captain":"John Elvis Hasenpusch","conference":"Europe","country":"Germany","city":"Berlin","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/1164488502497327","teamEmail":"buhurtberbra@gmail.com","teamLogo":"wix:image://v1/9db223_8064b74aeee24f54971558cf3bdfb15e~mv2.png/Sentinels%20of%20Eagle.png#originWidth=1536&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/9db223_8064b74aeee24f54971558cf3bdfb15e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["John Elvis Hasenpusch"],"sourceCreatedAt":"2025-11-29T22:00:22.033Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sentinels of Eagle',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Berlin',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'buhurtberbra@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/1164488502497327'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9db223_8064b74aeee24f54971558cf3bdfb15e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Elvis Hasenpusch','captain','bi_teams','https://www.buhurtinternational.com/team/sentinels-of-eagle','sentinels-of-eagle',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='serra-red-lions' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-serra-red-lions' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Serra Red Lions','Lisbon',true,'active','public','bi-serra-red-lions','EU','Europe','PT','Portugal','direcao@serraredlions.com','https://serraredlions.com/','https://static.wixstatic.com/media/8b735a_c297703005524d3e86484e2b841c2bb6~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','serra-red-lions','https://www.buhurtinternational.com/team/serra-red-lions','Serra Red Lions','Lisbon','direcao@serraredlions.com','https://serraredlions.com/',20,'{"biCollectionId":"dedb1091-6b71-4900-b75c-78a0df0a0f21","teamName":"Serra Red Lions","club":null,"gender":"Male","captain":"Daniel Gomes dos Santos","conference":"Europe","country":"Portugal","city":"Lisbon","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Lisbon","name":"Lisbon","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Lisbon","name":"Lisbon","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Lisbon","name":"Lisbon","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"PT","name":"Portugal","type":"COUNTRY"}],"city":"Lisbon","location":{"latitude":38.7222524,"longitude":-9.1393366},"streetAddress":{"apt":"","formattedAddressLine":"Lisbon","name":"","number":""},"formatted":"Lisbon, Portugal","country":"PT","subdivision":"11"},"websiteFacebookUrl":"https://serraredlions.com/","teamEmail":"direcao@serraredlions.com","teamLogo":"wix:image://v1/8b735a_c297703005524d3e86484e2b841c2bb6~mv2.png/SRL%20LOGO%20black.png#originWidth=960&originHeight=720","logoUrl":"https://static.wixstatic.com/media/8b735a_c297703005524d3e86484e2b841c2bb6~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Torneio Medieval de Pirescoxe 2026","date":"2026-05-02","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":10}]},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":10,"tournaments":[{"_id":"1","points":3,"Tournament":"Torneio Medieval de Pirescoxe 2025","date":"2025-05-03","category":"5vs5","place":3}]}},"members":["Diogo Gouveia","Rui Martinho","Leonardo Carvalho","Carlos da Silva","Jorge Henrique Tatim da Cruz","João Vieira","Daniel Gomes dos Santos","João  Vieira","David Heleno Morais"],"sourceCreatedAt":"2024-04-11T20:30:48.209Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Serra Red Lions',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lisbon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Portugal',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'direcao@serraredlions.com'),
 website_url=coalesce(t.website_url,'https://serraredlions.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8b735a_c297703005524d3e86484e2b841c2bb6~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Diogo Gouveia','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rui Martinho','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Carvalho','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carlos da Silva','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jorge Henrique Tatim da Cruz','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'João Vieira','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Gomes dos Santos','captain','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'João  Vieira','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Heleno Morais','fighter','bi_teams','https://www.buhurtinternational.com/team/serra-red-lions','serra-red-lions',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='shadow-company' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-shadow-company' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Shadow Company','Marion',true,'active','public','bi-shadow-company','NA','North America','US','United States','codiseous890@gmail.com','https://www.facebook.com/MarionMayhem?mibextid=ZbWKwL','https://static.wixstatic.com/media/3d8996_00b34147c0694b119d6b68e13e08c6e7~mv2.png','Est. 2021 in Marion Ohio as the 2nd team to be established in ohio. Co-Hosted The Arnold Expo Fighting events all three years. Founding Team of the Midlands Medieval Faire. Sire Team to the Akron Hedge Knights, Hocking Hills Highlanders, Columbus Sun Tyrants, & Lima Frost Legion.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','shadow-company','https://www.buhurtinternational.com/team/shadow-company','Shadow Company','Marion','codiseous890@gmail.com','https://www.facebook.com/MarionMayhem?mibextid=ZbWKwL',20,'{"biCollectionId":"348cc72f-5da7-4b2f-93ad-278f05bc74e9","teamName":"Shadow Company","club":"Shadow Company","gender":"Male","captain":"Cody L. Parsons","conference":"North America","country":"United States","city":"Marion","teamInfo":"Est. 2021 in Marion Ohio as the 2nd team to be established in ohio. Co-Hosted The Arnold Expo Fighting events all three years. Founding Team of the Midlands Medieval Faire. Sire Team to the Akron Hedge Knights, Hocking Hills Highlanders, Columbus Sun Tyrants, & Lima Frost Legion.","trainingInfo":"Newbies Welcome, please make sure you bring your own Groin protection and gym equipment. Currently no Brick & mortar establishment.","trainingLocation":{"subdivisions":[{"code":"OH","name":"Ohio","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Marion County","name":"Marion County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Marion","name":"Marion","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Marion","location":{"latitude":40.5887502,"longitude":-83.09576109999999},"streetAddress":{"apt":"","formattedAddressLine":"1295 Harding Hwy E","name":"Harding Highway East","number":"1295"},"formatted":"1295 Harding Hwy E, Marion, OH 43302, USA","country":"US","postalCode":"43302-4563","subdivision":"OH"},"websiteFacebookUrl":"https://www.facebook.com/MarionMayhem?mibextid=ZbWKwL","teamEmail":"codiseous890@gmail.com","teamLogo":"wix:image://v1/3d8996_00b34147c0694b119d6b68e13e08c6e7~mv2.png/Screenshot%202024-06-30%2011.40.51%20AM.png#originWidth=254&originHeight=262","logoUrl":"https://static.wixstatic.com/media/3d8996_00b34147c0694b119d6b68e13e08c6e7~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Cody L. Parsons","Cody Parsons","Evan A Whitaker","Logan Bargainnier","Salvatore  Hoekstra","Gage Swaisgood"],"sourceCreatedAt":"2024-06-30T17:21:59.214Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Shadow Company',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Marion',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'codiseous890@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/MarionMayhem?mibextid=ZbWKwL'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3d8996_00b34147c0694b119d6b68e13e08c6e7~mv2.png'),
 public_description=coalesce(t.public_description,'Est. 2021 in Marion Ohio as the 2nd team to be established in ohio. Co-Hosted The Arnold Expo Fighting events all three years. Founding Team of the Midlands Medieval Faire. Sire Team to the Akron Hedge Knights, Hocking Hills Highlanders, Columbus Sun Tyrants, & Lima Frost Legion.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cody L. Parsons','captain','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cody Parsons','fighter','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan A Whitaker','fighter','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Bargainnier','fighter','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Salvatore  Hoekstra','fighter','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gage Swaisgood','fighter','bi_teams','https://www.buhurtinternational.com/team/shadow-company','shadow-company',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='she-beasts' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-she-beasts' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sheasts','Brisbane',true,'active','public','bi-she-beasts','OC','Oceania','AU','Australia','women@beasts.org.au. ','https://www.beasts.org.au/','https://static.wixstatic.com/media/8a581b_e5e0e553900a42569f37f494749a7661~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','she-beasts','https://www.buhurtinternational.com/team/she-beasts','Sheasts','Brisbane','women@beasts.org.au. ','https://www.beasts.org.au/',20,'{"biCollectionId":"f2d1a804-e672-431c-9d80-7bb024f9d81b","teamName":"Sheasts","club":"Beasts","gender":"Female","captain":"Siobhan Oxford","conference":"APAC","country":"Australia","city":"Brisbane","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.beasts.org.au/","teamEmail":"women@beasts.org.au. ","teamLogo":"wix:image://v1/8a581b_e5e0e553900a42569f37f494749a7661~mv2.jpeg/IMG_4674.jpeg#originWidth=2088&originHeight=2088","logoUrl":"https://static.wixstatic.com/media/8a581b_e5e0e553900a42569f37f494749a7661~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":11,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"3vs3","place":4},{"_id":"2","points":5,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":2},{"_id":"3","points":6,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":"\n    "},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":9,"tournaments":[{"_id":"1","points":5,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"3vs3","place":1},{"_id":"2","points":5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":2}]}},"members":["Siobhan Oxford","Jade Kathleen Clarke","Sarina brandes","Ro Vidler","Kylie Middleton","Bree wolf","Monica Joan Frances Robbie","Luka Cox","Taliah Ramage","Ellora Davy"],"sourceCreatedAt":"2023-09-14T00:13:30.867Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sheasts',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brisbane',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'women@beasts.org.au. '),
 website_url=coalesce(t.website_url,'https://www.beasts.org.au/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8a581b_e5e0e553900a42569f37f494749a7661~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Siobhan Oxford','captain','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jade Kathleen Clarke','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarina brandes','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ro Vidler','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kylie Middleton','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bree wolf','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Monica Joan Frances Robbie','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luka Cox','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taliah Ramage','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ellora Davy','fighter','bi_teams','https://www.buhurtinternational.com/team/she-beasts','she-beasts',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='shreveport-swamp-puppies' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-shreveport-swamp-puppies' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Shreveport Swamp Puppies','Shreveport',true,'active','public','bi-shreveport-swamp-puppies','NA','North America','US','United States','ShreveportSwampPuppies@gmail.com',NULL,'https://static.wixstatic.com/media/72c3fa_d3c98484dd4242a09f25ded38faffb89~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','shreveport-swamp-puppies','https://www.buhurtinternational.com/team/shreveport-swamp-puppies','Shreveport Swamp Puppies','Shreveport','ShreveportSwampPuppies@gmail.com',NULL,20,'{"biCollectionId":"bac9d05f-4afc-462f-b766-afd09700ca8d","teamName":"Shreveport Swamp Puppies","club":null,"gender":"Male","captain":"Collin Sly","conference":"North America","country":"United States","city":"Shreveport","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"ShreveportSwampPuppies@gmail.com","teamLogo":"wix:image://v1/72c3fa_d3c98484dd4242a09f25ded38faffb89~mv2.png/swamp%20puppies.png#originWidth=923&originHeight=1384","logoUrl":"https://static.wixstatic.com/media/72c3fa_d3c98484dd4242a09f25ded38faffb89~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Collin Sly"],"sourceCreatedAt":"2026-04-11T04:28:12.620Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Shreveport Swamp Puppies',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Shreveport',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ShreveportSwampPuppies@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/72c3fa_d3c98484dd4242a09f25ded38faffb89~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Collin Sly','captain','bi_teams','https://www.buhurtinternational.com/team/shreveport-swamp-puppies','shreveport-swamp-puppies',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sibylla' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sibylla' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sibylla',NULL,true,'active','public','bi-sibylla','EU','Europe','IT','Italy','ariannamedei@gmail.com',NULL,'https://static.wixstatic.com/media/547240_76c212b2ffc94024a4b84c68f1c6e209~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sibylla','https://www.buhurtinternational.com/team/sibylla','Sibylla',NULL,'ariannamedei@gmail.com',NULL,20,'{"biCollectionId":"a3617b9a-0b3e-4a8d-8a86-9a1c4c7751e6","teamName":"Sibylla","club":null,"gender":"Female","captain":"Arianna Medei","conference":"Europe","country":"Italy","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"ariannamedei@gmail.com","teamLogo":"wix:image://v1/547240_76c212b2ffc94024a4b84c68f1c6e209~mv2.jpg/IMG_20260119_104733.jpg#originWidth=854&originHeight=845","logoUrl":"https://static.wixstatic.com/media/547240_76c212b2ffc94024a4b84c68f1c6e209~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":8,"tournaments":[{"_id":"1","points":2,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":3}]}},"members":["Arianna Medei","Stella Barbaro","Anna Corbucci","Elizabeth Anne Pennock","Gaia Davi","Rossella Ramundo"],"sourceCreatedAt":"2025-05-22T21:50:02.831Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sibylla',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ariannamedei@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/547240_76c212b2ffc94024a4b84c68f1c6e209~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arianna Medei','captain','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stella Barbaro','fighter','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anna Corbucci','fighter','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elizabeth Anne Pennock','fighter','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gaia Davi','fighter','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rossella Ramundo','fighter','bi_teams','https://www.buhurtinternational.com/team/sibylla','sibylla',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sierotki' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sierotki' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sierotki','Cracow',true,'active','public','bi-sierotki','EU','Europe','PL','Poland','team.sierotki@gmail.com','https://www.facebook.com/sierotki','https://static.wixstatic.com/media/688c30_996dc24dae5e49d685e1a3c287c84b8a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sierotki','https://www.buhurtinternational.com/team/sierotki','Sierotki','Cracow','team.sierotki@gmail.com','https://www.facebook.com/sierotki',20,'{"biCollectionId":"ea3a90b1-3397-4b5c-a6a2-f0c84c22f0df","teamName":"Sierotki","club":null,"gender":"Male","captain":"Janusz Giercuszkiewicz","conference":"Europe","country":"Poland","city":"Cracow","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/sierotki","teamEmail":"team.sierotki@gmail.com","teamLogo":"wix:image://v1/688c30_996dc24dae5e49d685e1a3c287c84b8a~mv2.png/Veritas_V_RGB_v01%20(1).png#originWidth=1579&originHeight=1750","logoUrl":"https://static.wixstatic.com/media/688c30_996dc24dae5e49d685e1a3c287c84b8a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":6}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"King Kazimierz Cup 2024","date":45528,"category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"King Kazimierz Cup 2025","date":"2025-08-16","category":"5vs5","place":4}]}},"members":["Janusz Giercuszkiewicz","Dominik Stopka","Jan Sissmeir","Artur Miękina","Martin Srom","Kamil Szumielewicz","Marcin Taborowski","Hubert Haznar","Maciej Plichta","Damian Bednarczyk","Krzysztof Baran","Tomasz Kolodziejczyk","Oleksii Hlodovskyi","Hubert Ławniczak","Jerzy Ilnicki","Kacper Zadlak","Łukasz Długosz"],"sourceCreatedAt":"2023-08-04T10:37:56.842Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sierotki',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cracow',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'team.sierotki@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/sierotki'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/688c30_996dc24dae5e49d685e1a3c287c84b8a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Janusz Giercuszkiewicz','captain','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Stopka','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Sissmeir','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Artur Miękina','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Srom','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kamil Szumielewicz','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcin Taborowski','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hubert Haznar','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maciej Plichta','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damian Bednarczyk','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Krzysztof Baran','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomasz Kolodziejczyk','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oleksii Hlodovskyi','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hubert Ławniczak','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerzy Ilnicki','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kacper Zadlak','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Łukasz Długosz','fighter','bi_teams','https://www.buhurtinternational.com/team/sierotki','sierotki',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='silver-gryphons' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-silver-gryphons' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Silver Gryphons','Calgary',true,'active','public','bi-silver-gryphons','NA','North America','CA','Canada','SilverGryphons@hacsacanada.com','https://www.hacsacanada.com/teams#anchors-l9oona4v3','https://static.wixstatic.com/media/070a67_fe8c855cc70140d2afa213909929c062~mv2.png','We are the local HACSA Buhurt team in Calgary, AB, Canada! New members welcome - contact us via the national HACSA website to find your nearest Canadian team and join up!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','silver-gryphons','https://www.buhurtinternational.com/team/silver-gryphons','Silver Gryphons','Calgary','SilverGryphons@hacsacanada.com','https://www.hacsacanada.com/teams#anchors-l9oona4v3',20,'{"biCollectionId":"1df2d6e6-66c7-40fc-bc81-57f6d87cc837","teamName":"Silver Gryphons","club":null,"gender":"Male","captain":"Michael Diaz","conference":"North America","country":"Canada","city":"Calgary","teamInfo":"We are the local HACSA Buhurt team in Calgary, AB, Canada! New members welcome - contact us via the national HACSA website to find your nearest Canadian team and join up!","trainingInfo":"","trainingLocation":{"formatted":"NE Calgary, AB"},"websiteFacebookUrl":"https://www.hacsacanada.com/teams#anchors-l9oona4v3","teamEmail":"SilverGryphons@hacsacanada.com","teamLogo":"wix:image://v1/070a67_fe8c855cc70140d2afa213909929c062~mv2.png/Calgary%20Silver%20Gryphons%20logo.PNG#originWidth=378&originHeight=347","logoUrl":"https://static.wixstatic.com/media/070a67_fe8c855cc70140d2afa213909929c062~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4.5,"Tournament":"Coulee Clash 2026","date":"2026-05-30","category":"3vs3","place":1}],"eventsHistory":{},"members":["William L Baliko","Michael Diaz","Gemariah Robert Ongteco","Bryce Jerrom","Jackson Lowe","Nolan Bernard","Jason lacroix","Nevan Ondrus","Barret Magera"],"sourceCreatedAt":"2026-05-04T20:51:23.954Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Silver Gryphons',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Calgary',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'SilverGryphons@hacsacanada.com'),
 website_url=coalesce(t.website_url,'https://www.hacsacanada.com/teams#anchors-l9oona4v3'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/070a67_fe8c855cc70140d2afa213909929c062~mv2.png'),
 public_description=coalesce(t.public_description,'We are the local HACSA Buhurt team in Calgary, AB, Canada! New members welcome - contact us via the national HACSA website to find your nearest Canadian team and join up!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William L Baliko','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Diaz','captain','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gemariah Robert Ongteco','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryce Jerrom','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jackson Lowe','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nolan Bernard','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason lacroix','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nevan Ondrus','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Barret Magera','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-gryphons','silver-gryphons',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='silver-guard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-silver-guard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Silver Guard','São Paulo',true,'active','public','bi-silver-guard','SA','South America','BR','Brazil','ciaespadadeprata@gmail.com','https://www.casamedievaleventos.com/','https://static.wixstatic.com/media/444beb_33378dc6081a4f92863b21ead601868a~mv2.png','Silver Sword Company Team 2 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe 2 da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','silver-guard','https://www.buhurtinternational.com/team/silver-guard','Silver Guard','São Paulo','ciaespadadeprata@gmail.com','https://www.casamedievaleventos.com/',20,'{"biCollectionId":"143e92b0-8116-473b-8f94-458ef979ff37","teamName":"Silver Guard","club":"Silver Sword Company","gender":"Male","captain":"Flavio Pinho","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"Silver Sword Company Team 2 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe 2 da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.","trainingInfo":"If interested in joining the Silver Sword Company reach out to us on Whatsapp at: +55 (11) 98588-7356 Se estiver interessado em fazer parte da Silver Sword Company, entre em contato conosco pelo Whatsapp: +55 (11) 98588-7356","trainingLocation":{"city":"Vila Clementino","location":{"latitude":-23.6054405,"longitude":-46.6484435},"streetAddress":{"apt":"","formattedAddressLine":"Rua Guapiaçu, 370","name":"Rua Guapiaçu","number":"370"},"formatted":"Rua Guapiaçu, 370 - Vila Clementino, São Paulo - SP, 04024-020, Brazil","country":"BR","postalCode":"04024-020","subdivision":"SP"},"websiteFacebookUrl":"https://www.casamedievaleventos.com/","teamEmail":"ciaespadadeprata@gmail.com","teamLogo":"wix:image://v1/444beb_33378dc6081a4f92863b21ead601868a~mv2.png/GuardaPratabranco1x1.png#originWidth=850&originHeight=850","logoUrl":"https://static.wixstatic.com/media/444beb_33378dc6081a4f92863b21ead601868a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Flavio Pinho","Bruno Fedeli","Hugo César","Antonio Paneguini","César Boanerges","Pedro Vilela","Vinicius Zugliani","Thiago Braz"],"sourceCreatedAt":"2023-06-26T19:07:16.876Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Silver Guard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ciaespadadeprata@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.casamedievaleventos.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/444beb_33378dc6081a4f92863b21ead601868a~mv2.png'),
 public_description=coalesce(t.public_description,'Silver Sword Company Team 2 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe 2 da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Flavio Pinho','captain','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruno Fedeli','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hugo César','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antonio Paneguini','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'César Boanerges','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pedro Vilela','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vinicius Zugliani','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thiago Braz','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-guard','silver-guard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='silver-sword' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-silver-sword' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Silver Sword','São Paulo',true,'active','public','bi-silver-sword','SA','South America','BR','Brazil','ciaespadadeprata@gmail.com','https://www.casamedievaleventos.com/','https://static.wixstatic.com/media/444beb_c0bca93ea33d4285bffa7eeeb9d17773~mv2.png','Silver Sword Company Team 1 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. Feats: Several National Tournament Gold, Silver and Bronze medals in Longsword, Sword and Shield and Sword and Buckler Highest-ranked Brazilian League Sword and Shield Duelist Silver Medal for longsword at IMCF 2023 Playoffs at Battle of the Nations 2019 The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe Principal da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. Feitos: Várias medalhas de ouro, prata e bronze em torneios nacionais de espada longa, espada e escudo e espada e buckler Duelista de espada e escudo mais bem classificado da Liga Brasileira Medalha de prata em espada longa no IMCF 2023 Eliminatórias na Batalha das Nações 2019 O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','silver-sword','https://www.buhurtinternational.com/team/silver-sword','Silver Sword','São Paulo','ciaespadadeprata@gmail.com','https://www.casamedievaleventos.com/',20,'{"biCollectionId":"7ffe21aa-8faf-40ab-bf47-ed1ed1a559dd","teamName":"Silver Sword","club":"Silver Sword Company","gender":"Male","captain":"Fábio Toniolo Silvério","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"Silver Sword Company Team 1 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. Feats: Several National Tournament Gold, Silver and Bronze medals in Longsword, Sword and Shield and Sword and Buckler Highest-ranked Brazilian League Sword and Shield Duelist Silver Medal for longsword at IMCF 2023 Playoffs at Battle of the Nations 2019 The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe Principal da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. Feitos: Várias medalhas de ouro, prata e bronze em torneios nacionais de espada longa, espada e escudo e espada e buckler Duelista de espada e escudo mais bem classificado da Liga Brasileira Medalha de prata em espada longa no IMCF 2023 Eliminatórias na Batalha das Nações 2019 O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.","trainingInfo":"If interested in joining the Silver Sword Company reach out to us on Whatsapp at: +55 (11) 98588-7356 Se estiver interessado em fazer parte da Compania da Espada de Prata, entre em contato conosco pelo Whatsapp: +55 (11) 98588-7356","trainingLocation":{"city":"Vila Clementino","location":{"latitude":-23.6054405,"longitude":-46.6484435},"streetAddress":{"apt":"","formattedAddressLine":"Rua Guapiaçu, 370","name":"Rua Guapiaçu","number":"370"},"formatted":"Rua Guapiaçu, 370 - Vila Clementino, São Paulo - SP, 04024-020, Brazil","country":"BR","postalCode":"04024-020","subdivision":"SP"},"websiteFacebookUrl":"https://www.casamedievaleventos.com/","teamEmail":"ciaespadadeprata@gmail.com","teamLogo":"wix:image://v1/444beb_c0bca93ea33d4285bffa7eeeb9d17773~mv2.png/espadaPrata1x1.png#originWidth=850&originHeight=850","logoUrl":"https://static.wixstatic.com/media/444beb_c0bca93ea33d4285bffa7eeeb9d17773~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Fábio Toniolo Silvério","Daniel Nardotto","João Pedro Olivieri de Castro Souza","Antonio Lopes Paneguini","Bruno Fedeli de Oliveira"],"sourceCreatedAt":"2023-06-26T18:57:04.008Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Silver Sword',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ciaespadadeprata@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.casamedievaleventos.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/444beb_c0bca93ea33d4285bffa7eeeb9d17773~mv2.png'),
 public_description=coalesce(t.public_description,'Silver Sword Company Team 1 - Founded in 2017 by Flavio Pinho, Vitor Vital and Fabio Silverio the team quickly established itself as one of the strongest duel teams in the nation winning national events every time they participated, eventually as the team grew the silver sword expanded to group fights. Feats: Several National Tournament Gold, Silver and Bronze medals in Longsword, Sword and Shield and Sword and Buckler Highest-ranked Brazilian League Sword and Shield Duelist Silver Medal for longsword at IMCF 2023 Playoffs at Battle of the Nations 2019 The club has its own training hall at the Casa Medieval where it also has a tavern serving historic food and an arena for events. - PT Equipe Principal da Compania da Espada de Prata - Fundada em 2017 por Flavio Pinho, Vitor Vital e Fabio Silverio, a equipe rapidamente se estabeleceu como uma das equipes de duelo mais fortes do país, vencendo eventos nacionais todas as vezes que participaram, eventualmente, à medida que a equipe crescia, a espada de prata expandiu para lutas em grupo tambem. Feitos: Várias medalhas de ouro, prata e bronze em torneios nacionais de espada longa, espada e escudo e espada e buckler Duelista de espada e escudo mais bem classificado da Liga Brasileira Medalha de prata em espada longa no IMCF 2023 Eliminatórias na Batalha das Nações 2019 O clube tem seu próprio salão de treinamento na Casa Medieval, onde também há uma taberna que serve comida histórica e uma arena para eventos.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fábio Toniolo Silvério','captain','bi_teams','https://www.buhurtinternational.com/team/silver-sword','silver-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Nardotto','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-sword','silver-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'João Pedro Olivieri de Castro Souza','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-sword','silver-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antonio Lopes Paneguini','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-sword','silver-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruno Fedeli de Oliveira','fighter','bi_teams','https://www.buhurtinternational.com/team/silver-sword','silver-sword',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='skskb-praha' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-skskb-praha' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'SKSKB Praha','Praha',true,'active','public','bi-skskb-praha','EU','Europe','CZ','Czech Republic','stredovekyboj@gmail.com','https://www.stredovekyboj.cz/','https://static.wixstatic.com/media/f266d7_4a5270461fa74f9ba99cfb0a70adc85a~mv2.png','Sports Club of Medieval Contact Combat PRAGUE has been operating since 2013 and is one of the founders of HMB sport in the Czech Republic. At the same time, it is the largest and most successful club in our country. Our members are collecting successes both on the domestic and foreign HMB scene.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','skskb-praha','https://www.buhurtinternational.com/team/skskb-praha','SKSKB Praha','Praha','stredovekyboj@gmail.com','https://www.stredovekyboj.cz/',20,'{"biCollectionId":"4bc63eb3-1179-442c-8e10-922f9786a2c6","teamName":"SKSKB Praha","club":null,"gender":"Male","captain":"Dominik Sladovník","conference":"Europe","country":"Czech Republic","city":"Praha","teamInfo":"Sports Club of Medieval Contact Combat PRAGUE has been operating since 2013 and is one of the founders of HMB sport in the Czech Republic. At the same time, it is the largest and most successful club in our country. Our members are collecting successes both on the domestic and foreign HMB scene.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Prague","name":"Prague","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Hlavní město Praha","name":"Hlavní město Praha","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"CZ","name":"Czechia","type":"COUNTRY"}],"city":"Prague 9","location":{"latitude":50.111297,"longitude":14.5025507},"streetAddress":{"apt":"","formattedAddressLine":"Prague 9","name":"","number":""},"formatted":"Prague 9, Czechia","country":"CZ","subdivision":"PR"},"websiteFacebookUrl":"https://www.stredovekyboj.cz/","teamEmail":"stredovekyboj@gmail.com","teamLogo":"wix:image://v1/f266d7_4a5270461fa74f9ba99cfb0a70adc85a~mv2.png/SKSKB%20PRAHA%20FB.png#originWidth=864&originHeight=896","logoUrl":"https://static.wixstatic.com/media/f266d7_4a5270461fa74f9ba99cfb0a70adc85a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":4,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":14,"remainingTokens":3,"tournaments":[{"_id":"1","points":7,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":3},{"_id":"2","points":7,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":3}]}},"members":["Dominik Sladovník","Jeffrey Booij","Dan Melichar","Emil Rudolf Jirák","Jiří Ludvík","Adrian Sarvaš","Jaroslav Grűndl","Michal Vajdl"],"sourceCreatedAt":"2025-02-16T12:32:16.460Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('SKSKB Praha',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Praha',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'stredovekyboj@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.stredovekyboj.cz/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f266d7_4a5270461fa74f9ba99cfb0a70adc85a~mv2.png'),
 public_description=coalesce(t.public_description,'Sports Club of Medieval Contact Combat PRAGUE has been operating since 2013 and is one of the founders of HMB sport in the Czech Republic. At the same time, it is the largest and most successful club in our country. Our members are collecting successes both on the domestic and foreign HMB scene.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Sladovník','captain','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeffrey Booij','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dan Melichar','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emil Rudolf Jirák','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jiří Ludvík','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Sarvaš','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaroslav Grűndl','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michal Vajdl','fighter','bi_teams','https://www.buhurtinternational.com/team/skskb-praha','skskb-praha',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='solar-knight' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-solar-knight' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Solar Knight','Shanghai',true,'active','public','bi-solar-knight','AS','Asia Pacific',NULL,'China','zijieoctober@163.com','https://space.bilibili.com/34606574?spm_id_from=333.1007.0.0','https://static.wixstatic.com/media/b4323e_6d668bdc524c40ae9622ef4381649afc~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','solar-knight','https://www.buhurtinternational.com/team/solar-knight','Solar Knight','Shanghai','zijieoctober@163.com','https://space.bilibili.com/34606574?spm_id_from=333.1007.0.0',20,'{"biCollectionId":"16fa6f9e-9073-4737-9962-b6b2f110f4d7","teamName":"Solar Knight","club":null,"gender":"Male","captain":"Zijie Zhang","conference":"APAC","country":"China","city":"Shanghai","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"海潮路133弄 B1 C802 Huangpu Shanghai"},"websiteFacebookUrl":"https://space.bilibili.com/34606574?spm_id_from=333.1007.0.0","teamEmail":"zijieoctober@163.com","teamLogo":"wix:image://v1/b4323e_6d668bdc524c40ae9622ef4381649afc~mv2.png/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20240708233034.png#originWidth=3544&originHeight=3544","logoUrl":"https://static.wixstatic.com/media/b4323e_6d668bdc524c40ae9622ef4381649afc~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":8}]},"2025":{"remainingTokens":10}},"members":["Zijie Zhang","Yuan jun","Xukuangyao","Sheng Qi Liang","Yuxi Jin","yujie yang","Xuan liu","Jiashu Zhang","Heming Jin"],"sourceCreatedAt":"2024-07-08T16:09:18.007Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Solar Knight',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Shanghai',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('AS',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Asia Pacific',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce(NULL,t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('China',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'zijieoctober@163.com'),
 website_url=coalesce(t.website_url,'https://space.bilibili.com/34606574?spm_id_from=333.1007.0.0'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b4323e_6d668bdc524c40ae9622ef4381649afc~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zijie Zhang','captain','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yuan jun','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Xukuangyao','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sheng Qi Liang','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yuxi Jin','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'yujie yang','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Xuan liu','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jiashu Zhang','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heming Jin','fighter','bi_teams','https://www.buhurtinternational.com/team/solar-knight','solar-knight',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='soldados' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-soldados' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Soldados','Santa Barbara',true,'active','public','bi-soldados','NA','North America','US','United States','santabarbarasoldados@gmail.com','https://santabarbarasoldados.com/','https://static.wixstatic.com/media/599ef1_d40937da01f348029cc26e3c663fded4~mv2.jpg','The Santa Barbara Soldados are the local Buhurt Club for Santa Barbara and Ventura Counties along the California coast. Founded in 2016 by former Los Angeles Golden Knights Lance Hoffman and Chris Minerd, the Santa Barbara Soldados remained a small chapter with only three fighting members until early 2020, when an influx of new fighters more than doubled the team’s size. We earned silver in our debut tournament at the Ventura Melee Megabowl in 2023. Several Soldados have earned medals for exceptional performance in both duels and melees fighting, nationally and internationally.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','soldados','https://www.buhurtinternational.com/team/soldados','Soldados','Santa Barbara','santabarbarasoldados@gmail.com','https://santabarbarasoldados.com/',20,'{"biCollectionId":"5c964400-be30-4832-b0d3-6512162e49ac","teamName":"Soldados","club":"The Santa Barbara Soldados are the local Buhurt Club for Santa Barbara and Ventura Counties. Founded in 2016 by former Los Angeles Golden Knights Lance Hoffman and Chris Minerd, the Santa Barbara Soldados remained a small chapter with only three fighting members until early 2020, when an influx of new fighters more than doubled the team’s size. Several Soldados have since been awarded gold medals for exceptional performance in both duels and melees, nationally and internationally.","gender":"Male","captain":"Mark Sanders","conference":"North America","country":"United States","city":"Santa Barbara","teamInfo":"The Santa Barbara Soldados are the local Buhurt Club for Santa Barbara and Ventura Counties along the California coast. Founded in 2016 by former Los Angeles Golden Knights Lance Hoffman and Chris Minerd, the Santa Barbara Soldados remained a small chapter with only three fighting members until early 2020, when an influx of new fighters more than doubled the team’s size. We earned silver in our debut tournament at the Ventura Melee Megabowl in 2023. Several Soldados have earned medals for exceptional performance in both duels and melees fighting, nationally and internationally.","trainingInfo":"","trainingLocation":{"formatted":"The Soldados train at locations in the cities of Santa Barbara and Ventura.  We welcome new fighters and are also currently building a women''s melee team as well. For more information reach out to us via our email or Facebook page."},"websiteFacebookUrl":"https://santabarbarasoldados.com/","teamEmail":"santabarbarasoldados@gmail.com","teamLogo":"wix:image://v1/599ef1_d40937da01f348029cc26e3c663fded4~mv2.jpg/20230803_181705.jpg#originWidth=522&originHeight=598","logoUrl":"https://static.wixstatic.com/media/599ef1_d40937da01f348029cc26e3c663fded4~mv2.jpg","rank5v5":4,"averagePoints5v5":11.42,"points5v5":34.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":5,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":3},{"_id":"2","points":16.25,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":1},{"_id":"3","points":13,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Ventura Melee Megabowl 2024","date":"14-04-2024","category":"5vs5","place":3},{"_id":"2","points":6,"Tournament":"Rise of an Empire 2024","date":"2024-08-30","category":"5vs5","place":2},{"_id":"3","points":6,"Tournament":"California Classic 2024","date":"2024-09-21","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":null,"remainingTokens":10,"tournaments":[{"Tournament":"Ventura Melee Megabowl 2025","category":"5vs5","date":"2025-05-24","place":5}]}},"members":["Mark Sanders","Mark Forrest Sanders","Cousteau Bix Christopher","Kyle Lee","Wylde Brandt","Joseph Brandt","Michael Stokell","Alexander Das","Matthew Brown","Matthew De La Rosa","Kyle Olson","Lawrence manzanares","Zon Wang","Martin Roger Escalera","Jackson Thomas Fisher"],"sourceCreatedAt":"2023-08-04T01:24:00.614Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Soldados',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Santa Barbara',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'santabarbarasoldados@gmail.com'),
 website_url=coalesce(t.website_url,'https://santabarbarasoldados.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/599ef1_d40937da01f348029cc26e3c663fded4~mv2.jpg'),
 public_description=coalesce(t.public_description,'The Santa Barbara Soldados are the local Buhurt Club for Santa Barbara and Ventura Counties along the California coast. Founded in 2016 by former Los Angeles Golden Knights Lance Hoffman and Chris Minerd, the Santa Barbara Soldados remained a small chapter with only three fighting members until early 2020, when an influx of new fighters more than doubled the team’s size. We earned silver in our debut tournament at the Ventura Melee Megabowl in 2023. Several Soldados have earned medals for exceptional performance in both duels and melees fighting, nationally and internationally.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark Sanders','captain','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark Forrest Sanders','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cousteau Bix Christopher','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Lee','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wylde Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Stokell','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Das','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Brown','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew De La Rosa','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Olson','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lawrence manzanares','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zon Wang','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Roger Escalera','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jackson Thomas Fisher','fighter','bi_teams','https://www.buhurtinternational.com/team/soldados','soldados',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sovereign-steel' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sovereign-steel' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sovereign Steel',NULL,true,'active','public','bi-sovereign-steel','NA','North America','US','United States','Sovereignsteelbuhurt@gmail.com','https://www.facebook.com/share/14i5X1T5hdJ/','https://static.wixstatic.com/media/4ad3d9_60295d30eea845ae91694a3a6471de20~mv2.png','Sovereign Steel is a full-contact, women&#x27;s armored combat team built on steel, sisterhood, and a shared passion for the list. For us, Buhurt is more than a sport—it is a crucible where we push each other to find our power, unified by the belief that iron sharpens iron. We cultivate a collaborative, healthy team dynamic where mentorship, safety, and mutual respect come first , ensuring every teammate has the space to thrive and safely hone her skills. Our strength as fighters is rooted entirely in this supportive community we build together outside the armor. We train hard, fight with everything we have, and uplift one another every step of the way. Above all, we are driven by a genuine love for the fight, standing fiercely together as teammates and sisters-in-arms.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sovereign-steel','https://www.buhurtinternational.com/team/sovereign-steel','Sovereign Steel',NULL,'Sovereignsteelbuhurt@gmail.com','https://www.facebook.com/share/14i5X1T5hdJ/',20,'{"biCollectionId":"84ddea52-25fb-4abd-8d85-b4a5a65dc600","teamName":"Sovereign Steel","club":null,"gender":"Female","captain":"Yolanda Santistevan","conference":"North America","country":"United States","city":null,"teamInfo":"Sovereign Steel is a full-contact, women&#x27;s armored combat team built on steel, sisterhood, and a shared passion for the list. For us, Buhurt is more than a sport—it is a crucible where we push each other to find our power, unified by the belief that iron sharpens iron. We cultivate a collaborative, healthy team dynamic where mentorship, safety, and mutual respect come first , ensuring every teammate has the space to thrive and safely hone her skills. Our strength as fighters is rooted entirely in this supportive community we build together outside the armor. We train hard, fight with everything we have, and uplift one another every step of the way. Above all, we are driven by a genuine love for the fight, standing fiercely together as teammates and sisters-in-arms.","trainingInfo":"We welcome meeting new people with interest in this amazing sport.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/14i5X1T5hdJ/","teamEmail":"Sovereignsteelbuhurt@gmail.com","teamLogo":"wix:image://v1/4ad3d9_60295d30eea845ae91694a3a6471de20~mv2.png/file_000000006a9871fdb6549daaa99b3d5a.png#originWidth=1254&originHeight=1254","logoUrl":"https://static.wixstatic.com/media/4ad3d9_60295d30eea845ae91694a3a6471de20~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Belinda Qualls","Whitney Richardson","Yolanda Santistevan"],"sourceCreatedAt":"2026-07-07T23:04:38.752Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sovereign Steel',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Sovereignsteelbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/14i5X1T5hdJ/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4ad3d9_60295d30eea845ae91694a3a6471de20~mv2.png'),
 public_description=coalesce(t.public_description,'Sovereign Steel is a full-contact, women&#x27;s armored combat team built on steel, sisterhood, and a shared passion for the list. For us, Buhurt is more than a sport—it is a crucible where we push each other to find our power, unified by the belief that iron sharpens iron. We cultivate a collaborative, healthy team dynamic where mentorship, safety, and mutual respect come first , ensuring every teammate has the space to thrive and safely hone her skills. Our strength as fighters is rooted entirely in this supportive community we build together outside the armor. We train hard, fight with everything we have, and uplift one another every step of the way. Above all, we are driven by a genuine love for the fight, standing fiercely together as teammates and sisters-in-arms.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Belinda Qualls','fighter','bi_teams','https://www.buhurtinternational.com/team/sovereign-steel','sovereign-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Whitney Richardson','fighter','bi_teams','https://www.buhurtinternational.com/team/sovereign-steel','sovereign-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yolanda Santistevan','captain','bi_teams','https://www.buhurtinternational.com/team/sovereign-steel','sovereign-steel',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='spartoi' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-spartoi' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Spartoi','Viña del Mar',true,'active','public','bi-spartoi','SA','South America','CL','Chile','spartoihmb@gmail.com','https://www.facebook.com/SpartoiHMB/','https://static.wixstatic.com/media/3ea64e_0f190d3a001741d397fe4fb68636c8f8~mv2.png','Club deportivo de combate medieval orientado a la practica y difusión de "Historical Medieval Battles" ubicado en Viña del Mar, Chile.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','spartoi','https://www.buhurtinternational.com/team/spartoi','Spartoi','Viña del Mar','spartoihmb@gmail.com','https://www.facebook.com/SpartoiHMB/',20,'{"biCollectionId":"2025469f-14ac-428a-9858-21400a62d719","teamName":"Spartoi","club":null,"gender":"Male","captain":"Alejandro Abarzúa Ramírez","conference":"South America","country":"Chile","city":"Viña del Mar","teamInfo":"Club deportivo de combate medieval orientado a la practica y difusión de \"Historical Medieval Battles\" ubicado en Viña del Mar, Chile.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/SpartoiHMB/","teamEmail":"spartoihmb@gmail.com","teamLogo":"wix:image://v1/3ea64e_0f190d3a001741d397fe4fb68636c8f8~mv2.png/Heraldica%20HD.png#originWidth=2250&originHeight=2250","logoUrl":"https://static.wixstatic.com/media/3ea64e_0f190d3a001741d397fe4fb68636c8f8~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Mauricio Espíndola","Alejandro Abarzúa Ramírez","Daniela Diaz","Lucas Gaviño","Jose Tapia"],"sourceCreatedAt":"2023-06-27T19:39:52.176Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Spartoi',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Viña del Mar',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Chile',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'spartoihmb@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/SpartoiHMB/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3ea64e_0f190d3a001741d397fe4fb68636c8f8~mv2.png'),
 public_description=coalesce(t.public_description,'Club deportivo de combate medieval orientado a la practica y difusión de "Historical Medieval Battles" ubicado en Viña del Mar, Chile.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mauricio Espíndola','fighter','bi_teams','https://www.buhurtinternational.com/team/spartoi','spartoi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alejandro Abarzúa Ramírez','captain','bi_teams','https://www.buhurtinternational.com/team/spartoi','spartoi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniela Diaz','fighter','bi_teams','https://www.buhurtinternational.com/team/spartoi','spartoi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Gaviño','fighter','bi_teams','https://www.buhurtinternational.com/team/spartoi','spartoi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Tapia','fighter','bi_teams','https://www.buhurtinternational.com/team/spartoi','spartoi',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='steel-coven-(m)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-steel-coven-(m)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Steel Coven (M)','Greensboro, NC',true,'active','public','bi-steel-coven-(m)','NA','North America','US','United States','steelcovencombat@gmail.com','http://www.steelcoven.com','https://static.wixstatic.com/media/871a2f_2347129868eb4f12b69ca39cf87fdfc1~mv2.jpg','We are a mutli-gender team based out of Greensboro, North Carolina. We emphasisze inclusivity and a great team culture!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','steel-coven-(m)','https://www.buhurtinternational.com/team/steel-coven-(m)','Steel Coven (M)','Greensboro, NC','steelcovencombat@gmail.com','http://www.steelcoven.com',20,'{"biCollectionId":"02363b0b-6da4-443d-8c69-803f4a0ba588","teamName":"Steel Coven (M)","club":null,"gender":"Male","captain":"Quentin Dulaney","conference":"North America","country":"United States","city":"Greensboro, NC","teamInfo":"We are a mutli-gender team based out of Greensboro, North Carolina. We emphasisze inclusivity and a great team culture!","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"http://www.steelcoven.com","teamEmail":"steelcovencombat@gmail.com","teamLogo":"wix:image://v1/871a2f_2347129868eb4f12b69ca39cf87fdfc1~mv2.jpg/SC_Snake_Black_Bleed.jpg#originWidth=3198&originHeight=3238","logoUrl":"https://static.wixstatic.com/media/871a2f_2347129868eb4f12b69ca39cf87fdfc1~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Quentin Dulaney","Chaz Antinori","Gavin Sparks","Griffin Gillispie","Terence Willcox"],"sourceCreatedAt":"2023-08-29T15:12:22.483Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Steel Coven (M)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Greensboro, NC',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'steelcovencombat@gmail.com'),
 website_url=coalesce(t.website_url,'http://www.steelcoven.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/871a2f_2347129868eb4f12b69ca39cf87fdfc1~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a mutli-gender team based out of Greensboro, North Carolina. We emphasisze inclusivity and a great team culture!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quentin Dulaney','captain','bi_teams','https://www.buhurtinternational.com/team/steel-coven-(m)','steel-coven-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chaz Antinori','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-coven-(m)','steel-coven-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gavin Sparks','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-coven-(m)','steel-coven-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Griffin Gillispie','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-coven-(m)','steel-coven-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Terence Willcox','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-coven-(m)','steel-coven-(m)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='steel-thorns' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-steel-thorns' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Steel Thorns',NULL,true,'active','public','bi-steel-thorns','OC','Oceania','NZ','New Zealand','greatswordjordan@gmail.com','https://www.facebook.com/steelthorns','https://static.wixstatic.com/media/607d89_8256a9bb390845abb31939c3fcc0cd89~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','steel-thorns','https://www.buhurtinternational.com/team/steel-thorns','Steel Thorns',NULL,'greatswordjordan@gmail.com','https://www.facebook.com/steelthorns',20,'{"biCollectionId":"73c5684e-4567-49f9-93c0-d8d9e242743c","teamName":"Steel Thorns","club":null,"gender":"Male","captain":"Jordan King","conference":"APAC","country":"New Zealand","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/steelthorns","teamEmail":"greatswordjordan@gmail.com","teamLogo":"wix:image://v1/607d89_8256a9bb390845abb31939c3fcc0cd89~mv2.jpg/steel%20thorns%20logo.jfif#originWidth=671&originHeight=1000","logoUrl":"https://static.wixstatic.com/media/607d89_8256a9bb390845abb31939c3fcc0cd89~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":8}]},"2025":{"remainingTokens":10}},"members":["Rueben King","James Hamill","Jordan King","Joshua McLean","William Piercy"],"sourceCreatedAt":"2024-06-30T07:10:46.257Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Steel Thorns',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'greatswordjordan@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/steelthorns'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/607d89_8256a9bb390845abb31939c3fcc0cd89~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rueben King','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-thorns','steel-thorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Hamill','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-thorns','steel-thorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan King','captain','bi_teams','https://www.buhurtinternational.com/team/steel-thorns','steel-thorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua McLean','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-thorns','steel-thorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Piercy','fighter','bi_teams','https://www.buhurtinternational.com/team/steel-thorns','steel-thorns',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='strathcona-warhorse-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-strathcona-warhorse-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Strathcona Warhorse ','Sherwood park ',true,'active','public','bi-strathcona-warhorse-','NA','North America','CA','Canada','strathconawarhorse@gmail.com',NULL,'https://static.wixstatic.com/media/c4f213_87328a397b4944299d6a698afbd797f2~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','strathcona-warhorse-','https://www.buhurtinternational.com/team/strathcona-warhorse-','Strathcona Warhorse ','Sherwood park ','strathconawarhorse@gmail.com',NULL,20,'{"biCollectionId":"2ecb2fea-e25b-4d5b-8390-8848b170392f","teamName":"Strathcona Warhorse ","club":null,"gender":"Male","captain":"Christopher Keen","conference":"North America","country":"Canada","city":"Sherwood park ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"strathconawarhorse@gmail.com","teamLogo":"wix:image://v1/c4f213_87328a397b4944299d6a698afbd797f2~mv2.jpeg/warhorse(yellow)nobackground.jpeg#originWidth=1114&originHeight=1375","logoUrl":"https://static.wixstatic.com/media/c4f213_87328a397b4944299d6a698afbd797f2~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Christopher Keen"],"sourceCreatedAt":"2026-05-07T22:21:26.220Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Strathcona Warhorse ',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sherwood park ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'strathconawarhorse@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c4f213_87328a397b4944299d6a698afbd797f2~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Keen','captain','bi_teams','https://www.buhurtinternational.com/team/strathcona-warhorse-','strathcona-warhorse-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sun-eaters' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sun-eaters' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sun Eaters','Missoula',true,'active','public','bi-sun-eaters','NA','North America','US','United States','montanasuneaters@gmail.com','https://www.facebook.com/profile.php?id=100094421216691','https://static.wixstatic.com/media/6e675c_5b48e5fdb60b4f0cb32226683a4e4674~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sun-eaters','https://www.buhurtinternational.com/team/sun-eaters','Sun Eaters','Missoula','montanasuneaters@gmail.com','https://www.facebook.com/profile.php?id=100094421216691',20,'{"biCollectionId":"29b56a29-c8b7-46bb-a810-bb3595547078","teamName":"Sun Eaters","club":null,"gender":"Male","captain":"Kyle James Olson","conference":"North America","country":"United States","city":"Missoula","teamInfo":"","trainingInfo":"An athletic cup and a good attitude.","trainingLocation":{"city":"Florence","location":{"latitude":46.6316893,"longitude":-114.0788985},"streetAddress":{"apt":"","formattedAddressLine":"Florence","name":"","number":""},"formatted":"Florence, MT 59833, USA","country":"US","postalCode":"59833","subdivision":"MT"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100094421216691","teamEmail":"montanasuneaters@gmail.com","teamLogo":"wix:image://v1/6e675c_5b48e5fdb60b4f0cb32226683a4e4674~mv2.png/wavesunredevtteefybg.png#originWidth=462&originHeight=462","logoUrl":"https://static.wixstatic.com/media/6e675c_5b48e5fdb60b4f0cb32226683a4e4674~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Idaho Armored Combat Potato Mash 2026","date":"2026-06-20","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Idaho Armored Combat Invitational 2024","date":"2024-04-20","category":"5vs5","place":2},{"_id":"2","points":4.5,"Tournament":"Pacific Cup 2024","date":"2024-06-14","category":"5vs5","place":6}]},"2025":{"points12v12":0,"points5v5":6,"remainingTokens":8,"tournaments":[{"_id":"1","points":6,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":3}]}},"members":["Kyle James Olson","Jaiden Perry","Jared Webley","Will Matson","Trenton Hoskins","Wyatt Lux"],"sourceCreatedAt":"2023-07-16T03:50:27.200Z","sourceUpdatedAt":"2026-09-28T20:30:50.909Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sun Eaters',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Missoula',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'montanasuneaters@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100094421216691'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6e675c_5b48e5fdb60b4f0cb32226683a4e4674~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle James Olson','captain','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaiden Perry','fighter','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jared Webley','fighter','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Will Matson','fighter','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Trenton Hoskins','fighter','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wyatt Lux','fighter','bi_teams','https://www.buhurtinternational.com/team/sun-eaters','sun-eaters',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sword-gym-münchen' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sword-gym-münchen' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sword Gym München','Munich',true,'active','public','bi-sword-gym-münchen','EU','Europe','DE','Germany','sword.gym.muenchen@gmx.de','https://www.facebook.com/VKSGM/','https://static.wixstatic.com/media/7c9ec1_214f1f928b0d4c128b2dbeb0ae03277a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sword-gym-münchen','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','Sword Gym München','Munich','sword.gym.muenchen@gmx.de','https://www.facebook.com/VKSGM/',20,'{"biCollectionId":"188ceed1-c5dc-4d76-9b4e-75cbccf72d97","teamName":"Sword Gym München","club":"Sword Gym München e.V.","gender":"Male","captain":"Patrik Kuznia","conference":"Europe","country":"Germany","city":"Munich","teamInfo":"","trainingInfo":"","trainingLocation":{"city":"München","location":{"latitude":48.1068776,"longitude":11.5857621},"streetAddress":{"apt":"","formattedAddressLine":"Weißenseestraße 45","name":"Weißenseestraße","number":"45"},"formatted":"Weißenseestraße 45, 81539 München, Germany","country":"DE","postalCode":"81539","subdivision":"BY"},"websiteFacebookUrl":"https://www.facebook.com/VKSGM/","teamEmail":"sword.gym.muenchen@gmx.de","teamLogo":"wix:image://v1/7c9ec1_214f1f928b0d4c128b2dbeb0ae03277a~mv2.png/SGM.png#originWidth=814&originHeight=933","logoUrl":"https://static.wixstatic.com/media/7c9ec1_214f1f928b0d4c128b2dbeb0ae03277a~mv2.png","rank5v5":8,"averagePoints5v5":3,"points5v5":9,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":5},{"_id":"2","points":3,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":4},{"_id":"3","points":4,"Tournament":"Valley of Warriors Buhurt Tournament 2026","date":"2026-06-06","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":5},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":6}]},"2025":{"tournaments":[{"_id":"1","points":3,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":5},{"_id":"2","points":1,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":8},{"_id":"3","points":6,"Tournament":"Valley of Warriors Buhurt Tournament 2025","date":"2025-06-07","category":"5vs5","place":2},{"_id":"4","points":4,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":4},{"_id":"5","points":2,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":5}],"points12v12":0,"averagePoints5v5":4.33,"rank5v5":7,"remainingTokens":8,"points5v5":16}},"members":["Patrik Kuznia","Ingo Sievers","Benjamin slabik","Johannes Schumacher","Michael Bußjäger","Franz Handschuher","Daniel \"Aschi\" Aschenbrenner","Josef Schmerer","Felix Sander","Stefan Dunka","Dominic Miklos Somogyi","Maximilian Bacek","Sebastian Brehovsky"],"sourceCreatedAt":"2023-08-07T10:18:37.329Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sword Gym München',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Munich',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'sword.gym.muenchen@gmx.de'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/VKSGM/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7c9ec1_214f1f928b0d4c128b2dbeb0ae03277a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patrik Kuznia','captain','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ingo Sievers','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin slabik','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johannes Schumacher','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Bußjäger','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Franz Handschuher','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel "Aschi" Aschenbrenner','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josef Schmerer','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Felix Sander','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stefan Dunka','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominic Miklos Somogyi','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maximilian Bacek','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Brehovsky','fighter','bi_teams','https://www.buhurtinternational.com/team/sword-gym-m%C3%BCnchen','sword-gym-münchen',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='swords-of-cygnus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-swords-of-cygnus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Swords of Cygnus','Central',true,'active','public','bi-swords-of-cygnus','EU','Europe','GB','United Kingdom','Swordsofcygnus@gmail.com','https://www.swordsofcygnus.co.uk/','https://static.wixstatic.com/media/907cdd_55160ed573f74cbc9a0c516f434098fb~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','swords-of-cygnus','https://www.buhurtinternational.com/team/swords-of-cygnus','Swords of Cygnus','Central','Swordsofcygnus@gmail.com','https://www.swordsofcygnus.co.uk/',20,'{"biCollectionId":"6b0ae156-83b6-469c-909e-8dde725f9bf2","teamName":"Swords of Cygnus","club":null,"gender":"Female","captain":"Cat Booth","conference":"Europe","country":"United Kingdom","city":"Central","teamInfo":"","trainingInfo":"","trainingLocation":{"city":"Birmingham","location":{"latitude":52.48624299999999,"longitude":-1.890401},"streetAddress":{"apt":"","formattedAddressLine":"Birmingham","name":"","number":""},"formatted":"Birmingham, UK","country":"GB"},"websiteFacebookUrl":"https://www.swordsofcygnus.co.uk/","teamEmail":"Swordsofcygnus@gmail.com","teamLogo":"wix:image://v1/907cdd_55160ed573f74cbc9a0c516f434098fb~mv2.png/OFFICIAL%20LOGO%20Transparent%20Background.png#originWidth=1592&originHeight=1228","logoUrl":"https://static.wixstatic.com/media/907cdd_55160ed573f74cbc9a0c516f434098fb~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Anastasia","Cat Booth","Steffanie Holbrook","Stephanie Shepherd","Rebecca Griff"],"sourceCreatedAt":"2023-08-28T15:45:55.577Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Swords of Cygnus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Central',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Swordsofcygnus@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.swordsofcygnus.co.uk/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/907cdd_55160ed573f74cbc9a0c516f434098fb~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anastasia','fighter','bi_teams','https://www.buhurtinternational.com/team/swords-of-cygnus','swords-of-cygnus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cat Booth','captain','bi_teams','https://www.buhurtinternational.com/team/swords-of-cygnus','swords-of-cygnus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steffanie Holbrook','fighter','bi_teams','https://www.buhurtinternational.com/team/swords-of-cygnus','swords-of-cygnus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephanie Shepherd','fighter','bi_teams','https://www.buhurtinternational.com/team/swords-of-cygnus','swords-of-cygnus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebecca Griff','fighter','bi_teams','https://www.buhurtinternational.com/team/swords-of-cygnus','swords-of-cygnus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='sydney-city-marauders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-sydney-city-marauders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Sydney City Marauders','Sydney',true,'active','public','bi-sydney-city-marauders','OC','Oceania','AU','Australia','hmb-scm@outlook.com',NULL,'https://static.wixstatic.com/media/b2ba71_f328b6a086f445a6866b79705de3d998~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','sydney-city-marauders','https://www.buhurtinternational.com/team/sydney-city-marauders','Sydney City Marauders','Sydney','hmb-scm@outlook.com',NULL,20,'{"biCollectionId":"44a6dfb0-271f-4712-a2c7-79e030492e06","teamName":"Sydney City Marauders","club":null,"gender":"Male","captain":"Seth Stewart","conference":"APAC","country":"Australia","city":"Sydney","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"hmb-scm@outlook.com","teamLogo":"wix:image://v1/b2ba71_f328b6a086f445a6866b79705de3d998~mv2.png/ShieldTransparent.png#originWidth=1602&originHeight=1900","logoUrl":"https://static.wixstatic.com/media/b2ba71_f328b6a086f445a6866b79705de3d998~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"Tournament":"Winterfest Cup 2026","_id":"1","category":"5vs5","date":"2026-07-04"},{"_id":"2","points":0,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":13}],"eventsHistory":{},"members":["Seth Stewart","Jason Rauwerda","Jack Pope","Xavier Managreve","Richard Nicholas Gage","Joshua vanderlugt","William Major","Matt Solomonson","Jerome Joseph Grguric"],"sourceCreatedAt":"2026-05-28T06:21:16.637Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Sydney City Marauders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sydney',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hmb-scm@outlook.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b2ba71_f328b6a086f445a6866b79705de3d998~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Seth Stewart','captain','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Rauwerda','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Pope','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Xavier Managreve','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Nicholas Gage','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua vanderlugt','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Major','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matt Solomonson','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerome Joseph Grguric','fighter','bi_teams','https://www.buhurtinternational.com/team/sydney-city-marauders','sydney-city-marauders',now());
end $$;
commit;
