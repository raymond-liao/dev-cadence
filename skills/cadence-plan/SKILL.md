---
name: cadence-plan
description: Write Dev Cadence delivery plans. Use after intent and design are clarified and before implementation, especially when work must be split into executable tasks with files, behavior, verification, risks, and review checkpoints.
---

# Cadence Plan

Use this Skill only after requirements readiness is satisfied or the remaining gaps are explicitly accepted by a named Human Gate.

## Core Rule

Create executable plans. A Worker with no chat history and limited context must be able to complete one task from the plan without inventing files, APIs, behavior, acceptance criteria, or verification.

Vague plans are blocked at G3.

## Required References

- `../../references/principles.md`
- `../../references/planning-discipline.md`
- `../../references/spec-templates.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`

Use the skill-local `skills/cadence-plan/plan-document-reviewer.md` prompt when an independent plan review is needed.

## Scope

Produce artifact-ready planning content for:

- `specs/records/{task_id}/03-tasks.md`;
- `specs/records/{task_id}/04-test-plan.md`.

Leave concrete artifact writes to the Supervisor/Harness path unless this Skill is explicitly being used as the artifact authoring action.

For `S0`, a lightweight plan in the conversation or compact evidence note is acceptable only when the task is tiny, local, reversible, and low risk. When unsure, use standard `S1` artifact-ready content.

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

`03-tasks.md` content must start with a clear header:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [one sentence describing the accepted outcome]

**Architecture:** [2-3 sentences describing the approved approach]

**Tech Stack:** [key technologies, libraries, versions, and repository conventions]

## Global Constraints

[Project-wide requirements copied from the approved requirements/design: version floors, dependency limits, naming rules, platform requirements, security/privacy constraints, artifact language, and forbidden scope. Every task inherits these constraints.]
```

Do not leave bracketed placeholders in the final handoff content. Replace them with the actual accepted values or return a blocker.

## Task Structure

Each task must include this information:

```markdown
### Task N: [Component or behavior name]

**Goal:** [what this task delivers]

**Files:**
- Create: `exact/path/to/new-file.ext`
- Modify: `exact/path/to/existing-file.ext` or `exact/path/to/existing-file.ext:line-range`
- Test: `exact/path/to/test-file.ext`

**Interfaces:**
- Consumes: [interfaces, files, data, commands, or artifacts this task depends on]
- Produces: [functions, types, behavior, files, commands, or evidence later tasks rely on]

**Acceptance Mapping:**
- Covers: [accepted requirement or acceptance criterion IDs/names]

**Steps:**
- [ ] Write the failing test or characterization check.
  - Command: `exact command`
  - Expected: [specific failure or characterization output]
- [ ] Implement the minimal change.
- [ ] Run focused verification.
  - Command: `exact command`
  - Expected: [specific passing result]
- [ ] Run relevant neighboring/regression checks.
  - Command: `exact command or documented manual check`
  - Expected: [specific result]
- [ ] Return changed files, evidence, skipped checks, and residual risk for Supervisor/Harness recording.

**Dependencies:** [prior tasks or external decisions]

**Risk:** [correctness, security, data, UX, migration, or operational risk]

**Expected Evidence:** [test output, diff summary, manual check, review checkpoint, or gate input]
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
- references to functions, types, files, commands, APIs, or dependencies that are neither present in the repository nor created by an earlier task;
- broad tasks that mix unrelated changes or require new architecture decisions.

If any of these appear, fix the plan before handoff or return a blocker.

## Test Plan Requirements

`04-test-plan.md` content must map verification to the accepted behavior and task list:

- test strategy by task or behavior slice;
- exact commands or manual checks;
- expected result for each command/check;
- coverage for changed components and integration points;
- skipped checks with reason, residual risk, and whether a Human Gate is required;
- review checkpoints and evidence expected for G4/G5/G6.

Do not let "tests pass" stand in for acceptance mapping. The plan must say which requirement each verification step proves.

## Self-Review

After producing the full plan content, review it yourself before handoff:

1. **Requirement coverage:** Every accepted requirement and non-goal maps to tasks or explicit exclusions.
2. **Scope control:** No task adds unaccepted behavior, dependencies, platforms, migrations, or broad refactors.
3. **Placeholder scan:** No `TBD`, `TODO`, vague edge cases, bracket placeholders, or "similar to" shortcuts remain.
4. **File/interface consistency:** Names, paths, signatures, data fields, commands, and artifact paths match across tasks.
5. **Task buildability:** Tasks are ordered so each dependency exists before use.
6. **Verification quality:** Each task has exact commands/checks and expected results.
7. **Worker context:** A fresh Worker can execute one task without chat history or guessing.

Fix issues inline in the handoff content. If a requirement cannot be planned without a new Human decision, return the blocker to `using-dev-cadence` instead of inventing scope.

## Execution Handoff

When planning is ready, return a concise handoff to `using-dev-cadence` with:

- artifact-ready `03-tasks.md` and `04-test-plan.md` content or their Supervisor/Harness recording fields;
- file structure map;
- task count and ordering;
- recommended execution path: `cadence-subagent-development` for bounded independent Worker tasks, `cadence-executing-plans` for inline execution, or `cadence-dispatch-parallel` only for independent domains selected by the Supervisor;
- unresolved blockers and required Human decisions;
- gate status, skipped checks, and residual risk.

Do not invoke execution Skills from here. Do not implement the plan from this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
