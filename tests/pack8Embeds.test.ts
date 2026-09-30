import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import {
  buildEmbedUrl, buildIframeCode, clampHeight, embedPath, escapeAttr, parseAccent, parseTheme
} from '../src/lib/embedBuilder';
import { buildIcs } from '../src/lib/ics';
import {
  calendar, getEvent, getTeam, getTeamStats, listEvents, listOrganizations, resolveApiV1, toEventDTO, toTeamDTO, type EventDTO, type TeamDTO
} from '../src/lib/publicApiV1';
import { AgendaView, EmbedState, EventCardView, StandingsView, TeamCardView } from '../src/pages/EmbedPages';
import type { PublicEventSummary } from '../src/lib/publicDirectory';
import type { PublicDirectoryTeam } from '../src/lib/teamDirectory';

const team: PublicDirectoryTeam = {
  id: 't1', slug: 'red-deer-reavers', organizationName: 'Historical Armored Combat Sports Association', organizationShortName: 'HACSA',
  name: 'Red Deer Reavers', location: 'Red Deer', continentCode: 'NA', continentName: 'North America', countryCode: 'CA', countryName: 'Canada',
  adminAreaCode: 'AB', adminAreaName: 'Alberta', email: 'private@example.test', contactUrl: 'https://facebook.com/private-profile',
  websiteUrl: 'https://reavers.example', rank5v5: 12, points5v5: 340, sourceKind: 'hacsa', sourceUrl: 'https://hacsa.example/teams', verifiedAt: '2026-09-29',
  latitude: 52.26, longitude: -113.81
};

const event: PublicEventSummary = {
  id: '6028e471-a95c-4d8a-8101-1f168bc68c8b', organizationId: 'org1', name: 'Red Deer Rumble', venue: 'Horse in Hand Ranch, Blackfalds, Alberta',
  startsAt: '2026-11-14T07:00:00Z', endsAt: '2026-11-16T06:59:59Z', organizerName: 'Red Deer Reavers', eventType: 'custom', standingsMode: 'no_standings',
  status: 'published', timezone: 'America/Edmonton', publicDescription: 'Two-day armored combat event.',
  publicLinks: { facebook: 'https://facebook.com/events/s/red-deer-rumble/1629371538573110/', host_team_id: 'e8a655d9-7292-4ee5-b46b-11e80fd57a99', schedule_tba: true, admin_token: 'SECRET', website: 'javascript:alert(1)' },
  registrationOpen: false, hostTeamId: 'e8a655d9-7292-4ee5-b46b-11e80fd57a99'
};

describe('public data contract v1', () => {
  it('team DTO is a whitelist and never carries private contact data', () => {
    const dto = toTeamDTO(team);
    expect(Object.keys(dto).sort()).toEqual(['captain', 'country', 'id', 'location', 'logoUrl', 'name', 'organization', 'rankings', 'region', 'slug', 'source', 'websiteUrl'].sort());
    const json = JSON.stringify(dto);
    expect(json).not.toContain('private@example.test');
    expect(json).not.toContain('private-profile');
    expect(json).not.toContain('latitude');
    expect(dto.rankings.rank5v5).toBe(12);
  });

  it('event DTO exposes only safe links and public fields', () => {
    const dto = toEventDTO(event, new Map([['org1', 'HACSA']]));
    expect(dto.links).toEqual({ facebook: 'https://facebook.com/events/s/red-deer-rumble/1629371538573110/' });
    const json = JSON.stringify(dto);
    expect(json).not.toContain('SECRET');
    expect(json).not.toContain('javascript:');
    expect(json).not.toContain('schedule_tba');
    expect(dto.category).toBe('custom');
    expect(dto.organization).toEqual({ id: 'org1', shortName: 'HACSA' });
    expect(dto.host).toEqual({ teamId: 'e8a655d9-7292-4ee5-b46b-11e80fd57a99', name: 'Red Deer Reavers' });
    expect(Object.keys(dto).sort()).toEqual(['category', 'categoryLabel', 'description', 'endsAt', 'host', 'id', 'imageUrl', 'links', 'name', 'organization', 'registrationOpen', 'slug', 'startsAt', 'status', 'timezone', 'venue'].sort());
  });

  it('resolves the conceptual /api/v1 routes (no backend configured)', async () => {
    expect(await listOrganizations()).toEqual([]);
    expect(await listEvents()).toEqual([]);
    const cal = await calendar();
    expect(cal.version).toBe('v1');
    expect(cal.events).toEqual([]);
    expect(await resolveApiV1('/api/v1/organizations')).toEqual([]);
    expect(await resolveApiV1('/api/v1/events/unknown')).toBeUndefined();
    expect(await resolveApiV1('/api/v1/teams/not-a-team')).toBeUndefined();
    expect(await resolveApiV1('/api/v2/events')).toBeUndefined();
    expect((await resolveApiV1('/api/v1/calendar') as { version: string }).version).toBe('v1');
  });

  it('serves team and empty stats through the DTO layer only', async () => {
    const dto = await getTeam('red-deer-reavers');
    expect(dto?.slug).toBe('red-deer-reavers');
    expect(dto?.organization.shortName).toBe('HACSA');
    expect(JSON.stringify(dto)).not.toMatch(/@/);
    const stats = await getTeamStats('red-deer-reavers');
    expect(stats?.official).toBeNull();
    expect(await getTeam('does-not-exist')).toBeUndefined();
    expect(await getTeamStats('does-not-exist')).toBeUndefined();
  });

  it('treats an unknown, private or unpublished event id as missing', async () => {
    expect(await getEvent('00000000-0000-0000-0000-000000000000')).toBeUndefined();
    expect(await getEvent('6028e471-a95c-4d8a-8101-1f168bc68c8b')).toBeUndefined();
  });
});

describe('embed builder', () => {
  const base = 'https://dothecoolwip1.github.io/BuhurtOS/';
  it('builds stable hash URLs for each widget', () => {
    expect(buildEmbedUrl(base, { type: 'team', entity: 'red-deer-reavers' })).toBe('https://dothecoolwip1.github.io/BuhurtOS/#/embed/team/red-deer-reavers');
    expect(buildEmbedUrl(base, { type: 'event', entity: '6028e471-a95c-4d8a-8101-1f168bc68c8b', theme: 'dark', accent: '#D9680C' }))
      .toBe('https://dothecoolwip1.github.io/BuhurtOS/#/embed/event/6028e471-a95c-4d8a-8101-1f168bc68c8b?theme=dark&accent=d9680c');
    expect(buildEmbedUrl(base, { type: 'standings', entity: 'abc' })).toContain('#/embed/standings/abc');
    expect(embedPath({ type: 'events', organization: 'HACSA', limit: 5, theme: 'light' })).toBe('/embed/events?theme=light&org=HACSA&limit=5');
    expect(embedPath({ type: 'events' })).toBe('/embed/events');
  });

  it('validates accent colors and themes', () => {
    expect(parseAccent('#abc')).toBe('#aabbcc');
    expect(parseAccent('d9680c')).toBe('#d9680c');
    expect(parseAccent('red; background:url(x)')).toBeUndefined();
    expect(parseAccent('')).toBeUndefined();
    expect(parseTheme('dark')).toBe('dark');
    expect(parseTheme('neon')).toBe('auto');
  });

  it('escapes attribute values in generated iframe code and clamps height', () => {
    const code = buildIframeCode('https://x.test/#/embed/events?a=1&b="2"', { type: 'events', height: 99999 }, 'My "widget" <b>');
    expect(code).toContain('&amp;b=&quot;2&quot;');
    expect(code).toContain('title="My &quot;widget&quot; &lt;b&gt;"');
    expect(code).toContain('height="1400"');
    expect(code).toContain('referrerpolicy="no-referrer"');
    expect(code).toContain('width="100%"');
    expect(clampHeight(10, 'team')).toBe(240);
    expect(clampHeight(undefined, 'team')).toBe(420);
    expect(escapeAttr('a&b')).toBe('a&amp;b');
  });
});

describe('ICS feed', () => {
  const dto = toEventDTO(event);
  it('builds a valid calendar with escaped text', () => {
    const ics = buildIcs([{ ...dto, name: 'Clash; of, Steel', description: 'Line one\nLine two' }], 'HACSA events', new Date('2026-09-30T00:00:00Z'));
    expect(ics.startsWith('BEGIN:VCALENDAR\r\n')).toBe(true);
    expect(ics).toContain('SUMMARY:Clash\\; of\\, Steel');
    expect(ics).toContain('DESCRIPTION:Line one\\nLine two');
    expect(ics).toContain('DTSTART:20261114T070000Z');
    expect(ics).toContain('UID:6028e471-a95c-4d8a-8101-1f168bc68c8b@buhurtos');
    expect(ics.endsWith('END:VCALENDAR\r\n')).toBe(true);
  });
  it('marks cancelled events, skips invalid dates and never adds private link fields', () => {
    const ics = buildIcs([{ ...dto, status: 'cancelled' }, { ...dto, id: 'bad', startsAt: 'nope' }]);
    expect(ics).toContain('STATUS:CANCELLED');
    expect(ics).not.toContain('bad@buhurtos');
    expect(ics).not.toContain('SECRET');
  });
  it('folds long lines at 75 characters', () => {
    const ics = buildIcs([{ ...dto, description: 'x'.repeat(300) }]);
    for (const line of ics.split('\r\n')) expect(line.length).toBeLessThanOrEqual(75);
  });
});

const render = (node: Parameters<typeof renderToStaticMarkup>[0]) => renderToStaticMarkup(node);
const eventDto: EventDTO = toEventDTO(event, new Map([['org1', 'HACSA']]));
const teamDto: TeamDTO = toTeamDTO(team);

describe('embed views', () => {
  it('agenda lists public events with categories and CTAs, and has a clear empty state', () => {
    const html = render(createElement(AgendaView, { events: [eventDto] }));
    expect(html).toContain('Red Deer Rumble');
    expect(html).toContain('Custom');
    expect(render(createElement(AgendaView, { events: [] }))).toContain('No events to show');
  });
  it('event card shows the event without private fields', () => {
    const html = render(createElement(EventCardView, { event: eventDto }));
    expect(html).toContain('Horse in Hand Ranch');
    expect(html).toContain('Hosted by Red Deer Reavers');
    expect(html).toContain('Facebook event');
    expect(html).not.toContain('SECRET');
  });
  it('team card handles empty official stats honestly', () => {
    const html = render(createElement(TeamCardView, { team: teamDto, stats: { slug: 'red-deer-reavers', teamId: 't1', official: null, rankings: teamDto.rankings, sources: [] } }));
    expect(html).toContain('No official BuhurtOS match record yet');
    expect(html).toContain('#12');
    expect(html).not.toContain('private@example.test');
  });
  it('team card shows the official record when matches exist', () => {
    const html = render(createElement(TeamCardView, { team: teamDto, stats: { slug: 's', teamId: 't1', official: { matches: 4, wins: 2, losses: 1, draws: 1, pointsFor: 15, pointsAgainst: 9, events: 1 }, rankings: teamDto.rankings, sources: [] } }));
    expect(html).toContain('2-1-1');
  });
  it('standings view has empty and demo states', () => {
    expect(render(createElement(StandingsView, { eventName: 'Test', rows: [] }))).toContain('No standings yet');
    expect(render(createElement(StandingsView, { eventName: 'Test', rows: [], demo: true }))).toContain('DEMO DATA');
  });
  it('error and missing states are explicit', () => {
    expect(render(createElement(EmbedState, { title: 'Not available', text: 'This event is not published or does not exist.' }))).toContain('not published');
  });
});
