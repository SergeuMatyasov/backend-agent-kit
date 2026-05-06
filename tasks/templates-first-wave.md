# Задача: развить слой shared templates в backend-agent-kit

Дата создания: 06.05.2026  
Статус: в работе  
Актуализировано: 06.05.2026

## Цель

Собрать следующую практическую волну shared templates для `tools/backend-agent-kit/templates/`,
чтобы в репозитории был не только базовый набор текстовых заготовок,
но и устойчивый каталог reusable шаблонов для prompts, skills и supporting docs.

Результат должен дать:

- канонические reusable text artifacts для повторяемых engineering workflows;
- меньше дублирования одних и тех же markdown-структур внутри skills, prompts и docs;
- понятные stable templates для review, reporting, rollout и incident сценариев;
- backlog для controlled expansion слоя templates без смешения с active Copilot primitives.

## Текущее состояние каталога

Сейчас в `templates/` уже есть baseline templates:

- `module-analysis-template.md`
- `readme-flow-template.md`

Следствие:

- не нужно плодить шаблоны с тем же смыслом под другим именем;
- новая волна должна закрывать реальные reusable структуры, которые пригодятся нескольким skills, prompts или docs;
- перед созданием нового template нужно сначала проверить, не живет ли уже каноническая заготовка в `templates/` или внутри существующего skill.

## Контекст и ограничения

Слой `templates/` нужен для reusable text artifacts,
которые не должны быть instructions, prompts, agents, hooks или skills сами по себе,
но полезны как канонические текстовые структуры.

Это правильный слой, если нужен:

- стабильный markdown-шаблон;
- reusable checklist;
- report skeleton;
- canonical output structure для skill или prompt;
- заготовка документа, summary или incident report.

Важно сохранить границы слоев:

- `instructions/` - для always-on file-based правил;
- `prompts/` - для slash-command запуска и task-specific UX;
- `agents/` - для роли, tool-профиля и handoff behavior;
- `skills/` - для repeatable multi-step workflow с supporting materials;
- `templates/` - для канонических reusable text artifacts без собственной логики исполнения;
- `docs/` - для human-facing reference documentation, а не для чистых заготовок.

Следствие:

- не превращать template в workflow-инструкцию;
- не переносить в template правила, которые должны жить в instruction или `copilot-instructions.md`;
- не делать template, если нужен полноценный skill с decision flow;
- не держать дубли одинаковых markdown-структур в нескольких skills/prompts, если можно выделить один canonical template;
- не выносить в shared templates repo-specific заготовки Leo.Products.

Отдельное ограничение текущего контракта:

- `templates/` пока не раскладывается напрямую в consumer `.github/*` слой;
- если prompt или skill уже использует template, внутри него допустимо держать сокращенную совместимую копию;
- каноническая версия при этом должна жить в `templates/`.

## Критерии хорошего shared template

Каждый новый template должен:

- быть текстовой структурой, а не логикой выполнения;
- иметь устойчивую и понятную форму;
- переиспользоваться несколькими prompts, skills или docs;
- быть полезным нескольким backend-сервисам;
- не зависеть от одного bounded context или локальной операционки Leo.Products;
- быть канонической версией структуры, а не очередной локальной копией.

Признак того, что template действительно нужен:

- одна и та же markdown-структура уже повторяется или явно начнет повторяться;
- эту структуру удобно ссылать из разных skills/prompts/docs;
- шаблон полезен сам по себе, даже без привязки к одной конкретной persona или tool-конфигурации.

## Первая волна расширения shared templates

### 1. release-readiness-template.md

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- канонический шаблон итогового release readiness отчета.

Что должно быть внутри:

- status: Ready / Ready with risks / Not ready;
- blockers;
- key risks;
- rollout notes;
- required validation;
- pre-release checklist.

Где может переиспользоваться:

- future release-readiness skill;
- release-readiness prompt;
- docs по change assessment.

### 2. incident-first-report-template.md

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- шаблон первой структурированной сводки по production-инциденту.

Что должно быть внутри:

- symptoms;
- scope;
- likely causes;
- observability gaps;
- first safe plan;
- open questions.

Где может переиспользоваться:

- incident-triage skill;
- incident-first-report prompt;
- incident-related docs.

### 3. regression-review-template.md

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- шаблон отчета по сохранению старого поведения после refactor, migration или contract changes.

Что должно быть внутри:

- preserved behavior;
- risky deltas;
- missing validation;
- required tests;
- recommendation.

Где может переиспользоваться:

- regression-review skill;
- regression-check prompt;
- change review docs.

### 4. performance-investigation-template.md

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- шаблон отчета по первичному performance investigation.

Что должно быть внутри:

- symptoms;
- current evidence;
- likely bottlenecks;
- what to measure next;
- missing observability;
- first optimization hypotheses.

Где может переиспользоваться:

- performance-investigation skill;
- performance-first-pass prompt;
- supporting docs.

### 5. openapi-review-template.md

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- шаблон review отчета по API contract changes и OpenAPI drift.

Что должно быть внутри:

- affected endpoints;
- contract deltas;
- breaking change risk;
- compatibility notes;
- missing checks;
- recommended next steps.

Где может переиспользоваться:

- openapi-review skill;
- openapi-drift-review prompt;
- contract docs.

### 6. commit-split-template.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- шаблон разбиения большого diff на commit slices.

Что должно быть внутри:

- slice name;
- included files or scope;
- rationale;
- dependencies;
- draft commit title.

Где может переиспользоваться:

- commit-splitting skill;
- commit-split-plan prompt;
- docs по change slicing.

## Вторая волна shared templates

Эти шаблоны полезны, но их лучше брать после первой волны,
когда появится реальный reuse в skills и prompts.

### 1. tech-debt-sweep-template.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- шаблон cleanup-аудита: safe to remove, likely stale, needs confirmation.

### 2. logging-review-template.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- шаблон отчета по signal quality, missing context и noisy logs.

### 3. error-alignment-template.md

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- шаблон отчета по exceptions, error messages и error contract alignment.

### 4. pr-summary-template.md

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- краткая инженерная структура описания PR без маркетинговой воды.

### 5. release-notes-template.md

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- шаблон release notes с фокусом на behavior change и rollout notes.

## Что не надо выносить в shared templates

Держать локально или в других слоях, а не в shared templates:

- repo-specific шаблоны Leo.Products;
- operational runbooks с локальной инфраструктурой;
- полноценные how-to документы, которые лучше оформить как `docs/`;
- file-based правила, которые должны жить в `instructions/`;
- workflow-процедуры, которым нужен `skills/` слой;
- tool-specific slash-command тексты, если это уже prompt, а не reusable structure.

## Рекомендуемый порядок заполнения

Предлагаемый первый practical batch:

1. `release-readiness-template.md`
2. `incident-first-report-template.md`
3. `regression-review-template.md`
4. `performance-investigation-template.md`
5. `openapi-review-template.md`

Следующий batch:

1. `commit-split-template.md`
2. `tech-debt-sweep-template.md`
3. `logging-review-template.md`
4. `error-alignment-template.md`

## Шаблон для каждого template-файла

Использовать как минимальную заготовку:

```md
# Template Title

## Section 1

## Section 2

## Section 3
```

Если шаблон нужен как checklist, допустима структура:

```md
# Checklist Title

- [ ] Item 1
- [ ] Item 2
- [ ] Item 3
```

Если шаблону нужна поясняющая рамка, она должна быть короткой.
Как только файл начинает превращаться в полноценный workflow или guide,
нужно отдельно проверить, не является ли он на самом деле `docs/` или `skills/` артефактом.

## Definition of Done

Слой считается достаточно развитым на этой волне, если:

- проведена инвентаризация текущего baseline shared templates;
- выбраны только те структуры, которые реально повторяются или явно будут повторяться;
- добавлено не меньше 3-5 новых reusable templates;
- хотя бы часть новых templates реально упомянута в skills, prompts или docs;
- templates не дублируют существующие docs и workflow-артефакты;
- новый каталог остается понятным и не засоряется локальными one-off шаблонами.

## Чек-лист выполнения

- [ ] Зафиксировать текущий baseline shared templates.
- [ ] Выделить реальные повторяющиеся структуры в skills, prompts и docs.
- [ ] Для каждого кандидата проверить, нужен ли именно template, а не prompt/skill/doc.
- [ ] Создать first batch template-файлов в `tools/backend-agent-kit/templates/`.
- [ ] При необходимости обновить skills/prompts/docs ссылками на новые templates.
- [ ] Проверить, не появился ли лишний дублирующий markdown в соседних слоях.
- [ ] Закоммитить shared template batch и consumer sync, если он понадобится отдельно.