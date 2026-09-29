import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';
import {PageHeader,Pill} from '../components/ShowcaseUI';

const initials=(n:string)=>n.replace(/^The\s+/i,'').split(/\s+/).filter(Boolean).slice(0,3).map(x=>x[0]?.toUpperCase()).join('');
const project=(lat:number,lon:number)=>({x:(lon+180)/360*100,y:(90-lat)/180*100});

export function TeamsPage(){
 const [query,setQuery]=useState(''); const [org,setOrg]=useState('all'); const [country,setCountry]=useState('all');
 const [directory,setDirectory]=useState<PublicDirectoryTeam[]>([]); const [loading,setLoading]=useState(true); const [view,setView]=useState<'directory'|'map'>('directory');
 useEffect(()=>{let active=true;loadPublicTeamDirectory().then(x=>{if(active)setDirectory(x)}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const orgs=useMemo(()=>[...new Set(directory.map(x=>x.organizationShortName).filter(Boolean))].sort(),[directory]);
 const countries=useMemo(()=>[...new Set(directory.map(x=>x.countryName).filter(x=>x&&x!=='Country pending'))].sort(),[directory]);
 const teams=useMemo(()=>{const n=query.trim().toLowerCase();return directory.filter(t=>(org==='all'||t.organizationShortName===org)&&(country==='all'||t.countryName===country)&&(!n||[t.name,t.location,t.adminAreaName,t.countryName,t.organizationShortName].some(v=>v.toLowerCase().includes(n))))},[directory,query,org,country]);
 const mapped=teams.filter(t=>t.latitude!=null&&t.longitude!=null);
 return <>
  <PageHeader eyebrow="Global Team Directory" title="Every team. One public directory." description="Browse Buhurt teams worldwide, open public team profiles and rosters, or explore verified general team locations on the map. Public access is read-only."
   actions={<label className="show-search"><span>⌕</span><input aria-label="Search teams" value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search team, city, region or country"/></label>}/>
  <div className="public-directory-toolbar">
   <div className="show-filter-row"><select value={org} onChange={e=>setOrg(e.target.value)}><option value="all">All organizations</option>{orgs.map(x=><option key={x}>{x}</option>)}</select>
   <select value={country} onChange={e=>setCountry(e.target.value)}><option value="all">All countries</option>{countries.map(x=><option key={x}>{x}</option>)}</select></div>
   <div className="directory-view-switch"><button className={view==='directory'?'selected':''} onClick={()=>setView('directory')}>☷ Directory</button><button className={view==='map'?'selected':''} onClick={()=>setView('map')}>⌖ Map</button></div>
  </div>
  <div className="public-directory-summary"><Pill tone="green">Public · read only</Pill><strong>{teams.length}</strong><span>teams shown</span><b>{mapped.length}</b><span>verified map pins</span></div>
  {loading?<div className="state-card">Loading global team directory…</div>:view==='map'?<section className="team-world-map" aria-label="World team map">
    <div className="map-grid"/><div className="map-label north-america">North America</div><div className="map-label europe">Europe</div><div className="map-label apac">Asia Pacific</div>
    {mapped.map(t=>{const p=project(t.latitude!,t.longitude!);return <Link key={t.id} to={'/teams/'+t.slug} className="team-map-pin" style={{left:p.x+'%',top:p.y+'%'}} title={t.name+' · '+t.location}><span/><b>{t.name}</b></Link>})}
    {mapped.length===0?<div className="map-empty">No verified map pins match these filters yet.</div>:null}
   </section>:teams.length===0?<div className="state-card">No teams match those filters.</div>:<div className="show-team-grid public-global-grid">{teams.map(team=><Link to={'/teams/'+team.slug} className="show-team-card" key={team.id}>
    <div className="show-team-banner official"><span>{initials(team.name)}</span><Pill tone="green">{team.organizationShortName}</Pill></div>
    <div className="show-team-body"><small>{[team.location,team.adminAreaName,team.countryName].filter(x=>x&&!x.includes('pending')).join(' · ')||'Location being normalized'}</small><h2>{team.name}</h2>
    <p>{team.sourceKind==='hacsa'?'HACSA source-backed team record.':team.sourceKind==='bi_teams'?'Buhurt International team record.':'Public BuhurtOS team record.'}</p>
    <div className="team-public-actions"><span>View roster & stats</span>{team.latitude!=null?<b>⌖ Mapped</b>:null}</div></div></Link>)}</div>}
 </>;
}