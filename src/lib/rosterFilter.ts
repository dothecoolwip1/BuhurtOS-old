import type { RosterEntry } from '../types';
import { checkCompliance, checkPhysicalCompliance } from './compliance';

export type RosterStatus = 'cleared' | 'ready' | 'blocked';
export type RosterFilterKey = 'all' | RosterStatus | 'unregistered';

/** One word for where an entry stands: cleared to compete, ready for the marshal, or still blocked. */
export function rosterStatus(entry: RosterEntry): RosterStatus {
  if (checkCompliance(entry).eligible) return 'cleared';
  return checkPhysicalCompliance(entry).eligible ? 'ready' : 'blocked';
}

export function rosterCounts(entries: RosterEntry[]): Record<RosterFilterKey, number> {
  const counts: Record<RosterFilterKey, number> = { all: entries.length, cleared: 0, ready: 0, blocked: 0, unregistered: 0 };
  for (const entry of entries) {
    counts[rosterStatus(entry)] += 1;
    if (entry.attendanceStatus !== 'approved') counts.unregistered += 1;
  }
  return counts;
}

/** Filters by status and by a name or team search (case-insensitive, any part of the name). */
export function filterRoster(entries: RosterEntry[], filter: RosterFilterKey, query: string, teamName: (id?: string) => string = () => ''): RosterEntry[] {
  const needle = query.trim().toLowerCase();
  return entries.filter(entry => {
    if (filter === 'unregistered' ? entry.attendanceStatus === 'approved' : filter !== 'all' && rosterStatus(entry) !== filter) return false;
    if (!needle) return true;
    return entry.displayName.toLowerCase().includes(needle) || teamName(entry.teamId).toLowerCase().includes(needle);
  });
}
