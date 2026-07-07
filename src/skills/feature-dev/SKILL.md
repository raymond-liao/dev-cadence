---
name: feature-dev
description: Use when a user asks to add or change user-visible or system-visible feature behavior in a target project.
---

# Feature Dev

Use this skill to manage the Dev Cadence `feature-dev` workflow.

This skill orchestrates vendored Superpowers skills from:

```text
.dev-cadence/vendor/superpowers/skills/
```

Do not substitute globally installed Superpowers skills unless the user explicitly asks to do so.

Keep task artifacts in the target repository's normal project space. Do not write task artifacts, plans, reports, or acceptance records inside `.dev-cadence/`; that directory is the installed rules package.

## Stage Order

Run exactly one stage at a time:

```text
需求确认 -> 制定技术方案 -> 制定计划 -> 开发实施 -> 系统测试 -> 业务验收
```

Do not skip stages. Do not start implementation before the user has approved requirements, technical solution, and TDD implementation plan.

## Stage 1: 需求确认

Purpose: produce `明确的需求`.

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Apply only the requirements clarification parts:

- understand the user goal and target project context;
- ask one clarifying question at a time when needed;
- identify scope, non-goals, acceptance criteria, obvious contradictions, and issues that need technical solution work;
- present the clarified requirement for user approval.

Stop when the user confirms the requirement.

Do not produce a technical solution, implementation plan, or code in this stage.

## Stage 2: 制定技术方案

Purpose: produce `技术方案`.

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Apply only the design and approach parts:

- inspect the relevant project structure;
- identify feasible technical approach;
- list affected boundaries, constraints, risks, and tradeoffs;
- ask for user decision when a business tradeoff or risk acceptance is needed;
- present the technical solution for user approval.

Stop when the user confirms the technical solution.

Do not write the TDD implementation plan or code in this stage.

## Stage 3: 制定计划

Purpose: produce `TDD 开发实施计划`.

Use:

```text
.dev-cadence/vendor/superpowers/skills/writing-plans/SKILL.md
```

The plan must serve only the next stage, `开发实施`.

The plan must include:

- input requirement and technical solution;
- implementation modules;
- behavior scenarios;
- TDD cycles for each behavior;
- failing test step;
- minimal implementation step;
- passing verification step;
- refactor or cleanup step;
- concrete output for each task.

Do not create the system test plan or business acceptance plan in this stage.

Stop when the user confirms the TDD implementation plan.

## Stage 4: 开发实施

Purpose: produce `可工作的交付物`, `配套测试资产`, and `实施记录`.

Use:

```text
.dev-cadence/vendor/superpowers/skills/test-driven-development/SKILL.md
.dev-cadence/vendor/superpowers/skills/executing-plans/SKILL.md
```

Follow the approved TDD implementation plan.

For each behavior:

1. write the failing test;
2. run it and confirm the expected failure;
3. write minimal implementation;
4. run the test and confirm it passes;
5. refactor only after green;
6. record what changed and what verification ran.

If debugging is needed, use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

Do not push development-stage testing into `系统测试`.

## Stage 5: 系统测试

Purpose: produce `系统测试报告`.

Use:

```text
.dev-cadence/vendor/superpowers/skills/verification-before-completion/SKILL.md
```

Verify the working deliverable in the target project:

- read the confirmed requirement, technical solution, TDD implementation plan, and implementation record;
- confirm actual changed scope and run entry points;
- define system-level test scenarios from the requirement and actual changes;
- execute system tests;
- record passed checks, failures, skipped checks, residual risk, and whether the work can enter business acceptance.

If system testing reveals a bug, use:

```text
.dev-cadence/vendor/superpowers/skills/systematic-debugging/SKILL.md
```

Do not claim the system is ready without fresh verification evidence.

## Stage 6: 业务验收

Purpose: produce `业务验收记录`.

Superpowers does not provide a dedicated business acceptance skill. Use this Dev Cadence rule:

- summarize the confirmed requirement;
- summarize the technical solution and implementation result;
- summarize system test evidence and residual risks;
- ask the user for a named decision: accept, reject, or accept with residual risk;
- record the decision and the accepted residual risks.

Do not substitute system test success for user acceptance.

## Review

When code review is required, use:

```text
.dev-cadence/vendor/superpowers/skills/requesting-code-review/SKILL.md
```

Code review does not replace system testing or business acceptance.
