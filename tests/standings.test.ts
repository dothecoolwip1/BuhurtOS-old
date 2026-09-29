import { describe, expect, it } from 'vitest';
import { computeTeamStandings } from '../src/lib/standings';
import type { EventRecord, EventTeam, MatchRecord, RosterEntry } from '../src/types';

const event = (mode: EventRecord['standingsMode'] = 'season_and_event'): EventRecord => ({
  id: 'e1', organizationId: 'org-1', seasonId: 's1', name: 'Test Event', venue: 'Field',
  startsAt: '2026-09-01T16:00:00.000Z', endsAt: '2026-09-01T23:00:00.000Z',
  eventType: 'ranked_competitive', standingsMode: mode, status: 'published', timezone: 'UTC'
});

const entry = (id: string, teamId?: string): RosterEntry => ({
  id, organizationId: 'org-1', eventId: 'e1', teamId, entryType: 'fighter', displayName: 'Fighter ' + id,
  checkedIn: true, armorCleared: true, medicalCleared: true, waiverConfirmed: true, weighInCleared: true,
  attendanceStatus: 'approved'
});

const teams: EventTeam[] = [
  { id: 'team-a', name: 'Alpha', cityOrRegion: 'A City' },
  { id: 'team-b', name: 'Beta', cityOrRegion: 'B City' },
];

const bout = (
  id: string,
  sideA: string,
  sideB: string,
  overrides: Partial<MatchRecord> = {}
): MatchRecord => ({
  id, organizationId: 'org-1', seasonId: 's1', eventId: 'e1', label: 'Bout ' + id, category: 'longsword',
  matchType: 'duel', scoringConfig: { kind: 'duel', roundsRequired: 1 }, status: 'finalized', stage: 'pool',
  scheduledOrder: 1,
  participants: [{ rosterEntryId: sideA, sideIndex: 1 }, { rosterEntryId: sideB, sideIndex: 2 }],
  rounds: [],
  resultSummary: { winnerSide: 1, side1Total: 3, side2Total: 1, roundsWonSide1: 1, roundsWonSide2: 0, resultType: 'points' },
  ...overrides,
});

const roster = [
  entry('r1', 'team-a'),
  entry('r2', 'team-a'),
  entry('r3', 'team-b'),
  entry('r4', 'team-b'),
  entry('r5'),
];

describe('computeTeamStandings', () => {
  it('aggregates finalized cross-team bouts into per-team rows with 3/1/0 scoring', () => {
    const matches = [
      bout('m1', 'r1', 'r3', { resultSummary: { winnerSide: 1, side1Total: 3, side2Total: 1, roundsWonSide1: 1, roundsWonSide2: 0, resultType: 'points' } }),
      bout('m2', 'r2', 'r4', { resultSummary: { winnerSide: 2, side1Total: 2, side2Total: 4, roundsWonSide1: 0, roundsWonSide2: 1, resultType: 'points' } }),
    ];
    const rows = computeTeamStandings(event(), matches, roster, teams);
    expect(rows).toHaveLength(2);
    const alpha = rows.find(r => r.teamId === 'team-a')!;
    const beta = rows.find(r => r.teamId === 'team-b')!;
    expect(alpha.name).toBe('Alpha');
    expect(beta.name).toBe('Beta');
    expect(alpha.fighters).toBe(2);
    expect(beta.fighters).toBe(2);
    expect(alpha.matches).toBe(2);
    expect(alpha.wins).toBe(1);
    expect(alpha.losses).toBe(1);
    expect(alpha.pointsFor).toBe(5);
    expect(alpha.pointsAgainst).toBe(5);
    expect(alpha.standingPoints).toBe(3);
    expect(beta.wins).toBe(1);
    expect(beta.losses).toBe(1);
    expect(beta.pointsFor).toBe(5);
    expect(beta.standingPoints).toBe(3);
  });

  it('skips intra-team, individual, non-finalized and bye bouts', () => {
    const matches = [
      bout('m1', 'r1', 'r3'),
      bout('m2', 'r1', 'r2'), // intra-team sparring
      bout('m3', 'r5', 'r3'), // unaffiliated fighter
      bout('m4', 'r1', 'r4', { status: 'scheduled' }),
      bout('m5', 'r1', 'r4', { resultSummary: { winnerSide: null as any, side1Total: 0, side2Total: 0, roundsWonSide1: 0, roundsWonSide2: 0, resultType: 'bye' } }),
    ];
    const rows = computeTeamStandings(event(), matches, roster, teams);
    expect(rows).toHaveLength(2);
    expect(rows.every(r => r.matches === 1)).toBe(true);
  });

  it('scores draws as one point for each team', () => {
    const matches = [
      bout('m1', 'r1', 'r3', { resultSummary: { winnerSide: null as any, side1Total: 2, side2Total: 2, roundsWonSide1: 1, roundsWonSide2: 1, resultType: 'draw' } }),
    ];
    const rows = computeTeamStandings(event(), matches, roster, teams);
    expect(rows).toHaveLength(2);
    for (const row of rows) {
      expect(row.draws).toBe(1);
      expect(row.standingPoints).toBe(1);
    }
  });

  it('falls back to an Unknown Team name when the team is not in the catalog', () => {
    const ghostRoster = [entry('r6', 'team-ghost'), entry('r3', 'team-b')];
    const matches = [bout('m1', 'r6', 'r3')];
    const rows = computeTeamStandings(event(), matches, ghostRoster, teams);
    expect(rows.find(r => r.teamId === 'team-ghost')?.name).toBe('Unknown Team');
  });

  it('returns nothing for no_standings events or when no team bouts exist', () => {
    expect(computeTeamStandings(event('no_standings'), [bout('m1', 'r1', 'r3')], roster, teams)).toEqual([]);
    expect(computeTeamStandings(event(), [], roster, teams)).toEqual([]);
    const individualOnly = roster.filter(e => !e.teamId);
    expect(computeTeamStandings(event(), [bout('m1', 'r5', 'r5', { participants: [{ rosterEntryId: 'r5', sideIndex: 1 }, { rosterEntryId: 'r5', sideIndex: 2 }] })], roster, teams)).toEqual([]);
    void individualOnly;
  });

  it('sorts by standing points, differential, points scored, wins, then name', () => {
    const rows = computeTeamStandings(event(), [
      bout('m1', 'r1', 'r3', { resultSummary: { winnerSide: 1, side1Total: 5, side2Total: 0, roundsWonSide1: 1, roundsWonSide2: 0, resultType: 'points' } }),
      bout('m2', 'r2', 'r4', { resultSummary: { winnerSide: 2, side1Total: 1, side2Total: 2, roundsWonSide1: 0, roundsWonSide2: 1, resultType: 'points' } }),
    ], roster, teams);
    expect(rows[0].teamId).toBe('team-a');
    expect(rows[1].teamId).toBe('team-b');
  });
});