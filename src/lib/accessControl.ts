import { supabase } from './supabase';

export interface AccessCodeSummary {
  id: string;
  codePrefix: string;
  label: string;
  notes?: string;
  maxUses?: number;
  activeUses: number;
  totalRedemptions: number;
  expiresAt?: string;
  disabledAt?: string;
  createdAt: string;
}

export interface AccessUserSummary {
  userId: string;
  displayEmail: string;
  codeLabel: string;
  redeemedAt: string;
  revokedAt?: string;
}

export interface CreatedAccessCode {
  id: string;
  code: string;
  label: string;
  maxUses?: number;
  expiresAt?: string;
}

export async function redeemAccessCode(code: string): Promise<{ label?: string; alreadyRedeemed?: boolean }> {
  if (!supabase) throw new Error('BuhurtOS is not connected to its production database.');
  const normalized = code.trim().toUpperCase();
  if (!normalized) throw new Error('Enter your access code.');
  const { data, error } = await supabase.rpc('redeem_buhurtos_access_code', { p_code: normalized });
  if (error) throw error;
  const result = (data ?? {}) as Record<string, unknown>;
  return {
    label: typeof result.label === 'string' ? result.label : undefined,
    alreadyRedeemed: result.already_redeemed === true
  };
}

export async function hasBuhurtOSAccess(): Promise<boolean> {
  if (!supabase) return true;
  const { data, error } = await supabase.rpc('has_buhurtos_access');
  if (error) throw error;
  return data === true;
}

export async function createAccessCode(input: {
  label: string;
  maxUses?: number;
  expiresAt?: string;
  notes?: string;
}): Promise<CreatedAccessCode> {
  if (!supabase) throw new Error('BuhurtOS is not connected to its production database.');
  const { data, error } = await supabase.rpc('create_buhurtos_access_code', {
    p_label: input.label.trim(),
    p_max_uses: input.maxUses ?? null,
    p_expires_at: input.expiresAt ? new Date(input.expiresAt).toISOString() : null,
    p_notes: input.notes?.trim() || null
  });
  if (error) throw error;
  const row = (data ?? {}) as Record<string, unknown>;
  return {
    id: String(row.id ?? ''),
    code: String(row.code ?? ''),
    label: String(row.label ?? input.label),
    maxUses: typeof row.max_uses === 'number' ? row.max_uses : undefined,
    expiresAt: typeof row.expires_at === 'string' ? row.expires_at : undefined
  };
}

export async function listAccessCodes(): Promise<AccessCodeSummary[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_buhurtos_access_codes');
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    id: row.id,
    codePrefix: row.code_prefix,
    label: row.label,
    notes: row.notes ?? undefined,
    maxUses: row.max_uses ?? undefined,
    activeUses: Number(row.active_uses ?? 0),
    totalRedemptions: Number(row.total_redemptions ?? 0),
    expiresAt: row.expires_at ?? undefined,
    disabledAt: row.disabled_at ?? undefined,
    createdAt: row.created_at
  }));
}

export async function revokeAccessCode(codeId: string): Promise<void> {
  if (!supabase) return;
  const { error } = await supabase.rpc('revoke_buhurtos_access_code', { p_code_id: codeId });
  if (error) throw error;
}

export async function listAccessUsers(): Promise<AccessUserSummary[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_buhurtos_access_users');
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    userId: row.user_id,
    displayEmail: row.display_email,
    codeLabel: row.code_label,
    redeemedAt: row.redeemed_at,
    revokedAt: row.revoked_at ?? undefined
  }));
}

export async function revokeUserAccess(userId: string): Promise<void> {
  if (!supabase) return;
  const { error } = await supabase.rpc('revoke_buhurtos_user_access', { p_user_id: userId });
  if (error) throw error;
}
