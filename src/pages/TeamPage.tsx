import {useEffect,useState} from 'react';import {Link,useParams} from 'react-router-dom';
import {loadPublicTeamDetail,loadPublicTeamDirectory,loadPublicTeamRoster,type PublicDirectoryTeam,type PublicRosterMember,type PublicTeamDetail} from '../lib/teamDirectory';
import {Panel,Pill} from '../components/ShowcaseUI';
import {loadOfficialTeamStats,loadTeamProvenance,provenanceToCard,type PublicTeamStats} from '../lib/publicStats';
import {summarizeRecord} from '../lib/canonicalStats';
const initials=(n:string)=>n.replace(/^The\s+/i,'').split(/\s+/).filter(Boolean).slice(0,3).map(x=>x[0]?.toUpperCase()).join('');
const val=(v:number|undefined)=>v==null?'—':String(v);
export function TeamPage(){
 const {teamId=''}=useParams();const [team,setTeam]=useState<PublicDirectoryTeam>();const [detail,setDetail]=useState<PublicTeamDetail>();const [roster,setRoster]=useState<PublicRosterMember[]>([]);const [loading,setLoading]=useState(true);const [error,setError]=useState('');const [stats,setStats]=useState<PublicTeamStats>();const [provenance,setProvenance]=useState<ReturnType<typeof provenanceToCard>>();
 useEffect(()=>{let active=true;(async()=>{try{const rows=await loadPublicTeamDirectory({teamSlug:teamId});if(!active)return;setTeam(rows[0]);if(rows[0]){const [r,d]=await Promise.all([loadPublicTeamRoster(rows[0].id),loadPublicTeamDetail(rows[0].id)]);if(active){setRoster(r);setDetail(d)}loadOfficialTeamStats(rows[0].id).then(x=>{if(active)setStats(x)});loadTeamProvenance(rows[0].id).then(x=>{if(active)setProvenance(provenanceToCard(x))})}}catch(err){if(active)setError(err instanceof Error?err.message:'Unable to load this team.')}finally{if(active)setLoading(false)}})();return()=>{active=false}},[teamId]);
 if(loading)return <div className="state-card">Loading public team profile…</div>;
 if(error)return <div className="state-card"><strong>Unable to load team</strong><p>{error}</p><Link className="show-btn secondary" to="/teams">Back to teams</Link></div>;
 if(!team)return <div className="state-card"><h2>Team not found</h2><Link className="show-btn secondary" to="/teams">Back to teams</Link></div>;
 const recent=[...(detail?.tournamentsJoined??[])].sort((a,b)=>String(b.date??'').localeCompare(String(a.date??''))).slice(0,8);
 return <>
 <div className="show-profile-hero team official-team-hero">
   {detail?.logoPath||team.logoPath?<img className="show-team-logo-image" src={detail?.logoPath??team.logoPath} alt={team.name+' logo'}/>:<div className="show-team-logo-xl">{initials(team.name)}</div>}
   <div className="grow"><span className="eyebrow">PUBLIC TEAM PROFILE</span><h1>{team.name}</h1>
   <p>{[team.location,team.adminAreaName,team.countryName].filter(x=>x&&!x.includes('pending')).join(' · ')||'Location being normalized'}</p>
   <div className="show-inline-pills"><Pill tone="green">Read only</Pill><Pill>{team.organizationShortName}</Pill>{detail?.conference?<Pill>{detail.conference}</Pill>:null}{team.verifiedAt?<Pill>Verified {team.verifiedAt}</Pill>:null}</div></div>
   {team.sourceUrl?<a className="show-btn secondary" href={team.sourceUrl} target="_blank" rel="noopener noreferrer">View source ↗</a>:null}
 </div>
 <div className="directory-hierarchy compact"><strong>{team.organizationShortName}</strong>{team.continentName&&!team.continentName.includes('pending')?<><span>›</span><b>{team.continentName}</b></>:null}{team.countryName&&!team.countryName.includes('pending')?<><span>›</span><b>{team.countryName}</b></>:null}{team.adminAreaName&&!team.adminAreaName.includes('pending')?<><span>›</span><b>{team.adminAreaName}</b></>:null}</div>
 <div className="show-stat-grid">
   <div className="show-stat accent"><span>Public roster</span><strong>{roster.length}</strong><small>BI + BuhurtOS public fighters</small></div>
   <div className="show-stat"><span>5v5 rank</span><strong>{val(detail?.rank5v5??team.rank5v5)}</strong><small>{detail?.averagePoints5v5!=null?String(detail.averagePoints5v5)+' average points':'BI ranking'}</small></div>
   <div className="show-stat"><span>5v5 points</span><strong>{val(detail?.points5v5??team.points5v5)}</strong><small>current BI points</small></div>
   <div className="show-stat good"><span>Captain</span><strong className="stat-text">{detail?.captain??team.captain??'—'}</strong><small>BI team record</small></div>
 </div>
 <div className="show-two-col wide-left"><div className="show-stack">
   <Panel title="About the team" subtitle="Public team information from the current BI team record.">
    {detail?.description||team.description?<p className="team-about-copy">{detail?.description??team.description}</p>:<div className="source-empty-state"><strong>No public description supplied</strong><p>BI has not published a team description for this record.</p></div>}
    <div className="show-detail-rows">
      {detail?.club?<div><span>Club</span><b>{detail.club}</b></div>:null}
      {detail?.gender?<div><span>Competition group</span><b>{detail.gender}</b></div>:null}
      {detail?.captain?<div><span>Captain</span><b>{detail.captain}</b></div>:null}
      {detail?.trainingInfo?<div className="detail-row-wide"><span>Training info</span><b>{detail.trainingInfo}</b></div>:null}
    </div>
   </Panel>
   <Panel title="Public roster" subtitle="BI-listed members and public BuhurtOS fighter identities. BI roster records do not create fake user accounts.">
    {roster.length?<div className="show-roster-table">{roster.map((f,i)=><article key={f.identityId??(f.displayName+'-'+i)}><span className="show-avatar md">{initials(f.displayName)}</span><div className="grow"><b>{f.displayName}</b><small>{[f.nickname,f.role,f.publicRegion].filter(Boolean).join(' · ')||'Fighter'}{f.sourceKind==='bi_teams'?' · BI source':''}</small></div>{f.identityId?<Link className="show-link-btn" to={'/fighters/'+f.identityId}>Profile →</Link>:<span className="show-pill">BI roster</span>}</article>)}</div>:<div className="source-empty-state"><strong>No public roster entries</strong><p>This BI record currently does not publish member names.</p></div>}
   </Panel>
   {stats&&stats.matches>0?<Panel title="Native BuhurtOS record" subtitle="Official results only: finalized matches from published events."><div className="show-detail-rows"><div><span>Record (W-L-D)</span><b>{summarizeRecord(stats)}</b></div><div><span>Matches</span><b>{stats.matches}</b></div><div><span>Points for / against</span><b>{stats.pointsFor} / {stats.pointsAgainst}</b></div><div><span>Events</span><b>{stats.events}</b></div></div></Panel>:null}
   <Panel title="Recent BI tournament record">
    {recent.length?<div className="team-tournament-list">{recent.map((e:any,i)=><article key={String(e.Tournament??'event')+'-'+String(e.date??i)}><div><b>{e.Tournament??'Tournament'}</b><small>{[e.date,e.category].filter(Boolean).join(' · ')}</small></div><div><strong>{e.place?'#'+e.place:'—'}</strong><small>{e.points!=null?String(e.points)+' pts':''}</small></div></article>)}</div>:<div className="source-empty-state"><strong>No current tournament entries</strong><p>BI has not attached current tournament history to this team record.</p></div>}
   </Panel>
 </div>
 <div className="show-stack">
   <Panel title="Team information"><div className="show-detail-rows">
    <div><span>Team</span><b>{team.name}</b></div><div><span>Organization</span><b>{team.organizationShortName}</b></div>
    <div><span>Published location</span><b>{team.location}</b></div>{team.countryName&&!team.countryName.includes('pending')?<div><span>Country</span><b>{team.countryName}</b></div>:null}
    {detail?.rank12v12!=null?<div><span>12v12 rank</span><b>{detail.rank12v12}</b></div>:null}{detail?.points12v12!=null?<div><span>12v12 points</span><b>{detail.points12v12}</b></div>:null}
    {team.email?<div><span>Public email</span><a href={'mailto:'+team.email}>{team.email}</a></div>:null}
   </div>{team.websiteUrl?<a className="show-btn secondary full" href={team.websiteUrl} target="_blank" rel="noopener noreferrer">Team website / social ↗</a>:null}</Panel>
   {provenance&&provenance.sources.length?<Panel title="Sources & provenance" subtitle="Every source keeps its own facts. Disagreements are shown, not overwritten."><div className="show-detail-rows">{provenance.sources.map(src=><div key={src.externalId??src.sourceKind}><span>{src.sourceKind==='hacsa'?'HACSA':src.sourceKind==='bi_teams'?'BI Teams':src.sourceKind==='bi_ranking'?'BI Ranking':'BuhurtOS'}</span><b>{src.sourceUrl?<a href={src.sourceUrl} target="_blank" rel="noopener noreferrer">Source ↗</a>:'—'}{src.verifiedAt?<small> · verified {String(src.verifiedAt).slice(0,10)}</small>:null}</b></div>)}</div>{provenance.conflicts.length?<div className="source-empty-state"><strong>Sources disagree</strong>{provenance.conflicts.map(c=><p key={c.field}>{c.field}: {c.values.map(v=>v.value+' ('+v.sourceKind+')').join(' · ')}</p>)}</div>:null}</Panel>:null}
   {team.latitude!=null?<Panel title="Map location"><div className="mini-map-pin"><span>⌖</span><b>{team.location}</b><small>Approximate public location only</small></div></Panel>:null}
 </div></div></>;
}