# Задача: заполнить слой shared prompts в backend-agent-kit

Дата создания: 06.05.2026  
Статус: в работе  
Актуализировано: 06.05.2026

## Цель

Собрать первую рабочую волну shared prompt-файлов для `tools/backend-agent-kit/prompts/`,
чтобы в репозитории появился практичный набор reusable slash-команд для частых инженерных задач.

Результат должен дать:

- короткие одноцелевые prompt-команды для повторяемых сценариев;
- единый формат ответа для типовых backend workflow;
- тонкий UX-слой поверх уже существующих shared agents там, где agent уже есть;
- минимальный стартовый каталог prompts, который можно расширять без хаотичного роста.

## Контекст и ограничения

Слой `prompts/` в `backend-agent-kit` нужен для reusable slash-commands,
а не для новых always-on правил и не для новых persona.

Важно сохранить границы слоев:

- `prompts/` - для легкой одноцелевой команды;
- `agents/` - для устойчивой роли, handoff, tool-профиля и multi-step поведения;
- `skills/` - для переносимого workflow с примерами, ресурсами и supporting materials;
- `instructions/` - для always-on правил, а не для разовых запусков.

Следствие:

- не дублировать в prompt большой agent workflow, если он уже существует в `agents/`;
- не переносить в prompt глобальные правила из `copilot-instructions.md` и `instructions/`;
- не делать один prompt на слишком много разнотипных задач;
- если prompt опирается на reusable template, держать внутри prompt минимально достаточную совместимую версию,
  пока sync-контракт не раскладывает `templates/` в consumer `.github/*` слой.

## Критерии хорошего shared prompt

Каждый новый prompt должен:

- решать одну понятную задачу;
- иметь ясный ожидаемый outcome;
- задавать формат ответа;
- быть переиспользуемым в нескольких backend-сервисах;
- не зависеть от одного bounded context или локальной инфраструктуры Leo.Products;
- по возможности опираться на уже существующий shared agent, а не дублировать его логику.

## Первая волна shared prompts

### 1. shared-release-readiness

Статус: [ ] не начато  
Приоритет: высокий  
Опора на agent: `shared-release-readiness`

Назначение:

- быстрый вход в проверку готовности change set к выпуску.

Ожидаемый результат:

- `Ready` / `Ready with risks` / `Not ready`;
- blockers;
- rollout notes;
- pre-release checklist.

### 2. shared-slice-plan

Статус: [ ] не начато  
Приоритет: высокий  
Опора на agent: `shared-slice-planner`

Назначение:

- декомпозиция большой задачи на reviewable slices.

Ожидаемый результат:

- slices;
- зависимости;
- validation per slice.

### 3. shared-incident-first-report

Статус: [ ] не начато  
Приоритет: высокий  
Опора на agent: `shared-incident-triager`

Назначение:

- первая структурированная сводка по продовой проблеме.

Ожидаемый результат:

- symptoms;
- scope;
- likely causes;
- first safe plan.

### 4. shared-regression-check

Статус: [ ] не начато  
Приоритет: высокий  
Опора на agent: `shared-regression-guard`

Назначение:

- проверить, не сломаны ли старые сценарии после рефакторинга, миграции или контрактных изменений.

Ожидаемый результат:

- preserved behavior;
- risky deltas;
- missing validation.

### 5. shared-logging-delta-review

Статус: [ ] не начато  
Приоритет: средний  
Опора на agent: `shared-logging-aligner`

Назначение:

- ревью только изменений по логированию.

Ожидаемый результат:

- signal gaps;
- missing context;
- noisy logs;
- recommended fixes.

### 6. shared-error-handling-review

Статус: [ ] не начато  
Приоритет: средний  
Опора на agent: `shared-error-aligner`

Назначение:

- ревью исключений, error messages и error contract.

Ожидаемый результат:

- inconsistent errors;
- missing domain exceptions;
- bad message shape;
- risk points.

### 7. shared-tech-debt-sweep

Статус: [ ] не начато  
Приоритет: средний  
Опора на agent: `shared-tech-debt-sweeper`

Назначение:

- быстрый поиск мусора после большого change set.

Ожидаемый результат:

- safe to remove;
- likely stale;
- needs confirmation.

### 8. shared-performance-first-pass

Статус: [ ] не начато  
Приоритет: средний  
Опора на agent: `shared-performance-investigator`

Назначение:

- первичный разбор жалобы «работает медленно».

Ожидаемый результат:

- likely bottlenecks;
- what to measure;
- missing observability.

### 9. shared-test-gap-analysis

Статус: [ ] не начато  
Приоритет: высокий  
Опора на agent: `shared-test-updater`

Назначение:

- анализ того, каких тестов не хватает по текущему diff.

Ожидаемый результат:

- unit gaps;
- integration gaps;
- contract gaps;
- priority.

### 10. shared-commit-split-plan

Статус: [ ] не начато  
Приоритет: средний  
Опора на agent: `shared-commit-splitter`

Назначение:

- разложить большой diff на логичные коммиты.

Ожидаемый результат:

- commit boundaries;
- rationale;
- draft commit titles.

## Вторая волна shared prompts

Эти prompts можно делать после первой волны. Они полезны, но не обязаны сразу опираться на отдельного agent.

### 1. shared-openapi-drift-review

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- сравнить изменения контроллеров, DTO и контрактного слоя;
- подсказать, где возможен OpenAPI drift.

### 2. shared-controller-contract-review

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- узкое ревью controller slice на HTTP-коды, DTO, cancellation token и OpenAPI.

### 3. shared-rollout-risk

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- проверить change set только на rollout-риск:
  migrations, config, health checks, feature flags, deployment assumptions.

### 4. shared-pr-summary

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- собрать короткое инженерное описание PR без маркетинговой воды.

### 5. shared-release-notes-draft

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- сделать draft release notes с акцентом на behavior changes и rollout notes.

## Что не надо выносить в shared prompts

Держать локально, а не в shared catalog:

- prompts, завязанные на конкретный bounded context Leo.Products;
- prompts под локальные operational контуры, naming или infra-only детали;
- prompts, которые имеют смысл только рядом с одним модулем или одной командной практикой.

## Рекомендуемый порядок заполнения

Предлагаемый первый practical batch:

1. `shared-release-readiness`
2. `shared-slice-plan`
3. `shared-regression-check`
4. `shared-test-gap-analysis`
5. `shared-incident-first-report`

Второй batch:

1. `shared-logging-delta-review`
2. `shared-error-handling-review`
3. `shared-tech-debt-sweep`
4. `shared-performance-first-pass`
5. `shared-commit-split-plan`

## Шаблон для каждого prompt-файла

Использовать как минимальную заготовку:

```md
---
name: <prompt-name>
description: Короткое описание задачи
agent: <optional-agent-name>
argument-hint: diff, branch, PR, scope или описание проблемы
---

# <Prompt Title>

## Когда использовать

- ...

## Что нужно сделать

1. ...
2. ...
3. ...

## Формат результата

- ...

## Ограничения

- ...
```

## Definition of Done

Для первой волны слой считается заполненным достаточно хорошо, если:

- создано не меньше 5 prompt-файлов из первой волны;
- у каждого prompt есть один четкий outcome;
- у каждого prompt есть явный формат результата;
- prompts не дублируют глобальные instructions и не подменяют agents;
- prompts синхронизируются в consumer `.github/prompts/` без drift;
- хотя бы 2 prompt-файла реально используют существующие shared agents как thin entrypoint.

## Чек-лист выполнения

- [ ] Создать папку `tools/backend-agent-kit/tasks/` для planning-артефактов catalog fill.
- [ ] Зафиксировать текущий backlog prompts в markdown.
- [ ] Выбрать first batch из 3-5 prompts.
- [ ] Для каждого prompt определить: outcome, format, argument-hint, нужен ли agent.
- [ ] Создать первые prompt-файлы в `tools/backend-agent-kit/prompts/`.
- [ ] Прогнать sync в consumer repo.
- [ ] Проверить `.github/prompts/` и validate-only.
- [ ] Закоммитить shared prompt batch и consumer sync отдельными коммитами.