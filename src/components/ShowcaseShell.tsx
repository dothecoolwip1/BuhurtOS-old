import {useEffect,useState} from 'react';
import {NavLink,Outlet,useLocation} from 'react-router-dom';

const nav=[
  ['/public','Discover','◎'],
  ['/governance','Organizations','⌘'],
  ['/teams','Teams','♜'],
  ['/fighters','Fighters','♟'],
  ['/events','Events','⚔'],
  ['/rankings','Rankings','↗'],
  ['/rules','Rules','§']
] as const;

export function ShowcaseShell(){
 const location=useLocation();
 const [menuOpen,setMenuOpen]=useState(false);
 const isLanding=location.pathname==='/public';
 useEffect(()=>{setMenuOpen(false)},[location.pathname]);

 if(isLanding){
   const jumpToIntro=()=>{
     setMenuOpen(false);
     document.getElementById('what-is-buhurt')?.scrollIntoView({behavior:'smooth',block:'start'});
   };
   return <div className="landing-shell">
    <header className="landing-nav">
      <NavLink to="/public" className="show-brand landing-brand" onClick={()=>setMenuOpen(false)}>
        <span className="show-brand-mark">B</span>
        <span><b>BuhurtOS</b><small>Explore armored combat</small></span>
      </NavLink>
      <nav className="landing-nav-links" aria-label="Public navigation">
        <button type="button" onClick={jumpToIntro}>What is Buhurt?</button>
        <NavLink to="/teams">Teams</NavLink>
        <NavLink to="/fighters">Fighters</NavLink>
        <NavLink to="/events">Events</NavLink>
        <NavLink to="/rankings">Rankings</NavLink>
        <NavLink to="/rules">Rules</NavLink>
      </nav>
      <div className="landing-nav-actions">
        <NavLink className="show-btn secondary" to="/ops/login">Sign in</NavLink>
        <NavLink className="show-btn primary" to="/teams">Explore</NavLink>
      </div>
      <button className={'landing-menu-toggle '+(menuOpen?'open':'')} type="button" aria-label="Toggle navigation" aria-expanded={menuOpen} onClick={()=>setMenuOpen(value=>!value)}>
        <span/><span/><span/>
      </button>
    </header>
    {menuOpen?<div className="landing-mobile-menu">
      <button type="button" onClick={jumpToIntro}>New here? Start with “What is Buhurt?”</button>
      {nav.slice(1).map(([to,label,icon])=><NavLink key={to} to={to} onClick={()=>setMenuOpen(false)}><span>{icon}</span><b>{label}</b><i>→</i></NavLink>)}
      <NavLink className="show-btn primary full" to="/ops/login" onClick={()=>setMenuOpen(false)}>Sign in / manage</NavLink>
    </div>:null}
    <main className="landing-main"><Outlet/></main>
   </div>;
 }

 return <div className="show-shell">
  <aside className="show-sidebar">
   <NavLink to="/public" className="show-brand"><span className="show-brand-mark">B</span><span><b>BuhurtOS</b><small>Explore the sport</small></span></NavLink>
   <div className="show-context"><span>PUBLIC VIEW</span><strong>Read-only sport directory</strong><small>Teams · fighters · events · rules</small></div>
   <nav className="show-nav">{nav.map(([to,label,icon])=><NavLink key={to} to={to}><span>{icon}</span><b>{label}</b></NavLink>)}</nav>
   <div className="show-side-bottom"><NavLink className="show-btn primary full" to="/ops/login">Sign in / manage</NavLink><small>Public records are source-backed. Private account data is never shown here.</small></div>
  </aside>
  <main className="show-main">
   <header className="show-topbar">
    <div className="show-mobile-brand"><span className="show-brand-mark">B</span><b>BuhurtOS Public</b></div>
    <div className="show-top-context"><span className="status-chip">PUBLIC</span><span>Explore Buhurt from federation to fighter</span></div>
    <div className="show-topbar-actions">
      <NavLink className="show-btn secondary show-top-signin" to="/ops/login">Sign in</NavLink>
      <button className={'landing-menu-toggle show-mobile-menu-toggle '+(menuOpen?'open':'')} type="button" aria-label="Open all public navigation" aria-expanded={menuOpen} onClick={()=>setMenuOpen(value=>!value)}>
        <span/><span/><span/>
      </button>
    </div>
   </header>
   {menuOpen?<div className="landing-mobile-menu show-public-mobile-menu" aria-label="All public sections">
      {nav.map(([to,label,icon])=><NavLink key={to} to={to} onClick={()=>setMenuOpen(false)}><span>{icon}</span><b>{label}</b><i>→</i></NavLink>)}
      <NavLink className="show-btn primary full" to="/ops/login" onClick={()=>setMenuOpen(false)}>Sign in / manage</NavLink>
    </div>:null}
   <div className="show-content"><Outlet/></div>
  </main>
  <nav className="show-bottom-nav">{nav.slice(0,5).map(([to,label,icon])=><NavLink key={to} to={to}><span>{icon}</span><small>{label}</small></NavLink>)}</nav>
 </div>;
}