import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {PublicTeamMap} from '../components/PublicTeamMap';

const initials=(n:string)=>n.replace(/^The\s+/i,'').split(/\s+/).filter(Boolean).slice(0,3).map(x=>x[0]?.toUpperCase()).join('');

export function TeamsPage(){
 const [query,setQuery]=useState(''); const [org,setOrg]=useState('all'); const [country,setCountry]=useState('all');
 const [directory,setDirectory]=useState<PublicDirectoryTeam[]>([]); const [loading,setLoading]=useState(true); const [error,setError]=useState(''); const [view,setView]=useState<'directory'|'map'>('directory'); const [visibleCount,setVisibleCount]=useState(60);
 useEffect(()=>{let active=true;loadPublicTeamDirectory().then(x=>{if(active)setDirectory(x)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load the team directory.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const orgs=useMemo(()=>[...new Set(directory.map(x=>x.organizationShortName).filter(Boolean))].sort(),[directory]);
 const countries=useMemo(()=>[...new Set(directory.map(x=>x.countryName).filter(x=>x&&x!=='Country pending'))].sort(),[directory]);
 const teams=useMemo(()=>{const n=query.trim().toLowerCase();return directory.filter(t=>(org==='all'||t.organizationShortName===org)&&(country==='all'||t.countryName===country)&&(!n||[t.name,t.location,t.adminAreaName,t.countryName,t.organizationShortName,t.captain??''].some(v=>v.toLowerCase().includes(n))))},[directory,query,org,country]);
 const mapped=teams.filter(t=>t.latitude!=null&&t.longitude!=null); const visibleTeams=teams.slice(0,visibleCount); const hasMore=view==='directory'&&visibleCount<teams.length;
 useEffect(()=>{setVisibleCount(60)},[query,org,country]);
 return <>
  <PageHeader eyebrow="Global Team Directory" title="Every team. One public directory." description="Browse source-backed Buhurt teams worldwide, including logos, public rosters, BI rankings, captains and general locations. Public access is read-only."
   actions={<label className="show-search"><span>⌕</span><input aria-label="Search teams" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search team, captain, city, region or country"/></label>}/>
  <div className="public-directory-toolbar">
   <div className="show-filter-row"><select value={org} onChange={e=>setOrg(e.target.value)}><option value="all">All organizations</option>{orgs.map(x=><option key={x}>{x}</option>)}</select>
   <select value={country} onChange={e=>setCountry(e.target.value)}><option value="all">All countries</option>{countries.map(x=><option key={x}>{x}</option>)}</select></div>
   <div className="directory-view-switch"><button className={view==='directory'?'selected':''} onClick={()=>setView('directory')}>☷ Directory</button><button className={view==='map'?'selected':''} onClick={()=>setView('map')}>⌖ Map</button></div>
  </div>
  <div className="public-directory-summary"><Pill tone="green">Public · read only</Pill><strong>{teams.length}</strong><span>teams shown</span><b>{mapped.length}</b><span>verified map pins</span></div>
  {loading?<LoadingGrid count={6}/>:error?<StatePanel tone="error" title="Unable to load teams" text={error}/>:view==='map'?(mapped.length?<PublicTeamMap teams={mapped}/>:<StatePanel title="No verified map pins match these filters yet." text="Switch back to the directory or clear a filter to see more teams."/>):teams.length===0?<StatePanel title="No teams match those filters." text="Try a broader search, organization, or country."/>:<>
   <div className="show-team-grid public-global-grid">{visibleTeams.map(team=><Link to={'/teams/'+team.slug} className="show-team-card" key={team.id}>
    <div className="show-team-banner official">{team.logoPath?<img className="team-card-logo" src={team.logoPath} alt={team.name+' logo'} loading="lazy" decoding="async"/>:<span>{initials(team.name)}</span>}<Pill tone="green">{team.organizationShortName}</Pill></div>
    <div className="show-team-body"><small>{[team.location,team.adminAreaName,team.countryName].filter(x=>x&&!x.includes('pending')).join(' · ')||'Location being normalized'}</small><h2>{team.name}</h2>
    <p>{team.captain?'Captain: '+team.captain:(team.description||'Public source-backed team record.')}</p>
    <div className="team-card-stats">{team.rank5v5!=null?<span><b>#{team.rank5v5}</b><small>5v5</small></span>:null}{team.points5v5!=null?<span><b>{team.points5v5}</b><small>points</small></span>:null}</div>
    <div className="team-public-actions"><span>View roster, stats & history</span>{team.latitude!=null?<b>⌖ Mapped</b>:null}</div></div></Link>)}</div>
   {hasMore?<div className="directory-load-more"><span>Showing {visibleTeams.length} of {teams.length} teams</span><button className="show-btn secondary" type="button" onClick={()=>setVisibleCount(count=>Math.min(count+60,teams.length))}>Show 60 more</button></div>:teams.length>60?<div className="directory-load-more complete"><span>All {teams.length} matching teams are shown.</span></div>:null}
  </>}
 </>;
}