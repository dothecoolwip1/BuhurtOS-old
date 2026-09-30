import { useCallback, useEffect, useState } from 'react';
import { publicSupabase } from '../lib/supabase';
import { friendlyError } from '../lib/friendlyError';
import { loadCompetitionReferenceData, type TierRequirement } from '../lib/tournamentStructure';

interface RuleDocument { id: string; family: 'executive' | 'marshal' | 'tournament' | 'authenticity'; title: string; version?: string; effectiveLabel?: string; url: string; verifiedAt: string; notes?: string }

const familyLabels: Record<RuleDocument['family'], { label: string; blurb: string }> = {
  tournament: { label: 'Tournament', blurb: 'How tournaments are structured, formatted, scored and run.' },
  marshal: { label: 'Marshal', blurb: 'How fights are officiated.' },
  authenticity: { label: 'Authenticity', blurb: 'Armor and weapon requirements. Listed as source links only.' },
  executive: { label: 'Executive', blurb: 'Policies, conduct and governance. Listed as source links only.' }
};
const familyOrder: RuleDocument['family'][] = ['tournament', 'marshal', 'authenticity', 'executive'];

const money = (value: unknown) => (typeof value === 'string' ? value : '');

/**
 * Where the tournament and league information comes from: each official Buhurt International document with its version,
 * when BuhurtOS last checked it, and a link to the original. BuhurtOS links to the documents; it does not republish them.
 */
export function OfficialBiDocuments() {
  const [documents, setDocuments] = useState<RuleDocument[]>();
  const [tiers, setTiers] = useState<TierRequirement[]>([]);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setError(''); setDocuments(undefined);
    if (!publicSupabase) { setDocuments([]); return; }
    Promise.all([
      publicSupabase.from('rule_documents').select('*').eq('authority', 'bi').order('title'),
      loadCompetitionReferenceData()
    ]).then(([docs, reference]) => {
      if (docs.error) throw docs.error;
      setDocuments((docs.data ?? []).map((row: any) => ({ id: row.id, family: row.family, title: row.title, version: row.version ?? undefined, effectiveLabel: row.effective_label ?? undefined, url: row.source_url, verifiedAt: row.verified_at, notes: row.notes ?? undefined })));
      setTiers(['exhibition', 'source', 'classic', 'regional', 'conference'].map(t => reference.tiers.find(x => x.tier === t)).filter((x): x is TierRequirement => Boolean(x)));
    }).catch(err => { setError(friendlyError(err).message); setDocuments([]); });
  }, []);
  useEffect(load, [load]);

  const disagree = tiers.some(t => t.requirements.sourcesDisagree === true);

  return <section className="marshal-filter-panel" aria-labelledby="bi-docs-title">
    <div><span className="eyebrow">WHERE THIS COMES FROM</span><h2 id="bi-docs-title">Official Buhurt International documents</h2>
      <p>Tournament, league and structure information in BuhurtOS comes from these documents. Always check the original for the event you are running. BuhurtOS is not a Buhurt International product and is not endorsed by it.</p></div>
    {error ? <div className="state-card" role="alert"><strong>The document list could not be loaded</strong><p>{error}</p><button type="button" className="show-btn" onClick={load}>Try again</button></div> : null}
    {documents === undefined ? <div className="state-card" role="status">Loading documents…</div> : null}
    {documents && documents.length > 0 ? familyOrder.map(family => {
      const docs = documents.filter(d => d.family === family);
      if (!docs.length) return null;
      return <div key={family}>
        <h3>{familyLabels[family].label}</h3><p className="hint">{familyLabels[family].blurb}</p>
        <div className="marshal-source-grid">{docs.map(doc => <article className="marshal-source-card" key={doc.id}>
          <h4>{doc.title}</h4>
          <strong>{doc.version ? 'Version ' + doc.version : 'Version not stated by the source'}</strong>
          <small>{doc.effectiveLabel ? doc.effectiveLabel + ' · ' : ''}Checked by BuhurtOS {doc.verifiedAt}</small>
          <a className="show-btn secondary full" href={doc.url} target="_blank" rel="noopener noreferrer">Open official document ↗</a>
        </article>)}</div>
      </div>;
    }) : null}
    {tiers.length ? <div>
      <h3>Tournament tiers and what each asks for</h3>
      <p className="hint">From League Structure v2026.1. These are the authority’s requirements; approval happens with that authority, not in BuhurtOS.</p>
      <div className="nx-table-wrap"><table className="nx-table">
        <thead><tr><th>Tier</th><th>Submit ahead</th><th>Marshals</th><th>Approval and notes</th></tr></thead>
        <tbody>{tiers.map(tier => <tr key={tier.tier}>
          <th scope="row">{tier.tierLabel}</th>
          <td>{tier.leadDays ? tier.leadDays + ' days' : '—'}</td>
          <td>{money(tier.requirements.marshals) || '—'}</td>
          <td>{money(tier.requirements.approval) || money(tier.requirements.note) || '—'}<br /><small>{tier.sourceRef}</small></td>
        </tr>)}</tbody>
      </table></div>
      {disagree ? <p className="hint">The League Structure and the Tournament Structure give different season point values for Regional and Conference tournaments. BuhurtOS does not choose between them; check both documents.</p> : null}
    </div> : null}
  </section>;
}
