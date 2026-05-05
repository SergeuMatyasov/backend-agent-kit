# Mapping Rules

## Назначение

Этот документ фиксирует, как слои backend-agent-kit раскладываются в standard consumer paths внутри .github.

## Mapping

| Source in backend-agent-kit | Target in consumer repo |
|---|---|
| copilot-instructions.md | .github/copilot-instructions.md |
| instructions/* | .github/instructions/ |
| skills/* | .github/skills/ |
| agents/* | .github/agents/ |
| hooks/* | .github/hooks/ |
| prompts/* | .github/prompts/ |
| scripts/* | tools/backend-agent-kit/scripts/ |
| templates/* | tools/backend-agent-kit/templates/ |
| docs/* | tools/backend-agent-kit/docs/ |

## Основные правила

1. Copilot читает project-wide instructions, instructions, skills, agents, hooks и prompts только из поддерживаемых целевых путей внутри consumer-репозитория.
2. Поэтому shared repo должен сначала быть подключен как source of truth, а затем его содержимое должно быть разложено по .github/*.
3. Каталоги scripts, templates и docs не обязаны копироваться в .github. Они могут использоваться напрямую из tools/backend-agent-kit.

## Collision policy

1. Shared sync не должен удалять или перезаписывать произвольные локальные файлы consumer-репозитория.
2. Shared sync должен управлять только теми файлами, которые явно относятся к shared-слою.
3. Repo-specific файлы должны сохраняться рядом с shared-файлами.
4. Для single-file примитивов используется префикс shared-, чтобы уменьшить вероятность конфликта с локальными файлами.

## Что не должно раскладываться shared sync

Shared sync не должен управлять:

- .github/workflows/;
- локальными AGENTS.md;
- repo-specific overlay-файлами вроде `.github/copilot-instructions.local.md`;
- произвольными docs и scripts consumer-репозитория;
- файлами вне agreed target paths.

## Минимальное требование к sync-скрипту

Sync-скрипт должен:

- создавать недостающие целевые каталоги;
- копировать только managed shared-артефакты;
- поддерживать dry-run или validate-only режим;
- не использовать blind delete по всей .github;
- позволять review diff перед фиксацией изменений.
