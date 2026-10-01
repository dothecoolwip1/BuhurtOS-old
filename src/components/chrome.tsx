import { useEffect, useRef, useState, type ReactNode } from 'react';
import { Link, NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { recallListPath } from '../lib/urlState';
import { countMyUnreadNotifications } from '../lib/registrationAccess';
import { areaHome, areaLabel, breadcrumbsFor, hasAdminArea, type Area, type Crumb, type NavSection } from '../lib/navigation';
import { friendlyError } from '../lib/friendlyError';

export function initialsOf(name: string | undefined): string {
  const parts = (name ?? '').replace(/@.*$/, '').split(/[\s._-]+/).filter(Boolean);
  return (parts[0]?.[0] ?? '?').toUpperCase() + (parts[1]?.[0]?.toUpperCase() ?? '');
}

/** Moves between the three areas. Workspace and Administration appear only when they apply to the person. */
export function AreaSwitcher({ current, onNavigate }: { current: Area; onNavigate?: () => void }) {
  const { user, status } = useAccount();
  const signedIn = status === 'signedIn' || status === 'demo';
  const areas: Area[] = ['public', ...(signedIn ? (['workspace'] as Area[]) : []), ...(signedIn && hasAdminArea(user) ? (['admin'] as Area[]) : [])];
  return <nav className="nx-areas" aria-label="Areas of BuhurtOS">
    {areas.map(area => <NavLink key={area} to={areaHome[area]} end={area === 'public' ? false : undefined}
      className={() => 'nx-area' + (current === area ? ' active' : '')} aria-current={current === area ? 'page' : undefined} onClick={onNavigate}>{areaLabel[area]}</NavLink>)}
  </nav>;
}

/** Bell with an unread count; links to the notifications page. Counts refresh on navigation, every minute and when notifications change. */
export function NotificationBell() {
  const [count, setCount] = useState(0);
  const location = useLocation();
  useEffect(() => {
    let active = true;
    const refresh = () => { countMyUnreadNotifications().then(n => { if (active) setCount(n); }).catch(() => { /* a failed count never blocks navigation */ }); };
    refresh();
    const timer = window.setInterval(refresh, 60000);
    window.addEventListener('buhurtos:notifications-changed', refresh);
    return () => { active = false; window.clearInterval(timer); window.removeEventListener('buhurtos:notifications-changed', refresh); };
  }, [location.pathname]);
  return <Link to="/me/notifications" className="nx-bell" aria-label={count > 0 ? 'Notifications, ' + count + ' unread' : 'Notifications'}><span aria-hidden="true">🔔</span>{count > 0 ? <span className="nx-bell-badge" aria-hidden="true">{count > 99 ? '99+' : count}</span> : null}</Link>;
}

/** Signed-in identity, area links and sign out. Always reachable, on every screen size. */
export function AccountMenu({ current }: { current: Area }) {
  const { status, user, email, signOut, signingOut, contextError } = useAccount();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [error, setError] = useState('');
  const box = useRef<HTMLDivElement>(null);

  useEffect(() => { setOpen(false); }, [location.pathname]);
  useEffect(() => {
    if (!open) return;
    const onDown = (event: MouseEvent) => { if (box.current && !box.current.contains(event.target as Node)) setOpen(false); };
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape') setOpen(false); };
    document.addEventListener('mousedown', onDown);
    document.addEventListener('keydown', onKey);
    return () => { document.removeEventListener('mousedown', onDown); document.removeEventListener('keydown', onKey); };
  }, [open]);

  if (status === 'loading') return <span className="nx-account-loading" role="status" aria-label="Checking your account" />;
  if (status === 'anonymous') {
    const next = encodeURIComponent(location.pathname + location.search);
    return <Link className="nx-signin" to={`/sign-in?next=${next}`}>Sign in</Link>;
  }

  const name = user?.displayName ?? email ?? 'Your account';
  const handleSignOut = async () => {
    setError('');
    try { await signOut(); navigate('/sign-in?reason=signed_out', { replace: true }); }
    catch (err) { setError(friendlyError(err).message); }
  };

  return <>{status === 'signedIn' ? <NotificationBell /> : null}<div className="nx-account" ref={box}>
    <button type="button" className="nx-account-button" aria-expanded={open} aria-haspopup="true" onClick={() => setOpen(value => !value)}>
      <span className="nx-avatar" aria-hidden="true">{initialsOf(name)}</span>
      <span className="nx-account-name">{name}</span>
      <span aria-hidden="true">▾</span>
    </button>
    {open ? <div className="nx-account-panel" role="group" aria-label="Account">
      <div className="nx-account-id"><strong>{name}</strong>{email && email !== name ? <small>{email}</small> : null}{status === 'demo' ? <small>Demo mode: sample data, nothing is saved to the live backend.</small> : null}</div>
      {contextError ? <p className="nx-inline-error" role="alert">Your roles could not be loaded: {contextError}</p> : null}
      <Link to="/me" className={current === 'workspace' ? 'current' : ''}>My workspace</Link>
      {hasAdminArea(user) ? <Link to="/admin" className={current === 'admin' ? 'current' : ''}>Administration</Link> : null}
      <Link to="/public" className={current === 'public' ? 'current' : ''}>Public site</Link>
      {status === 'signedIn' ? <button type="button" className="nx-signout" disabled={signingOut} onClick={handleSignOut}>{signingOut ? 'Signing out…' : 'Sign out'}</button> : null}
      {error ? <p className="nx-inline-error" role="alert">{error}</p> : null}
    </div> : null}
  </div></>;
}

export function Breadcrumbs({ crumbs }: { crumbs: Crumb[] }) {
  if (crumbs.length <= 1) return null;
  return <nav className="nx-crumbs" aria-label="Breadcrumb"><ol>
    {crumbs.map((crumb, index) => <li key={crumb.label + index} aria-current={index === crumbs.length - 1 ? 'page' : undefined}>
      {crumb.to && index < crumbs.length - 1 ? <Link to={crumb.to}>{crumb.label}</Link> : <span>{crumb.label}</span>}
    </li>)}
  </ol></nav>;
}

/** States, in words, what the current screen acts on. */
export function ScopeBar({ kind, label, detail, tone = 'neutral' }: { kind: string; label: string; detail?: string; tone?: 'neutral' | 'warn' }) {
  return <div className={'nx-scope ' + tone} role="note"><span className="nx-scope-kind">{kind}</span><strong>{label}</strong>{detail ? <small>{detail}</small> : null}</div>;
}

export interface BottomItem { to: string; label: string; icon: string; end?: boolean }

interface ShellProps {
  area: Area;
  brandSub: string;
  sections: NavSection[];
  bottom: BottomItem[];
  /** Status chips beside the account menu (online, sync queue, data mode). */
  status?: ReactNode;
  /** Explicit scope line and workflow steps rendered above the page. */
  header?: ReactNode;
  /** When set, shown instead of the page (for example while the chosen event is unavailable). */
  blocked?: ReactNode;
}

function ItemLink({ to, label, end, onClick, description }: { to: string; label: string; end?: boolean; onClick?: () => void; description?: string }) {
  return <NavLink to={to} end={end} onClick={onClick} className={({ isActive }) => 'nx-link' + (isActive ? ' active' : '')} title={description}>{label}</NavLink>;
}

/** First tab stop: jumps past the menus. A button, because a #hash link would change the HashRouter route. */
export function SkipLink() {
  return <button type="button" className="nx-skip" onClick={() => { const main = document.getElementById('main-content'); main?.focus(); main?.scrollIntoView({ block: 'start' }); }}>Skip to main content</button>;
}

/** Sidebar on desktop; a menu sheet plus a short bottom bar on phones. One structure for Workspace and Administration. */
export function AppShell({ area, brandSub, sections, bottom, status, header, blocked }: ShellProps) {
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);
  const toggle = useRef<HTMLButtonElement>(null);
  const sheet = useRef<HTMLDivElement>(null);
  const crumbs = breadcrumbsFor(location.pathname);

  useEffect(() => { setMenuOpen(false); }, [location.pathname, location.search]);

  useEffect(() => {
    if (!menuOpen) return;
    document.documentElement.classList.add('nx-locked');
    sheet.current?.querySelector<HTMLElement>('a,button')?.focus();
    // Focus stays inside the open sheet: Tab wraps at both ends and the page behind is inert.
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') { setMenuOpen(false); return; }
      if (event.key !== 'Tab' || !sheet.current) return;
      const focusable = [...sheet.current.querySelectorAll<HTMLElement>('a[href],button:not([disabled]),summary,input,select,textarea,[tabindex]:not([tabindex="-1"])')].filter(node => node.offsetParent !== null);
      if (!focusable.length) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      const active = document.activeElement;
      if (event.shiftKey && (active === first || !sheet.current.contains(active))) { event.preventDefault(); last.focus(); }
      else if (!event.shiftKey && (active === last || !sheet.current.contains(active))) { event.preventDefault(); first.focus(); }
    };
    document.addEventListener('keydown', onKey);
    const opener = toggle.current;
    return () => { document.documentElement.classList.remove('nx-locked'); document.removeEventListener('keydown', onKey); opener?.focus(); };
  }, [menuOpen]);

  const nav = (onClick?: () => void) => sections.map(section => {
    const common = section.items.filter(item => !item.advanced);
    const advanced = section.items.filter(item => item.advanced);
    const showAdvanced = advanced.some(item => location.pathname === item.to || location.pathname.startsWith(item.to + '/'));
    return <div className="nx-group" data-section={section.id} key={section.id}>
      {sections.length > 1 && section.id !== 'overview' ? <h2 className="nx-group-title">{section.label}</h2> : null}
      {common.map(item => <ItemLink key={item.id} to={item.to} label={item.label} description={item.description} end={item.to === '/admin' || item.to === '/me'} onClick={onClick} />)}
      {advanced.length ? <details className="nx-more" open={showAdvanced}><summary>More tools</summary>
        {advanced.map(item => <ItemLink key={item.id} to={item.to} label={item.label} description={item.description} onClick={onClick} />)}
      </details> : null}
    </div>;
  });

  return <div className={`nx-shell nx-${area}`}>
    <SkipLink />
    <header className="nx-top" inert={menuOpen}>
      <button ref={toggle} type="button" className="nx-menu-button" aria-label="Open menu" aria-expanded={menuOpen} aria-controls="nx-sheet" onClick={() => setMenuOpen(true)}>
        <span aria-hidden="true">☰</span>
      </button>
      <Link to={areaHome[area]} className="nx-brand"><span className="nx-brand-mark" aria-hidden="true">B</span><span><b>BuhurtOS</b><small>{brandSub}</small></span></Link>
      <div className="nx-top-areas"><AreaSwitcher current={area} /></div>
      <div className="nx-top-right">{status}<AccountMenu current={area} /></div>
    </header>

    <div className="nx-body" inert={menuOpen}>
      <aside className="nx-side" aria-label={areaLabel[area] + ' menu'}>{nav()}</aside>
      <main className="nx-main" id="main-content" tabIndex={-1}>
        <Breadcrumbs crumbs={crumbs} />
        {header}
        {blocked ?? <Outlet />}
      </main>
    </div>

    <nav className="nx-bottom" aria-label="Main" inert={menuOpen}>
      {bottom.map(item => <NavLink key={item.to} to={item.to} end={item.end} className={({ isActive }) => 'nx-bottom-link' + (isActive ? ' active' : '')}><span aria-hidden="true">{item.icon}</span><small>{item.label}</small></NavLink>)}
      <button type="button" className="nx-bottom-link" aria-label="Open menu" aria-expanded={menuOpen} aria-controls="nx-sheet" onClick={() => setMenuOpen(true)}><span aria-hidden="true">☰</span><small>Menu</small></button>
    </nav>

    {menuOpen ? <div className="nx-overlay" onClick={() => setMenuOpen(false)}>
      <div id="nx-sheet" ref={sheet} className="nx-sheet" role="dialog" aria-modal="true" aria-label={areaLabel[area] + ' menu'} onClick={event => event.stopPropagation()}>
        <div className="nx-sheet-head"><strong>Menu</strong><button type="button" className="nx-close" aria-label="Close menu" onClick={() => setMenuOpen(false)}>✕</button></div>
        <AreaSwitcher current={area} onNavigate={() => setMenuOpen(false)} />
        <div className="nx-sheet-nav">{nav(() => setMenuOpen(false))}</div>
      </div>
    </div> : null}
  </div>;
}

/** Breadcrumb for public detail pages. The list link restores the filters the visitor last used. */
export function ListCrumbs({ list, label, current }: { list: string; label: string; current: string }) {
  return <Breadcrumbs crumbs={[{ label: 'Public site', to: '/public' }, { label, to: recallListPath(list) }, { label: current }]} />;
}
