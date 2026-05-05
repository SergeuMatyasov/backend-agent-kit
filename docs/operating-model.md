# Operating Model

## Назначение

Этот документ фиксирует постоянную рабочую модель `backend-agent-kit` после завершения миграции со старого skills-only контракта.

## Базовые правила

### 1. Shared repo хранит только повторно используемые backend-артефакты

В `backend-agent-kit` должны жить только те кастомизации, которые применимы к нескольким backend-сервисам.

Сюда подходят:

- shared instructions;
- shared skills;
- shared agents;
- shared hooks;
- shared prompts;
- supporting scripts, templates и docs.

Сюда не должны попадать:

- service-specific workflows;
- доменные документы одного конкретного сервиса;
- локальные исключения конкретного репозитория.

### 2. Repo-specific правила остаются в consumer-репозитории

В конкретном сервисе локально остаются:

- repo-specific instructions;
- repo-specific skills;
- repo-specific agents;
- repo-specific hooks;
- repo-specific prompts;
- project-level AGENTS.md;
- repo-specific overlay для shared `.github/copilot-instructions.md`, например `.github/copilot-instructions.local.md`;
- `.github/workflows` и локальные scripts.

### 3. Подключение идет через внешний source of truth

`backend-agent-kit` подключается вне `.github`, например как:

- `tools/backend-agent-kit`

Он не должен монтироваться как содержимое `.github/skills`.

### 4. Active files должны оказываться в стандартных `.github/*` путях

Рабочими путями для Copilot считаются:

- `.github/copilot-instructions.md`
- `.github/instructions`
- `.github/skills`
- `.github/agents`
- `.github/hooks`
- `.github/prompts`

Shared repo является source of truth, а active files появляются через sync.
Для project-wide instructions shared baseline может быть дополнен локальным overlay-файлом `.github/copilot-instructions.local.md`.

### 5. Update flow считается завершенным только после consumer-side sync

Корректный update flow:

1. Изменить `backend-agent-kit`.
2. Зафиксировать изменения в shared repo.
3. Обновить submodule в consumer-репозитории.
4. Выполнить sync в `.github/*`.
5. Просмотреть diff consumer-репозитория.
6. Зафиксировать consumer-side изменения отдельным коммитом.

Если sync и review diff не выполнены, обновление shared-kit не считается завершенным.

### 6. Новые слои добавляются только при наличии consumer-path и реального use case

Новый слой допустим только если:

- понятно, где он будет жить в shared repo;
- понятно, как он будет попадать в consumer-репозиторий;
- понятно, как Copilot или supporting workflow будет его использовать;
- это не дублирует уже существующий слой без новой ценности.

### 7. `.github/workflows` не входят в область ответственности backend-agent-kit

`backend-agent-kit` не должен:

- поставлять workflow-файлы за consumer-репозиторий;
- удалять локальные workflow-файлы;
- считать `.github/workflows` частью managed shared-слоя.

## Practical Consequences

Из этой модели следуют три практических последствия:

1. Shared и local файлы могут сосуществовать в одной `.github` директории.
2. Blind delete по всей `.github` запрещен.
3. Библиотечные репозитории вроде `Leonarto.Shared` и `Shared` не обязаны становиться самостоятельными consumer-репозиториями для agent-kit.