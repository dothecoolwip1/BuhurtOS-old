import {NavLink,Outlet} from 'react-router-dom';

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
    <NavLink className="show-btn secondary" to="/ops/login">Sign in</NavLink>
   </header>
   <div className="show-content"><Outlet/></div>
  </main>
  <nav className="show-bottom-nav">{nav.slice(0,5).map(([to,label,icon])=><NavLink key={to} to={to}><span>{icon}</span><small>{label}</small></NavLink>)}</nav>
 </div>;
}