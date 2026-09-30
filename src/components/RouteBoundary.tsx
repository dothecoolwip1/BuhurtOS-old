import { Component, type ErrorInfo, type ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';

type Props = { children: ReactNode; resetKey: string };
type State = { failed: boolean; message: string };

/**
 * Catches a page that fails to load or render (most often a lazy chunk that is gone after an update, or an offline first visit)
 * so the visitor gets a way forward instead of a blank screen.
 */
class Boundary extends Component<Props, State> {
  state: State = { failed: false, message: '' };

  static getDerivedStateFromError(error: unknown): State {
    return { failed: true, message: error instanceof Error ? error.message : String(error) };
  }

  componentDidUpdate(previous: Props) {
    if (this.state.failed && previous.resetKey !== this.props.resetKey) this.setState({ failed: false, message: '' });
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Route failed', error, info.componentStack);
  }

  render() {
    if (!this.state.failed) return this.props.children;
    const chunk = /dynamically imported module|Loading chunk|Failed to fetch|Importing a module script failed/i.test(this.state.message);
    return <main className="auth-shell" id="main-content"><section className="auth-card" role="alert">
      <span className="eyebrow">BuhurtOS</span>
      <h1>This page could not be shown</h1>
      <p>{chunk
        ? 'The page could not be downloaded. You may be offline, or BuhurtOS was updated while this tab was open. Reloading usually fixes it.'
        : 'Something went wrong while drawing this page. Nothing you entered elsewhere has been lost.'}</p>
      <button type="button" className="primary big" onClick={() => window.location.reload()}>Reload the page</button>
      <p className="auth-back"><Link to="/public">← Back to the public site</Link></p>
    </section></main>;
  }
}

export function RouteBoundary({ children }: { children: ReactNode }) {
  const location = useLocation();
  return <Boundary resetKey={location.pathname}>{children}</Boundary>;
}

/** A page that does not exist: says so, instead of silently redirecting somewhere else. */
export function NotFoundPage() {
  const location = useLocation();
  return <main className="auth-shell" id="main-content"><section className="auth-card">
    <span className="eyebrow">Page not found</span>
    <h1>There is nothing at this address</h1>
    <p>The link may be old, mistyped, or for something that was removed. <code>{location.pathname}</code></p>
    <div className="show-actions">
      <Link className="show-btn primary" to="/public">Go to the public site</Link>
      <Link className="show-btn secondary" to="/events">Browse events</Link>
      <Link className="show-btn secondary" to="/teams">Browse teams</Link>
    </div>
    <p className="auth-back"><Link to="/me">My workspace</Link></p>
  </section></main>;
}
