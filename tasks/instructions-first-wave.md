# Задача: развить слой shared instructions в backend-agent-kit

Дата создания: 06.05.2026  
Статус: в работе  
Актуализировано: 06.05.2026

## Цель

Собрать следующую практическую волну shared instruction-файлов для `tools/backend-agent-kit/instructions/`,
чтобы в репозитории был не только базовый catalog общих правил, но и устойчивый набор
file-based инструкций для частых backend-сценариев.

Результат должен дать:

- расширяемый каталог shared instructions без хаотичного роста;
- явное покрытие типовых backend-срезов через `applyTo`;
- меньше repo-local дубликатов одних и тех же правил;
- более предсказуемое поведение Copilot в API, тестах, миграциях и документации.

## Текущее состояние каталога

В `backend-agent-kit` уже есть baseline shared instructions:

- `shared-code-style-conventions.instructions.md`
- `shared-commit-messages.instructions.md`
- `shared-errors.instructions.md`
- `shared-logs.instructions.md`
- `shared-skill-writing.instructions.md`
- `shared-summary.instructions.md`

Следствие:

- не нужно заново создавать инструкции на эти же темы;
- новая волна должна закрывать реальные пробелы, а не дублировать уже существующий baseline;
- при добавлении новых instruction-файлов нужно отдельно проверять пересечение по теме и по `applyTo`.

## Контекст и ограничения

Слой `instructions/` нужен для file-based always-on правил,
которые привязаны к типу файла, технологии, фреймворку или части структуры репозитория.

Важно сохранить границы слоев:

- `instructions/` - для постоянных правил и стандартов по файлам и технологиям;
- `prompts/` - для разового slash-command запуска под одну задачу;
- `agents/` - для отдельной persona, tool-профиля, handoff и устойчивого поведения;
- `skills/` - для многошагового workflow с примерами, supporting docs и скриптами;
- `copilot-instructions.md` - для project-wide always-on правил верхнего уровня.

Следствие:

- не превращать instruction в task checklist или workflow;
- не дублировать в instruction глобальные правила, которые уже живут в `copilot-instructions.md`;
- не плодить несколько instruction-файлов с почти одинаковыми `applyTo` и одной темой;
- не переносить в shared layer repo-specific соглашения Leo.Products;
- не делать слишком широкие `applyTo`, если из-за этого начнут конфликтовать правила из разных instruction-файлов.

## Критерии хорошего shared instruction

Каждая новая instruction должна:

- покрывать одну устойчивую тему;
- быть полезной нескольким backend-сервисам, а не одному модулю;
- иметь понятный и неслучайный `applyTo`;
- содержать короткие, прикладные правила без воды;
- не дублировать уже существующие shared instructions;
- не конфликтовать по смыслу с `copilot-instructions.md`;
- не зависеть от локальной инфраструктуры, naming или bounded context Leo.Products.

## Первая волна расширения shared instructions

### 1. shared-dotnet-api.instructions.md

Статус: [ ] не начато  
Приоритет: высокий  
Кандидат `applyTo`: `**/Controllers/**/*.cs`, `**/*Controller.cs`

Назначение:

- правила для ASP.NET Core API-файлов;
- контракт DTO, HTTP-коды, ошибки, `CancellationToken`, роутинг, response shape.

Что должно попасть внутрь:

- не возвращать доменные сущности напрямую;
- использовать request/response DTO для внешнего контракта;
- явно описывать статусы и error-paths;
- не терять `CancellationToken`;
- не размывать API-контракт логикой инфраструктуры.

### 2. shared-tests.instructions.md

Статус: [ ] не начато  
Приоритет: высокий  
Кандидат `applyTo`: `**/*Tests*/**/*.cs`

Назначение:

- общие правила для unit, integration и validator tests.

Что должно попасть внутрь:

- именование тестов;
- границы ответственности теста;
- правила по setup/fixture;
- когда писать unit, а когда integration;
- как избегать хрупких assertion patterns.

### 3. shared-openapi-contract.instructions.md

Статус: [ ] не начато  
Приоритет: высокий  
Кандидат `applyTo`: controller DTO, request/response контракты, `contracts/openapi/**/*.json`

Назначение:

- правила для стабильности внешнего контракта и OpenAPI drift control.

Что должно попасть внутрь:

- backward compatibility ожидания;
- осторожность с rename/remove полей;
- синхронизация DTO, controller behavior и contract artifacts;
- явная фиксация breaking change risk.

### 4. shared-efcore-migrations.instructions.md

Статус: [ ] не начато  
Приоритет: средний  
Кандидат `applyTo`: `**/Migrations/**/*.cs`, EF configuration files

Назначение:

- правила для миграций, индексов, constraint changes и data safety.

Что должно попасть внутрь:

- не смешивать risky schema change и unrelated cleanup;
- явно помечать destructive operations;
- проверять индексы, default values и backfill assumptions;
- помнить про rollout и совместимость со старым кодом на промежуточном этапе.

### 5. shared-documentation.instructions.md

Статус: [ ] не начато  
Приоритет: средний  
Кандидат `applyTo`: `**/*.md`, кроме узкоспециализированных skill-файлов

Назначение:

- единые правила для README и внутренней инженерной документации.

Что должно попасть внутрь:

- писать только то, что подтверждается кодом или контрактом;
- не превращать docs в маркетинговый текст;
- фиксировать ограничения, rollout notes и реальные команды/пути;
- поддерживать структуру, удобную для внутренней команды.

## Вторая волна shared instructions

Эти темы полезны, но их лучше брать после первой волны,
когда базовое покрытие API, tests, OpenAPI, migrations и docs уже собрано.

### 1. shared-validation.instructions.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- правила для validator-файлов и validation flow.

### 2. shared-di-registration.instructions.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- правила для dependency injection registration и composition root.

### 3. shared-http-clients.instructions.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- правила для внешних HTTP-клиентов, retry, timeout и error handling на integration boundaries.

### 4. shared-options-config.instructions.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- правила для options-классов, конфигурации и безопасного использования настроек.

### 5. shared-background-processing.instructions.md

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- правила для background jobs, schedulers и long-running processing logic.

## Что не надо выносить в shared instructions

Держать локально, а не в shared layer:

- правила, завязанные на конкретный bounded context Leo.Products;
- naming и архитектурные ограничения, которые уже живут в local repo и не обобщаются на другие сервисы;
- operational runbooks и task-specific инструкции;
- workflow-описания, которые лучше оформить как `skills/` или `prompts/`;
- team-specific process notes, не привязанные к типу файла или технологии.

## Рекомендуемый порядок заполнения

Предлагаемый первый practical batch:

1. `shared-dotnet-api.instructions.md`
2. `shared-tests.instructions.md`
3. `shared-openapi-contract.instructions.md`
4. `shared-efcore-migrations.instructions.md`

Следующий batch:

1. `shared-documentation.instructions.md`
2. `shared-validation.instructions.md`
3. `shared-di-registration.instructions.md`
4. `shared-http-clients.instructions.md`

## Шаблон для каждого instruction-файла

Использовать как минимальную заготовку:

```md
---
name: <short-name>
description: "Короткое описание темы instruction"
applyTo: '**/<pattern>/**'
---

# <Instruction Title>

## Цель

- ...

## Когда использовать

- ...

## Обязательные правила

1. ...
2. ...

## Рекомендуемые практики

1. ...

## Анти-паттерны

1. ...

## Проверка перед завершением

1. ...
```

## Definition of Done

Слой считается достаточно развитым на этой волне, если:

- проведена инвентаризация текущего baseline shared instructions;
- добавлено не меньше 3-4 новых instruction-файлов по реально общим темам;
- у каждого нового instruction-файла есть осмысленный `applyTo`;
- между instruction-файлами нет явного смыслового конфликта и чрезмерного overlap;
- новые инструкции не дублируют `copilot-instructions.md` и существующий baseline;
- sync в consumer `.github/instructions/` проходит без drift.

## Чек-лист выполнения

- [ ] Зафиксировать текущий baseline shared instructions.
- [ ] Выделить реальные пробелы в каталоге.
- [ ] Для каждого нового instruction-файла определить тему и `applyTo`.
- [ ] Проверить, не пересекается ли новая тема с уже существующими shared instructions.
- [ ] Создать first batch instruction-файлов в `tools/backend-agent-kit/instructions/`.
- [ ] Прогнать sync в consumer repo.
- [ ] Проверить `.github/instructions/` и validate-only.
- [ ] Закоммитить shared instruction batch и consumer sync отдельными коммитами.