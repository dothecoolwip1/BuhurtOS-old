import { describe, expect, it } from 'vitest';
import {
  adviseStructure, buildFormatSelection, describeStructure, leadTimeAdvice, overrideProblem, registrationCloseAdvice,
  type FormatTemplate, type TierRequirement
} from '../src/lib/tournamentStructure';

const t = (optionKey: string, min: number, max: number | null, structure: FormatTemplate['structure'], recommended = true, caution?: string): FormatTemplate =>
  ({ authority: 'bi', docVersion: 'Jan 2026', optionKey, title: optionKey, minEntrants: min, maxEntrants: max, structure, recommended, caution, sourceRef: 'Tournament Structure Jan 2026' });

// Mirrors the seeded BI Tournament Structure (Jan 2026) rows.
const templates: FormatTemplate[] = [
  t('rr_4_6', 4, 6, { kind: 'round_robin' }),
  t('rr_6_12', 6, 12, { kind: 'round_robin' }),
  t('pools_6_12_rr', 6, 12, { kind: 'pools', poolSizeMin: 3, poolSizeMax: 6, advancePerPool: 2, finals: 'round_robin', finalists: 4 }),
  t('pools_6_12_se', 6, 12, { kind: 'pools', poolSizeMin: 3, poolSizeMax: 6, advancePerPool: 2, finals: 'single_elimination', finalists: 4, thirdPlaceMatch: true }),
  t('pools_12_16_two_rr', 12, 16, { kind: 'pools', pools: 2, poolSizeMin: 6, poolSizeMax: 8, advancePerPool: 2, finals: 'round_robin', finalists: 4 }),
  t('pools_12_16_two_se', 12, 16, { kind: 'pools', pools: 2, poolSizeMin: 6, poolSizeMax: 8, advancePerPool: 2, finals: 'single_elimination', finalists: 4, thirdPlaceMatch: true }),
  t('pools_12_16_three_rr', 12, 16, { kind: 'pools', pools: 3, poolSizeMin: 4, poolSizeMax: 6, advancePerPool: 2, finals: 'round_robin', finalists: 6, tiebreakerRound: true }),
  t('pools_12_16_three_se', 12, 16, { kind: 'pools', pools: 3, poolSizeMin: 4, poolSizeMax: 6, advancePerPool: 2, finals: 'single_elimination', finalists: 6, thirdPlaceMatch: true }, false, 'Not recommended: six-team bracket'),
  t('pools_16_20_two_rr', 16, 20, { kind: 'pools', pools: 2, poolSizeMin: 8, poolSizeMax: 10, advancePerPool: 2, finals: 'round_robin', finalists: 4 }),
  t('pools_16_20_four_rr', 16, 20, { kind: 'pools', pools: 4, poolSizeMin: 4, poolSizeMax: 5, advancePerPool: 2, finals: 'round_robin', finalists: 8 }, false, 'Not recommended: long tournament')
];

const keys = (n: number) => adviseStructure(templates, n).options.map(o => o.optionKey);

describe('structure advice from the selected rules version', () => {
  it('gives a round robin for 4 to 6 entrants', () => {
    expect(keys(5)).toEqual(['rr_4_6']);
  });
  it('offers both documented sets where the source ranges overlap', () => {
    expect(keys(6)).toEqual(['rr_4_6', 'rr_6_12', 'pools_6_12_rr', 'pools_6_12_se']);
    expect(keys(12)).toContain('rr_6_12');
    expect(keys(12)).toContain('pools_12_16_two_se');
    expect(keys(16)).toContain('pools_12_16_three_rr');
    expect(keys(16)).toContain('pools_16_20_two_rr');
  });
  it('gives two- and three-pool options for 14 entrants, marking the discouraged one', () => {
    const advice = adviseStructure(templates, 14);
    expect(advice.options.map(o => o.optionKey)).toEqual(['pools_12_16_two_rr', 'pools_12_16_two_se', 'pools_12_16_three_rr', 'pools_12_16_three_se']);
    expect(advice.options.filter(o => !o.recommended).map(o => o.optionKey)).toEqual(['pools_12_16_three_se']);
  });
  it('does not invent a structure below the documented range', () => {
    const advice = adviseStructure(templates, 3);
    expect(advice.options).toEqual([]);
    expect(advice.note).toMatch(/no structure below 4/i);
  });
  it('says what to do above the documented range instead of guessing', () => {
    const advice = adviseStructure(templates, 24);
    expect(advice.options.length).toBeGreaterThan(0);
    expect(advice.note).toMatch(/in proportion/i);
  });
  it('asks for a number when there is none', () => {
    expect(adviseStructure(templates, Number.NaN).note).toMatch(/enter how many/i);
  });
  it('describes structures in plain words', () => {
    expect(describeStructure(templates[0])).toMatch(/plays everyone/i);
    expect(describeStructure(templates.find(x => x.optionKey === 'pools_12_16_two_se')!)).toMatch(/2 pools of 6-8.*top 2.*single-elimination.*third-place/i);
  });
});

describe('recording a selection and overrides', () => {
  const advice = adviseStructure(templates, 14);
  it('records the version, count, choice and timestamp with no override for a recommended option', () => {
    const selection = buildFormatSelection({ rulesVersion: 'Jan 2026', entrantCount: 14, option: advice.options[0], advice, now: new Date('2026-10-01T00:00:00Z') });
    expect(selection).toEqual({ rulesVersion: 'Jan 2026', entrantCount: 14, optionKey: 'pools_12_16_two_rr', generatedAt: '2026-10-01T00:00:00.000Z', override: false, overrideReason: undefined });
    expect(overrideProblem(selection)).toBeUndefined();
  });
  it('treats a not-recommended option as an override that needs a reason', () => {
    const discouraged = advice.options.find(o => !o.recommended)!;
    const without = buildFormatSelection({ rulesVersion: 'Jan 2026', entrantCount: 14, option: discouraged, advice });
    expect(without.override).toBe(true);
    expect(overrideProblem(without)).toMatch(/say why/i);
    const withReason = buildFormatSelection({ rulesVersion: 'Jan 2026', entrantCount: 14, option: discouraged, advice, overrideReason: 'Field is short on time' });
    expect(overrideProblem(withReason)).toBeUndefined();
  });
  it('treats an organizer choice outside the options as an override', () => {
    const selection = buildFormatSelection({ rulesVersion: 'Jan 2026', entrantCount: 14, option: undefined, advice });
    expect(selection.override).toBe(true);
  });
});

describe('lead time advice', () => {
  const classic: TierRequirement = { authority: 'bi', docVersion: 'v2026.1', tier: 'classic', tierLabel: 'Classic', leadDays: 45, requirements: {}, sourceRef: 'League Structure v2026.1 §2.3.3' };
  const conference: TierRequirement = { ...classic, tier: 'conference', tierLabel: 'Conference', leadDays: 120 };
  const exhibition: TierRequirement = { ...classic, tier: 'exhibition', tierLabel: 'Exhibition', leadDays: null };
  const now = new Date('2026-10-01T00:00:00Z');
  it('is fine when there is time', () => {
    const advice = leadTimeAdvice(classic, '2026-12-01T00:00:00Z', now);
    expect(advice.status).toBe('ok');
    expect(advice.message).toMatch(/16 days left/);
  });
  it('warns, without blocking, when the window may have passed', () => {
    const advice = leadTimeAdvice(conference, '2026-11-14T00:00:00Z', now);
    expect(advice.status).toBe('late');
    expect(advice.message).toMatch(/120 days ahead/);
    expect(advice.message).toMatch(/check with the authority/i);
  });
  it('has nothing to say for exhibitions or an unset date', () => {
    expect(leadTimeAdvice(exhibition, '2026-11-14T00:00:00Z', now).status).toBe('none');
    expect(leadTimeAdvice(classic, undefined, now).message).toMatch(/set the event date/i);
  });
  it('checks the 15-day registration close guidance', () => {
    expect(registrationCloseAdvice('2026-11-14T00:00:00Z', '2026-11-10T00:00:00Z')).toMatch(/at least 15 days/);
    expect(registrationCloseAdvice('2026-11-14T00:00:00Z', '2026-10-20T00:00:00Z')).toBeUndefined();
  });
});
