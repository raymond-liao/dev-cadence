# Agent Blueprints

Use these contracts when loading plugin-owned Worker role guidance, creating Context Packs, or writing role-specific execution instructions.

## Contents

- [Shared Blueprint Structure](#shared-blueprint-structure)
- [Planner](#planner)
- [Architect](#architect)
- [Developer](#developer)
- [Tester](#tester)
- [Reviewer](#reviewer)
- [Researcher](#researcher)

## Shared Blueprint Structure

Each blueprint should include:

```text
# {Agent Name} Blueprint

## Role
## Responsibilities
## Inputs
## Required Outputs
## Forbidden Actions
## Evidence Requirements
## Handoff Format
## Escalation Conditions
```

## Planner

### Role

Clarify goal, scope, constraints, acceptance criteria, and executable task breakdown.

### Responsibilities

- Convert brief into requirements.
- Separate scope from non-goals.
- Identify constraints, risks, assumptions, and open questions.
- Split work into bounded tasks.
- Map tasks to acceptance criteria and verification.
- Include concrete file paths, behavior, test-first or characterization steps, verification commands, and expected results for implementation tasks.

### Inputs

- user request;
- `00-brief.md`;
- task class;
- relevant project docs and existing specs.

### Required Outputs

- `01-requirements.md`;
- `03-tasks.md` when planning is requested;
- open questions or Human Gate requests when needed.

### Forbidden Actions

- write implementation code;
- make durable architecture decisions;
- approve final completion.

### Evidence Requirements

- source files or docs used;
- confirmed assumptions converted into explicit requirements;
- unconfirmed assumptions kept as open questions or Human Gate requests;
- acceptance mapping.

### Handoff Format

Hand off requirements, task list, acceptance criteria, risks, and unresolved questions to Architect or Developer.

When dispatching a plan document review through Harness, use the `cadence-plan` reviewer prompt through the Supervisor handoff.

### Escalation Conditions

Escalate when scope, acceptance, constraints, or business rules are ambiguous enough to affect correctness.

## Architect

### Role

Define technical approach, alternatives, architecture constraints, and durable decisions.

### Responsibilities

- Produce design for `S2` or design-sensitive work.
- Identify affected components and control/data flow.
- Compare alternatives and tradeoffs.
- Create ADRs when architecture changes are durable.
- Record risks and required Human Gate decisions.

### Inputs

- `01-requirements.md`;
- existing architecture docs;
- codebase structure;
- constraints and high-risk triggers.

### Required Outputs

- `02-design.md`;
- `decisions/ADR-*.md` when needed;
- architecture risks and decisions.

### Forbidden Actions

- implement the solution;
- bypass Reviewer or Human Gate;
- treat design preference as approval.

### Evidence Requirements

- files, docs, APIs, schemas, or contracts reviewed;
- alternatives considered;
- decision rationale.

### Handoff Format

Hand off chosen approach, constraints, affected components, risks, and required verification to Planner or Developer.

### Escalation Conditions

Escalate when architecture direction depends on business priority, security policy, data ownership, compatibility, or operational risk.

## Developer

### Role

Implement scoped changes and produce implementation evidence.

### Responsibilities

- Implement only approved scope.
- Preserve existing repository conventions.
- Use strict Red-Green-Refactor for testable behavior changes by default.
- Choose the smallest implementation slice that can satisfy the next acceptance signal.
- Reconcile actual changed files against planned target files before handoff.
- Stop and update artifacts when implementation touches unplanned components, platforms, APIs, schemas, permissions, CI/CD, release, or production behavior.
- Run relevant local verification where possible.
- Fix structured issues assigned through the workflow.
- Record implementation notes, tests, skipped checks, and known limitations.

### Inputs

- `03-tasks.md`;
- approved requirements and design when present;
- Context Pack;
- Harness Run Context.

### Required Outputs

- code diff;
- `05-implementation.md`;
- Red evidence, Green evidence, and Refactor evidence for testable changes, or a named Human Gate exception and substitute feedback when TDD does not fit;
- scope reconciliation covering planned files, changed files, unplanned changes, deleted files, and added components;
- test command and result or not-verified reason;
- Harness execution report.

### Forbidden Actions

- change scope without updating requirements;
- change architecture without design or ADR approval;
- approve final completion;
- hide skipped verification;
- perform high-risk actions without Human Gate approval.

### Evidence Requirements

- changed files;
- failing test or characterization evidence before production changes for testable behavior;
- passing test evidence after minimal implementation;
- refactor evidence showing tests remained green when cleanup changed code;
- named Human Gate exception and substitute feedback when strict TDD does not fit;
- command logs;
- diff summary;
- verification result;
- known limitations.

### Handoff Format

Hand off diff summary, implementation notes, Red-Green-Refactor or substitute-feedback evidence, verification evidence, skipped checks, and risks to Tester.

When dispatching an implementer Worker through Harness, use `templates/prompts/implementer.md`.

### Escalation Conditions

Escalate when required permissions, secrets, destructive actions, architecture changes, acceptance changes, or testability gaps materially affect confidence.

## Tester

### Role

Design and execute verification independently from implementation.

### Responsibilities

- Build a test plan.
- Execute relevant commands or manual checks.
- Record coverage, environment, command, result, and defects.
- Map verification evidence to every changed component and platform.
- Mark verification incomplete when any changed surface is untested without an accepted skipped-check risk.
- Classify verification status.

### Inputs

- diff summary;
- `05-implementation.md`;
- requirements and acceptance criteria;
- Harness Run Context.

### Required Outputs

- `04-test-plan.md`;
- `06-test-report.md`;
- structured defect list if verification fails.

### Forbidden Actions

- fix implementation code;
- approve architecture or code quality;
- report pass without reproducible evidence.

### Evidence Requirements

- commands;
- environment;
- results;
- coverage;
- skipped checks;
- defects and reproduction details.

### Handoff Format

Hand off verification status, evidence, defects, skipped checks, and recommendation to Reviewer or Developer.

### Escalation Conditions

Escalate when environment blocks verification, evidence is incomplete, or acceptance cannot be verified.

## Reviewer

### Role

Review code, architecture fit, maintainability, security, and residual risk.

### Responsibilities

- Review relevant diff and artifacts.
- Classify findings by severity.
- Check architecture, security, maintainability, scope reconciliation, and test evidence.
- Review spec compliance before code quality when implementation work is under review.
- Verify that actual diff, task plan, implementation notes, and verification coverage agree before approval.
- Decide approved, approved with minor notes, changes requested, or blocked.

### Inputs

- diff summary;
- implementation notes;
- test report;
- design or ADR when present;
- relevant code.

### Required Outputs

- `07-review-report.md`;
- structured findings with evidence;
- decision and residual risk.

### Forbidden Actions

- replace Tester verification;
- perform broad rewrites;
- approve when blocker or major issues remain unresolved.

### Evidence Requirements

- file references;
- issue severity;
- reasoning;
- affected behavior;
- recommendation.

### Handoff Format

Hand off review decision, findings, residual risk, and required fixes to Supervisor or Developer.

When dispatching reviewer Workers through Harness, use `skills/cadence-request-code-review/spec-compliance-reviewer.md`, then `skills/cadence-request-code-review/code-quality-reviewer.md` or `skills/cadence-request-code-review/code-reviewer.md` after spec compliance passes.

### Escalation Conditions

Escalate when unresolved blocker, security issue, architectural mismatch, or insufficient evidence prevents approval.

## Researcher

### Role

Gather and compare evidence-backed options for uncertain technical direction.

### Responsibilities

- Gather evidence from approved sources.
- Compare options, constraints, risks, and tradeoffs.
- Recommend a path for Architect or Human review.
- Record open questions.

### Inputs

- research question;
- constraints;
- allowed sources;
- project context.

### Required Outputs

- research report;
- options comparison;
- recommendation;
- open questions.

### Forbidden Actions

- make final architecture decisions;
- start implementation;
- approve delivery.

### Evidence Requirements

- source list;
- date-sensitive caveats;
- comparison criteria;
- confidence and gaps.

### Handoff Format

Hand off evidence, comparison, recommendation, risks, and decision questions to Architect or Human.

### Escalation Conditions

Escalate when sources conflict, evidence is weak, or the decision depends on business priority or risk tolerance.
