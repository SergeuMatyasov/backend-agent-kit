# Minimal Consumer Layout

## Цель

Показать минимальную целевую структуру consumer-репозитория после перехода на backend-agent-kit.

## Пример структуры

```text
service-repo/
  .github/
    workflows/
    instructions/
    skills/
    agents/
    hooks/
    prompts/
  tools/
    backend-agent-kit/
```

## Принцип

1. tools/backend-agent-kit содержит shared source of truth.
2. .github/* содержит уже разложенные shared-файлы и локальные repo-specific файлы.
3. workflows остаются локальными.
4. Copilot читает кастомизации из .github/*, а не из произвольной вложенной папки.

## Пример после sync

```text
service-repo/
  .github/
    workflows/
      openapi-publish.yml
    instructions/
      shared-dotnet-testing.instructions.md
      image-domain.instructions.md
    skills/
      clean-code-principles/
      unit-testing/
      image-meta-analysis/
    agents/
      shared-code-reviewer.agent.md
      image-review.agent.md
    hooks/
      shared-openapi-drift.json
      local-dangerous-command-guard.json
    prompts/
      shared-controller-review.prompt.md
      local-regression-check.prompt.md
  tools/
    backend-agent-kit/
      instructions/
      skills/
      agents/
      hooks/
      prompts/
      scripts/
      templates/
      docs/
```

## Что важно

- backend-agent-kit не заменяет .github целиком;
- .github остается обычной директорией consumer-репозитория;
- shared и local файлы живут рядом;
- migration target считается корректным только если итоговые active files оказались в поддерживаемых путях .github/*.
