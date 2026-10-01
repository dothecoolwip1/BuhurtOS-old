import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { hasAdminArea } from '../lib/navigation';
import { describeResponsibilities, loadScopeNames, scopeKindLabel, type ScopeNames } from '../lib/workspace';
import { Card, LinkCard, PageTitle, StateBlock } from '../components/page';
import { personaLabels, personasOf, primaryTasks } from '../lib/journeys';
import { buildEventChecklist, loadEventSetupFacts, type ChecklistResult } from '../lib/eventChecklist';
import { friendlyError } from '../lib/friendlyError';

/** Setup progress for the events this person organizes, with a direct way back in. */
function OrganizerProgress({ eventIds }: { eventIds: string[] }) {
  const [rows, setRows] = useState<Array<{ id: string; name: string; result?: ChecklistResult; failed?: boolean }>>();
  useEffect(() => {
    let active = true;
    Promise.all(eventIds.slice(0, 3).map(id => loadEventSetupFacts(id).then(facts => ({ id, name: facts.name, result: buildEventChecklist(facts) })).catch(() => ({ id, name: 'Event', failed: true }))))
      .then(result => { if (active) setRows(result); });
    return () => { active = false; };
  }, [eventIds.join(',')]);
  if (!rows) return <StateBlock kind="loading" title="Checking your events…" />;
  return <ul className="nx-rows">{rows.map(row => <li key={row.id}>
    <div><span className="nx-kind">Event setup</span><strong>{row.name}</strong><small>{row.failed ? 'Progress could not be loaded right now.' : `${row.result!.completed} of ${row.result!.total} steps complete${row.result!.next ? ' · next: ' + row.result!.next.label : ''}`}</small></div>
    <div className="nx-row-actions"><Link className="nx-btn primary" to={'/admin/events/guide?event=' + row.id}>{row.result && !row.result.next ? 'Review setup' : 'Continue setup'}</Link></div>
  </li>)}</ul>;
}

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
      .catch(error => { if (active) setNamesError(friendlyError(error).message); });
    return () => { active = false; };
  }, [user]);

  const rows = user ? describeResponsibilities(user, names) : [];
  const tasks = primaryTasks(user);
  const personas = personasOf(user).filter(p => p !== 'fighter' || personasOf(user).length === 1);
  const organizerEvents = (user?.eventRoles ?? []).filter(r => r.role === 'event_organizer').map(r => r.eventId);
  const title = `Welcome${user?.displayName ? ', ' + user.displayName.replace(/@.*$/, '') : ''}`;

  return <>
    <PageTitle title={title} lead={status === 'demo' ? 'Demo mode: you are exploring with sample data.' : email ? `Signed in as ${email}.` : undefined} />

    {contextError ? <StateBlock kind="error" title="We could not load your roles">
      {contextError} <button type="button" className="nx-linkbutton" onClick={refresh}>Try again</button>
    </StateBlock> : null}

    {tasks.length ? <Card title="Start here" lead={personas.length ? 'Because you are: ' + personas.map(p => personaLabels[p]).join(', ') + '.' : undefined}>
      <div className="nx-grid">{tasks.map(task => <LinkCard key={task.id} to={task.to} title={task.label} text={task.text} />)}</div>
    </Card> : null}

    {organizerEvents.length ? <Card title="Your events" lead="Where each event stands, and the next step."><OrganizerProgress eventIds={organizerEvents} /></Card> : null}

    <h2 className="nx-more">More</h2>
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
