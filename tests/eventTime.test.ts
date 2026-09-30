import { describe, expect, it } from 'vitest';
import { eventDayKey, eventMonthKey, formatEventRange, formatEventTime, safeZone, zoneLabel } from '../src/lib/eventTime';
import { groupByMonth } from '../src/lib/eventCategories';

describe('event-local dates', () => {
  // 9 pm on 30 April in Edmonton (MDT, UTC-6) is already 1 May in UTC.
  const lateNight = '2026-05-01T03:00:00Z';
  it('keeps a midnight-crossing event on its local day and month', () => {
    expect(eventDayKey(lateNight, 'America/Edmonton')).toBe('2026-04-30');
    expect(eventMonthKey(lateNight, 'America/Edmonton')).toBe('2026-04');
    expect(eventMonthKey(lateNight, 'UTC')).toBe('2026-05');
  });
  it('judges a far-away timezone by its own calendar', () => {
    expect(eventDayKey('2026-05-01T20:00:00Z', 'Pacific/Auckland')).toBe('2026-05-02');
  });
  it('groups agenda months by event time, not viewer time', () => {
    const groups = groupByMonth([
      { startsAt: lateNight, timezone: 'America/Edmonton' },
      { startsAt: '2026-05-10T18:00:00Z', timezone: 'America/Edmonton' }
    ]);
    expect(groups.map(group => group.key)).toEqual(['2026-04', '2026-05']);
  });
  it('shows one day or a range based on local days', () => {
    expect(formatEventRange('2026-05-02T14:00:00Z', '2026-05-03T03:00:00Z', 'America/Edmonton')).not.toContain('–');
    expect(formatEventRange('2026-05-02T14:00:00Z', '2026-05-04T03:00:00Z', 'America/Edmonton')).toContain('–');
  });
  it('labels the time with its zone and never throws on a bad zone', () => {
    expect(formatEventTime('2026-05-02T16:00:00Z', 'America/Edmonton')).toMatch(/MDT|GMT-6/);
    expect(safeZone('Not/AZone')).toBe('UTC');
    expect(zoneLabel('Not/AZone')).toContain('unrecognized');
    expect(zoneLabel('')).toBe('UTC');
  });
  it('says Date TBA for an unusable date', () => {
    expect(formatEventRange('garbage', 'garbage', 'UTC')).toBe('Date TBA');
  });
});
