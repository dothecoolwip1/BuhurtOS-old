import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { hasAdminArea } from '../lib/navigation';
import { describeResponsibilities, loadScopeNames, scopeKindLabel, type ScopeNames } from '../lib/workspace';
import { Card, LinkCard, PageTitle, StateBlock } from '../components/page';

/** My workspace home: who you are here, what you are responsible for, and what to do next. */
export function WorkspaceHome() {
  const { user, email, status, contextError, refresh } = useAccount();
  const [names, setNames] = useState<ScopeNames>();
  const [namesError, setNamesError] = useState('');

  useEffect(() => {
    if (!user) return;
    let active = true;
    setNamesError('');
    loadScopeNames(user).then(result => { if (active) setNames(result); })
      .catch(error => { if (active) setNamesError(error instanceof Error ? error.message : 'Names could not be loaded.'); });
    return () => { active = false; };
  }, [user]);

  const rows = user ? describeResponsibilities(user, names) : [];
  const title = `Welcome${user?.displayName ? ', ' + user.displayName.replace(/@.*$/, '') : ''}`;

  return <>
    <PageTitle title={title} lead={status === 'demo' ? 'Demo mode: you are exploring with sample data.' : email ? `Signed in as ${email}.` : undefined} />

    {contextError ? <StateBlock kind="error" title="We could not load your roles">
      {contextError} <button type="button" className="nx-linkbutton" onClick={refresh}>Try again</button>
    </StateBlock> : null}

    <div className="nx-grid">
      <LinkCard to="/me/profile" title="My fighter profile" text="Keep your sporting identity, public profile and private details up to date." />
      <LinkCard to="/events" title="Find an event" text="See what is coming up and whether registration is open." />
      <LinkCard to="/me/join" title="Join with a code" text="Use an invitation or access code from an organizer, captain or the platform owner." />
      {hasAdminArea(user) ? <LinkCard to="/admin" title="Administration" text="Manage the events, teams and people you are responsible for." badge="You have access" /> : null}
    </div>

    <Card title="Your responsibilities" lead="Everything you are authorized to do, and where to do it.">
      {contextError ? <StateBlock kind="error" title="Responsibilities unavailable">Your roles could not be loaded, so nothing is shown here rather than something misleading.</StateBlock>
        : rows.length === 0 ? <StateBlock kind="empty" title="No roles yet">
          You can still browse everything public. To take part, <Link to="/me/join">join with a code</Link> or ask an organizer or team captain to invite you.
        </StateBlock>
        : <ul className="nx-rows">{rows.map(row => <li key={row.key}>
          <div><span className="nx-kind">{scopeKindLabel[row.kind]}</span><strong>{row.scopeName}</strong><small>{row.roleLabel}</small></div>
          <div className="nx-row-actions">
            {row.action ? <Link className="nx-btn" to={row.action.to}>{row.action.label}</Link> : null}
            {row.publicTo ? <Link className="nx-btn quiet" to={row.publicTo}>Public page</Link> : null}
          </div>
        </li>)}</ul>}
      {namesError ? <p className="nx-inline-error" role="alert">Some names could not be loaded ({namesError}). Roles are still accurate.</p> : null}
    </Card>
  </>;
}
