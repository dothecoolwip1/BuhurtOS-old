import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Card, PageTitle, StateBlock } from '../components/page';
import { useAppState } from '../features/AppState';
import { buildEventChecklist, loadEventSetupFacts, ownerDecisions, type DecisionKind, type OwnerDecision, type ChecklistItem, type ChecklistResult, type ChecklistStatus } from '../lib/eventChecklist';
import { isCompetitionCapable } from '../lib/eventCategories';
import { friendlyError } from '../lib/friendlyError';
import { isSupabaseConfigured } from '../lib/supabase';

const statusText: Record<ChecklistStatus, string> = { complete: 'Done', missing: 'To do', warning: 'Check this', unknown: 'Could not check' };
const decisionText: Record<DecisionKind, string> = { owner_decision: 'Owner decision', optional: 'Optional', external_approval: 'Outside approval' };
const statusMark: Record<ChecklistStatus, string> = { complete: '✓', missing: '○', warning: '!', unknown: '?' };

/**
 * One guided place to finish setting up any event, new or existing. Progress comes from what is actually saved,
 * so an event created last month shows its true state the first time it is opened here.
 */
export function EventGuidePage() {
  const { event } = useAppState();
  const [result, setResult] = useState<ChecklistResult>();
  const [decisions, setDecisions] = useState<OwnerDecision[]>([]);
  const [error, setError] = useState('');
  const eventId = event?.id;

  const load = useCallback(() => {
    if (!eventId) return;
    setError(''); setResult(undefined); setDecisions([]);
    loadEventSetupFacts(eventId).then(facts => { setResult(buildEventChecklist(facts)); setDecisions(ownerDecisions(facts)); }).catch(err => setError(friendlyError(err).message));
  }, [eventId]);
  useEffect(load, [load]);

  if (!event) return <StateBlock kind="empty" title="Choose an event first">Pick an event from the event picker above, or <Link to="/admin/events/setup">create one</Link>.</StateBlock>;

  if (!isSupabaseConfigured) return <>
    <PageTitle title={`Set up ${event.name}`} lead="Everything an event needs, in order." />
    <StateBlock kind="empty" title="The setup guide needs a connected backend">Demo mode only has sample data, so there is no saved setup to read. Connect a BuhurtOS project to see real progress.</StateBlock>
  </>;
  const competition = isCompetitionCapable(event.eventType);
  const percent = result ? Math.round((result.completed / Math.max(result.total, 1)) * 100) : 0;

  return <>
    <PageTitle title={`Set up ${event.name}`} lead="Everything an event needs, in order. Each step says what is done, what is missing and what to do next."
      actions={result?.next ? <Link className="nx-btn primary" to={result.next.action.to}>Continue setup: {result.next.label}</Link> : undefined} />
    {error ? <StateBlock kind="error" title="Setup progress could not be loaded">{error} <button type="button" className="nx-btn" onClick={load}>Try again</button></StateBlock>
      : !result ? <StateBlock kind="loading" title="Checking what is set up…" />
      : <>
        <Card>
          <div className="nx-progress" role="group" aria-label="Setup progress">
            <strong>{result.completed} of {result.total} steps complete</strong>
            <div className="nx-progress-bar" aria-hidden="true"><i style={{ width: percent + '%' }} /></div>
          </div>
          {!competition ? <p className="hint">This is not a tournament, so competition, division, schedule and marshal steps are skipped.</p> : null}
          {result.next ? null : <p><strong>Everything is set up.</strong> Review the public page, then publish when you are ready.</p>}
        </Card>
        <Card>
          <ol className="nx-steps">{result.items.map((item, index) => <Step key={item.id} item={item} index={index + 1} />)}</ol>
        </Card>
        {decisions.length ? <Card>
          <h2>Decisions for the owner</h2>
          <p className="hint">These are not forgotten tasks. They are choices only you can make, or approvals from outside BuhurtOS. Nothing here is changed for you.</p>
          <ul className="nx-steps">{decisions.map(d => <li key={d.id} className="nx-step warning">
            <span className="nx-step-mark" aria-hidden="true">{d.kind === 'external_approval' ? '↗' : d.kind === 'optional' ? '+' : '?'}</span>
            <div className="nx-step-body">
              <strong>{d.title} <small>({decisionText[d.kind]})</small></strong>
              <p>{d.now}</p>
              <p><em>If you leave it:</em> {d.consequence}</p>
            </div>
            <Link className="nx-btn" to={d.action.to}>{d.action.label}</Link>
          </li>)}</ul>
        </Card> : null}
        <p className="hint">Publishing and approval: BuhurtOS does not sanction events. If a federation or national organization approves a tournament, record that on the competition; it is a record, not a grant.</p>
      </>}
  </>;
}

function Step({ item, index }: { item: ChecklistItem; index: number }) {
  return <li className={'nx-step ' + item.status}>
    <span className="nx-step-mark" aria-hidden="true">{statusMark[item.status]}</span>
    <div className="nx-step-body">
      <strong>{index}. {item.label} <small>({statusText[item.status]})</small></strong>
      <p>{item.detail}</p>
    </div>
    <Link className={'nx-btn' + (item.status === 'complete' ? '' : ' primary')} to={item.action.to}>{item.action.label}</Link>
  </li>;
}
