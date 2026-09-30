import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';
import {availableRankingFormats,buildRankingRows,rankingFormatLabels,rankingSources,resolveRankingFilters} from '../lib/rankings';
import {useQueryStates} from '../lib/urlState';

export function ShowcaseRankingsPage(){
 const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 const [attempt,setAttempt]=useState(0);
 const [wanted,setWanted]=useQueryStates({format:'',source:'',country:'all'});
 useEffect(()=>{let active=true;loadPublicTeamDirectory().then(rows=>{if(active)setTeams(rows)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load rankings.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[attempt]);
 const formats=useMemo(()=>availableRankingFormats(teams),[teams]);
 // Filters live in the URL so a ranking view can be shared and survives reload; unknown values fall back to what the data offers.
 const {format,source:org}=useMemo(()=>resolveRankingFilters(teams,wanted),[teams,wanted]);
 const country=wanted.country;
 const sources=useMemo(()=>rankingSources(teams,format),[teams,format]);
 const rows=useMemo(()=>buildRankingRows(teams,format,{organization:org,country}),[teams,format,org,country]);
 const countries=useMemo(()=>[...new Set(teams.filter(t=>(format==='5v5'?t.rank5v5:t.rank12v12)!=null&&(org==='all'||t.organizationShortName===org)).map(t=>t.countryName).filter(x=>x&&!x.includes('pending')))].sort(),[teams,format,org]);
 const verified=rows.map(r=>r.team.verifiedAt).filter(Boolean).sort().pop();
 return <>
  <PageHeader eyebrow="PUBLIC RANKINGS" title="Team rankings" description="Source-backed team rankings currently available in the public directory. BuhurtOS does not invent missing positions or points."/>
  <div className="show-explain-card"><span>?</span><div><b>What does a ranking mean?</b><p>A ranking is a competitive position within a category such as 5v5 or 12v12. Points and ranking systems depend on the governing organization and ruleset. Every row names the source that published it; open a team to see the full record.</p></div><Link to="/rules">Learn about categories</Link></div>
  {loading?<LoadingGrid count={5}/>:error?<StatePanel tone="error" title="Unable to load rankings" text={error+' This does not mean there are no rankings.'} action={<button type="button" className="show-btn" onClick={()=>{setError('');setLoading(true);setAttempt(n=>n+1)}}>Try again</button>}/>:formats.length===0?<StatePanel title="No public rankings are available yet." text="BuhurtOS only displays source-backed ranking positions and points."/>:<>
   <div className="public-directory-toolbar">
    <div className="directory-view-switch" role="group" aria-label="Ranking category">{formats.map(f=><button key={f} type="button" className={format===f?'selected':''} aria-pressed={format===f} onClick={()=>setWanted({format:f,country:'all'})}>{rankingFormatLabels[f]}</button>)}</div>
    <div className="show-filter-row">
     <select aria-label="Ranking source" value={org} onChange={e=>setWanted({source:e.target.value,country:'all'})}>{sources.map(x=><option key={x.source} value={x.source}>{x.source} ({x.count})</option>)}{sources.length>1?<option value="all">All sources (positions are not comparable)</option>:null}</select>
     <select aria-label="Filter by country" value={country} onChange={e=>setWanted({country:e.target.value})}><option value="all">All countries</option>{countries.map(x=><option key={x}>{x}</option>)}</select>
    {country!=='all'?<button type="button" className="show-btn secondary" onClick={()=>setWanted({country:'all'})}>Clear country</button>:null}</div>
   </div>
   {org==='all'&&sources.length>1?<p className="show-note" role="note">These positions come from different sources and are not one combined ranking. Choose a single source to read a real ordering.</p>:null}
   <div className="public-directory-summary"><Pill tone="green">Source-backed</Pill><strong>{rows.length}</strong><span>ranked teams in {rankingFormatLabels[format]}</span>{verified?<><b>{verified}</b><span>latest source check</span></>:null}</div>
   {rows.length===0?<StatePanel title="No ranked teams match those filters." text="Clear a filter to see more of the published ranking."/>:<div className="show-table-wrap public-ranking-table"><table className="show-table"><thead><tr><th>Rank</th><th>Team</th><th>Source</th><th>Country</th><th>{rankingFormatLabels[format]} points</th><th>Provenance</th><th></th></tr></thead><tbody>{rows.map(({team,rank,points})=><tr key={team.id}><td><strong>#{rank}</strong></td><td><Link to={'/teams/'+team.slug}><strong>{team.name}</strong></Link></td><td><Pill>{team.organizationShortName}</Pill></td><td>{team.countryName&&!team.countryName.includes('pending')?team.countryName:'—'}</td><td>{points??'—'}</td><td>{team.sourceUrl?<a href={team.sourceUrl} target="_blank" rel="noopener noreferrer">{team.sourceKind==='bi_ranking'?'BI Official Ranking':'Source'} ↗</a>:'—'}{team.verifiedAt?<small> · {team.verifiedAt}</small>:null}</td><td><Link className="show-link-btn" to={'/teams/'+team.slug}>View →</Link></td></tr>)}</tbody></table></div>}
  </>}
 </>;
}
