import type { GeneratedBracket } from './bracket';
import type { Bracket, EventRecord, RosterEntry } from '../types';
import { supabase } from './supabase';

export interface TournamentBracketSummary {
  id: string;
  eventId: string;
  divisionId?: string;
  name: string;
  format: Bracket['format'];
  category: string;
  generationState: 'published' | 'superseded';
  generationMethod?: string;
  generationHash?: string;
  publishedAt?: string;
}

export async function listTournamentBrackets(eventId: string): Promise<TournamentBracketSummary[]> {
  if (!supabase) {
    const rows = JSON.parse(localStorage.getItem('buhurtos-demo-brackets') ?? '[]') as any[];
    return rows
      .filter(row => row.eventId === eventId)
      .map(row => ({
        id: row.id,
        eventId: row.eventId,
        divisionId: row.divisionId,
        name: row.name,
        format: row.format,
        category: row.category,
        generationState: row.generationState ?? 'published',
        generationMethod: row.metadata?.generationConfig?.seedMethod,
        generationHash: row.metadata?.generationHash,
        publishedAt: row.publishedAt
      }));
  }
  const { data, error } = await supabase
    .from('brackets')
    .select('id,event_id,division_id,name,format,category,generation_state,generation_method,generation_hash,published_at')
    .eq('event_id',eventId)
    .order('created_at',{ ascending:false });
  if (error) throw error;
  return (data ?? []).map((row:any) => ({
    id:row.id,
    eventId:row.event_id,
    divisionId:row.division_id ?? undefined,
    name:row.name,
    format:row.format,
    category:row.category,
    generationState:row.generation_state,
    generationMethod:row.generation_method ?? undefined,
    generationHash:row.generation_hash ?? undefined,
    publishedAt:row.published_at ?? undefined
  }));
}

export async function addGhostFighter(event: EventRecord, displayName: string, teamId?: string): Promise<RosterEntry> {
  const row: RosterEntry = {
    id: crypto.randomUUID(), organizationId: event.organizationId, eventId: event.id, teamId, entryType: 'ghost_fighter', displayName,
    checkedIn: false, armorCleared: false, medicalCleared: false, waiverConfirmed: false, weighInCleared: false, attendanceStatus: 'registered'
  };
  if (!supabase) {
    const key = 'buhurtos-demo-ghosts';
    const current = JSON.parse(localStorage.getItem(key) ?? '[]');
    localStorage.setItem(key, JSON.stringify([...current, row]));
    return row;
  }
  const { data, error } = await supabase.from('event_roster_entries').insert({ organization_id: event.organizationId, event_id: event.id, team_id: teamId ?? null, entry_type: 'ghost_fighter', display_name: displayName, ghost_original_name: displayName }).select('*').single();
  if (error) throw error;
  return { ...row, id: data.id };
}

export async function saveBracketPlan(event: EventRecord, plan: GeneratedBracket, options: { id: string; name: string; fightCardId?: string; divisionId?: string; category: string; format?: Bracket['format']; metadata?: Record<string, unknown> }): Promise<string> {
  if (!supabase) {
    const existing = JSON.parse(localStorage.getItem('buhurtos-demo-bracket-matches') ?? '[]');
    if (existing.some((match: any) => match.bracketId === options.id)) throw new Error('Published demo brackets cannot be regenerated in place. Create a new preview instead.');
    localStorage.setItem('buhurtos-demo-bracket-matches', JSON.stringify([...existing, ...plan.matches]));
    const brackets = JSON.parse(localStorage.getItem('buhurtos-demo-brackets') ?? '[]') as any[];
    const supersedes = typeof options.metadata?.supersedesBracketId === 'string' ? options.metadata.supersedesBracketId : undefined;
    if (supersedes) {
      const prior = brackets.find(row => row.id === supersedes && row.eventId === event.id && (row.generationState ?? 'published') === 'published');
      if (!prior) throw new Error('Replacement bracket could not be found.');
      const priorMatches = existing.filter((match:any) => match.bracketId === supersedes);
      const hasRecordedCompetition = priorMatches.some((match:any) =>
        ['active','completed','forfeit'].includes(match.status)
        || (match.status === 'finalized' && match.resultSummary?.resultType !== 'bye')
        || (Array.isArray(match.rounds) && match.rounds.length > 0)
      );
      if (hasRecordedCompetition) throw new Error('Tournament has recorded competition and cannot be regenerated.');
      prior.generationState = 'superseded';
      for (const match of existing) {
        if (match.bracketId === supersedes && (['scheduled','on_deck','in_the_hole'].includes(match.status) || match.resultSummary?.resultType === 'bye')) {
          match.status = 'cancelled';
        }
      }
      localStorage.setItem('buhurtos-demo-bracket-matches', JSON.stringify([...existing, ...plan.matches]));
    } else {
      localStorage.setItem('buhurtos-demo-bracket-matches', JSON.stringify([...existing, ...plan.matches]));
    }
    localStorage.setItem('buhurtos-demo-brackets', JSON.stringify([...brackets, {
      id: options.id,
      eventId: event.id,
      fightCardId: options.fightCardId,
      divisionId: options.divisionId,
      name: options.name,
      format: options.format ?? 'single_elimination',
      category: options.category,
      metadata: options.metadata ?? {},
      generationState:'published',
      publishedAt: new Date().toISOString()
    }]));
    return options.id;
  }
  const { data, error } = await supabase.rpc('save_bracket_plan', {
    p_bracket: { id: options.id, eventId: event.id, fightCardId: options.fightCardId ?? '', divisionId: options.divisionId ?? '', name: options.name, format: options.format ?? 'single_elimination', category: options.category, metadata: { generatedAt: new Date().toISOString(), antiFratricide: true, ...(options.metadata ?? {}) } },
    p_matches: plan.matches
  });
  if (error) throw error;
  return data as string;
}
