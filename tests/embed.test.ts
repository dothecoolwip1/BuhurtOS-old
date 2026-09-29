import { describe, expect, it } from 'vitest';
import { widgetEmbedCode, widgetStandingsUrl } from '../src/lib/embed';
import { demoFighters, demoTeams } from '../src/data/showcase';

describe('standings widget embed helpers', () => {
  it('widgetStandingsUrl appends the widget hash route to a base URL', () => {
    expect(widgetStandingsUrl('https://example.com/BuhurtOS/')).toBe('https://example.com/BuhurtOS/#/widget/standings');
    expect(widgetStandingsUrl('https://example.com/BuhurtOS/index.html')).toBe('https://example.com/BuhurtOS/index.html#/widget/standings');
    expect(widgetStandingsUrl('https://sub.example.org')).toBe('https://sub.example.org/#/widget/standings');
  });

  it('widgetEmbedCode emits a lazy iframe with escaped src/title and configured dimensions', () => {
    const code = widgetEmbedCode('https://example.com/BuhurtOS/#/widget/standings', { width: 640, height: 520, title: 'Demo "Fall Open" standings' });
    expect(code).toContain('<iframe src="https://example.com/BuhurtOS/#/widget/standings"');
    expect(code).toContain('title="Demo &quot;Fall Open&quot; standings"');
    expect(code).toContain('width="640"');
    expect(code).toContain('height="520"');
    expect(code).toContain('loading="lazy"');
    expect(code).toContain('referrerpolicy="no-referrer"');
  });

  it('widgetEmbedCode defaults dimensions when not provided', () => {
    const code = widgetEmbedCode('https://example.com/#/widget/standings');
    expect(code).toContain('width="600"');
    expect(code).toContain('height="480"');
  });
});

describe('showcase profile enrichments', () => {
  it('every profiled demo fighter that declares extras has well-formed rows', () => {
    for (const fighter of demoFighters) {
      if (fighter.tournamentHistory) {
        expect(fighter.tournamentHistory.length).toBeGreaterThan(0);
        for (const row of fighter.tournamentHistory) {
          expect(row.year).toBeTruthy();
          expect(row.event).toBeTruthy();
          expect(row.category).toBeTruthy();
          expect(row.placement).toBeTruthy();
        }
      }
      if (fighter.socials) {
        expect(fighter.socials.length).toBeGreaterThan(0);
        for (const link of fighter.socials) {
          expect(link.label).toBeTruthy();
          expect(link.url).toMatch(/^https:\/\//);
        }
      }
    }
  });

  it('experience metadata is internally consistent when present', () => {
    for (const fighter of demoFighters) {
      if (fighter.experienceYears !== undefined) expect(fighter.experienceYears).toBeGreaterThan(0);
      if (fighter.experienceLevel) {
        expect(['Rising', 'Experienced', 'Veteran', 'Elite']).toContain(fighter.experienceLevel);
      }
    }
  });

  it('demo team season results follow the result format', () => {
    for (const team of demoTeams) {
      if (team.seasonResults) {
        for (const row of team.seasonResults) {
          expect(row.event).toBeTruthy();
          expect(row.result).toMatch(/^(1st|2nd|3rd|4th|5th)\b/);
        }
      }
    }
  });

  it('a forming team never advertises season results or socials', () => {
    const forming = demoTeams.find(t => t.status === 'forming');
    expect(forming).toBeDefined();
    expect(forming?.seasonResults?.length ?? 0).toBe(0);
    expect(forming?.socials?.length ?? 0).toBe(0);
  });
});