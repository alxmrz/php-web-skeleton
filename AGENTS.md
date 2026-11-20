# AGENTS.md

## 1. Стек проекта

- PHP 8.1-FPM, без фреймворка. Приложение — `src/`, точка входа веба — `src/public/index.php`.
- nginx как reverse proxy/веб-сервер; docroot — `/app/public`.
- PostgreSQL 13.3, сервис `db` (database/user/password: `skeleton`, host порт `5432`).
- Docker Compose (`docker-compose.yml`) + `Makefile` как источник истины по командам.
- Composer предустановлен в образе (`/usr/local/bin/composer`); зависимости и тесты — `src/composer.json`.
- Тесты — PHPUnit 9.6 (`require-dev`), линтер в проекте не настроен: не выдумывай команд тестов/линта, которых нет в `Makefile`.

## 2. Команды: запуск, сборка, тесты

### Запуск

- `make up` — поднять стек (`docker-compose up -d --remove-orphans`).
- Веб: http://localhost:80. nginx `server_name` — `skeleton.local`, но default-сервер отвечает на localhost без правки `hosts`.
- `make shell-php` — bash внутри контейнера `php`.
- `make deps` — `composer install` в контейнере `php`.
- `make cli` — запуск консольной игры в контейнере `php`
  (`docker-compose exec php php cli/bin/tictactoe`).

### Сборка

- `make rebuild` — `docker-compose build --no-cache`; нужен после правки `docker/php/Dockerfile`.

### Тесты

- Стандарт проекта — PHPUnit (`phpunit/phpunit` в `require-dev`), конфигурация
  `src/phpunit.xml`, тесты в `src/cli/tests/`. Самописные раннеры и `make test`-заглушки
  не используются.
- `make test` — весь набор в контейнере `php`
  (`docker-compose exec php vendor/bin/phpunit -c phpunit.xml`).
- Запуск в контейнере (рабочий каталог `/app`, то есть `src/`):
  `docker-compose exec php vendor/bin/phpunit -c phpunit.xml`
- Запуск одного модуля:
  `docker-compose exec php vendor/bin/phpunit -c phpunit.xml --filter BoardTest`
- Локально: `vendor/bin/phpunit -c phpunit.xml` из каталога `src/`.
- После добавления тестов обновляй этот раздел, если меняются команды запуска.

## 3. Правила

### OpenSpec / планирование

- Все правила написания артефактов (`proposal.md`, `spec.md`, `design.md`,
  `tasks.md`) — в скилле `spec-authoring` (`.opencode/skills/spec-authoring/`).
  Загружай его перед работой над спекой; здесь они намеренно не повторяются.
- `openspec/config.yaml` (`rules.*`) содержит только ссылку на этот скилл.
- Тестовый фреймворк, команды запуска и раскладка каталогов — раздел 2 выше.

### Код и изменения

- Следуй структуре, именованию и стилю окружающего кода; не удаляй и не перезаписывай чужие
  изменения, не разобравшись, что они делают.
- Цикломатическая сложность метода — не больше 2: максимум одна точка ветвления (`if`,
  тернарник, `??`, `catch`, `&&`/`||`, цикл или `match`). Если логика требует большего —
  выноси ветки в отдельные приватные методы, а не наращивай вложенность.
- Большие блоки тела метода (длинные ветки, циклы, подготовка данных) выноси в приватные
  методы с говорящими именами; публичный метод должен читаться как короткий сценарий.
- Правки в `src/` сразу видны в контейнерах (bind-mount) — пересборка не нужна. Пересборка
  нужна только для `docker/php/Dockerfile` (`make rebuild`).

## 4. Layout / wiring

- `src/` bind-mounted в `/app` в контейнерах `php` и `nginx`; рабочий каталог PHP — `/app`.
- nginx docroot — `/app/public`, веб-вход — `src/public/index.php`.
- `composer.json` живёт в `src/composer.json` (= `/app`), vendor — `src/vendor`.
- PostgreSQL: сервис `db`, БД/пользователь/пароль — `skeleton`, порт на хосте `5432`.

## 5. Gotchas

- `src/.gitignore` игнорирует `vendor/`; корневой `.gitignore` игнорирует только `.idea`.
- Xdebug установлен с `start_with_request=yes` (всегда включён) и замедляет каждый запрос.
  `client_host` — `host.docker.internal`, на Linux проброшен через `extra_hosts` в `docker-compose.yml`.
- Логи nginx bind-mount'ятся из `docker/nginx/logs/` (содержимое gitignored).
