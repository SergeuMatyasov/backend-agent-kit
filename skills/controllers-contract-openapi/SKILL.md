---
name: controllers-contract-openapi
description: "Используй при работе с контрактом контроллера и OpenAPI: DTO, коды ответов, атрибуты и совместимость схем."
---

# Controllers Contract OpenAPI

## Цель
Сделать API-контракт прозрачным, строго типизированным и синхронизированным с OpenAPI.

## Когда использовать
Используй этот skill, если нужно:
- менять request/response DTO;
- менять коды ответа;
- обновлять `ProducesResponseType`;
- синхронизировать контракт и OpenAPI.

## Обязательные правила
1. Для `200 OK` с телом использовать `ProducesResponseType(typeof(...), 200)`.
2. Не использовать анонимные объекты в публичном `Ok(...)` ответе.
3. DTO должны быть явно разделены на request и response, если это разные контракты.
4. Все публичные изменения контракта должны быть отражены в OpenAPI.
5. Ошибки должны возвращаться в согласованном формате (ProblemDetails/ValidationProblemDetails).
6. Имена полей DTO в JSON-контракте должны быть в формате camelCase.

## Рекомендуемые практики
1. Фиксировать матрицу ответов endpoint (код -> тип -> условие).
2. Использовать осмысленные имена DTO по доменному смыслу.
3. Явно указывать `ProducesResponseType` для всех основных веток результата.
4. Проверять backward compatibility схем перед merge.

## Анти-паттерны
1. `ProducesResponseType(200)` без типа ответа.
2. `Ok(new { ... })` вместо именованного DTO.
3. Изменение DTO без обновления OpenAPI.
4. Несогласованный формат ошибок между endpoint.

## Примеры

### Do
```csharp
[ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
```

### Don't
```csharp
[ProducesResponseType(StatusCodes.Status200OK)]
return Ok(new { id = user.Id, name = user.Name });
```

## Алгоритм принятия решений
1. Определи, меняется ли внешний контракт.
2. Зафиксируй конечные request/response DTO и коды ответа.
3. Добавь/обнови атрибуты `ProducesResponseType`.
4. Обнови OpenAPI-спецификацию.
5. Проверь совместимость схем и клиентов.

## Проверка перед завершением
1. Все `200 OK` с телом типизированы.
2. Нет анонимных response-объектов.
3. OpenAPI синхронизирован с кодом.
4. Формат ошибок согласован.
