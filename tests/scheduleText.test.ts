import { describe, expect, it } from 'vitest';
import { groupRowsByArea, scheduleAsText } from '../src/lib/scheduleText';

const rows = [
  { time: '10:00', area: 'Field 1', label: 'Pool A • Match 1', side1: 'Ann', side2: 'Bo' },
  { time: '10:00', area: 'Field 2', label: 'Pool B • Match 4', side1: 'Cy', side2: 'Di' },
  { time: '10:07', area: 'Field 1', label: 'Pool A • Match 2', side1: 'Ann', side2: 'Cy' },
  { time: '', area: '', label: 'Extra', side1: 'Ed', side2: 'Flo' }
];

describe('schedule text', () => {
  it('groups by area keeping each area in time order', () => {
    const groups = groupRowsByArea(rows);
    expect(groups.map(g => g.area)).toEqual(['Field 1', 'Field 2', 'Unassigned']);
    expect(groups[0].rows.map(r => r.time)).toEqual(['10:00', '10:07']);
  });
  it('produces chat-ready text', () => {
    const text = scheduleAsText('Spring Open order of play', rows);
    expect(text).toContain('Spring Open order of play');
    expect(text).toContain('10:00  Pool A • Match 1: Ann vs Bo');
    expect(text).toContain('Extra: Ed vs Flo');
    expect(text.endsWith('\n')).toBe(true);
  });
});
