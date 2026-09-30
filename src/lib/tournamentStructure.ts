import { publicSupabase } from './supabase';

/**
 * Structure guidance comes from versioned reference data (tournament_format_templates and ruleset_tier_requirements),
 * seeded from the official BI documents. Nothing here hard-codes a BI format: change the data, not this file.
 */
export interface FormatTemplate {
  authority: string;
  docVersion: string;
  optionKey: string;
  title: string;
  minEntrants: number;
  maxEntrants: number | null;
  structure: { kind: string; pools?: number; poolSizeMin?: number; poolSizeMax?: number; advancePerPool?: number; finals?: string; finalists?: number; thirdPlaceMatch?: boolean; tiebreakerRound?: boolean };
  recommended: boolean;
  caution?: string;
  sourceRef: string;
}

export interface TierRequirement {
  authority: string;
  docVersion: string;
  tier: 'exhibition' | 'source' | 'classic' | 'regional' | 'conference';
  tierLabel: string;
  leadDays: number | null;
  requirements: Record<string, unknown>;
  sourceRef: string;
}

export interface CompetitionCategory {
  id: string;
  authority: string;
  league: 'buhurt' | 'duels' | 'outrance' | 'other';
  key: string;
  displayName: string;
  teamSize?: number;
  rankedCapable: boolean;
  active: boolean;
  sourceRef?: string;
}

export interface ReferenceData {
  templates: FormatTemplate[];
  tiers: TierRequirement[];
  categories: CompetitionCategory[];
}

let cache: { at: number; value: ReferenceData } | undefined;
const CACHE_MS = 5 * 60 * 1000;

export async function loadCompetitionReferenceData(): Promise<ReferenceData> {
  if (cache && Date.now() - cache.at < CACHE_MS) return cache.value;
  if (!publicSupabase) return { templates: [], tiers: [], categories: [] };
  const [templates, tiers, categories] = await Promise.all([
    publicSupabase.from('tournament_format_templates').select('*').order('min_entrants'),
    publicSupabase.from('ruleset_tier_requirements').select('*'),
    publicSupabase.from('competition_categories').select('*').eq('active', true).order('display_name')
  ]);
  if (templates.error) throw templates.error;
  if (tiers.error) throw tiers.error;
  if (categories.error) throw categories.error;
  const value: ReferenceData = {
    templates: (templates.data ?? []).map((row: any) => ({
      authority: row.authority, docVersion: row.doc_version, optionKey: row.option_key, title: row.title,
      minEntrants: row.min_entrants, maxEntrants: row.max_entrants ?? null, structure: row.structure ?? { kind: 'unknown' },
      recommended: Boolean(row.recommended), caution: row.caution ?? undefined, sourceRef: row.source_ref
    })),
    tiers: (tiers.data ?? []).map((row: any) => ({
      authority: row.authority, docVersion: row.doc_version, tier: row.tier, tierLabel: row.tier_label,
      leadDays: row.lead_days ?? null, requirements: row.requirements ?? {}, sourceRef: row.source_ref
    })),
    categories: (categories.data ?? []).map((row: any) => ({
      id: row.id, authority: row.authority, league: row.league, key: row.key, displayName: row.display_name,
      teamSize: row.team_size ?? undefined, rankedCapable: Boolean(row.ranked_capable), active: Boolean(row.active), sourceRef: row.source_ref ?? undefined
    }))
  };
  cache = { at: Date.now(), value };
  return value;
}

export interface StructureAdvice {
  entrants: number;
  /** Options whose entrant range contains the count. Ranges overlap at 6, 12, 16 and 20 in the source, so both sets may apply. */
  options: FormatTemplate[];
  note?: string;
}

/** Which documented structures apply to this many entrants. */
export function adviseStructure(templates: FormatTemplate[], entrants: number): StructureAdvice {
  if (!Number.isFinite(entrants) || entrants < 1) return { entrants, options: [], note: 'Enter how many teams or competitors are entered.' };
  const fits = templates.filter(t => entrants >= t.minEntrants && (t.maxEntrants == null || entrants <= t.maxEntrants));
  if (fits.length > 0) return { entrants, options: fits };
  const lowest = Math.min(...templates.map(t => t.minEntrants));
  const highest = templates.reduce((max, t) => Math.max(max, t.maxEntrants ?? t.minEntrants), 0);
  if (templates.length > 0 && entrants < lowest) {
    return { entrants, options: [], note: `The document gives no structure below ${lowest} entrants. You can still run the competition; record your choice as an organizer decision.` };
  }
  if (templates.length > 0 && entrants > highest) {
    return { entrants, options: templates.filter(t => t.maxEntrants === highest), note: `For more than ${highest} entrants the document says to continue the same examples in proportion. The options shown are the largest documented ones; adjust pool counts and record your choice as an organizer decision.` };
  }
  return { entrants, options: [] };
}

/** One readable line for a structure. */
export function describeStructure(template: FormatTemplate): string {
  const s = template.structure;
  if (s.kind === 'round_robin') return 'Everyone plays everyone the same number of times; results by matches won.';
  if (s.kind === 'pools') {
    const pools = s.pools ? `${s.pools} pools` : 'Pools';
    const size = s.poolSizeMin && s.poolSizeMax ? ` of ${s.poolSizeMin}-${s.poolSizeMax}` : '';
    const advance = s.advancePerPool ? `top ${s.advancePerPool} from each pool advance` : 'the top entrants advance';
    const finals = s.finals === 'single_elimination' ? `a ${s.finalists ?? ''}-team single-elimination bracket${s.thirdPlaceMatch ? ' with a third-place match' : ''}`.replace('  ', ' ')
      : s.finals === 'round_robin' ? `a ${s.finalists ?? ''}-team round robin${s.tiebreakerRound ? ' with a tiebreaker round' : ''}`.replace('  ', ' ') : 'a final stage';
    return `${pools}${size}; ${advance}; then ${finals}.`;
  }
  return template.title;
}

export interface LeadTimeAdvice {
  status: 'ok' | 'late' | 'none';
  message: string;
  daysUntilEvent?: number;
}

/** Advisory only: submission lead times are the authority's rule, and approval happens outside BuhurtOS. */
export function leadTimeAdvice(tier: TierRequirement | undefined, eventStart: Date | string | undefined, now: Date = new Date()): LeadTimeAdvice {
  if (!tier || tier.leadDays == null) return { status: 'none', message: tier ? `${tier.tierLabel} tournaments have no submission lead time in ${tier.sourceRef}.` : 'Choose a tier to see its requirements.' };
  const start = eventStart ? new Date(eventStart) : undefined;
  if (!start || Number.isNaN(start.getTime())) return { status: 'none', message: `${tier.tierLabel} tournaments must be submitted ${tier.leadDays} days ahead. Set the event date to check this.` };
  const days = Math.floor((start.getTime() - now.getTime()) / 86400000);
  if (days < tier.leadDays) {
    return { status: 'late', daysUntilEvent: days, message: `${tier.tierLabel} tournaments must be submitted ${tier.leadDays} days ahead (${tier.sourceRef}). This event is ${Math.max(days, 0)} days away, so the submission window may already have passed. Check with the authority.` };
  }
  return { status: 'ok', daysUntilEvent: days, message: `${tier.tierLabel} tournaments must be submitted ${tier.leadDays} days ahead. You have ${days - tier.leadDays} days left to submit.` };
}

/** BI Tournament Structure §1.1.1: registration should close at least 15 days before the event. */
export function registrationCloseAdvice(eventStart: Date | string | undefined, registrationClosesAt: Date | string | undefined, minimumDays = 15): string | undefined {
  if (!eventStart || !registrationClosesAt) return undefined;
  const start = new Date(eventStart).getTime();
  const closes = new Date(registrationClosesAt).getTime();
  if (Number.isNaN(start) || Number.isNaN(closes)) return undefined;
  const days = Math.floor((start - closes) / 86400000);
  return days < minimumDays ? `Registration closes ${Math.max(days, 0)} days before the event. BI Tournament Structure asks for at least ${minimumDays} days so the event can be planned.` : undefined;
}

export interface FormatSelection {
  rulesVersion: string;
  entrantCount: number;
  optionKey?: string;
  generatedAt: string;
  override: boolean;
  overrideReason?: string;
}

/** The record stored with a competition: rules version, entrant count, selected format, timestamp, override and why. */
export function buildFormatSelection(input: { rulesVersion: string; entrantCount: number; option?: FormatTemplate; advice: StructureAdvice; overrideReason?: string; now?: Date }): FormatSelection {
  const { option, advice } = input;
  const offered = option ? advice.options.some(o => o.optionKey === option.optionKey) : false;
  const override = !offered || Boolean(option && !option.recommended);
  return {
    rulesVersion: input.rulesVersion, entrantCount: input.entrantCount, optionKey: option?.optionKey,
    generatedAt: (input.now ?? new Date()).toISOString(), override, overrideReason: override ? (input.overrideReason?.trim() || undefined) : undefined
  };
}

/** An override must say why. Returns a message when it does not. */
export function overrideProblem(selection: FormatSelection): string | undefined {
  return selection.override && !selection.overrideReason ? 'Say why you are not following the documented structure.' : undefined;
}

export const tierLabels: Record<string, string> = {
  exhibition: 'Exhibition', source: 'Source', classic: 'Classic', regional: 'Regional', conference: 'Conference', custom: 'Organization-defined'
};
export const tierClassificationLabels: Record<string, string> = { division_1: 'Division 1', division_2: 'Division 2', open: 'Open' };
export const leagueLabels: Record<string, string> = { buhurt: 'Buhurt (group fight)', duels: 'Duels', outrance: 'Outrance / Profights', other: 'Other' };
export const classificationLabels: Record<string, string> = { men: "Men's", women: "Women's", open: 'Open', mixed: 'Mixed' };
