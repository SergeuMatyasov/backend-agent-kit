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
- список управляемых shared-paths записывается в `.github/.backend-agent-kit-manifest`.

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

## Ограничения

Скрипт не должен запускаться, пока backend-agent-kit все еще смонтирован в `.github/skills` как direct-mount submodule.

Корректная модель такая:

- backend-agent-kit подключен вне `.github`, например в `tools/backend-agent-kit`;
- `.github/*` состоит из обычных директорий consumer-репозитория;
- sync script раскладывает shared-артефакты в поддерживаемые active paths.