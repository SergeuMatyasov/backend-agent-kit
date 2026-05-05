# Local Repo Artifacts

## Назначение

Этот документ фиксирует, какие артефакты должны оставаться локальными в consumer-репозитории и не должны управляться backend-agent-kit.

## Локальные артефакты consumer-репозитория

Локальными считаются:

- .github/workflows/;
- AGENTS.md конкретного репозитория;
- repo-specific overlay для shared project-wide instructions, например `.github/copilot-instructions.local.md`;
- repo-specific instructions;
- repo-specific skills;
- repo-specific agents;
- repo-specific hooks;
- repo-specific prompts;
- domain-specific документация и scripts, связанные только с одним сервисом.

## Правило сосуществования shared и local слоев

1. Shared repo поставляет только повторно используемые backend-артефакты.
2. Consumer-репозиторий имеет право добавлять рядом локальные файлы.
3. Shared sync не должен считать локальные файлы своей собственностью.
4. Удаление локальных файлов во время sync считается ошибкой.

## Примеры локальных артефактов

Для типового backend-сервиса локальными могут быть:

- openapi drift checks, завязанные на конкретный контракт репозитория;
- repo-specific дополнения к shared `.github/copilot-instructions.md`, вынесенные в `.github/copilot-instructions.local.md`;
- инструкции по конкретному модулю или bounded context;
- prompts для внутренней команды проекта;
- hooks, завязанные на локальные scripts и локальную инфраструктуру;
- service-specific skills, не подходящие для общего backend-kit.
