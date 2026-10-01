import { isCompetitionCapable } from './eventCategories';
import { registrationCloseAdvice } from './tournamentStructure';
import { supabase } from './supabase';

/**
 * Setup progress for any event, new or existing. Pure: it reads saved facts and says what is complete, missing or
 * worth a second look, and where to fix it. Nothing here writes anything.
 */
export type ChecklistStatus = 'complete' | 'missing' | 'warning' | 'unknown';

export interface EventSetupFacts {
  eventId: string;
  name: string;
  startsAt?: string;
  endsAt?: string;
  timezone?: string;
  venue?: string;
  publicDescription?: string;
  imagePath?: string;
  imageAlt?: string;
  status: string;
  eventType: string;
  registrationOpen?: boolean;
  registrationOpensAt?: string;
  registrationClosesAt?: string;
  registrationAccessScope?: string;
  rulesetId?: string;
  /** Counts; undefined means "could not be checked", never "zero". */
  competitions?: number;
  competitionsMissingDetails?: number;
  competitionsWithoutStructure?: number;
  divisions?: number;
  matches?: number;
  marshals?: number;
}

export interface ChecklistItem {
  id: 'basics' | 'venue' | 'poster' | 'registration' | 'rules' | 'competitions' | 'divisions' | 'schedule' | 'marshals';
  label: string;
  status: ChecklistStatus;
  /** What is true now, in plain words. */
  detail: string;
  /** What to do next, and where. */
  action: { label: string; to: string };
}

export interface ChecklistResult {
  items: ChecklistItem[];
  completed: number;
  total: number;
  /** First item that is not complete, so "Continue setup" always has a destination. */
  next?: ChecklistItem;
}

const manage = (id: string, extra = '') => `/admin/events/manage?event=${id}${extra}`;

export function buildEventChecklist(f: EventSetupFacts): ChecklistResult {
  const items: ChecklistItem[] = [];
  const competition = isCompetitionCapable(f.eventType);

  const basicsMissing = [!f.name?.trim() && 'name', !f.startsAt && 'start date', !f.endsAt && 'end date', !f.timezone && 'time zone'].filter(Boolean) as string[];
  items.push({
    id: 'basics', label: 'Basics',
    status: basicsMissing.length ? 'missing' : f.publicDescription?.trim() ? 'complete' : 'warning',
    detail: basicsMissing.length ? `Still needed: ${basicsMissing.join(', ')}.` : f.publicDescription?.trim() ? 'Name, dates, time zone and description are set.' : 'Add a short public description so visitors know what this event is.',
    action: { label: basicsMissing.length || !f.publicDescription?.trim() ? 'Finish basics' : 'Review basics', to: manage(f.eventId) }
  });

  items.push({
    id: 'venue', label: 'Venue', status: f.venue?.trim() ? 'complete' : 'missing',
    detail: f.venue?.trim() ? f.venue.trim() : 'Where will it happen? Visitors and fighters need an address or location name.',
    action: { label: f.venue?.trim() ? 'Review venue' : 'Add venue', to: manage(f.eventId) }
  });

  items.push({
    id: 'poster', label: 'Poster', status: f.imagePath ? 'complete' : 'missing',
    detail: f.imagePath ? 'A poster is attached and shows on the public event page.' : 'No poster yet. A poster makes the public page and event cards recognizable.',
    action: { label: f.imagePath ? 'Replace poster' : 'Upload poster', to: manage(f.eventId) }
  });

  if (competition) {
    const closeAdvice = registrationCloseAdvice(f.startsAt, f.registrationClosesAt);
    const hasWindow = Boolean(f.registrationOpensAt && f.registrationClosesAt);
    const configured = hasWindow || f.registrationOpen;
    items.push({
      id: 'registration', label: 'Registration',
      status: !configured ? 'missing' : closeAdvice ? 'warning' : 'complete',
      detail: !configured ? 'Set when registration opens and closes, and who may register without a signup code.'
        : closeAdvice ?? `Registration is configured${f.registrationAccessScope && f.registrationAccessScope !== 'invite_only' ? ' and eligible members skip the signup code' : ''}.`,
      action: { label: configured ? 'Review registration' : 'Set up registration', to: manage(f.eventId) }
    });

    items.push({
      id: 'rules', label: 'Rules',
      status: f.rulesetId ? 'complete' : 'missing',
      detail: f.rulesetId ? 'A ruleset is chosen for this event.' : 'Choose the ruleset this event runs under, so marshals and fighters see the same rules.',
      action: { label: f.rulesetId ? 'Review ruleset' : 'Choose ruleset', to: `/admin/rules/rulesets?event=${f.eventId}` }
    });

    const comps = f.competitions;
    items.push({
      id: 'competitions', label: 'Competitions',
      status: comps === undefined ? 'unknown' : comps === 0 ? 'missing' : (f.competitionsMissingDetails ?? 0) > 0 || (f.competitionsWithoutStructure ?? 0) > 0 ? 'warning' : 'complete',
      detail: comps === undefined ? 'Competitions could not be checked right now. Try again.'
        : comps === 0 ? 'No competitions yet. A competition is one tournament inside the event, for example Men’s 5v5 Classic.'
        : (f.competitionsMissingDetails ?? 0) > 0 ? `${comps} added; ${f.competitionsMissingDetails} still need a tier or category.`
        : (f.competitionsWithoutStructure ?? 0) > 0 ? `${comps} added; ${f.competitionsWithoutStructure} still need a structure chosen.`
        : `${comps} competition${comps === 1 ? '' : 's'} set up with tier, category and structure.`,
      action: { label: comps ? 'Manage competitions' : 'Add a competition', to: manage(f.eventId, '&tab=competitions') }
    });

    items.push({
      id: 'divisions', label: 'Divisions',
      status: f.divisions === undefined ? 'unknown' : f.divisions > 0 ? 'complete' : 'missing',
      detail: f.divisions === undefined ? 'Divisions could not be checked right now. Try again.' : f.divisions > 0 ? `${f.divisions} division${f.divisions === 1 ? '' : 's'} available for registration.` : 'No divisions yet. Divisions decide which entrants compete together and are what fighters register into.',
      action: { label: f.divisions ? 'Review divisions' : 'Add a division', to: '/admin/rules/divisions' }
    });

    items.push({
      id: 'schedule', label: 'Schedule',
      status: f.matches === undefined ? 'unknown' : f.matches > 0 ? 'complete' : 'missing',
      detail: f.matches === undefined ? 'The schedule could not be checked right now. Try again.' : f.matches > 0 ? `${f.matches} match${f.matches === 1 ? '' : 'es'} planned.` : 'Nothing is scheduled yet. Build the bracket and order of play once entrants are known.',
      action: { label: f.matches ? 'Open schedule' : 'Build tournament', to: f.matches ? '/admin/events/bracket' : '/admin/events/tools' }
    });

    items.push({
      id: 'marshals', label: 'Marshals',
      status: f.marshals === undefined ? 'unknown' : f.marshals > 0 ? 'complete' : 'missing',
      detail: f.marshals === undefined ? 'Marshals could not be checked right now. Try again.' : f.marshals > 0 ? `${f.marshals} marshal${f.marshals === 1 ? '' : 's'} assigned.` : 'No marshals assigned. Invite the people who will run the fields.',
      action: { label: f.marshals ? 'Manage people' : 'Invite marshals', to: '/admin/people/invite' }
    });
  }

  const completed = items.filter(item => item.status === 'complete').length;
  return { items, completed, total: items.length, next: items.find(item => item.status !== 'complete') };
}

/**
 * Things that are not "missing" in the sense of forgotten work: they are choices only the event owner can make, or
 * approvals that come from outside BuhurtOS. Each says in plain words what happens if nothing is decided. BuhurtOS
 * never makes these choices for an owner.
 */
export type DecisionKind = 'owner_decision' | 'optional' | 'external_approval';

export interface OwnerDecision {
  id: string;
  kind: DecisionKind;
  title: string;
  /** What is true now. */
  now: string;
  /** What this means for fighters, visitors or marshals if left as is. */
  consequence: string;
  action: { label: string; to: string };
}

export function ownerDecisions(f: EventSetupFacts): OwnerDecision[] {
  const out: OwnerDecision[] = [];
  const competition = isCompetitionCapable(f.eventType);
  const published = f.status === 'published';

  if (competition) {
    const scope = f.registrationAccessScope ?? 'invite_only';
    out.push({
      id: 'registration_access', kind: 'owner_decision', title: 'Who may register without a signup code',
      now: scope === 'invite_only' ? 'Everyone needs a signup code, including members of the host organization.'
        : scope === 'open' ? 'Any signed-in fighter may register.' : 'Eligible members of the chosen organization register without a code.',
      consequence: scope === 'invite_only'
        ? 'Fighters on your own teams still have to be handed a code, or they can ask you for permission. If you want members to sign up on their own, choose a wider group.'
        : 'Anyone in that group can sign up straight away. Others still need a code or your permission.',
      action: { label: 'Choose who can register', to: manage(f.eventId) }
    });
    if (!(f.registrationOpensAt && f.registrationClosesAt)) {
      out.push({
        id: 'registration_window', kind: 'owner_decision', title: 'When registration opens and closes',
        now: 'No registration window is set.',
        consequence: 'Without dates, nobody can tell when signing up is possible, and closing cannot be checked against the 15-day advice for tournaments.',
        action: { label: 'Set registration dates', to: manage(f.eventId) }
      });
    }
    if (f.eventType === 'custom') {
      out.push({
        id: 'event_category', kind: 'owner_decision', title: 'What kind of event this is',
        now: 'The event type is "custom".',
        consequence: 'A custom event is treated as a general gathering. The tournament planner, competitions and standings stay unavailable until you say it is a tournament or another competition type.',
        action: { label: 'Choose the event type', to: manage(f.eventId) }
      });
    }
    if (!f.rulesetId) {
      out.push({
        id: 'ruleset', kind: 'owner_decision', title: 'Which ruleset the event runs under',
        now: 'No ruleset is chosen.',
        consequence: 'Marshals and fighters will not see one agreed set of rules, and scoring defaults cannot be taken from a ruleset.',
        action: { label: 'Choose ruleset', to: `/admin/rules/rulesets?event=${f.eventId}` }
      });
    }
    out.push({
      id: 'external_approval', kind: 'external_approval', title: 'Approval from a federation or national body',
      now: 'BuhurtOS does not know whether an outside body must approve this event.',
      consequence: 'If your federation requires approval (for example a BI tier with a lead time), that approval happens with them, not here. Record it on the competition once you have it.',
      action: { label: 'Open competitions', to: manage(f.eventId, '&tab=competitions') }
    });
  }
  if (f.imagePath && !f.imageAlt?.trim()) {
    out.push({
      id: 'poster_alt', kind: 'optional', title: 'Describe the poster for screen readers',
      now: 'The poster has no description.',
      consequence: published ? 'The public page falls back to "' + f.name + ' poster". People who cannot see the image get no detail such as dates or prizes.' : 'It will fall back to the event name until you add one.',
      action: { label: 'Add description', to: manage(f.eventId) }
    });
  }
  return out;
}

/** Reads what the checklist needs. A failed lookup becomes "unknown", never a false "none". */
export async function loadEventSetupFacts(eventId: string): Promise<EventSetupFacts> {
  if (!supabase) throw new Error('BuhurtOS is not connected.');
  const { data: event, error } = await supabase.from('events')
    .select('id,name,starts_at,ends_at,timezone,venue,public_description,image_path,image_alt,status,event_type,registration_open,registration_opens_at,registration_closes_at,registration_access_scope,ruleset_id')
    .eq('id', eventId).maybeSingle();
  if (error) throw error;
  if (!event) throw new Error('Event not found.');

  const count = async (table: string, filter?: (q: any) => any): Promise<number | undefined> => {
    try {
      let q: any = supabase!.from(table).select('id', { count: 'exact', head: true }).eq('event_id', eventId);
      if (filter) q = filter(q);
      const { count: n, error: e } = await q;
      return e ? undefined : (n ?? 0);
    } catch { return undefined; }
  };

  const [competitions, divisions, matches, marshals] = await Promise.all([
    count('event_competitions'), count('event_divisions'), count('matches'),
    count('event_memberships', q => q.in('role', ['field_marshal', 'assistant_marshal']))
  ]);

  let competitionsMissingDetails: number | undefined;
  let competitionsWithoutStructure: number | undefined;
  try {
    const { data, error: e } = await supabase.from('event_competitions').select('tier,category_id,format_selection').eq('event_id', eventId);
    if (!e) {
      competitionsMissingDetails = (data ?? []).filter((c: any) => !c.tier || !c.category_id).length;
      competitionsWithoutStructure = (data ?? []).filter((c: any) => !c.format_selection?.optionKey).length;
    }
  } catch { /* stays unknown */ }

  return {
    eventId, name: event.name, startsAt: event.starts_at ?? undefined, endsAt: event.ends_at ?? undefined, timezone: event.timezone ?? undefined,
    venue: event.venue ?? undefined, publicDescription: event.public_description ?? undefined, imagePath: event.image_path ?? undefined, imageAlt: event.image_alt ?? undefined,
    status: event.status, eventType: event.event_type, registrationOpen: Boolean(event.registration_open),
    registrationOpensAt: event.registration_opens_at ?? undefined, registrationClosesAt: event.registration_closes_at ?? undefined,
    registrationAccessScope: event.registration_access_scope ?? undefined, rulesetId: event.ruleset_id ?? undefined,
    competitions, competitionsMissingDetails, competitionsWithoutStructure, divisions, matches, marshals
  };
}
