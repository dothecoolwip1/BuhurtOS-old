import { useMemo, useState } from 'react';
import { useAppState } from '../features/AppState';
import { checkCompliance, checkPhysicalCompliance } from '../lib/compliance';
import { hasPermission } from '../lib/permissions';
import { filterRoster, rosterCounts, type RosterFilterKey } from '../lib/rosterFilter';
import { useQueryStates } from '../lib/urlState';
import { downloadText, htmlTable, openPrintableReport, rosterCsv } from '../lib/export';
import { friendlyError } from '../lib/friendlyError';

const fields = [
  ['checkedIn', 'Check in'], ['armorCleared', 'Armor'], ['medicalCleared', 'Medical'], ['waiverConfirmed', 'Waiver'], ['weighInCleared', 'Weigh in']
] as const;

export function RosterPage() {
  const { roster, updateCompliance, setCompetitionClearance, user, event, teams } = useAppState();
  const [filters, setFilters] = useQueryStates({ show: 'all', q: '' });
  const show = (['all', 'cleared', 'ready', 'blocked', 'unregistered'].includes(filters.show) ? filters.show : 'all') as RosterFilterKey;
  const teamName = (id?: string) => teams.find(team => team.id === id)?.name ?? '';
  const counts = useMemo(() => rosterCounts(roster), [roster]);
  const shown = useMemo(() => filterRoster(roster, show, filters.q, id => teams.find(team => team.id === id)?.name ?? ''), [roster, show, filters.q, teams]);
  const change = async (id: string, field: (typeof fields)[number][0], value: boolean) => {
    setMessage('');
    try { await updateCompliance(id, field, value); }
    catch (error) { setMessage(friendlyError(error).message); }
  };
  const [message,setMessage]=useState('');
  const canManage = Boolean(event && hasPermission(user, 'roster.manage', event.id, event.organizationId));
  const toggleFinal = async (entryId:string,value:boolean) => {
    setMessage('');
    try { await setCompetitionClearance(entryId,value); }
    catch(error){ setMessage(friendlyError(error).message); }
  };
  const phone = typeof window !== 'undefined' && typeof window.matchMedia === 'function' && window.matchMedia('(max-width: 700px)').matches;
  return <>
    <section className="section-head"><div><span className="eyebrow">Entries</span><h1>Roster & check-in</h1><p>Registration approval, physical check in and final competition clearance are separate gates. Only a marshal clearance makes an entry competition ready.</p></div><div className="header-actions"><button onClick={() => downloadText('buhurtos-registration-report.csv', rosterCsv(roster))}>Export roster CSV</button><button onClick={() => openPrintableReport(`${event?.name ?? 'Event'} Registration Report`, htmlTable(['Competitor', 'Entry Type', 'Registration', 'Checked In', 'Armor', 'Medical', 'Waiver', 'Weigh In', 'Cleared To Compete'], roster.map(r => [r.displayName, r.entryType.replaceAll('_', ' '), r.attendanceStatus.replaceAll('_', ' '), r.checkedIn, r.armorCleared, r.medicalCleared, r.waiverConfirmed, r.weighInCleared, Boolean(r.competitionCleared)])))}>Print / PDF</button></div></section>
    {message&&<div className="auth-message">{message}</div>}
    <div className="ro-summary" role="status"><strong>{counts.cleared} of {counts.all} cleared to compete</strong><progress max={Math.max(1, counts.all)} value={counts.cleared} aria-label="Cleared to compete" /></div>
    <div className="ro-filters">
      <label className="show-search grow"><span>⌕</span><input type="search" aria-label="Find a competitor or team" value={filters.q} onChange={e => setFilters({ q: e.target.value })} placeholder="Find a competitor or team" /></label>
      <div className="directory-view-switch" role="group" aria-label="Show entries">
        {([['all', 'All'], ['blocked', 'Blocked'], ['ready', 'Ready for marshal'], ['cleared', 'Cleared'], ['unregistered', 'Not approved']] as Array<[RosterFilterKey, string]>).map(([key, label]) => <button key={key} type="button" className={show === key ? 'selected' : ''} aria-pressed={show === key} onClick={() => setFilters({ show: key })}>{label} ({counts[key]})</button>)}
      </div>
    </div>
    {shown.length === 0 ? <div className="state-card">{roster.length === 0 ? 'No entries yet. Entries appear here as fighters register.' : 'No entries match. Clear the search or choose another filter.'}</div> : null}
    <div className="roster-list">{shown.map(entry => {
      const physical = checkPhysicalCompliance(entry);
      const compliance = checkCompliance(entry);
      const done = fields.filter(([field]) => entry[field]).length;
      return <details className="roster-card" key={entry.id} open={!phone}>
        <summary className="roster-main"><div><strong>{entry.displayName}</strong><small>{[teamName(entry.teamId), entry.entryType.replaceAll('_', ' '), 'registration ' + entry.attendanceStatus.replaceAll('_',' ')].filter(Boolean).join(' · ')}</small></div>
          <span className={`eligibility ${compliance.eligible ? 'ok' : 'blocked'}`}>{compliance.eligible ? 'CLEARED' : physical.eligible ? 'READY FOR MARSHAL' : 'BLOCKED'}<small className="roster-count"> · {done}/{fields.length} checks</small></span>
        </summary>
        <div className="check-grid">{fields.map(([field, label]) => <label key={field} className={entry[field] ? 'checked' : ''}><input type="checkbox" checked={entry[field]} disabled={!canManage || entry.attendanceStatus!=='approved'} onChange={e => change(entry.id, field, e.target.checked)}/><span>{label}</span></label>)}</div>
        {!physical.eligible && <div className="missing-line">Physical gate missing: {physical.missing.join(', ')}</div>}
        <div className="header-actions">
          <button className={entry.competitionCleared?'primary':''} disabled={!canManage || (!physical.eligible && !entry.competitionCleared)} onClick={()=>toggleFinal(entry.id,!entry.competitionCleared)}>
            {entry.competitionCleared ? 'Revoke Competition Clearance' : 'Grant Competition Clearance'}
          </button>
        </div>
        {!compliance.eligible && physical.eligible && !entry.competitionCleared && <div className="missing-line">A marshal must grant final competition clearance.</div>}
      </details>;
    })}</div>
  </>;
}
