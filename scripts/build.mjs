/**
 * Netlify build step (npm run build).
 *
 * 1. Copies the front-end sources from the project root into public/ so the deployed
 *    copy can never drift from the source (it did before: public/ was stuck on v5.3.20).
 * 2. Checks that everything the service worker pre-caches really exists in public/.
 * 3. Checks that the Netlify functions and migrations are in place.
 *
 * No dependencies. Fails the build with a clear message instead of publishing a broken site.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const PUBLIC = path.join(ROOT, 'public');
const errors = [];

for (const f of ['app.js', 'app.css', 'sw.js']) {
  const src = path.join(ROOT, f);
  if (!fs.existsSync(src)) { errors.push(`нет исходного файла ${f} в корне проекта`); continue; }
  fs.copyFileSync(src, path.join(PUBLIC, f));
  console.log(`[build] ${f} -> public/${f}`);
}

for (const f of ['index.html', 'offline.html', 'manifest.webmanifest']) {
  if (!fs.existsSync(path.join(PUBLIC, f))) errors.push(`нет public/${f}`);
}

// Everything listed in STATIC of the service worker must exist, otherwise cache.addAll() fails
// and the PWA does not install.
const sw = fs.readFileSync(path.join(PUBLIC, 'sw.js'), 'utf8');
const staticBlock = sw.match(/const STATIC = \[([\s\S]*?)\];/);
if (!staticBlock) {
  errors.push('в sw.js не найден список STATIC');
} else {
  for (const m of staticBlock[1].matchAll(/'([^']+)'/g)) {
    const url = m[1];
    if (url === '/') continue;
    if (!fs.existsSync(path.join(PUBLIC, url.replace(/^\//, '')))) errors.push(`sw.js кэширует ${url}, но файла нет в public/`);
  }
}

for (const f of ['netlify/functions/api.mjs', 'netlify/functions/health.mjs']) {
  if (!fs.existsSync(path.join(ROOT, f))) errors.push(`нет ${f}`);
}
const migDir = path.join(ROOT, 'netlify', 'database', 'migrations');
const migrations = fs.existsSync(migDir) ? fs.readdirSync(migDir).filter((f) => f.endsWith('.sql')) : [];
if (!migrations.length) errors.push('нет миграций в netlify/database/migrations');

if (errors.length) {
  console.error('\n[build] ОШИБКА:\n - ' + errors.join('\n - '));
  process.exit(1);
}
console.log(`[build] OK: public/ готов, миграций: ${migrations.length}`);
