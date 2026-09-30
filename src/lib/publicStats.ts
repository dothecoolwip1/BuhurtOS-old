import { publicSupabase } from './supabase';
import { reconcileTeamRecords, type CanonicalTeamCard, type EventStats, type RecordStats, type SourceKind, type SourcedTeamRecord } from './canonicalStats';

export type PublicTeamStats = Pick<RecordStats, 'matches' | 'wins' | 'losses' | 'draws' | 'pointsFor' | 'pointsAgainst' | 'events'>;

export type PublicTeamProvenanceRow = {
  teamId: string;
  sourceKind: SourceKind;
  sourceRecordKey: string;
  sourceUrl: string;
  sourceTeamName: string;
  sourceLocation?: string;
  sourceWebsiteUrl?: string;
  sourcePriority: number;
  verifiedAt?: string;
  lastSyncedAt?: string;
  isAlias: boolean;
};

/** The stats layer is not installed on this backend (function missing): "unavailable", not a failure. */
export function isStatsLayerMissing(error: { code?: string; message?: string } | null | undefined): boolean {
  if (!error) return false;
  return error.code === 'PGRST202' || error.code === '42883' || /could not find the function|function .* does not exist/i.test(error.message ?? '');
}

const CACHE_MS = 2 * 60 * 1000;
const cache = new Map<string, { at: number; value: unknown }>();

async function cached<T>(key: string, load: () => Promise<T>): Promise<T> {
  const hit = cache.get(key);
  if (hit && Date.now() - hit.at < CACHE_MS) return hit.value as T;
  const value = await load();
  cache.set(key, { at: Date.now(), value });
  return value;
}

/**
 * Official native team record from the database. Resolves undefined when the backend has no stats layer or no record yet;
 * rejects when the request itself failed, so callers can say "could not load" instead of implying there is nothing to show.
 */
export async function loadOfficialTeamStats(teamId: string): Promise<PublicTeamStats | undefined> {
  if (!publicSupabase) return undefined;
  return cached('team-stats:' + teamId, async () => {
    const { data, error } = await publicSupabase!.rpc('official_team_stats', { p_team_id: teamId });
    if (error) { if (isStatsLayerMissing(error)) return undefined; throw error; }
    const row = Array.isArray(data) ? data[0] : data;
    if (!row) return undefined;
    return {
      matches: Number(row.matches ?? 0), wins: Number(row.wins ?? 0), losses: Number(row.losses ?? 0), draws: Number(row.draws ?? 0),
      pointsFor: Number(row.points_for ?? 0), pointsAgainst: Number(row.points_against ?? 0), events: Number(row.events ?? 0)
    };
  });
}

export async function loadOfficialEventStats(eventId: string): Promise<EventStats | undefined> {
  if (!publicSupabase) return undefined;
  return cached('event-stats:' + eventId, async () => {
    const { data, error } = await publicSupabase!.rpc('official_event_stats', { p_event_id: eventId });
    if (error) { if (isStatsLayerMissing(error)) return undefined; throw error; }
    const row = Array.isArray(data) ? data[0] : data;
    if (!row) return undefined;
    return {
      participants: Number(row.participants ?? 0), teams: Number(row.teams ?? 0), matches: Number(row.matches ?? 0),
      completedMatches: Number(row.completed_matches ?? 0), finalizedMatches: Number(row.finalized_matches ?? 0),
      officialResults: Number(row.official_results ?? 0), formats: Array.isArray(row.formats) ? row.formats : []
    };
  });
}

export async function loadTeamProvenance(teamId: string): Promise<PublicTeamProvenanceRow[]> {
  if (!publicSupabase) return [];
  return cached('team-provenance:' + teamId, async () => {
    const { data, error } = await publicSupabase!.rpc('public_team_provenance', { p_team_id: teamId });
    if (error) { if (isStatsLayerMissing(error)) return []; throw error; }
    return (data ?? []).map((row: any) => ({
      teamId: row.team_id, sourceKind: row.source_kind, sourceRecordKey: row.source_record_key, sourceUrl: row.source_url,
      sourceTeamName: row.source_team_name, sourceLocation: row.source_location ?? undefined, sourceWebsiteUrl: row.source_website_url ?? undefined,
      sourcePriority: Number(row.source_priority ?? 100), verifiedAt: row.verified_at ?? undefined, lastSyncedAt: row.last_synced_at ?? undefined,
      isAlias: Boolean(row.is_alias)
    }));
  });
}

/** Turns provenance rows into a reconciled card so sources and conflicts render from one place. */
export function provenanceToCard(rows: PublicTeamProvenanceRow[], links: Record<string, string> = {}): CanonicalTeamCard | undefined {
  if (!rows.length) return undefined;
  const records: SourcedTeamRecord[] = rows.map(row => ({
    recordId: row.teamId + ':' + row.sourceKind,
    name: row.sourceTeamName,
    location: row.sourceLocation,
    websiteUrl: row.sourceWebsiteUrl,
    provenance: {
      sourceKind: row.sourceKind, sourceUrl: row.sourceUrl, externalId: row.sourceRecordKey,
      retrievedAt: row.lastSyncedAt, verifiedAt: row.verifiedAt, sourcePriority: row.sourcePriority
    }
  }));
  // Provenance rows already belong to one canonical team; force them into a single group.
  const linked: Record<string, string> = { ...links };
  for (const record of records.slice(1)) linked[record.recordId] = records[0].recordId;
  return reconcileTeamRecords(records, linked)[0];
}
