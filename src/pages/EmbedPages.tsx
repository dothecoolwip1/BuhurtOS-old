import { useEffect, useState, type CSSProperties, type ReactNode } from 'react';
import { useParams, useSearchParams } from 'react-router-dom';
import { eventCta, groupByMonth } from '../lib/eventCategories';
import { formatEventDate } from '../lib/eventTime';
import { parseAccent, parseTheme, readableTextOn, type EmbedTheme } from '../lib/embedBuilder';
import { calendar, getEvent, getTeam, getTeamStats, type EventDTO, type TeamDTO, type TeamStatsDTO } from '../lib/publicApiV1';
import { loadEventSnapshot } from '../lib/repository';
import { computeEventStandings, type StandingRow } from '../lib/standings';
import { isSupabaseConfigured } from '../lib/supabase';

/** Absolute link to a full BuhurtOS page from inside an embed (opens in a new tab). */
export function siteLink(path: string): string {
  if (typeof window === 'undefined') return path;
  return `${window.location.origin}${window.location.pathname}#${path}`;
}

export function EmbedFrame({ theme, accent, children }: { theme: EmbedTheme; accent?: string; children: ReactNode }) {
  const style = accent ? ({ '--embed-accent': accent, '--embed-on-accent': readableTextOn(accent) } as CSSProperties) : undefined;
  return <div className="embed-shell" data-theme={theme} style={style}>
    {children}
    <div className="embed-foot"><a href={siteLink('/public')} target="_blank" rel="noopener noreferrer">Powered by BuhurtOS</a></div>
  </div>;
}

export function EmbedState({ title, text }: { title: string; text?: string }) {
  return <div className="embed-state" role="status"><strong>{title}</strong>{text ? <p>{text}</p> : null}</div>;
}

const fmtDate = (iso: string, timezone?: string) => formatEventDate(iso, timezone, { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' });

// ---- Views (presentational, unit-testable) --------------------------------

export function AgendaView({ events }: { events: EventDTO[] }) {
  if (events.length === 0) return <EmbedState title="No events to show" text="Nothing matching these filters is published right now." />;
  const months = groupByMonth(events);
  return <div className="embed-agenda">{months.map(month => <section key={month.key}>
    <h2>{month.label}</h2>
    {month.events.map(event => {
      const cta = eventCta(event.category, { registrationOpen: event.registrationOpen, hasLink: true, status: event.status });
      return <a className="embed-row" key={event.id} href={siteLink('/events/' + (event.slug || event.id))} target="_blank" rel="noopener noreferrer">
        <span className="embed-date">{fmtDate(event.startsAt, event.timezone)}</span>
        <span className="embed-main"><strong>{event.name}</strong><small>{event.venue}</small></span>
        <span className="embed-tags"><em>{event.categoryLabel}</em>{event.status === 'cancelled' ? <em className="warn">Cancelled</em> : null}<b>{cta.label} →</b></span>
      </a>;
    })}
  </section>)}</div>;
}

export function EventCardView({ event }: { event: EventDTO }) {
  const cta = eventCta(event.category, { registrationOpen: event.registrationOpen, hasLink: true, status: event.status });
  return <article className="embed-card">
    {event.imageUrl ? <img className="embed-poster" src={event.imageUrl} alt={event.imageAlt ?? event.name + ' poster'} loading="lazy" decoding="async" /> : null}
    <div className="embed-card-body">
      <span className="embed-kicker">{event.categoryLabel}{event.status === 'cancelled' ? ' · Cancelled' : ''}</span>
      <h1>{event.name}</h1>
      <p className="embed-meta">{fmtDate(event.startsAt, event.timezone)}{fmtDate(event.endsAt, event.timezone) !== fmtDate(event.startsAt, event.timezone) ? ' – ' + fmtDate(event.endsAt, event.timezone) : ''}</p>
      <p className="embed-meta">{event.venue}</p>
      {event.host?.name ? <p className="embed-meta">Hosted by {event.host.name}</p> : null}
      {event.description ? <p className="embed-copy">{event.description}</p> : null}
      <div className="embed-actions">
        <a className="embed-btn primary" href={siteLink('/events/' + (event.slug || event.id))} target="_blank" rel="noopener noreferrer">{cta.kind === 'none' ? 'Event page' : cta.label}</a>
        {event.links.facebook ? <a className="embed-btn" href={event.links.facebook} target="_blank" rel="noopener noreferrer">Facebook event ↗</a> : null}
      </div>
    </div>
  </article>;
}

export function TeamCardView({ team, stats }: { team: TeamDTO; stats?: TeamStatsDTO }) {
  const official = stats?.official;
  const place = [team.location, team.region, team.country].filter(Boolean).join(' · ');
  return <article className="embed-card">
    <div className="embed-card-body">
      <div className="embed-team-head">
        {team.logoUrl ? <img className="embed-logo" src={team.logoUrl} alt={team.name + ' logo'} loading="lazy" decoding="async" /> : <span className="embed-logo initials">{team.name.replace(/^The\s+/i, '').split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase()).join('')}</span>}
        <div><span className="embed-kicker">{team.organization.shortName}</span><h1>{team.name}</h1>{place ? <p className="embed-meta">{place}</p> : null}</div>
      </div>
      <dl className="embed-stats">
        {team.rankings.rank5v5 != null ? <div><dt>5v5 rank</dt><dd>#{team.rankings.rank5v5}</dd></div> : null}
        {team.rankings.points5v5 != null ? <div><dt>5v5 points</dt><dd>{team.rankings.points5v5}</dd></div> : null}
        {team.rankings.rank12v12 != null ? <div><dt>12v12 rank</dt><dd>#{team.rankings.rank12v12}</dd></div> : null}
        {official ? <div><dt>Record</dt><dd>{official.wins}-{official.losses}-{official.draws}</dd></div> : null}
        {official ? <div><dt>Matches</dt><dd>{official.matches}</dd></div> : null}
        {team.captain ? <div><dt>Captain</dt><dd className="text">{team.captain}</dd></div> : null}
      </dl>
      {!official ? <p className="embed-note">No official BuhurtOS match record yet. Rankings shown are source-backed.</p> : null}
      <div className="embed-actions">
        <a className="embed-btn primary" href={siteLink('/teams/' + team.slug)} target="_blank" rel="noopener noreferrer">Full team profile</a>
        {team.source?.url ? <a className="embed-btn" href={team.source.url} target="_blank" rel="noopener noreferrer">Source ↗</a> : null}
      </div>
    </div>
  </article>;
}

export function StandingsView({ eventName, rows, demo }: { eventName: string; rows: StandingRow[]; demo?: boolean }) {
  return <div>
    <div className="embed-standings-head"><strong>{eventName}</strong>{demo ? <span className="embed-demo">DEMO DATA</span> : null}</div>
    {rows.length === 0 ? <EmbedState title="No standings yet" text="Standings appear once matches are finalized." /> : <table className="embed-table">
      <thead><tr><th>#</th><th>Competitor</th><th>W</th><th>L</th><th>D</th><th>Pts</th></tr></thead>
      <tbody>{rows.map((row, index) => <tr key={row.rosterEntryId}><td>{index + 1}</td><td><strong>{row.name}</strong></td><td>{row.wins}</td><td>{row.losses}</td><td>{row.draws}</td><td><b>{row.standingPoints}</b></td></tr>)}</tbody>
    </table>}
  </div>;
}

// ---- Routes ---------------------------------------------------------------

function useEmbedLook() {
  const [params] = useSearchParams();
  return { theme: parseTheme(params.get('theme')), accent: parseAccent(params.get('accent')), params };
}

type Loaded<T> = { state: 'loading' } | { state: 'error'; message: string } | { state: 'missing' } | { state: 'ready'; value: T };

function useLoad<T>(load: () => Promise<T | undefined>, deps: unknown[]): Loaded<T> {
  const [value, setValue] = useState<Loaded<T>>({ state: 'loading' });
  useEffect(() => {
    let active = true;
    setValue({ state: 'loading' });
    load().then(result => { if (active) setValue(result === undefined ? { state: 'missing' } : { state: 'ready', value: result }); })
      .catch(err => { if (active) setValue({ state: 'error', message: err instanceof Error ? err.message : 'Unable to load this widget.' }); });
    return () => { active = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
  return value;
}

function Gate<T>({ loaded, missing, children }: { loaded: Loaded<T>; missing: string; children: (value: T) => ReactNode }) {
  if (loaded.state === 'loading') return <EmbedState title="Loading…" />;
  if (loaded.state === 'error') return <EmbedState title="Unable to load" text="This widget could not reach BuhurtOS. Try again shortly." />;
  if (loaded.state === 'missing') return <EmbedState title="Not available" text={missing} />;
  return <>{children(loaded.value)}</>;
}

export function EmbedEventsPage() {
  const { theme, accent, params } = useEmbedLook();
  const when = params.get('when') === 'past' ? 'past' : params.get('when') === 'all' ? 'all' : 'upcoming';
  const limit = Number(params.get('limit')) || 10;
  const loaded = useLoad(async () => (await calendar({ organization: params.get('org') ?? undefined, team: params.get('team') ?? undefined, category: params.get('category') ?? undefined, when, limit })).events,
    [params.toString()]);
  return <EmbedFrame theme={theme} accent={accent}><Gate loaded={loaded} missing="No events.">{events => <AgendaView events={events} />}</Gate></EmbedFrame>;
}

export function EmbedEventPage() {
  const { eventId = '' } = useParams();
  const { theme, accent } = useEmbedLook();
  const loaded = useLoad(() => getEvent(eventId), [eventId]);
  return <EmbedFrame theme={theme} accent={accent}><Gate loaded={loaded} missing="This event is not published or does not exist.">{event => <EventCardView event={event} />}</Gate></EmbedFrame>;
}

export function EmbedTeamPage() {
  const { slug = '' } = useParams();
  const { theme, accent } = useEmbedLook();
  const loaded = useLoad(async () => {
    const team = await getTeam(slug);
    if (!team) return undefined;
    return { team, stats: await getTeamStats(team.slug) };
  }, [slug]);
  return <EmbedFrame theme={theme} accent={accent}><Gate loaded={loaded} missing="This team is not in the public directory.">{({ team, stats }) => <TeamCardView team={team} stats={stats} />}</Gate></EmbedFrame>;
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function EmbedStandingsPage() {
  const { eventId = '' } = useParams();
  const { theme, accent } = useEmbedLook();
  const loaded = useLoad(async () => {
    let id = eventId;
    if (!UUID.test(id)) {
      const event = await getEvent(id);
      if (!event) return undefined;
      id = event.id;
    }
    try {
      const snapshot = await loadEventSnapshot(id, 'public');
      return { name: snapshot.event.name, rows: computeEventStandings(snapshot.event, snapshot.matches, snapshot.roster), demo: !isSupabaseConfigured };
    } catch (err) {
      // PGRST116: the public client cannot see this event (missing, unpublished or private).
      if ((err as { code?: string })?.code === 'PGRST116') return undefined;
      throw err;
    }
  }, [eventId]);
  return <EmbedFrame theme={theme} accent={accent}><Gate loaded={loaded} missing="This event is not published or does not exist.">{value => <StandingsView eventName={value.name} rows={value.rows} demo={value.demo} />}</Gate></EmbedFrame>;
}
