import { describe, expect, it } from 'vitest';
import { buildEventChecklist, type EventSetupFacts } from '../src/lib/eventChecklist';

// Red Deer Rumble as it stands on the hosted project: basics, venue and poster done; nothing competition-related yet.
const rumble: EventSetupFacts = {
  eventId: '6028e471-a95c-4d8a-8101-1f168bc68c8b', name: 'Red Deer Rumble', startsAt: '2026-11-14T07:00:00Z', endsAt: '2026-11-16T06:59:59Z',
  timezone: 'America/Edmonton', venue: 'Horse in Hand Ranch, Blackfalds, Alberta', publicDescription: 'Two-day armored combat event.',
  imagePath: '6028e471-a95c-4d8a-8101-1f168bc68c8b/poster-1790803806143.webp', status: 'published', eventType: 'custom',
  registrationOpen: false, competitions: 0, divisions: 0, matches: 0, marshals: 0
};

const byId = (facts: EventSetupFacts) => Object.fromEntries(buildEventChecklist(facts).items.map(i => [i.id, i]));

describe('setup checklist for an existing event (Red Deer Rumble)', () => {
  const result = buildEventChecklist(rumble);
  it('shows nine steps with honest progress', () => {
    expect(result.total).toBe(9);
    expect(result.completed).toBe(3);
    const items = byId(rumble);
    expect(items.basics.status).toBe('complete');
    expect(items.venue.status).toBe('complete');
    expect(items.poster.status).toBe('complete');
    for (const id of ['registration', 'rules', 'competitions', 'divisions', 'schedule', 'marshals'] as const) expect(items[id].status).toBe('missing');
  });
  it('points "Continue setup" at the first unfinished step, with a destination', () => {
    expect(result.next?.id).toBe('registration');
    expect(result.next?.action.to).toContain(rumble.eventId);
  });
  it('explains every missing step and gives it an action', () => {
    for (const item of result.items.filter(i => i.status === 'missing')) {
      expect(item.detail.length).toBeGreaterThan(20);
      expect(item.action.label.length).toBeGreaterThan(3);
      expect(item.action.to.startsWith('/admin/')).toBe(true);
    }
  });
  it('sends the competitions step straight to the competitions tab', () => {
    expect(byId(rumble).competitions.action.to).toBe(`/admin/events/manage?event=${rumble.eventId}&tab=competitions`);
  });
});

describe('progress follows the saved data', () => {
  it('completes steps as they are set up', () => {
    const facts: EventSetupFacts = { ...rumble, registrationOpensAt: '2026-10-01T00:00:00Z', registrationClosesAt: '2026-10-25T00:00:00Z', rulesetId: 'r1',
      competitions: 2, competitionsMissingDetails: 0, competitionsWithoutStructure: 0, divisions: 2, matches: 12, marshals: 3 };
    const result = buildEventChecklist(facts);
    expect(result.completed).toBe(9);
    expect(result.next).toBeUndefined();
  });
  it('warns, rather than completes, when competitions lack a tier, category or structure', () => {
    expect(byId({ ...rumble, competitions: 2, competitionsMissingDetails: 1, competitionsWithoutStructure: 2 }).competitions.status).toBe('warning');
    expect(byId({ ...rumble, competitions: 2, competitionsMissingDetails: 0, competitionsWithoutStructure: 1 }).competitions.detail).toMatch(/structure/i);
  });
  it('warns when registration closes too close to the event (BI asks for 15 days)', () => {
    const late = byId({ ...rumble, registrationOpensAt: '2026-10-01T00:00:00Z', registrationClosesAt: '2026-11-10T00:00:00Z' }).registration;
    expect(late.status).toBe('warning');
    expect(late.detail).toMatch(/15 days/);
  });
  it('asks for a description instead of calling basics complete without one', () => {
    expect(byId({ ...rumble, publicDescription: '' }).basics.status).toBe('warning');
    expect(byId({ ...rumble, startsAt: undefined }).basics.detail).toMatch(/start date/);
  });
  it('never turns a failed lookup into "none": it says it could not check', () => {
    const items = byId({ ...rumble, competitions: undefined, divisions: undefined, matches: undefined, marshals: undefined });
    for (const id of ['competitions', 'divisions', 'schedule', 'marshals'] as const) {
      expect(items[id].status).toBe('unknown');
      expect(items[id].detail).toMatch(/could not be checked/i);
    }
  });
});

describe('events that are not tournaments', () => {
  it('a gathering has no competition steps at all', () => {
    const result = buildEventChecklist({ ...rumble, eventType: 'gathering_social' });
    expect(result.items.map(i => i.id)).toEqual(['basics', 'venue', 'poster']);
    expect(result.total).toBe(3);
  });
  it('a meeting and a clinic also skip tournament setup', () => {
    for (const eventType of ['meeting_agm', 'clinic_workshop', 'training']) expect(buildEventChecklist({ ...rumble, eventType }).items.some(i => i.id === 'divisions')).toBe(false);
  });
});
