import { beforeEach, describe, expect, it, vi } from 'vitest';

type Reply = { data: any; error: any };
const state = vi.hoisted(() => ({ calls: [] as string[], eventReplies: [] as any[], tableRows: {} as Record<string, any[]> }));

vi.mock('../src/lib/supabase', () => {
  const builder = (table: string, columns: string) => {
    const reply = (): Reply => {
      if (table === 'events') {
        state.calls.push(columns);
        const next = state.eventReplies.shift();
        return typeof next === 'function' ? next(columns) : next;
      }
      return { data: state.tableRows[table] ?? [], error: null };
    };
    const chain: any = {};
    for (const method of ['eq', 'in', 'not', 'order', 'neq', 'or', 'limit', 'gte', 'lte']) chain[method] = () => chain;
    chain.maybeSingle = async () => {
      const r = reply();
      return Array.isArray(r.data) ? { data: r.data[0] ?? null, error: r.error } : r;
    };
    chain.then = (resolve: any, reject: any) => Promise.resolve(reply()).then(resolve, reject);
    return chain;
  };
  return {
    isSupabaseConfigured: true,
    supabase: null,
    publicSupabase: { from: (table: string) => ({ select: (columns: string) => builder(table, columns) }), rpc: async () => ({ data: [], error: null }) }
  };
});

import { clearPublicDirectoryCaches, isMissingColumnError, loadPublicEventDetails, loadPublicEvents } from '../src/lib/publicDirectory';

const row = {
  id: 'e1', organization_id: 'o1', name: 'Spring Open', venue: 'Red Deer', starts_at: '2026-05-01T16:00:00Z', ends_at: '2026-05-01T23:00:00Z',
  organizer_name: 'Reavers', event_type: 'tournament', standings_mode: 'ranked', status: 'published', timezone: 'America/Edmonton',
  public_description: 'desc', public_links: {}, registration_open: true, published_at: '2026-01-01T00:00:00Z',
  slug: 'spring-open', host_team_id: 'team-1', image_path: 'posters/spring.png'
};

beforeEach(() => {
  state.calls = []; state.eventReplies = []; state.tableRows = {};
  clearPublicDirectoryCaches();
});

describe('missing-column detection', () => {
  it('recognizes only schema-shaped errors', () => {
    expect(isMissingColumnError({ code: '42703', message: 'x' })).toBe(true);
    expect(isMissingColumnError({ code: 'PGRST204', message: 'x' })).toBe(true);
    expect(isMissingColumnError({ message: 'column events.slug does not exist' })).toBe(true);
    expect(isMissingColumnError({ code: '42501', message: 'permission denied for table events' })).toBe(false);
    expect(isMissingColumnError({ message: 'Failed to fetch' })).toBe(false);
    expect(isMissingColumnError(null)).toBe(false);
  });
});

describe('event detail loader', () => {
  it('carries the stored poster, host team and slug through to the detail view model', async () => {
    state.eventReplies = [{ data: row, error: null }];
    const details = await loadPublicEventDetails('e1');
    expect(state.calls[0]).toContain('image_path');
    expect(state.calls[0]).toContain('host_team_id');
    expect(details?.event.imagePath).toBe('posters/spring.png');
    expect(details?.event.hostTeamId).toBe('team-1');
    expect(details?.event.slug).toBe('spring-open');
  });

  it('falls back to legacy columns only when a column is missing', async () => {
    const { slug, host_team_id, image_path, ...legacy } = row;
    state.eventReplies = [{ data: null, error: { code: '42703', message: 'column events.slug does not exist' } }, { data: legacy, error: null }];
    const details = await loadPublicEventDetails('e1');
    expect(state.calls).toHaveLength(2);
    expect(state.calls[1]).not.toContain('image_path');
    expect(details?.event.name).toBe('Spring Open');
    expect(details?.event.imagePath).toBeUndefined();
  });

  it('keeps ordinary failures as errors instead of silently degrading', async () => {
    state.eventReplies = [{ data: null, error: { code: '42501', message: 'permission denied' } }];
    await expect(loadPublicEventDetails('e1')).rejects.toMatchObject({ code: '42501' });
    expect(state.calls).toHaveLength(1);
  });

  it('reports an unpublished event as not found, not as an error', async () => {
    state.eventReplies = [{ data: null, error: null }];
    expect(await loadPublicEventDetails('missing')).toBeUndefined();
  });
});

describe('event list loader', () => {
  it('keeps ordinary failures as errors', async () => {
    state.eventReplies = [{ data: null, error: { code: '57014', message: 'statement timeout' } }];
    await expect(loadPublicEvents()).rejects.toMatchObject({ code: '57014' });
  });
});
