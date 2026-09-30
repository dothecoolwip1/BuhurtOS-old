import {useEffect,useMemo,useState} from 'react';
import {Link,useLocation} from 'react-router-dom';
import {rememberListSearch,useQueryStates} from '../lib/urlState';
import {loadFeaturedTeams,loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {PublicTeamMap} from '../components/PublicTeamMap';

type Tab='featured'|'bi'|'hacsa'|'worldwide';
const tabs:{key:Tab;label:string}[]=[{key:'featured',label:'Featured'},{key:'bi',label:'Buhurt International'},{key:'hacsa',label:'HACSA'},{key:'worldwide',label:'All worldwide teams'}];
const initials=(n:string)=>n.replace(/^The\s+/i,'').split(/\s+/).filter(Boolean).slice(0,3).map(x=>x[0]?.toUpperCase()).join('');

export function TeamsPage(){
 const [filters,setFilters]=useQueryStates({q:'',org:'all',country:'all',region:'all',view:'directory',tab:'featured'}); const tab=(tabs.some(t=>t.key===filters.tab)?filters.tab:'featured') as Tab; const query=filters.q,org=filters.org,country=filters.country,region=filters.region,view=(filters.view==='map'?'map':'directory') as 'directory'|'map'; const setQuery=(v:string)=>setFilters({q:v}),setOrg=(v:string)=>setFilters({org:v}),setRegion=(v:string)=>setFilters({region:v}),setView=(v:'directory'|'map')=>setFilters({view:v}),setTab=(v:Tab)=>setFilters({tab:v,org:'all',country:'all',region:'all'}); const location=useLocation(); useEffect(()=>rememberListSearch('/teams',location.search),[location.search]);
 const [directory,setDirectory]=useState<PublicDirectoryTeam[]>([]); const [loading,setLoading]=useState(true); const [error,setError]=useState(''); const [attempt,setAttempt]=useState(0); const [visibleCount,setVisibleCount]=useState(60);
 // Featured loads a small list. The large directory loads only for the BI, HACSA and Worldwide tabs, or when someone searches.
 const searching=query.trim().length>0; const scope:'featured'|'bi'|'hacsa'|'all'=searching?'all':tab==='featured'?'featured':tab==='bi'?'bi':tab==='hacsa'?'hacsa':'all';
 useEffect(()=>{let active=true;setLoading(true);setError('');const load=scope==='featured'?loadFeaturedTeams():loadPublicTeamDirectory(scope==='all'?{}:{organizationShortName:scope==='bi'?'BI':'HACSA'});load.then(x=>{if(active)setDirectory(x)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load the team directory.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[attempt,scope]);
 const orgs=useMemo(()=>[...new Set(directory.map(x=>x.organizationShortName).filter(Boolean))].sort(),[directory]);
 const countries=useMemo(()=>[...new Set(directory.map(x=>x.countryName).filter(x=>x&&x!=='Country pending'))].sort(),[directory]);
 const regions=useMemo(()=>[...new Set(directory.filter(t=>country==='all'||t.countryName===country).map(t=>t.adminAreaName).filter(x=>x&&!x.includes('pending')))].sort(),[directory,country]);
 const teams=useMemo(()=>{const n=query.trim().toLowerCase();return directory.filter(t=>(org==='all'||t.organizationShortName===org)&&(country==='all'||t.countryName===country)&&(region==='all'||t.adminAreaName===region)&&(!n||[t.name,t.location,t.adminAreaName,t.countryName,t.organizationShortName,t.captain??''].some(v=>v.toLowerCase().includes(n))))},[directory,query,org,country,region]);
 const mapped=teams.filter(t=>t.latitude!=null&&t.longitude!=null); const visibleTeams=teams.slice(0,visibleCount); const hasMore=view==='directory'&&visibleCount<teams.length;
 useEffect(()=>{setVisibleCount(60)},[query,org,country,region]);
 return <>
  <PageHeader eyebrow="Team Directory" title="Find a team" description="Teams listed from public sources and from BuhurtOS. Search by team, captain, city, region or country. This directory is read-only and may not include every team."
   actions={<label className="show-search"><span>⌕</span><input aria-label="Search teams" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search team, captain, city, region or country"/></label>}/>
  <div className="directory-view-switch teams-tabs" role="tablist" aria-label="Team groups">{tabs.map(t=><button key={t.key} type="button" role="tab" aria-selected={!searching&&tab===t.key} className={!searching&&tab===t.key?'selected':''} onClick={()=>setTab(t.key)}>{t.label}</button>)}</div>
  {searching?<p className="hint" role="status">Searching all worldwide teams. <button type="button" className="show-btn secondary" onClick={()=>setQuery('')}>Clear search</button></p>:tab==='featured'?<p className="hint">Featured teams are a display choice for this release, not an endorsement. Every other team is available under “All worldwide teams” or by search.</p>:null}
  <div className="public-directory-toolbar">
   <div className="show-filter-row">{scope==='all'?<select aria-label='Filter by organization' value={org} onChange={e=>setOrg(e.target.value)}><option value="all">All organizations</option>{orgs.map(x=><option key={x}>{x}</option>)}</select>:null}
   <select aria-label='Filter by country' value={country} onChange={e=>setFilters({country:e.target.value,region:'all'})}><option value="all">All countries</option>{countries.map(x=><option key={x}>{x}</option>)}</select>
   {regions.length>1?<select aria-label='Filter by region' value={region} onChange={e=>setRegion(e.target.value)}><option value='all'>All regions</option>{regions.map(x=><option key={x}>{x}</option>)}</select>:null}</div>
   <div className="directory-view-switch" role="group" aria-label="Directory view"><button type="button" className={view==='directory'?'selected':''} aria-pressed={view==='directory'} onClick={()=>setView('directory')}>☷ Directory</button><button type="button" className={view==='map'?'selected':''} aria-pressed={view==='map'} onClick={()=>setView('map')}>⌖ Map</button></div>
  </div>
  <div className="public-directory-summary"><Pill tone="green">Public · read only</Pill><strong>{teams.length}</strong><span>teams shown</span><b>{mapped.length}</b><span>with a map location</span>{(query||org!=='all'||country!=='all'||region!=='all')?<button type="button" className="show-btn secondary" onClick={()=>setFilters({q:'',org:'all',country:'all',region:'all'})}>Reset filters</button>:null}</div>
  {loading?<LoadingGrid count={6}/>:error?<StatePanel tone="error" title="Unable to load teams" text={error+' This does not mean there are no teams.'} action={<button type="button" className="show-btn" onClick={()=>{setError('');setLoading(true);setAttempt(n=>n+1)}}>Try again</button>}/>:view==='map'?(mapped.length?<PublicTeamMap teams={mapped}/>:<StatePanel title="No verified map pins match these filters yet." text="Switch back to the directory or clear a filter to see more teams."/>):teams.length===0?<StatePanel title="No teams match those filters." text="Try a broader search, organization, or country."/>:<>
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