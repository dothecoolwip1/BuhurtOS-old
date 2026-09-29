begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,-32.9593609),
 public_longitude=coalesce(t.public_longitude,-60.6617024),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Santa Fe'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-S'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='yunque-&-martillo' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,37.6922361),
 public_longitude=coalesce(t.public_longitude,-97.3375448),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kansas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-KS'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wichita-bison' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,37.9755648),
 public_longitude=coalesce(t.public_longitude,23.7348324),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Περιφέρεια Αττικής'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GR-I'),
 country_code=coalesce(nullif(t.country_code,''),'GR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='protospatharii' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.5610193),
 public_longitude=coalesce(t.public_longitude,151.953351),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tyr''s-valkyries' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.0884689),
 public_longitude=coalesce(t.public_longitude,-81.1802101),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'South Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-SC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='one-eyed-one--horned-flying-purple-people-eaters' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.5780381),
 public_longitude=coalesce(t.public_longitude,-116.5616885),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Idaho'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-ID'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='rat-pack' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-31.4299499),
 public_longitude=coalesce(t.public_longitude,152.9103525),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mid-north-coast-crusaders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,28.5421218),
 public_longitude=coalesce(t.public_longitude,-81.379045),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Florida'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-FL'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='rogues' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.416782),
 public_longitude=coalesce(t.public_longitude,-3.703507),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunidad de Madrid'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-MD'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sala-de-armas-carranza' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.5935919),
 public_longitude=coalesce(t.public_longitude,-0.9388829),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Aragón'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-Z'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='renacidos' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.8354045),
 public_longitude=coalesce(t.public_longitude,18.292978),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Moravskoslezský kraj'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-806'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mfc-slezsko' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5234561),
 public_longitude=coalesce(t.public_longitude,-0.2592862),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-EAL'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='swords-of-cygnus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.7762719),
 public_longitude=coalesce(t.public_longitude,-96.7968559),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dallas-mythics' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.5973002),
 public_longitude=coalesce(t.public_longitude,-48.5496098),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Santa Catarina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SC'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='new-order' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.8476352),
 public_longitude=coalesce(t.public_longitude,9.6665313),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Emilia-Romagna'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-PC'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='basilisk' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.6365654),
 public_longitude=coalesce(t.public_longitude,3.0635282),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Hauts-de-France'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-59'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='arma-flandriae' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.0874654),
 public_longitude=coalesce(t.public_longitude,14.4212535),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-10'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='prague-vixens' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.5810606),
 public_longitude=coalesce(t.public_longitude,-121.493895),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='warpigs' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.1496278),
 public_longitude=coalesce(t.public_longitude,10.2134046),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Region Midtjylland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DK-82'),
 country_code=coalesce(nullif(t.country_code,''),'DK'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='aros-buhurt-club' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.1674263),
 public_longitude=coalesce(t.public_longitude,-115.1484131),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nevada'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NV'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='death-dealers-umbra' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.416782),
 public_longitude=coalesce(t.public_longitude,-3.703507),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunidad de Madrid'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-MD'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='indomitus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='harpias-combate-medieval' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-36.852095),
 public_longitude=coalesce(t.public_longitude,174.7631803),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auckland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-AUK'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='auckland-armoured-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.5610193),
 public_longitude=coalesce(t.public_longitude,151.953351),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tyr''s-raiders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.9527237),
 public_longitude=coalesce(t.public_longitude,-75.1635262),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pennsylvania'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-PA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='outcasts' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.40726),
 public_longitude=coalesce(t.public_longitude,8.9338624),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Liguria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-GE'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='san-giorgio-fight-team' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.6945782),
 public_longitude=coalesce(t.public_longitude,-112.8331033),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-company-of-the-black-spears' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.5225021),
 public_longitude=coalesce(t.public_longitude,150.840466),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='illawarra-manticore-medieval-combat-inc' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.1111324),
 public_longitude=coalesce(t.public_longitude,5.1395849),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Grand Est'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-52'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='chaumont-béhourd' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.7578137),
 public_longitude=coalesce(t.public_longitude,4.8320114),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auvergne-Rhône-Alpes'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-69M'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='la-confrérie-des-loups' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.139981),
 public_longitude=coalesce(t.public_longitude,-104.820246),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Wyoming'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wyoming-free-company-f' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.6038321),
 public_longitude=coalesce(t.public_longitude,-122.330062),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Washington'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vagabonds-errant' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.9534193),
 public_longitude=coalesce(t.public_longitude,-1.1496461),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-NTT'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='white-company-(w)' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.9493977),
 public_longitude=coalesce(t.public_longitude,24.1051846),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'LV-RIX'),
 country_code=coalesce(nullif(t.country_code,''),'LV'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='medieval-combat-school-"leonid"' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.40726),
 public_longitude=coalesce(t.public_longitude,8.9338624),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Liguria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-GE'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='aquila-ferox' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.5202471),
 public_longitude=coalesce(t.public_longitude,-122.674194),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oregon'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OR'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='death-jesters' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,33.4151005),
 public_longitude=coalesce(t.public_longitude,-111.831455),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Arizona'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-AZ'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='phoenix-blood-eagles' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.7578137),
 public_longitude=coalesce(t.public_longitude,4.8320114),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auvergne-Rhône-Alpes'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-69M'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='lupus-fratum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.2640845),
 public_longitude=coalesce(t.public_longitude,-2.9202408),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bretagne'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-BRE'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ar-groaz-du' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.0893891),
 public_longitude=coalesce(t.public_longitude,8.6295216),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Region Midtjylland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DK-82'),
 country_code=coalesce(nullif(t.country_code,''),'DK'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='broderskabet-sons-of-haddock' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.8588897),
 public_longitude=coalesce(t.public_longitude,2.320041),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Île-de-France'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-75C'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-lys-de-france' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='valherjes' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,60.1666204),
 public_longitude=coalesce(t.public_longitude,24.9435408),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Uusimaa'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FI-18'),
 country_code=coalesce(nullif(t.country_code,''),'FI'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='helsinki-medieval-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.6915847),
 public_longitude=coalesce(t.public_longitude,-0.9101268),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Aragón'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-Z'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='draconis-armatus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-26.6544338),
 public_longitude=coalesce(t.public_longitude,153.0933668),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-vultures' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.3315509),
 public_longitude=coalesce(t.public_longitude,-83.0466403),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Michigan'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MI'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='order-of-the-pegasus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.9493977),
 public_longitude=coalesce(t.public_longitude,24.1051846),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'LV-RIX'),
 country_code=coalesce(nullif(t.country_code,''),'LV'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='livland' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.4978789),
 public_longitude=coalesce(t.public_longitude,19.0402383),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Közép-Magyarország'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'HU-BU'),
 country_code=coalesce(nullif(t.country_code,''),'HU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ferreus-lupus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,29.7725425),
 public_longitude=coalesce(t.public_longitude,-95.241258),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='matagots' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.0874654),
 public_longitude=coalesce(t.public_longitude,14.4212535),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-10'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='skskb-praha' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.0677551),
 public_longitude=coalesce(t.public_longitude,7.6824892),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Piemonte'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-TO'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='taurus-mfc' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.5501721),
 public_longitude=coalesce(t.public_longitude,10.0013165),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-HH'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='decima' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.2298399),
 public_longitude=coalesce(t.public_longitude,-123.2180414),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oregon'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OR'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dominus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.4714722),
 public_longitude=coalesce(t.public_longitude,10.6797912),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Toscana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-PI'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iron-tower' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.8462236),
 public_longitude=coalesce(t.public_longitude,-77.3063733),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Virginia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-VA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iron-lions-vanguard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.9632425),
 public_longitude=coalesce(t.public_longitude,-85.6678639),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Michigan'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MI'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='loc-mor-kelpies' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.5202471),
 public_longitude=coalesce(t.public_longitude,-122.674194),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oregon'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OR'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='athena''s-wrath-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.962493),
 public_longitude=coalesce(t.public_longitude,-76.7276989),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pennsylvania'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-PA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-forsaken' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.8698439),
 public_longitude=coalesce(t.public_longitude,151.2082848),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sydney-city-marauders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.8698439),
 public_longitude=coalesce(t.public_longitude,151.2082848),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-havoc-(f)' limit 1);

commit;