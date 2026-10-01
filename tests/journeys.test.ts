import { describe, expect, it } from 'vitest';
import { personasOf, primaryTasks, tasksFor, workspaceBottomTabs } from '../src/lib/journeys';
import type { UserContext } from '../src/types';

const base: UserContext = { userId: 'u1', displayName: 'Test', hasPlatformAccess: true, platformRoles: [], organizationRoles: [], eventRoles: [] };
const EVENT = '6028e471-a95c-4d8a-8101-1f168bc68c8b';

describe('who someone is here to be', () => {
  it('a plain signed-in person is a fighter', () => {
    expect(personasOf(base)).toEqual(['fighter']);
  });
  it('nobody signed in has no persona', () => {
    expect(personasOf(null)).toEqual([]);
  });
  it('orders by responsibility and keeps fighter last', () => {
    const everything: UserContext = {
      ...base, platformRoles: ['platform_super_admin'], organizationRoles: [{ organizationId: 'o', role: 'organization_admin' }],
      eventRoles: [{ eventId: EVENT, role: 'event_organizer' }, { eventId: 'e2', role: 'field_marshal' }],
      teamRoles: [{ teamId: 't', role: 'captain' }]
    };
    expect(personasOf(everything)).toEqual(['platform_owner', 'org_admin', 'organizer', 'captain', 'marshal', 'fighter']);
  });
  it('an organization staff member without admin is not an organization admin', () => {
    expect(personasOf({ ...base, organizationRoles: [{ organizationId: 'o', role: 'organization_staff' }] })).toEqual(['fighter']);
  });
  it('a club admin counts as a team admin', () => {
    expect(personasOf({ ...base, clubRoles: [{ clubId: 'c', role: 'club_admin' }] })).toContain('captain');
  });
});

describe('what each person sees first', () => {
  it('a fighter leads with registering, their profile and notifications', () => {
    expect(primaryTasks(base).map(t => t.label)).toEqual(['Register for an event', 'My profile', 'My notifications']);
  });
  it('an organizer leads with setting up their event, carrying the event id', () => {
    const user: UserContext = { ...base, eventRoles: [{ eventId: EVENT, role: 'event_organizer' }] };
    const first = primaryTasks(user)[0];
    expect(first.label).toBe('Set up my event');
    expect(first.to).toBe(`/admin/events/guide?event=${EVENT}`);
  });
  it('a marshal leads with running their field', () => {
    const user: UserContext = { ...base, eventRoles: [{ eventId: 'e9', role: 'assistant_marshal' }] };
    expect(primaryTasks(user)[0]).toMatchObject({ label: 'Run my field', to: '/admin/events/run?event=e9' });
  });
  it('a platform owner leads with platform control', () => {
    expect(primaryTasks({ ...base, platformRoles: ['platform_super_admin'] })[0].to).toBe('/admin');
  });
  it('gives every role a slot, so a platform owner who also organizes still sees their event', () => {
    const user: UserContext = { ...base, platformRoles: ['platform_super_admin'], organizationRoles: [{ organizationId: 'o', role: 'organization_admin' }], eventRoles: [{ eventId: EVENT, role: 'event_organizer' }] };
    const labels = primaryTasks(user, 6).map(t => t.label);
    expect(labels).toContain('Set up my event');
    expect(labels).toContain('Platform control');
    expect(labels).toContain('My organization');
  });
  it('never repeats a destination and never exceeds the limit', () => {
    const user: UserContext = {
      ...base, platformRoles: ['platform_super_admin'], organizationRoles: [{ organizationId: 'o', role: 'organization_admin' }],
      eventRoles: [{ eventId: EVENT, role: 'event_organizer' }], teamRoles: [{ teamId: 't', role: 'team_admin' }]
    };
    const tasks = primaryTasks(user, 6);
    expect(tasks.length).toBe(6);
    expect(new Set(tasks.map(t => t.to.split('?')[0])).size).toBe(tasks.length);
  });
  it('every task has a destination and a sentence explaining it', () => {
    const user: UserContext = { ...base, eventRoles: [{ eventId: EVENT, role: 'event_organizer' }, { eventId: EVENT, role: 'field_marshal' }], teamRoles: [{ teamId: 't', role: 'captain' }] };
    for (const persona of personasOf(user)) for (const task of tasksFor(persona, user)) {
      expect(task.to.startsWith('/')).toBe(true);
      expect(task.text.length).toBeGreaterThan(15);
    }
  });
});

describe('phone bottom bar in My workspace', () => {
  it('always starts with Home and always includes notifications', () => {
    for (const user of [base, { ...base, eventRoles: [{ eventId: EVENT, role: 'event_organizer' as const }] }, { ...base, teamRoles: [{ teamId: 't', role: 'captain' as const }] }]) {
      const tabs = workspaceBottomTabs(user);
      expect(tabs[0].to).toBe('/me');
      expect(tabs.some(t => t.to === '/me/notifications')).toBe(true);
      expect(tabs.length).toBe(4);
    }
  });
  it('is chosen by what the person does', () => {
    expect(workspaceBottomTabs(base)[1].to).toBe('/events');
    expect(workspaceBottomTabs({ ...base, teamRoles: [{ teamId: 't', role: 'captain' }] })[1].to).toBe('/me/teams');
    expect(workspaceBottomTabs({ ...base, eventRoles: [{ eventId: EVENT, role: 'event_organizer' }] })[1].label).toBe('My event');
  });
});
