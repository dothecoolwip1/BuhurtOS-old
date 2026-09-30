import { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { useAccount } from '../features/Account';
import { useAppState } from '../features/AppState';
import { acceptMembershipInvitation } from '../lib/organizationAdmin';
import { Card, PageTitle, StateBlock } from '../components/page';

/** Accepting an invitation. Needs a signed-in account and the link's token, nothing else. */
export function MembershipInvitePage() {
  const { user } = useAccount();
  const { event } = useAppState();
  const { refresh } = useAccount();
  const [params] = useSearchParams();
  const [message, setMessage] = useState<{ ok: boolean; text: string }>();
  const [accepted, setAccepted] = useState(false);
  const [busy, setBusy] = useState(false);
  const token = params.get('token') || '';

  if (!token) return <>
    <PageTitle title="Accept an invitation" />
    <StateBlock kind="empty" title="This link is missing its invitation code">
      Open the full link you were sent. If you have a short access code instead, use <Link to="/me/join">Join with a code</Link>.
    </StateBlock>
  </>;

  const accept = async () => {
    if (!user) return;
    setBusy(true); setMessage(undefined);
    try {
      await acceptMembershipInvitation(event?.organizationId ?? '', token, { userId: user.userId, displayName: user.displayName });
      refresh();
      setAccepted(true);
      setMessage({ ok: true, text: 'Invitation accepted. Your new access is active.' });
    } catch (error) {
      setMessage({ ok: false, text: error instanceof Error ? error.message : 'The invitation could not be accepted.' });
    } finally { setBusy(false); }
  };

  return <>
    <PageTitle title="Accept your invitation" lead="The invitation is tied to the email address it was sent to. BuhurtOS also checks that whoever sent it still has the authority to give you this role." />
    <Card>
      {!user ? <StateBlock kind="error" title="We could not load your account">Sign out and back in, then open the invitation link again.</StateBlock> : <>
        {!accepted ? <button type="button" className="nx-btn" disabled={busy} onClick={accept}>{busy ? 'Checking…' : 'Accept invitation'}</button> : null}
        {message ? <div className={'nx-note ' + (message.ok ? 'ok' : 'bad')} role={message.ok ? 'status' : 'alert'}>{message.text}</div> : null}
        {accepted ? <p><Link className="nx-btn" to="/me">See what you can now do</Link></p> : null}
      </>}
    </Card>
  </>;
}
