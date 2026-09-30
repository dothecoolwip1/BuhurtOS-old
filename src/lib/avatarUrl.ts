import { loadFighterAvatarUrl } from './fighterIdentity';

/**
 * Fighter photos live in a private bucket. A public page shows one by asking the avatar function for a
 * short-lived signed URL (it only answers for identities marked public, or for their owner).
 * Signed URLs last 60 seconds, so they are cached for less than that and shared between components.
 */
const TTL_MS = 40_000;
const cache = new Map<string, { at: number; url: string | null }>();
const inflight = new Map<string, Promise<string | null>>();

export function getAvatarUrl(identityId: string, force = false, now: () => number = Date.now, load: (id: string) => Promise<string | null> = loadFighterAvatarUrl): Promise<string | null> {
  const hit = cache.get(identityId);
  if (!force && hit && now() - hit.at < TTL_MS) return Promise.resolve(hit.url);
  const pending = inflight.get(identityId);
  if (pending && !force) return pending;
  const request = load(identityId)
    .then(url => { cache.set(identityId, { at: now(), url }); return url; })
    .catch(() => { cache.set(identityId, { at: now(), url: null }); return null; })
    .finally(() => { inflight.delete(identityId); });
  inflight.set(identityId, request);
  return request;
}

export function clearAvatarCache(): void {
  cache.clear();
  inflight.clear();
}
