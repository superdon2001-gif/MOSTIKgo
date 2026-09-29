import fs from 'fs'; import {JSDOM} from 'jsdom';
const src=fs.readFileSync('/home/claude/MOSTIK_web_local/app.js','utf8');
const code=src.slice(src.indexOf('/* ---------- v5.3.27'),src.indexOf('function friendlyError'));
const dom=new JSDOM('<!doctype html><body><button id="trigger">t</button><div id="app"></div></body>',{pretendToBeVisual:true});
const w=dom.window; for(const k of ['document','FormData','Event','KeyboardEvent','MouseEvent','requestAnimationFrame']) globalThis[k]=w[k];
globalThis.esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
let copied=null; globalThis.copyText=async t=>{copied=t;return true};
(0,eval)(code+';globalThis.__api={uiForm,uiPrompt,uiChoice,uiConfirm,uiAlert,uiNotify,toast,uiOpenDialog};');
const A=globalThis.__api, $=s=>document.querySelector(s), $$=s=>[...document.querySelectorAll(s)];
const tick=()=>new Promise(r=>setTimeout(r,5));
const submit=()=>$('.ui-dialog form').dispatchEvent(new w.Event('submit',{bubbles:true,cancelable:true}));
const key=k=>document.dispatchEvent(new w.KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true}));
let pass=0,fail=0; const ok=(c,m)=>{ (c?pass++:fail++); console.log((c?'PASS':'FAIL'),m); };
document.querySelector('#trigger').focus();

// confirm: title/message split, danger -> focus on Cancel, verb label
let p=A.uiConfirm('Удалить животное и все связанные записи? Это действие необратимо.'); await tick();
ok($('.ui-dialog h3').textContent==='Удалить животное и все связанные записи?','confirm: title = first sentence');
ok($('.ui-dialog-msg').textContent==='Это действие необратимо.','confirm: explanation separated');
ok($('[data-ui-ok]').textContent==='Удалить' && $('[data-ui-ok]').classList.contains('danger'),'confirm: danger button labelled by verb');
ok(document.activeElement===$('[data-ui-cancel]'),'confirm: focus on Cancel for destructive action');
ok(document.body.classList.contains('modal-open'),'body.modal-open set');
submit(); ok((await p)===true,'confirm: OK -> true'); ok(!$('.ui-dialog') && !document.body.classList.contains('modal-open'),'closed, modal-open removed');
ok(document.activeElement===$('#trigger'),'focus restored to trigger');
p=A.uiConfirm('Выйти из MOSTIK?'); await tick(); ok(document.activeElement===$('[data-ui-ok]') && !$('[data-ui-ok]').classList.contains('danger') && $('[data-ui-ok]').textContent==='Выйти','non-destructive confirm: focus on OK, label "Выйти"');
key('Escape'); ok((await p)===false,'confirm: Escape -> false');
p=A.uiConfirm('Удалить тренировку?'); await tick(); $('[data-ui-cancel]').click(); ok((await p)===false,'confirm: Cancel -> false');
p=A.uiConfirm('Удалить запись?'); await tick(); $('.ui-dialog').dispatchEvent(new w.MouseEvent('mousedown',{bubbles:true})); ok((await p)===false,'confirm: backdrop click -> false');
p=A.uiConfirm('Импортировать 12 строк?\nБудет создан новый рацион.'); await tick(); ok($('.ui-dialog h3').textContent==='Импортировать 12 строк?' && $('.ui-dialog-msg').textContent==='Будет создан новый рацион.','confirm: newline split');
key('Escape'); await p;

// prompt: required validation, trim, cancel=null, XSS
p=A.uiPrompt('Название <img src=x onerror=alert(1)>',{required:true}); await tick();
ok(!$('.ui-dialog img'),'prompt: title is HTML-escaped (no injected <img>)');
submit(); await tick(); ok(!$('.ui-dialog-err').hidden && /Заполните поле/.test($('.ui-dialog-err').textContent) && $('.ui-dialog'),'prompt: empty required -> error, dialog stays');
$('input[name=value]').value='  Шаблон  '; submit(); ok((await p)==='Шаблон','prompt: value trimmed & returned');
p=A.uiPrompt('Целевой калораж',{type:'number',min:0}); await tick(); submit(); ok((await p)==='','prompt: optional empty -> "" (like native prompt)');
p=A.uiPrompt('Х',{type:'number',min:0}); await tick(); $('input[name=value]').value='-5'; submit(); await tick(); ok(/не меньше 0/.test($('.ui-dialog-err').textContent),'prompt: number min enforced'); key('Escape'); ok((await p)===null,'prompt: Escape -> null');
p=A.uiPrompt('Заметка',{multiline:true,label:'Как прошло'}); await tick(); ok($('textarea[name=value]') && /Как прошло/.test($('.ui-dialog-card label').textContent),'prompt: multiline textarea + visible label'); key('Escape'); await p;

// form with date validation
p=A.uiForm({title:'Новый план',fields:[{name:'name',label:'Название',value:'Основной',required:true},{name:'start',label:'Начало',type:'date',value:'2026-09-29',required:true},{name:'end',label:'Окончание',type:'date'}],validate:v=>v.end&&v.end<v.start?'Дата окончания раньше даты начала':null}); await tick();
$('input[name=end]').value='2026-09-01'; submit(); await tick(); ok($('.ui-dialog-err').textContent==='Дата окончания раньше даты начала','form: custom validate blocks submit');
$('input[name=end]').value='2026-10-01'; submit(); const fv=await p; ok(fv&&fv.name==='Основной'&&fv.start==='2026-09-29'&&fv.end==='2026-10-01','form: values returned');

// choice: radio (<=4) and select (>4)
p=A.uiChoice('Статус',[['normal','Обычное'],['attention','Внимание'],['critical','Критично']],'attention'); await tick();
ok($$('input[type=radio]').length===3 && $('input[type=radio]:checked').value==='attention','choice: radios, current value preselected');
$$('input[type=radio]')[2].checked=true; submit(); ok((await p)==='critical','choice: selected value returned');
p=A.uiChoice('Шаблон',[1,2,3,4,5].map(i=>[String(i),'Т'+i]),'1'); await tick(); ok($('select[name=value]')&&$$('option').length===5,'choice: >4 options -> select'); key('Escape'); ok((await p)===null,'choice: cancel -> null');

// alert with copy: persistent
p=A.uiAlert('Код: ABC-123',{title:'Новый код восстановления',copy:'ABC-123'}); await tick(); let settled=false; p.then(()=>settled=true);
key('Escape'); await tick(); $('.ui-dialog').dispatchEvent(new w.MouseEvent('mousedown',{bubbles:true})); await tick();
ok(!settled && $('.ui-dialog'),'alert+copy: Escape and backdrop do NOT close (code can\'t be lost)');
$('[data-ui-copy]').click(); await tick(); ok(copied==='ABC-123' && $('[data-ui-copy]').textContent==='Скопировано','alert+copy: copy button works');
submit(); ok((await p)===true,'alert+copy: OK closes');
p=A.uiAlert('Откройте меню браузера…',{title:'Установка приложения'}); await tick(); key('Escape'); ok((await p)===true,'plain alert: Escape closes');

// stacked dialogs: Escape only closes topmost
let p1=A.uiConfirm('Удалить А?'), p2; await tick(); p2=A.uiConfirm('Удалить Б?'); await tick();
key('Escape'); ok((await p2)===false && $$('.ui-dialog').length===1,'stacked: Escape closes only the top dialog'); key('Escape'); await p1;

// focus trap
p=A.uiForm({title:'F',fields:[{name:'a',label:'A'}]}); await tick(); const btns=$$('.ui-dialog button'); btns[btns.length-1].focus();
const ev=new w.KeyboardEvent('keydown',{key:'Tab',bubbles:true,cancelable:true}); document.dispatchEvent(ev);
ok(ev.defaultPrevented && document.activeElement===$('input[name=a]'),'focus trap: Tab from last wraps to first'); key('Escape'); await p;

// toast
A.uiNotify('Ошибка сети','err'); A.uiNotify('Готово','ok'); A.uiNotify('Проверьте поля');
const ts=$$('.mostik-toast'); ok(ts.length===3 && ts[0].className.includes('mostik-toast-err') && ts[0].getAttribute('role')==='alert' && ts[2].className.includes('mostik-toast-warn'),'toast: kinds/roles; default = warn');
ts[1].click(); ok(true,'toast: click handler attached');
A.toast('x','error'); ok($$('.mostik-toast').pop().className.includes('mostik-toast-err'),"toast: legacy 'error' mapped to 'err'");
console.log(`\n${pass} passed, ${fail} failed`); process.exit(fail?1:0);
