import { mkdir, writeFile } from 'node:fs/promises';

const ORIGIN = 'https://www.buhurtinternational.com';
const URL_OUTPUT = new URL('../src/data/biTeamUrls.json', import.meta.url);
const RAW_OUTPUT = new URL('../src/data/biTeamsRaw.json', import.meta.url);

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
    headers: { 'user-agent': 'BuhurtOS/1.0 (+https://dothecoolwip1.github.io/BuhurtOS/)' }
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

async function renderDirectory() {
  const { default: puppeteer } = await import('puppeteer-core');
  const browser = await puppeteer.launch({
    executablePath: process.env.CHROME_PATH || '/usr/bin/google-chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage']
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1440, height: 1200 });
    await page.setUserAgent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/140 Safari/537.36');
    await page.setRequestInterception(true);
    page.on('request', request => {
      if (['image', 'media', 'font'].includes(request.resourceType())) request.abort();
      else request.continue();
    });

    await page.goto(`${ORIGIN}/teams`, { waitUntil: 'domcontentloaded', timeout: 90_000 });
    await page.waitForFunction(
      () => document.querySelectorAll('a[href*="/team/"]').length > 0,
      { timeout: 90_000 }
    );

    let previousCount = 0;
    for (let attempt = 0; attempt < 100; attempt += 1) {
      const state = await page.evaluate(() => {
        const count = new Set(
          [...document.querySelectorAll('a[href*="/team/"]')]
            .map(a => a.href)
            .filter(Boolean)
        ).size;
        const control = [...document.querySelectorAll('button, [role="button"], a')]
          .find(el => /^load more$/i.test((el.textContent || '').trim()));
        if (!control) return { count, clicked: false };
        control.scrollIntoView({ block: 'center' });
        control.click();
        return { count, clicked: true };
      });

      if (!state.clicked) break;
      previousCount = state.count;
      await page.waitForFunction(
        oldCount => new Set(
          [...document.querySelectorAll('a[href*="/team/"]')]
            .map(a => a.href)
            .filter(Boolean)
        ).size > oldCount || ![...document.querySelectorAll('button, [role="button"], a')]
          .some(el => /^load more$/i.test((el.textContent || '').trim())),
        { timeout: 30_000 },
        previousCount
      ).catch(() => {});
    }

    return await page.evaluate(() => {
      const best = new Map();
      for (const anchor of document.querySelectorAll('a[href*="/team/"]')) {
        const href = anchor.href;
        if (!href || !new URL(href).pathname.startsWith('/team/')) continue;

        let node = anchor;
        let text = (anchor.textContent || '').trim();
        for (let depth = 0; depth < 10 && node.parentElement; depth += 1) {
          node = node.parentElement;
          const candidate = (node.innerText || '').replace(/\n{3,}/g, '\n\n').trim();
          if (!candidate || candidate.length > 5000) continue;
          if (/Conference/i.test(candidate) && /Country/i.test(candidate)) {
            text = candidate;
            break;
          }
          if (candidate.length > text.length) text = candidate;
        }

        const normalized = href.split('#')[0].split('?')[0];
        const existing = best.get(normalized);
        if (!existing || text.length > existing.text.length) best.set(normalized, { url: normalized, text });
      }
      return [...best.values()].sort((a, b) => a.url.localeCompare(b.url));
    });
  } finally {
    await browser.close();
  }
}

const { sitemaps, teamUrls } = await discoverTeamUrls();
if (!teamUrls.length) throw new Error('No BI team profile URLs were found. Refusing to write an empty snapshot.');

const generatedAt = new Date().toISOString();
await mkdir(new URL('../src/data/', import.meta.url), { recursive: true });
await writeFile(URL_OUTPUT, JSON.stringify({
  source: `${ORIGIN}/teams`,
  sourceHost: 'www.buhurtinternational.com',
  generatedAt,
  discovery: 'BI sitemap team profile URLs',
  count: teamUrls.length,
  sitemaps,
  teamUrls
}, null, 2) + '\n', 'utf8');

const renderedTeams = await renderDirectory();
if (renderedTeams.length < 100) {
  throw new Error(`Rendered BI directory returned only ${renderedTeams.length} team links. Refusing incomplete snapshot.`);
}

const renderedUrls = new Set(renderedTeams.map(team => team.url));
const sitemapUrls = new Set(teamUrls);
const raw = {
  source: `${ORIGIN}/teams`,
  generatedAt,
  sitemapCount: teamUrls.length,
  renderedCount: renderedTeams.length,
  missingFromRenderedDirectory: teamUrls.filter(url => !renderedUrls.has(url)),
  missingFromSitemap: renderedTeams.map(team => team.url).filter(url => !sitemapUrls.has(url)),
  teams: renderedTeams
};

await writeFile(RAW_OUTPUT, JSON.stringify(raw, null, 2) + '\n', 'utf8');
console.log(`BI source inventory: ${teamUrls.length} sitemap profiles, ${renderedTeams.length} rendered directory teams.`);
