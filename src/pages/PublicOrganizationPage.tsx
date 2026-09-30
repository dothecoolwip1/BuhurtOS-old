import {eventPath} from '../lib/publicDirectory';
import {useEffect,useState} from 'react';
import {Link,useParams} from 'react-router-dom';
import {PageHeader,Pill,Panel} from '../components/ShowcaseUI';
import {ListCrumbs} from '../components/chrome';
import {loadPublicOrganization,loadPublicOrganizationEvents,loadPublicOrganizationLinks,relationshipLabel,type PublicEventSummary,type PublicOrganizationLink,type PublicOrganizationSummary} from '../lib/publicDirectory';
import type {PublicDirectoryTeam} from '../lib/teamDirectory';

const initials=(n:string)=>n.replace(/^The\s+/i,'').split(/\s+/).filter(Boolean).slice(0,3).map(x=>x[0]?.toUpperCase()).join('');

export function PublicOrganizationPage(){
  const {organizationKey=''}=useParams();
  const [organization,setOrganization]=useState<PublicOrganizationSummary>();
  const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
  const [links,setLinks]=useState<PublicOrganizationLink[]>([]);
  const [events,setEvents]=useState<PublicEventSummary[]>([]);
  const [loading,setLoading]=useState(true);
  const [error,setError]=useState('');
  const [visibleCount,setVisibleCount]=useState(24);

  useEffect(()=>{let active=true;loadPublicOrganization(organizationKey).then(result=>{if(active&&result){setOrganization(result.organization);setTeams(result.teams);Promise.all([loadPublicOrganizationLinks(result.organization.id??''),loadPublicOrganizationEvents(result.organization.id)]).then(([l,e])=>{if(active){setLinks(l);setEvents(e)}}).catch(()=>{})}}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load this organization.')} ).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[organizationKey]);
  useEffect(()=>{setVisibleCount(24)},[organizationKey]);

  if(loading)return <div className="state-card">Loading organization profile…</div>;
  if(error)return <div className="state-card"><strong>Unable to load organization</strong><p>{error}</p><Link className="show-btn secondary" to="/governance">Back to organizations</Link></div>;
  if(!organization)return <div className="state-card"><h2>Organization not found</h2><Link className="show-btn secondary" to="/public">Back to public view</Link></div>;

  return <>
    <ListCrumbs list="/governance" label="Organizations" current={organization.shortName}/>
    <PageHeader eyebrow={organization.kind} title={organization.name} description={organization.description} actions={<>{organization.websiteUrl?<a className="show-btn secondary" href={organization.websiteUrl} target="_blank" rel="noopener noreferrer">Official website ↗</a>:null}<Link className="show-btn primary" to="/teams">Browse teams</Link></>}/>
    <div className="show-stat-grid">
      <div className="show-stat accent"><span>Teams</span><strong>{organization.teamCount}</strong><small>Public directory</small></div>
      <div className="show-stat good"><span>Roster records</span><strong>{organization.rosterCount}</strong><small>Publicly listed people</small></div>
      <div className="show-stat"><span>Countries</span><strong>{organization.countries}</strong><small>Represented by current team records</small></div>
      <div className="show-stat"><span>Region</span><strong className="stat-text">{organization.region}</strong><small>{organization.shortName}</small></div>
    </div>
    <div className="show-two-col wide-left">
      <Panel title="What is this organization?" subtitle="Plain-language public context">
        <p className="show-long-copy">{organization.description}</p>
        <div className="show-explain-card"><span>?</span><div><b>What does an organization do in BuhurtOS?</b><p>Organizations sit above teams and can represent international federations, national bodies, regional groups or local associations. Their public page connects teams, events, rules and results without implying ownership of BuhurtOS itself.</p></div><Link to="/governance">Explore the hierarchy</Link></div>
      </Panel>
      <Panel title="Public structure">
        <div className="show-detail-rows">
          <div><span>Name</span><b>{organization.name}</b></div>
          <div><span>Short name</span><b>{organization.shortName}</b></div>
          <div><span>Type</span><b>{organization.kind}</b></div>
          <div><span>Region</span><b>{organization.region}</b></div>
        </div>
      </Panel>
    </div>
    {events.length?<section className="show-public-section"><div className="show-public-section-head"><div><span className="eyebrow">EVENTS</span><h2>Published {organization.shortName} events</h2></div><Link to="/events">All events →</Link></div><div className="team-tournament-list">{events.map(ev=><Link key={ev.id} to={eventPath(ev)}><b>{ev.name}</b><small>{[ev.startsAt?.slice(0,10),ev.venue].filter(Boolean).join(' · ')}</small></Link>)}</div></section>:null}
    <section className="show-public-section">
      <div className="show-public-section-head"><div><span className="eyebrow">TEAMS</span><h2>Teams connected to {organization.shortName}</h2></div><Link to="/teams">Full team directory →</Link></div>
      {teams.length?<div className="show-team-grid public-global-grid">{teams.slice(0,visibleCount).map(team=><Link to={'/teams/'+team.slug} className="show-team-card" key={team.id}><div className="show-team-banner official">{team.logoPath?<img className="team-card-logo" src={team.logoPath} alt={team.name+' logo'} loading="lazy" decoding="async"/>:<span>{initials(team.name)}</span>}<Pill tone="green">{team.countryName}</Pill></div><div className="show-team-body"><small>{team.location}</small><h2>{team.name}</h2><p>{team.description||'Open the team profile for roster, ranking and source-backed information.'}</p><div className="team-card-stats">{team.rank5v5!=null?<span><b>#{team.rank5v5}</b><small>5v5 rank</small></span>:null}{team.points5v5!=null?<span><b>{team.points5v5}</b><small>5v5 points</small></span>:null}</div><div className="team-public-actions"><span>Open team</span><b>→</b></div></div></Link>)}</div>:<div className="state-card">No public team records are connected to this organization yet.</div>}
      {teams.length>visibleCount?<div className="directory-load-more"><span>Showing {visibleCount} of {teams.length} teams</span><button className="show-btn secondary" type="button" onClick={()=>setVisibleCount(c=>Math.min(c+48,teams.length))}>Show 48 more</button></div>:null}
    </section>
  </>;
}