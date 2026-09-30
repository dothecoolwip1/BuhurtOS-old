import {useEffect,useState} from 'react';
import {Link} from 'react-router-dom';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {loadPublicEvents,type PublicEventSummary} from '../lib/publicDirectory';

const label=(v:string)=>v.replaceAll('_',' ').replace(/\b\w/g,l=>l.toUpperCase());

export function ShowcaseEventsPage(){
 const [events,setEvents]=useState<PublicEventSummary[]>([]);
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 useEffect(()=>{let active=true;loadPublicEvents().then(rows=>{if(active)setEvents(rows)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load published events.')}).finally(()=>{if(active)setLoading(false)});return()=>{active=false}},[]);
 const upcoming=events.filter(e=>new Date(e.endsAt).getTime()>=Date.now());
 const past=events.filter(e=>new Date(e.endsAt).getTime()<Date.now()).reverse();
 return <>
  <PageHeader eyebrow="PUBLIC CALENDAR" title="Events" description="Only events actually published in BuhurtOS appear here. Draft and private events stay hidden."/>
  {loading?<LoadingGrid count={4}/>:error?<StatePanel tone="error" title="Unable to load events" text={error}/>:<>
   <section className="show-public-section"><div className="show-public-section-head"><div><span className="eyebrow">UPCOMING</span><h2>Upcoming events</h2></div></div>
    {upcoming.length?<div className="show-event-cards">{upcoming.map(event=><Link to={'/events/'+event.id} key={event.id} className="show-event-card"><div className="show-event-card-top"><div><span className="eyebrow">{event.organizerName||'BUHURTOS'}</span><h2>{event.name}</h2><p>{new Date(event.startsAt).toLocaleString()} · {event.venue}</p></div><Pill tone={event.status==='live'?'red':'green'}>{label(event.status)}</Pill></div><div className="show-event-footer"><span><small>TYPE</small><b>{label(event.eventType)}</b></span><span><small>DATES</small><b>{new Date(event.startsAt).toLocaleDateString()} → {new Date(event.endsAt).toLocaleDateString()}</b></span><i>Open event →</i></div></Link>)}</div>:<StatePanel title="No published upcoming events yet." text="When an organizer publishes a real event, it will show here automatically."/>}
   </section>
   {past.length?<section className="show-public-section"><div className="show-public-section-head"><div><span className="eyebrow">HISTORY</span><h2>Past events</h2></div></div><div className="show-event-cards">{past.map(event=><Link to={'/events/'+event.id} key={event.id} className="show-event-card"><div className="show-event-card-top"><div><h2>{event.name}</h2><p>{new Date(event.startsAt).toLocaleDateString()} · {event.venue}</p></div><Pill>{label(event.status)}</Pill></div></Link>)}</div></section>:null}
  </>}
 </>;
}