---
name: clean-code-functions
description: "Используй для проектирования методов: SRP, размер, читаемость, параметры, побочные эффекты и обработка ошибок."
---

# Clean Code Functions

## Цель
Сделать методы короткими, предсказуемыми и легко тестируемыми.

## Когда использовать
Используй этот skill, если нужно:
- написать новый метод;
- разбить длинный метод;
- улучшить тестируемость и читаемость существующего метода.

## Связанные skills
- `.github/skills/clean-code-principles/SKILL.md`
- `.github/skills/clean-code-refactoring/SKILL.md`
- `.github/skills/clean-code-naming/SKILL.md`
- `.github/skills/unit-testing/SKILL.md`

## Обязательные правила
1. Метод должен решать один сценарий.
2. Избегать глубокой вложенности: использовать guard clauses.
3. Не смешивать в одном методе вычисление, валидацию и IO без необходимости.
4. Явно обрабатывать ошибки ожидаемого сценария.
5. Пробрасывать `CancellationToken` в async-методах при наличии.

## Рекомендуемые практики
1. Держать метод небольшим и фокусным.
2. Ограничивать количество параметров через value objects/DTO при необходимости.
3. Отделять pure logic от побочных эффектов.
4. Возвращать осмысленные типы результатов вместо `bool` без контекста.
5. Называть метод по действию и результату сценария.

## Анти-паттерны
1. Метод на десятки строк с несколькими независимыми ветками.
2. Скрытые побочные эффекты без отражения в названии/контракте.
3. Проглатывание исключений без логирования и решения.

## Примеры

### Do
```csharp
public async Task<Unit> Handle(UpdateUserFullNameCommand request, CancellationToken ct)
{
    Validate(request);
    await usersRepository.UpdateFullNameAsync(request.UserId, request.FullName, ct);
    return Unit.Value;
}
```

### Don't
```csharp
public async Task<Unit> Handle(UpdateUserFullNameCommand request, CancellationToken ct)
{
    // validation + mapping + business rules + retry + persistence + response mapping in one method
    // ...
    return Unit.Value;
}
```

## Алгоритм принятия решений
1. Определи единственную ответственность метода.
2. Вынеси вспомогательные шаги в отдельные методы/компоненты.
3. Уменьши вложенность через ранние выходы.
4. Проверь тестируемость метода по контракту.

## Проверка перед завершением
1. Метод решает один сценарий.
2. Вложенность и когнитивная сложность контролируемы.
3. Побочные эффекты явные.
4. Ошибки обработаны предсказуемо.
