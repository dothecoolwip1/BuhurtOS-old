import { useCallback, useEffect, useState } from 'react';
import { friendlyError } from '../lib/friendlyError';
import {
  listRegistrationAccessRequests, loadEventRegistrationAccessScope, reviewRegistrationAccessRequest, scopeLabels,
  setEventRegistrationAccessScope, type RegistrationAccessRequest, type RegistrationAccessScope
} from '../lib/registrationAccess';

/**
 * Organizer side of registration access: who may register without a code, and the permission requests waiting for review.
 * The database decides who may see or change any of this; a person without authority gets the plain message it returns.
 */
export function RegistrationAccessPanel({ eventId, eventName }: { eventId: string; eventName: string }) {
  const [scope, setScope] = useState<RegistrationAccessScope>();
  const [requests, setRequests] = useState<RegistrationAccessRequest[]>([]);
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [message, setMessage] = useState('');
  const [loadError, setLoadError] = useState('');
  const [busy, setBusy] = useState(false);

  const refresh = useCallback(async () => {
    setLoadError('');
    try {
      const [nextScope, rows] = await Promise.all([loadEventRegistrationAccessScope(eventId), listRegistrationAccessRequests(eventId)]);
      setScope(nextScope);
      setRequests(rows);
    } catch (error) {
      setLoadError(friendlyError(error).message);
    }
  }, [eventId]);

  useEffect(() => { setScope(undefined); setRequests([]); void refresh(); }, [refresh]);

  const changeScope = async (next: RegistrationAccessScope) => {
    setBusy(true); setMessage('');
    try { await setEventRegistrationAccessScope(eventId, next); setScope(next); setMessage('Registration access updated.'); }
    catch (error) { setMessage(friendlyError(error).message); }
    finally { setBusy(false); }
  };

  const review = async (request: RegistrationAccessRequest, decision: 'approved' | 'denied') => {
    setBusy(true); setMessage('');
    try {
      await reviewRegistrationAccessRequest(request.id, decision, notes[request.id] ?? '');
      setMessage(decision === 'approved' ? request.fighterName + ' can now register for ' + eventName + '.' : 'Request denied. ' + request.fighterName + ' was told.');
      await refresh();
    } catch (error) { setMessage(friendlyError(error).message); }
    finally { setBusy(false); }
  };

  const pending = requests.filter(request => request.status === 'pending');
  const reviewed = requests.filter(request => request.status !== 'pending');

  return <section className="panel-card" aria-labelledby="reg-access-title">
    <h2 id="reg-access-title">Who can register without a code</h2>
    <p>Fighters who belong to the right team or organization can register without a signup code. Everyone else uses a signup code or asks you for permission.</p>
    {loadError ? <div className="state-card" role="alert"><strong>Registration access could not be loaded</strong><p>{loadError}</p><button type="button" onClick={() => void refresh()}>Try again</button></div> : <>
      <label>Registration access
        <select value={scope ?? ''} disabled={busy || !scope} onChange={event => void changeScope(event.target.value as RegistrationAccessScope)}>
          {!scope ? <option value="">Loading…</option> : null}
          {(Object.keys(scopeLabels) as RegistrationAccessScope[]).map(key => <option key={key} value={key}>{scopeLabels[key].label}</option>)}
        </select>
      </label>
      {scope ? <p className="hint">{scopeLabels[scope].help}</p> : null}
      {message ? <div className="auth-message" role="status">{message}</div> : null}

      <h3>Permission requests {pending.length ? '(' + pending.length + ' waiting)' : ''}</h3>
      {pending.length === 0 ? <div className="state-card"><strong>No requests waiting.</strong><p>When a fighter cannot be verified automatically they can ask for permission, and you will be notified here and in your notifications.</p></div> :
        <div className="registration-review-list">{pending.map(request => <article className="panel-card" key={request.id}>
          <div className="registration-review-head"><div><span className="eyebrow">{[request.teamName, request.organizationName].filter(Boolean).join(' · ') || 'No team on record'}</span><h3>{request.fighterName}</h3><p>Requested {new Date(request.createdAt).toLocaleDateString()}</p></div><span className="status-pill">pending</span></div>
          <div className="fighter-signup-admin-details">
            <div><small>Why access could not be verified</small><p>{request.membershipNote}</p></div>
            {request.reason ? <div><small>Their reason</small><p>{request.reason}</p></div> : null}
          </div>
          <div className="form-stack"><label>Notes (optional)<textarea value={notes[request.id] ?? ''} onChange={e => setNotes(current => ({ ...current, [request.id]: e.target.value }))} /></label></div>
          <div className="header-actions">
            <button className="primary" type="button" disabled={busy} onClick={() => void review(request, 'approved')}>Approve registration access</button>
            <button type="button" disabled={busy} onClick={() => void review(request, 'denied')}>Deny</button>
          </div>
          <small>Approving lets this person register for this event only. It does not add them to a team or organization or give them any role.</small>
        </article>)}</div>}
      {reviewed.length ? <details><summary>Reviewed requests ({reviewed.length})</summary><div className="membership-list">{reviewed.map(request => <article key={request.id}><div className="grow"><strong>{request.fighterName}</strong><small>{request.status} · {request.reviewedAt ? new Date(request.reviewedAt).toLocaleDateString() : ''}{request.reviewNotes ? ' · ' + request.reviewNotes : ''}</small></div></article>)}</div></details> : null}
    </>}
  </section>;
}
