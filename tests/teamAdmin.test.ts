import { describe, expect, it } from 'vitest';
import { filterTeamRows, teamAuthorityFor, type TeamListRow } from '../src/lib/teamAdmin';
import { membershipInvitePath, allowedInviteRoles } from '../src/lib/organizationAdmin';
import type { UserContext } from '../src/types';

const user = (over: Partial<UserContext> = {}): UserContext => ({
  userId: 'u', displayName: 'U', hasPlatformAccess: true, platformRoles: [], organizationRoles: [], eventRoles: [], clubRoles: [], teamRoles: [], ...over
});

const rows: TeamListRow[] = [
  { id: 't1', name: 'Red Deer Reavers', cityOrRegion: 'Red Deer', organizationId: 'hacsa', organizationName: 'HACSA', manageable: true },
  { id: 't2', name: 'Horde', cityOrRegion: 'Drayton Valley', organizationId: 'hacsa', organizationName: 'HACSA', manageable: false },
  { id: 't3', name: 'Newbery Harpias', cityOrRegion: 'Buenos Aires', organizationId: 'bi', organizationName: 'BI', manageable: false }
];

describe('team browser filtering', () => {
  it('searches name, place and organization', () => {
    expect(filterTeamRows(rows, 'reavers', 'all', false).map(r => r.id)).toEqual(['t1']);
    expect(filterTeamRows(rows, 'buenos', 'all', false).map(r => r.id)).toEqual(['t3']);
    expect(filterTeamRows(rows, 'hacsa', 'all', false).map(r => r.id)).toEqual(['t1', 't2']);
  });
  it('filters by organization and by teams the person can manage', () => {
    expect(filterTeamRows(rows, '', 'bi', false).map(r => r.id)).toEqual(['t3']);
    expect(filterTeamRows(rows, '', 'all', true).map(r => r.id)).toEqual(['t1']);
  });
});

describe('who may change a roster', () => {
  const team = { id: 't1', organizationId: 'hacsa', clubId: undefined };
  it('gives the owner every role', () => {
    const authority = teamAuthorityFor(user({ platformRoles: ['platform_super_admin'] }), team);
    expect(allowedInviteRoles('team', authority)).toEqual(['team_admin', 'captain', 'coach', 'fighter', 'support']);
  });
  it('gives an organization admin every role only for their own organization', () => {
    const mine = teamAuthorityFor(user({ organizationRoles: [{ organizationId: 'hacsa', role: 'organization_admin' }] }), team);
    const other = teamAuthorityFor(user({ organizationRoles: [{ organizationId: 'bi', role: 'organization_admin' }] }), team);
    expect(allowedInviteRoles('team', mine).length).toBe(5);
    expect(allowedInviteRoles('team', other)).toEqual([]);
  });
  it('lets a captain invite lower roles only on their own team', () => {
    const captain = user({ teamRoles: [{ teamId: 't1', role: 'captain' }] });
    expect(allowedInviteRoles('team', teamAuthorityFor(captain, team))).toEqual(['coach', 'fighter', 'support']);
    expect(allowedInviteRoles('team', teamAuthorityFor(captain, { ...team, id: 't2' }))).toEqual([]);
  });
  it('lets a fighter change nothing', () => {
    expect(allowedInviteRoles('team', teamAuthorityFor(user({ teamRoles: [{ teamId: 't1', role: 'fighter' }] }), team))).toEqual([]);
  });
});

describe('invitation links', () => {
  it('land in My workspace and carry only the token', () => {
    expect(membershipInvitePath('abc 123')).toBe('/me/invite?token=abc%20123');
  });
});
