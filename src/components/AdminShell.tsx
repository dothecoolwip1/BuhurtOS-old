import { useEffect, useRef, useState, type ReactNode } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { useAccount } from '../features/Account';
import { hasPermission } from '../lib/permissions';
import { isEventScopedPath, listWorkableEvents, recallEvent, rememberEvent, withEventParam, type SelectableEvent } from '../lib/eventScope';
import { useAccount as useAcct } from '../features/Account';
import { primaryTasks } from '../lib/journeys';
import { accessFromUser, scopeForPath, visibleAdminSections, type NavItem, type NavSection } from '../lib/navigation';
import { AppShell, ScopeBar, type BottomItem } from './chrome';
import { StateBlock } from './page';

const EVENT_STEPS = ['event-settings', 'event-signups', 'event-roster', 'event-bracket', 'event-run', 'event-results'];

/** What this person may see in administration right now (depends on the current event too). */
export function useAdminAccess() {
  const { event } = useAppState();
  const { user } = useAccount();
  const can = (permission: Parameters<typeof hasPermission>[1]) => Boolean(event && hasPermission(user, permission, event.id, event.organizationId));
  const access = accessFromUser(user, {
    eventManage: can('event.manage'), bracketManage: can('bracket.manage'), discipline: can('discipline.manage'), notes: can('notes.team'),
    any: can('event.view_private') || can('roster.manage') || can('match.manage')
  });
  return { access, sections: visibleAdminSections(access) };
}

/** Event-task links carry the chosen event so switching tasks never changes which event you are working on. */
export function scopedSections(sections: NavSection[], eventId: string | undefined): NavSection[] {
  return sections.map(section => ({
    ...section,
    items: section.items.map(item => isEventScopedPath(item.to) ? { ...item, to: withEventParam(item.to, eventId) } : item)
  }));
}

function eventLabel(event: SelectableEvent): string {
  const date = new Date(event.startsAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
  return `${event.name} · ${date}`;
}

/** The event scope line with an explicit, permission-filtered event picker. */
function EventScope() {
  const { event, error, scopeLoading } = useAppState();
  const { user } = useAccount();
  const navigate = useNavigate();
  const location = useLocation();
  const [choices, setChoices] = useState<SelectableEvent[]>();
  const [choicesError, setChoicesError] = useState('');
  const generation = useRef(0);

  useEffect(() => {
    if (!user) return;
    const mine = ++generation.current;
    setChoicesError('');
    listWorkableEvents(user).then(rows => { if (mine === generation.current) setChoices(rows); })
      .catch(err => { if (mine === generation.current) setChoicesError(err instanceof Error ? err.message : 'Events could not be listed.'); });
  }, [user]);

  const choose = (id: string) => {
    rememberEvent(id);
    navigate(withEventParam(location.pathname, id));
  };

  const currentId = event?.id ?? recallEvent();
  const detail = scopeLoading ? 'Loading this event…' : event ? event.venue : error ? `Could not open the chosen event: ${error}` : 'No event selected';
  return <div className={'nx-scope' + (error && !event ? ' warn' : '')} role="note">
    <span className="nx-scope-kind">Event</span>
    <strong>{event ? event.name : 'Choose an event'}</strong>
    <small>{detail}</small>
    {choices && choices.length > 0 ? <label className="nx-scope-pick">Switch event
      <select value={choices.some(row => row.id === currentId) ? currentId : ''} onChange={e => choose(e.target.value)}>
        {!choices.some(row => row.id === currentId) ? <option value="" disabled>Choose an event…</option> : null}
        {choices.map(row => <option key={row.id} value={row.id}>{eventLabel(row)}</option>)}
      </select>
    </label> : null}
    {choicesError ? <small role="alert">The event list could not be loaded: {choicesError}</small> : null}
  </div>;
}

/** Administration: everything a person may manage, grouped by task, with the scope always stated. */
export function AdminShell() {
  const location = useLocation();
  const { event, online, pendingCount, dataMode, syncNow, error, scopeLoading } = useAppState();
  const { sections } = useAdminAccess();
  const eventId = event?.id ?? (recallEvent() || undefined);
  const { user: adminUser } = useAcct();
  const startTasks = primaryTasks(adminUser).filter(task => task.to.startsWith('/admin') && task.to !== '/admin');
  const startHere: NavSection[] = startTasks.length ? [{ id: 'start-here', label: 'Start here', blurb: 'The jobs you do most, first.', items: startTasks.map(task => ({ id: 'start-' + task.id, label: task.label, to: task.to, description: task.text, gate: 'member' as const })) }] : [];
  const scoped = [...startHere, ...scopedSections(sections, eventId)];
  const visibleItems = scoped.flatMap(section => section.items);
  const stepsRef = useRef<HTMLElement>(null);
  useEffect(() => { stepsRef.current?.querySelector<HTMLElement>('.active')?.scrollIntoView({ inline: 'center', block: 'nearest' }); }, [location.pathname]);

  const firstOf = (sectionId: string): NavItem | undefined => scoped.find(section => section.id === sectionId)?.items[0];
  const bottom: BottomItem[] = [{ to: '/admin', label: 'Overview', icon: '⌂', end: true }];
  const events = firstOf('events');
  if (events) bottom.push({ to: events.to, label: 'Events', icon: '⚔' });
  const people = firstOf('people') ?? firstOf('organizations');
  if (people) bottom.push({ to: people.to, label: 'People', icon: '☺' });

  const scope = scopeForPath(location.pathname);
  let scopeBar = null;
  if (scope === 'event') {
    scopeBar = <EventScope />;
  } else if (scope === 'organization') {
    scopeBar = <ScopeBar kind="Organization" label="Organization level" detail="Changes here apply to the organization chosen on this page." />;
  } else if (scope === 'platform') {
    scopeBar = <ScopeBar kind="Platform" label="Whole platform" detail="Changes here affect every organization and person." tone="warn" />;
  }

  const steps = location.pathname.startsWith('/admin/events/') && scope === 'event'
    ? EVENT_STEPS.map(id => visibleItems.find(item => item.id === id)).filter((item): item is NavItem => Boolean(item))
    : [];

  const header = <>
    {scopeBar}
    {steps.length > 1 ? <nav ref={stepsRef} className="nx-steps" aria-label="Event workflow"><ol>
      {steps.map((item, index) => <li key={item.id}><NavLink to={item.to} className={({ isActive }) => 'nx-step' + (isActive ? ' active' : '')}><span className="nx-step-num" aria-hidden="true">{index + 1}</span>{item.label}</NavLink></li>)}
    </ol></nav> : null}
  </>;

  const status = <div className="nx-status">
    <span className={'nx-chip ' + (online ? 'ok' : 'warn')}>{online ? 'Online' : 'Offline'}</span>
    {dataMode === 'demo' ? <span className="nx-chip">Demo data</span> : null}
    {pendingCount > 0 ? <button type="button" className="nx-chip action" onClick={syncNow}>{pendingCount} waiting to sync</button> : null}
  </div>;

  // Event tools never render against a missing or previous event.
  let blocked: ReactNode;
  if (isEventScopedPath(location.pathname)) {
    if (scopeLoading) blocked = <StateBlock kind="loading" title="Loading this event…" />;
    else if (!event && error) blocked = <StateBlock kind="error" title="That event could not be opened">{error} It may not exist, or your account may not have access to it. Choose another event above.</StateBlock>;
    else if (!event) blocked = <StateBlock kind="empty" title="There is no event to work on yet">Create one under Seasons &amp; new events, or choose an event above.</StateBlock>;
  }

  return <AppShell area="admin" brandSub="Administration" sections={scoped} bottom={bottom} status={status} header={header} blocked={blocked} />;
}
