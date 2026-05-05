---
name: clean-architecture-placement
description: "Используй при создании новых файлов, переносе существующих и реорганизации папок по слоям: Domain, Application, Infrastructure, EFCore, Host, Shared, modules и tests."
---

# Clean Architecture Placement

## Цель
Зафиксировать целевую чистую архитектуру репозитория, чтобы:
- новый код сразу попадал в правильный слой;
- перенос существующих файлов не смешивал business logic и infrastructure;
- папки росли по feature и responsibility, а не превращались в общий dump;
- зависимости между проектами оставались направленными внутрь.

## Когда использовать
Используй этот skill, если нужно:
- создать новый файл, класс, handler, service, dto, exception или interface;
- перенести существующий файл в другой слой;
- разложить текущий legacy-код по правильным папкам;
- решить, где должен жить новый use case;
- провести ревью PR на соответствие чистой архитектуре.

## Связанные skills
- `.github/skills/mediator-commands-queries/SKILL.md`
- `.github/skills/clean-code-principles/SKILL.md`
- `.github/skills/clean-code-refactoring/SKILL.md`
- `.github/skills/clean-code-solid/SKILL.md`
- `.github/skills/code-style-conventions/SKILL.md`
- `.github/skills/controllers/SKILL.md`
- `.github/skills/unit-testing/SKILL.md`

## Целевая карта слоев

### Domain
Содержит бизнес-смысл и не знает о способе хранения или доставки данных.

Размещать здесь:
- entities и aggregate roots;
- value objects;
- domain enums и constants;
- domain exceptions;
- чистые бизнес-правила, policy, specification, calculation logic;
- repository contracts и domain-level contracts;
- domain services без зависимостей на HTTP, EF Core, RabbitMQ, Quartz и внешние SDK.

### Application
Содержит use case-ы и orchestration прикладного сценария.

Размещать здесь:
- commands, queries, handlers, validators;
- use case orchestration;
- application-specific exceptions;
- result models и dto, относящиеся к use case;
- outbound ports, которые нужны use case для вызова внешних систем;
- pipeline behaviors, относящиеся к выполнению use case.

### Infrastructure
Содержит технические адаптеры и реализации портов.

Размещать здесь:
- RabbitMQ, LDAP, 1C, IBD, TableView и другие external adapters;
- serializers, factories, retry wrappers и integration helpers;
- background jobs, которые только запускают application use case;
- consumers, producers, senders, connection services;
- реализации application/domain interfaces, не связанные напрямую с EF provider.

### EFCore
Содержит только provider-specific persistence code.

Размещать здесь:
- DbContext и entity configurations;
- migrations;
- PostgreSQL enum mapping и database-specific setup;
- EF repository implementations;
- persistence exceptions, связанные с EF Core и provider behavior.

### Host
Содержит delivery layer и composition root.

Размещать здесь:
- controllers и HTTP binding;
- app startup и DI registration;
- hosted services, связанные с жизненным циклом приложения;
- health checks;
- auth/current user adapters и web-specific services.

### Shared
Содержит только стабильные cross-cutting primitives.

Размещать здесь:
- базовые CQRS abstractions;
- shared settings и reusable cross-cutting models;
- универсальные interfaces и utilities, не принадлежащие одной feature;
- общие internal services, если они действительно используются в нескольких проектах.

Не использовать Shared как запасную папку для feature-кода.

### Tests
Тесты должны зеркалить source-структуру по слою и feature.

## Шаблон размещения

### Основной проект
```text
src/
  DebtRecalcService.Domain/
    Models/
    ValueObjects/
    Enums/
    Exceptions/
    Repositories/
    Services/

  DebtRecalcService.Application/
    UseCases/
      <Feature>/
        <CaseName>/
          <CaseName>Command.cs
          <CaseName>Query.cs
          <CaseName>CommandValidator.cs
          <CaseName>QueryValidator.cs
          <CaseName>Result.cs
          <CaseName>Dto.cs
        Ports/
          I<Feature>Port.cs
    Common/
      Behaviors/
      Exceptions/

  DebtRecalcService.Infrastructure/
    RabbitMq/
    InternalServices/
    Factories/
    Jobs/
    TableView/
    Extensions/
    Models/
    Exceptions/

  DebtRecalcService.EFCore/
    DbContexts/
    Repositories/
    Migrations/
    Exceptions/

  DebtRecalcService.Host/
    Controllers/
    Extensions/
    HostedServices/
    HealthChecks/
    Services/

  DebtRecalcService.Shared/
    CQRS/
    Settings/
    Interfaces/
    Models/
    Utils/
```

### Модули
Для каждого модуля использовать тот же шаблон слоев:

```text
modules/<ModuleName>/src/
  <ModuleName>.Domain/
  <ModuleName>.Application/
  <ModuleName>.Infrastructure/
  <ModuleName>.EFCore/
  <ModuleName>.Installer/
  <ModuleName>.Shared/
```

Если в модуле еще нет `.Application`, не продолжать класть новые use case-ы в `.Infrastructure` по инерции.
Сначала создать application-слой модуля или запланировать его введение отдельным техническим шагом.

### Тесты
```text
tests/
  DebtRecalcService.Tests/
    Application/
    Host/
    Infrastructure/
    Shared/
```

Если тестируется конкретный use case, путь в tests должен повторять путь исходника максимально близко.

## Обязательные правила
1. Новый business use case запрещено добавлять в `Infrastructure/CQRS`.
2. Legacy-папка `Infrastructure/CQRS` должна только уменьшаться в ходе рефакторинга.
3. Все новые command/query/handler/validator размещать в `Application/UseCases/...`.
4. Если файл принимает бизнес-решение, он должен жить в `Domain` или `Application`, но не в `Infrastructure`.
5. `Host` не должен импортировать request type-ы из `Infrastructure.CQRS` для новых сценариев.
6. `Host` должен общаться с use case-ами через request type-ы из `Application`.
7. `Application` не должно зависеть от `Infrastructure`, `EFCore` или `Host`.
8. `Domain` не должно зависеть от `Application`, `Infrastructure`, `EFCore` или `Host`.
9. Если use case нужен внешний вызов, interface этого порта должен жить в `Application`, а реализация в `Infrastructure`.
10. Если код зависит от `DbContext`, `ModelBuilder`, migrations или provider API, он должен жить в `EFCore`.
11. `Shared` допустимо использовать только для кода без одного явного feature-owner.
12. Перед переносом в `Shared` нужно назвать минимум два конкретных проекта-потребителя.
13. Если файл одновременно оркестрирует бизнес-сценарий и работает с transport/persistence API,
    его нужно разделить на `Application` orchestration и infrastructure adapter.
14. При переносе use case переносить вместе request, handler, validator, result/dto и локальные case-local типы.
15. Namespace должен соответствовать слою, feature и фактическому пути файла.

## Матрица размещения по типам файлов
1. Entity, ValueObject, domain enum, domain exception: `Domain`.
2. Чистый расчет долга, policy, rule, specification: `Domain`.
3. Command, Query, Handler, Validator, Result и case-local модели: `Application/UseCases/<Feature>/<CaseName>/`.
4. Interface для RabbitMQ sender, external gateway, file storage, LDAP, 1C, IBD,
   если он нужен use case: `Application/UseCases/<Feature>/Ports/` или `Application/Common/Ports/`.
5. Реализация external gateway: `Infrastructure`.
6. EF repository implementation, DbContext, migrations, enum mapping: `EFCore`.
7. Controller, API-only request/response model, hosted service wiring: `Host`.
8. Base CQRS abstractions, shared settings, reusable utility without feature-owner: `Shared`.
9. Quartz job, consumer или hosted loop с техническим запуском сценария: `Infrastructure` или `Host`,
   но бизнес-логика внутри них запрещена.
10. AutoMapper profile размещать рядом с границей, которую он обслуживает:
    application mapping в `Application`, integration/persistence mapping в `Infrastructure` или `EFCore`.

## Правила выбора папки внутри слоя
1. В `Application` использовать feature-first структуру: `UseCases/<Feature>/<CaseName>/`.
2. Не складывать handlers разных сценариев в одну общую папку без отдельной папки кейса.
3. DTO, result-model и validator, относящиеся только к одному сценарию, хранить рядом с этим сценарием.
4. Тип use case отражать в имени request type (`Command`/`Query`), а не через отдельные технические папки.
5. В `Infrastructure` группировать сначала по типу адаптера, потом по feature или направлению интеграции.
6. В `EFCore` группировать по типу persistence artifact: `DbContexts`, `Repositories`, `Migrations`, `Exceptions`.
7. В `Host` не создавать business folders, дублирующие application use case structure без необходимости.
8. Если целевой папки еще нет, создать ее в правильном слое, а не класть файл во временный root.
9. Не создавать папки `Helpers`, `Misc`, `Temp`, `CommonStuff`, если ответственность можно назвать точнее.

## Анти-паттерны
1. Новый handler в `Infrastructure/CQRS`.
Почему плохо: business flow остается смешан с integration code.
Как правильно: переносить handler в `Application/UseCases/<Feature>/<CaseName>/`.

2. Контроллер импортирует namespace из `Infrastructure.CQRS`.
Почему плохо: web-layer зависит от неправильного слоя use case-ов.
Как правильно: контроллер должен ссылаться на request type из `Application`.

3. `Shared` как мусорная корзина для DTO, exceptions и services.
Почему плохо: теряется owner кода, растет связность между проектами.
Как правильно: держать feature-код рядом с owning feature и слоем.

4. Job, consumer или sender содержит расчет и ветвление бизнес-правил.
Почему плохо: use case скрывается внутри инфраструктурной точки входа.
Как правильно: technical trigger вызывает application use case, а решение принимает application/domain.

5. Use case напрямую работает с `ModelBuilder`, provider enum mapping или EF-specific API.
Почему плохо: application связывается с persistence implementation.
Как правильно: EF-specific code оставлять в `EFCore`.

6. Перенос только одного handler без request/validator/result.
Почему плохо: feature распадается между слоями и папками.
Как правильно: переносить use case как цельный vertical slice.

## Примеры

### Do
- `CreateContractCommandHandler` -> `src/DebtRecalcService.Application/UseCases/Contracts/CreateContract/`
- `FindContractsByParametersQuery` -> `src/DebtRecalcService.Application/UseCases/Contracts/FindContractsByParameters/`
- `RabbitMqSender` -> `src/DebtRecalcService.Infrastructure/InternalServices/` или более узкая `RabbitMq/` папка
- `MapEnums` -> `src/DebtRecalcService.EFCore/`
- `ContractsController` -> `src/DebtRecalcService.Host/Controllers/`
- `ContractEventStatus` -> `src/DebtRecalcService.Domain/Enums/`

### Don't
- `PurchaseContractCommandHandler` в `src/DebtRecalcService.Infrastructure/CQRS/...`
- новый `QueryHandler` в `Infrastructure`, если он реализует прикладной сценарий
- feature-specific dto в `src/DebtRecalcService.Shared/Models/`, если у него один owner
- `IRabbitMqSender` в `Infrastructure`, если этот interface нужен application use case как outbound port

## Алгоритм принятия решений
1. Ответь на вопрос: файл принимает бизнес-решение или только работает с технологией?
2. Если файл принимает бизнес-решение, выбери `Domain` или `Application`.
3. Если файл только адаптирует EF Core, RabbitMQ, Quartz, LDAP, 1C или HTTP, выбери `Infrastructure`, `EFCore` или `Host`.
4. Определи feature-owner файла: `Contracts`, `ContractEvents`, `OperationProtocols`, `Account` и т.д.
5. Для use case выбери сценарий и создай отдельную папку `<CaseName>` внутри `UseCases/<Feature>/`.
6. Проверь, не нужен ли новый port interface в `Application` вместо прямой зависимости на infrastructure implementation.
7. Перенеси рядом все зависимые части vertical slice: request, handler, validator, dto/result, exception, tests.
8. Обнови namespace, DI registration, imports контроллеров и tests.
9. Проверь направление зависимостей: наружные слои могут зависеть от внутренних, но не наоборот.

## Проверка перед завершением
1. Новый или перемещенный файл лежит в одном понятном слое с одной причиной для существования.
2. В `Infrastructure/CQRS` не добавлено нового business-кода.
3. `Host` не ссылается на `Infrastructure.CQRS` для нового сценария.
4. `Application` и `Domain` не получили зависимость на `Infrastructure`, `EFCore` или `Host`.
5. EF-specific code остался в `EFCore`.
6. Feature-specific code не попал в `Shared` без двух явных потребителей.
7. Namespace совпадает с фактическим путем.
8. Tests зеркалят новый путь исходника.
9. Если потребовалась новая папка, она создана в правильном слое, а не как временный компромисс.