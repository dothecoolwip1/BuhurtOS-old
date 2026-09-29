import type { OfflineMutation } from '../types';

const DB_NAME = 'buhurtos-offline';
const STORE = 'mutations';
const memory = new Map<string, OfflineMutation>();

function hasIndexedDb(): boolean {
  return typeof indexedDB !== 'undefined';
}

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(STORE)) db.createObjectStore(STORE, { keyPath: 'id' });
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

async function withStore<T>(mode: IDBTransactionMode, work: (store: IDBObjectStore) => IDBRequest<T>): Promise<T> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, mode);
    const request = work(tx.objectStore(STORE));
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
    tx.oncomplete = () => db.close();
  });
}

export async function enqueueMutation(input: Omit<OfflineMutation, 'id' | 'createdAt' | 'attempts' | 'state'>): Promise<OfflineMutation> {
  const item: OfflineMutation = {
    ...input,
    id: globalThis.crypto?.randomUUID?.() ?? `q-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    createdAt: new Date().toISOString(),
    attempts: 0,
    state: 'queued'
  };
  if (!hasIndexedDb()) memory.set(item.id, item);
  else await withStore('readwrite', store => store.put(item));
  if (typeof navigator !== 'undefined' && 'serviceWorker' in navigator) {
    navigator.serviceWorker.ready.then(registration => {
      const syncManager = (registration as ServiceWorkerRegistration & { sync?: { register: (tag: string) => Promise<void> } }).sync;
      return syncManager?.register('buhurtos-sync');
    }).catch(() => undefined);
  }
  return item;
}

export async function listMutations(): Promise<OfflineMutation[]> {
  if (!hasIndexedDb()) return [...memory.values()].sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  const rows = await withStore<OfflineMutation[]>('readonly', store => store.getAll());
  return rows.sort((a, b) => a.createdAt.localeCompare(b.createdAt));
}

export async function updateMutation(item: OfflineMutation): Promise<void> {
  if (!hasIndexedDb()) { memory.set(item.id, item); return; }
  await withStore('readwrite', store => store.put(item));
}

export async function removeMutation(id: string): Promise<void> {
  if (!hasIndexedDb()) { memory.delete(id); return; }
  await withStore('readwrite', store => store.delete(id));
}

export type SyncOutcome = { ok: true } | { ok: false; conflict?: boolean; error: string };

/**
 * Maximum automatic sync attempts before an item is left failed for the user
 * to decide. Manual retry always resets the counter.
 */
const MAX_AUTO_ATTEMPTS = 8;

/** Exponential backoff base (attempt 1 -> 1s, attempt 2 -> 2s ... capped). */
const BASE_BACKOFF_MS = 1000;
const MAX_BACKOFF_MS = 60_000;

/**
 * A mutation left in `syncing` longer than this is considered interrupted
 * (tab closed, reloaded, or crashed mid-sync) and is retried by the next flush.
 */
const STALE_SYNCING_MS = 30_000;

function backoffMs(attempt: number): number {
  return Math.min(BASE_BACKOFF_MS * 2 ** Math.max(0, attempt - 1), MAX_BACKOFF_MS);
}

function isStaleSyncing(item: OfflineMutation, now: number): boolean {
  if (item.state !== 'syncing' || !item.lastAttemptAt) return false;
  const started = Date.parse(item.lastAttemptAt);
  return Number.isFinite(started) && now - started >= STALE_SYNCING_MS;
}

function shouldAutoRetry(item: OfflineMutation, now: number): boolean {
  if (item.state === 'conflict') return false; // conflicts always require a human decision
  // A fresh `syncing` item is still owned by an in-flight flush (possibly in
  // another tab sharing IndexedDB); only the stale-repair loop above re-queues it.
  if (item.state === 'syncing') return false;
  if (item.state === 'queued') return true;
  if (item.state === 'failed') {
    if (item.attempts >= MAX_AUTO_ATTEMPTS) return false;
    if (!item.lastAttemptAt) return true; // legacy item
    const last = Date.parse(item.lastAttemptAt);
    if (!Number.isFinite(last)) return true;
    return now - last >= backoffMs(item.attempts);
  }
  return false;
}

let inFlightFlush: Promise<{ synced: number; conflicts: number; failed: number }> | null = null;

export async function flushMutationQueue(executor: (mutation: OfflineMutation) => Promise<SyncOutcome>): Promise<{ synced: number; conflicts: number; failed: number }> {
  if (inFlightFlush) return inFlightFlush;

  inFlightFlush = (async () => {
    const queued = await listMutations();
    const now = Date.now();
    let synced = 0;
    let conflicts = 0;
    let failed = 0;

    // Repair interrupted syncs before filtering: a syncing item whose attempt
    // started long ago is treated as queued again so the next flush completes it
    // instead of stranding it forever after a tab death.
    for (const item of queued) {
      if (isStaleSyncing(item, now)) {
        await updateMutation({ ...item, state: 'queued', lastError: item.lastError });
      }
    }

    const candidates = (await listMutations()).filter(item => shouldAutoRetry(item, Date.now()));

    for (const item of candidates) {
      const syncing = { ...item, state: 'syncing' as const, attempts: item.attempts + 1, lastAttemptAt: new Date().toISOString() };
      await updateMutation(syncing);
      try {
        let result: SyncOutcome;
        try {
          result = await executor(syncing);
        } catch (error) {
          result = { ok: false, error: error instanceof Error ? error.message : 'Unknown sync error' };
        }
        if (result.ok === true) {
          await removeMutation(item.id);
          synced += 1;
        } else if (result.conflict) {
          await updateMutation({ ...syncing, state: 'conflict', lastError: result.error });
          conflicts += 1;
        } else {
          await updateMutation({ ...syncing, state: 'failed', lastError: result.error });
          failed += 1;
        }
      } catch (error) {
        await updateMutation({ ...syncing, state: 'failed', lastError: error instanceof Error ? error.message : 'Unknown sync error' });
        failed += 1;
      }
    }

    return { synced, conflicts, failed };
  })().finally(() => {
    inFlightFlush = null;
  });

  return inFlightFlush;
}

export async function retryMutation(id: string): Promise<void> {
  const item = (await listMutations()).find(row => row.id === id);
  if (!item) return;
  // Explicit user retry always clears failure state, backoff, and the attempt cap.
  await updateMutation({ ...item, state: 'queued', attempts: 0, lastError: undefined, lastAttemptAt: undefined });
}

export async function discardMutation(id: string): Promise<void> {
  await removeMutation(id);
}
