import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { describeResponsibilities, loadScopeNames, type ScopeNames } from '../lib/workspace';
import { Card, PageTitle, StateBlock } from '../components/page';

/** My teams: each team you belong to, with the tools your role allows. No team is assumed. */
export function WorkspaceTeams() {
  const { user, contextError } = useAccount();
  const [names, setNames] = useState<ScopeNames>();
  const [error, setError] = useState('');

  useEffect(() => {
    if (!user) return;
    let active = true;
    loadScopeNames(user).then(result => { if (active) setNames(result); }).catch(err => { if (active) setError(err instanceof Error ? err.message : 'Names could not be loaded.'); });
    return () => { active = false; };
  }, [user]);

  const rows = user ? describeResponsibilities(user, names).filter(row => row.kind === 'team' || row.kind === 'club') : [];

  return <>
    <PageTitle title="My teams" lead="Teams and clubs you belong to, and what your role lets you do." actions={<Link className="nx-btn" to="/teams">Browse all teams</Link>} />
    <Card>
      {contextError ? <StateBlock kind="error" title="Your teams could not be loaded">{contextError}</StateBlock>
        : rows.length === 0 ? <StateBlock kind="empty" title="You are not on a team in BuhurtOS yet">
          Find your team in the <Link to="/teams">team directory</Link>. A captain can invite you, or you can <Link to="/me/join">join with a code</Link>. Being listed on a public roster does not create an account or membership.
        </StateBlock>
        : <ul className="nx-rows">{rows.map(row => <li key={row.key}>
          <div><span className="nx-kind">{row.kind === 'team' ? 'Team' : 'Club'}</span><strong>{row.scopeName}</strong><small>{row.roleLabel}</small></div>
          <div className="nx-row-actions">
            {row.action ? <Link className="nx-btn" to={row.action.to}>{row.action.label}</Link> : <span className="nx-muted">No management tools for this role</span>}
            {row.publicTo ? <Link className="nx-btn quiet" to={row.publicTo}>Public page</Link> : null}
          </div>
        </li>)}</ul>}
      {error ? <p className="nx-inline-error" role="alert">Team names could not be loaded ({error}).</p> : null}
    </Card>
  </>;
}
