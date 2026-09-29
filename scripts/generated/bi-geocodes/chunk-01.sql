begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.8119602),
 public_longitude=coalesce(t.public_longitude,-79.2654452),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pennsylvania'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-PA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='knyaz-usa' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.9534193),
 public_longitude=coalesce(t.public_longitude,-1.1496461),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-NTT'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='white-company-(m)' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.7762719),
 public_longitude=coalesce(t.public_longitude,-96.7968559),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='warlords' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5074456),
 public_longitude=coalesce(t.public_longitude,-0.1277653),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='invicta' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.8142454),
 public_longitude=coalesce(t.public_longitude,144.9631732),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Victoria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-VIC'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-kraken' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,37.7021521),
 public_longitude=coalesce(t.public_longitude,-121.9357918),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='company-of-the-bear' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.4221319),
 public_longitude=coalesce(t.public_longitude,-119.702667),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='soldados' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.9772995),
 public_longitude=coalesce(t.public_longitude,-93.2654692),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Minnesota'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MN'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='twin-cities-wyverns' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.7157062),
 public_longitude=coalesce(t.public_longitude,-117.1638284),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ordo-draconis' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.6038321),
 public_longitude=coalesce(t.public_longitude,-122.330062),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Washington'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vagabonds' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.4689623),
 public_longitude=coalesce(t.public_longitude,153.0235009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='beasts(m)' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.8339578),
 public_longitude=coalesce(t.public_longitude,-104.825348),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Colorado'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wardens' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.8698439),
 public_longitude=coalesce(t.public_longitude,151.2082848),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-havoc' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.8653705),
 public_longitude=coalesce(t.public_longitude,-2.2458192),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-GLS'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='armoured-combat-gloucester' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,33.4509513),
 public_longitude=coalesce(t.public_longitude,-90.6550917),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Mississippi'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MS'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-new-order' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.1012809),
 public_longitude=coalesce(t.public_longitude,-84.5127405),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ohio'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='cincinnati-barbarians' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,33.4709714),
 public_longitude=coalesce(t.public_longitude,-81.9748429),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Georgia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-GA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='bastion' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.4424618),
 public_longitude=coalesce(t.public_longitude,-2.2324547),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-MAN'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-northern-wolves' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.5623013),
 public_longitude=coalesce(t.public_longitude,143.8605645),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Victoria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-VIC'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='western-wolves' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.9527237),
 public_longitude=coalesce(t.public_longitude,-75.1635262),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pennsylvania'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-PA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='exiles' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.0553813),
 public_longitude=coalesce(t.public_longitude,-2.7151735),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-HEF'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='isca' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,55.861155),
 public_longitude=coalesce(t.public_longitude,-4.2501687),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alba / Scotland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-GLG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='glasgow-sword-breakers-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.2320309),
 public_longitude=coalesce(t.public_longitude,15.7251022),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kraj Vysočina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-634'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mfc-vysocina' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.4948994),
 public_longitude=coalesce(t.public_longitude,-1.8518439),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-BIR'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='bmc-vanguard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.4689623),
 public_longitude=coalesce(t.public_longitude,153.0235009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='beasts-blood-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.8142454),
 public_longitude=coalesce(t.public_longitude,144.9631732),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Victoria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-VIC'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-kraken-green' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.1371079),
 public_longitude=coalesce(t.public_longitude,11.5753822),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bayern'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-BY'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sword-gym-münchen' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.1674263),
 public_longitude=coalesce(t.public_longitude,-115.1484131),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nevada'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NV'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='death-dealers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.1263106),
 public_longitude=coalesce(t.public_longitude,16.9781963),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo dolnośląskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-02'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='raubitters' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.3578899),
 public_longitude=coalesce(t.public_longitude,151.3783471),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='raven-guard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.4617238),
 public_longitude=coalesce(t.public_longitude,0.6975642),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='east-anglia-armoured-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.0536909),
 public_longitude=coalesce(t.public_longitude,-118.242766),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='la-golden-knights' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.0237848),
 public_longitude=coalesce(t.public_longitude,-84.5576217),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kentucky'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-KY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='lexington-lycans' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-35.2975906),
 public_longitude=coalesce(t.public_longitude,149.1012676),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'District of Canberra Central'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-ACT'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='canberra-burly-griffins' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.4278083),
 public_longitude=coalesce(t.public_longitude,150.893054),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='knights-of-albion' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-26.6544338),
 public_longitude=coalesce(t.public_longitude,153.0933668),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-vultures' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.2587459),
 public_longitude=coalesce(t.public_longitude,-95.9383758),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nebraska'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NE'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='omaha-hell-hounds' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.4816546),
 public_longitude=coalesce(t.public_longitude,-3.1791934),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Cymru / Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-CRF'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='draig' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.000754),
 public_longitude=coalesce(t.public_longitude,-81.0352313),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'South Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-SC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='(a)''wesome-(o)''possums' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.721596),
 public_longitude=coalesce(t.public_longitude,150.452826),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='havoc-blood-claws' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,33.7544657),
 public_longitude=coalesce(t.public_longitude,-84.3898151),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Georgia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-GA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='atlanta-valor' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.8142454),
 public_longitude=coalesce(t.public_longitude,144.9631732),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Victoria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-VIC'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='heroic-hares' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.006381),
 public_longitude=coalesce(t.public_longitude,28.9758715),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Marmara Bölgesi'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'TR-34'),
 country_code=coalesce(nullif(t.country_code,''),'TR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='free-fighters' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.9527237),
 public_longitude=coalesce(t.public_longitude,-75.1635262),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pennsylvania'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-PA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='philadelphia-hellcats' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-35.2975906),
 public_longitude=coalesce(t.public_longitude,149.1012676),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'District of Canberra Central'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-ACT'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='hippogriffs' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.7656251),
 public_longitude=coalesce(t.public_longitude,-71.4677032),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New Hampshire'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-headsmen' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-31.9558967),
 public_longitude=coalesce(t.public_longitude,115.8605784),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Western Australia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-WA'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wa-destriers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.6445197),
 public_longitude=coalesce(t.public_longitude,-114.044788),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='arverni-legion' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.9747357),
 public_longitude=coalesce(t.public_longitude,14.474285),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Jihočeský kraj'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-311'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mamánci' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='independence-dragons' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.3484804),
 public_longitude=coalesce(t.public_longitude,4.6398673),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Antwerpen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BE-VAN'),
 country_code=coalesce(nullif(t.country_code,''),'BE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='de-bockenreyders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,37.3399964),
 public_longitude=coalesce(t.public_longitude,-4.5811614),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Andalucía'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-AN'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='zona-sur' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.4641943),
 public_longitude=coalesce(t.public_longitude,9.1896346),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Lombardia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-MI'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='cavalieri-di-ranaan' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.1584617),
 public_longitude=coalesce(t.public_longitude,15.7468543),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Niederösterreich'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AT-3'),
 country_code=coalesce(nullif(t.country_code,''),'AT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='medieval-combat-union-pyhra' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5074456),
 public_longitude=coalesce(t.public_longitude,-0.1277653),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='knightmares' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.6859006),
 public_longitude=coalesce(t.public_longitude,176.167505),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bay of Plenty'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-BOP'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='titans' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.8955367),
 public_longitude=coalesce(t.public_longitude,-97.1384584),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Manitoba'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-MB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mace-company' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.4689623),
 public_longitude=coalesce(t.public_longitude,153.0235009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='she-beasts' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.3282887),
 public_longitude=coalesce(t.public_longitude,-59.1356957),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-B'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='centinelas' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5074456),
 public_longitude=coalesce(t.public_longitude,-0.1277653),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='knyaz-uk-(m)' limit 1);

commit;