# Задача: развить слой shared skills в backend-agent-kit

Дата создания: 06.05.2026  
Статус: в работе  
Актуализировано: 06.05.2026

## Цель

Собрать следующую практическую волну shared skills для `tools/backend-agent-kit/skills/`,
чтобы каталог покрывал не только clean architecture и code quality темы,
но и сложные повторяемые backend workflow, где одной инструкции или prompt уже недостаточно.

Результат должен дать:

- переносимые multi-step capabilities для нескольких backend-сервисов;
- skill-каталог без искусственного дублирования prompt/agent/instruction слоев;
- reusable workflow-артефакты: примеры, checklist, templates, sample inputs/outputs, scripts;
- понятный backlog для controlled expansion каталога.

## Текущее состояние каталога

Сейчас слой `skills/` уже хорошо покрывает несколько областей.

### Clean architecture и code quality

- `clean-architecture-placement`
- `clean-code-functions`
- `clean-code-naming`
- `clean-code-principles`
- `clean-code-refactoring`
- `clean-code-solid`
- `infra-logic-extraction`
- `module-analysis`
- `migration-principles`
- `stepwise-clean-architecture-migration`

### Application и domain workflow

- `mediator-commands-queries`
- `domain-entity-addition`
- `validators`

### Web API и contract surface

- `controllers`
- `controllers-contract-openapi`
- `controllers-testing`
- `professional-controllers`

### Testing и documentation

- `unit-testing`
- `integration-testing`
- `readme-documentation`

Следствие:

- не нужно создавать skill только ради повторения уже покрытых тем;
- новая волна должна закрывать реальные пробелы, а не плодить соседние skills с тем же смыслом;
- перед добавлением нового skill нужно сначала проверить, не достаточно ли уже существующего skill + agent/prompt поверх него.

## Контекст и ограничения

Слой `skills/` нужен для переносимых multi-step workflow,
когда одной file-based instruction мало и нужны supporting resources.

Это правильный слой, если нужны:

- пошаговая процедура;
- decision flow;
- примеры и анти-примеры;
- reusable checklist;
- sample inputs/outputs;
- templates;
- scripts, на которые skill ссылается.

Важно сохранить границы слоев:

- `instructions/` - для always-on file-based правил;
- `prompts/` - для коротких slash-command запусков с одним outcome;
- `agents/` - для роли, tool-профиля, handoff и устойчивого поведения;
- `skills/` - для repeatable workflow с supporting materials;
- `copilot-instructions.md` - для project-wide always-on правил верхнего уровня.

Следствие:

- не превращать skill в набор общих правил, если это скорее instruction;
- не делать skill ради одной короткой slash-команды, если это prompt;
- не форсить skill там, где нужна только persona и boundaries поведения, а не reusable workflow;
- не выносить в shared skill repo-specific процесс Leo.Products;
- не дублировать один и тот же workflow одновременно в нескольких skills с разными именами.

## Критерии хорошего shared skill

Каждый новый skill должен:

- покрывать один устойчивый repeatable workflow;
- быть полезным нескольким backend-сервисам, а не одному доменному модулю;
- содержать конкретные шаги принятия решений;
- иметь понятный `name` и `description`;
- по возможности включать supporting artifacts, если без них skill теряет смысл;
- не дублировать существующие skills;
- не подменять собой agent, prompt или instruction слой.

Признак того, что skill действительно нужен:

- workflow сложный и многошаговый;
- к нему полезно приложить checklist, шаблон, sample input/output или script;
- этот сценарий будет повторяться в нескольких change sets и сервисах.

## Первая волна расширения shared skills

Ниже кандидаты на skills, которые логично дополняют уже существующий каталог.
Их нужно создавать только если после проверки действительно нужен именно skill, а не просто agent/prompt.

### 1. openapi-review

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- полный workflow проверки API-контракта и риска OpenAPI drift;
- сравнение controller changes, DTO changes и contract artifacts;
- выделение breaking changes и migration notes.

Почему это кандидат именно в skills:

- здесь полезны repeatable checklist и sample outputs;
- можно приложить шаблон contract review summary;
- можно связать с примерами drift-проверок и checklist совместимости.

Возможные артефакты внутри skill:

- `SKILL.md`
- checklist для contract review
- шаблон итогового отчета
- sample diff scenarios

### 2. release-readiness

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- workflow проверки готовности change set к выпуску;
- миграции, конфиги, health checks, rollout notes, compatibility assumptions, validation scope.

Почему это кандидат именно в skills:

- здесь полезен reusable release checklist;
- можно держать шаблон readiness summary;
- workflow повторяемый и многосоставный.

Возможные артефакты внутри skill:

- release checklist
- шаблон readiness report
- rollout risk matrix

### 3. incident-triage-playbook

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- пошаговый workflow для первичного triage production-инцидента;
- сбор симптомов, scope, вероятных причин, observability gaps и first safe plan.

Почему это кандидат именно в skills:

- triage хорошо поддерживается checklist-формой;
- полезны шаблоны symptom capture и mitigation report;
- workflow повторяется, но не сводится к одной команде.

Возможные артефакты внутри skill:

- incident checklist
- шаблон first report
- шаблон hypotheses table

### 4. performance-investigation

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- workflow разбора жалобы «медленно работает»;
- различение bottleneck между БД, HTTP, сериализацией, бизнес-логикой и отсутствием observability.

Почему это кандидат именно в skills:

- нужны decision rules и measurement checklist;
- полезны sample investigation outputs;
- это стабильный, переиспользуемый диагностический сценарий.

Возможные артефакты внутри skill:

- measurement checklist
- шаблон bottleneck report
- example investigation outcomes

### 5. regression-review

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- workflow проверки сохранения старого поведения после рефакторинга, миграции или contract changes.

Почему это кандидат именно в skills:

- здесь полезны типовые категории preserved behavior;
- можно приложить regression checklist;
- можно держать шаблон отчета по risky deltas и missing validation.

Возможные артефакты внутри skill:

- regression checklist
- шаблон preserved behavior report
- sample categories of risky deltas

## Вторая волна shared skills

Эти темы возможны, но их лучше брать после первой волны и только если подтвердится,
что нужен именно skill с supporting resources, а не просто agent или prompt.

### 1. logging-review

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- workflow ревью логирования: signal quality, context, levels, noisy logs, observability usefulness.

### 2. error-alignment

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- workflow выравнивания exceptions, error messages и error contract.

### 3. tech-debt-sweep

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- workflow поиска stale code и cleanup opportunities после большого change set.

### 4. commit-splitting

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- workflow деления большого diff на reviewable commit slices с понятными границами.

### 5. rollout-risk-checklist

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- отдельный skill для rollout-risk анализа сложных инфраструктурных изменений.

## Что не надо выносить в shared skills

Держать локально или в других слоях, а не в shared skills:

- workflow, привязанные к конкретному bounded context Leo.Products;
- локальные operational runbooks, завязанные на одну инфраструктуру или команду;
- тонкие slash-command сценарии без supporting resources;
- общие file-based правила, которые лучше оформить как `instructions/`;
- чистые persona-описания без reusable workflow и supporting materials;
- небольшие checklists, которым не нужен отдельный skill-dir.

## Рекомендуемый порядок заполнения

Предлагаемый первый practical batch:

1. `openapi-review`
2. `release-readiness`
3. `incident-triage-playbook`
4. `performance-investigation`

Следующий batch:

1. `regression-review`
2. `logging-review`
3. `error-alignment`
4. `tech-debt-sweep`

## Шаблон для каждого skill

Использовать как минимальную заготовку:

```md
---
name: skill-name
description: "Краткое описание, когда использовать этот skill."
---

# Skill Name

## Цель

## Когда использовать

## Связанные skills

## Обязательные правила

## Рекомендуемые практики

## Анти-паттерны

## Примеры

## Алгоритм принятия решений

## Проверка перед завершением
```

Минимальная структура skill-директории:

```text
<skill-name>/
  SKILL.md
  examples/
  templates/
```

Если supporting artifacts не нужны вовсе, нужно отдельно проверить,
не является ли артефакт на самом деле instruction, prompt или agent.

## Definition of Done

Слой считается достаточно развитым на этой волне, если:

- проведена инвентаризация текущего baseline shared skills;
- выбраны только те новые темы, которым действительно нужен skill-format;
- добавлено не меньше 2-4 новых skill-директорий по реально общим workflow;
- хотя бы у части новых skills есть supporting artifacts кроме одного `SKILL.md`;
- новые skills не дублируют существующие skills, agents и instructions;
- sync в consumer `.github/skills/` проходит без drift.

## Чек-лист выполнения

- [ ] Зафиксировать текущий baseline shared skills.
- [ ] Выделить реальные пробелы в каталоге.
- [ ] Для каждого кандидата проверить, нужен ли именно skill, а не prompt/agent/instruction.
- [ ] Для выбранных skills определить структуру supporting artifacts.
- [ ] Создать first batch skill-директорий в `tools/backend-agent-kit/skills/`.
- [ ] При необходимости добавить examples, templates или scripts внутрь skill.
- [ ] Прогнать sync в consumer repo.
- [ ] Проверить `.github/skills/` и validate-only.
- [ ] Закоммитить shared skill batch и consumer sync отдельными коммитами.