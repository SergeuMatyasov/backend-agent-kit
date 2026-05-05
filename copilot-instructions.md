# Project Instructions

## Mandatory Consultation Rule

- If the user request contains a likely mistake, risky assumption, hidden regression risk, weak technical idea, suspicious constraint, or a materially better solution exists, stop before making edits or implementing the requested path.
- Explain briefly what looks wrong, risky, incomplete, or suboptimal.
- Propose the safer or better alternative first, with the key tradeoff.
- Ask for confirmation before proceeding when the better path changes architecture, contract, rollout, migration strategy, testing scope, or other important technical decisions.
- If a disputed or ambiguous decision materially affects the result and cannot be resolved confidently from the local context, ask the user instead of guessing.
- When escalation is needed, let the user either decide directly or explicitly delegate the decision back to the agent.
- Do not follow a technically weak or suspicious request blindly just because it was requested.
- If the user suggests one implementation idea, but there is a stronger option, present that option before execution.
- When assumptions are unverified and they matter to the result, surface them explicitly and discuss them before acting.

## Professional Quality Rule

- Preserve local consistency by default within the touched slice.
- Do not copy obvious anti-patterns, weak designs, or low-quality code style just because they are common in the project.
- For new code and substantial refactoring, prefer the more professional, maintainable, and technically sound solution.
- If deviating from the existing project style is necessary to avoid an anti-pattern or materially improve the result, explain the reason, the tradeoff, and the proposed scope before making that change.
- Do not expand a task into broad stylistic cleanup or codebase-wide rewriting without explicit confirmation from the user.
- When the existing style is imperfect but not harmful enough to justify divergence in the current slice, keep the change local and call out the issue instead of silently spreading either pattern.

## Reuse And Ownership Rule

- Reuse existing implementations before introducing duplicates.
- Before adding a reusable component, first check whether an equivalent implementation already exists in the repo and whether its semantics actually match the need.
- Keep feature-owned logic local until there is real shared semantics and clear ownership.
- It is acceptable to extract a small, pure, stable, cross-cutting primitive immediately when its responsibility is clearly generic and not owned by one feature.
- If the same logic starts to appear in multiple places, treat that as a trigger to extract it into the proper owning layer instead of duplicating it again.
- Do not move code to `Shared` by default. `Shared` is for stable cross-cutting code, not a convenience bucket.
- Do not introduce generic buckets such as `IService`, `Helper`, or `Utils` when a more specific domain or technical role can be named.
- If similar code exists but the semantics differ, keep the code local instead of forcing a weak shared abstraction.
- When reusable code is extracted, place it in the layer that owns the behavior rather than in a convenience bucket.

## Behavior Preservation Rule

- Refactoring and migration work should preserve behavior by default unless the user explicitly asked for a behavior change.
- Separate structural cleanup from behavior changes whenever practical.
- Do not remove an old path, fallback, or legacy behavior until the new path is validated strongly enough for that slice.
- When behavior preservation is uncertain, call it out explicitly instead of assuming equivalence.

## Root Cause Rule

- Prefer fixing the root cause over applying a surface-level patch when the safer path is clear.
- Do not add workaround-only logic without saying that it is a workaround and what risk remains.
- If a proper fix is too large for the current task, propose the smallest safe fix now and state the follow-up clearly.

## Slice Readiness Rule

- Prefer changes that can be reviewed, validated, and explained as one logical slice.
- If a task naturally contains multiple independent goals, propose splitting it into separate slices or PR stages before implementation.
- If the requested task is too large to implement safely as one slice, stop and propose a concrete breakdown before proceeding.
- If the expected volume of edits is likely to reduce solution quality, reviewability, or validation confidence, warn the user and suggest a narrower slice or staged delivery.
- Do not leave a task in a half-migrated or ambiguously mixed state when a smaller complete slice is possible.