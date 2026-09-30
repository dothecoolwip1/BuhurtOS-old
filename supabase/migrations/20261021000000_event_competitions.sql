-- Event competitions: a tournament inside an event (league, tier, category, ranked, entrants, format, approval record),
-- plus source-backed, versioned reference data so organizations can extend it without code changes.
-- Decision and evidence: docs/COMPETITION_MODEL_DECISION.md. Existing event_divisions / brackets are untouched except
-- for one nullable link column each.

-- ---------------------------------------------------------------------------
-- Reference data (public read, no client writes)
-- ---------------------------------------------------------------------------
create table if not exists public.competition_categories (
  id uuid primary key default gen_random_uuid(),
  authority text not null,                       -- 'bi' for Buhurt International; 'custom' for organization-defined
  organization_id uuid references public.organizations(id) on delete cascade,
  league text not null check (league in ('buhurt','duels','outrance','other')),
  key text not null,
  display_name text not null,
  team_size integer check (team_size is null or team_size > 0),
  ranked_capable boolean not null default true,
  active boolean not null default true,
  source_ref text,
  created_at timestamptz not null default now()
);
create unique index if not exists competition_categories_unique
  on public.competition_categories (coalesce(organization_id, '00000000-0000-0000-0000-000000000000'::uuid), authority, key);

create table if not exists public.rule_documents (
  id uuid primary key default gen_random_uuid(),
  authority text not null,
  family text not null check (family in ('executive','marshal','tournament','authenticity')),
  title text not null,
  version text,                                  -- null when the source does not state one
  effective_label text,
  source_url text not null,
  verified_at date not null,
  notes text,
  unique (authority, family, title)
);

create table if not exists public.ruleset_tier_requirements (
  authority text not null,
  doc_version text not null,
  tier text not null check (tier in ('exhibition','source','classic','regional','conference')),
  tier_label text not null,
  lead_days integer,
  requirements jsonb not null default '{}'::jsonb,
  source_ref text not null,
  primary key (authority, doc_version, tier)
);

create table if not exists public.tournament_format_templates (
  id uuid primary key default gen_random_uuid(),
  authority text not null,
  doc_version text not null,
  option_key text not null,
  title text not null,
  min_entrants integer not null,
  max_entrants integer,
  structure jsonb not null,
  recommended boolean not null default true,
  caution text,
  source_ref text not null,
  unique (authority, doc_version, option_key)
);

create table if not exists public.tiebreak_policies (
  authority text not null,
  doc_version text not null,
  steps jsonb not null,
  source_ref text not null,
  primary key (authority, doc_version)
);

alter table public.competition_categories enable row level security;
alter table public.rule_documents enable row level security;
alter table public.ruleset_tier_requirements enable row level security;
alter table public.tournament_format_templates enable row level security;
alter table public.tiebreak_policies enable row level security;

do $$
declare t text;
begin
  foreach t in array array['competition_categories','rule_documents','ruleset_tier_requirements','tournament_format_templates','tiebreak_policies'] loop
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to anon, authenticated', t);
    execute format('grant all on public.%I to service_role', t);
    execute format('drop policy if exists %I on public.%I', t || '_public_read', t);
    execute format('create policy %I on public.%I for select to anon, authenticated using (true)', t || '_public_read', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Event competitions
-- ---------------------------------------------------------------------------
create table if not exists public.event_competitions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  name text not null check (char_length(trim(name)) >= 2),
  league text not null check (league in ('buhurt','duels','outrance','other')),
  tier text check (tier in ('exhibition','source','classic','regional','conference','custom')),
  tier_classification text check (tier_classification in ('division_1','division_2','open')),
  classification text check (classification in ('men','women','open','mixed')),
  category_id uuid references public.competition_categories(id) on delete set null,
  authority text not null default 'bi',          -- ruleset authority: 'bi', an organization key or 'custom'
  rules_version text,                            -- the document version the organizer selected (for example 'v2026.1')
  ruleset_id uuid references public.rulesets(id) on delete set null,
  ranked boolean not null default false,
  entrant_cap integer check (entrant_cap is null or entrant_cap > 0),
  status text not null default 'draft' check (status in ('draft','open','running','completed','cancelled')),
  -- { rulesVersion, entrantCount, optionKey, generatedAt, override, overrideReason }
  format_selection jsonb not null default '{}'::jsonb,
  -- Approval granted OUTSIDE BuhurtOS (for example by a national organization). Recording it does not sanction anything.
  external_approval jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists event_competitions_event_idx on public.event_competitions(event_id, sort_order);

alter table public.event_divisions add column if not exists competition_id uuid references public.event_competitions(id) on delete set null;
alter table public.brackets add column if not exists competition_id uuid references public.event_competitions(id) on delete set null;
create index if not exists event_divisions_competition_idx on public.event_divisions(competition_id);
create index if not exists brackets_competition_idx on public.brackets(competition_id);

alter table public.event_competitions enable row level security;
revoke all on public.event_competitions from anon, authenticated;
grant select on public.event_competitions to anon, authenticated;
grant all on public.event_competitions to service_role;

drop policy if exists event_competitions_public_read on public.event_competitions;
create policy event_competitions_public_read on public.event_competitions
  for select to anon, authenticated
  using (private.event_is_public(event_id));
drop policy if exists event_competitions_team_read on public.event_competitions;
create policy event_competitions_team_read on public.event_competitions
  for select to authenticated
  using (private.can_participate_in_event_admin(auth.uid(), event_id));

-- Setup authority: platform admin, organization admin of the event's organization chain, or event organizer.
create or replace function private.can_manage_event_setup(p_user uuid, p_event uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$ select private.can_configure_event_registration(p_user, p_event); $$;

create or replace function private.upsert_event_competition(p_event uuid, p_id uuid, p_payload jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_id uuid;
  v_existing public.event_competitions%rowtype;
begin
  if v_actor is null then raise exception 'Sign in to manage competitions'; end if;
  if not private.can_manage_event_setup(v_actor, p_event) then
    raise exception 'You are not allowed to manage competitions for this event';
  end if;
  if p_id is not null then
    select * into v_existing from public.event_competitions where id = p_id and event_id = p_event;
    if v_existing.id is null then raise exception 'Competition not found for this event'; end if;
  end if;
  if coalesce(p_payload->>'league', v_existing.league) is null then raise exception 'Choose a league'; end if;

  if p_id is null then
    insert into public.event_competitions(
      event_id, name, league, tier, tier_classification, classification, category_id, authority, rules_version, ruleset_id,
      ranked, entrant_cap, status, format_selection, external_approval, sort_order, created_by)
    values (
      p_event, trim(p_payload->>'name'), p_payload->>'league', nullif(p_payload->>'tier',''), nullif(p_payload->>'tierClassification',''),
      nullif(p_payload->>'classification',''), nullif(p_payload->>'categoryId','')::uuid, coalesce(nullif(p_payload->>'authority',''),'bi'),
      nullif(p_payload->>'rulesVersion',''), nullif(p_payload->>'rulesetId','')::uuid,
      coalesce((p_payload->>'ranked')::boolean,false), nullif(p_payload->>'entrantCap','')::integer,
      coalesce(nullif(p_payload->>'status',''),'draft'), coalesce(p_payload->'formatSelection','{}'::jsonb),
      coalesce(p_payload->'externalApproval','{}'::jsonb),
      coalesce((select max(sort_order) + 1 from public.event_competitions where event_id = p_event), 0), v_actor)
    returning id into v_id;
  else
    update public.event_competitions set
      name = coalesce(nullif(trim(p_payload->>'name'),''), name),
      league = coalesce(p_payload->>'league', league),
      tier = case when p_payload ? 'tier' then nullif(p_payload->>'tier','') else tier end,
      tier_classification = case when p_payload ? 'tierClassification' then nullif(p_payload->>'tierClassification','') else tier_classification end,
      classification = case when p_payload ? 'classification' then nullif(p_payload->>'classification','') else classification end,
      category_id = case when p_payload ? 'categoryId' then nullif(p_payload->>'categoryId','')::uuid else category_id end,
      authority = coalesce(nullif(p_payload->>'authority',''), authority),
      rules_version = case when p_payload ? 'rulesVersion' then nullif(p_payload->>'rulesVersion','') else rules_version end,
      ruleset_id = case when p_payload ? 'rulesetId' then nullif(p_payload->>'rulesetId','')::uuid else ruleset_id end,
      ranked = coalesce((p_payload->>'ranked')::boolean, ranked),
      entrant_cap = case when p_payload ? 'entrantCap' then nullif(p_payload->>'entrantCap','')::integer else entrant_cap end,
      status = coalesce(nullif(p_payload->>'status',''), status),
      format_selection = coalesce(p_payload->'formatSelection', format_selection),
      external_approval = coalesce(p_payload->'externalApproval', external_approval),
      updated_at = now()
    where id = p_id
    returning id into v_id;
  end if;

  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (v_actor, p_event, 'event_competitions', v_id, case when p_id is null then 'create_event_competition' else 'update_event_competition' end,
          jsonb_build_object('league', p_payload->>'league', 'tier', p_payload->>'tier'));
  return v_id;
end;
$$;

create or replace function private.delete_event_competition(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_event uuid;
begin
  select event_id into v_event from public.event_competitions where id = p_id;
  if v_event is null then raise exception 'Competition not found'; end if;
  if not private.can_manage_event_setup(auth.uid(), v_event) then
    raise exception 'You are not allowed to manage competitions for this event';
  end if;
  if exists (select 1 from public.brackets where competition_id = p_id) then
    raise exception 'This competition already has a bracket. Cancel it instead of deleting it.';
  end if;
  delete from public.event_competitions where id = p_id;
  insert into public.audit_log(actor_user_id, event_id, table_name, record_id, action, payload)
  values (auth.uid(), v_event, 'event_competitions', p_id, 'delete_event_competition', '{}'::jsonb);
end;
$$;

-- Organizations add their own categories without code changes.
create or replace function private.upsert_competition_category(
  p_organization uuid, p_key text, p_display_name text, p_league text, p_team_size integer, p_ranked_capable boolean, p_active boolean
) returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then raise exception 'Sign in to manage categories'; end if;
  if not (private.is_platform_admin(auth.uid()) or private.has_org_role(auth.uid(), p_organization, array['organization_admin']::public.organization_role[])) then
    raise exception 'You are not allowed to manage categories for this organization';
  end if;
  if p_league not in ('buhurt','duels','outrance','other') then raise exception 'Unknown league'; end if;
  if char_length(trim(coalesce(p_key,''))) < 2 or char_length(trim(coalesce(p_display_name,''))) < 2 then
    raise exception 'A key and a display name are required';
  end if;
  insert into public.competition_categories(authority, organization_id, league, key, display_name, team_size, ranked_capable, active, source_ref)
  values ('custom', p_organization, p_league, lower(trim(p_key)), trim(p_display_name), p_team_size, coalesce(p_ranked_capable, true), coalesce(p_active, true), 'Defined by the organization')
  on conflict (coalesce(organization_id, '00000000-0000-0000-0000-000000000000'::uuid), authority, key)
  do update set display_name = excluded.display_name, league = excluded.league, team_size = excluded.team_size,
                ranked_capable = excluded.ranked_capable, active = excluded.active
  returning id into v_id;
  insert into public.audit_log(actor_user_id, organization_id, table_name, record_id, action, payload)
  values (auth.uid(), p_organization, 'competition_categories', v_id, 'upsert_competition_category', jsonb_build_object('key', lower(trim(p_key))));
  return v_id;
end;
$$;

revoke all on function private.can_manage_event_setup(uuid, uuid) from public, anon, authenticated;
revoke all on function private.upsert_event_competition(uuid, uuid, jsonb) from public, anon, authenticated;
revoke all on function private.delete_event_competition(uuid) from public, anon, authenticated;
revoke all on function private.upsert_competition_category(uuid, text, text, text, integer, boolean, boolean) from public, anon, authenticated;
grant execute on function private.can_manage_event_setup(uuid, uuid) to authenticated;
grant execute on function private.upsert_event_competition(uuid, uuid, jsonb) to authenticated;
grant execute on function private.delete_event_competition(uuid) to authenticated;
grant execute on function private.upsert_competition_category(uuid, text, text, text, integer, boolean, boolean) to authenticated;

create or replace function public.upsert_event_competition(p_event uuid, p_id uuid, p_payload jsonb)
returns uuid language sql security invoker set search_path = ''
as $$ select private.upsert_event_competition(p_event, p_id, p_payload); $$;
create or replace function public.delete_event_competition(p_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.delete_event_competition(p_id); $$;
create or replace function public.upsert_competition_category(
  p_organization uuid, p_key text, p_display_name text, p_league text, p_team_size integer default null, p_ranked_capable boolean default true, p_active boolean default true
) returns uuid language sql security invoker set search_path = ''
as $$ select private.upsert_competition_category(p_organization, p_key, p_display_name, p_league, p_team_size, p_ranked_capable, p_active); $$;

revoke all on function public.upsert_event_competition(uuid, uuid, jsonb) from public, anon;
revoke all on function public.delete_event_competition(uuid) from public, anon;
revoke all on function public.upsert_competition_category(uuid, text, text, text, integer, boolean, boolean) from public, anon;
grant execute on function public.upsert_event_competition(uuid, uuid, jsonb) to authenticated;
grant execute on function public.delete_event_competition(uuid) to authenticated;
grant execute on function public.upsert_competition_category(uuid, text, text, text, integer, boolean, boolean) to authenticated;

-- ---------------------------------------------------------------------------
-- Seed: Buhurt International, from the official documents checked 2026-09-30
--   League Structure v2026.1, Tournament Structure (updated January 2026), buhurtinternational.com/rules
-- ---------------------------------------------------------------------------
insert into public.competition_categories (authority, league, key, display_name, team_size, source_ref) values
  ('bi','buhurt','3v3','3v3 Melee',3,'League Structure v2026.1 §3.1 (3v3 tournaments)'),
  ('bi','buhurt','5v5','5v5 Melee',5,'League Structure v2026.1 §2.3, §3.1 (5v5 tournaments)'),
  ('bi','buhurt','12v12','12v12 Melee',12,'League Structure v2026.1 §3.2 (12v12 tournaments)'),
  ('bi','duels','longsword','Longsword',null,'Duels Rules 26.4; League Structure v2026.1 §2.3 example'),
  ('bi','duels','sword_buckler','Sword & Buckler',null,'Duels Rules 26.4; Tournament Structure Jan 2026 §3.2'),
  ('bi','duels','sword_shield','Sword & Shield',null,'Duels Rules 26.4'),
  ('bi','duels','polearm','Polearm',null,'Duels Rules 26.4'),
  ('bi','duels','long_axe','Long Axe',null,'BuhurtOS verified BI format list; confirm against the current Duels Rules'),
  ('bi','outrance','outrance','Outrance',null,'League Structure v2026.1 §1.1 (Outrance/Profights league); Outrance Rules 26.4')
on conflict do nothing;

insert into public.rule_documents (authority, family, title, version, effective_label, source_url, verified_at, notes) values
  ('bi','tournament','League Structure','v2026.1','January 2026','https://www.buhurtinternational.com/_files/ugd/735f05_a1ec192413a34eef82ef91f57207ab80.pdf','2026-09-30','Leagues, conferences, tournament tiers, rosters, ranking.'),
  ('bi','tournament','Tournament Structure and Formats','Jan 2026','Updated January 2026','https://www.buhurtinternational.com/_files/ugd/735f05_c0af5616cd814a779c43181befa8b29c.pdf','2026-09-30','Format by entrant count, tiebreaks, season points, tournament rules.'),
  ('bi','tournament','Buhurt Regulations','26.4','April 2026','https://drive.google.com/file/d/154lPdIUM8lnf4VSZmY_vlY88Waygzoq5/view','2026-09-29','Version from the BuhurtOS marshal reference; Drive file not machine-readable.'),
  ('bi','tournament','Duel Regulations','26.4','April 2026','https://drive.google.com/file/d/1gr2EmgMvo5SprZo46vBgGKWOOg6m7bTx/view','2026-09-29','Version from the BuhurtOS marshal reference; Drive file not machine-readable.'),
  ('bi','tournament','Secretary Accreditation',null,null,'https://www.buhurtinternational.com/_files/ugd/d219c5_bb995d5ca4d345d2a649067d7cb9d494.pdf','2026-09-30','Version not stated on the source page.'),
  ('bi','marshal','Buhurt Rules','26.4.1','April 2026','https://drive.google.com/file/d/1peAGsMBV8ldNkSlgR-U33V0JqCFYL8ja/view','2026-09-29','Covered by the BuhurtOS marshal reference.'),
  ('bi','marshal','Duels Rules','26.4','April 2026','https://drive.google.com/file/d/1BsQVd3-9v_mp8l5DPj2p_jDUGn2hZPrD/view','2026-09-29','Covered by the BuhurtOS marshal reference.'),
  ('bi','marshal','Outrance Rules and Regulations','26.4','April 2026','https://drive.google.com/file/d/1nRkVgelFzD3Vrk4EGXIAvZaCzWYniqQz/view','2026-09-29','Covered by the BuhurtOS marshal reference.'),
  ('bi','marshal','Weapon/Shield Chart','26.2.1','February 2026','https://drive.google.com/file/d/1n1JTMVa9t4lgQdTEp9kU8U63flesYTqy/view','2026-09-29','Covered by the BuhurtOS marshal reference.'),
  ('bi','marshal','Accreditation',null,null,'https://www.buhurtinternational.com/_files/ugd/53cbbd_aadb219ddd34443c817c2c5f6236a6a9.pdf','2026-09-30','Version not stated on the source page. Source link only.'),
  ('bi','marshal','Jobs, Titles, Uniforms, Accreditations',null,null,'https://www.buhurtinternational.com/_files/ugd/53cbbd_8340848f5250498c85d1c11c1b3653c8.pdf','2026-09-30','Version not stated on the source page. Source link only.'),
  ('bi','executive','Code of Conduct',null,null,'https://www.buhurtinternational.com/_files/ugd/735f05_eae9128857c1444290eaee38ec0fa73b.pdf','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','executive','Gender policies',null,null,'https://www.buhurtinternational.com/_files/ugd/d219c5_cd29c29d07894734abfd546ea3665066.pdf','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','executive','Structure, Accreditation, Titles',null,null,'https://www.buhurtinternational.com/_files/ugd/d219c5_ffce59b9558045d8a5dec698616e1b21.pdf','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','executive','Rule Update Policy',null,null,'https://www.buhurtinternational.com/_files/ugd/d219c5_0fec8c7da3bb4ab4a6f507e1ea724410.pdf','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','authenticity','Armor Requirements',null,null,'https://drive.google.com/file/d/1yQDGSiXkM2pjHS9yj5e-HLJklWIeRKZE/view','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','authenticity','Weapon requirements',null,null,'https://drive.google.com/file/d/1cVip6PUx62koGD1yzrygb9p0sAJ44IOj/view','2026-09-30','Source link only; not normalized before November 1.'),
  ('bi','authenticity','Infractions Classification and Application',null,null,'https://drive.google.com/file/d/1NQ5O-CT62qn-V6w3Zh4JqcCzKJVxEZS5/view','2026-09-30','Source link only; not normalized before November 1.')
on conflict (authority, family, title) do nothing;

insert into public.ruleset_tier_requirements (authority, doc_version, tier, tier_label, lead_days, requirements, source_ref) values
  ('bi','v2026.1','exhibition','Exhibition',null,
   '{"pointsPercent":0,"note":"Promotion only. May be a small festival. No points are given.","sourcesDisagree":false}',
   'League Structure v2026.1 §2.3.1'),
  ('bi','v2026.1','source','Source',45,
   '{"pointsPercent":50,"seasonMultiplier":0.5,"sourcesDisagree":false,"approval":"Must be approved by the Buhurt International Committee and submitted to BI 45 days in advance.","marshals":"1 Regional Accredited Marshal (may be waived by the National Org)","minimumEntrants":{"buhurt":"3 teams for either 3v3 or 5v5","duels":"3 or more duellists for each category"},"divisions":"No Division 1 teams in Buhurt. Division 1 duellists preferably coach only.","restriction":"For developing regions. Established regions may not use it without a special request."}',
   'League Structure v2026.1 §2.3.2; Tournament Structure Jan 2026 §4.2'),
  ('bi','v2026.1','classic','Classic',45,
   '{"pointsPercent":100,"seasonMultiplier":1,"sourcesDisagree":false,"classifications":["division_1","division_2","open"],"approval":"Submitted to BI 45 days in advance.","marshals":"1 Conference Accredited Marshal (a waiver may be requested)","minimumEntrants":{"buhurtMen":"4 registered 5v5 BI teams","buhurtWomen":"3 registered 5v5 BI teams","duelsMen":"6 duellists per category","duelsWomen":"3 duellists per category","duelsClubs":"Duellists from at least 2 clubs or teams"},"recording":"Video recording required; livestream recommended."}',
   'League Structure v2026.1 §2.3.3; Tournament Structure Jan 2026 §4.2'),
  ('bi','v2026.1','regional','Regional',90,
   '{"pointsPercent":150,"seasonMultiplier":1.25,"sourcesDisagree":true,"approval":"Submitted to BI 90 days in advance.","perRegion":"1 per region if under 80 competitors registered in the region, 2 if over 81.","marshals":"1 BI Accredited Marshal and 2 Regional Accredited Marshals","minimumEntrants":{"buhurtMen":"8 registered 5v5 BI teams","buhurtWomen":"5 registered 5v5 BI teams","duelsMen":"8 duellists per category","duelsWomen":"5 duellists per category","duelsClubs":"Duellists from at least 3 clubs"},"recording":"Video recording required; livestream recommended."}',
   'League Structure v2026.1 §2.3.4; Tournament Structure Jan 2026 §4.2'),
  ('bi','v2026.1','conference','Conference',120,
   '{"pointsPercent":200,"seasonMultiplier":1.5,"sourcesDisagree":true,"approval":"Needs 60/40 approval from all National Organizations in the conference and submission to BI 120 days in advance. One per conference.","marshals":"3 BI Accredited Marshals","minimumEntrants":{"countries":"Representatives of 3 countries (2 with Buhurt International Council approval)","buhurtMen":"10 registered 5v5 BI teams (8 with Council approval)","buhurtWomen":"7 registered 5v5 BI teams (5 with Council approval)","duelsMen":"10 duellists per category","duelsWomen":"7 duellists per category","duelsClubs":"Duellists from at least 5 clubs"},"recording":"Livestream and recording mandatory."}',
   'League Structure v2026.1 §2.3.5; Tournament Structure Jan 2026 §4.2')
on conflict do nothing;

-- Tournament Structure (Jan 2026) §1.3-1.7. Entrant ranges overlap at 6, 12, 16 and 20 in the source; both option sets apply there.
insert into public.tournament_format_templates (authority, doc_version, option_key, title, min_entrants, max_entrants, structure, recommended, caution, source_ref) values
  ('bi','Jan 2026','rr_4_6','Round robin',4,6,'{"kind":"round_robin"}',true,null,'§1.3'),
  ('bi','Jan 2026','rr_6_12','Round robin',6,12,'{"kind":"round_robin"}',true,null,'§1.4.1'),
  ('bi','Jan 2026','pools_6_12_rr','3-6 per pool, then a round-robin semifinal stage',6,12,'{"kind":"pools","poolSizeMin":3,"poolSizeMax":6,"advancePerPool":2,"finals":"round_robin","finalists":4}',true,null,'§1.4.2 Option 2A'),
  ('bi','Jan 2026','pools_6_12_se','3-6 per pool, then a single-elimination bracket',6,12,'{"kind":"pools","poolSizeMin":3,"poolSizeMax":6,"advancePerPool":2,"finals":"single_elimination","finalists":4,"thirdPlaceMatch":true}',true,null,'§1.4.2 Option 2B'),
  ('bi','Jan 2026','pools_12_16_two_rr','Two pools of 6-8, then a round-robin final stage',12,16,'{"kind":"pools","pools":2,"poolSizeMin":6,"poolSizeMax":8,"advancePerPool":2,"finals":"round_robin","finalists":4}',true,null,'§1.5.1 Option 1A'),
  ('bi','Jan 2026','pools_12_16_two_se','Two pools of 6-8, then a single-elimination bracket',12,16,'{"kind":"pools","pools":2,"poolSizeMin":6,"poolSizeMax":8,"advancePerPool":2,"finals":"single_elimination","finalists":4,"thirdPlaceMatch":true}',true,null,'§1.5.1 Option 1B'),
  ('bi','Jan 2026','pools_12_16_three_rr','Three pools of 4-6, then a round-robin final stage',12,16,'{"kind":"pools","pools":3,"poolSizeMin":4,"poolSizeMax":6,"advancePerPool":2,"finals":"round_robin","finalists":6,"tiebreakerRound":true}',true,null,'§1.5.2 Option 2A'),
  ('bi','Jan 2026','pools_12_16_three_se','Three pools of 4-6, then a six-team single-elimination bracket',12,16,'{"kind":"pools","pools":3,"poolSizeMin":4,"poolSizeMax":6,"advancePerPool":2,"finals":"single_elimination","finalists":6,"thirdPlaceMatch":true}',false,'Not recommended by the document because of six-team brackets.','§1.5.2 Option 2B'),
  ('bi','Jan 2026','pools_16_20_two_rr','Two pools of 8-10, then a round-robin final stage',16,20,'{"kind":"pools","pools":2,"poolSizeMin":8,"poolSizeMax":10,"advancePerPool":2,"finals":"round_robin","finalists":4}',true,null,'§1.6.1 Option 1A'),
  ('bi','Jan 2026','pools_16_20_two_se','Two pools of 8-10, then a single-elimination bracket',16,20,'{"kind":"pools","pools":2,"poolSizeMin":8,"poolSizeMax":10,"advancePerPool":2,"finals":"single_elimination","finalists":4,"thirdPlaceMatch":true}',true,null,'§1.6.1 Option 1B'),
  ('bi','Jan 2026','pools_16_20_four_rr','Four pools of 4-5, then an eight-team round-robin final stage',16,20,'{"kind":"pools","pools":4,"poolSizeMin":4,"poolSizeMax":5,"advancePerPool":2,"finals":"round_robin","finalists":8}',false,'Not recommended by the document because of the length of the tournament.','§1.6.2 Option 2A'),
  ('bi','Jan 2026','pools_16_20_four_se','Four pools of 4-5, then an eight-team single-elimination bracket',16,20,'{"kind":"pools","pools":4,"poolSizeMin":4,"poolSizeMax":5,"advancePerPool":2,"finals":"single_elimination","finalists":8,"thirdPlaceMatch":true}',true,null,'§1.6.2 Option 2B')
on conflict do nothing;

insert into public.tiebreak_policies (authority, doc_version, steps, source_ref) values
  ('bi','Jan 2026',
   '[{"key":"head_to_head","label":"Head-to-head result","appliesTo":"two_way_tie_only"},{"key":"round_ratio","label":"Round victories vs losses (Buhurt and Buckler) or hits earned vs hits received (other duels)"},{"key":"active_vs_downed","label":"Active vs downed competitors difference"},{"key":"fewest_penalties","label":"Fewest penalties received"}]',
   'Tournament Structure Jan 2026 §3')
on conflict do nothing;

notify pgrst, 'reload schema';
