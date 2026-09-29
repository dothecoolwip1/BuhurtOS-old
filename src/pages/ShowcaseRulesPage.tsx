import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { biRuleEntries, biRuleReferenceVerifiedAt, biRuleSources, biRulesLandingPage } from '../data/biMarshalRules';
import { filterBiRules, formatFromMatchCategory, ruleFilterLabels, type RuleFilter } from '../lib/ruleReference';
import { PageHeader, Pill } from '../components/ShowcaseUI';

const filters: RuleFilter[] = ['all','buhurt','3v3','5v5','12v12','30v30','champions_fight','duels','longsword','sword_shield','sword_buckler','polearm','triathlon','outrance'];
const quickSearches = ['grounded','prohibited strike zone','weapon loss','armor failure','yellow card','appeal'];

function initialFilter(raw: string | null): RuleFilter {
  if (raw && Object.prototype.hasOwnProperty.call(ruleFilterLabels, raw)) return raw as RuleFilter;
  return formatFromMatchCategory(raw);
}

export function ShowcaseRulesPage(){
  const [params,setParams]=useSearchParams();
  const [format,setFormatState]=useState<RuleFilter>(()=>initialFilter(params.get('format')));
  const [query,setQuery]=useState(params.get('q') ?? '');
  const [sourceId,setSourceId]=useState(params.get('source') ?? 'all');

  const setFormat=(next:RuleFilter)=>{
    setFormatState(next);
    const updated=new URLSearchParams(params);
    if(next==='all') updated.delete('format'); else updated.set('format',next);
    setParams(updated,{replace:true});
  };

  const rules=useMemo(()=>{
    const filtered=filterBiRules(biRuleEntries,format,query);
    return sourceId==='all'?filtered:filtered.filter(entry=>entry.sourceId===sourceId);
  },[format,query,sourceId]);

  const sourceById=useMemo(()=>new Map(biRuleSources.map(source=>[source.id,source])),[]);

  return <>
    <PageHeader
      eyebrow="BI Marshal Reference"
      title="Rules for the fight in front of you"
      description="Search the current Buhurt International fight rulebooks by category, call, penalty, technique or situation. Every result keeps its official document, version and section number visible."
      actions={<a className="show-btn secondary" href={biRulesLandingPage} target="_blank" rel="noopener noreferrer">Official BI rules page ↗</a>}
    />

    <div className="rule-source-status">
      <div><Pill tone="green">Source-backed</Pill><strong>{biRuleEntries.length} indexed rule sections</strong><span>Source set checked {biRuleReferenceVerifiedAt}</span></div>
      <span>Current fight corpus: Buhurt Rules 26.4.1, Buhurt Regulations 26.4, Duels Rules 26.4, Duels Regulations 26.4, Outrance 26.4 and Weapons / Shield Chart 26.2.1.</span>
    </div>

    <section className="marshal-filter-panel">
      <div className="marshal-format-tabs" role="tablist" aria-label="Fight format">
        {filters.map(value=><button key={value} className={format===value?'selected':''} onClick={()=>setFormat(value)}>{ruleFilterLabels[value]}</button>)}
      </div>
      <div className="marshal-search-row">
        <label className="show-search grow"><span>⌕</span><input aria-label="Search BI rules" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Try: grounded, back of knee, armor failure, yellow card…"/></label>
        <select aria-label="Filter by source document" value={sourceId} onChange={e=>setSourceId(e.target.value)}>
          <option value="all">All source documents</option>
          {biRuleSources.map(source=><option key={source.id} value={source.id}>{source.title} {source.version}</option>)}
        </select>
      </div>
      <div className="marshal-quick-search" aria-label="Common marshal questions">
        <span>Quick calls</span>
        {quickSearches.map(value=><button key={value} onClick={()=>setQuery(value)}>{value}</button>)}
        {(query||sourceId!=='all')?<button className="clear" onClick={()=>{setQuery('');setSourceId('all');}}>Clear</button>:null}
      </div>
    </section>

    <div className="marshal-result-head">
      <div><span className="eyebrow">Showing</span><h2>{ruleFilterLabels[format]}</h2></div>
      <strong>{rules.length} matching sections</strong>
    </div>

    {rules.length===0?<div className="state-card">No BI rule section matches those filters. Clear the search or choose another fight format.</div>:<div className="marshal-rule-grid">{rules.map(entry=>{
      const source=sourceById.get(entry.sourceId);
      return <article className="marshal-rule-card" key={entry.id}>
        <header>
          <div><span className="marshal-section">{entry.section}</span><h3>{entry.title}</h3></div>
          {entry.marshalCall?<Pill tone="amber">{entry.marshalCall}</Pill>:null}
        </header>
        <p>{entry.summary}</p>
        {entry.details?.length?<ul>{entry.details.map((detail,index)=><li key={index}>{detail}</li>)}</ul>:null}
        {entry.penalty?<div className="marshal-penalty"><b>Penalty / consequence</b><span>{entry.penalty}</span></div>:null}
        <footer>
          <div><small>{source?.title}</small><b>Version {source?.version} · § {entry.section}</b></div>
          {source?<a href={source.url} target="_blank" rel="noopener noreferrer">Open source ↗</a>:null}
        </footer>
      </article>;
    })}</div>}

    <section className="bi-source-library">
      <div className="section-head"><div><span className="eyebrow">Official documents</span><h2>BI source library</h2></div><span>{biRuleSources.length} current fight-reference sources</span></div>
      <div className="bi-source-grid">{biRuleSources.map(source=><article key={source.id}>
        <div><Pill tone="blue">BI</Pill><small>{source.publishedLabel}</small></div>
        <h3>{source.title}</h3>
        <p>{source.scope}</p>
        <strong>Version {source.version}</strong>
        <a className="show-btn secondary full" href={source.url} target="_blank" rel="noopener noreferrer">Open official document ↗</a>
      </article>)}</div>
    </section>
  </>;
}
