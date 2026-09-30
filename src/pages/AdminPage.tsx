import { useEffect, useMemo, useState } from 'react';
import { useAppState } from '../features/AppState';
import { checkCompliance } from '../lib/compliance';
import { computePoolQualificationState, generateSingleElimination } from '../lib/bracket';
import { buildTournamentPreview, type SeedMethod, type TournamentPlanPreview } from '../lib/tournamentGeneration';
import { addGhostFighter, listTournamentBrackets, saveBracketPlan, type TournamentBracketSummary } from '../lib/adminActions';
import { inviteEventMember, listEventMemberships, removeEventMembership, type EventMembershipView } from '../lib/memberAdmin';
import { competitionFormatById, competitionFormats } from '../lib/competitionFormats';
import { listEventDivisions, listEventRulesetSnapshots } from '../lib/governance';
import { applyRulesetToFormat } from '../lib/rulesetAdmin';
import type { Bracket, EventDivision, EventRole, EventRulesetSnapshot } from '../types';

const assignableRoles: Array<{value: EventRole; label: string}> = [
  { value: 'event_organizer', label: 'Event Organizer' },
  { value: 'field_marshal', label: 'Field Marshal' },
  { value: 'assistant_marshal', label: 'Assistant Marshal' },
  { value: 'team_captain', label: 'Team Captain' },
  { value: 'fighter', label: 'Fighter' }
];

export function AdminPage() {
  const { event, roster, fightCards, matches, reload } = useAppState();
  const [ghostName, setGhostName] = useState('');
  const [selected, setSelected] = useState<string[]>([]);
  const [bracketFormat, setBracketFormat] = useState<Bracket['format']>('single_elimination');
  const [competitionFormatId, setCompetitionFormatId] = useState('longsword');
  const [eventDivisionId, setEventDivisionId] = useState('');
  const [eventDivisions, setEventDivisions] = useState<EventDivision[]>([]);
  const [rulesetSnapshots, setRulesetSnapshots] = useState<EventRulesetSnapshot[]>([]);
  const [poolSize, setPoolSize] = useState(4);
  const [fightCardId, setFightCardId] = useState('');
  const [qualifiersPerPool, setQualifiersPerPool] = useState(2);
  const [seedMethod, setSeedMethod] = useState<SeedMethod>('manual');
  const [seedValues, setSeedValues] = useState<Record<string,string>>({});
  const [randomSeed, setRandomSeed] = useState('');
  const [preview, setPreview] = useState<TournamentPlanPreview | null>(null);
  const [publishedBrackets, setPublishedBrackets] = useState<TournamentBracketSummary[]>([]);
  const [supersedesBracketId, setSupersedesBracketId] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const [memberships, setMemberships] = useState<EventMembershipView[]>([]);
  const [memberForm, setMemberForm] = useState<{email:string; displayName:string; role:EventRole; teamId:string}>({ email:'', displayName:'', role:'field_marshal', teamId:'' });
  const eligible = useMemo(() => roster.filter(r => checkCompliance(r).eligible), [roster]);
  const teamOptions = useMemo(() => [...new Set(roster.map(entry => entry.teamId).filter((id): id is string => Boolean(id)))].map(id => ({ id, label: roster.filter(entry => entry.teamId === id).slice(0,2).map(entry => entry.displayName).join(', ') || `Team ${id.slice(0,8)}` })), [roster]);
  const poolStructures = useMemo(() => [...new Set(matches.filter(match => match.stage === 'pool' && match.bracketId).map(match => match.bracketId!))].map(bracketId => ({
    bracketId,
    first: matches.find(match => match.bracketId === bracketId && match.stage === 'pool')!
  })), [matches]);
  const selectedEventDivision = useMemo(
    () => eventDivisions.find(row => row.id === eventDivisionId),
    [eventDivisions,eventDivisionId]
  );
  const selectedRulesSnapshot = useMemo(() => {
    const snapshotId = selectedEventDivision?.rulesetSnapshotId || event?.rulesetSnapshotId;
    return rulesetSnapshots.find(row => row.id === snapshotId);
  }, [selectedEventDivision?.rulesetSnapshotId,event?.rulesetSnapshotId,rulesetSnapshots]);
  const enabledFormatIds = selectedRulesSnapshot?.resolvedSettings.enabledFormats ?? competitionFormats.map(format=>format.id);
  const selectableFormats = competitionFormats.filter(format => enabledFormatIds.includes(format.id));

  const loadMembers = async () => {
    if (!event) return;
    try { setMemberships(await listEventMemberships(event.id)); }
    catch (error) { setMessage(error instanceof Error ? error.message : 'Unable to load event access.'); }
  };
  const loadCompetitionPolicy = async () => {
    if (!event) return;
    try {
      const [divisions,snapshots,brackets]=await Promise.all([
        listEventDivisions(event.id),
        listEventRulesetSnapshots(event.id),
        listTournamentBrackets(event.id)
      ]);
      setEventDivisions(divisions);
      setRulesetSnapshots(snapshots);
      setPublishedBrackets(brackets);
      setEventDivisionId(current=>current&&divisions.some(row=>row.id===current)?current:(divisions[0]?.id||''));
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Unable to load event division policy.');
    }
  };
  useEffect(() => { loadMembers(); loadCompetitionPolicy(); }, [event?.id]);
  useEffect(() => {
    if(!selectedEventDivision)return;
    const formatId=String(selectedEventDivision.divisionSnapshot?.competitionFormatId||'');
    if(formatId)setCompetitionFormatId(formatId);
  }, [selectedEventDivision?.id]);
  if (!event) return null;

  const addGhost = async () => {
    if (!ghostName.trim()) return;
    setBusy(true); setMessage('');
    try { await addGhostFighter(event, ghostName.trim()); setGhostName(''); await reload(); setMessage('Ghost fighter added. Complete compliance before bracket placement.'); }
    catch (e) { setMessage(e instanceof Error ? e.message : 'Unable to add ghost fighter.'); }
    finally { setBusy(false); }
  };
  const generationContext = () => {
    const chosen = eligible.filter(r => selected.includes(r.id));
    if (chosen.length < 2) throw new Error('Choose at least two cleared competitors.');
    if(eventDivisions.length>0&&!selectedEventDivision)throw new Error('Choose a formal event division.');
    const formatId=selectedEventDivision
      ? String(selectedEventDivision.divisionSnapshot?.competitionFormatId||competitionFormatId)
      : competitionFormatId;
    const preset = competitionFormatById(formatId);
    if(selectedRulesSnapshot&&!selectedRulesSnapshot.resolvedSettings.enabledFormats.includes(formatId)){
      throw new Error('The selected competition format is not enabled by the locked ruleset snapshot.');
    }
    if((event.rulesetId||selectedEventDivision)&&!selectedRulesSnapshot){
      throw new Error('Lock the effective ruleset snapshot before generating competition.');
    }
    const governedPreset=selectedRulesSnapshot
      ? applyRulesetToFormat(preset,selectedRulesSnapshot.resolvedSettings)
      : preset;
    const category=selectedEventDivision
      ? String(selectedEventDivision.divisionSnapshot?.name||preset.name)
      : preset.name;
    const numericValues = Object.fromEntries(chosen.map(entry => [entry.id, seedValues[entry.id]?.trim() ? Number(seedValues[entry.id]) : Number.NaN]));
    return { chosen, governedPreset, category, numericValues };
  };

  const generatePreview = async () => {
    setBusy(true); setMessage('');
    try {
      const { chosen, governedPreset, category, numericValues } = generationContext();
      const bracketId = preview?.bracketId ?? crypto.randomUUID();
      const next = buildTournamentPreview({
        organizationId:event.organizationId,
        seasonId:event.seasonId,
        eventId:event.id,
        fightCardId:fightCardId||undefined,
        bracketId,
        divisionId:selectedEventDivision?.divisionId,
        rulesetSnapshotId:selectedRulesSnapshot?.id,
        category,
        matchType:governedPreset.matchType,
        scoringConfig:governedPreset.scoringConfig,
        format:bracketFormat,
        entries:chosen,
        seeding:{
          method:seedMethod,
          values:seedMethod==='random'?undefined:numericValues,
          randomSeed:seedMethod==='random'?randomSeed.trim():undefined
        },
        antiFratricide:selectedRulesSnapshot?.resolvedSettings.bracket.antiFratricide ?? true,
        targetPoolSize:poolSize,
        qualifiersPerPool
      });
      setPreview(next);
      setMessage('Preview generated. Review seeds, warnings, and match count before publishing.');
    } catch (e) {
      setPreview(null);
      setMessage(e instanceof Error ? e.message : 'Unable to preview competition structure.');
    } finally {
      setBusy(false);
    }
  };

  const publishPreview = async () => {
    if(!preview)return;
    setBusy(true); setMessage('');
    try {
      const { category } = generationContext();
      await saveBracketPlan(event, preview.plan, {
        id:preview.bracketId,
        name:category + ' ' + bracketFormat.replaceAll('_',' ') + ' ' + new Date().toLocaleDateString(),
        fightCardId:fightCardId||undefined,
        divisionId:selectedEventDivision?.divisionId,
        category,
        format:bracketFormat,
        metadata:{
          ...('pools' in preview.plan ? { pools:preview.plan.pools, targetPoolSize:poolSize } : {}),
          rulesetSnapshotId:selectedRulesSnapshot?.id,
          generationState:'published',
          generationHash:preview.generationHash,
          generationConfig:preview.generationConfig,
          tiebreakPolicy:preview.tiebreakPolicy,
          warnings:preview.warnings,
          supersedesBracketId:supersedesBracketId||undefined
        }
      });
      await Promise.all([reload(),loadCompetitionPolicy()]);
      setPreview(null);
      setSupersedesBracketId('');
      setMessage('Competition published with ' + preview.plan.matches.length + ' matches. Published generation history is immutable.');
    } catch (e) {
      setMessage(e instanceof Error ? e.message : 'Unable to publish competition structure.');
    } finally {
      setBusy(false);
    }
  };

  const advancePools = async (sourceBracketId: string) => {
    const qualification = computePoolQualificationState(matches, roster, sourceBracketId, qualifiersPerPool);
    if (!qualification.ready) return setMessage('All pool matches must be finalized before qualifiers can advance.');
    if (qualification.qualifiers.length < 2) return setMessage('Not enough qualifiers are available to build the playoff bracket.');
    const source = matches.find(match => match.bracketId === sourceBracketId && match.stage === 'pool');
    if (!source) return setMessage('Pool competition could not be found.');
    setBusy(true); setMessage('');
    try {
      const bracketId = crypto.randomUUID();
      const playoff = generateSingleElimination({
        organizationId: event.organizationId,
        seasonId: event.seasonId,
        eventId: event.id,
        fightCardId: fightCardId || source.fightCardId,
        bracketId,
        category: source.category,
        matchType: source.matchType,
        entries: qualification.qualifiers,
        scoringConfig: source.scoringConfig
      });
      playoff.matches.forEach(match=>{
        match.divisionId=source.divisionId;
        match.rulesetSnapshotId=source.rulesetSnapshotId;
      });
      await saveBracketPlan(event, playoff, {
        id: bracketId,
        name: source.category + ' Playoff',
        fightCardId: fightCardId || source.fightCardId,
        divisionId:source.divisionId,
        category: source.category,
        format: 'single_elimination',
        metadata: {
          sourcePoolBracketId: sourceBracketId,
          qualifiersPerPool,
          pools: qualification.pools.map(pool => ({ name: pool.name, qualifiers: pool.standings.slice(0, qualifiersPerPool).map(row => row.rosterEntryId) }))
        }
      });
      await reload();
      setMessage('Pool qualifiers seeded into a ' + playoff.matches.length + '-match playoff bracket.');
    } catch (e) {
      setMessage(e instanceof Error ? e.message : 'Unable to advance pool qualifiers.');
    } finally {
      setBusy(false);
    }
  };

  const addMember = async () => {
    if (!memberForm.email.trim()) return;
    if (memberForm.role === 'team_captain' && !memberForm.teamId) return setMessage('Choose a team for the captain.');
    setBusy(true); setMessage('');
    try {
      const result = await inviteEventMember({ eventId:event.id, email:memberForm.email.trim(), displayName:memberForm.displayName.trim() || undefined, role:memberForm.role, teamId:memberForm.role === 'team_captain' ? memberForm.teamId : undefined });
      await loadMembers();
      setMemberForm({ email:'', displayName:'', role:'field_marshal', teamId:'' });
      setMessage(result.invited ? 'Account access assigned.' : 'Existing account found and event access assigned. No email was sent.');
    } catch (e) { setMessage(e instanceof Error ? e.message : 'Unable to assign event access.'); }
    finally { setBusy(false); }
  };
  const removeMember = async (id: string) => {
    setBusy(true); setMessage('');
    try { await removeEventMembership(id); await loadMembers(); setMessage('Event role removed.'); }
    catch (e) { setMessage(e instanceof Error ? e.message : 'Unable to remove event role.'); }
    finally { setBusy(false); }
  };

  return <>
    <section className="section-head"><div><span className="eyebrow">Event tools</span><h1>Bracket tools</h1><p>Administrative actions are kept separate from live field controls.</p></div></section>
    <div className="admin-grid">
      <section className="panel-card"><h2>Add ghost fighter</h2><p>Create an event-only identity immediately. It can later be linked to a permanent fighter without changing historical match references.</p><div className="inline-form"><input value={ghostName} onChange={e => setGhostName(e.target.value)} placeholder="Display name"/><button className="primary" disabled={busy} onClick={addGhost}>Add</button></div></section>
      <section className="panel-card"><h2>Build competition structure</h2><p>Generate a reproducible preview first. Publishing commits that exact draw and preserves it as tournament history.</p><div className="form-stack">{eventDivisions.length>0?<label>Formal event division<select value={eventDivisionId} onChange={e=>{setEventDivisionId(e.target.value);setPreview(null);}}><option value="">Choose event division</option>{eventDivisions.map(row=><option key={row.id} value={row.id}>{String(row.divisionSnapshot?.name||'Division')} ┬╖ v{String(row.divisionSnapshot?.version||1)}</option>)}</select></label>:<label>Competition format<select value={competitionFormatId} onChange={e=>{setCompetitionFormatId(e.target.value);setPreview(null);}}>{selectableFormats.map(format=><option key={format.id} value={format.id}>{format.name}</option>)}</select></label>}{selectedRulesSnapshot&&<div className="state-card"><strong>{selectedRulesSnapshot.rulesetShortName} {selectedRulesSnapshot.rulesetVersion}</strong><br/>Scoring is locked from snapshot {selectedRulesSnapshot.id.slice(0,8)}. Same-team separation: {selectedRulesSnapshot.resolvedSettings.bracket.antiFratricide?'on':'off'}.</div>}<label>Structure<select value={bracketFormat} onChange={e=>{setBracketFormat(e.target.value as Bracket['format']);setPreview(null);}}><option value="single_elimination">Single elimination</option><option value="double_elimination">Double elimination</option><option value="round_robin">Round robin</option><option value="pools_to_bracket">Pools</option></select></label><label>Seeding method<select value={seedMethod} onChange={e=>{setSeedMethod(e.target.value as SeedMethod);setPreview(null);}}><option value="manual">Manual seed</option><option value="ranking">Ranking score</option><option value="season">Season points</option><option value="placement">Prior placement</option><option value="random">Recorded random draw</option></select></label>{seedMethod==='random'&&<label>Random seed<input value={randomSeed} onChange={e=>{setRandomSeed(e.target.value);setPreview(null);}} placeholder="Example: HACSA-2026-RED-DEER"/></label>}<label>Field / list<select value={fightCardId} onChange={e=>{setFightCardId(e.target.value);setPreview(null);}}><option value="">Unassigned</option>{[...fightCards].filter(card=>card.status!=='archived').sort((a,b)=>a.sortOrder-b.sortOrder).map(card=><option key={card.id} value={card.id}>{card.name}</option>)}</select></label><label>Safe regeneration<select value={supersedesBracketId} onChange={e=>{setSupersedesBracketId(e.target.value);setPreview(null);}}><option value="">Create a new structure</option>{publishedBrackets.filter(item=>item.generationState==='published'&&item.format===bracketFormat&&(!selectedEventDivision||item.divisionId===selectedEventDivision.divisionId)).map(item=><option key={item.id} value={item.id}>Replace unstarted: {item.name}</option>)}</select></label>{supersedesBracketId&&<small>Replacement is allowed only before real competition has been recorded. The prior draw is retained as superseded history.</small>}{bracketFormat==='pools_to_bracket'&&<label>Target pool size<input type="number" min="3" max="12" value={poolSize} onChange={e=>{setPoolSize(Math.max(3,Number(e.target.value)||4));setPreview(null);}}/></label>}</div><div className="selector-list">{eligible.map(entry => <label key={entry.id}><input type="checkbox" checked={selected.includes(entry.id)} onChange={e => {setSelected(current => e.target.checked ? [...current, entry.id] : current.filter(id => id !== entry.id));setPreview(null);}}/><span>{entry.displayName}</span>{selected.includes(entry.id)&&seedMethod!=='random'&&<input aria-label={entry.displayName+' seed value'} type="number" value={seedValues[entry.id]??''} onChange={e=>{setSeedValues(current=>({...current,[entry.id]:e.target.value}));setPreview(null);}} placeholder={seedMethod==='ranking'||seedMethod==='season'?'score':'seed'}/>}</label>)}</div><button className="primary big" disabled={busy || selected.length < 2} onClick={generatePreview}>Generate Preview</button>{preview&&<div className="state-card"><strong>Preview ┬╖ {preview.plan.matches.length} matches ┬╖ hash {preview.generationHash}</strong><div>{preview.seededEntries.map(item=><div key={item.entry.id}>#{item.seed} {item.entry.displayName}</div>)}</div>{preview.warnings.map((warning,index)=><p key={index}>{warning}</p>)}{preview.teamConflicts.length>0&&<details><summary>{preview.teamConflicts.length} same-team conflict{preview.teamConflicts.length===1?'':'s'}</summary>{preview.teamConflicts.map(item=><div key={item}>{item}</div>)}</details>}<button className="primary big" disabled={busy} onClick={publishPreview}>Publish This Preview</button></div>}</section>
      <section className="panel-card"><h2>Advance pool qualifiers</h2><p>Completed pools can seed directly into an elimination playoff. Rankings use wins, standing points, score differential and points scored as deterministic tie-breakers.</p><div className="form-stack"><label>Qualifiers per pool<input type="number" min="1" max="8" value={qualifiersPerPool} onChange={e=>setQualifiersPerPool(Math.max(1,Number(e.target.value)||2))}/></label><label>Playoff field<select value={fightCardId} onChange={e=>setFightCardId(e.target.value)}><option value="">Keep pool field</option>{[...fightCards].filter(card=>card.status!=='archived').sort((a,b)=>a.sortOrder-b.sortOrder).map(card=><option key={card.id} value={card.id}>{card.name}</option>)}</select></label></div><div className="pool-advance-list">{poolStructures.length===0?<div className="state-card">No pool competitions have been created yet.</div>:poolStructures.map(structure=>{const state=computePoolQualificationState(matches,roster,structure.bracketId,qualifiersPerPool);return <article key={structure.bracketId}><div className="grow"><b>{structure.first.category}</b><small>{state.pools.length} pool{state.pools.length===1?'':'s'} ┬╖ {state.ready?state.qualifiers.length+' qualifiers ready':state.incompleteMatchIds.length+' pool matches remaining'}</small></div><button className={state.ready?'primary':''} disabled={busy||!state.ready} onClick={()=>advancePools(structure.bracketId)}>{state.ready?'Create Playoff':'Pools Incomplete'}</button></article>;})}</div></section>
      <section className="panel-card"><h2>Assign event member</h2><p>Assign an existing verified BuhurtOS account by email. Account lookup happens server-side, privileged credentials never enter the browser, and no email is sent automatically.</p><div className="form-stack"><label>Email<input type="email" value={memberForm.email} onChange={e=>setMemberForm(f=>({...f,email:e.target.value}))}/></label><label>Display name<input value={memberForm.displayName} onChange={e=>setMemberForm(f=>({...f,displayName:e.target.value}))}/></label><label>Role<select value={memberForm.role} onChange={e=>setMemberForm(f=>({...f,role:e.target.value as EventRole,teamId:e.target.value === 'team_captain' ? f.teamId : ''}))}>{assignableRoles.map(role=><option key={role.value} value={role.value}>{role.label}</option>)}</select></label>{memberForm.role === 'team_captain' && <label>Captain team<select value={memberForm.teamId} onChange={e=>setMemberForm(f=>({...f,teamId:e.target.value}))}><option value="">Choose team</option>{teamOptions.map(team=><option key={team.id} value={team.id}>{team.label}</option>)}</select></label>}<button className="primary big" disabled={busy || !memberForm.email} onClick={addMember}>Assign Existing Account</button></div></section>
      <section className="panel-card"><h2>Event access</h2><p>Removing a role only removes access for this event. It does not delete the account or fighter history.</p><div className="membership-list">{memberships.length === 0 ? <div className="state-card">No managed event roles are visible yet.</div> : memberships.map(member=><article key={member.id}><div><strong>{member.displayName}</strong><small>{member.role.replaceAll('_',' ')}{member.teamId ? ` ┬╖ team ${member.teamId.slice(0,8)}` : ''}</small></div><button disabled={busy} onClick={()=>removeMember(member.id)}>Remove</button></article>)}</div></section>
    </div>
    {message && <div className="auth-message">{message}</div>}
  </>;
}
