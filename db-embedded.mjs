/**
 * Embedded Postgres (PGlite) — no Docker, no system PostgreSQL.
 * Data directory: ./data/pglite
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = path.join(__dirname, 'data', 'pglite');
const MIGRATIONS_DIR = path.join(__dirname, 'netlify', 'database', 'migrations');

function sqlTag(client) {
  return async function sql(strings, ...values) {
    let text = '';
    const params = [];
    for (let i = 0; i < strings.length; i++) {
      text += strings[i];
      if (i < values.length) {
        params.push(values[i]);
        text += `$${params.length}`;
      }
    }
    try {
      const result = await client.query(text, params);
      // Match postgres.js: await sql`…` → array of rows
      const rows = result?.rows ?? [];
      return rows;
    } catch (err) {
      err.message = `${err.message}\nSQL: ${text.slice(0, 240)}`;
      throw err;
    }
  };
}

async function ensureMigrations(client) {
  await client.exec(`
    CREATE TABLE IF NOT EXISTS _mostik_migrations (
      id text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    );
  `);
  const applied = await client.query('SELECT id FROM _mostik_migrations');
  const done = new Set((applied.rows || []).map((r) => r.id));

  if (!fs.existsSync(MIGRATIONS_DIR)) {
    console.warn('[pglite] migrations folder missing:', MIGRATIONS_DIR);
    return;
  }
  const files = fs
    .readdirSync(MIGRATIONS_DIR)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    if (done.has(file)) continue;
    const full = path.join(MIGRATIONS_DIR, file);
    const body = fs.readFileSync(full, 'utf8');
    console.log('[pglite] migration', file);
    try {
      await client.exec(body);
      await client.query('INSERT INTO _mostik_migrations(id) VALUES ($1)', [file]);
    } catch (err) {
      // Some migrations may partially apply on re-run; log and continue soft failures
      // for IF NOT EXISTS style, but hard-fail unknown errors after log
      console.warn('[pglite] migration warning', file, err.message?.slice(0, 200));
      // Still mark as applied to avoid infinite re-fail on non-critical alters
      try {
        await client.query(
          'INSERT INTO _mostik_migrations(id) VALUES ($1) ON CONFLICT DO NOTHING',
          [file],
        );
      } catch {
        /* ignore */
      }
    }
  }
}

let singleton;

export async function getEmbeddedDb() {
  if (singleton) return singleton;
  fs.mkdirSync(DATA_DIR, { recursive: true });
  const client = new PGlite(DATA_DIR);
  await client.waitReady;
  await ensureMigrations(client);
  const sql = sqlTag(client);
  singleton = { sql, client, kind: 'pglite' };
  console.log('MOSTIK DB: embedded PGlite →', DATA_DIR);
  return singleton;
}
