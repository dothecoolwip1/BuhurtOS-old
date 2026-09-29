begin;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tallàe-fer' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tallàe-fer' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tallàe Fer','Angoulême',true,'active','public','bi-tallàe-fer','EU','Europe','FR','France','lucien.antignyriquet@gmail.com','https://www.facebook.com/angoulemebehourd','https://static.wixstatic.com/media/7fa497_4768544a9d9a4b0c9073d5d954a349f9~mv2.jpg','Club de Béhourd basé en Charente. Combat en ligue 1 du circuit Français.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tallàe-fer','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','Tallàe Fer','Angoulême','lucien.antignyriquet@gmail.com','https://www.facebook.com/angoulemebehourd',20,'{"biCollectionId":"c55b4c9c-8354-4426-9e2b-97192a4911d5","teamName":"Tallàe Fer","club":null,"gender":"Male","captain":"Julien Baltazat","conference":"Europe","country":"France","city":"Angoulême","teamInfo":"Club de Béhourd basé en Charente. Combat en ligue 1 du circuit Français.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.facebook.com/angoulemebehourd","teamEmail":"lucien.antignyriquet@gmail.com","teamLogo":"wix:image://v1/7fa497_4768544a9d9a4b0c9073d5d954a349f9~mv2.jpg/248659160_397134058805274_1858514973347428004_n.jpg#originWidth=1875&originHeight=1875","logoUrl":"https://static.wixstatic.com/media/7fa497_4768544a9d9a4b0c9073d5d954a349f9~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Tournoi de Montby 2025","date":"2025-03-29","category":"5vs5","place":9},{"_id":"2","points":0,"Tournament":"Tournoi de Saint-Lô 2025","date":"2025-05-17","category":"5vs5","place":8}]}},"members":["Jérémy KLEIN","Florent Doyonnas","Jouffe Lenaic","Maxime OLIVON","Julien baltazat","Berthonnaud Samuel","Adrien Pilato"],"sourceCreatedAt":"2024-06-28T15:56:04.893Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tallàe Fer',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Angoulême',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FR',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('France',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'lucien.antignyriquet@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/angoulemebehourd'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7fa497_4768544a9d9a4b0c9073d5d954a349f9~mv2.jpg'),
 public_description=coalesce(t.public_description,'Club de Béhourd basé en Charente. Combat en ligue 1 du circuit Français.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jérémy KLEIN','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Florent Doyonnas','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jouffe Lenaic','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maxime OLIVON','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julien baltazat','captain','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Berthonnaud Samuel','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrien Pilato','fighter','bi_teams','https://www.buhurtinternational.com/team/tall%C3%A0e-fer','tallàe-fer',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='taurus-mfc' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-taurus-mfc' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Taurus mfc','Torino ',true,'active','public','bi-taurus-mfc','EU','Europe','IT','Italy','Taurus Medieval Fight Club <taurus.medievalfight@gmail.com>','https://www.taurus-mfc.it/?fbclid=IwAR1hB3W5-IrQWedFyhCe1_WWWHeJsJF_UaNoodsITQzI_KtlKTr3RzqeSHY','https://static.wixstatic.com/media/07c36a_6f71a1f6a699469796990f2b01ad0f0d~mv2.jpg','In 2015, some of the athletes with the greatest international experience in Italy decided to found the first Turin ASD that deals with Medieval Full Contact, calling it "Taurus MFC". The newly formed team immediately gave an extremely sporting edge to its DNA and quickly achieved results and acclaim both locally and internationally. The Taurus are in fact present in all the main Italian tournaments and in all the categories designed for this sport. At the moment the team is active with 2 gyms, one in Turin and one in Piacenza with 2 training sessions per week both with soft equipment and full armour.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','taurus-mfc','https://www.buhurtinternational.com/team/taurus-mfc','Taurus mfc','Torino ','Taurus Medieval Fight Club <taurus.medievalfight@gmail.com>','https://www.taurus-mfc.it/?fbclid=IwAR1hB3W5-IrQWedFyhCe1_WWWHeJsJF_UaNoodsITQzI_KtlKTr3RzqeSHY',20,'{"biCollectionId":"4ba290c2-3213-44cc-971d-3300ee1ca9a4","teamName":"Taurus mfc","club":null,"gender":"Male","captain":"Samuel Cogerino","conference":"Europe","country":"Italy","city":"Torino ","teamInfo":"In 2015, some of the athletes with the greatest international experience in Italy decided to found the first Turin ASD that deals with Medieval Full Contact, calling it \"Taurus MFC\". The newly formed team immediately gave an extremely sporting edge to its DNA and quickly achieved results and acclaim both locally and internationally. The Taurus are in fact present in all the main Italian tournaments and in all the categories designed for this sport. At the moment the team is active with 2 gyms, one in Turin and one in Piacenza with 2 training sessions per week both with soft equipment and full armour.","trainingInfo":"","trainingLocation":{"formatted":"10055 Condove, Metropolitan City of Turin, Italy"},"websiteFacebookUrl":"https://www.taurus-mfc.it/?fbclid=IwAR1hB3W5-IrQWedFyhCe1_WWWHeJsJF_UaNoodsITQzI_KtlKTr3RzqeSHY","teamEmail":"Taurus Medieval Fight Club <taurus.medievalfight@gmail.com>","teamLogo":"wix:image://v1/07c36a_6f71a1f6a699469796990f2b01ad0f0d~mv2.jpg/FB_IMG_1694126695482.jpg#originWidth=1080&originHeight=1116","logoUrl":"https://static.wixstatic.com/media/07c36a_6f71a1f6a699469796990f2b01ad0f0d~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":7}]},"2025":{"remainingTokens":6}},"members":["Dario Davi","Giacomo Munaretti","Luca Davi","Davide Rospi","Stefano Canella","Nicola Loda","Samuel Cogerino","Dario Cianci","Luca Vallò"],"sourceCreatedAt":"2023-09-07T23:50:11.105Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Taurus mfc',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Torino ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('IT',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Italy',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Taurus Medieval Fight Club <taurus.medievalfight@gmail.com>'),
 website_url=coalesce(t.website_url,'https://www.taurus-mfc.it/?fbclid=IwAR1hB3W5-IrQWedFyhCe1_WWWHeJsJF_UaNoodsITQzI_KtlKTr3RzqeSHY'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/07c36a_6f71a1f6a699469796990f2b01ad0f0d~mv2.jpg'),
 public_description=coalesce(t.public_description,'In 2015, some of the athletes with the greatest international experience in Italy decided to found the first Turin ASD that deals with Medieval Full Contact, calling it "Taurus MFC". The newly formed team immediately gave an extremely sporting edge to its DNA and quickly achieved results and acclaim both locally and internationally. The Taurus are in fact present in all the main Italian tournaments and in all the categories designed for this sport. At the moment the team is active with 2 gyms, one in Turin and one in Piacenza with 2 training sessions per week both with soft equipment and full armour.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dario Davi','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Giacomo Munaretti','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Davi','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Davide Rospi','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stefano Canella','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicola Loda','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Cogerino','captain','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dario Cianci','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luca Vallò','fighter','bi_teams','https://www.buhurtinternational.com/team/taurus-mfc','taurus-mfc',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tavastia-armigeri' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tavastia-armigeri' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tavastia Armigeri','Hämeenlinna',true,'active','public','bi-tavastia-armigeri','EU','Europe','FI','Finland','tavastiaarmigeri@gmail.com','https://www.tavastiaarmigeri.fi','https://static.wixstatic.com/media/591d83_2bf3e16046984666a3ef5f415a2a85ec~mv2.jpeg','Tavastia Armigeri is established 2017. Many fighters of Armigeri has been active fighters in Norska (old BL team) and in Finnish National team.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tavastia-armigeri','https://www.buhurtinternational.com/team/tavastia-armigeri','Tavastia Armigeri','Hämeenlinna','tavastiaarmigeri@gmail.com','https://www.tavastiaarmigeri.fi',20,'{"biCollectionId":"dfc8d46f-868a-4739-a245-61bbb0e5ffe8","teamName":"Tavastia Armigeri","club":null,"gender":"Male","captain":"Antti Tarkkala","conference":"Europe","country":"Finland","city":"Hämeenlinna","teamInfo":"Tavastia Armigeri is established 2017. Many fighters of Armigeri has been active fighters in Norska (old BL team) and in Finnish National team.","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":"https://www.tavastiaarmigeri.fi","teamEmail":"tavastiaarmigeri@gmail.com","teamLogo":"wix:image://v1/591d83_2bf3e16046984666a3ef5f415a2a85ec~mv2.jpeg/IMG_2535.jpeg#originWidth=283&originHeight=373","logoUrl":"https://static.wixstatic.com/media/591d83_2bf3e16046984666a3ef5f415a2a85ec~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":6,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":3},{"_id":"2","points":4,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":4},{"_id":"3","points":4.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":6}]},"2025":{"remainingTokens":8}},"members":["Antti Tarkkala","Matias Karell","Vili Helminen","Kari Kivistö","Eero Virtanen","Risto Järvinen","Dave McKee","Juuso Sistonen","Jussi Timonen","Teemu Lindstedt","Niilo Murto","Toni Välimäki"],"sourceCreatedAt":"2023-08-16T17:26:57.551Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tavastia Armigeri',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Hämeenlinna',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'tavastiaarmigeri@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.tavastiaarmigeri.fi'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/591d83_2bf3e16046984666a3ef5f415a2a85ec~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Tavastia Armigeri is established 2017. Many fighters of Armigeri has been active fighters in Norska (old BL team) and in Finnish National team.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Antti Tarkkala','captain','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matias Karell','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vili Helminen','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kari Kivistö','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eero Virtanen','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Risto Järvinen','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dave McKee','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juuso Sistonen','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jussi Timonen','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Teemu Lindstedt','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niilo Murto','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Toni Välimäki','fighter','bi_teams','https://www.buhurtinternational.com/team/tavastia-armigeri','tavastia-armigeri',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-basilisk' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-basilisk' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Team Basilisk','Albury',true,'active','public','bi-team-basilisk','OC','Oceania','AU','Australia','BuhurtBasilisk@gmail.com','https://www.facebook.com/profile.php?id=100088125977143','https://static.wixstatic.com/media/3d1d34_4ab6c6c029e24fa39f8321fe2c1347ca~mv2.jpg','Team Basilisk is a new Australian Team located on the border of New South Wales and Victoria. We started in 2022 and have grown substantially over the course of 1 year with the outlook to expand further. We are a bunch of new bodies with a massive interest to the sport and are keen to get in and battle it out with our fellow fighters.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-basilisk','https://www.buhurtinternational.com/team/team-basilisk','Team Basilisk','Albury','BuhurtBasilisk@gmail.com','https://www.facebook.com/profile.php?id=100088125977143',20,'{"biCollectionId":"845d912e-bdd7-417c-b1f2-96911d22c58e","teamName":"Team Basilisk","club":null,"gender":"Male","captain":"Joshua Gordon","conference":"APAC","country":"Australia","city":"Albury","teamInfo":"Team Basilisk is a new Australian Team located on the border of New South Wales and Victoria. We started in 2022 and have grown substantially over the course of 1 year with the outlook to expand further. We are a bunch of new bodies with a massive interest to the sport and are keen to get in and battle it out with our fellow fighters.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/profile.php?id=100088125977143","teamEmail":"BuhurtBasilisk@gmail.com","teamLogo":"wix:image://v1/3d1d34_4ab6c6c029e24fa39f8321fe2c1347ca~mv2.jpg/Basilisk.jpg#originWidth=2048&originHeight=1231","logoUrl":"https://static.wixstatic.com/media/3d1d34_4ab6c6c029e24fa39f8321fe2c1347ca~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":0,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":10}]}},"members":["Joshua Gordon","Jordan Clough","Samuel Walsh-Rajnsz","Kyle Mills","Thomas allen","Roland Touzel","Jonathon Meyers"],"sourceCreatedAt":"2023-09-25T11:56:16.813Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Team Basilisk',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Albury',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'BuhurtBasilisk@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/profile.php?id=100088125977143'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/3d1d34_4ab6c6c029e24fa39f8321fe2c1347ca~mv2.jpg'),
 public_description=coalesce(t.public_description,'Team Basilisk is a new Australian Team located on the border of New South Wales and Victoria. We started in 2022 and have grown substantially over the course of 1 year with the outlook to expand further. We are a bunch of new bodies with a massive interest to the sport and are keen to get in and battle it out with our fellow fighters.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Gordon','captain','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jordan Clough','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Walsh-Rajnsz','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kyle Mills','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Thomas allen','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Roland Touzel','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathon Meyers','fighter','bi_teams','https://www.buhurtinternational.com/team/team-basilisk','team-basilisk',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-havoc' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-havoc' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Team Havoc','Sydney',true,'active','public','bi-team-havoc','OC','Oceania','AU','Australia','markchenoweth@live.com','https://www.facebook.com/teamhavocAMC','https://static.wixstatic.com/media/542163_283f8b07f3d548e2bfa436171b14f894~mv2.png','Established in 2012 by just a handful of dedicated members, Club Havoc has grown into a cornerstone of Medieval Armoured Combat in Australia. By 2013, we proudly represented the nation as part of the Australian National Team at the Battle of the Nations and have competed in every world championship since. Our journey has taken us across the globe, from Mexico to Russia, battling in dozens of prestigious international tournaments. We are based out of our gym in Wetherill Park, affectionately known as "The Thedral" , where we host regular club training sessions.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-havoc','https://www.buhurtinternational.com/team/team-havoc','Team Havoc','Sydney','markchenoweth@live.com','https://www.facebook.com/teamhavocAMC',20,'{"biCollectionId":"597d95a6-0d2a-4eb1-a570-2f82bda34b59","teamName":"Team Havoc","club":null,"gender":"Male","captain":"Mark O’Connor","conference":"APAC","country":"Australia","city":"Sydney","teamInfo":"Established in 2012 by just a handful of dedicated members, Club Havoc has grown into a cornerstone of Medieval Armoured Combat in Australia. By 2013, we proudly represented the nation as part of the Australian National Team at the Battle of the Nations and have competed in every world championship since. Our journey has taken us across the globe, from Mexico to Russia, battling in dozens of prestigious international tournaments. We are based out of our gym in Wetherill Park, affectionately known as \"The Thedral\" , where we host regular club training sessions.","trainingInfo":"Club Havoc welcomes new fighters at any of our training sessions: Wedneday - Buhurt Training (throws, techniques and drills) (wear: regular gym attire). Thursday - Armoured Specfics (wear: steel armour) Saturday - Open Mat (wear: soft kit or steel armour).","trainingLocation":{"subdivisions":[{"code":"NSW","name":"New South Wales","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Fairfield","name":"Fairfield City Council","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Wetherill Park","name":"Wetherill Park","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Wetherill Park","location":{"latitude":-33.8466927,"longitude":150.9139732},"streetAddress":{"apt":"5","formattedAddressLine":"5/276 Victoria St","name":"Victoria Street","number":"276"},"formatted":"5/276 Victoria St, Wetherill Park NSW 2164, Australia","country":"AU","postalCode":"2164","subdivision":"NSW"},"websiteFacebookUrl":"https://www.facebook.com/teamhavocAMC","teamEmail":"markchenoweth@live.com","teamLogo":"wix:image://v1/542163_283f8b07f3d548e2bfa436171b14f894~mv2.png/IMG_7070.PNG#originWidth=3508&originHeight=4961","logoUrl":"https://static.wixstatic.com/media/542163_283f8b07f3d548e2bfa436171b14f894~mv2.png","rank5v5":3,"averagePoints5v5":8,"points5v5":26,"rank12v12":null,"points12v12":1,"tournamentsJoined":[{"_id":"1","points":6,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":3},{"_id":"2","points":8,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":3},{"_id":"3","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"12vs12","place":4},{"_id":"4","points":10,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":1},{"_id":"5","points":2,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":6}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":13,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"5vs5","place":1},{"_id":"2","points":10,"Tournament":"Winterfest 2024","date":"2024-07-06","category":"5vs5","place":2},{"_id":"3","points":4.5,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":4}]},"2025":{"tournaments":[{"_id":"1","points":5,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":4},{"_id":"2","points":14,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":1},{"_id":"3","points":12,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":2}],"points12v12":0,"averagePoints5v5":10.33,"rank5v5":1,"remainingTokens":2,"points5v5":31}},"members":["Mark O’Connor","Barry Dawson","Seth Micallef","Luke Woolnough","Andrew Worthington","Milan Pusara","Ryan Chenoweth","William Allen","Liam","Stephen Ramsay","James Nield","Tim meywes","Zachary Stevenson"],"sourceCreatedAt":"2023-08-10T04:56:23.823Z","sourceUpdatedAt":"2026-09-24T18:21:39.556Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Team Havoc',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sydney',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'markchenoweth@live.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/teamhavocAMC'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/542163_283f8b07f3d548e2bfa436171b14f894~mv2.png'),
 public_description=coalesce(t.public_description,'Established in 2012 by just a handful of dedicated members, Club Havoc has grown into a cornerstone of Medieval Armoured Combat in Australia. By 2013, we proudly represented the nation as part of the Australian National Team at the Battle of the Nations and have competed in every world championship since. Our journey has taken us across the globe, from Mexico to Russia, battling in dozens of prestigious international tournaments. We are based out of our gym in Wetherill Park, affectionately known as "The Thedral" , where we host regular club training sessions.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mark O’Connor','captain','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Barry Dawson','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Seth Micallef','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke Woolnough','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Worthington','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Milan Pusara','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ryan Chenoweth','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Allen','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stephen Ramsay','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Nield','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tim meywes','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Stevenson','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc','team-havoc',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-havoc-(f)' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-havoc-(f)' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Havoc Magpies','Sydney',true,'active','public','bi-team-havoc-(f)','OC','Oceania','AU','Australia','markchenoweth@live.com',NULL,'https://static.wixstatic.com/media/7ab0ce_36957293b7a34be8b3872e66865e2971~mv2.png','Women&#x27;s team for Club Havoc debuting as the Magpies in 2025!')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-havoc-(f)','https://www.buhurtinternational.com/team/team-havoc-(f)','Havoc Magpies','Sydney','markchenoweth@live.com',NULL,20,'{"biCollectionId":"444989a3-f9a0-4051-8b05-0cde7d8e7c60","teamName":"Havoc Magpies","club":null,"gender":"Female","captain":"Chelsie Wood-Jordan","conference":"APAC","country":"Australia","city":"Sydney","teamInfo":"Women&#x27;s team for Club Havoc debuting as the Magpies in 2025!","trainingInfo":"","trainingLocation":{"subdivisions":[{"code":"NSW","name":"New South Wales","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Camden","name":"Camden Council","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Leppington","name":"Leppington","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"AU","name":"Australia","type":"COUNTRY"}],"city":"Leppington","location":{"latitude":-33.9606874,"longitude":150.8187542},"streetAddress":{"apt":"","formattedAddressLine":"23 Cowpasture Rd","name":"Cowpasture Road","number":"23"},"formatted":"23 Cowpasture Rd, Leppington NSW 2179, Australia","country":"AU","postalCode":"2179","subdivision":"NSW"},"websiteFacebookUrl":null,"teamEmail":"markchenoweth@live.com","teamLogo":"wix:image://v1/7ab0ce_36957293b7a34be8b3872e66865e2971~mv2.png/Buhurt%20logo.PNG#originWidth=1449&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/7ab0ce_36957293b7a34be8b3872e66865e2971~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":11,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"Tournament":"Legends of Steel 2026","_id":"1","category":"3vs3","date":"2026-05-23"},{"_id":"2","points":6,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"3vs3","place":2},{"_id":"3","points":8,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":1},{"_id":"4","points":3,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":7,"tournaments":[{"_id":"1","points":3,"Tournament":"Winterfest 2025","date":45478,"category":"3vs3","place":2},{"_id":"2","points":0,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"3vs3","place":5},{"_id":"3","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":4}]}},"members":["Violet Morgan","Chelsie Wood-Jordan","Nariese Lovenfosse","Tamsen Horsnell","Helana cooper","Molly Fry","Kai Whitfield","Tee Thwaites","Rhiana Stockill","Monika Pusara"],"sourceCreatedAt":"2025-04-28T12:49:53.531Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Havoc Magpies',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sydney',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'markchenoweth@live.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7ab0ce_36957293b7a34be8b3872e66865e2971~mv2.png'),
 public_description=coalesce(t.public_description,'Women&#x27;s team for Club Havoc debuting as the Magpies in 2025!'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Violet Morgan','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chelsie Wood-Jordan','captain','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nariese Lovenfosse','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tamsen Horsnell','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Helana cooper','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Molly Fry','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kai Whitfield','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tee Thwaites','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rhiana Stockill','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Monika Pusara','fighter','bi_teams','https://www.buhurtinternational.com/team/team-havoc-(f)','team-havoc-(f)',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-kraken' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-kraken' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Team Kraken','Melbourne',true,'active','public','bi-team-kraken','OC','Oceania','AU','Australia','KrakenHMB@Gmail.com','https://www.facebook.com/teamkraken','https://static.wixstatic.com/media/547740_fb6bad5caab742818978fa6db3051512~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-kraken','https://www.buhurtinternational.com/team/team-kraken','Team Kraken','Melbourne','KrakenHMB@Gmail.com','https://www.facebook.com/teamkraken',20,'{"biCollectionId":"09b91708-4c6b-483f-b212-fc456c22868f","teamName":"Team Kraken","club":null,"gender":"Male","captain":"Jake Taylor","conference":"APAC","country":"Australia","city":"Melbourne","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/teamkraken","teamEmail":"KrakenHMB@Gmail.com","teamLogo":"wix:image://v1/547740_fb6bad5caab742818978fa6db3051512~mv2.jpg/304976104_542742610949650_5855259491989050430_n.jpg#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/547740_fb6bad5caab742818978fa6db3051512~mv2.jpg","rank5v5":1,"averagePoints5v5":12.67,"points5v5":38,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":10,"Tournament":"Axefest 3 (Melbourne Renfair tournament) 2026","date":"2026-05-16","category":"5vs5","place":1},{"_id":"2","points":12,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":1},{"_id":"3","points":16,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":1}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":12,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":1},{"_id":"2","points":14,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":1},{"_id":"3","points":12,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":2}]},"2025":{"points12v12":0,"points5v5":3,"remainingTokens":8,"tournaments":[{"_id":"1","points":3,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":4}]}},"members":["Bowen Slater","Drew Hossack","Jake Taylor","Julian Hewet-le Forestier","Marco Riotto","Iain Russell","Kameron Ritchie","Eric Alger"],"sourceCreatedAt":"2023-09-14T09:55:45.995Z","sourceUpdatedAt":"2026-09-29T07:44:59.055Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Team Kraken',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Melbourne',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'KrakenHMB@Gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/teamkraken'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/547740_fb6bad5caab742818978fa6db3051512~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bowen Slater','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Drew Hossack','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Taylor','captain','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Julian Hewet-le Forestier','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marco Riotto','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iain Russell','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kameron Ritchie','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric Alger','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken','team-kraken',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-kraken-green' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-kraken-green' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Team Kraken Green','Melbourne',true,'active','public','bi-team-kraken-green','OC','Oceania','AU','Australia','Kraken.HMB@Gmail.com',NULL,'https://static.wixstatic.com/media/547740_1c0318ea26a143fab2e31b2a6ed42970~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-kraken-green','https://www.buhurtinternational.com/team/team-kraken-green','Team Kraken Green','Melbourne','Kraken.HMB@Gmail.com',NULL,20,'{"biCollectionId":"d06e49f5-99bc-46e0-8847-30f5e3e64f76","teamName":"Team Kraken Green","club":null,"gender":"Male","captain":"Iain Russell","conference":"APAC","country":"Australia","city":"Melbourne","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"Kraken.HMB@Gmail.com","teamLogo":"wix:image://v1/547740_1c0318ea26a143fab2e31b2a6ed42970~mv2.png/TRANSPARENT%20BACKGROUND_EPS_Main-01.png#originWidth=4167&originHeight=4167","logoUrl":"https://static.wixstatic.com/media/547740_1c0318ea26a143fab2e31b2a6ed42970~mv2.png","rank5v5":6,"averagePoints5v5":3,"points5v5":9,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4,"Tournament":"Axefest 3 (Melbourne Renfair tournament) 2026","date":"2026-05-16","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Legends of Steel 2026","date":"2026-05-23","category":"5vs5","place":5},{"_id":"3","points":3,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":4}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1.5,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":8}]},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":7,"tournaments":[{"_id":"1","points":7,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":3},{"_id":"2","points":3,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":9}]}},"members":["Iain Russell","Dylan Terlich","Eric English","Robb Evans","Mateo Rossi","Alex Jacobsen","James Fisher","Jake Galland","Alice Phillps"],"sourceCreatedAt":"2024-09-14T02:28:15.926Z","sourceUpdatedAt":"2026-09-29T08:13:47.161Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Team Kraken Green',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Melbourne',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Kraken.HMB@Gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/547740_1c0318ea26a143fab2e31b2a6ed42970~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iain Russell','captain','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dylan Terlich','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eric English','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Robb Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mateo Rossi','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Jacobsen','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'James Fisher','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jake Galland','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alice Phillps','fighter','bi_teams','https://www.buhurtinternational.com/team/team-kraken-green','team-kraken-green',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='team-vultures' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-team-vultures' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Team Vultures (f)','Sunshine Coast',true,'active','public','bi-team-vultures','OC','Oceania','AU','Australia','jess@vultures.org.au','https://www.facebook.com/TeamVulturesAC/','https://static.wixstatic.com/media/815820_bc48510bf3354305b59c8bec4c38b0ae~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','team-vultures','https://www.buhurtinternational.com/team/team-vultures','Team Vultures (f)','Sunshine Coast','jess@vultures.org.au','https://www.facebook.com/TeamVulturesAC/',20,'{"biCollectionId":"4d534f7b-bf1d-40f0-86ed-892235169b5b","teamName":"Team Vultures (f)","club":null,"gender":"Female","captain":"Jess Van Straalen & Bree Blackmur","conference":"APAC","country":"Australia","city":"Sunshine Coast","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/TeamVulturesAC/","teamEmail":"jess@vultures.org.au","teamLogo":"wix:image://v1/815820_bc48510bf3354305b59c8bec4c38b0ae~mv2.png/thumbnail_Vultures-Logo-large.png#originWidth=960&originHeight=960","logoUrl":"https://static.wixstatic.com/media/815820_bc48510bf3354305b59c8bec4c38b0ae~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"3vs3","place":5},{"_id":"2","points":2,"Tournament":"Winterfest Cup 2026","date":"2026-07-04","category":"5vs5","place":3}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":10,"tournaments":[{"_id":"1","points":1.5,"Tournament":"Winterfest 2025","date":45478,"category":"3vs3","place":3},{"_id":"2","points":2,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"3vs3","place":3},{"_id":"3","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":5}]}},"members":["Jess Van Straalen & Bree Blackmur","Jessica Van Straalen","Breana Blackmur","Alhena Lamont","Tayla Brownlie","Skye Burnie","Stevi Eather","Heidi Van Leeuwen"],"sourceCreatedAt":"2025-03-07T07:43:19.875Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Team Vultures (f)',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Sunshine Coast',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jess@vultures.org.au'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TeamVulturesAC/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/815820_bc48510bf3354305b59c8bec4c38b0ae~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jess Van Straalen & Bree Blackmur','captain','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jessica Van Straalen','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Breana Blackmur','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alhena Lamont','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tayla Brownlie','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Skye Burnie','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Stevi Eather','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heidi Van Leeuwen','fighter','bi_teams','https://www.buhurtinternational.com/team/team-vultures','team-vultures',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-berserkers' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-berserkers' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Berserkers','Everywhere ',true,'active','public','bi-the-berserkers','NA','North America','US','United States','njsteelfighting@gmail.com',NULL,'https://static.wixstatic.com/media/dc246e_57a4ce4712484b07947e5c6b041ed742~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-berserkers','https://www.buhurtinternational.com/team/the-berserkers','The Berserkers','Everywhere ','njsteelfighting@gmail.com',NULL,20,'{"biCollectionId":"cedb8fc5-8523-4340-9d18-800fa7eaeff7","teamName":"The Berserkers","club":null,"gender":"Male","captain":"Darius Sileikis","conference":"North America","country":"United States","city":"Everywhere ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"njsteelfighting@gmail.com","teamLogo":"wix:image://v1/dc246e_57a4ce4712484b07947e5c6b041ed742~mv2.png/Berserkers_3.PNG#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/dc246e_57a4ce4712484b07947e5c6b041ed742~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":22.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":7.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":6},{"_id":"2","points":15,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":34,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":1}]},"2025":{"tournaments":[{"_id":"1","points":10,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":4},{"_id":"2","points":4,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":4},{"_id":"3","points":7.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":4},{"_id":"4","points":6,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":3}],"points12v12":0,"averagePoints5v5":7.83,"rank5v5":6,"remainingTokens":2,"points5v5":27.5}},"members":["Darius Sileikis","Darius J Sileikis","David Sweeney","Ian Robert Webb","Patrick Hurd","Wyatt Blackburn","Tanner Cox","Chris Crandall","John Rockhill","Cory Hogsett"],"sourceCreatedAt":"2024-06-02T05:09:57.140Z","sourceUpdatedAt":"2026-09-28T23:58:57.151Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Berserkers',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Everywhere ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'njsteelfighting@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/dc246e_57a4ce4712484b07947e5c6b041ed742~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Darius Sileikis','captain','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Darius J Sileikis','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Sweeney','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Robert Webb','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Patrick Hurd','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Wyatt Blackburn','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tanner Cox','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris Crandall','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Rockhill','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cory Hogsett','fighter','bi_teams','https://www.buhurtinternational.com/team/the-berserkers','the-berserkers',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-chaos-collective' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-chaos-collective' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Chaos Collective','Nashville',true,'active','public','bi-the-chaos-collective','NA','North America','US','United States','dannirbonner@gmail.com',NULL,'https://static.wixstatic.com/media/ffbb25_7f22f2ca836d48fbbf203625923b84ee~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-chaos-collective','https://www.buhurtinternational.com/team/the-chaos-collective','The Chaos Collective','Nashville','dannirbonner@gmail.com',NULL,20,'{"biCollectionId":"7c6c0108-8065-4810-ad3a-5f7226ae41b2","teamName":"The Chaos Collective","club":null,"gender":"Female","captain":"Danielle Rae Bonner","conference":"North America","country":"United States","city":"Nashville","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"dannirbonner@gmail.com","teamLogo":"wix:image://v1/ffbb25_7f22f2ca836d48fbbf203625923b84ee~mv2.jpg/IMG_20240815_003455_523.jpg#originWidth=720&originHeight=403","logoUrl":"https://static.wixstatic.com/media/ffbb25_7f22f2ca836d48fbbf203625923b84ee~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Dragon''s Cup 2024","date":"2024-08-31","category":"5vs5","place":3}]},"2025":{"remainingTokens":10}},"members":["Danielle Rae Bonner","Elizabeth Gifford","Allison Toth","Nicole dAquin","Megan Themm"],"sourceCreatedAt":"2024-08-14T22:27:46.818Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Chaos Collective',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nashville',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'dannirbonner@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ffbb25_7f22f2ca836d48fbbf203625923b84ee~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danielle Rae Bonner','captain','bi_teams','https://www.buhurtinternational.com/team/the-chaos-collective','the-chaos-collective',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Elizabeth Gifford','fighter','bi_teams','https://www.buhurtinternational.com/team/the-chaos-collective','the-chaos-collective',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Allison Toth','fighter','bi_teams','https://www.buhurtinternational.com/team/the-chaos-collective','the-chaos-collective',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicole dAquin','fighter','bi_teams','https://www.buhurtinternational.com/team/the-chaos-collective','the-chaos-collective',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Megan Themm','fighter','bi_teams','https://www.buhurtinternational.com/team/the-chaos-collective','the-chaos-collective',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-company-of-the-black-spears' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-company-of-the-black-spears' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Company of the Black Spears','Lethbridge',true,'active','public','bi-the-company-of-the-black-spears','NA','North America','CA','Canada','Bribo22@outlook.com',NULL,'https://static.wixstatic.com/media/5777d4_e471c2359a7c47eda9ab5fab1bc51209~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-company-of-the-black-spears','https://www.buhurtinternational.com/team/the-company-of-the-black-spears','The Company of the Black Spears','Lethbridge','Bribo22@outlook.com',NULL,20,'{"biCollectionId":"5bded9f6-2c66-4e3d-aba4-d521ced9c23e","teamName":"The Company of the Black Spears","club":null,"gender":"Male","captain":"Brian Boisson","conference":"North America","country":"Canada","city":"Lethbridge","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"Bribo22@outlook.com","teamLogo":"wix:image://v1/5777d4_e471c2359a7c47eda9ab5fab1bc51209~mv2.png/CBS%20Spears%20red%20light-1.png#originWidth=709&originHeight=822","logoUrl":"https://static.wixstatic.com/media/5777d4_e471c2359a7c47eda9ab5fab1bc51209~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Brian Boisson","Graham MacBean","Colum Terry"],"sourceCreatedAt":"2025-10-17T09:17:08.648Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Company of the Black Spears',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Lethbridge',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Bribo22@outlook.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5777d4_e471c2359a7c47eda9ab5fab1bc51209~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brian Boisson','captain','bi_teams','https://www.buhurtinternational.com/team/the-company-of-the-black-spears','the-company-of-the-black-spears',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Graham MacBean','fighter','bi_teams','https://www.buhurtinternational.com/team/the-company-of-the-black-spears','the-company-of-the-black-spears',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Colum Terry','fighter','bi_teams','https://www.buhurtinternational.com/team/the-company-of-the-black-spears','the-company-of-the-black-spears',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-fighting-uruk-hai' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-fighting-uruk-hai' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Fighting Uruk-Hai',NULL,true,'active','public','bi-the-fighting-uruk-hai','NA','North America','US','United States','Fighting.Urukhai.buhurt@gmail.com',NULL,'https://static.wixstatic.com/media/316a4e_312853f76b6b49439128ac71e27cf474~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-fighting-uruk-hai','https://www.buhurtinternational.com/team/the-fighting-uruk-hai','The Fighting Uruk-Hai',NULL,'Fighting.Urukhai.buhurt@gmail.com',NULL,20,'{"biCollectionId":"58d9891b-5c7d-4b6e-82a2-c1232ceef916","teamName":"The Fighting Uruk-Hai","club":null,"gender":"Male","captain":"Ian Martin","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"Fighting.Urukhai.buhurt@gmail.com","teamLogo":"wix:image://v1/316a4e_312853f76b6b49439128ac71e27cf474~mv2.png/Untitled49_20260430212803.png#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/316a4e_312853f76b6b49439128ac71e27cf474~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Ian Martin"],"sourceCreatedAt":"2026-04-30T01:03:02.522Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Fighting Uruk-Hai',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'Fighting.Urukhai.buhurt@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/316a4e_312853f76b6b49439128ac71e27cf474~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ian Martin','captain','bi_teams','https://www.buhurtinternational.com/team/the-fighting-uruk-hai','the-fighting-uruk-hai',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-forsaken' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-forsaken' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Forsaken','York',true,'active','public','bi-the-forsaken','NA','North America','US','United States','yorkforsaken@gmail.com',NULL,'https://static.wixstatic.com/media/2bfbc5_8c8d212d18ea4118910f81e86d577584~mv2.jpeg','Buhurt Team out of York, PA')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-forsaken','https://www.buhurtinternational.com/team/the-forsaken','The Forsaken','York','yorkforsaken@gmail.com',NULL,20,'{"biCollectionId":"44b54ee4-2e3e-434b-959d-1c45144fccdd","teamName":"The Forsaken","club":null,"gender":"Male","captain":"Drew Shipley","conference":"North America","country":"United States","city":"York","teamInfo":"Buhurt Team out of York, PA","trainingInfo":"Athletic attire","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"yorkforsaken@gmail.com","teamLogo":"wix:image://v1/2bfbc5_8c8d212d18ea4118910f81e86d577584~mv2.jpeg/Team%20Logo%20Official.JPEG#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/2bfbc5_8c8d212d18ea4118910f81e86d577584~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1,"remainingTokens":9,"tournaments":[{"_id":"1","points":1,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":11}]}},"members":["Drew Shipley"],"sourceCreatedAt":"2025-03-25T13:27:11.743Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Forsaken',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('York',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'yorkforsaken@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/2bfbc5_8c8d212d18ea4118910f81e86d577584~mv2.jpeg'),
 public_description=coalesce(t.public_description,'Buhurt Team out of York, PA'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Drew Shipley','captain','bi_teams','https://www.buhurtinternational.com/team/the-forsaken','the-forsaken',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-gorgons' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-gorgons' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Gorgons',NULL,true,'active','public','bi-the-gorgons','OC','Oceania','AU','Australia','catherinemaryleonard+gorgons@gmail.com',NULL,'https://static.wixstatic.com/media/4be6a2_dd2749a1091f4a7d8bde7d81fbb97f66~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-gorgons','https://www.buhurtinternational.com/team/the-gorgons','The Gorgons',NULL,'catherinemaryleonard+gorgons@gmail.com',NULL,20,'{"biCollectionId":"28ac7f48-770f-4229-b2a3-07673ab58ad5","teamName":"The Gorgons","club":null,"gender":"Female","captain":"Cat Leonard","conference":"APAC","country":"Australia","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"catherinemaryleonard+gorgons@gmail.com","teamLogo":"wix:image://v1/4be6a2_dd2749a1091f4a7d8bde7d81fbb97f66~mv2.png/gorgons%20copy.png#originWidth=2959&originHeight=2959","logoUrl":"https://static.wixstatic.com/media/4be6a2_dd2749a1091f4a7d8bde7d81fbb97f66~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"Tournament":"Legends of Steel 2026","_id":"1","category":"3vs3","date":"2026-05-23"}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":9,"tournaments":[{"_id":"1","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":6}]}},"members":["Cat Leonard","Mia Biddulph","Alannah Ní Thuathaigh","Teej Van Vark","Marie Holt","Eleanor Whitfort","Emmeline Taylor"],"sourceCreatedAt":"2024-09-11T00:14:04.493Z","sourceUpdatedAt":"2026-09-25T23:31:33.887Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Gorgons',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'catherinemaryleonard+gorgons@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4be6a2_dd2749a1091f4a7d8bde7d81fbb97f66~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cat Leonard','captain','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mia Biddulph','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alannah Ní Thuathaigh','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Teej Van Vark','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Marie Holt','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Eleanor Whitfort','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emmeline Taylor','fighter','bi_teams','https://www.buhurtinternational.com/team/the-gorgons','the-gorgons',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-hateful-eight' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-hateful-eight' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Hateful Eight','Zaragoza',true,'active','public','bi-the-hateful-eight','EU','Europe','ES','Spain','combatemedievalaragon@gmail.com',NULL,'https://static.wixstatic.com/media/283b84_54fc8fc35a494bf4890138263763f066~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-hateful-eight','https://www.buhurtinternational.com/team/the-hateful-eight','The Hateful Eight','Zaragoza','combatemedievalaragon@gmail.com',NULL,20,'{"biCollectionId":"043aeeec-6d6e-4b97-b76f-2472fbc5ba16","teamName":"The Hateful Eight","club":"The Hateful Eight","gender":"Male","captain":"David del Cerro","conference":"Europe","country":"Spain","city":"Zaragoza","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"combatemedievalaragon@gmail.com","teamLogo":"wix:image://v1/283b84_54fc8fc35a494bf4890138263763f066~mv2.jpeg/WhatsApp%20Image%202024-06-23%20at%2020.51.22.jpeg#originWidth=644&originHeight=707","logoUrl":"https://static.wixstatic.com/media/283b84_54fc8fc35a494bf4890138263763f066~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["David del Cerro","Salvador Castillo","Jorge Villanueva","Israel Esteban","Juan Lucas Torres","Alberto Vazquez","Gonzalo Ceballos","Francisco Garcia"],"sourceCreatedAt":"2024-06-25T21:15:58.827Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Hateful Eight',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Zaragoza',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'combatemedievalaragon@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/283b84_54fc8fc35a494bf4890138263763f066~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David del Cerro','captain','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Salvador Castillo','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jorge Villanueva','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Israel Esteban','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juan Lucas Torres','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Vazquez','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gonzalo Ceballos','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francisco Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/the-hateful-eight','the-hateful-eight',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-headsmen' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-headsmen' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Headsmen','Nashua',true,'active','public','bi-the-headsmen','NA','North America','US','United States','cdhennessey66@gmail.com',NULL,'https://static.wixstatic.com/media/5207d4_9eef48788a594cbe923e0a598c7e24ec~mv2.jpeg','A gaggle of goons looking to put a footprint on the Buhurt map')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-headsmen','https://www.buhurtinternational.com/team/the-headsmen','The Headsmen','Nashua','cdhennessey66@gmail.com',NULL,20,'{"biCollectionId":"fb28aa30-99bb-486b-9e60-dade29cb3190","teamName":"The Headsmen","club":null,"gender":"Male","captain":"Curtis Hennessey","conference":"North America","country":"United States","city":"Nashua","teamInfo":"A gaggle of goons looking to put a footprint on the Buhurt map","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"cdhennessey66@gmail.com","teamLogo":"wix:image://v1/5207d4_9eef48788a594cbe923e0a598c7e24ec~mv2.jpeg/received_880642226945532.jpeg#originWidth=522&originHeight=599","logoUrl":"https://static.wixstatic.com/media/5207d4_9eef48788a594cbe923e0a598c7e24ec~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":13}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":3,"Tournament":"Blood & Steel 7 2024","date":"2024-10-19","category":"5vs5","place":3}]},"2025":{"points12v12":0,"points5v5":2,"remainingTokens":10,"tournaments":[{"_id":"1","points":2,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":9}]}},"members":["Sean Billson","Ivan Smirnoff","Andrew LeBlanc","Curtis Hennessey","Gregory Hall","Joseph Goncalves","Kody Corbosiero","Victor Hoyseth"],"sourceCreatedAt":"2024-09-25T23:48:08.680Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Headsmen',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Nashua',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'cdhennessey66@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5207d4_9eef48788a594cbe923e0a598c7e24ec~mv2.jpeg'),
 public_description=coalesce(t.public_description,'A gaggle of goons looking to put a footprint on the Buhurt map'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sean Billson','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ivan Smirnoff','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew LeBlanc','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Curtis Hennessey','captain','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gregory Hall','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Goncalves','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kody Corbosiero','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Victor Hoyseth','fighter','bi_teams','https://www.buhurtinternational.com/team/the-headsmen','the-headsmen',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-infernal-unicorns' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-infernal-unicorns' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Infernal Unicorns','Scotland',true,'active','public','bi-the-infernal-unicorns','EU','Europe','GB','United Kingdom','infernal.unicorns@gmail.com','https://www.facebook.com/theinfernalunicorns','https://static.wixstatic.com/media/6de0eb_15e0fee53ff84a41b2f89605d8b53f8b~mv2.jpg','The Infernal Unicorns is a women&#x27;s medieval armoured combat sports team based in Scotland')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-infernal-unicorns','https://www.buhurtinternational.com/team/the-infernal-unicorns','The Infernal Unicorns','Scotland','infernal.unicorns@gmail.com','https://www.facebook.com/theinfernalunicorns',20,'{"biCollectionId":"8bb8bf28-5c64-47ea-9987-2220b9f1225f","teamName":"The Infernal Unicorns","club":null,"gender":"Female","captain":"Rachael Marriott","conference":"Europe","country":"United Kingdom","city":"Scotland","teamInfo":"The Infernal Unicorns is a women&#x27;s medieval armoured combat sports team based in Scotland","trainingInfo":"We welcome anyone interested in joining us, just contact us via our Facebook or Instagram accounts!","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/theinfernalunicorns","teamEmail":"infernal.unicorns@gmail.com","teamLogo":"wix:image://v1/6de0eb_15e0fee53ff84a41b2f89605d8b53f8b~mv2.jpg/InfernalUnicorns.jpg#originWidth=2335&originHeight=2480","logoUrl":"https://static.wixstatic.com/media/6de0eb_15e0fee53ff84a41b2f89605d8b53f8b~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":10}},"members":["Rachael Marriott","Laura Henderson","Athina Kladaki","Lyndsey Martin MacDonald","Emma Burnley-Davies"],"sourceCreatedAt":"2023-08-30T14:16:01.803Z","sourceUpdatedAt":"2026-09-24T18:21:42.396Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Infernal Unicorns',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Scotland',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'infernal.unicorns@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/theinfernalunicorns'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/6de0eb_15e0fee53ff84a41b2f89605d8b53f8b~mv2.jpg'),
 public_description=coalesce(t.public_description,'The Infernal Unicorns is a women&#x27;s medieval armoured combat sports team based in Scotland'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachael Marriott','captain','bi_teams','https://www.buhurtinternational.com/team/the-infernal-unicorns','the-infernal-unicorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Laura Henderson','fighter','bi_teams','https://www.buhurtinternational.com/team/the-infernal-unicorns','the-infernal-unicorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Athina Kladaki','fighter','bi_teams','https://www.buhurtinternational.com/team/the-infernal-unicorns','the-infernal-unicorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lyndsey Martin MacDonald','fighter','bi_teams','https://www.buhurtinternational.com/team/the-infernal-unicorns','the-infernal-unicorns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Emma Burnley-Davies','fighter','bi_teams','https://www.buhurtinternational.com/team/the-infernal-unicorns','the-infernal-unicorns',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-moose-men' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-moose-men' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Moose Men',NULL,true,'active','public','bi-the-moose-men','NA','North America','US','United States','spoo53@hotmail.com',NULL,'https://static.wixstatic.com/media/4e1f56_5cc29268ff4b4865b2df00bfc8ff8323~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-moose-men','https://www.buhurtinternational.com/team/the-moose-men','The Moose Men',NULL,'spoo53@hotmail.com',NULL,20,'{"biCollectionId":"ea5ca562-5abb-4dc2-b965-bc9410a2f8bd","teamName":"The Moose Men","club":null,"gender":"Male","captain":"Nathan Maxfield","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":""},"websiteFacebookUrl":null,"teamEmail":"spoo53@hotmail.com","teamLogo":"wix:image://v1/4e1f56_5cc29268ff4b4865b2df00bfc8ff8323~mv2.png/Shield.png#originWidth=1386&originHeight=1386","logoUrl":"https://static.wixstatic.com/media/4e1f56_5cc29268ff4b4865b2df00bfc8ff8323~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":9}},"members":["Nathan Maxfield"],"sourceCreatedAt":"2025-02-16T02:05:42.641Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Moose Men',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'spoo53@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4e1f56_5cc29268ff4b4865b2df00bfc8ff8323~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Maxfield','captain','bi_teams','https://www.buhurtinternational.com/team/the-moose-men','the-moose-men',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-new-order' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-new-order' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The New Order','Indianola',true,'active','public','bi-the-new-order','NA','North America','US','United States','neworderarmoredcombat@gmail.com','https://www.facebook.com/NewOrderArmoredCombat/','https://static.wixstatic.com/media/f46c0c_966219c4b3f5415ea2e5953935a3c2b5~mv2.png','Buhurt Team based out of Indianola , Iowa. We offer both a mens and womens melee division, as well as duels and profights.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-new-order','https://www.buhurtinternational.com/team/the-new-order','The New Order','Indianola','neworderarmoredcombat@gmail.com','https://www.facebook.com/NewOrderArmoredCombat/',20,'{"biCollectionId":"af3bfe91-8936-416e-b518-87addda7795e","teamName":"The New Order","club":"The New Order","gender":"Male","captain":"Zachary Shadu Fry","conference":"North America","country":"United States","city":"Indianola","teamInfo":"Buhurt Team based out of Indianola , Iowa. We offer both a mens and womens melee division, as well as duels and profights.","trainingInfo":"Training is open to the public, please bring workout cloths, comfortable shoes, and a water bottle","trainingLocation":{"subdivisions":[{"code":"IA","name":"Iowa","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Warren County","name":"Warren County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Indianola","name":"Indianola","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Indianola","location":{"latitude":41.3528998,"longitude":-93.558595},"streetAddress":{"apt":"","formattedAddressLine":"811 S Jefferson Way","name":"South Jefferson Way","number":"811"},"formatted":"811 S Jefferson Way, Indianola, IA 50125, USA","country":"US","postalCode":"50125-3217","subdivision":"IA"},"websiteFacebookUrl":"https://www.facebook.com/NewOrderArmoredCombat/","teamEmail":"neworderarmoredcombat@gmail.com","teamLogo":"wix:image://v1/f46c0c_966219c4b3f5415ea2e5953935a3c2b5~mv2.png/Untitled_Artwork.PNG#originWidth=1536&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/f46c0c_966219c4b3f5415ea2e5953935a3c2b5~mv2.png","rank5v5":9,"averagePoints5v5":6,"points5v5":21.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":4},{"_id":"2","points":4,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":4},{"_id":"3","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":9},{"_id":"4","points":1,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2026","date":"2026-06-27","category":"5vs5","place":4},{"_id":"5","points":9,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4.5,"Tournament":"Cincinnati Siege 2024: The second Harambe Memorial Tournament ","date":"2024-05-25","category":"5vs5","place":5},{"_id":"2","points":6,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":10},{"_id":"3","points":1,"Tournament":"Whacksgiving 2024","date":"2024-11-02","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":8,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":5},{"_id":"2","points":4.5,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"5vs5","place":5},{"_id":"3","points":0,"Tournament":"Cincinnati Siege 2025","date":"2025-05-23","category":"12vs12","place":6},{"_id":"4","points":3,"Tournament":"Springfield Missouri''s Armored Combat Tournament 2025","date":"2025-06-28","category":"5vs5","place":4}],"points12v12":0,"averagePoints5v5":5.17,"rank5v5":12,"remainingTokens":10,"points5v5":15.5}},"members":["Zachary Shadu Fry","Curtis Knapp","Aaron Miller","Rashad Nagi","Calvin Corell","Adam Thompson","Andrew Nikkel","Joseph brown spellacy","Alex Evans","Matthew Evans","Ethan Evans","Austin Andreasen","Alexzander Lee Pennington","Nathanial Velazquez","Gabriel Brown","Brannon"],"sourceCreatedAt":"2024-06-28T03:51:17.895Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The New Order',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Indianola',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'neworderarmoredcombat@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/NewOrderArmoredCombat/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/f46c0c_966219c4b3f5415ea2e5953935a3c2b5~mv2.png'),
 public_description=coalesce(t.public_description,'Buhurt Team based out of Indianola , Iowa. We offer both a mens and womens melee division, as well as duels and profights.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Shadu Fry','captain','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Curtis Knapp','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron Miller','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rashad Nagi','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Calvin Corell','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Thompson','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Nikkel','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph brown spellacy','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ethan Evans','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Austin Andreasen','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexzander Lee Pennington','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathanial Velazquez','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gabriel Brown','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brannon','fighter','bi_teams','https://www.buhurtinternational.com/team/the-new-order','the-new-order',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-northern-wolves' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-northern-wolves' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Northern Wolves','Manchester',true,'active','public','bi-the-northern-wolves','EU','Europe','GB','United Kingdom','honourandarmsclub@gmail.com','https://www.facebook.com/TheNorthernWolvesBH','https://static.wixstatic.com/media/7c9836_1d107b61e9074207ba90d2f1043a92dc~mv2.png','The Northern Wolves are a medieval combat team based in and covering the North of England')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-northern-wolves','https://www.buhurtinternational.com/team/the-northern-wolves','The Northern Wolves','Manchester','honourandarmsclub@gmail.com','https://www.facebook.com/TheNorthernWolvesBH',20,'{"biCollectionId":"a9585570-56d6-4fdc-8189-9e57cdd76237","teamName":"The Northern Wolves","club":null,"gender":"Male","captain":"Danny George","conference":"Europe","country":"United Kingdom","city":"Manchester","teamInfo":"The Northern Wolves are a medieval combat team based in and covering the North of England","trainingInfo":"We do allow anyone to come and join us for training, however we do ask for contact first so we know to expect you. Training is on the following: Tuesday 7pm - 9 pm Thursday 7pm - 9 pm Select Sunday sessions - please contact for dates.","trainingLocation":{"city":"Whitworth","location":{"latitude":53.6620155,"longitude":-2.1735864},"streetAddress":{"apt":"Bridge End Mills","formattedAddressLine":"Bridge End Mills","name":"Tong Lane","number":""},"formatted":"Bridge End Mills, Tong Ln, Whitworth, Rochdale OL12 8BE, UK","country":"GB","postalCode":"OL12 8BE"},"websiteFacebookUrl":"https://www.facebook.com/TheNorthernWolvesBH","teamEmail":"honourandarmsclub@gmail.com","teamLogo":"wix:image://v1/7c9836_1d107b61e9074207ba90d2f1043a92dc~mv2.png/Northern%20Wolves%20Logo.png#originWidth=783&originHeight=898","logoUrl":"https://static.wixstatic.com/media/7c9836_1d107b61e9074207ba90d2f1043a92dc~mv2.png","rank5v5":4,"averagePoints5v5":5,"points5v5":15,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":9,"Tournament":"Castleton Cup 2026","date":"2026-04-04","category":"5vs5","place":3},{"_id":"2","points":5,"Tournament":"The Leodis Cup 2026","date":"2026-05-16","category":"5vs5","place":4},{"_id":"3","points":1,"Tournament":"Tournament of Deeds 2026","date":"2026-06-27","category":"5vs5","place":7},{"_id":"4","points":0,"Tournament":"Severnside Clash 2026","date":"2026-07-25","category":"5vs5","place":10}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":10,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"5vs5","place":2},{"_id":"2","points":8,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":6},{"_id":"3","points":5,"Tournament":"Arnold UK 2024","date":"2024-03-15","category":"12vs12","place":2},{"_id":"4","points":6,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"5vs5","place":4},{"_id":"5","points":12,"Tournament":"Tournament Of Deeds 2024","date":"2024-06-15","category":"5vs5","place":2},{"_id":"6","points":5,"Tournament":"Castleton Cup 2024","date":"2024-04-20","category":"12vs12","place":2},{"_id":"7","points":2,"Tournament":"Way of Honor 2024","date":"2024-08-24","category":"5vs5","place":6},{"_id":"8","points":8,"Tournament":"Heritage Shield 2024","date":"2024-10-12","category":"5vs5","place":3}]},"2025":{"tournaments":[{"_id":"1","points":9,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"5vs5","place":3},{"_id":"2","points":6,"Tournament":"Castleton Cup 2025","date":"2025-04-19","category":"12vs12","place":2},{"_id":"3","points":2,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"5vs5","place":9},{"_id":"4","points":2,"Tournament":"Tournament of Deeds 2025","date":"2025-06-14","category":"12vs12","place":3},{"_id":"5","points":4,"Tournament":"Heritage Shield 2025","date":"2025-10-11","category":"5vs5","place":6}],"points12v12":8,"averagePoints5v5":5,"rank5v5":6,"remainingTokens":10,"points5v5":15}},"members":["Danny George","Mike Wilde","Dan Kennett","George barrett-hague","Nathan Henry","Jonathan naisbitt","Anthony Kelly","Gary Hussey","Ewan Cronin","Simon Twigg","Niall Pentony","Cian Pentony","Luke McCreery","Ben Major","Alex Noble","Euan Campbell"],"sourceCreatedAt":"2023-07-17T15:58:01.993Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Northern Wolves',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Manchester',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('GB',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United Kingdom',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'honourandarmsclub@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TheNorthernWolvesBH'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/7c9836_1d107b61e9074207ba90d2f1043a92dc~mv2.png'),
 public_description=coalesce(t.public_description,'The Northern Wolves are a medieval combat team based in and covering the North of England'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Danny George','captain','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mike Wilde','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dan Kennett','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'George barrett-hague','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Henry','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan naisbitt','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Anthony Kelly','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Gary Hussey','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ewan Cronin','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Simon Twigg','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Niall Pentony','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cian Pentony','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luke McCreery','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ben Major','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex Noble','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Euan Campbell','fighter','bi_teams','https://www.buhurtinternational.com/team/the-northern-wolves','the-northern-wolves',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='the-order-of-the-wild-rose' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-the-order-of-the-wild-rose' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'The Order of the Wild Rose','Calgary',true,'active','public','bi-the-order-of-the-wild-rose','NA','North America','CA','Canada','alexa.lacroix@hotmail.com','https://www.hacsacanada.com/','https://static.wixstatic.com/media/70cf64_d353eb5320204840bde756bf1175d5e7~mv2.jpeg','HACSA Western Canada Women&#x27;s Melee team. We represent the Sourthern Alberta Women&#x27;s teams in our league. We are currently growing our team and have begun competing in BI regulation tournaments.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','the-order-of-the-wild-rose','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','The Order of the Wild Rose','Calgary','alexa.lacroix@hotmail.com','https://www.hacsacanada.com/',20,'{"biCollectionId":"84851911-c48b-4a5b-9f69-5056382be378","teamName":"The Order of the Wild Rose","club":null,"gender":"Female","captain":"Alexa Lacroix","conference":"North America","country":"Canada","city":"Calgary","teamInfo":"HACSA Western Canada Women&#x27;s Melee team. We represent the Sourthern Alberta Women&#x27;s teams in our league. We are currently growing our team and have begun competing in BI regulation tournaments.","trainingInfo":"Formed from the women of HACSA we are primarily comprised of Southern Alberta teams. Most of our ladies hail from the Calgary Silver Gryphons - HUZZAH. We are a growing womens melee group and are always looking for new knights to join our ranks!","trainingLocation":{"subdivisions":[{"code":"AB","name":"Alberta","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"Rocky View County","name":"Rocky View County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Balzac","name":"Balzac","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"CA","name":"Canada","type":"COUNTRY"}],"city":"Balzac","location":{"latitude":51.2125597,"longitude":-114.0076361},"streetAddress":{"apt":"","formattedAddressLine":"Balzac","name":"","number":""},"formatted":"Balzac, AB T4B 5T5, Canada","country":"CA","postalCode":"T4B 5T5","subdivision":"AB"},"websiteFacebookUrl":"https://www.hacsacanada.com/","teamEmail":"alexa.lacroix@hotmail.com","teamLogo":"wix:image://v1/70cf64_d353eb5320204840bde756bf1175d5e7~mv2.jpeg/The%20Order%20Of%20the%20Wild%20Rose.jpeg#originWidth=2048&originHeight=2048","logoUrl":"https://static.wixstatic.com/media/70cf64_d353eb5320204840bde756bf1175d5e7~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{},"members":["Alexa Lacroix","Erin Burgess","Michaela Crump","Christina Nicholson","A. Bird"],"sourceCreatedAt":"2026-05-12T03:24:46.960Z","sourceUpdatedAt":"2026-09-24T18:21:40.362Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('The Order of the Wild Rose',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Calgary',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('CA',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Canada',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'alexa.lacroix@hotmail.com'),
 website_url=coalesce(t.website_url,'https://www.hacsacanada.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/70cf64_d353eb5320204840bde756bf1175d5e7~mv2.jpeg'),
 public_description=coalesce(t.public_description,'HACSA Western Canada Women&#x27;s Melee team. We represent the Sourthern Alberta Women&#x27;s teams in our league. We are currently growing our team and have begun competing in BI regulation tournaments.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexa Lacroix','captain','bi_teams','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','the-order-of-the-wild-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Erin Burgess','fighter','bi_teams','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','the-order-of-the-wild-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michaela Crump','fighter','bi_teams','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','the-order-of-the-wild-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Christina Nicholson','fighter','bi_teams','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','the-order-of-the-wild-rose',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'A. Bird','fighter','bi_teams','https://www.buhurtinternational.com/team/the-order-of-the-wild-rose','the-order-of-the-wild-rose',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tidewater-dogs-of-war' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tidewater-dogs-of-war' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tidewater Dogs of War',NULL,true,'active','public','bi-tidewater-dogs-of-war','NA','North America','US','United States','NickJ.tdow@gmail.com','https://tidewaterdogsofwar.com/','https://static.wixstatic.com/media/a68188_1bf3c9076c5741feb3b4af1c20eeb602~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tidewater-dogs-of-war','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','Tidewater Dogs of War',NULL,'NickJ.tdow@gmail.com','https://tidewaterdogsofwar.com/',20,'{"biCollectionId":"d1e1c254-db2e-425d-99cc-8684a52aabd3","teamName":"Tidewater Dogs of War","club":null,"gender":"Male","captain":"Nick Johnson","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://tidewaterdogsofwar.com/","teamEmail":"NickJ.tdow@gmail.com","teamLogo":"wix:image://v1/a68188_1bf3c9076c5741feb3b4af1c20eeb602~mv2.png/shield.png#originWidth=388&originHeight=292","logoUrl":"https://static.wixstatic.com/media/a68188_1bf3c9076c5741feb3b4af1c20eeb602~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":0,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":14}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":4,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":12},{"_id":"2","points":2,"Tournament":"Tournament of the Tower 2024","date":"2024-11-02","category":"5vs5","place":5}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Tournament of Legends 2025","date":"2025-04-26","category":"5vs5","place":3},{"_id":"2","points":2,"Tournament":"Grapes of Wrath 2025","date":"2025-04-05","category":"5vs5","place":8},{"_id":"3","points":2,"Tournament":"Blood and Suds 3 2025","date":"2025-10-11","category":"5vs5","place":4},{"_id":"4","points":2,"Tournament":"Tournament of the Castle 2025","date":"2025-11-15","category":"5vs5","place":7}],"points12v12":0,"averagePoints5v5":2.67,"rank5v5":15,"remainingTokens":7,"points5v5":10}},"members":["Nick Johnson","Nicholas Elam","Joseph Monico","Carter Hendrick","Jesse fitzsimmons","Saturnino Crispulo Pilar","Rafal Raczynski"],"sourceCreatedAt":"2024-06-26T01:03:50.217Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tidewater Dogs of War',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'NickJ.tdow@gmail.com'),
 website_url=coalesce(t.website_url,'https://tidewaterdogsofwar.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/a68188_1bf3c9076c5741feb3b4af1c20eeb602~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nick Johnson','captain','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Elam','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joseph Monico','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Carter Hendrick','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jesse fitzsimmons','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Saturnino Crispulo Pilar','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rafal Raczynski','fighter','bi_teams','https://www.buhurtinternational.com/team/tidewater-dogs-of-war','tidewater-dogs-of-war',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='titans' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-titans' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Titans','Tauranga ',true,'active','public','bi-titans','OC','Oceania','NZ','New Zealand','taurangaarmouredcombat9@gmail.com','https://www.facebook.com/share/1F24XQEkjL/','https://static.wixstatic.com/media/448cbc_ed987939344b457aaa55c03bd58df396~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','titans','https://www.buhurtinternational.com/team/titans','Titans','Tauranga ','taurangaarmouredcombat9@gmail.com','https://www.facebook.com/share/1F24XQEkjL/',20,'{"biCollectionId":"f3948674-a74a-4a15-bea0-e4dfb0a46ffb","teamName":"Titans","club":null,"gender":"Female","captain":"Maddie Knibbs ","conference":"APAC","country":"New Zealand","city":"Tauranga ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/share/1F24XQEkjL/","teamEmail":"taurangaarmouredcombat9@gmail.com","teamLogo":"wix:image://v1/448cbc_ed987939344b457aaa55c03bd58df396~mv2.jpg/FB_IMG_1739411518271.jpg#originWidth=822&originHeight=811","logoUrl":"https://static.wixstatic.com/media/448cbc_ed987939344b457aaa55c03bd58df396~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{},"2025":{"remainingTokens":"10"}},"members":["Maddie Knibbs","Sammie-Lee Morrighan","Jess Gooch","Maddie A Knibbs","Jess Thomas","Blossom Bevins","Imogen Bevins","Kate Briscoe"],"sourceCreatedAt":"2025-02-13T01:53:36.575Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Titans',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tauranga ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('NZ',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('New Zealand',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'taurangaarmouredcombat9@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/share/1F24XQEkjL/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/448cbc_ed987939344b457aaa55c03bd58df396~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maddie Knibbs','captain','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Sammie-Lee Morrighan','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jess Gooch','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Maddie A Knibbs','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jess Thomas','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Blossom Bevins','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Imogen Bevins','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kate Briscoe','fighter','bi_teams','https://www.buhurtinternational.com/team/titans','titans',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tulsa-free-company' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tulsa-free-company' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tulsa Free Company','Tulsa ',true,'active','public','bi-tulsa-free-company','NA','North America','US','United States','nedloghcaz@gmail',NULL,'https://static.wixstatic.com/media/599fb6_f434ee428b9f4e0d97fec6ab9389dca9~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tulsa-free-company','https://www.buhurtinternational.com/team/tulsa-free-company','Tulsa Free Company','Tulsa ','nedloghcaz@gmail',NULL,20,'{"biCollectionId":"2344ad3e-9210-4684-8663-c9b210f26376","teamName":"Tulsa Free Company","club":null,"gender":"Male","captain":"Samuel Daniel","conference":"North America","country":"United States","city":"Tulsa ","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"nedloghcaz@gmail","teamLogo":"wix:image://v1/599fb6_f434ee428b9f4e0d97fec6ab9389dca9~mv2.jpeg/att.Zm2h9sMfeumt2hrCiW71z5ws9KN8fqdxeX1snVnE-GE.jpeg#originWidth=612&originHeight=515","logoUrl":"https://static.wixstatic.com/media/599fb6_f434ee428b9f4e0d97fec6ab9389dca9~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":26,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":14,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":1},{"_id":"2","points":12,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":1}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":5,"tournaments":[{"_id":"1","points":0,"Tournament":"Cream City Clash 3 2025","date":"2025-08-30","category":"5vs5","place":4}]}},"members":["Samuel Daniel","Samuel Nathan Daniel","Alexander Shambrook","Zachary Golden","Tyler Gentile","Andrew Hatfield","Chance Nissen","Heath Sutherland","Joshua Sparks","Charles Harris","Rudy Brennan Salsbury","Jacob Frailey"],"sourceCreatedAt":"2025-08-01T03:32:40.691Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tulsa Free Company',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Tulsa ',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'nedloghcaz@gmail'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/599fb6_f434ee428b9f4e0d97fec6ab9389dca9~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Daniel','captain','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samuel Nathan Daniel','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Shambrook','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Zachary Golden','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tyler Gentile','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew Hatfield','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chance Nissen','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Heath Sutherland','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Joshua Sparks','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Charles Harris','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rudy Brennan Salsbury','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jacob Frailey','fighter','bi_teams','https://www.buhurtinternational.com/team/tulsa-free-company','tulsa-free-company',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='twin-cites-wyverns-b-side' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-twin-cites-wyverns-b-side' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Twin Cites Wyverns B-Side',NULL,true,'active','public','bi-twin-cites-wyverns-b-side','NA','North America','US','United States','jeffthemarshal@gmail.com','https://www.facebook.com/TCWyverns','https://static.wixstatic.com/media/ac4d6e_a9422ed58fb746f98acf7d28ee6d56e1~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','twin-cites-wyverns-b-side','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','Twin Cites Wyverns B-Side',NULL,'jeffthemarshal@gmail.com','https://www.facebook.com/TCWyverns',20,'{"biCollectionId":"a9d2cc76-29e2-4df7-8715-48333d1047f3","teamName":"Twin Cites Wyverns B-Side","club":null,"gender":"Male","captain":"Jeff Sorlie","conference":"North America","country":"United States","city":null,"teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/TCWyverns","teamEmail":"jeffthemarshal@gmail.com","teamLogo":"wix:image://v1/ac4d6e_a9422ed58fb746f98acf7d28ee6d56e1~mv2.png/wyverns-logo-notext.png#originWidth=2550&originHeight=3300","logoUrl":"https://static.wixstatic.com/media/ac4d6e_a9422ed58fb746f98acf7d28ee6d56e1~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":1,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":1,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":7}],"eventsHistory":{},"members":["Jeff Sorlie","Aaron Pescheck-Thompson","Livia Dennis","Samual J Quarry","Bryan Bredfeldt","Nathan Boyd","Brandon Welke","Hiro McKee"],"sourceCreatedAt":"2026-07-02T01:05:18.745Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Twin Cites Wyverns B-Side',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce(NULL,t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'jeffthemarshal@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/TCWyverns'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/ac4d6e_a9422ed58fb746f98acf7d28ee6d56e1~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jeff Sorlie','captain','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Aaron Pescheck-Thompson','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Livia Dennis','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Samual J Quarry','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bryan Bredfeldt','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Boyd','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brandon Welke','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hiro McKee','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cites-wyverns-b-side','twin-cites-wyverns-b-side',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='twin-cities-wyverns' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-twin-cities-wyverns' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Twin Cities Wyverns','Minneapolis',true,'active','public','bi-twin-cities-wyverns','NA','North America','US','United States','wyverns@mn-armored-combat.org','https://wyverns.info','https://static.wixstatic.com/media/225dff_4a8e9e3d1e8843a29f1d683be85e7a3e~mv2.png',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','twin-cities-wyverns','https://www.buhurtinternational.com/team/twin-cities-wyverns','Twin Cities Wyverns','Minneapolis','wyverns@mn-armored-combat.org','https://wyverns.info',20,'{"biCollectionId":"0be58579-a571-4444-a498-df6fee932d38","teamName":"Twin Cities Wyverns","club":null,"gender":"Male","captain":"Linden Holt","conference":"North America","country":"United States","city":"Minneapolis","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://wyverns.info","teamEmail":"wyverns@mn-armored-combat.org","teamLogo":"wix:image://v1/225dff_4a8e9e3d1e8843a29f1d683be85e7a3e~mv2.png/wyverns-badge.png#originWidth=737&originHeight=737","logoUrl":"https://static.wixstatic.com/media/225dff_4a8e9e3d1e8843a29f1d683be85e7a3e~mv2.png","rank5v5":5,"averagePoints5v5":11,"points5v5":43.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":4.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":7},{"_id":"2","points":10,"Tournament":"Saint Patrick''s Brawl 2026","date":"2026-03-28","category":"5vs5","place":2},{"_id":"3","points":11,"Tournament":"Tournament of Legends 2026","date":"2026-04-25","category":"5vs5","place":1},{"_id":"4","points":12,"Tournament":"Colorado Classic 2026","date":"2026-06-06","category":"5vs5","place":2},{"_id":"5","points":6,"Tournament":"Cream City Clash IV 2026","date":"2026-08-22","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"2","points":8,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"12vs12","place":3},{"_id":"1","points":2,"Tournament":"carolina carnage 2024","date":"15-02-2024","category":"5vs5","place":16}]},"2025":{"tournaments":[{"_id":"1","points":2,"Tournament":"Carolina Carnage Fest 2025","date":"2025-01-31","category":"5vs5","place":16},{"_id":"2","points":7,"Tournament":"Tournament of Legends 2025","date":"2025-04-26","category":"5vs5","place":2},{"_id":"3","points":8,"Tournament":"Colorado Classic 3 2025","date":"2025-06-07","category":"5vs5","place":1},{"_id":"4","points":6,"Tournament":"Cream City Clash 3 2025","date":"2025-08-30","category":"5vs5","place":2},{"_id":"5","points":9,"Tournament":"War in the North 2025","date":"2025-10-18","category":"12vs12","place":2}],"points12v12":9,"averagePoints5v5":7,"rank5v5":8,"remainingTokens":10,"points5v5":23}},"members":["Jerry  Kenyon","Taylor johnson","Geoff Carl","Linden Holt","Alexander Thom","Alex King","Adam Keys","Derek Docherty","William Grieman","Vishea Neisius","Karl Grebe"],"sourceCreatedAt":"2024-01-23T01:53:34.041Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Twin Cities Wyverns',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Minneapolis',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'wyverns@mn-armored-combat.org'),
 website_url=coalesce(t.website_url,'https://wyverns.info'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/225dff_4a8e9e3d1e8843a29f1d683be85e7a3e~mv2.png'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jerry  Kenyon','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taylor johnson','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Geoff Carl','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Linden Holt','captain','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alexander Thom','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alex King','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adam Keys','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derek Docherty','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'William Grieman','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Vishea Neisius','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Karl Grebe','fighter','bi_teams','https://www.buhurtinternational.com/team/twin-cities-wyverns','twin-cities-wyverns',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tyr''s-raiders' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tyr''s-raiders' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tyr''s Raiders','Toowoomba',true,'active','public','bi-tyr''s-raiders','OC','Oceania','AU','Australia','mmurdoch99@hotmail.com',NULL,'https://static.wixstatic.com/media/b34314_2729be9ba06e4a429fd923045755b7d4~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tyr''s-raiders','https://www.buhurtinternational.com/team/tyr''s-raiders','Tyr''s Raiders','Toowoomba','mmurdoch99@hotmail.com',NULL,20,'{"biCollectionId":"5dd01a72-d6e2-4fbe-8d5a-71b7141490d2","teamName":"Tyr''s Raiders","club":null,"gender":"Male","captain":"Matthew Perrin","conference":"APAC","country":"Australia","city":"Toowoomba","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"mmurdoch99@hotmail.com","teamLogo":"wix:image://v1/b34314_2729be9ba06e4a429fd923045755b7d4~mv2.jpeg/4b35ae_d432cf122b6d4ad29237f957e299d248~mv2.jpeg#originWidth=579&originHeight=710","logoUrl":"https://static.wixstatic.com/media/b34314_2729be9ba06e4a429fd923045755b7d4~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":2,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":0,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":15},{"_id":"2","points":2,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":7}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":1.5,"remainingTokens":7,"tournaments":[{"_id":"1","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":10}]}},"members":["Matthew Perrin","Morgan Harrison","Matthew Harradine","Dion Muirden","Hali Taylor Stemmler","Chris \"Genie\" Atkins","Andrew byrne","Derek McAuley","Dave Melloy","Lachlan King"],"sourceCreatedAt":"2025-09-13T23:43:25.591Z","sourceUpdatedAt":"2026-09-25T08:43:22.471Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tyr''s Raiders',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Toowoomba',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'mmurdoch99@hotmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b34314_2729be9ba06e4a429fd923045755b7d4~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Perrin','captain','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Morgan Harrison','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Harradine','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dion Muirden','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hali Taylor Stemmler','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Chris "Genie" Atkins','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andrew byrne','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Derek McAuley','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dave Melloy','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lachlan King','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-raiders','tyr''s-raiders',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tyr''s-valkyries' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tyr''s-valkyries' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tyr''s Valkyries','Toowoomba',true,'active','public','bi-tyr''s-valkyries','OC','Oceania','AU','Australia','valkyries@tyrswarriors.club','https://tyrswarriors.club/','https://static.wixstatic.com/media/5e64bf_5d60dfc42582467fac05a86c6b1ee49e~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tyr''s-valkyries','https://www.buhurtinternational.com/team/tyr''s-valkyries','Tyr''s Valkyries','Toowoomba','valkyries@tyrswarriors.club','https://tyrswarriors.club/',20,'{"biCollectionId":"72bd72ec-104e-4833-8bfe-9b1f41bbdeb4","teamName":"Tyr''s Valkyries","club":null,"gender":"Female","captain":"Mary Rose O’Mullane","conference":"APAC","country":"Australia","city":"Toowoomba","teamInfo":"","trainingInfo":"","trainingLocation":{"formatted":"6/57 Brook Street, Toowoomba QLD Australia"},"websiteFacebookUrl":"https://tyrswarriors.club/","teamEmail":"valkyries@tyrswarriors.club","teamLogo":"wix:image://v1/5e64bf_5d60dfc42582467fac05a86c6b1ee49e~mv2.jpg/Valkyries%20logo.jfif#originWidth=513&originHeight=520","logoUrl":"https://static.wixstatic.com/media/5e64bf_5d60dfc42582467fac05a86c6b1ee49e~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":9,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":10,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"3vs3","place":1},{"_id":"2","points":9,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":1}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":0,"remainingTokens":8,"tournaments":[{"_id":"1","points":4.5,"Tournament":"Winterfest 2025","date":45478,"category":"3vs3","place":1},{"_id":"2","points":0.5,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"3vs3","place":4},{"_id":"3","points":6.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"3vs3","place":1}]}},"members":["Mary Rose O’Mullane","Bella Mauger","Mary Rose O''Mullane","Rhiannon Greaves","Isabel Hoffmann","Hannah Brazier","Rachel Rowe","Camille King","Natasha (Tazz Katt) Franklin","Taegan White"],"sourceCreatedAt":"2024-05-19T10:31:06.850Z","sourceUpdatedAt":"2026-09-24T18:21:41.774Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tyr''s Valkyries',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Toowoomba',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'valkyries@tyrswarriors.club'),
 website_url=coalesce(t.website_url,'https://tyrswarriors.club/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/5e64bf_5d60dfc42582467fac05a86c6b1ee49e~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mary Rose O’Mullane','captain','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bella Mauger','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mary Rose O''Mullane','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rhiannon Greaves','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Isabel Hoffmann','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Hannah Brazier','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rachel Rowe','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Camille King','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Natasha (Tazz Katt) Franklin','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Taegan White','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr''s-valkyries','tyr''s-valkyries',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='tyr’s-warriors' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-tyr’s-warriors' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Tyr’s Warriors','Toowoomba',true,'active','public','bi-tyr’s-warriors','OC','Oceania','AU','Australia','info@tyrswarriors.club','https://www.tyrswarriors.club','https://static.wixstatic.com/media/4b35ae_d432cf122b6d4ad29237f957e299d248~mv2.jpeg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','tyr’s-warriors','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','Tyr’s Warriors','Toowoomba','info@tyrswarriors.club','https://www.tyrswarriors.club',20,'{"biCollectionId":"deb3ed47-8bc4-4723-b0a2-a7c5b635cd6a","teamName":"Tyr’s Warriors","club":null,"gender":"Male","captain":"Micah Weiden","conference":"APAC","country":"Australia","city":"Toowoomba","teamInfo":"","trainingInfo":"","trainingLocation":{"city":"North Toowoomba","location":{"latitude":-27.547349,"longitude":151.9497849},"streetAddress":{"apt":"","formattedAddressLine":"57 Brook St","name":"Brook Street","number":"57"},"formatted":"57 Brook St, North Toowoomba QLD 4350, Australia","country":"AU","postalCode":"4350"},"websiteFacebookUrl":"https://www.tyrswarriors.club","teamEmail":"info@tyrswarriors.club","teamLogo":"wix:image://v1/4b35ae_d432cf122b6d4ad29237f957e299d248~mv2.jpeg/IMG_1036.jpeg#originWidth=791&originHeight=801","logoUrl":"https://static.wixstatic.com/media/4b35ae_d432cf122b6d4ad29237f957e299d248~mv2.jpeg","rank5v5":null,"averagePoints5v5":null,"points5v5":10,"rank12v12":null,"points12v12":7,"tournamentsJoined":[{"_id":"1","points":2,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"5vs5","place":7},{"_id":"2","points":7,"Tournament":"Abbeystowe Challenger 2026","date":"2026-05-30","category":"12vs12","place":2},{"_id":"3","points":8,"Tournament":"Newcastle Buhurt Cup 2026","date":"2026-09-05","category":"5vs5","place":2}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"5vs5","place":7},{"_id":"2","points":5,"Tournament":"Abbey Challenger 2024","date":"2024-05-25","category":"12vs12","place":2},{"_id":"3","points":3,"Tournament":"Trans Tasman Cup and Waihora Reborn 2024","date":"2024-07-20","category":"5vs5","place":5},{"_id":"4","points":3,"Tournament":"AMCF National Selections 2024","date":"2024-10-05","category":"5vs5","place":6}]},"2025":{"tournaments":[{"_id":"1","points":4,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"5vs5","place":7},{"_id":"2","points":0,"Tournament":"Abbeystowe Challenger/Trans Tasman Cup 2025","date":"2025-06-07","category":"12vs12","place":4},{"_id":"3","points":2,"Tournament":"Winterfest 2025","date":45478,"category":"5vs5","place":5},{"_id":"4","points":1.5,"Tournament":"AMCF National Selections 2025","date":"2025-10-03","category":"5vs5","place":5}],"points12v12":0,"averagePoints5v5":2.5,"rank5v5":5,"remainingTokens":8,"points5v5":7.5}},"members":["Micah Weiden","Brad Swales","Deiter wieden","Steven Jefferson Hartfiel","Matthew Powderham","Matthew Perrin","Liam Brady","Bob Wieden","Micah wieden","Michael Lomas","Jackson Best","Matthew Murdoch"],"sourceCreatedAt":"2023-08-29T15:12:13.204Z","sourceUpdatedAt":"2026-09-25T10:48:47.212Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Tyr’s Warriors',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Toowoomba',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('OC',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Oceania',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('AU',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Australia',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'info@tyrswarriors.club'),
 website_url=coalesce(t.website_url,'https://www.tyrswarriors.club'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4b35ae_d432cf122b6d4ad29237f957e299d248~mv2.jpeg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Micah Weiden','captain','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Brad Swales','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Deiter wieden','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Jefferson Hartfiel','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Powderham','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Perrin','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Liam Brady','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Bob Wieden','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Micah wieden','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Michael Lomas','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jackson Best','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Murdoch','fighter','bi_teams','https://www.buhurtinternational.com/team/tyr%E2%80%99s-warriors','tyr’s-warriors',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='uleåborg-fighting-cocks-1' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-uleåborg-fighting-cocks-1' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Uleåborg Fighting Cocks 1','Oulu',true,'active','public','bi-uleåborg-fighting-cocks-1','EU','Europe','FI','Finland','ufc.hallitus@gmail.com','https://fi-fi.facebook.com/ufcry/','https://static.wixstatic.com/media/b1e17c_c224aff4c697444cb30a4669333b45da~mv2.png','Small buhurt club form Oulu in northern Finland')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','uleåborg-fighting-cocks-1','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','Uleåborg Fighting Cocks 1','Oulu','ufc.hallitus@gmail.com','https://fi-fi.facebook.com/ufcry/',20,'{"biCollectionId":"7c5dc0fd-8084-488c-bd35-cd15e79d881a","teamName":"Uleåborg Fighting Cocks 1","club":null,"gender":"Male","captain":"Juho-Ville Seppälä","conference":"Europe","country":"Finland","city":"Oulu","teamInfo":"Small buhurt club form Oulu in northern Finland","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://fi-fi.facebook.com/ufcry/","teamEmail":"ufc.hallitus@gmail.com","teamLogo":"wix:image://v1/b1e17c_c224aff4c697444cb30a4669333b45da~mv2.png/PSX_20240628_153938.png#originWidth=5193&originHeight=5194","logoUrl":"https://static.wixstatic.com/media/b1e17c_c224aff4c697444cb30a4669333b45da~mv2.png","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":0,"Tournament":"Häme Cup 2024","date":"2024-08-17","category":"5vs5","place":6}]},"2025":{"remainingTokens":10}},"members":["Juho-Ville Seppälä","Juuso-Matti Seppälä","Ilkka Mämmelä","Iivo Autio","Lari Harri Ilmari Lämpsä","Mikko Jylhä","Tony Palovaara"],"sourceCreatedAt":"2024-06-29T08:49:23.963Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Uleåborg Fighting Cocks 1',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Oulu',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('FI',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Finland',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ufc.hallitus@gmail.com'),
 website_url=coalesce(t.website_url,'https://fi-fi.facebook.com/ufcry/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/b1e17c_c224aff4c697444cb30a4669333b45da~mv2.png'),
 public_description=coalesce(t.public_description,'Small buhurt club form Oulu in northern Finland'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juho-Ville Seppälä','captain','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Juuso-Matti Seppälä','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ilkka Mämmelä','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iivo Autio','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Lari Harri Ilmari Lämpsä','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mikko Jylhä','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Tony Palovaara','fighter','bi_teams','https://www.buhurtinternational.com/team/ule%C3%A5borg-fighting-cocks-1','uleåborg-fighting-cocks-1',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ulfhednar' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ulfhednar' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ulfhednar','Eastern/Midwest United States',true,'active','public','bi-ulfhednar','NA','North America','US','United States','andysoup12@gmail.com',NULL,'https://static.wixstatic.com/media/4dffae_c68ec51b6ba743ac95a3c30321a69f5a~mv2.jpg','Fighters are from New Jersey, Virginia, North Carolina, Maine, Tennessee, Ohio, Georgia and Indiana.')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ulfhednar','https://www.buhurtinternational.com/team/ulfhednar','Ulfhednar','Eastern/Midwest United States','andysoup12@gmail.com',NULL,20,'{"biCollectionId":"f621cb09-944e-4709-b0d1-121828948f87","teamName":"Ulfhednar","club":null,"gender":"Male","captain":"Andy Campbell","conference":"North America","country":"United States","city":"Eastern/Midwest United States","teamInfo":"Fighters are from New Jersey, Virginia, North Carolina, Maine, Tennessee, Ohio, Georgia and Indiana.","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":null,"teamEmail":"andysoup12@gmail.com","teamLogo":"wix:image://v1/4dffae_c68ec51b6ba743ac95a3c30321a69f5a~mv2.jpg/Bi%20logo.jpg#originWidth=1024&originHeight=1536","logoUrl":"https://static.wixstatic.com/media/4dffae_c68ec51b6ba743ac95a3c30321a69f5a~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":2.5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":2.5,"Tournament":"Cincinnati Siege 2026: Alex Ding Memorial Tournament","date":"2026-05-22","category":"5vs5","place":10}],"eventsHistory":{},"members":["John Coorey","Andy Campbell","Richard Jackman","Steven Joseph Kostusyk","Shadrick Jones","Jason Sample","Matthew Agnew","John Patrick Bogusz","Jonathan Morgan","Randell Moore","Nathan Kitchen","Cano Mattheisen","Dillon Hildebrand"],"sourceCreatedAt":"2026-03-19T15:11:09.552Z","sourceUpdatedAt":"2026-09-29T12:39:54.388Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ulfhednar',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Eastern/Midwest United States',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'andysoup12@gmail.com'),
 website_url=coalesce(t.website_url,NULL),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4dffae_c68ec51b6ba743ac95a3c30321a69f5a~mv2.jpg'),
 public_description=coalesce(t.public_description,'Fighters are from New Jersey, Virginia, North Carolina, Maine, Tennessee, Ohio, Georgia and Indiana.'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Coorey','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andy Campbell','captain','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Richard Jackman','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Steven Joseph Kostusyk','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Shadrick Jones','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason Sample','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Matthew Agnew','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'John Patrick Bogusz','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jonathan Morgan','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Randell Moore','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nathan Kitchen','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cano Mattheisen','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Dillon Hildebrand','fighter','bi_teams','https://www.buhurtinternational.com/team/ulfhednar','ulfhednar',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='urna-regnum' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-urna-regnum' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Urna Regnum','Arnedo (La Rioja)',true,'active','public','bi-urna-regnum','EU','Europe','ES','Spain','urnaregnumfacturacion@gmail.com','https://www-facebook.com/Urnaregnum','https://static.wixstatic.com/media/4a2466_bf1d2a1fc7054705aabf3649f46a87e1~mv2.jpg','Equipo español, con localización principal en Arnedo (La Rioja) y miembros en Zaragoza, Barcelona, Cantabria, Navarra y País Vasco')
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','urna-regnum','https://www.buhurtinternational.com/team/urna-regnum','Urna Regnum','Arnedo (La Rioja)','urnaregnumfacturacion@gmail.com','https://www-facebook.com/Urnaregnum',20,'{"biCollectionId":"b2adfd53-9331-44b8-bb10-be387a338e31","teamName":"Urna Regnum","club":null,"gender":"Male","captain":"Alejandro Calleja Marin","conference":"Europe","country":"Spain","city":"Arnedo (La Rioja)","teamInfo":"Equipo español, con localización principal en Arnedo (La Rioja) y miembros en Zaragoza, Barcelona, Cantabria, Navarra y País Vasco","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www-facebook.com/Urnaregnum","teamEmail":"urnaregnumfacturacion@gmail.com","teamLogo":"wix:image://v1/4a2466_bf1d2a1fc7054705aabf3649f46a87e1~mv2.jpg/Imagen%20de%20WhatsApp%202024-06-18%20a%20las%2015.40.21_29b7ca16.jpg#originWidth=1240&originHeight=1754","logoUrl":"https://static.wixstatic.com/media/4a2466_bf1d2a1fc7054705aabf3649f46a87e1~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":null,"rank12v12":null,"points12v12":null,"tournamentsJoined":[],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":1,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":7}]},"2025":{"points12v12":0,"points5v5":4,"remainingTokens":10,"tournaments":[{"_id":"1","points":4,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":4}]}},"members":["Alejandro Calleja Marin","Santiago Torres Bejarano","Luis Miranda Montes","Mariano Fuertes Rion","Denys Rohovskyi","Evgeny Viitman","Jose Perez","Adolfo Carreño","Rayco Alberto Garcia","Ernesto Guevara","Axier Gallastegui","Francisco Canto de la Torre"],"sourceCreatedAt":"2024-06-23T16:06:56.127Z","sourceUpdatedAt":"2026-09-24T18:21:37.664Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Urna Regnum',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Arnedo (La Rioja)',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'urnaregnumfacturacion@gmail.com'),
 website_url=coalesce(t.website_url,'https://www-facebook.com/Urnaregnum'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/4a2466_bf1d2a1fc7054705aabf3649f46a87e1~mv2.jpg'),
 public_description=coalesce(t.public_description,'Equipo español, con localización principal en Arnedo (La Rioja) y miembros en Zaragoza, Barcelona, Cantabria, Navarra y País Vasco'),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alejandro Calleja Marin','captain','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Santiago Torres Bejarano','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Miranda Montes','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Mariano Fuertes Rion','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Denys Rohovskyi','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Evgeny Viitman','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jose Perez','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adolfo Carreño','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Rayco Alberto Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ernesto Guevara','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Axier Gallastegui','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francisco Canto de la Torre','fighter','bi_teams','https://www.buhurtinternational.com/team/urna-regnum','urna-regnum',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='ursus-custodes' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-ursus-custodes' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Ursus Custodes','Madrid',true,'active','public','bi-ursus-custodes','EU','Europe','ES','Spain','ursus.custodes.club@gmail.com','https://www.facebook.com/ursus.custodes','https://static.wixstatic.com/media/38de6e_37c0b4cefb6944a3a376c39b499b8fea~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','ursus-custodes','https://www.buhurtinternational.com/team/ursus-custodes','Ursus Custodes','Madrid','ursus.custodes.club@gmail.com','https://www.facebook.com/ursus.custodes',20,'{"biCollectionId":"a69bbd47-3e0e-4ef6-8b84-b9f23088431c","teamName":"Ursus Custodes","club":null,"gender":"Male","captain":"Santos Muñoz","conference":"Europe","country":"Spain","city":"Madrid","teamInfo":"","trainingInfo":"","trainingLocation":null,"websiteFacebookUrl":"https://www.facebook.com/ursus.custodes","teamEmail":"ursus.custodes.club@gmail.com","teamLogo":"wix:image://v1/38de6e_37c0b4cefb6944a3a376c39b499b8fea~mv2.jpg/IMG_20230830_110612.jpg#originWidth=357&originHeight=523","logoUrl":"https://static.wixstatic.com/media/38de6e_37c0b4cefb6944a3a376c39b499b8fea~mv2.jpg","rank5v5":null,"averagePoints5v5":null,"points5v5":5,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":5,"Tournament":"Torneio Medieval de Pirescoxe 2026","date":"2026-05-02","category":"5vs5","place":3}],"eventsHistory":{"2024":{"tournaments":[{"_id":"1","points":2,"Tournament":"Desafio Belmonte 2024","date":"2024-09-21","category":"5vs5","place":6},{"_id":"2","points":1.5,"Tournament":"Torneo delle Alpi 2024","date":"2024-10-26","category":"5vs5","place":10}]},"2025":{"points12v12":0,"points5v5":10,"remainingTokens":10,"tournaments":[{"_id":"1","points":10,"Tournament":"Desafio de Belmonte 2025","date":45478,"category":"5vs5","place":2}]}},"members":["Santos Muñoz","Fernando Torrent","Adrian Preciado","Adrian Sanchez","Abraham Labra Piola","Daniel Bernardos Bueno","Miguel Angel Potenciano Garcia","Andres Martos Casas","Alberto Sánchez Martín","Diego Medina","Daniel Calvo Montilla","Francisco Diaz ''Tristan''","Luis Miguel Saez Molina","Alpi ''El Mesías''","Iván Salcedo Riesgo","David Herranz Pablo"],"sourceCreatedAt":"2023-09-07T13:21:15.815Z","sourceUpdatedAt":"2026-09-24T18:21:37.665Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Ursus Custodes',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Madrid',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('EU',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('Europe',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('ES',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('Spain',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'ursus.custodes.club@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.facebook.com/ursus.custodes'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/38de6e_37c0b4cefb6944a3a376c39b499b8fea~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Santos Muñoz','captain','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Fernando Torrent','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Preciado','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Adrian Sanchez','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Abraham Labra Piola','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Bernardos Bueno','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Miguel Angel Potenciano Garcia','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Andres Martos Casas','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alberto Sánchez Martín','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Diego Medina','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Daniel Calvo Montilla','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Francisco Diaz ''Tristan''','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Luis Miguel Saez Molina','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Alpi ''El Mesías''','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Iván Salcedo Riesgo','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'David Herranz Pablo','fighter','bi_teams','https://www.buhurtinternational.com/team/ursus-custodes','ursus-custodes',now());
end $$;
do $$ declare v_team_id uuid; v_has_hacsa boolean; begin
select team_id into v_team_id from public.team_source_records where source_kind='bi_teams' and source_record_key='vagabonds' limit 1;
if v_team_id is null then select id into v_team_id from public.teams where directory_slug='bi-vagabonds' and deleted_at is null limit 1; end if;
if v_team_id is null then
  insert into public.teams(organization_id,name,city_or_region,is_active,status,visibility,directory_slug,continent_code,continent_name,country_code,country_name,public_contact_email,website_url,logo_path,public_description)
  values((select id from public.organizations where short_name='BI' order by created_at limit 1),'Vagabonds','Seattle, Washington',true,'active','public','bi-vagabonds','NA','North America','US','United States','vagabondsbuhurt@gmail.com','https://www.vagabondsbuhurt.com/','https://static.wixstatic.com/media/75c629_3fd13370548a4ee79165c31f48ea468d~mv2.jpg',NULL)
  returning id into v_team_id;
end if;
select exists(select 1 from public.team_source_records where team_id=v_team_id and source_kind='hacsa') into v_has_hacsa;
insert into public.team_source_records(team_id,source_kind,source_record_key,source_url,source_team_name,source_location,source_contact_email,source_website_url,source_priority,source_payload,verified_at,last_synced_at)
values(v_team_id,'bi_teams','vagabonds','https://www.buhurtinternational.com/team/vagabonds','Vagabonds','Seattle, Washington','vagabondsbuhurt@gmail.com','https://www.vagabondsbuhurt.com/',20,'{"biCollectionId":"321d5f56-f4e1-41a8-b98a-9474ba0fd8fd","teamName":"Vagabonds","club":null,"gender":"Male","captain":"Johny Porter","conference":"North America","country":"United States","city":"Seattle, Washington","teamInfo":"","trainingInfo":"You will need workout clothes, some water, groin protection ideally, and a positive attitude!","trainingLocation":{"subdivisions":[{"code":"WA","name":"Washington","type":"ADMINISTRATIVE_AREA_LEVEL_1"},{"code":"King County","name":"King County","type":"ADMINISTRATIVE_AREA_LEVEL_2"},{"code":"Seattle","name":"Seattle","type":"ADMINISTRATIVE_AREA_LEVEL_3"},{"code":"Highline","name":"Highline","type":"ADMINISTRATIVE_AREA_LEVEL_4"},{"code":"US","name":"United States","type":"COUNTRY"}],"city":"Seattle","location":{"latitude":47.5115328,"longitude":-122.3147202},"streetAddress":{"apt":"","formattedAddressLine":"1418 S 103rd St","name":"South 103rd Street","number":"1418"},"formatted":"1418 S 103rd St, Seattle, WA 98168, USA","country":"US","postalCode":"98168-1622","subdivision":"WA"},"websiteFacebookUrl":"https://www.vagabondsbuhurt.com/","teamEmail":"vagabondsbuhurt@gmail.com","teamLogo":"wix:image://v1/75c629_3fd13370548a4ee79165c31f48ea468d~mv2.jpg/vagabonds-logo-vtsmall.jpg#originWidth=232&originHeight=282","logoUrl":"https://static.wixstatic.com/media/75c629_3fd13370548a4ee79165c31f48ea468d~mv2.jpg","rank5v5":7,"averagePoints5v5":9.08,"points5v5":27.25,"rank12v12":null,"points12v12":0,"tournamentsJoined":[{"_id":"1","points":7.5,"Tournament":"Carolina Carnage Fest 2026","date":"2026-02-06","category":"5vs5","place":5},{"_id":"2","points":8.75,"Tournament":"Ventura Melee Megabowl 2026","date":"2026-05-03","category":"5vs5","place":3},{"_id":"3","points":11,"Tournament":"Warrior Expo: Signet Slaughter 2026","date":"2026-09-05","category":"5vs5","place":1}],"eventsHistory":{"2024":{},"2025":{"points12v12":0,"points5v5":23,"remainingTokens":8,"tournaments":[{"_id":"1","points":12,"Tournament":"Idaho Armored Combat Invitational 2025","date":"2025-09-13","category":"5vs5","place":1},{"_id":"2","points":11,"Tournament":"Frostfall 2025","date":"2025-09-13","category":"5vs5","place":1}]}},"members":["Johny Porter","Cord Preston Goss","Jason McClelland","Ford North","Noah J Smith","Manuel York","Kaden Carpenter","Nicholas Ferriell","Kaleb Carpenter","Nicholas ashby Ferriell"],"sourceCreatedAt":"2025-06-13T05:36:07.878Z","sourceUpdatedAt":"2026-09-24T18:21:32.705Z","sourceSnapshotAt":"2026-09-29T21:23:50.308Z"}'::jsonb,now(),now())
on conflict(source_kind,source_record_key) do update set team_id=excluded.team_id,source_url=excluded.source_url,source_team_name=excluded.source_team_name,source_location=excluded.source_location,source_contact_email=excluded.source_contact_email,source_website_url=excluded.source_website_url,source_payload=excluded.source_payload,verified_at=excluded.verified_at,last_synced_at=excluded.last_synced_at,updated_at=now();
update public.teams t set
 name=case when v_has_hacsa then t.name else coalesce('Vagabonds',t.name) end,
 city_or_region=case when v_has_hacsa and t.city_or_region is not null then t.city_or_region else coalesce('Seattle, Washington',t.city_or_region) end,
 continent_code=case when v_has_hacsa and t.continent_code is not null then t.continent_code else coalesce('NA',t.continent_code) end,
 continent_name=case when v_has_hacsa and t.continent_name is not null then t.continent_name else coalesce('North America',t.continent_name) end,
 country_code=case when v_has_hacsa and t.country_code is not null then t.country_code else coalesce('US',t.country_code) end,
 country_name=case when v_has_hacsa and t.country_name is not null then t.country_name else coalesce('United States',t.country_name) end,
 public_contact_email=coalesce(t.public_contact_email,'vagabondsbuhurt@gmail.com'),
 website_url=coalesce(t.website_url,'https://www.vagabondsbuhurt.com/'),
 logo_path=coalesce(t.logo_path,'https://static.wixstatic.com/media/75c629_3fd13370548a4ee79165c31f48ea468d~mv2.jpg'),
 public_description=coalesce(t.public_description,NULL),
 updated_at=now()
where t.id=v_team_id;
delete from public.team_public_roster_sources where team_id=v_team_id and source_kind='bi_teams';
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Johny Porter','captain','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Cord Preston Goss','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Jason McClelland','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Ford North','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Noah J Smith','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Manuel York','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kaden Carpenter','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas Ferriell','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Kaleb Carpenter','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
insert into public.team_public_roster_sources(team_id,display_name,role,source_kind,source_url,source_record_key,verified_at)
values(v_team_id,'Nicholas ashby Ferriell','fighter','bi_teams','https://www.buhurtinternational.com/team/vagabonds','vagabonds',now());
end $$;
commit;
