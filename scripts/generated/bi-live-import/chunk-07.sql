begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='order-of-the-pegasus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-order-of-the-pegasus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Chaos Cryptids','Detroit',true,'active','public','bi-order-of-the-pegasus','NA','North America','US','United States','orderofthepegasusbuhurt@gmail.com',NULL,'https://static.wixstatic.com/media/bf5822_acb33c7c963a44338073229ea81f6bce~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','order-of-the-pegasus','https://www.buhurtinternational.com/team/order-of-the-pegasus','Chaos Cryptids','Detroit','orderofthepegasusbuhurt@gmail.com',NULL,20,'{"biCollectionId":"4d2d7aca-c577-484b-8be0-30df3d404414","teamName":"Chaos Cryptids","club":"Detroit Fight Club","gender":"Female","captain":"Lisa Hoy","conference":"North America","country":"United States","city":"Detroit","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"orderofthepegasusbuhurt@gmail.com","teamLogo":"wix:image://v1/bf5822_acb33c7c963a44338073229ea81f6bce~mv2.jpeg/05AF0587-A131-462F-85D7-C658EF16E46C.jpeg#originWidth=268&originHeight=268","logoUrl":"https://static.wixstatic.com/media/bf5822_acb33c7c963a44338073229ea81f6bce~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":18,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":2},{"_id":"2","points":4.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":3},{"_id":"3","points":5,"Tournament":"Dragon''s Cup 2024","date":"2024-08-31","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":9},{"_id":"2","points":1.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":4},{"_id":"3","points":5,"Tournament":"War in the North 2025","date":"2025-10-18","category":"5vs5","place":2},{"_id":"4","points":9,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":5.17,"rank5v5":4,"remainingTokens":10,"points5v5":15.5}},"members":["Cassie Johnson","Lisa Hoy"],"sourceCreatedAt":"2023-07-22T02:56:16.484Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Chaos Cryptids',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Detroit',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'orderofthepegasusbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bf5822_acb33c7c963a44338073229ea81f6bce~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cassie Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-pegasus','order-of-the-pegasus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lisa Hoy','captain','bi_teams','https://www.buhurtinternational.com/team/order-of-the-pegasus','order-of-the-pegasus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='order-of-the-silver-rose' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-order-of-the-silver-rose' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Order of the Silver Rose','Salt Lake City',true,'active','public','bi-order-of-the-silver-rose','NA','North America','US','United States','trevorhutton90@gmail.com','https://www.facebook.com/trevor.hutton.52','https://static.wixstatic.com/media/78a157_e01e6e3b91fc4757bff6bdad8ffbe278~mv2.jpg','Salt Lake City, UT based club focused on traveling to competitive events')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','order-of-the-silver-rose','https://www.buhurtinternational.com/team/order-of-the-silver-rose','Order of the Silver Rose','Salt Lake City','trevorhutton90@gmail.com','https://www.facebook.com/trevor.hutton.52',20,'{"biCollectionId":"7fb3cd83-1ae2-463a-b6cc-2d111afbf12a","teamName":"Order of the Silver Rose","club":null,"gender":"Male","captain":"Trevor Hutton","conference":"North America","country":"United States","city":"Salt Lake City","teamInfo":"Salt Lake City, UT based club focused on traveling to competitive events","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"UT","name":"Utah","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Utah County","name":"Utah County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Springville","name":"Springville","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Springville","location":{"latitude":40.1652335,"longitude":-111.6107526},"streetAddress":{"apt":"","formattedAddressLine":"Springville","name":"","number":""},"formatted":"Springville, UT, USA","country":"US","subdivision":"UT"},"websiteFacebookUrl":"https://www.facebook.com/trevor.hutton.52","teamEmail":"trevorhutton90@gmail.com","teamLogo":"wix:image://v1/78a157_e01e6e3b91fc4757bff6bdad8ffbe278~mv2.jpg/Silver%20rose.jpg#originWidth=2048&originHeight=1430","logoUrl":"https://static.wixstatic.com/media/78a157_e01e6e3b91fc4757bff6bdad8ffbe278~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"Idaho Armored Combat Invitational 2024","date":"2024-04-20","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":6,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":7},{"_id":"2","points":3,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":4},{"_id":"3","points":1,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":5},{"_id":"4","points":1,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":5}],"points12v12":0,"averagePoints5v5":3.33,"rank5v5":14,"remainingTokens":10,"points5v5":11}},"members":["Trevor Hutton","Randy Davis","Marc Wells","Torin Holt","Jack Pfeiffer","William Anderson","Joon Yeo","Brandon Nakae","Jonathan Gaffney","Timothy Peck","Joshua Devine-king","Brendan Fisher","T Sterling Shawn Hamner Jr","Robert Safsten","Eli Chacon","Andrew Daniel Young"],"sourceCreatedAt":"2023-09-08T16:15:21.605Z","sourceUpdatedAt":"2026-09-29T01:00:39.456Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Order of the Silver Rose',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Salt Lake City',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'trevorhutton90@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/trevor.hutton.52'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/78a157_e01e6e3b91fc4757bff6bdad8ffbe278~mv2.jpg'),
 public_description=coalesce(t.public_description,'Salt Lake City, UT based club focused on traveling to competitive events'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Trevor Hutton','captain','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Randy Davis','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marc Wells','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Torin Holt','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Pfeiffer','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Anderson','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joon Yeo','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Nakae','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Gaffney','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy Peck','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Devine-king','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brendan Fisher','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'T Sterling Shawn Hamner Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Safsten','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eli Chacon','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Daniel Young','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-rose','order-of-the-silver-rose',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='order-of-the-silver-thorn' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-order-of-the-silver-thorn' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Order of the Silver Thorn','Utah',true,'active','public','bi-order-of-the-silver-thorn','NA','North America','US','United States','theorderofthesilverthorn@gmail.com','https://www.facebook.com/share/175rLdfR4A/','https://static.wixstatic.com/media/5b2430_620d3f35eb4046429403de56b4fc752a~mv2.jpg','We are a women&#x27;s team out for Utah looking to grow the community and help competitive women get where they want to be in the sport.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','order-of-the-silver-thorn','https://www.buhurtinternational.com/team/order-of-the-silver-thorn','Order of the Silver Thorn','Utah','theorderofthesilverthorn@gmail.com','https://www.facebook.com/share/175rLdfR4A/',20,'{"biCollectionId":"8f511cc2-070c-49e0-bc7c-65f800b761f0","teamName":"Order of the Silver Thorn","club":null,"gender":"Female","captain":"Jenni Young","conference":"North America","country":"United States","city":"Utah","teamInfo":"We are a women&#x27;s team out for Utah looking to grow the community and help competitive women get where they want to be in the sport.","trainingInfo":"We would love to have new faces! Bring hydration, athletic clothing, and a teachable mindset.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/175rLdfR4A/","teamEmail":"theorderofthesilverthorn@gmail.com","teamLogo":"wix:image://v1/5b2430_620d3f35eb4046429403de56b4fc752a~mv2.jpg/Screenshot_20260222_171027_Chrome.jpg#originWidth=1003&originHeight=807","logoUrl":"https://static.wixstatic.com/media/5b2430_620d3f35eb4046429403de56b4fc752a~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Jenni Young","Victoria G Monagas"],"sourceCreatedAt":"2026-02-23T00:17:47.328Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Order of the Silver Thorn',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Utah',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'theorderofthesilverthorn@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/175rLdfR4A/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5b2430_620d3f35eb4046429403de56b4fc752a~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a women&#x27;s team out for Utah looking to grow the community and help competitive women get where they want to be in the sport.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jenni Young','captain','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-thorn','order-of-the-silver-thorn',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Victoria G Monagas','fighter','bi_teams','https://www.buhurtinternational.com/team/order-of-the-silver-thorn','order-of-the-silver-thorn',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ordo-draconis' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ordo-draconis' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ordo Draconis','San Diego',true,'active','public','bi-ordo-draconis','NA','North America','US','United States','tmakotomason@gmail.com','https://www.facebook.com/ordodraconisfightclub','https://static.wixstatic.com/media/fbc94d_0d31d76a57c642369cf62a4da860e37d~mv2.jpg','Founded in 2016, one of the oldest North American teams that is still active as well as competitive.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ordo-draconis','https://www.buhurtinternational.com/team/ordo-draconis','Ordo Draconis','San Diego','tmakotomason@gmail.com','https://www.facebook.com/ordodraconisfightclub',20,'{"biCollectionId":"15a053dc-394e-4ecd-893f-4a3b9ff24599","teamName":"Ordo Draconis","club":null,"gender":"Male","captain":"Alexander Casillas","conference":"North America","country":"United States","city":"San Diego","teamInfo":"Founded in 2016, one of the oldest North American teams that is still active as well as competitive.","trainingInfo":"","trainingLocation":{"formatted":"Sundays at the The Dragon''s Lair"},"websiteFacebookUrl":"https://www.facebook.com/ordodraconisfightclub","teamEmail":"tmakotomason@gmail.com","teamLogo":"wix:image://v1/fbc94d_0d31d76a57c642369cf62a4da860e37d~mv2.jpg/40027877_2306900702914391_2816191394354298880_n.jpg#originWidth=874&originHeight=875","logoUrl":"https://static.wixstatic.com/media/fbc94d_0d31d76a57c642369cf62a4da860e37d~mv2.jpg","rank5v5":6,"averagePoints5v5":9.33,"points5v5":33.75,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":12,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":2},{"_id":"2","points":11,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":1},{"_id":"3","points":3.75,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":4},{"_id":"4","points":5,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":3},{"_id":"5","points":2,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":8,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":5},{"_id":"2","points":11,"Tournament":"Ventura Melee Megabowl 2024","date":"14-04-2024","category":"5vs5","place":1},{"_id":"3","points":3,"Tournament":"Rise of an Empire 2024","date":"2024-08-30","category":"5vs5","place":3},{"_id":"4","points":12,"Tournament":"California Classic 2024","date":"2024-09-21","category":"5vs5","place":1}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":6},{"_id":"2","points":3,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":4},{"_id":"3","points":6,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":3},{"_id":"4","points":9,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":6,"rank5v5":11,"remainingTokens":10,"points5v5":20}},"members":["Alexander Casillas","Landon Morris","Alexander Caillas","Logan Lutovsky","Matthew Flexen","Nick Shank","Cole Thomas","Lance Michael Garrison","Ricardo Schobert","Makoto Mason","Zachary Fletcher","Justin Ghazal","JOEL CASILLAS","Calvyn Cyril Bosch","Timothy Gaensler-Debs","Karl kalthoff","Dom Bell"],"sourceCreatedAt":"2023-08-31T03:48:26.833Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ordo Draconis',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('San Diego',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'tmakotomason@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ordodraconisfightclub'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/fbc94d_0d31d76a57c642369cf62a4da860e37d~mv2.jpg'),
 public_description=coalesce(t.public_description,'Founded in 2016, one of the oldest North American teams that is still active as well as competitive.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Casillas','captain','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Landon Morris','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Caillas','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Lutovsky','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Flexen','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nick Shank','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cole Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lance Michael Garrison','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ricardo Schobert','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Makoto Mason','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Fletcher','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Justin Ghazal','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JOEL CASILLAS','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Calvyn Cyril Bosch','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy Gaensler-Debs','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karl kalthoff','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dom Bell','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-draconis','ordo-draconis',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ordo-obelio' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ordo-obelio' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ordo obelio','East coast USA ',true,'active','public','bi-ordo-obelio','NA','North America','US','United States','madison.hartkeweber@gmail.com','https://www.facebook.com/OrdoObelios?mibextid=LQQJ4d','https://static.wixstatic.com/media/4b38fa_bb51a9c823cb4a478120cfeab2ae4d96~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ordo-obelio','https://www.buhurtinternational.com/team/ordo-obelio','Ordo obelio','East coast USA ','madison.hartkeweber@gmail.com','https://www.facebook.com/OrdoObelios?mibextid=LQQJ4d',20,'{"biCollectionId":"c06b8ec8-745d-48c0-a06c-2b4235bda707","teamName":"Ordo obelio","club":null,"gender":"Female","captain":"Madison Hartke","conference":"North America","country":"United States","city":"East coast USA ","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/OrdoObelios?mibextid=LQQJ4d","teamEmail":"madison.hartkeweber@gmail.com","teamLogo":"wix:image://v1/4b38fa_bb51a9c823cb4a478120cfeab2ae4d96~mv2.jpeg/IMG_5332.jpeg#originWidth=946&originHeight=960","logoUrl":"https://static.wixstatic.com/media/4b38fa_bb51a9c823cb4a478120cfeab2ae4d96~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":2},{"_id":"2","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":4},{"_id":"3","points":8,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":1}]},"2025":{"tournaments":[{"_id":"1","points":16,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":2},{"_id":"2","points":0,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":5},{"_id":"3","points":0,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":5.33,"rank5v5":3,"remainingTokens":10,"points5v5":16}},"members":["Madison Hartke","Natalya Dwyer","Freyja Seymore","Evelle Xastur","Tegan Gahan","Caitlyn Nichols"],"sourceCreatedAt":"2024-06-28T23:52:05.052Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ordo obelio',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('East coast USA ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'madison.hartkeweber@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/OrdoObelios?mibextid=LQQJ4d'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4b38fa_bb51a9c823cb4a478120cfeab2ae4d96~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Madison Hartke','captain','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Natalya Dwyer','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Freyja Seymore','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evelle Xastur','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tegan Gahan','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caitlyn Nichols','fighter','bi_teams','https://www.buhurtinternational.com/team/ordo-obelio','ordo-obelio',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ostlander' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ostlander' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ostlander','Strasbourg',true,'active','public','bi-ostlander','EU','Europe','FR','France','alsacecombatmed@gmail.com','https://alsacecombatmed.fr/','https://static.wixstatic.com/media/cbbaf7_f3fdb5d7498e48ca8238ecae837db3c0~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ostlander','https://www.buhurtinternational.com/team/ostlander','Ostlander','Strasbourg','alsacecombatmed@gmail.com','https://alsacecombatmed.fr/',20,'{"biCollectionId":"1a3f3bb4-7bda-4b25-913a-2cd29ccc605d","teamName":"Ostlander","club":null,"gender":"Male","captain":"Xavier Depeyre","conference":"Europe","country":"France","city":"Strasbourg","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://alsacecombatmed.fr/","teamEmail":"alsacecombatmed@gmail.com","teamLogo":"wix:image://v1/cbbaf7_f3fdb5d7498e48ca8238ecae837db3c0~mv2.jpg/156568249_4316630221699152_7524608156338148581_n.jpg#originWidth=1080&originHeight=706","logoUrl":"https://static.wixstatic.com/media/cbbaf7_f3fdb5d7498e48ca8238ecae837db3c0~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":6}]},"2025":{"remainingTokens":10}},"members":["Xavier Depeyre","Martin Zerbes","Vincent SITTLER","Schieber pierre","Amiot Luc","Vincent Hamm"],"sourceCreatedAt":"2023-07-31T20:36:02.221Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ostlander',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Strasbourg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'alsacecombatmed@gmail.com'),
 website_url=coalesce(t.website_url,'https://alsacecombatmed.fr/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cbbaf7_f3fdb5d7498e48ca8238ecae837db3c0~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Xavier Depeyre','captain','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Zerbes','fighter','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent SITTLER','fighter','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Schieber pierre','fighter','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amiot Luc','fighter','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Hamm','fighter','bi_teams','https://www.buhurtinternational.com/team/ostlander','ostlander',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='outcasts' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-outcasts' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Outcasts','Philadelphia',true,'active','public','bi-outcasts','NA','North America','US','United States','exilesarmoredcombatclub@gmail.com',NULL,'https://static.wixstatic.com/media/e4dfa1_835544d36d604deaa4fe560a2df9ef2e~mv2.jpg','The Outcasts are a secondary team for the Exiles. The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','outcasts','https://www.buhurtinternational.com/team/outcasts','Outcasts','Philadelphia','exilesarmoredcombatclub@gmail.com',NULL,20,'{"biCollectionId":"5d7eddf5-ff31-41c6-bc60-ab1667efb811","teamName":"Outcasts","club":null,"gender":"Male","captain":"Chester Dietrich","conference":"North America","country":"United States","city":"Philadelphia","teamInfo":"The Outcasts are a secondary team for the Exiles. The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition.","trainingInfo":"Interested in joining The Exiles? We’re looking for recruits who want more than a hobby—this is a competitive team built for people ready to train, improve, and fight. Whether you have armor or not, whether you’re experienced or just getting started, we’ll meet you where you are and push you to grow. Age and fitness level aren’t barriers—commitment is. We provide structured training, sparring, and full support to get you r","trainingLocation":{"subdivisions":[{"code":"MD","name":"Maryland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Cecil County","name":"Cecil County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Elkton","name":"Elkton","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Elkton","location":{"latitude":39.6060969,"longitude":-75.8325539},"streetAddress":{"apt":"","formattedAddressLine":"109 S Bridge St","name":"South Bridge Street","number":"109"},"formatted":"109 S Bridge St, Elkton, MD 21921, USA","country":"US","postalCode":"21921-5954","subdivision":"MD"},"websiteFacebookUrl":null,"teamEmail":"exilesarmoredcombatclub@gmail.com","teamLogo":"wix:image://v1/e4dfa1_835544d36d604deaa4fe560a2df9ef2e~mv2.jpg/Outcasts%20square.jpg#originWidth=1254&originHeight=1254","logoUrl":"https://static.wixstatic.com/media/e4dfa1_835544d36d604deaa4fe560a2df9ef2e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Chester Dietrich","Chester B Deitrich III","Karl Hoy Jr.","Paul Johnson Mehaffey","Albert W. Bennett III","Brandon Diaz"],"sourceCreatedAt":"2026-09-17T20:59:18.641Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Outcasts',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Philadelphia',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'exilesarmoredcombatclub@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e4dfa1_835544d36d604deaa4fe560a2df9ef2e~mv2.jpg'),
 public_description=coalesce(t.public_description,'The Outcasts are a secondary team for the Exiles. The Exiles are a competitive armored combat team based in the Philadelphia region, with members from Pennsylvania, New Jersey, and Maryland. Formed from the remnants of retired teams and battle-tested mercenaries, we’ve built something new—harder, leaner, and hungry for glory. Our home club is Armored Combat Elkton, where we train with purpose and build the foundation for success in national and international competition.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chester Dietrich','captain','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chester B Deitrich III','fighter','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karl Hoy Jr.','fighter','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Johnson Mehaffey','fighter','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Albert W. Bennett III','fighter','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Diaz','fighter','bi_teams','https://www.buhurtinternational.com/team/outcasts','outcasts',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pale-riders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pale-riders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pale Riders',NULL,true,'active','public','bi-pale-riders','NA','North America','US','United States','wmb.stone@gmail.com',NULL,'https://static.wixstatic.com/media/748f1d_55206254cf0145f78b0f222d1b7f72d4~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pale-riders','https://www.buhurtinternational.com/team/pale-riders','Pale Riders',NULL,'wmb.stone@gmail.com',NULL,20,'{"biCollectionId":"cab0e2ef-3caa-4218-acc3-5370584ee72b","teamName":"Pale Riders","club":null,"gender":"Male","captain":"William B Stone","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"wmb.stone@gmail.com","teamLogo":"wix:image://v1/748f1d_55206254cf0145f78b0f222d1b7f72d4~mv2.jpg/Riders.jpg#originWidth=1275&originHeight=1650","logoUrl":"https://static.wixstatic.com/media/748f1d_55206254cf0145f78b0f222d1b7f72d4~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":"10","tournaments":[{"_id":"1","points":2,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":8}]}},"members":["Lane Stone","William B Stone","Orion Goodman"],"sourceCreatedAt":"2025-09-24T01:59:03.032Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pale Riders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wmb.stone@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/748f1d_55206254cf0145f78b0f222d1b7f72d4~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lane Stone','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-riders','pale-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William B Stone','captain','bi_teams','https://www.buhurtinternational.com/team/pale-riders','pale-riders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orion Goodman','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-riders','pale-riders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pale-tempest' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pale-tempest' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pale Tempest',NULL,true,'active','public','bi-pale-tempest','NA','North America','US','United States','paletempestnw@gmail.com',NULL,'https://static.wixstatic.com/media/6e675c_45e65fa0f85d4db9afd8cbe7956e63fb~mv2.png','Montana (Sun Eaters) and Idaho (Rat Pack) competitive team.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pale-tempest','https://www.buhurtinternational.com/team/pale-tempest','Pale Tempest',NULL,'paletempestnw@gmail.com',NULL,20,'{"biCollectionId":"281eec68-aaef-43f4-a280-e7fd39e93f32","teamName":"Pale Tempest","club":null,"gender":"Male","captain":"Kyle James Olson","conference":"North America","country":"United States","city":null,"teamInfo":"Montana (Sun Eaters) and Idaho (Rat Pack) competitive team.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"paletempestnw@gmail.com","teamLogo":"wix:image://v1/6e675c_45e65fa0f85d4db9afd8cbe7956e63fb~mv2.png/mornt-2.png#originWidth=2000&originHeight=2000","logoUrl":"https://static.wixstatic.com/media/6e675c_45e65fa0f85d4db9afd8cbe7956e63fb~mv2.png","rank5v5":3,"averagePoints5v5":12,"points5v5":44,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":4},{"_id":"2","points":11,"Tournament":"Idaho Armored Combat Potato Mash 2026","date":"2026-06-20","category":"5vs5","place":1},{"_id":"3","points":16,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":1},{"_id":"4","points":8,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":2}],"eventsHistory":{},"members":["Kyle James Olson","Gunnar Averhart","Ethan Watt","Wyatt Bruin Herrick","Michael Clarke","Mercer Hiser","Clinton Gayman","Zachariah Pugmire","Jacob Wood","Nicholas Miller"],"sourceCreatedAt":"2025-12-23T15:53:20.556Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pale Tempest',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'paletempestnw@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6e675c_45e65fa0f85d4db9afd8cbe7956e63fb~mv2.png'),
 public_description=coalesce(t.public_description,'Montana (Sun Eaters) and Idaho (Rat Pack) competitive team.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle James Olson','captain','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gunnar Averhart','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Watt','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wyatt Bruin Herrick','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Clarke','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mercer Hiser','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Clinton Gayman','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachariah Pugmire','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Wood','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Miller','fighter','bi_teams','https://www.buhurtinternational.com/team/pale-tempest','pale-tempest',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='philadelphia-hellcats' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-philadelphia-hellcats' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Philadelphia Hellcats','Philadelphia ',true,'active','public','bi-philadelphia-hellcats','NA','North America','US','United States','hellcatsofphilly@gmail.com','https://www.facebook.com/share/1ExVZYc7hv/','https://static.wixstatic.com/media/5a9189_7df332c67bb44c558a19a49905ad8525~mv2.png','We are a buhurt team out of Philadelphia. We are welcoming to new and veteran fighters. We have a love of the sport and our city.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','philadelphia-hellcats','https://www.buhurtinternational.com/team/philadelphia-hellcats','Philadelphia Hellcats','Philadelphia ','hellcatsofphilly@gmail.com','https://www.facebook.com/share/1ExVZYc7hv/',20,'{"biCollectionId":"fb774c46-266b-4dbb-bd5a-445866271bf3","teamName":"Philadelphia Hellcats","club":null,"gender":"Male","captain":"Evan Meshanic","conference":"North America","country":"United States","city":"Philadelphia ","teamInfo":"We are a buhurt team out of Philadelphia. We are welcoming to new and veteran fighters. We have a love of the sport and our city.","trainingInfo":"Our team is open to anyone who wants to join, reach out on social media for more information.","trainingLocation":{"subdivisions":[{"code":"PA","name":"Pennsylvania","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Bucks County","name":"Bucks County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Bensalem","name":"Bensalem","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Bucks County","location":{"latitude":40.0780583,"longitude":-74.9182802},"streetAddress":{"apt":"","formattedAddressLine":"3401 State Rd.","name":"State Road","number":"3401"},"formatted":"3401 State Rd., Bensalem, PA 19020, USA","country":"US","postalCode":"19020-5915","subdivision":"PA"},"websiteFacebookUrl":"https://www.facebook.com/share/1ExVZYc7hv/","teamEmail":"hellcatsofphilly@gmail.com","teamLogo":"wix:image://v1/5a9189_7df332c67bb44c558a19a49905ad8525~mv2.png/Project%20202402211615.png#originWidth=1080&originHeight=1918","logoUrl":"https://static.wixstatic.com/media/5a9189_7df332c67bb44c558a19a49905ad8525~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Evan Meshanic"],"sourceCreatedAt":"2026-09-13T22:06:56.156Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Philadelphia Hellcats',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Philadelphia ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hellcatsofphilly@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1ExVZYc7hv/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5a9189_7df332c67bb44c558a19a49905ad8525~mv2.png'),
 public_description=coalesce(t.public_description,'We are a buhurt team out of Philadelphia. We are welcoming to new and veteran fighters. We have a love of the sport and our city.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan Meshanic','captain','bi_teams','https://www.buhurtinternational.com/team/philadelphia-hellcats','philadelphia-hellcats',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='phoenix-blood-eagles' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-phoenix-blood-eagles' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Phoenix Blood Eagles','Mesa',true,'active','public','bi-phoenix-blood-eagles','NA','North America','US','United States','info@armoredacademy.com','https://www.armoredacademy.com','https://static.wixstatic.com/media/df66e7_14f7135777f146ab910c60c4a0ca561e~mv2.png','The Blood Eagles are the men''s Buhurt team from the Buhurt training center Armored Academy of Arizona.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','phoenix-blood-eagles','https://www.buhurtinternational.com/team/phoenix-blood-eagles','Phoenix Blood Eagles','Mesa','info@armoredacademy.com','https://www.armoredacademy.com',20,'{"biCollectionId":"566fbb0e-0d87-4228-b0f7-fe0062e5733c","teamName":"Phoenix Blood Eagles","club":null,"gender":"Male","captain":"Rick Thom","conference":"North America","country":"United States","city":"Mesa","teamInfo":"The Blood Eagles are the men''s Buhurt team from the Buhurt training center Armored Academy of Arizona.","trainingInfo":"All someone needs to begin training are comfortable gym clothes, a water bottle and groin protection. We have loaner gear for people just starting out.","trainingLocation":{"city":"Mesa","location":{"latitude":33.3621856,"longitude":-111.8757226},"streetAddress":{"apt":"suite 1","formattedAddressLine":"2909 S Dobson Rd suite 1","name":"South Dobson Road","number":"2909"},"formatted":"2909 S Dobson Rd suite 1, Mesa, AZ 85202, USA","country":"US","postalCode":"85202-7900","subdivision":"AZ"},"websiteFacebookUrl":"https://www.armoredacademy.com","teamEmail":"info@armoredacademy.com","teamLogo":"wix:image://v1/df66e7_14f7135777f146ab910c60c4a0ca561e~mv2.png/SPLIT-FIN-A-Web.png#originWidth=870&originHeight=1000","logoUrl":"https://static.wixstatic.com/media/df66e7_14f7135777f146ab910c60c4a0ca561e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":8},{"_id":"2","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":5},{"_id":"3","points":4,"Tournament":"Ventura Melee Megabowl 2024","date":"14-04-2024","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":9},{"_id":"2","points":6,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":3},{"_id":"3","points":9,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":6.33,"rank5v5":10,"remainingTokens":9,"points5v5":19}},"members":["Rick Thom","Matthew Aaron","Les bolgren","Daniel Pike","Christopher Michael Simpson","Jeremy Tindell"],"sourceCreatedAt":"2023-09-24T01:27:00.213Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Phoenix Blood Eagles',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Mesa',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@armoredacademy.com'),
 website_url=coalesce(t.website_url,'https://www.armoredacademy.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/df66e7_14f7135777f146ab910c60c4a0ca561e~mv2.png'),
 public_description=coalesce(t.public_description,'The Blood Eagles are the men''s Buhurt team from the Buhurt training center Armored Academy of Arizona.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rick Thom','captain','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Aaron','fighter','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Les bolgren','fighter','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Pike','fighter','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Michael Simpson','fighter','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeremy Tindell','fighter','bi_teams','https://www.buhurtinternational.com/team/phoenix-blood-eagles','phoenix-blood-eagles',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pico-de-cuervo' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pico-de-cuervo' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pico de Cuervo','La Matanza / Villa Luzuriaga',true,'active','public','bi-pico-de-cuervo','SA','South America','AR','Argentina','marcelo_juarez_33@hotmail.com',NULL,'https://static.wixstatic.com/media/26af8a_89680099b1d04476a566dd491f95a31d~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pico-de-cuervo','https://www.buhurtinternational.com/team/pico-de-cuervo','Pico de Cuervo','La Matanza / Villa Luzuriaga','marcelo_juarez_33@hotmail.com',NULL,20,'{"biCollectionId":"9ab1d36b-e84c-47a1-8adc-a7081c8a6885","teamName":"Pico de Cuervo","club":null,"gender":"Male","captain":"Bruno Cerra","conference":"South America","country":"Argentina","city":"La Matanza / Villa Luzuriaga","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"marcelo_juarez_33@hotmail.com","teamLogo":"wix:image://v1/26af8a_89680099b1d04476a566dd491f95a31d~mv2.jpeg/Pico%20de%20cuervo.jpeg#originWidth=1440&originHeight=1440","logoUrl":"https://static.wixstatic.com/media/26af8a_89680099b1d04476a566dd491f95a31d~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Bruno Cerra"],"sourceCreatedAt":"2026-07-08T14:58:00.346Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pico de Cuervo',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('La Matanza / Villa Luzuriaga',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'marcelo_juarez_33@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/26af8a_89680099b1d04476a566dd491f95a31d~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bruno Cerra','captain','bi_teams','https://www.buhurtinternational.com/team/pico-de-cuervo','pico-de-cuervo',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pikarti' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pikarti' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pikarti','Prague',true,'active','public','bi-pikarti','EU','Europe','CZ','Czech Republic','wikkingdebarbaq@gmail.com','https://www.ceskakorouhev.com/pikarti','https://static.wixstatic.com/media/6a63f5_e03ef897aef245edb2142764755f2f2b~mv2.png','Pikarts are a sports team of medieval full-contact combat, operating under the auspices of the HMB club Česká korouhev . ​We derive our colors, symbols and name from a group of domestic sectarian religious fanatics of the middle and end of the 15th century, who interpreted the faith "in their own way" and committed various atrocities, when "...they murdered and they committed fornication during the day, they went to the border for fun...". There were many Picartic sects and sects, among the most famous were the Adamites. "They committed adultery, murdered and walked around naked" - the chronicles say. In 1421, Jan Žižka couldn&#x27;t put up with it any longer (even though he was already blind) and took the Pikarts from Tábor into battle and killed them mercilessly on the island near Nežárka. After suppressing the followers of the sect during 15th century the word "pikart" took on a derogatory meaning, essentially becoming a synonym for " heretics ". They were referred to as such not only utraquist (whether moderate or radical), but often even Catholics (by the Utraquists). You can learn more about Pikarts and their history on a special page dedicated to that, see. History of the Pikarts .')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pikarti','https://www.buhurtinternational.com/team/pikarti','Pikarti','Prague','wikkingdebarbaq@gmail.com','https://www.ceskakorouhev.com/pikarti',20,'{"biCollectionId":"90a96548-5882-4509-a1aa-2f6f58dfabbd","teamName":"Pikarti","club":"MFC Česká korouhev","gender":"Male","captain":"Martin Vašák","conference":"Europe","country":"Czech Republic","city":"Prague","teamInfo":"Pikarts are a sports team of medieval full-contact combat, operating under the auspices of the HMB club Česká korouhev . ​We derive our colors, symbols and name from a group of domestic sectarian religious fanatics of the middle and end of the 15th century, who interpreted the faith \"in their own way\" and committed various atrocities, when \"...they murdered and they committed fornication during the day, they went to the border for fun...\". There were many Picartic sects and sects, among the most famous were the Adamites. \"They committed adultery, murdered and walked around naked\" - the chronicles say. In 1421, Jan Žižka couldn&#x27;t put up with it any longer (even though he was already blind) and took the Pikarts from Tábor into battle and killed them mercilessly on the island near Nežárka. After suppressing the followers of the sect during 15th century the word \"pikart\" took on a derogatory meaning, essentially becoming a synonym for \" heretics \". They were referred to as such not only utraquist (whether moderate or radical), but often even Catholics (by the Utraquists). You can learn more about Pikarts and their history on a special page dedicated to that, see. History of the Pikarts .","trainingInfo":"Tuesdays : Power&Strength Time: 18:00/6pm Where: Fitness Maximus, Prague What: Weight lifting, Circle tr., Boxing Conditions: inside, gym Thursdays : Endurance&Techniqes Time: 18:00/6pm Where: Prague Central Camp What: Balding, Running, Stretching, Hiit, Fencing, Wrestling, Tires, Aerobics Conditions: outside, any weather Fridays : Wrestling&Mobility Time: 18:00/6pm Where: Brandýs nad Labem, Nursery What: Wrestling, Judo, Steps&Stances Conditions: inside, gym Saturdays : Full Contact Trainings Time: 11:00/11am Where: Libušín Fortress, What: Buhurt&Profight Conditions: outside, any weather (Only in case if there is no Tournament, PROMO, Gala Night Fights or Reenactment event)","trainingLocation":{"subdivisions":[{"code":"Hlavní město Praha","name":"Hlavní město Praha","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Hlavní město Praha","name":"Hlavní město Praha","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Žižkov","name":"Žižkov","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"CZ","name":"Czechia","type":"COUNTRY"}],"city":"Praha 3","location":{"latitude":50.09225840000001,"longitude":14.4732294},"streetAddress":{"apt":"","formattedAddressLine":"Prague Central Camp","name":"Nad Ohradou","number":"2667/17"},"formatted":"Nad Ohradou 2667/17, Žižkov, 130 00 Praha-Praha 3, Czechia","country":"CZ","postalCode":"130 00"},"websiteFacebookUrl":"https://www.ceskakorouhev.com/pikarti","teamEmail":"wikkingdebarbaq@gmail.com","teamLogo":"wix:image://v1/6a63f5_e03ef897aef245edb2142764755f2f2b~mv2.png/Pikarti_logo.png#originWidth=400&originHeight=400","logoUrl":"https://static.wixstatic.com/media/6a63f5_e03ef897aef245edb2142764755f2f2b~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":8},{"_id":"2","points":1,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":6}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"Valley of Warriors Buhurt Tournament 2024","date":"2024-06-15","category":"3vs3","place":3}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":8},{"_id":"2","points":2,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":5}]}},"members":["Dennis Rendl","Michal Šebela","Václav Polma","Pavel Kejla","Petr Mark Jr.","Jakub Kamas","Petr Mark","Martin Vašák","Zbyněk Hovorka","Jakub Pazdera","Zdeněk Martínek","Jan Kalaš","Ondřej Palouš","Petr Najman","Jan Švec","Dominik Šebela","Vilém Stříbrný"],"sourceCreatedAt":"2023-11-06T13:54:32.896Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pikarti',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Prague',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wikkingdebarbaq@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.ceskakorouhev.com/pikarti'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6a63f5_e03ef897aef245edb2142764755f2f2b~mv2.png'),
 public_description=coalesce(t.public_description,'Pikarts are a sports team of medieval full-contact combat, operating under the auspices of the HMB club Česká korouhev . ​We derive our colors, symbols and name from a group of domestic sectarian religious fanatics of the middle and end of the 15th century, who interpreted the faith "in their own way" and committed various atrocities, when "...they murdered and they committed fornication during the day, they went to the border for fun...". There were many Picartic sects and sects, among the most famous were the Adamites. "They committed adultery, murdered and walked around naked" - the chronicles say. In 1421, Jan Žižka couldn&#x27;t put up with it any longer (even though he was already blind) and took the Pikarts from Tábor into battle and killed them mercilessly on the island near Nežárka. After suppressing the followers of the sect during 15th century the word "pikart" took on a derogatory meaning, essentially becoming a synonym for " heretics ". They were referred to as such not only utraquist (whether moderate or radical), but often even Catholics (by the Utraquists). You can learn more about Pikarts and their history on a special page dedicated to that, see. History of the Pikarts .'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Rendl','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michal Šebela','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Václav Polma','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pavel Kejla','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petr Mark Jr.','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Kamas','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petr Mark','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Vašák','captain','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zbyněk Hovorka','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Pazdera','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zdeněk Martínek','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Kalaš','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ondřej Palouš','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petr Najman','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Švec','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Šebela','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vilém Stříbrný','fighter','bi_teams','https://www.buhurtinternational.com/team/pikarti','pikarti',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='portland-reavers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-portland-reavers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Portland Reavers','Portland',true,'active','public','bi-portland-reavers','NA','North America','US','United States','portlandreavers@gmail.com','https://www.facebook.com/profile.php?id=100057432401644','https://static.wixstatic.com/media/bbae3a_2d362f8985e94d8ab53ade4972d253e8~mv2.png','We are Maine&#x27;s Medieval Armored Combat team. Founded in 2019 by Kayla Scarponi and Chris Wilkins.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','portland-reavers','https://www.buhurtinternational.com/team/portland-reavers','Portland Reavers','Portland','portlandreavers@gmail.com','https://www.facebook.com/profile.php?id=100057432401644',20,'{"biCollectionId":"e3e82ace-971a-4201-afc9-05a81da86d82","teamName":"Portland Reavers","club":"Portland Reavers","gender":"Male","captain":"Christopher Wilkins","conference":"North America","country":"United States","city":"Portland","teamInfo":"We are Maine&#x27;s Medieval Armored Combat team. Founded in 2019 by Kayla Scarponi and Chris Wilkins.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100057432401644","teamEmail":"portlandreavers@gmail.com","teamLogo":"wix:image://v1/bbae3a_2d362f8985e94d8ab53ade4972d253e8~mv2.png/ACS%20LOGO-Grey%20BG.png#originWidth=950&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/bbae3a_2d362f8985e94d8ab53ade4972d253e8~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":7},{"_id":"2","points":0,"Tournament":"Blood & Steel 7 2024","date":"2024-10-19","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Christopher Wilkins","Christopher Lloyd Wilkins","Brock Everett Pollis","Thomas Philip Caswell","Paul T Wolfe","Ken Fox"],"sourceCreatedAt":"2024-01-27T11:19:07.159Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Portland Reavers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Portland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'portlandreavers@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100057432401644'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bbae3a_2d362f8985e94d8ab53ade4972d253e8~mv2.png'),
 public_description=coalesce(t.public_description,'We are Maine&#x27;s Medieval Armored Combat team. Founded in 2019 by Kayla Scarponi and Chris Wilkins.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Wilkins','captain','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Lloyd Wilkins','fighter','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brock Everett Pollis','fighter','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Philip Caswell','fighter','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul T Wolfe','fighter','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ken Fox','fighter','bi_teams','https://www.buhurtinternational.com/team/portland-reavers','portland-reavers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='portvcale-combate-medieval' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-portvcale-combate-medieval' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Portvcale Combate Medieval','Santa Maria da Feira',true,'active','public','bi-portvcale-combate-medieval','EU','Europe','PT','Portugal','portvcale.combate.medieval@gmail.com','https://www.facebook.com/PortvcaleCombateMedieval','https://static.wixstatic.com/media/6cb3cd_2e47ff810b79444aaee8a6e5a3d4374e~mv2.jpg','One of the first teams in Portugal Created after the 2013 Botn In aigues mortes')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','portvcale-combate-medieval','https://www.buhurtinternational.com/team/portvcale-combate-medieval','Portvcale Combate Medieval','Santa Maria da Feira','portvcale.combate.medieval@gmail.com','https://www.facebook.com/PortvcaleCombateMedieval',20,'{"biCollectionId":"2ef8ebb6-0b24-4c14-a08a-2dd626520370","teamName":"Portvcale Combate Medieval","club":null,"gender":"Male","captain":"Isidro Oliveira","conference":"Europe","country":"Portugal","city":"Santa Maria da Feira","teamInfo":"One of the first teams in Portugal Created after the 2013 Botn In aigues mortes","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/PortvcaleCombateMedieval","teamEmail":"portvcale.combate.medieval@gmail.com","teamLogo":"wix:image://v1/6cb3cd_2e47ff810b79444aaee8a6e5a3d4374e~mv2.jpg/277307166_495427572274426_4397903721050488511_n.jpg#originWidth=2008&originHeight=2011","logoUrl":"https://static.wixstatic.com/media/6cb3cd_2e47ff810b79444aaee8a6e5a3d4374e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Isidro Oliveira","Carlos Ferreira","Serhiy Boychenko","Nuno Rafael Borges Silva Jesus Lila","Kayo Pantoja"],"sourceCreatedAt":"2026-05-11T20:45:36.471Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Portvcale Combate Medieval',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Santa Maria da Feira',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Portugal',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'portvcale.combate.medieval@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/PortvcaleCombateMedieval'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6cb3cd_2e47ff810b79444aaee8a6e5a3d4374e~mv2.jpg'),
 public_description=coalesce(t.public_description,'One of the first teams in Portugal Created after the 2013 Botn In aigues mortes'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isidro Oliveira','captain','bi_teams','https://www.buhurtinternational.com/team/portvcale-combate-medieval','portvcale-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carlos Ferreira','fighter','bi_teams','https://www.buhurtinternational.com/team/portvcale-combate-medieval','portvcale-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Serhiy Boychenko','fighter','bi_teams','https://www.buhurtinternational.com/team/portvcale-combate-medieval','portvcale-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nuno Rafael Borges Silva Jesus Lila','fighter','bi_teams','https://www.buhurtinternational.com/team/portvcale-combate-medieval','portvcale-combate-medieval',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayo Pantoja','fighter','bi_teams','https://www.buhurtinternational.com/team/portvcale-combate-medieval','portvcale-combate-medieval',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='prague-trolls' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-prague-trolls' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Prague Trolls','Praha',true,'active','public','bi-prague-trolls','EU','Europe','CZ','Czech Republic','stredovekyboj@gmail.com','https://www.stredovekyboj.cz','https://static.wixstatic.com/media/f266d7_556a841caf8a4b7293f576773c8ad08a~mv2.jpg','Elite men&#x27;s team from the club SKSKB PRAHA from the Czech Republic.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','prague-trolls','https://www.buhurtinternational.com/team/prague-trolls','Prague Trolls','Praha','stredovekyboj@gmail.com','https://www.stredovekyboj.cz',20,'{"biCollectionId":"7c615ea7-1553-4c28-bd69-98e9464de713","teamName":"Prague Trolls","club":null,"gender":"Male","captain":"Jan Burgerstein","conference":"Europe","country":"Czech Republic","city":"Praha","teamInfo":"Elite men&#x27;s team from the club SKSKB PRAHA from the Czech Republic.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.stredovekyboj.cz","teamEmail":"stredovekyboj@gmail.com","teamLogo":"wix:image://v1/f266d7_556a841caf8a4b7293f576773c8ad08a~mv2.jpg/Trolls.jpg#originWidth=693&originHeight=840","logoUrl":"https://static.wixstatic.com/media/f266d7_556a841caf8a4b7293f576773c8ad08a~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":9,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":2}],"eventsHistory":{},"members":["Jan Burgerstein","Jan Horacek","Jakub Kubzzila Draxler","Dominik Sladovník","Daniel Dufek","Jan Kutnar","Tomáš Paidar","Vojtech Dusek","Michael Menge"],"sourceCreatedAt":"2026-02-16T08:17:37.793Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Prague Trolls',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Praha',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'stredovekyboj@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.stredovekyboj.cz'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f266d7_556a841caf8a4b7293f576773c8ad08a~mv2.jpg'),
 public_description=coalesce(t.public_description,'Elite men&#x27;s team from the club SKSKB PRAHA from the Czech Republic.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Burgerstein','captain','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Horacek','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Kubzzila Draxler','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Sladovník','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Dufek','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Kutnar','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomáš Paidar','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vojtech Dusek','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Menge','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-trolls','prague-trolls',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='prague-vixens' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-prague-vixens' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Prague Vixens','Prague',true,'active','public','bi-prague-vixens','EU','Europe','CZ','Czech Republic','pamela.pekarcikova@seznam.cz','https://www.facebook.com/praguevixskskbp','https://static.wixstatic.com/media/1fa9fb_7e2746ca48394a3fb97cad1a5cd15972~mv2.png','We´re an ambiotious team of fearless Vixens doing what they love and what makes them feel alive !!!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','prague-vixens','https://www.buhurtinternational.com/team/prague-vixens','Prague Vixens','Prague','pamela.pekarcikova@seznam.cz','https://www.facebook.com/praguevixskskbp',20,'{"biCollectionId":"66b2d3a3-c570-49f7-a139-b9e4139bba94","teamName":"Prague Vixens","club":"SKSKBP","gender":"Female","captain":"Klára Vintnerová ","conference":"Europe","country":"Czech Republic","city":"Prague","teamInfo":"We´re an ambiotious team of fearless Vixens doing what they love and what makes them feel alive !!!","trainingInfo":"For your first traning with us you only need apropriate shoes for wrestling and a great attitude !!! :D It´s better if you have your own gear as well, but we got some at the base. :) Looking forward to seeing u all !!!","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/praguevixskskbp","teamEmail":"pamela.pekarcikova@seznam.cz","teamLogo":"wix:image://v1/1fa9fb_7e2746ca48394a3fb97cad1a5cd15972~mv2.png/302711995_935629290691479_2253808205809510102_n.png#originWidth=1879&originHeight=1879","logoUrl":"https://static.wixstatic.com/media/1fa9fb_7e2746ca48394a3fb97cad1a5cd15972~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"12vs12","place":4},{"_id":"2","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3}]},"2025":{"remainingTokens":9}},"members":["Klára Vintnerová","Eliška Kočárová","Petra Jurečková","Ginette Šianská","Šárka Reindlová","Pamela Pekarcikova","Kristina Beatrix Bílá","BARBORA MRÁZOVÁ","Natalie Emma Forejtova"],"sourceCreatedAt":"2024-03-19T19:51:38.497Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Prague Vixens',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Prague',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'pamela.pekarcikova@seznam.cz'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/praguevixskskbp'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/1fa9fb_7e2746ca48394a3fb97cad1a5cd15972~mv2.png'),
 public_description=coalesce(t.public_description,'We´re an ambiotious team of fearless Vixens doing what they love and what makes them feel alive !!!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Klára Vintnerová','captain','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eliška Kočárová','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Petra Jurečková','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ginette Šianská','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Šárka Reindlová','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pamela Pekarcikova','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kristina Beatrix Bílá','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BARBORA MRÁZOVÁ','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Natalie Emma Forejtova','fighter','bi_teams','https://www.buhurtinternational.com/team/prague-vixens','prague-vixens',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pressburg-iron-company' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pressburg-iron-company' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pressburg Iron Company','Bratislava',true,'active','public','bi-pressburg-iron-company','EU','Europe','SK','Slovakia','mravciar@gmail.com','https://www.facebook.com/BratislavskaZeleznaKompania','https://static.wixstatic.com/media/dcaafa_65be05a9d249451295b582bd5b6534ac~mv2.jpg','First Slovak team, based in Bratislava, we train buhurt and duels.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pressburg-iron-company','https://www.buhurtinternational.com/team/pressburg-iron-company','Pressburg Iron Company','Bratislava','mravciar@gmail.com','https://www.facebook.com/BratislavskaZeleznaKompania',20,'{"biCollectionId":"a252f793-0cf2-4306-b36c-958747ba8134","teamName":"Pressburg Iron Company","club":null,"gender":"Male","captain":null,"conference":"Europe","country":"Slovakia","city":"Bratislava","teamInfo":"First Slovak team, based in Bratislava, we train buhurt and duels.","trainingInfo":"We train twice per week, if you are iterested, write us message first please.","trainingLocation":{"subdivisions":[{"code":"Bratislavský kraj","name":"Bratislavský kraj","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Bratislava IV","name":"Bratislava IV","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Bratislava","name":"Bratislava","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"SK","name":"Slovakia","type":"COUNTRY"}],"city":"Bratislava","location":{"latitude":48.1500645,"longitude":17.0619714},"streetAddress":{"apt":"","formattedAddressLine":"Cultural center Karlova Ves","name":"Molecova","number":"2"},"formatted":"Molecova 2, 841 04 Bratislava-Karlova Ves, Slovakia","country":"SK","postalCode":"841 04","subdivision":"BL"},"websiteFacebookUrl":"https://www.facebook.com/BratislavskaZeleznaKompania","teamEmail":"mravciar@gmail.com","teamLogo":"wix:image://v1/dcaafa_65be05a9d249451295b582bd5b6534ac~mv2.jpg/ZK%20LOGO.jpg#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/dcaafa_65be05a9d249451295b582bd5b6534ac~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Marek von Dedinský","Erik Michalik","Ján Šalát","Sebastián Janikovič","Dominik Morgenstern","Adrián Szabó"],"sourceCreatedAt":"2026-01-26T10:21:21.968Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pressburg Iron Company',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Bratislava',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('SK',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Slovakia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mravciar@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/BratislavskaZeleznaKompania'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/dcaafa_65be05a9d249451295b582bd5b6534ac~mv2.jpg'),
 public_description=coalesce(t.public_description,'First Slovak team, based in Bratislava, we train buhurt and duels.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marek von Dedinský','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erik Michalik','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ján Šalát','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastián Janikovič','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominik Morgenstern','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrián Szabó','fighter','bi_teams','https://www.buhurtinternational.com/team/pressburg-iron-company','pressburg-iron-company',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='protospatharii' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-protospatharii' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Protospatharii','Athens',true,'active','public','bi-protospatharii','EU','Europe','GR','Greece','ioannisdan@googlemail.com','https://www.facebook.com/protospatharii/?locale=el_GR','https://static.wixstatic.com/media/383147_26c8962187174ae3b7cda314a1deb16e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','protospatharii','https://www.buhurtinternational.com/team/protospatharii','Protospatharii','Athens','ioannisdan@googlemail.com','https://www.facebook.com/protospatharii/?locale=el_GR',20,'{"biCollectionId":"731fb0d4-c5dc-4a00-bf85-9ebd7eaa06a5","teamName":"Protospatharii","club":null,"gender":"Male","captain":"Marinos Meimaris - Ioannis Dandoulakis","conference":"Europe","country":"Greece","city":"Athens","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Athens","name":"Athens","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"GR","name":"Greece","type":"COUNTRY"}],"city":"Athens","location":{"latitude":37.9838096,"longitude":23.7275388},"streetAddress":{"apt":"","formattedAddressLine":"Athens","name":"","number":""},"formatted":"Athens, Greece","country":"GR"},"websiteFacebookUrl":"https://www.facebook.com/protospatharii/?locale=el_GR","teamEmail":"ioannisdan@googlemail.com","teamLogo":"wix:image://v1/383147_26c8962187174ae3b7cda314a1deb16e~mv2.png/buhurt%20logo.png#originWidth=1058&originHeight=1487","logoUrl":"https://static.wixstatic.com/media/383147_26c8962187174ae3b7cda314a1deb16e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Marinos Meimaris - Ioannis Dandoulakis"],"sourceCreatedAt":"2026-06-22T08:54:01.855Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Protospatharii',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Athens',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Greece',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ioannisdan@googlemail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/protospatharii/?locale=el_GR'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/383147_26c8962187174ae3b7cda314a1deb16e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marinos Meimaris - Ioannis Dandoulakis','captain','bi_teams','https://www.buhurtinternational.com/team/protospatharii','protospatharii',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pukekohe-paladins' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pukekohe-paladins' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pukekohe Paladins','Auckland',true,'active','public','bi-pukekohe-paladins','OC','Oceania','NZ','New Zealand','pukekohepaladins@gmail.com',NULL,'https://static.wixstatic.com/media/b38cf1_380511d9a2e74d94b9bd45a9f50d46c5~mv2.jpg','Hello! We are a small buhurt team in New Zealand. Slowly growing members and sets of armour')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pukekohe-paladins','https://www.buhurtinternational.com/team/pukekohe-paladins','Pukekohe Paladins','Auckland','pukekohepaladins@gmail.com',NULL,20,'{"biCollectionId":"dd97324b-4eda-41bf-aaad-1f40c386a607","teamName":"Pukekohe Paladins","club":null,"gender":"Male","captain":"CIARAN TURNER","conference":"APAC","country":"New Zealand","city":"Auckland","teamInfo":"Hello! We are a small buhurt team in New Zealand. Slowly growing members and sets of armour","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Auckland","name":"Auckland","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Auckland","name":"Auckland","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"NZ","name":"New Zealand","type":"COUNTRY"}],"city":"Auckland","location":{"latitude":-36.85088270000001,"longitude":174.7644881},"streetAddress":{"apt":"","formattedAddressLine":"Auckland","name":"","number":""},"formatted":"Auckland, New Zealand","country":"NZ","subdivision":"AUK"},"websiteFacebookUrl":null,"teamEmail":"pukekohepaladins@gmail.com","teamLogo":"wix:image://v1/b38cf1_380511d9a2e74d94b9bd45a9f50d46c5~mv2.jpg/inbound309840234818739040.jpg#originWidth=1037&originHeight=1029","logoUrl":"https://static.wixstatic.com/media/b38cf1_380511d9a2e74d94b9bd45a9f50d46c5~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Ciaran Turner","Declan Turner","Craig Close","Wiremu Kaiwai"],"sourceCreatedAt":"2026-08-05T08:47:33.281Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pukekohe Paladins',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Auckland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'pukekohepaladins@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b38cf1_380511d9a2e74d94b9bd45a9f50d46c5~mv2.jpg'),
 public_description=coalesce(t.public_description,'Hello! We are a small buhurt team in New Zealand. Slowly growing members and sets of armour'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ciaran Turner','captain','bi_teams','https://www.buhurtinternational.com/team/pukekohe-paladins','pukekohe-paladins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Declan Turner','fighter','bi_teams','https://www.buhurtinternational.com/team/pukekohe-paladins','pukekohe-paladins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Craig Close','fighter','bi_teams','https://www.buhurtinternational.com/team/pukekohe-paladins','pukekohe-paladins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wiremu Kaiwai','fighter','bi_teams','https://www.buhurtinternational.com/team/pukekohe-paladins','pukekohe-paladins',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='pystymetsä' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-pystymetsä' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Pystymetsä','Tampere/Turku/Pori',true,'active','public','bi-pystymetsä','EU','Europe','FI','Finland','goretex_@hotmail.com',NULL,'https://static.wixstatic.com/media/cbd1ef_f1824b1cc96f4c2ab98355f40b40276f~mv2.jpg','Various fighters from the deep forests of Finland')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','pystymetsä','https://www.buhurtinternational.com/team/pystymets%C3%A4','Pystymetsä','Tampere/Turku/Pori','goretex_@hotmail.com',NULL,20,'{"biCollectionId":"286da8c1-3d04-4f74-b61e-1622f3522f83","teamName":"Pystymetsä","club":null,"gender":"Male","captain":"Jörn Irondick","conference":"Europe","country":"Finland","city":"Tampere/Turku/Pori","teamInfo":"Various fighters from the deep forests of Finland","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"goretex_@hotmail.com","teamLogo":"wix:image://v1/cbd1ef_f1824b1cc96f4c2ab98355f40b40276f~mv2.jpg/Pystymets%C3%A4_Logo(Square)Orange_Black_Blue.jpg#originWidth=2000&originHeight=2000","logoUrl":"https://static.wixstatic.com/media/cbd1ef_f1824b1cc96f4c2ab98355f40b40276f~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":5}]},"2025":{"remainingTokens":10}},"members":["Niko Taipale","Janne Aleksi Juhani Mylly","Jarkko Jääskeläinen","Sami Kolehmainen","Jörn Irondick","Enewald Lappetelainen"],"sourceCreatedAt":"2024-07-09T15:11:51.142Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Pystymetsä',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tampere/Turku/Pori',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'goretex_@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cbd1ef_f1824b1cc96f4c2ab98355f40b40276f~mv2.jpg'),
 public_description=coalesce(t.public_description,'Various fighters from the deep forests of Finland'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niko Taipale','fighter','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Janne Aleksi Juhani Mylly','fighter','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jarkko Jääskeläinen','fighter','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sami Kolehmainen','fighter','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jörn Irondick','captain','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Enewald Lappetelainen','fighter','bi_teams','https://www.buhurtinternational.com/team/pystymets%C3%A4','pystymetsä',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ramstäk-frisia' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ramstäk-frisia' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ramstäk Frisia','Oldenburg ',true,'active','public','bi-ramstäk-frisia','EU','Europe','DE','Germany','ramstaekfrisia@gmail.com',NULL,'https://static.wixstatic.com/media/c39678_a067122910a047cfa0c98ec71c77e997~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ramstäk-frisia','https://www.buhurtinternational.com/team/ramst%C3%A4k-frisia','Ramstäk Frisia','Oldenburg ','ramstaekfrisia@gmail.com',NULL,20,'{"biCollectionId":"c80a14d0-ec74-4c94-9c7b-ee08d111713b","teamName":"Ramstäk Frisia","club":null,"gender":"Male","captain":"Jan Marencke","conference":"Europe","country":"Germany","city":"Oldenburg ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"ramstaekfrisia@gmail.com","teamLogo":"wix:image://v1/c39678_a067122910a047cfa0c98ec71c77e997~mv2.png/Ramst%C3%A4k%20Logo.png#originWidth=3000&originHeight=3500","logoUrl":"https://static.wixstatic.com/media/c39678_a067122910a047cfa0c98ec71c77e997~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":9}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Jan Marencke","Hauke Johann Gras","Andreas Hinrichs","Tim de Vries"],"sourceCreatedAt":"2025-10-03T08:42:05.136Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ramstäk Frisia',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Oldenburg ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ramstaekfrisia@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c39678_a067122910a047cfa0c98ec71c77e997~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Marencke','captain','bi_teams','https://www.buhurtinternational.com/team/ramst%C3%A4k-frisia','ramstäk-frisia',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hauke Johann Gras','fighter','bi_teams','https://www.buhurtinternational.com/team/ramst%C3%A4k-frisia','ramstäk-frisia',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas Hinrichs','fighter','bi_teams','https://www.buhurtinternational.com/team/ramst%C3%A4k-frisia','ramstäk-frisia',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim de Vries','fighter','bi_teams','https://www.buhurtinternational.com/team/ramst%C3%A4k-frisia','ramstäk-frisia',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='rat-pack' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-rat-pack' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Rat Pack','Nampa',true,'active','public','bi-rat-pack','NA','North America','US','United States','idahoarmoredcombat@gmail.com','https://www.idahoarmoredcombat.com/','https://static.wixstatic.com/media/f11e05_0fbeb08068954a9c89b92d1400e1f1d2~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','rat-pack','https://www.buhurtinternational.com/team/rat-pack','Rat Pack','Nampa','idahoarmoredcombat@gmail.com','https://www.idahoarmoredcombat.com/',20,'{"biCollectionId":"71da89bc-9398-4f60-8cf0-6f69cf2dbcff","teamName":"Rat Pack","club":null,"gender":"Male","captain":"Ethan Watt","conference":"North America","country":"United States","city":"Nampa","teamInfo":"","trainingInfo":"Check out our website if you are interested in training with us! https://www.idahoarmoredcombat.com/","trainingLocation":{"formatted":"1612 East Sherman Avenue"},"websiteFacebookUrl":"https://www.idahoarmoredcombat.com/","teamEmail":"idahoarmoredcombat@gmail.com","teamLogo":"wix:image://v1/f11e05_0fbeb08068954a9c89b92d1400e1f1d2~mv2.png/IACLogo6Color_WhiteLetters.png#originWidth=4000&originHeight=4000","logoUrl":"https://static.wixstatic.com/media/f11e05_0fbeb08068954a9c89b92d1400e1f1d2~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Idaho Armored Combat Potato Mash 2026","date":"2026-06-20","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":10,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":5},{"_id":"2","points":9,"Tournament":"Idaho Armored Combat Invitational 2024","date":"2024-04-20","category":"5vs5","place":1},{"_id":"3","points":16.5,"Tournament":"Pacific Cup 2024","date":"2024-06-14","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":5},{"_id":"2","points":8,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":2},{"_id":"3","points":8,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":6.67,"rank5v5":9,"remainingTokens":9,"points5v5":20}},"members":["Ethan Watt","Caleb Wilson","Conrad Raymond Rhoades","Dennis Rowley","Gavin Alexander Tweedie","William O’Keeffe"],"sourceCreatedAt":"2023-09-07T17:15:02.647Z","sourceUpdatedAt":"2026-09-28T22:14:24.815Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Rat Pack',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nampa',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'idahoarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.idahoarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f11e05_0fbeb08068954a9c89b92d1400e1f1d2~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Watt','captain','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caleb Wilson','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Conrad Raymond Rhoades','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Rowley','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gavin Alexander Tweedie','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William O’Keeffe','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-pack','rat-pack',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='rat-queens' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-rat-queens' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Rat Queens','New York',true,'active','public','bi-rat-queens','NA','North America','US','United States','sophiarigg000@gmail.com','https://www.instagram.com/ratqueensnyc/','https://static.wixstatic.com/media/601207_f5d4560dc9904009b18733a560b72e6c~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','rat-queens','https://www.buhurtinternational.com/team/rat-queens','Rat Queens','New York','sophiarigg000@gmail.com','https://www.instagram.com/ratqueensnyc/',20,'{"biCollectionId":"9bdbd165-a3ea-44b6-b110-01113213ad8c","teamName":"Rat Queens","club":null,"gender":"Female","captain":"Sophia Rigg","conference":"North America","country":"United States","city":"New York","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/ratqueensnyc/","teamEmail":"sophiarigg000@gmail.com","teamLogo":"wix:image://v1/601207_f5d4560dc9904009b18733a560b72e6c~mv2.jpeg/64614b73a9926432b9bf47f996185ef0.JPEG#originWidth=699&originHeight=800","logoUrl":"https://static.wixstatic.com/media/601207_f5d4560dc9904009b18733a560b72e6c~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":4,"tournaments":[{"_id":"1","points":2,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":3}]}},"members":["Sophia Rigg","Lukianna Maeve Strohl","Chelsea Agnew","Alexandra Sloan","Myriam Elizabeth Shane","Alanna Olive-Smith","Kathleen Lim","Laura Willis","Tessa Deutscher","Alma Francois Pijuan","Carli Winquest","Danielle Sanders"],"sourceCreatedAt":"2025-09-09T16:09:50.529Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Rat Queens',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('New York',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'sophiarigg000@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/ratqueensnyc/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/601207_f5d4560dc9904009b18733a560b72e6c~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sophia Rigg','captain','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lukianna Maeve Strohl','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chelsea Agnew','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandra Sloan','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Myriam Elizabeth Shane','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alanna Olive-Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kathleen Lim','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laura Willis','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tessa Deutscher','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alma Francois Pijuan','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carli Winquest','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danielle Sanders','fighter','bi_teams','https://www.buhurtinternational.com/team/rat-queens','rat-queens',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='raubitters' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-raubitters' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Raubritters','Wrocław',true,'active','public','bi-raubitters','EU','Europe','PL','Poland','raubitters@gmail.com',NULL,'https://static.wixstatic.com/media/88edd2_3bf8161d88c544b8993b7994dbf4b426~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','raubitters','https://www.buhurtinternational.com/team/raubitters','Raubritters','Wrocław','raubitters@gmail.com',NULL,20,'{"biCollectionId":"a88dcd4b-2603-4d41-941b-ef5252268cec","teamName":"Raubritters","club":null,"gender":"Male","captain":"Maciej Zakrzeczkowski","conference":"Europe","country":"Poland","city":"Wrocław","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Województwo dolnośląskie","name":"Województwo dolnośląskie","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Powiat Wrocław","name":"Powiat Wrocław","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Wrocław","name":"Wrocław","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"PL","name":"Poland","type":"COUNTRY"}],"city":"Wrocław","location":{"latitude":51.15144189999999,"longitude":17.1167629},"streetAddress":{"apt":"","formattedAddressLine":"Zakrzowska 27","name":"Zakrzowska","number":"27"},"formatted":"Zakrzowska 27, 51-318 Wrocław, Poland","country":"PL","postalCode":"51-318","subdivision":"DS"},"websiteFacebookUrl":null,"teamEmail":"raubitters@gmail.com","teamLogo":"wix:image://v1/88edd2_3bf8161d88c544b8993b7994dbf4b426~mv2.png/received_1068148918573163.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/88edd2_3bf8161d88c544b8993b7994dbf4b426~mv2.png","rank5v5":9,"averagePoints5v5":2.33,"points5v5":7,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":8},{"_id":"2","points":2,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":6},{"_id":"3","points":3,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"King Kazimierz Cup 2025","date":"2025-08-16","category":"5vs5","place":5}]}},"members":["Maciej Zakrzeczkowski","Krzysiek Ligęza","Piotr Przybylski","Radosław Rowiński","Bartosz Kozioł","Przemysław Skopik","Bartłomiej Kotnisz","Piotr Kujawa","Piotr Olesinski","Mateusz Wojtacki","Kacper Nowiński","Mateusz Birski"],"sourceCreatedAt":"2025-06-12T21:56:15.647Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Raubritters',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wrocław',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'raubitters@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/88edd2_3bf8161d88c544b8993b7994dbf4b426~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maciej Zakrzeczkowski','captain','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Krzysiek Ligęza','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Piotr Przybylski','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Radosław Rowiński','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bartosz Kozioł','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Przemysław Skopik','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bartłomiej Kotnisz','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Piotr Kujawa','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Piotr Olesinski','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mateusz Wojtacki','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kacper Nowiński','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mateusz Birski','fighter','bi_teams','https://www.buhurtinternational.com/team/raubitters','raubitters',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='raven-guard' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-raven-guard' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Raven Guard','Newcastle / Central Coast, NSW',true,'active','public','bi-raven-guard','OC','Oceania','AU','Australia','teamravenguard@gmail.com','https://www.facebook.com/ravenguardhmb','https://static.wixstatic.com/media/84aea1_85e08150a0374433bc4355fafe3901a4~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','raven-guard','https://www.buhurtinternational.com/team/raven-guard','Raven Guard','Newcastle / Central Coast, NSW','teamravenguard@gmail.com','https://www.facebook.com/ravenguardhmb',20,'{"biCollectionId":"96e26464-9d74-41af-b823-c9c1cb778eab","teamName":"Raven Guard","club":"Raven Guard","gender":"Male","captain":"Mason Pritchard","conference":"APAC","country":"Australia","city":"Newcastle / Central Coast, NSW","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"NSW","name":"New South Wales","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Lake Macquarie City Council","name":"Lake Macquarie City Council","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Morisset","name":"Morisset","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Morisset","location":{"latitude":-33.1184783,"longitude":151.4738422},"streetAddress":{"apt":"","formattedAddressLine":"3 Accolade Ave","name":"Accolade Avenue","number":"3"},"formatted":"3 Accolade Ave, Morisset NSW 2264, Australia","country":"AU","postalCode":"2264","subdivision":"NSW"},"websiteFacebookUrl":"https://www.facebook.com/ravenguardhmb","teamEmail":"teamravenguard@gmail.com","teamLogo":"wix:image://v1/84aea1_85e08150a0374433bc4355fafe3901a4~mv2.png/Crest%20-%20Colour%20-%20Name%20v3%20-%20Transparent%20BG.png#originWidth=3440&originHeight=4007","logoUrl":"https://static.wixstatic.com/media/84aea1_85e08150a0374433bc4355fafe3901a4~mv2.png","rank5v5":7,"averagePoints5v5":2.17,"points5v5":7.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1.5,"Tournament":"SA Buhurt Cup (Adelaide Medieval Fair) 2026","date":"2026-04-04","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":9},{"_id":"3","points":1,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":9},{"_id":"4","points":3,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Winterfest 2024","date":"2024-07-06","category":"5vs5","place":7},{"_id":"2","points":3,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":9}]},"2025":{"tournaments":[{"_id":"1","points":0,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":11},{"_id":"2","points":1,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":7},{"_id":"3","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":12}],"points12v12":0,"averagePoints5v5":0.83,"rank5v5":6,"remainingTokens":8,"points5v5":2.5}},"members":["Jai Edwin Hunter Maher-Brooks","Mason Pritchard","Ryan Hungerford","Derek James Elston","Sam Woodger","Gavin McGann","Guy Vincent","Nathan Grennan","Michael Wills","Harry Wills","Tim Hackett","Manase Foai-Auimatagi","Damien Hopkinson"],"sourceCreatedAt":"2023-10-07T04:57:38.136Z","sourceUpdatedAt":"2026-09-26T11:26:24.662Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Raven Guard',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Newcastle / Central Coast, NSW',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'teamravenguard@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ravenguardhmb'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/84aea1_85e08150a0374433bc4355fafe3901a4~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jai Edwin Hunter Maher-Brooks','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mason Pritchard','captain','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Hungerford','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derek James Elston','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sam Woodger','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gavin McGann','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guy Vincent','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Grennan','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Wills','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Harry Wills','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim Hackett','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Manase Foai-Auimatagi','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damien Hopkinson','fighter','bi_teams','https://www.buhurtinternational.com/team/raven-guard','raven-guard',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='red-deer-reavers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-red-deer-reavers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Red Deer Reavers','Red Deer',true,'active','public','bi-red-deer-reavers','NA','North America','CA','Canada','reddeerreavers@gmail.com','https://www.facebook.com/profile.php?id=61566406838469','https://static.wixstatic.com/media/69f367_dce793c3c0624155b88289eeb2508bdf~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','red-deer-reavers','https://www.buhurtinternational.com/team/red-deer-reavers','Red Deer Reavers','Red Deer','reddeerreavers@gmail.com','https://www.facebook.com/profile.php?id=61566406838469',20,'{"biCollectionId":"eb3d9cc2-8779-4775-940d-852605d9bbcf","teamName":"Red Deer Reavers","club":null,"gender":"Male","captain":"Kedrixx","conference":"North America","country":"Canada","city":"Red Deer","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61566406838469","teamEmail":"reddeerreavers@gmail.com","teamLogo":"wix:image://v1/69f367_dce793c3c0624155b88289eeb2508bdf~mv2.jpg/461676162_122102808956546894_398832970758293661_n.jpg#originWidth=1252&originHeight=1251","logoUrl":"https://static.wixstatic.com/media/69f367_dce793c3c0624155b88289eeb2508bdf~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Kedrixx"],"sourceCreatedAt":"2026-09-26T04:26:58.698Z","sourceUpdatedAt":"2026-09-26T04:26:58.698Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Red Deer Reavers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Red Deer',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'reddeerreavers@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61566406838469'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/69f367_dce793c3c0624155b88289eeb2508bdf~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kedrixx','captain','bi_teams','https://www.buhurtinternational.com/team/red-deer-reavers','red-deer-reavers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='regius-cohortis' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-regius-cohortis' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Regius Cohortis','Bălţi',true,'active','public','bi-regius-cohortis','EU','Europe','MD','Moldova','vldungarn@gmail.com','https://www.facebook.com/ladomerviktor.ungurean/','https://static.wixstatic.com/media/92d4fc_757b921950584bf181c5d40183c78fb6~mv2.jpg','Pro Rege! Pro Septentrione!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','regius-cohortis','https://www.buhurtinternational.com/team/regius-cohortis','Regius Cohortis','Bălţi','vldungarn@gmail.com','https://www.facebook.com/ladomerviktor.ungurean/',20,'{"biCollectionId":"7ae61554-ab45-47b4-bf75-c0d75a6329cf","teamName":"Regius Cohortis","club":null,"gender":"Male","captain":"Kim Vladimir Ladomér Victor Ungurean","conference":"Europe","country":"Moldova","city":"Bălţi","teamInfo":"Pro Rege! Pro Septentrione!","trainingInfo":"Pro Rege! Pro Septentrione!","trainingLocation":{"formatted":"Strada Locomotivelor 3, Bălți, Moldova"},"websiteFacebookUrl":"https://www.facebook.com/ladomerviktor.ungurean/","teamEmail":"vldungarn@gmail.com","teamLogo":"wix:image://v1/92d4fc_757b921950584bf181c5d40183c78fb6~mv2.jpg/Regius%20Signum.jpg#originWidth=250&originHeight=250","logoUrl":"https://static.wixstatic.com/media/92d4fc_757b921950584bf181c5d40183c78fb6~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Tournament of Visegrád 2026","date":"2026-07-10","category":"5vs5","place":5}],"eventsHistory":{},"members":["Kim Vladimir Ladomér Victor Ungurean","Bulbuc Semion","Vlados Turcanu","Vsevolod Maxim","Alexandr Alvanica"],"sourceCreatedAt":"2026-02-18T17:23:33.290Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Regius Cohortis',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Bălţi',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('MD',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Moldova',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'vldungarn@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ladomerviktor.ungurean/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/92d4fc_757b921950584bf181c5d40183c78fb6~mv2.jpg'),
 public_description=coalesce(t.public_description,'Pro Rege! Pro Septentrione!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kim Vladimir Ladomér Victor Ungurean','captain','bi_teams','https://www.buhurtinternational.com/team/regius-cohortis','regius-cohortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bulbuc Semion','fighter','bi_teams','https://www.buhurtinternational.com/team/regius-cohortis','regius-cohortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vlados Turcanu','fighter','bi_teams','https://www.buhurtinternational.com/team/regius-cohortis','regius-cohortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vsevolod Maxim','fighter','bi_teams','https://www.buhurtinternational.com/team/regius-cohortis','regius-cohortis',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandr Alvanica','fighter','bi_teams','https://www.buhurtinternational.com/team/regius-cohortis','regius-cohortis',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='renacidos' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-renacidos' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'RENACIDOS','cuarte de huerva',true,'active','public','bi-renacidos','EU','Europe','ES','Spain','gzebas@gmail.com','https://www.facebook.com/profile.php?id=100078537445925&sk=directory_names','https://static.wixstatic.com/media/7b2a4f_b40f727787de40b3a00a894fe21bd13c~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','renacidos','https://www.buhurtinternational.com/team/renacidos','RENACIDOS','cuarte de huerva','gzebas@gmail.com','https://www.facebook.com/profile.php?id=100078537445925&sk=directory_names',20,'{"biCollectionId":"6c035263-d950-4a01-948a-578be1ac6f94","teamName":"RENACIDOS","club":null,"gender":"Male","captain":"GONZALO CEBALLOS","conference":"Europe","country":"Spain","city":"cuarte de huerva","teamInfo":"","trainingInfo":"LOCALIZADO EN ZARAGOZA EN BUSQUEDA DE NUEVOS TALENTOS PARA EQUIPO","trainingLocation":{"subdivisions":[{"code":"AR","name":"Aragon","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Z","name":"Zaragoza","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Cuarte de Huerva","name":"Cuarte de Huerva","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"ES","name":"Spain","type":"COUNTRY"}],"city":"Cuarte de Huerva","location":{"latitude":41.5933551,"longitude":-0.9357245000000001},"streetAddress":{"apt":"","formattedAddressLine":"Cuarte de Huerva","name":"","number":""},"formatted":"Cuarte de Huerva, Zaragoza, Spain","country":"ES","subdivision":"AR"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100078537445925&sk=directory_names","teamEmail":"gzebas@gmail.com","teamLogo":"wix:image://v1/7b2a4f_b40f727787de40b3a00a894fe21bd13c~mv2.jpg/661198427_932409359386970_7521504907317389762_n.jpg#originWidth=1147&originHeight=1147","logoUrl":"https://static.wixstatic.com/media/7b2a4f_b40f727787de40b3a00a894fe21bd13c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["GONZALO CEBALLOS"],"sourceCreatedAt":"2026-03-31T13:14:13.542Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('RENACIDOS',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('cuarte de huerva',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'gzebas@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100078537445925&sk=directory_names'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7b2a4f_b40f727787de40b3a00a894fe21bd13c~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GONZALO CEBALLOS','captain','bi_teams','https://www.buhurtinternational.com/team/renacidos','renacidos',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='river-sirens' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-river-sirens' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'River Sirens','Cincinnati',true,'active','public','bi-river-sirens','NA','North America','US','United States','riversirenscombat@gmail.com','https://www.facebook.com/profile.php?id=61561873869797&mibextid=ZbWKwL','https://static.wixstatic.com/media/42942a_5a18933790c040eaa34a404a5dfaa4c3~mv2.jpeg','Women&#x27;s armored combat team based out of Eastern Cincinnati!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','river-sirens','https://www.buhurtinternational.com/team/river-sirens','River Sirens','Cincinnati','riversirenscombat@gmail.com','https://www.facebook.com/profile.php?id=61561873869797&mibextid=ZbWKwL',20,'{"biCollectionId":"42e9a8f3-c4a0-4fea-9d95-56082a31346f","teamName":"River Sirens","club":null,"gender":"Female","captain":"Jordan Shelton","conference":"North America","country":"United States","city":"Cincinnati","teamInfo":"Women&#x27;s armored combat team based out of Eastern Cincinnati!","trainingInfo":"","trainingLocation":{"formatted":"Cincinnati, Oh 45244"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61561873869797&mibextid=ZbWKwL","teamEmail":"riversirenscombat@gmail.com","teamLogo":"wix:image://v1/42942a_5a18933790c040eaa34a404a5dfaa4c3~mv2.jpeg/Messenger_creation_78109868-76cc-4866-ba0b-e895e05cf257.jpeg#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/42942a_5a18933790c040eaa34a404a5dfaa4c3~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":9,"rank12v12":null,"points12v12":5,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":1},{"_id":"2","points":5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"12vs12","place":2},{"_id":"3","points":0,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":6},{"_id":"2","points":10.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":2},{"_id":"3","points":8,"Tournament":"War in the North 2025","date":"2025-10-18","category":"5vs5","place":1},{"_id":"4","points":0,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":6.83,"rank5v5":2,"remainingTokens":10,"points5v5":20.5}},"members":["Jordan Shelton","Chelsea O’Donnell","Nicole Goodin","Ashlynn Pfau","Alison Miller","Samantha marie winkelbach","Sandy Aufermann","Maggie Ryan"],"sourceCreatedAt":"2024-07-30T15:59:59.162Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('River Sirens',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cincinnati',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'riversirenscombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61561873869797&mibextid=ZbWKwL'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/42942a_5a18933790c040eaa34a404a5dfaa4c3~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Women&#x27;s armored combat team based out of Eastern Cincinnati!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Shelton','captain','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chelsea O’Donnell','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicole Goodin','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ashlynn Pfau','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alison Miller','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samantha marie winkelbach','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sandy Aufermann','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maggie Ryan','fighter','bi_teams','https://www.buhurtinternational.com/team/river-sirens','river-sirens',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='rks-sileisa' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-rks-sileisa' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'RKS Sileisa','Wrocław',true,'active','public','bi-rks-sileisa','EU','Europe','PL','Poland','ligeza.krzysiek@gmail.com','https://www.facebook.com/RKSSilesia','https://static.wixstatic.com/media/88edd2_836b825cb826409cb03e7b8b01c6607c~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','rks-sileisa','https://www.buhurtinternational.com/team/rks-sileisa','RKS Sileisa','Wrocław','ligeza.krzysiek@gmail.com','https://www.facebook.com/RKSSilesia',20,'{"biCollectionId":"178eac37-cc04-4abe-83c9-c20d4a1bc894","teamName":"RKS Sileisa","club":null,"gender":"Male","captain":"Vito Bergen ","conference":"Europe","country":"Poland","city":"Wrocław","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Województwo dolnośląskie","name":"Województwo dolnośląskie","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Powiat Wrocław","name":"Powiat Wrocław","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Wrocław","name":"Wrocław","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"PL","name":"Poland","type":"COUNTRY"}],"city":"Wrocław","location":{"latitude":51.15144189999999,"longitude":17.1167629},"streetAddress":{"apt":"","formattedAddressLine":"Zakrzowska 27","name":"Zakrzowska","number":"27"},"formatted":"Zakrzowska 27, 51-318 Wrocław, Poland","country":"PL","postalCode":"51-318","subdivision":"DS"},"websiteFacebookUrl":"https://www.facebook.com/RKSSilesia","teamEmail":"ligeza.krzysiek@gmail.com","teamLogo":"wix:image://v1/88edd2_836b825cb826409cb03e7b8b01c6607c~mv2.jpg/logo%20rks.jpg#originWidth=1152&originHeight=1152","logoUrl":"https://static.wixstatic.com/media/88edd2_836b825cb826409cb03e7b8b01c6607c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["Vito Bergen","Vitalii"],"sourceCreatedAt":"2025-05-04T14:08:54.038Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('RKS Sileisa',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wrocław',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ligeza.krzysiek@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/RKSSilesia'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/88edd2_836b825cb826409cb03e7b8b01c6607c~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vito Bergen','captain','bi_teams','https://www.buhurtinternational.com/team/rks-sileisa','rks-sileisa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vitalii','fighter','bi_teams','https://www.buhurtinternational.com/team/rks-sileisa','rks-sileisa',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='rogues' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-rogues' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Rogues','Orlando ',true,'active','public','bi-rogues','NA','North America','US','United States','RogueKnightsOrlando@gmail.com','https://www.facebook.com/share/g/15WbLHrjtP/','https://static.wixstatic.com/media/678b6d_bd01d3360042470e886bac4b53b759ac~mv2.png','The Orlando Rogue Knights are a new Buhurt team based in Florida. We are dedicated to building not just fighters, but a true brotherhood and family, where every member contributes to our growth and success. Our team works hard to foster a culture of support, discipline, and resilience both on and off the list. Though we are new, we are eager to test ourselves in battle , measure our progress against seasoned teams, and continue developing our strength, skill, and unity. The Orlando Rogue Knights fight with heart, grit, and the determination to grow into a family. Honor, courage and commitment.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','rogues','https://www.buhurtinternational.com/team/rogues','Rogues','Orlando ','RogueKnightsOrlando@gmail.com','https://www.facebook.com/share/g/15WbLHrjtP/',20,'{"biCollectionId":"6f650b27-3b4e-4b34-9026-8ae049ec82bc","teamName":"Rogues","club":null,"gender":"Male","captain":"David Albert","conference":"North America","country":"United States","city":"Orlando ","teamInfo":"The Orlando Rogue Knights are a new Buhurt team based in Florida. We are dedicated to building not just fighters, but a true brotherhood and family, where every member contributes to our growth and success. Our team works hard to foster a culture of support, discipline, and resilience both on and off the list. Though we are new, we are eager to test ourselves in battle , measure our progress against seasoned teams, and continue developing our strength, skill, and unity. The Orlando Rogue Knights fight with heart, grit, and the determination to grow into a family. Honor, courage and commitment.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"FL","name":"Florida","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Orange County","name":"Orange County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Christmas","name":"Christmas","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Christmas","location":{"latitude":28.5363893,"longitude":-81.01756089999999},"streetAddress":{"apt":"","formattedAddressLine":"Christmas","name":"","number":""},"formatted":"Christmas, FL 32709, USA","country":"US","postalCode":"32709","subdivision":"FL"},"websiteFacebookUrl":"https://www.facebook.com/share/g/15WbLHrjtP/","teamEmail":"RogueKnightsOrlando@gmail.com","teamLogo":"wix:image://v1/678b6d_bd01d3360042470e886bac4b53b759ac~mv2.png/IMG_20250918_151816.png#originWidth=1024&originHeight=1536","logoUrl":"https://static.wixstatic.com/media/678b6d_bd01d3360042470e886bac4b53b759ac~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":7}},"members":["David Albert","James Faleris","Daniel Muniz","Adam Richardson","Nicholas Bernier","Christopher Fuller","Thomas Lester","Branden Levoyer"],"sourceCreatedAt":"2025-08-28T11:25:43.204Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Rogues',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Orlando ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'RogueKnightsOrlando@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/g/15WbLHrjtP/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/678b6d_bd01d3360042470e886bac4b53b759ac~mv2.png'),
 public_description=coalesce(t.public_description,'The Orlando Rogue Knights are a new Buhurt team based in Florida. We are dedicated to building not just fighters, but a true brotherhood and family, where every member contributes to our growth and success. Our team works hard to foster a culture of support, discipline, and resilience both on and off the list. Though we are new, we are eager to test ourselves in battle , measure our progress against seasoned teams, and continue developing our strength, skill, and unity. The Orlando Rogue Knights fight with heart, grit, and the determination to grow into a family. Honor, courage and commitment.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Albert','captain','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Faleris','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Muniz','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Richardson','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Bernier','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Fuller','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Lester','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Branden Levoyer','fighter','bi_teams','https://www.buhurtinternational.com/team/rogues','rogues',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ruckus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ruckus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ruckus','Wellington',true,'active','public','bi-ruckus','OC','Oceania','NZ','New Zealand','Ruckusbuhurt@gmail.com','https://www.facebook.com/RuckusBuhurt','https://static.wixstatic.com/media/60b0eb_577e4e1312604923969264a74e2d26ff~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ruckus','https://www.buhurtinternational.com/team/ruckus','Ruckus','Wellington','Ruckusbuhurt@gmail.com','https://www.facebook.com/RuckusBuhurt',20,'{"biCollectionId":"12007397-fc6a-407a-94d5-f5118eff6bae","teamName":"Ruckus","club":null,"gender":"Male","captain":"Jesse Strawbridge","conference":"APAC","country":"New Zealand","city":"Wellington","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/RuckusBuhurt","teamEmail":"Ruckusbuhurt@gmail.com","teamLogo":"wix:image://v1/60b0eb_577e4e1312604923969264a74e2d26ff~mv2.png/Bear-Head-Transparent.png#originWidth=2000&originHeight=2000","logoUrl":"https://static.wixstatic.com/media/60b0eb_577e4e1312604923969264a74e2d26ff~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":7}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Wesley Hastings Cup 2025","date":"2025-02-14","category":"5vs5","place":3}]}},"members":["Jesse Strawbridge","Liam Edginton","Finbar Main","Gavin Burgess","Stefan Bensley","Christian bissell","Eduard Sadrutdinov","Cam Stevens","Keanu james walsh","Miles Mauafua"],"sourceCreatedAt":"2024-06-12T05:46:39.004Z","sourceUpdatedAt":"2026-09-28T03:03:44.734Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ruckus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wellington',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Ruckusbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/RuckusBuhurt'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/60b0eb_577e4e1312604923969264a74e2d26ff~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesse Strawbridge','captain','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam Edginton','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Finbar Main','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gavin Burgess','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stefan Bensley','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christian bissell','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eduard Sadrutdinov','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cam Stevens','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Keanu james walsh','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miles Mauafua','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus','ruckus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ruckus-revenants' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ruckus-revenants' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ruckus Revenants','Wellington',true,'active','public','bi-ruckus-revenants','OC','Oceania','NZ','New Zealand','squealiebean@gmail.com','https://www.facebook.com/share/1DqjpQDRM9/','https://static.wixstatic.com/media/e72630_52332e136a5147dcb0c2094aa903b87c~mv2.jpg','The first official Women&#x27;s Team for Ruckus!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ruckus-revenants','https://www.buhurtinternational.com/team/ruckus-revenants','Ruckus Revenants','Wellington','squealiebean@gmail.com','https://www.facebook.com/share/1DqjpQDRM9/',20,'{"biCollectionId":"932ceddb-d2bb-4361-a65b-d48a985683f8","teamName":"Ruckus Revenants","club":null,"gender":"Female","captain":"Sarah Russell","conference":"APAC","country":"New Zealand","city":"Wellington","teamInfo":"The first official Women&#x27;s Team for Ruckus!","trainingInfo":"We run intakes (advertised on the Facebook page) and train Mon & Fri 7-9pm. Armour training fortnightly on the weekend!","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/share/1DqjpQDRM9/","teamEmail":"squealiebean@gmail.com","teamLogo":"wix:image://v1/e72630_52332e136a5147dcb0c2094aa903b87c~mv2.jpg/Screenshot_20260908_080243_Drive.jpg#originWidth=1079&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/e72630_52332e136a5147dcb0c2094aa903b87c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Sarah Russell","Ikara Howard","Amber O''Sullivan","Ilse Swanepoel","Marisa Eastergaard"],"sourceCreatedAt":"2026-09-07T20:13:13.617Z","sourceUpdatedAt":"2026-09-28T00:00:39.914Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ruckus Revenants',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Wellington',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'squealiebean@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1DqjpQDRM9/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e72630_52332e136a5147dcb0c2094aa903b87c~mv2.jpg'),
 public_description=coalesce(t.public_description,'The first official Women&#x27;s Team for Ruckus!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarah Russell','captain','bi_teams','https://www.buhurtinternational.com/team/ruckus-revenants','ruckus-revenants',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ikara Howard','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus-revenants','ruckus-revenants',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amber O''Sullivan','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus-revenants','ruckus-revenants',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ilse Swanepoel','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus-revenants','ruckus-revenants',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marisa Eastergaard','fighter','bi_teams','https://www.buhurtinternational.com/team/ruckus-revenants','ruckus-revenants',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ruhrpott-knights' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ruhrpott-knights' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ruhrpott Knights','Duisburg',true,'active','public','bi-ruhrpott-knights','EU','Europe','DE','Germany','mfcduisburg@gmail.com','https://www.instagram.com/ruhrpott_knights/','https://static.wixstatic.com/media/11fef1_380639e0f9464490b5e80e84374e734e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ruhrpott-knights','https://www.buhurtinternational.com/team/ruhrpott-knights','Ruhrpott Knights','Duisburg','mfcduisburg@gmail.com','https://www.instagram.com/ruhrpott_knights/',20,'{"biCollectionId":"bba1c078-ff1c-4aec-af10-e5fab6d62d6c","teamName":"Ruhrpott Knights","club":null,"gender":"Male","captain":"Dennis Schürfeld","conference":"Europe","country":"Germany","city":"Duisburg","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/ruhrpott_knights/","teamEmail":"mfcduisburg@gmail.com","teamLogo":"wix:image://v1/11fef1_380639e0f9464490b5e80e84374e734e~mv2.png/LogoRuhrpottknights_6000png.PNG#originWidth=6000&originHeight=6000","logoUrl":"https://static.wixstatic.com/media/11fef1_380639e0f9464490b5e80e84374e734e~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":10},{"_id":"2","points":1,"Tournament":"Jan van Brabant 2026","date":"2026-05-16","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":7,"tournaments":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":11}]}},"members":["Dennis Schürfeld","Seweryn Modrzejewski","Andreas Reinartz","Jan Woeste","Lars Bode","Chris Elgsnat","Silas Panagiotaris","Christian Unger","Sascha Mlocek","Henning Hottong","Moritz Dierdorf"],"sourceCreatedAt":"2025-01-30T19:41:43.157Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ruhrpott Knights',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Duisburg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mfcduisburg@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/ruhrpott_knights/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/11fef1_380639e0f9464490b5e80e84374e734e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dennis Schürfeld','captain','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Seweryn Modrzejewski','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas Reinartz','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Woeste','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lars Bode','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris Elgsnat','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silas Panagiotaris','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christian Unger','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sascha Mlocek','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henning Hottong','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Moritz Dierdorf','fighter','bi_teams','https://www.buhurtinternational.com/team/ruhrpott-knights','ruhrpott-knights',now());
end $$;
commit;
