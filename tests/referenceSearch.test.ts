import { describe, expect, it } from 'vitest';
import { referenceKindLabels, searchReference, type ReferenceCorpus } from '../src/lib/referenceSearch';

// A slice of the seeded BI reference data.
const corpus: ReferenceCorpus = {
  documents: [
    { id: 'd1', family: 'tournament', title: 'Tournament Structure and Formats', version: 'Jan 2026', effectiveLabel: 'Updated January 2026', url: 'https://example.test/ts.pdf', verifiedAt: '2026-09-30', notes: 'Format by entrant count, tiebreaks, season points.' },
    { id: 'd2', family: 'authenticity', title: 'Armor Requirements', url: 'https://example.test/armor', verifiedAt: '2026-09-30', notes: 'Source link only.' }
  ],
  tiers: [
    { authority: 'bi', docVersion: 'v2026.1', tier: 'classic', tierLabel: 'Classic', leadDays: 45, sourceRef: 'League Structure v2026.1 §2.3.3', requirements: { marshals: '1 Conference Accredited Marshal', approval: 'Submitted to BI 45 days in advance.', minimumEntrants: { buhurtMen: '4 registered 5v5 BI teams' } } },
    { authority: 'bi', docVersion: 'v2026.1', tier: 'conference', tierLabel: 'Conference', leadDays: 120, sourceRef: 'League Structure v2026.1 §2.3.5', requirements: { approval: 'Needs 60/40 approval from all National Organizations.' } }
  ],
  templates: [
    { authority: 'bi', docVersion: 'Jan 2026', optionKey: 'pools_12_16_two_se', title: 'Two pools of 6-8, then a single-elimination bracket', minEntrants: 12, maxEntrants: 16, structure: { kind: 'pools', pools: 2, poolSizeMin: 6, poolSizeMax: 8, advancePerPool: 2, finals: 'single_elimination', finalists: 4, thirdPlaceMatch: true }, recommended: true, sourceRef: '§1.5.1 Option 1B' },
    { authority: 'bi', docVersion: 'Jan 2026', optionKey: 'pools_12_16_three_se', title: 'Three pools of 4-6, then a six-team single-elimination bracket', minEntrants: 12, maxEntrants: 16, structure: { kind: 'pools', pools: 3, poolSizeMin: 4, poolSizeMax: 6, advancePerPool: 2, finals: 'single_elimination', finalists: 6 }, recommended: false, caution: 'Not recommended by the document because of six-team brackets.', sourceRef: '§1.5.2 Option 2B' }
  ],
  tiebreak: { authority: 'bi', docVersion: 'Jan 2026', sourceRef: 'Tournament Structure Jan 2026 §3', steps: [{ key: 'head_to_head', label: 'Head-to-head result', appliesTo: 'two_way_tie_only' }, { key: 'fewest_penalties', label: 'Fewest penalties received' }] }
};

const kinds = (q: string) => searchReference(q, corpus).map(r => r.kind);

describe('reference search', () => {
  it('finds a tier by name and by its lead time, labeled as a tier requirement', () => {
    expect(kinds('classic')).toContain('tier_requirement');
    const byDays = searchReference('120 days', corpus);
    expect(byDays.map(r => r.title)).toEqual(['Conference tournament']);
    expect(byDays[0].source).toBe('League Structure v2026.1 §2.3.5');
    expect(byDays[0].version).toBe('v2026.1');
  });
  it('finds structure guidance by entrant count and by structure words', () => {
    const byPools = searchReference('pools', corpus).filter(r => r.kind === 'structure_guidance');
    expect(byPools).toHaveLength(2);
    expect(searchReference('14 entrants', corpus).filter(r => r.kind === 'structure_guidance')).toHaveLength(0);
    expect(searchReference('12-16 entrants', corpus).filter(r => r.kind === 'structure_guidance')).toHaveLength(2);
  });
  it('carries cautions so a discouraged structure is not presented as plain advice', () => {
    const six = searchReference('six-team', corpus)[0];
    expect(six.summary).toMatch(/Not recommended/);
  });
  it('finds the tiebreak order with its version and source', () => {
    const result = searchReference('tiebreak', corpus).find(r => r.kind === 'tiebreak_rule')!;
    expect(result.summary).toMatch(/1\. Head-to-head result \(two-way ties only\) 2\. Fewest penalties received/);
    expect(result.version).toBe('Jan 2026');
    expect(result.source).toBe('Tournament Structure Jan 2026 §3');
  });
  it('finds official documents, keeps provenance and a link, and says when no version is stated', () => {
    const docs = searchReference('armor', corpus).filter(r => r.kind === 'official_document');
    expect(docs).toHaveLength(1);
    expect(docs[0]).toMatchObject({ url: 'https://example.test/armor', checkedAt: '2026-09-30', version: undefined });
    expect(searchReference('tournament structure', corpus).some(r => r.kind === 'official_document' && r.version === 'Jan 2026')).toBe(true);
  });
  it('requires every word to match, and returns nothing for an empty query', () => {
    expect(searchReference('classic pools', corpus)).toEqual([]);
    expect(searchReference('   ', corpus)).toEqual([]);
  });
  it('never labels reference material as a fight rule', () => {
    for (const result of searchReference('a', { ...corpus })) expect(Object.keys(referenceKindLabels)).toContain(result.kind);
    for (const meta of Object.values(referenceKindLabels)) expect(meta.explains).toMatch(/not a fight rule|actual text|published by the authority/i);
  });
});
