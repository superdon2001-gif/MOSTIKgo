import fs from 'fs';
const src = fs.readFileSync(new URL('./app.js', import.meta.url), 'utf8');
const a = src.indexOf('const DEL_ROW_SEL'), b = src.indexOf('/** Как alert()');
if (a < 0 || b < 0 || b < a) throw new Error('slice not found');
const code = src.slice(a, b);

let toasts = [], confirms = [], notes = [], winHandlers = {};
globalThis.window = {
  addEventListener: (t, f) => { winHandlers[t] = f; },
  removeEventListener: (t, f) => { if (winHandlers[t] === f) delete winHandlers[t]; },
};
globalThis.toast = (msg, kind, opts) => { const t = { msg, kind, opts, hidden: false }; toasts.push(t); return () => { t.hidden = true; }; };
globalThis.uiNotify = (m, k) => notes.push([m, k]);
let confirmAnswer = true;
globalThis.uiConfirm = async (m) => { confirms.push(m); return confirmAnswer; };
(0, eval)(code + ';globalThis.__t={delLabel,confirmDelete,deleteWithUndo,get pending(){return _pendingDelete}};');
const T = globalThis.__t;

const mkBtn = (label = 'Обед · 12:30') => {
  const row = { style: { display: '' }, isConnected: true, querySelector: () => label === null ? null : ({ textContent: label }) };
  return { row, closest: () => row };
};
let pass = 0, fail = 0;
const ok = (c, m) => { c ? pass++ : fail++; console.log((c ? 'PASS' : 'FAIL') + ' ' + m); };
const wait = (ms) => new Promise(r => setTimeout(r, ms));
const reset = () => { toasts = []; confirms = []; notes = []; winHandlers = {}; };

// --- naming
reset();
await T.confirmDelete(mkBtn(), 'приём пищи');
ok(confirms[0] === 'Удалить приём пищи «Обед · 12:30»?', 'confirm names the record: ' + confirms[0]);
reset();
await T.confirmDelete(mkBtn('Кто? Что?\n  тут'), 'запись');
ok(confirms[0] === 'Удалить запись «Кто Что тут»?', 'confirm strips ? and newlines from name (title split stays intact): ' + confirms[0]);
reset();
await T.confirmDelete(mkBtn('А'.repeat(90)), 'запись');
ok(/«А{57}…»\?$/.test(confirms[0]), 'long name truncated to 60 chars');
reset();
await T.confirmDelete(mkBtn(null), 'напоминание');
ok(confirms[0] === 'Удалить напоминание?', 'no title in row -> generic text');
reset();
await T.confirmDelete(mkBtn(), 'рацион', { note: 'Вместе с ним удалятся все его приёмы пищи.' });
ok(confirms[0] === 'Удалить рацион «Обед · 12:30»?\nВместе с ним удалятся все его приёмы пищи.', 'note goes on a second line');
reset();
ok(T.delLabel(mkBtn('Удалить'), 'запасное имя') === 'запасное имя', 'button caption "Удалить" is not used as a name');

// --- happy path
reset();
{
  let runs = 0, dones = 0; const btn = mkBtn();
  T.deleteWithUndo(btn, { noun: 'Приём пищи', verb: 'удалён', run: async () => { runs++; }, done: () => { dones++; }, ms: 40 });
  ok(btn.row.style.display === 'none', 'row hidden immediately');
  ok(toasts[0].msg === 'Приём пищи «Обед · 12:30» удалён' && toasts[0].opts.action.label === 'Отменить', 'toast text + Отменить: ' + toasts[0].msg);
  ok(runs === 0, 'request NOT sent yet');
  await wait(90);
  ok(runs === 1 && dones === 1, 'after timeout: request sent once, list refreshed once');
  ok(T.pending === null, 'pending slot cleared');
}
// --- undo
reset();
{
  let runs = 0, dones = 0; const btn = mkBtn();
  T.deleteWithUndo(btn, { noun: 'Наблюдение', verb: 'удалено', run: async () => { runs++; }, done: () => { dones++; }, ms: 40 });
  toasts[0].opts.action.onClick();
  ok(btn.row.style.display === '', 'undo: row shown again');
  await wait(90);
  ok(runs === 0 && dones === 0, 'undo: request never sent, no refresh');
  ok(!winHandlers.pagehide, 'undo: pagehide listener removed');
}
// --- second delete flushes the first (without refresh)
reset();
{
  const log = []; const b1 = mkBtn('Первая'), b2 = mkBtn('Вторая');
  T.deleteWithUndo(b1, { noun: 'Запись', verb: 'удалена', run: async () => { log.push('run1'); }, done: () => { log.push('done1'); }, ms: 60 });
  T.deleteWithUndo(b2, { noun: 'Запись', verb: 'удалена', run: async () => { log.push('run2'); }, done: () => { log.push('done2'); }, ms: 60 });
  await wait(5);
  ok(log.join() === 'run1', 'second delete: first request sent right away, no refresh: ' + log.join());
  ok(toasts[0].hidden === true, 'second delete: first toast hidden');
  await wait(100);
  ok(log.join() === 'run1,run2,done2', 'then second one completes with a single refresh: ' + log.join());
}
// --- error restores row
reset();
{
  let dones = 0; const btn = mkBtn();
  T.deleteWithUndo(btn, { noun: 'Запись', verb: 'удалена', run: async () => { throw new Error('Нет доступа'); }, done: () => { dones++; }, ms: 20 });
  await wait(70);
  ok(btn.row.style.display === '' && dones === 0, 'server error: row restored, no refresh');
  ok(notes.length === 1 && notes[0][0] === 'Нет доступа' && notes[0][1] === 'err', 'server error: red notice with the message');
}
// --- page closing sends the request
reset();
{
  let runs = 0, dones = 0; const btn = mkBtn();
  T.deleteWithUndo(btn, { noun: 'Запись', verb: 'удалена', run: async () => { runs++; }, done: () => { dones++; }, ms: 500 });
  ok(typeof winHandlers.pagehide === 'function', 'pagehide listener registered');
  winHandlers.pagehide();
  await wait(10);
  ok(runs === 1 && dones === 0, 'pagehide: request sent immediately, no refresh');
}
// --- user left the screen: no re-render over another view
reset();
{
  let runs = 0, dones = 0; const btn = mkBtn(); btn.row.isConnected = false;
  T.deleteWithUndo(btn, { noun: 'Запись', verb: 'удалена', run: async () => { runs++; }, done: () => { dones++; }, ms: 20 });
  await wait(60);
  ok(runs === 1 && dones === 0, 'row no longer in DOM: deleted on server, no refresh over the new screen');
}
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
