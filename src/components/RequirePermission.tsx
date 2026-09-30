import { Link } from 'react-router-dom';
import type { ReactNode } from 'react';
import type { Permission } from '../lib/permissions';
import { hasPermission } from '../lib/permissions';
import { useAppState } from '../features/AppState';
import { StateBlock } from './page';

/**
 * Guards an event-scoped admin page. The database enforces the real permission; this explains the outcome
 * instead of silently redirecting, and always offers a way forward.
 */
export function RequirePermission({ permission, children }: { permission: Permission; children: ReactNode }) {
  const { user, event, error } = useAppState();
  if (!event && error) {
    return <StateBlock kind="error" title="No event is available to work on">
      {error} <Link to="/admin/events/setup">Create or publish an event</Link> or <Link to="/admin">go back to the overview</Link>.
    </StateBlock>;
  }
  if (!event) return <StateBlock kind="loading" title="Loading your access…" />;
  if (!hasPermission(user, permission, event.id, event.organizationId)) {
    return <StateBlock kind="empty" title="This page is not available for your role">
      You are working on <strong>{event.name}</strong>, and your role there does not include this tool. If you think you should have access,
      ask the event organizer or the platform owner. <Link to="/admin">Back to the overview</Link>
    </StateBlock>;
  }
  return <>{children}</>;
}
