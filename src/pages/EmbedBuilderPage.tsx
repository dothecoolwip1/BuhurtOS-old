import { useEffect, useMemo, useState } from 'react';
import { PageHeader, Panel } from '../components/ShowcaseUI';
import {
  buildEmbedUrl, buildIframeCode, clampHeight, defaultEmbedHeights, embedWidgetLabels, parseAccent, specNeedsEntity,
  type EmbedSpec, type EmbedTheme, type EmbedWidgetType
} from '../lib/embedBuilder';
import { loadPublicEvents, loadPublicOrganizations, type PublicEventSummary, type PublicOrganizationSummary } from '../lib/publicDirectory';
import { loadPublicTeamDirectory, type PublicDirectoryTeam } from '../lib/teamDirectory';

const types = Object.keys(embedWidgetLabels) as EmbedWidgetType[];

/** Simple builder: pick a widget, pick the organization/team/event, theme and height, preview, copy the iframe. */
export function EmbedBuilderPage() {
  const [type, setType] = useState<EmbedWidgetType>('events');
  const [organization, setOrganization] = useState('');
  const [entity, setEntity] = useState('');
  const [theme, setTheme] = useState<EmbedTheme>('auto');
  const [accent, setAccent] = useState('');
  const [height, setHeight] = useState(defaultEmbedHeights.events);
  const [copied, setCopied] = useState('');
  const [orgs, setOrgs] = useState<PublicOrganizationSummary[]>([]);
  const [events, setEvents] = useState<PublicEventSummary[]>([]);
  const [teams, setTeams] = useState<PublicDirectoryTeam[]>([]);

  useEffect(() => {
    let active = true;
    loadPublicOrganizations().then(rows => { if (active) setOrgs(rows); }).catch(() => undefined);
    loadPublicEvents().then(rows => { if (active) setEvents(rows); }).catch(() => undefined);
    return () => { active = false; };
  }, []);
  useEffect(() => {
    if (type !== 'team' || teams.length) return;
    let active = true;
    loadPublicTeamDirectory().then(rows => { if (active) setTeams(rows); }).catch(() => undefined);
    return () => { active = false; };
  }, [type, teams.length]);

  const chooseType = (next: EmbedWidgetType) => { setType(next); setEntity(''); setHeight(defaultEmbedHeights[next]); };

  const needsEntity = specNeedsEntity(type);
  const spec: EmbedSpec = { type, entity: entity || undefined, organization: organization || undefined, theme, accent: accent || undefined, height };
  const ready = !needsEntity || Boolean(entity);
  const base = typeof window === 'undefined' ? '' : window.location.origin + window.location.pathname;
  const url = ready ? buildEmbedUrl(base, spec) : '';
  const code = ready ? buildIframeCode(url, spec) : '';
  const accentOk = !accent || Boolean(parseAccent(accent));

  const copy = async (value: string, label: string) => {
    try { await navigator.clipboard.writeText(value); setCopied(label + ' copied'); } catch { setCopied('Copy failed. Select the text and copy it manually.'); }
  };

  const publicEvents = useMemo(() => events.filter(event => event.status !== 'draft'), [events]);

  return <>
    <PageHeader eyebrow="WIDGETS" title="Embed BuhurtOS on your own website" description="Pick a widget, preview it, and paste one line of code into any page. Embeds show public data only and need no account. Your existing website stays exactly as it is." />
    <div className="embed-builder">
      <Panel title="Configure">
        <div className="embed-builder-form">
          <label>Widget
            <select value={type} onChange={e => chooseType(e.target.value as EmbedWidgetType)}>{types.map(t => <option key={t} value={t}>{embedWidgetLabels[t]}</option>)}</select>
          </label>
          {type === 'events' ? <label>Organization (optional)
            <select value={organization} onChange={e => setOrganization(e.target.value)}><option value="">All public events</option>{orgs.map(org => <option key={org.key} value={org.shortName}>{org.name}</option>)}</select>
          </label> : null}
          {type === 'team' ? <label>Team
            <select value={entity} onChange={e => setEntity(e.target.value)}><option value="">Choose a team</option>{teams.map(team => <option key={team.id} value={team.slug}>{team.name} · {team.organizationShortName}</option>)}</select>
          </label> : null}
          {type === 'event' || type === 'standings' ? <label>Event
            <select value={entity} onChange={e => setEntity(e.target.value)}><option value="">Choose an event</option>{publicEvents.map(event => <option key={event.id} value={event.id}>{event.name}</option>)}</select>
          </label> : null}
          <label>Theme
            <select value={theme} onChange={e => setTheme(e.target.value as EmbedTheme)}><option value="auto">Match the visitor (auto)</option><option value="light">Light</option><option value="dark">Dark</option></select>
          </label>
          <label>Accent color (optional hex)
            <input value={accent} onChange={e => setAccent(e.target.value)} placeholder="#d9680c" aria-invalid={!accentOk} />
          </label>
          {!accentOk ? <small role="alert">Use a hex color such as #d9680c.</small> : null}
          <label>Height (px)
            <input type="number" min={240} max={1400} value={height} onChange={e => setHeight(clampHeight(Number(e.target.value), type))} />
          </label>
        </div>
      </Panel>
      <div className="show-stack">
        <Panel title="Preview">
          {ready ? <div className="embed-preview"><iframe key={url} src={url} title="Widget preview" style={{ height }} loading="lazy" referrerPolicy="no-referrer" /></div> : <p>Choose {type === 'team' ? 'a team' : 'an event'} to see the preview.</p>}
        </Panel>
        <Panel title="Your embed code">
          <textarea className="embed-code" readOnly value={code || 'Finish the choices above to generate the code.'} aria-label="Iframe embed code" />
          <div className="show-page-actions">
            <button className="show-btn primary" type="button" disabled={!ready} onClick={() => copy(code, 'Embed code')}>Copy iframe code</button>
            <button className="show-btn secondary" type="button" disabled={!ready} onClick={() => copy(url, 'Link')}>Copy link</button>
          </div>
          {copied ? <p role="status">{copied}</p> : null}
        </Panel>
      </div>
    </div>
  </>;
}
