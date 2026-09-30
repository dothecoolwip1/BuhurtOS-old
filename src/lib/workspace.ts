import type { UserContext } from '../types';
import { supabase } from './supabase';

export type ScopeKind = 'platform' | 'organization' | 'club' | 'team' | 'event';

export interface ScopeNames {
  organizations: Map<string, string>;
  clubs: Map<string, string>;
  teams: Map<string, string>;
  events: Map<string, string>;
}

export interface Responsibility {
  key: string;
  kind: ScopeKind;
  scopeId?: string;
  scopeName: string;
  roleLabel: string;
  /** Where the person does the work, and what the link is called. */
  action?: { to: string; label: string };
  /** The public page for the same thing, when one exists. */
  publicTo?: string;
}

export const roleLabels: Record<string, string> = {
  platform_super_admin: 'Platform owner',
  organization_admin: 'Organization administrator',
  organization_staff: 'Organization staff',
  club_admin: 'Club administrator',
  coach: 'Coach',
  member: 'Member',
  team_admin: 'Team administrator',
  captain: 'Captain',
  fighter: 'Fighter',
  support: 'Support',
  event_organizer: 'Event organizer',
  field_marshal: 'Field marshal',
  assistant_marshal: 'Assistant marshal',
  team_captain: 'Team captain'
};

export const roleLabel = (role: string) => roleLabels[role] ?? role.replaceAll('_', ' ');

const ids = (values: Array<string | undefined>) => [...new Set(values.filter((value): value is string => Boolean(value)))];

/** Reads the names of everything the person holds a role in. Throws on failure; callers must show it. */
export async function loadScopeNames(user: UserContext): Promise<ScopeNames> {
  const empty: ScopeNames = { organizations: new Map(), clubs: new Map(), teams: new Map(), events: new Map() };
  if (!supabase) return empty;
  const client = supabase;
  const fetchNames = async (table: string, column: string, wanted: string[]) => {
    if (!wanted.length) return new Map<string, string>();
    const { data, error } = await client.from(table).select(`id,${column}`).in('id', wanted);
    if (error) throw error;
    return new Map<string, string>((data ?? []).map((row: any) => [row.id, row[column]]));
  };
  const [organizations, clubs, teams, events] = await Promise.all([
    fetchNames('organizations', 'name', ids(user.organizationRoles.map(role => role.organizationId))),
    fetchNames('clubs', 'name', ids((user.clubRoles ?? []).map(role => role.clubId))),
    fetchNames('teams', 'name', ids((user.teamRoles ?? []).map(role => role.teamId))),
    fetchNames('events', 'name', ids(user.eventRoles.map(role => role.eventId)))
  ]);
  return { organizations, clubs, teams, events };
}

/** Turns the raw role lists into plain rows a person can read and act on. */
export function describeResponsibilities(user: UserContext, names: Partial<ScopeNames> = {}): Responsibility[] {
  const rows: Responsibility[] = [];
  const name = (map: Map<string, string> | undefined, id: string, fallback: string) => map?.get(id) ?? fallback;

  for (const role of user.platformRoles) {
    rows.push({ key: 'platform:' + role, kind: 'platform', scopeName: 'BuhurtOS platform', roleLabel: roleLabel(role), action: { to: '/admin', label: 'Open administration' } });
  }
  for (const role of user.organizationRoles) {
    rows.push({
      key: `org:${role.organizationId}:${role.role}`, kind: 'organization', scopeId: role.organizationId,
      scopeName: name(names.organizations, role.organizationId, 'Organization'), roleLabel: roleLabel(role.role),
      action: role.role === 'organization_admin' ? { to: '/admin/organizations/manage', label: 'Manage teams and members' } : { to: '/admin', label: 'Open administration' }
    });
  }
  for (const role of user.clubRoles ?? []) {
    rows.push({
      key: `club:${role.clubId}:${role.role}`, kind: 'club', scopeId: role.clubId,
      scopeName: name(names.clubs, role.clubId, 'Club'), roleLabel: roleLabel(role.role),
      action: role.role === 'club_admin' ? { to: '/admin/organizations/manage', label: 'Manage club members' } : undefined
    });
  }
  for (const role of user.teamRoles ?? []) {
    const manages = role.role === 'team_admin' || role.role === 'captain';
    rows.push({
      key: `team:${role.teamId}:${role.role}`, kind: 'team', scopeId: role.teamId,
      scopeName: name(names.teams, role.teamId, 'Team'), roleLabel: roleLabel(role.role),
      action: manages ? { to: '/admin/organizations/manage', label: 'Manage this team' } : undefined,
      publicTo: '/teams/' + role.teamId
    });
  }
  for (const role of user.eventRoles) {
    const organizer = role.role === 'event_organizer';
    const marshal = role.role === 'field_marshal' || role.role === 'assistant_marshal';
    rows.push({
      key: `event:${role.eventId}:${role.role}`, kind: 'event', scopeId: role.eventId,
      scopeName: name(names.events, role.eventId, 'Event'), roleLabel: roleLabel(role.role),
      action: organizer ? { to: `/admin/events/manage?event=${role.eventId}`, label: 'Manage this event' }
        : marshal ? { to: `/admin/events/run?event=${role.eventId}`, label: 'Run fights' } : undefined,
      publicTo: '/events/' + role.eventId
    });
  }
  return rows;
}

export const scopeKindLabel: Record<ScopeKind, string> = { platform: 'Platform', organization: 'Organization', club: 'Club', team: 'Team', event: 'Event' };
