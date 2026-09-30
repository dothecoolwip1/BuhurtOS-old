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

/** Ranked-team counts per source for one category, most-ranked first. Positions from different sources are not comparable. */
export function rankingSources(teams: PublicDirectoryTeam[], format: RankingFormat): Array<{ source: string; count: number }> {
  const counts = new Map<string, number>();
  for (const team of teams) if (valuesFor(team, format).rank != null) counts.set(team.organizationShortName, (counts.get(team.organizationShortName) ?? 0) + 1);
  return [...counts.entries()].map(([source, count]) => ({ source, count })).sort((a, b) => b.count - a.count || a.source.localeCompare(b.source));
}

/** Validates filters that came from the URL against what the data actually offers. */
export function resolveRankingFilters(teams: PublicDirectoryTeam[], wanted: { format?: string; source?: string }): { format: RankingFormat; source: string } {
  const formats = availableRankingFormats(teams);
  const format = (formats.find(f => f === wanted.format) ?? formats[0] ?? '5v5') as RankingFormat;
  const sources = rankingSources(teams, format);
  const source = wanted.source === 'all' ? 'all' : sources.find(item => item.source === wanted.source)?.source ?? sources[0]?.source ?? 'all';
  return { format, source };
}
