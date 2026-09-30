import {useEffect,useMemo,useState} from 'react';
import {Link} from 'react-router-dom';
import {PublicTeamMap} from '../components/PublicTeamMap';
import {Pill} from '../components/ShowcaseUI';
import {loadPublicOrganizations,loadPublicEvents,type PublicOrganizationSummary,type PublicEventSummary} from '../lib/publicDirectory';
import {loadPublicTeamMap,type PublicDirectoryTeam} from '../lib/teamDirectory';

type RoleKey='spectator'|'fighter'|'team'|'organizer'|'organization';
type FlowKey='discover'|'prepare'|'event'|'history';

const roleContent:Record<RoleKey,{label:string;kicker:string;title:string;copy:string;items:string[];cta:string;to:string}>={
  spectator:{
    label:'Spectators',
    kicker:'UNDERSTAND THE SPORT',
    title:'Follow Buhurt without needing a rulebook open beside you.',
    copy:'Find teams, learn formats, open fighter profiles, follow real events and understand how the sport connects from federation to fighter.',
    items:['Public team and fighter discovery','Event schedules, brackets and results as they are published','Rules and competition format reference'],
    cta:'Explore the public sport',
    to:'/teams'
  },
  fighter:{
    label:'Fighters',
    kicker:'ONE SPORTING IDENTITY',
    title:'A career should follow the fighter, not the spreadsheet.',
    copy:'BuhurtOS is designed around one long-term fighter identity that can connect teams, events, results, rankings and achievements over time.',
    items:['Permanent public sporting profile','Team associations without losing history','Future claim and self-service workflows'],
    cta:'Browse fighters',
    to:'/fighters'
  },
  team:{
    label:'Teams',
    kicker:'TEAM OPERATIONS',
    title:'Give every team a real home inside the sport.',
    copy:'Team pages bring together roster, location, source-backed rankings, events and public discovery, with management tools growing behind the same record.',
    items:['Searchable public team profile and map presence','Roster and event connections','Future delegated team management without duplicate records'],
    cta:'Find a team',
    to:'/teams'
  },
  organizer:{
    label:'Organizers',
    kicker:'EVENT OPERATIONS',
    title:'Plan the event once, then let the same data power event day.',
    copy:'The operating side is being built for registration, check-in, fight cards, fields, brackets, scoring, announcements and public event output.',
    items:['Tournament and non-tournament event models','Role-based event operations','Offline-aware workflows for real venues'],
    cta:'Explore events',
    to:'/events'
  },
  organization:{
    label:'Organizations',
    kicker:'CONNECTED GOVERNANCE',
    title:'Represent the sport hierarchy without rebuilding it in every tool.',
    copy:'Federations, national bodies, regional organizations and teams can be connected in one hierarchy while keeping public records and private administration separate.',
    items:['Connected organization hierarchy','Scoped memberships and permissions','Rulesets, events and future delegated management'],
    cta:'Explore organizations',
    to:'/governance'
  }
};

const flowContent:Record<FlowKey,{label:string;eyebrow:string;title:string;copy:string;steps:Array<[string,string]>;to:string;cta:string}>={
  discover:{
    label:'Discover',
    eyebrow:'PUBLIC DISCOVERY',
    title:'Start anywhere. Keep drilling down.',
    copy:'A newcomer should be able to find a team, see who governs it, open its roster, discover nearby events and learn the rules without knowing where to look first.',
    steps:[['01','Find an organization or team'],['02','Open fighters and public history'],['03','See upcoming events'],['04','Learn the rules behind the format']],
    to:'/teams',
    cta:'Open team directory'
  },
  prepare:{
    label:'Before the event',
    eyebrow:'PRE-EVENT',
    title:'Turn planning into structured event data.',
    copy:'BuhurtOS is growing toward one preparation flow for published event details, registration, rosters, clearances, divisions, fields, schedules and organizer access.',
    steps:[['01','Publish the real event'],['02','Collect registrations'],['03','Prepare rosters and divisions'],['04','Build the operational fight plan']],
    to:'/events',
    cta:'Browse events'
  },
  event:{
    label:'Event day',
    eyebrow:'FIELD OPERATIONS',
    title:'One result should travel everywhere it needs to go.',
    copy:'The event operations model is designed so organizers and officials work from the same event record while the public sees only the information intended for them.',
    steps:[['01','Check in and clear fighters'],['02','Run fields and fight queues'],['03','Finalize real results'],['04','Publish the right public output']],
    to:'/ops/login',
    cta:'Open management sign in'
  },
  history:{
    label:'After the event',
    eyebrow:'LONG-TERM RECORD',
    title:'Do not let the sport reset after every tournament.',
    copy:'Finalized event data can become durable history for fighters, teams, rankings and organizations instead of disappearing into a spreadsheet or social post.',
    steps:[['01','Preserve finalized results'],['02','Connect fighter and team history'],['03','Support rankings and standings'],['04','Keep the source and ruleset context']],
    to:'/rankings',
    cta:'Explore rankings'
  }
};

const exploreCards=[
  {icon:'⌘',title:'Organizations',copy:'See how federations, national bodies, regional organizations and teams connect.',to:'/governance'},
  {icon:'♜',title:'Teams',copy:'Search real public team records, open profiles and explore the map.',to:'/teams'},
  {icon:'♟',title:'Fighters',copy:'Browse public fighter identities and the sporting records connected to them.',to:'/fighters'},
  {icon:'⚔',title:'Events',copy:'Find tournaments, demos, training, gatherings and other published events.',to:'/events'},
  {icon:'↗',title:'Rankings',copy:'See competitive standings only when real source data supports them.',to:'/rankings'},
  {icon:'§',title:'Rules',copy:'Use a readable reference for rulesets, formats and competition categories.',to:'/rules'}
] as const;

const currentCapabilities=[
  'Public organization hierarchy',
  'Global team directory and map',
  'Public fighter identities',
  'Published event pages',
  'Rules and rankings discovery',
  'Role-based management access',
  'Event operations foundation',
  'Fighter signup and delegated access foundations'
];

const futureCapabilities=[
  'Richer permanent fighter careers',
  'Team and organization claiming',
  'Broader event categories and calendars',
  'Embedded standings, teams and event widgets',
  'Deeper source-backed rankings and statistics',
  'More complete tournament-day automation',
  'Expanded historical records and season views',
  'Distribution tools for clubs and governing bodies'
];

function formatEventDate(value:string){
  const date=new Date(value);
  return Number.isNaN(date.getTime())?'Date TBA':date.toLocaleDateString(undefined,{month:'short',day:'numeric',year:'numeric'});
}

export function ShowcasePublicPage(){
  const [teams,setTeams]=useState<PublicDirectoryTeam[]>([]);
  const [orgs,setOrgs]=useState<PublicOrganizationSummary[]>([]);
  const [events,setEvents]=useState<PublicEventSummary[]>([]);
  const [loading,setLoading]=useState(true);
  const [teamsLoading,setTeamsLoading]=useState(true);
  const [error,setError]=useState('');
  const [teamsError,setTeamsError]=useState('');
  const [role,setRole]=useState<RoleKey>('spectator');
  const [flow,setFlow]=useState<FlowKey>('discover');

  useEffect(()=>{
    let active=true;
    Promise.all([loadPublicOrganizations(),loadPublicEvents()])
      .then(([o,e])=>{if(active){setOrgs(o);setEvents(e)}})
      .catch(err=>{if(active)setError(err instanceof Error?err.message:'Unable to load public organizations and events.')})
      .finally(()=>{if(active)setLoading(false)});
    loadPublicTeamMap()
      .then(t=>{if(active)setTeams(t)})
      .catch(err=>{if(active)setTeamsError(err instanceof Error?err.message:'Unable to load team locations.')})
      .finally(()=>{if(active)setTeamsLoading(false)});
    return()=>{active=false};
  },[]);

  const mapped=useMemo(()=>teams.filter(t=>t.latitude!=null&&t.longitude!=null),[teams]);
  const countries=useMemo(()=>new Set(teams.map(t=>t.countryCode||t.countryName).filter(Boolean)).size,[teams]);
  const upcoming=useMemo(()=>events.filter(e=>new Date(e.endsAt).getTime()>=Date.now()).slice(0,4),[events]);
  const rosterSourceCount=useMemo(()=>orgs.reduce((sum,o)=>sum+o.rosterCount,0),[orgs]);
  const activeRole=roleContent[role];
  const activeFlow=flowContent[flow];
  const spotlightEvent=upcoming[0];

  return <div className="bhome">
    <section className="bhome-hero">
      <div className="bhome-hero-copy">
        <span className="bhome-kicker"><i/> THE CONNECTED PLATFORM FOR ARMORED COMBAT</span>
        <h1>Everything Buhurt.<br/><em>One platform.</em></h1>
        <p className="bhome-lead">BuhurtOS is being built to connect the entire sport: governing organizations, teams, fighters, events, tournament operations, rankings, rules and public discovery.</p>
        <div className="bhome-hero-actions">
          <Link className="show-btn primary bhome-big-btn" to="/teams">Explore the sport <span>→</span></Link>
          <Link className="show-btn secondary bhome-big-btn" to="/about">What are we building?</Link>
        </div>
        <div className="bhome-trust-row">
          <span><b>PUBLIC FIRST</b><small>Useful without an account</small></span>
          <span><b>REAL DATA</b><small>No invented sports records</small></span>
          <span><b>ONE SYSTEM</b><small>Public + operations connected</small></span>
        </div>
      </div>

      <div className="bhome-command">
        <div className="bhome-command-top">
          <div><i/><span>BUHURTOS NETWORK</span></div>
          <small>{loading||teamsLoading?'SYNCING PUBLIC DATA':'PUBLIC DATA CONNECTED'}</small>
        </div>
        <div className="bhome-command-title">
          <span>SPORT SNAPSHOT</span>
          <strong>One connected view of Buhurt</strong>
          <p>Live counts below come from the public records currently available to BuhurtOS.</p>
        </div>
        <div className="bhome-command-stats">
          <Link to="/teams"><strong>{teamsLoading?'…':teams.length}</strong><span>Teams</span></Link>
          <Link to="/governance"><strong>{loading?'…':orgs.length}</strong><span>Organizations</span></Link>
          <Link to="/teams"><strong>{teamsLoading?'…':countries}</strong><span>Countries</span></Link>
          <Link to="/events"><strong>{loading?'…':events.length}</strong><span>Published events</span></Link>
        </div>
        <div className="bhome-command-divider"/>
        {spotlightEvent?
          <Link className="bhome-event-spotlight" to={'/events/'+spotlightEvent.id}>
            <div><span>NEXT PUBLISHED EVENT</span><strong>{spotlightEvent.name}</strong><small>{formatEventDate(spotlightEvent.startsAt)} · {spotlightEvent.venue||'Venue TBA'}</small></div>
            <b>→</b>
          </Link>
          :<div className="bhome-event-spotlight empty"><div><span>EVENT NETWORK</span><strong>No future published event yet</strong><small>When a real event is published, it will appear here automatically.</small></div></div>}
        <div className="bhome-command-links">
          <Link to="/teams">Team map <span>↗</span></Link>
          <Link to="/events">Event calendar <span>↗</span></Link>
          <Link to="/rules">Rules reference <span>↗</span></Link>
        </div>
      </div>
    </section>

    <section className="bhome-ecosystem" aria-label="BuhurtOS ecosystem">
      <Link to="/governance"><small>GOVERNANCE</small><b>International + national organizations</b><span>⌘</span></Link>
      <i>→</i>
      <Link to="/teams"><small>TEAMS</small><b>Clubs and fight teams</b><span>♜</span></Link>
      <i>→</i>
      <Link to="/fighters"><small>FIGHTERS</small><b>Permanent sporting identities</b><span>♟</span></Link>
      <i>→</i>
      <Link to="/events"><small>EVENTS</small><b>The sport in motion</b><span>⚔</span></Link>
    </section>

    <section className="bhome-section bhome-intro">
      <div className="bhome-section-head">
        <div>
          <span className="eyebrow">WHAT IS BUHURTOS?</span>
          <h2>The operating layer the sport has been missing.</h2>
        </div>
        <p>BuhurtOS is not meant to be only a bracket app, team directory or scoring screen. The goal is one shared platform that can carry the same trusted information from discovery, through event operations, into long-term sporting history.</p>
      </div>
      <div className="bhome-pillars">
        <article><span>01</span><h3>Discover</h3><p>Find organizations, teams, fighters, events, rankings and rules from one public front door.</p><Link to="/teams">Start exploring →</Link></article>
        <article><span>02</span><h3>Organize</h3><p>Give teams and organizations structured records, scoped access and a place to manage the real work behind the sport.</p><Link to="/governance">See the structure →</Link></article>
        <article><span>03</span><h3>Operate</h3><p>Support real event-day workflows including registration, fields, fight cards, scoring, announcements and public output.</p><Link to="/events">Open events →</Link></article>
        <article><span>04</span><h3>Remember</h3><p>Turn finalized competition data into durable fighter, team, event and ranking history instead of disposable files.</p><Link to="/rankings">View rankings →</Link></article>
      </div>
    </section>

    <section className="bhome-dark-band">
      <div className="bhome-section-head compact">
        <div><span className="eyebrow">BUILT FOR EVERY SIDE OF THE SPORT</span><h2>Pick your view.</h2></div>
        <p>Each role needs different tools, but they should all work from the same underlying sport records.</p>
      </div>
      <div className="bhome-role-layout">
        <div className="bhome-role-tabs" role="tablist" aria-label="BuhurtOS roles">
          {(Object.keys(roleContent) as RoleKey[]).map(key=><button key={key} type="button" role="tab" aria-selected={role===key} className={role===key?'active':''} onClick={()=>setRole(key)}><span>{roleContent[key].label}</span><b>→</b></button>)}
        </div>
        <div className="bhome-role-panel">
          <span className="eyebrow">{activeRole.kicker}</span>
          <h3>{activeRole.title}</h3>
          <p>{activeRole.copy}</p>
          <div className="bhome-check-list">{activeRole.items.map(item=><span key={item}><i>✓</i>{item}</span>)}</div>
          <Link className="show-btn primary" to={activeRole.to}>{activeRole.cta} →</Link>
        </div>
        <div className="bhome-role-visual" aria-hidden="true">
          <div className="bhome-visual-window">
            <div className="bhome-visual-bar"><i/><i/><i/><span>{activeRole.label}</span></div>
            <div className="bhome-visual-body">
              <small>{activeRole.kicker}</small>
              <strong>{activeRole.title}</strong>
              {activeRole.items.map((item,index)=><div key={item}><span>{String(index+1).padStart(2,'0')}</span><b>{item}</b></div>)}
            </div>
          </div>
        </div>
      </div>
    </section>

    <section className="bhome-section">
      <div className="bhome-section-head">
        <div><span className="eyebrow">HOW THE PLATFORM CONNECTS</span><h2>Before, during and long after the fight.</h2></div>
        <p>Explore the intended flow. The public platform and operational tools are being built as different views of the same connected records.</p>
      </div>
      <div className="bhome-flow-tabs" role="tablist" aria-label="BuhurtOS workflow stages">
        {(Object.keys(flowContent) as FlowKey[]).map(key=><button type="button" role="tab" aria-selected={flow===key} className={flow===key?'active':''} onClick={()=>setFlow(key)} key={key}>{flowContent[key].label}</button>)}
      </div>
      <div className="bhome-flow-panel">
        <div className="bhome-flow-copy">
          <span className="eyebrow">{activeFlow.eyebrow}</span>
          <h3>{activeFlow.title}</h3>
          <p>{activeFlow.copy}</p>
          <Link to={activeFlow.to}>{activeFlow.cta} →</Link>
        </div>
        <div className="bhome-flow-steps">{activeFlow.steps.map(([number,text],index)=><div key={number}><span>{number}</span><b>{text}</b>{index<activeFlow.steps.length-1?<i>→</i>:null}</div>)}</div>
      </div>
    </section>

    <section className="bhome-section bhome-explore">
      <div className="bhome-section-head">
        <div><span className="eyebrow">EXPLORE THE SPORT</span><h2>Six ways into the same ecosystem.</h2></div>
        <p>You do not need an account to start. The public side is designed to be useful to fighters, fans, teams and newcomers immediately.</p>
      </div>
      <div className="bhome-explore-grid">{exploreCards.map(card=><Link to={card.to} className="bhome-explore-card" key={card.title}><span>{card.icon}</span><div><h3>{card.title}</h3><p>{card.copy}</p></div><b>↗</b></Link>)}</div>
    </section>

    <section className="bhome-section bhome-map-section">
      <div className="bhome-section-head">
        <div><span className="eyebrow">GLOBAL TEAM DISCOVERY</span><h2>The sport should be visible on a map.</h2></div>
        <div className="bhome-map-meta"><strong>{teamsLoading?'…':mapped.length}</strong><span>mapped teams</span><Link to="/teams">Open full directory →</Link></div>
      </div>
      <div className="bhome-map-shell">
        <div className="bhome-map-note"><span>◎</span><div><b>Interactive team map</b><small>Approximate public team locations only. Select a marker to open the team profile.</small></div></div>
        {teamsLoading?<div className="state-card">Loading team locations…</div>:teamsError?<div className="state-card"><strong>Unable to load team locations</strong><p>{teamsError}</p></div>:mapped.length?<PublicTeamMap teams={mapped}/>:<div className="state-card">Team locations are still being normalized.</div>}
      </div>
    </section>

    <section className="bhome-section">
      <div className="bhome-section-head">
        <div><span className="eyebrow">WHAT'S HAPPENING NEXT?</span><h2>Real published events.</h2></div>
        <Link className="bhome-inline-link" to="/events">Open all events →</Link>
      </div>
      {error?<div className="state-card"><strong>Unable to load public directory data</strong><p>{error}</p></div>:null}
      {upcoming.length?<div className="bhome-events-grid">{upcoming.map(event=><Link to={'/events/'+event.id} key={event.id} className="bhome-event-card">
        <div className="bhome-event-date"><span>{formatEventDate(event.startsAt).split(' ')[0]}</span><strong>{new Date(event.startsAt).getDate()}</strong><small>{new Date(event.startsAt).getFullYear()}</small></div>
        <div className="bhome-event-content"><div><Pill tone={event.status==='live'?'red':'green'}>{event.status}</Pill><span>{event.eventType.replaceAll('_',' ')}</span></div><h3>{event.name}</h3><p>{event.venue||'Venue TBA'}{event.organizerName?' · '+event.organizerName:''}</p><b>Open event →</b></div>
      </Link>)}</div>:!loading?<div className="bhome-empty"><span>⚔</span><div><strong>No future published events yet.</strong><p>Draft and private events stay private. The moment a real event is published, it can appear here.</p></div><Link to="/events">View event directory →</Link></div>:<div className="state-card">Loading published events…</div>}
    </section>

    <section className="bhome-section">
      <div className="bhome-section-head">
        <div><span className="eyebrow">THE SPORT'S STRUCTURE</span><h2>Organizations are part of the map too.</h2></div>
        <Link className="bhome-inline-link" to="/governance">View organization hierarchy →</Link>
      </div>
      {orgs.length?<div className="bhome-org-grid">{orgs.slice(0,6).map(org=><Link key={org.key} to={'/organizations/'+org.key} className="bhome-org-card">
        <div className="bhome-org-mark">{org.shortName.slice(0,4)}</div>
        <div><span>{org.kind}</span><h3>{org.name}</h3><p>{org.description}</p><small>{org.teamCount} teams · {org.countries} countries · {org.rosterCount} public roster records</small></div>
        <b>→</b>
      </Link>)}</div>:loading?<div className="state-card">Loading organizations…</div>:null}
    </section>

    <section className="bhome-section bhome-roadmap">
      <div className="bhome-section-head">
        <div><span className="eyebrow">BUHURTOS NOW + NEXT</span><h2>A real platform being built in layers.</h2></div>
        <p>The public site should be clear about what exists today and what the architecture is being prepared to support next.</p>
      </div>
      <div className="bhome-roadmap-grid">
        <article className="now"><div><span>NOW</span><h3>The proof platform</h3><p>Working public discovery and connected operations foundations using real sport records.</p></div><div className="bhome-cap-list">{currentCapabilities.map(item=><span key={item}><i>✓</i>{item}</span>)}</div></article>
        <article className="next"><div><span>GROWING TOWARD</span><h3>The sport's shared operating system</h3><p>More complete self-service, tournament automation, historical records and distribution without creating parallel identities.</p></div><div className="bhome-cap-list">{futureCapabilities.map(item=><span key={item}><i>→</i>{item}</span>)}</div></article>
      </div>
    </section>

    <section className="bhome-final-cta">
      <div><span className="eyebrow">START WITH THE PUBLIC SIDE</span><h2>See the sport as one connected system.</h2><p>Browse what is already public, then sign in when you need the management side.</p></div>
      <div><Link className="show-btn primary bhome-big-btn" to="/teams">Explore BuhurtOS →</Link><Link className="show-btn secondary bhome-big-btn" to="/ops/login">Sign in / manage</Link></div>
    </section>

    <footer className="bhome-footer-note">
      <span>BuhurtOS</span>
      <p>Public records are shown only when backed by BuhurtOS or an identified public source. Private account and organizer data stays outside the public directory.</p>
    </footer>
  </div>;
}
