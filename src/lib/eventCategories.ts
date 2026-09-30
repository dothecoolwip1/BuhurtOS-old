/**
 * General event model helpers. Database `event_type` keeps its legacy labels
 * (ranked_competitive, demo_fun, exhibition, clinic_training, custom) and gains
 * the newer categories forward-only; this module maps every stored value onto
 * one display category so old rows keep working unchanged.
 */
export type EventCategory =
  | 'tournament' | 'exhibition' | 'demo' | 'training' | 'clinic_workshop' | 'recruitment'
  | 'fundraiser' | 'gathering_social' | 'meeting_agm' | 'community_appearance' | 'custom';

export const eventCategoryLabels: Record<EventCategory, string> = {
  tournament: 'Tournament',
  exhibition: 'Exhibition',
  demo: 'Demo',
  training: 'Training',
  clinic_workshop: 'Clinic / workshop',
  recruitment: 'Recruitment',
  fundraiser: 'Fundraiser',
  gathering_social: 'Gathering / social',
  meeting_agm: 'Meeting / AGM',
  community_appearance: 'Community appearance',
  custom: 'Custom'
};

export const eventCategoryOrder = Object.keys(eventCategoryLabels) as EventCategory[];

const legacyMap: Record<string, EventCategory> = {
  ranked_competitive: 'tournament',
  demo_fun: 'demo',
  clinic_training: 'training'
};

export function normalizeEventCategory(raw: string | null | undefined): EventCategory {
  const value = (raw ?? '').trim();
  if (value in legacyMap) return legacyMap[value];
  return (value in eventCategoryLabels ? value : 'custom') as EventCategory;
}

export function eventCategoryLabel(raw: string | null | undefined): string {
  return eventCategoryLabels[normalizeEventCategory(raw)];
}

export type EventCategoryTone = 'green' | 'amber' | 'blue' | 'purple' | 'neutral';

export function eventCategoryTone(raw: string | null | undefined): EventCategoryTone {
  switch (normalizeEventCategory(raw)) {
    case 'tournament': return 'green';
    case 'exhibition': case 'demo': return 'amber';
    case 'training': case 'clinic_workshop': return 'blue';
    case 'recruitment': case 'fundraiser': case 'community_appearance': return 'purple';
    default: return 'neutral';
  }
}

/** Categories that are competitions by nature. */
export function isCompetitiveCategory(raw: string | null | undefined): boolean {
  return normalizeEventCategory(raw) === 'tournament';
}

/** Purely social/administrative categories never show competition UI, even if rows exist. */
const neverCompetition: EventCategory[] = [
  'training', 'clinic_workshop', 'recruitment', 'fundraiser', 'gathering_social', 'meeting_agm', 'community_appearance'
];

export type EventCompetitionCounts = { divisions: number; matches: number; fields: number };
export type EventModules = { divisions: boolean; schedule: boolean; fields: boolean; standings: boolean; fighterSignup: boolean };

/**
 * Competition modules are conditional. Tournaments always show them (with helpful empty states);
 * exhibitions, demos and custom events show a module only when it actually has data; purely
 * social or administrative events never show competition UI.
 */
export function eventModules(raw: string | null | undefined, counts: EventCompetitionCounts): EventModules {
  const category = normalizeEventCategory(raw);
  if (neverCompetition.includes(category)) {
    return { divisions: false, schedule: false, fields: false, standings: false, fighterSignup: false };
  }
  if (category === 'tournament') {
    return { divisions: true, schedule: true, fields: true, standings: true, fighterSignup: true };
  }
  return {
    divisions: counts.divisions > 0,
    schedule: counts.matches > 0,
    fields: counts.fields > 0,
    standings: counts.matches > 0,
    fighterSignup: true
  };
}

export type EventCta = { label: string; kind: 'register' | 'signup' | 'link' | 'none' };

/** The single most relevant call to action for an event, by category and state. */
export function eventCta(raw: string | null | undefined, opts: { registrationOpen: boolean; hasLink: boolean; status: string }): EventCta {
  if (opts.status === 'cancelled') return { label: 'Cancelled', kind: 'none' };
  if (opts.status === 'completed' || opts.status === 'archived') return { label: 'View results', kind: 'link' };
  const category = normalizeEventCategory(raw);
  if (opts.registrationOpen) return { label: category === 'tournament' ? 'Register' : 'Sign up', kind: 'register' };
  if (opts.hasLink) return { label: 'Event details', kind: 'link' };
  return { label: 'Details', kind: 'none' };
}

export type EventListFilters = { category?: string; organizationId?: string; teamId?: string; when?: 'upcoming' | 'past' | 'all' };

type Filterable = { eventType: string; organizationId: string; hostTeamId?: string; endsAt: string };

export function filterEvents<T extends Filterable>(events: T[], filters: EventListFilters, now = Date.now()): T[] {
  return events.filter(event => {
    if (filters.category && filters.category !== 'all' && normalizeEventCategory(event.eventType) !== filters.category) return false;
    if (filters.organizationId && filters.organizationId !== 'all' && event.organizationId !== filters.organizationId) return false;
    if (filters.teamId && filters.teamId !== 'all' && event.hostTeamId !== filters.teamId) return false;
    const ended = new Date(event.endsAt).getTime() < now;
    if (filters.when === 'upcoming' && ended) return false;
    if (filters.when === 'past' && !ended) return false;
    return true;
  });
}

export function splitUpcomingPast<T extends { startsAt: string; endsAt: string }>(events: T[], now = Date.now()) {
  const upcoming = events.filter(e => new Date(e.endsAt).getTime() >= now)
    .sort((a, b) => new Date(a.startsAt).getTime() - new Date(b.startsAt).getTime());
  const past = events.filter(e => new Date(e.endsAt).getTime() < now)
    .sort((a, b) => new Date(b.startsAt).getTime() - new Date(a.startsAt).getTime());
  return { upcoming, past };
}

/** Agenda grouping keyed by month so a future FullCalendar view can reuse the same feed. */
export function groupByMonth<T extends { startsAt: string }>(events: T[]): Array<{ key: string; label: string; events: T[] }> {
  const groups = new Map<string, T[]>();
  for (const event of events) {
    const d = new Date(event.startsAt);
    const key = `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}`;
    groups.set(key, [...(groups.get(key) ?? []), event]);
  }
  return [...groups.entries()].map(([key, list]) => ({
    key,
    label: new Date(`${key}-01T00:00:00Z`).toLocaleDateString(undefined, { month: 'long', year: 'numeric', timeZone: 'UTC' }),
    events: list
  }));
}
