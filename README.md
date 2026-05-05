# backend-agent-kit

Shared source of truth for reusable Copilot customizations in backend repositories.

## Purpose

This repository stores shared backend-oriented customization layers:

- instructions;
- skills;
- agents;
- hooks;
- prompts;
- scripts;
- templates;
- docs.

The repository is no longer intended to be mounted directly into `.github/skills` of a consumer repository.

Instead, it should be:

1. connected outside `.github`, for example as `tools/backend-agent-kit`;
2. used as a source of truth;
3. synced into supported target paths inside `.github/*` of the consumer repository.

## Structure

```text
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

## Consumer Workflow

1. Update or pin `tools/backend-agent-kit` in the consumer repository.
2. Run the sync script that distributes shared artifacts into `.github/instructions`, `.github/skills`, `.github/agents`, `.github/hooks` and `.github/prompts`.
3. Review the resulting diff in the consumer repository.
4. Commit the consumer-side changes separately.

## What Stays Local In The Consumer Repo

The shared repo does not own:

- `.github/workflows`;
- repo-specific instructions, skills, agents, hooks and prompts;
- local `AGENTS.md` or `copilot-instructions.md`, unless a repository explicitly decides otherwise;
- service-specific documentation and scripts.

## Reference Docs

- `docs/backend-agent-kit-contract.md`
- `docs/mapping-rules.md`
- `docs/local-repo-artifacts.md`
- `docs/minimal-consumer-layout.md`
