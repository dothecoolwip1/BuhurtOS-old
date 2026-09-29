begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.4404591),
 public_longitude=coalesce(t.public_longitude,1.0939658),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Normandie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-76'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='diex-aie-secondus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.3619514),
 public_longitude=coalesce(t.public_longitude,-9.157153),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Leiria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PT-10'),
 country_code=coalesce(nullif(t.country_code,''),'PT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='armis-nostrum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.7961287),
 public_longitude=coalesce(t.public_longitude,3.570579),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bourgogne-Franche-Comté'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-89'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-descendants-du-hardi' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.8588897),
 public_longitude=coalesce(t.public_longitude,2.320041),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Île-de-France'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-75C'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='martel' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.7169694),
 public_longitude=coalesce(t.public_longitude,4.610416),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Brabant wallon'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BE-WBR'),
 country_code=coalesce(nullif(t.country_code,''),'BE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='auream-excubitores' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.2690628),
 public_longitude=coalesce(t.public_longitude,-113.8141464),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='red-deer-reavers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.139981),
 public_longitude=coalesce(t.public_longitude,-104.820246),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Wyoming'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wyoming-free-company-m' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.0538286),
 public_longitude=coalesce(t.public_longitude,3.7250121),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oost-Vlaanderen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BE-VOV'),
 country_code=coalesce(nullif(t.country_code,''),'BE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='green-bastards' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.0469432),
 public_longitude=coalesce(t.public_longitude,19.9971534),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo małopolskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-12'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sierotki' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.5363166),
 public_longitude=coalesce(t.public_longitude,6.0169531),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bourgogne-Franche-Comté'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-39'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-comtois' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.7127281),
 public_longitude=coalesce(t.public_longitude,-74.0060152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New York'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sentinels' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.0448424),
 public_longitude=coalesce(t.public_longitude,-65.3657954),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Tucumán'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-T'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='argentum-combate-historico-medieval' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,37.1778013),
 public_longitude=coalesce(t.public_longitude,-93.3247982),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Missouri'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iron-alliance' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.4690939),
 public_longitude=coalesce(t.public_longitude,-1.5228712),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nouvelle-Aquitaine'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-64'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='akerbeltz' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.1196964),
 public_longitude=coalesce(t.public_longitude,6.1763552),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Grand Est'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-57'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='graoully' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.3855592),
 public_longitude=coalesce(t.public_longitude,6.2980123),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Provence-Alpes-Côte d''Azur'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-83'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-vassaux-de-provence' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.5202471),
 public_longitude=coalesce(t.public_longitude,-122.674194),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oregon'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OR'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='portland-reavers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.4689623),
 public_longitude=coalesce(t.public_longitude,153.0235009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wild-wyverns' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.0796915),
 public_longitude=coalesce(t.public_longitude,-81.5196683),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ohio'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='akron-hedge-knights-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,60.9966192),
 public_longitude=coalesce(t.public_longitude,24.465141),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kanta-Häme'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FI-06'),
 country_code=coalesce(nullif(t.country_code,''),'FI'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tavastia-armigeri' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.7973912),
 public_longitude=coalesce(t.public_longitude,24.1519202),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Sibiu'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'RO-SB'),
 country_code=coalesce(nullif(t.country_code,''),'RO'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mfc-draco' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.7077507),
 public_longitude=coalesce(t.public_longitude,-9.1365919),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Lisboa'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PT-11'),
 country_code=coalesce(nullif(t.country_code,''),'PT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='serra-red-lions' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.5610193),
 public_longitude=coalesce(t.public_longitude,151.953351),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tyr’s-warriors' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-36.852095),
 public_longitude=coalesce(t.public_longitude,174.7631803),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auckland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-AUK'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='pukekohe-paladins' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,35.3540209),
 public_longitude=coalesce(t.public_longitude,-120.375716),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='manticores' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,35.9603948),
 public_longitude=coalesce(t.public_longitude,-83.9210261),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Tennessee'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TN'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dauntless-armored-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.3211088),
 public_longitude=coalesce(t.public_longitude,13.151022),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Salzburg'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AT-5'),
 country_code=coalesce(nullif(t.country_code,''),'AT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vk-salzburg-innagebirg' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.0726355),
 public_longitude=coalesce(t.public_longitude,-79.7919754),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'North Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vandals-ii' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.8701049),
 public_longitude=coalesce(t.public_longitude,-113.995267),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Montana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='scarlet-tempest' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.2538589),
 public_longitude=coalesce(t.public_longitude,4.6456631),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Occitanie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-30'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-bannis-de-la-grenouille' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,27.7567667),
 public_longitude=coalesce(t.public_longitude,-81.4639835),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Florida'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-FL'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='florida-men' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,31.2312707),
 public_longitude=coalesce(t.public_longitude,121.4700152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'上海市'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CN-SH'),
 country_code=coalesce(nullif(t.country_code,''),'CN'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='half-ton' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.6534817),
 public_longitude=coalesce(t.public_longitude,-79.3839347),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ontario'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-ON'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='northblood' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.100105),
 public_longitude=coalesce(t.public_longitude,-94.5781416),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Missouri'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='banished' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.0560828),
 public_longitude=coalesce(t.public_longitude,-118.2358646),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-berserkers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.3448498),
 public_longitude=coalesce(t.public_longitude,-3.6812477),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Castilla y León'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-BU'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='castilla' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.4948994),
 public_longitude=coalesce(t.public_longitude,-1.8518439),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-BIR'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='bmc-banshees' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.250559),
 public_longitude=coalesce(t.public_longitude,22.5701022),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo lubelskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-06'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='lwy-lublin' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.4225192),
 public_longitude=coalesce(t.public_longitude,-111.714358),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Utah'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-UT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='nomads-armored-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.3679627),
 public_longitude=coalesce(t.public_longitude,-3.3550331),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Castilla-La Mancha'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-CR'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='anima-belli' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.9019078),
 public_longitude=coalesce(t.public_longitude,20.5838491),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo świętokrzyskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-26'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='manticore' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.1389753),
 public_longitude=coalesce(t.public_longitude,8.2146017),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Niedersachsen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-NI'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ramstäk-frisia' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.6484505),
 public_longitude=coalesce(t.public_longitude,0.1561947),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nouvelle-Aquitaine'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-16'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tallàe-fer' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-31.9558967),
 public_longitude=coalesce(t.public_longitude,115.8605784),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Western Australia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-WA'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='west-australian-berserkers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.8755616),
 public_longitude=coalesce(t.public_longitude,-87.6244212),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Illinois'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-IL'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='chicago-hydras' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.9281805),
 public_longitude=coalesce(t.public_longitude,138.5999312),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'South Australia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-SA'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='warhounds-armoured-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='war-badgers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.3877429),
 public_longitude=coalesce(t.public_longitude,-0.0439057),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nouvelle-Aquitaine'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-33'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sanctis-draconis-petrocoria' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.2542376),
 public_longitude=coalesce(t.public_longitude,-85.759407),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kentucky'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-KY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='louisville-royals' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-36.852095),
 public_longitude=coalesce(t.public_longitude,174.7631803),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auckland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-AUK'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='auckland-man-o’-war' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.8339578),
 public_longitude=coalesce(t.public_longitude,-104.825348),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Colorado'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wards' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.434999),
 public_longitude=coalesce(t.public_longitude,6.759562),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nordrhein-Westfalen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-NW'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ruhrpott-knights' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5074456),
 public_longitude=coalesce(t.public_longitude,-0.1277653),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='invicta-rising' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.7762719),
 public_longitude=coalesce(t.public_longitude,-96.7968559),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dallas-mythics-red' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.5135356),
 public_longitude=coalesce(t.public_longitude,-93.7477839),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Louisiana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-LA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='shreveport-swamp-puppies' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.0410578),
 public_longitude=coalesce(t.public_longitude,-74.1182492),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New York'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='north-ga-crusaders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.4623626),
 public_longitude=coalesce(t.public_longitude,6.4856075),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Provence-Alpes-Côte d''Azur'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-83'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-vassaux-de-provence-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.3493795),
 public_longitude=coalesce(t.public_longitude,-6.2605593),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Leinster'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IE-D'),
 country_code=coalesce(nullif(t.country_code,''),'IE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='fragarach-amoured-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,30.2711286),
 public_longitude=coalesce(t.public_longitude,-97.7436995),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='austin-blood-guard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.2094255),
 public_longitude=coalesce(t.public_longitude,10.4589044),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Thüringen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-TH'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ferox' limit 1);

commit;