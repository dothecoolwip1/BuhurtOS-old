import type { EntityVisibility, Organization, OrganizationKind } from '../types';
import { supabase } from './supabase';

function rowToOrganization(row: any): Organization {
  return {
    id: row.id,
    name: row.name,
    shortName: row.short_name,
    region: row.region,
    status: row.status,
    kind: row.kind ?? undefined,
    visibility: row.visibility ?? undefined,
    countryCode: row.country_code ?? undefined,
    websiteUrl: row.website_url ?? undefined,
    publicContactEmail: row.public_contact_email ?? undefined
  };
}

export async function listPlatformOrganizations(): Promise<Organization[]> {
  if (!supabase) return [];
  const { data, error } = await supabase
    .from('organizations')
    .select('id,name,short_name,region,status,kind,visibility,country_code,website_url,public_contact_email')
    .order('name');
  if (error) throw error;
  return (data ?? []).map(rowToOrganization);
}

export async function createPlatformOrganization(input: {
  name: string;
  shortName: string;
  region: string;
  kind: OrganizationKind;
  visibility: EntityVisibility;
  countryCode?: string;
  userId: string;
}): Promise<string> {
  if (!supabase) throw new Error('Supabase is not configured.');
  if (!input.name.trim() || !input.shortName.trim() || !input.region.trim()) {
    throw new Error('Name, short name, and region are required.');
  }

  const { data, error } = await supabase
    .from('organizations')
    .insert({
      name: input.name.trim(),
      short_name: input.shortName.trim(),
      region: input.region.trim(),
      kind: input.kind,
      visibility: input.visibility,
      country_code: input.countryCode?.trim().toUpperCase() || null,
      status: 'active',
      created_by: input.userId,
      last_edited_by: input.userId
    })
    .select('id')
    .single();

  if (error) throw error;

  const { error: roleError } = await supabase.rpc('assign_organization_role', {
    p_organization_id: data.id,
    p_user_id: input.userId,
    p_role: 'organization_admin'
  });
  if (roleError) throw roleError;
  return data.id;
}
