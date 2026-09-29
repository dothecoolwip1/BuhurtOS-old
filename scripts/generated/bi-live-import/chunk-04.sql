begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hellions' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hellions' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Hellions','Gloucester',true,'active','public','bi-hellions','EU','Europe','GB','United Kingdom','info@armouredcombat.co.uk','https://www.facebook.com/ArmouredCombat/','https://static.wixstatic.com/media/9246e4_9a5578a855d742a0bc6e42a627d27dda~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hellions','https://www.buhurtinternational.com/team/hellions','Hellions','Gloucester','info@armouredcombat.co.uk','https://www.facebook.com/ArmouredCombat/',20,'{"biCollectionId":"0b64f217-ed2f-44d6-97bb-fda684b5424b","teamName":"Hellions","club":null,"gender":"Female","captain":"Rebecca Godfrey ","conference":"Europe","country":"United Kingdom","city":"Gloucester","teamInfo":"","trainingInfo":"We usually hold two beginners classes a year for new female fighters, however if you are interested please feel free to get in touch and we can see about getting you started asap. All information and sign up can be found on our website","trainingLocation":{"subdivisions":[{"code":"England","name":"England","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Gloucestershire","name":"Gloucestershire","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"GB","name":"United Kingdom","type":"COUNTRY"}],"city":"Gloucester","location":{"latitude":51.85594620000001,"longitude":-2.2502468},"streetAddress":{"apt":"","formattedAddressLine":"Morelands Trading Estate","name":"Morelands Trading Estate","number":""},"formatted":"Morelands Trading Estate, Gloucester GL1, UK","country":"GB","postalCode":"GL1","subdivision":"ENG"},"websiteFacebookUrl":"https://www.facebook.com/ArmouredCombat/","teamEmail":"info@armouredcombat.co.uk","teamLogo":"wix:image://v1/9246e4_9a5578a855d742a0bc6e42a627d27dda~mv2.jpg/sketch-1770025607382.jpg#originWidth=720&originHeight=720","logoUrl":"https://static.wixstatic.com/media/9246e4_9a5578a855d742a0bc6e42a627d27dda~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":11,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":2},{"_id":"2","points":5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":2},{"_id":"2","points":8,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":1},{"_id":"3","points":7,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":1}]},"2025":{"points12v12":0,"points5v5":7,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":3},{"_id":"2","points":5,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":2}]}},"members":["Toni King","Rachael Green","Georgie Bearder","Marieke Burmanje","Evie Spurdle","Heather Cumming","Tasha Hinder","Kirstie Townsend","Rebecca Tams","Margarita Athymariti","Rebecca Godfrey","Daisy May Hooper"],"sourceCreatedAt":"2023-09-14T19:28:21.794Z","sourceUpdatedAt":"2026-09-28T16:55:48.389Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Hellions',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Gloucester',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@armouredcombat.co.uk'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ArmouredCombat/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9246e4_9a5578a855d742a0bc6e42a627d27dda~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Toni King','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachael Green','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Georgie Bearder','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marieke Burmanje','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evie Spurdle','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heather Cumming','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tasha Hinder','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kirstie Townsend','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebecca Tams','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Margarita Athymariti','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rebecca Godfrey','captain','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daisy May Hooper','fighter','bi_teams','https://www.buhurtinternational.com/team/hellions','hellions',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='helsinki-medieval-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-helsinki-medieval-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Helsinki Medieval Combat','Helsinki',true,'active','public','bi-helsinki-medieval-combat','EU','Europe','FI','Finland','jkormu79@gmail.com','https://helsinkimedievalcombat.com/','https://static.wixstatic.com/media/92c395_8a26ba68a88f43c7b565724adfd2833d~mv2.png','Helsinki local club helped by reinforcements from Turku club MCS ABOENSIS')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','helsinki-medieval-combat','https://www.buhurtinternational.com/team/helsinki-medieval-combat','Helsinki Medieval Combat','Helsinki','jkormu79@gmail.com','https://helsinkimedievalcombat.com/',20,'{"biCollectionId":"4f5442c7-edb5-4b74-bc3f-af4fc6ecd131","teamName":"Helsinki Medieval Combat","club":"Helsinki Medieval Combat","gender":"Male","captain":null,"conference":"Europe","country":"Finland","city":"Helsinki","teamInfo":"Helsinki local club helped by reinforcements from Turku club MCS ABOENSIS","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://helsinkimedievalcombat.com/","teamEmail":"jkormu79@gmail.com","teamLogo":"wix:image://v1/92c395_8a26ba68a88f43c7b565724adfd2833d~mv2.png/HMC_RUND.png#originWidth=2041&originHeight=2006","logoUrl":"https://static.wixstatic.com/media/92c395_8a26ba68a88f43c7b565724adfd2833d~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Santeri Paukku","Kimmo Nurkse","Janne Moilanen","Antti Jalonen","Lauri Snellman","Rami Klemetti","Frans Kuusela"],"sourceCreatedAt":"2024-05-23T17:38:52.669Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Helsinki Medieval Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Helsinki',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jkormu79@gmail.com'),
 website_url=coalesce(t.website_url,'https://helsinkimedievalcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/92c395_8a26ba68a88f43c7b565724adfd2833d~mv2.png'),
 public_description=coalesce(t.public_description,'Helsinki local club helped by reinforcements from Turku club MCS ABOENSIS'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Santeri Paukku','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kimmo Nurkse','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Janne Moilanen','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antti Jalonen','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lauri Snellman','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rami Klemetti','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frans Kuusela','fighter','bi_teams','https://www.buhurtinternational.com/team/helsinki-medieval-combat','helsinki-medieval-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='helvete' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-helvete' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Helvete',NULL,true,'active','public','bi-helvete','EU','Europe','CH','Switzerland','lagarnisondemontby@gmail.com',NULL,'https://static.wixstatic.com/media/385ef3_51fdff3bcddd44cea0a212a095b97238~mv2.jpg','We&#x27;re the only women swiss team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','helvete','https://www.buhurtinternational.com/team/helvete','Helvete',NULL,'lagarnisondemontby@gmail.com',NULL,20,'{"biCollectionId":"b837a21d-43ba-4ae2-8f00-77c14c186aae","teamName":"Helvete","club":null,"gender":"Female","captain":"Nora Preisse","conference":"Europe","country":"Switzerland","city":null,"teamInfo":"We&#x27;re the only women swiss team","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"lagarnisondemontby@gmail.com","teamLogo":"wix:image://v1/385ef3_51fdff3bcddd44cea0a212a095b97238~mv2.jpg/365449299_748643720398845_8492080868065653037_n.jpg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/385ef3_51fdff3bcddd44cea0a212a095b97238~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":5,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"3vs3","place":2}]}},"members":["Nora Preisse","Preisse Nora","BOUDET Aline","Emeline Barbier"],"sourceCreatedAt":"2025-03-22T21:26:36.094Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Helvete',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CH',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Switzerland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lagarnisondemontby@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/385ef3_51fdff3bcddd44cea0a212a095b97238~mv2.jpg'),
 public_description=coalesce(t.public_description,'We&#x27;re the only women swiss team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nora Preisse','captain','bi_teams','https://www.buhurtinternational.com/team/helvete','helvete',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Preisse Nora','fighter','bi_teams','https://www.buhurtinternational.com/team/helvete','helvete',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BOUDET Aline','fighter','bi_teams','https://www.buhurtinternational.com/team/helvete','helvete',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emeline Barbier','fighter','bi_teams','https://www.buhurtinternational.com/team/helvete','helvete',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='heroic-hares' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-heroic-hares' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Heroic Hares','Melbourne ',true,'active','public','bi-heroic-hares','OC','Oceania','AU','Australia','ruthless.rabbits.general@gmail.com',NULL,'https://static.wixstatic.com/media/77f463_ff78e0f770ca40e4ae367f2537bfae9d~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','heroic-hares','https://www.buhurtinternational.com/team/heroic-hares','Heroic Hares','Melbourne ','ruthless.rabbits.general@gmail.com',NULL,20,'{"biCollectionId":"ff62d49b-a826-4e00-97f8-702ea418747f","teamName":"Heroic Hares","club":null,"gender":"Female","captain":"Kat Vigakottr","conference":"APAC","country":"Australia","city":"Melbourne ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"ruthless.rabbits.general@gmail.com","teamLogo":"wix:image://v1/77f463_ff78e0f770ca40e4ae367f2537bfae9d~mv2.png/Screenshot_20260518-232104.png#originWidth=857&originHeight=1011","logoUrl":"https://static.wixstatic.com/media/77f463_ff78e0f770ca40e4ae367f2537bfae9d~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"Tournament":"Legends of Steel 2026","_id":"1","category":"3vs3","date":"2026-05-23"}],"eventsHistory":{},"members":["Kat Vigakottr","Elise Desira","Ava Osborn"],"sourceCreatedAt":"2026-05-18T20:22:21.172Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Heroic Hares',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Melbourne ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ruthless.rabbits.general@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/77f463_ff78e0f770ca40e4ae367f2537bfae9d~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kat Vigakottr','captain','bi_teams','https://www.buhurtinternational.com/team/heroic-hares','heroic-hares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elise Desira','fighter','bi_teams','https://www.buhurtinternational.com/team/heroic-hares','heroic-hares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ava Osborn','fighter','bi_teams','https://www.buhurtinternational.com/team/heroic-hares','heroic-hares',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hippogriffs' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hippogriffs' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Hippogriffs','Canberra',true,'active','public','bi-hippogriffs','OC','Oceania','AU','Australia','lslorach@outlook.com',NULL,'https://static.wixstatic.com/media/bc1a35_0b49751f94c2431e90abcb02e2349e9f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hippogriffs','https://www.buhurtinternational.com/team/hippogriffs','Hippogriffs','Canberra','lslorach@outlook.com',NULL,20,'{"biCollectionId":"fb541b58-5bbe-4780-b57b-4d49e3a058ed","teamName":"Hippogriffs","club":null,"gender":"Female","captain":"Laura Slorach","conference":"APAC","country":"Australia","city":"Canberra","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"ACT","name":"Australian Capital Territory","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"location":{"latitude":-35.2190806,"longitude":149.1274964},"streetAddress":{"apt":"10","formattedAddressLine":"10/80 Bellenden St","name":"Bellenden Street","number":"80"},"formatted":"10/80 Bellenden St, Australian Capital Territory 2912, Australia","country":"AU","postalCode":"2912","subdivision":"ACT"},"websiteFacebookUrl":null,"teamEmail":"lslorach@outlook.com","teamLogo":"wix:image://v1/bc1a35_0b49751f94c2431e90abcb02e2349e9f~mv2.png/Marion%20-%20Shield.png#originWidth=10833&originHeight=10833","logoUrl":"https://static.wixstatic.com/media/bc1a35_0b49751f94c2431e90abcb02e2349e9f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Laura Slorach","Skye Ambrose"],"sourceCreatedAt":"2026-08-12T09:00:23.641Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Hippogriffs',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Canberra',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lslorach@outlook.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bc1a35_0b49751f94c2431e90abcb02e2349e9f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laura Slorach','captain','bi_teams','https://www.buhurtinternational.com/team/hippogriffs','hippogriffs',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Skye Ambrose','fighter','bi_teams','https://www.buhurtinternational.com/team/hippogriffs','hippogriffs',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hmb-academy-florence' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hmb-academy-florence' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'HMB Academy Florence',NULL,true,'active','public','bi-hmb-academy-florence','EU','Europe','IT','Italy','enricobernardeschi@gmail.com',NULL,'https://static.wixstatic.com/media/74360a_1a085472a97a47e2b82b24d72d6bc03f~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hmb-academy-florence','https://www.buhurtinternational.com/team/hmb-academy-florence','HMB Academy Florence',NULL,'enricobernardeschi@gmail.com',NULL,20,'{"biCollectionId":"134ca6b4-7c35-4269-b5c8-641b7251cc18","teamName":"HMB Academy Florence","club":null,"gender":"Male","captain":"Enrico Bernardeschi","conference":"Europe","country":"Italy","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"enricobernardeschi@gmail.com","teamLogo":"wix:image://v1/74360a_1a085472a97a47e2b82b24d72d6bc03f~mv2.jpeg/WhatsApp%20Image%202026-09-15%20at%2015.29.45.jpeg#originWidth=1600&originHeight=1600","logoUrl":"https://static.wixstatic.com/media/74360a_1a085472a97a47e2b82b24d72d6bc03f~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Enrico Bernardeschi","Nikita Vostorgin","Duccio Baroni","Lorenzo Landi","Matteo Vacca"],"sourceCreatedAt":"2026-09-16T17:10:38.635Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('HMB Academy Florence',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'enricobernardeschi@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/74360a_1a085472a97a47e2b82b24d72d6bc03f~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Enrico Bernardeschi','captain','bi_teams','https://www.buhurtinternational.com/team/hmb-academy-florence','hmb-academy-florence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nikita Vostorgin','fighter','bi_teams','https://www.buhurtinternational.com/team/hmb-academy-florence','hmb-academy-florence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Duccio Baroni','fighter','bi_teams','https://www.buhurtinternational.com/team/hmb-academy-florence','hmb-academy-florence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lorenzo Landi','fighter','bi_teams','https://www.buhurtinternational.com/team/hmb-academy-florence','hmb-academy-florence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matteo Vacca','fighter','bi_teams','https://www.buhurtinternational.com/team/hmb-academy-florence','hmb-academy-florence',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='honeybadgers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-honeybadgers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Honeybadgers','Taupo',true,'active','public','bi-honeybadgers','OC','Oceania','NZ','New Zealand','davidshells@xtra.co.nz','https://www.facebook.com/TaupoArmouredCombatSteelThorns','https://static.wixstatic.com/media/f7e60d_a9e3e692cfa64cdd9009a7425015b1f0~mv2.jpeg','We are a team based out of Taupo. We train twice a week, mainly Buhurt.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','honeybadgers','https://www.buhurtinternational.com/team/honeybadgers','Honeybadgers','Taupo','davidshells@xtra.co.nz','https://www.facebook.com/TaupoArmouredCombatSteelThorns',20,'{"biCollectionId":"abbb4940-3591-493b-af56-d5e82990479f","teamName":"Honeybadgers","club":null,"gender":"Male","captain":"David Briscoe","conference":"APAC","country":"New Zealand","city":"Taupo","teamInfo":"We are a team based out of Taupo. We train twice a week, mainly Buhurt.","trainingInfo":"Anyone wanting to train with us just needs to bring comfortable clothes and shoes and a water bottle.","trainingLocation":{"subdivisions":[{"code":"Waikato","name":"Waikato","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Taupō","name":"Taupō","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"NZ","name":"New Zealand","type":"COUNTRY"}],"city":"Taupō","location":{"latitude":-38.68676800000001,"longitude":176.1076989},"streetAddress":{"apt":"","formattedAddressLine":"79 Miro Street","name":"Miro Street","number":"79"},"formatted":"79 Miro Street, Tauhara, Taupō 3378, New Zealand","country":"NZ","postalCode":"3378"},"websiteFacebookUrl":"https://www.facebook.com/TaupoArmouredCombatSteelThorns","teamEmail":"davidshells@xtra.co.nz","teamLogo":"wix:image://v1/f7e60d_a9e3e692cfa64cdd9009a7425015b1f0~mv2.jpeg/IMG_0622.jpeg#originWidth=948&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/f7e60d_a9e3e692cfa64cdd9009a7425015b1f0~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"5vs5","place":5},{"_id":"2","points":7,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":14,"remainingTokens":9,"tournaments":[{"_id":"1","points":6,"Tournament":"Wesley Hastings Cup 2025","date":"2025-02-14","category":"5vs5","place":1},{"_id":"2","points":8,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":5}]}},"members":["Ian Hendl","Lee barwell","David Briscoe","Dylan Bines","Nicholas montin","Kade sinclair","Colm O''Brien","Daryen William George Berben","Jared Eastergaard","Nigel Austin","James Colliver"],"sourceCreatedAt":"2024-02-16T07:57:45.125Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Honeybadgers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Taupo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'davidshells@xtra.co.nz'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TaupoArmouredCombatSteelThorns'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f7e60d_a9e3e692cfa64cdd9009a7425015b1f0~mv2.jpeg'),
 public_description=coalesce(t.public_description,'We are a team based out of Taupo. We train twice a week, mainly Buhurt.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Hendl','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lee barwell','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Briscoe','captain','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Bines','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas montin','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kade sinclair','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colm O''Brien','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daryen William George Berben','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jared Eastergaard','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nigel Austin','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Colliver','fighter','bi_teams','https://www.buhurtinternational.com/team/honeybadgers','honeybadgers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='hospodars' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-hospodars' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Hospodars',NULL,true,'active','public','bi-hospodars','EU','Europe','MD','Moldova','hospodars.team@gmail.com',NULL,'https://static.wixstatic.com/media/4e0345_e3984731b1224ec194797fea19a2eb50~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','hospodars','https://www.buhurtinternational.com/team/hospodars','Hospodars',NULL,'hospodars.team@gmail.com',NULL,20,'{"biCollectionId":"096ba097-6b4b-4407-bf70-168622cad23a","teamName":"Hospodars","club":null,"gender":"Male","captain":"Bîrca Alexandr","conference":"Europe","country":"Moldova","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"hospodars.team@gmail.com","teamLogo":"wix:image://v1/4e0345_e3984731b1224ec194797fea19a2eb50~mv2.jpg/601001816_1479280169806764_1228445064193966342_n.jpg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/4e0345_e3984731b1224ec194797fea19a2eb50~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Valley of Warriors Buhurt Tournament 2026","date":"2026-06-06","category":"5vs5","place":5}],"eventsHistory":{},"members":["Bîrca Alexandr","Alexandr Birca","Nikolai Ivashchenko","Oleg Sergheev","Alex Tozlovanu","Alexandr Cebotari","Yevhenii Potsiluienko"],"sourceCreatedAt":"2026-01-09T16:06:46.150Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Hospodars',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('MD',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Moldova',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hospodars.team@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4e0345_e3984731b1224ec194797fea19a2eb50~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bîrca Alexandr','captain','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandr Birca','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nikolai Ivashchenko','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oleg Sergheev','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Tozlovanu','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandr Cebotari','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yevhenii Potsiluienko','fighter','bi_teams','https://www.buhurtinternational.com/team/hospodars','hospodars',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iac---shrew-crew' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iac---shrew-crew' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'IAC - Shrew Crew','Boise',true,'active','public','bi-iac---shrew-crew','NA','North America','US','United States','idahoarmoredcombat@gmail.com','https://www.idahoarmoredcombat.com/','https://static.wixstatic.com/media/eef379_530d3e0abbe747cfabed065e4e2e43ff~mv2.jpg','PNW Idaho Based Women&#x27;s Team - fighting/practicing with the Rat Pack, Idaho Armored Combat')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iac---shrew-crew','https://www.buhurtinternational.com/team/iac---shrew-crew','IAC - Shrew Crew','Boise','idahoarmoredcombat@gmail.com','https://www.idahoarmoredcombat.com/',20,'{"biCollectionId":"833fa56b-7dea-4351-822c-263e480a0a60","teamName":"IAC - Shrew Crew","club":null,"gender":"Female","captain":"Jennelle Brunner","conference":"North America","country":"United States","city":"Boise","teamInfo":"PNW Idaho Based Women&#x27;s Team - fighting/practicing with the Rat Pack, Idaho Armored Combat","trainingInfo":"We practice 3 times a week, check out our website and discord to learn more!","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.idahoarmoredcombat.com/","teamEmail":"idahoarmoredcombat@gmail.com","teamLogo":"wix:image://v1/eef379_530d3e0abbe747cfabed065e4e2e43ff~mv2.jpg/347120111_1459047594868658_5790062655700647883_n.jpg#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/eef379_530d3e0abbe747cfabed065e4e2e43ff~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":6}},"members":["Jennelle Brunner"],"sourceCreatedAt":"2025-08-12T21:28:04.410Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('IAC - Shrew Crew',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Boise',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'idahoarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.idahoarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/eef379_530d3e0abbe747cfabed065e4e2e43ff~mv2.jpg'),
 public_description=coalesce(t.public_description,'PNW Idaho Based Women&#x27;s Team - fighting/practicing with the Rat Pack, Idaho Armored Combat'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jennelle Brunner','captain','bi_teams','https://www.buhurtinternational.com/team/iac---shrew-crew','iac---shrew-crew',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='icarus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-icarus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Icarus','Mantova Piacenza Parma',true,'active','public','bi-icarus','EU','Europe','IT','Italy','teamicarusmf@gmail.com','https://www.facebook.com/profile.php?id=100078375452984/ - https://www.facebook.com/TheMarvelousChickenYard/','https://static.wixstatic.com/media/a05492_3af7056d80b1445b85a4c66a1b0644a5~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','icarus','https://www.buhurtinternational.com/team/icarus','Icarus','Mantova Piacenza Parma','teamicarusmf@gmail.com','https://www.facebook.com/profile.php?id=100078375452984/ - https://www.facebook.com/TheMarvelousChickenYard/',20,'{"biCollectionId":"aa779eb7-b08f-42c3-ae4c-21a421cd5d15","teamName":"Icarus","club":null,"gender":"Male","captain":"Alessandro Vernizzi","conference":"Europe","country":"Italy","city":"Mantova Piacenza Parma","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"Fidenza - Piacenza - Mantova"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100078375452984/ - https://www.facebook.com/TheMarvelousChickenYard/","teamEmail":"teamicarusmf@gmail.com","teamLogo":"wix:image://v1/a05492_3af7056d80b1445b85a4c66a1b0644a5~mv2.png/Logo%20Icarus.png#originWidth=1000&originHeight=1110","logoUrl":"https://static.wixstatic.com/media/a05492_3af7056d80b1445b85a4c66a1b0644a5~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Tavola Rotonda 2024","date":"2024-06-08","category":"5vs5","place":3},{"_id":"2","points":8,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2},{"_id":"3","points":3,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":8}]},"2025":{"points12v12":0,"points5v5":15,"remainingTokens":10,"tournaments":[{"_id":"1","points":9,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":2},{"_id":"2","points":6,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":3}]}},"members":["Alessandro Vernizzi","Omar Corda","Francesco Galli","Francesco Di Pietro","Gianni brivio","Lorenzo Ape","Edoardo Sergi","Roberto fontana","Lorenzo Toffali","Tazio Nosari","Yuri Corda","Armando Mancini","Ivo Cappelletti","Davide Lippi"],"sourceCreatedAt":"2023-08-24T12:32:42.717Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Icarus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mantova Piacenza Parma',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'teamicarusmf@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100078375452984/ - https://www.facebook.com/TheMarvelousChickenYard/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a05492_3af7056d80b1445b85a4c66a1b0644a5~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alessandro Vernizzi','captain','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Omar Corda','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesco Galli','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesco Di Pietro','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gianni brivio','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lorenzo Ape','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Edoardo Sergi','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roberto fontana','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lorenzo Toffali','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tazio Nosari','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yuri Corda','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Armando Mancini','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivo Cappelletti','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Davide Lippi','fighter','bi_teams','https://www.buhurtinternational.com/team/icarus','icarus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ignis-bellum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ignis-bellum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'IGNIS Bellum','Buenos Aires ',true,'active','public','bi-ignis-bellum','SA','South America','AR','Argentina','Rodriguez _brian@outlook.com','https://www.facebook.com/IGNISMedieval?mibextid=kFxxJD','https://static.wixstatic.com/media/d44b05_e26e91f8c0dc4caf9630eea3a57f84fa~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ignis-bellum','https://www.buhurtinternational.com/team/ignis-bellum','IGNIS Bellum','Buenos Aires ','Rodriguez _brian@outlook.com','https://www.facebook.com/IGNISMedieval?mibextid=kFxxJD',20,'{"biCollectionId":"2a97a5e1-a472-45ef-9858-dbb40be2d0a9","teamName":"IGNIS Bellum","club":null,"gender":"Male","captain":"Brian Rodriguez","conference":"South America","country":"Argentina","city":"Buenos Aires ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/IGNISMedieval?mibextid=kFxxJD","teamEmail":"Rodriguez _brian@outlook.com","teamLogo":"wix:image://v1/d44b05_e26e91f8c0dc4caf9630eea3a57f84fa~mv2.png/1698413009782.png#originWidth=1600&originHeight=1600","logoUrl":"https://static.wixstatic.com/media/d44b05_e26e91f8c0dc4caf9630eea3a57f84fa~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Copa Centinela 2024","date":"2024-05-04","category":"5vs5","place":3}]},"2025":{"remainingTokens":10}},"members":["Brian Rodriguez","Brian Horacio Rodriguez","Sergio nicolas Di gaetano","Nicolas Caram","Federico Bárcena","Martin Suárez","Samuel David Ludueña","Jorge eduardo campagno","Ignacio Moreno"],"sourceCreatedAt":"2024-04-16T00:00:33.792Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('IGNIS Bellum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Buenos Aires ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Rodriguez _brian@outlook.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/IGNISMedieval?mibextid=kFxxJD'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d44b05_e26e91f8c0dc4caf9630eea3a57f84fa~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Rodriguez','captain','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Horacio Rodriguez','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio nicolas Di gaetano','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicolas Caram','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Federico Bárcena','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Suárez','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel David Ludueña','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jorge eduardo campagno','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ignacio Moreno','fighter','bi_teams','https://www.buhurtinternational.com/team/ignis-bellum','ignis-bellum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='illawarra-manticore-medieval-combat-inc' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-illawarra-manticore-medieval-combat-inc' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Illawarra Manticore Medieval Combat Inc','Lake Illawarra ',true,'active','public','bi-illawarra-manticore-medieval-combat-inc','OC','Oceania','AU','Australia','manticoreillawarra@gmail.com','https://www.facebook.com/share/19yoMb8Qpb/','https://static.wixstatic.com/media/113006_30b9e1e4c0314bd6bc69999e08ac43b6~mv2.png','We are the Illawarra Manticore! We are an Illawarra-based team competing in the AMCF (Australian Medieval Combat Federation) and HMB (Historical medieval battle), united by a shared passion for history, combat and the unique challenges of buhurt that forges an unbreakable bond among participants.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','illawarra-manticore-medieval-combat-inc','https://www.buhurtinternational.com/team/illawarra-manticore-medieval-combat-inc','Illawarra Manticore Medieval Combat Inc','Lake Illawarra ','manticoreillawarra@gmail.com','https://www.facebook.com/share/19yoMb8Qpb/',20,'{"biCollectionId":"5bd4568f-9501-4de6-b3df-486fb8045f20","teamName":"Illawarra Manticore Medieval Combat Inc","club":null,"gender":"Male","captain":"Steven King-gee","conference":"APAC","country":"Australia","city":"Lake Illawarra ","teamInfo":"We are the Illawarra Manticore! We are an Illawarra-based team competing in the AMCF (Australian Medieval Combat Federation) and HMB (Historical medieval battle), united by a shared passion for history, combat and the unique challenges of buhurt that forges an unbreakable bond among participants.","trainingInfo":"We provide multiple weekly training session. Based in Lake Illawarra NSW 2528. We welcome individuals of all fitness backgrounds to join our team.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/19yoMb8Qpb/","teamEmail":"manticoreillawarra@gmail.com","teamLogo":"wix:image://v1/113006_30b9e1e4c0314bd6bc69999e08ac43b6~mv2.png/PNG.png#originWidth=2189&originHeight=2310","logoUrl":"https://static.wixstatic.com/media/113006_30b9e1e4c0314bd6bc69999e08ac43b6~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":10}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1.5,"remainingTokens":7,"tournaments":[{"_id":"1","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":11}]}},"members":["Steven King-gee","Steve King-Gee","Jacob Ty Sumelj","Aaron Gouveia"],"sourceCreatedAt":"2025-09-05T22:13:58.847Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Illawarra Manticore Medieval Combat Inc',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lake Illawarra ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'manticoreillawarra@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/19yoMb8Qpb/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/113006_30b9e1e4c0314bd6bc69999e08ac43b6~mv2.png'),
 public_description=coalesce(t.public_description,'We are the Illawarra Manticore! We are an Illawarra-based team competing in the AMCF (Australian Medieval Combat Federation) and HMB (Historical medieval battle), united by a shared passion for history, combat and the unique challenges of buhurt that forges an unbreakable bond among participants.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven King-gee','captain','bi_teams','https://www.buhurtinternational.com/team/illawarra-manticore-medieval-combat-inc','illawarra-manticore-medieval-combat-inc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steve King-Gee','fighter','bi_teams','https://www.buhurtinternational.com/team/illawarra-manticore-medieval-combat-inc','illawarra-manticore-medieval-combat-inc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Ty Sumelj','fighter','bi_teams','https://www.buhurtinternational.com/team/illawarra-manticore-medieval-combat-inc','illawarra-manticore-medieval-combat-inc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron Gouveia','fighter','bi_teams','https://www.buhurtinternational.com/team/illawarra-manticore-medieval-combat-inc','illawarra-manticore-medieval-combat-inc',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='imperium' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-imperium' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Imperium','Sanford/Fuquay-Varina ',true,'active','public','bi-imperium','NA','North America','US','United States','imperium.armored.combat@gmail.com','https://www.facebook.com/imperiumarmoredcombat','https://static.wixstatic.com/media/774814_ea3696479f02406087c7d82e5a7b9a02~mv2.jpg','We are a Central NC mens/womens armored combat team. Currently training and fighting out of Sanford/Fuquay-Varina right outside the states Capital City of Raleigh.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','imperium','https://www.buhurtinternational.com/team/imperium','Imperium','Sanford/Fuquay-Varina ','imperium.armored.combat@gmail.com','https://www.facebook.com/imperiumarmoredcombat',20,'{"biCollectionId":"3fc17e97-55f5-4a25-9941-f95498d926ba","teamName":"Imperium","club":"Imperium","gender":"Male","captain":"Jason Noakes","conference":"North America","country":"United States","city":"Sanford/Fuquay-Varina ","teamInfo":"We are a Central NC mens/womens armored combat team. Currently training and fighting out of Sanford/Fuquay-Varina right outside the states Capital City of Raleigh.","trainingInfo":"We do allow random people to join training after we talk to them online to set things up.","trainingLocation":{"subdivisions":[{"code":"NC","name":"North Carolina","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Lee County","name":"Lee County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Sanford","name":"Sanford","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Sanford","location":{"latitude":35.4798757,"longitude":-79.1802994},"streetAddress":{"apt":"","formattedAddressLine":"Sanford","name":"","number":""},"formatted":"Sanford, NC, USA","country":"US","subdivision":"NC"},"websiteFacebookUrl":"https://www.facebook.com/imperiumarmoredcombat","teamEmail":"imperium.armored.combat@gmail.com","teamLogo":"wix:image://v1/774814_ea3696479f02406087c7d82e5a7b9a02~mv2.jpg/330399155_132131239784624_1150920918506911931_n.jpg#originWidth=715&originHeight=712","logoUrl":"https://static.wixstatic.com/media/774814_ea3696479f02406087c7d82e5a7b9a02~mv2.jpg","rank5v5":14,"averagePoints5v5":2.08,"points5v5":6.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":14},{"_id":"2","points":5,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":3},{"_id":"3","points":1.25,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":14},{"_id":"4","points":0,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"12vs12","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":15},{"_id":"2","points":0,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":7}]},"2025":{"tournaments":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":22},{"_id":"2","points":0,"Tournament":"Tournament of Legends 2025","date":"2025-04-26","category":"5vs5","place":5},{"_id":"3","points":1,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":9}],"points12v12":0,"averagePoints5v5":0.33,"rank5v5":20,"remainingTokens":10,"points5v5":1}},"members":["Rian Freeman","Mike Stephenson","Jason McCardle","Jason Noakes","Tristan Cahill","Jason King","Tyler  Shockley","Chaz antinori","Collin Kelley","Christopher Clark"],"sourceCreatedAt":"2023-09-14T01:31:00.698Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Imperium',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sanford/Fuquay-Varina ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'imperium.armored.combat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/imperiumarmoredcombat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/774814_ea3696479f02406087c7d82e5a7b9a02~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a Central NC mens/womens armored combat team. Currently training and fighting out of Sanford/Fuquay-Varina right outside the states Capital City of Raleigh.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rian Freeman','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mike Stephenson','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason McCardle','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Noakes','captain','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tristan Cahill','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason King','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler  Shockley','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chaz antinori','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Collin Kelley','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Clark','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium','imperium',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='imperium-victrix' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-imperium-victrix' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Imperium Victrix','Sanford NC',true,'active','public','bi-imperium-victrix','NA','North America','US','United States','imperium.armored.combat.victrix@gmail.com',NULL,'https://static.wixstatic.com/media/8131e3_ed5c0078ab02401aba5a255d3746b4c4~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','imperium-victrix','https://www.buhurtinternational.com/team/imperium-victrix','Imperium Victrix','Sanford NC','imperium.armored.combat.victrix@gmail.com',NULL,20,'{"biCollectionId":"a1ea8e1a-6773-461e-b069-3d330a8b53e2","teamName":"Imperium Victrix","club":null,"gender":"Female","captain":"Morgan King","conference":"North America","country":"United States","city":"Sanford NC","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"NC","name":"North Carolina","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Lee County","name":"Lee County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Sanford","name":"Sanford","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Sanford","location":{"latitude":35.4798757,"longitude":-79.1802994},"streetAddress":{"apt":"","formattedAddressLine":"Sanford","name":"","number":""},"formatted":"Sanford, NC, USA","country":"US","subdivision":"NC"},"websiteFacebookUrl":null,"teamEmail":"imperium.armored.combat.victrix@gmail.com","teamLogo":"wix:image://v1/8131e3_ed5c0078ab02401aba5a255d3746b4c4~mv2.jpg/Screenshot_20250613_160724_Photos.jpg#originWidth=955&originHeight=965","logoUrl":"https://static.wixstatic.com/media/8131e3_ed5c0078ab02401aba5a255d3746b4c4~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Morgan King","Ashley Wagner","Yasmine Ketchie","Bee Perlstein","Laine Jeston-Fenton"],"sourceCreatedAt":"2026-08-11T17:42:34.437Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Imperium Victrix',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sanford NC',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'imperium.armored.combat.victrix@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8131e3_ed5c0078ab02401aba5a255d3746b4c4~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Morgan King','captain','bi_teams','https://www.buhurtinternational.com/team/imperium-victrix','imperium-victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ashley Wagner','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium-victrix','imperium-victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Yasmine Ketchie','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium-victrix','imperium-victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bee Perlstein','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium-victrix','imperium-victrix',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laine Jeston-Fenton','fighter','bi_teams','https://www.buhurtinternational.com/team/imperium-victrix','imperium-victrix',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='independence-dragons' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-independence-dragons' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Independence Dragons','São Paulo',true,'active','public','bi-independence-dragons','SA','South America','BR','Brazil','nathan.scherer637@gmail.com','https://www.instagram.com/dragoes_hmb/','https://static.wixstatic.com/media/3522cb_748c9d112a5e406285e548f8ab04cbe3~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','independence-dragons','https://www.buhurtinternational.com/team/independence-dragons','Independence Dragons','São Paulo','nathan.scherer637@gmail.com','https://www.instagram.com/dragoes_hmb/',20,'{"biCollectionId":"f7a21479-453a-43f0-ab8f-93b9792c1044","teamName":"Independence Dragons","club":null,"gender":"Male","captain":"Nathan Scherer","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.instagram.com/dragoes_hmb/","teamEmail":"nathan.scherer637@gmail.com","teamLogo":"wix:image://v1/3522cb_748c9d112a5e406285e548f8ab04cbe3~mv2.jpeg/WhatsApp%20Image%202023-06-27%20at%2017.15.43.jpeg#originWidth=640&originHeight=640","logoUrl":"https://static.wixstatic.com/media/3522cb_748c9d112a5e406285e548f8ab04cbe3~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Nathan Scherer","Nathan de Cerqueira Leite Scherer","Ygor Peluso"],"sourceCreatedAt":"2023-06-27T21:21:51.582Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Independence Dragons',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nathan.scherer637@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/dragoes_hmb/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3522cb_748c9d112a5e406285e548f8ab04cbe3~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Scherer','captain','bi_teams','https://www.buhurtinternational.com/team/independence-dragons','independence-dragons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan de Cerqueira Leite Scherer','fighter','bi_teams','https://www.buhurtinternational.com/team/independence-dragons','independence-dragons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ygor Peluso','fighter','bi_teams','https://www.buhurtinternational.com/team/independence-dragons','independence-dragons',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='indomitus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-indomitus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Indomitus','Madrid',true,'active','public','bi-indomitus','EU','Europe','ES','Spain','indomitus.medievalcombat@gmail.com','Indomitus Armored Combat Team ','https://static.wixstatic.com/media/d88007_5f5bf293534842c3971b65ddf4d0379f~mv2.jpg','Training We do allow anyone to come and join us for training, however we do ask for contact first so we know to expect you.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','indomitus','https://www.buhurtinternational.com/team/indomitus','Indomitus','Madrid','indomitus.medievalcombat@gmail.com','Indomitus Armored Combat Team ',20,'{"biCollectionId":"60b7df63-905e-4308-8548-3f0bb73438de","teamName":"Indomitus","club":null,"gender":"Male","captain":"Rubén Cabello González","conference":"Europe","country":"Spain","city":"Madrid","teamInfo":"Training We do allow anyone to come and join us for training, however we do ask for contact first so we know to expect you.","trainingInfo":"Indomitus are a medieval combat team based in Madrid.","trainingLocation":{"subdivisions":[{"code":"MD","name":"Community of Madrid","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"M","name":"Madrid","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Cubas de la Sagra","name":"Cubas de la Sagra","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"ES","name":"Spain","type":"COUNTRY"}],"city":"Cubas de la Sagra","location":{"latitude":40.1910568,"longitude":-3.8372005},"streetAddress":{"apt":"","formattedAddressLine":"Cubas de la Sagra","name":"","number":""},"formatted":"28978 Cubas de la Sagra, Madrid, Spain","country":"ES","postalCode":"28978","subdivision":"MD"},"websiteFacebookUrl":"Indomitus Armored Combat Team ","teamEmail":"indomitus.medievalcombat@gmail.com","teamLogo":"wix:image://v1/d88007_5f5bf293534842c3971b65ddf4d0379f~mv2.jpg/INDOMITUS%20LOGO%20MODIFICADO.jpg#originWidth=1078&originHeight=1448","logoUrl":"https://static.wixstatic.com/media/d88007_5f5bf293534842c3971b65ddf4d0379f~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Rubén Cabello González","Segain Julian","Ivan Oscar Pippino Carpinetti","Julio Burgos viedma","Adrian Pradillo Carchenilla","Ricardo Montilla","DROBNJAK dany","David Sanz","Daniel Martinez Perez"],"sourceCreatedAt":"2024-11-27T10:11:28.532Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Indomitus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Madrid',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'indomitus.medievalcombat@gmail.com'),
 website_url=coalesce(t.website_url,'Indomitus Armored Combat Team '),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d88007_5f5bf293534842c3971b65ddf4d0379f~mv2.jpg'),
 public_description=coalesce(t.public_description,'Training We do allow anyone to come and join us for training, however we do ask for contact first so we know to expect you.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rubén Cabello González','captain','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Segain Julian','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Oscar Pippino Carpinetti','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julio Burgos viedma','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Pradillo Carchenilla','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ricardo Montilla','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'DROBNJAK dany','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Sanz','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Martinez Perez','fighter','bi_teams','https://www.buhurtinternational.com/team/indomitus','indomitus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='invaders-armored-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-invaders-armored-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Invaders Armored Combat','Carlsbad, New Mexico',true,'active','public','bi-invaders-armored-combat','NA','North America','US','United States','shay.gerge@gmail.com','https://www.facebook.com/share/17kkHWrkck/?mibextid=wwXIfr','https://static.wixstatic.com/media/d32336_7408c542e3db49f592f6a7dc3ce534db~mv2.png','Primarily located in Carlsbad, New Mexico, we have members all across Southeastern & Central New Mexico and El Paso, Texas. We are always looking to get our a**** kicked and hopefully learn something from it.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','invaders-armored-combat','https://www.buhurtinternational.com/team/invaders-armored-combat','Invaders Armored Combat','Carlsbad, New Mexico','shay.gerge@gmail.com','https://www.facebook.com/share/17kkHWrkck/?mibextid=wwXIfr',20,'{"biCollectionId":"0d275f6d-b375-4517-b1b3-5a3a01470814","teamName":"Invaders Armored Combat","club":null,"gender":"Male","captain":"Shay Gregory","conference":"North America","country":"United States","city":"Carlsbad, New Mexico","teamInfo":"Primarily located in Carlsbad, New Mexico, we have members all across Southeastern & Central New Mexico and El Paso, Texas. We are always looking to get our a**** kicked and hopefully learn something from it.","trainingInfo":"Reach out to our Facebook page to be added to our practice group chat. Practices are typically every Saturday morning in Carlsbad, New Mexico but have ad-hoc practices in Roswell/Dexter, Las Cruces, Ruidoso, and El Paso when there is enough interest.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/17kkHWrkck/?mibextid=wwXIfr","teamEmail":"shay.gerge@gmail.com","teamLogo":"wix:image://v1/d32336_7408c542e3db49f592f6a7dc3ce534db~mv2.png/IMG_9294.png#originWidth=819&originHeight=785","logoUrl":"https://static.wixstatic.com/media/d32336_7408c542e3db49f592f6a7dc3ce534db~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Shay Gregory"],"sourceCreatedAt":"2025-11-03T23:23:55.794Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Invaders Armored Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Carlsbad, New Mexico',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'shay.gerge@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/17kkHWrkck/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d32336_7408c542e3db49f592f6a7dc3ce534db~mv2.png'),
 public_description=coalesce(t.public_description,'Primarily located in Carlsbad, New Mexico, we have members all across Southeastern & Central New Mexico and El Paso, Texas. We are always looking to get our a**** kicked and hopefully learn something from it.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shay Gregory','captain','bi_teams','https://www.buhurtinternational.com/team/invaders-armored-combat','invaders-armored-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='invicta' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-invicta' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Invicta','London',true,'active','public','bi-invicta','EU','Europe','GB','United Kingdom','Rowlandlongley1985@gmail.com','https://www.facebook.com/invicta.bh','https://static.wixstatic.com/media/ec34a7_7d7d2566a9dc4b6d89ecce1288bf604f~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','invicta','https://www.buhurtinternational.com/team/invicta','Invicta','London','Rowlandlongley1985@gmail.com','https://www.facebook.com/invicta.bh',20,'{"biCollectionId":"bdfe220e-559b-4177-b436-ede049c97389","teamName":"Invicta","club":null,"gender":"Male","captain":"Rowland Longley","conference":"Europe","country":"United Kingdom","city":"London","teamInfo":"","trainingInfo":"come along","trainingLocation":{"subdivisions":[{"code":"England","name":"England","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Surrey","name":"Surrey","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Caterham","name":"Caterham","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"GB","name":"United Kingdom","type":"COUNTRY"}],"city":"Caterham","location":{"latitude":51.28029600000001,"longitude":-0.08161589999999999},"streetAddress":{"apt":"","formattedAddressLine":"Caterham","name":"","number":""},"formatted":"Caterham, UK","country":"GB","subdivision":"ENG"},"websiteFacebookUrl":"https://www.facebook.com/invicta.bh","teamEmail":"Rowlandlongley1985@gmail.com","teamLogo":"wix:image://v1/ec34a7_7d7d2566a9dc4b6d89ecce1288bf604f~mv2.jpeg/448136F8-C55D-4FA1-ACBF-A3E7232D63D8.jpeg#originWidth=2048&originHeight=1536","logoUrl":"https://static.wixstatic.com/media/ec34a7_7d7d2566a9dc4b6d89ecce1288bf604f~mv2.jpeg","rank5v5":2,"averagePoints5v5":13.5,"points5v5":45.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":13,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":2},{"_id":"2","points":12.5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":2},{"_id":"3","points":5,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":3},{"_id":"4","points":15,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":7,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"12vs12","place":3},{"_id":"3","points":12,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":2},{"_id":"4","points":6,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":4},{"_id":"5","points":2,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"12vs12","place":3},{"_id":"6","points":10,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2},{"_id":"7","points":10,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":12,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":2},{"_id":"2","points":12,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":2},{"_id":"3","points":16,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":13.33,"rank5v5":2,"remainingTokens":9,"points5v5":40}},"members":["Rowland Longley","Ben Robertson","Gareth Kong","Jacob Cronin","Gregory Prior","Andrew Keeley","Jack Hallums","Doug Atkins","Andrew Wigley","Morgan wells","Seb Greaves","Steve Hegarty","Josh Stevenson-Mant","George Batchelor","Grzegorz Adam Warras"],"sourceCreatedAt":"2023-06-21T15:54:51.046Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Invicta',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('London',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Rowlandlongley1985@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/invicta.bh'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ec34a7_7d7d2566a9dc4b6d89ecce1288bf604f~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rowland Longley','captain','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Robertson','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gareth Kong','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Cronin','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Prior','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Keeley','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Hallums','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Doug Atkins','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Wigley','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Morgan wells','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Seb Greaves','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steve Hegarty','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Stevenson-Mant','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'George Batchelor','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Grzegorz Adam Warras','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta','invicta',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='invicta-rising' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-invicta-rising' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Invicta Rising','London',true,'active','public','bi-invicta-rising','EU','Europe','GB','United Kingdom','benrobertson122@gmail.com','https://www.invictamedievalcombat.co.uk/','https://static.wixstatic.com/media/32147b_25229f8f76304c82a1abe6dee6a98ac1~mv2.jpeg','Invicta Rising is the second‑team of Invicta Medieval Combat — one of the UK’s leading Buhurt clubs. Founded in 2017, Invicta has grown into a national powerhouse and regularly fields teams at major tournaments.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','invicta-rising','https://www.buhurtinternational.com/team/invicta-rising','Invicta Rising','London','benrobertson122@gmail.com','https://www.invictamedievalcombat.co.uk/',20,'{"biCollectionId":"bb28654e-0d3b-4d57-82dc-9c50f2403d8b","teamName":"Invicta Rising","club":null,"gender":"Male","captain":null,"conference":"Europe","country":"United Kingdom","city":"London","teamInfo":"Invicta Rising is the second‑team of Invicta Medieval Combat — one of the UK’s leading Buhurt clubs. Founded in 2017, Invicta has grown into a national powerhouse and regularly fields teams at major tournaments.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.invictamedievalcombat.co.uk/","teamEmail":"benrobertson122@gmail.com","teamLogo":"wix:image://v1/32147b_25229f8f76304c82a1abe6dee6a98ac1~mv2.jpeg/WhatsApp%20Image%202025-12-10%20at%2015.03.47.jpeg#originWidth=2048&originHeight=1536","logoUrl":"https://static.wixstatic.com/media/32147b_25229f8f76304c82a1abe6dee6a98ac1~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Alastair Dean","Blaze Kerwin","Benjamin Chisholm","Oskars Vilnitis-Pantelejevs","Andrew Jansen van Vuuren"],"sourceCreatedAt":"2025-12-04T19:20:32.746Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Invicta Rising',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('London',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'benrobertson122@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.invictamedievalcombat.co.uk/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/32147b_25229f8f76304c82a1abe6dee6a98ac1~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Invicta Rising is the second‑team of Invicta Medieval Combat — one of the UK’s leading Buhurt clubs. Founded in 2017, Invicta has grown into a national powerhouse and regularly fields teams at major tournaments.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alastair Dean','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta-rising','invicta-rising',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blaze Kerwin','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta-rising','invicta-rising',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Chisholm','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta-rising','invicta-rising',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oskars Vilnitis-Pantelejevs','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta-rising','invicta-rising',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Jansen van Vuuren','fighter','bi_teams','https://www.buhurtinternational.com/team/invicta-rising','invicta-rising',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='invictus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-invictus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Invictus','Murray',true,'active','public','bi-invictus','NA','North America','US','United States','info@invictusarmoredcombat.com','https://www.facebook.com/invictus.armored.combat','https://static.wixstatic.com/media/ace4b4_6533664bf04a47df902bbab45d721914~mv2.jpg','Armored combat team based out of Salt Lake, Utah. We have a permanent indoor facility in the heart of murray utah.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','invictus','https://www.buhurtinternational.com/team/invictus','Invictus','Murray','info@invictusarmoredcombat.com','https://www.facebook.com/invictus.armored.combat',20,'{"biCollectionId":"0d78ee85-6e72-491c-9807-7fcf25b2c9e5","teamName":"Invictus","club":null,"gender":"Male","captain":"Tre Waldrum","conference":"North America","country":"United States","city":"Murray","teamInfo":"Armored combat team based out of Salt Lake, Utah. We have a permanent indoor facility in the heart of murray utah.","trainingInfo":"Appropriate clothing and closed toes shoes.","trainingLocation":{"subdivisions":[{"code":"UT","name":"Utah","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Salt Lake County","name":"Salt Lake County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Murray","name":"Murray","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Murray","location":{"latitude":40.6711387,"longitude":-111.8944846},"streetAddress":{"apt":"","formattedAddressLine":"30 150 W St","name":"150 West Street","number":"30"},"formatted":"30 150 W St, Murray, UT 84107, USA","country":"US","postalCode":"84107","subdivision":"UT"},"websiteFacebookUrl":"https://www.facebook.com/invictus.armored.combat","teamEmail":"info@invictusarmoredcombat.com","teamLogo":"wix:image://v1/ace4b4_6533664bf04a47df902bbab45d721914~mv2.jpg/Invictus%20Logo.jpg#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/ace4b4_6533664bf04a47df902bbab45d721914~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Idaho Armored Combat Potato Mash 2026","date":"2026-06-20","category":"5vs5","place":4},{"_id":"2","points":4,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":1,"Tournament":"Colorado Classic 3 2025","date":"2025-06-07","category":"5vs5","place":4},{"_id":"2","points":1,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":6},{"_id":"3","points":2,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":1.33,"rank5v5":18,"remainingTokens":9,"points5v5":4}},"members":["Tre Waldrum","James Lee","Jacob Omer","Tyler Davis","Khaiden Haney","Bart Lopez","Gary Norton","Matthew Peterson","Brandon Comish","Grant Holmes","Jonathan Cheney","James Bridger Brandt","John Tucker V","Chandler Joseph Hunt"],"sourceCreatedAt":"2024-08-05T16:40:57.383Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Invictus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Murray',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@invictusarmoredcombat.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/invictus.armored.combat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ace4b4_6533664bf04a47df902bbab45d721914~mv2.jpg'),
 public_description=coalesce(t.public_description,'Armored combat team based out of Salt Lake, Utah. We have a permanent indoor facility in the heart of murray utah.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tre Waldrum','captain','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Lee','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Omer','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Khaiden Haney','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bart Lopez','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gary Norton','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Peterson','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Comish','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Grant Holmes','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Cheney','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Bridger Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Tucker V','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chandler Joseph Hunt','fighter','bi_teams','https://www.buhurtinternational.com/team/invictus','invictus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='irmandade-dos-espinhos' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-irmandade-dos-espinhos' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Irmandade dos Espinhos','São Paulo',true,'active','public','bi-irmandade-dos-espinhos','SA','South America','BR','Brazil','makacowow@gmail.com',NULL,'https://static.wixstatic.com/media/ad636f_bd2950dfd98f4fd6a6cb7629c7629a11~mv2.png','A Irmandade dos Espinhos nasceu em 2018! Somos parte do clube Dragões da Independência e esperamos você em nossos laçoes de amizade, dentro e fora da liça!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','irmandade-dos-espinhos','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','Irmandade dos Espinhos','São Paulo','makacowow@gmail.com',NULL,20,'{"biCollectionId":"96de16e6-54b5-48f2-883f-3b004ecd6763","teamName":"Irmandade dos Espinhos","club":null,"gender":"Male","captain":"Nathan \"Pendragon\" Scherer","conference":"South America","country":"Brazil","city":"São Paulo","teamInfo":"A Irmandade dos Espinhos nasceu em 2018! Somos parte do clube Dragões da Independência e esperamos você em nossos laçoes de amizade, dentro e fora da liça!","trainingInfo":"Pra agendar seu treino conosco, mande e-mail pra makacowow@gmail.com","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"makacowow@gmail.com","teamLogo":"wix:image://v1/ad636f_bd2950dfd98f4fd6a6cb7629c7629a11~mv2.png/Irmandade%20Logo.png#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/ad636f_bd2950dfd98f4fd6a6cb7629c7629a11~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Nathan \"Pendragon\" Scherer","Daniel Strazzabosco Rosa","Luiz  \"Leão\"","Igor Rodrigues Alves","Miguel Vinicius Santos Albiach","Ricardo Spagnuolo Martins"],"sourceCreatedAt":"2025-03-07T17:09:39.035Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Irmandade dos Espinhos',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('São Paulo',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'makacowow@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ad636f_bd2950dfd98f4fd6a6cb7629c7629a11~mv2.png'),
 public_description=coalesce(t.public_description,'A Irmandade dos Espinhos nasceu em 2018! Somos parte do clube Dragões da Independência e esperamos você em nossos laçoes de amizade, dentro e fora da liça!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan "Pendragon" Scherer','captain','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Strazzabosco Rosa','fighter','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luiz  "Leão"','fighter','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Igor Rodrigues Alves','fighter','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel Vinicius Santos Albiach','fighter','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ricardo Spagnuolo Martins','fighter','bi_teams','https://www.buhurtinternational.com/team/irmandade-dos-espinhos','irmandade-dos-espinhos',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iron-alliance' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iron-alliance' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Iron Alliance','Springfield MO',true,'active','public','bi-iron-alliance','NA','North America','US','United States','c.k.taylor27@att.net','https://www.facebook.com/profile.php?id=100091745344629','https://static.wixstatic.com/media/a0fbe2_154c475ada8247b7b7c1aa1fc6fdb0ab~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iron-alliance','https://www.buhurtinternational.com/team/iron-alliance','Iron Alliance','Springfield MO','c.k.taylor27@att.net','https://www.facebook.com/profile.php?id=100091745344629',20,'{"biCollectionId":"e7e7c781-1578-4ea1-89c7-3c4a505db61e","teamName":"Iron Alliance","club":null,"gender":"Male","captain":"Christopher Kirby Taylor","conference":"North America","country":"United States","city":"Springfield MO","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100091745344629","teamEmail":"c.k.taylor27@att.net","teamLogo":"wix:image://v1/a0fbe2_154c475ada8247b7b7c1aa1fc6fdb0ab~mv2.jpeg/Messenger_creation_8C934457-72CB-4008-B400-7FE488F5E517.jpeg#originWidth=500&originHeight=500","logoUrl":"https://static.wixstatic.com/media/a0fbe2_154c475ada8247b7b7c1aa1fc6fdb0ab~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Kayden Bruneau","Christopher Kirby Taylor","Tucker Snow","William venolia","JD Highfill"],"sourceCreatedAt":"2026-02-13T23:44:16.374Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Iron Alliance',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Springfield MO',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'c.k.taylor27@att.net'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100091745344629'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a0fbe2_154c475ada8247b7b7c1aa1fc6fdb0ab~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayden Bruneau','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-alliance','iron-alliance',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Kirby Taylor','captain','bi_teams','https://www.buhurtinternational.com/team/iron-alliance','iron-alliance',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tucker Snow','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-alliance','iron-alliance',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William venolia','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-alliance','iron-alliance',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JD Highfill','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-alliance','iron-alliance',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iron-lions-vanguard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iron-lions-vanguard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Iron Lions Vanguard','Fairfax, VA',true,'active','public','bi-iron-lions-vanguard','NA','North America','US','United States','ironlionsunited@gmail.com','https://www.facebook.com/ironlionsunited','https://static.wixstatic.com/media/4b1591_7ea285154f1346b39f70858f4337546e~mv2.png','Our club is based out of northern Virginia. We started in 2020, training and learning all about the sport. since then we have had a strong Core of fighters, most of which are still with the club today.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iron-lions-vanguard','https://www.buhurtinternational.com/team/iron-lions-vanguard','Iron Lions Vanguard','Fairfax, VA','ironlionsunited@gmail.com','https://www.facebook.com/ironlionsunited',20,'{"biCollectionId":"48976da9-862f-400f-b5fa-c9ebe5c216ff","teamName":"Iron Lions Vanguard","club":null,"gender":"Male","captain":"Kevin Leclerc","conference":"North America","country":"United States","city":"Fairfax, VA","teamInfo":"Our club is based out of northern Virginia. We started in 2020, training and learning all about the sport. since then we have had a strong Core of fighters, most of which are still with the club today.","trainingInfo":"We train hard and strive to continue learning and adapting to the higher levels of competition.","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/ironlionsunited","teamEmail":"ironlionsunited@gmail.com","teamLogo":"wix:image://v1/4b1591_7ea285154f1346b39f70858f4337546e~mv2.png/Shield%20Logo.png#originWidth=979&originHeight=1048","logoUrl":"https://static.wixstatic.com/media/4b1591_7ea285154f1346b39f70858f4337546e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":20,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":3},{"_id":"2","points":4.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":6},{"_id":"3","points":2,"Tournament":"Grapes of Wrath 2024","date":"2024-05-18","category":"5vs5","place":4},{"_id":"4","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":6},{"_id":"5","points":3,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":4}]},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":7},{"_id":"2","points":3,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":6}]}},"members":["Kevin Leclerc","Andrew Ferrio","Justin Ray Parker","Sean Levey","Cory Boroff","James DeLucas","Maddox Wheeler","Damian bruno","Robert Patrick Altobelli"],"sourceCreatedAt":"2023-06-27T22:19:13.551Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Iron Lions Vanguard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Fairfax, VA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ironlionsunited@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ironlionsunited'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4b1591_7ea285154f1346b39f70858f4337546e~mv2.png'),
 public_description=coalesce(t.public_description,'Our club is based out of northern Virginia. We started in 2020, training and learning all about the sport. since then we have had a strong Core of fighters, most of which are still with the club today.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kevin Leclerc','captain','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Ferrio','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin Ray Parker','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Levey','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cory Boroff','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James DeLucas','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maddox Wheeler','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damian bruno','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Patrick Altobelli','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-lions-vanguard','iron-lions-vanguard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iron-tower' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iron-tower' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Iron Tower','Pisa',true,'active','public','bi-iron-tower','EU','Europe','IT','Italy','iron.tower.italy@gmail.com','https://www.facebook.com/share/1CPv4AsYNA/','https://static.wixstatic.com/media/968f11_0cc8204a94974f158f091702fd85ec3e~mv2.jpg','🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships🇮🇹 GO HARD OR GO HOME⚔ #iro 🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships 🇮🇹 GO HARD OR GO HOME⚔ #irontower')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iron-tower','https://www.buhurtinternational.com/team/iron-tower','Iron Tower','Pisa','iron.tower.italy@gmail.com','https://www.facebook.com/share/1CPv4AsYNA/',20,'{"biCollectionId":"4a0b9ffe-da2e-4b9b-9251-56655189200f","teamName":"Iron Tower","club":null,"gender":"Male","captain":"Sara Fabbri","conference":"Europe","country":"Italy","city":"Pisa","teamInfo":"🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships🇮🇹 GO HARD OR GO HOME⚔ #iro 🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships 🇮🇹 GO HARD OR GO HOME⚔ #irontower","trainingInfo":"We have 3 gyms in Tuscany: Mugello (Florence) Lucca Livorno Our list: Santa Maria a Monte (Pisa) Contacts us to train with us! DM Instagram & FB","trainingLocation":{"subdivisions":[{"code":"Tuscany","name":"Tuscany","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"PI","name":"Province of Pisa","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Ponticelli","name":"Ponticelli","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IT","name":"Italy","type":"COUNTRY"}],"city":"Ponticelli","location":{"latitude":43.6987496,"longitude":10.6912592},"streetAddress":{"apt":"","formattedAddressLine":"Ponticelli","name":"","number":""},"formatted":"56020 Ponticelli, Province of Pisa, Italy","country":"IT","postalCode":"56020","subdivision":"BO"},"websiteFacebookUrl":"https://www.facebook.com/share/1CPv4AsYNA/","teamEmail":"iron.tower.italy@gmail.com","teamLogo":"wix:image://v1/968f11_0cc8204a94974f158f091702fd85ec3e~mv2.jpg/IMG-20250907-WA0001.jpg#originWidth=1080&originHeight=1211","logoUrl":"https://static.wixstatic.com/media/968f11_0cc8204a94974f158f091702fd85ec3e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":8}},"members":["Sara Fabbri","Marco De Maria","Gabriele Franchi"],"sourceCreatedAt":"2025-09-07T09:18:20.111Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Iron Tower',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Pisa',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'iron.tower.italy@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1CPv4AsYNA/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/968f11_0cc8204a94974f158f091702fd85ec3e~mv2.jpg'),
 public_description=coalesce(t.public_description,'🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships🇮🇹 GO HARD OR GO HOME⚔ #iro 🛡Medieval Fight Team in Tuscany (Italy)🛡 ⚔ Duel, Profight, Buhurt, Mass Battles 🇮🇹 2011-2025 World Championships 🇮🇹 GO HARD OR GO HOME⚔ #irontower'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sara Fabbri','captain','bi_teams','https://www.buhurtinternational.com/team/iron-tower','iron-tower',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco De Maria','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-tower','iron-tower',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriele Franchi','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-tower','iron-tower',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iron-wolves' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iron-wolves' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Iron Wolves','Aalborg',true,'active','public','bi-iron-wolves','EU','Europe','DK','Denmark','themetaljackhead@gmail.com','https://www.facebook.com/IronWolvesDK/','https://static.wixstatic.com/media/b61dae_ebf909ab66b54344a8d390812b53b3e0~mv2.jpg','Iron Wolves is the team that grew from the ashes of Danish Buhurt.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iron-wolves','https://www.buhurtinternational.com/team/iron-wolves','Iron Wolves','Aalborg','themetaljackhead@gmail.com','https://www.facebook.com/IronWolvesDK/',20,'{"biCollectionId":"8ddefecd-a988-4d07-bd3d-f4221fb91df1","teamName":"Iron Wolves","club":"Iron Wolves","gender":"Male","captain":"Frederik Søjborg","conference":"Europe","country":"Denmark","city":"Aalborg","teamInfo":"Iron Wolves is the team that grew from the ashes of Danish Buhurt.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Nørresundby","name":"Nørresundby","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"DK","name":"Denmark","type":"COUNTRY"}],"city":"Nørresundby","location":{"latitude":57.0724234,"longitude":9.9004697},"streetAddress":{"apt":"","formattedAddressLine":"Frederik Raschs Vej 15","name":"Frederik Raschs Vej","number":"15"},"formatted":"Frederik Raschs Vej 15, 9400 Nørresundby, Denmark","country":"DK","postalCode":"9400"},"websiteFacebookUrl":"https://www.facebook.com/IronWolvesDK/","teamEmail":"themetaljackhead@gmail.com","teamLogo":"wix:image://v1/b61dae_ebf909ab66b54344a8d390812b53b3e0~mv2.jpg/Netlogo.JPG#originWidth=617&originHeight=640","logoUrl":"https://static.wixstatic.com/media/b61dae_ebf909ab66b54344a8d390812b53b3e0~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":18,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":18,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":11,"remainingTokens":9,"tournaments":[{"_id":"1","points":11,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":2}]}},"members":["Henrik Majgaard Nielsen","Martin Allesøe","Frederik Søjborg","Sebastian Atke Højen Møller","Jan Udengaard Simonsen","Heine Holmquist Vistrup Erichsen","Berthil Møller","Johnny Andersen","William Watts","Martin Granding","Lucas Timm","Viktor Bech Jensen","Dennis Baun Larsen","David Larsen","Martin Søndergaard Adelstorp","Benjamin Krüger Runager","Oscar Gregers Nielsen"],"sourceCreatedAt":"2024-01-24T22:14:32.507Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Iron Wolves',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Aalborg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DK',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Denmark',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'themetaljackhead@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/IronWolvesDK/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b61dae_ebf909ab66b54344a8d390812b53b3e0~mv2.jpg'),
 public_description=coalesce(t.public_description,'Iron Wolves is the team that grew from the ashes of Danish Buhurt.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henrik Majgaard Nielsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Allesøe','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frederik Søjborg','captain','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Atke Højen Møller','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Udengaard Simonsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heine Holmquist Vistrup Erichsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Berthil Møller','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johnny Andersen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Watts','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Granding','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Timm','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Viktor Bech Jensen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Baun Larsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Larsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Søndergaard Adelstorp','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin Krüger Runager','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oscar Gregers Nielsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves','iron-wolves',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='iron-wolves-women''s-team' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-iron-wolves-women''s-team' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Iron Wolves Women''s Team','Aalborg',true,'active','public','bi-iron-wolves-women''s-team','EU','Europe','DK','Denmark','Mirajohansen@yahoo.dk',NULL,'https://static.wixstatic.com/media/7b959d_140d5a1d82744bc0b2269e4d3d8ae5eb~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','iron-wolves-women''s-team','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','Iron Wolves Women''s Team','Aalborg','Mirajohansen@yahoo.dk',NULL,20,'{"biCollectionId":"9be1cda1-4347-4b77-996c-e046f6b262b6","teamName":"Iron Wolves Women''s Team","club":null,"gender":"Female","captain":"Mira Anneke Aagaard","conference":"Europe","country":"Denmark","city":"Aalborg","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"Mirajohansen@yahoo.dk","teamLogo":"wix:image://v1/7b959d_140d5a1d82744bc0b2269e4d3d8ae5eb~mv2.jpg/3332158e-968e-40bc-8c67-a25593d3081a.jpg#originWidth=1021&originHeight=1021","logoUrl":"https://static.wixstatic.com/media/7b959d_140d5a1d82744bc0b2269e4d3d8ae5eb~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Sandra Udengaard Simonsen","Amanda Solveig Kruse","Mira Anneke Aagaard","Ida Lehm Madsen","Emilia Marie Kasper","Tina Krohn Detlevsen","Frida Lillemose","Caroline CVETANOVIC","Mariana Kimberly Cruz Noverón"],"sourceCreatedAt":"2026-01-20T14:52:48.624Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Iron Wolves Women''s Team',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Aalborg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DK',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Denmark',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Mirajohansen@yahoo.dk'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7b959d_140d5a1d82744bc0b2269e4d3d8ae5eb~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sandra Udengaard Simonsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amanda Solveig Kruse','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mira Anneke Aagaard','captain','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ida Lehm Madsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emilia Marie Kasper','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tina Krohn Detlevsen','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frida Lillemose','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caroline CVETANOVIC','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariana Kimberly Cruz Noverón','fighter','bi_teams','https://www.buhurtinternational.com/team/iron-wolves-women''s-team','iron-wolves-women''s-team',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ironclad-academy-of-the-sword' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ironclad-academy-of-the-sword' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ironclad Academy of the Sword','Adelaide',true,'active','public','bi-ironclad-academy-of-the-sword','OC','Oceania','AU','Australia','darrien.newcombe@gmail.com','https://ironclad-au.squarespace.com/','https://static.wixstatic.com/media/816efe_50cb384b3d5647bfa098865642322361~mv2.png','Ironclad Academy of the Sword is based in Adelaide, specialising in armoured dueling, HEMA and reenactment combat. We have a number of emerging duelists competing in both armoured and soft duel combat.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ironclad-academy-of-the-sword','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','Ironclad Academy of the Sword','Adelaide','darrien.newcombe@gmail.com','https://ironclad-au.squarespace.com/',20,'{"biCollectionId":"42edcbe8-9450-4806-8c9c-16c0709e0bf6","teamName":"Ironclad Academy of the Sword","club":null,"gender":"Male","captain":"Darrien Newcombe","conference":"APAC","country":"Australia","city":"Adelaide","teamInfo":"Ironclad Academy of the Sword is based in Adelaide, specialising in armoured dueling, HEMA and reenactment combat. We have a number of emerging duelists competing in both armoured and soft duel combat.","trainingInfo":"Please contact us via social media for details on joining us!","trainingLocation":{"city":"Hindmarsh","location":{"latitude":-34.9058302,"longitude":138.570272},"streetAddress":{"apt":"","formattedAddressLine":"Hindmarsh","name":"","number":""},"formatted":"Hindmarsh SA 5007, Australia","country":"AU","postalCode":"5007","subdivision":"SA"},"websiteFacebookUrl":"https://ironclad-au.squarespace.com/","teamEmail":"darrien.newcombe@gmail.com","teamLogo":"wix:image://v1/816efe_50cb384b3d5647bfa098865642322361~mv2.png/Ironclad.png#originWidth=1319&originHeight=1319","logoUrl":"https://static.wixstatic.com/media/816efe_50cb384b3d5647bfa098865642322361~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Darrien Newcombe","Luka Byrne","Raimund Ze''ev","Justin Flory","Nicholas Bevan"],"sourceCreatedAt":"2023-09-12T08:54:49.946Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ironclad Academy of the Sword',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Adelaide',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'darrien.newcombe@gmail.com'),
 website_url=coalesce(t.website_url,'https://ironclad-au.squarespace.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/816efe_50cb384b3d5647bfa098865642322361~mv2.png'),
 public_description=coalesce(t.public_description,'Ironclad Academy of the Sword is based in Adelaide, specialising in armoured dueling, HEMA and reenactment combat. We have a number of emerging duelists competing in both armoured and soft duel combat.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Darrien Newcombe','captain','bi_teams','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','ironclad-academy-of-the-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luka Byrne','fighter','bi_teams','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','ironclad-academy-of-the-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raimund Ze''ev','fighter','bi_teams','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','ironclad-academy-of-the-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin Flory','fighter','bi_teams','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','ironclad-academy-of-the-sword',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Bevan','fighter','bi_teams','https://www.buhurtinternational.com/team/ironclad-academy-of-the-sword','ironclad-academy-of-the-sword',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='irone-dome' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-irone-dome' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Irone Dome','Ramat gan',true,'active','public','bi-irone-dome','AS','Asia','IL','Israel','mihinius@gmail.com',NULL,'https://static.wixstatic.com/media/3a10a4_e472b29718964156a8454ab792db19b2~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','irone-dome','https://www.buhurtinternational.com/team/irone-dome','Irone Dome','Ramat gan','mihinius@gmail.com',NULL,20,'{"biCollectionId":"09e7691a-2395-46fd-a6cc-5e7d1acd4294","teamName":"Irone Dome","club":null,"gender":"Male","captain":"Michael Morgul","conference":"Europe","country":"Israel","city":"Ramat gan","teamInfo":"","trainingInfo":"We always glad for a people!","trainingLocation":{"subdivisions":[{"code":"Center District","name":"Center District","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Petach Tikva","name":"Petach Tikva","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"פ\"ת","name":"Petah Tikva","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IL","name":"Israel","type":"COUNTRY"}],"city":"Petah Tikva","location":{"latitude":32.0928789,"longitude":34.8548371},"streetAddress":{"apt":"","formattedAddressLine":"Zeev Jabotinsky St 112","name":"Zeev Jabotinsky Street","number":"112"},"formatted":"Zeev Jabotinsky St 112, Petah Tikva, Israel","country":"IL"},"websiteFacebookUrl":null,"teamEmail":"mihinius@gmail.com","teamLogo":"wix:image://v1/3a10a4_e472b29718964156a8454ab792db19b2~mv2.png/Logo_Iron_Dome_International.png#originWidth=1563&originHeight=1563","logoUrl":"https://static.wixstatic.com/media/3a10a4_e472b29718964156a8454ab792db19b2~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Michael Morgul","Andrey Alekseenko","Igor yarosh","Michael Morgulis","David Shestopal","Eitan David Rapaport"],"sourceCreatedAt":"2026-01-18T13:25:41.474Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Irone Dome',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ramat gan',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('AS',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Asia',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Israel',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mihinius@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3a10a4_e472b29718964156a8454ab792db19b2~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Morgul','captain','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrey Alekseenko','fighter','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Igor yarosh','fighter','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Morgulis','fighter','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Shestopal','fighter','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eitan David Rapaport','fighter','bi_teams','https://www.buhurtinternational.com/team/irone-dome','irone-dome',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='isca' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-isca' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'ISCA','Hereford',true,'active','public','bi-isca','EU','Europe','GB','United Kingdom','iscacaptain@gmail.com','https://www.facebook.com/IscaHMB','https://static.wixstatic.com/media/22aa5b_ee09ca4b16bc4ff6852c16c81647fca0~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','isca','https://www.buhurtinternational.com/team/isca','ISCA','Hereford','iscacaptain@gmail.com','https://www.facebook.com/IscaHMB',20,'{"biCollectionId":"6cf20096-e0e3-41f9-8992-d7b72f2b480d","teamName":"ISCA","club":null,"gender":"Male","captain":"Gregory Gosden","conference":"Europe","country":"United Kingdom","city":"Hereford","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/IscaHMB","teamEmail":"iscacaptain@gmail.com","teamLogo":"wix:image://v1/22aa5b_ee09ca4b16bc4ff6852c16c81647fca0~mv2.png/20230521_143056.png#originWidth=1938&originHeight=1644","logoUrl":"https://static.wixstatic.com/media/22aa5b_ee09ca4b16bc4ff6852c16c81647fca0~mv2.png","rank5v5":5,"averagePoints5v5":4.67,"points5v5":17,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":4},{"_id":"2","points":5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":5},{"_id":"3","points":3,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":4},{"_id":"4","points":3,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":7},{"_id":"2","points":1,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":9},{"_id":"3","points":1,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":9},{"_id":"4","points":3,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":3,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":7},{"_id":"2","points":3,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":7},{"_id":"3","points":11,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":5.67,"rank5v5":5,"remainingTokens":10,"points5v5":17}},"members":["Kyle Everton","Ben Bishop","Alex Wood","Jamie Davis","Aad Bhimarasetty","Kevin Francomb","PIotr Malak","Gregory Gosden","Willum Tiley","Josh Evans","Ben quick","Clive Jemison","Tim Spence"],"sourceCreatedAt":"2023-09-30T18:46:02.456Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('ISCA',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hereford',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'iscacaptain@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/IscaHMB'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/22aa5b_ee09ca4b16bc4ff6852c16c81647fca0~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Everton','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Bishop','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Wood','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jamie Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aad Bhimarasetty','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kevin Francomb','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PIotr Malak','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Gosden','captain','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Willum Tiley','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Josh Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben quick','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Clive Jemison','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim Spence','fighter','bi_teams','https://www.buhurtinternational.com/team/isca','isca',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='italian-bastards' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-italian-bastards' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Italian Bastards','Turin',true,'active','public','bi-italian-bastards','EU','Europe','IT','Italy','italianbastards.hmb@gmail.com','https://www.instagram.com/italian_bastards/','https://static.wixstatic.com/media/6575d4_b69d927c40804442a458c0607fa02e79~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','italian-bastards','https://www.buhurtinternational.com/team/italian-bastards','Italian Bastards','Turin','italianbastards.hmb@gmail.com','https://www.instagram.com/italian_bastards/',20,'{"biCollectionId":"0d05a436-6e80-465c-9a86-8e2170a1b700","teamName":"Italian Bastards","club":null,"gender":"Male","captain":"Luca Peinetti","conference":"Europe","country":"Italy","city":"Turin","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/italian_bastards/","teamEmail":"italianbastards.hmb@gmail.com","teamLogo":"wix:image://v1/6575d4_b69d927c40804442a458c0607fa02e79~mv2.png/Scudetto%20IB.png#originWidth=2167&originHeight=2780","logoUrl":"https://static.wixstatic.com/media/6575d4_b69d927c40804442a458c0607fa02e79~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Tavola Rotonda 2024","date":"2024-06-08","category":"5vs5","place":5},{"_id":"2","points":6,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4},{"_id":"3","points":4.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":30,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":1},{"_id":"2","points":3,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":4},{"_id":"3","points":2,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":5}],"points12v12":0,"averagePoints5v5":11.67,"rank5v5":3,"remainingTokens":10,"points5v5":35}},"members":["Gianluca Cataldi","Luca Pollaccia","Amedeo Clamer","Alessandro Vela","Sergio Quattrini","Davide Montaldo","Paolo Miotto","Nicola Lombardi","Francesco Falbo","Luca Peinetti","Roberto inzirillo","Lorenzo Valenzisi","Edoardo Maria Fusaro","Michael Kalu Perri","Fabrizio Tirapelle"],"sourceCreatedAt":"2023-07-06T11:33:13.353Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Italian Bastards',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Turin',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'italianbastards.hmb@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/italian_bastards/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6575d4_b69d927c40804442a458c0607fa02e79~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gianluca Cataldi','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Pollaccia','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amedeo Clamer','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alessandro Vela','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio Quattrini','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Davide Montaldo','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paolo Miotto','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicola Lombardi','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesco Falbo','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Peinetti','captain','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roberto inzirillo','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lorenzo Valenzisi','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Edoardo Maria Fusaro','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Kalu Perri','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabrizio Tirapelle','fighter','bi_teams','https://www.buhurtinternational.com/team/italian-bastards','italian-bastards',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='kivuttaret' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-kivuttaret' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Kivuttaret','Hämeenlinna',true,'active','public','bi-kivuttaret','EU','Europe','FI','Finland','roosamaria.jarvinen@gmail.com','https://www.facebook.com/kivuttaret','https://static.wixstatic.com/media/9ca0d8_88f3c5a4567340b4a40efcbe720b764c~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','kivuttaret','https://www.buhurtinternational.com/team/kivuttaret','Kivuttaret','Hämeenlinna','roosamaria.jarvinen@gmail.com','https://www.facebook.com/kivuttaret',20,'{"biCollectionId":"1a48e9a2-bc9b-4ef8-8e42-aeeffd24567a","teamName":"Kivuttaret","club":null,"gender":"Female","captain":"Roosa Järvinen","conference":"Europe","country":"Finland","city":"Hämeenlinna","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/kivuttaret","teamEmail":"roosamaria.jarvinen@gmail.com","teamLogo":"wix:image://v1/9ca0d8_88f3c5a4567340b4a40efcbe720b764c~mv2.png/Kivuttaret.png#originWidth=2812&originHeight=2849","logoUrl":"https://static.wixstatic.com/media/9ca0d8_88f3c5a4567340b4a40efcbe720b764c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":18,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2}]},"2025":{"remainingTokens":10}},"members":["Roosa Järvinen","Tuuli Rutanen","Tinja Lindstedt","Petra Oinonen","Miisa Kaivos","Pauliina Frimodig"],"sourceCreatedAt":"2023-07-24T17:29:37.430Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Kivuttaret',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hämeenlinna',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'roosamaria.jarvinen@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/kivuttaret'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9ca0d8_88f3c5a4567340b4a40efcbe720b764c~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roosa Järvinen','captain','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tuuli Rutanen','fighter','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tinja Lindstedt','fighter','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petra Oinonen','fighter','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miisa Kaivos','fighter','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pauliina Frimodig','fighter','bi_teams','https://www.buhurtinternational.com/team/kivuttaret','kivuttaret',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knightingales' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knightingales' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knightingales','Salt Lake City - Ogden',true,'active','public','bi-knightingales','NA','North America','US','United States','Knightingale.ut@gmail.com','https://www.facebook.com/knightingales.ut','https://static.wixstatic.com/media/399acd_fef47a435cae40aaa081d7985b98cde5~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knightingales','https://www.buhurtinternational.com/team/knightingales','Knightingales','Salt Lake City - Ogden','Knightingale.ut@gmail.com','https://www.facebook.com/knightingales.ut',20,'{"biCollectionId":"1ef678e4-8f34-4448-8e26-aeed1265d7ee","teamName":"Knightingales","club":null,"gender":"Female","captain":"Emily Bond","conference":"North America","country":"United States","city":"Salt Lake City - Ogden","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/knightingales.ut","teamEmail":"Knightingale.ut@gmail.com","teamLogo":"wix:image://v1/399acd_fef47a435cae40aaa081d7985b98cde5~mv2.jpg/Knightingale%20Logo%20Square%20larger%20background.jpg#originWidth=2740&originHeight=2740","logoUrl":"https://static.wixstatic.com/media/399acd_fef47a435cae40aaa081d7985b98cde5~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"3vs3","place":2}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Emily Bond","Paola Herrera Brandt","Saige Hinds","Dominique Martinez","April Hill","Alexa Gutierrez","Grace Haroldsen","Madeline Cole"],"sourceCreatedAt":"2025-05-26T15:55:19.885Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knightingales',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Salt Lake City - Ogden',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Knightingale.ut@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/knightingales.ut'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/399acd_fef47a435cae40aaa081d7985b98cde5~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emily Bond','captain','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paola Herrera Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Saige Hinds','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominique Martinez','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'April Hill','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexa Gutierrez','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Grace Haroldsen','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Madeline Cole','fighter','bi_teams','https://www.buhurtinternational.com/team/knightingales','knightingales',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knightmares' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knightmares' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knightmares','London',true,'active','public','bi-knightmares','EU','Europe','GB','United Kingdom','Rowlandlongley1985@gmail.com','https://www.facebook.com/invicta.bh','https://static.wixstatic.com/media/ec34a7_b1a198b5e4ee49b18a64e74d6fe6cfed~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knightmares','https://www.buhurtinternational.com/team/knightmares','Knightmares','London','Rowlandlongley1985@gmail.com','https://www.facebook.com/invicta.bh',20,'{"biCollectionId":"f5aef2ec-d6c7-4ff0-afe3-014cef28571d","teamName":"Knightmares","club":null,"gender":"Female","captain":"Bruna G. P. Longley","conference":"Europe","country":"United Kingdom","city":"London","teamInfo":"","trainingInfo":"Contact the captain for details, all welcome","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/invicta.bh","teamEmail":"Rowlandlongley1985@gmail.com","teamLogo":"wix:image://v1/ec34a7_b1a198b5e4ee49b18a64e74d6fe6cfed~mv2.jpeg/CB463699-5B91-4EC9-8B3A-709382D2A015.jpeg#originWidth=828&originHeight=750","logoUrl":"https://static.wixstatic.com/media/ec34a7_b1a198b5e4ee49b18a64e74d6fe6cfed~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":21.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":1},{"_id":"2","points":12.5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":3},{"_id":"3","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4},{"_id":"4","points":5,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":10,"tournaments":[{"_id":"1","points":3,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":3}]}},"members":["Bruna G. P. Longley","Bruna Gabriela Peixer Longley","JD Dahlgren","Celestine Eastwood","Meghan Jones","Kathryn Garner","Marina Halmenschlager Foresti","Mirian de França Santos Pereira","Rachel Terrell"],"sourceCreatedAt":"2023-06-18T20:43:17.053Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knightmares',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('London',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Rowlandlongley1985@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/invicta.bh'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ec34a7_b1a198b5e4ee49b18a64e74d6fe6cfed~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruna G. P. Longley','captain','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruna Gabriela Peixer Longley','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JD Dahlgren','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Celestine Eastwood','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Meghan Jones','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kathryn Garner','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marina Halmenschlager Foresti','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mirian de França Santos Pereira','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachel Terrell','fighter','bi_teams','https://www.buhurtinternational.com/team/knightmares','knightmares',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knights-of-albion' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knights-of-albion' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knights of Albion','Wollongong',true,'active','public','bi-knights-of-albion','OC','Oceania','AU','Australia','albionknightscombat@gmail.com','https://www.facebook.com/albionknightscombat','https://static.wixstatic.com/media/b77dae_d103f918898e444d92cffc84bd63ad1d~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knights-of-albion','https://www.buhurtinternational.com/team/knights-of-albion','Knights of Albion','Wollongong','albionknightscombat@gmail.com','https://www.facebook.com/albionknightscombat',20,'{"biCollectionId":"d3af6d2a-6a53-43c8-bcf7-11723280e9ab","teamName":"Knights of Albion","club":null,"gender":"Male","captain":"Timothy O’Shea","conference":"APAC","country":"Australia","city":"Wollongong","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/albionknightscombat","teamEmail":"albionknightscombat@gmail.com","teamLogo":"wix:image://v1/b77dae_d103f918898e444d92cffc84bd63ad1d~mv2.jpg/KOA_2024_Social%20No%20Background.JPG#originWidth=6124&originHeight=6124","logoUrl":"https://static.wixstatic.com/media/b77dae_d103f918898e444d92cffc84bd63ad1d~mv2.jpg","rank5v5":9,"averagePoints5v5":1.33,"points5v5":4,"rank12v12":null,"points12v12":3,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":10},{"_id":"2","points":3,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"12vs12","place":3},{"_id":"3","points":2,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":6},{"_id":"4","points":1,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":10}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Winterfest 2024","date":"2024-07-06","category":"5vs5","place":6},{"_id":"2","points":0,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":10}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":9},{"_id":"2","points":3,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"12vs12","place":3},{"_id":"3","points":1,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":8},{"_id":"4","points":4.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":7}],"points12v12":3,"averagePoints5v5":2.5,"rank5v5":5,"remainingTokens":8,"points5v5":7.5}},"members":["Timothy O’Shea","Scott James","Andrew William Irwin","Timothy James O’Shea","Hristian Spiroski","Brody Mitchell","Christopher Smith","Rixon Butfield","Jonathan Greaves","Jadein Gibson-Davis","Liam French","James Letham","Dylan Parker","Lukas Hoyt-Bull","Tyga Bar"],"sourceCreatedAt":"2024-06-21T13:26:47.893Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knights of Albion',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wollongong',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'albionknightscombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/albionknightscombat'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b77dae_d103f918898e444d92cffc84bd63ad1d~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy O’Shea','captain','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott James','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew William Irwin','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy James O’Shea','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hristian Spiroski','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brody Mitchell','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rixon Butfield','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Greaves','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jadein Gibson-Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam French','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Letham','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Parker','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lukas Hoyt-Bull','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyga Bar','fighter','bi_teams','https://www.buhurtinternational.com/team/knights-of-albion','knights-of-albion',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knyaz-fire' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knyaz-fire' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knyaz Fire',NULL,true,'active','public','bi-knyaz-fire','NA','North America','US','United States','scott@dataguardstorage.com',NULL,'https://static.wixstatic.com/media/b39fac_ecfb5d045d3d4bc3957562ce24107f7e~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knyaz-fire','https://www.buhurtinternational.com/team/knyaz-fire','Knyaz Fire',NULL,'scott@dataguardstorage.com',NULL,20,'{"biCollectionId":"8ccb3746-b6a9-4b57-854f-969674b3ef51","teamName":"Knyaz Fire","club":null,"gender":"Male","captain":"Paul Weeks Jr","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"scott@dataguardstorage.com","teamLogo":"wix:image://v1/b39fac_ecfb5d045d3d4bc3957562ce24107f7e~mv2.jpg/Knyaz.jpg#originWidth=517&originHeight=800","logoUrl":"https://static.wixstatic.com/media/b39fac_ecfb5d045d3d4bc3957562ce24107f7e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":11.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":3},{"_id":"2","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":8}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":21,"remainingTokens":0,"tournaments":[{"_id":"1","points":18,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":3},{"_id":"2","points":3,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":6}]}},"members":["Paul Weeks Jr","Hayden Boggs","Bradley Richard Eefsting","Dakota Miller","Daniel hammond","Travis Wilding","Jacob Robinson","John MacIntyre","Andrew Fera","Daniel Hedger"],"sourceCreatedAt":"2024-07-18T00:39:44.003Z","sourceUpdatedAt":"2026-09-25T12:18:02.493Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knyaz Fire',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'scott@dataguardstorage.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b39fac_ecfb5d045d3d4bc3957562ce24107f7e~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Weeks Jr','captain','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hayden Boggs','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bradley Richard Eefsting','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dakota Miller','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel hammond','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Travis Wilding','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Robinson','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John MacIntyre','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Fera','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Hedger','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-fire','knyaz-fire',now());
end $$;
commit;
