import type { UserContext } from '../types';
import { supabase } from './supabase';

export async function loadUserContext(userId: string, displayName: string): Promise<UserContext> {
  if (!supabase) return { userId, displayName, hasPlatformAccess: true, platformRoles: [], organizationRoles: [], eventRoles: [], clubRoles: [], teamRoles: [] };
  const [platform, org, event, club, team, access] = await Promise.all([
    supabase.from('platform_memberships').select('role').eq('user_id', userId),
    supabase.from('organization_memberships').select('organization_id,role').eq('user_id', userId),
    supabase.from('event_memberships').select('event_id,role,team_id').eq('user_id', userId),
    supabase.from('club_memberships').select('club_id,role').eq('user_id', userId).is('ends_on', null),
    supabase.from('team_memberships').select('team_id,role').eq('user_id', userId).is('ends_on', null),
    supabase.rpc('has_buhurtos_access')
  ]);
  const error = platform.error || org.error || event.error || club.error || team.error || access.error;
  if (error) throw error;
  return {
    userId,
    displayName,
    hasPlatformAccess: access.data === true,
    platformRoles: (platform.data ?? []).map(r => r.role),
    organizationRoles: (org.data ?? []).map(r => ({ organizationId: r.organization_id, role: r.role })),
    eventRoles: (event.data ?? []).map(r => ({ eventId: r.event_id, role: r.role, teamId: r.team_id ?? undefined })),
    clubRoles: (club.data ?? []).map(r => ({ clubId: r.club_id, role: r.role })),
    teamRoles: (team.data ?? []).map(r => ({ teamId: r.team_id, role: r.role }))
  } as UserContext;
}
