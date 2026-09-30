-- Pack 5 fighter signup codes: hashed at rest, anonymous submit with a valid code,
-- no anonymous/unrelated reads, and expired / disabled / max-use enforcement.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

create temp table t_codes(name text primary key, code text);
create temp table t_results(name text primary key, value text);
create temp table t_ids(name text primary key, id uuid);
grant all on t_codes, t_results, t_ids to public;

insert into auth.users (
  id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
('67000000-0000-0000-0000-000000000001','authenticated','authenticated','signup-admin@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Signup Admin"}',timezone('utc',now()),timezone('utc',now())),
('67000000-0000-0000-0000-000000000002','authenticated','authenticated','signup-other@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Signup Other"}',timezone('utc',now()),timezone('utc',now()));

insert into public.organizations(id,name,short_name,region,status)
values
('67000000-0000-0000-0000-000000000010','Signup Org','SO','Test','active'),
('68000000-0000-0000-0000-000000000010','Other Signup Org','SOO','Other','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('67000000-0000-0000-0000-000000000010','67000000-0000-0000-0000-000000000001','organization_admin'),
('68000000-0000-0000-0000-000000000010','67000000-0000-0000-0000-000000000002','organization_admin');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('67000000-0000-0000-0000-000000000020','67000000-0000-0000-0000-000000000010','Signup Season','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at)
values ('67000000-0000-0000-0000-000000000030','67000000-0000-0000-0000-000000000010','67000000-0000-0000-0000-000000000020','Red Deer Rumble','Ranch','2026-11-14T16:00:00Z','2026-11-15T23:00:00Z','custom','no_standings','published','UTC',now());

-- Unrelated organization administrators cannot mint codes.
set local role authenticated;
select set_config('request.jwt.claim.sub','67000000-0000-0000-0000-000000000002',true);

select throws_ok(
  $$select public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Nope',1,null)$$,
  'P0001', 'You are not allowed to create signup codes for this event',
  'unrelated organization admins cannot create signup codes'
);

-- The event organization administrator mints three codes.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','67000000-0000-0000-0000-000000000001',true);

insert into t_codes values
  ('single', public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Single use',1,null)),
  ('multi',  public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Multi use',5,null)),
  ('soon',   public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Expires soon',5,now()+interval '1 day'));

select throws_ok(
  $$select public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Bad',0,null)$$,
  'P0001', 'Max uses must be between 1 and 500',
  'max uses is bounded'
);

select throws_ok(
  $$select public.create_event_signup_code('67000000-0000-0000-0000-000000000030','Past',1,now()-interval '1 hour')$$,
  'P0001', 'Expiration must be in the future',
  'expiration must be in the future'
);

reset role;

insert into t_ids
select t.name, c.id from t_codes t join public.event_signup_codes c on c.code_hash = extensions.digest(upper(t.code),'sha256');

select ok(
  (select code like 'RDR26-______' from t_codes where name = 'single'),
  'codes are event-recognizable, e.g. RDR26-ABC123'
);

select is(
  (select count(*)::integer from public.event_signup_codes c join t_codes t on c.code_hash = extensions.digest(upper(t.code),'sha256')),
  3,
  'codes are stored as SHA-256 hashes'
);

select is(
  (select count(*)::integer from public.event_signup_codes c join t_codes t on c.code_hash = convert_to(t.code,'UTF8')),
  0,
  'plaintext codes are never stored'
);

-- Anonymous users validate and submit, but never read.
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000030',(select code from t_codes where name='single'))->>'valid'),
  'true',
  'anonymous users can validate a valid code'
);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000030','RDR26-NOPE00')->>'message'),
  'Code not recognized for this event',
  'unknown codes are rejected'
);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000031',(select code from t_codes where name='single'))->>'valid'),
  'false',
  'a code is only valid for its own event'
);

select throws_ok(
  format($$select public.submit_event_fighter_signup('67000000-0000-0000-0000-000000000030',%L,'Test Fighter','fighter@example.test',null,null,null,'{}',null,null,null,null,false)$$,(select code from t_codes where name='single')),
  'P0001', 'Consent is required',
  'consent is required to submit'
);

select throws_ok(
  $$select public.submit_event_fighter_signup('67000000-0000-0000-0000-000000000030','RDR26-NOPE00','Test Fighter','fighter@example.test',null,null,null,'{}',null,null,null,null,true)$$,
  'P0001', 'Code not recognized for this event',
  'an invalid code cannot submit'
);

select lives_ok(
  format($$select public.submit_event_fighter_signup('67000000-0000-0000-0000-000000000030',%L,'Test Fighter','Fighter@Example.test','555-0100','Test Team',3,array['longsword'],'full','driving','Emergency Person 555-0101','notes',true)$$,(select code from t_codes where name='single')),
  'anonymous users can submit with a valid code'
);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000030',(select code from t_codes where name='single'))->>'message'),
  'This signup code has reached its use limit',
  'a single-use code is exhausted after one submission'
);

select throws_ok(
  format($$select public.submit_event_fighter_signup('67000000-0000-0000-0000-000000000030',%L,'Second Fighter','second@example.test',null,null,null,'{}',null,null,null,null,true)$$,(select code from t_codes where name='single')),
  'P0001', 'This signup code has reached its use limit',
  'an exhausted code cannot submit again'
);

do $$
declare n integer;
begin
  select count(*) into n from public.fighter_event_signups;
  insert into t_results values ('anon_read', n::text);
exception when insufficient_privilege then
  insert into t_results values ('anon_read', 'denied');
end $$;

select ok(
  (select value in ('0','denied') from t_results where name = 'anon_read'),
  'anonymous users cannot list or read submissions'
);

-- Unrelated authenticated users cannot read submissions.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','67000000-0000-0000-0000-000000000002',true);

do $$
declare n integer;
begin
  select count(*) into n from public.fighter_event_signups;
  insert into t_results values ('other_read', n::text);
exception when insufficient_privilege then
  insert into t_results values ('other_read', 'denied');
end $$;

select ok(
  (select value in ('0','denied') from t_results where name = 'other_read'),
  'unrelated authenticated users cannot read submissions'
);

select throws_ok(
  format($$select public.disable_event_signup_code(%L::uuid)$$,(select id from t_ids where name='multi')),
  'P0001', 'You cannot manage this event signup code',
  'unrelated users cannot disable codes'
);

-- The authorized organization administrator can read, list, and disable.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','67000000-0000-0000-0000-000000000001',true);

select is(
  (select count(*)::integer from public.fighter_event_signups where event_id = '67000000-0000-0000-0000-000000000030'),
  1,
  'authorized event hierarchy can read the submission'
);

select is(
  (select uses from public.list_event_signup_codes('67000000-0000-0000-0000-000000000030') l join t_codes t on t.name='single' where l.label = 'Single use'),
  1::bigint,
  'the use count is reported for each code'
);

select lives_ok(
  format($$select public.disable_event_signup_code(%L::uuid)$$,(select id from t_ids where name='multi')),
  'authorized users can disable a code'
);

-- Disabled and expired codes are rejected.
reset role;
update public.event_signup_codes
   set expires_at = now() - interval '1 day'
 where code_hash = extensions.digest(upper((select code from t_codes where name='soon')),'sha256');

set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000030',(select code from t_codes where name='multi'))->>'message'),
  'This signup code is disabled',
  'disabled codes are rejected'
);

select is(
  (select public.validate_event_signup_code('67000000-0000-0000-0000-000000000030',(select code from t_codes where name='soon'))->>'message'),
  'This signup code has expired',
  'expired codes are rejected'
);

select throws_ok(
  format($$select public.submit_event_fighter_signup('67000000-0000-0000-0000-000000000030',%L,'Late Fighter','late@example.test',null,null,null,'{}',null,null,null,null,true)$$,(select code from t_codes where name='soon')),
  'P0001', 'This signup code has expired',
  'an expired code cannot submit'
);

reset role;
select * from finish();
rollback;
