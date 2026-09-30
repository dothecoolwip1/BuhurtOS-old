import { useEffect, useRef } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { useAccount } from '../features/Account';
import { hasPermission } from '../lib/permissions';
import { accessFromUser, scopeForPath, visibleAdminSections, type NavItem } from '../lib/navigation';
import { AppShell, ScopeBar, type BottomItem } from './chrome';

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

/** Administration: everything a person may manage, grouped by task, with the scope always stated. */
export function AdminShell() {
  const location = useLocation();
  const { event, online, pendingCount, dataMode, syncNow } = useAppState();
  const { sections } = useAdminAccess();
  const visibleItems = sections.flatMap(section => section.items);
  const stepsRef = useRef<HTMLElement>(null);
  useEffect(() => { stepsRef.current?.querySelector<HTMLElement>('.active')?.scrollIntoView({ inline: 'center', block: 'nearest' }); }, [location.pathname]);

  const firstOf = (sectionId: string): NavItem | undefined => sections.find(section => section.id === sectionId)?.items[0];
  const bottom: BottomItem[] = [{ to: '/admin', label: 'Overview', icon: '⌂', end: true }];
  const events = firstOf('events');
  if (events) bottom.push({ to: events.to, label: 'Events', icon: '⚔' });
  const people = firstOf('people') ?? firstOf('organizations');
  if (people) bottom.push({ to: people.to, label: 'People', icon: '☺' });

  const scope = scopeForPath(location.pathname);
  let scopeBar = null;
  if (scope === 'event') {
    scopeBar = event
      ? <ScopeBar kind="Event" label={event.name} detail={[event.venue, dataMode === 'demo' ? 'Demo data' : undefined].filter(Boolean).join(' · ')} />
      : <ScopeBar kind="Event" label="No event selected" detail="Create or publish an event first." tone="warn" />;
  } else if (scope === 'organization') {
    scopeBar = <ScopeBar kind="Organization" label="Organization level" detail="Changes here apply to the organization you choose on this page." />;
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

  return <AppShell area="admin" brandSub="Administration" sections={sections} bottom={bottom} status={status} header={header} />;
}
