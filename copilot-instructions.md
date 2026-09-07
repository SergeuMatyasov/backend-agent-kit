# Project Instructions

## Decisions And Follow-Through

- Identify factual mistakes and concrete technical risks candidly; explain the better option and its relevant tradeoff.
- For an implementation request, complete the authorized work and relevant verification. Resolve routine, reversible implementation choices from repository evidence instead of treating every uncertainty as a reason to stop.
- Ask when a missing decision materially changes the outcome and cannot be inferred, or when the proposed path changes a public contract, architecture, rollout, or migration strategy beyond the user's authorization. Do not request the same authorization again.
- Continue independent, authorized work while a decision is pending. Prepare evidence and a concrete proposal before requesting a decision.
- Preserve analysis-only, plan-only, and explicitly stepwise review requests; they do not authorize automatic implementation or skipping user checkpoints.
- Surface material assumptions and do not silently follow a demonstrably flawed premise.

## Instruction Scope And Validation

- Apply scoped instructions to the matching work. Read required files fully, but do not repeatedly load unchanged instructions already available in context.
- Select skills for the actual deliverable. Related-skill lists are navigation; load an additional skill only when its rules apply to the current task or it is explicitly required.
- Skill defaults do not override the user's explicit scope, output format, or already-authorized decisions. Explain the exact conflicting instruction if it prevents completion, subject to higher-priority instructions and tool permissions.
- Run required repository checks and tests that cover changed behavior and affected contracts. Add regression coverage for meaningful behavior changes; do not add tests solely to mirror an implementation or repeat broad suites without a new reason.
- Report results, relevant verification, and remaining limitations concisely. Keep internal checklists internal unless the user requests them or they are a requested artifact.

## Professional Quality Rule

- Preserve local consistency by default within the touched slice.
- Do not copy obvious anti-patterns, weak designs, or low-quality code style just because they are common in the project.
- For new code and substantial refactoring, prefer the more professional, maintainable, and technically sound solution.
- If deviating from the existing project style is necessary to avoid an anti-pattern or materially improve the result, explain the reason, the tradeoff, and the proposed scope before making that change.
- Do not expand a task into broad stylistic cleanup or codebase-wide rewriting without explicit confirmation from the user.
- When the existing style is imperfect but not harmful enough to justify divergence in the current slice, keep the change local and call out the issue instead of silently spreading either pattern.

## Clean Architecture Guard Rule

- Treat clean architecture as the default baseline when creating, moving, or refactoring code.
- Place new code in the owning layer instead of following nearby legacy placement when that legacy placement is architecturally wrong.
- Keep business decisions in Domain or Application, delivery concerns in Host, technical adapters in Infrastructure, and provider-specific persistence in EFCore.
- Do not add new use cases, orchestration, or business rules to Infrastructure, EFCore, Host, or convenience folders just because the surrounding code already does that.
- When the touched old code contains a clean architecture violation, explicitly call it out instead of silently extending the pattern.
- If that violation is small and safe to correct inside the current slice, propose the correction or include it after confirming scope when needed.
- If the violation is broader, risky, or not necessary to finish the requested task safely, propose the smallest safe follow-up instead of expanding scope silently.
- When placement or ownership is unclear, stop and resolve the ambiguity before adding more code to the wrong layer.

## SOLID Guard Rule

- Treat SOLID as a design baseline when creating, splitting, extending, or refactoring code.
- Keep responsibilities narrow and explicit instead of letting one class, handler, service, or controller accumulate unrelated reasons to change.
- Extend behavior through stable seams when variation is real, but do not manufacture abstractions, interfaces, or strategy layers with no real ownership or second use case.
- Keep contracts substitutable: implementations, derived types, and adapters must honor the expectations of the abstraction they implement.
- Prefer narrow interfaces and dependency boundaries that expose only what the caller actually needs.
- Depend on abstractions at module boundaries when behavior crosses technical or architectural seams, but do not cargo-cult DIP inside tiny local code where a direct dependency is clearer.
- When the touched old code contains a meaningful SOLID violation, explicitly call it out instead of silently copying the pattern into new code.
- If that violation is small and safe to improve inside the current slice, propose the correction or include it after confirming scope when needed.
- If the violation is broader, risky, or not required to complete the task safely, propose the smallest safe follow-up instead of expanding scope silently.

## Duplication And Cohesion Rule

- Prefer one clear owning implementation for one behavior instead of copying the same logic across handlers, services, controllers, repositories, or helpers.
- When logic starts repeating, extract the smallest stable shared unit into the layer that owns the behavior, but do not force weak abstractions just to satisfy DRY mechanically.
- Keep modules cohesive: a class, handler, service, or file should serve one tight concern instead of mixing orchestration, mapping, validation, persistence, transport, and business rules.
- Reduce coupling by depending on narrow inputs and outputs rather than reaching through deep object chains or leaking internal state across boundaries.
- Hide mutable or sensitive internals behind explicit operations and stable contracts instead of exposing data structures only to let outside code manipulate them.

## Pragmatic Simplicity Rule

- Prefer the simplest design that cleanly solves the current requirement.
- Do not add extension points, feature flags, abstractions, configuration knobs, or prebuilt scenarios for hypothetical future needs.
- Add complexity only when a real second use case, variation point, or operational constraint makes it necessary.
- Prefer convention and existing project patterns over new local frameworks, custom pipelines, or bespoke configuration unless they materially improve the result.
- Prefer composition or small collaborating types over deep inheritance trees when behavior needs to vary.

## Contract Clarity Rule

- Make behavior unsurprising: names, return values, side effects, and failure modes should match what another developer would reasonably expect.
- Prefer commands that mutate and queries that read to stay distinct; do not hide writes, remote calls, or expensive side effects behind read-like APIs.
- Validate critical assumptions early and fail fast before partial side effects leave the system in an invalid state.
- Keep public interfaces narrow and explicit; expose only the operations and data a caller actually needs.
- Give code, components, and integrations only the minimum access, scope, and privilege needed for the current job.

## Meaningful Improvement Rule

- If the user asks whether something can be improved, or asks you to improve it, and the current result is already good enough, say that explicitly.
- Do not invent cosmetic churn, fake optimization, or other busywork when it does not materially improve the outcome.
- If further changes would add motion without meaningful benefit, explain that clearly and stop instead of simulating progress.

## Adjacent Improvement Rule

- If, while working on the requested task, you notice a bug, risky behavior, clear optimization, or other meaningful improvement in pre-existing code, surface it to the user instead of staying silent.
- If that improvement is small, adjacent, and safe, you may propose including it in the current slice.
- If that improvement is broader, riskier, or changes the scope materially, call it out as a follow-up or ask whether to include it instead of expanding scope silently.

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
- If an authorized task contains multiple goals, organize it into reviewable slices and validate each before continuing.
- For a large implementation request, state a concrete staged plan and continue through the authorized stages. Pause only for unresolved consequential decisions or explicit user checkpoints.
- If the expected volume of edits is likely to reduce solution quality, reviewability, or validation confidence, warn the user and suggest a narrower slice or staged delivery.
- Do not leave a task in a half-migrated or ambiguously mixed state when a smaller complete slice is possible.
