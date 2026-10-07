/**
 * Применяет SQL-миграции из netlify/database/migrations к Postgres (Netlify Database / Neon).
 * Уже применённые файлы пропускаются (журнал в таблице _mostik_migrations, как и в локальной версии).
 * Каждая миграция идёт одной транзакцией: при ошибке она откатывается и скрипт останавливается.
 *
 *   DATABASE_URL="postgresql://..." npm run db:migrate
 *
 * Строку подключения берите в Netlify: Project configuration -> Database (или NETLIFY_DATABASE_URL).
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import postgres from 'postgres';

const url = (process.env.DATABASE_URL || process.env.NETLIFY_DATABASE_URL || process.env.NEON_DATABASE_URL || '').trim();
if (!url) {
  console.error('Не задан DATABASE_URL (или NETLIFY_DATABASE_URL).');
  process.exit(1);
}

const dir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', 'netlify', 'database', 'migrations');
const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();

const sql = postgres(url, { ssl: /localhost|127\.0\.0\.1/.test(url) ? false : 'require', max: 1, onnotice: () => {} });
try {
  await sql`CREATE TABLE IF NOT EXISTS _mostik_migrations (id text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())`;
  const done = new Set((await sql`SELECT id FROM _mostik_migrations`).map((r) => r.id));
  let applied = 0;
  for (const file of files) {
    if (done.has(file)) continue;
    const body = fs.readFileSync(path.join(dir, file), 'utf8');
    process.stdout.write(`-> ${file} ... `);
    await sql.begin(async (tx) => {
      await tx.unsafe(body);
      await tx`INSERT INTO _mostik_migrations(id) VALUES (${file})`;
    });
    console.log('ok');
    applied++;
  }
  console.log(applied ? `Применено миграций: ${applied}` : 'Новых миграций нет, база актуальна.');
} catch (e) {
  console.log('ОШИБКА');
  console.error(e.message || e);
  process.exitCode = 1;
} finally {
  await sql.end({ timeout: 5 });
}
