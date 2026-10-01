import { publicSupabase } from './supabase';
import { describeStructure, type FormatTemplate, type TierRequirement } from './tournamentStructure';
import { loadTiebreakPolicy, type TiebreakPolicy } from './tiebreak';

/**
 * Search over the reference material that is NOT a fight rule: official documents, tournament tiers, structure guidance
 * and the tiebreak order. Every result says what kind of thing it is and where it came from, so a tier requirement is
 * never mistaken for a rule a marshal enforces on the field.
 */
export type ReferenceKind = 'official_document' | 'tier_requirement' | 'structure_guidance' | 'tiebreak_rule';

export const referenceKindLabels: Record<ReferenceKind, { label: string; explains: string }> = {
  official_document: { label: 'Official document', explains: 'A document published by the authority. Open it to read the actual text.' },
  tier_requirement: { label: 'Tournament tier requirement', explains: 'What a tournament tier asks of the organizer. Not a fight rule.' },
  structure_guidance: { label: 'Tournament structure guidance', explains: 'How an event may be structured for a given number of entrants. Not a fight rule.' },
  tiebreak_rule: { label: 'Standings tiebreak order', explains: 'How teams or competitors level on points are ordered. Not a fight rule.' }
};

export interface RuleDocument {
  id: string;
  family: 'executive' | 'marshal' | 'tournament' | 'authenticity';
  title: string;
  version?: string;
  effectiveLabel?: string;
  url: string;
  verifiedAt: string;
  notes?: string;
}

export interface ReferenceResult {
  id: string;
  kind: ReferenceKind;
  title: string;
  summary: string;
  /** Where it comes from, in words: document and section. */
  source: string;
  version?: string;
  checkedAt?: string;
  url?: string;
}

export interface ReferenceCorpus {
  documents: RuleDocument[];
  tiers: TierRequirement[];
  templates: FormatTemplate[];
  tiebreak?: TiebreakPolicy;
}

const tokens = (text: string) => text.toLowerCase().split(/[^a-z0-9§.]+/).filter(Boolean);

function flatten(value: unknown): string {
  if (value == null) return '';
  if (typeof value === 'string') return value;
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  if (Array.isArray(value)) return value.map(flatten).join(' ');
  if (typeof value === 'object') return Object.values(value as Record<string, unknown>).map(flatten).join(' ');
  return '';
}

/** Every query word must appear somewhere in the item's text. */
function matches(query: string, haystack: string): boolean {
  const words = tokens(query);
  if (words.length === 0) return false;
  const text = haystack.toLowerCase();
  return words.every(word => text.includes(word));
}

const familyLabel: Record<RuleDocument['family'], string> = { executive: 'Executive', marshal: 'Marshal', tournament: 'Tournament', authenticity: 'Authenticity' };

export function searchReference(query: string, corpus: ReferenceCorpus): ReferenceResult[] {
  if (!query.trim()) return [];
  const out: ReferenceResult[] = [];

  for (const doc of corpus.documents) {
    const text = [doc.title, doc.family, familyLabel[doc.family], doc.version ?? '', doc.effectiveLabel ?? '', doc.notes ?? ''].join(' ');
    if (matches(query, text)) {
      out.push({
        id: 'doc:' + doc.id, kind: 'official_document', title: doc.title,
        summary: `${familyLabel[doc.family]} document${doc.notes ? '. ' + doc.notes : '.'}`,
        source: 'Buhurt International official documents', version: doc.version, checkedAt: doc.verifiedAt, url: doc.url
      });
    }
  }

  for (const tier of corpus.tiers) {
    const text = [tier.tierLabel, tier.tier, tier.leadDays != null ? `${tier.leadDays} days ahead submit` : '', flatten(tier.requirements)].join(' ');
    if (matches(query, text)) {
      const r = tier.requirements as Record<string, unknown>;
      const bits = [
        tier.leadDays != null ? `Submit ${tier.leadDays} days ahead.` : undefined,
        typeof r.marshals === 'string' ? `Marshals: ${r.marshals}.` : undefined,
        typeof r.approval === 'string' ? r.approval : typeof r.note === 'string' ? r.note : undefined
      ].filter(Boolean);
      out.push({ id: 'tier:' + tier.tier, kind: 'tier_requirement', title: `${tier.tierLabel} tournament`, summary: bits.join(' '), source: tier.sourceRef, version: tier.docVersion });
    }
  }

  for (const template of corpus.templates) {
    const range = template.maxEntrants == null ? `${template.minEntrants}+` : `${template.minEntrants}-${template.maxEntrants}`;
    const text = [template.title, `${range} entrants teams competitors`, describeStructure(template), template.caution ?? '', template.sourceRef, template.optionKey.replaceAll('_', ' ')].join(' ');
    if (matches(query, text)) {
      out.push({
        id: 'structure:' + template.optionKey, kind: 'structure_guidance', title: `${template.title} (${range} entrants)`,
        summary: describeStructure(template) + (template.caution ? ' ' + template.caution : template.recommended ? '' : ' Not recommended.'),
        source: `Tournament Structure ${template.sourceRef}`, version: template.docVersion
      });
    }
  }

  if (corpus.tiebreak) {
    const policy = corpus.tiebreak;
    const text = ['tiebreak tie break tied standings order head-to-head penalties', policy.steps.map(s => s.label).join(' '), policy.sourceRef].join(' ');
    if (matches(query, text)) {
      out.push({
        id: 'tiebreak:' + policy.authority, kind: 'tiebreak_rule', title: `${policy.authority.toUpperCase()} tiebreak order`,
        summary: policy.steps.map((s, i) => `${i + 1}. ${s.label}${s.appliesTo === 'two_way_tie_only' ? ' (two-way ties only)' : ''}`).join(' '),
        source: policy.sourceRef, version: policy.docVersion
      });
    }
  }
  return out;
}

let cache: { at: number; value: ReferenceCorpus } | undefined;

export async function loadReferenceCorpus(): Promise<ReferenceCorpus> {
  if (cache && Date.now() - cache.at < 5 * 60 * 1000) return cache.value;
  if (!publicSupabase) return { documents: [], tiers: [], templates: [] };
  const [docs, tiers, templates, tiebreak] = await Promise.all([
    publicSupabase.from('rule_documents').select('*').eq('authority', 'bi').order('title'),
    publicSupabase.from('ruleset_tier_requirements').select('*'),
    publicSupabase.from('tournament_format_templates').select('*').order('min_entrants'),
    loadTiebreakPolicy('bi')
  ]);
  if (docs.error) throw docs.error;
  if (tiers.error) throw tiers.error;
  if (templates.error) throw templates.error;
  const value: ReferenceCorpus = {
    documents: (docs.data ?? []).map((row: any) => ({ id: row.id, family: row.family, title: row.title, version: row.version ?? undefined, effectiveLabel: row.effective_label ?? undefined, url: row.source_url, verifiedAt: row.verified_at, notes: row.notes ?? undefined })),
    tiers: (tiers.data ?? []).map((row: any) => ({ authority: row.authority, docVersion: row.doc_version, tier: row.tier, tierLabel: row.tier_label, leadDays: row.lead_days ?? null, requirements: row.requirements ?? {}, sourceRef: row.source_ref })),
    templates: (templates.data ?? []).map((row: any) => ({ authority: row.authority, docVersion: row.doc_version, optionKey: row.option_key, title: row.title, minEntrants: row.min_entrants, maxEntrants: row.max_entrants ?? null, structure: row.structure ?? { kind: 'unknown' }, recommended: Boolean(row.recommended), caution: row.caution ?? undefined, sourceRef: row.source_ref })),
    tiebreak
  };
  cache = { at: Date.now(), value };
  return value;
}
