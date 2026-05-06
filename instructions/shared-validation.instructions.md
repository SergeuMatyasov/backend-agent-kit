---
name: validation
description: "Используй при создании, изменении и ревью FluentValidation-валидаторов: composition, async checks, error messages, deterministic rules и границы validation flow."
applyTo:
  - '**/Validators/**/*.cs'
  - '**/*Validator.cs'
---

# Validation

## Цель
Задать единый baseline для validator-файлов, который:
- держит validation flow предсказуемым и читаемым;
- не дает смешивать валидацию с бизнес-логикой и побочными эффектами;
- поощряет переиспользование правил без копипаста;
- снижает риск хрупких async checks и неожиданных validation bugs.

## Когда использовать
Используй эту instruction, если нужно:
- создать новый `AbstractValidator<T>`;
- изменить существующий validator или состав правил валидации;
- вынести повторяющиеся validation rules в отдельный компонент;
- провести PR-ревью validator-файла.

## Обязательные правила
1. Валидатор должен проверять корректность входа и preconditions, а не выполнять бизнес-операции, orchestration или write-side effects.
2. Повторяющиеся правила нужно переиспользовать через `SetValidator`, `Include` или отдельный reusable-validator, а не копировать по разным сценариям.
3. Cheap local checks (`NotNull`, `NotEmpty`, format, length, range) должны идти раньше async или dependency-backed checks.
4. Async validation обязана принимать и пробрасывать `CancellationToken` во все нижние async-вызовы.
5. Сообщения валидации должны быть на английском языке.
6. Вложенные валидаторы подключать через стандартную композицию FluentValidation, а не через ручной вызов `Validate`/`ValidateAsync` внутри `Must` или `MustAsync`.
7. Валидаторы должны быть детерминированными: не зависеть напрямую от случайных данных, текущего времени и неявного состояния окружения.
8. Не вызывать дорогие repository, database или external checks, пока не пройдены базовые shape checks.
9. Каждый `RuleFor` должен оставаться локально понятным: одна проверка или одна тесно связанная логическая группа.
10. Если validator использует зависимость, она должна обслуживать именно validation need, а не скрывать внутри полноценный use case.

## Рекомендуемые практики
1. Разделять reusable primitive validators и scenario-specific composite validators.
2. Использовать `Cascade(CascadeMode.Stop)`, когда поздние проверки имеют смысл только после ранних preconditions.
3. Держать имена validator-классов семантичными и заканчивающимися на `Validator`.
4. Выносить complex existence или format checks в отдельные validator-компоненты, если они реально переиспользуются.
5. Для validator changes поддерживать unit-тесты на негативные, граничные и null/empty сценарии.
6. При code review отдельно проверять, не утекла ли в validator бизнес-логика, которую должен решать application/domain layer.

## Анти-паттерны
1. Смешивание validation и business logic.
Почему плохо: validator получает лишнюю ответственность и начинает принимать бизнес-решения.
Как лучше: оставить в validator только checks входных данных и validation preconditions.

2. Копирование одинаковых правил по нескольким command/request validators.
Почему плохо: правила расходятся и усложняют сопровождение.
Как лучше: вынести общий reusable-validator и подключить его через `SetValidator` или `Include`.

3. `CancellationToken.None` внутри async validation.
Почему плохо: теряется управляемая отмена и validation становится менее безопасной под нагрузкой.
Как лучше: пробрасывать токен из async rule во все нижние async dependencies.

4. Ручной вызов вложенного validator внутри `Must` или `MustAsync`.
Почему плохо: теряется прозрачная композиция FluentValidation и растет хрупкость тестов.
Как лучше: использовать стандартное подключение вложенного validator через `SetValidator` или `Include`.

5. Запуск repository или external checks до базовой локальной валидации.
Почему плохо: растет стоимость validation и появляются лишние обращения для заведомо плохого входа.
Как лучше: сначала cheap local checks, потом dependency-backed rules.

## Примеры

### Do
```csharp
public sealed class UpdateUserFullNameCommandValidator : AbstractValidator<UpdateUserFullNameCommand>
{
    public UpdateUserFullNameCommandValidator(
        UserIdValidator userIdValidator,
        FullNameValidator fullNameValidator)
    {
        RuleFor(x => x.UserId).SetValidator(userIdValidator);
        RuleFor(x => x.FullName).SetValidator(fullNameValidator);
    }
}
```

### Don't
```csharp
public sealed class UpdateUserFullNameCommandValidator : AbstractValidator<UpdateUserFullNameCommand>
{
    public UpdateUserFullNameCommandValidator(IUsersRepository usersRepository)
    {
        RuleFor(x => x.UserId)
            .MustAsync((id, _) => usersRepository.IsExistsAsync(id, CancellationToken.None));

        RuleFor(x => x.FullName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(70)
            .Matches("^[A-Za-zА-Яа-я ]+$");
    }
}
```

## Алгоритм принятия решений
1. Определи, validator это для одного сценария или reusable rule-компонент.
2. Проверь, какие правила уже можно переиспользовать без дублирования.
3. Выстрой порядок: cheap local checks сначала, dependency-backed checks после них.
4. Проверь, не протекла ли в validator бизнес-логика, orchestration или write behavior.
5. Убедись, что async rules получают корректный `CancellationToken`.
6. Проверь, что validator остается детерминированным и понятным для unit-тестов.

## Проверка перед завершением
1. Валидатор не содержит бизнес-операций и побочных эффектов.
2. Повторяющиеся правила переиспользуются, а не копируются.
3. Async rules пробрасывают корректный `CancellationToken`.
4. Сообщения валидации на английском языке.
5. Cheap local checks не идут после дорогих dependency-backed checks.
6. Вложенные валидаторы подключены через стандартную композицию FluentValidation.