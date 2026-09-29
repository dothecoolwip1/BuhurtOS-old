begin;
update public.teams t set
 public_latitude=coalesce(t.public_latitude,41.6915847),
 public_longitude=coalesce(t.public_longitude,-0.9101268),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Aragón'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-Z'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='the-hateful-eight' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,40.416782),
 public_longitude=coalesce(t.public_longitude,-3.703507),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'Comunidad de Madrid'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'ES-MD'),
 country_code=coalesce(nullif(t.country_code,''),'ES'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='carranza-vipers' limit 1);

update public.teams t set
 public_latitude=coalesce(t.public_latitude,36.0726355),
 public_longitude=coalesce(t.public_longitude,-79.7919754),
 admin_area_name=coalesce(nullif(t.admin_area_name,''),'North Carolina'),
 admin_area_code=coalesce(nullif(t.admin_area_code,''),'US-NC'),
 country_code=coalesce(nullif(t.country_code,''),'US'),
 updated_at=now()
where t.id=(select s.team_id from public.team_source_records s where s.source_kind='bi_teams' and s.source_record_key='steel-coven-(m)' limit 1);

commit;