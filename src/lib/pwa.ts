/**
 * Service worker registration with a controlled update flow.
 * A new worker waits (see public/sw.js); the page is told via `buhurtos:update-ready` and the
 * visitor chooses when to reload, so a field marshal is never refreshed mid-bout.
 */
export const UPDATE_READY_EVENT = 'buhurtos:update-ready';

export function applyServiceWorkerUpdate(registration: Pick<ServiceWorkerRegistration, 'waiting'>): boolean {
  const waiting = registration.waiting;
  if (!waiting) return false;
  waiting.postMessage({ type: 'BuhurtOS_SKIP_WAITING' });
  return true;
}

export function registerServiceWorker(baseUrl: string): void {
  if (typeof navigator === 'undefined' || !('serviceWorker' in navigator)) return;
  window.addEventListener('load', () => {
    navigator.serviceWorker.register(baseUrl + 'sw.js').then(registration => {
      const announce = () => {
        if (registration.waiting && navigator.serviceWorker.controller) {
          window.dispatchEvent(new CustomEvent(UPDATE_READY_EVENT, { detail: { registration } }));
        }
      };
      announce();
      registration.addEventListener('updatefound', () => {
        const worker = registration.installing;
        worker?.addEventListener('statechange', () => { if (worker.state === 'installed') announce(); });
      });
      // Check for a new deployment when the app returns to the foreground.
      document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') registration.update().catch(() => undefined); });
    }).catch(() => undefined);

    let reloading = false;
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      if (reloading) return;
      reloading = true;
      window.location.reload();
    });
  });
}

/**
 * After a deployment, a page that is still running the old build may request lazy chunks whose
 * hashed files no longer exist. Reload once (guarded) so the visitor lands on the new build.
 */
export function recoverFromStaleChunks(storage: Pick<Storage, 'getItem' | 'setItem'> | undefined = safeSession()): void {
  if (typeof window === 'undefined') return;
  window.addEventListener('vite:preloadError', () => {
    const last = Number(storage?.getItem('buhurtos-chunk-reload') ?? 0);
    if (Date.now() - last < 30_000) return;
    storage?.setItem('buhurtos-chunk-reload', String(Date.now()));
    window.location.reload();
  });
}

function safeSession(): Storage | undefined {
  try { return typeof sessionStorage === 'undefined' ? undefined : sessionStorage; } catch { return undefined; }
}
