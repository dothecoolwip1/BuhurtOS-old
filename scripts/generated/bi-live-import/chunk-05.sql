begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knyaz-uk-(m)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knyaz-uk-(m)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knyaz UK (m)','London',true,'active','public','bi-knyaz-uk-(m)','EU','Europe','GB','United Kingdom','ukknyaz@gmail.com','https://www.facebook.com/Knyaz-UK-109055930462009/','https://static.wixstatic.com/media/c7dce6_b1f504461b7b435d9bc5f6c86dea4ac9~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knyaz-uk-(m)','https://www.buhurtinternational.com/team/knyaz-uk-(m)','Knyaz UK (m)','London','ukknyaz@gmail.com','https://www.facebook.com/Knyaz-UK-109055930462009/',20,'{"biCollectionId":"f187114a-53c3-476d-bc5f-f51eac2bfd4c","teamName":"Knyaz UK (m)","club":"Knyaz UK","gender":"Male","captain":"Olivia Digby-Clarke","conference":"Europe","country":"United Kingdom","city":"London","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"England","name":"England","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Greater London","name":"Greater London","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"GB","name":"United Kingdom","type":"COUNTRY"}],"city":"Hanworth","location":{"latitude":51.43641119999999,"longitude":-0.3911019},"streetAddress":{"apt":"","formattedAddressLine":"Backstreet Dojo","name":"Hounslow Road","number":""},"formatted":"Hanworth Centre, Hounslow Rd, Hanworth, Feltham TW13 6QQ, UK","country":"GB","postalCode":"TW13 6QQ"},"websiteFacebookUrl":"https://www.facebook.com/Knyaz-UK-109055930462009/","teamEmail":"ukknyaz@gmail.com","teamLogo":"wix:image://v1/c7dce6_b1f504461b7b435d9bc5f6c86dea4ac9~mv2.png/t.png#originWidth=500&originHeight=307","logoUrl":"https://static.wixstatic.com/media/c7dce6_b1f504461b7b435d9bc5f6c86dea4ac9~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":4,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":6}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Tavola Rotonda 2024","date":"2024-06-08","category":"5vs5","place":6}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":10},{"_id":"2","points":0,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"12vs12","place":4},{"_id":"3","points":3,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":10},{"_id":"4","points":10,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":5,"rank5v5":6,"remainingTokens":0,"points5v5":15}},"members":["Olivia Digby-Clarke","Peter Ellis","Gvidas Alekna","Benjamin johnston","Luke Wallis","David Butcher","Danny Mowatt","Calin Corcimaru","James Walters","Kurt Alexander","Martin Bhavon","Dominic Savio","Sam Bollen","George Wilson","Christopher Percival","Jack Gethin"],"sourceCreatedAt":"2023-11-02T08:07:40.928Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knyaz UK (m)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('London',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ukknyaz@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/Knyaz-UK-109055930462009/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c7dce6_b1f504461b7b435d9bc5f6c86dea4ac9~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olivia Digby-Clarke','captain','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Peter Ellis','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gvidas Alekna','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin johnston','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Wallis','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Butcher','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danny Mowatt','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Calin Corcimaru','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Walters','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kurt Alexander','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Bhavon','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dominic Savio','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sam Bollen','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'George Wilson','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Percival','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jack Gethin','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(m)','knyaz-uk-(m)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knyaz-uk-(w)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knyaz-uk-(w)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knyaz UK (w)','London',true,'active','public','bi-knyaz-uk-(w)','EU','Europe','GB','United Kingdom','ukknyaz@gmail.com','https://www.facebook.com/Knyaz-UK-109055930462009/','https://static.wixstatic.com/media/56003d_3499ad33ef0d4ccc85b126e8664146c1~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knyaz-uk-(w)','https://www.buhurtinternational.com/team/knyaz-uk-(w)','Knyaz UK (w)','London','ukknyaz@gmail.com','https://www.facebook.com/Knyaz-UK-109055930462009/',20,'{"biCollectionId":"a64ce78c-cf8d-4913-813b-d9369d4e2342","teamName":"Knyaz UK (w)","club":null,"gender":"Female","captain":"Olivia Digby-Clarke","conference":"Europe","country":"United Kingdom","city":"London","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"England","name":"England","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Greater London","name":"Greater London","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"GB","name":"United Kingdom","type":"COUNTRY"}],"city":"Hanworth","location":{"latitude":51.43641119999999,"longitude":-0.3911019},"streetAddress":{"apt":"","formattedAddressLine":"Backstreet Dojo","name":"Hounslow Road","number":""},"formatted":"Hanworth Centre, Hounslow Rd, Hanworth, Feltham TW13 6QQ, UK","country":"GB","postalCode":"TW13 6QQ"},"websiteFacebookUrl":"https://www.facebook.com/Knyaz-UK-109055930462009/","teamEmail":"ukknyaz@gmail.com","teamLogo":"wix:image://v1/56003d_3499ad33ef0d4ccc85b126e8664146c1~mv2.png/20230530_123031.png#originWidth=628&originHeight=628","logoUrl":"https://static.wixstatic.com/media/56003d_3499ad33ef0d4ccc85b126e8664146c1~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":4.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":3},{"_id":"2","points":1.25,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":7,"remainingTokens":0,"tournaments":[{"_id":"1","points":7,"Tournament":"Tavola Rotonda 2025","date":"2025-06-14","category":"5vs5","place":1}]}},"members":["Olivia Digby-Clarke","Juliane Fagotti","Fiona Young","Riyana Kasmawan","Helmi Keränen","Sarah Hummell","Rose Hernandez","Rowena Lam","Sophia Reinisch","Dani Schorn"],"sourceCreatedAt":"2024-04-03T18:49:29.137Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knyaz UK (w)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('London',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ukknyaz@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/Knyaz-UK-109055930462009/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/56003d_3499ad33ef0d4ccc85b126e8664146c1~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olivia Digby-Clarke','captain','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juliane Fagotti','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fiona Young','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Riyana Kasmawan','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Helmi Keränen','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sarah Hummell','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rose Hernandez','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rowena Lam','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sophia Reinisch','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dani Schorn','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-uk-(w)','knyaz-uk-(w)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='knyaz-usa' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-knyaz-usa' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Knyaz USA','Warren',true,'active','public','bi-knyaz-usa','NA','North America','US','United States','andrew.mccabe1@yahoo.com','https://www.facebook.com/profile.php?id=100064188421068','https://static.wixstatic.com/media/eec65c_9b3c20776665458581abfd3fd9b2e84b~mv2.png','Knyaz USA, Parterned International Team with MFC Knyaz')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','knyaz-usa','https://www.buhurtinternational.com/team/knyaz-usa','Knyaz USA','Warren','andrew.mccabe1@yahoo.com','https://www.facebook.com/profile.php?id=100064188421068',20,'{"biCollectionId":"47e55172-5a99-48be-ab2e-428018a2bcdb","teamName":"Knyaz USA","club":"KNYAZ USA","gender":"Male","captain":"Andrew McCabe","conference":"North America","country":"United States","city":"Warren","teamInfo":"Knyaz USA, Parterned International Team with MFC Knyaz","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100064188421068","teamEmail":"andrew.mccabe1@yahoo.com","teamLogo":"wix:image://v1/eec65c_9b3c20776665458581abfd3fd9b2e84b~mv2.png/Logo%20-%20png%20format.png#originWidth=10532&originHeight=4989","logoUrl":"https://static.wixstatic.com/media/eec65c_9b3c20776665458581abfd3fd9b2e84b~mv2.png","rank5v5":1,"averagePoints5v5":18.08,"points5v5":54.25,"rank12v12":null,"points12v12":6,"tournamentsJoined":[{"_id":"1","points":22.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":1},{"_id":"2","points":13,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":1},{"_id":"3","points":18.75,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":1},{"_id":"4","points":6,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"12vs12","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":24,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":2},{"_id":"2","points":20,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":2},{"_id":"3","points":18,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":2},{"_id":"4","points":12,"Tournament":"Tavola Rotonda 2024","date":"2024-06-08","category":"5vs5","place":1},{"_id":"5","points":8,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":2}]},"2025":{"tournaments":[{"_id":"1","points":18,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":2},{"_id":"2","points":15,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":1},{"_id":"3","points":21,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":1},{"_id":"4","points":16.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":1},{"_id":"5","points":12,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":1},{"_id":"6","points":10,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":2}],"points12v12":28.5,"averagePoints5v5":18,"rank5v5":1,"remainingTokens":10,"points5v5":64}},"members":["Andrew McCabe","Nick Duchene","Jordan Quick","Paul Weeks Jr","Timothy Rondeau","Alex Goodin","Mickey Gallus","Jim Shock","Nicklas huey","Jared Grogg","Chad Nightingale","Blake Allen","Ellis Williams","PETER MICHAEL MOE","Sean Fabian"],"sourceCreatedAt":"2023-09-06T21:33:04.025Z","sourceUpdatedAt":"2026-09-25T12:02:34.121Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Knyaz USA',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Warren',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'andrew.mccabe1@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100064188421068'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/eec65c_9b3c20776665458581abfd3fd9b2e84b~mv2.png'),
 public_description=coalesce(t.public_description,'Knyaz USA, Parterned International Team with MFC Knyaz'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew McCabe','captain','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nick Duchene','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Quick','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Weeks Jr','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Timothy Rondeau','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Goodin','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mickey Gallus','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jim Shock','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicklas huey','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jared Grogg','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chad Nightingale','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blake Allen','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ellis Williams','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PETER MICHAEL MOE','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Fabian','fighter','bi_teams','https://www.buhurtinternational.com/team/knyaz-usa','knyaz-usa',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='korventenn-an-ermin' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-korventenn-an-ermin' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Korventenn an Ermin','Josselin',true,'active','public','bi-korventenn-an-ermin','EU','Europe','FR','France','korventennanermin@gmail.com','https://www.facebook.com/korventenn.an.ermin','https://static.wixstatic.com/media/6e7461_265e4b957984437a94a1c7a1abf278dd~mv2.png','Nous sommes répartis dans toute la Bretagne et même au-delà. On s&#x27;entraîne 1x/mois avec Ar Groaz Du sur leur entraînement commun, puis on s&#x27;entraîne entre nous 2x/mois minimum. Que ce soit au sein des antennes d&#x27;entraînement ou en centre Bretagne: Josselin. Les lieux d&#x27;entraînement varient puisque nous avons 5 lieux différents : Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Au sein de ces antennes d&#x27;entraînement,jusqu&#x27;à 2 entraînements hebdomadaires supplémentaires sont possibles ! Combattante de cœur, femme de courage en Bretagne & ailleurs, tu veux affronter le fracas de la hache et de l&#x27;épée, vaincre tes peurs et dépasser tes limites ? Porter l&#x27;armure pour la première fois et combattre à nos côtés ? N&#x27;hésitez pas à nous contacter ! ______________________ We are spread throughout Brittany. We train 1x/month with Ar Groaz Du on their joint training, then we train between us 2x/month minimum. Training locations vary as we have 5 training locations: Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Within these training antennas, 2 additional weekly training sessions are offered! Fighter of heart, woman of courage in Brittany & elsewhere, do you want to face the crash of the ax and the sword, overcome your fears and exceed your limits? Wearing the armor for the first time and fighting alongside us? Don&#x27;t hesitate to contact us !')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','korventenn-an-ermin','https://www.buhurtinternational.com/team/korventenn-an-ermin','Korventenn an Ermin','Josselin','korventennanermin@gmail.com','https://www.facebook.com/korventenn.an.ermin',20,'{"biCollectionId":"afc6c96f-0be8-4fb9-8c39-04ef4e024882","teamName":"Korventenn an Ermin","club":null,"gender":"Female","captain":"Marie Beaujouan-Marlière","conference":"Europe","country":"France","city":"Josselin","teamInfo":"Nous sommes répartis dans toute la Bretagne et même au-delà. On s&#x27;entraîne 1x/mois avec Ar Groaz Du sur leur entraînement commun, puis on s&#x27;entraîne entre nous 2x/mois minimum. Que ce soit au sein des antennes d&#x27;entraînement ou en centre Bretagne: Josselin. Les lieux d&#x27;entraînement varient puisque nous avons 5 lieux différents : Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Au sein de ces antennes d&#x27;entraînement,jusqu&#x27;à 2 entraînements hebdomadaires supplémentaires sont possibles ! Combattante de cœur, femme de courage en Bretagne & ailleurs, tu veux affronter le fracas de la hache et de l&#x27;épée, vaincre tes peurs et dépasser tes limites ? Porter l&#x27;armure pour la première fois et combattre à nos côtés ? N&#x27;hésitez pas à nous contacter ! ______________________ We are spread throughout Brittany. We train 1x/month with Ar Groaz Du on their joint training, then we train between us 2x/month minimum. Training locations vary as we have 5 training locations: Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Within these training antennas, 2 additional weekly training sessions are offered! Fighter of heart, woman of courage in Brittany & elsewhere, do you want to face the crash of the ax and the sword, overcome your fears and exceed your limits? Wearing the armor for the first time and fighting alongside us? Don&#x27;t hesitate to contact us !","trainingInfo":"Contact us on social networks!","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/korventenn.an.ermin","teamEmail":"korventennanermin@gmail.com","teamLogo":"wix:image://v1/6e7461_265e4b957984437a94a1c7a1abf278dd~mv2.png/Korventenn%20texte%20d%C3%A9coup%C3%A9e.png#originWidth=586&originHeight=719","logoUrl":"https://static.wixstatic.com/media/6e7461_265e4b957984437a94a1c7a1abf278dd~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Jehanne DERING","Marie Beaujouan-Marlière","Granger Leïla","CARRIOT Gwendoline","Lisa MANCA","Alexandra Gressier","Caroline Couraud"],"sourceCreatedAt":"2023-08-07T17:39:37.417Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Korventenn an Ermin',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Josselin',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'korventennanermin@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/korventenn.an.ermin'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6e7461_265e4b957984437a94a1c7a1abf278dd~mv2.png'),
 public_description=coalesce(t.public_description,'Nous sommes répartis dans toute la Bretagne et même au-delà. On s&#x27;entraîne 1x/mois avec Ar Groaz Du sur leur entraînement commun, puis on s&#x27;entraîne entre nous 2x/mois minimum. Que ce soit au sein des antennes d&#x27;entraînement ou en centre Bretagne: Josselin. Les lieux d&#x27;entraînement varient puisque nous avons 5 lieux différents : Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Au sein de ces antennes d&#x27;entraînement,jusqu&#x27;à 2 entraînements hebdomadaires supplémentaires sont possibles ! Combattante de cœur, femme de courage en Bretagne & ailleurs, tu veux affronter le fracas de la hache et de l&#x27;épée, vaincre tes peurs et dépasser tes limites ? Porter l&#x27;armure pour la première fois et combattre à nos côtés ? N&#x27;hésitez pas à nous contacter ! ______________________ We are spread throughout Brittany. We train 1x/month with Ar Groaz Du on their joint training, then we train between us 2x/month minimum. Training locations vary as we have 5 training locations: Brest, Rennes, Vannes, Guérande, Saint-Brieuc. Within these training antennas, 2 additional weekly training sessions are offered! Fighter of heart, woman of courage in Brittany & elsewhere, do you want to face the crash of the ax and the sword, overcome your fears and exceed your limits? Wearing the armor for the first time and fighting alongside us? Don&#x27;t hesitate to contact us !'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jehanne DERING','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marie Beaujouan-Marlière','captain','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Granger Leïla','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'CARRIOT Gwendoline','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lisa MANCA','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandra Gressier','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caroline Couraud','fighter','bi_teams','https://www.buhurtinternational.com/team/korventenn-an-ermin','korventenn-an-ermin',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ks-rycerz' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ks-rycerz' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'KS Rycerz','ŁÓDŹ',true,'active','public','bi-ks-rycerz','EU','Europe','PL','Poland','ksrycerz@gmail.com','https://www.facebook.com/ksrycerzofficial','https://static.wixstatic.com/media/8140a4_77181390833443bbaecd10a4ef58ca57~mv2.png','Polish champions since 2017/2018 to 2025, every Buhurt Prime participant.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ks-rycerz','https://www.buhurtinternational.com/team/ks-rycerz','KS Rycerz','ŁÓDŹ','ksrycerz@gmail.com','https://www.facebook.com/ksrycerzofficial',20,'{"biCollectionId":"88b8f6a8-549e-496c-9078-8fd879a1604d","teamName":"KS Rycerz","club":null,"gender":"Male","captain":"Artur Patalas","conference":"Europe","country":"Poland","city":"ŁÓDŹ","teamInfo":"Polish champions since 2017/2018 to 2025, every Buhurt Prime participant.","trainingInfo":"Tower stands!","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/ksrycerzofficial","teamEmail":"ksrycerz@gmail.com","teamLogo":"wix:image://v1/8140a4_77181390833443bbaecd10a4ef58ca57~mv2.png/logo%20ksr%20(1)%20(1).png#originWidth=948&originHeight=1060","logoUrl":"https://static.wixstatic.com/media/8140a4_77181390833443bbaecd10a4ef58ca57~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":14,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":1},{"_id":"2","points":7,"Tournament":"King Kazimierz Cup 2024","date":45528,"category":"5vs5","place":2},{"_id":"3","points":10,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":6,"remainingTokens":4,"tournaments":[{"_id":"1","points":6,"Tournament":"King Kazimierz Cup 2025","date":"2025-08-16","category":"5vs5","place":3}]}},"members":["Artur Patalas","Aleksander Blausz","Artur Frontczak","Boleslaw Sitek","Mariusz Czubak","Robert Derus","Aleksander Czubak","Adrian Tomaszewski","Bogdan Raczyński","Lukas Jerabek","Karol Niemiec","Artur Klimanek","Marcin Marszalek","Stanislavs Simutis","Valiantsin Chernyshou","Samuel Siotkin"],"sourceCreatedAt":"2023-08-24T15:22:40.657Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('KS Rycerz',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('ŁÓDŹ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ksrycerz@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ksrycerzofficial'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8140a4_77181390833443bbaecd10a4ef58ca57~mv2.png'),
 public_description=coalesce(t.public_description,'Polish champions since 2017/2018 to 2025, every Buhurt Prime participant.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Artur Patalas','captain','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksander Blausz','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Artur Frontczak','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Boleslaw Sitek','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariusz Czubak','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robert Derus','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksander Czubak','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Tomaszewski','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bogdan Raczyński','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lukas Jerabek','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karol Niemiec','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Artur Klimanek','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcin Marszalek','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stanislavs Simutis','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valiantsin Chernyshou','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Siotkin','fighter','bi_teams','https://www.buhurtinternational.com/team/ks-rycerz','ks-rycerz',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='la-confrérie-des-loups' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-la-confrérie-des-loups' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'La Confrérie des Loups','Lyon',true,'active','public','bi-la-confrérie-des-loups','EU','Europe','FR','France','asamm.behourd@gmail.com','https://www.facebook.com/LaConfrerieDesLoups','https://static.wixstatic.com/media/4cfac6_6b99dc737bf6440db80d9de84bb40b7c~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','la-confrérie-des-loups','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','La Confrérie des Loups','Lyon','asamm.behourd@gmail.com','https://www.facebook.com/LaConfrerieDesLoups',20,'{"biCollectionId":"5a286f15-966a-4d34-89d0-8434ece67f45","teamName":"La Confrérie des Loups","club":null,"gender":"Male","captain":"Guillerme Freddy","conference":"Europe","country":"France","city":"Lyon","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/LaConfrerieDesLoups","teamEmail":"asamm.behourd@gmail.com","teamLogo":"wix:image://v1/4cfac6_6b99dc737bf6440db80d9de84bb40b7c~mv2.png/Ecusson%20Confr%C3%A9rie%20des%20Loups.png#originWidth=400&originHeight=459","logoUrl":"https://static.wixstatic.com/media/4cfac6_6b99dc737bf6440db80d9de84bb40b7c~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":6,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":3},{"_id":"2","points":3,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":5},{"_id":"3","points":12,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":7,"rank5v5":4,"remainingTokens":10,"points5v5":21}},"members":["Guillerme Freddy","Guillaume PARA","COURROYE Sylvain","VAUZELAS Adrien","Jean-Daniel Malcor","Victor Le roux","Brieuc GASTINEAU","Laugier adrien","LAMOTTE Alexandre","Bastien Demarais","Swann Cécillon"],"sourceCreatedAt":"2025-01-29T05:54:57.784Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('La Confrérie des Loups',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lyon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'asamm.behourd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/LaConfrerieDesLoups'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4cfac6_6b99dc737bf6440db80d9de84bb40b7c~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillerme Freddy','captain','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume PARA','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'COURROYE Sylvain','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VAUZELAS Adrien','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean-Daniel Malcor','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Victor Le roux','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brieuc GASTINEAU','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laugier adrien','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LAMOTTE Alexandre','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bastien Demarais','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Swann Cécillon','fighter','bi_teams','https://www.buhurtinternational.com/team/la-confr%C3%A9rie-des-loups','la-confrérie-des-loups',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='la-golden-knights' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-la-golden-knights' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'LA Golden Knights','Los Angeles',true,'active','public','bi-la-golden-knights','NA','North America','US','United States','brian.del.gaudio@gmail.com','https://lagoldenknights.com/','https://static.wixstatic.com/media/48d1b5_bbc4c68e1fef4204810a4cb10a70a9fb~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','la-golden-knights','https://www.buhurtinternational.com/team/la-golden-knights','LA Golden Knights','Los Angeles','brian.del.gaudio@gmail.com','https://lagoldenknights.com/',20,'{"biCollectionId":"8ca20dd6-e63a-4883-8ee4-ba29049bfbea","teamName":"LA Golden Knights","club":null,"gender":"Male","captain":"Jason Puerta","conference":"North America","country":"United States","city":"Los Angeles","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://lagoldenknights.com/","teamEmail":"brian.del.gaudio@gmail.com","teamLogo":"wix:image://v1/48d1b5_bbc4c68e1fef4204810a4cb10a70a9fb~mv2.png/goldenknights_logo.png#originWidth=1366&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/48d1b5_bbc4c68e1fef4204810a4cb10a70a9fb~mv2.png","rank5v5":15,"averagePoints5v5":1.83,"points5v5":5.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":5},{"_id":"2","points":2.5,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":6},{"_id":"3","points":2,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":7}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Rise of an Empire 2024","date":"2024-08-30","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":1,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":5},{"_id":"2","points":3,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":4},{"_id":"3","points":2,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":2,"rank5v5":17,"remainingTokens":7,"points5v5":6}},"members":["Jason Puerta","Brian Del Gaudio","Garrison Cook","Alexander Robinson","Bryan Alfaro","Bradley Harunkiewicz","Raymond Giron","Jason L Puerta","Sam Taylor"],"sourceCreatedAt":"2024-08-22T00:38:14.945Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('LA Golden Knights',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Los Angeles',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'brian.del.gaudio@gmail.com'),
 website_url=coalesce(t.website_url,'https://lagoldenknights.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/48d1b5_bbc4c68e1fef4204810a4cb10a70a9fb~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Puerta','captain','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Del Gaudio','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Garrison Cook','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Robinson','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryan Alfaro','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bradley Harunkiewicz','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raymond Giron','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason L Puerta','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sam Taylor','fighter','bi_teams','https://www.buhurtinternational.com/team/la-golden-knights','la-golden-knights',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='la-salle-d''armes-école-ancienne-aveyron' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-la-salle-d''armes-école-ancienne-aveyron' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'La Salle d''Armes École Ancienne Aveyron','Millau',true,'active','public','bi-la-salle-d''armes-école-ancienne-aveyron','EU','Europe','FR','France','saea.aveyron@gmail.com','https://la-salle-darmes-ancienne.fr/saea-aveyron/','https://static.wixstatic.com/media/d5d65f_615e2e4eee024ffc84a0d69e43c8fb47~mv2.jpg','SAEA AVEYRON is a club of dueling and Profight specialists. It offers leisure activities around historical combat sports and training for a team of competitors. The SAEA AVEYRON organizes the international duel and Profight tournament every year : Le Lion d&#x27;Acier (www.leliondacier.com)')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','la-salle-d''armes-école-ancienne-aveyron','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','La Salle d''Armes École Ancienne Aveyron','Millau','saea.aveyron@gmail.com','https://la-salle-darmes-ancienne.fr/saea-aveyron/',20,'{"biCollectionId":"167d9e62-6f03-4b73-aead-b52c56acbeb7","teamName":"La Salle d''Armes École Ancienne Aveyron","club":"Les Lions du Rouergue (SAEA AVEYRON)","gender":"Male","captain":"Vincent Balissat","conference":"Europe","country":"France","city":"Millau","teamInfo":"SAEA AVEYRON is a club of dueling and Profight specialists. It offers leisure activities around historical combat sports and training for a team of competitors. The SAEA AVEYRON organizes the international duel and Profight tournament every year : Le Lion d&#x27;Acier (www.leliondacier.com)","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Occitanie","name":"Occitanie","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Aveyron","name":"Aveyron","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Onet-le-Château","name":"Onet-le-Château","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Onet-le-Château","location":{"latitude":44.37948069999999,"longitude":2.5891648},"streetAddress":{"apt":"","formattedAddressLine":"Onet-le-Château","name":"","number":""},"formatted":"12850 Onet-le-Château, France","country":"FR","postalCode":"12850","subdivision":"OCC"},"websiteFacebookUrl":"https://la-salle-darmes-ancienne.fr/saea-aveyron/","teamEmail":"saea.aveyron@gmail.com","teamLogo":"wix:image://v1/d5d65f_615e2e4eee024ffc84a0d69e43c8fb47~mv2.jpg/image_6483441.JPG#originWidth=340&originHeight=300","logoUrl":"https://static.wixstatic.com/media/d5d65f_615e2e4eee024ffc84a0d69e43c8fb47~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Vincent Balissat","SAUNIER ANTHONY","Ivan Mignerat","Moulin Frédéric","COSTES Laurent","TEYSSONNEIRE Pierre-Elliot","MORALES Julien","Nayrolles Charlie","Julien Balloy","LATIEULE Theo","Clément CARSAC","VIC Christophe","Balissat Vincent"],"sourceCreatedAt":"2023-09-13T15:43:07.569Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('La Salle d''Armes École Ancienne Aveyron',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Millau',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'saea.aveyron@gmail.com'),
 website_url=coalesce(t.website_url,'https://la-salle-darmes-ancienne.fr/saea-aveyron/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d5d65f_615e2e4eee024ffc84a0d69e43c8fb47~mv2.jpg'),
 public_description=coalesce(t.public_description,'SAEA AVEYRON is a club of dueling and Profight specialists. It offers leisure activities around historical combat sports and training for a team of competitors. The SAEA AVEYRON organizes the international duel and Profight tournament every year : Le Lion d&#x27;Acier (www.leliondacier.com)'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Balissat','captain','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'SAUNIER ANTHONY','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Mignerat','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Moulin Frédéric','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'COSTES Laurent','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'TEYSSONNEIRE Pierre-Elliot','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MORALES Julien','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nayrolles Charlie','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julien Balloy','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LATIEULE Theo','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Clément CARSAC','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VIC Christophe','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Balissat Vincent','fighter','bi_teams','https://www.buhurtinternational.com/team/la-salle-d''armes-%C3%A9cole-ancienne-aveyron','la-salle-d''armes-école-ancienne-aveyron',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ladies-of-the-knight' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ladies-of-the-knight' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ladies of the Knight',NULL,true,'active','public','bi-ladies-of-the-knight','NA','North America','CA','Canada','LadiesoftheKnight.bi@gmail.com',NULL,'https://static.wixstatic.com/media/822fa6_244d0761310b45639d56673ce8ee793f~mv2.jpg','This team was pulled together from different cities and friendships to fight along side each other in battle')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ladies-of-the-knight','https://www.buhurtinternational.com/team/ladies-of-the-knight','Ladies of the Knight',NULL,'LadiesoftheKnight.bi@gmail.com',NULL,20,'{"biCollectionId":"20f49b8e-a2cc-4c0b-a6bf-b062115aab6f","teamName":"Ladies of the Knight","club":null,"gender":"Female","captain":"Kella McKenzie","conference":"North America","country":"Canada","city":null,"teamInfo":"This team was pulled together from different cities and friendships to fight along side each other in battle","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"LadiesoftheKnight.bi@gmail.com","teamLogo":"wix:image://v1/822fa6_244d0761310b45639d56673ce8ee793f~mv2.jpg/sirenlogo.jfif#originWidth=852&originHeight=803","logoUrl":"https://static.wixstatic.com/media/822fa6_244d0761310b45639d56673ce8ee793f~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Kella McKenzie","Kolby Verkirk"],"sourceCreatedAt":"2026-05-18T23:12:44.741Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ladies of the Knight',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'LadiesoftheKnight.bi@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/822fa6_244d0761310b45639d56673ce8ee793f~mv2.jpg'),
 public_description=coalesce(t.public_description,'This team was pulled together from different cities and friendships to fight along side each other in battle'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kella McKenzie','captain','bi_teams','https://www.buhurtinternational.com/team/ladies-of-the-knight','ladies-of-the-knight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kolby Verkirk','fighter','bi_teams','https://www.buhurtinternational.com/team/ladies-of-the-knight','ladies-of-the-knight',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='leeds-devils' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-leeds-devils' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Leeds Devils',NULL,true,'active','public','bi-leeds-devils','NA','North America','US','United States','leedsnj13@gmail.com','https://www.facebook.com/share/1HhrwVbTyt/?mibextid=wwXIfr','https://static.wixstatic.com/media/569fc1_f20e2acf2cdb4c5c8b0e48271d533547~mv2.jpeg','Team out of New Jersey looking to climb the ranks!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','leeds-devils','https://www.buhurtinternational.com/team/leeds-devils','Leeds Devils',NULL,'leedsnj13@gmail.com','https://www.facebook.com/share/1HhrwVbTyt/?mibextid=wwXIfr',20,'{"biCollectionId":"0350c2b6-4605-44d5-9d90-886b3e73d47d","teamName":"Leeds Devils","club":null,"gender":"Male","captain":"Pedro","conference":"North America","country":"United States","city":null,"teamInfo":"Team out of New Jersey looking to climb the ranks!","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/1HhrwVbTyt/?mibextid=wwXIfr","teamEmail":"leedsnj13@gmail.com","teamLogo":"wix:image://v1/569fc1_f20e2acf2cdb4c5c8b0e48271d533547~mv2.jpeg/IMG_9595.jpeg#originWidth=704&originHeight=1117","logoUrl":"https://static.wixstatic.com/media/569fc1_f20e2acf2cdb4c5c8b0e48271d533547~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Pedro","Constant Hackney","Anthony Carvalho","Christopher Andrew Torok","Aidan Marshall","Kyle Hopkins","Pedro Alanya","McLain Hirschbuhl"],"sourceCreatedAt":"2026-08-16T00:49:32.453Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Leeds Devils',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'leedsnj13@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1HhrwVbTyt/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/569fc1_f20e2acf2cdb4c5c8b0e48271d533547~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Team out of New Jersey looking to climb the ranks!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pedro','captain','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Constant Hackney','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anthony Carvalho','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Andrew Torok','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aidan Marshall','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Hopkins','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pedro Alanya','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'McLain Hirschbuhl','fighter','bi_teams','https://www.buhurtinternational.com/team/leeds-devils','leeds-devils',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='legenda-północy' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-legenda-północy' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Legenda Północy','Nidzica',true,'active','public','bi-legenda-północy','EU','Europe','PL','Poland','polnocylegenda@gmail.com','https://www.facebook.com/polnocylegenda','https://static.wixstatic.com/media/e6daee_e65c1d7b1e4545338bda0b1c9a413a96~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','legenda-północy','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','Legenda Północy','Nidzica','polnocylegenda@gmail.com','https://www.facebook.com/polnocylegenda',20,'{"biCollectionId":"7f470189-0cc5-4823-9265-fc810b93a7da","teamName":"Legenda Północy","club":null,"gender":"Male","captain":"Patryk Kruk","conference":"Europe","country":"Poland","city":"Nidzica","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/polnocylegenda","teamEmail":"polnocylegenda@gmail.com","teamLogo":"wix:image://v1/e6daee_e65c1d7b1e4545338bda0b1c9a413a96~mv2.png/LP%20png.png#originWidth=512&originHeight=601","logoUrl":"https://static.wixstatic.com/media/e6daee_e65c1d7b1e4545338bda0b1c9a413a96~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Grunwald Arena Cup 2026 ","date":"2025-05-31","category":"5vs5","place":7}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":0,"tournaments":[{"_id":"1","points":10,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":2}]}},"members":["Patryk Kruk","Mateusz Nowicki","Adam Szymański","Arkadiusz Kustra","Michał Głowacki","Miłosz Dawidowicz","Rafal Lewanczyk","Patryk Czeczko","Mikolaj Brzozowski"],"sourceCreatedAt":"2025-01-23T19:24:03.334Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Legenda Północy',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nidzica',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'polnocylegenda@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/polnocylegenda'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/e6daee_e65c1d7b1e4545338bda0b1c9a413a96~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patryk Kruk','captain','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mateusz Nowicki','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Szymański','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arkadiusz Kustra','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michał Głowacki','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miłosz Dawidowicz','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafal Lewanczyk','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patryk Czeczko','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mikolaj Brzozowski','fighter','bi_teams','https://www.buhurtinternational.com/team/legenda-p%C3%B3%C5%82nocy','legenda-północy',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='legion-of-honor' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-legion-of-honor' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Legion of Honor','St. Louis',true,'active','public','bi-legion-of-honor','NA','North America','US','United States','legionofhonor.stl@gmail.com','https://www.facebook.com/STL.LegionOfHonor','https://static.wixstatic.com/media/d05742_bdba3987fc874943a0be086447e2bcd9~mv2.jpg','We are located in St. Louis Missouri. The team started back in 2019 and we have roughly 20 members so far!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','legion-of-honor','https://www.buhurtinternational.com/team/legion-of-honor','Legion of Honor','St. Louis','legionofhonor.stl@gmail.com','https://www.facebook.com/STL.LegionOfHonor',20,'{"biCollectionId":"3f78fb42-0748-4f0f-a364-791a496cdf4e","teamName":"Legion of Honor","club":null,"gender":"Male","captain":"Sean Holland","conference":"North America","country":"United States","city":"St. Louis","teamInfo":"We are located in St. Louis Missouri. The team started back in 2019 and we have roughly 20 members so far!","trainingInfo":"People need to bring only themselves and workout attire to start.","trainingLocation":{"subdivisions":[{"code":"MO","name":"Missouri","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Jefferson County","name":"Jefferson County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Festus","name":"Festus","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Festus","location":{"latitude":38.2192657,"longitude":-90.3892699},"streetAddress":{"apt":"","formattedAddressLine":"20 E Main St","name":"East Main Street","number":"20"},"formatted":"20 E Main St, Festus, MO 63028, USA","country":"US","postalCode":"63028-1903","subdivision":"MO"},"websiteFacebookUrl":"https://www.facebook.com/STL.LegionOfHonor","teamEmail":"legionofhonor.stl@gmail.com","teamLogo":"wix:image://v1/d05742_bdba3987fc874943a0be086447e2bcd9~mv2.jpg/team%20logo.jpg#originWidth=1440&originHeight=1440","logoUrl":"https://static.wixstatic.com/media/d05742_bdba3987fc874943a0be086447e2bcd9~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":10,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":6},{"_id":"2","points":8,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":2}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":18,"remainingTokens":9,"tournaments":[{"_id":"1","points":18,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2025","date":"2025-06-28","category":"5vs5","place":1}]}},"members":["Sean Holland","William Anothony Tye Johnson","Cody Young","Dalton Robinson","Jacob Summers","Dakota Tebbe","John Bui","Jon lee","Daniel Harris"],"sourceCreatedAt":"2025-05-08T22:37:31.092Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Legion of Honor',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('St. Louis',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'legionofhonor.stl@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/STL.LegionOfHonor'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d05742_bdba3987fc874943a0be086447e2bcd9~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are located in St. Louis Missouri. The team started back in 2019 and we have roughly 20 members so far!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Holland','captain','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Anothony Tye Johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cody Young','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dalton Robinson','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Summers','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dakota Tebbe','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Bui','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jon lee','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Harris','fighter','bi_teams','https://www.buhurtinternational.com/team/legion-of-honor','legion-of-honor',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='león-albino' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-león-albino' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'León albino','Tucumán ',true,'active','public','bi-león-albino','SA','South America','AR','Argentina','leonalbinohmb@gmail.com','https://www.facebook.com/leonalbinocombatemedievaltucuman?mibextid=ZbWKwL','https://static.wixstatic.com/media/bcb30b_3724036619b34b9d80d430a9cf7c2416~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','león-albino','https://www.buhurtinternational.com/team/le%C3%B3n-albino','León albino','Tucumán ','leonalbinohmb@gmail.com','https://www.facebook.com/leonalbinocombatemedievaltucuman?mibextid=ZbWKwL',20,'{"biCollectionId":"9ad92fc5-c90b-4219-8efd-3bdf81ee89e1","teamName":"León albino","club":null,"gender":"Male","captain":"Sofía Reifschneider","conference":"South America","country":"Argentina","city":"Tucumán ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/leonalbinocombatemedievaltucuman?mibextid=ZbWKwL","teamEmail":"leonalbinohmb@gmail.com","teamLogo":"wix:image://v1/bcb30b_3724036619b34b9d80d430a9cf7c2416~mv2.jpg/Polish_20230911_195827671.jpg#originWidth=3112&originHeight=3112","logoUrl":"https://static.wixstatic.com/media/bcb30b_3724036619b34b9d80d430a9cf7c2416~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Sofía Reifschneider","Cervera facundo santiago","David Uriel Ardiles","Leonardo Bargas","Lucio Bergese","José Manuel Prieto Ganim","Mariano José Agustín"],"sourceCreatedAt":"2023-09-11T22:36:08.491Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('León albino',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tucumán ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'leonalbinohmb@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/leonalbinocombatemedievaltucuman?mibextid=ZbWKwL'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bcb30b_3724036619b34b9d80d430a9cf7c2416~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sofía Reifschneider','captain','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cervera facundo santiago','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Uriel Ardiles','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Bargas','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucio Bergese','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'José Manuel Prieto Ganim','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariano José Agustín','fighter','bi_teams','https://www.buhurtinternational.com/team/le%C3%B3n-albino','león-albino',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-bannerets-d''auvergne' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-bannerets-d''auvergne' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les Bannerets d''Auvergne','Le Mayet d''école',true,'active','public','bi-les-bannerets-d''auvergne','EU','Europe','FR','France','auvergne.behourd@gmail.com','https://www.facebook.com/bannerets63','https://static.wixstatic.com/media/0f0728_6862a89d002d4ac7adba8b74dafa398e~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-bannerets-d''auvergne','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','Les Bannerets d''Auvergne','Le Mayet d''école','auvergne.behourd@gmail.com','https://www.facebook.com/bannerets63',20,'{"biCollectionId":"3dff8791-a58f-46c4-aa07-47ee566c8e51","teamName":"Les Bannerets d''Auvergne","club":null,"gender":"Male","captain":"RICHARD Sébastien","conference":"Europe","country":"France","city":"Le Mayet d''école","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/bannerets63","teamEmail":"auvergne.behourd@gmail.com","teamLogo":"wix:image://v1/0f0728_6862a89d002d4ac7adba8b74dafa398e~mv2.jpg/logo%20bannerets.jpg#originWidth=305&originHeight=206","logoUrl":"https://static.wixstatic.com/media/0f0728_6862a89d002d4ac7adba8b74dafa398e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["RICHARD Sébastien","Leconte Loic","BÉNARD Clément","Thomas Cournol","Bresle Mathieu","Mayeul Bourillon","Maxime Vallet"],"sourceCreatedAt":"2024-03-26T16:00:16.917Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les Bannerets d''Auvergne',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Le Mayet d''école',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'auvergne.behourd@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/bannerets63'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/0f0728_6862a89d002d4ac7adba8b74dafa398e~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'RICHARD Sébastien','captain','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leconte Loic','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BÉNARD Clément','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Cournol','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bresle Mathieu','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mayeul Bourillon','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxime Vallet','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannerets-d''auvergne','les-bannerets-d''auvergne',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-bannis-de-la-grenouille' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-bannis-de-la-grenouille' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'LES BANNIS DE LA GRENOUILLE','Pont-Saint-Esprit',true,'active','public','bi-les-bannis-de-la-grenouille','EU','Europe','FR','France','lesbannisdelagrenouille@gmail.com','https://www.facebook.com/search/top?q=les%20bannis%20de%20la%20grenouille','https://static.wixstatic.com/media/3065da_da2fc54981f14fa3912bc0c32d1eea06~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-bannis-de-la-grenouille','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','LES BANNIS DE LA GRENOUILLE','Pont-Saint-Esprit','lesbannisdelagrenouille@gmail.com','https://www.facebook.com/search/top?q=les%20bannis%20de%20la%20grenouille',20,'{"biCollectionId":"d34c8b78-b8da-4eef-be6a-2ae2d0ab76ea","teamName":"LES BANNIS DE LA GRENOUILLE","club":null,"gender":"Male","captain":"Dany Lienthinger","conference":"Europe","country":"France","city":"Pont-Saint-Esprit","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/search/top?q=les%20bannis%20de%20la%20grenouille","teamEmail":"lesbannisdelagrenouille@gmail.com","teamLogo":"wix:image://v1/3065da_da2fc54981f14fa3912bc0c32d1eea06~mv2.png/les%20bannis.png#originWidth=959&originHeight=833","logoUrl":"https://static.wixstatic.com/media/3065da_da2fc54981f14fa3912bc0c32d1eea06~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":11}]},"2025":{"remainingTokens":10}},"members":["Dany Lienthinger","Thibaud Sommet","Joseph-Antoine Ciccoli","Hugo Bracali","TORREGROSSA Martial","Gwenaël Le bihan","Louis Zannini","David Diana","Adrien Jouffret"],"sourceCreatedAt":"2023-09-26T18:51:21.309Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('LES BANNIS DE LA GRENOUILLE',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Pont-Saint-Esprit',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lesbannisdelagrenouille@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/search/top?q=les%20bannis%20de%20la%20grenouille'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3065da_da2fc54981f14fa3912bc0c32d1eea06~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dany Lienthinger','captain','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thibaud Sommet','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph-Antoine Ciccoli','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hugo Bracali','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'TORREGROSSA Martial','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gwenaël Le bihan','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Louis Zannini','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Diana','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrien Jouffret','fighter','bi_teams','https://www.buhurtinternational.com/team/les-bannis-de-la-grenouille','les-bannis-de-la-grenouille',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-comtois' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-comtois' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les comtois','Morbier',true,'active','public','bi-les-comtois','EU','Europe','FR','France','mathieujeangaillard@orange.fr','https://www.facebook.com/search/top?q=les%20comtois','https://static.wixstatic.com/media/2a5d82_e1d65ad6f461456b806323f55aa7ae46~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-comtois','https://www.buhurtinternational.com/team/les-comtois','Les comtois','Morbier','mathieujeangaillard@orange.fr','https://www.facebook.com/search/top?q=les%20comtois',20,'{"biCollectionId":"ea0d24e4-489f-4984-a090-d0077616561a","teamName":"Les comtois","club":null,"gender":"Male","captain":"Aloïs Lamy","conference":"Europe","country":"France","city":"Morbier","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/search/top?q=les%20comtois","teamEmail":"mathieujeangaillard@orange.fr","teamLogo":"wix:image://v1/2a5d82_e1d65ad6f461456b806323f55aa7ae46~mv2.jpg/373421946_150265534798181_6725325436814291683_n.jpg#originWidth=403&originHeight=403","logoUrl":"https://static.wixstatic.com/media/2a5d82_e1d65ad6f461456b806323f55aa7ae46~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":6},{"_id":"2","points":9,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":2}]}},"members":["Mathieu gaillard","Aloïs Lamy","VIONNET Paul","BALLAUD Thomas","De Dieuleveult Gabriel","VIONNET Jean","Esteban Lanat","DINDELEUX Lucas","Louis FIRMIN","Vincent Kees","Rossier Nicolas"],"sourceCreatedAt":"2023-09-07T19:51:11.427Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les comtois',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Morbier',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mathieujeangaillard@orange.fr'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/search/top?q=les%20comtois'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2a5d82_e1d65ad6f461456b806323f55aa7ae46~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mathieu gaillard','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aloïs Lamy','captain','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VIONNET Paul','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BALLAUD Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'De Dieuleveult Gabriel','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VIONNET Jean','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Esteban Lanat','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'DINDELEUX Lucas','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Louis FIRMIN','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Kees','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rossier Nicolas','fighter','bi_teams','https://www.buhurtinternational.com/team/les-comtois','les-comtois',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-descendants-du-hardi' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-descendants-du-hardi' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les Descendants Du Hardi','Auxerre',true,'active','public','bi-les-descendants-du-hardi','EU','Europe','FR','France','olivegeo47180@gmail.com','https://www.facebook.com/les.descendants.du.hardi/','https://static.wixstatic.com/media/59b6ee_d992cda0f1f54350b155be45387d179d~mv2.jpg','lesdescendantsduhardi.auxerre@gmail.com')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-descendants-du-hardi','https://www.buhurtinternational.com/team/les-descendants-du-hardi','Les Descendants Du Hardi','Auxerre','olivegeo47180@gmail.com','https://www.facebook.com/les.descendants.du.hardi/',20,'{"biCollectionId":"ee31c793-c4a2-4dde-b021-15fa3de6f109","teamName":"Les Descendants Du Hardi","club":null,"gender":"Male","captain":"Julien LEMOINE ","conference":"Europe","country":"France","city":"Auxerre","teamInfo":"lesdescendantsduhardi.auxerre@gmail.com","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Bourgogne-Franche-Comté","name":"Bourgogne-Franche-Comté","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Yonne","name":"Yonne","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Auxerre","name":"Auxerre","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Auxerre","location":{"latitude":47.79241390000001,"longitude":3.5542442},"streetAddress":{"apt":"","formattedAddressLine":"Rue Jules Renard","name":"Rue Jules Renard","number":""},"formatted":"Rue Jules Renard, 89000 Auxerre, France","country":"FR","postalCode":"89000","subdivision":"BFC"},"websiteFacebookUrl":"https://www.facebook.com/les.descendants.du.hardi/","teamEmail":"olivegeo47180@gmail.com","teamLogo":"wix:image://v1/59b6ee_d992cda0f1f54350b155be45387d179d~mv2.jpg/images.jfif#originWidth=222&originHeight=227","logoUrl":"https://static.wixstatic.com/media/59b6ee_d992cda0f1f54350b155be45387d179d~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":3},{"_id":"2","points":3,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":4},{"_id":"3","points":2,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":7}],"points12v12":0,"averagePoints5v5":3,"rank5v5":10,"remainingTokens":9,"points5v5":9}},"members":["Julien LEMOINE","Thomas boidin","Lardet Benjamin","David BAUDOT","Thomas Lemoine","Sylvain Nicolardot","Charles Brelaud","Maxime Orani","Olivier Geoffroy","Da Silva Anthony"],"sourceCreatedAt":"2024-06-26T13:35:39.130Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les Descendants Du Hardi',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Auxerre',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'olivegeo47180@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/les.descendants.du.hardi/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/59b6ee_d992cda0f1f54350b155be45387d179d~mv2.jpg'),
 public_description=coalesce(t.public_description,'lesdescendantsduhardi.auxerre@gmail.com'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julien LEMOINE','captain','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas boidin','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lardet Benjamin','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David BAUDOT','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Lemoine','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sylvain Nicolardot','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charles Brelaud','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxime Orani','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olivier Geoffroy','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Da Silva Anthony','fighter','bi_teams','https://www.buhurtinternational.com/team/les-descendants-du-hardi','les-descendants-du-hardi',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-gargouilles-de-paris' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-gargouilles-de-paris' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les Gargouilles de Paris','Paris',true,'active','public','bi-les-gargouilles-de-paris','EU','Europe','FR','France','saeagargouillesdeparis@gmail.com','https://www.facebook.com/groups/2152737238386815','https://static.wixstatic.com/media/48da9c_5402a0368628443ba32bee3e1fa5c25f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-gargouilles-de-paris','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','Les Gargouilles de Paris','Paris','saeagargouillesdeparis@gmail.com','https://www.facebook.com/groups/2152737238386815',20,'{"biCollectionId":"33f5d422-10c2-4dd6-8273-d9f96b3a1e11","teamName":"Les Gargouilles de Paris","club":"Salle d''Armes École Ancienne","gender":"Male","captain":"Francky Malliet","conference":"Europe","country":"France","city":"Paris","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"IDF","name":"Île-de-France","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Département de Paris","name":"Département de Paris","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Paris","name":"Paris","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Paris","location":{"latitude":48.8759917,"longitude":2.3424338},"streetAddress":{"apt":"","formattedAddressLine":"26 Rue Buffault","name":"Rue Buffault","number":"26"},"formatted":"26 Rue Buffault, 75009 Paris, France","country":"FR","postalCode":"75009","subdivision":"IDF"},"websiteFacebookUrl":"https://www.facebook.com/groups/2152737238386815","teamEmail":"saeagargouillesdeparis@gmail.com","teamLogo":"wix:image://v1/48da9c_5402a0368628443ba32bee3e1fa5c25f~mv2.png/SAEA_Les_Gargouilles_de_Paris.png#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/48da9c_5402a0368628443ba32bee3e1fa5c25f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Paul Antoine","Quentin Mouty","Gil LE ROUX","Olivier Nguyen","Francky Malliet","Rémi Feton","Gaëtan Moreau","Jean TAUZIAC"],"sourceCreatedAt":"2024-02-12T09:00:34.482Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les Gargouilles de Paris',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Paris',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'saeagargouillesdeparis@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/2152737238386815'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/48da9c_5402a0368628443ba32bee3e1fa5c25f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Antoine','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quentin Mouty','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gil LE ROUX','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Olivier Nguyen','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francky Malliet','captain','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rémi Feton','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gaëtan Moreau','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean TAUZIAC','fighter','bi_teams','https://www.buhurtinternational.com/team/les-gargouilles-de-paris','les-gargouilles-de-paris',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-lys-de-france' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-lys-de-france' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les Lys de France','PARIS',true,'active','public','bi-les-lys-de-france','EU','Europe','FR','France','comitebehourdfeminin@gmail.com','https://combatmedieval.com/','https://static.wixstatic.com/media/252214_5fe26ba264f24583a13e74e8b1b5769c~mv2.jpg','A french alliance for womens&#x27; fights abroad !')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-lys-de-france','https://www.buhurtinternational.com/team/les-lys-de-france','Les Lys de France','PARIS','comitebehourdfeminin@gmail.com','https://combatmedieval.com/',20,'{"biCollectionId":"5190e64d-eb62-4554-ba1a-604a3ff4c2b2","teamName":"Les Lys de France","club":null,"gender":"Female","captain":"Louise HULLIN","conference":"Europe","country":"France","city":"PARIS","teamInfo":"A french alliance for womens&#x27; fights abroad !","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://combatmedieval.com/","teamEmail":"comitebehourdfeminin@gmail.com","teamLogo":"wix:image://v1/252214_5fe26ba264f24583a13e74e8b1b5769c~mv2.jpg/LYS.jpg#originWidth=650&originHeight=618","logoUrl":"https://static.wixstatic.com/media/252214_5fe26ba264f24583a13e74e8b1b5769c~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":9,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"12vs12","place":1},{"_id":"2","points":28,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":1}]},"2025":{"remainingTokens":9}},"members":["Louise HULLIN"],"sourceCreatedAt":"2024-04-17T19:47:27.459Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les Lys de France',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('PARIS',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'comitebehourdfeminin@gmail.com'),
 website_url=coalesce(t.website_url,'https://combatmedieval.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/252214_5fe26ba264f24583a13e74e8b1b5769c~mv2.jpg'),
 public_description=coalesce(t.public_description,'A french alliance for womens&#x27; fights abroad !'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Louise HULLIN','captain','bi_teams','https://www.buhurtinternational.com/team/les-lys-de-france','les-lys-de-france',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-vassaux-de-provence' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-vassaux-de-provence' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'LES VASSAUX DE PROVENCE','le luc',true,'active','public','bi-les-vassaux-de-provence','EU','Europe','FR','France','crampagnefrancois@gmail.com','https://www.facebook.com/lesvassauxdeprovence','https://static.wixstatic.com/media/c92b71_2c5e7d69920444a7aee220da3bc01118~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-vassaux-de-provence','https://www.buhurtinternational.com/team/les-vassaux-de-provence','LES VASSAUX DE PROVENCE','le luc','crampagnefrancois@gmail.com','https://www.facebook.com/lesvassauxdeprovence',20,'{"biCollectionId":"e5e1a5f8-ca83-4ce2-be0d-77eee2038063","teamName":"LES VASSAUX DE PROVENCE","club":null,"gender":"Male","captain":"Guillo Jean Baptiste","conference":"Europe","country":"France","city":"le luc","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Provence-Alpes-Côte d''Azur","name":"Provence-Alpes-Côte d''Azur","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Var","name":"Var","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Les Arcs","name":"Les Arcs","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Les Arcs","location":{"latitude":43.42209739999999,"longitude":6.470134299999999},"streetAddress":{"apt":"","formattedAddressLine":"Les vassaux de provence","name":"quartier riaou roux","number":""},"formatted":"quartier riaou roux, 83460 Les Arcs, France","country":"FR","postalCode":"83460"},"websiteFacebookUrl":"https://www.facebook.com/lesvassauxdeprovence","teamEmail":"crampagnefrancois@gmail.com","teamLogo":"wix:image://v1/c92b71_2c5e7d69920444a7aee220da3bc01118~mv2.jpg/logo%20vassaux.jpg#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/c92b71_2c5e7d69920444a7aee220da3bc01118~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":7}]}},"members":["LELOUP","VAN DYCK Jean-Patrick","Crampagne François","Carpentier Quentin","Guillo Jean Baptiste","Kyllian Setruk","Laval"],"sourceCreatedAt":"2023-09-14T05:53:36.372Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('LES VASSAUX DE PROVENCE',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('le luc',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'crampagnefrancois@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/lesvassauxdeprovence'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c92b71_2c5e7d69920444a7aee220da3bc01118~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LELOUP','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'VAN DYCK Jean-Patrick','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Crampagne François','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carpentier Quentin','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillo Jean Baptiste','captain','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyllian Setruk','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laval','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence','les-vassaux-de-provence',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='les-vassaux-de-provence-' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-les-vassaux-de-provence-' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Les vassaux de Provence ','Les arcs sur Argens ',true,'active','public','bi-les-vassaux-de-provence-','EU','Europe','FR','France','lesvassauxdeprovence@gmail.com',NULL,'https://static.wixstatic.com/media/ea7d5a_e0ebdb72cb41468bb536a6b861fbf1ea~mv2.jpg','Le club des vassaux de Provence se situe en France dans le sud Cette équipe évolue en ligue 2 française')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','les-vassaux-de-provence-','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','Les vassaux de Provence ','Les arcs sur Argens ','lesvassauxdeprovence@gmail.com',NULL,20,'{"biCollectionId":"b8b80fe4-3e22-4ffc-b9ea-c4b3debb442c","teamName":"Les vassaux de Provence ","club":null,"gender":"Male","captain":"Guillo","conference":"Europe","country":"France","city":"Les arcs sur Argens ","teamInfo":"Le club des vassaux de Provence se situe en France dans le sud Cette équipe évolue en ligue 2 française","trainingInfo":"Le club est ouvert au recrutement toute l&#x27;année","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"lesvassauxdeprovence@gmail.com","teamLogo":"wix:image://v1/ea7d5a_e0ebdb72cb41468bb536a6b861fbf1ea~mv2.jpg/IMG-20241119-WA0000.jpg#originWidth=1600&originHeight=1046","logoUrl":"https://static.wixstatic.com/media/ea7d5a_e0ebdb72cb41468bb536a6b861fbf1ea~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":9,"tournaments":[{"_id":"1","points":0,"Tournament":"Torneo Delle Alpi 2025","date":"2025-10-04","category":"5vs5","place":7}]}},"members":["Guillo","Fabre-Teste Charles","Guillo Jean Baptiste","Oriot Wilfried","William Fedeli","Julien VACHER","charpentier quentin","LELOUP","BARBASTE François","Anthony Barachet","Jocelyn Guiraud","Maniveau Sylvain","Anthony Mard","Thomas Alexandre","Quentin Jacob"],"sourceCreatedAt":"2025-03-14T10:26:01.574Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Les vassaux de Provence ',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Les arcs sur Argens ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lesvassauxdeprovence@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ea7d5a_e0ebdb72cb41468bb536a6b861fbf1ea~mv2.jpg'),
 public_description=coalesce(t.public_description,'Le club des vassaux de Provence se situe en France dans le sud Cette équipe évolue en ligue 2 française'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillo','captain','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fabre-Teste Charles','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillo Jean Baptiste','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oriot Wilfried','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Fedeli','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julien VACHER','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'charpentier quentin','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'LELOUP','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BARBASTE François','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anthony Barachet','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jocelyn Guiraud','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maniveau Sylvain','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anthony Mard','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Alexandre','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Quentin Jacob','fighter','bi_teams','https://www.buhurtinternational.com/team/les-vassaux-de-provence-','les-vassaux-de-provence-',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lexington-lycans' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lexington-lycans' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lexington Lycans','Lexington Kentucky',true,'active','public','bi-lexington-lycans','NA','North America','US','United States','brendan1kirwan@gmail.com','https://m.facebook.com/lexingtonlycans?mibextid=LQQJ4d','https://static.wixstatic.com/media/35c6c7_0165b5ca2ace441eb794365174bb4f14~mv2.jpg','We are located in Lexington Kentucky.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lexington-lycans','https://www.buhurtinternational.com/team/lexington-lycans','Lexington Lycans','Lexington Kentucky','brendan1kirwan@gmail.com','https://m.facebook.com/lexingtonlycans?mibextid=LQQJ4d',20,'{"biCollectionId":"065509dc-cf82-4553-96c7-9b6922f46532","teamName":"Lexington Lycans","club":null,"gender":"Male","captain":"Brendan Kirwan","conference":"North America","country":"United States","city":"Lexington Kentucky","teamInfo":"We are located in Lexington Kentucky.","trainingInfo":"You are welcome to come out and try a practice!","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://m.facebook.com/lexingtonlycans?mibextid=LQQJ4d","teamEmail":"brendan1kirwan@gmail.com","teamLogo":"wix:image://v1/35c6c7_0165b5ca2ace441eb794365174bb4f14~mv2.jpg/365017944_1977577305974554_818220603451999272_n.jpg#originWidth=828&originHeight=828","logoUrl":"https://static.wixstatic.com/media/35c6c7_0165b5ca2ace441eb794365174bb4f14~mv2.jpg","rank5v5":15,"averagePoints5v5":1.83,"points5v5":5.5,"rank12v12":null,"points12v12":3,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":7},{"_id":"2","points":1,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":5},{"_id":"3","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":11},{"_id":"4","points":3,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"12vs12","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":5.5,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":12},{"_id":"2","points":1.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":11}]}},"members":["Evan Bullock","David Poff","Joel McClure","Kenzie C Adams","Derek Carpenter","dylan Harring","Michael Harover","Brendan Kirwan","Kevin Stanfield","Tyler Schwartz","Lucas Ball","Jeremiah Holman"],"sourceCreatedAt":"2024-07-30T14:27:32.238Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lexington Lycans',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lexington Kentucky',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'brendan1kirwan@gmail.com'),
 website_url=coalesce(t.website_url,'https://m.facebook.com/lexingtonlycans?mibextid=LQQJ4d'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/35c6c7_0165b5ca2ace441eb794365174bb4f14~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are located in Lexington Kentucky.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan Bullock','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Poff','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joel McClure','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kenzie C Adams','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derek Carpenter','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'dylan Harring','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Harover','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brendan Kirwan','captain','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kevin Stanfield','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Schwartz','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Ball','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeremiah Holman','fighter','bi_teams','https://www.buhurtinternational.com/team/lexington-lycans','lexington-lycans',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lions-of-steel' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lions-of-steel' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lions of steel','liempde',true,'active','public','bi-lions-of-steel','EU','Europe','NL','Netherlands','https://www.facebook.com/LionsofSteel.NL','https://www.facebook.com/LionsofSteel.NL','https://static.wixstatic.com/media/ee3d8b_5afd47c477364d2e9d3bc8ab88c8743d~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lions-of-steel','https://www.buhurtinternational.com/team/lions-of-steel','Lions of steel','liempde','https://www.facebook.com/LionsofSteel.NL','https://www.facebook.com/LionsofSteel.NL',20,'{"biCollectionId":"11d5ab88-575e-4766-981f-c12e430a4ef6","teamName":"Lions of steel","club":null,"gender":"Male","captain":"jona lammert","conference":"Europe","country":"Netherlands","city":"liempde","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/LionsofSteel.NL","teamEmail":"https://www.facebook.com/LionsofSteel.NL","teamLogo":"wix:image://v1/ee3d8b_5afd47c477364d2e9d3bc8ab88c8743d~mv2.png/Untitled_Artwork-1%20(1).png#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/ee3d8b_5afd47c477364d2e9d3bc8ab88c8743d~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":6,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Jan van Brabant 2026","date":"2026-05-16","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":11,"remainingTokens":6,"tournaments":[{"_id":"1","points":11,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":1}]}},"members":["Mike langes","Colin Toonen","Octavian Albu","Evan Mackey","Kai Ahrens","Chris Zonneveld","William Dijkman","David Jung","Jona Lammert","Roy Hoeben","Tarek Léon Mostert","Ivar van elburg","Luc van Beek","Vladyslav Stetsenko","Bart de laat"],"sourceCreatedAt":"2023-08-22T19:54:30.029Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lions of steel',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('liempde',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Netherlands',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'https://www.facebook.com/LionsofSteel.NL'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/LionsofSteel.NL'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ee3d8b_5afd47c477364d2e9d3bc8ab88c8743d~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mike langes','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colin Toonen','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Octavian Albu','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evan Mackey','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kai Ahrens','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris Zonneveld','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Dijkman','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Jung','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jona Lammert','captain','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roy Hoeben','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tarek Léon Mostert','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivar van elburg','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luc van Beek','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vladyslav Stetsenko','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bart de laat','fighter','bi_teams','https://www.buhurtinternational.com/team/lions-of-steel','lions-of-steel',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='livland' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-livland' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'LIVLAND','Riga',true,'active','public','bi-livland','EU','Europe','LV','Latvia','Leonid.feigus@gmail.com','https://t.me/livland_knights','https://static.wixstatic.com/media/d7f343_05ed20215d8744a8bae149d1544165e3~mv2.jpg','LIVLAND! TILL LAST STANDING!!! LIVLAND develops as a community of like-minded people in the Baltic States interested in combat sports, especially Armored Combat. Our fighters charge forward, following the principle of ultimate clash until the last-man-standing with no mercy to ourselves, as to anyone fighting back. INTERNATIONAL ALLIANCE: UNITED LIVLAND UL stands for United Armored Combat Forces of the Baltic States and represents major teams based in Latvia Estonia and Lithuania. We fight together for the victories and development of knights&#x27; sports in every region of the Baltics. We are training regularly. We are working on our tactics. And we are ready for battles!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','livland','https://www.buhurtinternational.com/team/livland','LIVLAND','Riga','Leonid.feigus@gmail.com','https://t.me/livland_knights',20,'{"biCollectionId":"4ce6404e-5ac8-4a64-b934-905e261aef4a","teamName":"LIVLAND","club":"LIVLAND","gender":"Male","captain":"Leonid Feigus","conference":"Europe","country":"Latvia","city":"Riga","teamInfo":"LIVLAND! TILL LAST STANDING!!! LIVLAND develops as a community of like-minded people in the Baltic States interested in combat sports, especially Armored Combat. Our fighters charge forward, following the principle of ultimate clash until the last-man-standing with no mercy to ourselves, as to anyone fighting back. INTERNATIONAL ALLIANCE: UNITED LIVLAND UL stands for United Armored Combat Forces of the Baltic States and represents major teams based in Latvia Estonia and Lithuania. We fight together for the victories and development of knights&#x27; sports in every region of the Baltics. We are training regularly. We are working on our tactics. And we are ready for battles!","trainingInfo":"A basic sports suit is enough to join our training. You are always welcome in any citadel of medieval ultra-violence of the UNITED LIVLAND alliance, located in Riga (LV), and branches in Ogre (LV), Tallinn (EE), Tartu (EE), and Kaunas (LT)! ):D Call +37128857550 (Rhino) to get more information. https://t.me/Leonid_F https://t.me/livland_knights https://www.livlandclub.lv/","trainingLocation":{"subdivisions":[{"code":"Rīga","name":"Rīga","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"LV","name":"Latvia","type":"COUNTRY"}],"city":"Rīga","location":{"latitude":56.9615939,"longitude":24.1517832},"streetAddress":{"apt":"","formattedAddressLine":"Pērnavas iela 25","name":"Pērnavas iela","number":"25"},"formatted":"Pērnavas iela 25, Latgales priekšpilsēta, Rīga, LV-1012, Latvia","country":"LV","postalCode":"1012"},"websiteFacebookUrl":"https://t.me/livland_knights","teamEmail":"Leonid.feigus@gmail.com","teamLogo":"wix:image://v1/d7f343_05ed20215d8744a8bae149d1544165e3~mv2.jpg/TG.jpg#originWidth=900&originHeight=728","logoUrl":"https://static.wixstatic.com/media/d7f343_05ed20215d8744a8bae149d1544165e3~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Leonid Feigus","Aleksandr Marek Pusep","Igors Birjukovs","Aleksejs Resko","Mihails Birjukovs","Arthur Mezetski","Leo Stont","Sergei Starovoitov","Igors Juhta","Vytautas Medzevicius","Dmitri Filatov","Maris Komogorovs","Jevgeni Semenjuk"],"sourceCreatedAt":"2023-09-13T15:36:11.670Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('LIVLAND',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Riga',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('LV',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Latvia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Leonid.feigus@gmail.com'),
 website_url=coalesce(t.website_url,'https://t.me/livland_knights'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d7f343_05ed20215d8744a8bae149d1544165e3~mv2.jpg'),
 public_description=coalesce(t.public_description,'LIVLAND! TILL LAST STANDING!!! LIVLAND develops as a community of like-minded people in the Baltic States interested in combat sports, especially Armored Combat. Our fighters charge forward, following the principle of ultimate clash until the last-man-standing with no mercy to ourselves, as to anyone fighting back. INTERNATIONAL ALLIANCE: UNITED LIVLAND UL stands for United Armored Combat Forces of the Baltic States and represents major teams based in Latvia Estonia and Lithuania. We fight together for the victories and development of knights&#x27; sports in every region of the Baltics. We are training regularly. We are working on our tactics. And we are ready for battles!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonid Feigus','captain','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksandr Marek Pusep','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Igors Birjukovs','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aleksejs Resko','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mihails Birjukovs','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Arthur Mezetski','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leo Stont','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergei Starovoitov','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Igors Juhta','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vytautas Medzevicius','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dmitri Filatov','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maris Komogorovs','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jevgeni Semenjuk','fighter','bi_teams','https://www.buhurtinternational.com/team/livland','livland',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='loc-mor-kelpies' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-loc-mor-kelpies' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Loc Mor Kelpies','Grand Rapids',true,'active','public','bi-loc-mor-kelpies','NA','North America','US','United States','bradeefsting@yahoo.com','https://www.facebook.com/share/1Be79DAEyB/','https://static.wixstatic.com/media/0ce184_fe9f0819a8824b4795a0d48d880ec7ae~mv2.jpeg','Located in Grand Rapids, MI. We are a buhurt fighting team that participates in mens 5v5, 3v3, 12v12 and mercenary for Knyaz Fire when able. Many fighters are awaiting BI/MCUSA registration/armor photos to be approved to be added to the roster.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','loc-mor-kelpies','https://www.buhurtinternational.com/team/loc-mor-kelpies','Loc Mor Kelpies','Grand Rapids','bradeefsting@yahoo.com','https://www.facebook.com/share/1Be79DAEyB/',20,'{"biCollectionId":"46b78444-e250-4d2b-935a-7a76ba265809","teamName":"Loc Mor Kelpies","club":null,"gender":"Male","captain":"Bradley Eefsting","conference":"North America","country":"United States","city":"Grand Rapids","teamInfo":"Located in Grand Rapids, MI. We are a buhurt fighting team that participates in mens 5v5, 3v3, 12v12 and mercenary for Knyaz Fire when able. Many fighters are awaiting BI/MCUSA registration/armor photos to be approved to be added to the roster.","trainingInfo":"Typical gym gear and motovation. Water is available on site. fighter registration isnt due till fully commited to the sport.","trainingLocation":{"subdivisions":[{"code":"MI","name":"Michigan","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Kent County","name":"Kent County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Rockford","name":"Rockford","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Rockford","location":{"latitude":43.1200272,"longitude":-85.5600316},"streetAddress":{"apt":"","formattedAddressLine":"Rockford","name":"","number":""},"formatted":"Rockford, MI, USA","country":"US","subdivision":"MI"},"websiteFacebookUrl":"https://www.facebook.com/share/1Be79DAEyB/","teamEmail":"bradeefsting@yahoo.com","teamLogo":"wix:image://v1/0ce184_fe9f0819a8824b4795a0d48d880ec7ae~mv2.jpeg/loc%20Mor%20Kelpies.jpeg#originWidth=720&originHeight=740","logoUrl":"https://static.wixstatic.com/media/0ce184_fe9f0819a8824b4795a0d48d880ec7ae~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Bradley Eefsting","Taylor Brandt","Jerrod Roberts","Preston Locklear","Michael Piontek","Benjamin VanHeest","Evangalene Dreyer","Andrew Leemputte"],"sourceCreatedAt":"2026-07-07T18:37:23.726Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Loc Mor Kelpies',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Grand Rapids',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bradeefsting@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1Be79DAEyB/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/0ce184_fe9f0819a8824b4795a0d48d880ec7ae~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Located in Grand Rapids, MI. We are a buhurt fighting team that participates in mens 5v5, 3v3, 12v12 and mercenary for Knyaz Fire when able. Many fighters are awaiting BI/MCUSA registration/armor photos to be approved to be added to the roster.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bradley Eefsting','captain','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taylor Brandt','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerrod Roberts','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Preston Locklear','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Piontek','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benjamin VanHeest','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evangalene Dreyer','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Leemputte','fighter','bi_teams','https://www.buhurtinternational.com/team/loc-mor-kelpies','loc-mor-kelpies',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='los-angeles-gilded-blades' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-los-angeles-gilded-blades' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Los Angeles Gilded Blades',NULL,true,'active','public','bi-los-angeles-gilded-blades','NA','North America','US','United States','jason@lagoldenknights.com',NULL,'https://static.wixstatic.com/media/823451_ed8f7181184748bebb5a543d7c365290~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','los-angeles-gilded-blades','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','Los Angeles Gilded Blades',NULL,'jason@lagoldenknights.com',NULL,20,'{"biCollectionId":"7828d1a6-d964-41b8-a489-4b9f33e66604","teamName":"Los Angeles Gilded Blades","club":null,"gender":"Female","captain":"Maryam Sefati","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"jason@lagoldenknights.com","teamLogo":"wix:image://v1/823451_ed8f7181184748bebb5a543d7c365290~mv2.png/gildedblade_heraldry_finalA.png#originWidth=4202&originHeight=4202","logoUrl":"https://static.wixstatic.com/media/823451_ed8f7181184748bebb5a543d7c365290~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":4},{"_id":"2","points":0,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"3vs3","place":4}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":8}},"members":["Maryam Sefati","Maryam  Sefati","Shanti Rittgers","Delaney Januzzi","Madeleine Flores"],"sourceCreatedAt":"2025-08-15T01:58:52.842Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Los Angeles Gilded Blades',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jason@lagoldenknights.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/823451_ed8f7181184748bebb5a543d7c365290~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maryam Sefati','captain','bi_teams','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','los-angeles-gilded-blades',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maryam  Sefati','fighter','bi_teams','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','los-angeles-gilded-blades',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shanti Rittgers','fighter','bi_teams','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','los-angeles-gilded-blades',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Delaney Januzzi','fighter','bi_teams','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','los-angeles-gilded-blades',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Madeleine Flores','fighter','bi_teams','https://www.buhurtinternational.com/team/los-angeles-gilded-blades','los-angeles-gilded-blades',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lotharii-regnum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lotharii-regnum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lotharii Regnum','Hauconcourt (57)',true,'active','public','bi-lotharii-regnum','EU','Europe','FR','France','lotharii.regnum57@gmail.com','https://lotharii-regnum.com/','https://static.wixstatic.com/media/c9ecfa_b5f6314f79b941dab18d616c418c064b~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lotharii-regnum','https://www.buhurtinternational.com/team/lotharii-regnum','Lotharii Regnum','Hauconcourt (57)','lotharii.regnum57@gmail.com','https://lotharii-regnum.com/',20,'{"biCollectionId":"3c374e04-fd53-477e-887a-041c1e12cefd","teamName":"Lotharii Regnum","club":null,"gender":"Male","captain":"HOMBOURGER Benjamin","conference":"Europe","country":"France","city":"Hauconcourt (57)","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"Rue de la Grande Rayée, Hauconcourt"},"websiteFacebookUrl":"https://lotharii-regnum.com/","teamEmail":"lotharii.regnum57@gmail.com","teamLogo":"wix:image://v1/c9ecfa_b5f6314f79b941dab18d616c418c064b~mv2.jpeg/IMG_3673.jpeg#originWidth=1886&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/c9ecfa_b5f6314f79b941dab18d616c418c064b~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":6,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Jacoba van Beieren 2025","date":"2025-04-19","category":"5vs5","place":4},{"_id":"2","points":4,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":4}]}},"members":["HOMBOURGER Benjamin","Florian DI TERLIZZI","PERERA","GORZYNSKI Mathieu","Loïc Sauvage","Ahmed Tazen","Valentin Wiest","Thomas Vuillaume","Geronimus allan","Guillaume BRION","Adrien ROUSSEL-CIPCIA","GOGOLKIEWICZ Cedric","BETKER MAXIMILIEN","Cédric PINATO","Florian ERSFELD"],"sourceCreatedAt":"2024-06-30T21:38:30.464Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lotharii Regnum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hauconcourt (57)',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lotharii.regnum57@gmail.com'),
 website_url=coalesce(t.website_url,'https://lotharii-regnum.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c9ecfa_b5f6314f79b941dab18d616c418c064b~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'HOMBOURGER Benjamin','captain','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Florian DI TERLIZZI','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'PERERA','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GORZYNSKI Mathieu','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Loïc Sauvage','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ahmed Tazen','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valentin Wiest','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Vuillaume','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Geronimus allan','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Guillaume BRION','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrien ROUSSEL-CIPCIA','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GOGOLKIEWICZ Cedric','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'BETKER MAXIMILIEN','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cédric PINATO','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Florian ERSFELD','fighter','bi_teams','https://www.buhurtinternational.com/team/lotharii-regnum','lotharii-regnum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='louisville-royals' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-louisville-royals' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Louisville Royals','Louisville',true,'active','public','bi-louisville-royals','NA','North America','US','United States','edofusaro98@gmail.com','https://www.facebook.com/louisvilleroyalsarmoredcombatteam','https://static.wixstatic.com/media/41f9c8_8a9fdd7de8d9423da8a2af75383a1b6f~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','louisville-royals','https://www.buhurtinternational.com/team/louisville-royals','Louisville Royals','Louisville','edofusaro98@gmail.com','https://www.facebook.com/louisvilleroyalsarmoredcombatteam',20,'{"biCollectionId":"bda8fb62-1b59-4ecc-9262-ed31a94b4265","teamName":"Louisville Royals","club":null,"gender":"Male","captain":"Dakota Walker","conference":"North America","country":"United States","city":"Louisville","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/louisvilleroyalsarmoredcombatteam","teamEmail":"edofusaro98@gmail.com","teamLogo":"wix:image://v1/41f9c8_8a9fdd7de8d9423da8a2af75383a1b6f~mv2.jpg/477776813_630582022853447_6682594675988100274_n.jpg#originWidth=956&originHeight=960","logoUrl":"https://static.wixstatic.com/media/41f9c8_8a9fdd7de8d9423da8a2af75383a1b6f~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":4}],"eventsHistory":{},"members":["Dakota Walker","Matt Dodsworth","Mercutio foxhill","Braxton Bushnell","John Maurice Roution Jr.","Sean Sutton","Michael Godfrey","Amanda Godfrey"],"sourceCreatedAt":"2026-01-20T00:04:46.582Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Louisville Royals',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Louisville',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'edofusaro98@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/louisvilleroyalsarmoredcombatteam'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/41f9c8_8a9fdd7de8d9423da8a2af75383a1b6f~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dakota Walker','captain','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matt Dodsworth','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mercutio foxhill','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Braxton Bushnell','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Maurice Roution Jr.','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Sutton','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Godfrey','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Amanda Godfrey','fighter','bi_teams','https://www.buhurtinternational.com/team/louisville-royals','louisville-royals',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lowland-boars' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lowland-boars' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lowland Boars','Szolnok, Szeged',true,'active','public','bi-lowland-boars','EU','Europe','HU','Hungary','vezetoseg.lowland@gmail.com','https://www.facebook.com/lowlandboars','https://static.wixstatic.com/media/6a370c_1b257a393feb4cf5905186b30a92ae67~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lowland-boars','https://www.buhurtinternational.com/team/lowland-boars','Lowland Boars','Szolnok, Szeged','vezetoseg.lowland@gmail.com','https://www.facebook.com/lowlandboars',20,'{"biCollectionId":"9aadf681-84f5-4703-81dd-e7cc57c23109","teamName":"Lowland Boars","club":null,"gender":"Male","captain":"Martin Kovál","conference":"Europe","country":"Hungary","city":"Szolnok, Szeged","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/lowlandboars","teamEmail":"vezetoseg.lowland@gmail.com","teamLogo":"wix:image://v1/6a370c_1b257a393feb4cf5905186b30a92ae67~mv2.jpg/93859012_107472684267258_9085628943863644160_n.jpg#originWidth=320&originHeight=320","logoUrl":"https://static.wixstatic.com/media/6a370c_1b257a393feb4cf5905186b30a92ae67~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":12,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":5},{"_id":"2","points":10,"Tournament":"Valley of Warriors Buhurt Tournament 2026","date":"2026-06-06","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":4},{"_id":"2","points":1,"Tournament":"King Kazimierz Cup 2024","date":45528,"category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["István Szolnoki","Dr. Ferenczi Gábor","István Kucser","Orvendi Tibor","Zsolt Kendrei","Rapp László","Martin Kovál","Farkas Gábor"],"sourceCreatedAt":"2023-08-29T20:25:33.837Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lowland Boars',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Szolnok, Szeged',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('HU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Hungary',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'vezetoseg.lowland@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/lowlandboars'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6a370c_1b257a393feb4cf5905186b30a92ae67~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'István Szolnoki','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dr. Ferenczi Gábor','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'István Kucser','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Orvendi Tibor','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zsolt Kendrei','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rapp László','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Kovál','captain','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Farkas Gábor','fighter','bi_teams','https://www.buhurtinternational.com/team/lowland-boars','lowland-boars',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lupus-fratum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lupus-fratum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lupus Fratum','Lyon',true,'active','public','bi-lupus-fratum','EU','Europe','FR','France','swanncecillon5@gmail.com',NULL,'https://static.wixstatic.com/media/95aff8_600216fdfc4f4d0da8d8d3e7e92912c4~mv2.jpeg','2nd team of La Confrerie des Loups')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lupus-fratum','https://www.buhurtinternational.com/team/lupus-fratum','Lupus Fratum','Lyon','swanncecillon5@gmail.com',NULL,20,'{"biCollectionId":"54591693-74cd-41a9-8550-a7309fa81dc6","teamName":"Lupus Fratum","club":null,"gender":"Male","captain":"Swann Cecillon","conference":"Europe","country":"France","city":"Lyon","teamInfo":"2nd team of La Confrerie des Loups","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"swanncecillon5@gmail.com","teamLogo":"wix:image://v1/95aff8_600216fdfc4f4d0da8d8d3e7e92912c4~mv2.jpeg/IMG_0508.jpeg#originWidth=1318&originHeight=847","logoUrl":"https://static.wixstatic.com/media/95aff8_600216fdfc4f4d0da8d8d3e7e92912c4~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":5}]},"2025":{"remainingTokens":9}},"members":["Swann Cecillon","Vincent Courivaud","Adrien Pastorello","Gabriel CHEVALIER","Vincent RADZIEJEWSKI","Jérémy robert-maciocia"],"sourceCreatedAt":"2024-10-11T13:51:54.688Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lupus Fratum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lyon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'swanncecillon5@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/95aff8_600216fdfc4f4d0da8d8d3e7e92912c4~mv2.jpeg'),
 public_description=coalesce(t.public_description,'2nd team of La Confrerie des Loups'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Swann Cecillon','captain','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Courivaud','fighter','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrien Pastorello','fighter','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel CHEVALIER','fighter','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent RADZIEJEWSKI','fighter','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jérémy robert-maciocia','fighter','bi_teams','https://www.buhurtinternational.com/team/lupus-fratum','lupus-fratum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lusitania' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lusitania' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lusitania',NULL,true,'active','public','bi-lusitania','EU','Europe','PT','Portugal','apcombatemedieval@gmail.com',NULL,'https://static.wixstatic.com/media/8b735a_55c0db88d783437f8d79e44027002eb2~mv2.png','Band of mercenaries from various portuguese teams')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lusitania','https://www.buhurtinternational.com/team/lusitania','Lusitania',NULL,'apcombatemedieval@gmail.com',NULL,20,'{"biCollectionId":"2b62aa47-cc68-4017-88a5-414840d4d94f","teamName":"Lusitania","club":null,"gender":"Male","captain":null,"conference":"Europe","country":"Portugal","city":null,"teamInfo":"Band of mercenaries from various portuguese teams","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"apcombatemedieval@gmail.com","teamLogo":"wix:image://v1/8b735a_55c0db88d783437f8d79e44027002eb2~mv2.png/Flag_of_the_Kingdom_of_Portugal_(1385%E2%80%931485).png#originWidth=750&originHeight=750","logoUrl":"https://static.wixstatic.com/media/8b735a_55c0db88d783437f8d79e44027002eb2~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":2,"tournaments":[{"_id":"1","points":0,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":8}]}},"members":[],"sourceCreatedAt":"2025-07-08T14:52:38.313Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lusitania',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Portugal',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'apcombatemedieval@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8b735a_55c0db88d783437f8d79e44027002eb2~mv2.png'),
 public_description=coalesce(t.public_description,'Band of mercenaries from various portuguese teams'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';

end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='lwy-lublin' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-lwy-lublin' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Lwy Lublin','Lublin',true,'active','public','bi-lwy-lublin','EU','Europe','PL','Poland','m.wierzchowski@prawnik-zamosc.pl','https://www.facebook.com/LWY.LUBLIN','https://static.wixstatic.com/media/7d0aea_4cf9743fa478415cb66b827d14785d2a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','lwy-lublin','https://www.buhurtinternational.com/team/lwy-lublin','Lwy Lublin','Lublin','m.wierzchowski@prawnik-zamosc.pl','https://www.facebook.com/LWY.LUBLIN',20,'{"biCollectionId":"cb7dc1e3-641b-4525-975c-bcea5f87352f","teamName":"Lwy Lublin","club":null,"gender":"Male","captain":"Michał Wierzchowski","conference":"Europe","country":"Poland","city":"Lublin","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/LWY.LUBLIN","teamEmail":"m.wierzchowski@prawnik-zamosc.pl","teamLogo":"wix:image://v1/7d0aea_4cf9743fa478415cb66b827d14785d2a~mv2.png/lwy.png#originWidth=567&originHeight=567","logoUrl":"https://static.wixstatic.com/media/7d0aea_4cf9743fa478415cb66b827d14785d2a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":8,"tournaments":[{"_id":"1","points":10,"Tournament":"King Kazimierz Cup 2025","date":"2025-08-16","category":"5vs5","place":2}]}},"members":["Michał Wierzchowski","Adrian Siembida","Damian Woliński","Paweł Jardzioch","Bartłomiej Sieradzki","Mateusz  Macierzyński","Jakub Szłapka","Maciej Wikira","Filip Homeja"],"sourceCreatedAt":"2023-07-24T12:59:07.648Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Lwy Lublin',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lublin',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PL',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Poland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'m.wierzchowski@prawnik-zamosc.pl'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/LWY.LUBLIN'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7d0aea_4cf9743fa478415cb66b827d14785d2a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michał Wierzchowski','captain','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Siembida','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damian Woliński','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paweł Jardzioch','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bartłomiej Sieradzki','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mateusz  Macierzyński','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Szłapka','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maciej Wikira','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Filip Homeja','fighter','bi_teams','https://www.buhurtinternational.com/team/lwy-lublin','lwy-lublin',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mace-company' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mace-company' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Mace Company','Winnipeg',true,'active','public','bi-mace-company','NA','North America','CA','Canada','macecompanymanitoba@gmail.com','https://www.macecompany.ca','https://static.wixstatic.com/media/2d1c8d_9ee6fb47ab2d4a989bd15f778d81fe38~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mace-company','https://www.buhurtinternational.com/team/mace-company','Mace Company','Winnipeg','macecompanymanitoba@gmail.com','https://www.macecompany.ca',20,'{"biCollectionId":"f37de38b-f2da-463f-b739-d137f36e50f9","teamName":"Mace Company","club":null,"gender":"Male","captain":"Julian Kresz","conference":"North America","country":"Canada","city":"Winnipeg","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.macecompany.ca","teamEmail":"macecompanymanitoba@gmail.com","teamLogo":"wix:image://v1/2d1c8d_9ee6fb47ab2d4a989bd15f778d81fe38~mv2.png/TeamEmblem.png#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/2d1c8d_9ee6fb47ab2d4a989bd15f778d81fe38~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Julian Kresz","Tylor Prather"],"sourceCreatedAt":"2026-07-29T20:59:55.859Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Mace Company',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Winnipeg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'macecompanymanitoba@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.macecompany.ca'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2d1c8d_9ee6fb47ab2d4a989bd15f778d81fe38~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Kresz','captain','bi_teams','https://www.buhurtinternational.com/team/mace-company','mace-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tylor Prather','fighter','bi_teams','https://www.buhurtinternational.com/team/mace-company','mace-company',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mamánci' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mamánci' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Mamánci','České Budějovice',true,'active','public','bi-mamánci','EU','Europe','CZ','Czech Republic','Pechvo@seznam.cz','https://www.facebook.com/groups/202111615089037/?ref=share_group_link','https://static.wixstatic.com/media/70b37f_c4be5f5039bb467d9ad279c888975779~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mamánci','https://www.buhurtinternational.com/team/mam%C3%A1nci','Mamánci','České Budějovice','Pechvo@seznam.cz','https://www.facebook.com/groups/202111615089037/?ref=share_group_link',20,'{"biCollectionId":"f9e92e3a-e3ea-4b1d-b01c-382d0b0df1c7","teamName":"Mamánci","club":null,"gender":"Male","captain":"Vojtěch Pecha","conference":"Europe","country":"Czech Republic","city":"České Budějovice","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/202111615089037/?ref=share_group_link","teamEmail":"Pechvo@seznam.cz","teamLogo":"wix:image://v1/70b37f_c4be5f5039bb467d9ad279c888975779~mv2.jpg/page_1.jpg#originWidth=1190&originHeight=1682","logoUrl":"https://static.wixstatic.com/media/70b37f_c4be5f5039bb467d9ad279c888975779~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":24,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":10,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":2},{"_id":"2","points":14,"Tournament":"Gabreta Combat Tournament 2026","date":"2026-05-09","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":11,"Tournament":"Tournament of Visegrád 2024","date":"2024-07-12","category":"5vs5","place":2},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":14,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":1},{"_id":"2","points":1,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":7},{"_id":"3","points":14,"Tournament":"King Kazimierz Cup 2025","date":"2025-08-16","category":"5vs5","place":1},{"_id":"4","points":12,"Tournament":"IV. Veszprém Medieval Day 2025","date":"2025-10-11","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":13.33,"rank5v5":2,"remainingTokens":9,"points5v5":41}},"members":["Vojtěch Pecha","Filip Zimandl","Matěj Eliáš","Richard Štěpánek","Michal Rottner","Radek Sova","Tomás Kramar","Daniel Hajný","Jakub Jinda","Jakub Slavoj Musílek","Jiří Reindl","JAN SNEBERK","Dušan Buček","Jan Mráz","Michal Kašpárek","Matous Petrik","Thomas Brian Wolf"],"sourceCreatedAt":"2023-07-26T06:10:27.095Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Mamánci',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('České Budějovice',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Pechvo@seznam.cz'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/202111615089037/?ref=share_group_link'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/70b37f_c4be5f5039bb467d9ad279c888975779~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vojtěch Pecha','captain','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Filip Zimandl','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matěj Eliáš','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Štěpánek','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michal Rottner','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Radek Sova','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tomás Kramar','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Hajný','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Jinda','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jakub Slavoj Musílek','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jiří Reindl','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JAN SNEBERK','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dušan Buček','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Mráz','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michal Kašpárek','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matous Petrik','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Brian Wolf','fighter','bi_teams','https://www.buhurtinternational.com/team/mam%C3%A1nci','mamánci',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='mamutes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-mamutes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Mamutes','Rio de Janeiro',true,'active','public','bi-mamutes','SA','South America','BR','Brazil','victerlucas@gmail.com','https://www.instagram.com/mamutes_rj/','https://static.wixstatic.com/media/592f72_0862668c6b974926960541e99233c577~mv2.jpeg','Com a Fortitude do Mamute e o charme do Rio de Janeiro, viemos pra viajar e lutar pelo mundo inteiro! With Mammoth fortitude and Rio de Janeiro&#x27;s charm, we came to travel and fight the whole world!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','mamutes','https://www.buhurtinternational.com/team/mamutes','Mamutes','Rio de Janeiro','victerlucas@gmail.com','https://www.instagram.com/mamutes_rj/',20,'{"biCollectionId":"9d9623ca-d127-4173-986b-e6d5b781b03f","teamName":"Mamutes","club":null,"gender":"Male","captain":"Lucas Victer","conference":"South America","country":"Brazil","city":"Rio de Janeiro","teamInfo":"Com a Fortitude do Mamute e o charme do Rio de Janeiro, viemos pra viajar e lutar pelo mundo inteiro! With Mammoth fortitude and Rio de Janeiro&#x27;s charm, we came to travel and fight the whole world!","trainingInfo":"https://www.instagram.com/mamutes_rj/ Fale conosco pelo insta e vem treinar To practice with us, send dm on instagram aboce","trainingLocation":null,"websiteFacebookUrl":"https://www.instagram.com/mamutes_rj/","teamEmail":"victerlucas@gmail.com","teamLogo":"wix:image://v1/592f72_0862668c6b974926960541e99233c577~mv2.jpeg/Mamutes.jpeg#originWidth=1080&originHeight=1357","logoUrl":"https://static.wixstatic.com/media/592f72_0862668c6b974926960541e99233c577~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Lucas Victer","Luís \"Luisão\" Kopezynski","Gustavo de Mello Pereira Abrantes","Felipe Ayorsa","Gabriel \"Governador\" Blasi Franklin de Sá","Valmir \"Hazyel\" da Silva","Henrique Franklin"],"sourceCreatedAt":"2025-03-07T20:18:03.656Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Mamutes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Rio de Janeiro',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Brazil',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'victerlucas@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/mamutes_rj/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/592f72_0862668c6b974926960541e99233c577~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Com a Fortitude do Mamute e o charme do Rio de Janeiro, viemos pra viajar e lutar pelo mundo inteiro! With Mammoth fortitude and Rio de Janeiro&#x27;s charm, we came to travel and fight the whole world!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucas Victer','captain','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luís "Luisão" Kopezynski','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gustavo de Mello Pereira Abrantes','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Felipe Ayorsa','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel "Governador" Blasi Franklin de Sá','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valmir "Hazyel" da Silva','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henrique Franklin','fighter','bi_teams','https://www.buhurtinternational.com/team/mamutes','mamutes',now());
end $$;
commit;
