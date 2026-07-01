# Planning Discipline

Use this reference in the `planning` state before implementation.

## Core Rule

Planning must create executable tasks. A Worker should be able to complete one task with the provided context, exact files, expected behavior, and verification steps.

Vague plans are blocked at G3.

## Plan Shape

Each implementation task should include:

- task name and goal;
- exact files to create, modify, or test;
- acceptance criteria covered by the task;
- dependencies and ordering constraints;
- forbidden actions and out-of-scope changes;
- Red or characterization step;
- command to run and expected failing output;
- minimal implementation step;
- command to run and expected passing output;
- refactor allowance and required re-verification;
- review or checkpoint expectation.

## Plan Failures

Do not pass G3 when a plan contains:

- `TBD`, `TODO`, `implement later`, or `fill in details`;
- "write tests" without the behavior being tested;
- "add validation" without naming exact invalid cases;
- "handle edge cases" without naming the edge cases;
- references to functions, types, files, or APIs not present in prior context or created by the plan;
- task descriptions broad enough to require unbounded exploration;
- tasks that mix unrelated changes;
- verification commands without expected result;
- missing acceptance mapping.

## Task Granularity

Prefer tasks that can be implemented, verified, and reviewed as a bounded unit.

Good task boundaries:

- one behavior slice;
- one component or small set of related files;
- one failing test or characterization;
- one clear handoff.

Split work when a task requires multiple independent decisions, multiple subsystems, or unclear architecture.

## File Structure Planning

Before writing implementation tasks, map created and modified files:

- each file should have one clear responsibility;
- interfaces should be explicit enough that consumers do not need internals;
- files that change together should live together when repository conventions allow;
- avoid unrelated restructuring;
- if a touched file is already large or tangled, include only targeted improvement needed for the task.

## Plan Review

After writing `03-tasks.md`, review it against `01-requirements.md` and `02-design.md` when present.

Check:

- every accepted requirement maps to one or more tasks;
- no task adds unaccepted scope;
- task order is buildable;
- each task includes verification;
- Worker handoff context is sufficient;
- parallel candidates are independent.

For independent review, use the `cadence-plan` reviewer prompt through the Supervisor handoff.
