import { useState } from 'react';
import { useAppState } from '../features/AppState';
import { computeEventStandings, computeTeamStandings } from '../lib/standings';
import { downloadText, openPrintableReport, standingsCsv, teamStandingsCsv } from '../lib/export';
import { widgetEmbedCode, widgetStandingsUrl } from '../lib/embed';

type StandingsView = 'fighters' | 'teams';

export function StandingsPage() {
  const { event, matches, roster, teams } = useAppState();
  const [view, setView] = useState<StandingsView>('fighters');
  const [embedMessage, setEmbedMessage] = useState('');
  if (!event) return null;
  const fighterRows = computeEventStandings(event, matches, roster);
  const teamRows = computeTeamStandings(event, matches, roster, teams);
  const hasTeams = teams.length > 0;
  const activeView: StandingsView = view === 'teams' && !hasTeams ? 'fighters' : view;
  const shownRows = activeView === 'teams' ? teamRows : fighterRows;
  const embedCode = widgetEmbedCode(widgetStandingsUrl(), { title: `${event.name} standings` });
  const print = () => openPrintableReport(`${event.name} ${activeView === 'teams' ? 'Team' : ''} Standings`, `<table><thead><tr><th>Rank</th><th>${activeView === 'teams' ? 'Team' : 'Competitor'}</th><th>W</th><th>L</th><th>D</th><th>Pts</th></tr></thead><tbody>${shownRows.map((r: any, i) => `<tr><td>${i+1}</td><td>${r.name}</td><td>${r.wins}</td><td>${r.losses}</td><td>${r.draws}</td><td>${r.standingPoints}</td></tr>`).join('')}</tbody></table>`);
  const exportCsv = () => downloadText(
    activeView === 'teams' ? 'buhurtos-team-standings.csv' : 'buhurtos-standings.csv',
    activeView === 'teams' ? teamStandingsCsv(teamRows) : standingsCsv(fighterRows)
  );
  const copyEmbed = async () => {
    try {
      await navigator.clipboard.writeText(embedCode);
      setEmbedMessage('Standings widget embed code copied. Paste it into any page that allows iframes.');
    } catch {
      setEmbedMessage('Copying is unavailable in this browser — select the snippet below manually.');
    }
  };
  return <>
    <section className="section-head"><div><span className="eyebrow">{event.standingsMode.replaceAll('_',' ')}</span><h1>Standings</h1><p>Only finalized matches from standings-enabled events are counted. The team board aggregates fighter bouts between opposing teams.</p></div><div className="header-actions"><button onClick={exportCsv}>Export CSV</button><button onClick={print}>Print / PDF</button><button onClick={copyEmbed}>Embed widget</button></div></section>
    {hasTeams && <div className="field-tabs standings-view-toggle" role="tablist" aria-label="Standings view"><button className={activeView==='fighters'?'selected':''} onClick={()=>setView('fighters')}><b>Fighters</b></button><button className={activeView==='teams'?'selected':''} onClick={()=>setView('teams')}><b>Teams</b></button></div>}
    {shownRows.length === 0 ? <div className="state-card">{event.standingsMode === 'no_standings' ? 'This event is configured with no standings.' : activeView === 'teams' ? 'No finalized team-vs-team bouts yet. Intramural or unaffiliated bouts earn neither team any points.' : 'This event is configured with no standings, or no finalized matches exist yet.'}</div> : <div className="table-wrap"><table><thead><tr><th>#</th><th>{activeView === 'teams' ? 'Team' : 'Competitor'}</th>{activeView === 'teams' ? <th>Ftrs</th> : null}<th>W</th><th>L</th><th>D</th><th>PF</th><th>PA</th><th>Diff</th><th>Pts</th></tr></thead><tbody>{shownRows.map((r: any, i) => <tr key={activeView === 'teams' ? r.teamId : r.rosterEntryId}><td>{i+1}</td><td><strong>{r.name}</strong></td>{activeView === 'teams' ? <td>{r.fighters}</td> : null}<td>{r.wins}</td><td>{r.losses}</td><td>{r.draws}</td><td>{r.pointsFor}</td><td>{r.pointsAgainst}</td><td>{r.differential}</td><td><b>{r.standingPoints}</b></td></tr>)}</tbody></table></div>}
    {embedMessage ? <div className="auth-message">{embedMessage}</div> : null}
    <details className="embed-block">
      <summary>Embed this standings board as a widget</summary>
      <p className="field-hint">Paste the snippet into any page that allows iframes (WordPress via a Custom HTML block, Notion, GitHub Pages, etc.). The widget renders live from the event board and labels itself DEMO DATA when it is showing sample content.</p>
      <pre className="embed-code"><code>{embedCode}</code></pre>
      <a className="show-btn secondary" href={widgetStandingsUrl()} target="_blank" rel="noopener noreferrer">Preview widget ↗</a>
    </details>
  </>;
}