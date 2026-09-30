import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';

/** Page title: where am I, what matters, what can I do next. */
export function PageTitle({ title, lead, actions }: { title: string; lead?: string; actions?: ReactNode }) {
  return <header className="nx-title">
    <div><h1>{title}</h1>{lead ? <p>{lead}</p> : null}</div>
    {actions ? <div className="nx-title-actions">{actions}</div> : null}
  </header>;
}

export function Card({ title, lead, children, actions }: { title?: string; lead?: string; children: ReactNode; actions?: ReactNode }) {
  return <section className="nx-card">
    {title || actions ? <div className="nx-card-head"><div>{title ? <h2>{title}</h2> : null}{lead ? <p>{lead}</p> : null}</div>{actions}</div> : null}
    {children}
  </section>;
}

/** A failed request is shown as a failure, never as an empty list. */
export function StateBlock({ kind, title, children }: { kind: 'loading' | 'error' | 'empty'; title: string; children?: ReactNode }) {
  return <div className={'nx-state ' + kind} role={kind === 'error' ? 'alert' : 'status'}><strong>{title}</strong>{children ? <p>{children}</p> : null}</div>;
}

export function LinkCard({ to, title, text, badge }: { to: string; title: string; text: string; badge?: string }) {
  return <Link className="nx-linkcard" to={to}><strong>{title}{badge ? <em>{badge}</em> : null}</strong><span>{text}</span><i aria-hidden="true">→</i></Link>;
}
