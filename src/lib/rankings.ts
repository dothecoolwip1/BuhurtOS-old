import type { PublicDirectoryTeam } from './teamDirectory';

export type RankingFormat = '5v5' | '12v12';

export type RankingRow = {
  team: PublicDirectoryTeam;
  rank: number;
  points?: number;
};

export const rankingFormatLabels: Record<RankingFormat, string> = { '5v5': '5v5', '12v12': '12v12' };

function valuesFor(team: PublicDirectoryTeam, format: RankingFormat) {
  return format === '5v5'
    ? { rank: team.rank5v5, points: team.points5v5 }
    : { rank: team.rank12v12, points: team.points12v12 };
}

/** Only teams with a published source rank are listed; missing ranks are never invented. */
export function buildRankingRows(
  teams: PublicDirectoryTeam[],
  format: RankingFormat,
  filters: { organization?: string; country?: string } = {}
): RankingRow[] {
  const rows: RankingRow[] = [];
  for (const team of teams) {
    if (filters.organization && filters.organization !== 'all' && team.organizationShortName !== filters.organization) continue;
    if (filters.country && filters.country !== 'all' && team.countryName !== filters.country) continue;
    const { rank, points } = valuesFor(team, format);
    if (rank == null) continue;
    rows.push({ team, rank, points });
  }
  return rows.sort((a, b) => a.rank - b.rank || (b.points ?? 0) - (a.points ?? 0) || a.team.name.localeCompare(b.team.name));
}

export function availableRankingFormats(teams: PublicDirectoryTeam[]): RankingFormat[] {
  return (['5v5', '12v12'] as RankingFormat[]).filter(format => teams.some(team => valuesFor(team, format).rank != null));
}
