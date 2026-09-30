import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { listTournamentBrackets, type TournamentBracketSummary } from '../lib/adminActions';
import { computePoolQualificationState } from '../lib/bracket';
import { groupBracketRounds } from '../lib/bracketView';
import { eventClock } from '../lib/eventTime';
import { downloadText, htmlTable, matchesCsv, openPrintableReport } from '../lib/export';
import { useQueryStates } from '../lib/urlState';
import type { MatchRecord } from '../types';

type View = 'play' | 'pools' | 'bracket';

const statusLabel: Record<string, string> = {
  scheduled: 'Scheduled', on_deck: 'On deck', in_the_hole: 'Next up', active: 'Fighting now', completed: 'Needs result', finalized: 'Final', forfeit: 'Forfeit', cancelled: 'Cancelled'
};

/** Order of play, pool tables and the knockout bracket for the event, one tournament at a time. */
export function BracketPage() {
  const { matches, roster, event, fightCards } = useAppState();
  const [brackets, setBrackets] = useState<TournamentBracketSummary[]>([]);
  const [filters, setFilters] = useQueryStates({ view: '', bracket: 'all', area: 'all' });

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
    const map = new Map<string, { startsAt: string; order: number }>();
    for (const item of live) for (const slot of item.schedule?.slots ?? []) map.set(slot.matchId, { startsAt: slot.startsAt, order: slot.order });
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

  const poolBracketIds = useMemo(() => [...new Set(scoped.filter(m => m.stage === 'pool' && m.bracketId).map(m => m.bracketId!))], [scoped]);
  const rounds = groupBracketRounds(scoped.filter(m => m.stage !== 'pool'));
  const hasPools = poolBracketIds.length > 0;
  const hasBracket = rounds.length > 0;
  const requested = (filters.view || '') as View;
  const view: View = requested === 'pools' && hasPools ? 'pools' : requested === 'bracket' && hasBracket ? 'bracket' : requested === 'play' ? 'play' : hasBracket && !hasPools && !requested ? 'bracket' : hasPools && !requested ? 'pools' : 'play';

  const printOrder = () => {
    try {
      openPrintableReport(`${event?.name ?? 'Event'} Order of Play`, htmlTable(
        ['Order', 'Time', 'Area', 'Match', 'Category', 'Side 1', 'Side 2', 'Status', 'Winner'],
        ordered.map(m => [
          slotByMatch.get(m.id)?.order ?? m.scheduledOrder, clock(m) || '', areaName(m.fightCardId), m.label, m.category, side(m, 1), side(m, 2),
          statusLabel[m.status] ?? m.status, m.resultSummary?.winnerSide === 1 ? side(m, 1) : m.resultSummary?.winnerSide === 2 ? side(m, 2) : ''
        ])
      ));
    } catch (error) { window.alert(error instanceof Error ? error.message : 'Unable to open the printable report.'); }
  };

  const empty = matches.length === 0;
  const withTimes = ordered.some(m => clock(m));

  return <>
    <section className="section-head"><div><span className="eyebrow">Schedule</span><h1>Bracket &amp; schedule</h1>
      <p>{empty ? 'Nothing has been generated yet.' : `${played.length} of ${ordered.length} bouts finished.${withTimes ? ' Times are the plan; the order of play adjusts as bouts finish.' : ''}`}</p></div>
      <div className="header-actions"><button type="button" onClick={() => downloadText('buhurtos-order-of-play.csv', matchesCsv(ordered))}>Export CSV</button><button type="button" onClick={printOrder}>Print / PDF</button></div></section>

    {empty ? <div className="state-card"><strong>No tournament yet</strong><p>Build one in a few steps: choose the competitors, pick a format (BuhurtOS suggests one for your field size), and plan times and fighting areas.</p><Link className="primary big" to={'/admin/events/tools?event=' + (event?.id ?? '')} style={{display:'inline-flex',alignItems:'center',justifyContent:'center',textDecoration:'none',padding:'0 18px'}}>Build tournament</Link></div> : <>
      <div className="bp-controls">
        <div className="directory-view-switch" role="group" aria-label="Schedule view">
          <button type="button" className={view === 'play' ? 'selected' : ''} aria-pressed={view === 'play'} onClick={() => setFilters({ view: 'play' })}>Order of play</button>
          {hasPools ? <button type="button" className={view === 'pools' ? 'selected' : ''} aria-pressed={view === 'pools'} onClick={() => setFilters({ view: 'pools' })}>Pools</button> : null}
          {hasBracket ? <button type="button" className={view === 'bracket' ? 'selected' : ''} aria-pressed={view === 'bracket'} onClick={() => setFilters({ view: 'bracket' })}>Bracket</button> : null}
        </div>
        <div className="show-filter-row">
          {live.length > 1 ? <select aria-label="Tournament" value={bracketId} onChange={e => setFilters({ bracket: e.target.value })}><option value="all">All tournaments</option>{live.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}</select> : null}
          {fightCards.length > 1 ? <select aria-label="Fighting area" value={areaId} onChange={e => setFilters({ area: e.target.value })}><option value="all">All areas</option>{fightCards.filter(c => c.status !== 'archived').map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select> : null}
        </div>
      </div>

      {view === 'play' ? <ol className="bp-play">{ordered.map(match => {
        const when = clock(match);
        const won = match.resultSummary?.winnerSide;
        return <li key={match.id} className={'bp-row status-' + match.status}>
          <div className="bp-when"><b>{when || `#${match.scheduledOrder}`}</b><small>{areaName(match.fightCardId) || 'Unassigned'}</small></div>
          <div className="bp-what"><small>{match.label} · {match.category}</small>
            <div className={won === 1 ? 'winner' : ''}>{side(match, 1)}{match.resultSummary && won !== undefined ? <strong>{match.resultSummary.side1Total}</strong> : null}</div>
            <div className={won === 2 ? 'winner' : ''}>{side(match, 2)}{match.resultSummary && won !== undefined ? <strong>{match.resultSummary.side2Total}</strong> : null}</div>
          </div>
          <span className={'bp-status ' + match.status}>{statusLabel[match.status] ?? match.status}</span>
        </li>;
      })}</ol> : null}

      {view === 'pools' ? <div className="bp-pools">{poolBracketIds.map(id => {
        const state = computePoolQualificationState(matches, roster, id, 2);
        return state.pools.map(pool => <section key={id + pool.name} className="panel-card">
          <h2>{pool.name}</h2>
          <div className="table-wrap"><table><thead><tr><th>#</th><th>Competitor</th><th>W-L-D</th><th>Diff</th><th>Pts</th></tr></thead>
            <tbody>{pool.standings.map((row, index) => <tr key={row.rosterEntryId} className={index < 2 ? 'bp-advances' : ''}><td>{index + 1}</td><td>{row.name}</td><td>{row.wins}-{row.losses}-{row.draws}</td><td>{row.differential > 0 ? '+' : ''}{row.differential}</td><td>{row.standingPoints}</td></tr>)}</tbody></table></div>
          <small className="tp-note">Top two advance (highlighted). Ties are broken by the tiebreak policy saved with this tournament.</small>
        </section>);
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
