import { describe, expect, it } from 'vitest';
import {
  canSelfRegister, defaultPlatformConfig, isClaimEnabled, loadPlatformConfig, parsePlatformConfig, registrationNeedsInvite
} from '../src/lib/platformConfig';

describe('platform configuration layer', () => {
  it('defaults preserve launch behavior', () => {
    expect(defaultPlatformConfig).toEqual({
      accountRegistrationMode: 'open',
      eventCreationMode: 'approved_organizers',
      organizationClaimsEnabled: false,
      teamClaimsEnabled: false,
      fighterClaimsEnabled: false,
      eventClaimsEnabled: false
    });
  });

  it('parses the RPC payload and ignores invalid values', () => {
    const parsed = parsePlatformConfig({
      account_registration_mode: 'invite_only',
      event_creation_mode: 'platform_only',
      team_claims_enabled: true,
      organization_claims_enabled: 'yes',
      event_claims_enabled: 1
    });
    expect(parsed.accountRegistrationMode).toBe('invite_only');
    expect(parsed.eventCreationMode).toBe('platform_only');
    expect(parsed.teamClaimsEnabled).toBe(true);
    expect(parsed.organizationClaimsEnabled).toBe(false);
    expect(parsed.eventClaimsEnabled).toBe(false);
    expect(parsePlatformConfig({ account_registration_mode: 'anything' }).accountRegistrationMode).toBe('open');
    expect(parsePlatformConfig(null)).toEqual(defaultPlatformConfig);
    expect(parsePlatformConfig('nonsense')).toEqual(defaultPlatformConfig);
  });

  it('answers registration and claim questions in one place', () => {
    expect(canSelfRegister({ ...defaultPlatformConfig, accountRegistrationMode: 'disabled' })).toBe(false);
    expect(canSelfRegister({ ...defaultPlatformConfig, accountRegistrationMode: 'invite_only' })).toBe(true);
    expect(registrationNeedsInvite({ ...defaultPlatformConfig, accountRegistrationMode: 'invite_only' })).toBe(true);
    expect(registrationNeedsInvite(defaultPlatformConfig)).toBe(false);
    const config = { ...defaultPlatformConfig, teamClaimsEnabled: true };
    expect(isClaimEnabled(config, 'team')).toBe(true);
    expect(isClaimEnabled(config, 'organization')).toBe(false);
    expect(isClaimEnabled(config, 'fighter')).toBe(false);
    expect(isClaimEnabled(config, 'event')).toBe(false);
  });

  it('falls back to launch defaults when no backend is configured', async () => {
    expect(await loadPlatformConfig(true)).toEqual(defaultPlatformConfig);
  });
});
