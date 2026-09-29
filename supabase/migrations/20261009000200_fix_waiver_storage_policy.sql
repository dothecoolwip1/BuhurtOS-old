-- Fix the waiver storage read policy so the outer storage object path is
-- compared to event_registrations.waiver_storage_path. The original policy used
-- an unqualified "name" inside the subquery, which Postgres resolved to
-- events.name.

drop policy if exists waiver_staff_read on storage.objects;

create policy waiver_staff_read
on storage.objects
for select
to authenticated
using (
  bucket_id = 'waivers'
  and exists (
    select 1
    from public.event_registrations r
    join public.events e on e.id = r.event_id
    where r.waiver_storage_path = storage.objects.name
      and (
        private.has_org_role(
          (select auth.uid()),
          e.organization_id,
          array['organization_admin','organization_staff']::public.organization_role[]
        )
        or private.has_event_role(
          (select auth.uid()),
          e.id,
          array['event_organizer']::public.event_role[]
        )
      )
  )
);
