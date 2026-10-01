import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { useAppState } from '../features/AppState';
import { redeemAccessCode } from '../lib/accessControl';
import { redeemDelegatedAccessCode } from '../lib/delegatedAccess';
import { friendlyError } from '../lib/friendlyError';

export function AccessCodePage() {
  const { user, reload } = useAppState();
  const account = useAccount();
  const [code, setCode] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  if (!user) return <div className="state-card">Sign in before entering an access code.</div>;

  const redeem = async () => {
    setBusy(true);
    setMessage('');
    try {
      let destination = '/me';
      try {
        const delegated = await redeemDelegatedAccessCode(code);
        destination = '/me';
        setMessage('Done. You are now ' + delegated.role.replaceAll('_',' ') + ' of ' + delegated.targetName + '. Opening your workspace to show what changed…');
      } catch (delegatedError) {
        const text = friendlyError(delegatedError).message;
        if (!/not recognized/i.test(text)) throw delegatedError;
        const result = await redeemAccessCode(code);
        setMessage(result.alreadyRedeemed ? 'This code was already active on your account.' : 'BuhurtOS access granted.');
      }
      await reload();
      account.refresh();
      window.setTimeout(() => { window.location.hash = '#' + destination; }, 350);
    } catch (error) {
      setMessage(friendlyError(error).message);
    } finally {
      setBusy(false);
    }
  };

  return <section className="panel-card">
    <span className="eyebrow">My workspace</span>
    <h1>Join with a code</h1>
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
    {!user.hasPlatformAccess && <p><small>If you are setting up a brand-new BuhurtOS database, the first account can use the one-time <Link to="/admin/events/setup">platform admin bootstrap</Link>.</small></p>}
  </section>;
}
