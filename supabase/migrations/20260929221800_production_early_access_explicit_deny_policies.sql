create policy access_codes_no_direct_client_access
on public.access_codes
for all
to anon, authenticated
using (false)
with check (false);

create policy access_code_redemptions_no_direct_client_access
on public.access_code_redemptions
for all
to anon, authenticated
using (false)
with check (false);
