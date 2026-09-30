import { publicSupabase, supabase } from './supabase';

/**
 * Single platform configuration layer. Every adoption switch is read from here
 * (backed by public.platform_settings) so components never hardcode mode checks.
 */
export type AccountRegistrationMode = 'disabled' | 'invite_only' | 'open';
export type EventCreationMode = 'platform_only' | 'approved_organizers' | 'organization_members' | 'open';
export type ClaimEntityType = 'organization' | 'team' | 'fighter' | 'event';

export type PlatformConfig = {
  accountRegistrationMode: AccountRegistrationMode;
  eventCreationMode: EventCreationMode;
  organizationClaimsEnabled: boolean;
  teamClaimsEnabled: boolean;
  fighterClaimsEnabled: boolean;
  eventClaimsEnabled: boolean;
};

/** Launch behavior: public viewing open, operations controlled, claims off. */
export const defaultPlatformConfig: PlatformConfig = {
  accountRegistrationMode: 'open',
  eventCreationMode: 'approved_organizers',
  organizationClaimsEnabled: false,
  teamClaimsEnabled: false,
  fighterClaimsEnabled: false,
  eventClaimsEnabled: false
};

export const registrationModes: AccountRegistrationMode[] = ['disabled', 'invite_only', 'open'];
export const eventCreationModes: EventCreationMode[] = ['platform_only', 'approved_organizers', 'organization_members', 'open'];

export const settingLabels: Record<string, string> = {
  disabled: 'Disabled',
  invite_only: 'Invite only',
  open: 'Open',
  platform_only: 'Platform administrators only',
  approved_organizers: 'Approved organizers',
  organization_members: 'Organization members',
  account_registration_mode: 'Account registration',
  event_creation_mode: 'Event creation',
  organization_claims_enabled: 'Organization claims',
  team_claims_enabled: 'Team claims',
  fighter_claims_enabled: 'Fighter claims',
  event_claims_enabled: 'Event claims'
};

/** Normalizes the RPC payload; unknown or invalid values fall back to the launch defaults. */
export function parsePlatformConfig(raw: unknown): PlatformConfig {
  const source = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>;
  const pick = <T extends string>(value: unknown, allowed: readonly T[], fallback: T): T =>
    typeof value === 'string' && (allowed as readonly string[]).includes(value) ? (value as T) : fallback;
  const flag = (value: unknown, fallback: boolean) => (typeof value === 'boolean' ? value : fallback);
  return {
    accountRegistrationMode: pick(source.account_registration_mode, registrationModes, defaultPlatformConfig.accountRegistrationMode),
    eventCreationMode: pick(source.event_creation_mode, eventCreationModes, defaultPlatformConfig.eventCreationMode),
    organizationClaimsEnabled: flag(source.organization_claims_enabled, false),
    teamClaimsEnabled: flag(source.team_claims_enabled, false),
    fighterClaimsEnabled: flag(source.fighter_claims_enabled, false),
    eventClaimsEnabled: flag(source.event_claims_enabled, false)
  };
}

export function canSelfRegister(config: PlatformConfig): boolean {
  return config.accountRegistrationMode !== 'disabled';
}

export function registrationNeedsInvite(config: PlatformConfig): boolean {
  return config.accountRegistrationMode === 'invite_only';
}

export function isClaimEnabled(config: PlatformConfig, entity: ClaimEntityType): boolean {
  switch (entity) {
    case 'organization': return config.organizationClaimsEnabled;
    case 'team': return config.teamClaimsEnabled;
    case 'fighter': return config.fighterClaimsEnabled;
    case 'event': return config.eventClaimsEnabled;
  }
}

const CACHE_MS = 60 * 1000;
let cache: { at: number; value: PlatformConfig } | undefined;

export async function loadPlatformConfig(force = false): Promise<PlatformConfig> {
  const client = publicSupabase ?? supabase;
  if (!client) return defaultPlatformConfig;
  if (!force && cache && Date.now() - cache.at < CACHE_MS) return cache.value;
  try {
    const { data, error } = await client.rpc('get_platform_config');
    if (error) throw error;
    const value = parsePlatformConfig(data);
    cache = { at: Date.now(), value };
    return value;
  } catch {
    // Backends that predate the configuration layer keep launch behavior; do not retry for a minute.
    cache = { at: Date.now(), value: cache?.value ?? defaultPlatformConfig };
    return cache.value;
  }
}

export async function savePlatformSetting(key: string, value: string | boolean): Promise<PlatformConfig> {
  if (!supabase) throw new Error('Supabase is not configured.');
  const { data, error } = await supabase.rpc('set_platform_setting', { p_key: key, p_value: value });
  if (error) throw error;
  const next = parsePlatformConfig(data);
  cache = { at: Date.now(), value: next };
  return next;
}

export type ClaimRequestRow = {
  id: string;
  entityType: ClaimEntityType;
  entityId: string;
  requestedBy: string;
  message: string;
  status: 'pending' | 'approved' | 'rejected' | 'withdrawn';
  createdAt: string;
  reviewNote?: string;
};

export async function listClaimRequests(): Promise<ClaimRequestRow[]> {
  if (!supabase) return [];
  const { data, error } = await supabase
    .from('claim_requests')
    .select('id,entity_type,entity_id,requested_by,message,status,created_at,review_note')
    .order('created_at', { ascending: false })
    .limit(100);
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    id: row.id, entityType: row.entity_type, entityId: row.entity_id, requestedBy: row.requested_by,
    message: row.message ?? '', status: row.status, createdAt: row.created_at, reviewNote: row.review_note ?? undefined
  }));
}

export async function reviewClaimRequest(id: string, decision: 'approved' | 'rejected', note?: string): Promise<void> {
  if (!supabase) throw new Error('Supabase is not configured.');
  const { error } = await supabase.rpc('review_claim_request', { p_claim: id, p_decision: decision, p_note: note ?? null });
  if (error) throw error;
}
