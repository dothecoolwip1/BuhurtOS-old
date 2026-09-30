import { useEffect, useRef, useState } from 'react';
import { Link, NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { hasAdminArea, publicBottom, publicPrimary, publicSecondary } from '../lib/navigation';
import { AccountMenu, SkipLink } from './chrome';

/** The public site: explains the sport and lets anyone discover teams, events, fighters, rankings and rules. */
export function ShowcaseShell() {
  const location = useLocation();
  const { status, user } = useAccount();
  const [menuOpen, setMenuOpen] = useState(false);
  const toggle = useRef<HTMLButtonElement>(null);
  const sheet = useRef<HTMLDivElement>(null);
  const isLanding = location.pathname === '/public';
  const signedIn = status === 'signedIn' || status === 'demo';

  useEffect(() => { setMenuOpen(false); }, [location.pathname]);
  useEffect(() => {
    if (!menuOpen) return;
    document.documentElement.classList.add('nx-locked');
    sheet.current?.querySelector<HTMLElement>('a,button')?.focus();
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape') setMenuOpen(false); };
    document.addEventListener('keydown', onKey);
    const opener = toggle.current;
    return () => { document.documentElement.classList.remove('nx-locked'); document.removeEventListener('keydown', onKey); opener?.focus(); };
  }, [menuOpen]);

  const jumpToIntro = () => {
    setMenuOpen(false);
    document.getElementById('what-is-buhurt')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  const menu = menuOpen ? <div className="nx-overlay" onClick={() => setMenuOpen(false)}>
    <div id="nx-sheet" ref={sheet} className="nx-sheet" role="dialog" aria-modal="true" aria-label="Public site menu" onClick={event => event.stopPropagation()}>
      <div className="nx-sheet-head"><strong>Menu</strong><button type="button" className="nx-close" aria-label="Close menu" onClick={() => setMenuOpen(false)}>✕</button></div>
      <div className="nx-sheet-nav">
        <div className="nx-group">
          {isLanding ? <button type="button" className="nx-link" onClick={jumpToIntro}>New here? What is buhurt?</button> : null}
          {publicPrimary.map(item => <NavLink key={item.to} to={item.to} className={({ isActive }) => 'nx-link' + (isActive ? ' active' : '')}>{item.label}</NavLink>)}
        </div>
        <div className="nx-group">
          <h2 className="nx-group-title">For organizers and websites</h2>
          {publicSecondary.map(item => <NavLink key={item.to} to={item.to} className={({ isActive }) => 'nx-link' + (isActive ? ' active' : '')}>{item.label}</NavLink>)}
        </div>
        <div className="nx-group">
          <h2 className="nx-group-title">{signedIn ? 'Your account' : 'Account'}</h2>
          {signedIn ? <>
            <Link className="nx-link" to="/me">My workspace</Link>
            {hasAdminArea(user) ? <Link className="nx-link" to="/admin">Administration</Link> : null}
          </> : <Link className="nx-link" to="/sign-in">Sign in</Link>}
        </div>
      </div>
    </div>
  </div> : null;

  const menuButton = (
    <button ref={toggle} type="button" className="nx-menu-button" aria-label="Open menu" aria-expanded={menuOpen} aria-controls="nx-sheet" onClick={() => setMenuOpen(true)}>
      <span aria-hidden="true">☰</span>
    </button>
  );

  if (isLanding) {
    return <div className="landing-shell">
      <SkipLink />
      <header className="landing-nav">
        <NavLink to="/public" className="show-brand landing-brand">
          <span className="show-brand-mark">B</span>
          <span><b>BuhurtOS</b><small>Explore armored combat</small></span>
        </NavLink>
        <nav className="landing-nav-links" aria-label="Public navigation">
          <button type="button" onClick={jumpToIntro}>What is buhurt?</button>
          {publicPrimary.filter(item => item.to !== '/public' && item.to !== '/governance').map(item => <NavLink key={item.to} to={item.to}>{item.label}</NavLink>)}
        </nav>
        <div className="landing-nav-actions"><AccountMenu current="public" /></div>
        <span className="landing-menu-wrap">{menuButton}</span>
      </header>
      {menu}
      <main className="landing-main" id="main-content" tabIndex={-1}><Outlet /></main>
    </div>;
  }

  return <div className="show-shell">
    <SkipLink />
    <aside className="show-sidebar" aria-label="Public site menu">
      <NavLink to="/public" className="show-brand"><span className="show-brand-mark">B</span><span><b>BuhurtOS</b><small>Public site</small></span></NavLink>
      <nav className="show-nav" aria-label="Public navigation">{publicPrimary.map(item => <NavLink key={item.to} to={item.to}><span aria-hidden="true">{item.icon}</span><b>{item.label}</b></NavLink>)}</nav>
      <div className="show-side-bottom">
        {publicSecondary.map(item => <NavLink key={item.to} className="show-side-extra" to={item.to}>{item.label}</NavLink>)}
        <small>Everything here is public and read-only. Private account data is never shown.</small>
      </div>
    </aside>
    <main className="show-main" id="main-content" tabIndex={-1}>
      <header className="show-topbar">
        {menuButton}
        <NavLink to="/public" className="show-mobile-brand"><span className="show-brand-mark">B</span><b>BuhurtOS</b></NavLink>
        <div className="show-top-context"><span>Explore buhurt from federation to fighter</span></div>
        <div className="show-topbar-actions"><AccountMenu current="public" /></div>
      </header>
      {menu}
      <div className="show-content"><Outlet /></div>
    </main>
    <nav className="show-bottom-nav" aria-label="Main">
      {publicBottom.map(item => <NavLink key={item.to} to={item.to}><span aria-hidden="true">{item.icon}</span><small>{item.label}</small></NavLink>)}
      <button type="button" aria-label="Open menu" aria-expanded={menuOpen} aria-controls="nx-sheet" onClick={() => setMenuOpen(true)}><span aria-hidden="true">☰</span><small>More</small></button>
    </nav>
  </div>;
}
