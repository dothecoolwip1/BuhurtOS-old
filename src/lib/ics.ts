import type { EventDTO } from './publicApiV1';

const escapeText = (value: string) =>
  value.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replace(/\r?\n/g, '\\n');

function utc(iso: string): string {
  return new Date(iso).toISOString().replace(/[-:]/g, '').replace(/\.\d{3}Z$/, 'Z');
}

/** RFC 5545 line folding at 75 characters. */
function fold(line: string): string {
  if (line.length <= 75) return line;
  const parts = [line.slice(0, 75)];
  for (let i = 75; i < line.length; i += 74) parts.push(' ' + line.slice(i, i + 74));
  return parts.join('\r\n');
}

/** Builds a public calendar feed from published events only (the caller passes EventDTOs). */
export function buildIcs(events: EventDTO[], calendarName = 'BuhurtOS events', now = new Date()): string {
  const lines = [
    'BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//BuhurtOS//Public events v1//EN', 'CALSCALE:GREGORIAN',
    `X-WR-CALNAME:${escapeText(calendarName)}`
  ];
  for (const event of events) {
    if (Number.isNaN(new Date(event.startsAt).getTime()) || Number.isNaN(new Date(event.endsAt).getTime())) continue;
    lines.push(
      'BEGIN:VEVENT',
      `UID:${event.id}@buhurtos`,
      `DTSTAMP:${utc(now.toISOString())}`,
      `DTSTART:${utc(event.startsAt)}`,
      `DTEND:${utc(event.endsAt)}`,
      `SUMMARY:${escapeText(event.name)}`,
      `LOCATION:${escapeText(event.venue)}`
    );
    if (event.description) lines.push(`DESCRIPTION:${escapeText(event.description)}`);
    const url = event.links.facebook ?? event.links.website;
    if (url) lines.push(`URL:${url}`);
    if (event.status === 'cancelled') lines.push('STATUS:CANCELLED');
    lines.push('END:VEVENT');
  }
  lines.push('END:VCALENDAR');
  return lines.map(fold).join('\r\n') + '\r\n';
}

export interface BoutCalendarItem { id: string; title: string; startsAt: string; endsAt: string; location?: string; description?: string }

/** A calendar file of planned bouts, for a fighter or team to drop their day into a phone calendar. Planned times only. */
export function buildBoutsIcs(bouts: BoutCalendarItem[], calendarName: string, now = new Date()): string {
  const lines = ['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//BuhurtOS//Order of play//EN', 'CALSCALE:GREGORIAN', `X-WR-CALNAME:${escapeText(calendarName)}`];
  for (const bout of bouts) {
    if (Number.isNaN(new Date(bout.startsAt).getTime()) || Number.isNaN(new Date(bout.endsAt).getTime())) continue;
    lines.push(
      'BEGIN:VEVENT', `UID:${bout.id}@buhurtos-bout`, `DTSTAMP:${utc(now.toISOString())}`,
      `DTSTART:${utc(bout.startsAt)}`, `DTEND:${utc(bout.endsAt)}`, `SUMMARY:${escapeText(bout.title)}`
    );
    if (bout.location) lines.push(`LOCATION:${escapeText(bout.location)}`);
    if (bout.description) lines.push(`DESCRIPTION:${escapeText(bout.description)}`);
    lines.push('END:VEVENT');
  }
  lines.push('END:VCALENDAR');
  return lines.map(fold).join('\r\n') + '\r\n';
}
