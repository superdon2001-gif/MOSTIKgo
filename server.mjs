/**
 * MOSTIK — pure local server (no Netlify CLI required).
 *
 *   DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
 *   node server.mjs
 *
 * Serves static files from project root + /public and routes /api/* to api.mjs.
 */
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = __dirname;
const PORT = Number(process.env.PORT || 8787);

// Minimal .env loader (no dependency)
function loadEnv(file) {
  try {
    const raw = fs.readFileSync(file, 'utf8');
    for (const line of raw.split(/\r?\n/)) {
      const s = line.trim();
      if (!s || s.startsWith('#')) continue;
      const i = s.indexOf('=');
      if (i < 0) continue;
      const k = s.slice(0, i).trim();
      let v = s.slice(i + 1).trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.slice(1, -1);
      }
      if (!(k in process.env)) process.env[k] = v;
    }
  } catch {
    /* optional */
  }
}
loadEnv(path.join(ROOT, '.env'));

// Default: embedded DB (PGlite). Set MOSTIK_LOCAL=0 + DATABASE_URL for real Postgres.
const hasUrl = !!(process.env.DATABASE_URL || process.env.NETLIFY_DATABASE_URL || process.env.NEON_DATABASE_URL);
if (process.env.MOSTIK_LOCAL !== '0' && !hasUrl) {
  process.env.MOSTIK_LOCAL = '1';
}
if (process.env.MOSTIK_LOCAL === '1') {
  console.log('[mostik] mode: embedded database (no Docker)');
} else if (!hasUrl) {
  console.warn('[mostik] DATABASE_URL is empty — set it in .env or use MOSTIK_LOCAL=1');
}

const { default: apiHandler } = await import(pathToFileURL(path.join(ROOT, 'api.mjs')).href);

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.webmanifest': 'application/manifest+json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json',
  '.txt': 'text/plain; charset=utf-8',
};

function safeJoin(root, urlPath) {
  const decoded = decodeURIComponent((urlPath || '/').split('?')[0]);
  const cleaned = path.normalize(decoded).replace(/^(\.\.[/\\])+/, '');
  const full = path.join(root, cleaned);
  if (!full.startsWith(root)) return null;
  return full;
}

function sendFile(res, filePath) {
  if (!filePath || !fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Not found');
    return;
  }
  const ext = path.extname(filePath).toLowerCase();
  const type = MIME[ext] || 'application/octet-stream';
  res.writeHead(200, { 'content-type': type, 'cache-control': 'no-cache' });
  fs.createReadStream(filePath).pipe(res);
}

async function handleApi(req, res, url) {
  const headers = new Headers();
  for (const [k, v] of Object.entries(req.headers)) {
    if (v == null) continue;
    if (Array.isArray(v)) v.forEach((x) => headers.append(k, x));
    else headers.set(k, v);
  }
  // Local cookie path convenience
  if (!headers.has('x-forwarded-for')) {
    headers.set('x-forwarded-for', req.socket.remoteAddress || '127.0.0.1');
  }

  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const bodyBuf = Buffer.concat(chunks);
  const method = req.method || 'GET';
  const init = { method, headers };
  if (method !== 'GET' && method !== 'HEAD' && bodyBuf.length) {
    init.body = bodyBuf;
  }

  const requestUrl = `http://127.0.0.1:${PORT}${url.pathname}${url.search || ''}`;
  const request = new Request(requestUrl, init);

  let response;
  try {
    response = await apiHandler(request);
  } catch (err) {
    console.error('[api]', err);
    res.writeHead(500, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ error: err?.message || 'Internal error' }));
    return;
  }

  if (!response) {
    res.writeHead(204);
    res.end();
    return;
  }

  const outHeaders = {};
  response.headers.forEach((value, key) => {
    // Node requires set-cookie as array sometimes — getSetCookie if available
    if (key.toLowerCase() === 'set-cookie') return;
    outHeaders[key] = value;
  });
  if (typeof response.headers.getSetCookie === 'function') {
    const cookies = response.headers.getSetCookie();
    if (cookies?.length) outHeaders['set-cookie'] = cookies;
  } else {
    const sc = response.headers.get('set-cookie');
    if (sc) outHeaders['set-cookie'] = sc;
  }

  // Soften Secure cookie on plain http localhost so session works
  if (outHeaders['set-cookie']) {
    const fix = (c) =>
      String(c)
        .replace(/;\s*Secure/gi, '')
        .replace(/;\s*SameSite=None/gi, '; SameSite=Lax');
    if (Array.isArray(outHeaders['set-cookie'])) {
      outHeaders['set-cookie'] = outHeaders['set-cookie'].map(fix);
    } else {
      outHeaders['set-cookie'] = fix(outHeaders['set-cookie']);
    }
  }

  const buf = Buffer.from(await response.arrayBuffer());
  res.writeHead(response.status || 200, outHeaders);
  res.end(buf);
}

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url || '/', `http://127.0.0.1:${PORT}`);
    if (url.pathname === '/api' || url.pathname.startsWith('/api/')) {
      await handleApi(req, res, url);
      return;
    }

    // static: prefer exact file, then public/, then SPA index
    let filePath = safeJoin(ROOT, url.pathname === '/' ? '/index.html' : url.pathname);
    if (filePath && fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }
    if (!filePath || !fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
      const pub = safeJoin(path.join(ROOT, 'public'), url.pathname);
      if (pub && fs.existsSync(pub) && fs.statSync(pub).isFile()) {
        sendFile(res, pub);
        return;
      }
      // SPA fallback for client routes
      if (!url.pathname.startsWith('/api')) {
        const idx = path.join(ROOT, 'index.html');
        const pidx = path.join(ROOT, 'public', 'index.html');
        if (fs.existsSync(idx)) {
          sendFile(res, idx);
          return;
        }
        if (fs.existsSync(pidx)) {
          sendFile(res, pidx);
          return;
        }
      }
      res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('Not found');
      return;
    }
    sendFile(res, filePath);
  } catch (err) {
    console.error(err);
    res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Server error');
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log('  MOSTIK local (без Netlify)');
  console.log(`  → http://127.0.0.1:${PORT}`);
  console.log(`  → http://127.0.0.1:${PORT}/api/health`);
  console.log('');
});
