-- Pack 4: general event model.
-- Backward-compatible: existing event_type labels and rows are untouched. New
-- categories are added forward-only, and events gain a stable public slug, an
-- optional host team and an optional image reference.

alter type public.event_type add value if not exists 'tournament';
alter type public.event_type add value if not exists 'demo';
alter type public.event_type add value if not exists 'training';
alter type public.event_type add value if not exists 'clinic_workshop';
alter type public.event_type add value if not exists 'recruitment';
alter type public.event_type add value if not exists 'fundraiser';
alter type public.event_type add value if not exists 'gathering_social';
alter type public.event_type add value if not exists 'meeting_agm';
alter type public.event_type add value if not exists 'community_appearance';

alter table public.events
  add column if not exists slug text,
  add column if not exists host_team_id uuid references public.teams(id) on delete set null,
  add column if not exists image_path text;

alter table public.events
  drop constraint if exists events_slug_format;
alter table public.events
  add constraint events_slug_format check (slug is null or slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$');

create unique index if not exists events_slug_key on public.events(slug) where slug is not null;
create index if not exists events_host_team_idx on public.events(host_team_id) where host_team_id is not null;

create or replace function public.event_slug_base(p_name text)
returns text
language sql
immutable
set search_path = public
as $$
  select coalesce(
    nullif(trim(both '-' from regexp_replace(lower(coalesce(p_name, '')), '[^a-z0-9]+', '-', 'g')), ''),
    'event'
  )
$$;

create or replace function public.events_assign_slug()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.slug is null then
    new.slug := public.event_slug_base(new.name) || '-' || left(new.id::text, 8);
  end if;
  return new;
end;
$$;

drop trigger if exists events_assign_slug on public.events;
create trigger events_assign_slug
  before insert on public.events
  for each row execute function public.events_assign_slug();

-- Backfill without bumping updated_at or writing audit noise for a mechanical change.
alter table public.events disable trigger user;
update public.events
   set slug = public.event_slug_base(name) || '-' || left(id::text, 8)
 where slug is null;
alter table public.events enable trigger user;

-- Text comparison keeps this safe to create in the same transaction that added enum labels.
create or replace function public.event_type_is_competitive(p_type public.event_type)
returns boolean
language sql
immutable
set search_path = public
as $$
  select p_type::text in ('tournament', 'ranked_competitive')
$$;

grant execute on function public.event_type_is_competitive(public.event_type) to anon, authenticated;
grant execute on function public.event_slug_base(text) to anon, authenticated;

grant select (slug, host_team_id, image_path) on public.events to anon, authenticated;
