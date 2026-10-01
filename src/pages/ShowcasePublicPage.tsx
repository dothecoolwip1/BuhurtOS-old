import {useEffect,useMemo,useRef,useState} from 'react';
import {Link} from 'react-router-dom';
import {PublicTeamMap} from '../components/PublicTeamMap';
import {Pill,StatePanel} from '../components/ShowcaseUI';
import {eventPath,loadPublicOrganizations,loadPublicEvents,type PublicOrganizationSummary,type PublicEventSummary} from '../lib/publicDirectory';
import {formatEventDate,eventDayKey} from '../lib/eventTime';
import {loadFeaturedTeams,type PublicDirectoryTeam} from '../lib/teamDirectory';
import { friendlyError } from '../lib/friendlyError';

type FormatKey='melee'|'duels'|'outrance';
type VisitorKey='curious'|'watch'|'fight'|'organize';

const formats:Record<FormatKey,{tab:string;kicker:string;title:string;copy:string;points:string[];tag:string}>={
  melee:{
    tab:'Team melee',
    kicker:'MULTIPLE FIGHTERS · ONE LIST',
    title:'The version that looks impossible until you see it.',
    copy:'Teams enter the fighting area together in full armor. Striking, clinching, grappling and takedowns all matter, with the exact format and scoring controlled by the event ruleset.',
    points:['Common team formats include 5v5 and larger melees','Fighters use regulated blunt weapons and protective armor','Marshals control the fight and enforce the rules'],
    tag:'Fast · physical · tactical'
  },
  duels:{
    tab:'Duels',
    kicker:'ONE FIGHTER · ONE FIGHTER',
    title:'Technical armored combat, one opponent at a time.',
    copy:'Duels focus on individual skill and scoring within a defined weapon category. Events can include longsword, sword and buckler, sword and shield, polearm and other approved divisions.',
    points:['Individual rather than team competition','Weapon category determines the rules and scoring','Results can feed event and ranking records'],
    tag:'Precise · technical · competitive'
  },
  outrance:{
    tab:'Outrance',
    kicker:'INDIVIDUAL FULL CONTACT',
    title:'A different individual format with its own ruleset.',
    copy:'Outrance is another armored combat discipline used at some tournaments. It is separate from standard dueling and team melee, with its own competition rules and event structure.',
    points:['Individual armored competition','Separate rules from standard duels','Availability depends on the event and governing ruleset'],
    tag:'Individual · intense · ruleset specific'
  }
};

const visitorPaths:Record<VisitorKey,{label:string,title:string,copy:string,actions:Array<[string,string]>}>={
  curious:{
    label:'I am just curious',
    title:'Start with the sport itself.',
    copy:'You do not need to know a team, a ruleset or even what a “list” is. Start with the basics, then explore real teams and events when something catches your eye.',
    actions:[['Learn the formats','/rules'],['See teams near the action','/teams']]
  },
  watch:{
    label:'I want to watch',
    title:'Find what is happening and understand it while you watch.',
    copy:'Open published events, see the host, venue, schedule and competition information that has actually been entered, then use the rules area whenever something is unfamiliar.',
    actions:[['Find events','/events'],['Open the rules guide','/rules']]
  },
  fight:{
    label:'I want to try it',
    title:'Find the people already training near you.',
    copy:'The easiest first step is usually a local team. BuhurtOS maps public team locations and profiles so a newcomer can discover who is active and where to start asking questions.',
    actions:[['Find a team','/teams'],['Browse fighter profiles','/fighters']]
  },
  organize:{
    label:'I help run the sport',
    title:'This is where BuhurtOS becomes an operating system.',
    copy:'Organizations, teams and event staff can use the same underlying records for public discovery, access control, registration and event operations instead of rebuilding the same information in separate tools.',
    actions:[['See the organization structure','/governance'],['Sign in to manage','/sign-in']]
  }
};

const platformLayers=[
  ['DISCOVER','Teams · fighters · events · rules','The public front door'],
  ['ORGANIZE','Organizations · rosters · access','The people and structure'],
  ['OPERATE','Registration · fields · fight cards','The event-day system'],
  ['RECORD','Results · rankings · history','What survives after the event']
] as const;

const exploreCards=[
  {icon:'⌘',title:'Organizations',copy:'See how governing bodies and teams connect.',to:'/governance',meta:'STRUCTURE'},
  {icon:'♜',title:'Teams',copy:'Search real public team records and explore the map.',to:'/teams',meta:'FIND YOUR PEOPLE'},
  {icon:'♟',title:'Fighters',copy:'Browse public sporting identities and connected records.',to:'/fighters',meta:'ATHLETES'},
  {icon:'⚔',title:'Events',copy:'Find published tournaments, demos, training and gatherings.',to:'/events',meta:'WHAT IS NEXT'},
  {icon:'↗',title:'Rankings',copy:'See standings only when real source data supports them.',to:'/rankings',meta:'COMPETITION'},
  {icon:'§',title:'Rules',copy:'Understand formats, rulesets and what officials are calling.',to:'/rules',meta:'LEARN THE SPORT'}
] as const;

const currentCapabilities=[
  'Public organization hierarchy',
  'Global team directory and map',
  'Public fighter identities',
  'Published event pages',
  'Rules and rankings discovery',
  'Role-based management access',
  'Event operations foundation',
  'Signup and delegated access foundations'
];

const futureCapabilities=[
  'Richer permanent fighter careers',
  'Team and organization claiming',
  'Broader calendars and event types',
  'Embeddable standings and team widgets',
  'Deeper source-backed statistics',
  'More complete event-day automation',
  'Expanded season and historical records',
  'Distribution tools for the wider sport'
];



export function ShowcasePublicPage(){
  const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
  const [orgs,setOrgs]=useState<PublicOrganizationSummary[]>([]);
  const [events,setEvents]=useState<PublicEventSummary[]>([]);
  const [orgsLoading,setOrgsLoading]=useState(true);
  const [eventsLoading,setEventsLoading]=useState(true);
  const [orgsError,setOrgsError]=useState('');
  const [eventsError,setEventsError]=useState('');
  const [attempt,setAttempt]=useState(0);
  const [teamsAttempt,setTeamsAttempt]=useState(0);
  const [teamsLoading,setTeamsLoading]=useState(false);
  const [mapRequested,setMapRequested]=useState(false);
  const [teamsError,setTeamsError]=useState('');
  const mapSectionRef=useRef<HTMLElement|null>(null);
  const [format,setFormat]=useState<FormatKey>('melee');
  const [visitor,setVisitor]=useState<VisitorKey>('curious');

  useEffect(()=>{
    // Each section loads on its own: a failing events query must not blank the organization cards, and vice versa.
    let active=true;
    setOrgsLoading(true);setEventsLoading(true);setOrgsError('');setEventsError('');
    loadPublicOrganizations()
      .then(o=>{if(active)setOrgs(o)})
      .catch(err=>{if(active)setOrgsError(friendlyError(err).message)})
      .finally(()=>{if(active)setOrgsLoading(false)});
    loadPublicEvents()
      .then(e=>{if(active)setEvents(e)})
      .catch(err=>{if(active)setEventsError(friendlyError(err).message)})
      .finally(()=>{if(active)setEventsLoading(false)});
    return()=>{active=false};
  },[attempt]);

  useEffect(()=>{
    if(mapRequested)return;
    const node=mapSectionRef.current;
    if(!node)return;
    if(!('IntersectionObserver' in window)){setMapRequested(true);return;}
    const observer=new IntersectionObserver(entries=>{
      if(entries.some(entry=>entry.isIntersecting)){setMapRequested(true);observer.disconnect();}
    },{rootMargin:'700px'});
    observer.observe(node);
    return()=>observer.disconnect();
  },[mapRequested]);

  useEffect(()=>{
    if(!mapRequested)return;
    let active=true;
    setTeamsLoading(true);
    setTeamsError('');
    loadFeaturedTeams()
      .then(t=>{if(active)setTeams(t)})
      .catch(err=>{if(active)setTeamsError(friendlyError(err).message)})
      .finally(()=>{if(active)setTeamsLoading(false)});
    return()=>{active=false};
  },[mapRequested,teamsAttempt]);

  const mapped=useMemo(()=>teams.filter(t=>t.latitude!=null&&t.longitude!=null),[teams]);
  const featuredOrgs=useMemo(()=>{const f=orgs.filter(o=>o.featured);return f.length?f:orgs.slice(0,2)},[orgs]);
  const upcoming=useMemo(()=>events.filter(e=>new Date(e.endsAt).getTime()>=Date.now()).slice(0,4),[events]);
  const activeFormat=formats[format];
  const activeVisitor=visitorPaths[visitor];
  const spotlightEvent=upcoming[0];

  return <div className="bhome">
    <section className="bhome-cinema">
      <div className="bhome-cinema-photo" aria-hidden="true"/>
      <div className="bhome-cinema-wash" aria-hidden="true"/>
      <div className="bhome-cinema-grain" aria-hidden="true"/>
      <div className="bhome-cinema-content">
        <div className="bhome-cinema-copy">
          <span className="bhome-kicker"><i/> THIS IS A REAL SPORT</span>
          <h1>Steel armor.<br/>Full contact.<br/><em>Real competition.</em></h1>
          <p>Buhurt is modern armored combat using historically inspired protective armor and regulated blunt weapons. It is refereed, organized and competitive, not a staged medieval fight.</p>
          <div className="bhome-cinema-actions">
            <button className="show-btn primary bhome-big-btn" type="button" onClick={()=>document.getElementById('what-is-buhurt')?.scrollIntoView({behavior:'smooth'})}>I have never seen this before <span>↓</span></button>
            <Link className="show-btn glass bhome-big-btn" to="/events">Show me real events</Link>
            <Link className="show-btn glass bhome-big-btn" to="/teams">Find a team to join</Link>
          </div>
          <div className="bhome-cinema-facts">
            <span><b>FULL CONTACT</b><small>Striking, grappling and takedowns</small></span>
            <span><b>ARMORED</b><small>Protective equipment is checked</small></span>
            <span><b>SPORT</b><small>Rules, officials, events and rankings</small></span>
          </div>
        </div>

        <aside className="bhome-101">
          <div className="bhome-101-top"><span>BUHURT 101</span><b>What am I looking at?</b></div>
          <div className="bhome-101-row"><span>01</span><div><b>The armor is functional</b><small>Modern-made protective equipment is built to meet safety and historical appearance requirements.</small></div></div>
          <div className="bhome-101-row"><span>02</span><div><b>The weapons are regulated</b><small>Competition uses approved blunt weapons rather than sharpened battlefield weapons.</small></div></div>
          <div className="bhome-101-row"><span>03</span><div><b>The contact is real</b><small>Fighters compete under a ruleset with trained officials called marshals.</small></div></div>
          <div className="bhome-101-row"><span>04</span><div><b>There are different formats</b><small>Team melees, one-on-one duels and other categories can appear at an event.</small></div></div>
          <Link to="/rules">Open the beginner rules guide <span>→</span></Link>
        </aside>
      </div>
      <div className="bhome-scroll-cue"><span>SCROLL TO ENTER THE SPORT</span><i>↓</i></div>
    </section>

    <section className="bhome-beginner" id="what-is-buhurt">
      <div className="bhome-beginner-lead">
        <span className="eyebrow">NEW TO BUHURT?</span>
        <h2>Think combat sport.<br/><em>Then add armor.</em></h2>
        <p>You do not need to understand the organizations, rankings or rulebooks first. The simple version is that trained competitors fight in protective medieval-style armor under modern sporting rules.</p>
        <div className="bhome-word">
          <span>BUHURT</span>
          <div><b>also called armored combat</b><small>A modern full-contact combat sport, not choreographed reenactment.</small></div>
        </div>
      </div>
      <div className="bhome-format-explorer">
        <div className="bhome-format-tabs" role="tablist" aria-label="Common competition formats">
          {(Object.keys(formats) as FormatKey[]).map(key=><button key={key} type="button" role="tab" aria-selected={format===key} className={format===key?'active':''} onClick={()=>setFormat(key)}>{formats[key].tab}</button>)}
        </div>
        <div className="bhome-format-card">
          <span>{activeFormat.kicker}</span>
          <h3>{activeFormat.title}</h3>
          <p>{activeFormat.copy}</p>
          <div>{activeFormat.points.map(point=><small key={point}><i>✓</i>{point}</small>)}</div>
          <b>{activeFormat.tag}</b>
        </div>
      </div>
    </section>

    <section className="bhome-not-reenactment">
      <div>
        <span className="bhome-mega-word">NOT STAGED.</span>
        <span className="bhome-mega-word outline">NOT FANTASY.</span>
        <span className="bhome-mega-word accent">SPORT.</span>
      </div>
      <p>The historical look matters, but the competition is contemporary. Fighters train, equipment is inspected, marshals officiate, events publish results, and governing bodies maintain rules and standards.</p>
    </section>

    <section className="bhome-paths">
      <div className="bhome-section-head">
        <div><span className="eyebrow">YOU DO NOT NEED TO KNOW WHERE TO START</span><h2>Tell BuhurtOS why you are here.</h2></div>
        <p>The homepage changes the next step depending on whether you are discovering the sport, looking for something to watch, trying to join, or already helping run it.</p>
      </div>
      <div className="bhome-path-layout">
        <div className="bhome-path-tabs" role="tablist" aria-label="Visitor goals">
          {(Object.keys(visitorPaths) as VisitorKey[]).map(key=><button key={key} type="button" role="tab" aria-selected={visitor===key} className={visitor===key?'active':''} onClick={()=>setVisitor(key)}><span>{visitorPaths[key].label}</span><i>→</i></button>)}
        </div>
        <div className="bhome-path-panel">
          <span className="eyebrow">YOUR NEXT STEP</span>
          <h3>{activeVisitor.title}</h3>
          <p>{activeVisitor.copy}</p>
          <div>{activeVisitor.actions.map(([label,to],index)=><Link key={to} className={index===0?'show-btn primary':'show-btn secondary'} to={to}>{label} →</Link>)}</div>
        </div>
      </div>
    </section>

    <section className="bhome-platform">
      <div className="bhome-platform-intro">
        <span className="eyebrow">SO WHAT IS BUHURTOS?</span>
        <h2>The digital layer connecting the sport from first click to final result.</h2>
        <p>Today, the sport can live across websites, spreadsheets, forms, messages and isolated event systems. BuhurtOS is being built so the same real records can serve the public, teams, organizers, officials and governing organizations without being recreated over and over.</p>
      </div>
      <div className="bhome-platform-stack">
        {platformLayers.map(([title,items,caption],index)=><div key={title} className={'bhome-layer layer-'+index}><span>{String(index+1).padStart(2,'0')}</span><div><small>{caption}</small><b>{title}</b><p>{items}</p></div><i>↘</i></div>)}
      </div>
    </section>

    <section className="bhome-network">
      <div className="bhome-network-copy">
        <span className="eyebrow">THE NETWORK ALREADY HAS REAL DATA</span>
        <h2>This is not a pretend product tour.</h2>
        <p>The numbers here come from the public sport records currently available to BuhurtOS. No invented fan counts, fake fighters or made-up live events.</p>
        <Link className="show-btn secondary" to="/teams">Explore teams →</Link><Link className="show-btn secondary" to="/teams?tab=worldwide">Explore all worldwide teams →</Link>
      </div>
      <div className="bhome-network-stats">
        <Link to="/governance"><strong>{orgsLoading?'…':orgsError?'—':featuredOrgs.length}</strong><span>featured organizations</span><small>Buhurt International and HACSA</small></Link>
        <Link to="/teams"><strong>{mapRequested?(teamsLoading?'…':teamsError?'—':teams.length):'↘'}</strong><span>featured teams</span><small>{mapRequested?'Open the team directory':'Loads with the map below'}</small></Link>
        <Link to="/events"><strong>{eventsLoading?'…':eventsError?'—':upcoming.length}</strong><span>upcoming events</span><small>Published by organizers</small></Link>
      </div>
    </section>

    <section className="bhome-section bhome-explore">
      <div className="bhome-section-head">
        <div><span className="eyebrow">GO ANYWHERE FROM HERE</span><h2>One sport. Six public doors.</h2></div>
        <p>Each area answers a different question, but they all connect back to the same ecosystem.</p>
      </div>
      <div className="bhome-explore-grid">{exploreCards.map(card=><Link to={card.to} className="bhome-explore-card" key={card.title}><div className="bhome-explore-icon">{card.icon}</div><div><small>{card.meta}</small><h3>{card.title}</h3><p>{card.copy}</p></div><b>↗</b></Link>)}</div>
    </section>

    <section className="bhome-event-stage">
      <div className="bhome-event-stage-head">
        <div><span className="eyebrow">WHAT IS ACTUALLY HAPPENING?</span><h2>Real published events.</h2><p>If an event is not published, BuhurtOS does not pretend it is live. When organizers publish real information, it can appear here.</p></div>
        <Link to="/events">Open full event calendar →</Link>
      </div>
      {eventsError?<StatePanel tone="error" title="Events could not be loaded" text={eventsError+' This does not mean there are no events.'} action={<button type="button" className="show-btn" onClick={()=>setAttempt(n=>n+1)}>Try again</button>}/>:null}
      {spotlightEvent?<div className="bhome-featured-event">
        <div className="bhome-featured-date"><span>UP NEXT</span><strong>{Number(eventDayKey(spotlightEvent.startsAt,spotlightEvent.timezone).slice(8))}</strong><small>{formatEventDate(spotlightEvent.startsAt,spotlightEvent.timezone)}</small></div>
        <div className="bhome-featured-copy"><div><Pill tone={spotlightEvent.status==='live'?'red':'green'}>{spotlightEvent.status}</Pill><span>{spotlightEvent.eventType.replaceAll('_',' ')}</span></div><h3>{spotlightEvent.name}</h3><p>{spotlightEvent.venue||'Venue TBA'}{spotlightEvent.organizerName?' · '+spotlightEvent.organizerName:''}</p><Link className="show-btn primary" to={eventPath(spotlightEvent)}>Open event →</Link></div>
        <div className="bhome-featured-index"><span>BUHURTOS</span><b>EVENT</b><i>⚔</i></div>
      </div>:!eventsLoading&&!eventsError?<div className="bhome-empty"><span>⚔</span><div><strong>No future published events yet.</strong><p>The public calendar will populate from real event records as organizers publish them.</p></div><Link to="/events">View event directory →</Link></div>:eventsLoading?<div className="state-card" role="status">Loading published events…</div>:null}
      {upcoming.length>1?<div className="bhome-events-strip">{upcoming.slice(1).map(event=><Link to={eventPath(event)} key={event.id}><small>{formatEventDate(event.startsAt,event.timezone)}</small><b>{event.name}</b><span>{event.venue||'Venue TBA'}</span><i>→</i></Link>)}</div>:null}
    </section>

    <section className="bhome-map-stage" ref={mapSectionRef}>
      <div className="bhome-map-copy">
        <span className="eyebrow">WHERE DOES THIS EVEN EXIST?</span>
        <h2>Featured teams near the action.</h2>
        <p>BuhurtOS maps featured public team locations so somebody discovering the sport for the first time can go from “what is this?” to “who trains near me?” without hunting through disconnected social pages.</p>
        <div><strong>{!mapRequested?'↘':teamsLoading?'…':mapped.length}</strong><span>{!mapRequested?'map loads as you approach':'featured teams mapped'}</span></div>
        <Link className="show-btn primary" to="/teams">Find teams →</Link>
      </div>
      <div className="bhome-map-shell">
        <div className="bhome-map-note"><span>◎</span><div><b>Interactive team map</b><small>Approximate public locations only. Select a marker to open the team profile.</small></div></div>
        {!mapRequested?<div className="map-deferred-placeholder"><span>◎</span><strong>Interactive map deferred</strong><p>The rest of the homepage loads first. Team location data and the map library start only when this section approaches the viewport.</p></div>:teamsLoading?<div className="map-deferred-placeholder loading"><span>◎</span><strong>Loading team locations…</strong><p>Public content above remains usable while the map prepares.</p></div>:teamsError?<StatePanel tone="error" title="Unable to load team locations" text={teamsError} action={<button type="button" className="show-btn" onClick={()=>setTeamsAttempt(n=>n+1)}>Try again</button>}/>:mapped.length?<PublicTeamMap teams={mapped}/>:<StatePanel title="Team locations are still being normalized." text="The team directory remains available without the map."/>}
      </div>
    </section>

    <section className="bhome-org-stage">
      <div className="bhome-section-head">
        <div><span className="eyebrow">FEATURED ORGANIZATIONS</span><h2>Buhurt International and HACSA.</h2></div>
        <p>These are the organizations BuhurtOS is featuring in this release. Featuring is a display choice, not an endorsement or partnership, and every other organization and team stays available under Teams.</p>
      </div>
      {orgs.length?<div className="bhome-org-grid">{featuredOrgs.map(org=><Link key={org.key} to={'/organizations/'+org.key} className="bhome-org-card">
        <div className="bhome-org-mark">{org.shortName.slice(0,4)}</div>
        <div><span>{org.kind}</span><h3>{org.name}</h3><p>{org.description}</p><small>{org.teamCount} teams · {org.countries} countries · {org.rosterCount} public roster records</small></div>
        <b>→</b>
      </Link>)}</div>:orgsLoading?<div className="state-card" role="status">Loading organizations…</div>:orgsError?<StatePanel tone="error" title="Organizations could not be loaded" text={orgsError} action={<button type="button" className="show-btn" onClick={()=>setAttempt(n=>n+1)}>Try again</button>}/>:null}
    </section>

    <section className="bhome-roadmap">
      <div className="bhome-section-head">
        <div><span className="eyebrow">THIS IS THE START, NOT THE FINISH</span><h2>BuhurtOS now, and where it is going.</h2></div>
        <p>The public experience should never pretend unfinished work is complete. These are the pieces already represented in the platform and the direction the architecture is prepared to support.</p>
      </div>
      <div className="bhome-roadmap-grid">
        <article className="now"><div><span>WORKING FOUNDATION</span><h3>The proof platform</h3><p>Public discovery and connected operations foundations using real sport records.</p></div><div className="bhome-cap-list">{currentCapabilities.map(item=><span key={item}><i>✓</i>{item}</span>)}</div></article>
        <article className="next"><div><span>GROWING TOWARD</span><h3>The sport's shared operating system</h3><p>More complete self-service, event automation, historical records and distribution without creating parallel identities.</p></div><div className="bhome-cap-list">{futureCapabilities.map(item=><span key={item}><i>→</i>{item}</span>)}</div></article>
      </div>
    </section>

    <section className="bhome-final-cta">
      <div><span className="eyebrow">YOU KNOW ENOUGH TO START EXPLORING</span><h2>Pick a team. Open an event. Learn the sport.</h2><p>BuhurtOS should make sense before you ever need an account.</p></div>
      <div><Link className="show-btn primary bhome-big-btn" to="/teams">Explore BuhurtOS →</Link><Link className="show-btn secondary bhome-big-btn" to="/sign-in">Sign in / manage</Link></div>
    </section>

    <footer className="bhome-footer-note">
      <span>BuhurtOS</span>
      <p>Public sports records are shown only when backed by BuhurtOS or an identified public source. Private account and organizer data stays outside the public directory.</p>
    </footer>
  </div>;
}