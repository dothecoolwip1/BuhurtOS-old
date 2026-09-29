begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='born' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-born' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'BORN','Barcelona',true,'active','public','bi-born','EU','Europe','ES','Spain','borncombatmedieval@gmail.com','https://www.facebook.com/borncombatmedieval/?locale=es_ES','https://static.wixstatic.com/media/d86426_37b33eea606c482c8bb0755331f4ee9a~mv2.png','Buhurt team based in Barcelona.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','born','https://www.buhurtinternational.com/team/born','BORN','Barcelona','borncombatmedieval@gmail.com','https://www.facebook.com/borncombatmedieval/?locale=es_ES',20,'{"biCollectionId":"972a0194-20ef-4084-bb4a-bca6f2c36715","teamName":"BORN","club":"Born Combat Medieval","gender":"Male","captain":"Marcos Leal Lopez","conference":"Europe","country":"Spain","city":"Barcelona","teamInfo":"Buhurt team based in Barcelona.","trainingInfo":"","trainingLocation":{"city":"Barcelona","location":{"latitude":41.4161747,"longitude":2.1763619},"streetAddress":{"apt":"","formattedAddressLine":"Passatge de Flaugier, 52","name":"Passatge de Flaugier","number":"52"},"formatted":"Passatge de Flaugier, 52, 08041 Barcelona, Spain","country":"ES","postalCode":"08041","subdivision":"CT"},"websiteFacebookUrl":"https://www.facebook.com/borncombatmedieval/?locale=es_ES","teamEmail":"borncombatmedieval@gmail.com","teamLogo":"wix:image://v1/d86426_37b33eea606c482c8bb0755331f4ee9a~mv2.png/logo%20born%20modified.png#originWidth=4825&originHeight=4825","logoUrl":"https://static.wixstatic.com/media/d86426_37b33eea606c482c8bb0755331f4ee9a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Marcos Leal Lopez","Ignasi","Artem Badanin Drobot","Oriol Vilellas Tena","Lucio Guil","Christian Torcal","Didac Vargas Amengual","Alberto Muñoz Martinez","Daniel Fernandez Sanvisens","Cristian Bernal Ruiz"],"sourceCreatedAt":"2023-10-28T12:53:39.807Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('BORN',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Barcelona',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'borncombatmedieval@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/borncombatmedieval/?locale=es_ES'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d86426_37b33eea606c482c8bb0755331f4ee9a~mv2.png'),
 public_description=coalesce(t.public_description,'Buhurt team based in Barcelona.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Leal Lopez','captain','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ignasi','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Artem Badanin Drobot','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Oriol Vilellas Tena','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lucio Guil','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christian Torcal','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Didac Vargas Amengual','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Muñoz Martinez','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Fernandez Sanvisens','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cristian Bernal Ruiz','fighter','bi_teams','https://www.buhurtinternational.com/team/born','born',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='broderskabet-sons-of-haddock' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-broderskabet-sons-of-haddock' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Broderskabet Sons of Haddock','videbæk',true,'active','public','bi-broderskabet-sons-of-haddock','EU','Europe','DK','Denmark','hfomsgaard@live.dk','https://broderskabet.webnode.dk','https://static.wixstatic.com/media/3e81db_76719d7f930e421f923c3de456373a37~mv2.png','Buhurt fight club Broderskabet belongs to West Jutland, it has existed since 2013. The club consists of 12 fighters who train every Thursday. We train both in soft Combat equipment and in full armour. We have an indoor track, and we have an outdoor track, plus we have a Clubhouse where we can get our armor repaired when it breaks. In our premises there is a strength center where people can keep fit with weights and treadmills. When we go out and fight in tournaments we call ourselves the Sons of Haddock.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','broderskabet-sons-of-haddock','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','Broderskabet Sons of Haddock','videbæk','hfomsgaard@live.dk','https://broderskabet.webnode.dk',20,'{"biCollectionId":"51f94c31-c555-47ee-a7ee-80db1667bd49","teamName":"Broderskabet Sons of Haddock","club":null,"gender":"Male","captain":"Andreas Fomagaard","conference":"Europe","country":"Denmark","city":"videbæk","teamInfo":"Buhurt fight club Broderskabet belongs to West Jutland, it has existed since 2013. The club consists of 12 fighters who train every Thursday. We train both in soft Combat equipment and in full armour. We have an indoor track, and we have an outdoor track, plus we have a Clubhouse where we can get our armor repaired when it breaks. In our premises there is a strength center where people can keep fit with weights and treadmills. When we go out and fight in tournaments we call ourselves the Sons of Haddock.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Videbæk","name":"Videbæk","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"DK","name":"Denmark","type":"COUNTRY"}],"city":"Videbæk","location":{"latitude":56.065397,"longitude":8.5951402},"streetAddress":{"apt":"","formattedAddressLine":"Genforeningsvej 12","name":"Genforeningsvej","number":"12"},"formatted":"Genforeningsvej 12, 6920 Videbæk, Denmark","country":"DK","postalCode":"6920"},"websiteFacebookUrl":"https://broderskabet.webnode.dk","teamEmail":"hfomsgaard@live.dk","teamLogo":"wix:image://v1/3e81db_76719d7f930e421f923c3de456373a37~mv2.png/logo.png#originWidth=800&originHeight=1000","logoUrl":"https://static.wixstatic.com/media/3e81db_76719d7f930e421f923c3de456373a37~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":7}]},"2025":{"remainingTokens":10}},"members":["Andreas Fomagaard","Andreas Fomsgaard","Henrik Fomsgaard","Brian Dahl Buskbjerg","Mikkel Brøndum Sørensen","morten kæseler skoubo","Emil Sand-Jensen","Thomas Jørgensen","Benas Levulis","Valdemar Kongsgaard Espersen","Daniel Bendtsen Madsen"],"sourceCreatedAt":"2024-04-12T17:24:24.692Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Broderskabet Sons of Haddock',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('videbæk',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DK',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Denmark',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'hfomsgaard@live.dk'),
 website_url=coalesce(t.website_url,'https://broderskabet.webnode.dk'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3e81db_76719d7f930e421f923c3de456373a37~mv2.png'),
 public_description=coalesce(t.public_description,'Buhurt fight club Broderskabet belongs to West Jutland, it has existed since 2013. The club consists of 12 fighters who train every Thursday. We train both in soft Combat equipment and in full armour. We have an indoor track, and we have an outdoor track, plus we have a Clubhouse where we can get our armor repaired when it breaks. In our premises there is a strength center where people can keep fit with weights and treadmills. When we go out and fight in tournaments we call ourselves the Sons of Haddock.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas Fomagaard','captain','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andreas Fomsgaard','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henrik Fomsgaard','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Dahl Buskbjerg','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mikkel Brøndum Sørensen','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'morten kæseler skoubo','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emil Sand-Jensen','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Jørgensen','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Benas Levulis','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Valdemar Kongsgaard Espersen','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Bendtsen Madsen','fighter','bi_teams','https://www.buhurtinternational.com/team/broderskabet-sons-of-haddock','broderskabet-sons-of-haddock',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='brown-bear-company' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-brown-bear-company' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Brown Bear Company','Bucharest',true,'active','public','bi-brown-bear-company','EU','Europe','RO','Romania','vadrian.nicolae@gmail.com','https://www.facebook.com/CompaniaUrsuluiBrun','https://static.wixstatic.com/media/a80a04_b13d960f8c914c6190bb3a3904989876~mv2.jpeg','Buhurt team from Bucharest.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','brown-bear-company','https://www.buhurtinternational.com/team/brown-bear-company','Brown Bear Company','Bucharest','vadrian.nicolae@gmail.com','https://www.facebook.com/CompaniaUrsuluiBrun',20,'{"biCollectionId":"08a5e94f-bb1e-4d8b-b544-1cd3eb12c74b","teamName":"Brown Bear Company","club":null,"gender":"Male","captain":"Adrian Vlad Nicolae","conference":"Europe","country":"Romania","city":"Bucharest","teamInfo":"Buhurt team from Bucharest.","trainingInfo":"Contact on Facebook.","trainingLocation":{"subdivisions":[{"code":"Bucharest","name":"Bucharest","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Bucharest","name":"Bucharest","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Bucharest","name":"Bucharest","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"RO","name":"Romania","type":"COUNTRY"}],"city":"Bucharest","location":{"latitude":44.4267674,"longitude":26.1025384},"streetAddress":{"apt":"","formattedAddressLine":"Bucharest","name":"","number":""},"formatted":"Bucharest, Romania","country":"RO"},"websiteFacebookUrl":"https://www.facebook.com/CompaniaUrsuluiBrun","teamEmail":"vadrian.nicolae@gmail.com","teamLogo":"wix:image://v1/a80a04_b13d960f8c914c6190bb3a3904989876~mv2.jpeg/cub%20logo.jpeg#originWidth=1600&originHeight=1600","logoUrl":"https://static.wixstatic.com/media/a80a04_b13d960f8c914c6190bb3a3904989876~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Adrian Vlad Nicolae","Dumitru Andrei Vlad"],"sourceCreatedAt":"2026-06-12T18:54:15.045Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Brown Bear Company',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Bucharest',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('RO',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Romania',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'vadrian.nicolae@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/CompaniaUrsuluiBrun'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a80a04_b13d960f8c914c6190bb3a3904989876~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Buhurt team from Bucharest.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Vlad Nicolae','captain','bi_teams','https://www.buhurtinternational.com/team/brown-bear-company','brown-bear-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dumitru Andrei Vlad','fighter','bi_teams','https://www.buhurtinternational.com/team/brown-bear-company','brown-bear-company',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='canberra-burly-griffins' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-canberra-burly-griffins' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Canberra Burly Griffins','Canberra',true,'active','public','bi-canberra-burly-griffins','OC','Oceania','AU','Australia','canberraburlygriffins@gmail.com','https://www.facebook.com/profile.php?id=61550867214791','https://static.wixstatic.com/media/ecb458_8b47317e3a6345aea58a17f2318f80f0~mv2.png','The Burly Griffins are the Australian capitols first Buhurt team. We were established in 2023 and are open to all members from Canberra and surrounding areas.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','canberra-burly-griffins','https://www.buhurtinternational.com/team/canberra-burly-griffins','Canberra Burly Griffins','Canberra','canberraburlygriffins@gmail.com','https://www.facebook.com/profile.php?id=61550867214791',20,'{"biCollectionId":"6b1d628e-1dc3-4727-866b-41fd419e00f3","teamName":"Canberra Burly Griffins","club":null,"gender":"Male","captain":"Bryce Lightbody","conference":"APAC","country":"Australia","city":"Canberra","teamInfo":"The Burly Griffins are the Australian capitols first Buhurt team. We were established in 2023 and are open to all members from Canberra and surrounding areas.","trainingInfo":"All new recruits are welcome. Loaner kit will be provided so interested people don&#x27;t need anything except themselves to get started.","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61550867214791","teamEmail":"canberraburlygriffins@gmail.com","teamLogo":"wix:image://v1/ecb458_8b47317e3a6345aea58a17f2318f80f0~mv2.png/CBG%20-%20Frame.png#originWidth=10833&originHeight=10833","logoUrl":"https://static.wixstatic.com/media/ecb458_8b47317e3a6345aea58a17f2318f80f0~mv2.png","rank5v5":8,"averagePoints5v5":1.67,"points5v5":5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":6},{"_id":"2","points":1,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":11},{"_id":"3","points":1,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":9}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":8},{"_id":"2","points":4,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":4},{"_id":"3","points":24,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":1}],"points12v12":0,"averagePoints5v5":10,"rank5v5":2,"remainingTokens":4,"points5v5":30}},"members":["Bryce Lightbody","Simon Robert Cornish","Jackson Millers","Thomas Dixon","Jackson Wark","Sean Cannon","MICHAEL ROBINSON","Daniel Grant","Max convey","Ben Labudda","William Thomson"],"sourceCreatedAt":"2025-05-07T11:17:42.413Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Canberra Burly Griffins',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Canberra',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'canberraburlygriffins@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61550867214791'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ecb458_8b47317e3a6345aea58a17f2318f80f0~mv2.png'),
 public_description=coalesce(t.public_description,'The Burly Griffins are the Australian capitols first Buhurt team. We were established in 2023 and are open to all members from Canberra and surrounding areas.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryce Lightbody','captain','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Robert Cornish','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jackson Millers','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas Dixon','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jackson Wark','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Cannon','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'MICHAEL ROBINSON','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Grant','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Max convey','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Labudda','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Thomson','fighter','bi_teams','https://www.buhurtinternational.com/team/canberra-burly-griffins','canberra-burly-griffins',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='carcas-sonne' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-carcas-sonne' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Carcas Sonne','Carcassonne',true,'active','public','bi-carcas-sonne','EU','Europe','FR','France','behourdsportcarcassonne@gmail.com','https://www.facebook.com/profile.php?id=100063541058560','https://static.wixstatic.com/media/d3b62a_598baf9f386243c7bdf42a7a7bf75cb9~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','carcas-sonne','https://www.buhurtinternational.com/team/carcas-sonne','Carcas Sonne','Carcassonne','behourdsportcarcassonne@gmail.com','https://www.facebook.com/profile.php?id=100063541058560',20,'{"biCollectionId":"88604c1a-779b-4e56-8b59-e136c9bfd8e4","teamName":"Carcas Sonne","club":null,"gender":"Male","captain":"Romain Imbert","conference":"Europe","country":"France","city":"Carcassonne","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Occitanie","name":"Occitanie","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Aude","name":"Aude","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Carcassonne","name":"Carcassonne","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Carcassonne","location":{"latitude":43.2083238,"longitude":2.3609448},"streetAddress":{"apt":"","formattedAddressLine":"Rue des Troubadours","name":"Rue des Troubadours","number":""},"formatted":"Rue des Troubadours, 11000 Carcassonne, France","country":"FR","postalCode":"11000","subdivision":"OCC"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100063541058560","teamEmail":"behourdsportcarcassonne@gmail.com","teamLogo":"wix:image://v1/d3b62a_598baf9f386243c7bdf42a7a7bf75cb9~mv2.jpg/logo%20carcassonne%202.jpg#originWidth=851&originHeight=857","logoUrl":"https://static.wixstatic.com/media/d3b62a_598baf9f386243c7bdf42a7a7bf75cb9~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":9,"tournaments":[{"_id":"1","points":1,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":7}]}},"members":["Romain Imbert","Jean ROUX","Etienne Paganelli","Carton corentin","Paul Cayuela","CESSA Adrien","Alexandre BOIDRON","Davidenko Valentin","Coget Damien","Julien Esclangon","Batiste Lacroix","Vincent Capelle","Houdot jeremy"],"sourceCreatedAt":"2024-07-22T14:29:53.529Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Carcas Sonne',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Carcassonne',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'behourdsportcarcassonne@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100063541058560'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/d3b62a_598baf9f386243c7bdf42a7a7bf75cb9~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Romain Imbert','captain','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jean ROUX','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Etienne Paganelli','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carton corentin','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Paul Cayuela','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'CESSA Adrien','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandre BOIDRON','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Davidenko Valentin','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Coget Damien','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julien Esclangon','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Batiste Lacroix','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vincent Capelle','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Houdot jeremy','fighter','bi_teams','https://www.buhurtinternational.com/team/carcas-sonne','carcas-sonne',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='carranza-vipers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-carranza-vipers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'CARRANZA VIPERS','Madrid',true,'active','public','bi-carranza-vipers','EU','Europe','ES','Spain','gemaparral@hotmail.com',NULL,'https://static.wixstatic.com/media/88548f_7c29ec7722664363bde816c807b7259c~mv2.jpeg','We talk Párcel')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','carranza-vipers','https://www.buhurtinternational.com/team/carranza-vipers','CARRANZA VIPERS','Madrid','gemaparral@hotmail.com',NULL,20,'{"biCollectionId":"02d1812a-52c0-44d1-b973-40a98dd2a273","teamName":"CARRANZA VIPERS","club":null,"gender":"Female","captain":"Gema María Parral Sola","conference":"Europe","country":"Spain","city":"Madrid","teamInfo":"We talk Párcel","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"gemaparral@hotmail.com","teamLogo":"wix:image://v1/88548f_7c29ec7722664363bde816c807b7259c~mv2.jpeg/66bebd36-2710-471b-9cc4-cce5b362c9eb.jpeg#originWidth=1179&originHeight=1166","logoUrl":"https://static.wixstatic.com/media/88548f_7c29ec7722664363bde816c807b7259c~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":8}},"members":["Gema María Parral Sola","Gema Maria Parral Sola","Virginia Gutiérrez Álvarez","Natalia Bandach","Tatyana Filimonova"],"sourceCreatedAt":"2025-08-29T10:42:10.814Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('CARRANZA VIPERS',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Madrid',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'gemaparral@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/88548f_7c29ec7722664363bde816c807b7259c~mv2.jpeg'),
 public_description=coalesce(t.public_description,'We talk Párcel'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gema María Parral Sola','captain','bi_teams','https://www.buhurtinternational.com/team/carranza-vipers','carranza-vipers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gema Maria Parral Sola','fighter','bi_teams','https://www.buhurtinternational.com/team/carranza-vipers','carranza-vipers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Virginia Gutiérrez Álvarez','fighter','bi_teams','https://www.buhurtinternational.com/team/carranza-vipers','carranza-vipers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Natalia Bandach','fighter','bi_teams','https://www.buhurtinternational.com/team/carranza-vipers','carranza-vipers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tatyana Filimonova','fighter','bi_teams','https://www.buhurtinternational.com/team/carranza-vipers','carranza-vipers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cassowaries' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cassowaries' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Cassowaries','Ballarat/Adelaide',true,'active','public','bi-cassowaries','OC','Oceania','AU','Australia','molly.fry@outlook.com','https://www.facebook.com/WarhoundsAC','https://static.wixstatic.com/media/75740a_ada7aeba9d394496bf0449835b316837~mv2.jpeg','Named after the world&#x27;s deadliest Australian bird, this team is the creation of the ladies from all around Australia! Hailing from the land down under, these gals are not only pack a punch, but they are also great friends!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cassowaries','https://www.buhurtinternational.com/team/cassowaries','Cassowaries','Ballarat/Adelaide','molly.fry@outlook.com','https://www.facebook.com/WarhoundsAC',20,'{"biCollectionId":"bbc02ef5-9063-407b-ae5b-0b16b87df33e","teamName":"Cassowaries","club":null,"gender":"Female","captain":"Molly Fry","conference":"APAC","country":"Australia","city":"Ballarat/Adelaide","teamInfo":"Named after the world&#x27;s deadliest Australian bird, this team is the creation of the ladies from all around Australia! Hailing from the land down under, these gals are not only pack a punch, but they are also great friends!","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/WarhoundsAC","teamEmail":"molly.fry@outlook.com","teamLogo":"wix:image://v1/75740a_ada7aeba9d394496bf0449835b316837~mv2.jpeg/213C62EF-BC49-46FE-83B5-9CB0BC5C3BD0.jpeg#originWidth=1125&originHeight=1214","logoUrl":"https://static.wixstatic.com/media/75740a_ada7aeba9d394496bf0449835b316837~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"3vs3","place":1},{"_id":"2","points":1.5,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":8,"tournaments":[{"_id":"1","points":3.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":3}]}},"members":["Molly Fry","Ebony Jade Davidson"],"sourceCreatedAt":"2023-09-06T05:00:04.341Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Cassowaries',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Ballarat/Adelaide',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'molly.fry@outlook.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/WarhoundsAC'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/75740a_ada7aeba9d394496bf0449835b316837~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Named after the world&#x27;s deadliest Australian bird, this team is the creation of the ladies from all around Australia! Hailing from the land down under, these gals are not only pack a punch, but they are also great friends!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Molly Fry','captain','bi_teams','https://www.buhurtinternational.com/team/cassowaries','cassowaries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ebony Jade Davidson','fighter','bi_teams','https://www.buhurtinternational.com/team/cassowaries','cassowaries',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='castilla' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-castilla' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Castilla','Burgos',true,'active','public','bi-castilla','EU','Europe','ES','Spain','bohurtcastilla@gmail.com',NULL,'https://static.wixstatic.com/media/cdb0bb_1185c2addf4e46c1836a6049c3423ed6~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','castilla','https://www.buhurtinternational.com/team/castilla','Castilla','Burgos','bohurtcastilla@gmail.com',NULL,20,'{"biCollectionId":"cdee04c2-7542-45af-b131-40165ab2daf7","teamName":"Castilla","club":null,"gender":"Male","captain":"Sergio Abad Madrid","conference":"Europe","country":"Spain","city":"Burgos","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"bohurtcastilla@gmail.com","teamLogo":"wix:image://v1/cdb0bb_1185c2addf4e46c1836a6049c3423ed6~mv2.png/WhatsApp%20Image%202026-08-03%20at%2018.48.50%20copia.png#originWidth=395&originHeight=395","logoUrl":"https://static.wixstatic.com/media/cdb0bb_1185c2addf4e46c1836a6049c3423ed6~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Sergio Abad Madrid","Javier Gallardo Reyero"],"sourceCreatedAt":"2026-08-21T19:22:43.830Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Castilla',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Burgos',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bohurtcastilla@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cdb0bb_1185c2addf4e46c1836a6049c3423ed6~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sergio Abad Madrid','captain','bi_teams','https://www.buhurtinternational.com/team/castilla','castilla',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Javier Gallardo Reyero','fighter','bi_teams','https://www.buhurtinternational.com/team/castilla','castilla',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='caterva-violenta' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-caterva-violenta' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Caterva Violenta',NULL,true,'active','public','bi-caterva-violenta','EU','Europe','CH','Switzerland','info@caterva-violenta.ch',NULL,'https://static.wixstatic.com/media/084e49_a9e0bd45e66c4616966ae69883c5d40f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','caterva-violenta','https://www.buhurtinternational.com/team/caterva-violenta','Caterva Violenta',NULL,'info@caterva-violenta.ch',NULL,20,'{"biCollectionId":"e9cb5f05-5a78-46c6-8c17-5d61c2cc0efc","teamName":"Caterva Violenta","club":null,"gender":"Male","captain":"Jannot Hammer","conference":"Europe","country":"Switzerland","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"info@caterva-violenta.ch","teamLogo":"wix:image://v1/084e49_a9e0bd45e66c4616966ae69883c5d40f~mv2.png/Wappen_Caterva_Violenta_ohneBanner_shade_lowRes.png#originWidth=1902&originHeight=1598","logoUrl":"https://static.wixstatic.com/media/084e49_a9e0bd45e66c4616966ae69883c5d40f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Jannot Hammer"],"sourceCreatedAt":"2026-05-31T14:37:07.594Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Caterva Violenta',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CH',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Switzerland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@caterva-violenta.ch'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/084e49_a9e0bd45e66c4616966ae69883c5d40f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jannot Hammer','captain','bi_teams','https://www.buhurtinternational.com/team/caterva-violenta','caterva-violenta',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cavalieri-di-ranaan' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cavalieri-di-ranaan' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Cavalieri di Ranaan','Milan',true,'active','public','bi-cavalieri-di-ranaan','EU','Europe','IT','Italy','fede.prate@hotmail.it',NULL,'https://static.wixstatic.com/media/9084ea_462b04185e1e4578b5a7b539fbbdddb1~mv2.jpg','Buhurt italian team based in Milan')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cavalieri-di-ranaan','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','Cavalieri di Ranaan','Milan','fede.prate@hotmail.it',NULL,20,'{"biCollectionId":"f5ee4015-dae2-4dc9-8c91-0d1ff09965ff","teamName":"Cavalieri di Ranaan","club":null,"gender":"Male","captain":"Federico Pratesi","conference":"Europe","country":"Italy","city":"Milan","teamInfo":"Buhurt italian team based in Milan","trainingInfo":"You only need a belt and a pair of gloves","trainingLocation":{"subdivisions":[{"code":"Lombardia","name":"Lombardia","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"MI","name":"Città metropolitana di Milano","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Milano","name":"Milano","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"IT","name":"Italy","type":"COUNTRY"}],"city":"Milano","location":{"latitude":45.4775429,"longitude":9.2368522},"streetAddress":{"apt":"","formattedAddressLine":"Via Carlo Valvassori Peroni, 48","name":"Via Carlo Valvassori Peroni","number":"48"},"formatted":"Via Carlo Valvassori Peroni, 48, 20133 Milano MI, Italy","country":"IT","postalCode":"20133","subdivision":"25"},"websiteFacebookUrl":null,"teamEmail":"fede.prate@hotmail.it","teamLogo":"wix:image://v1/9084ea_462b04185e1e4578b5a7b539fbbdddb1~mv2.jpg/26274915_1354747564671370_7736658391400972288_n.jpg#originWidth=1080&originHeight=1080","logoUrl":"https://static.wixstatic.com/media/9084ea_462b04185e1e4578b5a7b539fbbdddb1~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Federico Pratesi","Marco Carrozzo","Alessandro David","Andrea Mollaretti","Sandro Castelli","Silvia Beghelli","Leonardo Cuppari","Simone Palermo","Simone Francesco Canevari","Francesco Giulio Pignatelli","Saul Rocca"],"sourceCreatedAt":"2026-01-15T16:30:45.862Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Cavalieri di Ranaan',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Milan',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'fede.prate@hotmail.it'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/9084ea_462b04185e1e4578b5a7b539fbbdddb1~mv2.jpg'),
 public_description=coalesce(t.public_description,'Buhurt italian team based in Milan'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Federico Pratesi','captain','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco Carrozzo','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alessandro David','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrea Mollaretti','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sandro Castelli','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Silvia Beghelli','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonardo Cuppari','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simone Palermo','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simone Francesco Canevari','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francesco Giulio Pignatelli','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Saul Rocca','fighter','bi_teams','https://www.buhurtinternational.com/team/cavalieri-di-ranaan','cavalieri-di-ranaan',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cecm---eagles' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cecm---eagles' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'CECM - Eagles','Buenos Aires ',true,'active','public','bi-cecm---eagles','SA','South America','AR','Argentina','cecm.combatemedieval@gmail.com','https://www.facebook.com/HMBCapitalFederal','https://static.wixstatic.com/media/c90105_13717c57b1484df9b5e3e49d5ee6a3b1~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cecm---eagles','https://www.buhurtinternational.com/team/cecm---eagles','CECM - Eagles','Buenos Aires ','cecm.combatemedieval@gmail.com','https://www.facebook.com/HMBCapitalFederal',20,'{"biCollectionId":"90b73ef7-c228-4d63-8945-fd04a137fb9d","teamName":"CECM - Eagles","club":"CECM - Águilas","gender":"Male","captain":"Martin Nielsen","conference":"South America","country":"Argentina","city":"Buenos Aires ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/HMBCapitalFederal","teamEmail":"cecm.combatemedieval@gmail.com","teamLogo":"wix:image://v1/c90105_13717c57b1484df9b5e3e49d5ee6a3b1~mv2.png/CECM.png#originWidth=381&originHeight=443","logoUrl":"https://static.wixstatic.com/media/c90105_13717c57b1484df9b5e3e49d5ee6a3b1~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Martin Nielsen","Diego Sebastián Oscar Villagrán","Vela Gonzalo Gabriel","Marcos Zúñiga","Maximiliano ezequiel Fernandez iglesias","juan ignacio garcia riccardi","Juan Manuel Chevasco Diaz","Leonel Javier Becher"],"sourceCreatedAt":"2023-10-10T20:35:52.230Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('CECM - Eagles',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Buenos Aires ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'cecm.combatemedieval@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/HMBCapitalFederal'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/c90105_13717c57b1484df9b5e3e49d5ee6a3b1~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Martin Nielsen','captain','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Diego Sebastián Oscar Villagrán','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vela Gonzalo Gabriel','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Zúñiga','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maximiliano ezequiel Fernandez iglesias','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'juan ignacio garcia riccardi','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juan Manuel Chevasco Diaz','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Leonel Javier Becher','fighter','bi_teams','https://www.buhurtinternational.com/team/cecm---eagles','cecm---eagles',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='centinelas' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-centinelas' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Centinelas','Tandil',true,'active','public','bi-centinelas','SA','South America','AR','Argentina','centinelastandil@yahoo.com','https://www.facebook.com/centinelasdelassierras','https://static.wixstatic.com/media/b7c3b6_82e32813d7b94c0db934e1f2ddd713f5~mv2.png','Centinelas de las Sierras - Combate Medieval Tandil Con la premisa de formar un verdadero Club deportivo, Centinelas de las Sierras realiza su actividad principal de Combate Medieval Histórico, donde hombres y mujeres se forman en el arte del combate con armadura, armas y escudos de la Edad Media. Reinando la camaraderia, solidaridad y respeto por compañeros e instructores, Centinelas llegó para quedarse. Demostrando evento a evento un crecimiento tanto en lo deportivo como en lo organizacional, siendo fruto de hacer las cosas bien, como debe ser. ORGANIZADORES DEL TORNEO MAS PRESTIGIOSO DEL PAÍS: LA COPA CENTINELA. - Campeones Sudamericanos 2022 en categoría Broquel Masculino (Francisco Caputo). - Campeones Sudamericanos 2022 en categoría Broquel Femenino (Juana Paula Arata).')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','centinelas','https://www.buhurtinternational.com/team/centinelas','Centinelas','Tandil','centinelastandil@yahoo.com','https://www.facebook.com/centinelasdelassierras',20,'{"biCollectionId":"f2b83c42-bf7d-4a63-b610-c54f9447222a","teamName":"Centinelas","club":null,"gender":"Male","captain":"Federico Omar Herrera de Prado","conference":"South America","country":"Argentina","city":"Tandil","teamInfo":"Centinelas de las Sierras - Combate Medieval Tandil Con la premisa de formar un verdadero Club deportivo, Centinelas de las Sierras realiza su actividad principal de Combate Medieval Histórico, donde hombres y mujeres se forman en el arte del combate con armadura, armas y escudos de la Edad Media. Reinando la camaraderia, solidaridad y respeto por compañeros e instructores, Centinelas llegó para quedarse. Demostrando evento a evento un crecimiento tanto en lo deportivo como en lo organizacional, siendo fruto de hacer las cosas bien, como debe ser. ORGANIZADORES DEL TORNEO MAS PRESTIGIOSO DEL PAÍS: LA COPA CENTINELA. - Campeones Sudamericanos 2022 en categoría Broquel Masculino (Francisco Caputo). - Campeones Sudamericanos 2022 en categoría Broquel Femenino (Juana Paula Arata).","trainingInfo":"Todos estan invitados a participar! No es necesario experiencia previa, nosotros te enseñamos todo lo que necesitas saber! Encontranos en el Club Boca Jrs de la ciudad de Tandil (Belgrano 967).","trainingLocation":{"city":"Tandil","location":{"latitude":-37.32700639999999,"longitude":-59.12987459999999},"streetAddress":{"apt":"","formattedAddressLine":"Belgrano 967","name":"Belgrano","number":"967"},"formatted":"Belgrano 967, B7000GES Tandil, Provincia de Buenos Aires, Argentina","country":"AR","postalCode":"B7000-GES"},"websiteFacebookUrl":"https://www.facebook.com/centinelasdelassierras","teamEmail":"centinelastandil@yahoo.com","teamLogo":"wix:image://v1/b7c3b6_82e32813d7b94c0db934e1f2ddd713f5~mv2.png/escudocentinela.png#originWidth=1459&originHeight=1624","logoUrl":"https://static.wixstatic.com/media/b7c3b6_82e32813d7b94c0db934e1f2ddd713f5~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Copa Centinela 2024","date":"2024-05-04","category":"5vs5","place":4}]},"2025":{"remainingTokens":10}},"members":["Federico Omar Herrera de Prado","Marcos Toloza","Joaquin Jose Sanchez Arce","Andrés Borda Fumadó","Francisco Caputo","Pedro Bruno Dennehy"],"sourceCreatedAt":"2023-09-02T22:36:07.396Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Centinelas',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tandil',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'centinelastandil@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/centinelasdelassierras'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b7c3b6_82e32813d7b94c0db934e1f2ddd713f5~mv2.png'),
 public_description=coalesce(t.public_description,'Centinelas de las Sierras - Combate Medieval Tandil Con la premisa de formar un verdadero Club deportivo, Centinelas de las Sierras realiza su actividad principal de Combate Medieval Histórico, donde hombres y mujeres se forman en el arte del combate con armadura, armas y escudos de la Edad Media. Reinando la camaraderia, solidaridad y respeto por compañeros e instructores, Centinelas llegó para quedarse. Demostrando evento a evento un crecimiento tanto en lo deportivo como en lo organizacional, siendo fruto de hacer las cosas bien, como debe ser. ORGANIZADORES DEL TORNEO MAS PRESTIGIOSO DEL PAÍS: LA COPA CENTINELA. - Campeones Sudamericanos 2022 en categoría Broquel Masculino (Francisco Caputo). - Campeones Sudamericanos 2022 en categoría Broquel Femenino (Juana Paula Arata).'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Federico Omar Herrera de Prado','captain','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marcos Toloza','fighter','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joaquin Jose Sanchez Arce','fighter','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrés Borda Fumadó','fighter','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francisco Caputo','fighter','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pedro Bruno Dennehy','fighter','bi_teams','https://www.buhurtinternational.com/team/centinelas','centinelas',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cerberus' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cerberus' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Cerberus','Buenos aires',true,'active','public','bi-cerberus','SA','South America','AR','Argentina','cerberusmedieval@protonmail.com',NULL,'https://static.wixstatic.com/media/8d9f20_386a86eff4484699b556047a73800e49~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cerberus','https://www.buhurtinternational.com/team/cerberus','Cerberus','Buenos aires','cerberusmedieval@protonmail.com',NULL,20,'{"biCollectionId":"763fcbf0-1b75-4416-b37c-dc7791e75a24","teamName":"Cerberus","club":null,"gender":"Male","captain":"Jorge eduardo campagno","conference":"South America","country":"Argentina","city":"Buenos aires","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"cerberusmedieval@protonmail.com","teamLogo":"wix:image://v1/8d9f20_386a86eff4484699b556047a73800e49~mv2.png/CERBERUS%20heraldica%20detallada%20para%20remera%20a.png#originWidth=6171&originHeight=7502","logoUrl":"https://static.wixstatic.com/media/8d9f20_386a86eff4484699b556047a73800e49~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Jorge eduardo campagno"],"sourceCreatedAt":"2025-09-17T00:39:40.821Z","sourceUpdatedAt":"2026-09-24T18:21:34.469Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Cerberus',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Buenos aires',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('SA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('South America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Argentina',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'cerberusmedieval@protonmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/8d9f20_386a86eff4484699b556047a73800e49~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jorge eduardo campagno','captain','bi_teams','https://www.buhurtinternational.com/team/cerberus','cerberus',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='chaumont-béhourd' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-chaumont-béhourd' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Chaumont Béhourd','Chaumont',true,'active','public','bi-chaumont-béhourd','EU','Europe','FR','France','chaumontbehourd@gmail.com',NULL,'https://static.wixstatic.com/media/cd9374_d081222df5c248aa9ccc7d9f5d8c3851~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','chaumont-béhourd','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','Chaumont Béhourd','Chaumont','chaumontbehourd@gmail.com',NULL,20,'{"biCollectionId":"5a3b9aee-afb4-47bc-8e48-e90fec63c5b9","teamName":"Chaumont Béhourd","club":null,"gender":"Male","captain":"Thierry Geuze","conference":"Europe","country":"France","city":"Chaumont","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"Grand Est","name":"Grand Est","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Haute-Marne","name":"Haute-Marne","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Chaumont","name":"Chaumont","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Chaumont","location":{"latitude":48.113748,"longitude":5.1392559},"streetAddress":{"apt":"","formattedAddressLine":"Chaumont","name":"","number":""},"formatted":"52000 Chaumont, France","country":"FR","postalCode":"52000","subdivision":"GES"},"websiteFacebookUrl":null,"teamEmail":"chaumontbehourd@gmail.com","teamLogo":"wix:image://v1/cd9374_d081222df5c248aa9ccc7d9f5d8c3851~mv2.jpg/347261249_133423419730258_1775065135165211753_n.jpg#originWidth=1000&originHeight=1200","logoUrl":"https://static.wixstatic.com/media/cd9374_d081222df5c248aa9ccc7d9f5d8c3851~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Jan van Brabant 2026","date":"2026-05-16","category":"5vs5","place":5}],"eventsHistory":{},"members":["Thierry Geuze","Beuzelin Edouard","Devillard Gaetan","Labeaune","Duchenne Nils","Clément MOULLIERE"],"sourceCreatedAt":"2026-02-26T14:10:53.625Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Chaumont Béhourd',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Chaumont',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'chaumontbehourd@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/cd9374_d081222df5c248aa9ccc7d9f5d8c3851~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thierry Geuze','captain','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Beuzelin Edouard','fighter','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Devillard Gaetan','fighter','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Labeaune','fighter','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Duchenne Nils','fighter','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Clément MOULLIERE','fighter','bi_teams','https://www.buhurtinternational.com/team/chaumont-b%C3%A9hourd','chaumont-béhourd',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='chicago-hydras' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-chicago-hydras' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Chicago Hydras','Chicago',true,'active','public','bi-chicago-hydras','NA','North America','US','United States','armoredchicago@gmail.com',NULL,'https://static.wixstatic.com/media/7b6921_cfac35f2e517486c865adf70e0d1dbea~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','chicago-hydras','https://www.buhurtinternational.com/team/chicago-hydras','Chicago Hydras','Chicago','armoredchicago@gmail.com',NULL,20,'{"biCollectionId":"c2e95bb7-113e-4576-8b45-641c941bc7cf","teamName":"Chicago Hydras","club":null,"gender":"Male","captain":"Raymond Paez","conference":"North America","country":"United States","city":"Chicago","teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"IL","name":"Illinois","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Cook County","name":"Cook County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Chicago","name":"Chicago","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Chicago","location":{"latitude":41.88325,"longitude":-87.6323879},"streetAddress":{"apt":"","formattedAddressLine":"Chicago","name":"","number":""},"formatted":"Chicago, IL, USA","country":"US","subdivision":"IL"},"websiteFacebookUrl":null,"teamEmail":"armoredchicago@gmail.com","teamLogo":"wix:image://v1/7b6921_cfac35f2e517486c865adf70e0d1dbea~mv2.png/Red_Red_251122_163429.png#originWidth=1013&originHeight=1308","logoUrl":"https://static.wixstatic.com/media/7b6921_cfac35f2e517486c865adf70e0d1dbea~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":6}],"eventsHistory":{},"members":["Jesse Sese","Hieu Van Nguyen","Anton Taylor Jones","Raymond Paez","Rand Aquino","Victor Paya","Julio Galvan","Ozmodeus Steelheart","Troy Arndt"],"sourceCreatedAt":"2026-04-27T13:51:09.206Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Chicago Hydras',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Chicago',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'armoredchicago@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7b6921_cfac35f2e517486c865adf70e0d1dbea~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesse Sese','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hieu Van Nguyen','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anton Taylor Jones','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raymond Paez','captain','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rand Aquino','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Victor Paya','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julio Galvan','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ozmodeus Steelheart','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Troy Arndt','fighter','bi_teams','https://www.buhurtinternational.com/team/chicago-hydras','chicago-hydras',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='chimera-armored-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-chimera-armored-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Chimera Armored Combat','OMAHA',true,'active','public','bi-chimera-armored-combat','NA','North America','US','United States','chimerahmb@gmail.com','https://www.chimeraarmoredcombat.com/','https://static.wixstatic.com/media/67dc3c_95612552cf86464ba044ef5f7ec6c99f~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','chimera-armored-combat','https://www.buhurtinternational.com/team/chimera-armored-combat','Chimera Armored Combat','OMAHA','chimerahmb@gmail.com','https://www.chimeraarmoredcombat.com/',20,'{"biCollectionId":"06ab2227-d0d7-4f71-b4f1-b75145c60d6d","teamName":"Chimera Armored Combat","club":null,"gender":"Male","captain":"Tyler B Schwartz","conference":"North America","country":"United States","city":"OMAHA","teamInfo":"","trainingInfo":"If you wish to come and fight with us please feel free to contact Tyler Schwartz","trainingLocation":{"subdivisions":[{"code":"NE","name":"Nebraska","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Douglas County","name":"Douglas County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Omaha","name":"Omaha","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"North Omaha","name":"North Omaha","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Omaha","location":{"latitude":41.3181881,"longitude":-95.9644852},"streetAddress":{"apt":"","formattedAddressLine":"6513 N 35th St","name":"North 35th Street","number":"6513"},"formatted":"6513 N 35th St, Omaha, NE 68112, USA","country":"US","postalCode":"68112-3027","subdivision":"NE"},"websiteFacebookUrl":"https://www.chimeraarmoredcombat.com/","teamEmail":"chimerahmb@gmail.com","teamLogo":"wix:image://v1/67dc3c_95612552cf86464ba044ef5f7ec6c99f~mv2.png/1_20240205_221611_0000.png#originWidth=5000&originHeight=5000","logoUrl":"https://static.wixstatic.com/media/67dc3c_95612552cf86464ba044ef5f7ec6c99f~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":5},{"_id":"2","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":8}],"eventsHistory":{"2024":{},"2025":{"remainingTokens":4}},"members":["Tyler B Schwartz","Collin Martineau","Steven Allee","Ted Vlamis","Micah Nelson","J Duke","Logan Kangas","Cash Kangas"],"sourceCreatedAt":"2025-08-01T02:17:37.860Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Chimera Armored Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('OMAHA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'chimerahmb@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.chimeraarmoredcombat.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/67dc3c_95612552cf86464ba044ef5f7ec6c99f~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler B Schwartz','captain','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Collin Martineau','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Allee','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ted Vlamis','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Micah Nelson','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'J Duke','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Logan Kangas','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cash Kangas','fighter','bi_teams','https://www.buhurtinternational.com/team/chimera-armored-combat','chimera-armored-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cicadidae-de-provence' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cicadidae-de-provence' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Cicadidae De Provence','Les Arcs',true,'active','public','bi-cicadidae-de-provence','EU','Europe','FR','France','lesvassauxdeprovence@gmail.com','https://www.instagram.com/cicadidae.de.provence?igsh=MTFtMW14ZDd4a2VqOQ==','https://static.wixstatic.com/media/120c5d_9f7196331ca642458804797565a35920~mv2.jpg','We are a young french female team of Les Vassaux de Provence, located in the south of France. CICA A TOT.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cicadidae-de-provence','https://www.buhurtinternational.com/team/cicadidae-de-provence','Cicadidae De Provence','Les Arcs','lesvassauxdeprovence@gmail.com','https://www.instagram.com/cicadidae.de.provence?igsh=MTFtMW14ZDd4a2VqOQ==',20,'{"biCollectionId":"b59404aa-0ba2-4797-90b5-02a93b6dc4f5","teamName":"Cicadidae De Provence","club":null,"gender":"Female","captain":"GENEVIÈVE FIGLIUZZI","conference":"Europe","country":"France","city":"Les Arcs","teamInfo":"We are a young french female team of Les Vassaux de Provence, located in the south of France. CICA A TOT.","trainingInfo":"If you&#x27;re located in the south of France, looking. forward to upgrate your confidence and your fighting competences, you&#x27;re more than welcome to joiln us","trainingLocation":{"subdivisions":[{"code":"Provence-Alpes-Côte d''Azur","name":"Provence-Alpes-Côte d''Azur","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Var","name":"Var","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Les Arcs","name":"Les Arcs","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"FR","name":"France","type":"COUNTRY"}],"city":"Les Arcs","location":{"latitude":43.42209739999999,"longitude":6.470134299999999},"streetAddress":{"apt":"","formattedAddressLine":"Les vassaux de provence","name":"quartier riaou roux","number":""},"formatted":"quartier riaou roux, 83460 Les Arcs, France","country":"FR","postalCode":"83460","subdivision":"PAC"},"websiteFacebookUrl":"https://www.instagram.com/cicadidae.de.provence?igsh=MTFtMW14ZDd4a2VqOQ==","teamEmail":"lesvassauxdeprovence@gmail.com","teamLogo":"wix:image://v1/120c5d_9f7196331ca642458804797565a35920~mv2.jpg/Logo%20Cica.jpg#originWidth=1402&originHeight=1600","logoUrl":"https://static.wixstatic.com/media/120c5d_9f7196331ca642458804797565a35920~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"3vs3","place":3}]}},"members":["GENEVIÈVE FIGLIUZZI","Michelle ANGLADE","Aimar Julie","GENEVIEVE FIGLIUZZI","Charlotte Ey","Mélodie Gomez"],"sourceCreatedAt":"2025-03-19T17:52:49.532Z","sourceUpdatedAt":"2026-09-24T18:21:42.395Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Cicadidae De Provence',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Les Arcs',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lesvassauxdeprovence@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.instagram.com/cicadidae.de.provence?igsh=MTFtMW14ZDd4a2VqOQ=='),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/120c5d_9f7196331ca642458804797565a35920~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are a young french female team of Les Vassaux de Provence, located in the south of France. CICA A TOT.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GENEVIÈVE FIGLIUZZI','captain','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michelle ANGLADE','fighter','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aimar Julie','fighter','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'GENEVIEVE FIGLIUZZI','fighter','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charlotte Ey','fighter','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mélodie Gomez','fighter','bi_teams','https://www.buhurtinternational.com/team/cicadidae-de-provence','cicadidae-de-provence',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='cincinnati-barbarians' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-cincinnati-barbarians' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Cincinnati Barbarians','Cincinnati ',true,'active','public','bi-cincinnati-barbarians','NA','North America','US','United States','travis@cincinnatibarbarians.com','https://www.cincinnatibarbarians.com','https://static.wixstatic.com/media/13ce5b_faffbd1159ac4cbea23734c13ebc6ef2~mv2.jpg','Training out of the Barbarian Academy in Centerville, Ohio. Our practices are always open to new or traveling fighters.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','cincinnati-barbarians','https://www.buhurtinternational.com/team/cincinnati-barbarians','Cincinnati Barbarians','Cincinnati ','travis@cincinnatibarbarians.com','https://www.cincinnatibarbarians.com',20,'{"biCollectionId":"049904c1-b928-48a1-9f2d-e7bc65e26598","teamName":"Cincinnati Barbarians","club":null,"gender":"Male","captain":"Travis Young","conference":"North America","country":"United States","city":"Cincinnati ","teamInfo":"Training out of the Barbarian Academy in Centerville, Ohio. Our practices are always open to new or traveling fighters.","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"OH","name":"Ohio","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Montgomery County","name":"Montgomery County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Dayton","name":"Dayton","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Dayton","location":{"latitude":39.6327355,"longitude":-84.1432554},"streetAddress":{"apt":"","formattedAddressLine":"126 Westpark Rd","name":"Westpark Road","number":"126"},"formatted":"126 Westpark Rd, Dayton, OH 45459, USA","country":"US","postalCode":"45459-4815","subdivision":"OH"},"websiteFacebookUrl":"https://www.cincinnatibarbarians.com","teamEmail":"travis@cincinnatibarbarians.com","teamLogo":"wix:image://v1/13ce5b_faffbd1159ac4cbea23734c13ebc6ef2~mv2.jpg/logo%20(1).jpg#originWidth=833&originHeight=1000","logoUrl":"https://static.wixstatic.com/media/13ce5b_faffbd1159ac4cbea23734c13ebc6ef2~mv2.jpg","rank5v5":10,"averagePoints5v5":5.83,"points5v5":17.5,"rank12v12":null,"points12v12":9,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":5},{"_id":"2","points":12,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":1},{"_id":"3","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":6},{"_id":"4","points":9,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"12vs12","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":10},{"_id":"2","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":11}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":10},{"_id":"2","points":4,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":5},{"_id":"3","points":3,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":9},{"_id":"4","points":3,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":4}],"points12v12":3,"averagePoints5v5":3.67,"rank5v5":13,"remainingTokens":10,"points5v5":11}},"members":["Ian Hartsough","Jay Bishop","Jake Dishun","Travis Young","Gabriel Hutchings","Jonathan white","Zane Robertson","Daniel Eddy","Alex Ding"],"sourceCreatedAt":"2023-07-20T16:23:15.309Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Cincinnati Barbarians',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Cincinnati ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'travis@cincinnatibarbarians.com'),
 website_url=coalesce(t.website_url,'https://www.cincinnatibarbarians.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/13ce5b_faffbd1159ac4cbea23734c13ebc6ef2~mv2.jpg'),
 public_description=coalesce(t.public_description,'Training out of the Barbarian Academy in Centerville, Ohio. Our practices are always open to new or traveling fighters.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Hartsough','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jay Bishop','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Dishun','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Travis Young','captain','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Hutchings','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan white','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zane Robertson','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Eddy','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Ding','fighter','bi_teams','https://www.buhurtinternational.com/team/cincinnati-barbarians','cincinnati-barbarians',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='colorado-wardames' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-colorado-wardames' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Colorado WarDames','Colorado Springs ',true,'active','public','bi-colorado-wardames','NA','North America','US','United States','solairealexis@gmail.com','https://www.facebook.com/profile.php?id=100094060682893','https://static.wixstatic.com/media/54b186_9c35dad5048d4d7787abd7dba1c671fd~mv2.png','The War Dames are the femme faction of the Colorado Wardens.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','colorado-wardames','https://www.buhurtinternational.com/team/colorado-wardames','Colorado WarDames','Colorado Springs ','solairealexis@gmail.com','https://www.facebook.com/profile.php?id=100094060682893',20,'{"biCollectionId":"2144822b-57a9-40e2-8312-2c8dbe795cfe","teamName":"Colorado WarDames","club":null,"gender":"Female","captain":"Alexis Solaire","conference":"North America","country":"United States","city":"Colorado Springs ","teamInfo":"The War Dames are the femme faction of the Colorado Wardens.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100094060682893","teamEmail":"solairealexis@gmail.com","teamLogo":"wix:image://v1/54b186_9c35dad5048d4d7787abd7dba1c671fd~mv2.png/Sun_Isolated%20(1).png#originWidth=928&originHeight=856","logoUrl":"https://static.wixstatic.com/media/54b186_9c35dad5048d4d7787abd7dba1c671fd~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Alexis Solaire","Axana Kovanda","Kate Petty","Drew Baer","Patience Noble","Shawna Shepherd","Bailey Pearsall","Savannah Moore","Kat Skender"],"sourceCreatedAt":"2026-05-13T03:28:55.784Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Colorado WarDames',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Colorado Springs ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'solairealexis@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100094060682893'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/54b186_9c35dad5048d4d7787abd7dba1c671fd~mv2.png'),
 public_description=coalesce(t.public_description,'The War Dames are the femme faction of the Colorado Wardens.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexis Solaire','captain','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Axana Kovanda','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kate Petty','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Drew Baer','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patience Noble','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shawna Shepherd','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bailey Pearsall','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Savannah Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kat Skender','fighter','bi_teams','https://www.buhurtinternational.com/team/colorado-wardames','colorado-wardames',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='compagnia-della-ruggine' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-compagnia-della-ruggine' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Compagnia della Ruggine','Todi',true,'active','public','bi-compagnia-della-ruggine','EU','Europe','IT','Italy','info@compagniadellaruggine.it','https://www.facebook.com/share/1FGvJexKF5/?mibextid=wwXIfr','https://static.wixstatic.com/media/6fa356_c6187b1cc5cb4412be78c79510eb83ba~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','compagnia-della-ruggine','https://www.buhurtinternational.com/team/compagnia-della-ruggine','Compagnia della Ruggine','Todi','info@compagniadellaruggine.it','https://www.facebook.com/share/1FGvJexKF5/?mibextid=wwXIfr',20,'{"biCollectionId":"8260d23d-ea1a-4c58-a9ec-f45d006ee867","teamName":"Compagnia della Ruggine","club":null,"gender":"Male","captain":"Gabriele Biondini","conference":"Europe","country":"Italy","city":"Todi","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/1FGvJexKF5/?mibextid=wwXIfr","teamEmail":"info@compagniadellaruggine.it","teamLogo":"wix:image://v1/6fa356_c6187b1cc5cb4412be78c79510eb83ba~mv2.jpeg/logo%20ruggine.jpeg#originWidth=543&originHeight=581","logoUrl":"https://static.wixstatic.com/media/6fa356_c6187b1cc5cb4412be78c79510eb83ba~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Gabriele Biondini","Giulio Bartolini","Nichi Diotallevi","Marco Boccolacci","Ludovico Fratini","Michelangelo Antonelli","Pietro Bartolini"],"sourceCreatedAt":"2026-05-30T08:35:20.533Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Compagnia della Ruggine',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Todi',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@compagniadellaruggine.it'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1FGvJexKF5/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6fa356_c6187b1cc5cb4412be78c79510eb83ba~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriele Biondini','captain','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Giulio Bartolini','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nichi Diotallevi','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco Boccolacci','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ludovico Fratini','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michelangelo Antonelli','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Pietro Bartolini','fighter','bi_teams','https://www.buhurtinternational.com/team/compagnia-della-ruggine','compagnia-della-ruggine',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='companhia-do-punho-de-ferro' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-companhia-do-punho-de-ferro' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Companhia do Punho de Ferro','Unhos',true,'active','public','bi-companhia-do-punho-de-ferro','EU','Europe','PT','Portugal','companhiadopunhodeferro2019@gmail.com',NULL,'https://static.wixstatic.com/media/1da7e9_6edb7068c072438092c895c7f7ebd55a~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','companhia-do-punho-de-ferro','https://www.buhurtinternational.com/team/companhia-do-punho-de-ferro','Companhia do Punho de Ferro','Unhos','companhiadopunhodeferro2019@gmail.com',NULL,20,'{"biCollectionId":"0daa9e65-6d47-4218-96ec-a92eb986ef80","teamName":"Companhia do Punho de Ferro","club":null,"gender":"Male","captain":"João da Silva","conference":"Europe","country":"Portugal","city":"Unhos","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"companhiadopunhodeferro2019@gmail.com","teamLogo":"wix:image://v1/1da7e9_6edb7068c072438092c895c7f7ebd55a~mv2.png/simbolo%20final.png#originWidth=2392&originHeight=2172","logoUrl":"https://static.wixstatic.com/media/1da7e9_6edb7068c072438092c895c7f7ebd55a~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Torneio Medieval de Pirescoxe 2025","date":"2025-05-03","category":"5vs5","place":4}]}},"members":["João da Silva","Tiago Miguel Correia Albano","Rúben Emanuel Almeida Mendes"],"sourceCreatedAt":"2025-04-05T21:36:15.019Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Companhia do Punho de Ferro',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Unhos',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('PT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Portugal',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'companhiadopunhodeferro2019@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/1da7e9_6edb7068c072438092c895c7f7ebd55a~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'João da Silva','captain','bi_teams','https://www.buhurtinternational.com/team/companhia-do-punho-de-ferro','companhia-do-punho-de-ferro',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tiago Miguel Correia Albano','fighter','bi_teams','https://www.buhurtinternational.com/team/companhia-do-punho-de-ferro','companhia-do-punho-de-ferro',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rúben Emanuel Almeida Mendes','fighter','bi_teams','https://www.buhurtinternational.com/team/companhia-do-punho-de-ferro','companhia-do-punho-de-ferro',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='company-of-the-bear' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-company-of-the-bear' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Company of the Bear','Dublin, CA',true,'active','public','bi-company-of-the-bear','NA','North America','US','United States','coltonhall55@yahoo.com','https://www.facebook.com/profile.php?id=61570394935793','https://static.wixstatic.com/media/a6350f_9f7489275bcd4774aaaa3c83fb50ee50~mv2.jpg','We are bringing back a buhurt team in the bay area. Open to all genders and levels of experience!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','company-of-the-bear','https://www.buhurtinternational.com/team/company-of-the-bear','Company of the Bear','Dublin, CA','coltonhall55@yahoo.com','https://www.facebook.com/profile.php?id=61570394935793',20,'{"biCollectionId":"856dce59-4ab5-4732-9f98-d5b22359e611","teamName":"Company of the Bear","club":null,"gender":"Male","captain":"Colton \"Zayl\" hall","conference":"North America","country":"United States","city":"Dublin, CA","teamInfo":"We are bringing back a buhurt team in the bay area. Open to all genders and levels of experience!","trainingInfo":"Please reach out via the facebook page to get in touch. For your first day, bring good shoes, athletic wear, and a cup!","trainingLocation":{"subdivisions":[{"code":"CA","name":"California","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Alameda County","name":"Alameda County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Dublin","name":"Dublin","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Dublin","location":{"latitude":37.7104611,"longitude":-121.8761179},"streetAddress":{"apt":"","formattedAddressLine":"4201 Central Pkwy","name":"Central Parkway","number":"4201"},"formatted":"4201 Central Pkwy, Dublin, CA 94568, USA","country":"US","postalCode":"94568","subdivision":"CA"},"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61570394935793","teamEmail":"coltonhall55@yahoo.com","teamLogo":"wix:image://v1/a6350f_9f7489275bcd4774aaaa3c83fb50ee50~mv2.jpg/91D6CDA4-B8E9-4BFF-ADDA-8A4A0F7D43B1-XarmerXixus.jpg#originWidth=300&originHeight=300","logoUrl":"https://static.wixstatic.com/media/a6350f_9f7489275bcd4774aaaa3c83fb50ee50~mv2.jpg","rank5v5":4,"averagePoints5v5":11.42,"points5v5":41.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":8,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":2},{"_id":"2","points":15,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":1},{"_id":"3","points":11.25,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":2},{"_id":"4","points":7,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":9,"tournaments":[{"_id":"1","points":1,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":6}]}},"members":["Colton \"Zayl\" Hall","Braden Mackay","David Lee Fadda","Jordan Nunes","Voss","Dante Swift","Andrew Barron","Sam Wheeler","Andrew Ritchson","Charlie Ellington"],"sourceCreatedAt":"2025-04-19T18:24:50.788Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Company of the Bear',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dublin, CA',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'coltonhall55@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61570394935793'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a6350f_9f7489275bcd4774aaaa3c83fb50ee50~mv2.jpg'),
 public_description=coalesce(t.public_description,'We are bringing back a buhurt team in the bay area. Open to all genders and levels of experience!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colton "Zayl" Hall','captain','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Braden Mackay','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Lee Fadda','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Nunes','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Voss','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dante Swift','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Barron','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sam Wheeler','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Ritchson','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charlie Ellington','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear','company-of-the-bear',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='company-of-the-bear---w' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-company-of-the-bear---w' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Company of the Bear - W',NULL,true,'active','public','bi-company-of-the-bear---w','NA','North America','US','United States','jbalesdollar27@gmail.com',NULL,'https://static.wixstatic.com/media/6fbcf5_92388652ba904fe49c47caf6c4b7d3b0~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','company-of-the-bear---w','https://www.buhurtinternational.com/team/company-of-the-bear---w','Company of the Bear - W',NULL,'jbalesdollar27@gmail.com',NULL,20,'{"biCollectionId":"ed4e5c3e-291a-41c5-8bb5-de6e445cd3eb","teamName":"Company of the Bear - W","club":null,"gender":"Female","captain":"Jilliyn Bales-Dollar","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"jbalesdollar27@gmail.com","teamLogo":"wix:image://v1/6fbcf5_92388652ba904fe49c47caf6c4b7d3b0~mv2.jpg/cob%20logo.jpg#originWidth=1080&originHeight=1084","logoUrl":"https://static.wixstatic.com/media/6fbcf5_92388652ba904fe49c47caf6c4b7d3b0~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Alexandra Nicklin","Jilliyn Bales-Dollar","Beth Hammer"],"sourceCreatedAt":"2026-08-25T16:46:40.941Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Company of the Bear - W',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jbalesdollar27@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6fbcf5_92388652ba904fe49c47caf6c4b7d3b0~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexandra Nicklin','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear---w','company-of-the-bear---w',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jilliyn Bales-Dollar','captain','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear---w','company-of-the-bear---w',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Beth Hammer','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-bear---w','company-of-the-bear---w',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='company-of-the-pale-horse' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-company-of-the-pale-horse' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Company of the Pale Horse','All American Ports',true,'active','public','bi-company-of-the-pale-horse','NA','North America','US','United States','palehorsearmoredcombat@gmail.com','https://www.facebook.com/share/jfdhQJGqLpSbMrtz/?mibextid=LQQJ4d','https://static.wixstatic.com/media/7d66d9_a57baebb90b34b31800fcb9978bc6fd2~mv2.jpeg','US based melee team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','company-of-the-pale-horse','https://www.buhurtinternational.com/team/company-of-the-pale-horse','Company of the Pale Horse','All American Ports','palehorsearmoredcombat@gmail.com','https://www.facebook.com/share/jfdhQJGqLpSbMrtz/?mibextid=LQQJ4d',20,'{"biCollectionId":"d2212ac2-d9fc-4fec-abda-675c47b22840","teamName":"Company of the Pale Horse","club":null,"gender":"Male","captain":"Alexander Straub","conference":"North America","country":"United States","city":"All American Ports","teamInfo":"US based melee team","trainingInfo":"","trainingLocation":{"formatted":"All American Ports"},"websiteFacebookUrl":"https://www.facebook.com/share/jfdhQJGqLpSbMrtz/?mibextid=LQQJ4d","teamEmail":"palehorsearmoredcombat@gmail.com","teamLogo":"wix:image://v1/7d66d9_a57baebb90b34b31800fcb9978bc6fd2~mv2.jpeg/att.L_1jG23WdzxZIEcwnFASE6lhOZmt6xuc1YuS3pNGgUA.jpeg#originWidth=885&originHeight=890","logoUrl":"https://static.wixstatic.com/media/7d66d9_a57baebb90b34b31800fcb9978bc6fd2~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":6.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":8},{"_id":"2","points":5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":5}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":13.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":3},{"_id":"2","points":5,"Tournament":"Grapes of Wrath 2024","date":"2024-05-18","category":"5vs5","place":3},{"_id":"3","points":8,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":6},{"_id":"4","points":6,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":6,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":4},{"_id":"2","points":9,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":3},{"_id":"3","points":18,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":2},{"_id":"4","points":7.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":3},{"_id":"5","points":10,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":2},{"_id":"6","points":2,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":5},{"_id":"7","points":3,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":4}],"points12v12":9.5,"averagePoints5v5":12.33,"rank5v5":3,"remainingTokens":10,"points5v5":46}},"members":["Dylan Meadows","Michael Sloma","Kyllian Twiss","William Hartke","James coughlin","Jonathan Fortin","Alexander Straub","Blade Pool","Jamezie Helenski","Christopher Sanner"],"sourceCreatedAt":"2024-06-10T18:02:51.522Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Company of the Pale Horse',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('All American Ports',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'palehorsearmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/jfdhQJGqLpSbMrtz/?mibextid=LQQJ4d'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7d66d9_a57baebb90b34b31800fcb9978bc6fd2~mv2.jpeg'),
 public_description=coalesce(t.public_description,'US based melee team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Meadows','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Sloma','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyllian Twiss','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Hartke','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James coughlin','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Fortin','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Straub','captain','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blade Pool','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jamezie Helenski','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Sanner','fighter','bi_teams','https://www.buhurtinternational.com/team/company-of-the-pale-horse','company-of-the-pale-horse',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='crimson-tulips' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-crimson-tulips' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Crimson Tulips','Eastern Canada',true,'active','public','bi-crimson-tulips','NA','North America','CA','Canada','gen.scallagrims@gmail.com',NULL,'https://static.wixstatic.com/media/4da8f8_2a3fa59ce7034449b1b26bccb7a17fdd~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','crimson-tulips','https://www.buhurtinternational.com/team/crimson-tulips','Crimson Tulips','Eastern Canada','gen.scallagrims@gmail.com',NULL,20,'{"biCollectionId":"1b76392a-9bb1-433f-8064-0b6c817d59ac","teamName":"Crimson Tulips","club":null,"gender":"Female","captain":"Genevieve Drouin","conference":"North America","country":"Canada","city":"Eastern Canada","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"gen.scallagrims@gmail.com","teamLogo":"wix:image://v1/4da8f8_2a3fa59ce7034449b1b26bccb7a17fdd~mv2.png/Tulip%20logo%20-%20square%20b&w2.png#originWidth=1062&originHeight=1130","logoUrl":"https://static.wixstatic.com/media/4da8f8_2a3fa59ce7034449b1b26bccb7a17fdd~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":3,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":3,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":6,"remainingTokens":8,"tournaments":[{"_id":"1","points":6,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":4}]}},"members":["Genevieve Drouin","Marie-Soleil Grenier","Lindsay McRae","Anne Von Wesselborg","Madison Hartke","Kaylee Knapp","Gabrielle Bastieri","Laura Carnes"],"sourceCreatedAt":"2024-07-13T16:22:17.648Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Crimson Tulips',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Eastern Canada',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'gen.scallagrims@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4da8f8_2a3fa59ce7034449b1b26bccb7a17fdd~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Genevieve Drouin','captain','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marie-Soleil Grenier','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lindsay McRae','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anne Von Wesselborg','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Madison Hartke','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kaylee Knapp','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabrielle Bastieri','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laura Carnes','fighter','bi_teams','https://www.buhurtinternational.com/team/crimson-tulips','crimson-tulips',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='czech-lions' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-czech-lions' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Czech Lions',NULL,true,'active','public','bi-czech-lions','EU','Europe','CZ','Czech Republic','jan.burgerstein@gamil.com',NULL,'https://static.wixstatic.com/media/994d17_39a29bc9c32d41b3a00264097173fe08~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','czech-lions','https://www.buhurtinternational.com/team/czech-lions','Czech Lions',NULL,'jan.burgerstein@gamil.com',NULL,20,'{"biCollectionId":"56599f01-8cc5-4eea-a71c-c0a6db195ad2","teamName":"Czech Lions","club":null,"gender":"Male","captain":"Jan Burgerstein","conference":"Europe","country":"Czech Republic","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"CZ","name":"Czechia","type":"COUNTRY"}],"location":{"latitude":49.81749199999999,"longitude":15.472962},"streetAddress":{"apt":"","formattedAddressLine":"Czechia","name":"","number":""},"formatted":"Czechia","country":"CZ"},"websiteFacebookUrl":null,"teamEmail":"jan.burgerstein@gamil.com","teamLogo":"wix:image://v1/994d17_39a29bc9c32d41b3a00264097173fe08~mv2.jpg/lev%20foto.jpg#originWidth=3147&originHeight=1748","logoUrl":"https://static.wixstatic.com/media/994d17_39a29bc9c32d41b3a00264097173fe08~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":13,"remainingTokens":8,"tournaments":[{"_id":"1","points":13,"Tournament":"Rattay Tourney 2025","date":"2025-06-14","category":"5vs5","place":1}]}},"members":["Jan Burgerstein","Vojta Pecha"],"sourceCreatedAt":"2025-05-18T16:50:48.934Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Czech Lions',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Czech Republic',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jan.burgerstein@gamil.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/994d17_39a29bc9c32d41b3a00264097173fe08~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jan Burgerstein','captain','bi_teams','https://www.buhurtinternational.com/team/czech-lions','czech-lions',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vojta Pecha','fighter','bi_teams','https://www.buhurtinternational.com/team/czech-lions','czech-lions',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dallas-lancers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dallas-lancers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dallas Lancers','Carrollton',true,'active','public','bi-dallas-lancers','NA','North America','US','United States','ethan.forbes01@gmail.com','https://www.facebook.com/ethan.forbes01','https://static.wixstatic.com/media/098382_a46765b0033241a6972b52adb88a731b~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dallas-lancers','https://www.buhurtinternational.com/team/dallas-lancers','Dallas Lancers','Carrollton','ethan.forbes01@gmail.com','https://www.facebook.com/ethan.forbes01',20,'{"biCollectionId":"0690a8d2-309e-4e21-9942-8d68f22cce75","teamName":"Dallas Lancers","club":null,"gender":"Male","captain":"Ethan A. Forbes","conference":"North America","country":"United States","city":"Carrollton","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"930-940 N Belt Line Rd, Irving, TX 75061"},"websiteFacebookUrl":"https://www.facebook.com/ethan.forbes01","teamEmail":"ethan.forbes01@gmail.com","teamLogo":"wix:image://v1/098382_a46765b0033241a6972b52adb88a731b~mv2.png/Dallas%20Dragoons%20Logo%20Clean.png#originWidth=1024&originHeight=1142","logoUrl":"https://static.wixstatic.com/media/098382_a46765b0033241a6972b52adb88a731b~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Ethan A. Forbes","Curtis holtrop","Travis Spradling","William Deputy","Victor Guevara","Brett Finnell","Charles Boswell"],"sourceCreatedAt":"2026-08-28T17:54:38.324Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dallas Lancers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Carrollton',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ethan.forbes01@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ethan.forbes01'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/098382_a46765b0033241a6972b52adb88a731b~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan A. Forbes','captain','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Curtis holtrop','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Travis Spradling','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Deputy','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Victor Guevara','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brett Finnell','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charles Boswell','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-lancers','dallas-lancers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dallas-mythics' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dallas-mythics' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dallas Mythics','Dallas',true,'active','public','bi-dallas-mythics','NA','North America','US','United States','thedallasmythics@gmail.com','https://www.facebook.com/thedallasmythics','https://static.wixstatic.com/media/4a5ef7_5800c427e85e4c379eb36210cb24adf4~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dallas-mythics','https://www.buhurtinternational.com/team/dallas-mythics','Dallas Mythics','Dallas','thedallasmythics@gmail.com','https://www.facebook.com/thedallasmythics',20,'{"biCollectionId":"6ac52541-057b-4413-ae52-9879d5106599","teamName":"Dallas Mythics","club":null,"gender":"Female","captain":"Shanna Knight","conference":"North America","country":"United States","city":"Dallas","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/thedallasmythics","teamEmail":"thedallasmythics@gmail.com","teamLogo":"wix:image://v1/4a5ef7_5800c427e85e4c379eb36210cb24adf4~mv2.jpg/mythics.jpg#originWidth=1596&originHeight=1596","logoUrl":"https://static.wixstatic.com/media/4a5ef7_5800c427e85e4c379eb36210cb24adf4~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":18,"rank12v12":null,"points12v12":8,"tournamentsJoined":[{"_id":"1","points":8,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"12vs12","place":1},{"_id":"2","points":9,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":1},{"_id":"3","points":9,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":24,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":1},{"_id":"2","points":8,"Tournament":"Dragon''s Cup 2024","date":"2024-08-31","category":"5vs5","place":1},{"_id":"3","points":8,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":1}]},"2025":{"tournaments":[{"_id":"1","points":16,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":3},{"_id":"2","points":15,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":1},{"_id":"3","points":6,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":12.33,"rank5v5":1,"remainingTokens":10,"points5v5":37}},"members":["Lauryn Lueken","Anna Metz","Kayla Forbes","Kayla Scarponi","Shanna Knight","Tyrle McDaniel","Caitlin Revanna","Beau Lee","Maenad Wilder","McKenzie Karickhoff","Jessica Hart","Katie Crosby","Hannah Elizabeth Crespo"],"sourceCreatedAt":"2023-09-14T14:42:38.829Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dallas Mythics',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dallas',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'thedallasmythics@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/thedallasmythics'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4a5ef7_5800c427e85e4c379eb36210cb24adf4~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lauryn Lueken','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anna Metz','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayla Forbes','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kayla Scarponi','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shanna Knight','captain','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyrle McDaniel','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caitlin Revanna','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Beau Lee','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maenad Wilder','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'McKenzie Karickhoff','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jessica Hart','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Katie Crosby','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hannah Elizabeth Crespo','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics','dallas-mythics',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dallas-mythics-red' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dallas-mythics-red' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dallas Mythics Red','Dallas',true,'active','public','bi-dallas-mythics-red','NA','North America','US','United States','thedallasmythics@gmail.com','http://www.facebook.com/thedallasmythics','https://static.wixstatic.com/media/182b90_804be9af27094ac681cfa562f2e152fb~mv2.jpg','The Dallas Mythics are the premier women&#x27;s team in the United States and one of the top armored combat teams in the world. We train at Lone Star Combat Academy. Reach out to us for more information!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dallas-mythics-red','https://www.buhurtinternational.com/team/dallas-mythics-red','Dallas Mythics Red','Dallas','thedallasmythics@gmail.com','http://www.facebook.com/thedallasmythics',20,'{"biCollectionId":"bb173ae4-1ae6-47b7-a385-72f855ff4682","teamName":"Dallas Mythics Red","club":null,"gender":"Female","captain":"Shanna Knight","conference":"North America","country":"United States","city":"Dallas","teamInfo":"The Dallas Mythics are the premier women&#x27;s team in the United States and one of the top armored combat teams in the world. We train at Lone Star Combat Academy. Reach out to us for more information!","trainingInfo":"Once you have reached out to us, we have all the equipment you&#x27;ll need! Show up with athletic clothes (pants only, no shorts!) and groin protection and get ready to have the time of your life!","trainingLocation":{"subdivisions":[{"code":"TX","name":"Texas","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Dallas County","name":"Dallas County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Irving","name":"Irving","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Irving","location":{"latitude":32.8346256,"longitude":-96.91333329999999},"streetAddress":{"apt":"suite 108","formattedAddressLine":"1915 Peters Rd suite 108","name":"Peters Road","number":"1915"},"formatted":"1915 Peters Rd suite 108, Irving, TX 75061, USA","country":"US","postalCode":"75061-3243","subdivision":"TX"},"websiteFacebookUrl":"http://www.facebook.com/thedallasmythics","teamEmail":"thedallasmythics@gmail.com","teamLogo":"wix:image://v1/182b90_804be9af27094ac681cfa562f2e152fb~mv2.jpg/Mythics%20logo%20-%20reversed.jpg#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/182b90_804be9af27094ac681cfa562f2e152fb~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":2}]},"2025":{"remainingTokens":10}},"members":["Shanna Knight","Julee Slovacek","Kathryn Anne Bryan","Emma Hampton"],"sourceCreatedAt":"2024-09-11T21:03:04.047Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dallas Mythics Red',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Dallas',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'thedallasmythics@gmail.com'),
 website_url=coalesce(t.website_url,'http://www.facebook.com/thedallasmythics'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/182b90_804be9af27094ac681cfa562f2e152fb~mv2.jpg'),
 public_description=coalesce(t.public_description,'The Dallas Mythics are the premier women&#x27;s team in the United States and one of the top armored combat teams in the world. We train at Lone Star Combat Academy. Reach out to us for more information!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shanna Knight','captain','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics-red','dallas-mythics-red',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julee Slovacek','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics-red','dallas-mythics-red',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kathryn Anne Bryan','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics-red','dallas-mythics-red',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emma Hampton','fighter','bi_teams','https://www.buhurtinternational.com/team/dallas-mythics-red','dallas-mythics-red',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='dauntless-armored-combat' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-dauntless-armored-combat' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Dauntless Armored Combat','Knoxville',true,'active','public','bi-dauntless-armored-combat','NA','North America','US','United States','mckinneyjwlll@gmail.com','https://www.facebook.com/share/g/1AFg6rxtx8/?mibextid=wwXIfr','https://static.wixstatic.com/media/a7960f_9346502f48614277a952639c974b72e9~mv2.jpg','Dauntless Armored Combat: Knoxville’s Premier Medieval Combat Team Dauntless Armored Combat is a dedicated medieval combat team based in Knoxville, Tennessee, specializing in the thrilling sport of Buhurt. Founded two years ago, Dauntless has quickly become a staple in the East Tennessee combat scene, hosting regular events and tournaments that bring history to life with real steel and real battles. Our Events • Home Venue: Schultz Brau Brewing Company, where we host bi-monthly combat showcases. • Ritterfest: Every April, Dauntless organizes an international Buhurt tournament as part of Schultz Brau’s Ritter Fest—a celebration of medieval culture featuring battling knights, merchants, and music. • Tournaments: Our team competes nationally at events like Carolina Carnage, US Nationals, and the Arnold Sports Classic. Join Us • Practice Sessions: Every Sunday at 2 pm Schultz Brau Brewing’s outdoor practice yard. Newcomers are welcome! • Gear & Training: We provide soft gear, loaner armor, and expert instruction to help you master Buhurt techniques. Whether you’re a seasoned fighter or just curious about medieval combat, Dauntless Armored Combat invites you to join the action. Follow us on Instagram for updates and event announcements')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','dauntless-armored-combat','https://www.buhurtinternational.com/team/dauntless-armored-combat','Dauntless Armored Combat','Knoxville','mckinneyjwlll@gmail.com','https://www.facebook.com/share/g/1AFg6rxtx8/?mibextid=wwXIfr',20,'{"biCollectionId":"dacccf3a-2803-4d2a-8e7f-2b0150e795dd","teamName":"Dauntless Armored Combat","club":null,"gender":"Male","captain":"JW McKinney","conference":"North America","country":"United States","city":"Knoxville","teamInfo":"Dauntless Armored Combat: Knoxville’s Premier Medieval Combat Team Dauntless Armored Combat is a dedicated medieval combat team based in Knoxville, Tennessee, specializing in the thrilling sport of Buhurt. Founded two years ago, Dauntless has quickly become a staple in the East Tennessee combat scene, hosting regular events and tournaments that bring history to life with real steel and real battles. Our Events • Home Venue: Schultz Brau Brewing Company, where we host bi-monthly combat showcases. • Ritterfest: Every April, Dauntless organizes an international Buhurt tournament as part of Schultz Brau’s Ritter Fest—a celebration of medieval culture featuring battling knights, merchants, and music. • Tournaments: Our team competes nationally at events like Carolina Carnage, US Nationals, and the Arnold Sports Classic. Join Us • Practice Sessions: Every Sunday at 2 pm Schultz Brau Brewing’s outdoor practice yard. Newcomers are welcome! • Gear & Training: We provide soft gear, loaner armor, and expert instruction to help you master Buhurt techniques. Whether you’re a seasoned fighter or just curious about medieval combat, Dauntless Armored Combat invites you to join the action. Follow us on Instagram for updates and event announcements","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"TN","name":"Tennessee","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Knox County","name":"Knox County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Knoxville","name":"Knoxville","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Knoxville","location":{"latitude":35.9770738,"longitude":-83.9261403},"streetAddress":{"apt":"","formattedAddressLine":"126 Bernard Ave","name":"Bernard Avenue","number":"126"},"formatted":"126 Bernard Ave, Knoxville, TN 37917, USA","country":"US","postalCode":"37917-7116","subdivision":"TN"},"websiteFacebookUrl":"https://www.facebook.com/share/g/1AFg6rxtx8/?mibextid=wwXIfr","teamEmail":"mckinneyjwlll@gmail.com","teamLogo":"wix:image://v1/a7960f_9346502f48614277a952639c974b72e9~mv2.jpg/IMG_1334.JPG#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/a7960f_9346502f48614277a952639c974b72e9~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":10},{"_id":"2","points":0,"Tournament":"3rd Annual Ritterfest 2026","date":"2026-04-11","category":"5vs5","place":7}],"eventsHistory":{"2024":{},"2025":{"points12v12":6,"points5v5":0,"remainingTokens":8,"tournaments":[{"_id":"1","points":6,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":3}]}},"members":["JW McKinney","Christopher Zachary","Keegan kooch","Terry Jenkins","William Hayes","Zachary tyler reaves","Matthew Patterson","Jake Hinkle"],"sourceCreatedAt":"2025-04-07T13:14:29.511Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Dauntless Armored Combat',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Knoxville',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mckinneyjwlll@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/g/1AFg6rxtx8/?mibextid=wwXIfr'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a7960f_9346502f48614277a952639c974b72e9~mv2.jpg'),
 public_description=coalesce(t.public_description,'Dauntless Armored Combat: Knoxville’s Premier Medieval Combat Team Dauntless Armored Combat is a dedicated medieval combat team based in Knoxville, Tennessee, specializing in the thrilling sport of Buhurt. Founded two years ago, Dauntless has quickly become a staple in the East Tennessee combat scene, hosting regular events and tournaments that bring history to life with real steel and real battles. Our Events • Home Venue: Schultz Brau Brewing Company, where we host bi-monthly combat showcases. • Ritterfest: Every April, Dauntless organizes an international Buhurt tournament as part of Schultz Brau’s Ritter Fest—a celebration of medieval culture featuring battling knights, merchants, and music. • Tournaments: Our team competes nationally at events like Carolina Carnage, US Nationals, and the Arnold Sports Classic. Join Us • Practice Sessions: Every Sunday at 2 pm Schultz Brau Brewing’s outdoor practice yard. Newcomers are welcome! • Gear & Training: We provide soft gear, loaner armor, and expert instruction to help you master Buhurt techniques. Whether you’re a seasoned fighter or just curious about medieval combat, Dauntless Armored Combat invites you to join the action. Follow us on Instagram for updates and event announcements'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'JW McKinney','captain','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Zachary','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Keegan kooch','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Terry Jenkins','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Hayes','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary tyler reaves','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Patterson','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Hinkle','fighter','bi_teams','https://www.buhurtinternational.com/team/dauntless-armored-combat','dauntless-armored-combat',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='de-bockenreyders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-de-bockenreyders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'De Bockenreyders','Brecht',true,'active','public','bi-de-bockenreyders','EU','Europe','BE','Belgium','bockenreydersmc@gmail.com','https://www.facebook.com/Bockenreyders','https://static.wixstatic.com/media/bc08f8_1c7a880d570b43308eb8719a78bb40a7~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','de-bockenreyders','https://www.buhurtinternational.com/team/de-bockenreyders','De Bockenreyders','Brecht','bockenreydersmc@gmail.com','https://www.facebook.com/Bockenreyders',20,'{"biCollectionId":"f7861899-775d-4d2d-8ec5-a5897a8f4026","teamName":"De Bockenreyders","club":null,"gender":"Male","captain":"Thorgal Van Looy","conference":"Europe","country":"Belgium","city":"Brecht","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/Bockenreyders","teamEmail":"bockenreydersmc@gmail.com","teamLogo":"wix:image://v1/bc08f8_1c7a880d570b43308eb8719a78bb40a7~mv2.png/BockenReyders.png#originWidth=850&originHeight=850","logoUrl":"https://static.wixstatic.com/media/bc08f8_1c7a880d570b43308eb8719a78bb40a7~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":13}]},"2025":{"remainingTokens":10}},"members":["Thorgal Van Looy","Rubén Zurlo Serrano","Stef Poppeliers","Thijs Boekhout"],"sourceCreatedAt":"2023-09-13T17:04:18.115Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('De Bockenreyders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Brecht',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('BE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Belgium',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'bockenreydersmc@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/Bockenreyders'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/bc08f8_1c7a880d570b43308eb8719a78bb40a7~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thorgal Van Looy','captain','bi_teams','https://www.buhurtinternational.com/team/de-bockenreyders','de-bockenreyders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rubén Zurlo Serrano','fighter','bi_teams','https://www.buhurtinternational.com/team/de-bockenreyders','de-bockenreyders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stef Poppeliers','fighter','bi_teams','https://www.buhurtinternational.com/team/de-bockenreyders','de-bockenreyders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thijs Boekhout','fighter','bi_teams','https://www.buhurtinternational.com/team/de-bockenreyders','de-bockenreyders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='death-dealers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-death-dealers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Death Dealers','Las Vegas',true,'active','public','bi-death-dealers','NA','North America','US','United States','tinoco.trston@yahoo.com','https://www.facebook.com/profile.php?id=61565116917524','https://static.wixstatic.com/media/b365fb_d61c8aedf47049099122d0ac80ce3909~mv2.png','EST 2019 - Las Vegas Buhurt Team')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','death-dealers','https://www.buhurtinternational.com/team/death-dealers','Death Dealers','Las Vegas','tinoco.trston@yahoo.com','https://www.facebook.com/profile.php?id=61565116917524',20,'{"biCollectionId":"afa7ac31-6a1c-49c5-a882-7d79d2bcb3ac","teamName":"Death Dealers","club":null,"gender":"Male","captain":"Triston Tinoco","conference":"North America","country":"United States","city":"Las Vegas","teamInfo":"EST 2019 - Las Vegas Buhurt Team","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=61565116917524","teamEmail":"tinoco.trston@yahoo.com","teamLogo":"wix:image://v1/b365fb_d61c8aedf47049099122d0ac80ce3909~mv2.png/ChatGPT%20Image%20Aug%2010,%202026,%2005_38_48%20PM.png#originWidth=1254&originHeight=1254","logoUrl":"https://static.wixstatic.com/media/b365fb_d61c8aedf47049099122d0ac80ce3909~mv2.png","rank5v5":13,"averagePoints5v5":2.67,"points5v5":9.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":9},{"_id":"2","points":2,"Tournament":"CoS Trials of Ursus 2026","date":"2026-03-06","category":"5vs5","place":4},{"_id":"3","points":1.25,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":8},{"_id":"4","points":4,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":4}],"eventsHistory":{"2024":{},"2025":{"tournaments":[{"_id":"1","points":1,"Tournament":"Testudo Bellum 2025","date":"2025-03-08","category":"5vs5","place":7},{"_id":"2","points":1,"Tournament":"Ventura Melee Megabowl 2025","date":"2025-05-24","category":"5vs5","place":6},{"_id":"3","points":0,"Tournament":"California Classic 2025","date":"2025-09-20","category":"5vs5","place":7}],"points12v12":0,"averagePoints5v5":0.67,"rank5v5":19,"remainingTokens":10,"points5v5":2}},"members":["Triston Tinoco","Kane Womack","Caleb Cole","Sebastian Vasquez","Mark Galvez","Erik Gottenborg","Alexander Dreyfus","Dylan Clifton","Corey turpin","Skyler Manganello","Jonathan nicastro","Frank Santana","Christopher Robbin Bunac"],"sourceCreatedAt":"2025-02-15T18:14:28.784Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Death Dealers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Las Vegas',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'tinoco.trston@yahoo.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=61565116917524'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b365fb_d61c8aedf47049099122d0ac80ce3909~mv2.png'),
 public_description=coalesce(t.public_description,'EST 2019 - Las Vegas Buhurt Team'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Triston Tinoco','captain','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kane Womack','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Caleb Cole','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sebastian Vasquez','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark Galvez','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erik Gottenborg','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Dreyfus','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Clifton','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Corey turpin','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Skyler Manganello','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan nicastro','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Frank Santana','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christopher Robbin Bunac','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers','death-dealers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='death-dealers-umbra' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-death-dealers-umbra' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Death Dealers Umbra','Las Vegas',true,'active','public','bi-death-dealers-umbra','NA','North America','US','United States','deathdealersLV@gmail.com',NULL,'https://static.wixstatic.com/media/35dcee_ae289a5f70fe4422bbbf78a22c9d8706~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','death-dealers-umbra','https://www.buhurtinternational.com/team/death-dealers-umbra','Death Dealers Umbra','Las Vegas','deathdealersLV@gmail.com',NULL,20,'{"biCollectionId":"61b3f97e-bcf8-4053-b5c5-897bb0e7f6c0","teamName":"Death Dealers Umbra","club":null,"gender":"Male","captain":"James Frey","conference":"North America","country":"United States","city":"Las Vegas","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"deathdealersLV@gmail.com","teamLogo":"wix:image://v1/35dcee_ae289a5f70fe4422bbbf78a22c9d8706~mv2.png/Death%20Dealer%20Umbra%20Logo.png#originWidth=1254&originHeight=1254","logoUrl":"https://static.wixstatic.com/media/35dcee_ae289a5f70fe4422bbbf78a22c9d8706~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"California Classic 2026","date":"2026-09-19","category":"5vs5","place":8}],"eventsHistory":{},"members":["James frey","Scott Gregory","Taylor John Hummon","Damien Greenwell","Dja''Afar Hardiono","Isaiah Melendez","Shawn Wood","Jaivon Harris","Enrique Ivan Rueda"],"sourceCreatedAt":"2026-08-19T05:24:05.846Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Death Dealers Umbra',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Las Vegas',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'deathdealersLV@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/35dcee_ae289a5f70fe4422bbbf78a22c9d8706~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James frey','captain','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Scott Gregory','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taylor John Hummon','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Damien Greenwell','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dja''Afar Hardiono','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isaiah Melendez','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shawn Wood','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jaivon Harris','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Enrique Ivan Rueda','fighter','bi_teams','https://www.buhurtinternational.com/team/death-dealers-umbra','death-dealers-umbra',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='death-jesters' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-death-jesters' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Death Jesters','Portland, Oregon',true,'active','public','bi-death-jesters','NA','North America','US','United States','deathjesters@gmail.com','https://www.facebook.com/groups/196093453592197','https://static.wixstatic.com/media/132c5f_93ae20c654d34718a958f95fbdfdbc48~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','death-jesters','https://www.buhurtinternational.com/team/death-jesters','Death Jesters','Portland, Oregon','deathjesters@gmail.com','https://www.facebook.com/groups/196093453592197',20,'{"biCollectionId":"56f057cf-358c-4302-9f14-6aeccfd8b604","teamName":"Death Jesters","club":null,"gender":"Male","captain":"Troy Toney","conference":"North America","country":"United States","city":"Portland, Oregon","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/groups/196093453592197","teamEmail":"deathjesters@gmail.com","teamLogo":"wix:image://v1/132c5f_93ae20c654d34718a958f95fbdfdbc48~mv2.jpg/429110272_417817910750535_2686835109391832584_n.jpg#originWidth=1080&originHeight=1054","logoUrl":"https://static.wixstatic.com/media/132c5f_93ae20c654d34718a958f95fbdfdbc48~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":10,"tournaments":[{"_id":"1","points":1,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":5},{"_id":"2","points":0,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":6}]}},"members":["Troy Toney","Mathurin Fogg","Samuel  OBERON Morgan","Kyle Abernathy","Matthew Courtnay","Zander Scott"],"sourceCreatedAt":"2025-09-12T05:19:55.163Z","sourceUpdatedAt":"2026-09-24T20:26:27.119Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Death Jesters',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Portland, Oregon',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'deathjesters@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/groups/196093453592197'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/132c5f_93ae20c654d34718a958f95fbdfdbc48~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Troy Toney','captain','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mathurin Fogg','fighter','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel  OBERON Morgan','fighter','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Abernathy','fighter','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Courtnay','fighter','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zander Scott','fighter','bi_teams','https://www.buhurtinternational.com/team/death-jesters','death-jesters',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='decima' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-decima' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Liekedeeler','Hamburg',true,'active','public','bi-decima','EU','Europe','DE','Germany','swordfightdecima@gmail.com','Liekedeeler-buhurt.com','https://static.wixstatic.com/media/510ae0_504c78fcf2194abdab11c03d73c6d551~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','decima','https://www.buhurtinternational.com/team/decima','Liekedeeler','Hamburg','swordfightdecima@gmail.com','Liekedeeler-buhurt.com',20,'{"biCollectionId":"4b1cfcd8-543d-4863-b726-2e37f897f418","teamName":"Liekedeeler","club":null,"gender":"Male","captain":"Maximilian Splettstößer","conference":"Europe","country":"Germany","city":"Hamburg","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"Liekedeeler-buhurt.com","teamEmail":"swordfightdecima@gmail.com","teamLogo":"wix:image://v1/510ae0_504c78fcf2194abdab11c03d73c6d551~mv2.jpg/IMG-20251014-WA0012.jpg#originWidth=1024&originHeight=1024","logoUrl":"https://static.wixstatic.com/media/510ae0_504c78fcf2194abdab11c03d73c6d551~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Swaiut Toringi Cup 2026","date":"2026-04-25","category":"5vs5","place":12}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":5,"Tournament":"Swaiut Toringi Cup 2024","date":"2024-06-08","category":"5vs5","place":4},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":5}]},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Swaiut Toringi Cup 2025","date":"2025-05-03","category":"5vs5","place":12}]}},"members":["Jens Stöhr","Alexander Krupp","Maximilian Splettstößer","Simon Schröder","Alfons Henning","Max Heinze","Karsten Fricke","Waldemar Wiedenmeier","Niklas Wehrmann","Henri Diers","Raphael Stoll","Robin Diers"],"sourceCreatedAt":"2024-06-16T18:06:40.476Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Liekedeeler',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hamburg',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('DE',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Germany',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'swordfightdecima@gmail.com'),
 website_url=coalesce(t.website_url,'Liekedeeler-buhurt.com'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/510ae0_504c78fcf2194abdab11c03d73c6d551~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jens Stöhr','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Krupp','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maximilian Splettstößer','captain','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Schröder','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alfons Henning','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Max Heinze','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karsten Fricke','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Waldemar Wiedenmeier','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niklas Wehrmann','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Henri Diers','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Raphael Stoll','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robin Diers','fighter','bi_teams','https://www.buhurtinternational.com/team/decima','decima',now());
end $$;
commit;
