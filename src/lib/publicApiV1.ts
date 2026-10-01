/**
 * BuhurtOS public data contract, version 1.
 *
 * GitHub Pages hosting cannot serve literal /api/v1 HTTP routes, so the contract is
 * a versioned service layer. Every payload is an explicit whitelist DTO built from
 * the public read paths only (public RPCs, published events). Raw table rows and
 * private fields (contact details, notes, waivers, account ids) can never reach a
 * widget because nothing outside these mappers is exposed.
 *
 * Conceptual routes handled by `resolveApiV1`:
 *   /api/v1/organizations
 *   /api/v1/teams/{slug}
 *   /api/v1/teams/{slug}/stats
 *   /api/v1/events
 *   /api/v1/events/{slug}
 *   /api/v1/calendar
 */
import { eventCategoryLabel, filterEvents, normalizeEventCategory, splitUpcomingPast, type EventCategory } from './eventCategories';
import { eventImageAlt, eventImageUrl } from './eventMedia';
import { loadPublicEvents, loadPublicOrganizations, type PublicEventSummary, type PublicOrganizationSummary } from './publicDirectory';
import { loadOfficialTeamStats, loadTeamProvenance, type PublicTeamStats } from './publicStats';
import { loadPublicTeamDirectory, type PublicDirectoryTeam } from './teamDirectory';

export const API_VERSION = 'v1' as const;

export type OrganizationDTO = {
  id?: string; key: string; name: string; shortName: string; kind: string; region: string;
  websiteUrl?: string; teamCount: number; countries: number;
};

export type TeamDTO = {
  id: string; slug: string; name: string; organization: { shortName: string; name: string };
  location: string; region?: string; country?: string; logoUrl?: string; websiteUrl?: string; captain?: string;
  rankings: { rank5v5?: number; points5v5?: number; rank12v12?: number; points12v12?: number };
  source?: { kind?: string; url?: string; verifiedAt?: string };
};

export type TeamStatsDTO = {
  slug: string; teamId: string;
  official: { matches: number; wins: number; losses: number; draws: number; pointsFor: number; pointsAgainst: number; events: number } | null;
  rankings: TeamDTO['rankings'];
  sources: Array<{ kind: string; url: string; verifiedAt?: string }>;
};

export type EventDTO = {
  id: string; slug?: string; name: string; category: EventCategory; categoryLabel: string; status: string;
  startsAt: string; endsAt: string; timezone: string; venue: string;
  organization?: { id: string; shortName?: string }; host?: { teamId?: string; name?: string };
  description?: string; imageUrl?: string; imageAlt?: string; registrationOpen: boolean;
  links: { facebook?: string; website?: string; livestream?: string };
};

export type CalendarDTO = { version: typeof API_VERSION; generatedAt: string; events: EventDTO[] };

const SAFE_LINK_KEYS = ['facebook', 'website', 'livestream'] as const;

function safeUrl(value: unknown): string | undefined {
  if (typeof value !== 'string') return undefined;
  try {
    const url = new URL(value);
    return url.protocol === 'https:' || url.protocol === 'http:' ? url.toString() : undefined;
  } catch {
    return undefined;
  }
}

export function toOrganizationDTO(org: PublicOrganizationSummary): OrganizationDTO {
  return {
    id: org.id, key: org.key, name: org.name, shortName: org.shortName, kind: org.kind, region: org.region,
    websiteUrl: org.websiteUrl, teamCount: org.teamCount, countries: org.countries
  };
}

const known = (value: string | undefined) => (value && !value.includes('pending') ? value : undefined);

export function toTeamDTO(team: PublicDirectoryTeam): TeamDTO {
  return {
    id: team.id, slug: team.slug, name: team.name,
    organization: { shortName: team.organizationShortName, name: team.organizationName },
    location: team.location, region: known(team.adminAreaName), country: known(team.countryName),
    logoUrl: team.logoPath, websiteUrl: safeUrl(team.websiteUrl), captain: team.captain,
    rankings: { rank5v5: team.rank5v5, points5v5: team.points5v5, rank12v12: team.rank12v12, points12v12: team.points12v12 },
    source: { kind: team.sourceKind, url: team.sourceUrl, verifiedAt: team.verifiedAt }
  };
}

export function toEventDTO(event: PublicEventSummary, orgShortNames: Map<string, string> = new Map()): EventDTO {
  const links: EventDTO['links'] = {};
  const raw = event.publicLinks ?? {};
  for (const key of SAFE_LINK_KEYS) {
    const url = safeUrl(raw[key]);
    if (url) links[key] = url;
  }
  return {
    id: event.id, slug: event.slug, name: event.name,
    category: normalizeEventCategory(event.eventType), categoryLabel: eventCategoryLabel(event.eventType), status: event.status,
    startsAt: event.startsAt, endsAt: event.endsAt, timezone: event.timezone, venue: event.venue,
    organization: { id: event.organizationId, shortName: orgShortNames.get(event.organizationId) },
    host: event.hostTeamId || event.organizerName ? { teamId: event.hostTeamId, name: event.organizerName } : undefined,
    description: event.publicDescription, imageUrl: eventImageUrl(event.imagePath), imageAlt: event.imagePath ? eventImageAlt(event.name, event.imageAlt) : undefined, registrationOpen: Boolean(event.registrationOpen),
    links
  };
}

export function toTeamStatsDTO(team: PublicDirectoryTeam, official: PublicTeamStats | undefined, sources: Array<{ sourceKind: string; sourceUrl: string; verifiedAt?: string }>): TeamStatsDTO {
  return {
    slug: team.slug, teamId: team.id,
    official: official && official.matches > 0 ? { ...official } : null,
    rankings: toTeamDTO(team).rankings,
    sources: sources.map(s => ({ kind: s.sourceKind, url: s.sourceUrl, verifiedAt: s.verifiedAt }))
  };
}

// ---------------------------------------------------------------------------
// Service functions (one per conceptual route)
// ---------------------------------------------------------------------------

export async function listOrganizations(): Promise<OrganizationDTO[]> {
  return (await loadPublicOrganizations()).map(toOrganizationDTO);
}

export async function getTeam(slug: string): Promise<TeamDTO | undefined> {
  const [team] = await loadPublicTeamDirectory({ teamSlug: slug });
  return team ? toTeamDTO(team) : undefined;
}

export async function getTeamStats(slug: string): Promise<TeamStatsDTO | undefined> {
  const [team] = await loadPublicTeamDirectory({ teamSlug: slug });
  if (!team) return undefined;
  const [official, provenance] = await Promise.all([loadOfficialTeamStats(team.id), loadTeamProvenance(team.id)]);
  return toTeamStatsDTO(team, official, provenance);
}

export type EventListFilters = { organization?: string; team?: string; category?: string; when?: 'upcoming' | 'past' | 'all'; limit?: number };

async function orgMaps() {
  const orgs = await loadPublicOrganizations().catch(() => []);
  const byId = new Map(orgs.map(org => [org.id ?? '', org.shortName]));
  const idByShort = new Map(orgs.map(org => [org.shortName.toLowerCase(), org.id ?? '']));
  return { byId, idByShort };
}

export async function listEvents(filters: EventListFilters = {}): Promise<EventDTO[]> {
  const [events, { byId, idByShort }] = await Promise.all([loadPublicEvents(), orgMaps()]);
  const organizationId = filters.organization
    ? (idByShort.get(filters.organization.toLowerCase()) ?? filters.organization)
    : undefined;
  const filtered = filterEvents(events, { category: filters.category, organizationId, teamId: filters.team, when: filters.when ?? 'all' });
  const { upcoming, past } = splitUpcomingPast(filtered);
  const ordered = filters.when === 'past' ? past : filters.when === 'all' || !filters.when ? [...upcoming, ...past] : upcoming;
  return ordered.slice(0, filters.limit ?? ordered.length).map(event => toEventDTO(event, byId));
}

export async function getEvent(idOrSlug: string): Promise<EventDTO | undefined> {
  const [events, { byId }] = await Promise.all([loadPublicEvents(), orgMaps()]);
  const event = events.find(item => item.id === idOrSlug || item.slug === idOrSlug);
  return event ? toEventDTO(event, byId) : undefined;
}

export async function calendar(filters: EventListFilters = {}): Promise<CalendarDTO> {
  return { version: API_VERSION, generatedAt: new Date().toISOString(), events: await listEvents({ when: 'upcoming', ...filters }) };
}

/** Maps a conceptual /api/v1 path to its service call, so an HTTP edge can adopt this contract unchanged. */
export async function resolveApiV1(path: string, query: Record<string, string | undefined> = {}): Promise<unknown | undefined> {
  const parts = path.replace(/^\/?api\/v1\/?/, '').split('/').filter(Boolean).map(decodeURIComponent);
  const filters: EventListFilters = {
    organization: query.organization, team: query.team, category: query.category,
    when: query.when === 'past' || query.when === 'all' ? query.when : query.when === 'upcoming' ? 'upcoming' : undefined,
    limit: query.limit ? Math.max(1, Math.min(100, Number(query.limit) || 0)) || undefined : undefined
  };
  switch (parts[0]) {
    case 'organizations': return parts.length === 1 ? listOrganizations() : undefined;
    case 'teams':
      if (parts.length === 2) return getTeam(parts[1]);
      if (parts.length === 3 && parts[2] === 'stats') return getTeamStats(parts[1]);
      return undefined;
    case 'events':
      if (parts.length === 1) return listEvents(filters);
      if (parts.length === 2) return getEvent(parts[1]);
      return undefined;
    case 'calendar': return parts.length === 1 ? calendar(filters) : undefined;
    default: return undefined;
  }
}
