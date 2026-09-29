import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { hacsaTeams, externalTeamSources } from '../data/hacsaTeams';
import { PageHeader, Pill } from '../components/ShowcaseUI';

function initials(name: string) {
  return name
    .replace(/^The\s+/i, '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 3)
    .map(part => part[0]?.toUpperCase())
    .join('');
}

export function TeamsPage(){
  const [query,setQuery]=useState('');
  const teams=useMemo(()=>{
    const needle=query.trim().toLowerCase();
    if(!needle)return hacsaTeams;
    return hacsaTeams.filter(team=>[team.name,team.location,team.email].some(value=>value.toLowerCase().includes(needle)));
  },[query]);
  const currentSource=externalTeamSources.find(source=>source.id==='hacsa');

  return <>
    <PageHeader
      eyebrow="HACSA Teams"
      title="Official team directory"
      description="HACSA is the first team source for BuhurtOS. These records come from HACSA's public team directory, with BI Teams and BI Official Ranking staged as the next sources."
      actions={<label className="show-search"><span>⌕</span><input aria-label="Search teams" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search team, city or email"/></label>}
    />

    <div className="source-trust-strip">
      <div><Pill tone="green">Source-backed</Pill><strong>{currentSource?.label}</strong><span>Verified 2026-09-29</span></div>
      <a className="show-btn secondary" href={currentSource?.url} target="_blank" rel="noopener noreferrer">Open HACSA source ↗</a>
    </div>

    {teams.length===0?<div className="state-card">No HACSA teams match that search.</div>:<div className="show-team-grid">{teams.map(team=><Link to={`/teams/${team.id}`} className="show-team-card" key={team.id}>
      <div className="show-team-banner official"><span>{initials(team.name)}</span><Pill tone="green">HACSA</Pill></div>
      <div className="show-team-body">
        <small>{team.location}</small>
        <h2>{team.name}</h2>
        <p>Current public team listing from HACSA.</p>
        <div className="official-team-contact"><span>Contact</span><b>{team.email}</b></div>
      </div>
    </Link>)}</div>}

    <div className="source-roadmap">
      {externalTeamSources.map(source=><article key={source.id} className={source.status==='current'?'current':''}>
        <div><small>Priority {source.priority}</small><strong>{source.label}</strong></div>
        <Pill tone={source.status==='current'?'green':'neutral'}>{source.status==='current'?'Active source':'Next source'}</Pill>
      </article>)}
    </div>
  </>;
}
