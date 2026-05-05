---
name: infra-logic-extraction
description: "Используй при выносе framework-specific и provider-specific логики из файла в правильный технический слой через port и adapter без изменения поведения."
---

# Infra Logic Extraction

## Цель

Безопасно выносить infrastructure-specific и framework-specific логику из файла,
который должен остаться orchestration-слоем, use case-слоем или feature-specific сервисом.

Skill нужен, чтобы:
- не держать EF Core, `ChangeTracker`, `DbSet`, `EntityState`, HTTP clients, MQ clients,
  serializers и другие технические зависимости внутри orchestration-кода;
- выносить техническую реализацию за port и adapter;
- сохранять текущее поведение 1 в 1;
- делать миграцию маленькими и проверяемыми шагами.

## Когда использовать

Используй этот skill, если:
- пользователь прислал конкретный файл и попросил вынести infra-логику в правильный слой;
- класс одновременно оркестрирует сценарий и работает с EF Core, файловой системой,
  HTTP, RabbitMQ, reflection, serializer API или другим framework-specific API;
- нужно выполнить маленький migration step без большого переписывания feature;
- нужно ввести port и adapter вокруг технической зависимости;
- текущий слой `Infrastructure` является временным и постепенно должен стать `Application`.

## Связанные skills
- `.github/skills/clean-architecture-placement/SKILL.md`
- `.github/skills/migration-principles/SKILL.md`
- `.github/skills/clean-code-refactoring/SKILL.md`
- `.github/skills/clean-code-naming/SKILL.md`
- `.github/instructions/shared-code-style-conventions.instructions.md`

## Что считать infra-логикой

Считать infra-логикой любой код, который зависит от технического механизма, а не от
бизнес-смысла сценария.

Типовые признаки:
- использование `DbContext`, `DbSet`, `EntityEntry`, `EntityState`, `ChangeTracker`, `ModelBuilder`, migrations;
- прямые вызовы `HttpClient`, RabbitMQ clients, внешних SDK, файловой системы, serializer APIs;
- работа с provider-specific типами, transport-specific API и framework-specific abstraction;
- код, который можно заменить adapter-ом без изменения наблюдаемого поведения сценария.

Не считать infra-логикой:
- orchestration порядка шагов use case;
- decision-making по бизнес-правилам;
- validation, относящуюся к сценарию, а не к транспортному механизму;
- сообщения логов, retry orchestration и вызов port-а как части сценария.

## Обязательные правила

1. Начинай с конкретного присланного файла, а не с широкого обхода модуля.
2. До первой правки назови точку входа, side effects и exact block технической логики,
   который можно вынести отдельным шагом.
3. Сохраняй внешний контракт текущего файла, если пользователь явно не попросил его менять.
4. Не выноси orchestration вместе с технической реализацией. Выносить нужно только technical block.
5. Вводи port в более внутреннем слое, чем реализация adapter-а.
6. Если вызывающему коду нужна только сводка, флаг или нейтральный результат, запрещено
   протаскивать наружу framework-specific типы. Вместо этого создай summary/result model.
7. Именуй новый port и adapter по фактической ответственности, а не по текущему caller feature,
   если логика не привязана к одному feature.
8. Если extracted code не feature-specific, вынеси contract из feature-папки в более точную общую папку,
   например `InternalServices/<Responsibility>/`.
9. Если service, reader, saver, sync, adapter или другой класс выполняет только техническую логику,
   его имя, namespace и путь должны содержать только техническую ответственность.
   Запрещено оставлять в таком имени business, domain или feature-слова вроде
   `EventProcessor`, `Contracts`, `Purchase`, `Accrual`, если класс не принимает бизнес-решений.
10. Это правило распространяется не только на `EFCore`, но и на любые другие technical services
    в `Infra`, `Infrastructure` и других технических слоях.
11. `Shared` использовать только если есть минимум два конкретных независимых потребителя.
12. Если код зависит от `DbContext`, `EntityEntry`, `EntityState`, `DbSet`, `ModelBuilder`, migrations
    или provider API, целевой слой по умолчанию `EFCore`.
13. Если в текущем migration step перенос в `EFCore` создает лишнюю архитектурную связанность или
    ломает текущую сборку, допустимо временно вынести technical adapter в `Infra`, но это нужно
    осознанно зафиксировать как переходный шаг.
14. После первого substantive edit сразу выполни самую узкую доступную проверку: тест или сборку
    затронутого проекта. Если для артефакта нет исполнимой проверки, выполни diff-based проверку.
15. Не смешивай extraction technical logic с бизнес-изменениями.

## Decision Matrix

### Куда класть port

Размещать port там, где живет orchestration, которому он нужен:
- во временном `Infrastructure`, если этот проект сейчас фактически играет роль application-слоя;
- в `Application`, если use case уже находится там;
- не в `Infra` и не в `EFCore`, если caller должен зависеть от контракта inward direction.

### Куда класть implementation

1. `EFCore`
Использовать, если extracted code является persistence/provider-specific кодом и его можно
поместить туда без инверсии зависимостей.

2. `Infra`
Использовать, если extracted code является техническим adapter-ом, но текущий migration step
еще не позволяет безопасно перенести его в `EFCore`.

3. Не оставлять в feature-orchestration папке
Если логика стала общей по ответственности, запрещено держать ее в папке вида
`EventProcessor/...`, `UseCase/...` или другой feature-папке только потому, что оттуда начался перенос.

## Пошаговый алгоритм

### Шаг 1. Зафиксировать текущий orchestration boundary
Определи:
- точку входа файла;
- его входы и выходы;
- side effects;
- какие строки принимают решение, а какие только общаются с infrastructure/framework.

### Шаг 2. Найти минимальный extractable block
Выбери самый маленький блок, который:
- зависит от technical API;
- не обязан оставаться рядом с orchestration;
- можно проверить отдельно после выноса.

### Шаг 3. Спроектировать port
Создай interface по ответственности блока.

Правила:
- имя должно описывать действие или читаемую сущность;
- метод должен возвращать neutral result model, а не framework-specific тип;
- shape контракта должен быть минимальным, только для текущего caller-а.

### Шаг 4. Выбрать нейтральную result model
Если caller не должен знать про внутренние технические типы, создай summary/result model рядом с port.

Примеры:
- `DbContextPendingChangesSummary`
- `MessagePublishResult`
- `FileReadSummary`

### Шаг 5. Выбрать target layer
Определи, куда пойдет реализация:
- `EFCore`, если зависимость persistence/provider-specific;
- `Infra`, если это переходный technical adapter step;
- не `Shared`, если reusable-use case еще не доказан.

### Шаг 6. Реализовать adapter
Вынеси framework-specific код в новую реализацию.

Правила:
- adapter должен делать только technical work;
- orchestration, retry-policy selection и feature-specific logging оставлять в caller-е;
- namespace и путь должны соответствовать новой ответственности;
- если adapter не содержит business decision-making, в его имени, namespace и пути
    должны остаться только technical terms.

### Шаг 7. Подключить port обратно в caller
Заменить прямой technical code на вызов port-а.

Caller должен:
- остаться точкой orchestration;
- логировать и принимать сценарные решения как раньше;
- не знать про `EntityEntry`, `HttpResponseMessage`, MQ-specific envelopes и другие technical types.

### Шаг 8. Проверить, не осталось ли feature-specific naming мусора
После extraction перепроверь:
- не остались ли в именах слова старого caller-а;
- не лежит ли общий adapter в feature-specific папке;
- не стали ли названия двусмысленными;
- нет ли в имени, namespace и пути business/domain слов у класса,
  который делает только technical work.

### Шаг 9. Провалидировать шаг
Выполни:
- узкий test, если он есть;
- иначе узкую сборку затронутого проекта;
- иначе diff-based проверку.

### Шаг 10. Зафиксировать итог шага
После каждого такого переноса явно перечисли:
- что изменено;
- что не изменено;
- какие риски остались;
- как проверить эквивалентность поведения.

## Рекомендуемые практики

1. Сначала выноси чтение technical state, потом мутации, потом более сложные transaction-boundary blocks.
2. Предпочитай summary/result model вместо утечки framework-specific enum и entry types.
3. Делай naming более общим только после проверки, что ответственность действительно общая.
4. Если общий adapter пока имеет одного потребителя, это не запрещает вынести его из feature-папки,
   если ответственность уже очевидно не feature-specific.
5. Если перенос явно временный, прямо фиксируй следующий возможный шаг, например перенос из `Infra` в `EFCore`.
6. Если extracted class делает только техническую работу, сначала убери из его имени и пути
    слова первого consumer-а, а потом уже проверяй, нужен ли дополнительный перенос между слоями.

## Анти-паттерны

1. Вынести весь сервис целиком в `Infra`, хотя только небольшой technical block зависит от framework.
2. Оставить `EntityEntry`, `EntityState`, `HttpResponseMessage` или другие technical types в port-контракте.
3. Назвать общий adapter по имени первого caller-а, например `EventProcessorPendingChangesReader`,
   когда логика не привязана к EventProcessor.
4. Перенести общий adapter в `Shared` без подтвержденных независимых потребителей.
5. После extraction не выполнить узкую проверку и продолжить следующий перенос на том же слепке.
6. Оставить в `EFCore` или `Infra` технический сервис с business naming,
   например `EventProcessorStateDbContextSyncService`, хотя класс только синхронизирует
   сущности с `DbContext` и не знает ничего про EventProcessor.

## Примеры

### Хорошо

Сценарий:
- `EventProcessorEntitiesSaver` должен сохранить изменения и залогировать counts.
- Прямой обход `mainContext.ChangeTracker.Entries()` является technical detail.

Правильный перенос:
- оставить `EventProcessorEntitiesSaver` orchestrator-ом;
- ввести `IDbContextPendingChangesReader`;
- вернуть `DbContextPendingChangesSummary` вместо `EntityEntry[]`;
- вынести реализацию reader-а в `Infra`;
- переместить contract в `InternalServices/DbContextPendingChanges/`, если он больше не feature-specific.

Дополнительное правило naming:
- если класс в итоге только читает pending changes из `DbContext`,
  называть его `DbContextPendingChangesReader`, а не `EventProcessorPendingChangesReader`;
- если класс только синхронизирует detached entities с `DbContext`,
  называть его `DbContextEntitySynchronizationService`, а не `EventProcessorStateDbContextSyncService`.

### Плохо

Сценарий:
- переименовать reader, но оставить его в папке `EventProcessor/EntitySaver/`;
- оставить `EntityState` и `EntityEntry` в контракте;
- одновременно поменять порядок сохранения и логирования.

Почему плохо:
- ответственность остается смазанной;
- framework leakage не устранен;
- changed behavior невозможно отделить от рефакторинга.

Дополнительно плохо:
- оставить общий технический adapter в пути `EventProcessor/...` только потому,
  что первый consumer находится в EventProcessor;
- назвать EFCore-only сервис через бизнес-сценарий вместо технической ответственности.

## Шаблон запроса к Copilot

Используй этот шаблон, когда пользователь прикладывает файл и хочет такой же перенос:

```text
Примени skill infra-logic-extraction к этому файлу.
Найди минимальный framework-specific или provider-specific блок,
вынеси его через port и adapter в правильный слой,
сохрани текущее поведение,
не меняй внешний контракт без необходимости,
после первого edit сразу запусти узкую проверку.
Если логика не feature-specific, переименуй типы по ответственности и вынеси их из feature-папки.
Если сервис выполняет только technical work, убери из имени, namespace и пути
все business, domain и feature-слова.
```

## Проверка перед завершением

1. Назван конкретный technical block, который был вынесен.
2. Caller сохранил orchestration responsibility.
3. Новый port не содержит framework-specific типов.
4. Реализация лежит в `Infra` или `EFCore` с явным обоснованием выбора.
5. Общий adapter не остался в feature-specific папке.
6. Имена отражают ответственность, а не имя первого caller-а.
7. У технического сервиса в имени, namespace и пути нет business/domain/feature naming,
   если он не принимает бизнес-решений.
8. Выполнена узкая проверка после первого substantive edit.
9. В итоговом сообщении перечислены измененное, неизмененное, риски и способ проверки.