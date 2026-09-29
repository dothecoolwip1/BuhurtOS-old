import type { BiRuleEntry, RuleFormat } from '../data/biMarshalRules';

export type RuleFilter = RuleFormat | 'all';

const aliases: Array<[RegExp, RuleFormat]> = [
  [/outrance|profight/i, 'outrance'],
  [/sword\s*(?:&|and)?\s*shield/i, 'sword_shield'],
  [/sword\s*(?:&|and)?\s*buckler|buckler/i, 'sword_buckler'],
  [/long\s*sword/i, 'longsword'],
  [/pole\s*arm/i, 'polearm'],
  [/triathlon/i, 'triathlon'],
  [/champion/i, 'champions_fight'],
  [/30\s*v\s*30/i, '30v30'],
  [/12\s*v\s*12/i, '12v12'],
  [/5\s*v\s*5/i, '5v5'],
  [/3\s*v\s*3/i, '3v3'],
  [/buhurt|melee/i, 'buhurt']
];

export const ruleFilterLabels: Record<RuleFilter, string> = {
  all: 'All BI rules',
  buhurt: 'Buhurt / group battles',
  '3v3': '3v3',
  '5v5': '5v5',
  '12v12': '12v12',
  '30v30': '30v30',
  champions_fight: 'Champion’s Fight',
  duels: 'All duels',
  longsword: 'Longsword',
  sword_shield: 'Sword & Shield',
  sword_buckler: 'Sword & Buckler',
  polearm: 'Polearm',
  triathlon: 'Triathlon',
  outrance: 'Outrance'
};

export function formatFromMatchCategory(category?: string | null): RuleFilter {
  if (!category) return 'all';
  for (const [pattern, format] of aliases) {
    if (pattern.test(category)) return format;
  }
  return 'all';
}

function belongsToFamily(format: RuleFilter, appliesTo: RuleFormat[]) {
  if (format === 'all' || appliesTo.includes('all')) return true;
  if (appliesTo.includes(format)) return true;

  const buhurtFormats: RuleFormat[] = ['3v3', '5v5', '12v12', '30v30'];
  const duelFormats: RuleFormat[] = ['longsword', 'sword_shield', 'sword_buckler', 'polearm', 'triathlon'];

  if (buhurtFormats.includes(format as RuleFormat) && appliesTo.includes('buhurt')) return true;
  if (format === 'buhurt' && appliesTo.some(value => buhurtFormats.includes(value))) return true;
  if (duelFormats.includes(format as RuleFormat) && appliesTo.includes('duels')) return true;
  if (format === 'duels' && appliesTo.some(value => duelFormats.includes(value))) return true;
  if (format === 'champions_fight' && appliesTo.includes('buhurt')) return true;

  return false;
}

export function filterBiRules(entries: BiRuleEntry[], format: RuleFilter, query: string) {
  const needle = query.trim().toLowerCase();
  return entries.filter(entry => {
    if (!belongsToFamily(format, entry.appliesTo)) return false;
    if (!needle) return true;
    const haystack = [
      entry.section,
      entry.title,
      entry.summary,
      entry.marshalCall ?? '',
      entry.penalty ?? '',
      ...entry.tags,
      ...(entry.details ?? [])
    ].join(' ').toLowerCase();
    return haystack.includes(needle);
  });
}
