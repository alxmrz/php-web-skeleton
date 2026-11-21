# Proposal

## Why

Скелет не содержит ни одного прикладного эндпоинта: `src/public/index.php` печатает
«Hello, world». Нужен минимальный, но полноценный HTTP CRUD над заказом, чтобы на
нём можно было проверять маршрутизацию, работу с JSON и тестовую инфраструктуру
проекта до появления БД.

## What Changes

- Появляется HTTP API заказов под `/orders`:
  - `GET /orders` — список всех заказов;
  - `GET /orders/{id}` — один заказ;
  - `POST /orders` — создание;
  - `PUT /orders/{id}` — частичное обновление переданных полей;
  - `DELETE /orders/{id}` — удаление.
- Заказ описывается полями `id`, `customer_id`, `amount`, `status`, `comment`,
  `items`, `createdAt`, `updatedAt`. Позиция (`items[]`) — `id`, `name`, `count`,
  `cost`.
- `amount` не принимается от клиента: считается как сумма `count * cost` по
  позициям.
- Статус — фиксированный набор `new`, `paid`, `shipped`, `cancelled` со строгой
  цепочкой переходов: `new → paid → shipped`, `new → cancelled`, `paid → cancelled`;
  `shipped` и `cancelled` терминальны.
- Удалять разрешено только заказ в статусе `new`; оплаченный, отправленный и
  отменённый заказ удалить нельзя.
- Хранилище — JSON-файл `src/data/orders.json`, без БД и без внешних зависимостей:
  чистый PHP 8.3.
- Ошибки отдаются как `{"error": "<code>", "message": "<text>"}` с HTTP-кодом
  400/404/405/409/422.
- **BREAKING**: `src/public/index.php` перестаёт печатать `Hello, world` и
  становится фронт-контроллером API.

## Capabilities

### New Capabilities
- `orders`: HTTP CRUD заказов, жизненный цикл статуса, валидация полей и
  JSON-хранилище заказов.

### Modified Capabilities
- Нет: `openspec/specs/` пуст, изменяемых требований не существует.

## Impact

- Код: `src/public/index.php`, новый каталог `src/app/` (PSR-4 `App\`) с классами приложения,
  `src/data/orders.json` (создаётся при первом запуске, данные — данные
  приложения, а не артефакт сборки).
- Инфраструктура: без изменений в `docker-compose.yml`, `docker/nginx/conf.d/site.conf`
  и `Makefile`; маршрутизация выполняется внутри фронт-контроллера по
  `REQUEST_URI`.
- Зависимости: без новых composer-пакетов.
- Тесты: Codeception, наборы `Unit` (валидация, репозиторий, сервис) и `Acceptance`
  (`PhpBrowser` против `http://localhost:8093`).
- PostgreSQL-сервис не затрагивается.
