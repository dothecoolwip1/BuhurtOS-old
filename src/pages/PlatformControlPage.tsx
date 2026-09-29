import { useEffect, useMemo, useState } from 'react';
import { useAppState } from '../features/AppState';
import { createGovernanceClub, createGovernanceTeam, createMembershipInvitation, loadGovernanceSnapshot } from '../lib/organizationAdmin';
import { createPlatformOrganization, listPlatformOrganizations } from '../lib/platformControl';
import type { ClubRole, EntityVisibility, Organization, OrganizationKind, TeamRole } from '../types';

const organizationKinds: OrganizationKind[] = [
  'international_federation',
  'national_federation',
  'regional_organization',
  'local_organization',
  'independent_organization'
];

const label = (value: string) => value.replaceAll('_', ' ').replace(/\b\w/g, letter => letter.toUpperCase());

export function PlatformControlPage() {
  const { user, dataMode } = useAppState();
  const isSuperAdmin = Boolean(user?.platformRoles.includes('platform_super_admin'));
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [selectedOrganizationId, setSelectedOrganizationId] = useState('');
  const [clubs, setClubs] = useState<Array<{ id: string; name: string }>>([]);
  const [teams, setTeams] = useState<Array<{ id: string; name: string }>>([]);
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  const [orgForm, setOrgForm] = useState({
    name: '',
    shortName: '',
    region: '',
    kind: 'international_federation' as OrganizationKind,
    visibility: 'public' as EntityVisibility,
    countryCode: ''
  });
  const [clubForm, setClubForm] = useState({ name: '', shortName: '', region: '' });
  const [teamForm, setTeamForm] = useState({ name: '', shortName: '', region: '', clubId: '' });
  const [inviteForm, setInviteForm] = useState({
    scope: 'team' as 'team' | 'club',
    targetId: '',
    email: '',
    role: 'fighter' as TeamRole | ClubRole
  });
  const [inviteLink, setInviteLink] = useState('');

  const refreshOrganizations = async () => {
    const rows = await listPlatformOrganizations();
    setOrganizations(rows);
    setSelectedOrganizationId(current => current || rows[0]?.id || '');
  };

  const refreshSelected = async (organizationId: string) => {
    if (!organizationId) {
      setClubs([]);
      setTeams([]);
      return;
    }
    const snapshot = await loadGovernanceSnapshot(organizationId);
    setClubs(snapshot.clubs.map(row => ({ id: row.id, name: row.name })));
    setTeams(snapshot.teams.map(row => ({ id: row.id, name: row.name })));
  };

  useEffect(() => {
    if (!isSuperAdmin) return;
    refreshOrganizations().catch(error => setMessage(error instanceof Error ? error.message : 'Unable to load platform organizations.'));
  }, [isSuperAdmin]);

  useEffect(() => {
    refreshSelected(selectedOrganizationId).catch(error => setMessage(error instanceof Error ? error.message : 'Unable to load organization resources.'));
  }, [selectedOrganizationId]);

  const selectedOrganization = useMemo(
    () => organizations.find(row => row.id === selectedOrganizationId),
    [organizations, selectedOrganizationId]
  );

  useEffect(() => {
    const rows = inviteForm.scope === 'club' ? clubs : teams;
    if (rows.some(row => row.id === inviteForm.targetId)) return;
    setInviteForm(form => ({
      ...form,
      targetId: rows[0]?.id || '',
      role: form.scope === 'club' ? 'member' : 'fighter'
    }));
  }, [inviteForm.scope, clubs, teams]);

  if (!user) return <div className="state-card">Sign in to access platform control.</div>;
  if (!isSuperAdmin) return <div className="state-card">Platform super administrator access is required.</div>;

  const run = async (work: () => Promise<void>, success: string) => {
    setBusy(true);
    setMessage('');
    try {
      await work();
      await refreshOrganizations();
      await refreshSelected(selectedOrganizationId);
      setMessage(success);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'The requested change could not be completed.');
    } finally {
      setBusy(false);
    }
  };

  const inviteRoles = inviteForm.scope === 'club'
    ? (['club_admin', 'coach', 'member'] as ClubRole[])
    : (['team_admin', 'captain', 'coach', 'fighter', 'support'] as TeamRole[]);

  return <>
    <section className="section-head">
      <div>
        <span className="eyebrow">Platform owner</span>
        <h1>BuhurtOS Platform Control</h1>
        <p>You sit above every sporting organization in BuhurtOS. BI, HACSA, national federations, regional bodies, clubs and teams are managed underneath the platform rather than owning it.</p>
      </div>
      <div className="header-actions">
        <span className="status-chip">{dataMode === 'supabase' ? 'Live DB' : 'Demo'}</span>
        <span className="status-chip">Platform Super Admin</span>
      </div>
    </section>

    {message && <div className="auth-message">{message}</div>}

    <div className="admin-grid">
      <section className="panel-card">
        <h2>Create top-level organization</h2>
        <p>Create another organization at the same platform level as BI or HACSA. Relationships between organizations can be added later without changing BuhurtOS ownership.</p>
        <div className="form-stack">
          <input placeholder="Organization name" value={orgForm.name} onChange={e => setOrgForm(form => ({ ...form, name: e.target.value }))}/>
          <input placeholder="Short name" value={orgForm.shortName} onChange={e => setOrgForm(form => ({ ...form, shortName: e.target.value }))}/>
          <input placeholder="Region" value={orgForm.region} onChange={e => setOrgForm(form => ({ ...form, region: e.target.value }))}/>
          <input placeholder="Country code, e.g. CA" maxLength={2} value={orgForm.countryCode} onChange={e => setOrgForm(form => ({ ...form, countryCode: e.target.value }))}/>
          <label>Organization type
            <select value={orgForm.kind} onChange={e => setOrgForm(form => ({ ...form, kind: e.target.value as OrganizationKind }))}>
              {organizationKinds.map(kind => <option key={kind} value={kind}>{label(kind)}</option>)}
            </select>
          </label>
          <label>Visibility
            <select value={orgForm.visibility} onChange={e => setOrgForm(form => ({ ...form, visibility: e.target.value as EntityVisibility }))}>
              <option value="public">Public</option>
              <option value="members">Members</option>
              <option value="private">Private</option>
            </select>
          </label>
          <button className="primary big" disabled={busy || !orgForm.name.trim() || !orgForm.shortName.trim() || !orgForm.region.trim()} onClick={() => run(async () => {
            const id = await createPlatformOrganization({ ...orgForm, userId: user.userId });
            setSelectedOrganizationId(id);
            setOrgForm({ name: '', shortName: '', region: '', kind: 'international_federation', visibility: 'public', countryCode: '' });
          }, 'Organization created. You are its initial organization administrator.')}>Create Organization</button>
        </div>
      </section>

      <section className="panel-card">
        <h2>Manage any organization</h2>
        <label>Organization
          <select value={selectedOrganizationId} onChange={e => setSelectedOrganizationId(e.target.value)}>
            <option value="">Choose organization</option>
            {organizations.map(org => <option key={org.id} value={org.id}>{org.name} ({org.shortName})</option>)}
          </select>
        </label>
        {selectedOrganization && <div className="state-card">
          <strong>{selectedOrganization.name}</strong><br/>
          {label(selectedOrganization.kind || 'independent_organization')} · {selectedOrganization.region}
        </div>}

        <h3>Create club</h3>
        <div className="form-stack">
          <input placeholder="Club name" value={clubForm.name} onChange={e => setClubForm(form => ({ ...form, name: e.target.value }))}/>
          <input placeholder="Short name" value={clubForm.shortName} onChange={e => setClubForm(form => ({ ...form, shortName: e.target.value }))}/>
          <input placeholder="Region" value={clubForm.region} onChange={e => setClubForm(form => ({ ...form, region: e.target.value }))}/>
          <button disabled={busy || !selectedOrganizationId || !clubForm.name.trim()} onClick={() => run(async () => {
            await createGovernanceClub(selectedOrganizationId, {
              name: clubForm.name,
              shortName: clubForm.shortName || undefined,
              region: clubForm.region || undefined,
              visibility: 'members'
            });
            setClubForm({ name: '', shortName: '', region: '' });
          }, 'Club created.')}>Create Club</button>
        </div>

        <h3>Create team</h3>
        <div className="form-stack">
          <input placeholder="Team name" value={teamForm.name} onChange={e => setTeamForm(form => ({ ...form, name: e.target.value }))}/>
          <input placeholder="Short name" value={teamForm.shortName} onChange={e => setTeamForm(form => ({ ...form, shortName: e.target.value }))}/>
          <input placeholder="City or region" value={teamForm.region} onChange={e => setTeamForm(form => ({ ...form, region: e.target.value }))}/>
          <label>Club
            <select value={teamForm.clubId} onChange={e => setTeamForm(form => ({ ...form, clubId: e.target.value }))}>
              <option value="">Directly under organization</option>
              {clubs.map(club => <option key={club.id} value={club.id}>{club.name}</option>)}
            </select>
          </label>
          <button disabled={busy || !selectedOrganizationId || !teamForm.name.trim()} onClick={() => run(async () => {
            await createGovernanceTeam(selectedOrganizationId, {
              name: teamForm.name,
              shortName: teamForm.shortName || undefined,
              region: teamForm.region || undefined,
              clubId: teamForm.clubId || undefined,
              visibility: 'members'
            });
            setTeamForm({ name: '', shortName: '', region: '', clubId: '' });
          }, 'Team created.')}>Create Team</button>
        </div>
      </section>

      <section className="panel-card">
        <h2>Add people</h2>
        <p>Create secure invitations for administrators, captains, coaches, fighters, support staff or club members. They create their own personal account, then the invitation grants the scoped role.</p>
        <div className="form-stack">
          <label>Scope
            <select value={inviteForm.scope} onChange={e => setInviteForm({
              scope: e.target.value as 'team' | 'club',
              targetId: '',
              email: inviteForm.email,
              role: e.target.value === 'club' ? 'member' : 'fighter'
            })}>
              <option value="team">Team</option>
              <option value="club">Club</option>
            </select>
          </label>
          <label>Target
            <select value={inviteForm.targetId} onChange={e => setInviteForm(form => ({ ...form, targetId: e.target.value }))}>
              <option value="">Choose target</option>
              {(inviteForm.scope === 'club' ? clubs : teams).map(row => <option key={row.id} value={row.id}>{row.name}</option>)}
            </select>
          </label>
          <label>Role
            <select value={inviteForm.role} onChange={e => setInviteForm(form => ({ ...form, role: e.target.value as TeamRole | ClubRole }))}>
              {inviteRoles.map(role => <option key={role} value={role}>{label(role)}</option>)}
            </select>
          </label>
          <input type="email" placeholder="person@example.com" value={inviteForm.email} onChange={e => setInviteForm(form => ({ ...form, email: e.target.value }))}/>
          <button disabled={busy || !selectedOrganizationId || !inviteForm.targetId || !inviteForm.email.trim()} onClick={() => run(async () => {
            const token = await createMembershipInvitation(selectedOrganizationId, {
              scope: inviteForm.scope,
              targetId: inviteForm.targetId,
              email: inviteForm.email,
              clubRole: inviteForm.scope === 'club' ? inviteForm.role as ClubRole : undefined,
              teamRole: inviteForm.scope === 'team' ? inviteForm.role as TeamRole : undefined
            });
            const path = '/ops/invite?token=' + encodeURIComponent(token);
            setInviteLink(window.location.origin + window.location.pathname + '#' + path);
            setInviteForm(form => ({ ...form, email: '' }));
          }, 'Invitation created.')}>Create Invitation</button>
          {inviteLink && <div className="state-card"><strong>Invitation link</strong><br/><code>{inviteLink}</code></div>}
        </div>
      </section>

      <section className="panel-card">
        <h2>Current hierarchy</h2>
        <p>{organizations.length} organizations are currently registered in BuhurtOS.</p>
        <div className="membership-list">
          {organizations.map(org => <article key={org.id}>
            <div className="grow">
              <strong>{org.name}</strong>
              <small>{org.shortName} · {label(org.kind || 'independent_organization')} · {org.region}</small>
            </div>
            <button disabled={busy} onClick={() => setSelectedOrganizationId(org.id)}>Manage</button>
          </article>)}
        </div>
      </section>
    </div>
  </>;
}
