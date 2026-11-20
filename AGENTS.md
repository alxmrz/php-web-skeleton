# AGENTS.md

Minimal PHP web skeleton: nginx + PHP 8.1-FPM + PostgreSQL 13.3 via Docker Compose. No framework, tests, lint, CI, or committed `composer.json`. Do not invent test/lint commands — there are none.

## Dev commands (Makefile is the source of truth)

- `make up` — start stack (`docker-compose up -d --remove-orphans`)
- `make deps` — `composer install` inside the `php` container (fails until `src/composer.json` exists)
- `make shell-php` — bash in the `php` container
- `make rebuild` — `docker-compose build --no-cache`; needed after editing `docker/php/Dockerfile`
- App: http://localhost:80 (README). nginx `server_name` is `skeleton.local`, but the default server answers on localhost without a hosts entry.

## Layout / wiring

- `src/` is bind-mounted to `/app` in both `php` and `nginx`; PHP working dir is `/app`.
- nginx docroot is `/app/public`, so the web entrypoint is `src/public/index.php`.
- `composer.json` belongs at `src/composer.json` (= `/app`), with vendor at `src/vendor`. Composer is preinstalled in the image at `/usr/local/bin/composer`.
- PostgreSQL service `db`: database/user/password all `skeleton`, host port `5432`.

## Gotchas

- `src/.gitignore` ignores `vendor/`; root `.gitignore` ignores only `.idea`.
- Xdebug is installed with `start_with_request=yes` (always on) and slows every request. `client_host` is `host.docker.internal`, mapped on Linux via `extra_hosts` in `docker-compose.yml`.
- nginx logs are bind-mounted from `docker/nginx/logs/` (gitignored content).
