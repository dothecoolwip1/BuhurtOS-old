import { describe, expect, it } from 'vitest';
import {
  disciplineCsv,
  htmlTable,
  matchesCsv,
  rosterCsv,
  standingsCsv,
  suspensionsCsv,
} from '../src/lib/export';
import type { MatchRecord, RosterEntry } from '../src/types';
import type { StandingRow } from '../src/lib/standings';

const standingsRow = (overrides: Partial<StandingRow> = {}): StandingRow => ({
  rosterEntryId: 'row-1',
  name: 'Ada, \"Blade\" Corvin',
  matches: 2,
  wins: 1,
  losses: 0,
  draws: 1,
  pointsFor: 12,
  pointsAgainst: 8,
  differential: 4,
  standingPoints: 3,
  ...overrides,
});

const rosterEntry = (overrides: Partial<RosterEntry> = {}): RosterEntry => ({
  id: 'r1',
  organizationId: 'org-1',
  eventId: 'e1',
  entryType: 'fighter',
  displayName: 'Bran Ironfoot',
  checkedIn: true,
  armorCleared: true,
  medicalCleared: false,
  waiverConfirmed: true,
  weighInCleared: false,
  competitionCleared: true,
  attendanceStatus: 'approved',
  ...overrides,
});

const matchRecord = (overrides: Partial<MatchRecord> = {}): MatchRecord => ({
  id: 'm1',
  organizationId: 'org-1',
  seasonId: 's1',
  eventId: 'e1',
  label: 'Bout 1, Group A',
  category: 'longsword',
  matchType: 'duel',
  scoringConfig: { kind: 'duel', roundsRequired: 1 },
  status: 'finalized',
  stage: 'pool',
  scheduledOrder: 3,
  participants: [],
  rounds: [],
  ...overrides,
});

describe('export CSV builders', () => {
  it('standingsCsv emits the header then ranked rows and escapes commas and quotes', () => {
    const csv = standingsCsv([standingsRow()]);
    const [header, row] = csv.split('\n');
    expect(header).toBe(['Rank', 'Competitor', 'Matches', 'Wins', 'Losses', 'Draws', 'Points For', 'Points Against', 'Differential', 'Standing Points'].join(','));
    expect(row).toContain('"Ada, ""Blade"" Corvin"');
    expect(row).toContain(',2,1,0,1,12,8,4,3');
  });

  it('matchesCsv reports order, stage, status and the winner side when finalized', () => {
    const csv = matchesCsv([
      matchRecord({ resultSummary: { winnerSide: 2, side1Total: 1, side2Total: 2, roundsWonSide1: 1, roundsWonSide2: 2, resultType: 'points' } }),
      matchRecord({ id: 'm2', label: 'Pending bout', status: 'scheduled' }),
    ]);
    const lines = csv.split('\n');
    expect(lines[0]).toContain('Order');
    expect(lines[1]).toContain('3,"Bout 1, Group A",longsword,pool,finalized,2,1,2');
    expect(lines[2]).toContain('Pending bout');
    expect(lines[2]).toContain('scheduled,,,');
  });

  it('disciplineCsv maps cards to competitor rows and localizes the issued-at time', () => {
    const csv = disciplineCsv([{ name: 'Bran Ironfoot', color: 'red', reason: 'Strike, after the hold', notes: 'Warned twice', issuedAt: '2026-09-20T16:40:00.000Z' }]);
    const lines = csv.split('\n');
    expect(lines[0]).toBe(['Competitor', 'Color', 'Reason', 'Notes', 'Issued At'].join(','));
    expect(lines[1]).toContain('Bran Ironfoot,red,"Strike, after the hold",Warned twice,');
    expect(lines[1]).toContain('2026');
  });

  it('suspensionsCsv exposes status and revoked-at; empty revoked leaves the cell blank', () => {
    const csv = suspensionsCsv([
      { name: 'Mara Vex', reason: 'Headshot on downed opponent', startsAt: '2026-09-25T00:00:00.000Z', endsAt: '2026-10-05T00:00:00.000Z', status: 'active' },
      { name: 'Odin Gray', reason: 'Repeated low blows', startsAt: '2026-08-01T00:00:00.000Z', endsAt: '2026-08-14T00:00:00.000Z', status: 'revoked', revokedAt: '2026-08-03T09:00:00.000Z' },
    ]);
    const lines = csv.split('\n');
    expect(lines[0]).toBe(['Competitor', 'Reason', 'Starts', 'Ends', 'Status', 'Revoked At'].join(','));
    expect(lines[1]).toContain(',active,');
    expect(lines[2]).toContain(',revoked,');
  });

  it('rosterCsv maps boolean gates to yes/no and normalizes enum labels', () => {
    const csv = rosterCsv([
      rosterEntry(),
      rosterEntry({ id: 'r2', displayName: 'Tara \"Tank\" Dunn', entryType: 'guest_fighter', attendanceStatus: 'no_show', checkedIn: false, armorCleared: false, waiverConfirmed: false, competitionCleared: false }),
    ]);
    const lines = csv.split('\n');
    expect(lines[0]).toBe(['Competitor', 'Entry Type', 'Attendance', 'Checked In', 'Armor', 'Medical', 'Waiver', 'Weigh In', 'Competition Cleared'].join(','));
    expect(lines[1]).toContain('Bran Ironfoot,fighter,approved,yes,yes,no,yes,no,yes');
    expect(lines[2]).toContain('"Tara ""Tank"" Dunn",guest fighter,no show,no,no,no,no,no,no');
  });

  it('htmlTable renders booleans as yes/no and keeps plain values intact', () => {
    expect(htmlTable(['Name', 'Clear'], [['Bran', true], ['Tara', false], ['Unknown', 'maybe']]))
      .toContain('<th>Name</th>');
    expect(htmlTable(['Name', 'Clear'], [['Bran', true], ['Tara', false], ['Unknown', 'maybe']]))
      .toContain('<td>Bran</td><td>yes</td>');
    expect(htmlTable(['Name', 'Clear'], [['Bran', true], ['Tara', false], ['Unknown', 'maybe']]))
      .toContain('<td>Tara</td><td>no</td>');
  });
});