import { describe, expect, it } from 'vitest';
import appSource from '../src/App.tsx?raw';
import {
  accessFromUser, adminSections, areaOfPath, breadcrumbsFor, canSee, hasAdminArea, legacyRedirects, noAccess, publicBottom, publicPrimary,
  resolveLegacyPath, scopeForPath, visibleAdminSections, workspaceItems
} from '../src/lib/navigation';
import { describeResponsibilities } from '../src/lib/workspace';
import { recallListPath, rememberListSearch } from '../src/lib/urlState';
import type { UserContext } from '../src/types';

const user = (over: Partial<UserContext> = {}): UserContext => ({
  userId: 'u1', displayName: 'Test', hasPlatformAccess: true, platformRoles: [], organizationRoles: [], eventRoles: [], clubRoles: [], teamRoles: [], ...over
});
const eventAccess = { eventManage: false, bracketManage: false, discipline: false, notes: false, any: false };

const allItems = adminSections.flatMap(section => section.items);
const adminRoutes = new Set(allItems.map(item => item.to));

describe('navigation model', () => {
  it('has unique, stable destinations', () => {
    const paths = [...allItems.map(i => i.to), ...workspaceItems.map(i => i.to)];
    expect(new Set(paths).size).toBe(paths.length);
    const ids = allItems.map(i => i.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it('every destination is an actual route in the app', () => {
    for (const item of allItems) {
      const relative = item.to === '/admin' ? null : item.to.replace('/admin/', '');
      expect(relative === null ? appSource.includes('<Route index element={<AdminHome/>}') : appSource.includes(`path="${relative}"`), item.to).toBe(true);
    }
    for (const item of workspaceItems) {
      const relative = item.to === '/me' ? null : item.to.replace('/me/', '');
      expect(relative === null ? appSource.includes('<Route index element={<WorkspaceHome/>}') : appSource.includes(`path="${relative}"`), item.to).toBe(true);
    }
  });

  it('keeps public primary labels consistent and the mobile bar short', () => {
    expect(publicPrimary.map(i => i.label)).toEqual(['Home', 'Teams', 'Events', 'Fighters', 'Rankings', 'Rules']);
    expect(publicBottom.length).toBe(4);
  });

  it('uses plain language, not internal jargon', () => {
    const labels = [...allItems, ...workspaceItems].map(i => i.label).join(' | ');
    for (const jargon of ['Ops', 'Foundation', 'Identity &', 'Pack ', 'Compliance Gate', 'Marshal Console']) expect(labels).not.toContain(jargon);
  });
});

describe('legacy URLs', () => {
  it('maps every old /ops URL to a real destination', () => {
    const valid = new Set([...adminRoutes, ...workspaceItems.map(i => i.to), '/sign-in', '/me/invite']);
    for (const entry of legacyRedirects) expect(valid.has(entry.to), `${entry.from} -> ${entry.to}`).toBe(true);
  });

  it('keeps query strings and tolerates trailing slashes', () => {
    expect(resolveLegacyPath('/ops/manage', '?event=abc')).toBe('/admin/events/manage?event=abc');
    expect(resolveLegacyPath('/ops/invite', '?token=t0k')).toBe('/me/invite?token=t0k');
    expect(resolveLegacyPath('/ops/login/')).toBe('/sign-in');
    expect(resolveLegacyPath('/ops')).toBe('/admin/events/run');
    expect(resolveLegacyPath('/team-hq')).toBe('/me/teams');
    expect(resolveLegacyPath('/teams')).toBeUndefined();
  });

  it('routes the old paths in the app', () => {
    expect(appSource).toContain('path="/ops/*"');
    expect(appSource).toContain('legacyRedirects.filter');
  });
});

describe('who sees what', () => {
  const labelsFor = (u: UserContext | null, event = eventAccess) =>
    visibleAdminSections(accessFromUser(u, event)).flatMap(s => s.items.map(i => i.id));

  it('shows nothing to an anonymous visitor', () => {
    expect(labelsFor(null)).toEqual([]);
    expect(canSee('member', noAccess)).toBe(false);
  });

  it('gives the owner everything', () => {
    const ids = labelsFor(user({ platformRoles: ['platform_super_admin'] }));
    for (const item of allItems) expect(ids).toContain(item.id);
  });

  it('gives a captain team tools but not organization or platform settings', () => {
    const ids = labelsFor(user({ teamRoles: [{ teamId: 't1', role: 'captain' }] }));
    expect(ids).toContain('teams');
    expect(ids).toContain('org-members');
    expect(ids).toContain('overview');
    for (const hidden of ['settings', 'accounts', 'organizations', 'create-teams', 'rulesets', 'event-setup', 'event-settings']) expect(ids).not.toContain(hidden);
  });

  it('gives an event organizer the event workflow only for the event they work on', () => {
    const organizer = user({ eventRoles: [{ eventId: 'e1', role: 'event_organizer' }] });
    const withEvent = labelsFor(organizer, { eventManage: true, bracketManage: true, discipline: true, notes: true, any: true });
    for (const id of ['event-settings', 'event-signups', 'event-roster', 'event-bracket', 'event-run', 'event-results', 'event-discipline']) expect(withEvent).toContain(id);
    expect(withEvent).not.toContain('settings');
    const without = labelsFor(user({ teamRoles: [{ teamId: 't', role: 'fighter' }] }));
    expect(without).not.toContain('event-run');
  });

  it('gives a marshal the fight tools but not event settings', () => {
    const ids = labelsFor(user({ eventRoles: [{ eventId: 'e1', role: 'field_marshal' }] }), { eventManage: false, bracketManage: false, discipline: true, notes: true, any: true });
    expect(ids).toContain('event-run');
    expect(ids).toContain('rules-reference');
    expect(ids).not.toContain('event-settings');
  });

  it('decides whether to offer the Administration area', () => {
    expect(hasAdminArea(null)).toBe(false);
    expect(hasAdminArea(user())).toBe(false);
    expect(hasAdminArea(user({ teamRoles: [{ teamId: 't', role: 'fighter' }] }))).toBe(false);
    expect(hasAdminArea(user({ teamRoles: [{ teamId: 't', role: 'captain' }] }))).toBe(true);
    expect(hasAdminArea(user({ eventRoles: [{ eventId: 'e', role: 'fighter' }] }))).toBe(true);
    expect(hasAdminArea(user({ platformRoles: ['platform_super_admin'] }))).toBe(true);
  });
});

describe('orientation', () => {
  it('knows which area a path belongs to', () => {
    expect(areaOfPath('/admin/events/run')).toBe('admin');
    expect(areaOfPath('/me/teams')).toBe('workspace');
    expect(areaOfPath('/teams/red-deer-reavers')).toBe('public');
  });

  it('builds breadcrumbs for deep pages', () => {
    expect(breadcrumbsFor('/admin/events/roster').map(c => c.label)).toEqual(['Administration', 'Events', 'Roster & check-in']);
    expect(breadcrumbsFor('/admin/settings').map(c => c.label)).toEqual(['Administration', 'Platform', 'Platform settings']);
    expect(breadcrumbsFor('/me/teams').map(c => c.label)).toEqual(['My workspace', 'My teams']);
    expect(breadcrumbsFor('/admin').length).toBe(1);
    expect(breadcrumbsFor('/teams')).toEqual([]);
  });

  it('states the scope of each page', () => {
    expect(scopeForPath('/admin/events/roster')).toBe('event');
    expect(scopeForPath('/admin/settings')).toBe('platform');
    expect(scopeForPath('/admin/organizations')).toBe('organization');
    expect(scopeForPath('/admin/events/setup')).toBe('organization');
    expect(scopeForPath('/me/profile')).toBe('personal');
    expect(scopeForPath('/admin')).toBe('none');
  });
});

describe('workspace responsibilities', () => {
  it('describes roles in plain language with the right destination', () => {
    const rows = describeResponsibilities(user({
      platformRoles: ['platform_super_admin'],
      organizationRoles: [{ organizationId: 'o1', role: 'organization_admin' }],
      teamRoles: [{ teamId: 't1', role: 'captain' }, { teamId: 't2', role: 'fighter' }],
      eventRoles: [{ eventId: 'e1', role: 'event_organizer' }, { eventId: 'e2', role: 'field_marshal' }]
    }), { teams: new Map([['t1', 'Red Deer Reavers']]), organizations: new Map([['o1', 'HACSA']]) });
    const byKey = (key: string) => rows.find(r => r.key.startsWith(key))!;
    expect(byKey('platform').roleLabel).toBe('Platform owner');
    expect(byKey('org:o1').scopeName).toBe('HACSA');
    expect(byKey('team:t1').roleLabel).toBe('Captain');
    expect(byKey('team:t1').scopeName).toBe('Red Deer Reavers');
    expect(byKey('team:t1').action?.to).toBe('/admin/organizations/manage');
    expect(byKey('team:t2').action).toBeUndefined();
    expect(byKey('event:e1').action?.to).toBe('/admin/events/manage?event=e1');
    expect(byKey('event:e2').action?.to).toBe('/admin/events/run?event=e2');
  });

  it('never invents a team for someone without one', () => {
    expect(describeResponsibilities(user())).toEqual([]);
  });
});

describe('remembered browsing context', () => {
  it('returns to the list with the filters last used', () => {
    const memory = new Map<string, string>();
    const store = { getItem: (k: string) => memory.get(k) ?? null, setItem: (k: string, v: string) => void memory.set(k, v), removeItem: (k: string) => void memory.delete(k) };
    expect(recallListPath('/teams', store)).toBe('/teams');
    rememberListSearch('/teams', '?country=Canada&region=Alberta', store);
    expect(recallListPath('/teams', store)).toBe('/teams?country=Canada&region=Alberta');
    rememberListSearch('/teams', '', store);
    expect(recallListPath('/teams', store)).toBe('/teams');
  });
});

describe('team roster tools', () => {
  it('routes the roster pages and the invitation landing page', () => {
    for (const path of ['path="teams"', 'path="teams/:teamId"', 'path="teams/new"', 'path="invite"']) expect(appSource).toContain(path);
    expect(appSource).toContain('<Navigate to={\'/me/invite\' + location.search} replace />');
  });
});
