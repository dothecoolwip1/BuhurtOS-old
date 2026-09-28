-- Pack 7: deterministic tournament generation, immutable publication, and walkover-safe progression.

alter table public.brackets
  add column if not exists generation_state text not null default 'published',
  add column if not exists generation_method text not null default 'legacy',
  add column if not exists random_seed text,
  add column if not exists generation_hash text,
  add column if not exists generation_config jsonb not null default '{}'::jsonb,
  add column if not exists tiebreak_policy jsonb not null default '["standing_points","wins","head_to_head","differential","points_for","seed"]'::jsonb,
  add column if not exists qualification_policy jsonb not null default '{}'::jsonb,
  add column if not exists generation_revision integer not null default 1,
  add column if not exists published_at timestamptz,
  add column if not exists supersedes_bracket_id uuid references public.brackets(id) on delete restrict;

update public.brackets
set published_at=coalesce(published_at,created_at),
    generation_method=case
      when metadata->'generationConfig'->>'seedMethod' in ('manual','ranking','season','placement','random')
        then metadata->'generationConfig'->>'seedMethod'
      else generation_method
    end,
    random_seed=coalesce(random_seed,nullif(metadata->'generationConfig'->>'randomSeed','')),
    generation_hash=coalesce(generation_hash,nullif(metadata->>'generationHash','')),
    generation_config=case
      when jsonb_typeof(metadata->'generationConfig')='object' then metadata->'generationConfig'
      else generation_config
    end,
    tiebreak_policy=case
      when jsonb_typeof(metadata->'tiebreakPolicy')='array' then metadata->'tiebreakPolicy'
      else tiebreak_policy
    end
where published_at is null
   or generation_hash is null
   or generation_config='{}'::jsonb;

alter table public.brackets
  drop constraint if exists brackets_generation_state_check,
  add constraint brackets_generation_state_check
    check (generation_state in ('published','superseded')),
  drop constraint if exists brackets_generation_method_check,
  add constraint brackets_generation_method_check
    check (generation_method in ('legacy','manual','ranking','season','placement','random')),
  drop constraint if exists brackets_generation_revision_check,
  add constraint brackets_generation_revision_check check (generation_revision > 0),
  drop constraint if exists brackets_generation_config_object,
  add constraint brackets_generation_config_object check (jsonb_typeof(generation_config)='object'),
  drop constraint if exists brackets_tiebreak_policy_array,
  add constraint brackets_tiebreak_policy_array check (jsonb_typeof(tiebreak_policy)='array'),
  drop constraint if exists brackets_qualification_policy_object,
  add constraint brackets_qualification_policy_object check (jsonb_typeof(qualification_policy)='object');

create index if not exists brackets_generation_hash_idx on public.brackets(event_id,generation_hash);
create index if not exists brackets_supersedes_idx on public.brackets(supersedes_bracket_id);

create or replace function private.pack7_protect_published_bracket()
returns trigger
language plpgsql
security definer
set search_path=''
as $$
begin
  if tg_op='DELETE' then
    if old.generation_state='published' then
      raise exception 'Published tournament structures are historical records and cannot be deleted';
    end if;
    return old;
  end if;

  if old.generation_state='published'
    and new.generation_state='superseded'
    and coalesce(current_setting('buhurtos.pack7_allow_supersede',true),'')='1'
  then
    return new;
  end if;

  if old.generation_state='published' and (
    old.generation_state is distinct from new.generation_state
    or old.event_id is distinct from new.event_id
    or old.fight_card_id is distinct from new.fight_card_id
    or old.division_id is distinct from new.division_id
    or old.ruleset_snapshot_id is distinct from new.ruleset_snapshot_id
    or old.name is distinct from new.name
    or old.format is distinct from new.format
    or old.category is distinct from new.category
    or old.metadata is distinct from new.metadata
    or old.generation_method is distinct from new.generation_method
    or old.random_seed is distinct from new.random_seed
    or old.generation_hash is distinct from new.generation_hash
    or old.generation_config is distinct from new.generation_config
    or old.tiebreak_policy is distinct from new.tiebreak_policy
    or old.qualification_policy is distinct from new.qualification_policy
    or old.generation_revision is distinct from new.generation_revision
    or old.published_at is distinct from new.published_at
    or old.supersedes_bracket_id is distinct from new.supersedes_bracket_id
  ) then
    raise exception 'Published tournament structures are immutable; create a replacement bracket instead';
  end if;
  return new;
end;
$$;

revoke execute on function private.pack7_protect_published_bracket() from public,anon,authenticated;

drop trigger if exists pack7_bracket_history_guard on public.brackets;
create trigger pack7_bracket_history_guard
before update or delete on public.brackets
for each row execute function private.pack7_protect_published_bracket();

create or replace function public.save_bracket_plan(p_bracket jsonb, p_matches jsonb)
returns uuid
language plpgsql
security invoker
set search_path=''
as $pack7$
declare
  v_bracket_id uuid := (p_bracket->>'id')::uuid;
  v_event_id uuid := (p_bracket->>'eventId')::uuid;
  v_division_id uuid := nullif(p_bracket->>'divisionId','')::uuid;
  v_event public.events%rowtype;
  v_event_division public.event_divisions%rowtype;
  v_snapshot public.event_ruleset_snapshots%rowtype;
  v_snapshot_id uuid;
  v_match jsonb;
  v_participant jsonb;
  v_roster uuid;
  v_format_id text;
  v_scoring_override jsonb;
  v_match_scoring jsonb;
  v_match_id uuid;
  v_target_id uuid;
  v_source_id uuid;
  v_generation jsonb := coalesce(p_bracket->'metadata'->'generationConfig','{}'::jsonb);
  v_tiebreak jsonb := coalesce(p_bracket->'metadata'->'tiebreakPolicy','["standing_points","wins","head_to_head","differential","points_for","seed"]'::jsonb);
  v_generation_method text := coalesce(nullif(v_generation->>'seedMethod',''),'legacy');
  v_random_seed text := nullif(v_generation->>'randomSeed','');
  v_generation_hash text := nullif(p_bracket->'metadata'->>'generationHash','');
  v_fight_card_id uuid := nullif(p_bracket->>'fightCardId','')::uuid;
  v_supersedes uuid := nullif(p_bracket->'metadata'->>'supersedesBracketId','')::uuid;
begin
  perform pg_advisory_xact_lock(hashtext('pack7-generation:'||v_event_id::text||':'||coalesce(v_division_id::text,'none')));

  select * into v_event from public.events where id=v_event_id for update;
  if not found then raise exception 'Event not found'; end if;
  if v_event.status not in ('draft','published') then
    raise exception 'Competition structures are locked once an event is live or historical';
  end if;
  if not (
    private.is_platform_admin((select auth.uid()))
    or private.has_org_role((select auth.uid()),v_event.organization_id,array['organization_admin']::public.organization_role[])
    or private.has_event_role((select auth.uid()),v_event_id,array['event_organizer','field_marshal']::public.event_role[])
  ) then
    raise exception 'Not authorized to create brackets';
  end if;

  if exists(select 1 from public.brackets where id=v_bracket_id) then
    raise exception 'Bracket ID already exists; published brackets cannot be regenerated in place';
  end if;

  if v_supersedes is not null then
    if not exists(
      select 1 from public.brackets b
      where b.id=v_supersedes
        and b.event_id=v_event_id
        and b.generation_state='published'
        and b.division_id is not distinct from v_division_id
        and b.format=p_bracket->>'format'
        and b.category=p_bracket->>'category'
    ) then
      raise exception 'Replacement bracket must reference a published structure for the same event, division, format, and category';
    end if;

    if exists(
      select 1 from public.matches m
      where m.bracket_id=v_supersedes
        and (
          m.status in ('active','completed','forfeit')
          or (m.status='finalized' and coalesce(m.result_summary->>'resultType','')<>'bye')
          or exists(select 1 from public.match_rounds mr where mr.match_id=m.id)
        )
    ) then
      raise exception 'Tournament has recorded competition and cannot be regenerated';
    end if;
  end if;

  if v_fight_card_id is not null and not exists(
    select 1 from public.fight_cards where id=v_fight_card_id and event_id=v_event_id
  ) then raise exception 'Fight card does not belong to this event'; end if;

  if jsonb_typeof(p_matches)<>'array' or jsonb_array_length(p_matches)<1 then
    raise exception 'Bracket plan has no matches';
  end if;
  if v_generation_method not in ('legacy','manual','ranking','season','placement','random') then
    raise exception 'Unsupported tournament seeding method';
  end if;
  if v_generation_method='random' and length(trim(coalesce(v_random_seed,'')))=0 then
    raise exception 'Random tournament generation requires a recorded seed';
  end if;
  if jsonb_typeof(v_generation)<>'object' then raise exception 'Generation config must be an object'; end if;
  if jsonb_typeof(v_tiebreak)<>'array' or jsonb_array_length(v_tiebreak)<1 then
    raise exception 'Published pool competition requires a tiebreak policy';
  end if;

  if exists(
    select 1
    from (
      select planned.value->>'id' as match_id,count(*) as count_rows
      from jsonb_array_elements(p_matches) as planned(value)
      group by planned.value->>'id'
      having count(*)>1
    ) duplicates
  ) then raise exception 'Bracket plan contains duplicate match IDs'; end if;

  if exists(select 1 from public.event_divisions ed where ed.event_id=v_event_id) and v_division_id is null then
    raise exception 'Choose a formal event division before creating competition';
  end if;

  if v_division_id is not null then
    select * into v_event_division
    from public.event_divisions
    where event_id=v_event_id and division_id=v_division_id;
    if not found then raise exception 'Selected division is not assigned to this event'; end if;
    if v_event_division.ruleset_snapshot_id is null then
      raise exception 'Event division does not have a locked ruleset snapshot';
    end if;
    v_snapshot_id:=v_event_division.ruleset_snapshot_id;
    v_format_id:=v_event_division.division_snapshot->>'competitionFormatId';
  else
    v_snapshot_id:=v_event.ruleset_snapshot_id;
  end if;

  if v_event.ruleset_id is not null and v_snapshot_id is null then
    raise exception 'Lock the event ruleset snapshot before creating competition';
  end if;
  if v_snapshot_id is not null then
    select * into v_snapshot
    from public.event_ruleset_snapshots
    where id=v_snapshot_id and event_id=v_event_id;
    if not found then raise exception 'Ruleset snapshot does not belong to this event'; end if;
  end if;

  for v_match in select value from jsonb_array_elements(p_matches)
  loop
    v_match_id:=(v_match->>'id')::uuid;

    if nullif(v_match->>'winnerAdvancesToMatchId','') is not null then
      v_target_id:=(v_match->>'winnerAdvancesToMatchId')::uuid;
      if v_target_id=v_match_id then raise exception 'A match cannot advance to itself'; end if;
      if not exists(
        select 1 from jsonb_array_elements(p_matches) as planned(value)
        where planned.value->>'id'=v_target_id::text
      ) then raise exception 'Winner advancement references a missing match'; end if;
    end if;

    if nullif(v_match->>'loserAdvancesToMatchId','') is not null then
      v_target_id:=(v_match->>'loserAdvancesToMatchId')::uuid;
      if v_target_id=v_match_id then raise exception 'A match cannot advance to itself'; end if;
      if not exists(
        select 1 from jsonb_array_elements(p_matches) as planned(value)
        where planned.value->>'id'=v_target_id::text
      ) then raise exception 'Loser advancement references a missing match'; end if;
    end if;

    if exists(
      select 1
      from jsonb_array_elements(coalesce(v_match->'participants','[]'::jsonb)) as participant(value)
      where nullif(participant.value->>'sourceMatchId','') is not null
        and not exists(
          select 1 from jsonb_array_elements(p_matches) as planned(value)
          where planned.value->>'id'=participant.value->>'sourceMatchId'
        )
    ) then raise exception 'Participant source references a missing match'; end if;

    if exists(
      select 1
      from jsonb_array_elements(coalesce(v_match->'participants','[]'::jsonb)) as participant(value)
      where nullif(participant.value->>'sourceMatchId','')::uuid=v_match_id
    ) then raise exception 'A match participant cannot depend on its own match'; end if;

    if exists(
      select 1
      from (
        select participant.value->>'sideIndex',count(*)
        from jsonb_array_elements(coalesce(v_match->'participants','[]'::jsonb)) as participant(value)
        group by participant.value->>'sideIndex'
        having count(*)>1
      ) duplicate_side
    ) then raise exception 'A match contains duplicate participant sides'; end if;

    if exists(
      select 1
      from (
        select participant.value->>'rosterEntryId',count(*)
        from jsonb_array_elements(coalesce(v_match->'participants','[]'::jsonb)) as participant(value)
        where nullif(participant.value->>'rosterEntryId','') is not null
        group by participant.value->>'rosterEntryId'
        having count(*)>1
      ) duplicate_entry
    ) then raise exception 'A match cannot contain the same competitor on both sides'; end if;
  end loop;

  insert into public.brackets(
    id,event_id,fight_card_id,division_id,ruleset_snapshot_id,name,format,category,metadata,created_by,
    generation_state,generation_method,random_seed,generation_hash,generation_config,tiebreak_policy,
    qualification_policy,generation_revision,published_at,supersedes_bracket_id
  )
  values (
    v_bracket_id,v_event_id,v_fight_card_id,v_division_id,v_snapshot_id,
    p_bracket->>'name',p_bracket->>'format',p_bracket->>'category',
    coalesce(p_bracket->'metadata','{}'::jsonb)||jsonb_build_object('rulesetSnapshotId',v_snapshot_id),
    (select auth.uid()),
    'published',v_generation_method,v_random_seed,v_generation_hash,v_generation,v_tiebreak,
    coalesce(p_bracket->'metadata'->'qualificationPolicy','{}'::jsonb),1,timezone('utc',now()),
    v_supersedes
  );

  for v_match in select value from jsonb_array_elements(p_matches)
  loop
    if v_division_id is not null and coalesce(v_match->>'matchType','')<>coalesce(v_format_id,'') then
      raise exception 'Match format does not match the selected event division';
    end if;
    if v_division_id is null then v_format_id:=v_match->>'matchType'; end if;

    v_match_scoring:=coalesce(v_match->'scoringConfig','{}'::jsonb);
    if v_snapshot_id is not null then
      if jsonb_array_length(coalesce(v_snapshot.resolved_settings->'enabledFormats','[]'::jsonb))>0
        and not (coalesce(v_snapshot.resolved_settings->'enabledFormats','[]'::jsonb) ? v_format_id)
      then raise exception 'Competition format is not enabled by the locked ruleset snapshot'; end if;
      v_scoring_override:=coalesce(v_snapshot.resolved_settings->'scoringOverrides'->v_format_id,'{}'::jsonb);
      if not (v_match_scoring @> v_scoring_override) then
        raise exception 'Match scoring does not include the locked ruleset override';
      end if;
    end if;

    insert into public.matches(
      id,organization_id,season_id,event_id,fight_card_id,bracket_id,division_id,ruleset_snapshot_id,
      label,category,match_type,scoring_config,status,stage,scheduled_order,bracket_round,bracket_slot,
      winner_advances_to_match_id,winner_advances_to_slot,loser_advances_to_match_id,loser_advances_to_slot,
      result_summary,created_by
    )
    values (
      (v_match->>'id')::uuid,v_event.organization_id,v_event.season_id,v_event.id,
      nullif(v_match->>'fightCardId','')::uuid,v_bracket_id,v_division_id,v_snapshot_id,
      v_match->>'label',v_match->>'category',v_match->>'matchType',v_match_scoring,
      coalesce((v_match->>'status')::public.match_status,'scheduled'::public.match_status),
      coalesce((v_match->>'stage')::public.match_stage,'bracket'::public.match_stage),
      coalesce((v_match->>'scheduledOrder')::integer,0),
      nullif(v_match->>'bracketRound','')::integer,v_match->>'bracketSlot',
      nullif(v_match->>'winnerAdvancesToMatchId','')::uuid,nullif(v_match->>'winnerAdvancesToSlot','')::smallint,
      nullif(v_match->>'loserAdvancesToMatchId','')::uuid,nullif(v_match->>'loserAdvancesToSlot','')::smallint,
      coalesce(v_match->'resultSummary','{}'::jsonb),(select auth.uid())
    );
  end loop;

  for v_match in select value from jsonb_array_elements(p_matches)
  loop
    for v_participant in select value from jsonb_array_elements(coalesce(v_match->'participants','[]'::jsonb))
    loop
      v_roster:=nullif(v_participant->>'rosterEntryId','')::uuid;
      v_source_id:=nullif(v_participant->>'sourceMatchId','')::uuid;
      if v_roster is not null and not exists(
        select 1 from public.event_roster_entries r
        where r.id=v_roster
          and r.event_id=v_event_id
          and r.can_compete
          and (v_event_division.id is null or r.event_division_id is null or r.event_division_id=v_event_division.id)
      ) then raise exception 'Bracket contains a competitor who is not cleared for this event division'; end if;

      insert into public.match_participants(
        match_id,roster_entry_id,side_index,seed,is_placeholder,placeholder_label,source_match_id,source_slot,is_winner_source
      )
      values (
        (v_match->>'id')::uuid,v_roster,(v_participant->>'sideIndex')::smallint,
        nullif(v_participant->>'seed','')::integer,coalesce((v_participant->>'isPlaceholder')::boolean,false),
        v_participant->>'placeholderLabel',v_source_id,
        nullif(v_participant->>'sourceSlot','')::smallint,nullif(v_participant->>'isWinnerSource','')::boolean
      );
    end loop;
  end loop;

  if v_supersedes is not null then
    perform set_config('buhurtos.pack7_allow_supersede','1',true);
    update public.brackets
    set generation_state='superseded',last_edited_by=(select auth.uid())
    where id=v_supersedes;
    perform set_config('buhurtos.pack7_allow_supersede','0',true);

    update public.matches
    set status='cancelled',last_edited_by=(select auth.uid())
    where bracket_id=v_supersedes
      and (
        status in ('scheduled','on_deck','in_the_hole')
        or (status='finalized' and coalesce(result_summary->>'resultType','')='bye')
      );

    insert into public.audit_log(organization_id,event_id,actor_user_id,table_name,record_id,action,payload)
    values (
      v_event.organization_id,v_event_id,(select auth.uid()),'brackets',v_supersedes,'supersede_tournament',
      jsonb_build_object('replacementBracketId',v_bracket_id)
    );
  end if;

  insert into public.audit_log(organization_id,event_id,actor_user_id,table_name,record_id,action,payload)
  values (
    v_event.organization_id,v_event_id,(select auth.uid()),'brackets',v_bracket_id,'publish_tournament',
    jsonb_build_object(
      'matchCount',jsonb_array_length(p_matches),
      'divisionId',v_division_id,
      'rulesetSnapshotId',v_snapshot_id,
      'generationMethod',v_generation_method,
      'randomSeed',v_random_seed,
      'generationHash',v_generation_hash,
      'tiebreakPolicy',v_tiebreak
    )
  );
  return v_bracket_id;
end;
$pack7$;

revoke execute on function public.save_bracket_plan(jsonb,jsonb) from public,anon;
grant execute on function public.save_bracket_plan(jsonb,jsonb) to authenticated;

-- Pack 7 allows the forfeiting side to be unavailable, while the winner must remain cleared.
-- A withdrawn/no-show competitor is not advanced to a lower bracket after the walkover.
create or replace function public.submit_match_result(
  p_match_id uuid,
  p_rounds jsonb,
  p_forfeit_side smallint default null,
  p_forfeit_reason text default null,
  p_expected_status public.match_status default 'scheduled'
) returns jsonb
language plpgsql
security invoker
set search_path=''
as $pack7result$
declare
  v_match public.matches%rowtype;
  v_config jsonb;
  v_required integer;
  v_allow_draw boolean;
  v_cap numeric;
  v_kind text;
  v_wins_required integer;
  v_count integer;
  v_s1 numeric:=0;
  v_s2 numeric:=0;
  v_w1 integer:=0;
  v_w2 integer:=0;
  v_winner smallint:=null;
  v_loser smallint:=null;
  v_item jsonb;
  v_entry record;
  v_winner_entry uuid;
  v_loser_entry uuid;
  v_loser_can_continue boolean:=true;
begin
  select * into v_match from public.matches where id=p_match_id for update;
  if not found then raise exception 'Match not found'; end if;
  if v_match.status<>p_expected_status then raise exception 'Match changed since it was loaded'; end if;
  if v_match.status in ('finalized','cancelled') then raise exception 'Match is already closed'; end if;
  if v_match.status not in ('active','completed') then raise exception 'Match must be active before a result can be submitted'; end if;
  if not (
    private.is_platform_admin((select auth.uid()))
    or private.has_org_role((select auth.uid()),v_match.organization_id,array['organization_admin']::public.organization_role[])
    or private.has_event_role((select auth.uid()),v_match.event_id,array['event_organizer','field_marshal','assistant_marshal']::public.event_role[])
  ) then raise exception 'Not authorized to score this match'; end if;

  for v_entry in
    select mp.roster_entry_id,mp.side_index,r.can_compete,r.attendance_status,r.metadata
    from public.match_participants mp
    join public.event_roster_entries r on r.id=mp.roster_entry_id
    where mp.match_id=p_match_id and mp.roster_entry_id is not null
  loop
    if p_forfeit_side is not null and v_entry.side_index=p_forfeit_side then
      continue;
    end if;
    if not v_entry.can_compete then raise exception 'A match participant is not cleared to compete'; end if;
  end loop;

  v_config:=v_match.scoring_config;
  v_required:=coalesce((v_config->>'roundsRequired')::integer,1);
  v_allow_draw:=coalesce((v_config->>'allowDrawRound')::boolean,false);
  v_cap:=nullif(v_config->>'scoreCapPerRound','')::numeric;
  v_kind:=coalesce(v_config->>'kind','duel');
  v_wins_required:=coalesce((v_config->>'winsRequired')::integer,floor(v_required/2.0)::integer+1);

  if p_forfeit_side is not null then
    if p_forfeit_side not in (1,2) then raise exception 'Invalid forfeit side'; end if;
    if coalesce((v_config->>'requireReasonOnForfeit')::boolean,true)
      and length(trim(coalesce(p_forfeit_reason,'')))=0
    then raise exception 'Forfeit reason is required'; end if;
    v_winner:=case when p_forfeit_side=1 then 2 else 1 end;
    delete from public.match_rounds where match_id=p_match_id;
  else
    if jsonb_typeof(p_rounds)<>'array' then raise exception 'Rounds must be an array'; end if;
    select jsonb_array_length(p_rounds) into v_count;
    if v_count<>v_required then raise exception 'Incorrect number of rounds'; end if;
    delete from public.match_rounds where match_id=p_match_id;

    for v_item in select value from jsonb_array_elements(p_rounds)
    loop
      if (v_item->>'roundNumber')::integer<1 or (v_item->>'roundNumber')::integer>v_required then
        raise exception 'Round number outside configured range';
      end if;
      if (v_item->>'side1Score')::numeric<0 or (v_item->>'side2Score')::numeric<0 then
        raise exception 'Scores cannot be negative';
      end if;
      if v_cap is not null and (
        (v_item->>'side1Score')::numeric>v_cap or (v_item->>'side2Score')::numeric>v_cap
      ) then raise exception 'Score exceeds configured cap'; end if;
      if not v_allow_draw and (v_item->>'side1Score')::numeric=(v_item->>'side2Score')::numeric then
        raise exception 'Tied round is not allowed';
      end if;

      insert into public.match_rounds(match_id,round_number,side_1_score,side_2_score,notes)
      values (
        p_match_id,(v_item->>'roundNumber')::integer,
        (v_item->>'side1Score')::numeric,(v_item->>'side2Score')::numeric,v_item->>'notes'
      );
      v_s1:=v_s1+(v_item->>'side1Score')::numeric;
      v_s2:=v_s2+(v_item->>'side2Score')::numeric;
      if (v_item->>'side1Score')::numeric>(v_item->>'side2Score')::numeric then v_w1:=v_w1+1;
      elsif (v_item->>'side2Score')::numeric>(v_item->>'side1Score')::numeric then v_w2:=v_w2+1;
      end if;
    end loop;

    if v_kind='team_fight' or v_config ? 'winsRequired' then
      if v_w1>=v_wins_required then v_winner:=1;
      elsif v_w2>=v_wins_required then v_winner:=2;
      elsif v_w1<>v_w2 then v_winner:=case when v_w1>v_w2 then 1 else 2 end;
      end if;
    else
      if v_s1>v_s2 then v_winner:=1;
      elsif v_s2>v_s1 then v_winner:=2;
      end if;
    end if;
  end if;

  if v_winner is not null then
    v_loser:=case when v_winner=1 then 2 else 1 end;
    select roster_entry_id into v_winner_entry
    from public.match_participants where match_id=p_match_id and side_index=v_winner;
    select roster_entry_id into v_loser_entry
    from public.match_participants where match_id=p_match_id and side_index=v_loser;

    if v_loser_entry is not null then
      select (
        r.can_compete
        and r.attendance_status not in ('withdrawn','no_show')
        and coalesce((r.metadata->>'tournamentDisqualified')::boolean,false)=false
      ) into v_loser_can_continue
      from public.event_roster_entries r where r.id=v_loser_entry;
    end if;
  end if;

  update public.matches set
    status='finalized',
    completed_at=timezone('utc',now()),
    finalized_at=timezone('utc',now()),
    last_edited_by=(select auth.uid()),
    result_summary=jsonb_build_object(
      'winnerSide',v_winner,'side1Total',v_s1,'side2Total',v_s2,
      'roundsWonSide1',v_w1,'roundsWonSide2',v_w2,
      'resultType',case
        when p_forfeit_side is not null then 'forfeit'
        when v_winner is null then 'draw'
        when v_kind='team_fight' or v_config ? 'winsRequired' then 'rounds'
        else 'points'
      end,
      'forfeitReason',p_forfeit_reason
    )
  where id=p_match_id;

  if v_winner is not null then
    if v_match.bracket_slot='GF-1' and v_match.winner_advances_to_match_id is not null then
      if v_winner=1 then
        update public.matches set status='cancelled',last_edited_by=(select auth.uid())
        where id=v_match.winner_advances_to_match_id;
      else
        update public.matches set status='scheduled',last_edited_by=(select auth.uid())
        where id=v_match.winner_advances_to_match_id;
        delete from public.match_participants
        where match_id=v_match.winner_advances_to_match_id
          and side_index in (v_match.winner_advances_to_slot,v_match.loser_advances_to_slot);
        insert into public.match_participants(
          match_id,roster_entry_id,side_index,source_match_id,source_slot,is_winner_source,is_placeholder
        ) values (
          v_match.winner_advances_to_match_id,v_winner_entry,v_match.winner_advances_to_slot,
          p_match_id,v_match.winner_advances_to_slot,true,false
        );
        if v_loser_can_continue and v_loser_entry is not null then
          insert into public.match_participants(
            match_id,roster_entry_id,side_index,source_match_id,source_slot,is_winner_source,is_placeholder
          ) values (
            v_match.loser_advances_to_match_id,v_loser_entry,v_match.loser_advances_to_slot,
            p_match_id,v_match.loser_advances_to_slot,false,false
          );
        end if;
      end if;
    else
      if v_match.winner_advances_to_match_id is not null and v_winner_entry is not null then
        delete from public.match_participants
        where match_id=v_match.winner_advances_to_match_id and side_index=v_match.winner_advances_to_slot;
        insert into public.match_participants(
          match_id,roster_entry_id,side_index,source_match_id,source_slot,is_winner_source,is_placeholder
        ) values (
          v_match.winner_advances_to_match_id,v_winner_entry,v_match.winner_advances_to_slot,
          p_match_id,v_match.winner_advances_to_slot,true,false
        );
      end if;
      if v_match.loser_advances_to_match_id is not null and v_loser_entry is not null and v_loser_can_continue then
        delete from public.match_participants
        where match_id=v_match.loser_advances_to_match_id and side_index=v_match.loser_advances_to_slot;
        insert into public.match_participants(
          match_id,roster_entry_id,side_index,source_match_id,source_slot,is_winner_source,is_placeholder
        ) values (
          v_match.loser_advances_to_match_id,v_loser_entry,v_match.loser_advances_to_slot,
          p_match_id,v_match.loser_advances_to_slot,false,false
        );
      end if;
    end if;
  end if;

  insert into public.audit_log(organization_id,event_id,actor_user_id,table_name,record_id,action,payload)
  values (
    v_match.organization_id,v_match.event_id,(select auth.uid()),'matches',p_match_id,'finalize_result',
    jsonb_build_object(
      'winnerSide',v_winner,
      'winnerAdvancedTo',v_match.winner_advances_to_match_id,
      'loserAdvancedTo',case when v_loser_can_continue then v_match.loser_advances_to_match_id else null end,
      'walkover',p_forfeit_side is not null
    )
  );
  return (select result_summary from public.matches where id=p_match_id);
end;
$pack7result$;

revoke execute on function public.submit_match_result(uuid,jsonb,smallint,text,public.match_status) from public,anon;
grant execute on function public.submit_match_result(uuid,jsonb,smallint,text,public.match_status) to authenticated;
