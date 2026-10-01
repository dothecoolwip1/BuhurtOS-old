-- Event media: poster alt text, and who may change the poster or its description.
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
select v.id::uuid,'authenticated','authenticated',v.email,'',timezone('utc',now()),'{}',('{"display_name":"'||v.name||'"}')::jsonb,timezone('utc',now()),timezone('utc',now())
from (values
  ('72000000-0000-0000-0000-000000000001','em-orgadmin@buhurtos.test','Media Org Admin'),
  ('72000000-0000-0000-0000-000000000002','em-fighter@buhurtos.test','Host Team Fighter'),
  ('72000000-0000-0000-0000-000000000003','em-captain@buhurtos.test','Host Team Captain'),
  ('72000000-0000-0000-0000-000000000004','em-other@buhurtos.test','Other Org Admin'),
  ('72000000-0000-0000-0000-000000000005','em-organizer@buhurtos.test','Event Organizer')
) as v(id,email,name);

insert into public.organizations(id,name,short_name,region,status) values
 ('72000000-0000-0000-0000-000000000010','EM Org','EMO','Test','active'),
 ('72000000-0000-0000-0000-000000000011','EM Other Org','EMX','Test','active');
insert into public.organization_memberships(organization_id,user_id,role) values
 ('72000000-0000-0000-0000-000000000010','72000000-0000-0000-0000-000000000001','organization_admin'),
 ('72000000-0000-0000-0000-000000000011','72000000-0000-0000-0000-000000000004','organization_admin');
insert into public.teams(id,organization_id,name,city_or_region) values ('72000000-0000-0000-0000-000000000020','72000000-0000-0000-0000-000000000010','EM Host Team','Test');
insert into public.team_memberships(team_id,user_id,role,display_name) values
 ('72000000-0000-0000-0000-000000000020','72000000-0000-0000-0000-000000000002','fighter','Host Fighter'),
 ('72000000-0000-0000-0000-000000000020','72000000-0000-0000-0000-000000000003','captain','Host Captain');
insert into public.seasons(id,organization_id,name,starts_at,ends_at,status) values ('72000000-0000-0000-0000-000000000030','72000000-0000-0000-0000-000000000010','EM Season','2026-01-01','2026-12-31','active');
insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at,host_team_id) values
 ('72000000-0000-0000-0000-000000000040','72000000-0000-0000-0000-000000000010','72000000-0000-0000-0000-000000000030','EM Open','Ranch','2026-11-14T16:00:00Z','2026-11-15T23:00:00Z','custom','no_standings','published','UTC',now(),'72000000-0000-0000-0000-000000000020');
insert into public.event_memberships(event_id,user_id,role) values ('72000000-0000-0000-0000-000000000040','72000000-0000-0000-0000-000000000005','event_organizer');

-- Organization administrator sets a poster and describes it.
set local role authenticated;
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000001',true);
select lives_ok($$select public.set_event_image('72000000-0000-0000-0000-000000000040','72000000-0000-0000-0000-000000000040/poster-1.webp')$$, 'an organization admin can set the poster');
select lives_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','  Two armored teams meet at a ranch  ')$$, 'an organization admin can describe the poster');
reset role;
select is((select image_alt from public.events where id='72000000-0000-0000-0000-000000000040'), 'Two armored teams meet at a ranch', 'the description is stored trimmed');

-- Anonymous visitors can read the poster and its description, not change them.
set local role anon;
select is((select image_alt from public.events where id='72000000-0000-0000-0000-000000000040'), 'Two armored teams meet at a ranch', 'anonymous visitors can read the description of a published event''s poster');
select throws_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','hacked')$$, '42501', null, 'anonymous visitors cannot change the description');
select throws_ok($$update public.events set image_alt='hacked' where id='72000000-0000-0000-0000-000000000040'$$, '42501', null, 'anonymous visitors cannot update the events table');
reset role;

-- Who else can, and cannot, change media.
set local role authenticated;
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000002',true);
select throws_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','fighter edit')$$, 'P0001', 'You are not allowed to change media for this event', 'a plain host-team fighter cannot change the description');
select throws_ok($$select public.set_event_image('72000000-0000-0000-0000-000000000040','72000000-0000-0000-0000-000000000040/poster-2.webp')$$, 'P0001', 'You are not allowed to change media for this event', 'a plain host-team fighter cannot replace the poster');
select throws_ok($$insert into storage.objects(bucket_id,name,owner,metadata) values ('event-media','72000000-0000-0000-0000-000000000040/fighter.webp','72000000-0000-0000-0000-000000000002','{}')$$, '42501', null, 'a plain host-team fighter cannot upload into the event''s media folder');

select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000004',true);
select throws_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','other org')$$, 'P0001', 'You are not allowed to change media for this event', 'an unrelated organization admin cannot change the description');

select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000003',true);
select lives_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','Captain wording')$$, 'a host-team captain can change the description');
select lives_ok($$insert into storage.objects(bucket_id,name,owner,metadata) values ('event-media','72000000-0000-0000-0000-000000000040/captain.webp','72000000-0000-0000-0000-000000000003','{}')$$, 'a host-team captain can upload into the event''s media folder');

select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000005',true);
select lives_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','Organizer wording')$$, 'an event organizer can change the description');

-- Validation.
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000001',true);
select throws_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040', repeat('x',301))$$, 'P0001', 'Keep the description under 300 characters', 'descriptions are limited to 300 characters');
select lives_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','   ')$$, 'a blank description clears it');
reset role;
select is((select image_alt from public.events where id='72000000-0000-0000-0000-000000000040'), null, 'a blank description is stored as nothing, so the public fallback applies');

-- Removing the poster clears any description.
set local role authenticated;
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000001',true);
select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','Stale description');
select public.set_event_image('72000000-0000-0000-0000-000000000040', null);
reset role;
select is((select image_alt from public.events where id='72000000-0000-0000-0000-000000000040'), null, 'removing the poster clears its description');
set local role authenticated;
select set_config('request.jwt.claim.sub','72000000-0000-0000-0000-000000000001',true);
select throws_ok($$select public.set_event_image_alt('72000000-0000-0000-0000-000000000040','No poster')$$, 'P0001', 'Add a poster before describing it', 'a description needs a poster');
reset role;

-- The changes are audited.
select ok(exists(select 1 from public.audit_log where event_id='72000000-0000-0000-0000-000000000040' and action='set_event_image_alt'), 'description changes are audited');
select ok(exists(select 1 from public.audit_log where event_id='72000000-0000-0000-0000-000000000040' and action='remove_event_image'), 'poster removal is audited');

select * from finish();
rollback;
