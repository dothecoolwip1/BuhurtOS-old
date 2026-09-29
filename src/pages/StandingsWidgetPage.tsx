import { useAppState } from '../features/AppState';
import { computeEventStandings } from '../lib/standings';

/**
 * Embeddable standings widget.
 *
 * A chrome-free surface rendered straight from the live event board so the
 * embed never shows more than the page that publishes it. In the default (demo)
 * build the data is the demo event and is labeled "DEMO DATA"; when a real
 * Supabase event is configured the widget renders that event's published
 * standings instead.
 */
export function StandingsWidgetPage() {
  const { loading, event, matches, roster, dataMode } = useAppState();
  if (loading) return <div className="widget-shell"><div className="widget-state">Loading standings…</div></div>;
  if (!event) return <div className="widget-shell"><div className="widget-state">No event data available.</div></div>;
  const rows = computeEventStandings(event, matches, roster);
  return (
    <div className="widget-shell">
      <div className="widget-head">
        <div>
          <strong>{event.name}</strong>
          <span>Standings • {event.standingsMode.replaceAll('_', ' ')}</span>
        </div>
        {dataMode === 'demo' ? <span className="widget-demo-badge">DEMO DATA</span> : null}
      </div>
      {rows.length === 0 ? (
        <div className="widget-state">No finalized matches have standings yet.</div>
      ) : (
        <table className="widget-table">
          <thead>
            <tr><th>#</th><th>Competitor</th><th>W</th><th>L</th><th>D</th><th>Pts</th></tr>
          </thead>
          <tbody>
            {rows.map((r, i) => (
              <tr key={r.rosterEntryId}>
                <td>{i + 1}</td>
                <td><strong>{r.name}</strong></td>
                <td>{r.wins}</td>
                <td>{r.losses}</td>
                <td>{r.draws}</td>
                <td><b>{r.standingPoints}</b></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      <div className="widget-foot">Powered by BuhurtOS</div>
    </div>
  );
}