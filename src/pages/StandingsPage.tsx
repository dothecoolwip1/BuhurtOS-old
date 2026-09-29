import { useState } from 'react';
import { useAppState } from '../features/AppState';
import { computeEventStandings } from '../lib/standings';
import { downloadText, openPrintableReport, standingsCsv } from '../lib/export';
import { widgetEmbedCode, widgetStandingsUrl } from '../lib/embed';

export function StandingsPage() {
  const { event, matches, roster } = useAppState();
  const [embedMessage, setEmbedMessage] = useState('');
  if (!event) return null;
  const rows = computeEventStandings(event, matches, roster);
  const embedCode = widgetEmbedCode(widgetStandingsUrl(), { title: `${event.name} standings` });
  const print = () => openPrintableReport(`${event.name} Standings`, `<table><thead><tr><th>Rank</th><th>Competitor</th><th>W</th><th>L</th><th>D</th><th>Pts</th></tr></thead><tbody>${rows.map((r,i) => `<tr><td>${i+1}</td><td>${r.name}</td><td>${r.wins}</td><td>${r.losses}</td><td>${r.draws}</td><td>${r.standingPoints}</td></tr>`).join('')}</tbody></table>`);
  const copyEmbed = async () => {
    try {
      await navigator.clipboard.writeText(embedCode);
      setEmbedMessage('Standings widget embed code copied. Paste it into any page that allows iframes.');
    } catch {
      setEmbedMessage('Copying is unavailable in this browser — select the snippet below manually.');
    }
  };
  return <>
    <section className="section-head"><div><span className="eyebrow">{event.standingsMode.replaceAll('_',' ')}</span><h1>Standings</h1><p>Only finalized matches from standings-enabled events are counted.</p></div><div className="header-actions"><button onClick={() => downloadText('buhurtos-standings.csv', standingsCsv(rows))}>Export CSV</button><button onClick={print}>Print / PDF</button><button onClick={copyEmbed}>Embed widget</button></div></section>
    {rows.length === 0 ? <div className="state-card">This event is configured with no standings, or no finalized matches exist yet.</div> : <div className="table-wrap"><table><thead><tr><th>#</th><th>Competitor</th><th>W</th><th>L</th><th>D</th><th>PF</th><th>PA</th><th>Diff</th><th>Pts</th></tr></thead><tbody>{rows.map((r,i) => <tr key={r.rosterEntryId}><td>{i+1}</td><td><strong>{r.name}</strong></td><td>{r.wins}</td><td>{r.losses}</td><td>{r.draws}</td><td>{r.pointsFor}</td><td>{r.pointsAgainst}</td><td>{r.differential}</td><td><b>{r.standingPoints}</b></td></tr>)}</tbody></table></div>}
    {embedMessage ? <div className="auth-message">{embedMessage}</div> : null}
    <details className="embed-block">
      <summary>Embed this standings board as a widget</summary>
      <p className="field-hint">Paste the snippet into any page that allows iframes (WordPress via a Custom HTML block, Notion, GitHub Pages, etc.). The widget renders live from the event board and labels itself DEMO DATA when it is showing sample content.</p>
      <pre className="embed-code"><code>{embedCode}</code></pre>
      <a className="show-btn secondary" href={widgetStandingsUrl()} target="_blank" rel="noopener noreferrer">Preview widget ↗</a>
    </details>
  </>;
}