import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';
import {
  eventCategoryLabel, eventCta, eventModules, filterEvents, groupByMonth, isCompetitiveCategory,
  normalizeEventCategory, splitUpcomingPast
} from '../src/lib/eventCategories';
import { EventDetailView } from '../src/pages/ShowcaseEventPage';
import type { PublicEventDetails } from '../src/lib/publicDirectory';

const none = { divisions: 0, matches: 0, fields: 0 };

describe('event categories', () => {
  it('maps legacy event_type values without losing them', () => {
    expect(normalizeEventCategory('ranked_competitive')).toBe('tournament');
    expect(normalizeEventCategory('demo_fun')).toBe('demo');
    expect(normalizeEventCategory('clinic_training')).toBe('training');
    expect(normalizeEventCategory('exhibition')).toBe('exhibition');
    expect(normalizeEventCategory('meeting_agm')).toBe('meeting_agm');
    expect(normalizeEventCategory('something_new')).toBe('custom');
    expect(normalizeEventCategory(undefined)).toBe('custom');
    expect(eventCategoryLabel('gathering_social')).toBe('Gathering / social');
  });
  it('only tournaments are competitive by nature', () => {
    expect(isCompetitiveCategory('tournament')).toBe(true);
    expect(isCompetitiveCategory('ranked_competitive')).toBe(true);
    expect(isCompetitiveCategory('meeting_agm')).toBe(false);
    expect(isCompetitiveCategory('demo')).toBe(false);
  });
});

describe('competition modules are conditional', () => {
  it('tournaments keep every competition module (existing behavior)', () => {
    const m = eventModules('ranked_competitive', none);
    expect(m).toEqual({ divisions: true, schedule: true, fields: true, standings: true, fighterSignup: true });
  });
  it('social and administrative events never show competition UI, even with data', () => {
    for (const type of ['gathering_social', 'meeting_agm', 'training', 'clinic_workshop', 'fundraiser', 'recruitment', 'community_appearance']) {
      expect(eventModules(type, { divisions: 3, matches: 9, fields: 2 })).toEqual({
        divisions: false, schedule: false, fields: false, standings: false, fighterSignup: false
      });
    }
  });
  it('demos and exhibitions only show modules that have data', () => {
    expect(eventModules('demo', none)).toMatchObject({ divisions: false, schedule: false, fields: false, standings: false });
    expect(eventModules('exhibition', { divisions: 0, matches: 4, fields: 1 })).toMatchObject({ divisions: false, schedule: true, fields: true, standings: true });
  });
  it('picks a relevant call to action', () => {
    expect(eventCta('tournament', { registrationOpen: true, hasLink: false, status: 'published' }).label).toBe('Register');
    expect(eventCta('meeting_agm', { registrationOpen: true, hasLink: false, status: 'published' }).label).toBe('Sign up');
    expect(eventCta('meeting_agm', { registrationOpen: false, hasLink: true, status: 'published' }).kind).toBe('link');
    expect(eventCta('tournament', { registrationOpen: true, hasLink: true, status: 'cancelled' }).kind).toBe('none');
  });
});

describe('event directory filtering', () => {
  const now = Date.parse('2026-06-15T00:00:00Z');
  const e = (id: string, type: string, org: string, start: string, end: string, host?: string) =>
    ({ id, eventType: type, organizationId: org, hostTeamId: host, startsAt: start, endsAt: end });
  const events = [
    e('a', 'ranked_competitive', 'o1', '2026-07-01T10:00:00Z', '2026-07-02T10:00:00Z', 't1'),
    e('b', 'meeting_agm', 'o2', '2026-08-01T10:00:00Z', '2026-08-01T12:00:00Z'),
    e('c', 'tournament', 'o1', '2026-05-01T10:00:00Z', '2026-05-02T10:00:00Z')
  ];
  it('filters by category, organization, host team and time', () => {
    expect(filterEvents(events, { category: 'tournament' }, now).map(x => x.id)).toEqual(['a', 'c']);
    expect(filterEvents(events, { organizationId: 'o2' }, now).map(x => x.id)).toEqual(['b']);
    expect(filterEvents(events, { teamId: 't1' }, now).map(x => x.id)).toEqual(['a']);
    expect(filterEvents(events, { when: 'upcoming' }, now).map(x => x.id)).toEqual(['a', 'b']);
    expect(filterEvents(events, { when: 'past' }, now).map(x => x.id)).toEqual(['c']);
  });
  it('splits upcoming (soonest first) and past (latest first) and groups by month', () => {
    const { upcoming, past } = splitUpcomingPast(events, now);
    expect(upcoming.map(x => x.id)).toEqual(['a', 'b']);
    expect(past.map(x => x.id)).toEqual(['c']);
    expect(groupByMonth(upcoming).map(g => g.key)).toEqual(['2026-07', '2026-08']);
  });
});

function details(eventType: string, extra: Partial<PublicEventDetails> = {}): PublicEventDetails {
  return {
    event: {
      id: 'e1', organizationId: 'o1', name: 'Test Event', venue: 'Hall', startsAt: '2026-09-01T10:00:00Z', endsAt: '2026-09-01T12:00:00Z',
      eventType, standingsMode: 'no_standings', status: 'published', timezone: 'UTC', publicLinks: {}
    },
    announcements: [], fields: [], divisions: [], matches: [], ...extra
  };
}
const render = (d: PublicEventDetails) =>
  renderToStaticMarkup(createElement(MemoryRouter, null, createElement(EventDetailView, { details: d, onFighterSignup: () => {} })));

describe('public event page rendering', () => {
  const competitionHeadings = ['Competition', 'Schedule &amp; matches', 'Fight areas', 'Fighter signup', 'Standings'];
  it('a noncompetitive event renders no competition UI', () => {
    const html = render(details('meeting_agm'));
    for (const heading of competitionHeadings) expect(html).not.toContain(heading);
    expect(html).toContain('About the event');
    expect(html).toContain('Meeting / AGM');
  });
  it('a noncompetitive event stays clean even if competition rows exist', () => {
    const html = render(details('gathering_social', {
      divisions: [{ id: 'd', name: 'Longsword', registrationOpen: true }],
      matches: [{ id: 'm', label: 'Bout 1', category: 'duel', status: 'scheduled', scheduledOrder: 1 }],
      fields: [{ id: 'f', name: 'Field 1', listName: 'Field 1', status: 'active', sortOrder: 1 }]
    }));
    for (const heading of competitionHeadings) expect(html).not.toContain(heading);
    expect(html).not.toContain('Bout 1');
  });
  it('a legacy ranked_competitive tournament still renders its competition modules', () => {
    const html = render(details('ranked_competitive'));
    for (const heading of ['Competition', 'Schedule &amp; matches', 'Fight areas', 'Fighter signup']) expect(html).toContain(heading);
  });
  it('a demo without data stays clean but shows data when it exists', () => {
    expect(render(details('demo'))).not.toContain('Fight areas');
    const withFields = render(details('demo', { fields: [{ id: 'f', name: 'Ring', listName: 'Ring', status: 'active', sortOrder: 1 }] }));
    expect(withFields).toContain('Fight areas');
  });
});
