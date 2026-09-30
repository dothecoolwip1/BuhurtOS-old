import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it } from 'vitest';
import { EVENT_MEDIA_MAX_BYTES, eventImageThumbUrl, eventImageUrl, scaleToFit, validateEventMediaFile } from '../src/lib/eventMedia';
import { EventDetailView } from '../src/pages/ShowcaseEventPage';
import type { PublicEventDetails } from '../src/lib/publicDirectory';

describe('event media helpers', () => {
  it('validates type and size', () => {
    expect(validateEventMediaFile({ type: 'image/png', size: 1000 })).toBeUndefined();
    expect(validateEventMediaFile({ type: 'application/pdf', size: 1000 })).toMatch(/JPG, PNG or WebP/);
    expect(validateEventMediaFile({ type: 'image/webp', size: EVENT_MEDIA_MAX_BYTES * 5 })).toMatch(/too large/);
  });
  it('scales down the long edge and never upscales', () => {
    expect(scaleToFit(3200, 1600)).toEqual({ width: 1600, height: 800 });
    expect(scaleToFit(900, 1800)).toEqual({ width: 800, height: 1600 });
    expect(scaleToFit(800, 600)).toEqual({ width: 800, height: 600 });
  });
  it('does not use the render endpoint unless transformations are enabled', () => {
    const url = eventImageThumbUrl('evt/poster.webp', 640);
    if (url) expect(url).not.toContain('/render/image/');
  });
  it('returns no URL when there is no stored path', () => {
    expect(eventImageUrl(undefined)).toBeUndefined();
    expect(eventImageThumbUrl(null)).toBeUndefined();
  });
});

const rumble = (extra: Partial<PublicEventDetails['event']> = {}): PublicEventDetails => ({
  event: {
    id: '6028e471-a95c-4d8a-8101-1f168bc68c8b', organizationId: 'o1', name: 'Red Deer Rumble', venue: 'Horse in Hand Ranch, Blackfalds, Alberta',
    startsAt: '2026-11-14T07:00:00Z', endsAt: '2026-11-16T06:59:59Z', organizerName: 'Red Deer Reavers', eventType: 'custom',
    standingsMode: 'no_standings', status: 'published', timezone: 'America/Edmonton', hostTeamId: 'e8a655d9-7292-4ee5-b46b-11e80fd57a99',
    publicDescription: 'Two-day armored combat event.', publicLinks: { facebook: 'https://facebook.com/events/s/red-deer-rumble/1629371538573110/', schedule_tba: true },
    ...extra
  },
  announcements: [], fields: [], divisions: [], matches: []
});
const render = (d: PublicEventDetails) =>
  renderToStaticMarkup(createElement(MemoryRouter, null, createElement(EventDetailView, { details: d, onFighterSignup: () => {} })));

describe('Red Deer Rumble public page', () => {
  it('shows honest TBA and hides competition modules that have no real data', () => {
    const html = render(rumble());
    expect(html).toContain('Red Deer Rumble');
    expect(html).toContain('Horse in Hand Ranch');
    expect(html).toContain('Red Deer Reavers');
    expect(html).toContain('Facebook event');
    expect(html).toContain('Fighter interest form');
    expect(html).toContain('Divisions');
    expect(html).toContain('To be announced');
    expect(html).not.toContain('Fight areas');
    expect(html).not.toContain('Schedule &amp; matches');
    expect(html).not.toContain('Standings');
  });
  it('never invents a poster when none is stored', () => {
    expect(render(rumble())).not.toContain('event-hero-media');
  });
  it('activates competition modules only when real data exists', () => {
    const html = render({ ...rumble(), divisions: [{ id: 'd', name: 'Longsword', registrationOpen: true }] });
    expect(html).toContain('Competition');
    expect(html).toContain('Longsword');
  });
});
