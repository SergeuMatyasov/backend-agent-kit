# Backend Agent Kit Contract

## Назначение

Этот репозиторий является source of truth для повторно используемых Copilot-кастомизаций в backend-репозиториях.

Репозиторий больше не должен рассматриваться как содержимое, которое напрямую монтируется в .github/skills consumer-репозитория.

## Утвержденные решения

### 1. Корень репозитория содержит слои

В корне репозитория должны находиться следующие каталоги:

- instructions/
- skills/
- agents/
- hooks/
- prompts/
- scripts/
- templates/
- docs/

### 2. Skills переносятся под skills/

Все существующие skill-папки сохраняют свои текущие имена, но физически живут под skills/.

Пример:

- было: clean-code-principles/
- стало: skills/clean-code-principles/

Это сохраняет идентичность skills и не ломает их внутренние имена.

### 3. Shared repo подключается в consumer-репозитории вне .github

Рекомендуемый путь подключения:

- tools/backend-agent-kit

Shared repo не должен подключаться как submodule в .github/skills.

### 4. .github/workflows не входят в область ответственности shared repo

Workflow-файлы являются локальной ответственностью конкретного consumer-репозитория.

Shared repo не должен:

- хранить workflows за consumer-репозиторий;
- удалять локальные workflows;
- считать workflows частью managed shared-слоя.

### 5. Repo-specific кастомизации остаются локальными

В consumer-репозитории локально остаются:

- domain-specific instructions;
- repo-specific skills;
- repo-specific agents;
- repo-specific hooks;
- repo-specific prompts;
- project-wide AGENTS.md;
- repo-specific overlay для shared `.github/copilot-instructions.md`, например `.github/copilot-instructions.local.md`;
- любые локальные workflow и сервисные документы.

Shared repo должен дополнять локальный слой, а не заменять его.

### 6. Naming convention для shared-файлов

Приняты следующие соглашения:

- shared skill-папки сохраняют существующие semantic names без префикса;
- shared instructions именуются с префиксом shared-, например shared-dotnet-testing.instructions.md;
- shared agents именуются с префиксом shared-, например shared-code-reviewer.agent.md;
- shared prompts именуются с префиксом shared-, например shared-controller-review.prompt.md;
- shared hooks именуются с префиксом shared-, например shared-openapi-drift.json;
- docs, scripts и templates именуются в kebab-case.

Причина этого правила:

- skills уже имеют стабильные имена и на них могут ссылаться другие документы;
- single-file примитивы должны визуально отличаться от локальных repo-specific файлов и не конфликтовать с ними по имени.
- root-level `copilot-instructions.md` использует фиксированное платформенное имя и поэтому не префиксуется.

### 7. Update flow

Постоянный update flow выглядит так:

1. Изменения вносятся в backend-agent-kit.
2. Изменения коммитятся и публикуются в shared repo.
3. В consumer-репозитории обновляется submodule tools/backend-agent-kit.
4. Выполняется sync shared-артефактов в .github/*.
5. Просматривается diff в consumer-репозитории.
6. Изменения фиксируются отдельным коммитом в consumer-репозитории.

## Что не входит в этот контракт

В этот контракт не входит:

- прямая поставка .github/workflows;
- автоматическое удаление всех локальных файлов consumer-репозитория;
- управление произвольными файлами вне .github/* без отдельного решения;
- обязательное использование submodule как единственного механизма доставки.

## Следствие для миграции

Если consumer-репозиторий все еще монтирует этот shared repo в .github/skills, после переноса skills под skills/ старый direct-mount контракт считается сломанным по дизайну.

Это ожидаемое поведение на этапе миграции.
