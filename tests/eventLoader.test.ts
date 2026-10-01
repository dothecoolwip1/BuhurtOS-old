import { beforeEach, describe, expect, it, vi } from 'vitest';

type Reply = { data: any; error: any };
const state = vi.hoisted(() => ({ calls: [] as string[], eventReplies: [] as any[], tableRows: {} as Record<string, any[]>, rpc: undefined as undefined | ((name: string) => any), eqs: [] as string[] }));

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
    chain.eq = (column: string, value: string) => { state.eqs.push(column + '=' + value); return chain; };
    for (const method of ['in', 'not', 'order', 'neq', 'or', 'limit', 'gte', 'lte']) chain[method] = () => chain;
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
    publicSupabase: { from: (table: string) => ({ select: (columns: string) => builder(table, columns) }), rpc: async (name: string) => (state.rpc ? state.rpc(name) : { data: [], error: null }) }
  };
});

import { eventPath, clearPublicDirectoryCaches, isMissingColumnError, loadPublicEventDetails, loadPublicEventSchedule, loadPublicEvents } from '../src/lib/publicDirectory';

const EVENT_UUID = '11111111-1111-4111-8111-111111111111';
const row = {
  id: 'e1', organization_id: 'o1', name: 'Spring Open', venue: 'Red Deer', starts_at: '2026-05-01T16:00:00Z', ends_at: '2026-05-01T23:00:00Z',
  organizer_name: 'Reavers', event_type: 'tournament', standings_mode: 'ranked', status: 'published', timezone: 'America/Edmonton',
  public_description: 'desc', public_links: {}, registration_open: true, published_at: '2026-01-01T00:00:00Z',
  slug: 'spring-open', host_team_id: 'team-1', image_path: 'posters/spring.png'
};

beforeEach(() => {
  state.calls = []; state.eventReplies = []; state.tableRows = {}; state.rpc = undefined; state.eqs = [];
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
    const details = await loadPublicEventDetails(EVENT_UUID);
    expect(state.calls[0]).toContain('image_path');
    expect(state.calls[0]).toContain('host_team_id');
    expect(details?.event.imagePath).toBe('posters/spring.png');
    expect(details?.event.hostTeamId).toBe('team-1');
    expect(details?.event.slug).toBe('spring-open');
  });

  it('keeps the poster when only the newest column (alt text) is missing', async () => {
    state.eventReplies = [{ data: null, error: { code: '42703', message: 'column events.image_alt does not exist' } }, { data: row, error: null }];
    const details = await loadPublicEventDetails(EVENT_UUID);
    expect(state.calls).toHaveLength(2);
    expect(state.calls[0]).toContain('image_alt');
    expect(state.calls[1]).not.toContain('image_alt');
    expect(state.calls[1]).toContain('image_path');
    expect(details?.event.imagePath).toBe('posters/spring.png');
    expect(details?.event.imageAlt).toBeUndefined();
  });

  it('carries poster alt text through when the backend has it', async () => {
    state.eventReplies = [{ data: { ...row, image_alt: 'Poster: two armored teams clash' }, error: null }];
    const details = await loadPublicEventDetails(EVENT_UUID);
    expect(details?.event.imageAlt).toBe('Poster: two armored teams clash');
  });

  it('falls back to legacy columns only when columns are missing at every newer tier', async () => {
    const { slug, host_team_id, image_path, ...legacy } = row;
    state.eventReplies = [
      { data: null, error: { code: '42703', message: 'column events.image_alt does not exist' } },
      { data: null, error: { code: '42703', message: 'column events.slug does not exist' } },
      { data: legacy, error: null }
    ];
    const details = await loadPublicEventDetails(EVENT_UUID);
    expect(state.calls).toHaveLength(3);
    expect(state.calls[2]).not.toContain('image_path');
    expect(details?.event.name).toBe('Spring Open');
    expect(details?.event.imagePath).toBeUndefined();
  });

  it('keeps ordinary failures as errors instead of silently degrading', async () => {
    state.eventReplies = [{ data: null, error: { code: '42501', message: 'permission denied' } }];
    await expect(loadPublicEventDetails(EVENT_UUID)).rejects.toMatchObject({ code: '42501' });
    expect(state.calls).toHaveLength(1);
  });

  it('reports an unpublished event as not found, not as an error', async () => {
    state.eventReplies = [{ data: null, error: null }];
    expect(await loadPublicEventDetails(EVENT_UUID)).toBeUndefined();
  });
});

describe('event list loader', () => {
  it('keeps ordinary failures as errors', async () => {
    state.eventReplies = [{ data: null, error: { code: '57014', message: 'statement timeout' } }];
    await expect(loadPublicEvents()).rejects.toMatchObject({ code: '57014' });
  });
});

describe('public schedule loader', () => {
  it('reads planned slots from the saved bracket schedule and skips unusable ones', async () => {
    state.tableRows.brackets = [
      { id: 'b1', metadata: { schedule: { slots: [
        { matchId: 'm2', areaId: 'a1', startsAt: '2026-06-06T16:10:00Z', endsAt: '2026-06-06T16:16:00Z', order: 2 },
        { matchId: 'm1', areaId: 'a1', startsAt: '2026-06-06T16:00:00Z', endsAt: '2026-06-06T16:06:00Z', order: 1 },
        { matchId: 'bad', startsAt: 'nope', endsAt: 'nope', order: 3 }
      ] } } },
      { id: 'b2', metadata: {} },
      { id: 'b3', metadata: null }
    ];
    const slots = await loadPublicEventSchedule('e1');
    expect(slots.map(slot => slot.matchId)).toEqual(['m1', 'm2']);
  });
  it('returns nothing when no tournament has a schedule', async () => {
    state.tableRows.brackets = [{ id: 'b1', metadata: {} }];
    expect(await loadPublicEventSchedule('e1')).toEqual([]);
  });
});

describe('event addresses', () => {
  it('prefers the slug in links and falls back to the id', () => {
    expect(eventPath({ id: 'abc', slug: 'red-deer-rumble' })).toBe('/events/red-deer-rumble');
    expect(eventPath({ id: 'abc' })).toBe('/events/abc');
  });
  it('resolves a slug or an id to the same event', async () => {
    state.eventReplies = [{ data: row, error: null }];
    const bySlug = await loadPublicEventDetails('spring-open');
    expect(state.eqs).toContain('slug=spring-open');
    expect(bySlug?.event.id).toBe('e1');
    clearPublicDirectoryCaches(); state.eqs = [];
    state.eventReplies = [{ data: row, error: null }];
    await loadPublicEventDetails('6028e471-a95c-4d8a-8101-1f168bc68c8b');
    expect(state.eqs).toContain('id=6028e471-a95c-4d8a-8101-1f168bc68c8b');
  });
});
