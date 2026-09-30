import { describe, expect, it, vi } from 'vitest';
import swSource from '../public/sw.js?raw';
import manifestSource from '../public/manifest.webmanifest?raw';
import { applyServiceWorkerUpdate, recoverFromStaleChunks } from '../src/lib/pwa';
import { coalesce, eventTopic, fieldTopic, matchTopic } from '../src/lib/realtime';

describe('service worker safety', () => {
  it('only ever caches same-origin GET navigations and static assets', () => {
    expect(swSource).toContain("if (request.method !== 'GET') return false;");
    expect(swSource).toContain('if (url.origin !== self.location.origin) return false;');
    expect(swSource).toContain("request.headers.has('authorization')");
    expect(swSource).toContain("['script','style','image','font','manifest']");
  });

  it('never caches Supabase Data API, Auth or Storage traffic', () => {
    expect(swSource).not.toMatch(/supabase\.co/);
    expect(swSource).not.toMatch(/\/rest\/v1|\/auth\/v1|\/storage\/v1/);
  });

  it('keeps the build placeholders the precache plugin replaces', () => {
    expect(swSource).toContain("const BUILD_ID = 'dev';");
    expect(swSource).toContain('const PRECACHE_ASSETS = [];');
    expect(swSource).toContain("const CACHE = 'buhurtos-shell-' + BUILD_ID;");
  });

  it('updates only when the visitor accepts, never mid-visit', () => {
    expect(swSource).not.toMatch(/addEventListener\('install'[\s\S]{0,400}self\.skipWaiting\(\);\s*\}\);/);
    expect(swSource).toContain("event.data.type === 'BuhurtOS_SKIP_WAITING'");
  });

  it('serves an offline shell for navigations and drops old caches on activation', () => {
    expect(swSource).toContain('caches.match(SCOPE_PATH)');
    expect(swSource).toContain('keys.filter(key => key !== CACHE).map(key => caches.delete(key))');
  });
});

describe('web app manifest', () => {
  const manifest = JSON.parse(manifestSource);
  it('is installable', () => {
    expect(manifest.display).toBe('standalone');
    expect(manifest.start_url).toBe('./');
    expect(manifest.scope).toBe('./');
    expect(manifest.id).toBeTruthy();
    const sizes = manifest.icons.map((icon: any) => icon.sizes);
    expect(sizes).toContain('192x192');
    expect(sizes).toContain('512x512');
  });
  it('declares any and maskable purposes separately', () => {
    const purposes = manifest.icons.map((icon: any) => icon.purpose);
    expect(purposes).toContain('any');
    expect(purposes).toContain('maskable');
    expect(purposes).not.toContain('any maskable');
  });
});

describe('update flow', () => {
  it('asks the waiting worker to take over', () => {
    const postMessage = vi.fn();
    expect(applyServiceWorkerUpdate({ waiting: { postMessage } as unknown as ServiceWorker })).toBe(true);
    expect(postMessage).toHaveBeenCalledWith({ type: 'BuhurtOS_SKIP_WAITING' });
    expect(applyServiceWorkerUpdate({ waiting: null })).toBe(false);
  });
  it('stale-chunk recovery is a no-op outside the browser', () => {
    expect(() => recoverFromStaleChunks(undefined)).not.toThrow();
  });
});

describe('realtime design', () => {
  it('uses narrow topics', () => {
    expect(eventTopic('e1')).toBe('event:e1');
    expect(fieldTopic('f1')).toBe('field:f1');
    expect(matchTopic('m1')).toBe('match:m1');
  });

  it('coalesces a burst of notifications into a single trailing refresh', () => {
    vi.useFakeTimers();
    const refresh = vi.fn();
    const handler = coalesce(refresh, 400);
    handler(); handler(); handler();
    vi.advanceTimersByTime(399);
    expect(refresh).not.toHaveBeenCalled();
    vi.advanceTimersByTime(2);
    expect(refresh).toHaveBeenCalledTimes(1);
    handler();
    handler.cancel();
    vi.advanceTimersByTime(1000);
    expect(refresh).toHaveBeenCalledTimes(1);
    vi.useRealTimers();
  });
});
