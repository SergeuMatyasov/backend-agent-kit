# Sync Workflow

## Назначение

Этот документ описывает, как shared backend-agent-kit раскладывается в активные `.github/*` каталоги consumer-репозитория.

## Основной сценарий

Из consumer-репозитория:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

Результат:

- shared instructions копируются в `.github/instructions/`;
- shared skills копируются в `.github/skills/`;
- shared agents копируются в `.github/agents/`;
- shared hooks копируются в `.github/hooks/`;
- shared prompts копируются в `.github/prompts/`;
- `templates/`, `docs/` и `scripts/` остаются в source-of-truth слое `tools/backend-agent-kit` и сами по себе в `.github/*` не раскладываются;
- список управляемых shared-paths записывается в `.github/.backend-agent-kit-manifest`.

Практическое следствие:

- если skill или prompt опирается на reusable template из `templates/`, а consumer работает в `.github/*`-only модели, внутри активного skill или prompt нужно оставить короткую совместимую копию шаблона или минимально достаточную структуру;
- вынос шаблона в `templates/` без такой совместимой копии допустим только после расширения sync-контракта.

## Внедрение в другой сервис

Ниже описан рекомендуемый вариант внедрения через git submodule.

Если конкретный сервис использует другой механизм доставки shared-репозитория, итоговая целевая модель не меняется:

- `backend-agent-kit` живет вне `.github`, обычно в `tools/backend-agent-kit`;
- active files оказываются в стандартных `.github/*` путях;
- раскладка shared-артефактов выполняется через sync.

### Сценарий 1. Миграция со старой схемы

Этот сценарий нужен, если сервис уже использует старую модель, где shared skills были смонтированы напрямую в `.github/skills`.

#### Шаг 1. Зафиксировать текущее состояние

Перед миграцией нужно убедиться, что репозиторий находится в предсказуемом состоянии.

Проверь:

- есть ли в `.gitmodules` запись для `.github/skills`;
- нет ли незакоммиченных правок в `.github` и в старом shared submodule;
- понимает ли команда, какие файлы в `.github` являются локальными repo-specific файлами и не должны потеряться.

#### Шаг 2. Подключить `backend-agent-kit` вне `.github`

Рекомендуемый путь подключения:

```bash
git submodule add <backend-agent-kit-url> tools/backend-agent-kit
git submodule update --init --recursive
```

После этого shared source of truth уже доступен в правильном месте, но active files для Copilot еще не разложены.

#### Шаг 3. Снять старый direct-mount контракт с `.github/skills`

Цель этого шага - перестать трактовать `.github/skills` как submodule path и превратить его в обычную директорию consumer-репозитория.

Практически это обычно включает:

1. Удаление записи `[submodule ".github/skills"]` из `.gitmodules`.
2. Удаление старого gitlink `.github/skills` из индекса.
3. Деинициализацию старого submodule, если git все еще считает путь зарегистрированным submodule.

Типовой набор команд выглядит так:

```bash
git submodule deinit -f .github/skills
git rm --cached -r .github/skills
git submodule sync --recursive
```

Если конкретный репозиторий хранит локальные repo-specific файлы внутри `.github/skills`, их нужно сохранить как обычные файлы consumer-репозитория, а не как содержимое старого submodule.

#### Шаг 4. Разложить shared-файлы по новой схеме

После снятия старого gitlink запускается обычный sync:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

Ожидаемый результат:

- появляется `.github/.backend-agent-kit-manifest`;
- `.github/skills` снова существует, но уже как обычная директория с файлами;
- при необходимости создаются `.github/instructions`, `.github/agents`, `.github/hooks` и `.github/prompts`.

#### Шаг 5. Проверить diff до коммита

В корректном diff обычно видны такие изменения:

- добавлен `tools/backend-agent-kit`;
- удален старый gitlink `.github/skills`;
- под `.github/skills` появились обычные файлы и директории;
- создан или обновлен `.github/.backend-agent-kit-manifest`.

Если git по-прежнему показывает `.github/skills` как submodule или `git submodule status` падает с ошибкой про `.github/skills`, значит старый gitlink удален не до конца.

#### Шаг 6. Выполнить контрольные проверки

До коммита стоит проверить:

```bash
git submodule status
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --validate-only
```

Ожидается:

- `git submodule status` больше не содержит `.github/skills` и не падает;
- `--validate-only` возвращает код `0`;
- локальные `.github/workflows` и repo-specific файлы сохранились.

#### Шаг 7. Зафиксировать изменения

После проверки обычно фиксируются два слоя изменений:

1. Подключение `tools/backend-agent-kit` и снятие старого direct-mount контракта.
2. Разложенные active files внутри `.github/*`.

Допустимо хранить это в одном consumer-side коммите, если diff остается читаемым.

### Сценарий 2. Подключение на чистом листе

Этот сценарий нужен, если сервис раньше вообще не использовал shared skills repo и сразу строится на новой схеме.

#### Шаг 1. Подключить `backend-agent-kit`

Рекомендуемый вариант:

```bash
git submodule add <backend-agent-kit-url> tools/backend-agent-kit
git submodule update --init --recursive
```

После этого в репозитории появляется shared source of truth, но Copilot еще не использует эти файлы, пока не выполнен sync.

#### Шаг 2. Выполнить первичную раскладку shared-файлов

Из корня consumer-репозитория:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

Скрипт создаст недостающие standard paths и разложит shared-артефакты в рабочие каталоги `.github/*`.

#### Шаг 3. Добавить repo-specific слой при необходимости

После sync можно добавлять локальные файлы сервиса рядом с shared-файлами:

- `.github/instructions/*` для локальных инструкций;
- `.github/skills/*` для repo-specific skills;
- `.github/agents/*` для локальных agents;
- `.github/hooks/*` для локальных hooks;
- `.github/prompts/*` для локальных prompts;
- `.github/workflows/*` для CI/CD и других локальных workflow.

Важно: локальные файлы не должны переноситься в `backend-agent-kit`, если они относятся только к одному сервису.

#### Шаг 4. Выполнить контрольные проверки

Проверь:

```bash
git submodule status
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --validate-only
```

Ожидается:

- `tools/backend-agent-kit` виден как обычный submodule;
- `.github/.backend-agent-kit-manifest` существует;
- `.github/skills`, `.github/instructions`, `.github/agents`, `.github/hooks` и `.github/prompts` являются обычными директориями consumer-репозитория;
- `--validate-only` возвращает код `0` сразу после первичного sync.

#### Шаг 5. Зафиксировать начальное состояние

Обычно initial adoption фиксируется отдельным коммитом consumer-репозитория:

1. submodule `tools/backend-agent-kit`;
2. разложенные shared active files;
3. при необходимости локальные repo-specific файлы, добавленные поверх shared-слоя.

## Как выбрать правильный сценарий

Используй сценарий миграции, если в репозитории уже был direct-mount submodule в `.github/skills` или иная legacy-модель, где `.github/skills` не является обычной директорией consumer-репозитория.

Используй сценарий чистого листа, если сервис внедряет `backend-agent-kit` впервые и в нем нет старого shared-skills контракта, который нужно снимать.

## Dry run

Чтобы посмотреть, что изменится без записи на диск:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --dry-run
```

## Validate only

Чтобы использовать скрипт как drift-check:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --validate-only
```

Поведение:

- код `0`: consumer-репозиторий уже синхронизирован;
- код `1`: обнаружен drift и sync внес бы изменения.

## Локальная git hook автоматизация

Если нужно сделать поведение явным и повторяемым, в `backend-agent-kit` можно включить локальный git `post-commit` hook.

Versioned hook лежит здесь:

- `tools/backend-agent-kit/scripts/git-hooks/post-commit`

Хук вызывает:

- `tools/backend-agent-kit/scripts/auto-sync-consumer-after-shared-commit.sh`

Что делает эта автоматизация:

1. После commit внутри `tools/backend-agent-kit` запускает обычный `sync-to-github.sh --repo-root .`.
2. Ставит в index только `.github/*` managed changes и `tools/backend-agent-kit`.
3. Создает отдельный consumer-side commit в основном репозитории.

Как включить локально:

```bash
git -C tools/backend-agent-kit config core.hooksPath scripts/git-hooks
chmod +x tools/backend-agent-kit/scripts/git-hooks/post-commit
chmod +x tools/backend-agent-kit/scripts/auto-sync-consumer-after-shared-commit.sh
```

Важные guard-условия:

- если в consumer-репозитории уже есть staged changes, auto-commit не делается;
- если `.github` уже грязный, auto-sync и auto-commit не делаются автоматически;
- если `backend-agent-kit` расположен не по пути `tools/backend-agent-kit`, hook завершается без действия.

Это сделано специально, чтобы hook не подмешивал в consumer commit посторонние изменения.

## Manifest

Manifest хранится по пути:

- `.github/.backend-agent-kit-manifest`

Он содержит список путей, которыми владеет shared sync.

Manifest нужен для двух задач:

- удалить stale shared-paths, которые больше не существуют в backend-agent-kit;
- удалять только managed shared-paths, не трогая локальные repo-specific файлы.

## Scoped cleanup

Shared sync не использует blind delete по всей `.github`.

Допустимое удаление ограничено:

- только путями из manifest;
- только внутри managed shared layers.

Это защищает локальные:

- `.github/workflows/`;
- repo-specific skills;
- repo-specific instructions;
- repo-specific agents;
- repo-specific hooks;
- repo-specific prompts.

## Rollback / cleanup

Если нужно убрать из consumer-репозитория только ранее разложенные shared-paths:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --clean-managed
```

Dry-run вариант:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --clean-managed --dry-run
```

Важно:

- `--clean-managed` только удаляет managed shared-paths и завершает текущий запуск;
- повторный sync в том же запуске не выполняется;
- если после cleanup нужно снова разложить shared-файлы, запускается отдельная обычная команда sync.

Пример cleanup + повторного sync:

```bash
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root . --clean-managed
./tools/backend-agent-kit/scripts/sync-to-github.sh --repo-root .
```

## Ограничения

Скрипт не должен запускаться, пока backend-agent-kit все еще смонтирован в `.github/skills` как direct-mount submodule.

Корректная модель такая:

- backend-agent-kit подключен вне `.github`, например в `tools/backend-agent-kit`;
- `.github/*` состоит из обычных директорий consumer-репозитория;
- sync script раскладывает shared-артефакты в поддерживаемые active paths.