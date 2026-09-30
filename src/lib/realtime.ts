/**
 * Realtime topic design. One channel per scope, never a global subscription:
 *   event:<id>   event-level changes (matches, roster, announcements, fight cards, event row)
 *   field:<id>   a single field / fight card queue (reserved for finer subscriptions)
 *   match:<id>   one match (reserved for scoreboards and widgets)
 */
export const eventTopic = (id: string) => `event:${id}`;
export const fieldTopic = (id: string) => `field:${id}`;
export const matchTopic = (id: string) => `match:${id}`;

export type Coalesced = { (): void; cancel(): void };

/**
 * Collapses a burst of realtime notifications (a bracket advance touches many rows) into one
 * trailing refresh, so the client reloads once instead of once per row.
 */
export function coalesce(fn: () => void, waitMs = 400, timers: Pick<typeof globalThis, 'setTimeout' | 'clearTimeout'> = globalThis): Coalesced {
  let handle: ReturnType<typeof setTimeout> | undefined;
  const run = (() => {
    if (handle !== undefined) timers.clearTimeout(handle);
    handle = timers.setTimeout(() => { handle = undefined; fn(); }, waitMs);
  }) as Coalesced;
  run.cancel = () => { if (handle !== undefined) { timers.clearTimeout(handle); handle = undefined; } };
  return run;
}
