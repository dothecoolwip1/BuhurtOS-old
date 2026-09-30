/**
 * The one navigation model for BuhurtOS.
 *
 * Three connected areas:
 *   PUBLIC SITE      browse the sport without an account            (#/public, #/teams, #/events ...)
 *   MY WORKSPACE     a signed-in person's own things                (#/me/...)
 *   ADMINISTRATION   manage what you are authorized to manage       (#/admin/...)
 *
 * Shells render from this file so labels, order and destinations stay identical everywhere.
 * Menus hide entries the person cannot use, but the database still enforces every permission.
 */
import type { UserContext } from '../types';

export type Area = 'public' | 'workspace' | 'admin';

/** What a person needs in order to see a menu entry. */
export type NavGate =
  | 'member'        // any signed-in person with platform access
  | 'event'         // can work on the current event (any event role, org admin or owner)
  | 'eventManage'   // can manage the current event
  | 'bracketManage' // can manage brackets of the current event
  | 'discipline'    // can issue cards for the current event
  | 'notes'         // can read fight notes
  | 'teamManager'   // can manage a team or club (team admin, captain, club admin) or an organization
  | 'orgAdmin'      // administers at least one organization (or owner)
  | 'superAdmin';   // platform owner

export interface NavItem {
  id: string;
  label: string;
  to: string;
  /** One plain sentence shown on overview pages and menus. */
  description: string;
  gate: NavGate;
  /** Less common tools sit below everyday tasks. */
  advanced?: boolean;
}

export interface NavSection {
  id: string;
  label: string;
  blurb: string;
  items: NavItem[];
}

// ---------------------------------------------------------------------------
// Public site
// ---------------------------------------------------------------------------

export const publicPrimary: Array<{ to: string; label: string; icon: string }> = [
  { to: '/public', label: 'Discover', icon: '◎' },
  { to: '/teams', label: 'Teams', icon: '♜' },
  { to: '/events', label: 'Events', icon: '⚔' },
  { to: '/fighters', label: 'Fighters', icon: '♟' },
  { to: '/rankings', label: 'Rankings', icon: '↗' },
  { to: '/rules', label: 'Rules', icon: '§' },
  { to: '/governance', label: 'Organizations', icon: '⌘' }
];

/** Mobile bottom bar: four everyday destinations plus the full menu. */
export const publicBottom = publicPrimary.filter(item => ['/public', '/teams', '/events', '/rules'].includes(item.to));

export const publicSecondary: Array<{ to: string; label: string; description: string }> = [
  { to: '/embed-builder', label: 'Put BuhurtOS on your website', description: 'Copy a widget for events, a team or standings.' }
];

// ---------------------------------------------------------------------------
// My workspace
// ---------------------------------------------------------------------------

export const workspaceItems: NavItem[] = [
  { id: 'home', label: 'Home', to: '/me', description: 'Your responsibilities and what to do next.', gate: 'member' },
  { id: 'profile', label: 'My fighter profile', to: '/me/profile', description: 'Your sporting identity, public profile and private details.', gate: 'member' },
  { id: 'teams', label: 'My teams', to: '/me/teams', description: 'Teams you belong to and the tools your role allows.', gate: 'member' },
  { id: 'join', label: 'Join with a code', to: '/me/join', description: 'Use an invitation or access code you were given.', gate: 'member' }
];

// ---------------------------------------------------------------------------
// Administration
// ---------------------------------------------------------------------------

export const adminSections: NavSection[] = [
  {
    id: 'overview', label: 'Overview', blurb: 'What needs attention and where to go next.',
    items: [
      { id: 'overview', label: 'Overview', to: '/admin', description: 'Items needing attention and shortcuts to your work.', gate: 'member' }
    ]
  },
  {
    id: 'events', label: 'Events & competition', blurb: 'Set up an event, take entries, run the day and publish results.',
    items: [
      { id: 'event-setup', label: 'Seasons & new events', to: '/admin/events/setup', description: 'Create seasons and events for an organization.', gate: 'orgAdmin' },
      { id: 'event-settings', label: 'Event settings', to: '/admin/events/manage', description: 'Dates, registration, fields, announcements and poster.', gate: 'eventManage' },
      { id: 'event-signups', label: 'Fighter signups', to: '/admin/events/signups', description: 'Signup codes and review of fighters who applied.', gate: 'event' },
      { id: 'event-roster', label: 'Roster & check-in', to: '/admin/events/roster', description: 'Who is entered, checked in and cleared to compete.', gate: 'event' },
      { id: 'event-bracket', label: 'Bracket & schedule', to: '/admin/events/bracket', description: 'Build divisions, pools and the fight order.', gate: 'event' },
      { id: 'event-run', label: 'Run fights', to: '/admin/events/run', description: 'The live fight queue for marshals and scorekeepers.', gate: 'event' },
      { id: 'event-results', label: 'Results & standings', to: '/admin/events/results', description: 'Finalized results and standings for the event.', gate: 'event' },
      { id: 'event-discipline', label: 'Discipline', to: '/admin/events/discipline', description: 'Cards and suspensions.', gate: 'discipline' },
      { id: 'event-notes', label: 'Fight notes', to: '/admin/events/notes', description: 'Team and marshal notes.', gate: 'notes' },
      { id: 'event-tools', label: 'Bracket tools', to: '/admin/events/tools', description: 'Advanced bracket and fighter utilities.', gate: 'bracketManage', advanced: true },
      { id: 'event-all', label: 'All seasons & events', to: '/admin/events/all', description: 'Every season and event across the platform.', gate: 'superAdmin', advanced: true }
    ]
  },
  {
    id: 'organizations', label: 'Organizations & teams', blurb: 'The groups that make up the sport.',
    items: [
      { id: 'organizations', label: 'Organizations', to: '/admin/organizations', description: 'Create and edit organizations and their relationships.', gate: 'superAdmin' },
      { id: 'teams', label: 'Teams & rosters', to: '/admin/teams', description: 'Find a team, see who is on it, add or remove people.', gate: 'teamManager' },
      { id: 'org-members', label: 'Clubs & applications', to: '/admin/organizations/manage', description: 'Clubs, applications and relationships for the organization of the current event.', gate: 'teamManager', advanced: true },
      { id: 'create-teams', label: 'Create teams & clubs', to: '/admin/teams/new', description: 'Add a new team or club inside an organization.', gate: 'superAdmin', advanced: true }
    ]
  },
  {
    id: 'people', label: 'People & access', blurb: 'Who can sign in and what each person may do.',
    items: [
      { id: 'accounts', label: 'Early access codes', to: '/admin/people/accounts', description: 'Let someone sign in to BuhurtOS for the first time.', gate: 'superAdmin' },
      { id: 'codes', label: 'Role codes', to: '/admin/people/codes', description: 'Give someone a role in an organization, club or team with a one-time code.', gate: 'orgAdmin' },
      { id: 'identity-review', label: 'Fighter identity review', to: '/admin/people/identity-review', description: 'Resolve fighter claims, duplicates and merges.', gate: 'orgAdmin' }
    ]
  },
  {
    id: 'rules', label: 'Rules & structure', blurb: 'The rulebooks and divisions competition runs on.',
    items: [
      { id: 'rules-reference', label: 'Rules reference', to: '/admin/rules/reference', description: 'Search the rulebooks by fight format.', gate: 'member' },
      { id: 'rulesets', label: 'Rulesets', to: '/admin/rules/rulesets', description: 'Publish and version the rules an event uses.', gate: 'orgAdmin' },
      { id: 'divisions', label: 'Fighters & divisions', to: '/admin/rules/divisions', description: 'Fighter records, clubs and competition divisions.', gate: 'orgAdmin', advanced: true }
    ]
  },
  {
    id: 'platform', label: 'Platform', blurb: 'Settings that affect the whole platform.',
    items: [
      { id: 'settings', label: 'Platform settings', to: '/admin/settings', description: 'Registration, event creation and claims switches.', gate: 'superAdmin' },
      { id: 'sync', label: 'Offline sync', to: '/admin/system/sync', description: 'Changes saved on this device waiting to upload.', gate: 'member', advanced: true }
    ]
  }
];

// ---------------------------------------------------------------------------
// Access and filtering
// ---------------------------------------------------------------------------

export interface NavAccess {
  signedIn: boolean;
  superAdmin: boolean;
  orgAdmin: boolean;
  teamManager: boolean;
  /** Event-scoped checks; false when there is no current event. */
  event: boolean;
  eventManage: boolean;
  bracketManage: boolean;
  discipline: boolean;
  notes: boolean;
}

export const noAccess: NavAccess = { signedIn: false, superAdmin: false, orgAdmin: false, teamManager: false, event: false, eventManage: false, bracketManage: false, discipline: false, notes: false };

export function canSee(gate: NavGate, access: NavAccess): boolean {
  if (!access.signedIn) return false;
  switch (gate) {
    case 'member': return true;
    case 'event': return access.superAdmin || access.event;
    case 'eventManage': return access.superAdmin || access.eventManage;
    case 'bracketManage': return access.superAdmin || access.bracketManage;
    case 'discipline': return access.superAdmin || access.discipline;
    case 'notes': return access.superAdmin || access.notes;
    case 'teamManager': return access.superAdmin || access.orgAdmin || access.teamManager;
    case 'orgAdmin': return access.superAdmin || access.orgAdmin;
    case 'superAdmin': return access.superAdmin;
  }
}

export function visibleAdminSections(access: NavAccess): NavSection[] {
  return adminSections
    .map(section => ({ ...section, items: section.items.filter(item => canSee(item.gate, access)) }))
    .filter(section => section.items.length > 0);
}

/** Derives menu access from the signed-in person. Event checks are supplied by the caller. */
export function accessFromUser(
  user: UserContext | null,
  event: { eventManage: boolean; bracketManage: boolean; discipline: boolean; notes: boolean; any: boolean } = { eventManage: false, bracketManage: false, discipline: false, notes: false, any: false }
): NavAccess {
  if (!user) return noAccess;
  const superAdmin = user.platformRoles.includes('platform_super_admin');
  const orgAdmin = superAdmin || user.organizationRoles.some(role => role.role === 'organization_admin');
  const teamManager = orgAdmin
    || (user.teamRoles ?? []).some(role => role.role === 'team_admin' || role.role === 'captain')
    || (user.clubRoles ?? []).some(role => role.role === 'club_admin');
  return {
    signedIn: true, superAdmin, orgAdmin, teamManager,
    event: event.any || user.eventRoles.length > 0 || orgAdmin,
    eventManage: event.eventManage, bracketManage: event.bracketManage, discipline: event.discipline, notes: event.notes
  };
}

/** Does this person have anything to administer? Drives the "Administration" entry in menus. */
export function hasAdminArea(user: UserContext | null): boolean {
  if (!user) return false;
  return user.platformRoles.length > 0
    || user.organizationRoles.length > 0
    || user.eventRoles.length > 0
    || (user.teamRoles ?? []).some(role => role.role === 'team_admin' || role.role === 'captain')
    || (user.clubRoles ?? []).some(role => role.role === 'club_admin');
}

export function areaOfPath(pathname: string): Area {
  if (pathname === '/admin' || pathname.startsWith('/admin/')) return 'admin';
  if (pathname === '/me' || pathname.startsWith('/me/')) return 'workspace';
  return 'public';
}

export const areaHome: Record<Area, string> = { public: '/public', workspace: '/me', admin: '/admin' };
export const areaLabel: Record<Area, string> = { public: 'Public site', workspace: 'My workspace', admin: 'Administration' };

export type Scope = 'event' | 'organization' | 'platform' | 'personal' | 'none';

/** What a page acts on. Shells show this explicitly so people always know what a change will affect. */
export function scopeForPath(pathname: string): Scope {
  if (pathname === '/me' || pathname.startsWith('/me/')) return 'personal';
  if (pathname.startsWith('/admin/events/all')) return 'platform';
  if (pathname.startsWith('/admin/events/setup') || pathname.startsWith('/admin/organizations') || pathname.startsWith('/admin/teams') || pathname.startsWith('/admin/rules/rulesets') || pathname.startsWith('/admin/rules/divisions') || pathname.startsWith('/admin/people/codes') || pathname.startsWith('/admin/people/identity-review')) return 'organization';
  if (pathname.startsWith('/admin/events/')) return 'event';
  if (pathname.startsWith('/admin/settings') || pathname.startsWith('/admin/people/accounts')) return 'platform';
  return 'none';
}

export function sectionForPath(pathname: string): NavSection | undefined {
  const exact = adminSections.find(section => section.items.some(item => item.to === pathname));
  if (exact) return exact;
  return adminSections.find(section => section.items.some(item => item.to !== '/admin' && pathname.startsWith(item.to + '/')));
}

export function itemForPath(pathname: string): NavItem | undefined {
  const all = [...adminSections.flatMap(section => section.items), ...workspaceItems];
  return all.find(item => item.to === pathname) ?? all.filter(item => item.to !== '/admin' && item.to !== '/me').find(item => pathname.startsWith(item.to + '/'));
}

export type Crumb = { label: string; to?: string };

/** Breadcrumb trail for admin and workspace pages. Public detail pages build their own. */
export function breadcrumbsFor(pathname: string): Crumb[] {
  const area = areaOfPath(pathname);
  if (area === 'public') return [];
  const home: Crumb = { label: areaLabel[area], to: areaHome[area] };
  const item = itemForPath(pathname);
  if (!item || item.to === areaHome[area]) return [{ label: areaLabel[area] }];
  if (area === 'workspace') return [home, { label: item.label }];
  const section = sectionForPath(pathname);
  return section && section.id !== 'overview' ? [home, { label: section.label }, { label: item.label }] : [home, { label: item.label }];
}

// ---------------------------------------------------------------------------
// Legacy URLs (old "ops" layout) -> new destinations. Old links in emails, chats and bookmarks keep working.
// ---------------------------------------------------------------------------

export const legacyRedirects: Array<{ from: string; to: string }> = [
  { from: '/ops/login', to: '/sign-in' },
  { from: '/ops/roster', to: '/admin/events/roster' },
  { from: '/ops/bracket', to: '/admin/events/bracket' },
  { from: '/ops/standings', to: '/admin/events/results' },
  { from: '/ops/manage', to: '/admin/events/manage' },
  { from: '/ops/signups', to: '/admin/events/signups' },
  { from: '/ops/admin', to: '/admin/events/tools' },
  { from: '/ops/discipline', to: '/admin/events/discipline' },
  { from: '/ops/notes', to: '/admin/events/notes' },
  { from: '/ops/setup', to: '/admin/events/setup' },
  { from: '/ops/identity-review', to: '/admin/people/identity-review' },
  { from: '/ops/identity', to: '/me/profile' },
  { from: '/ops/governance', to: '/admin/organizations/manage' },
  { from: '/ops/invite', to: '/me/invite' },
  { from: '/ops/access-admin', to: '/admin/people/accounts' },
  { from: '/ops/access', to: '/me/join' },
  { from: '/ops/codes', to: '/admin/people/codes' },
  { from: '/ops/platform', to: '/admin' },
  { from: '/ops/foundation', to: '/admin/rules/divisions' },
  { from: '/ops/rulesets', to: '/admin/rules/rulesets' },
  { from: '/ops/marshal-reference', to: '/admin/rules/reference' },
  { from: '/ops/sync', to: '/admin/system/sync' },
  { from: '/ops', to: '/admin/events/run' },
  { from: '/team-hq', to: '/me/teams' }
];

/** Resolves an old path (with its query string) to the new one, or undefined when it is not a legacy path. */
export function resolveLegacyPath(pathname: string, search = ''): string | undefined {
  const clean = pathname.replace(/\/+$/, '') || '/';
  const hit = legacyRedirects.find(entry => entry.from === clean);
  return hit ? hit.to + search : undefined;
}

/** Where a signed-in person lands by default, and where a safe `next` path may point. */
export const DEFAULT_SIGNED_IN_PATH = '/me';
export const SAFE_RETURN_PREFIXES = ['/me', '/admin', '/ops'];
