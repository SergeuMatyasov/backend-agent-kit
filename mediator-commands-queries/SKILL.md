---
name: mediator-commands-queries
description: "Используй при создании и рефакторинге команд и запросов на MediatR: границы Command/Query, структура кейса, handler, validator и правила файлов."
---

# Mediator Commands Queries

## Цель
Зафиксировать единый стандарт для MediatR-command/query use case-ов, чтобы:
- команды и запросы не смешивали read и write поведение;
- один use case был собран в одном месте;
- код не расползался по папкам `Commands`, `Queries`, `Handlers` и `Dtos` без owner-контекста;
- handler-ы оставались тонкими orchestration-компонентами;
- новые кейсы сразу попадали в правильный слой и правильную папку.

## Когда использовать
Используй этот skill, если нужно:
- создать новую команду, запрос, handler или validator на MediatR;
- перенести legacy use case из `Infrastructure/CQRS` в `Application`;
- упростить структуру папок для конкретного кейса;
- провести ревью CQRS/Mediator-кода;
- решить, это command или query.

## Связанные skills
- `.github/skills/clean-architecture-placement/SKILL.md`
- `.github/skills/clean-code-principles/SKILL.md`
- `.github/skills/clean-code-refactoring/SKILL.md`
- `.github/skills/code-style-conventions/SKILL.md`
- `.github/skills/summary/SKILL.md`
- `.github/skills/validators/SKILL.md`

## Целевая структура кейса

### Базовое правило
Один use case должен жить в одной отдельной папке.

Целевой путь:

```text
src/DebtRecalcService.Application/UseCases/<Feature>/<CaseName>/
```

Примеры:
- `src/DebtRecalcService.Application/UseCases/Account/SignIn/`
- `src/DebtRecalcService.Application/UseCases/Contracts/EvaluateInterestAccrualEligibility/`
- `src/DebtRecalcService.Application/UseCases/Contracts/PrepareAndEvaluateInterestAccrualEligibility/`

### Что хранить в папке кейса
В одной папке кейса хранить все, что используется только этим кейсом:
- command или query;
- handler;
- result model;
- case-local enum;
- case-local helper model;
- validator в отдельном файле.

### Чего не делать
Не создавать для одного кейса поддиректории:
- `Commands/`
- `Queries/`
- `Handlers/`
- `Validators/`

Тип use case должен определяться именем request type, а не промежуточной папкой.

## Обязательные правила
1. Любой новый MediatR use case размещать в `Application`, а не в `Infrastructure/CQRS`.
2. Один request = один use case = одна отдельная папка.
3. Query не должен менять persistent state, external state или observable system state.
4. Query запрещено использовать для `SaveChanges`, `Insert`, `Update`, `Delete`, publish в broker, запуска job, отправки команд во внешние системы и других side effects.
5. Command должен моделировать write intent. Если use case ничего не меняет и только вычисляет/читает, это не command, а query.
6. Handler должен оркестрировать один сценарий и не должен становиться местом для большого объема domain-логики.
7. Domain-расчеты и reusable business rules должны выноситься в `Domain` или в application/domain services, а не копироваться в handler.
8. Handler должен зависеть от абстракций, а не от concrete infrastructure implementation.
9. Для request type использовать `ICommand<TResponse>` или `IQuery<TResponse>` из `Shared.CQRS.Interfaces`.
10. Для handler использовать `ICommandHandler<TCommand, TResponse>` или `IQueryHandler<TQuery, TResponse>`.
11. Если request и handler небольшие и вместе не загрязняют файл, их нужно держать в одном файле, причем сначала request, затем handler.
12. Если combined file стал большим, содержит много case-local типов или перестал быстро читаться, request и handler нужно разнести по разным файлам, но оставить в той же папке кейса.
13. Валидатор, если он есть, всегда хранить в отдельном файле внутри той же папки кейса.
14. Не создавать отдельный exception под конкретный handler вида `SomeCommandException` или `SomeQueryException`.
15. Для ошибок использовать общие typed exceptions из папок слоя `Exceptions`, если эти исключения имеют смысл и вне одного handler.
16. Namespace должен отражать feature и case folder, а не искусственные сегменты `Commands`, `Queries`, `Handlers`.
17. Все public types кейса должны иметь XML `summary`.
18. XML `summary` писать по правилам из `.github/skills/summary/SKILL.md`.
19. `CancellationToken` должен пробрасываться по всей async-цепочке handler-а.
20. Query должен трактовать вход как read-only контракт и не использовать request как контейнер для подготовки состояния перед сохранением.
21. Command может координировать изменение состояния, но должен иметь один связный write-сценарий, а не набор несвязанных действий.
22. Validator не должен менять состояние, вызывать `SaveChanges`, публиковать сообщения или выполнять внешние side effects.

## Правила файла command/query и handler
1. Если request и handler находятся в одном файле, имя файла должно совпадать с request type: `SignInCommand.cs`, `EvaluateInterestAccrualEligibilityQuery.cs`.
2. В combined file сначала объявлять request type, затем handler.
3. В combined file допустимо держать только request, handler и небольшие private helper methods handler-а.
4. Не держать в combined file validator вместе с handler-ом.
5. Не держать в combined file несколько разных request type-ов.
6. Если в кейсе есть result model, enum или helper model, по умолчанию выносить их в отдельные файлы той же папки.
7. Если handler вызывает длинные private methods с собственной самостоятельной логикой, это сигнал к выделению service или разбиению use case.

## Правила command
1. Command используется, если use case меняет состояние системы или инициирует внешний side effect.
2. Command может возвращать `Unit`, идентификатор, result model или другой минимально необходимый результат.
3. Не возвращать из command большой read model, если caller-у нужен отдельный запрос на чтение.
4. Не использовать command для простого `CanXxx`, `GetXxx`, `EvaluateXxx` или других read-only сценариев.
5. Если command координирует несколько шагов, он должен явно владеть write boundary и последовательностью действий.

## Правила query
1. Query используется только для чтения, вычисления, оценки, поиска, агрегации и формирования read-model.
2. Query может выполнять in-memory вычисления и проекции, но не должен изменять сохраняемое состояние.
3. Query не должен скрыто подготавливать данные к записи или изменять tracked entities ради последующего сохранения.
4. Query должен возвращать данные, projection, evaluation result или read-only decision result.
5. Если кейс сначала подготавливает состояние, а потом выполняет read-only оценку, подготовка должна быть отдельным command/use case или application service, а не частью query.

## Правила validator
1. Валидатор именовать `<CaseName>CommandValidator` или `<CaseName>QueryValidator`.
2. Валидатор хранить в отдельном файле внутри папки кейса.
3. Валидатор должен проверять входной контракт, структурную корректность и дешевые preconditions.
4. Не помещать в валидатор business orchestration.
5. Избегать тяжелых внешних вызовов из валидатора; если без read-check не обойтись, он должен быть read-only, дешевым и детерминированным.
6. Не дублировать в валидаторе сложные domain rules, если они уже выражены в domain/application service.

## Правила зависимостей и переиспользования
1. Не делать глубокие цепочки `sender.Send(...)` между handler-ами как основной способ reuse.
2. Если логика нужна нескольким handler-ам, предпочитать выделение application service или domain service.
3. Один hop `command -> query` допустим только для явной orchestration-задачи, когда внешний handler координирует уже существующий read-only use case.
4. Запрещены циклические цепочки `command -> query -> command` и аналогичные скрытые workflow через MediatR.
5. Не использовать MediatR как замену обычному методу или сервису внутри одного и того же куска логики без явной причины.

## Рекомендуемые практики
1. Предпочитать `sealed record` или `sealed class` для request type с `required` и `init`, если это не конфликтует с binding/serialization сценарием.
2. Имена кейсов делать по намерению: `SignIn`, `EvaluateInterestAccrualEligibility`, `PrepareAndEvaluateInterestAccrualEligibility`.
3. Для result model использовать имя по смыслу кейса, а не абстрактное `ResponseDto`, если это не внешний transport DTO.
4. Для query-результатов предпочитать immutable/read-only модели там, где это уместно.
5. Логи в handler-ах делать structured и только на английском языке.
6. В command логировать важные write milestones, в query логировать только значимые read/evaluation события.
7. Держать handler коротким: он должен читаться как сценарий сверху вниз.
8. Если кейс маленький, combined file предпочтительнее двух мелких файлов, потому что он лучше сохраняет локальный контекст.
9. Если кейс большой, разносить файлы внутри той же папки кейса, а не плодить технические подпапки.
10. Если result model, enum или helper model начали использоваться несколькими кейсами, переносить их на feature-common уровень осознанно, а не по привычке в `Shared`.

## Анти-паттерны
1. Query, который вызывает `SaveChanges`, обновляет сущности или отправляет сообщение в брокер.
Почему плохо: read/write граница сломана, поведение становится неожиданным.
Как правильно: разделить write и read use case.

2. Command, который только проверяет условие и ничего не меняет.
Почему плохо: нарушается семантика паттерна, код становится труднее читать и искать.
Как правильно: моделировать такой сценарий как query.

3. Папки вида `Commands/<CaseName>/Handlers/` или `Queries/<CaseName>/Validators/`.
Почему плохо: use case распадается на технические слои вместо локального feature-контекста.
Как правильно: хранить все case-local файлы в одной папке кейса.

4. Handler-specific exception вроде `GetContractQueryException` или `CreateUserCommandException`.
Почему плохо: плодятся одноразовые типы без повторного смысла и размывается модель ошибок.
Как правильно: использовать общие typed exceptions из слоя `Exceptions`.

5. Validator внутри того же файла, что и handler.
Почему плохо: файл перестает быть компактным, смешиваются orchestration и validation concerns.
Как правильно: выносить validator в отдельный файл той же папки кейса.

6. Глубокая цепочка MediatR-вызовов для reuse.
Почему плохо: сценарий трудно отследить, растет риск циклов и скрытых side effects.
Как правильно: выделять reusable service.

7. Namespace, повторяющий технический legacy путь `Infrastructure.CQRS.<Feature>.Commands.<CaseName>` для нового Application use case.
Почему плохо: слой уже сменился, а модель структуры осталась старой и вводит в заблуждение.
Как правильно: использовать namespace по новому пути кейса в `Application.UseCases`.

8. Комбинированный файл, в котором лежат request, handler, validator, result, enum, mapper и еще несколько вспомогательных классов.
Почему плохо: теряется локальная читабельность, файл начинает загрязняться.
Как правильно: оставлять combined file только для request + handler, остальное выносить в соседние файлы по мере роста.

## Примеры

### Do
```text
src/DebtRecalcService.Application/UseCases/Account/SignIn/
  SignInCommand.cs                   // request + handler, если кейс небольшой
  SignInCommandValidator.cs          // отдельный файл, если нужен
  SignInResult.cs                    // отдельный файл, если нужен
```

```text
src/DebtRecalcService.Application/UseCases/Contracts/EvaluateInterestAccrualEligibility/
  EvaluateInterestAccrualEligibilityQuery.cs
  EvaluateInterestAccrualEligibilityQueryValidator.cs
  InterestAccrualEligibilityEvaluationResult.cs
  InterestAccrualEligibilityFailureReason.cs
  InterestAccrualEligibilityRequestedAction.cs
```

### Don't
```text
src/DebtRecalcService.Application/UseCases/Contracts/Queries/EvaluateInterestAccrualEligibility/
  Handlers/
    EvaluateInterestAccrualEligibilityQueryHandler.cs
  Validators/
    EvaluateInterestAccrualEligibilityQueryValidator.cs
```

```text
src/DebtRecalcService.Infrastructure/CQRS/Contracts/Queries/EvaluateInterestAccrualEligibility/
  EvaluateInterestAccrualEligibility.cs
```

## Алгоритм принятия решений
1. Определи, меняет ли сценарий состояние системы или инициирует side effect.
2. Если да, создавай command. Если нет, создавай query.
3. Выбери feature-owner кейса и создай папку `UseCases/<Feature>/<CaseName>/`.
4. Назови request type с суффиксом `Command` или `Query`.
5. Реши, помещаются ли request и handler в один компактный файл без загрязнения.
6. Если да, положи request и handler в один файл, request первым.
7. Если нет, разнеси request и handler по отдельным файлам внутри той же папки кейса.
8. Если нужен validator, создай отдельный файл validator-а внутри этой же папки.
9. Для ошибок используй существующие typed exceptions из общих папок слоя `Exceptions`.
10. Добавь XML `summary` для request, handler, validator и result по правилам `.github/skills/summary/SKILL.md`.
11. Проверь, что query не меняет состояние, а command не маскирует read-only сценарий.
12. Проверь, что handler не утащил в себя reusable business logic, которую нужно выделить в service.

## Проверка перед завершением
1. Use case лежит в одной отдельной папке.
2. Новый кейс не попал в `Infrastructure/CQRS`.
3. Query не меняет состояние и не вызывает side effects.
4. Command действительно моделирует write intent.
5. Request type использует правильную CQRS abstraction из `Shared`.
6. Handler зависит от абстракций и пробрасывает `CancellationToken`.
7. Combined file содержит только request + handler и остается компактным.
8. Validator, если он есть, лежит в отдельном файле.
9. Нет handler-specific exception-класса.
10. Все public types имеют XML `summary` по правилам `.github/skills/summary/SKILL.md`.
11. Namespace соответствует feature и case folder.
12. Нет лишних папок `Commands`, `Queries`, `Handlers`, `Validators` внутри одного кейса.