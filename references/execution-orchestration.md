# Execution Orchestration

Use this reference when executing a plan through Workers or deciding between inline, sequential subagent, and parallel execution.

## Core Rule

Supervisor chooses execution shape. Harness records every Worker run. Worker context must be focused and explicit; do not rely on inherited chat history.

## State Loading Contract

For each Worker run, provide:

- task text or review target;
- Context Pack;
- Harness Run Context;
- pre-implementation status for S1/S2 implementation or fix runs;
- allowed files and forbidden actions;
- expected artifacts;
- required evidence;
- handoff target.

Use prompt templates under `templates/prompts/` when dispatching Workers.

## Subagent-Style Execution

Use independent Worker contexts when the platform supports them and tasks are bounded.

Per task:

1. Dispatch implementer with full task text and context.
2. If implementer asks questions, answer or update artifacts before implementation.
3. Implementer completes work, verification, and self-review.
4. Run spec compliance review.
5. Fix spec gaps and re-review until clear.
6. Run code quality review.
7. Fix blocking quality issues and re-review.
8. Mark task complete only after required evidence is recorded.

Do not move to a dependent task while spec compliance or blocking code-quality issues remain open.

## Inline Execution

Use inline execution when subagents are unavailable or the work is tightly coupled.

Inline execution must still:

- follow task order;
- maintain Harness run evidence;
- capture S1/S2 pre-implementation status before product edits;
- perform Red-Green-Refactor when required;
- run verification;
- perform spec compliance and code quality review checkpoints;
- stop when blocked instead of guessing.

## Parallel Worker Runs

Use parallel runs only when there are two or more independent domains:

- independent failing test files;
- independent subsystems;
- independent investigation tracks;
- independent research options;
- review slices that do not share mutable state.

Do not parallelize when Workers would:

- edit the same files;
- depend on each other's findings;
- share mutable state;
- require a whole-system mental model;
- likely create merge conflicts.

## Integration After Parallel Runs

After parallel runs return:

1. Review each summary and changed file list.
2. Check for overlapping edits and semantic conflicts.
3. Run integrated verification.
4. Record integration evidence.
5. Continue to review only after conflicts and verification gaps are resolved.

## Worker Status Handling

Treat Worker reports as claims that need evidence.

Allowed statuses:

```text
DONE
DONE_WITH_CONCERNS
NEEDS_CONTEXT
BLOCKED
```

Handle them as follows:

- `DONE`: proceed to required review.
- `DONE_WITH_CONCERNS`: inspect concerns before review; update artifacts or escalate if correctness or scope is affected.
- `NEEDS_CONTEXT`: provide context or update task artifacts before re-dispatch.
- `BLOCKED`: analyze whether the blocker is missing context, task size, model capability, plan flaw, or external dependency.

Never force the same Worker to retry unchanged after it reports a real blocker.
