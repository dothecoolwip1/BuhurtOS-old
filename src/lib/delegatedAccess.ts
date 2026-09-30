import { supabase } from './supabase';

export type DelegatedScope = 'organization' | 'club' | 'team';

export interface DelegatedAccessTarget {
  scope: DelegatedScope;
  targetId: string;
  targetName: string;
  role: string;
}

export interface DelegatedAccessCodeSummary {
  id: string;
  codePrefix: string;
  label: string;
  targetScope: DelegatedScope;
  targetId: string;
  targetName: string;
  role: string;
  maxUses: number;
  activeUses: number;
  expiresAt?: string;
  disabledAt?: string;
  createdBy: string;
  createdAt: string;
}

export async function listDelegatedAccessTargets(): Promise<DelegatedAccessTarget[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_delegated_access_targets');
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    scope: row.scope,
    targetId: row.target_id,
    targetName: row.target_name,
    role: row.role
  }));
}

export async function createDelegatedAccessCode(input: {
  scope: DelegatedScope;
  targetId: string;
  role: string;
  label?: string;
  maxUses?: number;
  expiresAt?: string;
}): Promise<string> {
  if (!supabase) throw new Error('BuhurtOS is not connected to its production database.');
  const { data, error } = await supabase.rpc('create_delegated_access_code', {
    p_scope: input.scope,
    p_target: input.targetId,
    p_role: input.role,
    p_label: input.label?.trim() || null,
    p_max_uses: input.maxUses ?? 1,
    p_expires_at: input.expiresAt ? new Date(input.expiresAt).toISOString() : null
  });
  if (error) throw error;
  return String(data ?? '');
}

export async function listDelegatedAccessCodes(): Promise<DelegatedAccessCodeSummary[]> {
  if (!supabase) return [];
  const { data, error } = await supabase.rpc('list_delegated_access_codes');
  if (error) throw error;
  return (data ?? []).map((row: any) => ({
    id: row.id,
    codePrefix: row.code_prefix,
    label: row.label,
    targetScope: row.target_scope,
    targetId: row.target_id,
    targetName: row.target_name,
    role: row.role,
    maxUses: Number(row.max_uses ?? 1),
    activeUses: Number(row.active_uses ?? 0),
    expiresAt: row.expires_at ?? undefined,
    disabledAt: row.disabled_at ?? undefined,
    createdBy: row.created_by,
    createdAt: row.created_at
  }));
}

export async function disableDelegatedAccessCode(id: string): Promise<void> {
  if (!supabase) return;
  const { error } = await supabase.rpc('disable_delegated_access_code', { p_id: id });
  if (error) throw error;
}

export async function redeemDelegatedAccessCode(code: string): Promise<{
  scope: DelegatedScope;
  targetId: string;
  targetName: string;
  role: string;
}> {
  if (!supabase) throw new Error('BuhurtOS is not connected to its production database.');
  const { data, error } = await supabase.rpc('redeem_delegated_access_code', { p_code: code.trim().toUpperCase() });
  if (error) throw error;
  const row = (data ?? {}) as any;
  return {
    scope: row.scope,
    targetId: row.targetId,
    targetName: row.targetName,
    role: row.role
  };
}
