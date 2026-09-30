import { describe, expect, it } from 'vitest';
import source from '../src/lib/publicDirectory.ts?raw';
import { buildRankingRows, availableRankingFormats } from '../src/lib/rankings';
import { hacsaFallbackDirectory, loadPublicTeamDirectory, type PublicDirectoryTeam } from '../src/lib/teamDirectory';

const team = (over: Partial<PublicDirectoryTeam>): PublicDirectoryTeam => ({
  id: over.id ?? 'x', slug: over.id ?? 'x', organizationName: 'BI', organizationShortName: 'BI', name: 'T',
  location: '', continentCode: '', continentName: '', countryCode: '', countryName: 'Canada', adminAreaCode: '', adminAreaName: '', ...over
});

describe('rankings', () => {
  const teams = [
    team({ id: 'a', name: 'A', rank5v5: 2, points5v5: 50 }),
    team({ id: 'b', name: 'B', rank5v5: 1, points5v5: 90, rank12v12: 3 }),
    team({ id: 'c', name: 'C' }),
    team({ id: 'd', name: 'D', rank5v5: 4, organizationShortName: 'HACSA', countryName: 'Germany' })
  ];
  it('never invents a rank for unranked teams and sorts by rank', () => {
    const rows = buildRankingRows(teams, '5v5');
    expect(rows.map(r => r.team.id)).toEqual(['b', 'a', 'd']);
    expect(rows.find(r => r.team.id === 'c')).toBeUndefined();
  });
  it('filters by format, organization and country', () => {
    expect(buildRankingRows(teams, '12v12').map(r => r.team.id)).toEqual(['b']);
    expect(buildRankingRows(teams, '5v5', { organization: 'HACSA' }).map(r => r.team.id)).toEqual(['d']);
    expect(buildRankingRows(teams, '5v5', { country: 'Canada' }).map(r => r.team.id)).toEqual(['b', 'a']);
  });
  it('only offers formats that have published ranks', () => {
    expect(availableRankingFormats(teams)).toEqual(['5v5', '12v12']);
    expect(availableRankingFormats([team({ rank5v5: 1 })])).toEqual(['5v5']);
  });
});

describe('team directory identity', () => {
  it('uses the permanent red-deer-reavers slug and keeps the legacy id working', async () => {
    const rows = hacsaFallbackDirectory();
    const reavers = rows.find(r => r.slug === 'red-deer-reavers');
    expect(reavers).toBeDefined();
    expect(reavers?.organizationShortName).toBe('HACSA');
    expect((await loadPublicTeamDirectory({ teamSlug: 'red-deer-reavers' })).length).toBe(1);
    expect((await loadPublicTeamDirectory({ teamSlug: 'reavers' })).length).toBe(1);
  });
});

describe('public fighter privacy', () => {
  it('never selects private identity columns for public reads', () => {
    const selects = source.match(/from\('fighter_identities'\)\s*\.select\('([^']+)'\)/g) ?? [];
    expect(selects.length).toBeGreaterThan(0);
    for (const s of selects) expect(s).not.toMatch(/email|phone|birth|dob|emergency|waiver|legal|guardian|notes/i);
  });
});
