import { lazy, Suspense } from 'react';
import { HashRouter, Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom';
import { ShowcaseShell } from './components/ShowcaseShell';
import { Layout } from './components/Layout';
import { RequirePermission } from './components/RequirePermission';
import { AppStateProvider, useAppState } from './features/AppState';

const PublicOrganizationPage = lazy(() => import('./pages/PublicOrganizationPage').then(module => ({ default: module.PublicOrganizationPage })));
const GovernancePage = lazy(() => import('./pages/GovernancePage').then(module => ({ default: module.GovernancePage })));
const TeamsPage = lazy(() => import('./pages/TeamsPage').then(module => ({ default: module.TeamsPage })));
const TeamPage = lazy(() => import('./pages/TeamPage').then(module => ({ default: module.TeamPage })));
const TeamHQPage = lazy(() => import('./pages/TeamHQPage').then(module => ({ default: module.TeamHQPage })));
const FightersPage = lazy(() => import('./pages/FightersPage').then(module => ({ default: module.FightersPage })));
const FighterProfilePage = lazy(() => import('./pages/FighterProfilePage').then(module => ({ default: module.FighterProfilePage })));
const MyProfilePage = lazy(() => import('./pages/MyProfilePage').then(module => ({ default: module.MyProfilePage })));
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
const MarketingHome = lazy(() => import('./pages/MarketingHome').then(module => ({ default: module.MarketingHome })));
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

function OperationalGate() {
  const { loading, authReady, authNotice, user, dataMode } = useAppState();
  const location = useLocation();
  if (dataMode === 'supabase' && !authReady) return <div className="state-card">Checking account access…</div>;
  if (dataMode === 'supabase' && !user) {
    const next = encodeURIComponent(location.pathname + location.search);
    const reason = authNotice ? `&reason=${encodeURIComponent(authNotice)}` : '';
    return <Navigate to={`/ops/login?next=${next}${reason}`} replace />;
  }
  const accessBypass = location.pathname === '/ops/access' || location.pathname === '/ops/setup';
  if (dataMode === 'supabase' && user && !user.hasPlatformAccess && !accessBypass) {
    return <Navigate to="/ops/access" replace />;
  }
  if (loading) return <div className="state-card">Loading tournament operations…</div>;
  return <Layout />;
}

function RouteFallback() {
  return <div className="state-card" role="status" aria-live="polite">Loading BuhurtOS…</div>;
}

export function App(){
  return <HashRouter><Suspense fallback={<RouteFallback/>}><Routes>
    <Route path="/" element={<Navigate to="/public" replace/>}/>
    <Route path="/about" element={<MarketingHome/>}/>
    <Route path="/embed/events" element={<EmbedEventsPage/>}/>
    <Route path="/embed/event/:eventId" element={<EmbedEventPage/>}/>
    <Route path="/embed/team/:slug" element={<EmbedTeamPage/>}/>
    <Route path="/embed/standings/:eventId" element={<EmbedStandingsPage/>}/>
    <Route element={<ShowcaseShell/>}>
      <Route path="/public" element={<ShowcasePublicPage/>}/>
      <Route path="/home" element={<Navigate to="/public" replace/>}/>
      <Route path="/organizations/:organizationKey" element={<PublicOrganizationPage/>}/>
      <Route path="/governance" element={<GovernancePage/>}/>
      <Route path="/teams" element={<TeamsPage/>}/>
      <Route path="/teams/:teamId" element={<TeamPage/>}/>
      <Route path="/team-hq" element={<TeamHQPage/>}/>
      <Route path="/fighters" element={<FightersPage/>}/>
      <Route path="/fighters/:fighterId" element={<FighterProfilePage/>}/>
      <Route path="/me" element={<MyProfilePage/>}/>
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
      <Route path="/ops/login" element={<LoginPage/>}/>
      <Route path="/ops" element={<OperationalGate/>}>
        <Route index element={<OpsPage/>}/>
        <Route path="roster" element={<RosterPage/>}/>
        <Route path="bracket" element={<BracketPage/>}/>
        <Route path="standings" element={<StandingsPage/>}/>
        <Route path="manage" element={<RequirePermission permission="event.manage"><EventManagementPage/></RequirePermission>}/>
        <Route path="signups" element={<FighterSignupAdminPage/>}/>
        <Route path="admin" element={<RequirePermission permission="bracket.manage"><AdminPage/></RequirePermission>}/>
        <Route path="discipline" element={<RequirePermission permission="discipline.manage"><DisciplinePage/></RequirePermission>}/>
        <Route path="notes" element={<RequirePermission permission="notes.team"><NotesPage/></RequirePermission>}/>
        <Route path="identity" element={<IdentityPage/>}/>
        <Route path="identity-review" element={<IdentityReviewPage/>}/>
        <Route path="governance" element={<OrganizationManagementPage/>}/>
        <Route path="invite" element={<MembershipInvitePage/>}/>
        <Route path="access" element={<AccessCodePage/>}/>
        <Route path="access-admin" element={<AccessAdminPage/>}/>
        <Route path="platform" element={<PlatformControlPage/>}/>
        <Route path="codes" element={<DelegatedAccessPage/>}/>
        <Route path="foundation" element={<FoundationPage/>}/>
        <Route path="rulesets" element={<RulesetsPage/>}/>
        <Route path="marshal-reference" element={<ShowcaseRulesPage/>}/>
        <Route path="sync" element={<SyncPage/>}/>
        <Route path="setup" element={<SetupPage/>}/>
      </Route>
    </Route>

    <Route path="*" element={<Navigate to="/" replace/>}/>
  </Routes></Suspense></HashRouter>;
}
