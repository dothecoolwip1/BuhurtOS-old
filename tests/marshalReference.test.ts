import { describe, expect, it } from 'vitest';
import { hacsaTeams } from '../src/data/hacsaTeams';
import { biRuleEntries, biRuleSources } from '../src/data/biMarshalRules';
import { filterBiRules, formatFromMatchCategory } from '../src/lib/ruleReference';

describe('source backed team directory', () => {
  it('contains the current HACSA directory snapshot with provenance', () => {
    expect(hacsaTeams).toHaveLength(10);
    expect(hacsaTeams.every(team => team.sourceId === 'hacsa')).toBe(true);
    expect(hacsaTeams.every(team => team.sourceUrl === 'https://www.hacsacanada.com/teams')).toBe(true);
    expect(hacsaTeams.find(team => team.id === 'reavers')?.location).toBe('Red Deer');
  });
});

describe('BI marshal reference', () => {
  it('maps active fight categories to the right rules filter', () => {
    expect(formatFromMatchCategory('5v5 Men')).toBe('5v5');
    expect(formatFromMatchCategory('Longsword Women')).toBe('longsword');
    expect(formatFromMatchCategory('Sword & Shield')).toBe('sword_shield');
    expect(formatFromMatchCategory('Outrance Division 1')).toBe('outrance');
  });

  it('filters group battle rules without leaking duel-only rules', () => {
    const results = filterBiRules(biRuleEntries, '5v5', '');
    expect(results.some(rule => rule.sourceId === 'buhurt-rules')).toBe(true);
    expect(results.some(rule => rule.sourceId === 'duel-rules')).toBe(false);
  });

  it('finds common marshal calls by plain-language query', () => {
    const results = filterBiRules(biRuleEntries, 'buhurt', 'back of knee');
    expect(results.some(rule => rule.section === '6.3')).toBe(true);
  });

  it('keeps every indexed entry tied to a current source document', () => {
    const sourceIds = new Set(biRuleSources.map(source => source.id));
    expect(biRuleEntries.length).toBeGreaterThan(100);
    expect(biRuleEntries.every(rule => sourceIds.has(rule.sourceId))).toBe(true);
  });
});
