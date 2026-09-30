import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {PublicTeamMap} from '../components/PublicTeamMap';
import {PageHeader,Pill} from '../components/ShowcaseUI';
import {loadPublicOrganizations,loadPublicEvents,type PublicOrganizationSummary,type PublicEventSummary} from '../lib/publicDirectory';
import {loadPublicTeamMap,type PublicDirectoryTeam} from '../lib/teamDirectory';

const categoryHelp=[
  ['Organizations','Federations, national bodies, regional organizations and local groups that organize or govern parts of the sport.','/governance'],
  ['Teams','Competitive clubs and fight teams. Open a team to see its location, roster, rankings and source-backed history.','/teams'],
  ['Fighters','Public athlete identities. Profiles can include team, region, categories, biography and verified competition history.','/fighters'],
  ['Events','Published tournaments, demonstrations, clinics and competitions. Open an event for schedule, divisions, brackets and results.','/events'],
  ['Rankings','Current competitive standings and points when a source or finalized BuhurtOS result supports them.','/rankings'],
  ['Rules & categories','Learn the difference between 5v5, 12v12, longsword, sword & buckler and other competition formats.','/rules']
] as const;

export function ShowcasePublicPage(){
 const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
 const [orgs,setOrgs]=useState<PublicOrganizationSummary[]>([]);
 const [events,setEvents]=useState<PublicEventSummary[]>([]);
 const [loading,setLoading]=useState(true);
 const [teamsLoading,setTeamsLoading]=useState(true);
 useEffect(()=>{
   let active=true;
   Promise.all([loadPublicOrganizations(),loadPublicEvents()])
     .then(([o,e])=>{if(active){setOrgs(o);setEvents(e)}})
     .finally(()=>{if(active)setLoading(false)});
   loadPublicTeamMap()
     .then(t=>{if(active)setTeams(t)})
     .finally(()=>{if(active)setTeamsLoading(false)});
   return()=>{active=false};
 },[]);
 const mapped=useMemo(()=>teams.filter(t=>t.latitude!=null&&t.longitude!=null),[teams]);
 const upcoming=useMemo(()=>events.filter(e=>new Date(e.endsAt).getTime()>=Date.now()).slice(0,6),[events]);
 const rosterSourceCount=useMemo(()=>orgs.reduce((sum,o)=>sum+o.rosterCount,0),[orgs]);
 return <div className="public-hub">
  <PageHeader eyebrow="PUBLIC BUHURT DIRECTORY" title="Explore the sport." description="Teams, organizations, fighters, events, rankings and rules in one public, read-only place. Open anything to keep drilling down." actions={<><Link className="show-btn primary" to="/teams">Explore teams</Link><Link className="show-btn secondary" to="/events">Upcoming events</Link></>}/>
  <div className="show-stat-grid">
    <div className="show-stat accent"><span>Teams</span><strong>{teamsLoading?'…':teams.length}</strong><small>Public source-backed records</small></div>
    <div className="show-stat good"><span>Organizations</span><strong>{loading?'…':orgs.length}</strong><small>Federations to local groups</small></div>
    <div className="show-stat"><span>Roster records</span><strong>{loading?'…':rosterSourceCount}</strong><small>Publicly listed members</small></div>
    <div className="show-stat"><span>Upcoming events</span><strong>{loading?'…':upcoming.length}</strong><small>Published in BuhurtOS</small></div>
  </div>

  <section className="panel-card public-map-panel">
    <div className="show-public-section-head"><div><span className="eyebrow">GLOBAL MAP</span><h2>Find teams around the world</h2><p>Pins use approximate public team locations only.</p></div><Link to="/teams">Open full directory →</Link></div>
    {teamsLoading?<div className="state-card">Loading team locations…</div>:mapped.length?<PublicTeamMap teams={mapped}/>:<div className="state-card">Team locations are still being normalized.</div>}
  </section>

  <section className="show-public-section">
    <div className="show-public-section-head"><div><span className="eyebrow">WHO ORGANIZES THE SPORT?</span><h2>Organizations</h2><p>Open an organization to see what it is, the teams beneath it and its public footprint.</p></div><Link to="/governance">See hierarchy →</Link></div>
    <div className="show-team-grid public-global-grid">{orgs.slice(0,8).map(org=><Link className="show-team-card" key={org.key} to={'/organizations/'+org.key}><div className="show-team-banner official"><span>{org.shortName.slice(0,4)}</span><Pill tone="blue">{org.kind}</Pill></div><div className="show-team-body"><small>{org.region}</small><h2>{org.name}</h2><p>{org.description}</p><div className="team-card-stats"><span><b>{org.teamCount}</b><small>teams</small></span><span><b>{org.rosterCount}</b><small>roster records</small></span><span><b>{org.countries}</b><small>countries</small></span></div><div className="team-public-actions"><span>Learn more</span><b>→</b></div></div></Link>)}</div>
  </section>

  <section className="show-public-section">
    <div className="show-public-section-head"><div><span className="eyebrow">WHAT'S NEXT?</span><h2>Upcoming events</h2></div><Link to="/events">All events →</Link></div>
    {upcoming.length?<div className="show-event-cards">{upcoming.map(event=><Link to={'/events/'+event.id} key={event.id} className="show-event-card"><div className="show-event-card-top"><div><span className="eyebrow">{event.organizerName||'BUHURTOS EVENT'}</span><h2>{event.name}</h2><p>{new Date(event.startsAt).toLocaleString()} · {event.venue}</p></div><Pill tone={event.status==='live'?'red':'green'}>{event.status}</Pill></div><div className="show-event-footer"><span><small>TYPE</small><b>{event.eventType.replaceAll('_',' ')}</b></span><i>Open event →</i></div></Link>)}</div>:<div className="state-card"><strong>No published upcoming events yet.</strong><p>Draft/private events do not appear here. When an organizer publishes one, it will automatically show in the public calendar.</p></div>}
  </section>

  <section className="show-public-section">
    <div className="show-public-section-head"><div><span className="eyebrow">NEW TO BUHURT?</span><h2>Click anything you don't know.</h2><p>BuhurtOS should explain the sport while you browse it.</p></div></div>
    <div className="marketing-problem-grid">{categoryHelp.map(([title,text,to])=><Link to={to} key={title} className="public-learn-card"><span>?</span><h3>{title}</h3><p>{text}</p><b>Find out more →</b></Link>)}</div>
  </section>
 </div>;
}