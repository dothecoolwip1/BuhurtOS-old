import { useCallback, useEffect, useRef, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useAccount } from '../features/Account';
import {
  allowedInviteRoles, cancelMembershipRequest, changeMembershipRole, createMembershipInvitation, endMembership,
  membershipInvitePath, reviewMembershipApplication
} from '../lib/organizationAdmin';
import { loadTeamForManagement, teamAuthorityFor, type TeamManagement } from '../lib/teamAdmin';
import { loadPublicTeamRoster, type PublicRosterMember } from '../lib/teamDirectory';
import { roleLabel } from '../lib/workspace';
import type { TeamRole } from '../types';
import { Card, PageTitle, StateBlock } from '../components/page';

function inviteUrl(token: string): string {
  return `${window.location.origin}${window.location.pathname}#${membershipInvitePath(token)}`;
}

/** One team: its members, invitations and applications, and the public (source) roster for reference. */
export function TeamManagePage() {
  const { teamId = '' } = useParams();
  const { user, refresh } = useAccount();
  const [data, setData] = useState<TeamManagement>();
  const [missing, setMissing] = useState(false);
  const [loadError, setLoadError] = useState('');
  const [roster, setRoster] = useState<PublicRosterMember[]>([]);
  const [message, setMessage] = useState<{ ok: boolean; text: string }>();
  const [busy, setBusy] = useState(false);
  const [email, setEmail] = useState('');
  const [role, setRole] = useState<TeamRole>('fighter');
  const [note, setNote] = useState('');
  const [link, setLink] = useState('');

  const latest = useRef(teamId);
  latest.current = teamId;
  const load = useCallback(async () => {
    setLoadError('');
    try {
      const result = await loadTeamForManagement(teamId);
      if (latest.current !== teamId) return; // a different team is open now
      setMissing(!result);
      setData(result);
    } catch (error) {
      if (latest.current !== teamId) return;
      setLoadError(error instanceof Error ? error.message : 'This team could not be loaded.');
    }
  }, [teamId]);

  useEffect(() => {
    // Opening another team never shows the previous team's members or messages.
    setData(undefined); setMissing(false); setRoster([]); setMessage(undefined); setLink('');
    void load();
  }, [load]);
  useEffect(() => {
    let active = true;
    loadPublicTeamRoster(teamId).then(rows => { if (active) setRoster(rows); }).catch(() => { if (active) setRoster([]); });
    return () => { active = false; };
  }, [teamId]);

  if (loadError) return <StateBlock kind="error" title="This team could not be loaded">{loadError} <Link to="/admin/teams">Back to teams</Link></StateBlock>;
  if (missing) return <StateBlock kind="empty" title="Team not found">It may have been archived, or you may not have access. <Link to="/admin/teams">Back to teams</Link></StateBlock>;
  if (!data || !user) return <StateBlock kind="loading" title="Loading team…" />;

  const { team, snapshot, organizationName } = data;
  const organizationId = team.organizationId;
  const authority = teamAuthorityFor(user, team);
  const roles = allowedInviteRoles('team', authority) as TeamRole[];
  const canManage = roles.length > 0;
  const members = snapshot.teamMemberships.filter(row => row.teamId === team.id);
  const waiting = snapshot.requests.filter(row => row.teamId === team.id && row.status === 'pending');

  const run = async (work: () => Promise<void>, success: string) => {
    setBusy(true); setMessage(undefined);
    try { await work(); await load(); refresh(); setMessage({ ok: true, text: success }); }
    catch (error) { setMessage({ ok: false, text: error instanceof Error ? error.message : 'That change could not be made.' }); }
    finally { setBusy(false); }
  };

  const invite = () => run(async () => {
    const token = await createMembershipInvitation(organizationId, { scope: 'team', targetId: team.id, email, teamRole: role, message: note });
    setLink(inviteUrl(token));
    setEmail(''); setNote('');
  }, 'Invitation created. Copy the link below and send it to them; it only works for the email address you entered.');

  const copy = async () => {
    try { await navigator.clipboard.writeText(link); setMessage({ ok: true, text: 'Link copied.' }); }
    catch { setMessage({ ok: false, text: 'Could not copy automatically. Select the link and copy it.' }); }
  };

  return <>
    <PageTitle title={team.name} lead={[organizationName, team.cityOrRegion].filter(Boolean).join(' · ')}
      actions={<><Link className="nx-btn quiet" to="/admin/teams">All teams</Link><Link className="nx-btn quiet" to={`/teams/${team.id}`}>Public page</Link></>} />

    {message ? <div className={'nx-note ' + (message.ok ? 'ok' : 'bad')} role={message.ok ? 'status' : 'alert'}>{message.text}</div> : null}
    {!canManage ? <StateBlock kind="empty" title="You can view this team but not change it">Only the platform owner, the organization administrator, the team administrator or a captain can add or remove people.</StateBlock> : null}

    <Card title={`Members (${members.length})`} lead="People with a BuhurtOS account who belong to this team.">
      {members.length === 0 ? <StateBlock kind="empty" title="No one has joined this team in BuhurtOS yet">
        {canManage ? 'Invite people below. Names shown under "Public roster" come from BI and HACSA and are not accounts.' : 'Members will appear here once they join.'}
      </StateBlock> : <ul className="nx-rows">{members.map(member => <li key={member.id}>
        <div><strong>{member.displayName}</strong><small>{roleLabel(member.role)} · since {member.startsOn}</small></div>
        <div className="nx-row-actions">
          {canManage && member.userId !== user.userId ? <select aria-label={`Role for ${member.displayName}`} disabled={busy} value={member.role}
            onChange={event => run(() => changeMembershipRole(organizationId, 'team', member.id, event.target.value as TeamRole), `${member.displayName} is now ${roleLabel(event.target.value)}.`)}>
            {[...new Set([member.role, ...roles])].map(value => <option key={value} value={value}>{roleLabel(value)}</option>)}
          </select> : null}
          {canManage || member.userId === user.userId ? <button type="button" className="nx-btn quiet" disabled={busy}
            onClick={() => { if (window.confirm(`Remove ${member.displayName} from ${team.name}? Their history is kept.`)) void run(() => endMembership(organizationId, 'team', member.id), `${member.displayName} was removed from the team.`); }}>
            {member.userId === user.userId ? 'Leave team' : 'Remove'}</button> : null}
        </div>
      </li>)}</ul>}
    </Card>

    {canManage ? <Card title="Add someone" lead="Enter their email address. They get a link to accept; nothing changes until they do.">
      <form className="nx-form" onSubmit={event => { event.preventDefault(); void invite(); }}>
        <label>Email address<input type="email" required value={email} onChange={e => setEmail(e.target.value)} autoComplete="off" /></label>
        <label>Role on the team
          <select value={role} onChange={e => setRole(e.target.value as TeamRole)}>{roles.map(value => <option key={value} value={value}>{roleLabel(value)}</option>)}</select>
        </label>
        <label>Message (optional)<input value={note} onChange={e => setNote(e.target.value)} /></label>
        <button type="submit" className="nx-btn" disabled={busy || !email}>{busy ? 'Working…' : 'Create invitation'}</button>
      </form>
      {link ? <div className="nx-linkbox"><label>Invitation link<input readOnly value={link} onFocus={e => e.currentTarget.select()} /></label><button type="button" className="nx-btn quiet" onClick={copy}>Copy link</button></div> : null}
    </Card> : null}

    {waiting.length > 0 ? <Card title={`Waiting for a decision (${waiting.length})`}>
      <ul className="nx-rows">{waiting.map(request => <li key={request.id}>
        <div><strong>{request.requestKind === 'invitation' ? `Invited ${request.inviteEmail ?? 'someone'}` : 'Application to join'}</strong>
          <small>{request.requestedTeamRole ? roleLabel(request.requestedTeamRole) : 'Member'}{request.message ? ` · ${request.message}` : ''}</small></div>
        <div className="nx-row-actions">
          {canManage && request.requestKind === 'application' ? <>
            <button type="button" className="nx-btn" disabled={busy} onClick={() => run(() => reviewMembershipApplication(organizationId, request.id, 'accept'), 'Application accepted.')}>Accept</button>
            <button type="button" className="nx-btn quiet" disabled={busy} onClick={() => run(() => reviewMembershipApplication(organizationId, request.id, 'reject'), 'Application declined.')}>Decline</button>
          </> : null}
          {canManage && request.requestKind === 'invitation' && request.inviteToken ? <button type="button" className="nx-btn quiet" onClick={() => { setLink(inviteUrl(request.inviteToken!)); }}>Show link</button> : null}
          {canManage ? <button type="button" className="nx-btn quiet" disabled={busy} onClick={() => run(() => cancelMembershipRequest(organizationId, request.id), 'Cancelled.')}>Cancel</button> : null}
        </div>
      </li>)}</ul>
    </Card> : null}

    <Card title={`Public roster (${roster.length})`} lead="Names listed publicly for this team from BI, HACSA and public BuhurtOS profiles. They are not accounts, and adding or removing them is not done here.">
      {roster.length === 0 ? <StateBlock kind="empty" title="No public roster listed">The sources do not publish member names for this team.</StateBlock>
        : <ul className="nx-chips">{roster.map((person, index) => <li key={person.identityId ?? person.displayName + index}>{person.displayName}{person.role ? <small> · {person.role}</small> : null}</li>)}</ul>}
    </Card>
  </>;
}
