import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from './Account';
import { useAppState } from './AppState';
import { listSelectableOrganizations, recallOrganization, rememberOrganization, resolveOrganizationChoice, type ScopeOrganization } from '../lib/organizationScope';
import { useQueryState } from '../lib/urlState';
import { StateBlock } from '../components/page';

export interface OrganizationScope {
  status: 'loading' | 'error' | 'empty' | 'ready';
  organizations: ScopeOrganization[];
  organizationId: string;
  organization?: ScopeOrganization;
  error?: string;
  select: (id: string) => void;
  retry: () => void;
}

/**
 * The organization an organization-level tool is working on. Independent of any event:
 * the choice lives in the address (?org=), is remembered for the session, and only offers organizations
 * this person may work on. Nothing here grants access; the database enforces every action.
 */
export function useOrganizationScope(): OrganizationScope {
  const { user, status: accountStatus, contextError } = useAccount();
  const { event } = useAppState();
  const [requested, setRequested] = useQueryState('org');
  const [organizations, setOrganizations] = useState<ScopeOrganization[]>([]);
  const [state, setState] = useState<'loading' | 'error' | 'ready'>('loading');
  const [error, setError] = useState<string>();
  const [tick, setTick] = useState(0);
  const generation = useRef(0);

  useEffect(() => {
    if (accountStatus === 'loading') return;
    if (accountStatus === 'signedIn' && !user) { setState('error'); setError(contextError ?? 'Your roles could not be loaded.'); return; }
    if (accountStatus === 'demo') {
      setOrganizations(event ? [{ id: event.organizationId, name: event.organizerName || 'Demo organization' }] : []);
      setState('ready');
      return;
    }
    const mine = ++generation.current;
    setState('loading'); setError(undefined);
    listSelectableOrganizations(user).then(rows => {
      if (mine !== generation.current) return;
      setOrganizations(rows); setState('ready');
    }).catch(err => {
      if (mine !== generation.current) return;
      setError(err instanceof Error ? err.message : 'Organizations could not be loaded.'); setState('error');
    });
  }, [user, accountStatus, contextError, tick, event?.organizationId]);

  const organizationId = useMemo(
    () => resolveOrganizationChoice(organizations, requested, recallOrganization(), event?.organizationId ?? ''),
    [organizations, requested, event?.organizationId]
  );
  useEffect(() => { if (organizationId) rememberOrganization(organizationId); }, [organizationId]);

  const select = useCallback((id: string) => { rememberOrganization(id); setRequested(id); }, [setRequested]);
  const retry = useCallback(() => setTick(value => value + 1), []);
  const organization = organizations.find(row => row.id === organizationId);
  const status = state === 'ready' ? (organizations.length === 0 ? 'empty' : 'ready') : state;
  return { status, organizations, organizationId, organization, error, select, retry };
}

/** Shows the organization picker and a real loading / error / denied state; renders the page only once one is chosen. */
export function OrganizationGate({ scope, children, toolName }: { scope: OrganizationScope; toolName: string; children: (organizationId: string) => ReactNode }) {
  if (scope.status === 'loading') return <StateBlock kind="loading" title="Loading your organizations…" />;
  if (scope.status === 'error') return <StateBlock kind="error" title="Your organizations could not be loaded">{scope.error} <button type="button" className="nx-linkbutton" onClick={scope.retry}>Try again</button></StateBlock>;
  if (scope.status === 'empty') return <StateBlock kind="empty" title={`${toolName} is not available for your account`}>
    You do not administer an organization, or a club or team inside one. Ask the platform owner or an organization administrator for access, or <Link to="/me/join">join with a code</Link>.
  </StateBlock>;
  return <>
    <div className="nx-picker">
      <label>Organization you are working on
        <select value={scope.organizationId} onChange={event => scope.select(event.target.value)}>
          {scope.organizations.map(org => <option key={org.id} value={org.id}>{org.name}</option>)}
        </select>
      </label>
      <small>Everything on this page applies to this organization only.</small>
    </div>
    {children(scope.organizationId)}
  </>;
}
