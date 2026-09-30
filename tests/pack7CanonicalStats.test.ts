import { describe, expect, it } from 'vitest';
import {
  buildOfficialResults, computeEventStats, computeFighterStats, computeTeamStats, normalizeTeamKey,
  reconcileTeamRecords, summarizeRecord, type SourcedTeamRecord
} from '../src/lib/canonicalStats';
import { provenanceToCard } from '../src/lib/publicStats';
import type { MatchRecord } from '../src/types';

const roster = [
  { id: 'r1', teamId: 'A', fighterId: 'f1' },
  { id: 'r2', teamId: 'B', fighterId: 'f2' },
  { id: 'r3', teamId: 'A', fighterId: 'f3' },
  { id: 'r4', teamId: undefined, fighterId: undefined }
];

function match(id: string, status: string, summary: any, sides: Array<[string | undefined, boolean?]>, extra: Partial<MatchRecord> = {}): MatchRecord {
  return {
    id, organizationId: 'o', seasonId: 's', eventId: 'e1', label: id, category: 'duel', matchType: 'duel',
    scoringConfig: {} as any, status: status as any, stage: 'pool' as any, scheduledOrder: 0, rounds: [],
    resultSummary: summary,
    participants: sides.map(([rosterEntryId, isPlaceholder], index) => ({ id: id + index, matchId: id, sideIndex: (index + 1) as 1 | 2, rosterEntryId, isPlaceholder: Boolean(isPlaceholder) })) as any,
    rulesetSnapshotId: 'snap1',
    ...extra
  } as MatchRecord;
}

const pts = (winnerSide: 1 | 2 | null, a: number, b: number, resultType = 'points') => ({ winnerSide, side1Total: a, side2Total: b, roundsWonSide1: 0, roundsWonSide2: 0, resultType });

const matches: MatchRecord[] = [
  match('m1', 'finalized', pts(1, 5, 3), [['r1'], ['r2']]),
  match('m2', 'finalized', pts(2, 2, 4), [['r1'], ['r2']]),
  match('m3', 'completed', pts(1, 9, 0), [['r1'], ['r2']]),
  match('m4', 'finalized', pts(1, 0, 0, 'bye'), [['r1'], ['r2']]),
  match('m5', 'finalized', pts(1, 3, 1), [['r1'], ['r3']]),
  match('m6', 'finalized', pts(null, 1, 1, 'draw'), [['r1'], ['r2']]),
  match('m7', 'scheduled', undefined, [['r1'], ['r2']]),
  match('m8', 'finalized', pts(1, 4, 0), [['r1'], [undefined, true]]),
  match('m9', 'finalized', pts(1, 7, 1), [['r3'], ['r4']])
];

describe('official results', () => {
  const results = buildOfficialResults(matches, roster, { finalizedAt: () => '2026-06-01T00:00:00Z', auditRecorded: () => true });

  it('keeps only finalized, non-bye, two-real-sided results', () => {
    expect(results.map(r => r.matchId)).toEqual(['m1', 'm2', 'm5', 'm6', 'm9']);
  });

  it('non-finalized matches never affect official stats', () => {
    const withoutCompleted = buildOfficialResults(matches.filter(m => m.id !== 'm3'), roster);
    expect(computeTeamStats(results, 'A')).toEqual(computeTeamStats(withoutCompleted, 'A'));
    expect(computeTeamStats(results, 'A').matches).toBe(4);
  });

  it('native results retain event, ruleset snapshot, finalization time and audit context', () => {
    expect(results[0].provenance).toEqual({
      sourceKind: 'native', eventId: 'e1', rulesetSnapshotId: 'snap1', finalizedAt: '2026-06-01T00:00:00Z', auditRecorded: true
    });
  });
});

describe('canonical stats', () => {
  const results = buildOfficialResults(matches, roster);

  it('computes team records and ignores intra-team bouts', () => {
    const a = computeTeamStats(results, 'A');
    expect([a.wins, a.losses, a.draws]).toEqual([2, 1, 1]);
    expect(a.matches).toBe(4);
    expect(a.pointsFor).toBe(5 + 2 + 1 + 7);
    expect(a.pointsAgainst).toBe(3 + 4 + 1 + 1);
    expect(a.byFormat.duel.matches).toBe(4);
    const b = computeTeamStats(results, 'B');
    expect([b.wins, b.losses, b.draws]).toEqual([1, 1, 1]);
  });

  it('merges aliased team ids into one record', () => {
    expect(computeTeamStats(results, ['A', 'B']).matches).toBe(4);
  });

  it('computes fighter stats only from linked identities', () => {
    const f1 = computeFighterStats(results, 'f1');
    expect([f1.matches, f1.wins, f1.losses, f1.draws]).toEqual([4, 2, 1, 1]);
    expect(f1.teamHistory).toEqual(['A']);
    expect(computeFighterStats(results, 'nobody').matches).toBe(0);
  });

  it('computes event stats from the same official results', () => {
    const stats = computeEventStats('e1', matches, roster, results);
    expect(stats.officialResults).toBe(5);
    expect(stats.finalizedMatches).toBe(7);
    expect(stats.completedMatches).toBe(8);
    expect(stats.teams).toBe(2);
    expect(stats.formats).toEqual(['duel']);
  });

  it('gives pages and widgets the same summary', () => {
    const team = computeTeamStats(results, 'A');
    expect(summarizeRecord(team)).toBe('2-1-1');
    expect(summarizeRecord(computeTeamStats(results, 'ZZZ'))).toBe('No official matches yet');
  });
});

describe('source reconciliation', () => {
  const rec = (recordId: string, name: string, kind: any, priority: number, extra: Partial<SourcedTeamRecord> = {}): SourcedTeamRecord => ({
    recordId, name, countryCode: 'CA', provenance: { sourceKind: kind, sourceUrl: 'https://example.test/' + kind, sourcePriority: priority, verifiedAt: '2026-09-29' }, ...extra
  });

  it('does not create duplicate cards for the same team across sources', () => {
    const cards = reconcileTeamRecords([
      rec('h1', 'Red Deer Reavers', 'hacsa', 1, { location: 'Red Deer' }),
      rec('b1', 'The Red Deer Reavers', 'bi_teams', 2, { location: 'Red Deer, AB' }),
      rec('x1', 'Another Team', 'hacsa', 1)
    ]);
    expect(cards).toHaveLength(2);
    const reavers = cards.find(c => c.name === 'Red Deer Reavers')!;
    expect(reavers.sources.map(s => s.sourceKind)).toEqual(['hacsa', 'bi_teams']);
    expect(reavers.recordIds).toEqual(['h1', 'b1']);
  });

  it('honors explicit links even when names differ', () => {
    const cards = reconcileTeamRecords([
      rec('h1', 'Alpha', 'hacsa', 1),
      rec('b1', 'Alpha Buhurt Club', 'bi_teams', 2)
    ], { b1: 'h1' });
    expect(cards).toHaveLength(1);
    expect(cards[0].canonicalId).toBe('h1');
  });

  it('keeps conflicting facts visible instead of overwriting them', () => {
    const [card] = reconcileTeamRecords([
      rec('h1', 'Reavers', 'hacsa', 1, { location: 'Red Deer', websiteUrl: 'https://a.test' }),
      rec('b1', 'Reavers', 'bi_teams', 2, { location: 'Calgary', websiteUrl: 'https://a.test' })
    ]);
    expect(card.location).toBe('Red Deer');
    expect(card.conflicts).toHaveLength(1);
    expect(card.conflicts[0].field).toBe('location');
    expect(card.conflicts[0].values.map(v => v.value)).toEqual(['Red Deer', 'Calgary']);
  });

  it('normalizes names without losing distinct teams', () => {
    expect(normalizeTeamKey('The Red Deer Reavers', 'ca')).toBe(normalizeTeamKey('red-deer reavers', 'CA'));
    expect(normalizeTeamKey('Reavers', 'CA')).not.toBe(normalizeTeamKey('Reavers', 'US'));
  });

  it('turns provenance rows into one card with source links preserved', () => {
    const card = provenanceToCard([
      { teamId: 't1', sourceKind: 'hacsa', sourceRecordKey: 'k1', sourceUrl: 'https://h', sourceTeamName: 'Alpha', sourcePriority: 1, verifiedAt: '2026-09-29', isAlias: false },
      { teamId: 't2', sourceKind: 'bi_teams', sourceRecordKey: 'k2', sourceUrl: 'https://b', sourceTeamName: 'Alpha Buhurt', sourcePriority: 2, verifiedAt: '2026-09-28', isAlias: true }
    ])!;
    expect(card.sources.map(s => s.sourceUrl)).toEqual(['https://h', 'https://b']);
    expect(card.conflicts.find(c => c.field === 'name')).toBeDefined();
    expect(provenanceToCard([])).toBeUndefined();
  });
});

import { reconcileTeamRecords as reconcileForNames, sameTeamName } from '../src/lib/canonicalStats';
describe('team name agreement', () => {
  it('treats a short form of a name as the same name', () => {
    expect(sameTeamName('Reavers', 'Red Deer Reavers')).toBe(true);
    expect(sameTeamName('The Horde', 'horde')).toBe(true);
    expect(sameTeamName('Red Deer Reavers', 'Calgary Reavers')).toBe(false);
    expect(sameTeamName('Ox', 'Red Ox')).toBe(false);
  });
  it('does not report a conflict for a short form, but still reports a real one', () => {
    const rec = (id: string, name: string, kind: any, priority: number) => ({ recordId: id, name, provenance: { sourceKind: kind, sourceUrl: 'u', externalId: id, sourcePriority: priority } });
    const links = { b: 'a' };
    const same = reconcileForNames([rec('a', 'Reavers', 'hacsa', 10), rec('b', 'Red Deer Reavers', 'bi_teams', 20)], links)[0];
    expect(same.conflicts.filter(c => c.field === 'name')).toEqual([]);
    const different = reconcileForNames([rec('a', 'Reavers', 'hacsa', 10), rec('b', 'Mountain Wolves', 'bi_teams', 20)], links)[0];
    expect(different.conflicts.some(c => c.field === 'name')).toBe(true);
  });
});
