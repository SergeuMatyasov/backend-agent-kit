---
name: validators
description: "Используй для FluentValidation-валидаторов."
---

# Validators

## Цель
Сформировать единый стандарт для валидаторов, который:
- делает правила валидации предсказуемыми;
- упрощает повторное использование правил;
- сохраняет читаемость и тестируемость;
- снижает количество регрессий при изменениях.

## Когда использовать
Используй этот skill, если нужно:
- создать новый `AbstractValidator<T>`;
- отрефакторить существующий validator;
- вынести общие validation-правила в переиспользуемые компоненты;
- провести PR-ревью validator-кода и validator-тестов.

## Связанные skills
- `.github/skills/unit-testing/SKILL.md`

## Обязательные правила
1. Валидатор должен отвечать только за валидацию входных данных
    и не содержать бизнес-логики.
2. Для повторяющихся правил использовать композицию (`SetValidator`)
    вместо копирования условий.
3. Для async-правил обязательно пробрасывать `CancellationToken`
    в зависимости.
4. Сообщения валидации должны быть на английском языке.
5. Для публичных сценариев имена validator-классов должны быть
    семантичными
    и заканчиваться на `Validator`.
6. При проверках, где последующие шаги зависят от предыдущих,
    использовать `Cascade(CascadeMode.Stop)`.
7. Валидаторы должны быть детерминированными: без зависимости
    от текущего времени, окружения и случайных данных без фиксации.
8. Вложенные валидаторы подключать через `SetValidator` или `Include`,
    а не через ручной вызов `Validate/ValidateAsync` внутри `Must/MustAsync`.
9. Если валидатор можно переиспользовать в нескольких сценариях,
    выделять его в отдельный класс (например, `TbankNotificationValidator`)
    и внедрять через конструктор.

## Рекомендуемые практики
1. Разделять primitive validators и object validators:
    сначала переиспользуемые правила для поля,
    затем композиция в command/request validator.
2. Делать каждый `RuleFor` коротким и фокусным:
    одно правило или одна логическая группа.
3. Использовать явные и устойчивые property checks в тестах:
    `PropertyName`, `ErrorMessage`.
4. Для комплексных сценариев писать `Theory`
    с набором граничных значений.
5. Для правил с доступом к репозиторию сначала валидировать
    базовые условия (`NotEmpty`), затем вызывать `MustAsync`.
6. Сохранять единый стиль имен: `UserIdExistsValidator`, `UpdateUserFullNameCommandValidator`.
7. Тестировать вложенные валидаторы отдельно,
    а в composite-validator проверять только корректное подключение и ожидаемые ошибки.
8. Для `RuleFor(x => x.Property).SetValidator(...)` предпочитать
    проверку конкретного `PropertyName` и сообщения ошибки,
    чтобы тесты оставались устойчивыми к внутреннему рефакторингу.

## Анти-паттерны
1. Смешивание валидации и бизнес-операций.
Почему плохо: растет связность и ломается SRP.
Как лучше: оставлять в валидаторе
только проверки корректности входа.

2. Дублирование одинаковых проверок в каждом command validator.
Почему плохо: сложно сопровождать
и легко получить расхождение правил.
Как лучше: выносить общие правила в отдельные validators
и подключать через `SetValidator`.

3. Использование `CancellationToken.None` внутри async-правил.
Почему плохо: ломается управляемая отмена под нагрузкой.
Как лучше: пробрасывать токен из `MustAsync` в зависимости.

4. Тесты только на happy path.
Почему плохо: регрессии в граничных
и негативных кейсах остаются незамеченными.
Как лучше: покрывать негативные сценарии и границы
(`null`, пустая строка, пробелы, минимум/максимум).

5. Прямая валидация `null` как корневой модели для `AbstractValidator<string>`.
Почему плохо: `Validate/ValidateAsync(null)` для root string-модели
может бросать `ArgumentNullException`,
а не возвращать `ValidationResult`.
Как лучше: тестировать невалидные строковые значения (`""`, `" "`)
и учитывать особое поведение `null` отдельно.

6. Ручной вызов вложенного валидатора внутри `MustAsync`.
Почему плохо: дублируется инфраструктура FluentValidation,
теряется прозрачность композиции и усложняется unit-тестирование.
Как лучше: подключать вложенный валидатор через `SetValidator`/`Include`
и тестировать его как отдельный компонент.

## Примеры

### Do
```csharp
public class UpdateUserFullNameCommandValidator : AbstractValidator<UpdateUserFullNameCommand>
{
    public UpdateUserFullNameCommandValidator(
        UserIdExistsValidator userIdExistsValidator,
        FullNameValidator fullNameValidator)
    {
        RuleFor(x => x.UserId).SetValidator(userIdExistsValidator);
        RuleFor(x => x.FullName).SetValidator(fullNameValidator);
    }
}
```

```csharp
public class HandleTbankNotificationCommandValidator : AbstractValidator<HandleTbankNotificationCommand>
{
    public HandleTbankNotificationCommandValidator(TbankNotificationValidator tbankNotificationValidator)
    {
        RuleFor(x => x.JsonElement)
            .SetValidator(tbankNotificationValidator);
    }
}
```

### Don't
```csharp
public class UpdateUserFullNameCommandValidator : AbstractValidator<UpdateUserFullNameCommand>
{
    public UpdateUserFullNameCommandValidator(IUsersRepository usersRepository)
    {
        RuleFor(x => x.UserId)
            .MustAsync((id, _) => usersRepository.IsExistAsync(id, CancellationToken.None))
            .WithMessage("Пользователь не найден");

        RuleFor(x => x.FullName)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(70)
            .Matches("^[A-Za-zА-Яа-я ]+$");
    }
}
```

## Алгоритм принятия решений
1. Определи, это новый validator или расширение существующего.
2. Выдели, какие правила уже можно переиспользовать
    из общих validator-компонентов.
3. Определи порядок проверок: сначала cheap checks, затем async/dependency checks.
4. Выбери формат и язык сообщений ошибок (только английский).
5. Добавь/обнови unit-тесты: позитив, негатив, границы.
6. Проверь, что изменения не затрагивают
    внешний контракт вне валидации.
7. Для вложенных правил реши, что именно тестируется:
    сам reusable-validator или только wiring в composite-validator.

## Проверка перед завершением
1. Валидатор не содержит бизнес-операций и побочных эффектов.
2. Общие правила переиспользуются, а не дублируются.
3. Все async-проверки используют корректный `CancellationToken`.
4. Сообщения валидации на английском языке.
5. Покрыты ключевые тестовые сценарии: позитив, негатив и границы.
6. Нет неожиданного поведения с `null` для root primitive validators.
7. Вложенные валидаторы подключены через `SetValidator`/`Include`
    и покрыты отдельными unit-тестами.
