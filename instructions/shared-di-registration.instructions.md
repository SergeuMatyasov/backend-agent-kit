---
name: di-registration
description: "Используй при создании, изменении и ревью dependency injection registration files: composition root, service lifetimes, interface-based reflection registration, scanning safety, module registration boundaries и anti-service-locator rules."
applyTo:
  - '**/*DependencyInjection*.cs'
  - '**/*ServiceCollectionExtensions*.cs'
---

# DI Registration

## Цель
Задать единый baseline для файлов регистрации зависимостей, который:
- держит DI registration в роли composition root, а не места для бизнес-логики;
- делает lifetimes и wiring предсказуемыми;
- поддерживает основной паттерн регистрации через service interfaces и reflection/marker-based scanning;
- снижает риск runtime ошибок из-за плохой регистрации или неосторожного auto-scanning;
- упрощает проверку registration boundaries и DI health.

## Когда использовать
Используй эту instruction, если нужно:
- создать или изменить `DependencyInjection.cs`;
- добавить новый registration extension method для `IServiceCollection`;
- внедрить assembly scanning, marker-based registration или bulk registration;
- провести PR-ревью composition root и DI wiring.

## Обязательные правила
1. Файл DI registration должен оставаться composition root: регистрировать зависимости, а не принимать бизнес-решения и не выполнять runtime orchestration.
2. Не размещать в registration method бизнес-логику, запросы к БД, сетевые вызовы и другой operational behavior.
3. Выбирать lifetime по фактическому поведению зависимости и ее нижним зависимостям, а не по удобству вызова.
4. Singleton не должен зависеть от scoped service напрямую или косвенно.
5. Не использовать `BuildServiceProvider()` внутри обычной регистрации ради раннего резолва сервисов или обхода DI graph.
6. Не превращать registration code в service locator: не резолвить сервисы из контейнера там, где достаточно корректного wiring.
7. Если сервис использует основной паттерн interface-based reflection registration, сканирование должно регистрировать реализации по их service interfaces и marker lifetimes, а не по случайным public interfaces класса.
8. Marker-based или reflection-based scanning должно покрывать только реальные service contracts и implementation types, а не случайные framework interfaces.
9. Специальные framework-specific типы, такие как `DelegatingHandler`, hosted infrastructure helpers или disposable adapters, регистрировать явно рядом с тем местом, где они реально используются.
10. При marker-based регистрации изменение интерфейса или marker lifetime считать контрактным изменением DI wiring и проверять, не выпал ли сервис из авто-регистрации.
11. Модульные registration methods должны регистрировать только свой срез зависимостей и не подменять ownership соседних модулей.
12. Любая неочевидная registration convention должна быть стабильной, локально понятной и проверяемой тестом или focused validation.

## Рекомендуемые практики
1. Держать публичные registration entry points короткими и раскладывать wiring по понятным module-level extension methods.
2. Явно группировать регистрации по слою или capability: application, infrastructure, host, external clients, options, health checks.
3. Если в сервисе принят marker-interface подход, предпочитать его для обычных application/infrastructure services вместо ручной поштучной регистрации каждого implementation.
4. Для marker-based или reflection-based scanning иметь focused тесты на критичные регистрации, lifetimes и наличие нужных service interfaces.
5. Регистрировать typed/http clients, handlers и options рядом с тем capability, которому они принадлежат.
6. При выборе lifetime отдельно проверять thread-safety, statefulness, disposable behavior и наличие scoped dependencies ниже по графу.
7. Если registration зависит от configuration, fail fast на обязательных значениях в явной и предсказуемой точке.

## Анти-паттерны
1. Бизнес-логика внутри `DependencyInjection.cs`.
Почему плохо: composition root начинает принимать решения, которые должны жить в application/domain code.
Как лучше: оставить в DI только wiring и вынести поведение в owning layer.

2. `BuildServiceProvider()` внутри регистрации ради получения уже зарегистрированного сервиса.
Почему плохо: появляются скрытые контейнеры, ломаются lifetimes и усложняется диагностика.
Как лучше: перестроить wiring через нормальные зависимости, factories или framework-supported overloads.

3. Blind auto-scanning, который регистрирует не только service contract, но и случайные framework interfaces вроде `IDisposable`.
Почему плохо: контейнер получает лишние или опасные registrations, которые всплывают уже на runtime.
Как лучше: ограничить scanning явными service contracts и special-case типы регистрировать вручную.

4. Class больше не реализует service interface или marker interface, но команда рассчитывает, что reflection registration продолжит работать.
Почему плохо: сервис тихо выпадает из DI graph и ошибка проявляется только при резолве на runtime.
Как лучше: относиться к service interface и marker lifetime как к части DI контракта и покрывать критичные регистрации тестами.

5. Singleton поверх scoped graph.
Почему плохо: появляется invalid lifetime usage и нестабильное поведение под нагрузкой.
Как лучше: либо опустить lifetime до scoped/transient, либо перестроить зависимости через правильную границу.

6. Один registration method знает слишком много о нескольких модулях сразу.
Почему плохо: ownership размывается, а изменение одного capability ломает общий composition root.
Как лучше: держать отдельные module-level registration methods и собирать их в короткой верхнеуровневой entry point.

## Примеры

### Do
```csharp
public static IServiceCollection AddApplicationLayer(this IServiceCollection services)
{
    services.AddCustomServicesFromAssemblies(new[] { typeof(DependencyInjection).Assembly });

    return services;
}
```

```csharp
public interface IEmailSender : ITransientCustomService
{
}

public sealed class SmtpEmailSender : IEmailSender
{
}
```

```csharp
public static IServiceCollection AddLeoApiHttpClients(this IServiceCollection services)
{
    services.AddHttpContextAccessor();
    services.AddTransient<BearerForwardingHandler>();

    services.AddHttpClient(nameof(LeoIdentityApiClient))
        .AddHttpMessageHandler<BearerForwardingHandler>();

    return services;
}
```

### Don't
```csharp
public static IServiceCollection AddInfrastructure(this IServiceCollection services)
{
    using var provider = services.BuildServiceProvider();
    var configuration = provider.GetRequiredService<IConfiguration>();

    if (DateTime.UtcNow.Hour > 12)
    {
        services.AddSingleton<IEmailSender, SmtpEmailSender>();
    }

    return services;
}
```

## Алгоритм принятия решений
1. Определи, какой модуль или capability владеет этой registration method.
2. Проверь, что метод только wires dependencies и не выполняет runtime behavior.
3. Для каждой новой регистрации выбери lifetime по реальным зависимостям и state model.
4. Если используется interface-based reflection registration, проверь, какие service interfaces и marker lifetimes реально увидит сканер.
5. Проверь, не выпадет ли сервис из registration при изменении implemented interfaces или marker interfaces.
6. Выдели explicit registration для special framework types и special-case adapters.
7. Убедись, что registration boundary остается модульной и локально понятной.

## Проверка перед завершением
1. Registration code не содержит бизнес-логики и service locator поведения.
2. Lifetimes согласованы с зависимостями и не создают singleton->scoped violation.
3. Interface-based reflection scanning регистрирует именно нужные service contracts и marker lifetimes.
4. Marker-based или reflection-based scanning не регистрирует случайные framework interfaces.
5. Special framework types зарегистрированы явно там, где им и место.
6. Module-level registration methods не смешивают ownership нескольких независимых срезов.
7. Неочевидные registration conventions подтверждены тестом или focused validation.
