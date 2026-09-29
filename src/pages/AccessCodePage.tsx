import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { redeemAccessCode } from '../lib/accessControl';

export function AccessCodePage() {
  const { user, reload } = useAppState();
  const [code, setCode] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  if (!user) return <div className="state-card">Sign in before entering an access code.</div>;

  if (user.hasPlatformAccess) {
    return <section className="panel-card">
      <span className="eyebrow">Production access</span>
      <h1>Access active</h1>
      <p>This account is approved to use the live BuhurtOS operations system.</p>
      <Link className="primary big" to="/ops">Open BuhurtOS</Link>
    </section>;
  }

  const redeem = async () => {
    setBusy(true);
    setMessage('');
    try {
      const result = await redeemAccessCode(code);
      await reload();
      setMessage(result.alreadyRedeemed ? 'This code was already active on your account.' : 'Access granted. Welcome to the live BuhurtOS system.');
      window.setTimeout(() => { window.location.hash = '#/ops'; }, 350);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'The access code could not be redeemed.');
    } finally {
      setBusy(false);
    }
  };

  return <section className="panel-card">
    <span className="eyebrow">Controlled early access</span>
    <h1>Enter your BuhurtOS code</h1>
    <p>Public teams, fighters, events, rankings and rules remain open. A code is currently required to enter the live operations system.</p>
    <label className="form-stack">Access code
      <input
        autoCapitalize="characters"
        autoCorrect="off"
        spellCheck={false}
        placeholder="BO-XXXXXXXXXXXX"
        value={code}
        onChange={event => setCode(event.target.value.toUpperCase())}
      />
    </label>
    <button className="primary big" disabled={busy || !code.trim()} onClick={redeem}>
      {busy ? 'Checking code…' : 'Unlock BuhurtOS'}
    </button>
    {message && <div className="auth-message" role="status">{message}</div>}
    <p><small>If you are setting up a brand-new BuhurtOS database, the first account can use the one-time <Link to="/ops/setup">platform admin bootstrap</Link>.</small></p>
  </section>;
}
