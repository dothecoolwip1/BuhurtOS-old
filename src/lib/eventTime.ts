/**
 * Event dates and times are shown in the event's own timezone, so a fight at 9 pm in Edmonton is the same day for every viewer
 * instead of shifting with the visitor's device. A missing or unrecognized zone falls back to UTC and says so via `zoneLabel`.
 */
export function safeZone(timezone?: string | null): string {
  if (!timezone) return 'UTC';
  try {
    new Intl.DateTimeFormat('en', { timeZone: timezone });
    return timezone;
  } catch {
    return 'UTC';
  }
}

export function zoneLabel(timezone?: string | null): string {
  const zone = safeZone(timezone);
  return zone === 'UTC' && timezone && timezone.toUpperCase() !== 'UTC' ? `UTC (unrecognized zone "${timezone}")` : zone;
}

const valid = (iso: string) => !Number.isNaN(new Date(iso).getTime());

/** `YYYY-MM-DD` of the instant as seen in the zone. */
export function eventDayKey(iso: string, timezone?: string | null): string {
  const parts = new Intl.DateTimeFormat('en-CA', { timeZone: safeZone(timezone), year: 'numeric', month: '2-digit', day: '2-digit' }).formatToParts(new Date(iso));
  const get = (type: string) => parts.find(part => part.type === type)?.value ?? '';
  return `${get('year')}-${get('month')}-${get('day')}`;
}

export function eventMonthKey(iso: string, timezone?: string | null): string {
  return eventDayKey(iso, timezone).slice(0, 7);
}

export function formatEventDate(iso: string, timezone?: string | null, options: Intl.DateTimeFormatOptions = { month: 'short', day: 'numeric', year: 'numeric' }): string {
  if (!valid(iso)) return 'Date TBA';
  return new Date(iso).toLocaleDateString(undefined, { ...options, timeZone: safeZone(timezone) });
}

export function formatEventTime(iso: string, timezone?: string | null): string {
  if (!valid(iso)) return 'Time TBA';
  return new Date(iso).toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit', timeZone: safeZone(timezone), timeZoneName: 'short' });
}

/** "May 1" for a one-day event, "May 1 – May 3, 2026" across days; days are judged in the event's zone. */
export function formatEventRange(startIso: string, endIso: string, timezone?: string | null, long = false): string {
  if (!valid(startIso)) return 'Date TBA';
  if (!valid(endIso) || eventDayKey(startIso, timezone) === eventDayKey(endIso, timezone)) {
    return formatEventDate(startIso, timezone, long ? { month: 'long', day: 'numeric', year: 'numeric' } : { weekday: 'short', month: 'short', day: 'numeric' });
  }
  const sameYear = eventDayKey(startIso, timezone).slice(0, 4) === eventDayKey(endIso, timezone).slice(0, 4);
  const month = long ? 'long' : 'short';
  return `${formatEventDate(startIso, timezone, { month, day: 'numeric', year: sameYear ? undefined : 'numeric' })} – ${formatEventDate(endIso, timezone, { month, day: 'numeric', year: 'numeric' })}`;
}

/** Label for a `YYYY-MM` group, independent of the viewer's zone. */
export function monthLabel(key: string): string {
  return new Date(`${key}-01T12:00:00Z`).toLocaleDateString(undefined, { month: 'long', year: 'numeric', timeZone: 'UTC' });
}
