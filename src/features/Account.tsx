import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import type { UserContext } from '../types';
import { demoUser } from '../data/demo';
import { signOut as signOutRequest } from '../lib/auth';
import { isSupabaseConfigured, supabase } from '../lib/supabase';
import { loadUserContext } from '../lib/userContext';
import { friendlyError } from '../lib/friendlyError';

/**
 * Who is using the app, available to every area (public site, workspace, administration).
 * It only answers identity questions; event data lives in AppState under the operations routes.
 */
export type AccountStatus = 'loading' | 'anonymous' | 'signedIn' | 'demo';

export interface AccountValue {
  status: AccountStatus;
  /** Null when signed out, or when signed in but the roles request failed (see contextError). */
  user: UserContext | null;
  email?: string;
  /** Set when the session exists but roles could not be loaded; never shown as "no roles". */
  contextError?: string;
  signingOut: boolean;
  signOut: () => Promise<void>;
  refresh: () => void;
}

const AccountContext = createContext<AccountValue | null>(null);

export function AccountProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AccountStatus>(isSupabaseConfigured ? 'loading' : 'demo');
  const [user, setUser] = useState<UserContext | null>(isSupabaseConfigured ? null : { ...demoUser, platformRoles: ['platform_super_admin'] });
  const [email, setEmail] = useState<string>();
  const [contextError, setContextError] = useState<string>();
  const [signingOut, setSigningOut] = useState(false);
  const [tick, setTick] = useState(0);
  const generation = useRef(0);

  useEffect(() => {
    if (!supabase) return;
    const client = supabase;
    let active = true;

    const load = async (id: string, mail: string | undefined) => {
      const mine = ++generation.current;
      setEmail(mail);
      try {
        const context = await loadUserContext(id, mail ?? 'Signed in user');
        if (!active || mine !== generation.current) return;
        setUser(context); setContextError(undefined); setStatus('signedIn');
      } catch (error) {
        if (!active || mine !== generation.current) return;
        setUser(null);
        setContextError(friendlyError(error).message);
        setStatus('signedIn');
      }
    };

    client.auth.getSession().then(({ data }) => {
      if (!active) return;
      const session = data.session;
      if (!session?.user) { setStatus('anonymous'); setUser(null); return; }
      void load(session.user.id, session.user.email ?? undefined);
    }).catch(() => { if (active) setStatus('anonymous'); });

    const { data } = client.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_OUT' || !session?.user) {
        generation.current += 1;
        setUser(null); setEmail(undefined); setContextError(undefined); setStatus('anonymous');
        return;
      }
      // Defer to avoid calling into the client from inside its own auth callback.
      setTimeout(() => { if (active) void load(session.user.id, session.user.email ?? undefined); }, 0);
    });
    return () => { active = false; data.subscription.unsubscribe(); };
  }, [tick]);

  const signOut = useCallback(async () => {
    setSigningOut(true);
    try { await signOutRequest(); } finally { setSigningOut(false); }
  }, []);
  const refresh = useCallback(() => setTick(value => value + 1), []);

  const value = useMemo<AccountValue>(() => ({ status, user, email, contextError, signingOut, signOut, refresh }), [status, user, email, contextError, signingOut, signOut, refresh]);
  return <AccountContext.Provider value={value}>{children}</AccountContext.Provider>;
}

export function useAccount(): AccountValue {
  const value = useContext(AccountContext);
  if (!value) throw new Error('useAccount must be used inside AccountProvider');
  return value;
}
