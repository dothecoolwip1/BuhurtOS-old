import type { UserContext } from '../types';
import { supabase } from './supabase';

export interface ScopeOrganization {
  id: string;
  name: string;
  shortName?: string;
}

const STORAGE_KEY = 'nx:organization';

function store(): Storage | undefined {
  try { return typeof sessionStorage === 'undefined' ? undefined : sessionStorage; } catch { return undefined; }
}

export function rememberOrganization(id: string, target: Pick<Storage, 'setItem' | 'removeItem'> | undefined = store()): void {
  if (!target) return;
  if (id) target.setItem(STORAGE_KEY, id); else target.removeItem(STORAGE_KEY);
}

export function recallOrganization(target: Pick<Storage, 'getItem'> | undefined = store()): string {
  return target?.getItem(STORAGE_KEY) ?? '';
}

/**
 * Organizations this person may work on with organization-level tools.
 * Owner: all. Otherwise only organizations where they hold an organization role, or that contain a club/team they manage.
 * Pure so it can be tested; the database still enforces every action.
 */
export function selectableOrganizationIds(
  user: UserContext | null,
  teamOrganizations: Record<string, string> = {},
  clubOrganizations: Record<string, string> = {}
): 'all' | string[] {
  if (!user) return [];
  if (user.platformRoles.includes('platform_super_admin')) return 'all';
  const ids = new Set<string>();
  for (const role of user.organizationRoles) ids.add(role.organizationId);
  for (const role of user.teamRoles ?? []) {
    if ((role.role === 'team_admin' || role.role === 'captain') && teamOrganizations[role.teamId]) ids.add(teamOrganizations[role.teamId]);
  }
  for (const role of user.clubRoles ?? []) {
    if (role.role === 'club_admin' && clubOrganizations[role.clubId]) ids.add(clubOrganizations[role.clubId]);
  }
  return [...ids];
}

/** Picks the organization to work on: explicit choice, then the remembered one, then the preferred default, then the first. */
export function resolveOrganizationChoice(available: ScopeOrganization[], requested: string, remembered: string, preferred: string): string {
  const has = (id: string) => Boolean(id) && available.some(org => org.id === id);
  if (has(requested)) return requested;
  if (has(remembered)) return remembered;
  if (has(preferred)) return preferred;
  return available[0]?.id ?? '';
}

export async function listSelectableOrganizations(user: UserContext | null): Promise<ScopeOrganization[]> {
  if (!supabase || !user) return [];
  const teamIds = (user.teamRoles ?? []).filter(role => role.role === 'team_admin' || role.role === 'captain').map(role => role.teamId);
  const clubIds = (user.clubRoles ?? []).filter(role => role.role === 'club_admin').map(role => role.clubId);
  const [teams, clubs] = await Promise.all([
    teamIds.length ? supabase.from('teams').select('id,organization_id').in('id', teamIds) : Promise.resolve({ data: [], error: null }),
    clubIds.length ? supabase.from('clubs').select('id,organization_id').in('id', clubIds) : Promise.resolve({ data: [], error: null })
  ]);
  if (teams.error) throw teams.error;
  if (clubs.error) throw clubs.error;
  const allowed = selectableOrganizationIds(
    user,
    Object.fromEntries((teams.data ?? []).map((row: any) => [row.id, row.organization_id])),
    Object.fromEntries((clubs.data ?? []).map((row: any) => [row.id, row.organization_id]))
  );
  if (allowed !== 'all' && allowed.length === 0) return [];
  let query = supabase.from('organizations').select('id,name,short_name').order('name');
  if (allowed !== 'all') query = query.in('id', allowed);
  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []).map((row: any) => ({ id: row.id, name: row.name, shortName: row.short_name ?? undefined }));
}
