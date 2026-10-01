import type { EventRecord, EventTeam, MatchRecord, RosterEntry } from '../types';
import { describeTiebreakBasis, rankWithPolicy, type Bout, type TieResolution, type TiebreakPolicy } from './tiebreak';

export interface StandingsOptions {
  /** A stored tiebreak policy. Without one the legacy order applies (differential, points scored, name). */
  policy?: TiebreakPolicy;
  /** Penalties received per roster entry (or team), when known. Without it the penalties step is reported as skipped. */
  penalties?: ReadonlyMap<string, number>;
}

export interface StandingsResult<T> {
  rows: T[];
  /** The policy that ordered ties, or undefined when the legacy fallback did. */
  policy?: TiebreakPolicy;
  resolutions: TieResolution[];
  skippedSteps: Array<{ key: string; reason: string }>;
  /** Plain-language statement of how ties were ordered. */
  basis: string;
}

const compareFor = (match: MatchRecord): Bout['compare'] => (match.scoringConfig.kind === 'duel' ? 'hit_ratio' : 'round_difference');

function toBout(match: MatchRecord, a: string, b: string): Bout {
  const r = match.resultSummary!;
  return { a, b, winner: r.winnerSide === 1 ? 'a' : r.winnerSide === 2 ? 'b' : null, roundsA: r.roundsWonSide1, roundsB: r.roundsWonSide2, hitsA: r.side1Total, hitsB: r.side2Total, compare: compareFor(match) };
}

export interface StandingRow {
  rosterEntryId: string;
  name: string;
  matches: number;
  wins: number;
  losses: number;
  draws: number;
  pointsFor: number;
  pointsAgainst: number;
  differential: number;
  standingPoints: number;
}

export function computeEventStandings(event: EventRecord, matches: MatchRecord[], roster: RosterEntry[]): StandingRow[] {
  return computeEventStandingsDetailed(event, matches, roster).rows;
}

export function computeEventStandingsDetailed(event: EventRecord, matches: MatchRecord[], roster: RosterEntry[], options: StandingsOptions = {}): StandingsResult<StandingRow> {
  if (event.standingsMode === 'no_standings') return { rows: [], resolutions: [], skippedSteps: [], basis: describeTiebreakBasis(options.policy) };
  const bouts: Bout[] = [];
  const rows = new Map<string, StandingRow>();
  const names = new Map(roster.map(r => [r.id, r.displayName]));

  for (const match of matches.filter(m => m.eventId === event.id && m.status === 'finalized' && m.resultSummary && m.resultSummary.resultType !== 'bye')) {
    const sides = match.participants.filter(p => !p.isPlaceholder && p.rosterEntryId);
    if (sides.length < 2) continue;
    for (const p of sides) {
      const id = p.rosterEntryId!;
      if (!rows.has(id)) rows.set(id, { rosterEntryId: id, name: names.get(id) ?? 'Unknown', matches: 0, wins: 0, losses: 0, draws: 0, pointsFor: 0, pointsAgainst: 0, differential: 0, standingPoints: 0 });
    }
    const side1 = sides.find(p => p.sideIndex === 1)?.rosterEntryId;
    const side2 = sides.find(p => p.sideIndex === 2)?.rosterEntryId;
    if (!side1 || !side2) continue;
    const r1 = rows.get(side1)!;
    const r2 = rows.get(side2)!;
    const result = match.resultSummary!;
    bouts.push(toBout(match, side1, side2));
    r1.matches += 1;
    r2.matches += 1;
    r1.pointsFor += result.side1Total;
    r1.pointsAgainst += result.side2Total;
    r2.pointsFor += result.side2Total;
    r2.pointsAgainst += result.side1Total;
    if (result.winnerSide === 1) { r1.wins += 1; r2.losses += 1; r1.standingPoints += 3; }
    else if (result.winnerSide === 2) { r2.wins += 1; r1.losses += 1; r2.standingPoints += 3; }
    else { r1.draws += 1; r2.draws += 1; r1.standingPoints += 1; r2.standingPoints += 1; }
  }

  const list = [...rows.values()].map(r => ({ ...r, differential: r.pointsFor - r.pointsAgainst }));
  const ranked = rankWithPolicy(
    list.map(r => ({ id: r.rosterEntryId, row: r })), item => item.row.standingPoints,
    (a, b) => b.row.standingPoints - a.row.standingPoints || b.row.differential - a.row.differential || b.row.pointsFor - a.row.pointsFor || a.row.name.localeCompare(b.row.name),
    bouts, options.policy, options.penalties
  );
  return { rows: ranked.ranked.map(item => item.row), policy: ranked.policy, resolutions: ranked.resolutions, skippedSteps: ranked.skippedSteps, basis: describeTiebreakBasis(options.policy) };
}

export interface TeamStandingRow {
  teamId: string;
  name: string;
  fighters: number;
  matches: number;
  wins: number;
  losses: number;
  draws: number;
  pointsFor: number;
  pointsAgainst: number;
  differential: number;
  standingPoints: number;
}

/**
 * Team standings aggregate the event's finalized fighter bouts by team, so a
 * team event ranks clubs/nations by how their members performed head-to-head.
 *
 * Rules that keep the board honest:
 *   * only bouts between two DIFFERENT teams score (intra-team sparring and
 *     unaffiliated/individual bouts earn neither team points);
 *   * the recognized member count counts DISTINCT roster entries that actually
 *     appeared in a scored team bout;
 *   * scoring mirrors the fighter board: 3 for a win, 1 for a draw, 0 for a
 *     loss, with differential and points scored as deterministic tie-breakers.
 */
export function computeTeamStandings(event: EventRecord, matches: MatchRecord[], roster: RosterEntry[], teams: EventTeam[]): TeamStandingRow[] {
  return computeTeamStandingsDetailed(event, matches, roster, teams).rows;
}

export function computeTeamStandingsDetailed(event: EventRecord, matches: MatchRecord[], roster: RosterEntry[], teams: EventTeam[], options: StandingsOptions = {}): StandingsResult<TeamStandingRow> {
  if (event.standingsMode === 'no_standings') return { rows: [], resolutions: [], skippedSteps: [], basis: describeTiebreakBasis(options.policy) };
  const bouts: Bout[] = [];
  const entryTeam = new Map(roster.filter(r => r.teamId).map(r => [r.id, r.teamId] as const));
  const teamNames = new Map(teams.map(t => [t.id, t.name]));
  const rows = new Map<string, TeamStandingRow>();
  const fighterSets = new Map<string, Set<string>>();

  const touch = (teamId: string, fighterId: string) => {
    if (!rows.has(teamId)) {
      rows.set(teamId, { teamId, name: teamNames.get(teamId) ?? 'Unknown Team', fighters: 0, matches: 0, wins: 0, losses: 0, draws: 0, pointsFor: 0, pointsAgainst: 0, differential: 0, standingPoints: 0 });
    }
    let set = fighterSets.get(teamId);
    if (!set) { set = new Set(); fighterSets.set(teamId, set); }
    set.add(fighterId);
  };

  for (const match of matches.filter(m => m.eventId === event.id && m.status === 'finalized' && m.resultSummary && m.resultSummary.resultType !== 'bye')) {
    const sides = match.participants.filter(p => !p.isPlaceholder && p.rosterEntryId);
    if (sides.length < 2) continue;
    const side1 = sides.find(p => p.sideIndex === 1)?.rosterEntryId;
    const side2 = sides.find(p => p.sideIndex === 2)?.rosterEntryId;
    if (!side1 || !side2) continue;
    const team1 = entryTeam.get(side1);
    const team2 = entryTeam.get(side2);
    if (!team1 || !team2 || team1 === team2) continue;

    touch(team1, side1);
    touch(team2, side2);
    const r1 = rows.get(team1)!;
    const r2 = rows.get(team2)!;
    const result = match.resultSummary!;
    bouts.push(toBout(match, team1, team2));
    r1.matches += 1;
    r2.matches += 1;
    r1.pointsFor += result.side1Total;
    r1.pointsAgainst += result.side2Total;
    r2.pointsFor += result.side2Total;
    r2.pointsAgainst += result.side1Total;
    if (result.winnerSide === 1) { r1.wins += 1; r2.losses += 1; r1.standingPoints += 3; }
    else if (result.winnerSide === 2) { r2.wins += 1; r1.losses += 1; r2.standingPoints += 3; }
    else { r1.draws += 1; r2.draws += 1; r1.standingPoints += 1; r2.standingPoints += 1; }
  }

  for (const [teamId, fighterSet] of fighterSets) {
    rows.get(teamId)!.fighters = fighterSet.size;
  }

  const list = [...rows.values()].map(r => ({ ...r, differential: r.pointsFor - r.pointsAgainst }));
  const ranked = rankWithPolicy(
    list.map(r => ({ id: r.teamId, row: r })), item => item.row.standingPoints,
    (a, b) => b.row.standingPoints - a.row.standingPoints || b.row.differential - a.row.differential || b.row.pointsFor - a.row.pointsFor || b.row.wins - a.row.wins || a.row.name.localeCompare(b.row.name),
    bouts, options.policy, options.penalties
  );
  return { rows: ranked.ranked.map(item => item.row), policy: ranked.policy, resolutions: ranked.resolutions, skippedSteps: ranked.skippedSteps, basis: describeTiebreakBasis(options.policy) };
}