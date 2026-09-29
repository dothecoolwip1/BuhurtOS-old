begin;
create extension if not exists pgtap with schema extensions;

select no_plan();

select is(
  (select count(*)::integer from public.team_source_records where source_kind='hacsa'),
  10,
  'all ten current HACSA source records are seeded'
);

select is(
  (select count(*)::integer from public.public_team_directory('HACSA',null,null,null,null)),
  10,
  'public HACSA directory returns all ten teams'
);

select is(
  (select count(*)::integer from public.public_team_directory('HACSA','NA','CA','AB',null)),
  7,
  'HACSA Alberta directory contains seven teams'
);

select is(
  (select count(*)::integer from public.public_team_directory('HACSA','NA','CA','BC',null)),
  1,
  'HACSA British Columbia directory contains one team'
);

select is(
  (select count(*)::integer from public.public_team_directory('HACSA','NA','CA','MB',null)),
  1,
  'HACSA Manitoba directory contains one team'
);

select is(
  (select count(*)::integer from public.public_team_directory('HACSA','NA','CA','SK',null)),
  1,
  'HACSA Saskatchewan directory contains one team'
);

select is(
  (select team_name from public.public_team_directory('HACSA',null,null,null,'reavers')),
  'Reavers',
  'team slug resolves the HACSA Reavers record'
);

select is(
  (select city_or_region from public.public_team_directory('HACSA',null,null,null,'silver-gryphons')),
  'Calgary (North)',
  'directory preserves HACSA published location wording'
);

select ok(
  not has_table_privilege('anon','public.team_source_records','SELECT'),
  'raw source provenance is not directly exposed to anonymous callers'
);

select ok(
  has_function_privilege('anon','public.public_team_directory(text,text,text,text,text)','EXECUTE'),
  'anonymous spectators can execute the sanitized public directory RPC'
);

reset role;
set local role anon;

select is(
  (select count(*)::integer from public.public_team_directory('HACSA','NA','CA',null,null)),
  10,
  'anonymous callers can browse the public HACSA hierarchy'
);

select * from finish();
rollback;
