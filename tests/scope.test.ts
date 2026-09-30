import { describe, expect, it } from 'vitest';
import { scopedSections } from '../src/components/AdminShell';
import { adminSections } from '../src/lib/navigation';
import {
  eventParamFromHash, filterWorkableEvents, isEventScopedPath, recallEvent, rememberEvent, withEventParam, type SelectableEvent
} from '../src/lib/eventScope';
import { recallOrganization, rememberOrganization, resolveOrganizationChoice, selectableOrganizationIds } from '../src/lib/organizationScope';
import type { UserContext } from '../src/types';

const user = (over: Partial<UserContext> = {}): UserContext => ({
  userId: 'u', displayName: 'U', hasPlatformAccess: true, platformRoles: [], organizationRoles: [], eventRoles: [], clubRoles: [], teamRoles: [], ...over
});

describe('event scope links', () => {
  it('adds the chosen event to event tasks and keeps other query parameters', () => {
    expect(withEventParam('/admin/events/roster', 'e1')).toBe('/admin/events/roster?event=e1');
    expect(withEventParam('/admin/events/signups?tab=codes', 'e1')).toBe('/admin/events/signups?tab=codes&event=e1');
    expect(withEventParam('/admin/events/roster?event=old', 'e2')).toBe('/admin/events/roster?event=e2');
    expect(withEventParam('/admin/events/roster', undefined)).toBe('/admin/events/roster');
  });

  it('reads the event from a hash route', () => {
    expect(eventParamFromHash('#/admin/events/run?event=abc')).toBe('abc');
    expect(eventParamFromHash('#/admin/events/run')).toBe('');
  });

  it('recognizes which admin pages act on one event', () => {
    for (const path of ['/admin/events/roster', '/admin/events/bracket', '/admin/events/run', '/admin/events/results', '/admin/events/manage', '/admin/events/signups']) {
      expect(isEventScopedPath(path)).toBe(true);
    }
    for (const path of ['/admin/events/setup', '/admin/events/all', '/admin/teams', '/admin/organizations/manage', '/me/teams']) {
      expect(isEventScopedPath(path)).toBe(false);
    }
  });

  it('qualifies every event task in the menu, and nothing else', () => {
    const sections = scopedSections(adminSections, 'e9');
    const items = sections.flatMap(section => section.items);
    for (const item of items) {
      if (isEventScopedPath(item.to.split('?')[0])) expect(item.to, item.id).toContain('event=e9');
      else expect(item.to, item.id).not.toContain('event=');
    }
    expect(scopedSections(adminSections, undefined).flatMap(s => s.items).every(item => !item.to.includes('event='))).toBe(true);
  });

  it('remembers an explicit choice for the session', () => {
    const memory = new Map<string, string>();
    const storage = { getItem: (k: string) => memory.get(k) ?? null, setItem: (k: string, v: string) => void memory.set(k, v), removeItem: (k: string) => void memory.delete(k) };
    expect(recallEvent(storage)).toBe('');
    rememberEvent('e5', storage);
    expect(recallEvent(storage)).toBe('e5');
    rememberEvent('', storage);
    expect(recallEvent(storage)).toBe('');
  });
});

describe('which events a person may pick', () => {
  const events: SelectableEvent[] = [
    { id: 'a', name: 'A', startsAt: '2026-01-01', status: 'published', organizationId: 'o1' },
    { id: 'b', name: 'B', startsAt: '2026-02-01', status: 'published', organizationId: 'o2' },
    { id: 'c', name: 'C', startsAt: '2026-03-01', status: 'draft', organizationId: 'o2' }
  ];
  it('gives the owner every event', () => {
    expect(filterWorkableEvents(user({ platformRoles: ['platform_super_admin'] }), events).length).toBe(3);
  });
  it('limits an organization admin to their organizations', () => {
    const rows = filterWorkableEvents(user({ organizationRoles: [{ organizationId: 'o2', role: 'organization_admin' }] }), events);
    expect(rows.map(r => r.id)).toEqual(['b', 'c']);
  });
  it('limits an organizer or marshal to events they hold a role in', () => {
    expect(filterWorkableEvents(user({ eventRoles: [{ eventId: 'a', role: 'field_marshal' }] }), events).map(r => r.id)).toEqual(['a']);
  });
  it('gives an ordinary user and an anonymous visitor nothing', () => {
    expect(filterWorkableEvents(user(), events)).toEqual([]);
    expect(filterWorkableEvents(null, events)).toEqual([]);
  });
});

describe('which organizations a person may work on', () => {
  it('gives the owner all, others only their own', () => {
    expect(selectableOrganizationIds(user({ platformRoles: ['platform_super_admin'] }))).toBe('all');
    expect(selectableOrganizationIds(user({ organizationRoles: [{ organizationId: 'o1', role: 'organization_admin' }] }))).toEqual(['o1']);
    expect(selectableOrganizationIds(user())).toEqual([]);
    expect(selectableOrganizationIds(null)).toEqual([]);
  });
  it('includes the organization of a team or club the person manages, but not one they only belong to', () => {
    const captain = user({ teamRoles: [{ teamId: 't1', role: 'captain' }, { teamId: 't2', role: 'fighter' }] });
    expect(selectableOrganizationIds(captain, { t1: 'o7', t2: 'o8' })).toEqual(['o7']);
    const clubAdmin = user({ clubRoles: [{ clubId: 'c1', role: 'club_admin' }] });
    expect(selectableOrganizationIds(clubAdmin, {}, { c1: 'o9' })).toEqual(['o9']);
  });
  it('never works without an event: the choice comes from the list, not the event', () => {
    const orgs = [{ id: 'o1', name: 'One' }, { id: 'o2', name: 'Two' }];
    expect(resolveOrganizationChoice(orgs, 'o2', '', '')).toBe('o2');
    expect(resolveOrganizationChoice(orgs, 'nope', 'o2', '')).toBe('o2');
    expect(resolveOrganizationChoice(orgs, '', '', 'o1')).toBe('o1');
    expect(resolveOrganizationChoice(orgs, 'forbidden', '', '')).toBe('o1');
    expect(resolveOrganizationChoice([], 'o1', 'o1', 'o1')).toBe('');
  });
  it('remembers the selection for the session', () => {
    const memory = new Map<string, string>();
    const storage = { getItem: (k: string) => memory.get(k) ?? null, setItem: (k: string, v: string) => void memory.set(k, v), removeItem: (k: string) => void memory.delete(k) };
    rememberOrganization('o3', storage);
    expect(recallOrganization(storage)).toBe('o3');
  });
});
