import { supabase } from './supabase';

/**
 * Registration access is decided by the database (private.registration_eligibility). This module only asks
 * and renders; it never infers eligibility itself.
 */
export type RegistrationAccessState =
  | 'eligible'
  | 'code_required'
  | 'permission_requested'
  | 'permission_granted'
  | 'denied'
  | 'already_registered'
  | 'registration_closed'
  | 'membership_unverified'
  | 'error';

export type RegistrationAccessScope = 'invite_only' | 'host_team' | 'organization' | 'organization_tree' | 'open';

export const scopeLabels: Record<RegistrationAccessScope, { label: string; help: string }> = {
  invite_only: { label: 'Signup code always required', help: 'Everyone needs a signup code, including members of the host organization.' },
  host_team: { label: 'Host team members', help: 'Fighters on the host team register without a code. Everyone else needs a code.' },
  organization: { label: 'Organization members', help: 'Fighters on any team in the host organization register without a code.' },
  organization_tree: { label: 'Organization and its teams and clubs', help: 'Fighters in the host organization, and in every organization it governs, register without a code.' },
  open: { label: 'Any signed-in fighter profile', help: 'Any signed-in fighter with a BuhurtOS fighter profile registers without a code.' }
};

export interface RegistrationAccess {
  state: RegistrationAccessState;
  scope?: RegistrationAccessScope;
  teamId?: string;
  requestId?: string;
}

export interface RegistrationAccessCopy {
  title: string;
  body: string;
  /** What the primary control should do next. */
  next: 'continue' | 'enter_code' | 'request_or_code' | 'none';
}

/** Plain-language copy for each server-decided state. */
export function describeAccess(state: RegistrationAccessState): RegistrationAccessCopy {
  switch (state) {
    case 'eligible':
      return { title: 'Your BuhurtOS fighter profile is eligible for this event.', body: 'You do not need a signup code.', next: 'continue' };
    case 'permission_granted':
      return { title: 'The organizers approved your request.', body: 'You can continue registration without a signup code.', next: 'continue' };
    case 'membership_unverified':
      return { title: 'We could not verify registration access for your fighter profile.', body: 'Ask the organizers for permission, or use a signup code if you have one.', next: 'request_or_code' };
    case 'permission_requested':
      return { title: 'Your request is waiting for the organizers.', body: 'You will get a notification in BuhurtOS when they answer. You can also use a signup code if you have one.', next: 'enter_code' };
    case 'denied':
      return { title: 'The organizers did not approve your request.', body: 'You can still register with a signup code, or contact the organizer.', next: 'enter_code' };
    case 'already_registered':
      return { title: 'You have already submitted a signup for this event.', body: 'The organizers will follow up using the contact details you gave.', next: 'none' };
    case 'registration_closed':
      return { title: 'Registration is not open for this event.', body: 'Check the event page for dates, or contact the organizer.', next: 'none' };
    case 'error':
      return { title: 'We could not check your registration access.', body: 'Try again, or use a signup code if you have one.', next: 'enter_code' };
    case 'code_required':
    default:
      return { title: 'Enter your event registration code.', body: 'Ask the organizers or your team captain for a signup code for this event.', next: 'enter_code' };
  }
}

export async function getEventRegistrationAccess(eventId: string): Promise<RegistrationAccess> {
  if (!supabase) return { state: 'code_required' };
  const { data: session } = await supabase.auth.getSession();
  // Signed-out visitors always use the code flow; the server only answers for signed-in accounts.
  if (!session.session) return { state: 'code_required' };
  const { data, error } = await supabase.rpc('get_event_registration_access', { p_event: eventId });
  if (error) throw error;
  const row = (data ?? {}) as { state?: RegistrationAccessState; scope?: RegistrationAccessScope; team_id?: string; request_id?: string };
  return { state: row.state ?? 'error', scope: row.scope, teamId: row.team_id, requestId: row.request_id };
}

export async function requestEventRegistrationAccess(eventId: string, reason: string): Promise<string> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { data, error } = await supabase.rpc('request_event_registration_access', { p_event: eventId, p_reason: reason.trim() || null });
  if (error) throw error;
  return String(data ?? '');
}

export interface RegistrationAccessRequest {
  id: string;
  userId: string;
  fighterName: string;
  teamName?: string;
  organizationName?: string;
  reason?: string;
  status: 'pending' | 'approved' | 'denied' | 'cancelled';
  createdAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
  membershipNote: string;
}

export async function listRegistrationAccessRequests(eventId: string): Promise<RegistrationAccessRequest[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_event_registration_access_requests', { p_event: eventId });
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    id: row.id, userId: row.user_id, fighterName: row.fighter_name ?? 'Unnamed fighter',
    teamName: row.team_name ?? undefined, organizationName: row.organization_name ?? undefined,
    reason: row.reason ?? undefined, status: row.status, createdAt: row.created_at,
    reviewedAt: row.reviewed_at ?? undefined, reviewNotes: row.review_notes ?? undefined,
    membershipNote: snapshotNote(row.eligibility_snapshot)
  }));
}

/** Why the request was needed, from the eligibility snapshot taken when it was made. */
export function snapshotNote(snapshot: { state?: string; scope?: string } | null | undefined): string {
  if (!snapshot?.state) return 'No eligibility details were recorded.';
  if (snapshot.state === 'membership_unverified') return 'No active team membership linked to a fighter profile was found.';
  if (snapshot.state === 'code_required') return 'Has an active membership, but outside this event’s registration scope.';
  return 'Eligibility state: ' + snapshot.state.replaceAll('_', ' ') + '.';
}

export async function reviewRegistrationAccessRequest(requestId: string, decision: 'approved' | 'denied', notes: string): Promise<void> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { error } = await supabase.rpc('review_event_registration_access_request', { p_request: requestId, p_decision: decision, p_notes: notes.trim() || null });
  if (error) throw error;
}

export async function setEventRegistrationAccessScope(eventId: string, scope: RegistrationAccessScope): Promise<void> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { error } = await supabase.rpc('set_event_registration_access_scope', { p_event: eventId, p_scope: scope });
  if (error) throw error;
}

export async function loadEventRegistrationAccessScope(eventId: string): Promise<RegistrationAccessScope | undefined> {
  if (!supabase) return undefined;
  const { data, error } = await supabase.from('events').select('registration_access_scope').eq('id', eventId).maybeSingle();
  if (error) throw error;
  return (data?.registration_access_scope as RegistrationAccessScope | undefined) ?? undefined;
}

export interface AppNotification {
  id: string;
  kind: string;
  title: string;
  body?: string;
  link?: string;
  eventId?: string;
  createdAt: string;
  read: boolean;
}

export async function listMyNotifications(limit = 30): Promise<AppNotification[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_my_notifications', { p_limit: limit });
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    id: row.id, kind: row.kind, title: row.title, body: row.body ?? undefined, link: row.link ?? undefined,
    eventId: row.event_id ?? undefined, createdAt: row.created_at, read: Boolean(row.read_at)
  }));
}

export async function countMyUnreadNotifications(): Promise<number> {
  if (!supabase) return 0;
  const { data, error } = await supabase.rpc('count_my_unread_notifications');
  if (error) throw error;
  return Number(data ?? 0);
}

export async function markNotificationRead(id: string): Promise<void> {
  if (!supabase) return;
  const { error } = await supabase.rpc('mark_notification_read', { p_id: id });
  if (error) throw error;
}

export async function markAllNotificationsRead(): Promise<void> {
  if (!supabase) return;
  const { error } = await supabase.rpc('mark_all_notifications_read');
  if (error) throw error;
}
