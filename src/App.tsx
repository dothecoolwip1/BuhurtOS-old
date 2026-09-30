import { lazy, Suspense } from 'react';
import { NotFoundPage, RouteBoundary, RouteEffects } from './components/RouteBoundary';
import { HashRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom';
import { ShowcaseShell } from './components/ShowcaseShell';
import { AdminShell } from './components/AdminShell';
import { WorkspaceShell } from './components/WorkspaceShell';
import { AccountProvider } from './features/Account';
import { legacyRedirects, resolveLegacyPath } from './lib/navigation';
import { RequirePermission } from './components/RequirePermission';
import { AppStateProvider, useAppState } from './features/AppState';

const PublicOrganizationPage = lazy(() => import('./pages/PublicOrganizationPage').then(module => ({ default: module.PublicOrganizationPage })));
const GovernancePage = lazy(() => import('./pages/GovernancePage').then(module => ({ default: module.GovernancePage })));
const NotificationsPage = lazy(() => import('./pages/NotificationsPage').then(module => ({ default: module.NotificationsPage })));
const TeamsPage = lazy(() => import('./pages/TeamsPage').then(module => ({ default: module.TeamsPage })));
const TeamPage = lazy(() => import('./pages/TeamPage').then(module => ({ default: module.TeamPage })));
const FightersPage = lazy(() => import('./pages/FightersPage').then(module => ({ default: module.FightersPage })));
const FighterProfilePage = lazy(() => import('./pages/FighterProfilePage').then(module => ({ default: module.FighterProfilePage })));
const EmbedEventsPage = lazy(() => import('./pages/EmbedPages').then(module => ({ default: module.EmbedEventsPage })));
const EmbedEventPage = lazy(() => import('./pages/EmbedPages').then(module => ({ default: module.EmbedEventPage })));
const EmbedTeamPage = lazy(() => import('./pages/EmbedPages').then(module => ({ default: module.EmbedTeamPage })));
const EmbedStandingsPage = lazy(() => import('./pages/EmbedPages').then(module => ({ default: module.EmbedStandingsPage })));
const EmbedBuilderPage = lazy(() => import('./pages/EmbedBuilderPage').then(module => ({ default: module.EmbedBuilderPage })));
const ShowcaseEventsPage = lazy(() => import('./pages/ShowcaseEventsPage').then(module => ({ default: module.ShowcaseEventsPage })));
const ShowcaseEventPage = lazy(() => import('./pages/ShowcaseEventPage').then(module => ({ default: module.ShowcaseEventPage })));
const ShowcaseRankingsPage = lazy(() => import('./pages/ShowcaseRankingsPage').then(module => ({ default: module.ShowcaseRankingsPage })));
const ShowcaseRulesPage = lazy(() => import('./pages/ShowcaseRulesPage').then(module => ({ default: module.ShowcaseRulesPage })));
const ShowcasePublicPage = lazy(() => import('./pages/ShowcasePublicPage').then(module => ({ default: module.ShowcasePublicPage })));
const WorkspaceHome = lazy(() => import('./pages/WorkspaceHome').then(module => ({ default: module.WorkspaceHome })));
const WorkspaceTeams = lazy(() => import('./pages/WorkspaceTeams').then(module => ({ default: module.WorkspaceTeams })));
const AdminHome = lazy(() => import('./pages/AdminHome').then(module => ({ default: module.AdminHome })));
const TeamsBrowserPage = lazy(() => import('./pages/TeamsBrowserPage').then(module => ({ default: module.TeamsBrowserPage })));
const TeamManagePage = lazy(() => import('./pages/TeamManagePage').then(module => ({ default: module.TeamManagePage })));
const SettingsPage = lazy(() => import('./pages/SettingsPage').then(module => ({ default: module.SettingsPage })));
const LoginPage = lazy(() => import('./pages/LoginPage').then(module => ({ default: module.LoginPage })));
const OpsPage = lazy(() => import('./pages/OpsPage').then(module => ({ default: module.OpsPage })));
const RosterPage = lazy(() => import('./pages/RosterPage').then(module => ({ default: module.RosterPage })));
const BracketPage = lazy(() => import('./pages/BracketPage').then(module => ({ default: module.BracketPage })));
const StandingsPage = lazy(() => import('./pages/StandingsPage').then(module => ({ default: module.StandingsPage })));
const AdminPage = lazy(() => import('./pages/AdminPage').then(module => ({ default: module.AdminPage })));
const DisciplinePage = lazy(() => import('./pages/DisciplinePage').then(module => ({ default: module.DisciplinePage })));
const NotesPage = lazy(() => import('./pages/NotesPage').then(module => ({ default: module.NotesPage })));
const SyncPage = lazy(() => import('./pages/SyncPage').then(module => ({ default: module.SyncPage })));
const SetupPage = lazy(() => import('./pages/SetupPage').then(module => ({ default: module.SetupPage })));
const RegistrationPage = lazy(() => import('./pages/RegistrationPage').then(module => ({ default: module.RegistrationPage })));
const PublicPage = lazy(() => import('./pages/PublicPage').then(module => ({ default: module.PublicPage })));
const EventGuidePage = lazy(() => import('./pages/EventGuidePage').then(module => ({ default: module.EventGuidePage })));
const EventManagementPage = lazy(() => import('./pages/EventManagementPage').then(module => ({ default: module.EventManagementPage })));
const FoundationPage = lazy(() => import('./pages/FoundationPage').then(module => ({ default: module.FoundationPage })));
const RulesetsPage = lazy(() => import('./pages/RulesetsPage').then(module => ({ default: module.RulesetsPage })));
const IdentityPage = lazy(() => import('./pages/IdentityPage').then(module => ({ default: module.IdentityPage })));
const IdentityReviewPage = lazy(() => import('./pages/IdentityReviewPage').then(module => ({ default: module.IdentityReviewPage })));
const StandingsWidgetPage = lazy(() => import('./pages/StandingsWidgetPage').then(module => ({ default: module.StandingsWidgetPage })));
const OrganizationManagementPage = lazy(() => import('./pages/OrganizationManagementPage').then(module => ({ default: module.OrganizationManagementPage })));
const MembershipInvitePage = lazy(() => import('./pages/MembershipInvitePage').then(module => ({ default: module.MembershipInvitePage })));
const AccessCodePage = lazy(() => import('./pages/AccessCodePage').then(module => ({ default: module.AccessCodePage })));
const AccessAdminPage = lazy(() => import('./pages/AccessAdminPage').then(module => ({ default: module.AccessAdminPage })));
const PlatformControlPage = lazy(() => import('./pages/PlatformControlPage').then(module => ({ default: module.PlatformControlPage })));
const DelegatedAccessPage = lazy(() => import('./pages/DelegatedAccessPage').then(module => ({ default: module.DelegatedAccessPage })));
const FighterSignupAdminPage = lazy(() => import('./pages/FighterSignupAdminPage').then(module => ({ default: module.FighterSignupAdminPage })));

function OperationsProvider() {
  return <AppStateProvider><Outlet /></AppStateProvider>;
}

function signInRedirect(location: { pathname: string; search: string }, reason?: string | null) {
  const next = encodeURIComponent(location.pathname + location.search);
  return `/sign-in?next=${next}${reason ? '&reason=' + encodeURIComponent(reason) : ''}`;
}

/** My workspace: any signed-in person. No platform access or event data is required. */
function WorkspaceGate() {
  const { authReady, authNotice, user, dataMode } = useAppState();
  const location = useLocation();
  if (dataMode === 'supabase' && !authReady) return <div className="state-card" role="status">Checking account access…</div>;
  if (dataMode === 'supabase' && !user) return <Navigate to={signInRedirect(location, authNotice)} replace />;
  return <WorkspaceShell />;
}

/** Administration: signed in, with platform access. Redeeming a code and accepting an invitation stay reachable. */
function AdminGate() {
  const { loading, authReady, authNotice, user, dataMode } = useAppState();
  const location = useLocation();
  if (dataMode === 'supabase' && !authReady) return <div className="state-card" role="status">Checking account access…</div>;
  if (dataMode === 'supabase' && !user) return <Navigate to={signInRedirect(location, authNotice)} replace />;
  const reachableWithoutAccess = location.pathname === '/admin/events/setup';
  if (dataMode === 'supabase' && user && !user.hasPlatformAccess && !reachableWithoutAccess) return <Navigate to="/me/join" replace />;
  if (loading) return <div className="state-card" role="status">Loading…</div>;
  return <AdminShell />;
}

/** Invitation links now live in My workspace; older links keep working. */
function InviteRedirect() {
  const location = useLocation();
  return <Navigate to={'/me/invite' + location.search} replace />;
}

/** Old /ops links (emails, bookmarks, chats) keep working. */
function LegacyRedirect() {
  const location = useLocation();
  const target = resolveLegacyPath(location.pathname, location.search) ?? '/admin';
  return <Navigate to={target} replace />;
}

function RouteFallback() {
  return <div className="state-card" role="status" aria-live="polite">Loading BuhurtOS…</div>;
}

export function App(){
  return <HashRouter><AccountProvider><RouteEffects/><RouteBoundary><Suspense fallback={<RouteFallback/>}><Routes>
    <Route path="/" element={<Navigate to="/public" replace/>}/>
    <Route path="/about" element={<Navigate to="/public" replace/>}/>
    <Route path="/embed/events" element={<EmbedEventsPage/>}/>
    <Route path="/embed/event/:eventId" element={<EmbedEventPage/>}/>
    <Route path="/embed/team/:slug" element={<EmbedTeamPage/>}/>
    <Route path="/embed/standings/:eventId" element={<EmbedStandingsPage/>}/>

    {/* PUBLIC SITE */}
    <Route element={<ShowcaseShell/>}>
      <Route path="/public" element={<ShowcasePublicPage/>}/>
      <Route path="/home" element={<Navigate to="/public" replace/>}/>
      <Route path="/organizations/:organizationKey" element={<PublicOrganizationPage/>}/>
      <Route path="/governance" element={<GovernancePage/>}/>
      <Route path="/teams" element={<TeamsPage/>}/>
      <Route path="/teams/:teamId" element={<TeamPage/>}/>
      <Route path="/fighters" element={<FightersPage/>}/>
      <Route path="/fighters/:fighterId" element={<FighterProfilePage/>}/>
      <Route path="/events" element={<ShowcaseEventsPage/>}/>
      <Route path="/events/:eventId" element={<ShowcaseEventPage/>}/>
      <Route path="/rankings" element={<ShowcaseRankingsPage/>}/>
      <Route path="/rules" element={<ShowcaseRulesPage/>}/>
      <Route path="/embed-builder" element={<EmbedBuilderPage/>}/>
    </Route>

    <Route element={<OperationsProvider/>}>
      <Route path="/live" element={<PublicPage/>}/>
      <Route path="/register" element={<RegistrationPage/>}/>
      <Route path="/widget/standings" element={<StandingsWidgetPage/>}/>
      <Route path="/sign-in" element={<LoginPage/>}/>

      {/* MY WORKSPACE */}
      <Route path="/me" element={<WorkspaceGate/>}>
        <Route index element={<WorkspaceHome/>}/>
        <Route path="profile" element={<IdentityPage/>}/>
        <Route path="teams" element={<WorkspaceTeams/>}/>
        <Route path="join" element={<AccessCodePage/>}/>
        <Route path="notifications" element={<Suspense fallback={null}><NotificationsPage/></Suspense>}/>
        <Route path="invite" element={<MembershipInvitePage/>}/>
      </Route>

      {/* ADMINISTRATION */}
      <Route path="/admin" element={<AdminGate/>}>
        <Route index element={<AdminHome/>}/>
        <Route path="events/setup" element={<SetupPage/>}/>
        <Route path="events/guide" element={<RequirePermission permission="event.manage"><EventGuidePage/></RequirePermission>}/>
        <Route path="events/manage" element={<RequirePermission permission="event.manage"><EventManagementPage/></RequirePermission>}/>
        <Route path="events/signups" element={<FighterSignupAdminPage/>}/>
        <Route path="events/roster" element={<RosterPage/>}/>
        <Route path="events/bracket" element={<BracketPage/>}/>
        <Route path="events/run" element={<OpsPage/>}/>
        <Route path="events/results" element={<StandingsPage/>}/>
        <Route path="events/discipline" element={<RequirePermission permission="discipline.manage"><DisciplinePage/></RequirePermission>}/>
        <Route path="events/notes" element={<RequirePermission permission="notes.team"><NotesPage/></RequirePermission>}/>
        <Route path="events/tools" element={<RequirePermission permission="bracket.manage"><AdminPage/></RequirePermission>}/>
        <Route path="events/all" element={<PlatformControlPage section="events"/>}/>
        <Route path="organizations" element={<PlatformControlPage section="organizations"/>}/>
        <Route path="organizations/manage" element={<OrganizationManagementPage/>}/>
        <Route path="teams" element={<TeamsBrowserPage/>}/>
        <Route path="teams/new" element={<PlatformControlPage section="people"/>}/>
        <Route path="teams/:teamId" element={<TeamManagePage/>}/>
        <Route path="people/accounts" element={<AccessAdminPage/>}/>
        <Route path="people/codes" element={<DelegatedAccessPage/>}/>
        <Route path="people/invite" element={<InviteRedirect/>}/>
        <Route path="people/identity-review" element={<IdentityReviewPage/>}/>
        <Route path="rules/reference" element={<ShowcaseRulesPage/>}/>
        <Route path="rules/rulesets" element={<RulesetsPage/>}/>
        <Route path="rules/divisions" element={<FoundationPage/>}/>
        <Route path="settings" element={<SettingsPage/>}/>
        <Route path="system/sync" element={<SyncPage/>}/>
        <Route path="*" element={<NotFoundPage/>}/>
      </Route>
    </Route>

    {/* Old links keep working */}
    {legacyRedirects.filter(entry => entry.from !== '/ops').map(entry => <Route key={entry.from} path={entry.from} element={<LegacyRedirect/>}/>)}
    <Route path="/ops" element={<LegacyRedirect/>}/>
    <Route path="/ops/*" element={<LegacyRedirect/>}/>

    <Route path="*" element={<NotFoundPage/>}/>
  </Routes></Suspense></RouteBoundary></AccountProvider></HashRouter>;
}
