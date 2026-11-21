# Tasks

Ссылки на сценарии — имена из `specs/orders/spec.md`. Команды запускаются из корня
репозитория; Codeception работает в контейнере `php`.

## 1. Каркас (волна 0)

- [x] 1.1 Подключить автозагрузку приложения и каталог данных
      Файлы: `src/composer.json`, `src/.gitignore`, `src/data/.gitkeep`,
      `src/tests/Unit.suite.yml`, `src/tests/Unit/_bootstrap.php`
      Зависит от: нет
      Закрывает сценарии: нет (каркас)
      Проверка: `docker-compose exec php composer dump-autoload` завершается
      успешно, `docker-compose exec php vendor/bin/codecept run Unit MeTest`
      зелёный, `src/data/.gitkeep` существует, `data/orders.json` — в
      `src/.gitignore`

- [x] 1.2 Добавить `App\ApiError` с фабриками ошибок
      Файлы: `src/app/ApiError.php`
      Зависит от: 1.1
      Закрывает сценарии: «Ошибка отдаётся как JSON» (частично: форма ошибки)
      Проверка: `docker-compose exec php php -r` с подключением
      `vendor/autoload.php` проверяет, что `orderNotFound(1)` даёт статус 404 и
      код `order_not_found`, `validationFailed(['a' => 'b'])` — 422 и
      `validation_failed`, `storageFailure('/x')` — 500 и `storage_failure`

## 2. Домен заказа (волна 1, задачи 2.1–2.3 параллельны)

- [x] 2.1 Реализовать статусы и переходы заказа
      Файлы: `src/app/Order/OrderStatus.php`,
      `src/tests/Unit/Order/OrderStatusTest.php`
      Зависит от: 1.1 (autoload)
      Закрывает сценарии: «new переходит в paid», «paid переходит в shipped»,
      «new и paid переходят в cancelled», «Повторная установка текущего статуса
      разрешена», «Терминальный статус не меняется»
      Тесты: `OrderStatusTest::testNewCanBePaid`, `testPaidCanBeShipped`,
      `testNewAndPaidCanBeCancelled`, `testSameStatusIsAllowed`,
      `testTerminalStatusesCannotChange`
      Проверка: `docker-compose exec php vendor/bin/codecept run Unit OrderStatusTest`

- [x] 2.2 Реализовать валидацию входных данных заказа
      Файлы: `src/app/Order/OrderInput.php`,
      `src/tests/Unit/Order/OrderInputTest.php`
      Зависит от: 1.1, контракты `App\ApiError` из 1.2
      Закрывает сценарии: «customer_id должен быть целым больше нуля»,
      «Пустой список позиций отклоняется», «Некорректная позиция отклоняется с
      путём поля», «Некорректная стоимость позиции отклоняется», «Идентификатор
      позиции необязателен», «Переданный идентификатор позиции переопределяется»,
      «Неизвестное поле отклоняется», «Служебные поля
      игнорируются», «Слишком длинный комментарий отклоняется», «Неизвестный
      статус отклоняется», «Создание с ненулевым статусом отклоняется»
      Тесты: `OrderInputTest::testCreateNormalizesPayload`,
      `testCustomerIdMustBePositiveInteger`,
      `testCommentIsLimitedTo1000Characters`, `testItemsMustNotBeEmpty`,
      `testItemNameMustNotBeEmpty`, `testItemCountMustBePositive`,
      `testItemCostMustNotBeNegative`, `testItemIdsAreAssignedByServer`,
      `testUnknownFieldIsRejected`,
      `testServerOwnedFieldsAreIgnored`, `testCreateRejectsNonNewStatus`,
      `testUnknownStatusIsRejected`
      Проверка: `docker-compose exec php vendor/bin/codecept run Unit OrderInputTest`

- [x] 2.3 Реализовать JSON-хранилище заказов
      Файлы: `src/app/Order/OrderRepository.php`,
      `src/tests/Unit/Order/OrderRepositoryTest.php`
      Зависит от: 1.1, контракты `App\ApiError` из 1.2
      Закрывает сценарии: «Идентификатор удалённого заказа не переиспользуется»,
      «Заказ сохраняется в JSON-файл», «Файл создаётся при первой записи»,
      «Повреждённый файл не перезаписывается», «Данные видны новому экземпляру
      хранилища», «Сохранённые заказы попадают в список» (порядок по `id`),
      «Пустое хранилище отдаёт пустой массив»
      Тесты: `OrderRepositoryTest::testAllReturnsOrdersOrderedById`,
      `testAllReturnsEmptyListWhenFileMissing`, `testAddAssignsNextId`,
      `testAddDoesNotReuseIdAfterRemoval`, `testAddPersistsOrderInJsonFile`,
      `testWriteCreatesMissingFile`, `testCorruptedFileRaisesStorageFailure`,
      `testDataSurvivesNewRepositoryInstance`, `testNextIdIsPersisted`
      Проверка: `docker-compose exec php vendor/bin/codecept run Unit OrderRepositoryTest`
      (тесты пишут во временный файл в `tests/_output/`)

- [x] 2.4 Реализовать бизнес-правила заказа
      Файлы: `src/app/Order/OrderService.php`,
      `src/tests/Unit/Order/OrderServiceTest.php`
      Зависит от: реализация 2.1–2.3
      Закрывает сценарии: «Создание возвращает 201 и сохранённый заказ», «Новый
      заказ получает статус new и отметки времени», «Сумма считается по
      позициям», «Присланная клиентом сумма игнорируется», «Сумма
      пересчитывается при замене позиций», «Сумма округляется до двух знаков»,
      «Отказ валидации не меняет хранилище», «Меняются только переданные поля»,
      «Позиции заменяются целиком», «createdAt сохраняется, updatedAt
      обновляется», «new переходит в paid», «Недопустимый переход не
      сохраняется», «Заказ в статусе new удаляется», «Оплаченный заказ удалить
      нельзя», «Отменённый заказ удалить нельзя», «Несуществующий заказ
      отклоняется»
      Тесты: `OrderServiceTest::testCreateAssignsIdStatusAndTimestamps`,
      `testCreateCalculatesAmount`, `testCreateIgnoresClientAmount`,
      `testAmountIsRoundedToTwoDecimals`,
      `testCreateDoesNotWriteOnValidationFailure`,
      `testUpdateAppliesOnlyProvidedFields`, `testUpdateReplacesItemsEntirely`,
      `testUpdateKeepsCreatedAt`,
      `testUpdateRecalculatesAmountOnlyWhenItemsSent`, `testUpdateAllowsNewToPaid`,
      `testInvalidTransitionIsRejected`, `testGetUnknownOrderThrowsNotFound`,
      `testDeleteRemovesNewOrder`, `testDeleteRejectsPaidOrder`,
      `testDeleteRejectsCancelledOrder`
      Проверка: `docker-compose exec php vendor/bin/codecept run Unit OrderServiceTest`

## 3. HTTP-слой (волна 2)

- [x] 3.1 Реализовать транспорт: запрос, ответ, маршрутизатор
      Файлы: `src/app/Http/Request.php`, `src/app/Http/Response.php`,
      `src/app/Http/Router.php`
      Зависит от: 1.2
      Закрывает сценарии: «Неизвестный путь», «Нечисловой идентификатор в пути»,
      «Неподдерживаемый метод», «Ошибка отдаётся как JSON» (заголовок и форма),
      «Пустое тело запроса», «Некорректный JSON»
      Проверка: `docker-compose exec php php -r` проверяет, что
      `Router::orderId('/orders')` даёт `null`, `'/orders/5'` — `5`, а
      `'/unknown'` бросает `ApiError` с 404; `Response::error()` даёт
      `application/json`

- [x] 3.2 Реализовать обработчик HTTP и его контракт      Файлы: `src/app/Http/Application.php`,
      `src/tests/Unit/Http/ApplicationTest.php`
      Зависит от: реализация 2.4 и 3.1
      Закрывает сценарии: все сценарии требований «Список заказов», «Просмотр
      заказа», «Создание заказа», «Частичное обновление заказа», «Удаление
      заказа», «Ошибки маршрутизации и формата запроса», «Хранение заказов в
      JSON-файле» на уровне HTTP
      Тесты: `ApplicationTest::testIndexReturnsAllOrders`,
      `testIndexReturnsEmptyArray`, `testShowReturnsOrder`,
      `testShowUnknownOrderReturns404`, `testCreateReturns201`,
      `testUpdateReturns200`, `testDeleteReturns204`,
      `testDeletePaidOrderReturns409`, `testDeleteUnknownOrderReturns404`,
      `testValidationErrorReturns422`, `testInvalidTransitionReturns409`,
      `testUnknownRouteReturns404`, `testNonNumericIdReturns404`,
      `testMethodNotAllowedReturns405`, `testMalformedJsonReturns400`,
      `testEmptyBodyReturns400`, `testErrorResponseIsJson`,
      `testStorageFailureReturns500`
      Проверка: `docker-compose exec php vendor/bin/codecept run Unit Http`

## 4. Точка входа и интеграция (волна 3)

- [x] 4.1 Заменить заглушку фронт-контроллером
      Файлы: `src/public/index.php`
      Зависит от: 3.2
      Закрывает сценарии: нет (сборка), поведение уже покрыто в 3.2
      Проверка: `docker-compose exec php php public/index.php` не падает, а
      `curl -i http://localhost:8093/index.php/orders` (после 4.2) отдаёт JSON

- [x] 4.2 Направить некорневые пути в PHP
      Файлы: `docker/nginx/conf.d/site.conf`
      Зависит от: 4.1
      Закрывает сценарии: «Неизвестный путь» (через nginx)
      Проверка: после `docker-compose restart nginx`
      `curl -i http://localhost:8093/orders` отдаёт 200 и `[]`,
      `curl -i http://localhost:8093/unknown` — 404 `route_not_found`

- [x] 4.3 Добавить сквозной Acceptance-тест CRUD
      Файлы: `src/tests/Acceptance.suite.yml`,
      `src/tests/Acceptance/OrderCrudCest.php`
      Зависит от: 4.1, 4.2
      Закрывает сценарии: сквозная проверка «Создание возвращает 201 и
      сохранённый заказ» → «Меняются только переданные поля» → «Существующий
      заказ отдаётся целиком»
      Тесты: `OrderCrudCest::createUpdateAndReadOrder`
      Проверка: `make up`, `make deps`, затем
      `docker-compose exec php vendor/bin/codecept run Acceptance` зелёный

- [x] 4.4 Прогнать полный набор и проверить ручной сценарий
      Файлы: нет
      Зависит от: 4.1–4.3
      Закрывает сценарии: интеграционная проверка всех требований
      Проверка: `make test` зелёный; вручную через `curl`: создать заказ,
      перевести в `paid`, попробовать `DELETE` (409), перевести в `shipped`,
      проверить `GET /orders/{id}`

## Workflow follow-up

- Архивировать изменение после ревью артефактов и успешного `make test`.
