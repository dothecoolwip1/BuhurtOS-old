import { useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { hasPermission } from '../lib/permissions';
import { signOut } from '../lib/auth';

const eventNav = [
  ['/ops', 'Ops', '⚔'],
  ['/ops/roster', 'Roster', '✓'],
  ['/ops/bracket', 'Bracket', '⌘'],
  ['/ops/standings', 'Standings', '≡'],
  ['/live', 'Public', '◎']
] as const;

const ownerNav = [
  ['/ops/platform', 'Owner', '★'],
  ['/ops/codes', 'Codes', '⌘'],
  ['/ops/setup', 'Events', '⚔'],
  ['/ops/rulesets', 'Rules', '§'],
  ['/public', 'Public', '◎']
] as const;

export function Layout() {
  const navigate = useNavigate();
  const [signingOut, setSigningOut] = useState(false);
  const [logoutError, setLogoutError] = useState('');
  const [menuOpen, setMenuOpen] = useState(false);
  const handleSignOut = async () => {
    setSigningOut(true);
    setLogoutError('');
    try {
      await signOut();
      navigate('/ops/login?reason=signed_out', { replace: true });
    } catch (error) {
      setLogoutError(error instanceof Error ? error.message : 'Unable to sign out. Please try again.');
    } finally { setSigningOut(false); }
  };
  const { event, online, pendingCount, dataMode, syncNow, user } = useAppState();
  const can = (permission: Parameters<typeof hasPermission>[1]) => Boolean(event && hasPermission(user, permission, event.id, event.organizationId));
  const isPlatformSuperAdmin = Boolean(user?.platformRoles.includes('platform_super_admin'));
  const canSetup = Boolean(isPlatformSuperAdmin || user?.organizationRoles.some(role => role.role === 'organization_admin'));
  const nav = isPlatformSuperAdmin ? ownerNav : eventNav;
  return (
    <div className={"app-shell" + (isPlatformSuperAdmin ? " owner-shell" : "")}>
      <aside id="operations-menu" className={"side-rail" + (menuOpen ? " menu-open" : "")} onClick={e => { if ((e.target as HTMLElement).closest("a")) setMenuOpen(false); }}>
        <div className="brand-block"><span className="brand-mark">B</span><div><b>BuhurtOS</b><small>{isPlatformSuperAdmin ? 'Platform Owner Console' : 'Buhurt Tournament Operations'}</small></div></div>
        <nav>{nav.map(([to, label, icon]) => <NavLink key={to} to={to} end={to === '/ops'}><span>{icon}</span>{label}</NavLink>)}</nav>
        <div className="utility-nav">
          {can('event.manage') && <NavLink to={event ? '/ops/manage?event=' + event.id : '/ops/manage'}>Event Command Centre</NavLink>}
          {event && <NavLink to={'/ops/signups?event=' + event.id}>Fighter Signups</NavLink>}
          {can('bracket.manage') && <NavLink to="/ops/admin">Bracket & Access Tools</NavLink>}
          {can('discipline.manage') && <NavLink to="/ops/discipline">Discipline</NavLink>}
          {can('notes.team') && <NavLink to="/ops/notes">Fight Notes</NavLink>}
          <NavLink to="/ops/identity">My Fighter Identity</NavLink>
          {canSetup && <NavLink to="/ops/identity-review">Identity Review</NavLink>}
          {canSetup && <NavLink to="/ops/foundation">Identity & Divisions</NavLink>}
          <NavLink to="/ops/marshal-reference">BI Marshal Reference</NavLink>
          {canSetup && <NavLink to="/ops/rulesets">Rulesets</NavLink>}
          <NavLink to="/ops/sync">Sync Queue</NavLink>
          <NavLink to="/ops/codes">Access Codes</NavLink>
          {isPlatformSuperAdmin && <NavLink to="/ops/platform">Platform Control</NavLink>}
          {isPlatformSuperAdmin && <NavLink to="/ops/access-admin">Accounts & Early Access</NavLink>}
          {canSetup && <NavLink to="/ops/setup">Setup</NavLink>}
          <NavLink to={'/register' + (event ? '?event=' + event.id : '')}>Registration</NavLink>
          <NavLink to="/">Platform Home</NavLink>

        </div>
      </aside>
      <main className="main-shell">
        <header className="topbar">
          <button className="ops-menu-toggle" aria-controls="operations-menu" aria-expanded={menuOpen} onClick={() => setMenuOpen(!menuOpen)}>{menuOpen ? 'Close' : 'Menu'}</button>
          <div className="topbar-title"><strong>{isPlatformSuperAdmin ? 'Owner workspace' : event?.name ?? 'BuhurtOS'}</strong><small>{isPlatformSuperAdmin ? 'BuhurtOS administration' : event?.venue ?? 'No event selected'}</small></div>
          <div className="status-row">
            <span className={'status-pill ' + (online ? 'ok' : 'warn')}>{online ? 'Online' : 'Offline'}</span>
            <span className="status-pill">{dataMode === 'supabase' ? 'Live DB' : 'Demo'}</span>
            {pendingCount > 0 && <button className="status-pill action" onClick={syncNow}>{pendingCount} queued</button>}
            {dataMode === 'supabase' && <button className="logout-button" disabled={signingOut} onClick={handleSignOut}>{signingOut ? 'Signing out…' : 'Sign out'}</button>}
          </div>
        </header>
        {logoutError && <div className="auth-message" role="alert">{logoutError}</div>}
        <div className="page-wrap"><Outlet /></div>
      </main>
      <nav className="bottom-nav">{nav.map(([to, label, icon]) => <NavLink key={to} to={to} end={to === '/ops'}><span>{icon}</span><small>{label}</small></NavLink>)}</nav>
    </div>
  );
}
