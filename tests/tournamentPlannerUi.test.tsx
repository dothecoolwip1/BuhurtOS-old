import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { SchedulePlanner, StructureAdvisor } from '../src/features/TournamentPlanner';
import { buildTournamentPreview } from '../src/lib/tournamentGeneration';
import type { FightCard, RosterEntry } from '../src/types';

const entry = (n: number): RosterEntry => ({
  id: `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`, organizationId: 'o', eventId: 'e', teamId: `t${n % 3}`, entryType: 'fighter', displayName: `Fighter ${n}`,
  checkedIn: true, armorCleared: true, medicalCleared: true, waiverConfirmed: true, weighInCleared: true, competitionCleared: true, attendanceStatus: 'approved'
});
const entries = Array.from({ length: 10 }, (_, i) => entry(i + 1));
const preview = buildTournamentPreview({
  organizationId: '10000000-0000-4000-8000-000000000001', seasonId: '10000000-0000-4000-8000-000000000002', eventId: '10000000-0000-4000-8000-000000000003',
  bracketId: '10000000-0000-4000-8000-000000000004', category: 'Longsword', matchType: 'longsword', scoringConfig: { kind: 'duel', roundsRequired: 3, allowDrawRound: false },
  format: 'pools_to_bracket', entries, seeding: { method: 'manual', values: Object.fromEntries(entries.map((e, i) => [e.id, i + 1])) }, antiFratricide: false, targetPoolSize: 5
});
const cards: FightCard[] = [
  { id: '20000000-0000-4000-8000-00000000000a', eventId: 'e', name: 'Ring 1', listName: 'Ring 1', status: 'live', sortOrder: 1 },
  { id: '20000000-0000-4000-8000-00000000000b', eventId: 'e', name: 'Ring 2', listName: 'Ring 2', status: 'live', sortOrder: 2 }
];

describe('structure advisor', () => {
  it('asks for competitors first, then explains each option in plain numbers', () => {
    expect(renderToStaticMarkup(createElement(StructureAdvisor, { entrants: 0, family: 'duel', matchType: 'longsword', areas: 1, onUse: () => undefined }))).toContain('Tick at least two');
    const html = renderToStaticMarkup(createElement(StructureAdvisor, { entrants: 10, family: 'duel', matchType: 'longsword', areas: 2, onUse: () => undefined }));
    expect(html).toContain('Suggested');
    expect(html).toContain('Each fights');
    expect(html).toContain('Use this structure');
    expect(html).toMatch(/\d+ min|\d+ h/);
  });
});

describe('schedule planner', () => {
  it('shows a timeline per area in the event timezone with pairings', () => {
    const html = renderToStaticMarkup(createElement(SchedulePlanner, {
      matches: preview.plan.matches, fightCards: cards, matchType: 'longsword', eventStartsAt: '2026-06-06T15:00:00Z', timezone: 'America/Edmonton',
      names: (match, side) => preview.seededEntries.find(item => item.entry.id === match.participants.find(p => p.sideIndex === side)?.rosterEntryId)?.entry.displayName ?? 'TBD',
      onPlan: () => undefined
    }));
    expect(html).toContain('Ring 1');
    expect(html).toContain('Ring 2');
    expect(html).toContain('09:00');
    expect(html).toContain(`${preview.plan.matches.length} bouts`);
    expect(html).toMatch(/Fighter \d+ vs Fighter \d+/);
    expect(html).toContain('America/Edmonton');
  });
});
