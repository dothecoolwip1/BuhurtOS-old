begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.9281805),
 public_longitude=coalesce(t.public_longitude,138.5999312),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'South Australia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-SA'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ironclad-academy-of-the-sword' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.1012809),
 public_longitude=coalesce(t.public_longitude,-84.5127405),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ohio'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='river-sirens' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.7309697),
 public_longitude=coalesce(t.public_longitude,7.4248152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),NULL),
 country_code=coalesce(nullif(t.country_code,''),'MC'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='grimaldi-milites' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.6254063),
 public_longitude=coalesce(t.public_longitude,-90.190009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Missouri'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='legion-of-honor' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.1012809),
 public_longitude=coalesce(t.public_longitude,-84.5127405),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ohio'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='barbarians-ice' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.1684483),
 public_longitude=coalesce(t.public_longitude,3.2410883),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Auvergne-Rhône-Alpes'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-03'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-bannerets-d''auvergne' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.2195051),
 public_longitude=coalesce(t.public_longitude,6.192811),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Grand Est'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-57'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='lotharii-regnum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,59.9133301),
 public_longitude=coalesce(t.public_longitude,10.7389701),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NO-03'),
 country_code=coalesce(nullif(t.country_code,''),'NO'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='norsemen' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.7931661),
 public_longitude=coalesce(t.public_longitude,-94.344488),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='shadow-company' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.8588897),
 public_longitude=coalesce(t.public_longitude,2.320041),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Île-de-France'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-75C'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='les-gargouilles-de-paris' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6161231),
 public_longitude=coalesce(t.public_longitude,-58.4356212),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='grifas-valherjes' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.938361),
 public_longitude=coalesce(t.public_longitude,6.959974),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nordrhein-Westfalen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-NW'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='masnada' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.15),
 public_longitude=coalesce(t.public_longitude,13.166667),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Skåne län'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'SE-M'),
 country_code=coalesce(nullif(t.country_code,''),'SE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='scania-jacks' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.4237276),
 public_longitude=coalesce(t.public_longitude,-3.6899043),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunidad de Madrid'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-MD'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='s.a.w.' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.2083537),
 public_longitude=coalesce(t.public_longitude,16.3725042),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AT-9'),
 country_code=coalesce(nullif(t.country_code,''),'AT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vienna-basilisks' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.9254179),
 public_longitude=coalesce(t.public_longitude,-8.5426688),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Aveiro'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PT-01'),
 country_code=coalesce(nullif(t.country_code,''),'PT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='portvcale-combate-medieval' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.5256963),
 public_longitude=coalesce(t.public_longitude,-113.296631),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='strathcona-warhorse-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.5695818),
 public_longitude=coalesce(t.public_longitude,2.6500745),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Illes Balears'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-PM'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='guàrdia-del-mar' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.1174186),
 public_longitude=coalesce(t.public_longitude,7.3094552),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Piemonte'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-TO'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='santau' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ignis-bellum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6161231),
 public_longitude=coalesce(t.public_longitude,-58.4356212),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='newbery-vulpes' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.2677639),
 public_longitude=coalesce(t.public_longitude,18.4285404),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Dunántúl'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'HU-TO'),
 country_code=coalesce(nullif(t.country_code,''),'HU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='desdichado-medieval-fight-club' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.8701049),
 public_longitude=coalesce(t.public_longitude,-113.995267),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Montana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sun-eaters' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.1563122),
 public_longitude=coalesce(t.public_longitude,-95.9927516),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Oklahoma'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OK'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='tulsa-free-company' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,61.4866126),
 public_longitude=coalesce(t.public_longitude,21.7972071),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Satakunta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FI-17'),
 country_code=coalesce(nullif(t.country_code,''),'FI'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mcs-satakunta' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.0493286),
 public_longitude=coalesce(t.public_longitude,13.7381437),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Sachsen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-SN'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='eiserne-löwen' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.8339578),
 public_longitude=coalesce(t.public_longitude,-104.825348),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Colorado'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CO'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='colorado-wardames' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.4135582),
 public_longitude=coalesce(t.public_longitude,-80.7013751),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'North Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='hell''s-belles' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.0244535),
 public_longitude=coalesce(t.public_longitude,-71.5517636),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Región de Valparaíso'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CL-VS'),
 country_code=coalesce(nullif(t.country_code,''),'CL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='spartoi' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.0456064),
 public_longitude=coalesce(t.public_longitude,-114.057541),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='silver-gryphons' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.4991723),
 public_longitude=coalesce(t.public_longitude,8.7291498),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Zürich'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CH-ZH'),
 country_code=coalesce(nullif(t.country_code,''),'CH'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='säbelrassler' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.1293575),
 public_longitude=coalesce(t.public_longitude,-66.7917966),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Eastern Canada'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),NULL),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='crimson-tulips' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,29.7589382),
 public_longitude=coalesce(t.public_longitude,-95.3676974),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='san-jacinto-knights' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.3588336),
 public_longitude=coalesce(t.public_longitude,-71.0578303),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Massachusetts'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vandals' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,60.9966192),
 public_longitude=coalesce(t.public_longitude,24.465141),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Kanta-Häme'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FI-06'),
 country_code=coalesce(nullif(t.country_code,''),'FI'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='kivuttaret' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.584614),
 public_longitude=coalesce(t.public_longitude,7.7507127),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Grand Est'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-67'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ostlander' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.1263106),
 public_longitude=coalesce(t.public_longitude,16.9781963),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo dolnośląskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-02'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='rks-sileisa' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,31.2312707),
 public_longitude=coalesce(t.public_longitude,121.4700152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'上海市'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CN-SH'),
 country_code=coalesce(nullif(t.country_code,''),'CN'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='solar-knight' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.6975175),
 public_longitude=coalesce(t.public_longitude,-85.5162552),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alabama'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-AL'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='order-of-the-black-bear' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.1006693),
 public_longitude=coalesce(t.public_longitude,3.0777594),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Occitanie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-12'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='la-salle-d''armes-école-ancienne-aveyron' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.4697065),
 public_longitude=coalesce(t.public_longitude,-0.3763353),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunitat Valenciana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-V'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='valentia-regnum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='silver-guard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.2872408),
 public_longitude=coalesce(t.public_longitude,0.7144705),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Centre-Val de Loire'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-37'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='faucons-noirs' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='newbery-fox' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-41.2887953),
 public_longitude=coalesce(t.public_longitude,174.7772114),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Wellington'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-WGN'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ruckus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5705349),
 public_longitude=coalesce(t.public_longitude,5.3713218),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Noord-Brabant'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NL-NB'),
 country_code=coalesce(nullif(t.country_code,''),'NL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='lions-of-steel' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.2333742),
 public_longitude=coalesce(t.public_longitude,21.0711489),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo mazowieckie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-14'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='bober-krv' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,38.8263302),
 public_longitude=coalesce(t.public_longitude,-9.1238076),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Lisboa'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PT-11'),
 country_code=coalesce(nullif(t.country_code,''),'PT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='companhia-do-punho-de-ferro' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,34.7851861),
 public_longitude=coalesce(t.public_longitude,-84.7352262),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Georgia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-GA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='invictus' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.4257456),
 public_longitude=coalesce(t.public_longitude,-104.237612),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New Mexico'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NM'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='invaders-armored-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.0677551),
 public_longitude=coalesce(t.public_longitude,7.6824892),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Piemonte'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-TO'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='italian-bastards' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.8653705),
 public_longitude=coalesce(t.public_longitude,-2.2458192),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-GLS'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='hellions' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.9976168),
 public_longitude=coalesce(t.public_longitude,-57.5482079),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-B'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dragonas' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.0686867),
 public_longitude=coalesce(t.public_longitude,34.8246812),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'מחוז תל אביב'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IL-TA'),
 country_code=coalesce(nullif(t.country_code,''),'IL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='irone-dome' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.94095),
 public_longitude=coalesce(t.public_longitude,12.2260232),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bayern'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-BY'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='schwarzkittel' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,44.4361414),
 public_longitude=coalesce(t.public_longitude,26.102684),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'RO-B'),
 country_code=coalesce(nullif(t.country_code,''),'RO'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='brown-bear-company' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.9281805),
 public_longitude=coalesce(t.public_longitude,138.5999312),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'South Australia'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-SA'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='hellhounds' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.2577886),
 public_longitude=coalesce(t.public_longitude,4.031926),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Grand Est'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-51'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='exactor-mortis' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.2587459),
 public_longitude=coalesce(t.public_longitude,-95.9383758),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nebraska'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NE'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='chimera-armored-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,32.9515472),
 public_longitude=coalesce(t.public_longitude,-96.9034244),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Texas'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TX'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dallas-lancers' limit 1);

commit;