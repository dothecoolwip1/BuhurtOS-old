import { describe, expect, it } from 'vitest';
import { applySchedule, balancedGroupSizes, defaultTiming, estimateMinutes, recommendStructures, scheduleMatches, type ScheduleSettings } from '../src/lib/tournamentPlanner';
import { buildTournamentPreview } from '../src/lib/tournamentGeneration';
import type { RosterEntry } from '../src/types';

const entry = (n: number, teamId?: string): RosterEntry => ({
  id: `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`, organizationId: 'o', eventId: 'e', teamId, entryType: 'fighter', displayName: `F${n}`,
  checkedIn: true, armorCleared: true, medicalCleared: true, waiverConfirmed: true, weighInCleared: true, competitionCleared: true, attendanceStatus: 'approved'
});
const field = (n: number) => Array.from({ length: n }, (_, i) => entry(i + 1, `t${i % 4}`));
const ids = { organizationId: '10000000-0000-4000-8000-000000000001', seasonId: '10000000-0000-4000-8000-000000000002', eventId: '10000000-0000-4000-8000-000000000003', bracketId: '10000000-0000-4000-8000-000000000004' };
const build = (n: number, format: any, extra: any = {}) => buildTournamentPreview({
  ...ids, category: 'Longsword', matchType: 'longsword', scoringConfig: { kind: 'duel', roundsRequired: 3, allowDrawRound: false }, format, entries: field(n),
  seeding: { method: 'manual', values: Object.fromEntries(field(n).map((e, i) => [e.id, i + 1])) }, antiFratricide: false, ...extra
});
const A = '20000000-0000-4000-8000-00000000000a', B = '20000000-0000-4000-8000-00000000000b';
const settings = (over: Partial<ScheduleSettings> = {}): ScheduleSettings => ({ startsAt: '2026-06-06T15:00:00Z', areaIds: [A, B], boutMinutes: 6, changeoverMinutes: 2, minRestMinutes: 10, ...over });

describe('structure advice', () => {
  it('splits a field into groups that differ by at most one', () => {
    expect(balancedGroupSizes(13, 3)).toEqual([5, 4, 4]);
    expect(balancedGroupSizes(9, 2)).toEqual([5, 4]);
    expect(balancedGroupSizes(2, 5)).toEqual([1, 1]);
  });
  it('recommends a round robin for a small field and pools into a knockout for a day event', () => {
    expect(recommendStructures(4)[0].format).toBe('round_robin');
    const twenty = recommendStructures(20)[0];
    expect(twenty.format).toBe('pools_to_bracket');
    expect(twenty.groups.reduce((a, b) => a + b, 0)).toBe(20);
    expect(Math.min(...twenty.groups)).toBeGreaterThanOrEqual(4);
    expect(recommendStructures(1)).toEqual([]);
    expect(recommendStructures(2)[0].bouts).toBe(1);
  });
  it('counts pool bouts the way the generator builds them', () => {
    const pools = recommendStructures(12)[0];
    const real = build(12, 'pools_to_bracket', { targetPoolSize: pools.poolSize, qualifiersPerPool: pools.qualifiersPerPool });
    const poolBouts = real.plan.matches.filter(m => m.stage === 'pool').length;
    expect(poolBouts).toBe(pools.groups.map(g => g * (g - 1) / 2).reduce((a, b) => a + b, 0));
  });
  it('counts single elimination bouts as entrants minus one', () => {
    const matches = build(9, 'single_elimination').plan.matches.filter(m => (m.resultSummary as any)?.resultType !== 'bye');
    expect(matches.length).toBe(recommendStructures(9).find(s => s.id === 'single')!.bouts);
  });
  it('estimates time from bouts, areas and slot length', () => {
    expect(estimateMinutes(20, 2, { boutMinutes: 6, changeoverMinutes: 2 })).toBe(80);
    expect(defaultTiming('5v5').boutMinutes).toBeGreaterThan(defaultTiming('longsword').boutMinutes);
  });
});

describe('pool draw', () => {
  it('snakes the seeds so pools are balanced', () => {
    const preview = build(8, 'pools_to_bracket', { targetPoolSize: 4 }) as any;
    const seedOf = (id: string) => preview.seededEntries.find((s: any) => s.entry.id === id).seed;
    const totals = preview.plan.pools.map((pool: any) => pool.entryIds.reduce((t: number, id: string) => t + seedOf(id), 0));
    expect(totals[0]).toBe(totals[1]);
  });
});

describe('scheduler', () => {
  const pools = () => build(12, 'pools_to_bracket', { targetPoolSize: 4 }).plan.matches;

  it('places every bout once and keeps each competitor apart by the rest time', () => {
    const matches = pools();
    const plan = scheduleMatches(matches, settings());
    expect(plan.slots).toHaveLength(matches.length);
    expect(new Set(plan.slots.map(s => s.matchId)).size).toBe(matches.length);
    const byComp = new Map<string, Array<{ s: number; e: number }>>();
    for (const slot of plan.slots) {
      const match = matches.find(m => m.id === slot.matchId)!;
      for (const p of match.participants) if (p.rosterEntryId) {
        const list = byComp.get(p.rosterEntryId) ?? [];
        list.push({ s: Date.parse(slot.startsAt), e: Date.parse(slot.endsAt) });
        byComp.set(p.rosterEntryId, list);
      }
    }
    for (const list of byComp.values()) {
      list.sort((a, b) => a.s - b.s);
      for (let i = 1; i < list.length; i++) expect(list[i].s - list[i - 1].e).toBeGreaterThanOrEqual(10 * 60_000);
    }
  });

  it('never runs two bouts on the same area at the same time', () => {
    const plan = scheduleMatches(pools(), settings());
    for (const area of [A, B]) {
      const list = plan.slots.filter(s => s.areaId === area).sort((a, b) => a.startsAt.localeCompare(b.startsAt));
      for (let i = 1; i < list.length; i++) expect(Date.parse(list[i].startsAt)).toBeGreaterThanOrEqual(Date.parse(list[i - 1].endsAt));
    }
  });

  it('runs later rounds only after the bouts that feed them, even in double elimination', () => {
    const matches = build(8, 'double_elimination').plan.matches;
    const plan = scheduleMatches(matches, settings());
    const slot = new Map(plan.slots.map(s => [s.matchId, s]));
    let checked = 0;
    for (const match of matches) for (const target of [match.winnerAdvancesToMatchId, match.loserAdvancesToMatchId]) {
      if (target && slot.has(match.id) && slot.has(target)) {
        checked += 1;
        expect(Date.parse(slot.get(target)!.startsAt)).toBeGreaterThanOrEqual(Date.parse(slot.get(match.id)!.endsAt));
      }
    }
    expect(checked).toBeGreaterThan(5);
  });

  it('skips byes, honors breaks and reports an overrun', () => {
    const matches = build(6, 'single_elimination').plan.matches;
    const real = matches.filter(m => (m.resultSummary as any)?.resultType !== 'bye' && m.status !== 'cancelled');
    const plan = scheduleMatches(matches, settings({ areaIds: [A], breaks: [{ label: 'Lunch', startsAt: '2026-06-06T15:10:00Z', minutes: 60 }], dayEndsAt: '2026-06-06T15:30:00Z' }));
    expect(plan.slots).toHaveLength(real.length);
    const lunchStart = Date.parse('2026-06-06T15:10:00Z');
    const lunchEnd = lunchStart + 60 * 60_000;
    for (const s of plan.slots) {
      const start = Date.parse(s.startsAt), end = Date.parse(s.endsAt);
      expect(end <= lunchStart || start >= lunchEnd).toBe(true);
    }
    expect(plan.warnings.join(' ')).toMatch(/cut-off/);
  });

  it('more areas finish sooner', () => {
    const matches = pools();
    const one = scheduleMatches(matches, settings({ areaIds: [A] })).finishesAt!;
    const two = scheduleMatches(matches, settings({ areaIds: [A, B] })).finishesAt!;
    expect(Date.parse(two)).toBeLessThan(Date.parse(one));
  });

  it('applies areas and order to the matches without touching the draw', () => {
    const matches = pools();
    const plan = scheduleMatches(matches, settings());
    const applied = applySchedule(matches, plan);
    expect(applied.every(m => [A, B].includes(m.fightCardId as string))).toBe(true);
    expect(new Set(applied.map(m => m.scheduledOrder)).size).toBe(matches.length);
    expect(applied.map(m => m.id)).toEqual(matches.map(m => m.id));
  });

  it('rejects missing areas and bad start times with a message, not a crash', () => {
    expect(scheduleMatches(pools(), settings({ areaIds: [] })).warnings[0]).toMatch(/area/);
    expect(scheduleMatches(pools(), settings({ startsAt: 'nope' })).warnings[0]).toMatch(/start time/);
  });
});

describe('clean playoffs', () => {
  it('prefers a knockout that fills its places when the field allows', () => {
    for (const n of [12, 14, 16, 20, 24]) {
      const top = recommendStructures(n)[0];
      const advancing = top.groups.length * (top.qualifiersPerPool ?? 0);
      expect([4, 8, 16]).toContain(advancing);
      expect(Math.min(...top.groups)).toBeGreaterThanOrEqual(3);
    }
  });
});

describe('labels', () => {
  it('uses a clean bullet and still reads pool names from older saved labels', () => {
    const matches = build(8, 'pools_to_bracket', { targetPoolSize: 4 }).plan.matches;
    expect(matches[0].label).toMatch(/^Pool A • Match 1$/);
  });
});

import { playoffStart } from '../src/lib/tournamentPlanner';
describe('playoff scheduling', () => {
  it('starts after the pools are due to finish, plus rest, on a tidy five minutes', () => {
    const start = playoffStart('2026-06-06T17:01:00Z', 10, Date.parse('2026-06-06T15:00:00Z'));
    expect(start).toBe('2026-06-06T17:15:00.000Z');
  });
  it('starts from now when the pools ran late', () => {
    const start = playoffStart('2026-06-06T17:00:00Z', 10, Date.parse('2026-06-06T18:02:00Z'));
    expect(Date.parse(start)).toBeGreaterThanOrEqual(Date.parse('2026-06-06T18:12:00Z'));
    expect(Date.parse(start) % (5 * 60_000)).toBe(0);
  });
  it('plans a knockout after pools without overlapping them, and keeps global order', () => {
    const poolMatches = build(12, 'pools_to_bracket', { targetPoolSize: 4 }).plan.matches;
    const poolPlan = scheduleMatches(poolMatches, settings());
    const knockout = build(8, 'single_elimination').plan.matches;
    const at = playoffStart(poolPlan.finishesAt, 10);
    const plan = scheduleMatches(knockout, settings({ startsAt: at }));
    expect(Date.parse(plan.slots[0].startsAt)).toBeGreaterThanOrEqual(Date.parse(poolPlan.finishesAt!));
    const offset = poolMatches.length;
    const applied = applySchedule(knockout, plan, offset);
    expect(Math.min(...applied.map(m => m.scheduledOrder))).toBeGreaterThan(offset);
    const final = knockout.find(m => !m.winnerAdvancesToMatchId)!;
    const semis = knockout.filter(m => m.winnerAdvancesToMatchId === final.id);
    const slot = (id: string) => plan.slots.find(s => s.matchId === id)!;
    for (const semi of semis) expect(Date.parse(slot(final.id).startsAt)).toBeGreaterThanOrEqual(Date.parse(slot(semi.id).endsAt));
  });
});

describe('third-place match', () => {
  it('adds one match fed by the semifinal losers, only when asked and only with four or more', () => {
    const plain = build(8, 'single_elimination').plan.matches;
    const withBronze = build(8, 'single_elimination', { thirdPlace: true }).plan.matches;
    expect(withBronze.length).toBe(plain.length + 1);
    const bronze = withBronze.find(m => m.label === 'Third place')!;
    const semis = withBronze.filter(m => m.loserAdvancesToMatchId === bronze.id);
    expect(semis).toHaveLength(2);
    expect(bronze.participants.map(p => p.sourceMatchId).sort()).toEqual(semis.map(m => m.id).sort());
    expect(build(3, 'single_elimination', { thirdPlace: true }).plan.matches.some(m => m.label === 'Third place')).toBe(false);
  });
  it('is scheduled after both semifinals', () => {
    const matches = build(8, 'single_elimination', { thirdPlace: true }).plan.matches;
    const plan = scheduleMatches(matches, settings());
    const bronze = matches.find(m => m.label === 'Third place')!;
    const slot = (id: string) => plan.slots.find(s => s.matchId === id)!;
    for (const semi of matches.filter(m => m.loserAdvancesToMatchId === bronze.id)) {
      expect(Date.parse(slot(bronze.id).startsAt)).toBeGreaterThanOrEqual(Date.parse(slot(semi.id).endsAt));
    }
  });
});

import { areasNeeded } from '../src/lib/tournamentPlanner';
describe('areas needed', () => {
  it('rounds up to fit the day', () => {
    expect(areasNeeded(34, 8, { boutMinutes: 5, changeoverMinutes: 2 })).toBe(1);
    expect(areasNeeded(100, 4, { boutMinutes: 5, changeoverMinutes: 2 })).toBe(3);
    expect(areasNeeded(0, 8, { boutMinutes: 5, changeoverMinutes: 2 })).toBe(1);
  });
});
