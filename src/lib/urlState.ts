import { useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';

/**
 * Filters that live in the address bar. Back, forward, refresh and shared links restore the same view,
 * and a list remembers its last filters so a detail page can link back to "where you were".
 */
export function useQueryState(name: string, fallback = ''): readonly [string, (next: string) => void] {
  const [params, setParams] = useSearchParams();
  const value = params.get(name) ?? fallback;
  const set = useCallback((next: string) => {
    setParams(previous => {
      const updated = new URLSearchParams(previous);
      if (!next || next === fallback) updated.delete(name); else updated.set(name, next);
      return updated;
    }, { replace: true });
  }, [name, fallback, setParams]);
  return [value, set] as const;
}

/** Updates several filters in one navigation (separate calls in one tick can overwrite each other). */
export function useQueryStates(fallbacks: Record<string, string>): readonly [Record<string, string>, (patch: Record<string, string>) => void] {
  const [params, setParams] = useSearchParams();
  const values: Record<string, string> = {};
  for (const [key, fallback] of Object.entries(fallbacks)) values[key] = params.get(key) ?? fallback;
  const set = useCallback((patch: Record<string, string>) => {
    setParams(previous => {
      const updated = new URLSearchParams(previous);
      for (const [key, next] of Object.entries(patch)) {
        if (!next || next === fallbacks[key]) updated.delete(key); else updated.set(key, next);
      }
      return updated;
    }, { replace: true });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [setParams]);
  return [values, set] as const;
}

const PREFIX = 'nx:list:';

function storage(): Storage | undefined {
  try { return typeof sessionStorage === 'undefined' ? undefined : sessionStorage; } catch { return undefined; }
}

export function rememberListSearch(path: string, search: string, store: Pick<Storage, 'setItem' | 'removeItem'> | undefined = storage()): void {
  if (!store) return;
  if (search && search !== '?') store.setItem(PREFIX + path, search); else store.removeItem(PREFIX + path);
}

/** The list page address including the filters last used, e.g. "/teams?country=Canada". */
export function recallListPath(path: string, store: Pick<Storage, 'getItem'> | undefined = storage()): string {
  const search = store?.getItem(PREFIX + path);
  return search ? path + search : path;
}
