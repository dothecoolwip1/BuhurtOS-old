import { useEffect, useMemo, useState } from 'react';
import { friendlyError } from '../lib/friendlyError';
import { loadReferenceCorpus, referenceKindLabels, searchReference, type ReferenceCorpus, type ReferenceKind } from '../lib/referenceSearch';

const kindOrder: ReferenceKind[] = ['tier_requirement', 'structure_guidance', 'tiebreak_rule', 'official_document'];

/**
 * Reference material that matches the search but is not a fight rule: tiers, structure guidance, tiebreak order and the
 * official documents. Grouped and labeled by what it is, each with its source and version.
 */
export function ReferenceMatches({ query }: { query: string }) {
  const [corpus, setCorpus] = useState<ReferenceCorpus>();
  const [error, setError] = useState('');
  const [attempt, setAttempt] = useState(0);
  useEffect(() => {
    let active = true;
    setError('');
    loadReferenceCorpus().then(c => { if (active) setCorpus(c); }).catch(err => { if (active) setError(friendlyError(err).message); });
    return () => { active = false; };
  }, [attempt]);

  const results = useMemo(() => (corpus ? searchReference(query, corpus) : []), [corpus, query]);
  if (!query.trim()) return null;
  if (error) return <div className="state-card" role="alert"><strong>Tournament reference material could not be searched</strong><p>{error}</p><button type="button" className="show-btn" onClick={() => setAttempt(n => n + 1)}>Try again</button></div>;
  if (!corpus) return <div className="state-card" role="status">Searching tournament reference material…</div>;
  if (results.length === 0) return <p className="hint">No tournament tiers, structure guidance, tiebreaks or official documents match “{query}”.</p>;

  return <section className="marshal-filter-panel" aria-labelledby="ref-matches-title">
    <div><span className="eyebrow">NOT FIGHT RULES</span><h2 id="ref-matches-title">Tournament reference matching “{query}”</h2>
      <p className="hint">These are tournament and league requirements, structure guidance and source documents. They are separate from the fight rule sections above.</p></div>
    {kindOrder.map(kind => {
      const group = results.filter(r => r.kind === kind);
      if (!group.length) return null;
      return <div key={kind}>
        <h3>{referenceKindLabels[kind].label} ({group.length})</h3>
        <p className="hint">{referenceKindLabels[kind].explains}</p>
        <div className="marshal-source-grid">{group.map(result => <article className="marshal-source-card" key={result.id}>
          <span className="eyebrow">{referenceKindLabels[result.kind].label.toUpperCase()}</span>
          <h4>{result.title}</h4>
          <p>{result.summary}</p>
          <small>Source: {result.source}{result.version ? ' · version ' + result.version : ''}{result.checkedAt ? ' · checked ' + result.checkedAt : ''}</small>
          {result.url ? <a className="show-btn secondary full" href={result.url} target="_blank" rel="noopener noreferrer">Open official document ↗</a> : null}
        </article>)}</div>
      </div>;
    })}
  </section>;
}
