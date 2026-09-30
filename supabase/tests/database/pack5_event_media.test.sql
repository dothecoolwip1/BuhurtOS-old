-- Pack 5 event media (migration 20261015000000).
begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

insert into auth.users (
  id,aud,role,email,encrypted_password,email_confirmed_at,
  raw_app_meta_data,raw_user_meta_data,created_at,updated_at
) values
('65000000-0000-0000-0000-000000000001','authenticated','authenticated','media-admin@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Media Admin"}',timezone('utc',now()),timezone('utc',now())),
('65000000-0000-0000-0000-000000000002','authenticated','authenticated','media-other@buhurtos.test','',timezone('utc',now()),'{}','{"display_name":"Media Other"}',timezone('utc',now()),timezone('utc',now()));

insert into public.organizations(id,name,short_name,region,status)
values
('65000000-0000-0000-0000-000000000010','Media Org','MO','Test','active'),
('66000000-0000-0000-0000-000000000010','Other Media Org','MOO','Other','active');

insert into public.organization_memberships(organization_id,user_id,role)
values
('65000000-0000-0000-0000-000000000010','65000000-0000-0000-0000-000000000001','organization_admin'),
('66000000-0000-0000-0000-000000000010','65000000-0000-0000-0000-000000000002','organization_admin');

insert into public.seasons(id,organization_id,name,starts_at,ends_at,status)
values ('65000000-0000-0000-0000-000000000020','65000000-0000-0000-0000-000000000010','Media Season','2026-01-01','2026-12-31','active');

insert into public.events(id,organization_id,season_id,name,venue,starts_at,ends_at,event_type,standings_mode,status,timezone,published_at)
values ('65000000-0000-0000-0000-000000000030','65000000-0000-0000-0000-000000000010','65000000-0000-0000-0000-000000000020','Media Event','Ranch','2026-11-14T16:00:00Z','2026-11-15T23:00:00Z','custom','no_standings','published','UTC',now());

select is(
  (select public from storage.buckets where id = 'event-media'),
  true,
  'event-media bucket exists and is public-read'
);

select is(
  (select file_size_limit from storage.buckets where id = 'event-media'),
  5242880::bigint,
  'event-media bucket limits uploads to 5 MB'
);

select is(
  private.event_media_event_id('65000000-0000-0000-0000-000000000030/poster.webp'),
  '65000000-0000-0000-0000-000000000030'::uuid,
  'event id is parsed from a well-formed object path'
);

select is(
  private.event_media_event_id('not-a-uuid/poster.webp'),
  null::uuid,
  'malformed object paths resolve to no event instead of raising'
);

-- Unauthenticated callers cannot set the poster.
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select throws_ok(
  $$select public.set_event_image('65000000-0000-0000-0000-000000000030','65000000-0000-0000-0000-000000000030/poster.webp')$$,
  '42501', null,
  'anonymous callers cannot execute set_event_image'
);

select throws_ok(
  $$insert into storage.objects(bucket_id,name) values ('event-media','65000000-0000-0000-0000-000000000030/anon.webp')$$,
  '42501', null,
  'anonymous callers cannot upload event media'
);

-- Unrelated organization administrators are rejected.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','65000000-0000-0000-0000-000000000002',true);

select throws_ok(
  $$select public.set_event_image('65000000-0000-0000-0000-000000000030','65000000-0000-0000-0000-000000000030/poster.webp')$$,
  'P0001', 'You are not allowed to change media for this event',
  'unrelated organization admins cannot set the poster'
);

select throws_ok(
  $$insert into storage.objects(bucket_id,name) values ('event-media','65000000-0000-0000-0000-000000000030/other.webp')$$,
  '42501', null,
  'unrelated organization admins cannot upload event media'
);

-- The event organization administrator can manage media.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','65000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$insert into storage.objects(bucket_id,name) values ('event-media','65000000-0000-0000-0000-000000000030/poster-1.webp')$$,
  'event administrators can upload event media'
);

select throws_ok(
  $$insert into storage.objects(bucket_id,name) values ('event-media','65000000-0000-0000-0000-000000000099/poster.webp')$$,
  '42501', null,
  'event administrators cannot upload into another event folder'
);

select throws_ok(
  $$select public.set_event_image('65000000-0000-0000-0000-000000000030','65000000-0000-0000-0000-000000000099/poster.webp')$$,
  'P0001', 'Invalid event media path',
  'the poster path must live in the event own folder'
);

select lives_ok(
  $$select public.set_event_image('65000000-0000-0000-0000-000000000030','65000000-0000-0000-0000-000000000030/poster-1.webp')$$,
  'event administrators can set the poster reference'
);

select is(
  (select image_path from public.events where id = '65000000-0000-0000-0000-000000000030'),
  '65000000-0000-0000-0000-000000000030/poster-1.webp',
  'the stored path is recorded on the event'
);

reset role;
set local role anon;
select set_config('request.jwt.claim.sub','',true);

select is(
  (select image_path from public.events where id = '65000000-0000-0000-0000-000000000030'),
  '65000000-0000-0000-0000-000000000030/poster-1.webp',
  'the public poster reference is readable by spectators'
);

select is(
  (select count(*)::integer from storage.objects where bucket_id = 'event-media' and name = '65000000-0000-0000-0000-000000000030/poster-1.webp'),
  1,
  'spectators can read event media objects'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','65000000-0000-0000-0000-000000000001',true);

select lives_ok(
  $$select public.set_event_image('65000000-0000-0000-0000-000000000030', null)$$,
  'event administrators can remove the poster reference'
);

select is(
  (select image_path from public.events where id = '65000000-0000-0000-0000-000000000030'),
  null::text,
  'the poster reference is cleared'
);

reset role;
select * from finish();
rollback;
