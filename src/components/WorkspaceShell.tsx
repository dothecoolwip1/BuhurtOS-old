import { useAccount } from '../features/Account';
import { workspaceBottomTabs } from '../lib/journeys';
import { workspaceItems } from '../lib/navigation';
import { AppShell, ScopeBar } from './chrome';

/** My workspace: a signed-in person's own profile, teams and invitations. */
export function WorkspaceShell() {
  const { user } = useAccount();
  return <AppShell
    area="workspace"
    brandSub="My workspace"
    sections={[{ id: 'workspace', label: 'My workspace', blurb: 'Your own account.', items: workspaceItems }]}
    bottom={workspaceBottomTabs(user)}
    header={<ScopeBar kind="Personal" label="Your own account" detail="Only you can see this area." />}
  />;
}
