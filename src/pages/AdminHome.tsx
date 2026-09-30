import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { useAdminAccess } from '../components/AdminShell';
import { supabase } from '../lib/supabase';
import { canSee, type NavGate } from '../lib/navigation';
import { Card, LinkCard, PageTitle, StateBlock } from '../components/page';

type Count = { state: 'loading' } | { state: 'error'; message: string } | { state: 'ready'; value: number };

function useCount(run: (() => PromiseLike<{ count: number | null; error: { message: string } | null }>) | undefined, deps: unknown[]): Count {
  const [value, setValue] = useState<Count>({ state: 'loading' });
  useEffect(() => {
    if (!run) return;
    let active = true;
    setValue({ state: 'loading' });
    Promise.resolve(run()).then(({ count, error }) => {
      if (!active) return;
      setValue(error ? { state: 'error', message: error.message } : { state: 'ready', value: count ?? 0 });
    }).catch(error => { if (active) setValue({ state: 'error', message: error instanceof Error ? error.message : 'Request failed' }); });
    return () => { active = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
  return value;
}

function Attention({ to, label, count, doneText }: { to: string; label: string; count: Count; doneText: string }) {
  if (count.state === 'loading') return <li className="nx-attn"><span>{label}</span><em>Checking…</em></li>;
  if (count.state === 'error') return <li className="nx-attn error" role="alert"><span>{label}</span><em>Could not check: {count.message}</em></li>;
  if (count.value === 0) return <li className="nx-attn"><span>{label}</span><em>{doneText}</em></li>;
  return <li className="nx-attn due"><span>{label}</span><Link to={to}>{count.value} to review →</Link></li>;
}

const commonTasks: Array<{ to: string; title: string; text: string; gate: NavGate }> = [
  { to: '/admin/teams', title: 'Add or remove people on a team', text: 'Open a team to see its roster and invite or remove members.', gate: 'teamManager' },
  { to: '/admin/people/codes', title: 'Give someone a role', text: 'Make a one-time code for a captain, team admin, organization admin and more.', gate: 'orgAdmin' },
  { to: '/admin/people/accounts', title: 'Let someone sign in', text: 'Create an early-access code for a new person.', gate: 'superAdmin' },
  { to: '/admin/organizations', title: 'See and edit organizations', text: 'Every organization, its details and its relationships.', gate: 'superAdmin' },
  { to: '/admin/events/setup', title: 'Create an event', text: 'Set up a season and a new event.', gate: 'orgAdmin' },
  { to: '/admin/events/signups', title: 'Review fighter signups', text: 'Accept or decline fighters who applied to the current event.', gate: 'event' }
];

/** Administration overview: what needs attention, then every tool this person may use, grouped by task. */
export function AdminHome() {
  const { event, pendingCount, dataMode } = useAppState();
  const { access, sections } = useAdminAccess();

  const signups = useCount(supabase && event && access.event
    ? () => supabase!.from('fighter_event_signups').select('id', { count: 'exact', head: true }).eq('event_id', event.id).eq('status', 'new')
    : undefined, [event?.id, access.event]);
  const claims = useCount(supabase && access.superAdmin
    ? () => supabase!.from('claim_requests').select('id', { count: 'exact', head: true }).eq('status', 'pending')
    : undefined, [access.superAdmin]);

  const tools = sections.filter(section => section.id !== 'overview');
  const showSignups = Boolean(supabase && event && access.event);

  return <>
    <PageTitle title="Administration" lead={event ? `Current event: ${event.name}.` : 'Manage the events, teams and people you are responsible for.'} />

    <Card title="What do you want to do?" lead="The most common jobs, one click away.">
      <div className="nx-grid">{commonTasks.filter(task => canSee(task.gate, access)).map(task => <LinkCard key={task.to} to={task.to} title={task.title} text={task.text} />)}</div>
    </Card>

    <Card title="Needs your attention" lead="Checked live each time you open this page.">
      <ul className="nx-attn-list">
        {showSignups && event ? <Attention to={`/admin/events/signups?event=${event.id}`} label={`New fighter signups for ${event.name}`} count={signups} doneText="Nothing waiting" /> : null}
        {supabase && access.superAdmin ? <Attention to="/admin/settings" label="Ownership claims waiting for review" count={claims} doneText="Nothing waiting" /> : null}
        <li className={'nx-attn' + (pendingCount > 0 ? ' due' : '')}><span>Changes saved on this device</span>{pendingCount > 0 ? <Link to="/admin/system/sync">{pendingCount} waiting to upload →</Link> : <em>All uploaded</em>}</li>
      </ul>
      {dataMode === 'demo' ? <p className="nx-muted">Demo mode: these figures come from sample data, not the live backend.</p> : null}
    </Card>

    {tools.length === 0
      ? <StateBlock kind="empty" title="No administration tools for your account yet">Ask the platform owner or an organizer to give you a role, or <Link to="/me/join">join with a code</Link>.</StateBlock>
      : tools.map(section => <Card key={section.id} title={section.label} lead={section.blurb}>
        <div className="nx-grid">{section.items.map(item => <LinkCard key={item.id} to={item.to} title={item.label} text={item.description} />)}</div>
      </Card>)}
  </>;
}
