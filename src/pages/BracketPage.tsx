import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { listTournamentBrackets, type TournamentBracketSummary } from '../lib/adminActions';
import { computePoolQualificationState } from '../lib/bracket';
import { groupBracketRounds } from '../lib/bracketView';
import { eventClock, eventDayKey } from '../lib/eventTime';
import { minutesBehindPlan } from '../lib/tournamentPlanner';
import { downloadText, htmlTable, matchesCsv, openPrintableReport } from '../lib/export';
import { buildBoutsIcs } from '../lib/ics';
import { groupRowsByArea, scheduleAsText, type ScheduleRow } from '../lib/scheduleText';
import { useQueryStates } from '../lib/urlState';
import type { MatchRecord } from '../types';
import { friendlyError } from '../lib/friendlyError';

type View = 'play' | 'pools' | 'bracket';

const statusLabel: Record<string, string> = {
  scheduled: 'Scheduled', on_deck: 'On deck', in_the_hole: 'Next up', active: 'Fighting now', completed: 'Needs result', finalized: 'Final', forfeit: 'Forfeit', cancelled: 'Cancelled'
};

/** Order of play, pool tables and the knockout bracket for the event, one tournament at a time. */
export function BracketPage() {
  const { matches, roster, event, fightCards, teams } = useAppState();
  const [brackets, setBrackets] = useState<TournamentBracketSummary[]>([]);
  const [filters, setFilters] = useQueryStates({ view: '', bracket: 'all', area: 'all', q: '' });

  useEffect(() => {
    if (!event) return;
    let active = true;
    listTournamentBrackets(event.id).then(rows => { if (active) setBrackets(rows); }).catch(() => { if (active) setBrackets([]); });
    return () => { active = false; };
  }, [event?.id]);

  const timezone = event?.timezone ?? 'UTC';
  const live = brackets.filter(b => b.generationState === 'published');
  const bracketId = live.some(b => b.id === filters.bracket) ? filters.bracket : 'all';
  const areaId = fightCards.some(card => card.id === filters.area) ? filters.area : 'all';

  const scoped = useMemo(() => matches.filter(match =>
    match.status !== 'cancelled' && (bracketId === 'all' || match.bracketId === bracketId) && (areaId === 'all' || match.fightCardId === areaId)
  ), [matches, bracketId, areaId]);

  const slotByMatch = useMemo(() => {
    const map = new Map<string, { startsAt: string; endsAt: string; order: number }>();
    for (const item of live) for (const slot of item.schedule?.slots ?? []) map.set(slot.matchId, { startsAt: slot.startsAt, endsAt: slot.endsAt, order: slot.order });
    return map;
  }, [live]);

  const name = (id?: string, placeholder?: string) => roster.find(r => r.id === id)?.displayName ?? placeholder ?? 'To be decided';
  const side = (match: MatchRecord, index: 1 | 2) => { const p = match.participants.find(x => x.sideIndex === index); return name(p?.rosterEntryId, p?.placeholderLabel); };
  const areaName = (id?: string) => fightCards.find(card => card.id === id)?.name ?? '';
  const clock = (match: MatchRecord) => { const slot = slotByMatch.get(match.id); return slot ? eventClock(slot.startsAt, timezone) : ''; };

  const played = scoped.filter(m => m.resultSummary && (m.resultSummary as { resultType?: string }).resultType !== 'bye');
  const ordered = useMemo(() => [...scoped]
    .filter(m => (m.resultSummary as { resultType?: string } | undefined)?.resultType !== 'bye')
    .sort((a, b) => (slotByMatch.get(a.id)?.order ?? a.scheduledOrder) - (slotByMatch.get(b.id)?.order ?? b.scheduledOrder)), [scoped, slotByMatch]);

  const needle = filters.q.trim().toLowerCase();
  const involves = (match: MatchRecord) => !needle || match.participants.some(p => {
    const entry = roster.find(r => r.id === p.rosterEntryId);
    const team = teams.find(t => t.id === entry?.teamId)?.name ?? '';
    return [entry?.displayName ?? '', team, p.placeholderLabel ?? ''].some(text => text.toLowerCase().includes(needle));
  });
  const shown = useMemo(() => ordered.filter(involves), [ordered, needle, roster, teams]); // eslint-disable-line react-hooks/exhaustive-deps
  const nextUpId = ordered.find(m => m.status !== 'finalized' && m.status !== 'forfeit' && m.status !== 'completed')?.id;
  // Only meaningful on the event day itself: compare the next unfinished bout's planned start with the clock.
  const nextSlot = nextUpId ? slotByMatch.get(nextUpId) : undefined;
  const behind = event && nextSlot && eventDayKey(nextSlot.startsAt, timezone) === eventDayKey(new Date().toISOString(), timezone) ? minutesBehindPlan(nextSlot.startsAt) : 0;
  const poolBracketIds = useMemo(() => [...new Set(scoped.filter(m => m.stage === 'pool' && m.bracketId).map(m => m.bracketId!))], [scoped]);
  const rounds = groupBracketRounds(scoped.filter(m => m.stage !== 'pool'));
  const hasPools = poolBracketIds.length > 0;
  const hasBracket = rounds.length > 0;
  const requested = (filters.view || '') as View;
  const view: View = requested === 'pools' && hasPools ? 'pools' : requested === 'bracket' && hasBracket ? 'bracket' : 'play';

  const rows: ScheduleRow[] = ordered.filter(involves).map(m => ({ time: clock(m), area: areaName(m.fightCardId), label: m.label, side1: side(m, 1), side2: side(m, 2), status: statusLabel[m.status] ?? m.status }));
  const [copied, setCopied] = useState('');
  const printOrder = () => {
    try {
      const body = groupRowsByArea(rows).map(group => '<h2>' + group.area.replace(/&/g, '&amp;').replace(/</g, '&lt;') + '</h2>' + htmlTable(
        ['Time', 'Match', 'Side 1', 'Side 2', 'Status'],
        group.rows.map(r => [r.time || '', r.label, r.side1, r.side2, r.status ?? ''])
      )).join('');
      openPrintableReport(`${event?.name ?? 'Event'} Order of Play`, body);
    } catch (error) { window.alert(friendlyError(error).message); }
  };
  const downloadCalendar = () => {
    const bouts = ordered.filter(involves).flatMap(m => {
      const slot = slotByMatch.get(m.id);
      return slot ? [{ id: m.id, title: `${m.label}: ${side(m, 1)} vs ${side(m, 2)}`, startsAt: slot.startsAt, endsAt: slot.endsAt, location: [areaName(m.fightCardId), event?.venue].filter(Boolean).join(' · '), description: `${event?.name ?? ''} (planned time)` }] : [];
    });
    downloadText('buhurtos-my-bouts.ics', buildBoutsIcs(bouts, filters.q.trim() ? `${filters.q.trim()} at ${event?.name ?? 'the event'}` : `${event?.name ?? 'Event'} order of play`), 'text/calendar;charset=utf-8');
  };
  const copySchedule = async () => {
    try {
      await navigator.clipboard.writeText(scheduleAsText(`${event?.name ?? 'Event'} order of play`, rows));
      setCopied('Copied. Paste it into your group chat or post.');
    } catch { setCopied('Could not copy. Use Print / PDF instead.'); }
    setTimeout(() => setCopied(''), 4000);
  };

  const empty = matches.length === 0;
  const withTimes = ordered.some(m => clock(m));

  return <>
    <section className="section-head"><div><span className="eyebrow">Schedule</span><h1>Bracket &amp; schedule</h1>
      <p>{empty ? 'Nothing has been generated yet.' : `${played.length} of ${ordered.length} bouts finished.${withTimes ? ' Times are the plan; the order of play adjusts as bouts finish.' : ''}`}</p></div>
      <div className="header-actions"><button type="button" onClick={() => downloadText('buhurtos-order-of-play.csv', matchesCsv(ordered))}>Export CSV</button><button type="button" onClick={copySchedule}>Copy as text</button>{withTimes ? <button type="button" onClick={downloadCalendar}>{filters.q.trim() ? 'Add these bouts to my calendar' : 'Add all to calendar'}</button> : null}<button type="button" onClick={printOrder}>Print / PDF</button></div></section>

    {empty ? <div className="state-card"><strong>No tournament yet</strong><p>Build one in a few steps: choose the competitors, pick a format (BuhurtOS suggests one for your field size), and plan times and fighting areas.</p><Link className="primary big" to={'/admin/events/tools?event=' + (event?.id ?? '')} style={{display:'inline-flex',alignItems:'center',justifyContent:'center',textDecoration:'none',padding:'0 18px'}}>Build tournament</Link></div> : <>
      {copied ? <p className="auth-message" role="status">{copied}</p> : null}
      {behind > 0 ? <p className="tp-warning" role="status">The day is running about {behind} minutes behind the plan: the next bout was planned for {eventClock(nextSlot!.startsAt, timezone)}. Planned times are not changed automatically. Tell fighters and adjust the order if needed.</p> : null}
      <div className="bp-controls">
        <div className="directory-view-switch" role="group" aria-label="Schedule view">
          <button type="button" className={view === 'play' ? 'selected' : ''} aria-pressed={view === 'play'} onClick={() => setFilters({ view: 'play' })}>Order of play</button>
          {hasPools ? <button type="button" className={view === 'pools' ? 'selected' : ''} aria-pressed={view === 'pools'} onClick={() => setFilters({ view: 'pools' })}>Pools</button> : null}
          {hasBracket ? <button type="button" className={view === 'bracket' ? 'selected' : ''} aria-pressed={view === 'bracket'} onClick={() => setFilters({ view: 'bracket' })}>Bracket</button> : null}
        </div>
        <div className="show-filter-row">
          <label className="show-search grow"><span>⌕</span><input type="search" aria-label="Find a fighter or team" value={filters.q} onChange={e => setFilters({ q: e.target.value })} placeholder="Find a fighter or team" /></label>
          {live.length > 1 ? <select aria-label="Tournament" value={bracketId} onChange={e => setFilters({ bracket: e.target.value })}><option value="all">All tournaments</option>{live.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}</select> : null}
          {fightCards.length > 1 ? <select aria-label="Fighting area" value={areaId} onChange={e => setFilters({ area: e.target.value })}><option value="all">All areas</option>{fightCards.filter(c => c.status !== 'archived').map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select> : null}
        </div>
      </div>

      {view === 'play' ? <ol className="bp-play">{shown.length === 0 ? <li className="state-card">No bouts match that search. Try part of a fighter’s name or a team name.</li> : null}{shown.map(match => {
        const when = clock(match);
        const won = match.resultSummary?.winnerSide;
        return <li key={match.id} className={'bp-row status-' + match.status + (match.id === nextUpId ? ' next-up' : '')}>
          <div className="bp-when"><b>{when || `#${match.scheduledOrder}`}</b><small>{areaName(match.fightCardId) || 'Unassigned'}</small></div>
          <div className="bp-what"><small>{match.label} · {match.category}</small>
            <div className={won === 1 ? 'winner' : ''}>{side(match, 1)}{match.resultSummary && won !== undefined ? <strong>{match.resultSummary.side1Total}</strong> : null}</div>
            <div className={won === 2 ? 'winner' : ''}>{side(match, 2)}{match.resultSummary && won !== undefined ? <strong>{match.resultSummary.side2Total}</strong> : null}</div>
          </div>
          <span className={'bp-status ' + match.status}>{match.id === nextUpId && match.status === 'scheduled' ? 'Next up' : statusLabel[match.status] ?? match.status}</span>
        </li>;
      })}</ol> : null}

      {view === 'pools' ? <div className="bp-pools">{poolBracketIds.map(id => {
        const state = computePoolQualificationState(matches, roster, id, 2);
        const poolBouts = matches.filter(m => m.bracketId === id && m.stage === 'pool' && m.status !== 'cancelled');
        const done = poolBouts.length - state.incompleteMatchIds.length;
        const hasPlayoff = brackets.some(b => b.generationState === 'published' && b.sourcePoolBracketId === id);
        return [<section key={id + '-progress'} className="bp-progress panel-card" role="status">
          <strong>{done} of {poolBouts.length} pool bouts finished</strong>
          <progress max={poolBouts.length} value={done} aria-label="Pool stage progress" />
          {hasPlayoff ? <span>The playoff has been created. See the Order of play or Bracket view for its times.</span> : state.ready ? <span>All pools are done. <Link to={'/admin/events/tools?event=' + (event?.id ?? '')}>Create the playoff</Link> (it is scheduled automatically).</span> : <span>The playoff can be created once every pool bout is final.</span>}
        </section>, ...state.pools.map(pool => <section key={id + pool.name} className="panel-card">
          <h2>{pool.name}</h2>
          <div className="table-wrap"><table><thead><tr><th>#</th><th>Competitor</th><th>W-L-D</th><th>Diff</th><th>Pts</th></tr></thead>
            <tbody>{pool.standings.map((row, index) => <tr key={row.rosterEntryId} className={index < 2 ? 'bp-advances' : ''}><td>{index + 1}</td><td>{row.name}</td><td>{row.wins}-{row.losses}-{row.draws}</td><td>{row.differential > 0 ? '+' : ''}{row.differential}</td><td>{row.standingPoints}</td></tr>)}</tbody></table></div>
          <small className="tp-note">Top two advance (highlighted). Ties are broken by the tiebreak policy saved with this tournament.</small>
        </section>)];
      })}</div> : null}

      {view === 'bracket' ? <div className="bracket-scroll"><div className="bracket-grid">{rounds.map(group => <section className="bracket-round" key={group.round}>
        <h2>{group.round === rounds.length ? 'Final' : `Round ${group.round}`}</h2>
        {group.matches.map(match => <article className="bracket-match" key={match.id}><span>{match.label}{clock(match) ? ` · ${clock(match)}` : ''}</span>
          {[1, 2].map(index => <div className={match.resultSummary?.winnerSide === index ? 'winner' : ''} key={index}><b>{side(match, index as 1 | 2)}</b>{match.resultSummary && match.resultSummary.winnerSide != null ? <strong>{index === 1 ? match.resultSummary.side1Total : match.resultSummary.side2Total}</strong> : null}</div>)}
        </article>)}
      </section>)}</div></div> : null}
    </>}
  </>;
}
