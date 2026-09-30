import { publicSupabase, supabase } from './supabase';
import type { FormatSelection } from './tournamentStructure';

/** One tournament inside an event. See docs/COMPETITION_MODEL_DECISION.md for why this is not a "division". */
export interface EventCompetition {
  id: string;
  eventId: string;
  name: string;
  league: 'buhurt' | 'duels' | 'outrance' | 'other';
  tier?: 'exhibition' | 'source' | 'classic' | 'regional' | 'conference' | 'custom';
  tierClassification?: 'division_1' | 'division_2' | 'open';
  classification?: 'men' | 'women' | 'open' | 'mixed';
  categoryId?: string;
  authority: string;
  rulesVersion?: string;
  ranked: boolean;
  entrantCap?: number;
  status: 'draft' | 'open' | 'running' | 'completed' | 'cancelled';
  formatSelection: Partial<FormatSelection>;
  externalApproval: { approvedBy?: string; date?: string; reference?: string };
}

export type EventCompetitionInput = Partial<Omit<EventCompetition, 'id' | 'eventId'>>;

/** Explicit columns: anonymous visitors cannot read the creator columns, so a select-star would be refused. */
const COLUMNS = 'id,event_id,name,league,tier,tier_classification,classification,category_id,authority,rules_version,ranked,entrant_cap,status,format_selection,external_approval,sort_order';

function map(row: any): EventCompetition {
  return {
    id: row.id, eventId: row.event_id, name: row.name, league: row.league, tier: row.tier ?? undefined,
    tierClassification: row.tier_classification ?? undefined, classification: row.classification ?? undefined,
    categoryId: row.category_id ?? undefined, authority: row.authority ?? 'bi', rulesVersion: row.rules_version ?? undefined,
    ranked: Boolean(row.ranked), entrantCap: row.entrant_cap ?? undefined, status: row.status,
    formatSelection: row.format_selection ?? {}, externalApproval: row.external_approval ?? {}
  };
}

/** Public callers see published events' competitions; organizers also see drafts. */
export async function listEventCompetitions(eventId: string, asOrganizer = false): Promise<EventCompetition[]> {
  const client = asOrganizer ? supabase : publicSupabase;
  if (!client) return [];
  const { data, error } = await client.from('event_competitions').select(COLUMNS).eq('event_id', eventId).order('sort_order');
  if (error) throw error;
  return (data ?? []).map(map);
}

function payload(input: EventCompetitionInput): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  if (input.name !== undefined) out.name = input.name;
  if (input.league !== undefined) out.league = input.league;
  if ('tier' in input) out.tier = input.tier ?? '';
  if ('tierClassification' in input) out.tierClassification = input.tierClassification ?? '';
  if ('classification' in input) out.classification = input.classification ?? '';
  if ('categoryId' in input) out.categoryId = input.categoryId ?? '';
  if (input.authority !== undefined) out.authority = input.authority;
  if ('rulesVersion' in input) out.rulesVersion = input.rulesVersion ?? '';
  if (input.ranked !== undefined) out.ranked = input.ranked;
  if ('entrantCap' in input) out.entrantCap = input.entrantCap == null ? '' : String(input.entrantCap);
  if (input.status !== undefined) out.status = input.status;
  if (input.formatSelection !== undefined) out.formatSelection = input.formatSelection;
  if (input.externalApproval !== undefined) out.externalApproval = input.externalApproval;
  return out;
}

export async function saveEventCompetition(eventId: string, id: string | null, input: EventCompetitionInput): Promise<string> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { data, error } = await supabase.rpc('upsert_event_competition', { p_event: eventId, p_id: id, p_payload: payload(input) });
  if (error) throw error;
  return String(data);
}

export async function deleteEventCompetition(id: string): Promise<void> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { error } = await supabase.rpc('delete_event_competition', { p_id: id });
  if (error) throw error;
}

/** Plain-language one-liner, for example "Men's 5v5 Melee · Classic Division 1 · ranked". */
export function describeCompetition(c: EventCompetition, categoryName?: string): string {
  const tier = c.tier ? ({ exhibition: 'Exhibition', source: 'Source', classic: 'Classic', regional: 'Regional', conference: 'Conference', custom: 'Organization-defined' }[c.tier]) : 'No tier chosen';
  const division = c.tierClassification ? ' ' + ({ division_1: 'Division 1', division_2: 'Division 2', open: 'Open' }[c.tierClassification]) : '';
  const who = c.classification ? ({ men: "Men's", women: "Women's", open: 'Open', mixed: 'Mixed' }[c.classification]) + ' ' : '';
  return `${who}${categoryName ?? c.league} · ${tier}${division} · ${c.ranked ? 'ranked' : 'unranked'}`;
}
