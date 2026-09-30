import { workspaceItems } from '../lib/navigation';
import { AppShell, ScopeBar } from './chrome';

/** My workspace: a signed-in person's own profile, teams and invitations. */
export function WorkspaceShell() {
  return <AppShell
    area="workspace"
    brandSub="My workspace"
    sections={[{ id: 'workspace', label: 'My workspace', blurb: 'Your own account.', items: workspaceItems }]}
    bottom={[
      { to: '/me', label: 'Home', icon: '⌂', end: true },
      { to: '/me/profile', label: 'Profile', icon: '♟' },
      { to: '/me/teams', label: 'Teams', icon: '♜' }
    ]}
    header={<ScopeBar kind="Personal" label="Your own account" detail="Only you can see this area." />}
  />;
}
