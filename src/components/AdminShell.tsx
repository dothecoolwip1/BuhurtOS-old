import { type ReactNode } from 'react';
import { useLocation } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { useAccount } from '../features/Account';
import { hasPermission } from '../lib/permissions';
import { isEventScopedPath, recallEvent, withEventParam } from '../lib/eventScope';
import { useAccount as useAcct } from '../features/Account';
import { primaryTasks } from '../lib/journeys';
import { accessFromUser, scopeForPath, visibleAdminSections, type NavItem, type NavSection } from '../lib/navigation';
import { AppShell, ScopeBar, type BottomItem } from './chrome';
import { StateBlock } from './page';
import { EventHeader } from './EventHeader';

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

/** Administration: everything a person may manage, grouped by task, with the scope always stated. */
export function AdminShell() {
  const location = useLocation();
  const { event, online, pendingCount, dataMode, syncNow, error, scopeLoading } = useAppState();
  const { sections } = useAdminAccess();
  const eventId = event?.id ?? (recallEvent() || undefined);
  const { user: adminUser } = useAcct();
  const startTasks = primaryTasks(adminUser).filter(task => task.to.startsWith('/admin') && task.to !== '/admin');
  const startHere: NavSection[] = startTasks.length ? [{ id: 'start-here', label: 'Start here', blurb: 'The jobs you do most, first.', items: startTasks.map(task => ({ id: 'start-' + task.id, label: task.label, to: task.to, description: task.text, gate: 'member' as const })) }] : [];
  // A destination listed under "Start here" is not listed a second time below it, so one page never has two highlighted entries.
  const startPaths = new Set(startTasks.map(task => task.to.split('?')[0]));
  const rest = scopedSections(sections, eventId)
    .map(section => ({ ...section, items: section.items.filter(item => !startPaths.has(item.to.split('?')[0])) }))
    .filter(section => section.items.length > 0);
  const scoped = [...startHere, ...rest];
  const inEventNow = scopeForPath(location.pathname) === 'event' && location.pathname.startsWith('/admin/events/');
  // Inside an event the event's tools live in the event's own tabs, so the sidebar stops repeating them.
  const sidebar = inEventNow ? scoped.map(section => ({ ...section, items: section.items.filter(item => !isEventScopedPath(item.to)) })).filter(section => section.items.length > 0) : scoped;
  const visibleItems = scoped.flatMap(section => section.items);

  const firstOf = (sectionId: string): NavItem | undefined => scoped.find(section => section.id === sectionId)?.items[0];
  const bottom: BottomItem[] = [{ to: '/admin', label: 'Overview', icon: '⌂', end: true }];
  const events = firstOf('events');
  if (events) bottom.push({ to: events.to, label: 'Events', icon: '⚔' });
  const people = firstOf('people') ?? firstOf('organizations');
  if (people) bottom.push({ to: people.to, label: 'People', icon: '☺' });

  const scope = scopeForPath(location.pathname);
  let scopeBar = null;
  if (scope === 'event') {
    scopeBar = null;
  } else if (scope === 'organization') {
    scopeBar = <ScopeBar kind="Organization" label="Organization level" detail="Changes here apply to the organization chosen on this page." />;
  } else if (scope === 'platform') {
    scopeBar = <ScopeBar kind="Platform" label="Whole platform" detail="Changes here affect every organization and person." tone="warn" />;
  }

  const inEvent = scope === 'event' && location.pathname.startsWith('/admin/events/');
  const eventItems = inEvent ? scopedSections(sections, eventId).flatMap(section => section.items).filter(item => isEventScopedPath(item.to)) : [];
  const header = inEvent ? <EventHeader items={eventItems} /> : scopeBar;

  // On a phone, inside an event the bottom bar is the event's own: the four things done most, then Menu for the rest.
  const phoneTabs: Array<[string, string, string]> = [['event-guide', 'Overview', '◔'], ['event-signups', 'Signups', '✉'], ['event-roster', 'Roster', '☷'], ['event-run', 'Run', '⚔']];
  const eventBottom: BottomItem[] = phoneTabs
    .map(([id, label, icon]) => ({ item: eventItems.find(candidate => candidate.id === id), label, icon }))
    .filter((entry): entry is { item: NavItem; label: string; icon: string } => Boolean(entry.item))
    .map(entry => ({ to: entry.item.to, label: entry.label, icon: entry.icon }));
  const bottomItems = inEvent && eventBottom.length >= 3 ? eventBottom : bottom;
  // The rest of the event's tools are reachable from the phone menu, under "This event".
  const bottomPaths = new Set(eventBottom.map(item => item.to.split('?')[0]));
  const thisEvent: NavSection[] = inEvent ? [{ id: 'this-event', label: 'This event', blurb: '', items: eventItems.filter(item => !bottomPaths.has(item.to.split('?')[0])) }] : [];

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

  return <AppShell area="admin" brandSub="Administration" sections={[...sidebar, ...thisEvent]} bottom={bottomItems} status={status} header={header} blocked={blocked} />;
}
