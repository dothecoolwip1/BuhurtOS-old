import type { Team, UserContext } from '../types';
import { loadGovernanceSnapshot, type GovernanceAuthority, type GovernanceSnapshot } from './organizationAdmin';
import { supabase } from './supabase';

export interface TeamListRow {
  id: string;
  name: string;
  cityOrRegion?: string;
  status?: string;
  organizationId: string;
  organizationName: string;
  /** Why this person can manage it (used to explain an empty or short list). */
  manageable: boolean;
}

/** Every team the person can see, marked with whether they can manage its people. */
export async function listTeamsForAdmin(user: UserContext | null): Promise<TeamListRow[]> {
  if (!supabase || !user) return [];
  const [teams, orgs] = await Promise.all([
    supabase.from('teams').select('id,name,city_or_region,status,organization_id').is('deleted_at', null).order('name').limit(2000),
    supabase.from('organizations').select('id,name,short_name').order('name')
  ]);
  if (teams.error) throw teams.error;
  if (orgs.error) throw orgs.error;
  const orgName = new Map((orgs.data ?? []).map((row: any) => [row.id, row.short_name || row.name]));
  const owner = user.platformRoles.includes('platform_super_admin');
  const adminOrgs = new Set(user.organizationRoles.filter(role => role.role === 'organization_admin').map(role => role.organizationId));
  const myTeams = new Set((user.teamRoles ?? []).filter(role => role.role === 'team_admin' || role.role === 'captain').map(role => role.teamId));
  return (teams.data ?? []).map((row: any) => ({
    id: row.id,
    name: row.name,
    cityOrRegion: row.city_or_region ?? undefined,
    status: row.status ?? undefined,
    organizationId: row.organization_id,
    organizationName: orgName.get(row.organization_id) ?? 'Organization',
    manageable: owner || adminOrgs.has(row.organization_id) || myTeams.has(row.id)
  }));
}

export interface TeamManagement {
  team: Team;
  organizationName: string;
  snapshot: GovernanceSnapshot;
}

export async function loadTeamForManagement(teamId: string): Promise<TeamManagement | undefined> {
  if (!supabase) return undefined;
  const { data, error } = await supabase.from('teams').select('id,organization_id').eq('id', teamId).maybeSingle();
  if (error) throw error;
  if (!data) return undefined;
  const snapshot = await loadGovernanceSnapshot(data.organization_id);
  const team = snapshot.teams.find(row => row.id === teamId);
  if (!team) return undefined;
  const organization = snapshot.organizations.find(row => row.id === team.organizationId);
  return { team, organizationName: organization?.shortName || organization?.name || 'Organization', snapshot };
}

export function teamAuthorityFor(user: UserContext, team: Pick<Team, 'id' | 'organizationId' | 'clubId'>): GovernanceAuthority {
  const roles = user.teamRoles ?? [];
  return {
    platformAdmin: user.platformRoles.includes('platform_super_admin'),
    organizationAdmin: user.organizationRoles.some(role => role.organizationId === team.organizationId && role.role === 'organization_admin'),
    clubAdmin: Boolean(team.clubId && (user.clubRoles ?? []).some(role => role.clubId === team.clubId && role.role === 'club_admin')),
    teamAdmin: roles.some(role => role.teamId === team.id && role.role === 'team_admin'),
    captain: roles.some(role => role.teamId === team.id && role.role === 'captain')
  };
}

/** Case-insensitive match on team name, place or organization. */
export function filterTeamRows(rows: TeamListRow[], query: string, organizationId: string, onlyMine: boolean): TeamListRow[] {
  const needle = query.trim().toLowerCase();
  return rows.filter(row =>
    (!organizationId || organizationId === 'all' || row.organizationId === organizationId)
    && (!onlyMine || row.manageable)
    && (!needle || [row.name, row.cityOrRegion ?? '', row.organizationName].some(value => value.toLowerCase().includes(needle))));
}
