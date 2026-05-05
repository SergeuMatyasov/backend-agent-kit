# backend-agent-kit

Shared source of truth for reusable Copilot customizations in backend repositories.

## Что это

`backend-agent-kit` хранит общий набор backend-кастомизаций, которые могут переиспользоваться в нескольких сервисах:

- project-wide copilot instructions baseline;
- instructions;
- skills;
- agents;
- hooks;
- prompts;
- scripts;
- templates;
- docs.

Этот репозиторий больше не должен монтироваться напрямую в `.github/skills` consumer-репозитория.

Текущая модель такая:

1. `tools/backend-agent-kit` является source of truth.
2. Copilot продолжает читать active files из стандартных `.github/*` путей consumer-репозитория.
3. Shared-артефакты попадают в `.github/*` через sync-скрипт.

## Как это работает

1. Shared-файлы редактируются в `tools/backend-agent-kit`.
2. Consumer-репозиторий обновляет submodule `tools/backend-agent-kit`.
3. Скрипт `tools/backend-agent-kit/scripts/sync-to-github.sh` раскладывает shared-файлы в:
	- `.github/copilot-instructions.md` как shared baseline с optional local overlay
   - `.github/instructions/`
   - `.github/skills/`
   - `.github/agents/`
   - `.github/hooks/`
   - `.github/prompts/`
4. Скрипт записывает список managed shared-paths в `.github/.backend-agent-kit-manifest`.
5. Consumer-репозиторий просматривает diff и фиксирует его отдельным коммитом.

## Чем новая схема отличается от старой

| Вопрос | Старая схема | Новая схема |
|---|---|---|
| Где живет shared repo | Монтировался прямо в `.github/skills` | Подключается вне `.github`, например в `tools/backend-agent-kit` |
| Что видел Copilot | Только то, что физически лежит в `.github/skills` | Active files по-прежнему лежат в стандартных `.github/*` путях |
| Какие слои можно было хранить | По сути только skills | Skills, instructions, agents, hooks, prompts, scripts, templates и docs |
| Кто является source of truth | Direct-mount каталог `.github/skills` | Репозиторий `tools/backend-agent-kit` |
| Как обновляется consumer | Через изменение submodule в `.github/skills` | Через update submodule + sync в `.github/*` |
| Как удаляются stale shared-paths | Контракт не контролировал это безопасно | Только через manifest и scoped cleanup |
| Что происходит с локальными файлами consumer | Модель плохо масштабировалась при смешении shared и local файлов | Shared и local файлы могут жить рядом в `.github/*` |

Главное отличие: раньше shared repo пытался быть сразу и source of truth, и active path для Copilot. Теперь эти роли разделены.

## Где что находится

### В `tools/backend-agent-kit`

Здесь живет shared source of truth:

- `copilot-instructions.md` - shared baseline для project-wide always-on instructions;
- `instructions/` - общие instruction-файлы;
- `skills/` - shared skills;
- `agents/` - shared agents;
- `hooks/` - shared hooks;
- `prompts/` - shared prompts;
- `scripts/` - служебные скрипты, включая sync;
- `templates/` - шаблоны для переиспользования;
- `docs/` - документация по схеме и правилам.

### В consumer-репозитории `.github/*`

Здесь лежат active files, которые реально подхватываются Copilot:

- `.github/copilot-instructions.md`
- `.github/instructions/`
- `.github/skills/`
- `.github/agents/`
- `.github/hooks/`
- `.github/prompts/`

Shared-файлы попадают сюда через sync. Repo-specific файлы могут жить рядом с ними.
Для project-wide instructions repo-specific overlay можно хранить в `.github/copilot-instructions.local.md`.

### В `.github/.backend-agent-kit-manifest`

Этот файл хранит список shared-paths, которыми управляет sync-скрипт.

Он нужен, чтобы:

- безопасно удалять только managed shared-paths;
- не трогать локальные `.github/workflows` и repo-specific файлы;
- чистить stale shared-файлы, которых больше нет в `backend-agent-kit`.

## Что править в разных сценариях

Если нужно изменить shared-поведение для нескольких backend-репозиториев, правки вносятся в `tools/backend-agent-kit/*`.

Если нужно добавить правило только для текущего consumer-репозитория, его нужно держать локально в соответствующем `.github/*` каталоге.

Если нужно добавить repo-specific project-wide правило поверх shared baseline, его нужно держать локально в `.github/copilot-instructions.local.md`.

Если нужно изменить workflow, это делается локально в `.github/workflows/` consumer-репозитория.

Если нужно изменить общую схему sync, правятся `tools/backend-agent-kit/scripts/` и связанные docs.

## Базовый workflow обновления

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

Обычно процесс выглядит так:

1. Обновить `tools/backend-agent-kit` до нужного commit.
2. Запустить sync.
3. Просмотреть diff consumer-репозитория.
4. Зафиксировать consumer-side изменения отдельным коммитом.

## Важные ограничения

- `backend-agent-kit` не должен снова подключаться как direct-mount submodule в `.github/skills`.
- `.github/workflows` не входят в зону ответственности shared-kit.
- Для shared-изменений нельзя считать `.github/*` первичным источником правды; первичен `tools/backend-agent-kit`.
- `--clean-managed` делает только cleanup managed paths и завершает работу; если после cleanup нужен повторный sync, его нужно запускать отдельной командой.

## Структура

```text
backend-agent-kit/
	copilot-instructions.md
	instructions/
	skills/
	agents/
	hooks/
	prompts/
	scripts/
	templates/
	docs/
```

## Основные документы

- `docs/source-of-truth-sync-model.md` - обзор новой схемы: как она работает, чем отличается от старой и что где лежит.
- `docs/layer-playbook.md` - практический guide по каждому слою: для чего он нужен, как его заполнять, примеры и типовые сценарии.
- `docs/backend-agent-kit-contract.md` - утвержденный контракт shared repo.
- `docs/mapping-rules.md` - правила раскладки shared-слоев в consumer paths.
- `docs/local-repo-artifacts.md` - что остается локальной ответственностью consumer-репозитория.
- `docs/minimal-consumer-layout.md` - минимальная целевая структура consumer-репозитория.
- `docs/operating-model.md` - постоянная рабочая модель после миграции.
- `docs/sync-workflow.md` - как запускать sync и cleanup.
