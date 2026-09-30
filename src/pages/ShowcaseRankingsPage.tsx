import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';
import {availableRankingFormats,buildRankingRows,rankingFormatLabels,type RankingFormat} from '../lib/rankings';

export function ShowcaseRankingsPage(){
 const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 const [format,setFormat]=useState<RankingFormat>('5v5');
 const [org,setOrg]=useState('all');
 const [country,setCountry]=useState('all');
 useEffect(()=>{let active=true;loadPublicTeamDirectory().then(rows=>{if(active)setTeams(rows)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load rankings.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const formats=useMemo(()=>availableRankingFormats(teams),[teams]);
 useEffect(()=>{if(formats.length&&!formats.includes(format))setFormat(formats[0])},[formats,format]);
 const rows=useMemo(()=>buildRankingRows(teams,format,{organization:org,country}),[teams,format,org,country]);
 const orgs=useMemo(()=>[...new Set(teams.filter(t=>(format==='5v5'?t.rank5v5:t.rank12v12)!=null).map(t=>t.organizationShortName))].sort(),[teams,format]);
 const countries=useMemo(()=>[...new Set(teams.filter(t=>(format==='5v5'?t.rank5v5:t.rank12v12)!=null).map(t=>t.countryName).filter(x=>x&&!x.includes('pending')))].sort(),[teams,format]);
 const verified=rows.map(r=>r.team.verifiedAt).filter(Boolean).sort().pop();
 return <>
  <PageHeader eyebrow="PUBLIC RANKINGS" title="Team rankings" description="Source-backed team rankings currently available in the public directory. BuhurtOS does not invent missing positions or points."/>
  <div className="show-explain-card"><span>?</span><div><b>What does a ranking mean?</b><p>A ranking is a competitive position within a category such as 5v5 or 12v12. Points and ranking systems depend on the governing organization and ruleset. Every row names the source that published it; open a team to see the full record.</p></div><Link to="/rules">Learn about categories</Link></div>
  {loading?<LoadingGrid count={5}/>:error?<StatePanel tone="error" title="Unable to load rankings" text={error}/>:formats.length===0?<StatePanel title="No public rankings are available yet." text="BuhurtOS only displays source-backed ranking positions and points."/>:<>
   <div className="public-directory-toolbar">
    <div className="directory-view-switch" role="group" aria-label="Ranking category">{formats.map(f=><button key={f} type="button" className={format===f?'selected':''} aria-pressed={format===f} onClick={()=>setFormat(f)}>{rankingFormatLabels[f]}</button>)}</div>
    <div className="show-filter-row">
     <select aria-label="Filter by organization" value={org} onChange={e=>setOrg(e.target.value)}><option value="all">All sources</option>{orgs.map(x=><option key={x}>{x}</option>)}</select>
     <select aria-label="Filter by country" value={country} onChange={e=>setCountry(e.target.value)}><option value="all">All countries</option>{countries.map(x=><option key={x}>{x}</option>)}</select>
    </div>
   </div>
   <div className="public-directory-summary"><Pill tone="green">Source-backed</Pill><strong>{rows.length}</strong><span>ranked teams in {rankingFormatLabels[format]}</span>{verified?<><b>{verified}</b><span>latest source check</span></>:null}</div>
   {rows.length===0?<StatePanel title="No ranked teams match those filters." text="Clear a filter to see more of the published ranking."/>:<div className="show-table-wrap public-ranking-table"><table className="show-table"><thead><tr><th>Rank</th><th>Team</th><th>Source</th><th>Country</th><th>{rankingFormatLabels[format]} points</th><th>Provenance</th><th></th></tr></thead><tbody>{rows.map(({team,rank,points})=><tr key={team.id}><td><strong>#{rank}</strong></td><td><Link to={'/teams/'+team.slug}><strong>{team.name}</strong></Link></td><td><Pill>{team.organizationShortName}</Pill></td><td>{team.countryName&&!team.countryName.includes('pending')?team.countryName:'—'}</td><td>{points??'—'}</td><td>{team.sourceUrl?<a href={team.sourceUrl} target="_blank" rel="noopener noreferrer">{team.sourceKind==='bi_ranking'?'BI Official Ranking':'Source'} ↗</a>:'—'}{team.verifiedAt?<small> · {team.verifiedAt}</small>:null}</td><td><Link className="show-link-btn" to={'/teams/'+team.slug}>View →</Link></td></tr>)}</tbody></table></div>}
  </>}
 </>;
}
