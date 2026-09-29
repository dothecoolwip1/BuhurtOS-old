begin;
create extension if not exists pgtap with schema extensions;

select plan(4);

select ok(
  exists(select 1 from storage.buckets where id='fighter-avatars'),
  'fighter avatar bucket exists'
);

select is(
  (select public from storage.buckets where id='fighter-avatars'),
  false,
  'fighter avatar bucket is private'
);

select is(
  (select file_size_limit from storage.buckets where id='fighter-avatars'),
  5242880::bigint,
  'fighter avatar bucket limits uploads to 5 MB'
);

select is(
  (select array_to_string(allowed_mime_types, ',') from storage.buckets where id='fighter-avatars'),
  'image/jpeg,image/png,image/webp',
  'fighter avatar bucket accepts only JPEG, PNG, and WebP images'
);

select * from finish();
rollback;
