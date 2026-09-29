import { mkdir, writeFile } from 'node:fs/promises';

const ORIGIN = 'https://www.buhurtinternational.com';
const OUTPUT = new URL('../src/data/biTeamUrls.json', import.meta.url);

function decodeXml(value) {
  return value
    .replace(/^<!\[CDATA\[/, '')
    .replace(/\]\]>$/, '')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .trim();
}

function locs(xml) {
  return [...xml.matchAll(/<loc>\s*([\s\S]*?)\s*<\/loc>/gi)].map(match => decodeXml(match[1]));
}

async function fetchText(url) {
  const response = await fetch(url, {
    redirect: 'follow',
    headers: {
      'user-agent': 'BuhurtOS/1.0 (+https://dothecoolwip1.github.io/BuhurtOS/)'
    }
  });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`);
  return response.text();
}

async function discoverTeamUrls() {
  const queue = [`${ORIGIN}/sitemap.xml`];
  const seen = new Set();
  const sitemaps = [];
  const teams = new Set();

  while (queue.length) {
    const current = queue.shift();
    if (!current || seen.has(current)) continue;
    if (seen.size >= 100) throw new Error('Sitemap traversal exceeded safety limit.');
    seen.add(current);

    const xml = await fetchText(current);
    sitemaps.push(current);

    for (const rawLoc of locs(xml)) {
      let url;
      try { url = new URL(rawLoc); } catch { continue; }
      if (url.origin !== ORIGIN) continue;

      if (/^\/team\//i.test(url.pathname)) {
        url.hash = '';
        url.search = '';
        teams.add(url.toString());
      } else if (/sitemap/i.test(url.pathname) && !seen.has(url.toString())) {
        queue.push(url.toString());
      }
    }
  }

  return { sitemaps, teamUrls: [...teams].sort((a, b) => a.localeCompare(b)) };
}

const { sitemaps, teamUrls } = await discoverTeamUrls();
if (!teamUrls.length) throw new Error('No BI team profile URLs were found. Refusing to write an empty snapshot.');

const payload = {
  source: `${ORIGIN}/teams`,
  sourceHost: 'www.buhurtinternational.com',
  generatedAt: new Date().toISOString(),
  discovery: 'BI sitemap team profile URLs',
  count: teamUrls.length,
  sitemaps,
  teamUrls
};

await mkdir(new URL('../src/data/', import.meta.url), { recursive: true });
await writeFile(OUTPUT, JSON.stringify(payload, null, 2) + '\n', 'utf8');
console.log(`Discovered ${teamUrls.length} Buhurt International team profiles.`);


function readableText(html) {
  return html
    .replace(/<script\b[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style\b[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&#39;|&apos;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/\s+/g, ' ')
    .trim();
}

for (const sample of teamUrls.slice(0, 2)) {
  const html = await fetchText(sample);
  const text = readableText(html);
  const marker = Math.max(0, ['Conference', 'Country', 'City']
    .map(label => text.indexOf(label))
    .filter(index => index >= 0)
    .reduce((min, index) => Math.min(min, index), Number.POSITIVE_INFINITY));
  console.log('BI_PROFILE_PROBE', JSON.stringify({
    url: sample,
    title: (html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1] ?? '').trim(),
    text: text.slice(Number.isFinite(marker) ? Math.max(0, marker - 500) : 0, Number.isFinite(marker) ? marker + 1800 : 2300)
  }));
}
