---
name: cadence-plan
description: Write Dev Cadence delivery plans. Use after intent and design are clarified and before implementation, especially when work must be split into executable tasks with files, behavior, verification, risks, and review checkpoints.
---

# Cadence Plan

Use this Skill only after requirements readiness is satisfied or the remaining gaps are explicitly accepted by a named Human Gate.

## Core Rule

Create executable implementation plans. A Worker with no chat history and limited context must be able to complete one task from the plan without inventing files, APIs, behavior, acceptance criteria, or verification.

Vague plans fail planning review.

## Required References

- `../../references/principles.md`
- `../../references/planning-discipline.md`
- `../../references/spec-templates.md`

Use the skill-local `skills/cadence-plan/plan-document-reviewer.md` prompt when an independent plan review is needed.

## Scope

Produce implementation plan content: file structure, ordered tasks, task-level TDD or characterization steps, verification commands, risks, dependencies, and review checkpoints.

When persistent artifacts are used, the plan content should be easy to place into `03-tasks.md` and `04-test-plan.md`.

For `S0`, a lightweight plan in the conversation is acceptable only when the task is tiny, local, reversible, and low risk. When unsure, use a standard `S1` implementation plan.

## Scope Check

Before writing tasks, check whether the requirements/design cover multiple independent subsystems. If they do, stop and return a decomposition recommendation to `using-dev-cadence` instead of writing one large plan.

Each plan should produce working, testable software on its own. Do not hide unrelated projects inside one task list.

## File Structure Planning

Before defining implementation tasks, map created and modified files. This is where decomposition decisions get locked in.

For every planned file, state its responsibility and why it belongs there:

- design units with clear boundaries and explicit interfaces;
- prefer smaller focused files over large files that do too much;
- keep files that change together near each other when repository conventions allow;
- follow existing repository patterns;
- do not add unrelated restructuring;
- if a touched file is already large or tangled, include only the targeted improvement needed for this work.

The file structure map must inform task boundaries. Each task should produce a self-contained change that makes sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth an independent review gate.

When drawing task boundaries:

- fold setup, configuration, scaffolding, docs, and fixtures into the task whose deliverable needs them;
- split only where a reviewer could meaningfully reject one task while approving its neighbor;
- keep each task to one behavior slice or one tightly related component change;
- ensure each task ends with an independently testable deliverable;
- avoid tasks that require unbounded exploration or new requirements decisions.

## Plan Document Shape

The plan must start with a clear header:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [one sentence describing the accepted outcome]

**Architecture:** [2-3 sentences describing the approved approach]

**Tech Stack:** [key technologies, libraries, versions, and repository conventions]

## Global Constraints

[Project-wide requirements copied from the approved requirements/design: version floors, dependency limits, naming rules, platform requirements, security/privacy constraints, artifact language, and forbidden scope. Every task inherits these constraints.]
```

Replace bracketed placeholders with actual accepted values in the final handoff content.

## Task Structure

Each task must include this information:

```markdown
### Task N: [Component or behavior name]

**Goal:** [what this task delivers]

**Files:**
- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext` or `exact/path/to/existing-file.ext:line-range`
- Test: `exact/path/to/test-file.ext` or `not_applicable: [reason]`

**Interfaces:**
- Consumes: [interfaces, files, data, commands, or artifacts this task depends on]
- Produces: [functions, types, behavior, files, commands, or evidence later tasks rely on]

**Acceptance Mapping:**
- Covers: [accepted requirement or acceptance criterion IDs/names]

**Test-First Plan:**
- Red behavior or characterization: [specific behavior to prove before implementation]
- Red command: `exact command or documented manual check`
- Expected Red result: [specific failing output or characterization result]
- Green command: `exact command or documented manual check`
- Expected Green result: [specific passing output]
- Neighboring checks: [related commands or manual checks]

**Test-First Exception:** [only when test-first feedback is not useful or possible: reason, substitute feedback, residual risk, and required Human decision if any]

**Implementation Detail:**
- Test detail: [test name, fixture/data shape, assertion, and expected failure]
- Code detail: [function/type/API signatures, data fields, config keys, or pseudocode required]
- New/changed surface: [exports, commands, user-visible behavior, or integration contract]

**Steps:**
- [ ] Write the failing test or characterization check.
  - Command: `exact command or documented manual check`
  - Expected: [specific failure or characterization output]
- [ ] Implement the minimal change.
- [ ] Run focused verification.
  - Command: `exact command or documented manual check`
  - Expected: [specific result]
- [ ] Run relevant neighboring/regression checks.
  - Command: `exact command or documented manual check`
  - Expected: [specific result]
- [ ] Record review checkpoint notes: changed files, verification results, skipped checks, and residual risk.

**Dependencies:** [prior tasks or external decisions]

**Risk:** [correctness, security, data, UX, migration, or operational risk]

**Expected Evidence:** [Red/characterization result, Green result, neighboring check output, manual check, diff summary, or review checkpoint]
```

Use checkbox (`- [ ]`) steps so execution can track progress. Do not include commit steps unless the Human explicitly asked this workflow to plan commits.

## No Placeholders

Every task must contain the actual content an implementer needs. These are plan failures:

- `TBD`, `TODO`, `implement later`, `fill in details`, or bracketed placeholders in final content;
- "add appropriate error handling" without naming the exact failure modes;
- "add validation" without naming exact invalid cases;
- "handle edge cases" without listing the edge cases;
- "write tests" or "test the above" without naming behavior, file, command, and expected result;
- "similar to Task N" instead of repeating the needed details;
- code-changing steps that lack enough test/code detail to prevent a Worker from inventing signatures, fields, or behavior;
- references to functions, types, files, commands, APIs, or dependencies that are neither present in the repository nor created by an earlier task;
- broad tasks that mix unrelated changes or require new architecture decisions.

If any of these appear, fix the plan before handoff or return a blocker.

## Test Plan Requirements

The verification plan must map checks to the accepted behavior and task list:

- exact commands or manual checks;
- expected result for each command/check;
- Red/Green or characterization evidence for each testable task;
- test-first exceptions with substitute feedback and residual risk;
- coverage for changed components and integration points;
- skipped checks with reason, residual risk, and whether a Human decision is required;
- review and verification checkpoints.

Do not let "tests pass" stand in for acceptance mapping. The plan must say which requirement each verification step proves.

## Self-Review

After producing the full plan content, review it yourself before handoff:

1. **Requirement coverage:** Every accepted requirement and non-goal maps to tasks or explicit exclusions.
2. **Scope control:** No task adds unaccepted behavior, dependencies, platforms, migrations, or broad refactors.
3. **Placeholder scan:** No `TBD`, `TODO`, vague edge cases, bracket placeholders, or "similar to" shortcuts remain.
4. **File/interface consistency:** Names, paths, signatures, data fields, commands, and artifact paths match across tasks.
5. **Task buildability:** Tasks are ordered so each dependency exists before use.
6. **Verification quality:** Each task has Red/characterization, Green, neighboring checks, and expected results, or a named test-first exception.
7. **Implementation specificity:** Code-changing steps include enough test/code detail that a Worker does not invent signatures, fields, or behavior.
8. **Worker context:** A fresh Worker can execute one task without chat history or guessing.

Fix issues inline in the handoff content. If a requirement cannot be planned without a new Human decision, surface the blocker in the handoff instead of inventing scope.

## Execution Handoff

When planning is ready, return a concise handoff to `using-dev-cadence` with:

- implementation plan content;
- file structure map;
- task count and ordering;
- serial or parallel execution candidates with dependency notes;
- unresolved blockers and required Human decisions;
- skipped checks and residual risk.

End with the plan handoff.
