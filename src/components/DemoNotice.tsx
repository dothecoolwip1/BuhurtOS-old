import { Link } from 'react-router-dom';

/**
 * Persistent disambiguation banner for showcase/prototype surfaces.
 *
 * Showcase pages render sample data so the product can be explored without a
 * configured event. That content must never be mistaken for live tournament
 * data: every showcase route carries this banner, and the emotional "LIVE"
 * claims elsewhere in those pages are titled as demo/sample instead.
 */
export function DemoNotice({ compact = false }: { compact?: boolean }) {
  return (
    <div className={compact ? 'demo-notice compact' : 'demo-notice'} role="note">
      <span className="demo-notice-mark" aria-hidden="true">◈</span>
      <div className="demo-notice-body">
        <b>Interactive demo — sample data only.</b>
        <p>Scores, brackets, standings and rosters shown here are sample content, not a live event. Open the live event view for real tournament data.</p>
      </div>
      <Link className="demo-notice-cta" to="/live">Open live event view →</Link>
    </div>
  );
}