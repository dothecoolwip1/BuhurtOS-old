-- Fighter avatars stay in a private bucket. Upload, replacement, removal, and
-- signed retrieval are mediated by the fighter-avatar Edge Function, which
-- verifies identity control before using its service-role storage access.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'fighter-avatars',
  'fighter-avatars',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public=excluded.public,
    file_size_limit=excluded.file_size_limit,
    allowed_mime_types=excluded.allowed_mime_types;
