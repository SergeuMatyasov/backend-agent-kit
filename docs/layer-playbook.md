# Layer Playbook

## Назначение

Этот документ нужен как практическая шпаргалка по всем слоям `backend-agent-kit`.

Он отвечает на четыре вопроса для каждого слоя:

1. Для чего слой нужен.
2. Что именно в него класть.
3. Как выглядит минимальный рабочий пример.
4. В каких сценариях этот слой обычно используется.

Если цель состоит в том, чтобы сначала собрать правильный шаблон по ширине, а потом наполнять его в глубину, начинать лучше с этого документа.

## Как читать этот playbook

Внутри шаблона есть три категории поверхностей:

1. Primary Copilot layers.
Это основной `.github/*`-first набор, на который стоит опираться в Copilot-only модели.

2. Supporting layers.
Это не сами active customizations, а вспомогательные материалы, через которые живут hooks, skills, prompts и docs.

3. Compatibility surfaces.
Это совместимые пути, которые Copilot умеет понимать, но которые обычно не нужны в чистой Copilot-only схеме.

## Быстрый выбор слоя

| Слой | Когда использовать | Когда не использовать |
|---|---|---|
| `instructions/` | Нужны правила и стандарты для файлов, технологий или частей репозитория | Нужен одноразовый task-specific запуск |
| `prompts/` | Нужен переиспользуемый slash-command для одной конкретной задачи | Нужна persona, handoff или набор tool restrictions |
| `agents/` | Нужна отдельная persona, модель, tools, handoffs или subagent workflow | Нужен просто шаблон запроса без постоянной persona |
| `hooks/` | Нужна детерминированная автоматизация или enforcement на lifecycle-событиях | Достаточно обычных instructions без гарантированного исполнения |
| `skills/` | Нужен переносимый multi-step workflow с ресурсами, примерами и скриптами | Нужна только кодстайл-инструкция или один prompt |
| `scripts/` | Нужны helper scripts для hooks, skills или supporting automation | Скрипт не привязан ни к одному customization use case |
| `templates/` | Нужны шаблоны, которые будут переиспользоваться prompts, skills или людьми | Нужен полноценный executable workflow, а не шаблон |
| `docs/` | Нужна документация для людей и reference-материалы, на которые можно ссылаться | Нужен active Copilot artifact |
| `.claude/*` | Нужна совместимость с Claude-format поверхностями | Репозиторий работает только в `.github/*`-first модели |
| `.agents/skills/` | Нужен portability-friendly skills path вне `.github` | Достаточно обычного `skills/` как primary source |

## 1. `instructions/`

### Для чего нужен слой

`instructions/` хранит file-based инструкции, которые объясняют Copilot правила работы с определенными файлами, языками, фреймворками или участками монорепозитория.

Это правильный слой для:

- кодстайла;
- naming rules;
- framework conventions;
- правил для тестов;
- правил для документации;
- ограничений для конкретных папок или типов файлов.

### Что сюда класть

Сюда кладутся файлы `*.instructions.md`.

Обычно один файл отвечает за одну узкую тему.

Хорошие имена:

- `shared-dotnet-api.instructions.md`
- `shared-tests.instructions.md`
- `shared-documentation.instructions.md`

### Минимальный пример

```md
---
name: Dotnet API Rules
description: Правила для ASP.NET Core API файлов
applyTo: '**/Controllers/**/*.cs'
---

# API Rules

- Используй DTO для внешнего контракта.
- Не возвращай доменные сущности напрямую из контроллера.
- Явно описывай HTTP-коды и ошибки.
```

### Как заполнять глубже

Хорошая инструкция обычно содержит:

1. Узкую тему.
2. Ясный `applyTo`.
3. Короткие правила без воды.
4. Причины только там, где они реально помогают.
5. При необходимости ссылки на supporting docs.

### Тонкий список сценариев

- Правила для `*.cs` файлов API-слоя.
- Отдельные правила для тестов.
- Отдельные правила для миграций.
- Правила для OpenAPI-контрактов.
- Правила для markdown-документации.

## 2. `prompts/`

### Для чего нужен слой

`prompts/` хранит reusable slash-commands для легких, одноцелевых задач.

Prompt file удобен, когда нужно:

- запускать повторяемую задачу через `/`;
- фиксировать формат результата;
- дать короткий task-specific workflow;
- при необходимости выбрать agent, model и tools для этого запуска.

### Что сюда класть

Сюда кладутся файлы `*.prompt.md`.

Обычно один prompt = одна задача.

Хорошие имена:

- `shared-pr-review.prompt.md`
- `shared-openapi-check.prompt.md`
- `shared-test-gap-analysis.prompt.md`

### Минимальный пример

```md
---
name: shared-pr-review
description: Выполнить короткое ревью изменений
agent: ask
argument-hint: путь к diff или описание области ревью
---

# PR Review

Проверь изменения на:

- регрессии поведения;
- риски контракта;
- недостающие тесты.

Верни результат в формате:

1. Findings
2. Risks
3. Suggested next steps
```

### Как заполнять глубже

Хороший prompt обычно содержит:

1. Один четкий outcome.
2. Формат ожидаемого результата.
3. Минимальный нужный набор tools.
4. Ссылки на instructions или docs вместо дублирования больших правил.

### Тонкий список сценариев

- Ревью PR.
- Генерация release notes.
- Анализ тестовых дыр.
- Подготовка миграционного плана.
- Проверка OpenAPI drift.

## 3. `agents/`

### Для чего нужен слой

`agents/` хранит custom agents, то есть устойчивые persona-конфигурации с собственными tools, model preferences, handoffs и правилами поведения.

Это правильный слой, когда нужна не просто задача, а роль.

### Что сюда класть

Сюда кладутся файлы `*.agent.md`.

Хорошие имена:

- `shared-planner.agent.md`
- `shared-security-reviewer.agent.md`
- `shared-refactoring-agent.agent.md`

### Минимальный пример

```md
---
name: shared-planner
description: Готовит план изменений без редактирования файлов
tools: ['search', 'web']
model: GPT-5 (copilot)
user-invocable: true
---

# Planner Agent

Твоя задача:

- собрать минимальный нужный контекст;
- выделить риски;
- предложить пошаговый план;
- не редактировать файлы.
```

### Как заполнять глубже

Хороший agent обычно содержит:

1. Роль.
2. Ограниченный список tools.
3. Ясные boundaries поведения.
4. При необходимости handoffs в следующий agent.
5. Ссылки на инструкции или docs, которые агент должен учитывать.

### Тонкий список сценариев

- Planner.
- Security reviewer.
- Refactoring agent.
- Documentation agent.
- API contract reviewer.
- Test writer.

## 4. `hooks/`

### Для чего нужен слой

`hooks/` хранит детерминированные lifecycle automation rules. В отличие от instructions, hook не советует, а выполняет команду или блокирует действие.

Это правильный слой, когда нужно:

- блокировать опасные команды;
- форматировать файлы после edit;
- запускать валидацию;
- логировать tool usage;
- подмешивать контекст в session start;
- контролировать завершение сессии.

### Что сюда класть

Сюда кладутся `*.json` файлы с объектом `hooks`.

Хорошие имена:

- `shared-dangerous-command-guard.json`
- `shared-format-after-edit.json`
- `shared-session-context.json`

### Минимальный пример

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "./scripts/format-changed-file.sh",
        "timeout": 15
      }
    ]
  }
}
```

### Как заполнять глубже

Хороший hook обычно содержит:

1. Один четкий lifecycle intent.
2. Безопасную внешнюю команду.
3. Ограниченный timeout.
4. Понятный failure mode.
5. Минимальные права и минимальный side effect.

### Тонкий список сценариев

- Блокировка destructive terminal-команд.
- Автоформат после edit.
- Локальный lint/check после edit.
- Инъекция контекста о ветке и окружении.
- Audit trail по tool invocations.
- Требование прогнать тесты перед завершением.

## 5. `skills/`

### Для чего нужен слой

`skills/` хранит переносимые multi-step capabilities. Skill нужен, когда одной инструкции мало и нужны еще скрипты, примеры, шаблоны и supporting resources.

Это правильный слой для сложных повторяемых workflow.

### Что сюда класть

Каждый skill - это отдельная директория с `SKILL.md`.

Внутри skill-директории можно хранить:

- `SKILL.md`;
- scripts;
- examples;
- templates;
- sample inputs и sample outputs.

### Минимальный пример

```md
---
name: openapi-review
description: Проверка изменений API-контракта и риска drift
---

# OpenAPI Review

Используй этот skill, когда нужно:

- сравнить контракт до и после изменений;
- найти breaking changes;
- предложить проверки.

Шаги:

1. Найди OpenAPI-файлы.
2. Сравни изменения.
3. Выдели breaking changes.
4. Предложи тесты и migration notes.
```

### Как заполнять глубже

Хороший skill обычно содержит:

1. Четкое `name`, совпадающее с именем папки.
2. Хорошее `description`, по которому Copilot поймет, когда skill загружать.
3. Пошаговую процедуру.
4. Ссылки на scripts, templates и docs внутри skill-директории.
5. При необходимости примеры input/output.

Для пограничных случаев используй такое правило:

1. Если артефакт оркестрирует несколько связанных capabilities в один repeatable workflow, он остается `skills/`, даже если внутри много ссылок на другие skills.
2. Если внутри skill живет reusable структура текста, чеклист или заготовка документа, канонический шаблон нужно выносить в `templates/`.
3. Пока текущий sync-контракт раскладывает в consumer только `.github/instructions`, `.github/skills`, `.github/agents`, `.github/hooks` и `.github/prompts`, полезный template при необходимости нужно дублировать краткой совместимой копией внутри skill или prompt, который на него опирается.
4. Если артефакт больше похож на глобальное правило для файлов или языка, чем на workflow, его нужно переносить в `instructions/`, а не оставлять в `skills/`.

### Тонкий список сценариев

- Debugging integration tests.
- OpenAPI review.
- Deployment readiness check.
- Migration playbook.
- Incident triage.
- Database rollout checklist.

## 6. `scripts/`

### Для чего нужен слой

`scripts/` хранит supporting automation, на которую ссылаются hooks, skills, prompts или docs.

Скрипт сам по себе не является customization layer для Copilot, но часто является рабочей частью automation.

### Что сюда класть

Сюда кладутся исполняемые helper scripts.

Хорошие имена:

- `format-changed-file.sh`
- `check-openapi-drift.sh`
- `export-session-context.sh`

### Минимальный пример

```bash
#!/usr/bin/env bash

set -euo pipefail

file_path=${1:-}

if [ -z "$file_path" ]; then
  echo "missing file path" >&2
  exit 1
fi

dotnet format "$file_path"
```

### Как заполнять глубже

Хороший script обычно:

1. Имеет один четкий use case.
2. Безопасен при ошибках.
3. Не требует скрытых глобальных зависимостей без документации.
4. Имеет predictable stdout/stderr.
5. Явно связан с hook, skill или prompt.

### Тонкий список сценариев

- Format helper для hooks.
- Contract drift checker.
- Генерация контекста для session start.
- Безопасный wrapper для тестов.
- Export diagnostic bundle.

## 7. `templates/`

### Для чего нужен слой

`templates/` хранит reusable text artifacts, которые не должны быть instructions, agents или prompts сами по себе, но полезны как готовые заготовки.

### Что сюда класть

Сюда кладутся шаблоны, на которые можно ссылаться из skills, prompts и docs.

Хорошие имена:

- `pr-review-template.md`
- `migration-checklist-template.md`
- `incident-report-template.md`

### Минимальный пример

```md
# PR Review Template

## Findings

## Risks

## Missing Tests

## Suggested Next Steps
```

### Как заполнять глубже

Хороший template обычно:

1. Не содержит логики исполнения.
2. Имеет стабильную структуру.
3. Понятно переиспользуется в нескольких сценариях.
4. Упоминается в docs, prompts или skills.

Для шаблонов, выделенных из skill или prompt, придерживайся следующих правил:

1. В `templates/` лежит каноническая версия reusable структуры.
2. В skill или prompt остается ссылка на template.
3. Если consumer работает на `.github/*`-only sync и `templates/` пока не раскладывается, внутри skill или prompt допустимо держать сокращенную совместимую копию шаблона.
4. Как только sync-контракт начнет доставлять `templates/`, совместимые копии можно удалять отдельным change set, не смешивая это с функциональным рефакторингом layer placement.

### Тонкий список сценариев

- PR review format.
- ADR template.
- Migration checklist.
- Bug report template.
- Release checklist.

## 8. `docs/`

### Для чего нужен слой

`docs/` хранит human-facing reference docs, которые объясняют модель, flow, правила и договоренности по использованию слоев.

Этот слой не должен сам по себе становиться active Copilot primitive, но он может использоваться как supporting context через ссылки.

### Что сюда класть

Сюда кладутся:

- архитектурные документы;
- contract docs;
- how-to guides;
- onboarding docs;
- layer playbooks.

### Минимальный пример

```md
# OpenAPI Review Workflow

## Когда использовать

Используй этот workflow, когда меняется внешний API-контракт.

## Порядок действий

1. Обновить контракт.
2. Сравнить diff.
3. Проверить breaking changes.
4. Обновить совместимые тесты.
```

### Как заполнять глубже

Хороший doc обычно:

1. Имеет четкую цель.
2. Описывает реальный workflow.
3. Не дублирует без нужды содержимое инструкций.
4. Может быть процитирован из skills или prompts.

### Тонкий список сценариев

- Onboarding guide.
- Architecture contract.
- Sync workflow.
- Layer playbook.
- Troubleshooting guide.

## 9. `.claude/rules/`

### Для чего нужен слой

`.claude/rules/` нужен только для compatibility-сценария, если ты хочешь, чтобы один и тот же репозиторий был понятен не только Copilot, но и Claude-format tooling.

В чистой Copilot-only модели этот слой обычно можно не заполнять.

### Что сюда класть

Сюда кладутся Claude-style rules files.

Ключевое отличие от `.instructions.md`: вместо `applyTo` обычно используется `paths`.

### Минимальный пример

```md
---
description: Правила для backend C# файлов
paths:
  - '**/*.cs'
---

- Используй явные DTO для внешних контрактов.
- Не возвращай доменные сущности из API.
```

### Тонкий список сценариев

- Совместимость с Claude Code.
- Единые правила для смешанной команды Copilot и Claude.
- Переиспользование существующих Claude rules.

## 10. `.claude/agents/`

### Для чего нужен слой

`.claude/agents/` нужен для Claude-compatible agent definitions.

В чистой Copilot-only модели этот слой обычно оставляют пустым.

### Что сюда класть

Сюда кладутся `.md` agent files в Claude-format.

### Минимальный пример

```md
---
name: planner
description: Build implementation plans before coding
tools: Read, Grep, Glob
---

You are a planning agent.
```

### Тонкий список сценариев

- Один и тот же agent для Copilot и Claude.
- Постепенная миграция между агентными форматами.
- Поддержка mixed-toolchain команды.

## 11. `.claude/skills/`

### Для чего нужен слой

`.claude/skills/` нужен только если skill должен быть обнаруживаемым через Claude-compatible path.

В Copilot-only модели primary слой для skills остается `skills/`.

### Что сюда класть

Сюда кладутся skill directories с `SKILL.md`.

### Минимальный пример

```md
---
name: deployment-check
description: Проверка готовности релиза
---

# Deployment Check

1. Проверь конфигурацию.
2. Проверь миграции.
3. Проверь health checks.
```

### Тонкий список сценариев

- Shared skills для Claude-compatible среды.
- Эксперименты с cross-tool portability.
- Подготовка общего skills catalog.

## 12. `.agents/skills/`

### Для чего нужен слой

`.agents/skills/` - это compatibility surface для agent-skills standard вне `.github`.

Он полезен, если ты хочешь более явно держать portable skills path независимо от GitHub-specific layout.

### Что сюда класть

Сюда кладутся skill directories с `SKILL.md`, по тем же правилам, что и в обычном `skills/`.

### Минимальный пример

```md
---
name: incident-triage
description: Быстрый triage production-инцидента
---

# Incident Triage

1. Собери контекст.
2. Выдели scope проблемы.
3. Сформулируй первичный mitigation plan.
```

### Тонкий список сценариев

- Agent-skills portability.
- Нейтральный skills path вне `.github`.
- Подготовка шаблона для нескольких AI toolchains.

## Root-level file primitives

Это не каталоги, но их важно помнить, если цель - покрыть все repo-side возможности Copilot.

### `.github/copilot-instructions.md`

Используй как project-wide always-on instruction file.

В текущем контракте `backend-agent-kit` может поставлять shared baseline для этого файла через root-level `copilot-instructions.md`,
а конкретный consumer может дополнять его локальным `.github/copilot-instructions.local.md`.

Когда подходит:

- единый кодстайл на весь репозиторий;
- ключевые архитектурные правила;
- список preferred libraries;
- требования к безопасности и документации.

Минимальный пример:

```md
# Project Instructions

- Используй MediatR для application use cases.
- Не выноси framework logic в domain.
- Пиши новые docs на русском языке.
```

### `AGENTS.md`

Используй как root-level always-on instructions file, особенно если в репозитории используются разные AI agents или nested agent rules.

Когда подходит:

- один общий набор правил для нескольких agent modes;
- монорепозиторий с folder-level agent behavior;
- общий operational contract для всех агентов.

### `CLAUDE.md`

Используй только если нужна совместимость с Claude-style always-on instructions.

В Copilot-only модели этот файл обычно не обязателен.

## Практическая рекомендация по заполнению

Если шаблон строится именно для Copilot-first работы, порядок наполнения обычно такой:

1. `instructions/`
2. `prompts/`
3. `agents/`
4. `hooks/`
5. `skills/`
6. `scripts/`, `templates/`, `docs/`

Compatibility surfaces `.claude/*` и `.agents/skills/` имеет смысл трогать только если у проекта действительно есть cross-tool цель.

## Минимальный стартовый набор

Если нужен практичный первый слой наполнения, обычно достаточно такого набора:

1. 2-4 хороших `*.instructions.md` файла по ключевым правилам репозитория.
2. 2-3 `*.prompt.md` файла для частых повторяемых задач.
3. 1 planner agent и 1 review agent.
4. 1-2 hooks для safe guard и formatting.
5. 1-3 skills для самых дорогих recurring workflows.

После этого шаблон уже начинает приносить реальную пользу, и дальше его можно расширять в глубину по фактическим use cases.