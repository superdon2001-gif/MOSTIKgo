MOSTIK patch v5.3.24 — надёжный Logout
======================================

Содержимое
----------
app.js                          — клиент (doLogout + credentials + ?logout=1)
api.mjs                         — зеркало корня API
netlify/functions/api.mjs       — Netlify Function (тот же код)
package.json                    — version 5.3.24
PATCH_NOTES_v5.3.24.txt
README_INSTALL.txt

Установка
---------
1. Из корня репозитория MOSTIK:

   cp app.js                    <repo>/app.js
   cp api.mjs                   <repo>/api.mjs
   cp netlify/functions/api.mjs <repo>/netlify/functions/api.mjs
   cp package.json              <repo>/package.json

   (в этом архиве netlify/functions/api.mjs лежит как
    netlify/functions/api.mjs после распаковки — см. структуру ниже)

2. Commit + push:

   git add app.js api.mjs netlify/functions/api.mjs package.json
   git commit -m "fix(auth): reliable logout (v5.3.24)"
   git push

3. После деплоя:

   - Открыть https://mostikik.netlify.app
   - Войти любым demo-* / demo123
   - «Выйти» → должен появиться экран входа
   - F5 → остаётесь на экране входа
   - GET /api/health → {"version":"5.3.24",...}

Структура архива после распаковки
---------------------------------
MOSTIK_patch_v5.3.24/
  app.js
  api.mjs
  package.json
  PATCH_NOTES_v5.3.24.txt
  README_INSTALL.txt
  netlify/
    functions/
      api.mjs
