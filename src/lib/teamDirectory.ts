import { hacsaTeams } from '../data/hacsaTeams';
import { publicSupabase } from './supabase';

export type PublicDirectoryTeam = {
  id: string;
  slug: string;
  organizationId?: string;
  organizationName: string;
  organizationShortName: string;
  name: string;
  location: string;
  continentCode: string;
  continentName: string;
  countryCode: string;
  countryName: string;
  adminAreaCode: string;
  adminAreaName: string;
  email?: string;
  websiteUrl?: string;
  contactUrl?: string;
  sourceKind: 'hacsa' | 'bi_teams' | 'bi_ranking';
  sourceUrl: string;
  verifiedAt: string;
};

export type TeamDirectoryFilters = {
  organizationShortName?: string;
  continentCode?: string;
  countryCode?: string;
  adminAreaCode?: string;
  teamSlug?: string;
};

export function hacsaFallbackDirectory(): PublicDirectoryTeam[] {
  return hacsaTeams.map(team => ({
    id: team.id,
    slug: team.id,
    organizationName: 'Historical Armored Combat Sports Association',
    organizationShortName: 'HACSA',
    name: team.name,
    location: team.location,
    continentCode: team.continentCode,
    continentName: team.continentName,
    countryCode: team.countryCode,
    countryName: team.countryName,
    adminAreaCode: team.adminAreaCode,
    adminAreaName: team.adminAreaName,
    email: team.email,
    websiteUrl: team.websiteUrl,
    contactUrl: team.contactUrl,
    sourceKind: 'hacsa',
    sourceUrl: team.sourceUrl,
    verifiedAt: team.verifiedAt
  }));
}

export async function loadPublicTeamDirectory(filters: TeamDirectoryFilters = {}): Promise<PublicDirectoryTeam[]> {
  if (!publicSupabase) {
    return hacsaFallbackDirectory().filter(team =>
      (!filters.organizationShortName || team.organizationShortName.toLowerCase() === filters.organizationShortName.toLowerCase()) &&
      (!filters.continentCode || team.continentCode === filters.continentCode) &&
      (!filters.countryCode || team.countryCode === filters.countryCode) &&
      (!filters.adminAreaCode || team.adminAreaCode === filters.adminAreaCode) &&
      (!filters.teamSlug || team.slug === filters.teamSlug)
    );
  }

  const { data, error } = await publicSupabase.rpc('public_team_directory', {
    p_organization_short_name: filters.organizationShortName ?? null,
    p_continent_code: filters.continentCode ?? null,
    p_country_code: filters.countryCode ?? null,
    p_admin_area_code: filters.adminAreaCode ?? null,
    p_team_slug: filters.teamSlug ?? null
  });

  if (error) throw error;

  return (data ?? []).map((row: any) => ({
    id: row.id,
    slug: row.directory_slug,
    organizationId: row.organization_id,
    organizationName: row.organization_name,
    organizationShortName: row.organization_short_name,
    name: row.team_name,
    location: row.city_or_region,
    continentCode: row.continent_code,
    continentName: row.continent_name ?? row.continent_code,
    countryCode: row.country_code,
    countryName: row.country_name ?? row.country_code,
    adminAreaCode: row.admin_area_code,
    adminAreaName: row.admin_area_name,
    email: row.public_contact_email,
    websiteUrl: row.website_url ?? undefined,
    contactUrl: row.source_contact_url ?? undefined,
    sourceKind: row.source_kind,
    sourceUrl: row.source_url,
    verifiedAt: String(row.source_verified_at).slice(0, 10)
  }));
}
