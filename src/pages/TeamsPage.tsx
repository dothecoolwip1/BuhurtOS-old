import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { externalTeamSources } from '../data/hacsaTeams';
import { hacsaFallbackDirectory, loadPublicTeamDirectory, type PublicDirectoryTeam } from '../lib/teamDirectory';
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
  const [province,setProvince]=useState('all');
  const [directory,setDirectory]=useState<PublicDirectoryTeam[]>(()=>hacsaFallbackDirectory());
  const [directoryStatus,setDirectoryStatus]=useState<'loading'|'live'|'fallback'>('loading');

  useEffect(()=>{
    let active=true;
    loadPublicTeamDirectory({ organizationShortName:'HACSA' })
      .then(rows=>{
        if(!active)return;
        setDirectory(rows.length?rows:hacsaFallbackDirectory());
        setDirectoryStatus(rows.length?'live':'fallback');
      })
      .catch(()=>{
        if(!active)return;
        setDirectory(hacsaFallbackDirectory());
        setDirectoryStatus('fallback');
      });
    return ()=>{active=false;};
  },[]);

  const provinces=useMemo(()=>{
    const values=new Map<string,string>();
    directory.forEach(team=>values.set(team.adminAreaCode,team.adminAreaName));
    return [...values.entries()].sort((a,b)=>a[1].localeCompare(b[1]));
  },[directory]);

  const teams=useMemo(()=>{
    const needle=query.trim().toLowerCase();
    return directory.filter(team=>{
      if(province!=='all'&&team.adminAreaCode!==province)return false;
      if(!needle)return true;
      return [team.name,team.location,team.email ?? '',team.adminAreaName,team.countryName]
        .some(value=>value.toLowerCase().includes(needle));
    });
  },[directory,province,query]);

  const grouped=useMemo(()=>{
    const groups=new Map<string,PublicDirectoryTeam[]>();
    teams.forEach(team=>{
      const list=groups.get(team.adminAreaName)??[];
      list.push(team);
      groups.set(team.adminAreaName,list);
    });
    return [...groups.entries()].sort((a,b)=>a[0].localeCompare(b[0]));
  },[teams]);

  const currentSource=externalTeamSources.find(source=>source.id==='hacsa');

  return <>
    <PageHeader
      eyebrow="HACSA Teams"
      title="Official team directory"
      description="HACSA is the first live team source in BuhurtOS. Browse the directory by organization, continent, country and province while keeping HACSA's published team details intact."
      actions={<label className="show-search"><span>⌕</span><input aria-label="Search teams" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search team, city, province or email"/></label>}
    />

    <div className="directory-hierarchy" aria-label="Directory hierarchy">
      <strong>HACSA</strong><span>›</span><b>North America</b><span>›</span><b>Canada</b>
    </div>

    <div className="province-filter" aria-label="Province filter">
      <button className={province==='all'?'selected':''} onClick={()=>setProvince('all')}>All provinces <small>{directory.length}</small></button>
      {provinces.map(([code,name])=><button key={code} className={province===code?'selected':''} onClick={()=>setProvince(code)}>
        {name} <small>{directory.filter(team=>team.adminAreaCode===code).length}</small>
      </button>)}
    </div>

    <div className="source-trust-strip">
      <div>
        <Pill tone="green">Source-backed</Pill>
        <strong>{currentSource?.label}</strong>
        <span>Verified 2026-09-29</span>
        <span>{directoryStatus==='live'?'Live Supabase directory':directoryStatus==='loading'?'Checking live directory…':'Verified local fallback'}</span>
      </div>
      <a className="show-btn secondary" href={currentSource?.url} target="_blank" rel="noopener noreferrer">Open HACSA source ↗</a>
    </div>

    {teams.length===0?<div className="state-card">No HACSA teams match that search or province.</div>:<div className="directory-groups">
      {grouped.map(([area,areaTeams])=><section className="directory-group" key={area}>
        <header><div><small>Canada</small><h2>{area}</h2></div><Pill>{areaTeams.length} {areaTeams.length===1?'team':'teams'}</Pill></header>
        <div className="show-team-grid">{areaTeams.map(team=><Link to={`/teams/${team.slug}`} className="show-team-card" key={team.slug}>
          <div className="show-team-banner official"><span>{initials(team.name)}</span><Pill tone="green">HACSA</Pill></div>
          <div className="show-team-body">
            <small>{team.location} · {team.adminAreaName}</small>
            <h2>{team.name}</h2>
            <p>Current public team listing from HACSA.</p>
            {team.email?<div className="official-team-contact"><span>Contact</span><b>{team.email}</b></div>:null}
          </div>
        </Link>)}</div>
      </section>)}
    </div>}

    <div className="source-roadmap">
      {externalTeamSources.map(source=><article key={source.id} className={source.status==='current'?'current':''}>
        <div><small>Priority {source.priority}</small><strong>{source.label}</strong></div>
        <Pill tone={source.status==='current'?'green':'neutral'}>{source.status==='current'?'Active source':'Next source'}</Pill>
      </article>)}
    </div>
  </>;
}
