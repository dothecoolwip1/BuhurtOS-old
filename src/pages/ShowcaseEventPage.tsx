import {useEffect,useState} from 'react';
import {Link,useParams} from 'react-router-dom';
import {PageHeader,Panel,Pill} from '../components/ShowcaseUI';
import {FighterSignupModal} from '../components/FighterSignupModal';
import {loadPublicEventDetails,type PublicEventDetails} from '../lib/publicDirectory';
import {ListCrumbs} from '../components/chrome';
import {eventCategoryLabel,eventCategoryTone,eventModules,isCompetitionCapable} from '../lib/eventCategories';
import {eventImageThumbUrl,eventImageUrl} from '../lib/eventMedia';
import {useDocumentTitle} from '../lib/pageTitle';
import {buildIcs} from '../lib/ics';
import {toEventDTO} from '../lib/publicApiV1';
import {downloadText} from '../lib/export';
import {useAccount} from '../features/Account';
import {eventClock,formatEventRange,formatEventTime,zoneLabel} from '../lib/eventTime';
import {loadPublicEventSchedule,type PublicScheduleSlot} from '../lib/publicDirectory';
import {loadOfficialEventStats} from '../lib/publicStats';
import type {EventStats} from '../lib/canonicalStats';

const slugName=(name:string)=>name.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')||'event';
/** Native share sheet on phones; otherwise copy the link and say so. Never throws at the visitor. */
function ShareButton({title}:{title:string}){
  const [note,setNote]=useState('');
  const share=async()=>{
    const url=window.location.href;
    try{
      if(navigator.share){await navigator.share({title,url});return;}
      await navigator.clipboard.writeText(url);
      setNote('Link copied');
    }catch(error){
      if((error as Error)?.name!=='AbortError')setNote('Could not share. Copy the address from your browser.');
    }
    setTimeout(()=>setNote(''),3000);
  };
  return <button type="button" className="show-btn secondary" onClick={share} aria-live="polite">{note||'Share'}</button>;
}
const pretty=(value:string)=>value.replaceAll('_',' ').replace(/\b\w/g,c=>c.toUpperCase());


function PlannedTimes({slots,details}:{slots:PublicScheduleSlot[];details:PublicEventDetails}){
  const tz=details.event.timezone;
  const live=details.matches.filter(match=>match.status!=='cancelled');
  const label=new Map(live.map(match=>[match.id,match.label]));
  const fieldName=(slot:PublicScheduleSlot)=>slot.areaName||details.fields.find(field=>field.id===slot.areaId)?.name||'Fighting area';
  slots=slots.filter(slot=>label.has(slot.matchId));
  if(slots.length===0)return null;
  const areas=[...new Set(slots.map(fieldName))];
  return <div className="planned-times">
    <p className="show-note" role="note">Planned times in {zoneLabel(tz)}. Bouts can start earlier or later than planned, so check with the marshals on the day.</p>
    <div className="planned-grid">{areas.map(area=><section key={area}><h4>{area}</h4><ol>{slots.filter(slot=>fieldName(slot)===area).map(slot=><li key={slot.matchId}><time dateTime={slot.startsAt}>{eventClock(slot.startsAt,tz)}</time><span>{label.get(slot.matchId)??'Bout'}</span></li>)}</ol></section>)}</div>
  </div>;
}

export function EventDetailView({details,onFighterSignup,stats,statsError,organizerToolsHref,schedule}:{details:PublicEventDetails;onFighterSignup:()=>void;stats?:EventStats;statsError?:boolean;organizerToolsHref?:string;schedule?:PublicScheduleSlot[]}){
  const event=details.event;
  const scheduleTba=Boolean(event.publicLinks?.schedule_tba);
  const facebook=typeof event.publicLinks?.facebook==='string'?event.publicLinks.facebook:undefined;
  const hostTeamId=event.hostTeamId;
  const modules=eventModules(event.eventType,{divisions:details.divisions.length,matches:details.matches.length,fields:details.fields.length});
  const upcomingMatches=details.matches.filter(match=>!['completed','finalized','cancelled'].includes(match.status));
  return <>
    <ListCrumbs list="/events" label="Events" current={event.name}/>
    {event.imagePath?<figure className="event-hero-media"><picture><source media="(max-width: 640px)" srcSet={eventImageThumbUrl(event.imagePath,640)}/><img src={eventImageUrl(event.imagePath)} alt={event.name+' poster'} decoding="async" fetchPriority="high"/></picture></figure>:null}
    <PageHeader
      eyebrow={event.status==='live'?'LIVE EVENT':'PUBLISHED EVENT'}
      title={event.name}
      description={formatEventRange(event.startsAt,event.endsAt,event.timezone,true)+' • '+event.venue}
      actions={<>
        {modules.fighterSignup&&event.status!=='cancelled'&&event.status!=='completed'?<button className="show-btn primary" type="button" onClick={()=>onFighterSignup()}>Fighter interest form</button>:null}
        <button type="button" className="show-btn secondary" onClick={()=>downloadText(slugName(event.name)+'.ics',buildIcs([toEventDTO(event)],event.name),'text/calendar;charset=utf-8')}>Add to calendar</button>
        <ShareButton title={event.name}/>
        {facebook?<a className="show-btn secondary" href={facebook} target="_blank" rel="noopener noreferrer">Facebook event ↗</a>:null}
        {organizerToolsHref?<Link className="show-btn secondary" to={organizerToolsHref}>Organizer tools</Link>:null}
      </>}
    />

    <div className="show-event-statusbar">
      <Pill tone={eventCategoryTone(event.eventType)}>{eventCategoryLabel(event.eventType)}</Pill>
      <Pill tone={event.status==='live'?'red':'green'}>{pretty(event.status)}</Pill>
      <span>Host: <b>{event.organizerName||'TBA'}</b></span>
      <span>Category: <b>{eventCategoryLabel(event.eventType)}</b></span>
      <span>Timezone: <b>{zoneLabel(event.timezone)}</b></span>
      {scheduleTba?<span><b>Times TBA</b></span>:null}
    </div>

    <div className="show-two-col wide-left">
      <div className="show-stack">
        <Panel title="About the event">
          <p className="show-long-copy">{event.publicDescription||'Public event details have not been added yet.'}</p>
          {hostTeamId?<div className="show-explain-card"><span>♜</span><div><b>Hosted by {event.organizerName||'a Buhurt team'}</b><p>Open the host team to see its public profile, roster and source-backed information.</p></div><Link to={'/teams/'+hostTeamId}>View host team →</Link></div>:null}
        </Panel>

        {modules.divisions?<Panel title="Competition">
          {details.divisions.length===0
            ? <div className="source-empty-state"><strong>Divisions not announced yet.</strong><p>When the organizers add real competition divisions, they will appear here automatically.</p></div>
            : <div className="membership-list">{details.divisions.map(division=><article key={division.id}><div className="grow"><strong>{division.name}</strong><small>{division.registrationOpen?'Registration open':'Registration not open'}</small></div></article>)}</div>}
        </Panel>:null}

        {modules.schedule?<Panel title="Schedule & matches">
          {schedule&&schedule.length>0?<PlannedTimes slots={schedule} details={details}/>:null}
          {upcomingMatches.length===0
            ? <div className="source-empty-state"><strong>{scheduleTba?'Schedule to be announced.':'No matches are published yet.'}</strong><p>Once real matches are placed on the fight card, this section becomes the public fight schedule.</p></div>
            : <div className="show-master-schedule">{upcomingMatches.map((match,index)=><article key={match.id}><span className="show-order-num">{match.scheduledOrder||index+1}</span><Pill>{pretty(match.status)}</Pill><div className="grow"><b>{match.label}</b><small>{match.category}</small></div></article>)}</div>}
        </Panel>:null}

        <Panel title="Announcements">
          {details.announcements.length===0
            ? <div className="source-empty-state"><strong>No public announcements yet.</strong><p>Organizer announcements will appear here when posted.</p></div>
            : <div className="announcement-list">{details.announcements.map(item=><article key={item.id}><div className="grow"><b>{item.title}</b><p>{item.body}</p><small>{item.scheduledFor?new Date(item.scheduledFor).toLocaleString():new Date(item.createdAt).toLocaleString()}</small></div></article>)}</div>}
        </Panel>
      </div>

      <div className="show-stack">
        <Panel title="Event details">
          <div className="show-detail-rows">
            <div><span>Dates</span><b>{formatEventRange(event.startsAt,event.endsAt,event.timezone,true)}</b></div>
            <div><span>Times</span><b>{scheduleTba?'To be announced':formatEventTime(event.startsAt,event.timezone)+' start'}</b></div>
            <div><span>Venue</span><b>{event.venue}</b></div>
            <div><span>Host</span><b>{event.organizerName||'TBA'}</b></div>
            <div><span>Category</span><b>{eventCategoryLabel(event.eventType)}</b></div>
            {isCompetitionCapable(event.eventType)&&!modules.divisions?<div><span>Divisions</span><b>To be announced</b></div>:null}
            {isCompetitionCapable(event.eventType)&&!modules.schedule?<div><span>Fight schedule</span><b>To be announced</b></div>:null}
            {modules.standings?<div><span>Standings</span><b>{pretty(event.standingsMode)}</b></div>:null}
          </div>
        </Panel>

        {modules.standings&&statsError?<p className="show-note" role="status">Official results could not be loaded right now. Reload the page to try again.</p>:null}
        {modules.standings&&stats&&stats.officialResults>0?<Panel title="Official results" subtitle="Finalized matches only."><div className="show-detail-rows"><div><span>Participants</span><b>{stats.participants}</b></div><div><span>Teams</span><b>{stats.teams}</b></div><div><span>Matches finalized</span><b>{stats.finalizedMatches} of {stats.matches}</b></div><div><span>Formats</span><b>{stats.formats.join(', ')||'—'}</b></div></div></Panel>:null}
        <Panel title="Registration">
          <div className="state-card">
            <strong>{event.status==='cancelled'?'This event was cancelled':event.registrationOpen?'Registration is open':'Registration is not open'}</strong>
            <p>{event.status==='cancelled'?'No registration is being taken.':event.registrationOpen?'Use the BuhurtOS registration flow for this event.':'Registration details will appear here when the organizers open registration.'}{modules.fighterSignup&&event.status!=='completed'&&event.status!=='cancelled'?' The fighter interest form tells organizers you want to take part with an invite code; it does not reserve a place.':''}</p>
            {event.registrationOpen&&event.status!=='cancelled'?<Link className="show-btn primary full" to={'/register?event='+event.id}>Register</Link>:null}
          </div>
        </Panel>

        {modules.fields?<Panel title="Fight areas">
          {details.fields.length===0
            ? <div className="state-card">No fight areas have been configured yet.</div>
            : <div className="show-detail-rows">{details.fields.map(field=><div key={field.id}><span>{field.listName}</span><b>{pretty(field.status)}</b></div>)}</div>}
        </Panel>:null}

        <Panel title="What happens next?">
          <div className="show-explain-card"><span>?</span><div><b>This page grows with the event.</b><p>{modules.divisions?'As organizers add divisions, registrations, fight cards, brackets, live matches, results and announcements, the public event page fills itself from the same live BuhurtOS data.':'Organizers can add details, links and announcements here as the event gets closer.'}</p></div></div>
        </Panel>
      </div>
    </div>
  </>;
}

export function ShowcaseEventPage(){
  const {user}=useAccount();
  const {eventId=''}=useParams();
  const [details,setDetails]=useState<PublicEventDetails>();
  const [loading,setLoading]=useState(true);
  const [error,setError]=useState('');
  const [fighterSignupOpen,setFighterSignupOpen]=useState(false);
  const [stats,setStats]=useState<EventStats>();
  const [statsError,setStatsError]=useState(false);
  const [schedule,setSchedule]=useState<PublicScheduleSlot[]>([]);
  const [attempt,setAttempt]=useState(0);

  useEffect(()=>{
    let active=true;
    // A new event id never renders the previous event's data or error.
    setDetails(undefined);setStats(undefined);setStatsError(false);setSchedule([]);setError('');setLoading(true);setFighterSignupOpen(false);
    loadPublicEventDetails(eventId)
      .then(result=>{
        if(!active)return;
        setDetails(result);
        if(result)loadPublicEventSchedule(result.event.id).then(rows=>{if(active)setSchedule(rows)}).catch(()=>undefined);
        if(result)loadOfficialEventStats(result.event.id).then(x=>{if(active)setStats(x)}).catch(()=>{if(active)setStatsError(true)});
      })
      .catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load this event.')})
      .finally(()=>{if(active)setLoading(false)});
    return()=>{active=false};
  },[eventId,attempt]);

  useDocumentTitle(details?.event.name,'Event');
  if(loading)return <div className="state-card" role="status">Loading event…</div>;
  if(error)return <div className="state-card" role="alert"><strong>This event could not be loaded</strong><p>{error}</p><p>This is a connection or server problem, not a missing event.</p><div className="show-actions"><button type="button" className="show-btn" onClick={()=>setAttempt(n=>n+1)}>Try again</button><Link className="show-btn secondary" to="/events">Back to events</Link></div></div>;
  if(!details)return <div className="state-card"><h2>Event not found</h2><p>This event is not published or is no longer publicly available.</p><Link className="show-btn secondary" to="/events">Back to events</Link></div>;

  return <>
    <FighterSignupModal open={fighterSignupOpen} onClose={()=>setFighterSignupOpen(false)} eventId={details.event.id} eventName={details.event.name}/>
    <EventDetailView details={details} onFighterSignup={()=>setFighterSignupOpen(true)} stats={stats} statsError={statsError} schedule={schedule} organizerToolsHref={user?'/admin/events/manage?event='+details.event.id:undefined}/>
  </>;
}
