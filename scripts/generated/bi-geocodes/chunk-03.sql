begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.4629097),
 public_longitude=coalesce(t.public_longitude,6.4786269),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Provence-Alpes-Côte d''Azur'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-83'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='cicadidae-de-provence' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.4697065),
 public_longitude=coalesce(t.public_longitude,-0.3763353),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunitat Valenciana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-V'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='victrix' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.6080651),
 public_longitude=coalesce(t.public_longitude,9.0284647),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Hessen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-HE'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='nassauer-löwen' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.2273401),
 public_longitude=coalesce(t.public_longitude,-2.0995697),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'La Rioja'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-RI'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='urna-regnum' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='guarda-de-são-jorge' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.9540017),
 public_longitude=coalesce(t.public_longitude,-2.5472538),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bretagne'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-56'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='korventenn-an-ermin' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-33.8698439),
 public_longitude=coalesce(t.public_longitude,151.2082848),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='old-mates' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.3496953),
 public_longitude=coalesce(t.public_longitude,-74.6597376),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New Jersey'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NJ'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='bloodhounds' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-38.6866197),
 public_longitude=coalesce(t.public_longitude,176.0694773),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Waikato'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-WKO'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='honeybadgers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.7766839),
 public_longitude=coalesce(t.public_longitude,20.476507),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo warmińsko-mazurskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-28'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='warmińska-dzika-kompania' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.7194842),
 public_longitude=coalesce(t.public_longitude,12.8980967),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bayern'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-BY'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vmvk-alpenkrieger' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.416782),
 public_longitude=coalesce(t.public_longitude,-3.703507),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunidad de Madrid'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-MD'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ursus-custodes' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.5074456),
 public_longitude=coalesce(t.public_longitude,-0.1277653),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'England'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-ENG'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='knyaz-uk-(w)' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.4996574),
 public_longitude=coalesce(t.public_longitude,-81.6936772),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ohio'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-OH'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='victoriam' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-18.5136365),
 public_longitude=coalesce(t.public_longitude,141.9670155),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ruthless-rabbits' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,48.1435026),
 public_longitude=coalesce(t.public_longitude,17.1082867),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Bratislavský kraj'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'SK-BL'),
 country_code=coalesce(nullif(t.country_code,''),'SK'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='pressburg-iron-company' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,35.4798757),
 public_longitude=coalesce(t.public_longitude,-79.1802994),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'North Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='imperium-victrix' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,45.8354243),
 public_longitude=coalesce(t.public_longitude,1.2644847),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Nouvelle-Aquitaine'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-87'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ardents' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-22.9110137),
 public_longitude=coalesce(t.public_longitude,-43.2093727),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Rio de Janeiro'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-RJ'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='mamutes' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.0386475),
 public_longitude=coalesce(t.public_longitude,-87.9090751),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Wisconsin'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WI'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='milwaukee-iron-stags' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.7394421),
 public_longitude=coalesce(t.public_longitude,-119.78483),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'California'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-CA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='order-of-the-gauntlet-and-rose' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,49.0677708),
 public_longitude=coalesce(t.public_longitude,0.3138532),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Normandie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-NOR'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='diex-aie' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,57.0462626),
 public_longitude=coalesce(t.public_longitude,9.9215263),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Region Nordjylland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DK-81'),
 country_code=coalesce(nullif(t.country_code,''),'DK'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iron-wolves-women''s-team' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.7127281),
 public_longitude=coalesce(t.public_longitude,-74.0060152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New York'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='rat-queens' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-37.9976168),
 public_longitude=coalesce(t.public_longitude,-57.5482079),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-B'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dragones-atlánticos' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.0448424),
 public_longitude=coalesce(t.public_longitude,-65.3657954),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Tucumán'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-T'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='león-albino' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6640796),
 public_longitude=coalesce(t.public_longitude,-58.5833995),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-B'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='pico-de-cuervo' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.2056991),
 public_longitude=coalesce(t.public_longitude,-83.3529754),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Michigan'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MI'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='detroit-fight-club' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.3825802),
 public_longitude=coalesce(t.public_longitude,2.177073),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Catalunya'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-B'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='born' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='irmandade-dos-espinhos' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-41.2887953),
 public_longitude=coalesce(t.public_longitude,174.7772114),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Wellington'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'NZ-WGN'),
 country_code=coalesce(nullif(t.country_code,''),'NZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ruckus-revenants' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='cecm---eagles' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.0874654),
 public_longitude=coalesce(t.public_longitude,14.4212535),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-10'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='pikarti' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,46.0985679),
 public_longitude=coalesce(t.public_longitude,-64.8004265),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New Brunswick / Nouveau-Brunswick'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-NB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='moncton-marauders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,39.4225192),
 public_longitude=coalesce(t.public_longitude,-111.714358),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Utah'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-UT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='order-of-the-silver-thorn' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.2744122),
 public_longitude=coalesce(t.public_longitude,-9.0490601),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Connacht'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IE-G'),
 country_code=coalesce(nullif(t.country_code,''),'IE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='1316-mfc' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,57.0462626),
 public_longitude=coalesce(t.public_longitude,9.9215263),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Region Nordjylland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DK-81'),
 country_code=coalesce(nullif(t.country_code,''),'DK'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iron-wolves' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,56.7861112),
 public_longitude=coalesce(t.public_longitude,-4.1140518),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alba / Scotland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'GB-SCT'),
 country_code=coalesce(nullif(t.country_code,''),'GB'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-infernal-unicorns' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-27.4689623),
 public_longitude=coalesce(t.public_longitude,153.0235009),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Queensland'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-QLD'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='wild-wyverns-' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.7127281),
 public_longitude=coalesce(t.public_longitude,-74.0060152),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New York'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NY'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='nyc-armored-combat' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,52.5173885),
 public_longitude=coalesce(t.public_longitude,13.3951309),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-BE'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='sentinels-of-eagle' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.7728245),
 public_longitude=coalesce(t.public_longitude,19.478486),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo łódzkie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-10'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='ks-rycerz' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.2130358),
 public_longitude=coalesce(t.public_longitude,2.3491069),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Occitanie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FR-11'),
 country_code=coalesce(nullif(t.country_code,''),'FR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='carcas-sonne' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,51.0456064),
 public_longitude=coalesce(t.public_longitude,-114.057541),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Alberta'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CA-AB'),
 country_code=coalesce(nullif(t.country_code,''),'CA'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-order-of-the-wild-rose' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-36.0737734),
 public_longitude=coalesce(t.public_longitude,146.9135265),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'New South Wales'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AU-NSW'),
 country_code=coalesce(nullif(t.country_code,''),'AU'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='team-basilisk' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.4847448),
 public_longitude=coalesce(t.public_longitude,8.2659245),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Hessen'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'DE-HE'),
 country_code=coalesce(nullif(t.country_code,''),'DE'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='zitadelle-e.v.' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,43.6166163),
 public_longitude=coalesce(t.public_longitude,-116.200886),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Idaho'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-ID'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='iac---shrew-crew' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.7824434),
 public_longitude=coalesce(t.public_longitude,12.4062554),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Umbria'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'IT-PG'),
 country_code=coalesce(nullif(t.country_code,''),'IT'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='compagnia-della-ruggine' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.6038321),
 public_longitude=coalesce(t.public_longitude,-122.330062),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Washington'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-WA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='vagabonds-vanguard' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-23.5506507),
 public_longitude=coalesce(t.public_longitude,-46.6333824),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'São Paulo'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'BR-SP'),
 country_code=coalesce(nullif(t.country_code,''),'BR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='silver-sword' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.7596198),
 public_longitude=coalesce(t.public_longitude,-111.886797),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Utah'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-UT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='order-of-the-silver-rose' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,53.3613838),
 public_longitude=coalesce(t.public_longitude,20.4275719),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'województwo warmińsko-mazurskie'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'PL-28'),
 country_code=coalesce(nullif(t.country_code,''),'PL'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='legenda-północy' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,42.2056991),
 public_longitude=coalesce(t.public_longitude,-83.3529754),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Michigan'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-MI'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='dfc-marauders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.1622767),
 public_longitude=coalesce(t.public_longitude,-86.7742984),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Tennessee'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-TN'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-chaos-collective' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,50.0874654),
 public_longitude=coalesce(t.public_longitude,14.4212535),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'CZ-10'),
 country_code=coalesce(nullif(t.country_code,''),'CZ'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='prague-trolls' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,65.0117914),
 public_longitude=coalesce(t.public_longitude,25.4701973),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Pohjois-Pohjanmaa'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'FI-14'),
 country_code=coalesce(nullif(t.country_code,''),'FI'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='uleåborg-fighting-cocks-1' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,47.7623952),
 public_longitude=coalesce(t.public_longitude,27.9286022),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),NULL),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'MD-BA'),
 country_code=coalesce(nullif(t.country_code,''),'MD'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='regius-cohortis' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,29.9561422),
 public_longitude=coalesce(t.public_longitude,-90.0733934),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Louisiana'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-LA'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='new-orleans-storm-riders' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.7596198),
 public_longitude=coalesce(t.public_longitude,-111.886797),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Utah'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-UT'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='13th-legion' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,-34.6095579),
 public_longitude=coalesce(t.public_longitude,-58.3887904),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Ciudad Autónoma de Buenos Aires'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'AR-C'),
 country_code=coalesce(nullif(t.country_code,''),'AR'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='cerberus' limit 1);

commit;