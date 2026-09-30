import type { Bracket, MatchRecord, UUID } from '../types';
import type { CompetitionFamily } from './competitionFormats';

/**
 * Tournament planning: which structure suits a field of this size, and when and where each bout can run.
 *
 * Everything here is advice with editable defaults. Pool sizes of four to six and pools feeding a knockout are common practice in
 * sword and combat-sport events; the bout lengths are starting estimates, not rules. The governing ruleset and the organizer decide.
 */

// ---------------------------------------------------------------------------
// Structure advice
// ---------------------------------------------------------------------------

export interface StructureSuggestion {
  id: string;
  format: Bracket['format'];
  title: string;
  /** Group sizes for pool formats, largest first. Empty for plain brackets. */
  groups: number[];
  poolSize?: number;
  qualifiersPerPool?: number;
  bouts: number;
  /** Longest chain of bouts one competitor could fight, including the playoff. */
  maxBoutsPerCompetitor: number;
  minBoutsPerCompetitor: number;
  why: string;
  recommended: boolean;
}

/** Splits n into `count` groups whose sizes differ by at most one. */
export function balancedGroupSizes(entrants: number, count: number): number[] {
  const groups = Math.max(1, Math.min(count, entrants));
  const base = Math.floor(entrants / groups);
  const extra = entrants % groups;
  return Array.from({ length: groups }, (_, index) => base + (index < extra ? 1 : 0));
}

const roundRobinBouts = (size: number) => (size * (size - 1)) / 2;
const sum = (values: number[]) => values.reduce((total, value) => total + value, 0);
const nextPowerOfTwo = (n: number) => { let p = 1; while (p < n) p *= 2; return p; };

/** The pool size the generator needs so that it builds exactly `groups` pools. */
export function poolSizeForGroups(entrants: number, groups: number): number {
  return Math.max(3, Math.ceil(entrants / Math.max(1, groups)));
}

function poolsThenKnockout(entrants: number, groups: number, qualifiers: number, title: string, why: string, recommended: boolean): StructureSuggestion {
  const sizes = balancedGroupSizes(entrants, groups);
  const advancing = Math.min(entrants, sizes.length * qualifiers);
  const poolBouts = sum(sizes.map(roundRobinBouts));
  const playoffRounds = Math.ceil(Math.log2(Math.max(2, advancing)));
  return {
    id: `pools-${groups}-${qualifiers}`,
    format: 'pools_to_bracket',
    title,
    groups: sizes,
    poolSize: poolSizeForGroups(entrants, groups),
    qualifiersPerPool: qualifiers,
    bouts: poolBouts + Math.max(0, advancing - 1),
    maxBoutsPerCompetitor: Math.max(...sizes) - 1 + playoffRounds,
    minBoutsPerCompetitor: Math.min(...sizes) - 1,
    why,
    recommended
  };
}

/**
 * Ranked suggestions for a field. `family` matters because team melees are scarce, tiring bouts: teams should not face a long
 * chain of them, so pools stay small and the knockout starts sooner.
 */
export function recommendStructures(entrants: number, family: CompetitionFamily = 'duel'): StructureSuggestion[] {
  if (!Number.isFinite(entrants) || entrants < 2) return [];
  const melee = family === 'melee';
  const out: StructureSuggestion[] = [];

  if (entrants === 2) {
    return [{
      id: 'single-2', format: 'single_elimination', title: 'One match', groups: [], bouts: 1, maxBoutsPerCompetitor: 1, minBoutsPerCompetitor: 1,
      why: 'Two competitors: a single match decides it. Use a longer scoring format (best of three rounds) if you want a fairer result.', recommended: true
    }];
  }

  const single = (recommended: boolean): StructureSuggestion => ({
    id: 'single', format: 'single_elimination', title: 'Single elimination', groups: [], bouts: entrants - 1,
    maxBoutsPerCompetitor: Math.ceil(Math.log2(entrants)), minBoutsPerCompetitor: 1,
    why: entrants < 5
      ? 'Quickest. Half the field is out after one bout, so use it only when time is very short.'
      : 'Fewest bouts and a clear finish time. One bad bout ends a competitor’s day, so seeding matters.',
    recommended
  });
  const double = (recommended: boolean): StructureSuggestion => ({
    id: 'double', format: 'double_elimination', title: 'Double elimination', groups: [], bouts: 2 * entrants - 2,
    maxBoutsPerCompetitor: Math.ceil(Math.log2(entrants)) * 2, minBoutsPerCompetitor: 2,
    why: 'Everyone gets at least two bouts and a second chance. About twice the bouts of single elimination, plus a possible final reset.',
    recommended
  });
  const roundRobin = (recommended: boolean): StructureSuggestion => ({
    id: 'round-robin', format: 'round_robin', title: 'Round robin (everyone fights everyone)', groups: [entrants], bouts: roundRobinBouts(entrants),
    maxBoutsPerCompetitor: entrants - 1, minBoutsPerCompetitor: entrants - 1,
    why: 'The fairest result and the most fights per person. Bout count grows quickly, so it suits small fields.', recommended
  });

  if (entrants <= (melee ? 5 : 5)) {
    out.push(roundRobin(true), single(false));
    if (entrants >= 4) out.push(double(false));
    return out;
  }

  // Aim for pools of about four to five (three to four for melee), then a knockout from the top of each pool.
  const target = melee ? 4 : 5;
  const groups = Math.max(2, Math.round(entrants / target));
  const sizes = balancedGroupSizes(entrants, groups);
  const qualifiers = sizes.every(size => size >= 4) && entrants >= 12 ? 3 : 2;
  const advancing = sizes.length * qualifiers;
  // Keep the playoff a clean bracket where possible: prefer qualifier counts that fill 4, 8 or 16 places.
  const clean = nextPowerOfTwo(advancing) === advancing;
  out.push(poolsThenKnockout(
    entrants, groups, qualifiers,
    `${sizes.length} pools, top ${qualifiers} advance`,
    `Pools of ${sizes[sizes.length - 1]}${sizes[0] !== sizes[sizes.length - 1] ? '–' + sizes[0] : ''} give everyone at least ${Math.min(...sizes) - 1} bouts before the knockout${clean ? '' : ' (the playoff will include byes)'}. The usual format for a full event day.`,
    true
  ));
  if (groups > 2 && qualifiers === 2) out.push(poolsThenKnockout(entrants, Math.max(2, groups - 1), 2, `${Math.max(2, groups - 1)} larger pools, top 2 advance`, 'Fewer, bigger pools: more bouts each and a smaller playoff.', false));
  out.push(single(false), double(false));
  return out;
}

// ---------------------------------------------------------------------------
// Time estimates
// ---------------------------------------------------------------------------

export interface BoutTiming { boutMinutes: number; changeoverMinutes: number; minRestMinutes: number }

/** Starting estimates per match type. Rulesets differ; these are meant to be edited, not trusted. */
export function defaultTiming(matchType: string): BoutTiming {
  const type = matchType.toLowerCase();
  if (type === '3v3') return { boutMinutes: 12, changeoverMinutes: 5, minRestMinutes: 30 };
  if (type === '5v5' || type === '10v10') return { boutMinutes: 15, changeoverMinutes: 5, minRestMinutes: 30 };
  if (/^(12|16|21)v/.test(type)) return { boutMinutes: 25, changeoverMinutes: 8, minRestMinutes: 45 };
  if (type === 'profight') return { boutMinutes: 16, changeoverMinutes: 5, minRestMinutes: 20 };
  if (type === 'marathon') return { boutMinutes: 30, changeoverMinutes: 10, minRestMinutes: 30 };
  if (type === 'triathlon') return { boutMinutes: 10, changeoverMinutes: 4, minRestMinutes: 15 };
  return { boutMinutes: 5, changeoverMinutes: 2, minRestMinutes: 10 };
}

/** Rough wall-clock length for a bout count on N areas, before any rest conflicts. */
export function estimateMinutes(bouts: number, areas: number, timing: Pick<BoutTiming, 'boutMinutes' | 'changeoverMinutes'>): number {
  const slot = timing.boutMinutes + timing.changeoverMinutes;
  return Math.ceil(bouts / Math.max(1, areas)) * slot;
}

export function formatDuration(minutes: number): string {
  if (minutes < 60) return `${minutes} min`;
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  return rest ? `${hours} h ${rest} min` : `${hours} h`;
}

// ---------------------------------------------------------------------------
// Scheduling
// ---------------------------------------------------------------------------

export interface ScheduleBreak { label: string; startsAt: string; minutes: number }

export interface ScheduleSettings extends BoutTiming {
  startsAt: string;
  areaIds: UUID[];
  breaks?: ScheduleBreak[];
  /** If set, a plan that finishes later than this gets a warning. */
  dayEndsAt?: string;
}

export interface ScheduleSlot {
  matchId: UUID;
  areaId: UUID;
  startsAt: string;
  endsAt: string;
  order: number;
  label: string;
}

export interface SchedulePlan {
  slots: ScheduleSlot[];
  finishesAt?: string;
  warnings: string[];
  perArea: Record<UUID, { bouts: number; busyMinutes: number }>;
  /** Shortest gap any competitor gets between two of their own bouts, when known. */
  shortestRestMinutes?: number;
}

type SchedulableMatch = Pick<MatchRecord, 'id' | 'label' | 'stage' | 'status' | 'scheduledOrder' | 'participants' | 'resultSummary'> &
  Partial<Pick<MatchRecord, 'bracketRound' | 'winnerAdvancesToMatchId' | 'loserAdvancesToMatchId'>>;

const MINUTE = 60_000;
const stageRank: Record<string, number> = { pool: 0, bracket: 1, showcase: 2, final: 3 };

function isRealBout(match: SchedulableMatch): boolean {
  if (match.resultSummary && (match.resultSummary as { resultType?: string }).resultType === 'bye') return false;
  return match.status !== 'cancelled';
}

/**
 * Greedy list scheduling. At each step every bout whose feeder bouts are already placed is a candidate; the one that can start
 * soonest goes on the area that frees up first. That naturally spreads a competitor's bouts apart instead of stacking them.
 *
 * Guarantees: a bout never starts before the bouts feeding it have ended plus the rest time; nobody is in two bouts at once or
 * with less than the minimum rest (when the plan is feasible, otherwise it is reported); nothing runs through a break.
 */
export function scheduleMatches(matches: SchedulableMatch[], settings: ScheduleSettings): SchedulePlan {
  const warnings: string[] = [];
  const areas = settings.areaIds.length ? settings.areaIds : [];
  const start = new Date(settings.startsAt).getTime();
  if (!areas.length) return { slots: [], warnings: ['Choose at least one fighting area.'], perArea: {} };
  if (Number.isNaN(start)) return { slots: [], warnings: ['Enter a valid start time.'], perArea: {} };

  const bout = Math.max(1, settings.boutMinutes) * MINUTE;
  const changeover = Math.max(0, settings.changeoverMinutes) * MINUTE;
  const rest = Math.max(0, settings.minRestMinutes) * MINUTE;
  const breaks = (settings.breaks ?? [])
    .map(item => ({ label: item.label, from: new Date(item.startsAt).getTime(), to: new Date(item.startsAt).getTime() + Math.max(0, item.minutes) * MINUTE }))
    .filter(item => !Number.isNaN(item.from) && item.to > item.from)
    .sort((a, b) => a.from - b.from);

  const real = matches.filter(isRealBout);
  const byId = new Map(real.map(match => [match.id, match]));
  const feeders = new Map<UUID, UUID[]>();
  for (const match of real) {
    const list = new Set<UUID>();
    for (const participant of match.participants) if (participant.sourceMatchId && byId.has(participant.sourceMatchId)) list.add(participant.sourceMatchId);
    feeders.set(match.id, [...list]);
  }
  for (const match of real) {
    for (const target of [match.winnerAdvancesToMatchId, match.loserAdvancesToMatchId]) {
      if (target && byId.has(target)) {
        const list = feeders.get(target) ?? [];
        if (!list.includes(match.id)) list.push(match.id);
        feeders.set(target, list);
      }
    }
  }

  const areaFree = new Map<UUID, number>(areas.map(id => [id, start]));
  const competitorFree = new Map<string, number>();
  const competitorLast = new Map<string, { start: number; end: number }>();
  const ends = new Map<UUID, number>();
  const placed = new Set<UUID>();
  const slots: ScheduleSlot[] = [];
  let shortestRest: number | undefined;

  const afterBreaks = (from: number): number => {
    let t = from;
    for (const item of breaks) if (t < item.to && t + bout > item.from) t = item.to;
    return t;
  };

  const competitorsOf = (match: SchedulableMatch) => match.participants.map(p => p.rosterEntryId).filter((id): id is string => Boolean(id));
  const ordered = [...real].sort((a, b) =>
    (stageRank[a.stage] ?? 1) - (stageRank[b.stage] ?? 1) || (a.bracketRound ?? 0) - (b.bracketRound ?? 0) || a.scheduledOrder - b.scheduledOrder);

  const remaining = new Set(ordered.map(match => match.id));
  while (remaining.size) {
    let best: { match: SchedulableMatch; area: UUID; at: number } | undefined;
    for (const match of ordered) {
      if (!remaining.has(match.id)) continue;
      const needs = feeders.get(match.id) ?? [];
      if (needs.some(id => !placed.has(id))) continue;
      let earliest = start;
      for (const id of needs) earliest = Math.max(earliest, (ends.get(id) ?? start) + rest);
      for (const id of competitorsOf(match)) earliest = Math.max(earliest, competitorFree.get(id) ?? start);
      let area = areas[0];
      for (const candidate of areas) if ((areaFree.get(candidate) ?? start) < (areaFree.get(area) ?? start)) area = candidate;
      const at = afterBreaks(Math.max(earliest, areaFree.get(area) ?? start));
      if (!best || at < best.at) best = { match, area, at };
    }
    if (!best) {
      warnings.push('Some bouts could not be placed because their feeder bouts form a loop. Regenerate the bracket.');
      break;
    }
    const { match, area, at } = best;
    const end = at + bout;
    slots.push({ matchId: match.id, areaId: area, startsAt: new Date(at).toISOString(), endsAt: new Date(end).toISOString(), order: slots.length + 1, label: match.label });
    areaFree.set(area, end + changeover);
    ends.set(match.id, end);
    for (const id of competitorsOf(match)) {
      const previous = competitorLast.get(id);
      if (previous) {
        const gap = Math.round((at - previous.end) / MINUTE);
        shortestRest = shortestRest === undefined ? gap : Math.min(shortestRest, gap);
      }
      competitorLast.set(id, { start: at, end });
      competitorFree.set(id, end + rest);
    }
    placed.add(match.id);
    remaining.delete(match.id);
  }

  slots.sort((a, b) => a.startsAt.localeCompare(b.startsAt) || areas.indexOf(a.areaId) - areas.indexOf(b.areaId));
  slots.forEach((slot, index) => { slot.order = index + 1; });

  const finishes = slots.reduce((latest, slot) => Math.max(latest, new Date(slot.endsAt).getTime()), 0);
  const perArea: SchedulePlan['perArea'] = Object.fromEntries(areas.map(id => [id, { bouts: 0, busyMinutes: 0 }]));
  for (const slot of slots) {
    perArea[slot.areaId].bouts += 1;
    perArea[slot.areaId].busyMinutes += settings.boutMinutes + settings.changeoverMinutes;
  }

  if (shortestRest !== undefined && shortestRest < settings.minRestMinutes) {
    warnings.push(`Some competitors get only ${shortestRest} minutes between bouts (you asked for ${settings.minRestMinutes}). Add an area, shorten the day’s plan, or lower the rest time.`);
  }
  if (settings.dayEndsAt) {
    const limit = new Date(settings.dayEndsAt).getTime();
    if (!Number.isNaN(limit) && finishes > limit) warnings.push(`This plan finishes at ${new Date(finishes).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}, after your ${new Date(limit).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })} cut-off. Add an area or choose a faster structure.`);
  }
  if (areas.length > 1) {
    const counts = areas.map(id => perArea[id].bouts);
    if (Math.max(...counts) - Math.min(...counts) > Math.ceil(slots.length / areas.length) / 2 + 1) warnings.push('Bouts are unevenly spread across areas, usually because one round is waiting on another. This is normal near the final.');
  }

  return { slots, finishesAt: finishes ? new Date(finishes).toISOString() : undefined, warnings, perArea, shortestRestMinutes: shortestRest };
}

/** Puts the planned area and order onto the matches (the stored draw itself is untouched). */
export function applySchedule<T extends { id: UUID; fightCardId?: UUID; scheduledOrder: number }>(matches: T[], plan: SchedulePlan): T[] {
  const byMatch = new Map(plan.slots.map(slot => [slot.matchId, slot]));
  const unplaced = matches.filter(match => !byMatch.has(match.id));
  let next = plan.slots.length;
  return matches.map(match => {
    const slot = byMatch.get(match.id);
    if (slot) return { ...match, fightCardId: slot.areaId, scheduledOrder: slot.order };
    next += 1;
    return unplaced.includes(match) ? { ...match, scheduledOrder: next } : match;
  });
}

/** Compact record stored with the bracket so the planned times survive publishing. */
export function scheduleMetadata(plan: SchedulePlan, settings: ScheduleSettings) {
  return {
    version: 1,
    settings: {
      startsAt: settings.startsAt, boutMinutes: settings.boutMinutes, changeoverMinutes: settings.changeoverMinutes,
      minRestMinutes: settings.minRestMinutes, areaIds: settings.areaIds, breaks: settings.breaks ?? []
    },
    finishesAt: plan.finishesAt,
    slots: plan.slots.map(slot => ({ matchId: slot.matchId, areaId: slot.areaId, startsAt: slot.startsAt, endsAt: slot.endsAt, order: slot.order }))
  };
}
