/**
 * Embed widget URLs, parameters and iframe code.
 * Embeds are plain iframes pointing at stable, chrome-free /embed routes that read public data only.
 */
export type EmbedWidgetType = 'events' | 'team' | 'event' | 'standings';
export type EmbedTheme = 'auto' | 'light' | 'dark';

export type EmbedSpec = {
  type: EmbedWidgetType;
  /** team slug (team), event id or slug (event, standings); ignored for the agenda. */
  entity?: string;
  /** Agenda filters. */
  organization?: string;
  team?: string;
  category?: string;
  when?: 'upcoming' | 'past' | 'all';
  limit?: number;
  theme?: EmbedTheme;
  accent?: string;
  height?: number;
};

export const embedWidgetLabels: Record<EmbedWidgetType, string> = {
  events: 'Upcoming events / calendar agenda',
  team: 'Team card & stats',
  event: 'Event card',
  standings: 'Standings & results'
};

export const defaultEmbedHeights: Record<EmbedWidgetType, number> = { events: 520, team: 420, event: 380, standings: 480 };

const HEX = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i;

/** Returns a normalized "#rrggbb"-style accent or undefined when the value is not a safe hex color. */
export function parseAccent(value: string | null | undefined): string | undefined {
  if (!value || !HEX.test(value.trim())) return undefined;
  const hex = value.trim().replace('#', '').toLowerCase();
  return '#' + (hex.length === 3 ? hex.split('').map(c => c + c).join('') : hex);
}

export function parseTheme(value: string | null | undefined): EmbedTheme {
  return value === 'light' || value === 'dark' ? value : 'auto';
}

export function clampHeight(value: number | undefined, type: EmbedWidgetType): number {
  const n = Number.isFinite(value) ? Math.round(value as number) : defaultEmbedHeights[type];
  return Math.max(240, Math.min(1400, n));
}

export function embedPath(spec: EmbedSpec): string {
  const entity = spec.entity ? encodeURIComponent(spec.entity) : '';
  const params = new URLSearchParams();
  if (spec.theme && spec.theme !== 'auto') params.set('theme', spec.theme);
  const accent = parseAccent(spec.accent);
  if (accent) params.set('accent', accent.slice(1));
  if (spec.type === 'events') {
    if (spec.organization) params.set('org', spec.organization);
    if (spec.team) params.set('team', spec.team);
    if (spec.category && spec.category !== 'all') params.set('category', spec.category);
    if (spec.when && spec.when !== 'upcoming') params.set('when', spec.when);
    if (spec.limit) params.set('limit', String(Math.max(1, Math.min(50, Math.round(spec.limit)))));
  }
  const query = params.toString();
  const base = spec.type === 'events' ? '/embed/events' : spec.type === 'team' ? `/embed/team/${entity}` : spec.type === 'event' ? `/embed/event/${entity}` : `/embed/standings/${entity}`;
  return base + (query ? '?' + query : '');
}

/** Stable absolute URL (HashRouter form) on the deployed site. */
export function buildEmbedUrl(siteBase: string, spec: EmbedSpec): string {
  let root = siteBase;
  try {
    const url = new URL(siteBase, 'https://buhurtos.invalid');
    root = url.origin === 'https://buhurtos.invalid' ? url.pathname : url.origin + url.pathname;
  } catch {
    // keep siteBase as given
  }
  return root.replace(/\/$/, '') + '/#' + embedPath(spec);
}

export function escapeAttr(value: string | number): string {
  return String(value).replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}

export function buildIframeCode(url: string, spec: Pick<EmbedSpec, 'type' | 'height'>, title?: string): string {
  const height = clampHeight(spec.height, spec.type);
  const label = title ?? `BuhurtOS ${embedWidgetLabels[spec.type]}`;
  return `<iframe src="${escapeAttr(url)}" title="${escapeAttr(label)}" width="100%" height="${height}" loading="lazy" style="border:0;border-radius:8px;max-width:100%" referrerpolicy="no-referrer"></iframe>`;
}

export function specNeedsEntity(type: EmbedWidgetType): boolean {
  return type !== 'events';
}

function relativeLuminance(hex: string): number {
  const channel = (value: number) => { const c = value / 255; return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; };
  const n = parseInt(hex.replace('#', ''), 16);
  return 0.2126 * channel((n >> 16) & 255) + 0.7152 * channel((n >> 8) & 255) + 0.0722 * channel(n & 255);
}

/** Picks black or white text, whichever reads better on the given accent (WCAG contrast). */
export function readableTextOn(accentHex: string): '#111111' | '#ffffff' {
  const accent = parseAccent(accentHex);
  if (!accent) return '#ffffff';
  const l = relativeLuminance(accent);
  const whiteContrast = 1.05 / (l + 0.05);
  const blackContrast = (l + 0.05) / (relativeLuminance('#111111') + 0.05);
  return whiteContrast >= blackContrast ? '#ffffff' : '#111111';
}
