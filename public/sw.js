// Replaced at build time by scripts/swPrecachePlugin.mjs. The placeholders below stay in source.
const BUILD_ID = 'dev';
const PRECACHE_ASSETS = [];

const CACHE = 'buhurtos-shell-' + BUILD_ID;
const SCOPE_URL = new URL(self.registration.scope);
const SCOPE_PATH = SCOPE_URL.pathname;
const SHELL = [SCOPE_PATH, `${SCOPE_PATH}manifest.webmanifest`];

// Only same-origin GET navigations and static assets are ever cached. Cross-origin
// requests (the Supabase Data API, Auth and Storage) and anything carrying an
// Authorization header are never cached, so private responses cannot be stored.
const isSameOriginCacheable = request => {
  if (request.method !== 'GET') return false;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return false;
  if (request.headers.has('authorization')) return false;
  return request.mode === 'navigate'
    || ['script','style','image','font','manifest'].includes(request.destination);
};

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(async cache => {
    await cache.addAll(SHELL);
    // Best effort: a single missing asset must not block installation.
    await Promise.allSettled(PRECACHE_ASSETS.map(asset => cache.add(SCOPE_PATH + asset)));
  }));
  // A new worker waits until the page asks it to take over, so a visit is never split across versions.
});

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'BuhurtOS_SKIP_WAITING') self.skipWaiting();
});

self.addEventListener('activate', event => event.waitUntil(Promise.all([
  self.clients.claim(),
  caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE).map(key => caches.delete(key))))
])));

self.addEventListener('fetch', event => {
  const { request } = event;
  if (!isSameOriginCacheable(request)) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then(response => response.ok ? response : Promise.reject(new Error('Navigation failed')))
        .catch(() => caches.match(SCOPE_PATH))
    );
    return;
  }

  event.respondWith(
    caches.match(request).then(cached => {
      const network = fetch(request).then(response => {
        if (response.ok && response.type === 'basic') {
          const copy = response.clone();
          caches.open(CACHE).then(cache => cache.put(request, copy));
        }
        return response;
      });
      return cached || network;
    })
  );
});

self.addEventListener('sync', event => {
  if (event.tag !== 'buhurtos-sync') return;
  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clients => {
    for (const client of clients) client.postMessage({ type: 'BuhurtOS_SYNC_REQUEST' });
  }));
});
