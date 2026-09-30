import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {loadPublicTeamDirectory,type PublicDirectoryTeam} from '../lib/teamDirectory';

export function ShowcaseRankingsPage(){
 const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 useEffect(()=>{let active=true;loadPublicTeamDirectory().then(rows=>{if(active)setTeams(rows)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load rankings.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const ranked=useMemo(()=>teams.filter(t=>t.rank5v5!=null).sort((a,b)=>(a.rank5v5??9999)-(b.rank5v5??9999)||((b.points5v5??0)-(a.points5v5??0))),[teams]);
 return <>
  <PageHeader eyebrow="PUBLIC RANKINGS" title="Team rankings" description="Source-backed team rankings currently available in the public directory. BuhurtOS does not invent missing positions or points."/>
  <div className="show-explain-card"><span>?</span><div><b>What does a ranking mean?</b><p>A ranking is a competitive position within a category such as 5v5. Points and ranking systems depend on the governing organization and ruleset. Open a team to see the source-backed values BuhurtOS has for it.</p></div><Link to="/rules">Learn about categories</Link></div>
  {loading?<LoadingGrid count={5}/>:error?<StatePanel tone="error" title="Unable to load rankings" text={error}/>:ranked.length===0?<StatePanel title="No public rankings are available yet." text="BuhurtOS only displays source-backed ranking positions and points."/>:<div className="show-table-wrap public-ranking-table"><table className="show-table"><thead><tr><th>Rank</th><th>Team</th><th>Organization</th><th>Country</th><th>5v5 points</th><th></th></tr></thead><tbody>{ranked.map((team,i)=><tr key={team.id}><td><strong>#{team.rank5v5}</strong></td><td><strong>{team.name}</strong></td><td><Pill>{team.organizationShortName}</Pill></td><td>{team.countryName}</td><td>{team.points5v5??'—'}</td><td><Link className="show-link-btn" to={'/teams/'+team.slug}>View →</Link></td></tr>)}</tbody></table></div>}
 </>;
}