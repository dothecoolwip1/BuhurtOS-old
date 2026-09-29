// Embeddable widget helpers.
//
// The standings widget is a self-contained route rendered from the live event
// board (demo events are labeled "DEMO DATA" inside the widget). These helpers
// build the clean widget URL and the iframe snippet hosts paste into their
// pages; attribute values are escaped so untrusted data cannot break out of
// the markup.

export type WidgetEmbedOptions = {
  width?: number;
  height?: number;
  title?: string;
};

export function widgetStandingsUrl(base: string = typeof window === 'undefined' ? '' : window.location.href): string {
  try {
    const url = new URL(base, 'https://buhurtos.invalid');
    return `${url.origin}${url.pathname}#/widget/standings`;
  } catch {
    return `${base}#/widget/standings`;
  }
}

function escapeAttr(value: string | number): string {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

export function widgetEmbedCode(embedUrl: string, options: WidgetEmbedOptions = {}): string {
  const width = options.width ?? 600;
  const height = options.height ?? 480;
  const title = options.title ?? 'BuhurtOS standings widget';
  return [
    '<!-- BuhurtOS standings widget. Rendered from the event board; demo events are labeled as such inside the widget. -->',
    `<iframe src="${escapeAttr(embedUrl)}" title="${escapeAttr(title)}" width="${escapeAttr(width)}" height="${escapeAttr(height)}" loading="lazy" style="border:0;border-radius:8px;max-width:100%" referrerpolicy="no-referrer"></iframe>`,
  ].join('\n');
}