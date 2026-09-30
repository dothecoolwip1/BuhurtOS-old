import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { filterTeamRows, listTeamsForAdmin, type TeamListRow } from '../lib/teamAdmin';
import { useQueryStates } from '../lib/urlState';
import { Card, PageTitle, StateBlock } from '../components/page';

/** Teams & rosters: find any team you may work with and open its roster. */
export function TeamsBrowserPage() {
  const { user } = useAccount();
  const [rows, setRows] = useState<TeamListRow[]>();
  const [error, setError] = useState('');
  const [filters, setFilters] = useQueryStates({ q: '', org: 'all', mine: '' });
  const [visible, setVisible] = useState(60);

  useEffect(() => {
    if (!user) return;
    let active = true;
    setError('');
    listTeamsForAdmin(user).then(result => { if (active) setRows(result); })
      .catch(err => { if (active) setError(err instanceof Error ? err.message : 'Teams could not be loaded.'); });
    return () => { active = false; };
  }, [user]);

  useEffect(() => setVisible(60), [filters.q, filters.org, filters.mine]);

  const organizations = useMemo(() => {
    const map = new Map<string, string>();
    (rows ?? []).forEach(row => map.set(row.organizationId, row.organizationName));
    return [...map.entries()].sort((a, b) => a[1].localeCompare(b[1]));
  }, [rows]);
  const shown = useMemo(() => filterTeamRows(rows ?? [], filters.q, filters.org, filters.mine === '1'), [rows, filters]);
  const manageableCount = (rows ?? []).filter(row => row.manageable).length;

  return <>
    <PageTitle title="Teams & rosters" lead="Open a team to see who is on it, add or remove people, and answer applications." />
    <Card>
      <div className="nx-filters">
        <label>Search<input type="search" value={filters.q} onChange={e => setFilters({ q: e.target.value })} placeholder="Team, place or organization" /></label>
        <label>Organization
          <select value={filters.org} onChange={e => setFilters({ org: e.target.value })}>
            <option value="all">All organizations</option>
            {organizations.map(([id, name]) => <option key={id} value={id}>{name}</option>)}
          </select>
        </label>
        <label className="nx-check"><input type="checkbox" checked={filters.mine === '1'} onChange={e => setFilters({ mine: e.target.checked ? '1' : '' })} /> Only teams I can manage ({manageableCount})</label>
      </div>
      {error ? <StateBlock kind="error" title="Teams could not be loaded">{error}</StateBlock>
        : !rows ? <StateBlock kind="loading" title="Loading teams…" />
        : shown.length === 0 ? <StateBlock kind="empty" title="No teams match">Clear the search or choose another organization.</StateBlock>
        : <>
          <p className="nx-muted" role="status">{shown.length} team{shown.length === 1 ? '' : 's'}</p>
          <ul className="nx-rows">{shown.slice(0, visible).map(row => <li key={row.id}>
            <div><span className="nx-kind">{row.organizationName}</span><strong>{row.name}</strong><small>{[row.cityOrRegion, row.status && row.status !== 'active' ? row.status : ''].filter(Boolean).join(' · ') || 'Team'}</small></div>
            <div className="nx-row-actions">
              <Link className={row.manageable ? 'nx-btn' : 'nx-btn quiet'} to={`/admin/teams/${row.id}`}>{row.manageable ? 'Manage roster' : 'View roster'}</Link>
              <Link className="nx-btn quiet" to={`/teams/${row.id}`}>Public page</Link>
            </div>
          </li>)}</ul>
          {shown.length > visible ? <p><button type="button" className="nx-btn quiet" onClick={() => setVisible(count => count + 60)}>Show 60 more</button></p> : null}
        </>}
    </Card>
  </>;
}
