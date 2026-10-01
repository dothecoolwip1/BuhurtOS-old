import { useEffect, useRef, useState } from 'react';
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { useAccount } from '../features/Account';
import { buildEventChecklist, loadEventSetupFacts, type ChecklistResult, type EventSetupFacts } from '../lib/eventChecklist';
import { listWorkableEvents, recallEvent, rememberEvent, withEventParam, type SelectableEvent } from '../lib/eventScope';
import { friendlyError } from '../lib/friendlyError';
import { isSupabaseConfigured } from '../lib/supabase';
import type { NavItem } from '../lib/navigation';

/** Plain labels for the event's stage. */
const statusLabel: Record<string, string> = { draft: 'Draft, not public', published: 'Public', live: 'Happening now', completed: 'Finished', cancelled: 'Cancelled', archived: 'Archived' };

function dateLabel(iso: string | undefined): string {
  if (!iso) return 'Date not set';
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
}

/** Event tabs, in the order an organizer works, with the labels an organizer would use. Anything else goes under "More". */
const TAB_LABELS: Record<string, string> = {
  'event-guide': 'Overview', 'event-settings': 'Details', 'event-signups': 'Registration', 'event-roster': 'Roster',
  'event-bracket': 'Schedule', 'event-run': 'Run fights', 'event-results': 'Results'
};
const TAB_ORDER = Object.keys(TAB_LABELS);

/**
 * One persistent header for everything about one event: which event, when, whether it is public, how far setup has got,
 * the next thing to do, and the tabs that move between event tools without ever leaving the event.
 */
export function EventHeader({ items }: { items: NavItem[] }) {
  const { event, error, scopeLoading } = useAppState();
  const { user } = useAccount();
  const navigate = useNavigate();
  const location = useLocation();
  const [facts, setFacts] = useState<EventSetupFacts>();
  const [progress, setProgress] = useState<ChecklistResult>();
  const [progressFailed, setProgressFailed] = useState(false);
  const [choices, setChoices] = useState<SelectableEvent[]>();
  const [choicesError, setChoicesError] = useState('');
  const generation = useRef(0);
  const tabs = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!user) return;
    const mine = ++generation.current;
    setChoicesError('');
    listWorkableEvents(user).then(rows => { if (mine === generation.current) setChoices(rows); })
      .catch(err => { if (mine === generation.current) setChoicesError(friendlyError(err).message); });
  }, [user]);

  const eventId = event?.id;
  useEffect(() => {
    if (!eventId || !isSupabaseConfigured) { setFacts(undefined); setProgress(undefined); return; }
    let live = true;
    setProgressFailed(false);
    loadEventSetupFacts(eventId).then(f => { if (live) { setFacts(f); setProgress(buildEventChecklist(f)); } }).catch(() => { if (live) setProgressFailed(true); });
    return () => { live = false; };
  }, [eventId, location.pathname]);

  useEffect(() => { tabs.current?.querySelector<HTMLElement>('.active')?.scrollIntoView({ inline: 'center', block: 'nearest' }); }, [location.pathname]);

  const byId = new Map(items.map(item => [item.id, item]));
  const main = TAB_ORDER.map(id => byId.get(id)).filter((item): item is NavItem => Boolean(item));
  const more = items.filter(item => !TAB_LABELS[item.id]);
  const currentId = event?.id ?? recallEvent();
  const pick = (id: string) => { rememberEvent(id); navigate(withEventParam(location.pathname, id)); };

  if (!event) {
    return <div className={'nx-evhead' + (error ? ' warn' : '')} role="note">
      <strong>{scopeLoading ? 'Opening the event…' : error ? 'That event could not be opened' : 'Choose an event'}</strong>
      {choices && choices.length > 0 ? <EventPicker choices={choices} currentId={currentId} onPick={pick} /> : null}
    </div>;
  }

  const registration = facts ? (facts.registrationOpen ? 'Registration open' : 'Registration not open') : undefined;
  const next = progress?.next;
  return <>
    <div className="nx-evhead" role="region" aria-label={'Event: ' + event.name}>
      <div className="nx-evhead-main">
        <div className="nx-evhead-title">
          <h2>{event.name}</h2>
          <p>{dateLabel(event.startsAt)}{event.venue ? <span className="nx-evhead-venue"> · {event.venue}</span> : null}</p>
        </div>
        <details className="nx-evmenu"><summary aria-label="Event actions">⋯</summary><div>
          <Link to={`/events/${event.id}`}>View public page</Link>
          {choices && choices.length > 1 ? <EventPicker choices={choices} currentId={currentId} onPick={pick} compact /> : null}
        </div></details>
        <div className="nx-evhead-facts">
          <span className={'nx-pill ' + (event.status === 'published' || event.status === 'live' ? 'ok' : '')}>{statusLabel[event.status] ?? event.status}</span>
          {registration ? <span className="nx-pill">{registration}</span> : null}
          {progress ? <span className="nx-pill" title="Steps completed in the setup overview">Setup {progress.completed} of {progress.total}</span> : progressFailed ? <span className="nx-pill warn">Setup progress unavailable</span> : null}
        </div>
      </div>
      <div className="nx-evhead-actions">
        {next ? <Link className="nx-btn primary nx-evnext" to={withEventParam(next.action.to, event.id)}>Next: {next.action.label}</Link> : null}
        <Link className="nx-btn nx-desk-only" to={`/events/${event.id}`}>View public page</Link>
        {choices && choices.length > 1 ? <span className="nx-desk-only"><EventPicker choices={choices} currentId={currentId} onPick={pick} compact /></span> : null}
      </div>
      {choicesError ? <small role="alert">The event list could not be loaded: {choicesError}</small> : null}
    </div>
    {main.length > 0 ? <nav ref={tabs} className="nx-evtabs" aria-label={event.name + ' tools'}>
      {main.map(item => <NavLink key={item.id} to={item.to} className={({ isActive }) => 'nx-evtab' + (isActive ? ' active' : '')}>{TAB_LABELS[item.id]}</NavLink>)}
      {more.length ? <details className="nx-evmore"><summary>More</summary><div>{more.map(item => <NavLink key={item.id} to={item.to} className={({ isActive }) => 'nx-evtab' + (isActive ? ' active' : '')} title={item.description}>{item.label}</NavLink>)}</div></details> : null}
    </nav> : null}
  </>;
}

function EventPicker({ choices, currentId, onPick, compact }: { choices: SelectableEvent[]; currentId: string; onPick: (id: string) => void; compact?: boolean }) {
  return <label className={'nx-scope-pick' + (compact ? ' compact' : '')}>{compact ? 'Change event' : 'Event'}
    <select value={choices.some(row => row.id === currentId) ? currentId : ''} onChange={e => onPick(e.target.value)}>
      {!choices.some(row => row.id === currentId) ? <option value="" disabled>Choose an event…</option> : null}
      {choices.map(row => <option key={row.id} value={row.id}>{row.name} · {dateLabel(row.startsAt)}</option>)}
    </select>
  </label>;
}
