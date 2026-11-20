rebuild:
	docker-compose build --no-cache

up:
	docker-compose up -d --remove-orphans

shell-php:
	docker-compose exec php bash

deps:
	docker-compose exec php composer install

test:
	docker-compose exec php vendor/bin/phpunit -c phpunit.xml

cli:
	docker-compose exec php php cli/bin/tictactoe