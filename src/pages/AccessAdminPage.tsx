import { useEffect, useState } from 'react';
import { useAppState } from '../features/AppState';
import {
  createAccessCode,
  listAccessCodes,
  listAccessUsers,
  revokeAccessCode,
  revokeUserAccess,
  type AccessCodeSummary,
  type AccessUserSummary
} from '../lib/accessControl';

export function AccessAdminPage() {
  const { user } = useAppState();
  const [codes, setCodes] = useState<AccessCodeSummary[]>([]);
  const [users, setUsers] = useState<AccessUserSummary[]>([]);
  const [label, setLabel] = useState('');
  const [maxUses, setMaxUses] = useState('');
  const [expiresAt, setExpiresAt] = useState('');
  const [notes, setNotes] = useState('');
  const [createdCode, setCreatedCode] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  const isSuperAdmin = Boolean(user?.platformRoles.includes('platform_super_admin'));

  const refresh = async () => {
    const [codeRows, userRows] = await Promise.all([listAccessCodes(), listAccessUsers()]);
    setCodes(codeRows);
    setUsers(userRows);
  };

  useEffect(() => {
    if (!isSuperAdmin) return;
    refresh().catch(error => setMessage(error instanceof Error ? error.message : 'Unable to load access controls.'));
  }, [isSuperAdmin]);

  if (!isSuperAdmin) return <div className="state-card">Platform super admin access is required.</div>;

  const create = async () => {
    setBusy(true);
    setMessage('');
    setCreatedCode('');
    try {
      const parsedMaxUses = maxUses.trim() ? Number(maxUses) : undefined;
      if (parsedMaxUses !== undefined && (!Number.isInteger(parsedMaxUses) || parsedMaxUses < 1)) {
        throw new Error('Maximum uses must be a whole number of at least 1.');
      }
      const result = await createAccessCode({
        label,
        maxUses: parsedMaxUses,
        expiresAt: expiresAt || undefined,
        notes
      });
      setCreatedCode(result.code);
      setLabel('');
      setMaxUses('');
      setExpiresAt('');
      setNotes('');
      setMessage('Access code created. Copy it now because the full code is not stored or shown again.');
      await refresh();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Unable to create the access code.');
    } finally {
      setBusy(false);
    }
  };

  const disableCode = async (id: string) => {
    if (!window.confirm('Disable this access code? Existing users keep access until you revoke them separately.')) return;
    setBusy(true);
    try {
      await revokeAccessCode(id);
      await refresh();
      setMessage('Access code disabled.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Unable to disable the code.');
    } finally {
      setBusy(false);
    }
  };

  const revokeUser = async (id: string) => {
    if (!window.confirm('Revoke this user’s early access? Their account and sporting records will remain intact.')) return;
    setBusy(true);
    try {
      await revokeUserAccess(id);
      await refresh();
      setMessage('User early access revoked.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Unable to revoke user access.');
    } finally {
      setBusy(false);
    }
  };

  return <>
    <section className="section-head"><div>
      <span className="eyebrow">People & access</span>
      <h1>Accounts & early access</h1>
      <p>Control entry into the live BuhurtOS operations system without changing team, marshal, fighter or organization roles.</p>
    </div></section>

    <div className="admin-grid">
      <section className="panel-card">
        <h2>Create code</h2>
        <div className="form-stack">
          <label>Label<input placeholder="Reavers captains" value={label} onChange={event => setLabel(event.target.value)} /></label>
          <label>Maximum uses<input inputMode="numeric" placeholder="Blank = unlimited" value={maxUses} onChange={event => setMaxUses(event.target.value)} /></label>
          <label>Expires<input type="datetime-local" value={expiresAt} onChange={event => setExpiresAt(event.target.value)} /></label>
          <label>Notes<textarea rows={3} placeholder="Why this code exists" value={notes} onChange={event => setNotes(event.target.value)} /></label>
          <button className="primary" disabled={busy || label.trim().length < 2} onClick={create}>Create Access Code</button>
        </div>
        {createdCode && <div className="state-card">
          <strong>{createdCode}</strong>
          <button onClick={() => navigator.clipboard.writeText(createdCode)}>Copy Code</button>
          <small>This is the only time the complete code is displayed.</small>
        </div>}
      </section>

      <section className="panel-card">
        <h2>Issued codes</h2>
        <div className="membership-list">
          {codes.length === 0 ? <div className="state-card">No access codes have been issued yet.</div> : codes.map(code => <article key={code.id}>
            <div>
              <strong>{code.label}</strong>
              <small>{code.codePrefix}… · {code.activeUses}{code.maxUses ? ' / ' + code.maxUses : ''} active uses</small>
              <small>{code.disabledAt ? 'Disabled' : code.expiresAt ? 'Expires ' + new Date(code.expiresAt).toLocaleString() : 'No expiration'}</small>
            </div>
            {!code.disabledAt && <button disabled={busy} onClick={() => disableCode(code.id)}>Disable</button>}
          </article>)}
        </div>
      </section>

      <section className="panel-card">
        <h2>Access users</h2>
        <div className="membership-list">
          {users.length === 0 ? <div className="state-card">No one has redeemed an access code yet.</div> : users.map((entry, index) => <article key={entry.userId + '-' + entry.redeemedAt + '-' + index}>
            <div>
              <strong>{entry.displayEmail}</strong>
              <small>{entry.codeLabel} · redeemed {new Date(entry.redeemedAt).toLocaleString()}</small>
              <small>{entry.revokedAt ? 'Revoked ' + new Date(entry.revokedAt).toLocaleString() : 'Active'}</small>
            </div>
            {!entry.revokedAt && <button disabled={busy} onClick={() => revokeUser(entry.userId)}>Revoke</button>}
          </article>)}
        </div>
      </section>
    </div>

    {message && <div className="auth-message" role="status">{message}</div>}
  </>;
}
