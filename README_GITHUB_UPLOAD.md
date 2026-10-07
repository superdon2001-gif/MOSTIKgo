# MOSTIK — PATCH 1, 2, 4

Этот пакет содержит только файлы, изменённые/добавленные патчами №1, №2 и №4.

## Вариант 1 — GitHub Desktop / Git

1. Распакуйте архив.
2. Откройте папку существующего репозитория MOSTIK.
3. Скопируйте содержимое этой папки в корень репозитория с сохранением структуры каталогов.
4. Разрешите замену существующих файлов.
5. Проверьте `git status`.
6. Сделайте commit:

   `git add api.mjs app.js public/app.js netlify/functions/api.mjs netlify/database/migrations/050_demo_baikal_enrichment.sql PATCH_1_2_4.md`

   `git commit -m "Apply patches 1 2 and 4"`

7. Отправьте изменения:

   `git push`

## Вариант 2 — GitHub через браузер

На странице репозитория используйте **Add file → Upload files** и загрузите изменённые файлы в соответствующие каталоги.

Важно: не загружайте `.netlify/db` и другие локальные файлы базы данных.

## Что входит

- `api.mjs` — исправления API/данных.
- `app.js` — основной клиентский код.
- `public/app.js` — клиентский код для public-сборки.
- `netlify/functions/api.mjs` — Netlify API-функция.
- `netlify/database/migrations/050_demo_baikal_enrichment.sql` — демо-данные Байкала.
- `PATCH_1_2_4.md` — описание патча.

После загрузки на GitHub Netlify должен собрать проект из файлов репозитория согласно его текущей конфигурации.
