---
name: domain-entity-addition
description: "Используй при добавлении новой доменной сущности в основной контекст приложения: placement в Domain, naming, repository contract, EFCore реализация, MainContext и конфигурация сущности."
---

# Domain Entity Addition

## Цель
Зафиксировать единый способ добавления новой доменной сущности в основной контекст приложения, чтобы:
- сущность сразу попадала в правильный слой;
- naming был предсказуемым и консистентным;
- persistence wiring не оставлял мертвых конфигураций и незарегистрированных зависимостей;
- новая сущность была доступна через Domain repository contract и EFCore implementation;
- изменения не ломали startup, миграции и использование `IMainContext`.

## Когда использовать
Используй этот skill, если нужно:
- добавить новую сущность в `src/DebtRecalcService.Domain`;
- подключить сущность к `IMainContext` и `MainContext`;
- создать `I<Entity>Repository` в Domain и реализацию в EFCore;
- добавить EF Core configuration для новой сущности;
- провести ревью PR, в котором появляется новая таблица или новый persisted aggregate в основном контексте приложения.

Этот skill относится к основному приложению и `MainContext`.
Если сущность принадлежит модулю, ее нужно добавлять в Domain/EFCore/DbContext конкретного модуля, а не в корневой `MainContext`.

## Связанные skills
- `.github/skills/clean-architecture-placement/SKILL.md`
- `.github/skills/clean-code-naming/SKILL.md`
- `.github/instructions/shared-code-style-conventions.instructions.md`
- `.github/instructions/shared-summary.instructions.md`

## Обязательные правила
1. Новую persisted-сущность добавлять в Domain, а не в `Infrastructure`, `EFCore`, `Host` или `Shared`.
2. Сущность размещать в подходящей папке внутри `src/DebtRecalcService.Domain/Models/`.
3. Если для сущности уже задано имя, использовать его без самовольного переименования.
4. Если имя не задано, выбирать доменное имя в единственном числе без технического шума и временных суффиксов.
5. Интерфейс репозитория называть по шаблону `I<Entity>Repository` и размещать в `src/DebtRecalcService.Domain/Repositories/Interfaces/`.
6. Реализацию репозитория называть по шаблону `<Entity>Repository` и размещать в `src/DebtRecalcService.EFCore/Repositories/`.
7. Repository contract должен наследоваться от `IBaseRepository<TEntity, TKey>`.
8. EFCore-реализация должна наследоваться от `BaseRepository<TEntity, TKey>` и работать через `IMainContext`.
9. Контракт репозитория не должен возвращать `DbSet`, `IQueryable`, EF-specific типы и provider-specific детали.
10. Если сущность хранится в основном контексте, нужно добавить `DbSet<TEntity>` и в `IMainContext`, и в `MainContext`.
11. Для новой сущности обязательно создать отдельный configuration class в `src/DebtRecalcService.EFCore/DbContexts/Configurations/`.
12. Configuration class должен называться по шаблону `<Entity>Configuration` и реализовывать `IEntityTypeConfiguration<TEntity>`.
13. Одного файла конфигурации недостаточно: его обязательно нужно подключить в `MainContext.OnModelCreating` через `builder.ApplyConfiguration(new <Entity>Configuration())`.
14. Если у сущности есть связи, их нужно настроить явно через fluent configuration и синхронно обновить навигации на обеих сторонах, когда это требуется моделью.
15. Если сущность использует таблицу или колонки с нестандартными именами, нужно явно задать mapping, а не полагаться на случайное совпадение конвенций.
16. Если новая сущность меняет схему основной базы, после wiring нужно создать migration для `MainContext`.
17. Если репозиторий должен резолвиться через DI, нужно либо добавить явную регистрацию, либо проверить, что существующая конвенция регистрации действительно подхватывает новый тип.
18. Добавление новой сущности считается незавершенным, если код компилируется, но репозиторий или конфигурация не используются приложением на старте.

## Что именно нужно создать
### Минимальный набор артефактов
1. Entity class в Domain.
2. `I<Entity>Repository` в Domain.
3. `DbSet<TEntity>` в `IMainContext`.
4. `DbSet<TEntity>` в `MainContext`.
5. `<Entity>Configuration` в EFCore.
6. `builder.ApplyConfiguration(new <Entity>Configuration())` в `MainContext.OnModelCreating`.
7. `<Entity>Repository` в EFCore.
8. DI wiring или подтверждение, что текущий composition root уже подхватывает репозиторий автоматически.

### Обычные целевые пути
```text
src/
  DebtRecalcService.Domain/
    Models/
      <Entity>.cs
    Repositories/
      Interfaces/
        I<Entity>Repository.cs

  DebtRecalcService.EFCore/
    DbContexts/
      Configurations/
        <Entity>Configuration.cs
      MainContext.cs
    Repositories/
      <Entity>Repository.cs
```

## Правила именования
1. Название сущности должно отражать бизнес-понятие, а не способ хранения или интеграцию.
2. Для класса сущности использовать единственное число: `Contract`, `RetryContractJob`, `OperationProtocol`.
3. Для `DbSet` использовать множественное число, принятое в текущем контексте: `Contracts`, `RetryContractJobs`, `OperationProtocols`.
4. Не использовать имена вроде `Entity`, `Data`, `Model`, `Temp`, `New`, если они не являются частью доменного термина.
5. Имя таблицы, колонок и внешних ключей должно быть консистентным с уже существующей схемой и snake_case naming strategy.

## Рекомендуемые практики
1. Перед созданием сущности проверить соседние модели и использовать тот же базовый тип, что и в owning контексте.
2. Сразу определить ключ сущности и его тип, чтобы не переделывать repository contract и migration позже.
3. Если у сущности есть значения по умолчанию, согласовать domain default и database default между моделью и configuration.
4. Методы репозитория называть по бизнес-смыслу, а не по технике выполнения запроса.
5. Для async-методов репозитория пробрасывать `CancellationToken`, если операция может быть отменена.
6. Для сложных связей или ограничений добавлять индексы, foreign keys и required/optional настройки явно.
7. Если сущность используется в startup, hosted service или background processor, отдельно проверить runtime resolution репозитория.
8. Если рядом используются XML summary, поддерживать тот же уровень документирования в новой сущности и репозитории.
9. После добавления persisted-сущности выполнять хотя бы одну быструю проверку: targeted build, startup validation или focused test.

## Анти-паттерны
1. Сущность добавлена только в `Domain/Models`, но отсутствует в `IMainContext` и `MainContext`.
Почему плохо: код компилируется частично, но EF Core не знает о сущности как о части основного контекста.

2. Создан `<Entity>Configuration`, но он не зарегистрирован через `ApplyConfiguration`.
Почему плохо: файл существует, но mapping фактически не применяется.

3. `I<Entity>Repository` содержит `IQueryable`, `DbContext`, `Include`, SQL или другие EF-specific детали.
Почему плохо: domain contract протекает инфраструктурой и перестает быть стабильной границей.

4. Реализация репозитория создана в `Infrastructure` вместо `EFCore`.
Почему плохо: provider-specific persistence code смешивается с остальной инфраструктурой и ломает архитектурную границу.

5. Добавлена конфигурация сущности, но не создана migration после изменения схемы.
Почему плохо: приложение и база расходятся по контракту хранения.

6. Репозиторий используется сервисами, но не зарегистрирован и не подхватывается DI.
Почему плохо: ошибка проявляется только на runtime при старте или первом резолве зависимости.

7. Сущность названа по технической роли (`TableRecord`, `ContractEntityModel`) вместо доменного смысла.
Почему плохо: теряется язык домена и усложняется чтение соседнего кода.

## Примеры

### Do
```text
Добавить RetryContractJob:
- Domain/Models/RetryContractJob.cs
- Domain/Repositories/Interfaces/IRetryContractJobRepository.cs
- Domain/DbContexts/Interfaces/IMainContext.cs -> DbSet<RetryContractJob>
- EFCore/DbContexts/MainContext.cs -> DbSet<RetryContractJob>
- EFCore/DbContexts/MainContext.cs -> ApplyConfiguration(new RetryContractJobConfiguration())
- EFCore/DbContexts/Configurations/RetryContractJobConfiguration.cs
- EFCore/Repositories/RetryContractJobRepository.cs
- Composition root -> проверить регистрацию репозитория
```

### Don't
```text
Добавить только Domain-модель и сразу использовать ее в коде,
не создав configuration, repository contract, DbSet и wiring в MainContext.
```

## Алгоритм принятия решений
1. Убедись, что сущность действительно принадлежит основному домену и должна жить в `MainContext`.
2. Определи доменное имя сущности и целевой тип ключа.
3. Создай entity class в правильной папке `Domain/Models`.
4. Создай `I<Entity>Repository` в Domain и определи только domain-level операции.
5. Добавь `DbSet<TEntity>` в `IMainContext`.
6. Добавь `DbSet<TEntity>` в `MainContext`.
7. Создай `<Entity>Configuration` и опиши table mapping, keys, relations, indexes, defaults и required fields.
8. Зарегистрируй конфигурацию через `ApplyConfiguration` в `MainContext.OnModelCreating`.
9. Создай `<Entity>Repository` в EFCore на базе `BaseRepository<TEntity, TKey>`.
10. Проверь composition root и регистрацию нового репозитория.
11. Если схема изменилась, создай migration.
12. Выполни быструю валидацию: build, startup check или targeted test.

## Проверка перед завершением
1. Сущность лежит в Domain и названа по доменному смыслу.
2. Создан `I<Entity>Repository` в Domain.
3. Создан `<Entity>Repository` в EFCore.
4. `DbSet<TEntity>` добавлен в `IMainContext`.
5. `DbSet<TEntity>` добавлен в `MainContext`.
6. Создан `<Entity>Configuration`.
7. Конфигурация зарегистрирована в `MainContext.OnModelCreating`.
8. Связи, индексы и ограничения описаны явно там, где это важно для схемы.
9. Репозиторий резолвится через текущий DI-механизм.
10. Migration создана, если менялась схема БД.
11. Выполнена хотя бы одна исполнимая проверка результата.