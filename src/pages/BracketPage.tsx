import { useAppState } from '../features/AppState';
import { groupBracketRounds } from '../lib/bracketView';
import { downloadText, htmlTable, matchesCsv, openPrintableReport } from '../lib/export';

export function BracketPage() {
  const { matches, roster, event } = useAppState();
  const rounds = groupBracketRounds(matches);
  const name = (id?: string, placeholder?: string) => roster.find(r => r.id === id)?.displayName ?? placeholder ?? 'TBD';
  const printOrder = () => {
    const sorted = [...matches].sort((a, b) => a.scheduledOrder - b.scheduledOrder);
    return openPrintableReport(
      `${event?.name ?? 'Event'} Order of Play`,
      htmlTable(
        ['Order', 'Label', 'Category', 'Side 1', 'Side 2', 'Status', 'Winner'],
        sorted.map(m => {
          const p1 = m.participants.find(x => x.sideIndex === 1);
          const p2 = m.participants.find(x => x.sideIndex === 2);
          return [m.scheduledOrder, m.label, m.category, name(p1?.rosterEntryId, p1?.placeholderLabel), name(p2?.rosterEntryId, p2?.placeholderLabel), m.status, m.resultSummary?.winnerSide === 1 ? 'Side 1' : m.resultSummary?.winnerSide === 2 ? 'Side 2' : ''];
        })
      )
    );
  };
  return <>
    <section className="section-head"><div><span className="eyebrow">Bracket</span><h1>Live Progression</h1><p>Winner links are relational, so completed results advance without rewriting bracket history.</p></div><div className="header-actions"><button onClick={() => downloadText('buhurtos-order-of-play.csv', matchesCsv(matches))}>Export CSV</button><button onClick={printOrder}>Print / PDF</button></div></section>
    <div className="bracket-scroll"><div className="bracket-grid">{rounds.map(group => <section className="bracket-round" key={group.round}><h2>{group.round === rounds.length ? 'Final' : `Round ${group.round}`}</h2>{group.matches.map(match => <article className="bracket-match" key={match.id}><span>{match.label}</span>{[1,2].map(side => { const p = match.participants.find(x => x.sideIndex === side); return <div className={match.resultSummary?.winnerSide === side ? 'winner' : ''} key={side}><b>{name(p?.rosterEntryId, p?.placeholderLabel)}</b>{match.resultSummary && <strong>{side === 1 ? match.resultSummary.side1Total : match.resultSummary.side2Total}</strong>}</div>; })}</article>)}</section>)}</div></div>
  </>;
}
