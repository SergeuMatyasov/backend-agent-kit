---
name: dotnet-api
description: "Используй при создании, изменении и ревью ASP.NET Core API controller files: внешний контракт, request/response DTO, HTTP-коды, error-paths, routing и CancellationToken."
applyTo:
  - '**/Controllers/**/*.cs'
  - '**/*Controller.cs'
---

# Dotnet API

## Цель
Задать единый baseline для ASP.NET Core API-файлов, который:
- держит контроллеры тонким presentation layer;
- сохраняет стабильный внешний HTTP-контракт;
- снижает риск drift между code, DTO и OpenAPI;
- не дает протекать infrastructure details в API-слой.

## Когда использовать
Используй эту instruction, если нужно:
- создать новый API controller;
- изменить endpoint, маршрут, DTO, HTTP-коды или shape ответа;
- провести PR-ревью ASP.NET Core API-файла;
- проверить, не протекла ли бизнес- или инфраструктурная логика в presentation layer.

## Обязательные правила
1. Контроллер должен оставаться тонким HTTP-адаптером: binding входа, вызов application use case, mapping результата в HTTP-ответ.
2. Не возвращать domain entities, EF Core entities и внутренние application models напрямую из публичного API.
3. Для внешнего контракта использовать явные request DTO и response DTO с семантикой, привязанной к API, а не к внутренней реализации.
4. Каждый async endpoint должен принимать `CancellationToken` и пробрасывать его во все нижние async-вызовы.
5. Для каждого endpoint должны быть явно определены ожидаемые success statuses и error-paths.
6. Не смешивать в контроллере бизнес-решения, работу с БД, внешними HTTP-клиентами и другую infrastructure logic.
7. Ошибки должны возвращаться в предсказуемом и единообразном формате проекта без утечки внутренних деталей.
8. Не использовать анонимные типы и ad hoc payload-структуры в публичных API-ответах.
9. Изменение публичного DTO, маршрута или кода ответа считать контрактным изменением и проверять на backward compatibility risk.
10. API-поведение, DTO и OpenAPI-артефакты должны синхронно отражать один и тот же контракт.

## Рекомендуемые практики
1. Использовать resource-oriented routes и route constraints для идентификаторов.
2. Держать request DTO и response DTO отдельными типами даже для похожих сценариев.
3. Делать mapping между HTTP DTO и application contract явным и читаемым.
4. Использовать `201 Created` только когда действительно создается новый ресурс, и `204 NoContent` для успешной операции без тела.
5. Выносить повторяющийся mapping и response conversion из контроллера, если он перестает быть тривиальным.
6. Держать validation flow предсказуемым: shape validation на входе, бизнес-валидацию в application/domain layer.

## Анти-паттерны
1. Возврат domain model напрямую из endpoint.
Почему плохо: клиент начинает зависеть от внутренней модели и ломается при внутренних изменениях.
Как лучше: отдать отдельный response DTO, принадлежащий API-контракту.

2. Прямой вызов `DbContext`, repository или внешнего клиента из контроллера.
Почему плохо: presentation layer берет на себя чужую ответственность и становится трудно тестируемым.
Как лучше: вызывать application/service use case, который инкапсулирует orchestration и infrastructure access.

3. `Ok(new { ... })` или разные error payload для одинаковых сценариев.
Почему плохо: контракт становится неявным и плохо документируемым.
Как лучше: использовать именованные response DTO и единый формат ошибок.

4. Async action без `CancellationToken` или с потерей токена по пути вниз.
Почему плохо: сервер теряет возможность корректно прерывать отмененный запрос.
Как лучше: принимать `CancellationToken` в action и прокидывать его во все async dependency calls.

5. Всегда возвращать `200 OK`, независимо от результата операции.
Почему плохо: HTTP-контракт перестает отражать семантику сценария.
Как лучше: выбирать точный код ответа для create, update, validation failure, not found и conflict.

## Примеры

### Do
```csharp
[HttpGet("{id:guid}")]
[ProducesResponseType(typeof(ProductResponse), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public async Task<ActionResult<ProductResponse>> GetByIdAsync(
    Guid id,
    CancellationToken cancellationToken)
{
    var result = await mediator.Send(new GetProductQuery(id), cancellationToken);

    return result is null
        ? NotFound()
        : Ok(ProductResponse.FromResult(result));
}
```

### Don't
```csharp
[HttpGet("{id}")]
public async Task<IActionResult> Get(Guid id)
{
    var entity = await dbContext.Products.FindAsync(id);
    return Ok(entity);
}
```

## Алгоритм принятия решений
1. Определи, какой user scenario обслуживает endpoint.
2. Проверь, есть ли у сценария явные request/response DTO для внешнего контракта.
3. Определи success status и expected error statuses до написания тела метода.
4. Убедись, что контроллер только переводит HTTP-вход в вызов application layer.
5. Проверь, что `CancellationToken` доходит до всех async boundary calls.
6. Сверь DTO, поведение endpoint и OpenAPI на предмет drift и breaking change risk.

## Проверка перед завершением
1. Контроллер не содержит бизнес- и инфраструктурной логики.
2. Публичный API не возвращает domain/entity модели напрямую.
3. Для внешнего контракта используются явные request/response DTO.
4. Для async endpoint не потерян `CancellationToken`.
5. Success statuses и error-paths выражены явно и соответствуют поведению.
6. DTO, controller behavior и OpenAPI не расходятся между собой.