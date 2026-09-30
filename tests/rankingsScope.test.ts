import { describe, expect, it } from 'vitest';
import { buildRankingRows, rankingSources, resolveRankingFilters } from '../src/lib/rankings';
import type { PublicDirectoryTeam } from '../src/lib/teamDirectory';

const team = (over: Partial<PublicDirectoryTeam>): PublicDirectoryTeam => ({ id: over.name ?? 't', slug: over.name ?? 't', name: 'T', organizationShortName: 'BI', ...over } as PublicDirectoryTeam);
const teams = [
  team({ name: 'A', organizationShortName: 'BI', rank5v5: 1, points5v5: 100 }),
  team({ name: 'B', organizationShortName: 'BI', rank5v5: 2 }),
  team({ name: 'C', organizationShortName: 'HACSA', rank5v5: 1, points5v5: 40 }),
  team({ name: 'D', organizationShortName: 'BI', rank12v12: 1 })
];

describe('ranking scope', () => {
  it('lists sources by how many teams they rank, per category', () => {
    expect(rankingSources(teams, '5v5')).toEqual([{ source: 'BI', count: 2 }, { source: 'HACSA', count: 1 }]);
    expect(rankingSources(teams, '12v12')).toEqual([{ source: 'BI', count: 1 }]);
  });
  it('defaults to one source so positions from different sources are never interleaved', () => {
    expect(resolveRankingFilters(teams, {})).toEqual({ format: '5v5', source: 'BI' });
    expect(resolveRankingFilters(teams, { source: 'all' }).source).toBe('all');
  });
  it('repairs filters from a stale or hand-edited URL', () => {
    expect(resolveRankingFilters(teams, { format: '7v7', source: 'nope' })).toEqual({ format: '5v5', source: 'BI' });
    expect(resolveRankingFilters(teams, { format: '12v12', source: 'HACSA' })).toEqual({ format: '12v12', source: 'BI' });
  });
  it('keeps missing points missing instead of zero', () => {
    const rows = buildRankingRows(teams, '5v5', { organization: 'BI' });
    expect(rows.map(r => r.points)).toEqual([100, undefined]);
  });
});
