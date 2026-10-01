import { describe, expect, it } from 'vitest';
import { describeTiebreakBasis, rankWithPolicy, resolveTies, type Bout, type TiebreakPolicy } from '../src/lib/tiebreak';
import { computeEventStandings, computeEventStandingsDetailed, computeTeamStandingsDetailed } from '../src/lib/standings';
import type { EventRecord, EventTeam, MatchRecord, RosterEntry } from '../src/types';

// Mirrors the seeded BI Tournament Structure (Jan 2026) policy.
const BI: TiebreakPolicy = {
  authority: 'bi', docVersion: 'Jan 2026', sourceRef: 'Tournament Structure Jan 2026 §3',
  steps: [
    { key: 'head_to_head', label: 'Head-to-head result', appliesTo: 'two_way_tie_only' },
    { key: 'round_ratio', label: 'Round victories vs losses, or hits earned vs received' },
    { key: 'active_vs_downed', label: 'Active vs downed competitors difference' },
    { key: 'fewest_penalties', label: 'Fewest penalties received' }
  ]
};

const bout = (a: string, b: string, winner: 'a' | 'b' | null, o: Partial<Bout> = {}): Bout => ({ a, b, winner, roundsA: winner === 'a' ? 1 : 0, roundsB: winner === 'b' ? 1 : 0, hitsA: 0, hitsB: 0, compare: 'hit_ratio', ...o });

describe('stage 1: head-to-head (two-way ties only)', () => {
  it('puts the winner of the direct bout first', () => {
    const out = resolveTies(['x', 'y'], [bout('x', 'y', 'b')], BI);
    expect(out.order).toEqual(['y', 'x']);
    expect(out.resolutions[0]).toMatchObject({ resolvedBy: 'head_to_head', unresolved: false });
  });
  it('is not used for three-way ties', () => {
    const bouts = [bout('x', 'y', 'a', { hitsA: 1, hitsB: 0 }), bout('y', 'z', 'a', { hitsA: 5, hitsB: 1 }), bout('z', 'x', 'a', { hitsA: 2, hitsB: 1 })];
    const out = resolveTies(['x', 'y', 'z'], bouts, BI);
    expect(out.resolutions[0].resolvedBy).toBe('round_ratio');
  });
  it('falls through when the two never met or drew', () => {
    const out = resolveTies(['x', 'y'], [bout('x', 'y', null, { hitsA: 4, hitsB: 2 })], BI);
    expect(out.order).toEqual(['x', 'y']);
    expect(out.resolutions[0].resolvedBy).toBe('round_ratio');
  });
});

describe('stage 2: round ratio', () => {
  it('uses hits earned over hits received for other duels, not the raw difference', () => {
    // x: +5 difference, ratio 2.0. y: +3 difference, ratio 4.0. A difference-based order would put x first.
    const bouts = [bout('x', 'p', 'a', { hitsA: 10, hitsB: 5 }), bout('y', 'q', 'a', { hitsA: 4, hitsB: 1 })];
    const out = resolveTies(['x', 'y'], bouts, { ...BI, steps: BI.steps.filter(s => s.key === 'round_ratio') });
    expect(out.order).toEqual(['y', 'x']);
  });
  it('uses round victories minus losses for Buhurt and Buckler', () => {
    const bouts = [bout('x', 'p', 'a', { compare: 'round_difference', roundsA: 3, roundsB: 2 }), bout('y', 'q', 'a', { compare: 'round_difference', roundsA: 3, roundsB: 0 })];
    const out = resolveTies(['x', 'y'], bouts, { ...BI, steps: BI.steps.filter(s => s.key === 'round_ratio') });
    expect(out.order).toEqual(['y', 'x']);
  });
  it('treats no hits received as better than any ratio', () => {
    const bouts = [bout('x', 'p', 'a', { hitsA: 9, hitsB: 1 }), bout('y', 'q', 'a', { hitsA: 1, hitsB: 0 })];
    expect(resolveTies(['x', 'y'], bouts, { ...BI, steps: BI.steps.filter(s => s.key === 'round_ratio') }).order).toEqual(['y', 'x']);
  });
});

describe('stage 3: active vs downed', () => {
  it('is reported as skipped because BuhurtOS does not record it, never guessed', () => {
    const out = resolveTies(['x', 'y'], [bout('x', 'y', null)], { ...BI, steps: BI.steps.filter(s => s.key === 'active_vs_downed') });
    expect(out.skippedSteps).toEqual([{ key: 'active_vs_downed', reason: expect.stringMatching(/does not record/i) }]);
    expect(out.resolutions[0].unresolved).toBe(true);
    expect(out.order).toEqual(['x', 'y']);
  });
});

describe('stage 4: fewest penalties', () => {
  const only = { ...BI, steps: BI.steps.filter(s => s.key === 'fewest_penalties') };
  it('prefers the competitor with fewer penalties when they are known', () => {
    const out = resolveTies(['x', 'y'], [], only, new Map([['x', 3], ['y', 1]]));
    expect(out.order).toEqual(['y', 'x']);
    expect(out.resolutions[0]).toMatchObject({ resolvedBy: 'fewest_penalties', unresolved: false });
  });
  it('is reported as skipped when penalty records were not supplied', () => {
    const out = resolveTies(['x', 'y'], [], only);
    expect(out.skippedSteps[0]).toMatchObject({ key: 'fewest_penalties' });
    expect(out.resolutions[0].unresolved).toBe(true);
  });
});

describe('ties no step can break', () => {
  it('are flagged unresolved for an organizer decision, with input order preserved', () => {
    const out = resolveTies(['x', 'y', 'z'], [], BI, new Map([['x', 0], ['y', 0], ['z', 0]]));
    expect(out.order).toEqual(['x', 'y', 'z']);
    expect(out.resolutions.some(r => r.unresolved)).toBe(true);
  });
  it('continue with later steps inside a subgroup that is still level', () => {
    // x clearly ahead on ratio; y and z level on ratio, separated by penalties.
    const bouts = [bout('x', 'p', 'a', { hitsA: 9, hitsB: 1 }), bout('y', 'q', 'a', { hitsA: 2, hitsB: 1 }), bout('z', 'r', 'a', { hitsA: 4, hitsB: 2 })];
    const out = resolveTies(['y', 'z', 'x'], bouts, BI, new Map([['x', 0], ['y', 2], ['z', 1]]));
    expect(out.order).toEqual(['x', 'z', 'y']);
  });
});

describe('ranking with a policy', () => {
  const rows = [{ id: 'a', pts: 3 }, { id: 'b', pts: 6 }, { id: 'c', pts: 3 }];
  it('orders by the primary key first and only breaks ties within a group', () => {
    const result = rankWithPolicy(rows, r => r.pts, (p, q) => q.pts - p.pts, [bout('a', 'c', 'b')], BI);
    expect(result.ranked.map(r => r.id)).toEqual(['b', 'c', 'a']);
    expect(result.policy?.docVersion).toBe('Jan 2026');
  });
  it('uses the supplied fallback comparator, and names no policy, when none is configured', () => {
    const result = rankWithPolicy(rows, r => r.pts, (p, q) => q.pts - p.pts || p.id.localeCompare(q.id), [], undefined);
    expect(result.ranked.map(r => r.id)).toEqual(['b', 'a', 'c']);
    expect(result.policy).toBeUndefined();
  });
});

// ---- Through the real standings boards ------------------------------------------------------------------

const event = (): EventRecord => ({ id: 'e1', organizationId: 'o', seasonId: 's', name: 'Test', venue: 'V', startsAt: '2026-09-01T16:00:00Z', endsAt: '2026-09-01T23:00:00Z', eventType: 'ranked_competitive', standingsMode: 'season_and_event', status: 'published', timezone: 'UTC' });
const entry = (id: string, teamId?: string): RosterEntry => ({ id, organizationId: 'o', eventId: 'e1', teamId, entryType: 'fighter', displayName: id.toUpperCase(), checkedIn: true, armorCleared: true, medicalCleared: true, waiverConfirmed: true, weighInCleared: true, attendanceStatus: 'approved' });
const match = (id: string, s1: string, s2: string, winner: 1 | 2 | null, t1: number, t2: number, kind: 'duel' | 'team_fight' = 'duel'): MatchRecord => ({
  id, organizationId: 'o', seasonId: 's', eventId: 'e1', label: id, category: 'longsword', matchType: 'duel', scoringConfig: { kind, roundsRequired: 1 }, status: 'finalized', stage: 'pool', scheduledOrder: 1,
  participants: [{ rosterEntryId: s1, sideIndex: 1 }, { rosterEntryId: s2, sideIndex: 2 }], rounds: [],
  resultSummary: { winnerSide: winner, side1Total: t1, side2Total: t2, roundsWonSide1: winner === 1 ? 1 : 0, roundsWonSide2: winner === 2 ? 1 : 0, resultType: 'points' }
});
const roster = ['a', 'b', 'c', 'd', 'e'].map(id => entry(id));

describe('standings: nothing regresses without a policy', () => {
  // a and b both win once (3 points). b has the larger differential, so the legacy order puts b first.
  const matches = [match('m1', 'a', 'c', 1, 3, 2), match('m2', 'b', 'd', 1, 9, 0)];
  it('keeps the legacy order and says so', () => {
    const detailed = computeEventStandingsDetailed(event(), matches, roster);
    expect(detailed.rows.map(r => r.rosterEntryId)).toEqual(['b', 'a', 'c', 'd']);
    expect(detailed.policy).toBeUndefined();
    expect(detailed.basis).toMatch(/No official tiebreak policy/);
    expect(computeEventStandings(event(), matches, roster).map(r => r.rosterEntryId)).toEqual(['b', 'a', 'c', 'd']);
  });
  it('still returns nothing when standings are off', () => {
    expect(computeEventStandingsDetailed({ ...event(), standingsMode: 'no_standings' }, matches, roster).rows).toEqual([]);
  });
});

describe('standings: a configured policy orders ties and identifies itself', () => {
  it('uses head-to-head for a genuine two-way tie even when the loser has the better differential', () => {
    // a beat b directly (3-2); b then beat c 9-0. Both finish on 3 points. Legacy order: b first (differential +8 vs +1).
    const matches = [match('m1', 'a', 'b', 1, 3, 2), match('m2', 'b', 'c', 1, 9, 0)];
    const legacy = computeEventStandingsDetailed(event(), matches, roster);
    expect(legacy.rows.map(r => r.rosterEntryId)).toEqual(['b', 'a', 'c']);
    const withPolicy = computeEventStandingsDetailed(event(), matches, roster, { policy: BI });
    expect(withPolicy.rows.map(r => r.rosterEntryId)).toEqual(['a', 'b', 'c']);
    expect(withPolicy.resolutions).toEqual([{ ids: ['a', 'b'], resolvedBy: 'head_to_head', unresolved: false }]);
    expect(withPolicy.policy).toMatchObject({ authority: 'bi', docVersion: 'Jan 2026' });
    expect(withPolicy.basis).toMatch(/BI tiebreak rules \(Tournament Structure Jan 2026/);
  });
  it('falls to the round ratio for a three-way tie and records that step, not head-to-head', () => {
    // a>b, b>c, c>a in a cycle: everyone on 3 points; hits decide.
    const matches = [match('m1', 'a', 'b', 1, 3, 2), match('m2', 'b', 'c', 1, 9, 0), match('m3', 'c', 'a', 1, 2, 1)];
    const result = computeEventStandingsDetailed(event(), matches, roster, { policy: BI });
    expect(result.rows.map(r => r.standingPoints)).toEqual([3, 3, 3]);
    expect(result.resolutions[0]).toMatchObject({ resolvedBy: 'round_ratio', unresolved: false });
    expect(result.rows[0].rosterEntryId).toBe('b');
  });
  it('reports the steps it could not evaluate when a tie survives to them', () => {
    const matches = [match('m1', 'a', 'b', null, 3, 3)];
    const result = computeEventStandingsDetailed(event(), matches, roster, { policy: BI });
    expect(result.resolutions.some(r => r.unresolved)).toBe(true);
    expect(result.skippedSteps.map(s => s.key)).toEqual(expect.arrayContaining(['active_vs_downed', 'fewest_penalties']));
  });
  it('team standings use the same engine and report the policy', () => {
    const teams: EventTeam[] = [{ id: 'ta', name: 'Alpha', cityOrRegion: 'x' }, { id: 'tb', name: 'Beta', cityOrRegion: 'y' }];
    const teamRoster = [entry('p1', 'ta'), entry('p2', 'ta'), entry('p3', 'tb'), entry('p4', 'tb')];
    const matches = [match('t1', 'p1', 'p3', 1, 3, 2), match('t2', 'p4', 'p2', 1, 3, 2)];
    const result = computeTeamStandingsDetailed(event(), matches, teamRoster, teams, { policy: BI });
    expect(result.rows.map(r => r.teamId)).toHaveLength(2);
    expect(result.policy?.docVersion).toBe('Jan 2026');
    expect(result.resolutions.length).toBeGreaterThan(0);
  });
});

describe('describing the basis', () => {
  it('names the authority, version source and steps', () => {
    expect(describeTiebreakBasis(BI)).toMatch(/BI tiebreak rules \(Tournament Structure Jan 2026 §3\): Head-to-head result; then Round victories/);
  });
  it('is honest when there is no policy', () => {
    expect(describeTiebreakBasis(undefined)).toMatch(/No official tiebreak policy is configured/);
  });
});
