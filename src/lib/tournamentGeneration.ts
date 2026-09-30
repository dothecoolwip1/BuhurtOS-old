import type { Bracket, MatchRecord, RosterEntry, ScoringConfig, UUID } from '../types';
import {
  generateDoubleElimination,
  generateRoundRobin,
  generateRoundRobinPools,
  generateSingleElimination,
  type GeneratedBracket,
  type GeneratedPools,
  type SeededEntry
} from './bracket';

export type SeedMethod = 'manual' | 'ranking' | 'season' | 'placement' | 'random';
export type PoolTiebreakCriterion = 'standing_points' | 'wins' | 'head_to_head' | 'differential' | 'points_for' | 'seed';

export interface SeedingConfig {
  method: SeedMethod;
  values?: Record<UUID, number>;
  randomSeed?: string;
}

export interface TournamentGenerationInput {
  organizationId: UUID;
  seasonId: UUID;
  eventId: UUID;
  fightCardId?: UUID;
  bracketId: UUID;
  divisionId?: UUID;
  rulesetSnapshotId?: UUID;
  category: string;
  matchType: string;
  scoringConfig: ScoringConfig;
  format: Bracket['format'];
  entries: RosterEntry[];
  seeding: SeedingConfig;
  antiFratricide: boolean;
  targetPoolSize?: number;
  qualifiersPerPool?: number;
  tiebreakPolicy?: PoolTiebreakCriterion[];
  /** Single elimination only: adds a match between the semifinal losers. */
  thirdPlace?: boolean;
}

export interface TournamentPlanPreview {
  bracketId: UUID;
  plan: GeneratedBracket | GeneratedPools;
  seededEntries: SeededEntry[];
  generationHash: string;
  warnings: string[];
  teamConflicts: string[];
  generationConfig: Record<string, unknown>;
  tiebreakPolicy: PoolTiebreakCriterion[];
}

export interface TournamentPlanValidation {
  valid: boolean;
  errors: string[];
}

const defaultTiebreakPolicy: PoolTiebreakCriterion[] = [
  'standing_points',
  'wins',
  'head_to_head',
  'differential',
  'points_for',
  'seed'
];

function hash32(value: string, seed = 2166136261): number {
  let hash = seed >>> 0;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) return '[' + value.map(stableStringify).join(',') + ']';
  if (value && typeof value === 'object') {
    return '{' + Object.entries(value as Record<string, unknown>)
      .sort(([a],[b]) => a.localeCompare(b))
      .map(([key,item]) => JSON.stringify(key) + ':' + stableStringify(item))
      .join(',') + '}';
  }
  return JSON.stringify(value);
}

function deterministicUuid(namespace: string, counter: number): UUID {
  const a = hash32(namespace + ':' + counter + ':a');
  const b = hash32(namespace + ':' + counter + ':b');
  const c = hash32(namespace + ':' + counter + ':c');
  const d = hash32(namespace + ':' + counter + ':d');
  const hex = [a,b,c,d].map(value => value.toString(16).padStart(8,'0')).join('');
  return [
    hex.slice(0,8),
    hex.slice(8,12),
    '4' + hex.slice(13,16),
    ((parseInt(hex.slice(16,18),16) & 0x3f) | 0x80).toString(16).padStart(2,'0') + hex.slice(18,20),
    hex.slice(20,32)
  ].join('-');
}

export function createDeterministicIdFactory(namespace: string): () => UUID {
  let counter = 0;
  return () => deterministicUuid(namespace, ++counter);
}

function seededRandom(seedText: string): () => number {
  let state = hash32(seedText || 'buhurtos');
  return () => {
    state += 0x6D2B79F5;
    let value = state;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function randomOrder(entries: RosterEntry[], seed: string): RosterEntry[] {
  const copy = [...entries].sort((a,b) => a.id.localeCompare(b.id));
  const random = seededRandom(seed);
  for (let index = copy.length - 1; index > 0; index -= 1) {
    const target = Math.floor(random() * (index + 1));
    [copy[index],copy[target]] = [copy[target],copy[index]];
  }
  return copy;
}

export function seedTournamentEntries(entries: RosterEntry[], config: SeedingConfig): { entries: SeededEntry[]; warnings: string[] } {
  if (entries.length < 2) throw new Error('At least two competitors are required.');
  const ids = new Set<string>();
  for (const entry of entries) {
    if (ids.has(entry.id)) throw new Error('A competitor cannot appear more than once in a generation request.');
    ids.add(entry.id);
  }

  const warnings: string[] = [];
  let ordered: RosterEntry[];

  if (config.method === 'random') {
    const seed = config.randomSeed?.trim();
    if (!seed) throw new Error('A recorded random seed is required for random seeding.');
    ordered = randomOrder(entries, seed);
  } else {
    const values = config.values ?? {};
    const missing = entries.filter(entry => !Number.isFinite(values[entry.id]));
    if (missing.length) throw new Error('Every selected competitor needs a seed value for ' + config.method + ' seeding.');

    const seen = new Map<number,string[]>();
    for (const entry of entries) {
      const value = values[entry.id];
      if (!seen.has(value)) seen.set(value,[]);
      seen.get(value)!.push(entry.displayName);
    }

    if (config.method === 'manual' || config.method === 'placement') {
      const duplicates = [...seen.entries()].filter(([,names]) => names.length > 1);
      if (duplicates.length) throw new Error('Manual and placement seed values must be unique.');
    } else {
      const ties = [...seen.entries()].filter(([,names]) => names.length > 1);
      for (const [value,names] of ties) warnings.push('Tied ' + config.method + ' value ' + value + ': ' + names.join(', ') + '. Stable roster ID is the recorded fallback.');
    }

    ordered = [...entries].sort((a,b) => {
      const left = values[a.id];
      const right = values[b.id];
      const direction = config.method === 'ranking' || config.method === 'season' ? right - left : left - right;
      return direction || a.id.localeCompare(b.id);
    });
  }

  return { entries: ordered.map((entry,index) => ({ entry, seed:index + 1 })), warnings };
}

function realParticipants(match: MatchRecord): UUID[] {
  return match.participants.filter(item => !item.isPlaceholder && item.rosterEntryId).map(item => item.rosterEntryId!);
}

export function validateTournamentPlan(plan: GeneratedBracket, selectedEntryIds: UUID[]): TournamentPlanValidation {
  const errors: string[] = [];
  const ids = new Set<string>();
  const selected = new Set(selectedEntryIds);

  if (plan.matches.length < 1) errors.push('Tournament plan contains no matches.');

  for (const match of plan.matches) {
    if (ids.has(match.id)) errors.push('Duplicate match ID: ' + match.id);
    ids.add(match.id);

    const sides = new Set<number>();
    for (const participant of match.participants) {
      if (sides.has(participant.sideIndex)) errors.push(match.label + ' contains duplicate side ' + participant.sideIndex + '.');
      sides.add(participant.sideIndex);
      if (participant.rosterEntryId && !selected.has(participant.rosterEntryId)) {
        errors.push(match.label + ' references an entrant outside the selected field.');
      }
    }
    const real = realParticipants(match);
    if (new Set(real).size !== real.length) errors.push(match.label + ' places the same competitor on both sides.');
  }

  for (const match of plan.matches) {
    const dependencies = [
      match.winnerAdvancesToMatchId,
      match.loserAdvancesToMatchId,
      ...match.participants.map(item => item.sourceMatchId)
    ].filter((id): id is UUID => Boolean(id));
    for (const target of dependencies) {
      if (target === match.id) errors.push(match.label + ' depends on itself.');
      if (!ids.has(target)) errors.push(match.label + ' references a missing match dependency.');
    }
  }

  return { valid: errors.length === 0, errors:[...new Set(errors)] };
}

function collectTeamConflicts(plan: GeneratedBracket, roster: RosterEntry[]): string[] {
  const byId = new Map(roster.map(entry => [entry.id,entry]));
  const conflicts: string[] = [];
  for (const match of plan.matches) {
    const real = realParticipants(match).map(id => byId.get(id)).filter((entry): entry is RosterEntry => Boolean(entry));
    if (real.length === 2 && real[0].teamId && real[0].teamId === real[1].teamId) {
      conflicts.push(match.label + ': ' + real[0].displayName + ' vs ' + real[1].displayName);
    }
  }
  return conflicts;
}

export function buildTournamentPreview(input: TournamentGenerationInput): TournamentPlanPreview {
  const seeded = seedTournamentEntries(input.entries,input.seeding);
  const namespace = stableStringify({
    bracketId:input.bracketId,
    eventId:input.eventId,
    format:input.format,
    entrants:seeded.entries.map(item => ({ id:item.entry.id, seed:item.seed })),
    randomSeed:input.seeding.randomSeed ?? null
  });
  const idFactory = createDeterministicIdFactory(namespace);
  const common = {
    organizationId:input.organizationId,
    seasonId:input.seasonId,
    eventId:input.eventId,
    fightCardId:input.fightCardId,
    bracketId:input.bracketId,
    category:input.category,
    matchType:input.matchType,
    entries:seeded.entries,
    scoringConfig:input.scoringConfig,
    idFactory,
    antiFratricide:input.antiFratricide
  };
  const plan = input.format === 'round_robin'
    ? generateRoundRobin(common)
    : input.format === 'pools_to_bracket'
      ? generateRoundRobinPools({ ...common, targetPoolSize:input.targetPoolSize })
      : input.format === 'double_elimination'
        ? generateDoubleElimination(common)
        : generateSingleElimination({ ...common, thirdPlace: input.thirdPlace });

  plan.matches.forEach(match => {
    match.divisionId = input.divisionId;
    match.rulesetSnapshotId = input.rulesetSnapshotId;
  });

  const validation = validateTournamentPlan(plan,input.entries.map(entry => entry.id));
  if (!validation.valid) throw new Error(validation.errors.join(' '));

  const tiebreakPolicy = input.tiebreakPolicy?.length ? input.tiebreakPolicy : defaultTiebreakPolicy;
  const teamConflicts = input.antiFratricide ? collectTeamConflicts(plan,input.entries) : [];
  const generationConfig = {
    version:1,
    seedMethod:input.seeding.method,
    seedValues:input.seeding.values ?? {},
    randomSeed:input.seeding.randomSeed ?? null,
    antiFratricide:input.antiFratricide,
    targetPoolSize:input.targetPoolSize ?? null,
    qualifiersPerPool:input.qualifiersPerPool ?? null,
    thirdPlace:Boolean(input.thirdPlace),
    tiebreakPolicy,
    entrantSeeds:seeded.entries.map(item => ({ rosterEntryId:item.entry.id, seed:item.seed }))
  };
  const generationHash = hash32(stableStringify({ generationConfig, matches:plan.matches })).toString(16).padStart(8,'0');

  const warnings = [...seeded.warnings];
  if (teamConflicts.length) warnings.push('Same-team separation is not fully feasible. Review the listed conflicts before publishing.');

  return {
    bracketId:input.bracketId,
    plan,
    seededEntries:seeded.entries,
    generationHash,
    warnings,
    teamConflicts,
    generationConfig,
    tiebreakPolicy
  };
}
