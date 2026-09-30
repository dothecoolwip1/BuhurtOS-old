import { describe, expect, it, vi } from 'vitest';
import loginSource from '../src/pages/LoginPage.tsx?raw';
import panelSource from '../src/components/PlatformSettingsPanel.tsx?raw';
import { isStatsLayerMissing } from '../src/lib/publicStats';

vi.mock('../src/lib/supabase', () => ({
  isSupabaseConfigured: true,
  supabase: null,
  publicSupabase: { rpc: async () => ({ data: null, error: { code: '500', message: 'boom' } }) }
}));

import { defaultPlatformConfig, loadPlatformConfig, loadPlatformConfigStatus } from '../src/lib/platformConfig';

describe('platform configuration failures', () => {
  it('reports that the values are only defaults when the server could not be read', async () => {
    const status = await loadPlatformConfigStatus(true);
    expect(status.source).toBe('default');
    expect(status.error).toBeTruthy();
    expect(status.config).toEqual(defaultPlatformConfig);
    expect(await loadPlatformConfig(true)).toEqual(defaultPlatformConfig);
  });
  it('tells admins the registration switch is not a server lock', () => {
    expect(panelSource).toContain('does not lock account creation');
    expect(panelSource).toContain('could not be confirmed');
  });
});

describe('sign-in form', () => {
  it('submits with Enter: one real form, primary actions are submit buttons', () => {
    expect(loginSource).toContain('<form onSubmit={submit}');
    expect(loginSource).not.toMatch(/className="primary big"[^>]*onClick=/);
    expect(loginSource).toContain('type="submit"');
  });
  it('explains the four kinds of access', () => {
    for (const phrase of ['Early access code', 'Role code or invitation', 'Event signup code']) expect(loginSource).toContain(phrase);
  });
});

describe('stats layer errors', () => {
  it('treats a missing function as unavailable but anything else as a failure', () => {
    expect(isStatsLayerMissing({ code: 'PGRST202' })).toBe(true);
    expect(isStatsLayerMissing({ message: 'Could not find the function public.official_team_stats' })).toBe(true);
    expect(isStatsLayerMissing({ code: '57014', message: 'statement timeout' })).toBe(false);
    expect(isStatsLayerMissing(null)).toBe(false);
  });
});
