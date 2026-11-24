rebuild:
	docker-compose build --no-cache

up:
	docker-compose up -d --remove-orphans

shell-php:
	docker-compose exec php bash

deps:
	docker-compose exec php composer install

test:
	docker-compose exec php vendor/bin/codecept run

test-unit:
	docker-compose exec php vendor/bin/codecept run Unit

test-acceptance:
	docker-compose exec php vendor/bin/codecept run Acceptance
