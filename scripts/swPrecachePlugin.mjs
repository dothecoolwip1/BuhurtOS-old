import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

/**
 * Injects the built asset list into sw.js so every lazily loaded route (including the
 * operations pages) is available offline after the first visit, and so each deploy gets
 * its own cache name and old caches are dropped on activation.
 */
export default function swPrecachePlugin() {
  let outDir = 'dist';
  return {
    name: 'buhurtos-sw-precache',
    apply: 'build',
    configResolved(config) {
      outDir = config.build.outDir;
    },
    closeBundle() {
      const dir = path.resolve(outDir);
      const swPath = path.join(dir, 'sw.js');
      const assetsDir = path.join(dir, 'assets');
      if (!fs.existsSync(swPath) || !fs.existsSync(assetsDir)) return;
      const list = fs.readdirSync(assetsDir).filter(file => /\.(js|css)$/.test(file)).sort().map(file => 'assets/' + file);
      const buildId = crypto.createHash('sha256').update(list.join('|')).digest('hex').slice(0, 10);
      const source = fs.readFileSync(swPath, 'utf8')
        .replace('const PRECACHE_ASSETS = [];', 'const PRECACHE_ASSETS = ' + JSON.stringify(list) + ';')
        .replace("const BUILD_ID = 'dev';", "const BUILD_ID = '" + buildId + "';");
      fs.writeFileSync(swPath, source);
    }
  };
}
