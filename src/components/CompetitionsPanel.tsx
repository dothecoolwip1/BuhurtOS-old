import { useCallback, useEffect, useMemo, useState } from 'react';
import { deleteEventCompetition, describeCompetition, listEventCompetitions, saveEventCompetition, type EventCompetition, type EventCompetitionInput } from '../lib/eventCompetitions';
import { friendlyError } from '../lib/friendlyError';
import {
  adviseStructure, buildFormatSelection, classificationLabels, describeStructure, leadTimeAdvice, leagueLabels, loadCompetitionReferenceData,
  overrideProblem, tierClassificationLabels, tierLabels, type ReferenceData
} from '../lib/tournamentStructure';

const empty: EventCompetitionInput = { name: '', league: 'buhurt', tier: undefined, classification: undefined, ranked: false, authority: 'bi', rulesVersion: 'v2026.1' };

/**
 * The tournaments inside one event. An event is not a tournament: a single BI event can hold, for example,
 * a Men's 5v5 Classic, a Women's 5v5 Source and a Longsword duel, each with its own tier, entrants and format.
 */
export function CompetitionsPanel({ eventId, startsAt }: { eventId: string; startsAt?: string }) {
  const [items, setItems] = useState<EventCompetition[]>();
  const [reference, setReference] = useState<ReferenceData>();
  const [loadError, setLoadError] = useState('');
  const [editing, setEditing] = useState<{ id: string | null; draft: EventCompetitionInput }>();
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  const load = useCallback(() => {
    setLoadError('');
    Promise.all([listEventCompetitions(eventId, true), loadCompetitionReferenceData()])
      .then(([rows, ref]) => { setItems(rows); setReference(ref); })
      .catch(error => { setLoadError(friendlyError(error).message); setItems([]); });
  }, [eventId]);
  useEffect(() => { setItems(undefined); setEditing(undefined); load(); }, [load]);

  const categoryName = (id?: string) => reference?.categories.find(c => c.id === id)?.displayName;

  const save = async () => {
    if (!editing) return;
    setBusy(true); setMessage('');
    try {
      await saveEventCompetition(eventId, editing.id, editing.draft);
      setEditing(undefined); setMessage('Competition saved.'); load();
    } catch (error) { setMessage(friendlyError(error).message); }
    finally { setBusy(false); }
  };
  const remove = async (competition: EventCompetition) => {
    if (!window.confirm(`Delete "${competition.name}"? This cannot be undone.`)) return;
    setBusy(true); setMessage('');
    try { await deleteEventCompetition(competition.id); setMessage('Competition deleted.'); load(); }
    catch (error) { setMessage(friendlyError(error).message); }
    finally { setBusy(false); }
  };

  return <section className="panel-card" aria-labelledby="competitions-title">
    <h2 id="competitions-title">Competitions</h2>
    <p>A competition is one tournament inside this event, for example “Men’s 5v5 Classic”. One event can have several, each with its own tier, category, entrants and format.</p>
    {loadError ? <div className="state-card" role="alert"><strong>Competitions could not be loaded</strong><p>{loadError}</p><button type="button" onClick={load}>Try again</button></div> : null}
    {message ? <div className="auth-message" role="status">{message}</div> : null}
    {items === undefined ? <div className="state-card" role="status">Loading competitions…</div>
      : items.length === 0 && !editing ? <div className="state-card"><strong>No competitions have been added yet.</strong><p>Add a competition for each tournament you will run. Fighters register into competitions, and formats and brackets are built from them.</p><button className="primary" type="button" onClick={() => setEditing({ id: null, draft: { ...empty } })}>Add competition</button></div>
      : <div className="membership-list">{items.map(c => <article key={c.id}>
        <div className="grow"><strong>{c.name}</strong><small>{describeCompetition(c, categoryName(c.categoryId))}{c.entrantCap ? ` · up to ${c.entrantCap} entrants` : ''}</small>
          {c.formatSelection.optionKey ? <small>Structure chosen for {c.formatSelection.entrantCount} entrants ({c.formatSelection.rulesVersion}){c.formatSelection.override ? ' · organizer override' : ''}</small> : <small>No structure chosen yet.</small>}
          {c.externalApproval.approvedBy ? <small>Approval recorded from {c.externalApproval.approvedBy}{c.externalApproval.date ? ' on ' + c.externalApproval.date : ''}. Recorded only; BuhurtOS did not grant it.</small> : null}</div>
        <div className="header-actions"><button type="button" disabled={busy} onClick={() => setEditing({ id: c.id, draft: { ...c } })}>Edit</button><button type="button" disabled={busy} onClick={() => void remove(c)}>Delete</button></div>
      </article>)}</div>}
    {items && items.length > 0 && !editing ? <button className="primary" type="button" onClick={() => setEditing({ id: null, draft: { ...empty } })}>Add another competition</button> : null}
    {editing && reference ? <CompetitionForm reference={reference} startsAt={startsAt} value={editing.draft} isNew={editing.id === null} busy={busy}
      onChange={draft => setEditing({ id: editing.id, draft })} onSave={() => void save()} onCancel={() => setEditing(undefined)} /> : null}
  </section>;
}

function CompetitionForm({ reference, startsAt, value, isNew, busy, onChange, onSave, onCancel }: {
  reference: ReferenceData; startsAt?: string; value: EventCompetitionInput; isNew: boolean; busy: boolean;
  onChange: (v: EventCompetitionInput) => void; onSave: () => void; onCancel: () => void;
}) {
  const set = (patch: EventCompetitionInput) => onChange({ ...value, ...patch });
  const categories = reference.categories.filter(c => c.league === value.league);
  const tierRule = reference.tiers.find(t => t.tier === value.tier);
  const lead = useMemo(() => leadTimeAdvice(tierRule, startsAt), [tierRule, startsAt]);
  const isBi = (value.authority ?? 'bi') === 'bi';
  const [entrants, setEntrants] = useState(String(value.formatSelection?.entrantCount ?? ''));
  const [overrideReason, setOverrideReason] = useState(value.formatSelection?.overrideReason ?? '');
  const count = Number(entrants);
  const advice = useMemo(() => adviseStructure(isBi ? reference.templates.filter(t => t.authority === 'bi') : [], count), [reference, count, isBi]);
  const selected = advice.options.find(o => o.optionKey === value.formatSelection?.optionKey);
  const nameProblem = (value.name ?? '').trim().length < 2 ? 'Give the competition a name, for example “Men’s 5v5 Classic”.' : undefined;

  const choose = (optionKey: string) => {
    const option = advice.options.find(o => o.optionKey === optionKey);
    const selection = buildFormatSelection({ rulesVersion: advice.options[0]?.docVersion ?? 'Jan 2026', entrantCount: count, option, advice, overrideReason });
    set({ formatSelection: selection });
  };
  const selectionProblem = value.formatSelection?.optionKey && value.formatSelection.override && !value.formatSelection.overrideReason ? overrideProblem(value.formatSelection as never) : undefined;

  return <div className="form-stack" role="group" aria-label={isNew ? 'New competition' : 'Edit competition'}>
    <h3>{isNew ? 'New competition' : 'Edit competition'}</h3>
    <label>Name<input value={value.name ?? ''} onChange={e => set({ name: e.target.value })} placeholder="Men’s 5v5 Classic" /></label>
    <label>League<select value={value.league} onChange={e => set({ league: e.target.value as never, categoryId: undefined })}>{Object.entries(leagueLabels).map(([k, label]) => <option key={k} value={k}>{label}</option>)}</select></label>
    <label>Category<select value={value.categoryId ?? ''} onChange={e => set({ categoryId: e.target.value || undefined })}><option value="">Not chosen yet</option>{categories.map(c => <option key={c.id} value={c.id}>{c.displayName}</option>)}</select></label>
    <label>Who can enter<select value={value.classification ?? ''} onChange={e => set({ classification: (e.target.value || undefined) as never })}><option value="">Not chosen yet</option>{Object.entries(classificationLabels).map(([k, label]) => <option key={k} value={k}>{label}</option>)}</select></label>
    <label>Tier<select value={value.tier ?? ''} onChange={e => set({ tier: (e.target.value || undefined) as never, tierClassification: undefined })}><option value="">Not chosen yet</option>{Object.entries(tierLabels).map(([k, label]) => <option key={k} value={k}>{label}</option>)}</select></label>
    {value.tier === 'classic' ? <label>Classic type<select value={value.tierClassification ?? ''} onChange={e => set({ tierClassification: (e.target.value || undefined) as never })}><option value="">Not chosen yet</option>{Object.entries(tierClassificationLabels).map(([k, label]) => <option key={k} value={k}>{label}</option>)}</select></label> : null}
    {value.tier && value.tier !== 'custom' ? <div className={lead.status === 'late' ? 'state-card' : 'hint'} role={lead.status === 'late' ? 'alert' : 'status'}>{lead.message}{lead.status === 'late' ? null : ' Approval happens outside BuhurtOS.'}</div> : null}
    <label className="fighter-signup-consent"><input type="checkbox" checked={Boolean(value.ranked)} onChange={e => set({ ranked: e.target.checked })} /><span>Ranked (counts toward league standings)</span></label>
    <p className="hint">BI allows only one of the same category to be ranked at a single event (League Structure v2026.1 §3.3.4).</p>
    <label>Entrant cap (optional)<input inputMode="numeric" value={value.entrantCap ?? ''} onChange={e => set({ entrantCap: e.target.value ? Number(e.target.value) || undefined : undefined })} /></label>

    <fieldset>
      <legend>Structure</legend>
      <label>How many teams or competitors are entered?<input inputMode="numeric" value={entrants} onChange={e => setEntrants(e.target.value)} /></label>
      {count >= 1 ? <>
        <p className="hint">{advice.options.length ? `Based on BI Tournament Structure (${advice.options[0].docVersion}), these structures fit ${count} entrants:` : advice.note}</p>
        {advice.options.length && advice.note ? <p className="hint">{advice.note}</p> : null}
        {advice.options.map(o => <label key={o.optionKey} className="fighter-signup-consent"><input type="radio" name="structure" checked={selected?.optionKey === o.optionKey} onChange={() => choose(o.optionKey)} />
          <span><b>{o.title}</b>{o.recommended ? '' : ' (not recommended)'}<br /><small>{describeStructure(o)} {o.caution ? o.caution + '. ' : ''}Source: {o.sourceRef}.</small></span></label>)}
        {value.formatSelection?.override ? <label>Why are you choosing this? <input value={overrideReason} onChange={e => { setOverrideReason(e.target.value); set({ formatSelection: { ...value.formatSelection, overrideReason: e.target.value } }); }} placeholder="For example: limited field time" /></label> : null}
        {selectionProblem ? <p className="auth-message" role="alert">{selectionProblem}</p> : null}
      </> : <p className="hint">Enter the entrant count to see the structures the rules allow.</p>}
    </fieldset>

    <fieldset>
      <legend>Approval from outside BuhurtOS (optional)</legend>
      <p className="hint">If a federation or national organization approved this tournament, record it here. BuhurtOS does not grant or imply sanction.</p>
      <label>Approved by<input value={value.externalApproval?.approvedBy ?? ''} onChange={e => set({ externalApproval: { ...value.externalApproval, approvedBy: e.target.value } })} /></label>
      <label>Date<input type="date" value={value.externalApproval?.date ?? ''} onChange={e => set({ externalApproval: { ...value.externalApproval, date: e.target.value } })} /></label>
      <label>Reference or link<input value={value.externalApproval?.reference ?? ''} onChange={e => set({ externalApproval: { ...value.externalApproval, reference: e.target.value } })} /></label>
    </fieldset>

    {nameProblem ? <p className="hint">{nameProblem}</p> : null}
    <div className="header-actions"><button className="primary" type="button" disabled={busy || Boolean(nameProblem) || Boolean(selectionProblem)} onClick={onSave}>{busy ? 'Saving…' : 'Save competition'}</button><button type="button" onClick={onCancel}>Cancel</button></div>
  </div>;
}
