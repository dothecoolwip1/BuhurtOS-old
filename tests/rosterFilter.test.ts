import { describe, expect, it } from 'vitest';
import { filterRoster, rosterCounts, rosterStatus } from '../src/lib/rosterFilter';
import type { RosterEntry } from '../src/types';

const base: RosterEntry = { id: 'x', organizationId: 'o', eventId: 'e', entryType: 'fighter', displayName: 'Base', checkedIn: true, armorCleared: true, medicalCleared: true, waiverConfirmed: true, weighInCleared: true, attendanceStatus: 'approved' };
const entries: RosterEntry[] = [
  { ...base, id: '1', displayName: 'Ann Archer', teamId: 't1', competitionCleared: true },
  { ...base, id: '2', displayName: 'Bo Bailey', teamId: 't2' },
  { ...base, id: '3', displayName: 'Cy Cooper', teamId: 't1', armorCleared: false },
  { ...base, id: '4', displayName: 'Di Dane', attendanceStatus: 'registered', checkedIn: false }
];
const team = (id?: string) => ({ t1: 'Red Deer Reavers', t2: 'North Garrison' } as Record<string, string>)[id ?? ''] ?? '';

describe('roster filters', () => {
  it('names where each entry stands', () => {
    expect(entries.map(rosterStatus)).toEqual(['cleared', 'ready', 'blocked', 'blocked']);
  });
  it('counts every group', () => {
    expect(rosterCounts(entries)).toEqual({ all: 4, cleared: 1, ready: 1, blocked: 2, unregistered: 1 });
  });
  it('filters by status', () => {
    expect(filterRoster(entries, 'blocked', '').map(e => e.id)).toEqual(['3', '4']);
    expect(filterRoster(entries, 'unregistered', '').map(e => e.id)).toEqual(['4']);
    expect(filterRoster(entries, 'all', '').length).toBe(4);
  });
  it('finds people by part of a name or by team, ignoring case', () => {
    expect(filterRoster(entries, 'all', 'cOOp', team).map(e => e.id)).toEqual(['3']);
    expect(filterRoster(entries, 'all', 'reavers', team).map(e => e.id)).toEqual(['1', '3']);
    expect(filterRoster(entries, 'blocked', 'reavers', team).map(e => e.id)).toEqual(['3']);
    expect(filterRoster(entries, 'all', 'zzz', team)).toEqual([]);
  });
});
