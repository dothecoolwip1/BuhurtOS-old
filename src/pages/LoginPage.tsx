import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Link, Navigate, useLocation } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import {
  requestPasswordReset,
  resendVerification,
  sanitizeAuthReturnPath,
  sendMagicLink,
  signIn,
  signUp,
  updatePassword
} from '../lib/auth';

import { canSelfRegister, defaultPlatformConfig, loadPlatformConfigStatus, registrationNeedsInvite, type PlatformConfig } from '../lib/platformConfig';

type AuthMode = 'signin' | 'signup' | 'forgot' | 'verify' | 'recovery';

function modeFromSearch(search: string): AuthMode {
  const mode = new URLSearchParams(search).get('mode');
  return mode === 'signup' || mode === 'forgot' || mode === 'verify' || mode === 'recovery' ? mode : 'signin';
}

export function LoginPage() {
  const { user, authReady, authNotice } = useAppState();
  const location = useLocation();
  const next = useMemo(() => sanitizeAuthReturnPath(new URLSearchParams(location.search).get('next')), [location.search]);
  const requestedMode = modeFromSearch(location.search);
  const [mode, setMode] = useState<AuthMode>(requestedMode);
  const [displayName, setDisplayName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const [platformConfig, setPlatformConfig] = useState<PlatformConfig>(defaultPlatformConfig);
  const [configProblem, setConfigProblem] = useState('');
  useEffect(() => {
    let active = true;
    loadPlatformConfigStatus().then(status => { if (active) { setPlatformConfig(status.config); setConfigProblem(status.error ?? ''); } });
    return () => { active = false; };
  }, []);
  const registrationOpen = canSelfRegister(platformConfig);

  useEffect(() => setMode(requestedMode), [requestedMode]);

  if (!authReady) {
    return <main className="auth-shell"><section className="auth-card"><div className="state-card">Checking your account session…</div></section></main>;
  }
  if (user && mode !== 'recovery') return <Navigate to={next} replace />;

  const run = async (action: 'password' | 'magic' | 'signup' | 'forgot' | 'resend' | 'recovery') => {
    setBusy(true);
    setMessage('');
    try {
      if (action === 'password') {
        await signIn(email, password);
        setMessage('Signed in.');
      } else if (action === 'magic') {
        await sendMagicLink(email, next);
        setMessage('Sign in link sent. Check your email.');
      } else if (action === 'signup') {
        if (password.length < 8) throw new Error('Use a password with at least 8 characters.');
        if (password !== confirmation) throw new Error('The passwords do not match.');
        if (!displayName.trim()) throw new Error('Enter a display name.');
        const result = await signUp(email, password, displayName, next);
        if (result.requiresVerification) {
          setMode('verify');
          setPassword('');
          setConfirmation('');
          setMessage('Account created. Check your email to verify the address before signing in.');
        } else {
          setMessage('Account created and signed in.');
        }
      } else if (action === 'forgot') {
        await requestPasswordReset(email, next);
        setMessage('If that address belongs to an account, a password reset message has been sent.');
      } else if (action === 'resend') {
        await resendVerification(email, next);
        setMessage('Verification message sent. Check your email.');
      } else {
        if (!user) throw new Error('Open the password recovery link from your email before choosing a new password.');
        if (password.length < 8) throw new Error('Use a password with at least 8 characters.');
        if (password !== confirmation) throw new Error('The passwords do not match.');
        await updatePassword(password);
        setPassword('');
        setConfirmation('');
        setMessage('Password updated. Your current session remains signed in.');
        window.location.hash = `#${next}`;
      }
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Account action failed.');
    } finally {
      setBusy(false);
    }
  };

  const submit = (event: FormEvent) => {
    event.preventDefault();
    if (busy) return;
    if (mode === 'signin') { if (email && password) void run('password'); }
    else if (mode === 'signup') { if (registrationOpen) void run('signup'); }
    else if (mode === 'forgot') { if (email) void run('forgot'); }
    else if (mode === 'verify') { if (email) void run('resend'); }
    else if (password && confirmation) void run('recovery');
  };

  const notice = authNotice === 'session_expired'
    ? 'Your session ended. Sign in again to continue.'
    : authNotice === 'signed_out'
      ? 'You have been signed out.'
      : '';

  return <main className="auth-shell"><section className="auth-card">
    <span className="brand-mark large">B</span>
    <span className="eyebrow">BuhurtOS</span>
    <h1>{mode === 'signup' ? 'Create Account' : mode === 'forgot' ? 'Reset Password' : mode === 'verify' ? 'Verify Email' : mode === 'recovery' ? 'Choose New Password' : 'Sign in'}</h1>

    {mode === 'signin' && <p>Use your BuhurtOS account. Public event pages never require a login.</p>}
    {mode === 'signup' && !registrationOpen && <p role="alert">New account registration is currently closed. Ask an organizer for an invitation.</p>}
    {mode === 'signup' && registrationOpen && registrationNeedsInvite(platformConfig) && <p>Sign-up is meant for invited people. Use the email address your invitation or access code was sent to.</p>}
    {mode === 'signup' && configProblem && <p role="status">The current sign-up settings could not be checked, so the form is shown. If sign-up is closed you will be told after you submit.</p>}
    {mode === 'signup' && <p>Create your personal account first. Organization and event permissions are assigned separately by authorized administrators.</p>}
    {mode === 'forgot' && <p>Enter your account email and BuhurtOS will send the secure recovery link configured by Supabase Auth.</p>}
    {mode === 'verify' && <p>Your account exists, but email verification is still required before normal sign in.</p>}
    {mode === 'recovery' && <p>Choose a new password for the account linked by the recovery message.</p>}

    {notice && <div className="auth-message" role="status">{notice}</div>}

    <form onSubmit={submit} noValidate>
    {mode === 'signup' && <label>Display name<input autoComplete="name" value={displayName} onChange={event => setDisplayName(event.target.value)}/></label>}
    {mode !== 'recovery' && <label>Email<input type="email" autoComplete="email" value={email} onChange={event => setEmail(event.target.value)}/></label>}
    {(mode === 'signin' || mode === 'signup' || mode === 'recovery') && <label>{mode === 'recovery' ? 'New password' : 'Password'}<input type="password" autoComplete={mode === 'signin' ? 'current-password' : 'new-password'} value={password} onChange={event => setPassword(event.target.value)}/></label>}
    {(mode === 'signup' || mode === 'recovery') && <label>Confirm password<input type="password" autoComplete="new-password" value={confirmation} onChange={event => setConfirmation(event.target.value)}/></label>}

    {message && <div className="auth-message" role="status" aria-live="polite">{message}</div>}

    {mode === 'signin' && <>
      <button type="submit" className="primary big" disabled={busy || !email || !password}>{busy ? 'Signing In…' : 'Sign In'}</button>
      <button type="button" className="big" disabled={busy || !email} onClick={() => run('magic')}>Email Sign In Link</button>
      <button type="button" className="link-button" disabled={busy} onClick={() => { setMode('forgot'); setMessage(''); }}>Forgot password?</button>
      {registrationOpen && <button type="button" className="link-button" disabled={busy} onClick={() => { setMode('signup'); setMessage(''); }}>Create an account</button>}
    </>}

    {mode === 'signup' && <>
      <button type="submit" className="primary big" disabled={busy || !registrationOpen || !displayName.trim() || !email || !password || !confirmation}>{busy ? 'Creating…' : 'Create Account'}</button>
      <button type="button" className="link-button" disabled={busy} onClick={() => { setMode('signin'); setMessage(''); }}>Back to sign in</button>
    </>}

    {mode === 'forgot' && <>
      <button type="submit" className="primary big" disabled={busy || !email}>{busy ? 'Sending…' : 'Send Recovery Link'}</button>
      <button type="button" className="link-button" disabled={busy} onClick={() => { setMode('signin'); setMessage(''); }}>Back to sign in</button>
    </>}

    {mode === 'verify' && <>
      <button type="submit" className="primary big" disabled={busy || !email}>{busy ? 'Sending…' : 'Resend Verification'}</button>
      <button type="button" className="link-button" disabled={busy} onClick={() => { setMode('signin'); setMessage(''); }}>I have verified my email</button>
    </>}

    {mode === 'recovery' && <button type="submit" className="primary big" disabled={busy || !password || !confirmation}>{busy ? 'Updating…' : 'Update Password'}</button>}
    </form>
    <details className="auth-help">
      <summary>Which code or invitation do I need?</summary>
      <ul>
        <li><b>Account:</b> your personal login. Anyone can look at public pages without one.</li>
        <li><b>Early access code:</b> issued by the platform owner so a specific person can get an account while access is limited.</li>
        <li><b>Role code or invitation:</b> entered after you sign in (under My workspace) to join a team or organization with a set role.</li>
        <li><b>Event signup code:</b> entered on an event page to unlock that event's fighter interest form. It is not an account.</li>
      </ul>
    </details>
    <p className="auth-back"><Link to="/public">← Back to the public site</Link></p>
  </section></main>;
}
