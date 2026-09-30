import { useEffect, useMemo, useState } from 'react';
import type { CompetitionFamily } from '../lib/competitionFormats';
import { eventClock, eventDayKey, zonedTimeToIso, zoneLabel } from '../lib/eventTime';
import {
  areasNeeded, defaultTiming, estimateMinutes, formatDuration, recommendStructures, scheduleMatches, scheduleMetadata,
  type ScheduleSettings, type SchedulePlan, type StructureSuggestion
} from '../lib/tournamentPlanner';
import type { FightCard, MatchRecord } from '../types';

/** Plain-language structure advice for the number of competitors chosen. */
export function StructureAdvisor({ entrants, family, matchType, areas: fields, onUse }: {
  entrants: number; family: CompetitionFamily; matchType: string; areas: number; onUse: (suggestion: StructureSuggestion) => void;
}) {
  const suggestions = useMemo(() => recommendStructures(entrants, family), [entrants, family]);
  const timing = defaultTiming(matchType);
  const [areas, setAreas] = useState(Math.max(1, fields));
  const [hours, setHours] = useState(8);
  if (entrants < 2) return <div className="state-card">Tick at least two cleared competitors below and BuhurtOS will suggest how to run them, with bout counts and a time estimate.</div>;
  return <div className="tp-advisor" aria-label="Suggested structures">
    <h3>Suggested ways to run {entrants} {family === 'melee' ? 'teams' : 'competitors'}</h3>
    <div className="tp-grid">
      <label>Fighting areas<input type="number" min={1} max={8} value={areas} onChange={e => setAreas(Math.max(1, Math.min(8, Number(e.target.value) || 1)))} /></label>
      <label>Hours available<input type="number" min={1} max={16} step={0.5} value={hours} onChange={e => setHours(Math.max(1, Math.min(16, Number(e.target.value) || 1)))} /></label>
    </div>
    <p className="tp-note">Estimates use {timing.boutMinutes} minutes per bout plus {timing.changeoverMinutes} to reset. You can change these in the schedule step.</p>
    <ul className="tp-cards">{suggestions.map(item => <li key={item.id} className={item.recommended ? 'recommended' : ''}>
      <div className="tp-card-head"><strong>{item.title}</strong>{item.recommended ? <span className="tp-badge">Suggested</span> : null}</div>
      {item.groups.length > 1 ? <p className="tp-groups">Pools of {[...new Set(item.groups)].join(' and ')} ({item.groups.length} pools){item.qualifiersPerPool ? `, top ${item.qualifiersPerPool} from each go to the knockout` : ''}</p> : null}
      <dl className="tp-facts">
        <div><dt>Bouts</dt><dd>{item.bouts}</dd></div>
        <div><dt>Each fights</dt><dd>{item.minBoutsPerCompetitor === item.maxBoutsPerCompetitor ? item.minBoutsPerCompetitor : `${item.minBoutsPerCompetitor}–${item.maxBoutsPerCompetitor}`}</dd></div>
        <div><dt>About</dt><dd>{formatDuration(estimateMinutes(item.bouts, areas, timing))}</dd></div>
      </dl>
      {estimateMinutes(item.bouts, areas, timing) <= hours * 60
        ? <p className="tp-fit ok">Fits in {hours} hours on {areas} area{areas === 1 ? '' : 's'}.</p>
        : <p className="tp-fit over">Too long for {hours} hours on {areas} area{areas === 1 ? '' : 's'}. You would need {areasNeeded(item.bouts, hours, timing)} areas, or a faster structure.</p>}
      <p>{item.why}</p>
      <button type="button" className={item.recommended ? 'primary' : ''} onClick={() => onUse(item)}>Use this structure</button>
    </li>)}</ul>
  </div>;
}

export interface PlannedSchedule { plan: SchedulePlan; settings: ScheduleSettings; metadata: ReturnType<typeof scheduleMetadata> }

type Names = (match: MatchRecord, side: 1 | 2) => string;

/** Picks fighting areas, bout length and breaks, then shows the day as a timeline per area. */
export function SchedulePlanner({ matches, fightCards, matchType, eventStartsAt, timezone, names, onPlan }: {
  matches: MatchRecord[]; fightCards: FightCard[]; matchType: string; eventStartsAt: string; timezone: string; names: Names;
  onPlan: (planned: PlannedSchedule | undefined) => void;
}) {
  const cards = useMemo(() => [...fightCards].filter(card => card.status !== 'archived').sort((a, b) => a.sortOrder - b.sortOrder), [fightCards]);
  const timing = useMemo(() => defaultTiming(matchType), [matchType]);
  const day = eventDayKey(eventStartsAt, timezone);
  const [enabled, setEnabled] = useState(true);
  const [areaCount, setAreaCount] = useState(Math.max(1, Math.min(cards.length || 1, 2)));
  const [startTime, setStartTime] = useState(eventClock(eventStartsAt, timezone) || '09:00');
  const [endTime, setEndTime] = useState('18:00');
  const [boutMinutes, setBoutMinutes] = useState(timing.boutMinutes);
  const [changeover, setChangeover] = useState(timing.changeoverMinutes);
  const [rest, setRest] = useState(timing.minRestMinutes);
  const [lunch, setLunch] = useState(false);
  const [lunchStart, setLunchStart] = useState('12:30');
  const [lunchMinutes, setLunchMinutes] = useState(45);
  const [view, setView] = useState<'areas' | 'list'>('areas');

  // New match type, new starting estimates.
  useEffect(() => { setBoutMinutes(timing.boutMinutes); setChangeover(timing.changeoverMinutes); setRest(timing.minRestMinutes); }, [timing]);

  const areaIds = useMemo(() => Array.from({ length: areaCount }, (_, index) => cards[index]?.id ?? `virtual-area-${index + 1}`), [areaCount, cards]);
  const areaName = (id: string) => cards.find(card => card.id === id)?.name ?? `Area ${areaIds.indexOf(id) + 1}`;

  const settings: ScheduleSettings = useMemo(() => ({
    startsAt: zonedTimeToIso(day, startTime, timezone),
    dayEndsAt: endTime ? zonedTimeToIso(day, endTime, timezone) : undefined,
    areaIds, boutMinutes, changeoverMinutes: changeover, minRestMinutes: rest,
    breaks: lunch ? [{ label: 'Break', startsAt: zonedTimeToIso(day, lunchStart, timezone), minutes: lunchMinutes }] : []
  }), [day, startTime, endTime, areaIds, boutMinutes, changeover, rest, lunch, lunchStart, lunchMinutes, timezone]);

  const plan = useMemo(() => (enabled && matches.length ? scheduleMatches(matches, settings) : undefined), [enabled, matches, settings]);

  useEffect(() => {
    onPlan(enabled && plan && plan.slots.length ? { plan, settings, metadata: scheduleMetadata(plan, settings) } : undefined);
  }, [enabled, plan, settings]); // eslint-disable-line react-hooks/exhaustive-deps

  const matchById = useMemo(() => new Map(matches.map(match => [match.id, match])), [matches]);
  const clock = (iso: string) => eventClock(iso, timezone);
  const pairing = (id: string) => {
    const match = matchById.get(id);
    return match ? `${names(match, 1)} vs ${names(match, 2)}` : '';
  };

  return <div className="tp-schedule">
    <label className="tp-check"><input type="checkbox" checked={enabled} onChange={e => setEnabled(e.target.checked)} /> Plan times and areas for these bouts</label>
    {enabled ? <>
      <p className="tp-note">Times are in the event’s timezone ({zoneLabel(timezone)}). Bout length and rest are starting estimates. Change them to match your ruleset and your past events.</p>
      <div className="tp-grid">
        <label>Fighting areas<input type="number" min={1} max={8} value={areaCount} onChange={e => setAreaCount(Math.max(1, Math.min(8, Number(e.target.value) || 1)))} />
          <small>{cards.length ? `${Math.min(areaCount, cards.length)} of your ${cards.length} field${cards.length === 1 ? '' : 's'} will be used.` : 'No fields created yet, so areas are placeholders.'}</small></label>
        <label>First bout<input type="time" value={startTime} onChange={e => setStartTime(e.target.value)} /></label>
        <label>Day should end by<input type="time" value={endTime} onChange={e => setEndTime(e.target.value)} /></label>
        <label>Minutes per bout<input type="number" min={1} max={120} value={boutMinutes} onChange={e => setBoutMinutes(Math.max(1, Number(e.target.value) || 1))} /></label>
        <label>Minutes to reset<input type="number" min={0} max={60} value={changeover} onChange={e => setChangeover(Math.max(0, Number(e.target.value) || 0))} /></label>
        <label>Minimum rest between a fighter’s bouts<input type="number" min={0} max={180} value={rest} onChange={e => setRest(Math.max(0, Number(e.target.value) || 0))} /></label>
      </div>
      <label className="tp-check"><input type="checkbox" checked={lunch} onChange={e => setLunch(e.target.checked)} /> Add a break (nothing runs during it)</label>
      {lunch ? <div className="tp-grid">
        <label>Break starts<input type="time" value={lunchStart} onChange={e => setLunchStart(e.target.value)} /></label>
        <label>Break length (minutes)<input type="number" min={5} max={240} value={lunchMinutes} onChange={e => setLunchMinutes(Math.max(5, Number(e.target.value) || 5))} /></label>
      </div> : null}

      {plan ? <>
        <div className="tp-summary" role="status">
          <strong>{plan.slots.length} bouts</strong>
          {plan.finishesAt ? <span>finish about <b>{clock(plan.finishesAt)}</b></span> : null}
          <span>{areaIds.length} area{areaIds.length === 1 ? '' : 's'}</span>
          {plan.shortestRestMinutes !== undefined ? <span>shortest rest {plan.shortestRestMinutes} min</span> : null}
        </div>
        {plan.warnings.map((warning, index) => <p key={index} className="tp-warning" role="alert">{warning}</p>)}
        <div className="directory-view-switch" role="group" aria-label="Schedule view">
          <button type="button" className={view === 'areas' ? 'selected' : ''} aria-pressed={view === 'areas'} onClick={() => setView('areas')}>By area</button>
          <button type="button" className={view === 'list' ? 'selected' : ''} aria-pressed={view === 'list'} onClick={() => setView('list')}>Order of play</button>
        </div>
        {view === 'areas'
          ? <div className="tp-areas">{areaIds.map(id => <section key={id}>
              <h4>{areaName(id)} <small>{plan.perArea[id]?.bouts ?? 0} bouts</small></h4>
              <ol>{plan.slots.filter(slot => slot.areaId === id).map(slot => <li key={slot.matchId}><time>{clock(slot.startsAt)}</time><span><b>{slot.label}</b><small>{pairing(slot.matchId)}</small></span></li>)}</ol>
            </section>)}</div>
          : <ol className="tp-order">{plan.slots.map(slot => <li key={slot.matchId}><time>{clock(slot.startsAt)}</time><span><b>{slot.label}</b><small>{areaName(slot.areaId)} · {pairing(slot.matchId)}</small></span></li>)}</ol>}
      </> : <p className="tp-note">Generate a preview to see the schedule.</p>}
    </> : null}
  </div>;
}
