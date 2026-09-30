import { useEffect, useState } from 'react';
import {
  defaultPlatformConfig, eventCreationModes, listClaimRequests, loadPlatformConfigStatus, registrationModes,
  reviewClaimRequest, savePlatformSetting, settingLabels, type ClaimRequestRow, type PlatformConfig
} from '../lib/platformConfig';

const claimFlags: Array<[keyof PlatformConfig, string]> = [
  ['organizationClaimsEnabled', 'organization_claims_enabled'],
  ['teamClaimsEnabled', 'team_claims_enabled'],
  ['fighterClaimsEnabled', 'fighter_claims_enabled'],
  ['eventClaimsEnabled', 'event_claims_enabled']
];

/** Owner console panel: adoption switches and claim review. Changes are enforced by the database. */
export function PlatformSettingsPanel({ isSuperAdmin }: { isSuperAdmin: boolean }) {
  const [config, setConfig] = useState<PlatformConfig>(defaultPlatformConfig);
  const [claims, setClaims] = useState<ClaimRequestRow[]>([]);
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const [loadProblem, setLoadProblem] = useState('');

  useEffect(() => {
    let active = true;
    loadPlatformConfigStatus(true).then(status => { if (active) { setConfig(status.config); setLoadProblem(status.error ?? (status.source === 'default' ? 'No live settings were returned, so launch defaults are shown.' : '')); } });
    if (isSuperAdmin) listClaimRequests().then(rows => { if (active) setClaims(rows); }).catch(() => undefined);
    return () => { active = false; };
  }, [isSuperAdmin]);

  async function change(key: string, value: string | boolean) {
    setBusy(true); setMessage('');
    try { setConfig(await savePlatformSetting(key, value)); setMessage('Setting saved.'); }
    catch (err) { setMessage(err instanceof Error ? err.message : 'Could not save the setting.'); }
    finally { setBusy(false); }
  }

  async function decide(id: string, decision: 'approved' | 'rejected') {
    setBusy(true); setMessage('');
    try {
      await reviewClaimRequest(id, decision);
      setClaims(await listClaimRequests());
      setMessage(decision === 'approved' ? 'Claim approved. Grant the matching role from Teams & people.' : 'Claim rejected.');
    } catch (err) { setMessage(err instanceof Error ? err.message : 'Could not review the claim.'); }
    finally { setBusy(false); }
  }

  return <>
    <section className="panel-card">
      <h2>Adoption switches</h2>
      <p>One place to control how open the platform is. Public viewing always stays open.</p>
      {loadProblem ? <p className="hint" role="alert">The live settings could not be confirmed: {loadProblem} The values shown may not match what is actually in effect; reload before changing anything.</p> : null}
      {!isSuperAdmin ? <p className="hint">Only platform super administrators can change these settings.</p> : null}
      <div className="form-stack">
        <label>{settingLabels.account_registration_mode}
          <select disabled={!isSuperAdmin || busy} value={config.accountRegistrationMode} onChange={e => change('account_registration_mode', e.target.value)}>
            {registrationModes.map(mode => <option key={mode} value={mode}>{settingLabels[mode]}</option>)}
          </select>
          <small>Controls whether this site offers the sign-up form. It does not lock account creation at the authentication service, so treat it as guidance for visitors, not a security control. Event creation and claim switches below are enforced by the database.</small>
        </label>
        <label>{settingLabels.event_creation_mode}
          <select disabled={!isSuperAdmin || busy} value={config.eventCreationMode} onChange={e => change('event_creation_mode', e.target.value)}>
            {eventCreationModes.map(mode => <option key={mode} value={mode}>{settingLabels[mode]}</option>)}
          </select>
        </label>
        {claimFlags.map(([field, key]) => <label key={key} className="checkbox-line">
          <input type="checkbox" disabled={!isSuperAdmin || busy} checked={Boolean(config[field])} onChange={e => change(key, e.target.checked)} />
          <span>{settingLabels[key]} enabled</span>
        </label>)}
        {message ? <p className="hint" role="status">{message}</p> : null}
      </div>
    </section>
    {isSuperAdmin ? <section className="panel-card">
      <h2>Claim requests</h2>
      {claims.length === 0 ? <p className="hint">No claim requests yet. Claims stay off until you enable them above.</p> : <div className="membership-list">
        {claims.map(claim => <article key={claim.id}>
          <div className="grow"><strong>{claim.entityType} · {claim.entityId.slice(0, 8)}</strong><small>{claim.status} · {new Date(claim.createdAt).toLocaleDateString()}{claim.message ? ` · ${claim.message}` : ''}</small></div>
          {claim.status === 'pending' ? <><button disabled={busy} onClick={() => decide(claim.id, 'approved')}>Approve</button><button disabled={busy} onClick={() => decide(claim.id, 'rejected')}>Reject</button></> : null}
        </article>)}
      </div>}
    </section> : null}
  </>;
}
