rebuild:
	docker-compose build --no-cache

up:
	docker-compose up -d --remove-orphans

shell-php:
	docker-compose exec php bash

deps:
	docker-compose exec php composer install