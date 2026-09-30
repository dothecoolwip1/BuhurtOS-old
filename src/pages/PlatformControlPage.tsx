import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppState } from '../features/AppState';
import {
  createGovernanceClub,
  createGovernanceTeam,
  createMembershipInvitation,
  createOrganizationRelationship,
  loadGovernanceSnapshot
} from '../lib/organizationAdmin';
import {
  createPlatformOrganization,
  listPlatformOrganizations,
  setPlatformOrganizationStatus,
  updatePlatformOrganization
} from '../lib/platformControl';
import { createEvent, createSeason, listEvents, listSeasons, setSeasonStatus, type SetupSeason } from '../lib/setup';
import type {
  ClubRole,
  EntityVisibility,
  EventType,
  Organization,
  OrganizationKind,
  OrganizationRelationship,
  OrganizationRelationshipKind,
  StandingsMode,
  TeamRole
} from '../types';
import { PlatformSettingsPanel } from '../components/PlatformSettingsPanel';

const organizationKinds: OrganizationKind[] = [
  'international_federation',
  'national_federation',
  'regional_organization',
  'local_organization',
  'independent_organization'
];

const relationshipKinds: OrganizationRelationshipKind[] = ['governs', 'recognizes', 'affiliate', 'sanctioned', 'predecessor'];
const eventTypes: EventType[] = ['tournament', 'exhibition', 'demo', 'training', 'clinic_workshop', 'recruitment', 'fundraiser', 'gathering_social', 'meeting_agm', 'community_appearance', 'custom', 'ranked_competitive', 'demo_fun', 'clinic_training'];
const standingsModes: StandingsMode[] = ['season_and_event', 'event_only', 'no_standings'];

const label = (value: string) => value.replaceAll('_', ' ').replace(/\b\w/g, letter => letter.toUpperCase());

export function PlatformControlPage() {
  const { user, dataMode } = useAppState();
  const isSuperAdmin = Boolean(user?.platformRoles.includes('platform_super_admin'));

  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [relationships, setRelationships] = useState<OrganizationRelationship[]>([]);
  const [selectedOrganizationId, setSelectedOrganizationId] = useState('');
  const [clubs, setClubs] = useState<Array<{ id: string; name: string }>>([]);
  const [teams, setTeams] = useState<Array<{ id: string; name: string }>>([]);
  const [seasons, setSeasons] = useState<SetupSeason[]>([]);
  const [events, setEvents] = useState<Array<{ id: string; name: string; venue: string; startsAt: string; status: string }>>([]);
  const selectionRequest = useRef(0);
  const [resourcesLoading, setResourcesLoading] = useState(true);
  const [organizationsLoaded, setOrganizationsLoaded] = useState(false);
  const [section, setSection] = useState('overview');
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
  const [editOrgForm, setEditOrgForm] = useState({
    name: '',
    shortName: '',
    region: '',
    kind: 'independent_organization' as OrganizationKind,
    visibility: 'members' as EntityVisibility,
    countryCode: ''
  });
  const [relationshipForm, setRelationshipForm] = useState({
    parentId: '',
    childId: '',
    kind: 'governs' as OrganizationRelationshipKind
  });
  const [seasonForm, setSeasonForm] = useState({
    name: '2026 Season',
    startsAt: '2026-01-01T00:00',
    endsAt: '2026-12-31T23:59'
  });
  const [eventForm, setEventForm] = useState({
    seasonId: '',
    name: '',
    venue: '',
    startsAt: '',
    endsAt: '',
    timezone: 'America/Edmonton',
    eventType: 'ranked_competitive' as EventType,
    standingsMode: 'season_and_event' as StandingsMode
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

  const selectedOrganization = useMemo(
    () => organizations.find(row => row.id === selectedOrganizationId),
    [organizations, selectedOrganizationId]
  );

  const refreshOrganizations = async () => {
    const rows = await listPlatformOrganizations();
    setOrganizations(rows);
    setOrganizationsLoaded(true);
    setSelectedOrganizationId(current => current || rows[0]?.id || '');
  };

  const refreshSelected = async (organizationId: string) => {
    const request = ++selectionRequest.current;
    setResourcesLoading(true);
    if (!organizationId) {
      setResourcesLoading(false);
      setRelationships([]);
      setClubs([]);
      setTeams([]);
      setSeasons([]);
      setEvents([]);
      return;
    }
    try {
      const [snapshot, seasonRows, eventRows] = await Promise.all([
        loadGovernanceSnapshot(organizationId),
        listSeasons(organizationId),
        listEvents(organizationId)
      ]);
      if (request !== selectionRequest.current) return;
      setRelationships(snapshot.relationships);
      setClubs(snapshot.clubs.map(row => ({ id: row.id, name: row.name })));
      setTeams(snapshot.teams.map(row => ({ id: row.id, name: row.name })));
      setSeasons(seasonRows);
      setEvents(eventRows);
      setEventForm(form => ({
        ...form,
        seasonId: seasonRows.some(row => row.id === form.seasonId) ? form.seasonId : seasonRows[0]?.id || ''
      }));
    } finally {
      if (request === selectionRequest.current) setResourcesLoading(false);
    }
  };

  useEffect(() => {
    if (!isSuperAdmin) return;
    refreshOrganizations().catch(error => setMessage(error instanceof Error ? error.message : 'Unable to load platform organizations.'));
  }, [isSuperAdmin]);

  useEffect(() => {
    refreshSelected(selectedOrganizationId).catch(error => setMessage(error instanceof Error ? error.message : 'Unable to load organization resources.'));
  }, [selectedOrganizationId]);

  useEffect(() => {
    if (!selectedOrganization) return;
    setEditOrgForm({
      name: selectedOrganization.name,
      shortName: selectedOrganization.shortName,
      region: selectedOrganization.region,
      kind: selectedOrganization.kind || 'independent_organization',
      visibility: selectedOrganization.visibility || 'members',
      countryCode: selectedOrganization.countryCode || ''
    });
    setRelationshipForm(form => ({ ...form, parentId: form.parentId || selectedOrganization.id }));
  }, [selectedOrganization?.id]);

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

  const activeRelationships = relationships.filter(row => !row.endsOn);

  return <div className="owner-console">
    <section className="owner-hero">
      <div><span className="eyebrow">BUHURTOS / ADMINISTRATION</span>
        <h1>Your platform.<br/><span>Under control.</span></h1>
        <p>Manage the organizations, people and events that bring the sport together.</p>
      </div>
      <Link className="owner-public-link" to="/public">View public site ↗</Link>
    </section>
    <div className="owner-workspace">
      <label>Working organization
        <select value={selectedOrganizationId} onChange={e => setSelectedOrganizationId(e.target.value)}>
          <option value="">Choose organization</option>
          {organizations.map(org => <option key={org.id} value={org.id}>{org.name}</option>)}
        </select>
      </label>
      <span className="owner-scope">{dataMode === 'supabase' ? 'Connected to live data' : 'Preview data'}<small>Teams, seasons and events below belong to this organization.</small></span>
    </div>
    <nav className="owner-tabs" aria-label="Platform sections">
      {[['overview', 'Overview'], ['organizations', 'Organizations'], ['events', 'Seasons & events'], ['people', 'Teams & people'], ['settings', 'Platform settings']].map(([id, title]) =>
        <button key={id} aria-current={section === id ? 'page' : undefined} onClick={() => setSection(id)}>{title}</button>)}
    </nav>
    {message && <div className="auth-message" role="status">{message}</div>}
    {section === 'overview' && <>
      <div className="owner-metrics">
        {[[organizationsLoaded ? organizations.length : '…', 'Organizations', 'Across the platform'], [resourcesLoading ? '…' : teams.length, 'Teams', 'In this organization'], [resourcesLoading ? '…' : events.length, 'Events', 'In this organization'], [resourcesLoading ? '…' : seasons.length, 'Seasons', 'In this organization']].map(([count, title, scope]) =>
          <div key={title}><span>{title}</span><strong>{count}</strong><small>{scope}</small></div>)}
      </div>
      <div className="owner-section-heading"><h2>Make things happen</h2><p>Your everyday administration tools.</p></div>
      <div className="owner-shortcuts">
        {[
          ['/ops/access-admin', '01', 'Accounts & access', 'Manage who can use the platform.'],
          ['/ops/codes', '02', 'Access codes', 'Control invitations and delegated access.'],
          ['/ops/identity-review', '03', 'Identity review', 'Resolve fighter claims and duplicate records.'],
          ['/ops/rulesets', '04', 'Rulesets', 'Manage the rules behind competition.'],
          ['/ops/foundation', '05', 'Fighters & divisions', 'Organize sporting identities and divisions.'],
          ['/ops/setup', '06', 'Event setup', 'Prepare the next event for your community.']
        ].map(([to, number, title, description]) => <Link key={to} to={to}><span className="shortcut-number">{number}</span><strong>{title}<span>↗</span></strong><p>{description}</p></Link>)}
      </div>
    </>}
    <div className="admin-grid">
      {section === 'settings' && <PlatformSettingsPanel isSuperAdmin={isSuperAdmin} />}
      <section className="panel-card" hidden={section !== 'organizations'}>
        <h2>Create top-level organization</h2>
        <p>Create another organization at the same platform level as BI or HACSA.</p>
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

      <section className="panel-card" hidden={section !== 'organizations'}>
        <h2>Edit any organization</h2>
        <label>Organization
          <select value={selectedOrganizationId} onChange={e => setSelectedOrganizationId(e.target.value)}>
            <option value="">Choose organization</option>
            {organizations.map(org => <option key={org.id} value={org.id}>{org.name} ({org.shortName})</option>)}
          </select>
        </label>
        {selectedOrganization && <div className="form-stack">
          <input value={editOrgForm.name} onChange={e => setEditOrgForm(form => ({ ...form, name: e.target.value }))}/>
          <input value={editOrgForm.shortName} onChange={e => setEditOrgForm(form => ({ ...form, shortName: e.target.value }))}/>
          <input value={editOrgForm.region} onChange={e => setEditOrgForm(form => ({ ...form, region: e.target.value }))}/>
          <input placeholder="Country code" maxLength={2} value={editOrgForm.countryCode} onChange={e => setEditOrgForm(form => ({ ...form, countryCode: e.target.value }))}/>
          <label>Type
            <select value={editOrgForm.kind} onChange={e => setEditOrgForm(form => ({ ...form, kind: e.target.value as OrganizationKind }))}>
              {organizationKinds.map(kind => <option key={kind} value={kind}>{label(kind)}</option>)}
            </select>
          </label>
          <label>Visibility
            <select value={editOrgForm.visibility} onChange={e => setEditOrgForm(form => ({ ...form, visibility: e.target.value as EntityVisibility }))}>
              <option value="public">Public</option>
              <option value="members">Members</option>
              <option value="private">Private</option>
            </select>
          </label>
          <button disabled={busy} onClick={() => run(
            () => updatePlatformOrganization({ id: selectedOrganization.id, ...editOrgForm }),
            'Organization updated.'
          )}>Save Organization</button>
          <button disabled={busy} onClick={() => run(
            () => setPlatformOrganizationStatus(selectedOrganization.id, selectedOrganization.status === 'active' ? 'inactive' : 'active'),
            selectedOrganization.status === 'active' ? 'Organization deactivated.' : 'Organization activated.'
          )}>{selectedOrganization.status === 'active' ? 'Deactivate Organization' : 'Activate Organization'}</button>
        </div>}
      </section>

      <section className="panel-card" hidden={section !== 'organizations'}>
        <h2>Organization hierarchy</h2>
        <p>Define who governs, recognizes, affiliates with or sanctions whom. BuhurtOS remains above the entire tree.</p>
        <div className="form-stack">
          <label>Parent
            <select value={relationshipForm.parentId} onChange={e => setRelationshipForm(form => ({ ...form, parentId: e.target.value }))}>
              <option value="">Choose parent</option>
              {organizations.map(org => <option key={org.id} value={org.id}>{org.name}</option>)}
            </select>
          </label>
          <label>Child
            <select value={relationshipForm.childId} onChange={e => setRelationshipForm(form => ({ ...form, childId: e.target.value }))}>
              <option value="">Choose child</option>
              {organizations.map(org => <option key={org.id} value={org.id}>{org.name}</option>)}
            </select>
          </label>
          <label>Relationship
            <select value={relationshipForm.kind} onChange={e => setRelationshipForm(form => ({ ...form, kind: e.target.value as OrganizationRelationshipKind }))}>
              {relationshipKinds.map(kind => <option key={kind} value={kind}>{label(kind)}</option>)}
            </select>
          </label>
          <button disabled={busy || !relationshipForm.parentId || !relationshipForm.childId || relationshipForm.parentId === relationshipForm.childId} onClick={() => run(
            () => createOrganizationRelationship(selectedOrganizationId, relationshipForm.parentId, relationshipForm.childId, relationshipForm.kind).then(() => undefined),
            'Organization relationship created.'
          )}>Add Relationship</button>
        </div>
        <div className="membership-list">
          {activeRelationships.length === 0 ? <div className="state-card">No active organization relationships.</div> : activeRelationships.map(row => {
            const parent = organizations.find(org => org.id === row.parentOrganizationId);
            const child = organizations.find(org => org.id === row.childOrganizationId);
            return <article key={row.id}><div>
              <strong>{parent?.name || 'Organization'} → {child?.name || 'Organization'}</strong>
              <small>{label(row.relationshipKind)}</small>
            </div></article>;
          })}
        </div>
      </section>

      <section className="panel-card" hidden={section !== 'events'}>
        <h2>Seasons</h2>
        <div className="form-stack">
          <input placeholder="Season name" value={seasonForm.name} onChange={e => setSeasonForm(form => ({ ...form, name: e.target.value }))}/>
          <label>Starts<input type="datetime-local" value={seasonForm.startsAt} onChange={e => setSeasonForm(form => ({ ...form, startsAt: e.target.value }))}/></label>
          <label>Ends<input type="datetime-local" value={seasonForm.endsAt} onChange={e => setSeasonForm(form => ({ ...form, endsAt: e.target.value }))}/></label>
          <button disabled={busy || !selectedOrganizationId || !seasonForm.name.trim()} onClick={() => run(async () => {
            await createSeason({
              organizationId: selectedOrganizationId,
              name: seasonForm.name,
              startsAt: new Date(seasonForm.startsAt).toISOString(),
              endsAt: new Date(seasonForm.endsAt).toISOString(),
              userId: user.userId
            });
          }, 'Season created.')}>Create Season</button>
        </div>
        <div className="membership-list">
          {seasons.length === 0 ? <div className="state-card">No seasons yet.</div> : seasons.map(season => <article key={season.id}>
            <div className="grow">
              <strong>{season.name}</strong>
              <small>{label(season.status)} · {new Date(season.startsAt).toLocaleDateString()} – {new Date(season.endsAt).toLocaleDateString()}</small>
            </div>
            {season.status !== 'active' && <button disabled={busy} onClick={() => run(
              () => setSeasonStatus(selectedOrganizationId, season.id, 'active', season.updatedAt),
              'Season activated.'
            )}>Activate</button>}
            {season.status === 'active' && <button disabled={busy} onClick={() => run(
              () => setSeasonStatus(selectedOrganizationId, season.id, 'archived', season.updatedAt),
              'Season archived.'
            )}>Archive</button>}
          </article>)}
        </div>
      </section>

      <section className="panel-card" hidden={section !== 'events'}>
        <h2>Events</h2>
        <div className="form-stack">
          <label>Season
            <select value={eventForm.seasonId} onChange={e => setEventForm(form => ({ ...form, seasonId: e.target.value }))}>
              <option value="">Choose season</option>
              {seasons.map(season => <option key={season.id} value={season.id}>{season.name}</option>)}
            </select>
          </label>
          <input placeholder="Event name" value={eventForm.name} onChange={e => setEventForm(form => ({ ...form, name: e.target.value }))}/>
          <input placeholder="Venue" value={eventForm.venue} onChange={e => setEventForm(form => ({ ...form, venue: e.target.value }))}/>
          <label>Starts<input type="datetime-local" value={eventForm.startsAt} onChange={e => setEventForm(form => ({ ...form, startsAt: e.target.value }))}/></label>
          <label>Ends<input type="datetime-local" value={eventForm.endsAt} onChange={e => setEventForm(form => ({ ...form, endsAt: e.target.value }))}/></label>
          <label>Event type
            <select value={eventForm.eventType} onChange={e => setEventForm(form => ({ ...form, eventType: e.target.value as EventType }))}>
              {eventTypes.map(type => <option key={type} value={type}>{label(type)}</option>)}
            </select>
          </label>
          <label>Standings
            <select value={eventForm.standingsMode} onChange={e => setEventForm(form => ({ ...form, standingsMode: e.target.value as StandingsMode }))}>
              {standingsModes.map(mode => <option key={mode} value={mode}>{label(mode)}</option>)}
            </select>
          </label>
          <button disabled={busy || !selectedOrganizationId || !eventForm.seasonId || !eventForm.name.trim() || !eventForm.venue.trim() || !eventForm.startsAt || !eventForm.endsAt} onClick={() => run(async () => {
            await createEvent({
              organizationId: selectedOrganizationId,
              seasonId: eventForm.seasonId,
              name: eventForm.name,
              venue: eventForm.venue,
              startsAt: new Date(eventForm.startsAt).toISOString(),
              endsAt: new Date(eventForm.endsAt).toISOString(),
              timezone: eventForm.timezone,
              eventType: eventForm.eventType,
              standingsMode: eventForm.standingsMode,
              userId: user.userId
            });
            setEventForm(form => ({ ...form, name: '', venue: '', startsAt: '', endsAt: '' }));
          }, 'Draft event created.')}>Create Draft Event</button>
        </div>
        <div className="membership-list">
          {events.length === 0 ? <div className="state-card">No events yet.</div> : events.map(event => <article key={event.id}>
            <div className="grow">
              <strong>{event.name}</strong>
              <small>{event.venue} · {label(event.status)} · {new Date(event.startsAt).toLocaleString()}</small>
            </div>
            <Link className="button" to={'/ops/manage?event=' + event.id}>Manage</Link>
          </article>)}
        </div>
      </section>

      <section className="panel-card" hidden={section !== 'people'}>
        <h2>Clubs & teams</h2>
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
        <small>{clubs.length} clubs · {teams.length} teams in the selected organization</small>
      </section>

      <section className="panel-card" hidden={section !== 'people'}>
        <h2>Add people</h2>
        <p>Invite admins, captains, coaches, fighters, support staff or club members. Their account remains personal while the role is scoped to the organization structure you choose.</p>
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

      <section className="panel-card" hidden={section !== 'overview'}>
        <h2>Platform inventory</h2>
        <p>{organizations.length} organizations are currently registered in BuhurtOS.</p>
        <div className="membership-list">
          {organizations.map(org => <article key={org.id}>
            <div className="grow">
              <strong>{org.name}</strong>
              <small>{org.shortName} · {label(org.kind || 'independent_organization')} · {org.region} · {label(org.status)}</small>
            </div>
            <button disabled={busy} onClick={() => { setSelectedOrganizationId(org.id); setSection('organizations'); }}>Manage</button>
          </article>)}
        </div>
      </section>
    </div>
  </div>;
}
