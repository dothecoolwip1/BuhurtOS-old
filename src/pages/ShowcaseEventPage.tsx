import {useEffect,useMemo,useState} from 'react';
import {Link,useParams} from 'react-router-dom';
import {PageHeader,Panel,Pill} from '../components/ShowcaseUI';
import {loadPublicEventDetails,type PublicEventDetails} from '../lib/publicDirectory';

const pretty=(value:string)=>value.replaceAll('_',' ').replace(/\b\w/g,c=>c.toUpperCase());

function dateRange(startIso:string,endIso:string){
  const start=new Date(startIso);
  const end=new Date(endIso);
  const sameYear=start.getFullYear()===end.getFullYear();
  const startText=start.toLocaleDateString(undefined,{month:'long',day:'numeric',year:sameYear?undefined:'numeric'});
  const endText=end.toLocaleDateString(undefined,{month:'long',day:'numeric',year:'numeric'});
  return startText+' – '+endText;
}

export function ShowcaseEventPage(){
  const {eventId=''}=useParams();
  const [details,setDetails]=useState<PublicEventDetails>();
  const [loading,setLoading]=useState(true);
  const [error,setError]=useState('');

  useEffect(()=>{
    let active=true;
    loadPublicEventDetails(eventId)
      .then(result=>{if(active)setDetails(result)})
      .catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load this event.')})
      .finally(()=>{if(active)setLoading(false)});
    return()=>{active=false};
  },[eventId]);

  const event=details?.event;
  const scheduleTba=Boolean(event?.publicLinks?.schedule_tba);
  const facebook=typeof event?.publicLinks?.facebook==='string'?event.publicLinks.facebook:undefined;
  const hostTeamId=typeof event?.publicLinks?.host_team_id==='string'?event.publicLinks.host_team_id:undefined;
  const upcomingMatches=useMemo(()=>details?.matches.filter(match=>!['completed','finalized','cancelled'].includes(match.status))??[],[details]);

  if(loading)return <div className="state-card">Loading event…</div>;
  if(error)return <div className="state-card"><strong>Unable to load event</strong><p>{error}</p></div>;
  if(!details||!event)return <div className="state-card"><h2>Event not found</h2><p>This event is not published or is no longer publicly available.</p><Link className="show-btn secondary" to="/events">Back to events</Link></div>;

  return <>
    <PageHeader
      eyebrow={event.status==='live'?'LIVE EVENT':'PUBLISHED EVENT'}
      title={event.name}
      description={dateRange(event.startsAt,event.endsAt)+' • '+event.venue}
      actions={<>
        {facebook?<a className="show-btn secondary" href={facebook} target="_blank" rel="noopener noreferrer">Facebook event ↗</a>:null}
        <Link className="show-btn primary" to={'/ops/manage?event='+event.id}>Organizer tools</Link>
      </>}
    />

    <div className="show-event-statusbar">
      <Pill tone={event.status==='live'?'red':'green'}>{pretty(event.status)}</Pill>
      <span>Host: <b>{event.organizerName||'TBA'}</b></span>
      <span>Type: <b>{pretty(event.eventType)}</b></span>
      <span>Timezone: <b>{event.timezone}</b></span>
      {scheduleTba?<span><b>Times TBA</b></span>:null}
    </div>

    <div className="show-two-col wide-left">
      <div className="show-stack">
        <Panel title="About the event">
          <p className="show-long-copy">{event.publicDescription||'Public event details have not been added yet.'}</p>
          {hostTeamId?<div className="show-explain-card"><span>♜</span><div><b>Hosted by {event.organizerName||'a Buhurt team'}</b><p>Open the host team to see its public profile, roster and source-backed information.</p></div><Link to={'/teams/'+hostTeamId}>View host team →</Link></div>:null}
        </Panel>

        <Panel title="Competition">
          {details.divisions.length===0
            ? <div className="source-empty-state"><strong>Divisions not announced yet.</strong><p>When the organizers add real competition divisions, they will appear here automatically.</p></div>
            : <div className="membership-list">{details.divisions.map(division=><article key={division.id}><div className="grow"><strong>{division.name}</strong><small>{division.registrationOpen?'Registration open':'Registration not open'}</small></div></article>)}</div>}
        </Panel>

        <Panel title="Schedule & matches">
          {upcomingMatches.length===0
            ? <div className="source-empty-state"><strong>{scheduleTba?'Schedule to be announced.':'No matches are published yet.'}</strong><p>Once real matches are placed on the fight card, this section becomes the public fight schedule.</p></div>
            : <div className="show-master-schedule">{upcomingMatches.map((match,index)=><article key={match.id}><span className="show-order-num">{match.scheduledOrder||index+1}</span><Pill>{pretty(match.status)}</Pill><div className="grow"><b>{match.label}</b><small>{match.category}</small></div></article>)}</div>}
        </Panel>

        <Panel title="Announcements">
          {details.announcements.length===0
            ? <div className="source-empty-state"><strong>No public announcements yet.</strong><p>Organizer announcements will appear here when posted.</p></div>
            : <div className="announcement-list">{details.announcements.map(item=><article key={item.id}><div className="grow"><b>{item.title}</b><p>{item.body}</p><small>{item.scheduledFor?new Date(item.scheduledFor).toLocaleString():new Date(item.createdAt).toLocaleString()}</small></div></article>)}</div>}
        </Panel>
      </div>

      <div className="show-stack">
        <Panel title="Event details">
          <div className="show-detail-rows">
            <div><span>Dates</span><b>{dateRange(event.startsAt,event.endsAt)}</b></div>
            <div><span>Times</span><b>{scheduleTba?'To be announced':new Date(event.startsAt).toLocaleTimeString()}</b></div>
            <div><span>Venue</span><b>{event.venue}</b></div>
            <div><span>Host</span><b>{event.organizerName||'TBA'}</b></div>
            <div><span>Event type</span><b>{pretty(event.eventType)}</b></div>
            <div><span>Standings</span><b>{pretty(event.standingsMode)}</b></div>
          </div>
        </Panel>

        <Panel title="Registration">
          <div className="state-card">
            <strong>{event.registrationOpen?'Registration is open':'Registration is not open yet'}</strong>
            <p>{event.registrationOpen?'Use the BuhurtOS registration flow for this event.':'Registration details will appear here when the organizers open registration.'}</p>
            {event.registrationOpen?<Link className="show-btn primary full" to={'/register?event='+event.id}>Register</Link>:null}
          </div>
        </Panel>

        <Panel title="Fight areas">
          {details.fields.length===0
            ? <div className="state-card">No fight areas have been configured yet.</div>
            : <div className="show-detail-rows">{details.fields.map(field=><div key={field.id}><span>{field.listName}</span><b>{pretty(field.status)}</b></div>)}</div>}
        </Panel>

        <Panel title="What happens next?">
          <div className="show-explain-card"><span>?</span><div><b>This page grows with the event.</b><p>As organizers add divisions, registrations, fight cards, brackets, live matches, results and announcements, the public event page fills itself from the same live BuhurtOS data.</p></div></div>
        </Panel>
      </div>
    </div>
  </>;
}
