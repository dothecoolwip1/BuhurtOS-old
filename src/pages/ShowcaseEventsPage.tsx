import {useEffect,useMemo,useState} from 'react';
import {Link,useLocation} from 'react-router-dom';
import {rememberListSearch,useQueryState} from '../lib/urlState';
import {LoadingGrid,PageHeader,Pill,StatePanel} from '../components/ShowcaseUI';
import {loadPublicEvents,loadPublicOrganizations,type PublicEventSummary,type PublicOrganizationSummary} from '../lib/publicDirectory';
import {downloadText} from '../lib/export';
import {buildIcs} from '../lib/ics';
import {toEventDTO} from '../lib/publicApiV1';
import {formatEventRange} from '../lib/eventTime';
import {eventCategoryLabel,eventCategoryLabels,eventCategoryOrder,eventCategoryTone,eventCta,filterEvents,groupByMonth,normalizeEventCategory,splitUpcomingPast} from '../lib/eventCategories';

const label=(v:string)=>v.replaceAll('_',' ').replace(/\b\w/g,l=>l.toUpperCase());

function dateText(event:PublicEventSummary){
 return formatEventRange(event.startsAt,event.endsAt,event.timezone);
}

export function ShowcaseEventsPage(){
 const [events,setEvents]=useState<PublicEventSummary[]>([]);
 const [orgs,setOrgs]=useState<PublicOrganizationSummary[]>([]);
 const [loading,setLoading]=useState(true);
 const [error,setError]=useState('');
 const [whenValue,setWhen]=useQueryState('when','upcoming');
 const when=(whenValue==='past'?'past':'upcoming') as 'upcoming'|'past';
 const [category,setCategory]=useQueryState('category','all');
 const [organizationId,setOrganizationId]=useQueryState('org','all');
 const [teamId,setTeamId]=useQueryState('team','all');
 const location=useLocation(); useEffect(()=>rememberListSearch('/events',location.search),[location.search]);
 useEffect(()=>{let active=true;
  loadPublicEvents().then(rows=>{if(active)setEvents(rows)}).catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load published events.')}).finally(()=>{if(active)setLoading(false)});
  loadPublicOrganizations().then(rows=>{if(active)setOrgs(rows)}).catch(()=>{});
  return()=>{active=false}},[]);
 const orgName=useMemo(()=>new Map(orgs.map(o=>[o.id??'',o.shortName])),[orgs]);
 const presentCategories=useMemo(()=>eventCategoryOrder.filter(c=>events.some(e=>normalizeEventCategory(e.eventType)===c)),[events]);
 const presentOrgs=useMemo(()=>[...new Set(events.map(e=>e.organizationId))].filter(id=>orgName.has(id)),[events,orgName]);
 const hostTeams=useMemo(()=>{const map=new Map<string,string>();events.forEach(e=>{if(e.hostTeamId)map.set(e.hostTeamId,e.organizerName||'Host team')});return [...map.entries()]},[events]);
 const {upcoming,past}=useMemo(()=>splitUpcomingPast(filterEvents(events,{category,organizationId,teamId})),[events,category,organizationId,teamId]);
 const shown=when==='upcoming'?upcoming:past;
 const months=useMemo(()=>groupByMonth(shown),[shown]);
 const filtered=category!=='all'||organizationId!=='all'||teamId!=='all';
 const exportIcs=()=>downloadText('buhurtos-events.ics',buildIcs(shown.map(event=>toEventDTO(event,orgName)),'BuhurtOS events'),'text/calendar;charset=utf-8');
 return <>
  <PageHeader eyebrow="PUBLIC CALENDAR" title="Events" description="Tournaments, demos, training, meetings and community gatherings. Only events actually published in BuhurtOS appear here. Draft and private events stay hidden."/>
  {loading?<LoadingGrid count={4}/>:error?<StatePanel tone="error" title="Unable to load events" text={error}/>:<>
   <div className="public-directory-toolbar events-toolbar">
    <div className="directory-view-switch" role="group" aria-label="Upcoming or past events">
     <button type="button" className={when==='upcoming'?'selected':''} aria-pressed={when==='upcoming'} onClick={()=>setWhen('upcoming')}>Upcoming ({upcoming.length})</button>
     <button type="button" className={when==='past'?'selected':''} aria-pressed={when==='past'} onClick={()=>setWhen('past')}>Past ({past.length})</button>
    </div>
    <div className="show-filter-row">
     <select aria-label="Filter by category" value={category} onChange={e=>setCategory(e.target.value)}><option value="all">All categories</option>{presentCategories.map(c=><option key={c} value={c}>{eventCategoryLabels[c]}</option>)}</select>
     {presentOrgs.length>1?<select aria-label="Filter by organization" value={organizationId} onChange={e=>setOrganizationId(e.target.value)}><option value="all">All organizations</option>{presentOrgs.map(id=><option key={id} value={id}>{orgName.get(id)}</option>)}</select>:null}
     {hostTeams.length>0?<select aria-label="Filter by host team" value={teamId} onChange={e=>setTeamId(e.target.value)}><option value="all">All host teams</option>{hostTeams.map(([id,name])=><option key={id} value={id}>{name}</option>)}</select>:null}
    </div>
   </div>
   {shown.length>0?<div className="directory-load-more"><span>{shown.length} event{shown.length===1?'':'s'} shown</span><button className="show-btn secondary" type="button" onClick={exportIcs}>Add to calendar (.ics)</button></div>:null}
   {shown.length===0?<StatePanel title={filtered?'No events match those filters.':when==='upcoming'?'No published upcoming events yet.':'No past events yet.'} text={filtered?'Clear a filter to see more events.':'When an organizer publishes a real event, it will show here automatically.'}/>:months.map(month=><section className="show-public-section event-month" key={month.key}>
    <div className="show-public-section-head"><div><span className="eyebrow">{when==='upcoming'?'AGENDA':'HISTORY'}</span><h2>{month.label}</h2></div></div>
    <div className="show-event-cards">{month.events.map(event=>{
     const cta=eventCta(event.eventType,{registrationOpen:Boolean(event.registrationOpen),hasLink:true,status:event.status});
     return <Link to={'/events/'+event.id} key={event.id} className="show-event-card">
      <div className="show-event-card-top"><div><span className="eyebrow">{orgName.get(event.organizationId)||event.organizerName||'BUHURTOS'}</span><h2>{event.name}</h2><p>{dateText(event)} · {event.venue}</p></div>
       <div className="show-inline-pills"><Pill tone={eventCategoryTone(event.eventType)}>{eventCategoryLabel(event.eventType)}</Pill>{when==='upcoming'&&event.status!=='cancelled'?<Pill tone={event.registrationOpen?'green':'neutral'}>{event.registrationOpen?'Registration open':'Registration not open yet'}</Pill>:null}{event.status!=='published'?<Pill tone={event.status==='live'?'red':event.status==='cancelled'?'amber':'neutral'}>{label(event.status)}</Pill>:null}</div></div>
      <div className="show-event-footer"><span><small>HOST</small><b>{event.organizerName||orgName.get(event.organizationId)||'TBA'}</b></span><span><small>DATES</small><b>{dateText(event)}</b></span><i>{cta.label} →</i></div>
     </Link>})}</div>
   </section>)}
  </>}
 </>;
}
