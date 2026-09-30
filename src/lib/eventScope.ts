import type { UserContext } from '../types';
import { supabase } from './supabase';

/**
 * The event an administrator is working on is an explicit choice: it lives in the address (?event=<id>) so
 * refresh, Back/Forward and shared links keep it, and is remembered for the session as a fallback when a
 * link omits it. It is never silently replaced by "whatever event is newest" once chosen.
 */
const STORAGE_KEY = 'nx:event';

function store(): Storage | undefined {
  try { return typeof sessionStorage === 'undefined' ? undefined : sessionStorage; } catch { return undefined; }
}

export function rememberEvent(id: string, target: Pick<Storage, 'setItem' | 'removeItem'> | undefined = store()): void {
  if (!target) return;
  if (id) target.setItem(STORAGE_KEY, id); else target.removeItem(STORAGE_KEY);
}

export function recallEvent(target: Pick<Storage, 'getItem'> | undefined = store()): string {
  return target?.getItem(STORAGE_KEY) ?? '';
}

/** Adds (or replaces) the event parameter on an in-app path, keeping any other query parameters. */
export function withEventParam(path: string, eventId: string | undefined | null): string {
  if (!eventId) return path;
  const [base, query = ''] = path.split('?');
  const params = new URLSearchParams(query);
  params.set('event', eventId);
  return `${base}?${params.toString()}`;
}

/** Reads ?event= from a hash route such as "#/admin/events/roster?event=abc". */
export function eventParamFromHash(hash: string): string {
  const index = hash.indexOf('?');
  if (index < 0) return '';
  return new URLSearchParams(hash.slice(index + 1)).get('event') ?? '';
}

export interface SelectableEvent {
  id: string;
  name: string;
  startsAt: string;
  status: string;
  organizationId: string;
}

/** Events this person may work on: owner all, organization admins their organizations' events, others events they hold a role in. */
export function filterWorkableEvents(user: UserContext | null, events: SelectableEvent[]): SelectableEvent[] {
  if (!user) return [];
  if (user.platformRoles.includes('platform_super_admin')) return events;
  const adminOrgs = new Set(user.organizationRoles.filter(role => role.role === 'organization_admin').map(role => role.organizationId));
  const roleEvents = new Set(user.eventRoles.map(role => role.eventId));
  return events.filter(event => adminOrgs.has(event.organizationId) || roleEvents.has(event.id));
}

export async function listWorkableEvents(user: UserContext | null): Promise<SelectableEvent[]> {
  if (!supabase || !user) return [];
  const { data, error } = await supabase.from('events').select('id,name,starts_at,status,organization_id').order('starts_at', { ascending: false }).limit(300);
  if (error) throw error;
  return filterWorkableEvents(user, (data ?? []).map((row: any) => ({
    id: row.id, name: row.name, startsAt: row.starts_at, status: row.status, organizationId: row.organization_id
  })));
}

/** True for admin pages that act on a single event. */
export function isEventScopedPath(pathname: string): boolean {
  if (!pathname.startsWith('/admin/events/')) return false;
  return !pathname.startsWith('/admin/events/setup') && !pathname.startsWith('/admin/events/all');
}
