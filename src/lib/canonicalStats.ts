/**
 * Canonical statistics and provenance layer.
 *
 * Public pages, rankings and (later) embeds must read stats from here instead of
 * interpreting results themselves. One definition of an "official" result:
 * finalized, a recorded winnerSide, not a bye, and two real (non-placeholder) sides.
 */
import type { MatchRecord, RosterEntry } from '../types';

export type SourceKind = 'native' | 'hacsa' | 'bi_teams' | 'bi_ranking';

export type Provenance = {
  sourceKind: SourceKind;
  sourceUrl?: string;
  externalId?: string;
  retrievedAt?: string;
  verifiedAt?: string;
  sourceVersion?: string;
  /** Native results only. */
  eventId?: string;
  rulesetSnapshotId?: string;
  finalizedAt?: string;
  auditRecorded?: boolean;
};

export type OfficialSide = { rosterEntryId: string; teamId?: string; fighterId?: string; total: number };

export type OfficialResult = {
  matchId: string;
  eventId: string;
  category: string;
  resultType: string;
  winnerSide: 1 | 2 | null;
  sides: [OfficialSide, OfficialSide];
  provenance: Provenance;
};

/** Builds official results; everything not finalized and valid is dropped here, once. */
export function buildOfficialResults(
  matches: MatchRecord[],
  roster: Array<Pick<RosterEntry, 'id'> & { teamId?: string; fighterId?: string }>,
  options: { finalizedAt?: (match: MatchRecord) => string | undefined; auditRecorded?: (match: MatchRecord) => boolean } = {}
): OfficialResult[] {
  const byId = new Map(roster.map(entry => [entry.id, entry]));
  const results: OfficialResult[] = [];
  for (const match of matches) {
    const summary = match.resultSummary;
    if (match.status !== 'finalized' || !summary || summary.resultType === 'bye') continue;
    if (summary.winnerSide === undefined) continue;
    const real = match.participants.filter(p => !p.isPlaceholder && p.rosterEntryId);
    const s1 = real.find(p => p.sideIndex === 1);
    const s2 = real.find(p => p.sideIndex === 2);
    if (!s1 || !s2) continue;
    const e1 = byId.get(s1.rosterEntryId!);
    const e2 = byId.get(s2.rosterEntryId!);
    results.push({
      matchId: match.id,
      eventId: match.eventId,
      category: match.category,
      resultType: summary.resultType,
      winnerSide: summary.winnerSide,
      sides: [
        { rosterEntryId: s1.rosterEntryId!, teamId: e1?.teamId, fighterId: e1?.fighterId, total: summary.side1Total },
        { rosterEntryId: s2.rosterEntryId!, teamId: e2?.teamId, fighterId: e2?.fighterId, total: summary.side2Total }
      ],
      provenance: {
        sourceKind: 'native',
        eventId: match.eventId,
        rulesetSnapshotId: match.rulesetSnapshotId,
        finalizedAt: options.finalizedAt?.(match),
        auditRecorded: options.auditRecorded?.(match)
      }
    });
  }
  return results;
}

export type RecordStats = {
  matches: number; wins: number; losses: number; draws: number;
  pointsFor: number; pointsAgainst: number; events: number;
  byFormat: Record<string, { matches: number; wins: number; losses: number; draws: number }>;
};

const emptyRecord = (): RecordStats => ({ matches: 0, wins: 0, losses: 0, draws: 0, pointsFor: 0, pointsAgainst: 0, events: 0, byFormat: {} });

function accumulate(results: OfficialResult[], pickSide: (result: OfficialResult) => 0 | 1 | undefined): RecordStats {
  const stats = emptyRecord();
  const events = new Set<string>();
  for (const result of results) {
    const index = pickSide(result);
    if (index === undefined) continue;
    const mine = index + 1;
    const format = (stats.byFormat[result.category] ??= { matches: 0, wins: 0, losses: 0, draws: 0 });
    stats.matches += 1; format.matches += 1;
    events.add(result.eventId);
    stats.pointsFor += result.sides[index].total;
    stats.pointsAgainst += result.sides[index === 0 ? 1 : 0].total;
    if (result.winnerSide === null) { stats.draws += 1; format.draws += 1; }
    else if (result.winnerSide === mine) { stats.wins += 1; format.wins += 1; }
    else { stats.losses += 1; format.losses += 1; }
  }
  stats.events = events.size;
  return stats;
}

/** Team record from official results. Intra-team bouts and unaffiliated sides earn nothing. */
export function computeTeamStats(results: OfficialResult[], teamIds: string | string[]): RecordStats {
  const ids = new Set(Array.isArray(teamIds) ? teamIds : [teamIds]);
  return accumulate(results, result => {
    const [a, b] = result.sides;
    if (a.teamId && a.teamId === b.teamId) return undefined;
    if (a.teamId && ids.has(a.teamId)) return 0;
    if (b.teamId && ids.has(b.teamId)) return 1;
    return undefined;
  });
}

/** Fighter record only from entries linked to a real fighter identity; never inferred from names. */
export function computeFighterStats(results: OfficialResult[], fighterId: string): RecordStats & { teamHistory: string[] } {
  const stats = accumulate(results, result => {
    if (result.sides[0].fighterId === fighterId) return 0;
    if (result.sides[1].fighterId === fighterId) return 1;
    return undefined;
  });
  const teams = new Set<string>();
  for (const result of results) for (const side of result.sides) if (side.fighterId === fighterId && side.teamId) teams.add(side.teamId);
  return { ...stats, teamHistory: [...teams] };
}

export type EventStats = {
  participants: number; teams: number; matches: number;
  completedMatches: number; finalizedMatches: number; officialResults: number; formats: string[];
};

export function computeEventStats(eventId: string, matches: MatchRecord[], roster: Array<Pick<RosterEntry, 'id'> & { teamId?: string }>, results: OfficialResult[]): EventStats {
  const inEvent = matches.filter(match => match.eventId === eventId && match.status !== 'cancelled');
  const official = results.filter(result => result.eventId === eventId);
  return {
    participants: roster.length,
    teams: new Set(roster.map(entry => entry.teamId).filter(Boolean)).size,
    matches: inEvent.length,
    completedMatches: inEvent.filter(match => ['completed', 'finalized', 'forfeit'].includes(match.status)).length,
    finalizedMatches: inEvent.filter(match => match.status === 'finalized').length,
    officialResults: official.length,
    formats: [...new Set(official.map(result => result.category))].sort()
  };
}

/** One compact shape shared by pages and (later) embeds. */
export function summarizeRecord(stats: Pick<RecordStats, 'matches' | 'wins' | 'losses' | 'draws'>): string {
  return stats.matches === 0 ? 'No official matches yet' : `${stats.wins}-${stats.losses}-${stats.draws}`;
}

// ---------------------------------------------------------------------------
// Source reconciliation
// ---------------------------------------------------------------------------

export type SourcedTeamRecord = {
  recordId: string;
  name: string;
  location?: string;
  countryCode?: string;
  websiteUrl?: string;
  provenance: Provenance & { sourcePriority: number };
};

export type SourceConflict = { field: 'name' | 'location' | 'websiteUrl'; values: Array<{ value: string; sourceKind: SourceKind; sourceUrl?: string }> };

export type CanonicalTeamCard = {
  canonicalId: string;
  name: string;
  location?: string;
  websiteUrl?: string;
  sources: Array<Provenance & { sourcePriority: number }>;
  conflicts: SourceConflict[];
  recordIds: string[];
};

export const normalizeTeamKey = (name: string, countryCode = '') =>
  name.toLowerCase().normalize('NFKD').replace(/[̀-ͯ]/g, '').replace(/^the\s+/, '').replace(/[^a-z0-9]+/g, '') + '|' + countryCode.toUpperCase();

/** Two team names that only differ by a leading place or word ("Reavers" and "Red Deer Reavers") are the same name, not a conflict. */
export function sameTeamName(a: string, b: string): boolean {
  const x = normalizeTeamKey(a).split('|')[0];
  const y = normalizeTeamKey(b).split('|')[0];
  if (x === y) return true;
  const [short, long] = x.length <= y.length ? [x, y] : [y, x];
  return short.length >= 5 && long.endsWith(short);
}

/**
 * Groups records describing the same team into one public card.
 * Explicit links (alias record id -> canonical record id) win; otherwise records sharing a
 * normalized name and country are treated as the same team. Facts from the highest-priority
 * source are shown, and any disagreement is reported in `conflicts`, never overwritten.
 */
export function reconcileTeamRecords(records: SourcedTeamRecord[], links: Record<string, string> = {}): CanonicalTeamCard[] {
  const groups = new Map<string, SourcedTeamRecord[]>();
  const keyFor = (record: SourcedTeamRecord) => {
    const canonical = links[record.recordId];
    if (canonical) return 'link:' + canonical;
    const linkedAsCanonical = Object.values(links).includes(record.recordId);
    return linkedAsCanonical ? 'link:' + record.recordId : 'name:' + normalizeTeamKey(record.name, record.countryCode);
  };
  for (const record of records) {
    const key = keyFor(record);
    groups.set(key, [...(groups.get(key) ?? []), record]);
  }
  return [...groups.values()].map(group => {
    const ordered = [...group].sort((a, b) => a.provenance.sourcePriority - b.provenance.sourcePriority);
    const primary = ordered[0];
    const conflicts: SourceConflict[] = [];
    for (const field of ['name', 'location', 'websiteUrl'] as const) {
      const distinct = new Map<string, SourceConflict['values'][number]>();
      for (const record of ordered) {
        const value = record[field]?.trim();
        if (!value) continue;
        const key = field === 'name' ? normalizeTeamKey(value) : value.toLowerCase();
        const alreadySeen = field === 'name' && [...distinct.values()].some(existing => sameTeamName(existing.value, value));
        if (!distinct.has(key) && !alreadySeen) distinct.set(key, { value, sourceKind: record.provenance.sourceKind, sourceUrl: record.provenance.sourceUrl });
      }
      if (distinct.size > 1) conflicts.push({ field, values: [...distinct.values()] });
    }
    return {
      canonicalId: primary.recordId,
      name: primary.name,
      location: primary.location ?? ordered.find(r => r.location)?.location,
      websiteUrl: primary.websiteUrl ?? ordered.find(r => r.websiteUrl)?.websiteUrl,
      sources: ordered.map(record => record.provenance),
      conflicts,
      recordIds: ordered.map(record => record.recordId)
    };
  });
}
