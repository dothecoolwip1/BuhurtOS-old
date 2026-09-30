import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import { redeemAccessCode } from '../lib/accessControl';
import { redeemDelegatedAccessCode } from '../lib/delegatedAccess';

export function AccessCodePage() {
  const { user, reload } = useAppState();
  const [code, setCode] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  if (!user) return <div className="state-card">Sign in before entering an access code.</div>;

  const redeem = async () => {
    setBusy(true);
    setMessage('');
    try {
      let destination = '/ops';
      try {
        const delegated = await redeemDelegatedAccessCode(code);
        destination = '/ops/codes';
        setMessage('Access granted: ' + delegated.targetName + ' · ' + delegated.role.replaceAll('_',' ') + '.');
      } catch (delegatedError) {
        const text = delegatedError instanceof Error ? delegatedError.message : '';
        if (!/not recognized/i.test(text)) throw delegatedError;
        const result = await redeemAccessCode(code);
        setMessage(result.alreadyRedeemed ? 'This code was already active on your account.' : 'BuhurtOS access granted.');
      }
      await reload();
      window.setTimeout(() => { window.location.hash = '#' + destination; }, 350);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'The access code could not be redeemed.');
    } finally {
      setBusy(false);
    }
  };

  return <section className="panel-card">
    <span className="eyebrow">Access & membership</span>
    <h1>Enter your BuhurtOS code</h1>
    <p>{user.hasPlatformAccess ? 'Your account already has BuhurtOS access. You can still enter another code to join an organization, club or team.' : 'Public teams, fighters, events, rankings and rules remain open. Enter the code supplied by your parent group to unlock the correct BuhurtOS access and role.'}</p>
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
      {busy ? 'Checking code…' : user.hasPlatformAccess ? 'Redeem Group Code' : 'Unlock BuhurtOS'}
    </button>
    {message && <div className="auth-message" role="status">{message}</div>}
    {user.hasPlatformAccess && <p><small>Your current platform access stays active. Redeeming a subgroup code adds the scoped membership carried by that code.</small></p>}
    {!user.hasPlatformAccess && <p><small>If you are setting up a brand-new BuhurtOS database, the first account can use the one-time <Link to="/ops/setup">platform admin bootstrap</Link>.</small></p>}
  </section>;
}
