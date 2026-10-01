import type { UserContext } from '../types';

/**
 * What a person is probably here to do. One account can be several personas; the list is ordered so the most
 * responsible one comes first. This only shapes what is shown first: the database still enforces every permission,
 * and everything else stays one tap away under "More tools".
 */
export type Persona = 'platform_owner' | 'org_admin' | 'organizer' | 'captain' | 'marshal' | 'fighter';

export interface JourneyTask {
  id: string;
  label: string;
  text: string;
  to: string;
  persona: Persona;
}

export const personaLabels: Record<Persona, string> = {
  platform_owner: 'Platform owner', org_admin: 'Organization admin', organizer: 'Event organizer',
  captain: 'Captain or team admin', marshal: 'Marshal', fighter: 'Fighter'
};

const MARSHAL_ROLES = ['field_marshal', 'assistant_marshal'];

export function personasOf(user: UserContext | null | undefined): Persona[] {
  if (!user) return [];
  const personas: Persona[] = [];
  if (user.platformRoles.includes('platform_super_admin')) personas.push('platform_owner');
  if (user.organizationRoles.some(r => r.role === 'organization_admin')) personas.push('org_admin');
  if (user.eventRoles.some(r => r.role === 'event_organizer')) personas.push('organizer');
  if ((user.teamRoles ?? []).some(r => r.role === 'team_admin' || r.role === 'captain') || (user.clubRoles ?? []).some(r => r.role === 'club_admin')) personas.push('captain');
  if (user.eventRoles.some(r => MARSHAL_ROLES.includes(r.role))) personas.push('marshal');
  // Everyone signed in can be a fighter; it is the default way in when nothing else applies.
  personas.push('fighter');
  return personas;
}

function firstEvent(user: UserContext, roles: string[]): string | undefined {
  return user.eventRoles.find(r => roles.includes(r.role))?.eventId;
}

const withEvent = (path: string, eventId: string | undefined) => (eventId ? `${path}?event=${encodeURIComponent(eventId)}` : path);

/** Tasks for one persona, each with a real destination. */
export function tasksFor(persona: Persona, user: UserContext): JourneyTask[] {
  const t = (id: string, label: string, text: string, to: string): JourneyTask => ({ id, label, text, to, persona });
  switch (persona) {
    case 'platform_owner':
      return [
        t('platform', 'Platform control', 'Overview of everything that needs attention.', '/admin'),
        t('orgs', 'Organizations and teams', 'See and edit every organization and its teams.', '/admin/organizations'),
        t('access', 'Accounts and access', 'Let someone sign in, or give someone a role.', '/admin/people/accounts')
      ];
    case 'org_admin':
      return [
        t('my-org', 'My organization', 'Teams, clubs and members you administer.', '/admin/organizations/manage'),
        t('org-events', 'Create or set up an event', 'Start a new event, or continue one.', '/admin/events/setup'),
        t('rulesets', 'Rulesets', 'Choose the rules your events run under.', '/admin/rules/rulesets')
      ];
    case 'organizer': {
      const eventId = firstEvent(user, ['event_organizer']);
      return [
        t('setup', 'Set up my event', 'Step-by-step progress and what to do next.', withEvent('/admin/events/guide', eventId)),
        t('requests', 'Registrations and requests', 'Signups, signup codes and permission requests.', withEvent('/admin/events/signups', eventId)),
        t('schedule', 'Schedule and brackets', 'Order of play, pools and bracket.', withEvent('/admin/events/bracket', eventId))
      ];
    }
    case 'captain':
      return [
        t('my-team', 'My team', 'Roster, invitations and the tools your role allows.', '/me/teams'),
        t('team-requests', 'Requests and answers', 'Permission requests and notifications for your team.', '/me/notifications'),
        t('team-events', 'Find events to enter', 'See what is coming up and whether registration is open.', '/events')
      ];
    case 'marshal': {
      const eventId = firstEvent(user, MARSHAL_ROLES);
      return [
        t('run', 'Run my field', 'The live fight queue, scoring and finalizing.', withEvent('/admin/events/run', eventId)),
        t('rules', 'Rules at hand', 'Find the rule that applies, by format.', '/rules')
      ];
    }
    case 'fighter':
    default:
      return [
        t('register', 'Register for an event', 'See what is coming up and whether you can sign up.', '/events'),
        t('profile', 'My profile', 'Your sporting identity, public profile and details.', '/me/profile'),
        t('notifications', 'My notifications', 'Answers to your requests and news for you.', '/me/notifications')
      ];
  }
}

/**
 * The short list to lead with: one task from each persona in turn (most responsible first), never more than `limit`,
 * never the same destination twice.
 */
export function primaryTasks(user: UserContext | null | undefined, limit = 6): JourneyTask[] {
  if (!user) return [];
  // Round-robin across personas so someone with several roles sees something for each, most responsible first.
  const lists = personasOf(user).map(persona => tasksFor(persona, user));
  const seen = new Set<string>();
  const out: JourneyTask[] = [];
  for (let round = 0; out.length < limit && lists.some(list => round < list.length); round++) {
    for (const list of lists) {
      const task = list[round];
      if (!task) continue;
      const key = task.to.split('?')[0];
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(task);
      if (out.length >= limit) break;
    }
  }
  return out;
}

export interface BottomTab { to: string; label: string; icon: string; end?: boolean }

/** Four everyday destinations for the phone bottom bar in My workspace, chosen by what the person does. */
export function workspaceBottomTabs(user: UserContext | null | undefined): BottomTab[] {
  const personas = personasOf(user);
  const tabs: BottomTab[] = [{ to: '/me', label: 'Home', icon: '⌂', end: true }];
  if (personas.includes('organizer')) tabs.push({ to: '/admin/events/guide', label: 'My event', icon: '⚑' });
  else if (personas.includes('captain')) tabs.push({ to: '/me/teams', label: 'My team', icon: '♜' });
  else tabs.push({ to: '/events', label: 'Events', icon: '⚔' });
  tabs.push({ to: '/me/profile', label: 'Profile', icon: '♟' });
  tabs.push({ to: '/me/notifications', label: 'Alerts', icon: '🔔' });
  return tabs;
}
