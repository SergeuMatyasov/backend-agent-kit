---
name: controllers
summary: Используй при разработке, рефакторинге и ревью ASP.NET Core контроллеров.
description: >
  Стандарт для ASP.NET Core контроллеров: контракт API, маршруты, DTO, HTTP-коды,
  валидация, OpenAPI, CancellationToken, порядок методов и стиль кода.
---

# Controllers Skill

## Цель

Использовать единый стандарт для ASP.NET Core контроллеров, который обеспечивает:

- чистый и поддерживаемый presentation layer;
- отсутствие бизнес-логики в контроллерах;
- стабильный и предсказуемый API-контракт;
- корректные HTTP-коды для каждого сценария;
- единый стиль DTO, маршрутов и документации;
- корректную OpenAPI-документацию;
- удобство тестирования и ревью.

## Когда использовать

Используй этот skill, если нужно:

- создать новый ASP.NET Core контроллер;
- изменить endpoint, маршрут, DTO, HTTP-коды или атрибуты API;
- провести рефакторинг существующего контроллера;
- сделать PR-ревью контроллера;
- проверить совместимость API-контракта;
- подготовить контроллер к OpenAPI-документации и тестам.

## Связанные skills

- `controllers-contract-openapi`
- `controllers-testing`
- `validators`
- `dto-style`
- `api-versioning`

## Роль контроллера

Контроллер должен быть тонким слоем между HTTP API и application layer.

Контроллер отвечает за:

- прием входных данных;
- binding route, query и body параметров;
- базовую валидацию входа через DTO и атрибуты;
- вызов application/service layer;
- преобразование результата use case в HTTP-ответ;
- описание API-контракта через атрибуты и XML-документацию.

Контроллер не отвечает за:

- бизнес-правила;
- вычисления и принятие бизнес-решений;
- работу с базой данных напрямую;
- сложный mapping;
- повторяющуюся validation-логику;
- построение domain-моделей вручную;
- оркестрацию нескольких независимых бизнес-сценариев.

## Обязательные правила

### Общий стиль

1. Использовать primary constructor для внедрения зависимостей, где это возможно.
2. Длина строки не должна превышать 120 символов.
3. Контроллер должен быть `sealed`, если нет явной причины для наследования.
4. Контроллер должен наследоваться от `ControllerBase`, если views не используются.
5. Для API-контроллеров обязательно использовать `[ApiController]`.
6. Для контроллера обязательно задавать базовый `[Route(...)]`.
7. Использовать `[Produces("application/json")]`, если endpoint возвращает JSON.
8. Action-методы должны быть короткими: один метод = один пользовательский сценарий.
9. Использовать guard clauses вместо глубокой вложенности.
10. Не смешивать разные стили кода, маршрутов и ответов внутри одного контроллера.

### Документация

11. Каждый публичный action-метод должен иметь XML-документацию.
12. Для action-метода обязательно указывать `summary`, `param` и `returns`.
13. `summary`, `param` и `returns` писать на русском языке.
14. Тексты ошибок, исключений, логов и `ProblemDetails` писать на английском языке.
15. XML-документация должна описывать пользовательский сценарий, а не техническую реализацию.
16. Документация должна соответствовать фактическому маршруту, DTO и HTTP-кодам.

### Маршруты

17. Использовать ресурсный стиль маршрутов.
18. Route должен отражать ресурс, а не внутреннее имя метода или сервиса.
19. Идентификатор ресурса предпочтительно брать из route parameters, а не из body.
20. Не дублировать один и тот же `id` одновременно в route и body без необходимости.
21. Если дублирование `id` в route и body неизбежно, нужно явно проверять их согласованность.
22. Route parameters должны иметь constraints, например `{id:guid}`.
23. Не использовать query string для идентификатора основного ресурса, если ресурс адресуется напрямую.
24. Query string использовать для фильтрации, сортировки, поиска и пагинации.
25. Не смешивать singular и plural naming без причины.
26. Предпочитать plural resource names: `users`, `orders`, `projects`.
27. Не использовать глаголы в маршрутах, если сценарий выражается стандартным HTTP-методом.
28. Допускаются action-like subroutes только для явных команд или state transitions.

Пример допустимого state transition:

```csharp
[HttpPost("{id:guid}/activation")]
```

### HTTP-методы

29. `GET` использовать для чтения без изменения состояния.
30. `POST` использовать для создания ресурса или запуска команды.
31. `PUT` использовать для полной замены ресурса.
32. `PATCH` использовать для частичного изменения ресурса.
33. `DELETE` использовать для удаления ресурса.
34. Не использовать `GET` для операций, изменяющих состояние.
35. Не использовать `POST` для чтения, если нет веской причины вроде сложного search-запроса с body.

### HTTP-коды

36. Для каждого endpoint явно указывать все ожидаемые HTTP status codes.
37. Для `200 OK` с телом обязательно указывать тип ответа:

```csharp
[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status200OK)]
```

38. Не использовать `[ProducesResponseType(StatusCodes.Status200OK)]`, если `200 OK` возвращает тело.
39. Для `201 Created` с телом обязательно указывать тип ответа.
40. Для успешной операции без тела использовать `204 NoContent`.
41. Не возвращать `200 OK`, если более точным является `201 Created` или `204 NoContent`.
42. `400 BadRequest` использовать для некорректного запроса или ошибок binding/validation.
43. `401 Unauthorized` использовать при отсутствии или некорректности аутентификации.
44. `403 Forbidden` использовать при недостатке прав.
45. `404 NotFound` использовать, если ресурс не найден.
46. `409 Conflict` использовать для конфликтов состояния, конкурентности или уникальности.
47. `422 UnprocessableEntity` использовать только если это принято в проекте как стандарт validation semantics.
48. `500 InternalServerError` не возвращать вручную для обычных ошибок application flow.
49. Для одинаковых сценариев возвращать одинаковые HTTP-коды во всех контроллерах.
50. Все возможные коды ответа должны быть отражены в OpenAPI.

### Ответы

51. Не использовать `Ok(new { ... })` в публичном API.
52. Не использовать анонимные типы в публичном API.
53. Для публичных ответов использовать именованные response DTO.
54. Не возвращать domain/entity модели напрямую из публичного API.
55. Не возвращать EF Core entities из контроллера.
56. Не возвращать внутренние application models, если они не являются частью API-контракта.
57. Для ошибок использовать единый формат, предпочтительно `ProblemDetails` или `ValidationProblemDetails`.
58. Не формировать разные структуры ошибок для одинаковых сценариев.
59. Error response должен быть предсказуемым и документированным.
60. Не раскрывать внутренние детали реализации, stack trace, SQL или инфраструктурные ошибки в API-ответе.

### DTO

61. Request DTO и response DTO должны быть разделены.
62. Все DTO публичного API должны иметь явные `[JsonPropertyName(...)]`.
63. JSON-поля должны использовать единый стиль именования, предпочтительно `camelCase`.
64. DTO не должны содержать бизнес-логику.
65. DTO не должны содержать инфраструктурные зависимости.
66. DTO не должны содержать лишние поля, не относящиеся к API-контракту.
67. Request DTO не должен включать `id` ресурса, если `id` уже передается в route.
68. Response DTO должен быть стабильной частью API-контракта.
69. Для nullable-полей явно отражать nullable semantics в типах и документации.
70. Для обязательных полей использовать `required`, validation attributes или валидатор проекта.
71. Не использовать один и тот же DTO для разных сценариев, если поля, правила или смысл отличаются.

### Валидация

72. Простую shape validation можно задавать через DataAnnotations или валидаторы проекта.
73. Бизнес-валидация должна находиться в application/domain layer, а не в контроллере.
74. Повторяющуюся validation-логику нужно выносить в переиспользуемые компоненты.
75. Не дублировать validation checks в каждом action-методе.
76. Если route `id` и body `id` неизбежно присутствуют одновременно, нужно вернуть `400 BadRequest` при несовпадении.
77. Ошибки валидации должны возвращаться единообразно.

### CancellationToken

78. Каждый async action-метод должен принимать `CancellationToken`.
79. `CancellationToken` должен пробрасываться во все нижние async-вызовы.
80. Не использовать `CancellationToken.None` внутри контроллера без явной причины.
81. Не игнорировать `CancellationToken` в service, repository и client вызовах.

### Application layer interaction

82. Контроллер должен вызывать один application/service use case на один пользовательский сценарий.
83. Контроллер не должен обращаться к repository напрямую, если в проекте есть application/service layer.
84. Контроллер не должен выполнять бизнес-оркестрацию нескольких use cases без явной причины.
85. Контроллер должен преобразовывать результат application layer в HTTP-ответ.
86. Application layer должен возвращать результат, достаточный для выбора HTTP-кода без бизнес-логики в контроллере.
87. Для результата use case предпочтительно использовать typed result object, enum status или discriminated union pattern.

### Mapping

88. Mapping должен быть простым и единообразным.
89. Сложный mapping нужно выносить из контроллера.
90. Не дублировать одинаковый mapping в нескольких action-методах.
91. Mapping response DTO может быть реализован через статический `Map`, mapper или extension method по стандарту проекта.
92. Mapping request DTO в command/query должен быть явным и читаемым.

### Порядок методов

93. Action-методы располагать в логическом порядке: сначала чтение, затем изменения.
94. Внутри чтения сначала располагать list/search endpoints, затем `GetById`.
95. Внутри изменений располагать методы по жизненному циклу сценария:

- create;
- update;
- state transitions;
- remove;
- batch operations.

96. Связанные endpoint держать рядом.
97. Контроллер должен читаться сверху вниз по основным пользовательским сценариям.

### Нейминг

98. Имена action-методов должны отражать намерение.
99. Использовать единый стиль именования: `GetById`, `Create`, `UpdateEmail`, `Delete`, `Activate`.
100. Не использовать имена вроде `Do`, `Process`, `Handle`, если они не раскрывают сценарий.
101. Request DTO называть по сценарию: `CreateUserRequestDto`, `UpdateUserEmailRequestDto`.
102. Response DTO называть по ресурсу или сценарию: `UserResponseDto`, `CreateUserResponseDto`.
103. Command/query модели называть по намерению: `CreateUserCommand`, `GetUserByIdQuery`.

### OpenAPI и контракт

104. OpenAPI должен соответствовать фактическому поведению endpoint.
105. Все публичные DTO должны корректно отображаться в OpenAPI.
106. Все публичные HTTP-коды должны быть указаны через `ProducesResponseType`.
107. Breaking changes в маршрутах, DTO, обязательных полях и HTTP-кодах делать только через migration strategy.
108. Любое изменение API-контракта должно проверяться на совместимость клиентов.
109. При необходимости использовать версионирование API.
110. Старый endpoint нельзя удалять без согласованного deprecation/migration plan.

### Безопасность

111. Для защищенных endpoint явно использовать `[Authorize]` или policy-based authorization по стандарту проекта.
112. Для публичных endpoint без авторизации явно понимать причину публичности.
113. Не принимать client-controlled поля, которые должны определяться сервером.
114. Не доверять user id, tenant id, role или permission из body, если они должны определяться из auth context.
115. Не возвращать чувствительные данные в response DTO.
116. Не логировать secrets, tokens, passwords, персональные данные без необходимости.

### Логи и ошибки

117. Тексты логов писать на английском языке.
118. Тексты ошибок писать на английском языке.
119. Логи должны помогать диагностировать сценарий, но не раскрывать чувствительные данные.
120. Не логировать каждую успешную CRUD-операцию без причины.
121. Не перехватывать все исключения в контроллере, если для этого есть global exception handler.
122. Исключения инфраструктуры должны обрабатываться централизованно.

### Тестируемость

123. Контракт контроллера должен быть покрыт тестами.
124. Тесты должны проверять основные HTTP-коды.
125. Тесты должны проверять shape response DTO.
126. Тесты должны проверять validation scenarios.
127. Тесты должны проверять, что `CancellationToken` пробрасывается в нижний слой, если это принято в проекте.
128. При изменении endpoint нужно обновлять связанные тесты.

## Анти-паттерны

Не допускается:

1. Бизнес-логика в контроллере.
2. Вычисления и бизнес-решения внутри action-метода.
3. Прямое обращение к EF Core `DbContext` из контроллера, если есть application/service layer.
4. Возврат domain/entity моделей наружу.
5. Возврат анонимных объектов через `Ok(new { ... })`.
6. `[ProducesResponseType(StatusCodes.Status200OK)]` для ответа с телом.
7. Игнорирование `CancellationToken`.
8. Дублирование `id` в route и body без необходимости.
9. Разные error response formats для одинаковых ошибок.
10. Смешивание route styles без причины.
11. Непредсказуемые HTTP-коды.
12. Дублирование validation/mapping логики в каждом методе.
13. Использование DTO одновременно для create, update и response, если сценарии отличаются.
14. Слишком длинные action-методы.
15. Скрытые breaking changes без migration strategy.
16. Тексты ошибок и логов на русском языке.
17. Возврат чувствительных данных в response DTO.
18. Ручная обработка всех исключений в каждом action-методе.

## Шаблон контроллера

```csharp
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[ApiController]
[Authorize]
[Route("api/users")]
[Produces("application/json")]
public sealed class UsersController(IUsersService usersService) : ControllerBase
{
	/// <summary>
	/// Возвращает пользователя по идентификатору.
	/// </summary>
	/// <param name="id">Идентификатор пользователя.</param>
	/// <param name="ct">Токен отмены операции.</param>
	/// <returns>Пользователь.</returns>
	[HttpGet("{id:guid}")]
	[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status200OK)]
	[ProducesResponseType(StatusCodes.Status401Unauthorized)]
	[ProducesResponseType(StatusCodes.Status403Forbidden)]
	[ProducesResponseType(StatusCodes.Status404NotFound)]
	public async Task<IActionResult> GetById([FromRoute] Guid id, CancellationToken ct)
	{
		UserDto? user = await usersService.GetByIdAsync(id, ct);

		if (user is null)
		{
			return NotFound();
		}

		return Ok(UserResponseDto.Map(user));
	}

	/// <summary>
	/// Создает нового пользователя.
	/// </summary>
	/// <param name="request">Данные для создания пользователя.</param>
	/// <param name="ct">Токен отмены операции.</param>
	/// <returns>Созданный пользователь.</returns>
	[HttpPost]
	[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status201Created)]
	[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
	[ProducesResponseType(StatusCodes.Status401Unauthorized)]
	[ProducesResponseType(StatusCodes.Status403Forbidden)]
	[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
	public async Task<IActionResult> Create([FromBody] CreateUserRequestDto request, CancellationToken ct)
	{
		CreateUserResult result = await usersService.CreateAsync(request.ToCommand(), ct);

		if (result.Status == CreateUserStatus.EmailAlreadyExists)
		{
			return Conflict(new ProblemDetails
			{
				Title = "Email already exists.",
				Detail = "A user with the specified email already exists.",
				Status = StatusCodes.Status409Conflict,
			});
		}

		UserResponseDto response = UserResponseDto.Map(result.User);

		return CreatedAtAction(nameof(GetById), new { id = response.Id }, response);
	}

	/// <summary>
	/// Обновляет email пользователя.
	/// </summary>
	/// <param name="id">Идентификатор пользователя.</param>
	/// <param name="request">Данные для обновления email.</param>
	/// <param name="ct">Токен отмены операции.</param>
	/// <returns>Обновленный пользователь.</returns>
	[HttpPatch("{id:guid}/email")]
	[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status200OK)]
	[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
	[ProducesResponseType(StatusCodes.Status401Unauthorized)]
	[ProducesResponseType(StatusCodes.Status403Forbidden)]
	[ProducesResponseType(StatusCodes.Status404NotFound)]
	[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
	public async Task<IActionResult> UpdateEmail(
		[FromRoute] Guid id,
		[FromBody] UpdateUserEmailRequestDto request,
		CancellationToken ct)
	{
		UpdateUserEmailResult result = await usersService.UpdateEmailAsync(id, request.ToCommand(), ct);

		return result.Status switch
		{
			UpdateUserEmailStatus.NotFound => NotFound(),
			UpdateUserEmailStatus.EmailAlreadyExists => Conflict(new ProblemDetails
			{
				Title = "Email already exists.",
				Detail = "A user with the specified email already exists.",
				Status = StatusCodes.Status409Conflict,
			}),
			_ => Ok(UserResponseDto.Map(result.User)),
		};
	}

	/// <summary>
	/// Удаляет пользователя.
	/// </summary>
	/// <param name="id">Идентификатор пользователя.</param>
	/// <param name="ct">Токен отмены операции.</param>
	/// <returns>Результат удаления пользователя.</returns>
	[HttpDelete("{id:guid}")]
	[ProducesResponseType(StatusCodes.Status204NoContent)]
	[ProducesResponseType(StatusCodes.Status401Unauthorized)]
	[ProducesResponseType(StatusCodes.Status403Forbidden)]
	[ProducesResponseType(StatusCodes.Status404NotFound)]
	public async Task<IActionResult> Delete([FromRoute] Guid id, CancellationToken ct)
	{
		bool deleted = await usersService.DeleteAsync(id, ct);

		if (!deleted)
		{
			return NotFound();
		}

		return NoContent();
	}
}

public sealed class CreateUserRequestDto
{
	[JsonPropertyName("email")]
	[Required]
	[EmailAddress]
	public required string Email { get; init; }

	[JsonPropertyName("name")]
	[Required]
	[StringLength(100, MinimumLength = 1)]
	public required string Name { get; init; }

	public CreateUserCommand ToCommand()
	{
		return new CreateUserCommand(Email, Name);
	}
}

public sealed class UpdateUserEmailRequestDto
{
	[JsonPropertyName("email")]
	[Required]
	[EmailAddress]
	public required string Email { get; init; }

	public UpdateUserEmailCommand ToCommand()
	{
		return new UpdateUserEmailCommand(Email);
	}
}

public sealed class UserResponseDto
{
	[JsonPropertyName("id")]
	public required Guid Id { get; init; }

	[JsonPropertyName("email")]
	public required string Email { get; init; }

	[JsonPropertyName("name")]
	public required string Name { get; init; }

	public static UserResponseDto Map(UserDto user)
	{
		return new UserResponseDto
		{
			Id = user.Id,
			Email = user.Email,
			Name = user.Name,
		};
	}
}

public interface IUsersService
{
	Task<UserDto?> GetByIdAsync(Guid id, CancellationToken ct);

	Task<CreateUserResult> CreateAsync(CreateUserCommand command, CancellationToken ct);

	Task<UpdateUserEmailResult> UpdateEmailAsync(
		Guid id,
		UpdateUserEmailCommand command,
		CancellationToken ct);

	Task<bool> DeleteAsync(Guid id, CancellationToken ct);
}

public sealed record CreateUserCommand(string Email, string Name);

public sealed record UpdateUserEmailCommand(string Email);

public sealed record UserDto(Guid Id, string Email, string Name);

public sealed record CreateUserResult(CreateUserStatus Status, UserDto User);

public enum CreateUserStatus
{
	Created,
	EmailAlreadyExists,
}

public sealed record UpdateUserEmailResult(UpdateUserEmailStatus Status, UserDto User);

public enum UpdateUserEmailStatus
{
	Updated,
	NotFound,
	EmailAlreadyExists,
}
```

## Пример проверки route id и body id

Такой подход нежелателен для нового API, но может потребоваться для обратной совместимости.

```csharp
[HttpPut("{id:guid}")]
[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public async Task<IActionResult> Update(
	[FromRoute] Guid id,
	[FromBody] UpdateUserRequestDto request,
	CancellationToken ct)
{
	if (id != request.Id)
	{
		ModelState.AddModelError("id", "Route id must match body id.");
		return ValidationProblem(ModelState);
	}

	UpdateUserResult result = await usersService.UpdateAsync(request.ToCommand(), ct);

	if (result.Status == UpdateUserStatus.NotFound)
	{
		return NotFound();
	}

	return Ok(UserResponseDto.Map(result.User));
}
```

Для нового API предпочтительный вариант — убрать `id` из body и оставить его только в route.

## Алгоритм работы агента

При создании или изменении контроллера:

1. Определи, является ли изменение внутренним refactoring или изменением API-контракта.
2. Если меняется route, DTO, обязательные поля, nullable semantics или HTTP-коды, считай это contract change.
3. Для contract change проверь, является ли оно breaking change.
4. Для breaking change предложи migration strategy:
   - новая версия endpoint;
   - временная обратная совместимость;
   - deprecation старого endpoint;
   - обновление клиентов;
   - обновление OpenAPI и тестов.
5. Проверь, что route оформлен ресурсно и `id` берется из route.
6. Проверь, что request DTO не дублирует route `id` без необходимости.
7. Проверь, что все DTO имеют `JsonPropertyName` и единый `camelCase` стиль.
8. Проверь, что action не содержит бизнес-логики.
9. Проверь, что `CancellationToken` принимается и пробрасывается вниз.
10. Проверь, что все response status codes указаны через `ProducesResponseType`.
11. Проверь, что все `200 OK` и `201 Created` с телом имеют typed response.
12. Проверь, что ошибки возвращаются в едином формате.
13. Проверь, что методы расположены в логическом порядке.
14. Проверь, что XML-документация соответствует endpoint.
15. Проверь, что OpenAPI и тесты должны быть обновлены.

## Чеклист перед завершением

Перед тем как считать контроллер готовым, проверь:

- [ ] Контроллер не содержит бизнес-логики.
- [ ] Зависимости внедрены через primary constructor, где это возможно.
- [ ] Action-методы короткие и соответствуют одному сценарию.
- [ ] Каждый публичный action имеет XML `summary`, `param`, `returns`.
- [ ] XML-документация написана на русском языке.
- [ ] Ошибки, логи и `ProblemDetails` написаны на английском языке.
- [ ] Route оформлен в ресурсном стиле.
- [ ] Route parameters имеют constraints.
- [ ] `id` ресурса берется из route, а не из body.
- [ ] `id` не дублируется в route и body без необходимости.
- [ ] Если `id` дублируется, есть явная проверка согласованности.
- [ ] Каждый async action принимает `CancellationToken`.
- [ ] `CancellationToken` проброшен во все нижние async-вызовы.
- [ ] Все публичные HTTP-коды указаны через `ProducesResponseType`.
- [ ] Все `200 OK` с телом имеют `ProducesResponseType(typeof(...), StatusCodes.Status200OK)`.
- [ ] Все `201 Created` с телом имеют typed response.
- [ ] Нет `Ok(new { ... })`.
- [ ] Нет анонимных типов в публичном API.
- [ ] Domain/entity модели не возвращаются наружу.
- [ ] Request DTO и response DTO разделены.
- [ ] DTO имеют `[JsonPropertyName(...)]`.
- [ ] JSON-поля используют единый `camelCase` стиль.
- [ ] Ошибки возвращаются через единый формат.
- [ ] Возможные `401` и `403` отражены для защищенных endpoint.
- [ ] Методы расположены в логическом порядке.
- [ ] OpenAPI соответствует фактическому контракту.
- [ ] Тесты синхронизированы с изменениями.
- [ ] Breaking changes имеют migration strategy.
- [ ] Нет строк длиннее 120 символов.

## Критерии PR-ревью

При ревью контроллера обязательно проверить:

1. Не появился ли business logic leakage в presentation layer.
2. Не изменился ли API-контракт без явного описания.
3. Не стал ли change breaking для клиентов.
4. Не добавлен ли `id` в body там, где он должен быть route parameter.
5. Не появились ли анонимные response objects.
6. Не возвращаются ли domain/entity модели наружу.
7. Все ли HTTP-коды документированы и предсказуемы.
8. Все ли DTO имеют корректный JSON contract.
9. Проброшен ли `CancellationToken`.
10. Обновлены ли OpenAPI и тесты.

## Минимальный эталон endpoint

```csharp
/// <summary>
/// Возвращает пользователя по идентификатору.
/// </summary>
/// <param name="id">Идентификатор пользователя.</param>
/// <param name="ct">Токен отмены операции.</param>
/// <returns>Пользователь.</returns>
[HttpGet("{id:guid}")]
[ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public async Task<IActionResult> GetById([FromRoute] Guid id, CancellationToken ct)
{
	UserDto? user = await usersService.GetByIdAsync(id, ct);

	if (user is null)
	{
		return NotFound();
	}

	return Ok(UserResponseDto.Map(user));
}
```

## Минимальный эталон DTO

```csharp
public sealed class UserResponseDto
{
	[JsonPropertyName("id")]
	public required Guid Id { get; init; }

	[JsonPropertyName("email")]
	public required string Email { get; init; }

	[JsonPropertyName("name")]
	public required string Name { get; init; }
}
```

## Основной принцип

Контроллер должен быть тонким, предсказуемым и контрактно-ориентированным.

Если в контроллере появляется бизнес-логика, сложное ветвление, повторяющийся mapping или ручная обработка
инфраструктурных ошибок, это сигнал вынести код в application layer, validator, mapper или middleware.
