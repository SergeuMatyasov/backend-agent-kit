---
name: integration-testing
description: "Используй при создании и обновлении integration tests: реальная БД и инфраструктура, изоляция окружения, migrations, reset state и проверки сквозного поведения."
---

# Integration Testing

## Цель

Писать integration tests, которые:
- проверяют реальные границы системы, а не их моки;
- выявляют дефекты wiring, SQL, migrations, транзакций и provider-specific поведения;
- воспроизводятся одинаково на локальной машине и в CI;
- не загрязняют состояние других тестов;
- остаются достаточно быстрыми и диагностичными.

---

## Когда использовать

Используй этот skill, если нужно:
- писать тесты для `DbContext`, EF Core repositories, migrations и database constraints;
- проверять `MainContext` pipeline с реальной БД;
- тестировать raw SQL, concurrency, locking, lease-механику и transaction boundaries;
- проверять несколько слоев сразу внутри одного процесса приложения;
- поднимать PostgreSQL или другой реальный инфраструктурный компонент для тестового сценария;
- писать сквозные smoke tests по business flow после unit stage.

Не используй этот skill как основной, если задача ограничивается:
- pure unit tests с моками и in-memory doubles;
- тестами одного метода без реальной инфраструктуры;
- snapshot/assertion тестами без интеграционной границы.

---

## Связанные skills
- `.github/skills/unit-testing/SKILL.md`
- `.github/skills/clean-architecture-placement/SKILL.md`
- `.github/instructions/shared-code-style-conventions.instructions.md`

---

## Обязательные правила

### 1. Интеграционные тесты размещать в отдельном test project

Если тест требует реальную БД, container, migrations, сеть, host wiring или заметно медленнее unit tests,
он должен жить в отдельном integration-test project.

Для этого репозитория базовое размещение:
- `tests/DebtRecalcService.IntegrationTests/`

Это нужно, чтобы:
- быстрый unit run не смешивался с тяжелыми integration tests;
- зависимости и fixture infrastructure были изолированы;
- CI мог запускать unit и integration stage отдельно.

### 2. Для каждого нового теста добавлять XML `summary` на русском

Правило такое же, как в unit-тестах:
- `summary` должен описывать проверяемое поведение;
- быть кратким и конкретным;
- быть понятным без чтения тела теста.

### 3. Проверять реальную интеграционную границу, а не ее имитацию

Если тест заявлен как integration test для репозитория, `DbContext` или migration behavior,
нельзя подменять целевую границу `InMemory`-провайдером или моками.

Примеры:
- `ContractFinancialStateSyncRepository` проверять только на реальном PostgreSQL;
- migrations проверять через реальное применение migrations;
- `MainContext` pipeline проверять через настоящий EF Core `SaveChanges`.

### 4. Для PostgreSQL использовать реальный изолированный инстанс

Предпочтительно:
- `Testcontainers.PostgreSql`

Допустимо:
- выделенная тестовая БД, если это осознанный CI/local contract.

Недопустимо:
- завязывать integration tests на случайную локальную dev-базу;
- использовать shared preprod/staging БД;
- ожидать, что разработчик вручную поднимет БД без явного контракта тестового проекта.

### 5. Применять migrations, а не `EnsureCreated`

Если тест проверяет persistence behavior приложения, schema должна подниматься так же,
как в production-пути, то есть через migrations.

Используй:
- `Database.Migrate()`

Не используй:
- `EnsureCreated()`, если тест затрагивает migrations, constraints, indexes, enum conversion или raw SQL.

### 6. Состояние БД должно очищаться между тестами

После каждого теста или перед каждым тестом нужно возвращать БД в чистое состояние.

Предпочтительно:
- `Respawn` для reset данных;
- либо пересоздание отдельной БД/schema на тестовый класс или fixture.

Недопустимо:
- зависеть от порядка выполнения тестов;
- оставлять данные одного теста для другого;
- использовать один общий mutable dataset без reset.

### 7. Seed-данные должны быть минимальными и детерминированными

Используй:
- фиксированные `Guid`;
- фиксированные даты и числа;
- только те сущности, которые нужны конкретному сценарию.

Не используй:
- случайные значения без необходимости;
- громоздкие общие seed-наборы, если тесту нужен один контракт и одна sync-запись.

### 8. Один integration test должен покрывать один сценарий одной границы

Тест может проходить через несколько слоев,
но у него должен быть один основной вопрос.

Хорошо:
- claim возвращает только stale `InProgress` и `Pending` записи;
- `SaveChanges` создает sync-запись в той же транзакции;
- migration создает partial index.

Плохо:
- один тест одновременно проверяет migration, claim ordering, retry flow и manual requeue.

### 9. Проверять наблюдаемое поведение на границе

Для integration tests приоритетны проверки:
- записей в БД;
- статусов и полей сущности после commit;
- ограничений и индексов в schema;
- реального rollback;
- SQL-level concurrency outcome;
- корректного wire-up сервисов и DI.

Не нужно проверять внутренние детали реализации,
если они не проявляются на интеграционной границе.

### 10. Concurrency-сценарии запускать на отдельных `DbContext` и соединениях

Если тест проверяет `FOR UPDATE SKIP LOCKED`, lease ownership или race-condition behavior,
нужно использовать отдельные `DbContext`/connection instances.

Недостаточно:
- гонять два действия на одном и том же `DbContext`.

### 11. `CancellationToken` пробрасывать и в integration tests, если он часть контракта

Если публичный async API принимает `CancellationToken`,
integration test должен передавать его дальше по цепочке так же,
как это делает production code.

### 12. Логи и тексты ошибок в integration helpers тоже должны быть на английском

Если в fixture, host bootstrap или custom test helper появляются сообщения ошибок,
они должны соответствовать общим repo-conventions.

---

## Рекомендуемые практики

### 1. Использовать shared fixture для дорогой инфраструктуры

Хороший pattern:
- один PostgreSQL container на test collection или test assembly;
- reset данных между тестами;
- минимальный bootstrap на каждый тест.

### 2. Разделять инфраструктурный bootstrap и сами тесты

Выносить в `Common`:
- container fixture;
- database reset helper;
- `DbContext` factory;
- seed builders;
- helpers для применения migrations.

### 3. Держать integration tests зеркальными к source-структуре

Рекомендуемая структура:
- `EFCore/Repositories/...`
- `EFCore/DbContexts/...`
- `Flow/...`
- `Common/Fixtures/...`
- `Common/Database/...`

### 4. Для schema assertions использовать системные таблицы и metadata запросы

Если нужно проверить index, constraint или column type,
лучше опрашивать PostgreSQL metadata,
а не делать косвенные предположения через поведение EF Core.

### 5. Для smoke tests подменять только внешние границы, не входящие в цель теста

Например:
- если проверяется sync flow до публикации, допустим test double publisher;
- если проверяется repository SQL, publisher и host вообще не нужны.

### 6. Писать тесты так, чтобы падение сразу указывало на проблемный слой

Предпочтительно:
- отдельные asserts на schema;
- отдельные tests на repository claim/finalize;
- отдельные smoke tests на полный flow.

---

## Анти-паттерны

### 1. Integration tests на `UseInMemoryDatabase`

Почему плохо:
- не проверяются raw SQL, migrations, indexes, constraints и provider behavior.

Как правильно:
- использовать реальный PostgreSQL.

### 2. Общая тестовая БД без reset

Почему плохо:
- тесты становятся order-dependent и flaky.

Как правильно:
- `Respawn` или пересоздание БД/schema.

### 3. Один большой end-to-end тест вместо набора направленных integration tests

Почему плохо:
- тяжело локализовать причину падения;
- растет стоимость сопровождения.

Как правильно:
- разделять repository, pipeline, schema и smoke tests.

### 4. Мок целевого репозитория в integration test репозитория

Почему плохо:
- тест перестает быть integration test.

Как правильно:
- поднимать реальный `MainContext` и PostgreSQL.

### 5. Проверка только happy path

Почему плохо:
- integration defects часто живут именно в negative/concurrency paths.

Как правильно:
- обязательно покрывать stale lease, wrong lease token, retry limit, rollback и schema mismatch scenarios.

---

## Рекомендуемый стек для этого репозитория

- `xUnit`
- `FluentAssertions`
- `Testcontainers.PostgreSql`
- `Respawn`
- `Npgsql`

Дополнительно подключать только по реальной необходимости:
- `Microsoft.AspNetCore.Mvc.Testing` для host-level HTTP integration tests;
- specialized test doubles для внешних транспортов, не являющихся целью текущего теста.

---

## Алгоритм принятия решений

1. Определи интеграционную границу теста.
2. Выбери минимальный реальный инфраструктурный компонент, который нужен для проверки этой границы.
3. Подними isolated environment через fixture/container.
4. Примени migrations и очисти состояние БД.
5. Засей только минимальный набор данных.
6. Выполни один сценарий.
7. Проверь только наблюдаемое поведение на нужной границе.
8. Убедись, что тест не зависит от порядка запуска и внешней локальной среды.

---

## Проверка перед завершением

1. Тест находится в отдельном integration-test project.
2. Проверяемая граница не замокана и не заменена `InMemory`-провайдером.
3. PostgreSQL поднимается изолированно или явно описан test contract окружения.
4. Schema создается через migrations.
5. Состояние БД очищается между тестами.
6. Seed-данные минимальны и детерминированы.
7. Каждый тест покрывает один сценарий.
8. Падение теста указывает на конкретную интеграционную проблему.
9. В новых тестах есть XML `summary` на русском.
10. Нет лишних зависимостей и broad end-to-end сценариев там, где достаточно более узкого integration test.