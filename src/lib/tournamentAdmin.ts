import type { RosterEntry } from '../types';
import { supabase } from './supabase';

export async function setTournamentDisqualification(
  entry: RosterEntry,
  disqualified: boolean,
  reason?: string
): Promise<void> {
  if (disqualified && !reason?.trim()) throw new Error('Disqualification reason is required.');

  if (!supabase) {
    const overrides = JSON.parse(localStorage.getItem('buhurtos-demo-roster-overrides') ?? '{}');
    overrides[entry.id] = {
      ...(overrides[entry.id] ?? {}),
      competitionCleared: disqualified ? false : entry.competitionCleared,
      metadata: {
        ...(entry.metadata ?? {}),
        ...(overrides[entry.id]?.metadata ?? {}),
        tournamentDisqualified: disqualified,
        tournamentDisqualificationReason: disqualified ? reason?.trim() : null,
        tournamentDisqualifiedAt: disqualified ? new Date().toISOString() : null
      }
    };
    localStorage.setItem('buhurtos-demo-roster-overrides',JSON.stringify(overrides));
    return;
  }

  if (!entry.updatedAt) throw new Error('Roster version is missing. Reload before changing disqualification.');
  const { error } = await supabase.rpc('set_tournament_disqualification_guarded',{
    p_roster_entry_id:entry.id,
    p_expected_updated_at:entry.updatedAt,
    p_disqualified:disqualified,
    p_reason:disqualified ? reason?.trim() : null
  });
  if (error) throw error;
}
