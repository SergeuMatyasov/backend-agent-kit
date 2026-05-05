# Source Of Truth And Sync Model

## Назначение

Этот документ объясняет новую рабочую схему `backend-agent-kit` целиком:

- что теперь считается source of truth;
- какие файлы являются active files для Copilot;
- чем новая схема отличается от старой direct-mount модели;
- где лежат shared и local артефакты;
- как выглядит нормальный update flow.

Если нужно быстро понять архитектуру после миграции, начинать лучше с этого документа.

## Коротко

В новой схеме есть две разные роли.

Первая роль - shared source of truth. Эту роль выполняет `tools/backend-agent-kit`.

Вторая роль - active files, которые Copilot реально читает в consumer-репозитории. Эти файлы лежат в стандартных путях внутри `.github/*`.

Shared-артефакты не читаются напрямую из `tools/backend-agent-kit`. Они сначала раскладываются в `.github/*` через sync-скрипт.

## Почему старая схема перестала подходить

Старая схема предполагала, что shared repo можно просто смонтировать прямо в `.github/skills`.

Пока shared-репозиторий содержал только skills, это еще работало как временный контракт.

После расширения набора слоев эта модель стала тесной по нескольким причинам:

1. Она естественно обслуживала только один active path - `.github/skills`.
2. Она не давала нормальной модели для `instructions`, `agents`, `hooks` и `prompts`.
3. Она смешивала source of truth и active files в одном и том же физическом пути.
4. Она плохо переживала coexistence shared и repo-specific файлов внутри `.github`.
5. Она не давала безопасного scoped cleanup для устаревших shared-paths.

Именно поэтому новая схема разделяет хранение shared-источника и delivery в active paths.

## Старая и новая схема рядом

| Аспект | Старая схема | Новая схема |
|---|---|---|
| Shared repo | submodule в `.github/skills` | submodule вне `.github`, обычно `tools/backend-agent-kit` |
| Source of truth | direct-mount path | `tools/backend-agent-kit` |
| Active files для Copilot | тот же direct-mount path | стандартные `.github/instructions`, `.github/skills`, `.github/agents`, `.github/hooks`, `.github/prompts` |
| Shared layers | по сути skills-only | несколько слоев: instructions, skills, agents, hooks, prompts, scripts, templates, docs |
| Обновление consumer | переключение submodule в `.github/skills` | update submodule + sync + review diff + отдельный commit |
| Удаление stale файлов | хрупкое, без точного ownership | controlled cleanup по manifest |
| Сосуществование shared и local файлов | неудобное | штатное |

## Как теперь устроен consumer-репозиторий

Нормальная целевая структура выглядит так:

```text
service-repo/
  .github/
    workflows/
    instructions/
    skills/
    agents/
    hooks/
    prompts/
    .backend-agent-kit-manifest
  tools/
    backend-agent-kit/
```

### Что означает каждая зона

`tools/backend-agent-kit/`:

- shared repo;
- source of truth;
- место, где меняются reusable shared-артефакты;
- место, где лежат supporting docs и scripts.

`.github/instructions/`, `.github/skills/`, `.github/agents/`, `.github/hooks/`, `.github/prompts/`:

- active files consumer-репозитория;
- именно отсюда Copilot подхватывает кастомизации;
- сюда попадают shared-файлы после sync;
- здесь же могут лежать repo-specific файлы.

`.github/workflows/`:

- локальная зона consumer-репозитория;
- не управляется `backend-agent-kit`.

`.github/.backend-agent-kit-manifest`:

- список managed shared-paths;
- техническая граница ownership для cleanup;
- защита от blind delete по всей `.github`.

## Как работает sync

Точка входа - скрипт:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

Он делает следующее:

1. Берет shared-файлы из `tools/backend-agent-kit`.
2. Раскладывает их в поддерживаемые `.github/*` каталоги consumer-репозитория.
3. Обновляет `.github/.backend-agent-kit-manifest`.
4. Удаляет stale managed shared-paths, которых больше нет в shared repo.
5. Не трогает локальные repo-specific файлы вне managed-списка.

### Важная деталь про cleanup

Команда:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --clean-managed
```

делает только cleanup managed paths и затем завершает работу.

Она не выполняет автоматический повторный sync в том же запуске.

Если нужен сценарий cleanup + повторная раскладка, его нужно делать двумя командами:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --clean-managed
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

## Что считается правильным update flow

Корректное обновление shared-кастомизаций выглядит так:

1. Изменить shared-файлы в `tools/backend-agent-kit`.
2. Зафиксировать и опубликовать изменения в shared repo.
3. Обновить submodule `tools/backend-agent-kit` в consumer-репозитории.
4. Запустить sync.
5. Просмотреть diff consumer-репозитория.
6. Зафиксировать consumer-side изменения отдельным коммитом.

Этот flow важен потому, что shared-kit commit и consumer-side разложенные active files - это две разные плоскости изменений.

## Что нужно менять в типовых случаях

### Нужно изменить shared skill для нескольких сервисов

Менять нужно `tools/backend-agent-kit/skills/...`, затем выполнять sync в consumer-репозиториях.

### Нужно добавить repo-specific skill только для одного сервиса

Менять нужно локальный `.github/skills/...` текущего consumer-репозитория.

### Нужно добавить или изменить instruction только для текущего репозитория

Менять нужно локальный `.github/instructions/...` или project-level `AGENTS.md` / `copilot-instructions.md`, если проект использует эти файлы.

### Нужно изменить workflow

Менять нужно локальный `.github/workflows/...` consumer-репозитория.

`backend-agent-kit` не должен брать ownership над workflow-файлами сервиса.

### Нужно изменить сам механизм доставки shared-файлов

Менять нужно:

- `tools/backend-agent-kit/scripts/...`;
- связанные документы в `tools/backend-agent-kit/docs/...`.

## Что считается ошибкой

Неправильно:

- снова монтировать `backend-agent-kit` прямо в `.github/skills`;
- считать `.github/*` первичным shared-источником;
- делать blind delete по всей `.github`;
- складывать workflow-файлы consumer-репозитория в shared-kit как будто он владеет ими;
- изменять shared-файл в `.github/*` и не переносить источник правды в `tools/backend-agent-kit`.

Правильно:

- держать shared source of truth в `tools/backend-agent-kit`;
- держать active files в стандартных `.github/*` путях;
- раскладывать shared-артефакты через sync;
- хранить локальные repo-specific файлы рядом, но отдельно по ownership.

## Как читать текущую схему в одном предложении

`tools/backend-agent-kit` хранит переиспользуемый shared-слой, а `.github/*` хранит активный consumer-layer, который получается из shared-слоя через sync и может дополняться локальными repo-specific файлами.