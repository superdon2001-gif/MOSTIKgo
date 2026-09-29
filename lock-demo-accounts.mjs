/**
 * Блокирует вход в демо-аккаунты (demo.*@mostik.local, пароль demo123 указан в документации,
 * поэтому на публичном сервере он никому не должен подходить).
 * Ваши собственные аккаунты не трогаются. Данные демо остаются в базе, войти в них просто нельзя.
 *
 * Запускать при ОСТАНОВЛЕННОМ сервере, из папки проекта:  node deploy/lock-demo-accounts.mjs
 * Безопасно запускать повторно.
 */
import { getEmbeddedDb } from '../db-embedded.mjs';

const db = await getEmbeddedDb(); // при первом запуске сам накатит миграции
const { client } = db;

const like = "lower(email) LIKE 'demo.%@mostik.local'";

const locked = await client.query(
  `UPDATE users SET password_hash = 'LOCKED', recovery_code_hash = NULL WHERE ${like} RETURNING id`,
);
const ids = locked.rows.map((r) => r.id);
if (ids.length) {
  await client.query('DELETE FROM sessions_auth WHERE user_id = ANY($1)', [ids]);
}
const rest = await client.query(`SELECT count(*)::int AS n FROM users WHERE NOT (${like})`);

console.log(`Демо-аккаунтов заблокировано: ${ids.length}`);
console.log(`Обычных (ваших) аккаунтов осталось: ${rest.rows[0].n}`);
await client.close();
