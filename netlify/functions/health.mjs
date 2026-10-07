import postgres from 'postgres';

export default async () => {
  const started = Date.now();
  let dbOk = false;
  let dbError = null;
  let mode = 'none';
  try {
    const url = process.env.NETLIFY_DATABASE_URL
      || process.env.DATABASE_URL
      || process.env.NEON_DATABASE_URL
      || '';
    if (url) {
      mode = 'url';
      const sql = postgres(url, {
        ssl: /localhost|127\.0\.0\.1/.test(url) ? false : 'require',
        max: 1,
        connect_timeout: 10,
      });
      await sql`SELECT 1 as ok`;
      await sql.end({ timeout: 2 });
      dbOk = true;
    } else {
      mode = 'netlify-database';
      const { getDatabase } = await import('@netlify/database');
      const db = getDatabase();
      await db.sql`SELECT 1 as ok`;
      dbOk = true;
    }
  } catch (e) {
    dbError = String(e?.message || e);
  }
  const body = {
    ok: dbOk,
    app: 'MOSTIK',
    version: '5.3.27',
    backend: 'netlify-functions',
    db: dbOk ? 'up' : 'down',
    db_mode: mode,
    latency_ms: Date.now() - started,
    ...(dbError ? { db_error: dbError } : {}),
  };
  return Response.json(body, { status: dbOk ? 200 : 503 });
};
export const config = { path: '/api/health' };
