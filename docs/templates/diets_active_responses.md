# Шаблоны ответов GET /api/diets/active

## Без сессии
HTTP 401
```json
{ "error": "Требуется вход" }
```

## Нет доступа к животному
HTTP 403
```json
{ "error": "Нет доступа" }
```

## Нет активного периода рациона
HTTP 200
```json
{ "active": null, "meals": [] }
```

## Есть активный рацион (после миграции 052, Байкал)
HTTP 200
```json
{
  "active": {
    "id": "demo-diet-period-baikal",
    "diet_id": "demo-diet-baikal",
    "diet_name": "Базовый рацион Байкала",
    "animal_id": "demo-animal-baikal",
    "start_date": "2026-08-14",
    "end_date": null,
    "target_calories": 1200
  },
  "meals": [
    {
      "id": "demo-meal-baikal-breakfast",
      "title": "Завтрак",
      "time_of_day": "08:00:00",
      "day_offset": 0,
      "products": [
        { "name": "Сухой корм премиум", "quantity": "150 г", "calories": 450 }
      ]
    }
  ],
  "day_offset": 0
}
```

## Было (баг до 5.3.23)
HTTP 404
```json
{ "error": "Рацион не найден" }
```
