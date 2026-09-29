import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  discardMutation,
  enqueueMutation,
  flushMutationQueue,
  listMutations,
  retryMutation,
  updateMutation
} from '../src/lib/offlineQueue';
import type { OfflineMutation } from '../src/types';

async function clearQueue() {
  for (const item of await listMutations()) await discardMutation(item.id);
}

describe('offline mutation queue hardening', () => {
  beforeEach(clearQueue);
  afterEach(clearQueue);

  it('preserves conflicts until a person explicitly retries them', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });

    const first = await flushMutationQueue(async () => ({
      ok: false as const,
      conflict: true,
      error: 'Match changed on another device.'
    }));

    expect(first).toEqual({ synced: 0, conflicts: 1, failed: 0 });
    expect(await listMutations()).toMatchObject([{
      id: queued.id,
      state: 'conflict',
      attempts: 1,
      lastError: 'Match changed on another device.'
    }]);

    const skipped = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(skipped).toEqual({ synced: 0, conflicts: 0, failed: 0 });
    expect(await listMutations()).toHaveLength(1);

    await retryMutation(queued.id);
    const retried = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(retried).toEqual({ synced: 1, conflicts: 0, failed: 0 });
    expect(await listMutations()).toEqual([]);
  });

  it('retains unexpected sync failures instead of dropping field work', async () => {
    const queued = await enqueueMutation({
      entity: 'event_roster_entries',
      entityId: 'roster-1',
      operation: 'update',
      payload: { checkedIn: true },
      baseVersion: JSON.stringify({ updatedAt: '2026-09-24T12:00:00Z' })
    });

    const result = await flushMutationQueue(async () => {
      throw new Error('Temporary network failure');
    });

    expect(result).toEqual({ synced: 0, conflicts: 0, failed: 1 });
    expect(await listMutations()).toMatchObject([{
      id: queued.id,
      state: 'failed',
      attempts: 1,
      lastError: 'Temporary network failure'
    }]);
  });

  it('repairs mutations stranded in syncing by a dead tab', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });
    // Simulate a tab that died mid-sync: last attempt started long ago.
    await updateMutation({
      ...queued,
      state: 'syncing',
      attempts: 1,
      lastAttemptAt: new Date(Date.now() - 120_000).toISOString()
    } as OfflineMutation);

    const result = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(result).toEqual({ synced: 1, conflicts: 0, failed: 0 });
    expect(await listMutations()).toEqual([]);
  });

  it('a fresh syncing item without a stale marker is not re-executed by the same flush', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });
    await updateMutation({
      ...queued,
      state: 'syncing',
      attempts: 1,
      lastAttemptAt: new Date().toISOString()
    } as OfflineMutation);

    // Backoff has not elapsed and the item is not stale, so a flush right now
    // must not touch it (its owning flush is still considered in progress).
    const result = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(result).toEqual({ synced: 0, conflicts: 0, failed: 0 });
    expect(await listMutations()).toHaveLength(1);
  });

  it('does not re-execute syncing items while their backoff has not elapsed', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });
    await updateMutation({
      ...queued,
      state: 'syncing',
      attempts: 1,
      lastAttemptAt: new Date(Date.now() - 5_000).toISOString()
    } as OfflineMutation);

    const result = await flushMutationQueue(async () => ({ ok: true as const }));
    // 5s is inside STALE_SYNCING_MS, so it is still considered in-flight.
    expect(result).toEqual({ synced: 0, conflicts: 0, failed: 0 });
    expect(await listMutations()).toHaveLength(1);
  });

  it('applies exponential backoff between failures', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });

    const first = await flushMutationQueue(async () => ({ ok: false as const, error: 'offline' }));
    expect(first).toEqual({ synced: 0, conflicts: 0, failed: 1 });

    // Attempt 1 backoff (1s) has not elapsed -> skipped.
    const immediate = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(immediate).toEqual({ synced: 0, conflicts: 0, failed: 0 });

    // Pretend the backoff window passed.
    const [stored] = await listMutations();
    await updateMutation({ ...stored, lastAttemptAt: new Date(Date.now() - 120_000).toISOString() } as OfflineMutation);

    const retried = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(retried).toEqual({ synced: 1, conflicts: 0, failed: 0 });
  });

  it('stops automatic retries after the attempt cap and lets manual retry override it', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });
    await updateMutation({
      ...queued,
      state: 'failed',
      attempts: 8,
      lastError: 'still down',
      lastAttemptAt: new Date(Date.now() - 120_000).toISOString()
    } as OfflineMutation);

    const skipped = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(skipped).toEqual({ synced: 0, conflicts: 0, failed: 0 });
    expect(await listMutations()).toHaveLength(1);

    await retryMutation(queued.id);
    const [afterRetry] = await listMutations();
    expect(afterRetry.state).toBe('queued');
    expect(afterRetry.attempts).toBe(0);

    const done = await flushMutationQueue(async () => ({ ok: true as const }));
    expect(done).toEqual({ synced: 1, conflicts: 0, failed: 0 });
  });

  it('shares a single run when flush is called concurrently', async () => {
    const queued = await enqueueMutation({
      entity: 'match_status',
      entityId: 'match-1',
      operation: 'rpc',
      payload: { status: 'active' },
      baseVersion: 'scheduled'
    });
    let executions = 0;
    const [a, b] = await Promise.all([
      flushMutationQueue(async () => { executions += 1; return { ok: true as const }; }),
      flushMutationQueue(async () => { executions += 1; return { ok: true as const }; })
    ]);
    expect(a).toEqual({ synced: 1, conflicts: 0, failed: 0 });
    expect(b).toEqual(a);
    // The queue only contains one item; it must never be executed twice.
    expect(executions).toBe(1);
    expect((await listMutations()).some(row => row.id === queued.id)).toBe(false);
  });
});
