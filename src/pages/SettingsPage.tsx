import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { PlatformSettingsPanel } from '../components/PlatformSettingsPanel';
import { PageTitle, StateBlock } from '../components/page';

/** Platform settings: the few switches that change how open the whole platform is. Owner only. */
export function SettingsPage() {
  const { user } = useAccount();
  const isOwner = Boolean(user?.platformRoles.includes('platform_super_admin'));
  return <>
    <PageTitle title="Platform settings" lead="Who can register, who can create events, and whether ownership claims are accepted. These apply to everyone." />
    {!isOwner
      ? <StateBlock kind="empty" title="Only the platform owner can change these settings">Organization and event settings live with the organization or event they belong to. <Link to="/admin">Back to overview</Link></StateBlock>
      : <div className="admin-grid"><PlatformSettingsPanel isSuperAdmin /></div>}
  </>;
}
