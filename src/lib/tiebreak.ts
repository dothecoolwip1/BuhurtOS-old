import { publicSupabase } from './supabase';

/**
 * Source-driven tiebreaks. The ordered steps come from tiebreak_policies (seeded from the official document) and are
 * applied only where BuhurtOS actually has the data. A step that cannot be evaluated is reported as skipped, and a tie no
 * step can break is reported as unresolved. Nothing here guesses.
 */
export interface TiebreakStep {
  key: string;
  label: string;
  appliesTo?: 'two_way_tie_only';
}

export interface TiebreakPolicy {
  authority: string;
  docVersion: string;
  steps: TiebreakStep[];
  sourceRef: string;
}

/** One finished bout between two participants (fighters, or teams when aggregating). */
export interface Bout {
  a: string;
  b: string;
  winner: 'a' | 'b' | null;
  roundsA: number;
  roundsB: number;
  hitsA: number;
  hitsB: number;
  /** BI: Buhurt and Buckler compare round victories minus losses; other duels compare hits earned to hits received. */
  compare: 'round_difference' | 'hit_ratio';
}

export interface TieResolution {
  /** Ids that were tied on points before any tiebreak. */
  ids: string[];
  /** The step that finally separated them, or undefined when it did not. */
  resolvedBy?: string;
  unresolved: boolean;
}

export interface TiebreakOutcome {
  order: string[];
  resolutions: TieResolution[];
  /** Steps that could not be evaluated because BuhurtOS has no data for them, with the reason. */
  skippedSteps: Array<{ key: string; reason: string }>;
}

const UNAVAILABLE: Record<string, string> = {
  active_vs_downed: 'BuhurtOS does not record how many fighters were still standing at the end of each round.'
};

function headToHead(pair: string[], bouts: Bout[]): string[][] {
  const [x, y] = pair;
  let xWins = 0, yWins = 0;
  for (const bout of bouts) {
    const between = (bout.a === x && bout.b === y) || (bout.a === y && bout.b === x);
    if (!between || !bout.winner) continue;
    const winnerId = bout.winner === 'a' ? bout.a : bout.b;
    if (winnerId === x) xWins++; else yWins++;
  }
  if (xWins > yWins) return [[x], [y]];
  if (yWins > xWins) return [[y], [x]];
  return [pair];
}

function roundRatioValue(id: string, bouts: Bout[], compare: Bout['compare']): number {
  let forRounds = 0, againstRounds = 0, forHits = 0, againstHits = 0;
  for (const bout of bouts) {
    if (bout.a !== id && bout.b !== id) continue;
    const mine = bout.a === id;
    forRounds += mine ? bout.roundsA : bout.roundsB; againstRounds += mine ? bout.roundsB : bout.roundsA;
    forHits += mine ? bout.hitsA : bout.hitsB; againstHits += mine ? bout.hitsB : bout.hitsA;
  }
  if (compare === 'round_difference') return forRounds - againstRounds;
  if (againstHits === 0) return forHits > 0 ? Number.POSITIVE_INFINITY : 0;
  return forHits / againstHits;
}

/** Splits a tied group into ordered subgroups by one metric (higher is better unless `lowerIsBetter`). */
function partition(group: string[], value: (id: string) => number, lowerIsBetter = false): string[][] {
  const sorted = [...group].sort((p, q) => (lowerIsBetter ? value(p) - value(q) : value(q) - value(p)));
  const out: string[][] = [];
  for (const id of sorted) {
    const last = out[out.length - 1];
    if (last && value(last[0]) === value(id)) last.push(id); else out.push([id]);
  }
  return out;
}

/**
 * Orders participants that are level on points, using the policy's steps in order. A step that separates the group
 * splits it into ordered subgroups; any subgroup still level continues with the steps after it.
 */
export function resolveTies(group: string[], bouts: Bout[], policy: TiebreakPolicy, penalties?: ReadonlyMap<string, number>): TiebreakOutcome {
  const skipped = new Map<string, string>();
  const resolutions: TieResolution[] = [];

  const settle = (ids: string[], stepIndex: number): string[] => {
    if (ids.length <= 1) return ids;
    for (let i = stepIndex; i < policy.steps.length; i++) {
      const step = policy.steps[i];
      if (step.appliesTo === 'two_way_tie_only' && ids.length !== 2) continue;
      let parts: string[][] | undefined;
      if (step.key === 'head_to_head') {
        parts = headToHead(ids, bouts);
      } else if (step.key === 'round_ratio') {
        const compare = bouts.find(b => ids.includes(b.a) || ids.includes(b.b))?.compare ?? 'hit_ratio';
        parts = partition(ids, id => roundRatioValue(id, bouts, compare));
      } else if (step.key === 'fewest_penalties') {
        if (!penalties) { skipped.set(step.key, 'Penalty records were not available for this board.'); continue; }
        parts = partition(ids, id => penalties.get(id) ?? 0, true);
      } else if (UNAVAILABLE[step.key]) {
        skipped.set(step.key, UNAVAILABLE[step.key]);
        continue;
      } else {
        skipped.set(step.key, 'BuhurtOS does not know how to evaluate this step yet.');
        continue;
      }
      if (parts.length > 1) {
        // This step is the one that actually separated the group; any subgroup still level carries on with later steps.
        resolutions.push({ ids, resolvedBy: step.key, unresolved: false });
        return parts.flatMap(part => settle(part, i + 1));
      }
    }
    resolutions.push({ ids, unresolved: true });
    return ids;
  };

  const order = settle(group, 0);
  return { order, resolutions, skippedSteps: [...skipped].map(([key, reason]) => ({ key, reason })) };
}

/** Ranks rows level on a primary key: `primaryKey` groups ties, `policy` orders each group, `fallback` is used with no policy. */
export function rankWithPolicy<T extends { id: string }>(
  rows: T[],
  primaryKey: (row: T) => number,
  fallback: (a: T, b: T) => number,
  bouts: Bout[],
  policy: TiebreakPolicy | undefined,
  penalties?: ReadonlyMap<string, number>
): { ranked: T[]; policy: TiebreakPolicy | undefined; resolutions: TieResolution[]; skippedSteps: Array<{ key: string; reason: string }> } {
  if (!policy) return { ranked: [...rows].sort(fallback), policy: undefined, resolutions: [], skippedSteps: [] };
  const byPrimary = [...rows].sort((a, b) => primaryKey(b) - primaryKey(a) || a.id.localeCompare(b.id));
  const ranked: T[] = [];
  const resolutions: TieResolution[] = [];
  const skipped = new Map<string, string>();
  for (let i = 0; i < byPrimary.length;) {
    let j = i + 1;
    while (j < byPrimary.length && primaryKey(byPrimary[j]) === primaryKey(byPrimary[i])) j++;
    const group = byPrimary.slice(i, j);
    if (group.length === 1) { ranked.push(group[0]); } else {
      const outcome = resolveTies(group.map(r => r.id), bouts, policy, penalties);
      const byId = new Map(group.map(r => [r.id, r] as const));
      ranked.push(...outcome.order.map(id => byId.get(id)!));
      resolutions.push(...outcome.resolutions);
      outcome.skippedSteps.forEach(s => skipped.set(s.key, s.reason));
    }
    i = j;
  }
  return { ranked, policy, resolutions, skippedSteps: [...skipped].map(([key, reason]) => ({ key, reason })) };
}

let policyCache: { at: number; key: string; value: TiebreakPolicy | undefined } | undefined;

/** Loads a stored policy. With no version it takes the newest one stored for the authority. */
export async function loadTiebreakPolicy(authority = 'bi', docVersion?: string): Promise<TiebreakPolicy | undefined> {
  if (!publicSupabase) return undefined;
  const key = `${authority}|${docVersion ?? ''}`;
  if (policyCache && policyCache.key === key && Date.now() - policyCache.at < 5 * 60 * 1000) return policyCache.value;
  let query = publicSupabase.from('tiebreak_policies').select('authority,doc_version,steps,source_ref').eq('authority', authority);
  if (docVersion) query = query.eq('doc_version', docVersion);
  const { data, error } = await query;
  if (error) throw error;
  const row = (data ?? [])[0] as { authority: string; doc_version: string; steps: Array<{ key: string; label: string; appliesTo?: 'two_way_tie_only' }>; source_ref: string } | undefined;
  const value = row ? { authority: row.authority, docVersion: row.doc_version, steps: row.steps ?? [], sourceRef: row.source_ref } : undefined;
  policyCache = { at: Date.now(), key, value };
  return value;
}

/** The plain-language label shown beside a board so the order is never a mystery. */
export function describeTiebreakBasis(policy: TiebreakPolicy | undefined): string {
  if (!policy) return 'Ties are ordered by point differential, then points scored, then name. No official tiebreak policy is configured for this event.';
  return `Ties are ordered by ${policy.authority.toUpperCase()} tiebreak rules (${policy.sourceRef}): ${policy.steps.map(s => s.label).join('; then ')}.`;
}
