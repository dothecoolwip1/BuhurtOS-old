import {useEffect,useState} from 'react';
import {Link} from 'react-router-dom';
import {PageHeader,Pill} from '../components/ShowcaseUI';
import {loadPublicOrganizations,type PublicOrganizationSummary} from '../lib/publicDirectory';

export function GovernancePage(){
 const [organizations,setOrganizations]=useState<PublicOrganizationSummary[]>([]);
 const [loading,setLoading]=useState(true);
 useEffect(()=>{let active=true;loadPublicOrganizations().then(rows=>{if(active)setOrganizations(rows)}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 return <>
  <PageHeader eyebrow="PUBLIC ORGANIZATION DIRECTORY" title="Organizations" description="Explore federations, national bodies, regional organizations and local groups represented in BuhurtOS. Open any organization to see what it is and what sits underneath it."/>
  {loading?<div className="state-card">Loading organizations…</div>:<div className="show-team-grid public-global-grid">{organizations.map(org=><Link className="show-team-card" key={org.key} to={'/organizations/'+org.key}><div className="show-team-banner official"><span>{org.shortName.slice(0,4)}</span><Pill tone="blue">{org.kind}</Pill></div><div className="show-team-body"><small>{org.region}</small><h2>{org.name}</h2><p>{org.description}</p><div className="team-card-stats"><span><b>{org.teamCount}</b><small>teams</small></span><span><b>{org.rosterCount}</b><small>roster records</small></span><span><b>{org.countries}</b><small>countries</small></span></div><div className="team-public-actions"><span>Open organization</span><b>→</b></div></div></Link>)}</div>}
  <div className="show-explain-card"><span>?</span><div><b>How does the hierarchy work?</b><p>BuhurtOS itself sits above the sporting organizations it records. An international federation can connect to national or regional organizations, which can connect to clubs and teams. The public pages describe those relationships without implying endorsement or ownership.</p></div><Link to="/rules">Learn about rulesets</Link></div>
 </>;
}