# Skill Authoring Pre-Spec

## 1. Purpose

This document defines the pre-authoring specification for the future `dev-cadence` Skill.

The goal is to stabilize the contracts that the Skill must implement before creating the actual Skill package. This document is not the Skill itself. It is the design input for the Skill's `SKILL.md`, references, templates, workflow files, and repo-local `.ai/` structure.

## 2. Design Assumptions

- Audience: reusable team Skill, initially applied as a repo-local workflow.
- Language: English for all Skill instructions, templates, Blueprint files, and generated artifacts.
- Executor model: executor-agnostic Harness, with examples that can be used by Codex-style coding agents.
- Delivery model: start with Skill rules and templates, not a platform.
- First workflows: `feature-dev`, `bugfix`, `code-review`, `refactor`, `research-spike`, `incident-fix`.
- Core Worker Agents: `Planner`, `Architect`, `Developer`, `Tester`, `Reviewer`.
- Optional Worker Agent: `Researcher`.
- Non-Agent roles: `Human`, `Supervisor`, `Harness`, `Quality Gate`, `Human Gate`.
- Invocation boundary: the system-level Skill may be implicitly selected only when the user asks to install, initialize, set up, or prepare repository-level AI-assisted delivery rules, workflows, gates, or templates. The user does not need to name `$dev-cadence` for initial setup.
- Update, sync, repair, inspect, diagnose, and other maintenance operations require explicit Skill-name invocation with `$dev-cadence` or `dev-cadence`.
- Product implementation work, general engineering advice, and maintenance requests that do not name the Skill should not implicitly trigger the Skill.
- Initialization boundary: setup, sync, repair, and diagnosis may write only root `AGENTS.md`, `.ai/**`, and `specs/.gitkeep` by default; they must not modify product code or create task-specific specs unless the user explicitly requests delivery work in the same turn.

## 3. Non-Negotiable Principles

1. Agent collaboration is artifact-first. Chat is not a stable source of truth.
2. Supervisor controls workflow state but does not write code, make final architecture decisions, or approve its own work.
3. Harness mediates every Worker Agent execution through context injection, tool policy, permission policy, logging, and evidence capture.
4. Worker Agents exchange structured artifacts, not conversational summaries.
5. Developer cannot declare final completion.
6. Tester and Reviewer remain independent responsibilities.
7. Fix loops have a hard maximum of three iterations.
8. High-risk actions require Human Gate approval.
9. Missing evidence is a workflow state, not an approval.
10. Incomplete verification is blocked until a named Human accepts the residual risk.
11. Supervisor, Harness, Developer, Tester, and Reviewer cannot be recorded as final accepter.
12. Workflow can be inferred, but unclear product intent cannot be guessed. Ambiguous goal, scope, non-goals, reference behavior, or acceptance criteria require user clarification before implementation.
13. Assumptions must be recorded separately and must not become scope, non-goals, or acceptance criteria without a named Human decision.
14. Requirements readiness must be checked before implementation. Broad or comparative wording such as "not as expected", "inconsistent", "same as", "match", "align", "parity", or "fix this issue" is not enough unless expected behavior and comparison dimension are explicit.
15. Clarification should be analysis-backed. The agent should inspect relevant code, docs, specs, or behavior, then present candidate interpretations and a recommended option rather than asking the user to discover the ambiguity from scratch.
16. Repository evidence can support candidate interpretations, but it cannot clarify user intent, accept requirements, or pass G1. When clarification is required, G1 must name the Human who selected or deferred the interpretation.
17. If the user rejects or corrects a prior result, requirements must be reopened and clarified before more implementation.
18. Platform automation is deferred until repo-local Skill rules are validated on real work.

## 4. Target Skill Package Shape

The future Skill should use progressive disclosure. `SKILL.md` should stay concise and route the agent to focused reference files only when needed.

```text
dev-cadence/
  SKILL.md
  references/
    principles.md
    supervisor-state-machine.md
    task-classes.md
    agent-blueprints.md
    workflows.md
    context-pack.md
    harness.md
    quality-gates.md
    human-gates.md
    spec-templates.md
    skill-layout.md
```

The Skill should not include generic README, installation guide, changelog, or narrative research documents. Those belong in the framework repository, not in the distributable Skill.

The Skill package should be safe to install at system scope. Its metadata must not describe ordinary feature, bugfix, review, refactor, research, or incident execution as a global trigger. Those workflows become automatic only through repo-local `AGENTS.md` and `.ai/` files after initialization.

## 5. Repo-Local Output Shape

When applied to a target repository, the Skill should create or update this structure:

```text
AGENTS.md

.ai/
  control/
    supervisor.md
  agents/
    planner.md
    architect.md
    developer.md
    tester.md
    reviewer.md
    researcher.md
  workflows/
    feature-dev.md
    bugfix.md
    code-review.md
    refactor.md
    research-spike.md
    release.md
    incident-fix.md
  policies/
    task-classes.md
    human-gates.md
    quality-gates.md
    permission-policy.md
    context-policy.md
    escalation-policy.md
    harness-policy.md
  templates/
    context-pack.md
    run-context.md
    execution-report.md
    spec/
      00-brief.md
      01-requirements.md
      02-design.md
      03-tasks.md
      04-test-plan.md
      05-implementation.md
      06-test-report.md
      07-review-report.md
      08-acceptance.md

specs/
  {task_id}/
    00-brief.md
    01-requirements.md
    02-design.md
    03-tasks.md
    04-test-plan.md
    05-implementation.md
    06-test-report.md
    07-review-report.md
    08-acceptance.md
    decisions/
      ADR-001.md
    runs/
      {run_id}/
        run-context.md
        execution-report.md
        tool-log.md
        test-log.md
        diff-summary.md
        permission-decisions.md
```

`AGENTS.md` activates the repo-local delivery workflow for normal Codex tasks. `.ai/` stores stable collaboration rules. `specs/` stores task-specific artifacts and Harness evidence.

The initialized repository must not require users to invoke the Skill name for every feature, bugfix, refactor, review, research, or incident request. Root `AGENTS.md` should route normal software delivery work to `.ai/control/supervisor.md`, and Supervisor should infer `selected_workflow` from the request.

Framework initialization, synchronization, repair, and diagnosis are not delivery tasks. They should not create `specs/{task_id}/` or touch product source, tests, migrations, build scripts, deployment files, or application configuration unless the same user request explicitly asks for a concrete delivery task.

## 6. Supervisor State Machine

The Supervisor must operate from explicit workflow state, not from conversational judgment.

| State | Owner | Required Input | Required Output | Gate | Next State |
|---|---|---|---|---|---|
| `intake` | Supervisor | user request | `00-brief.md` | goal, constraints, and requested outcome are recorded | `classify` |
| `classify` | Supervisor | `00-brief.md` | task class and workflow type | task class is one of `S0`, `S1`, `S2`, `research-spike`, `incident` | `requirements` or lightweight path |
| `requirements` | Planner | brief, task class | `01-requirements.md` | scope, non-goals, constraints, and acceptance criteria are clear | `design` or `planning` |
| `design` | Architect | requirements, project constraints | `02-design.md` or ADR | design is required only for high-risk or design-sensitive work | `planning` |
| `planning` | Planner | requirements, design if present | `03-tasks.md` | tasks are executable and bounded | `implementation` |
| `implementation` | Developer via Harness | tasks, context pack, run context | code diff, `05-implementation.md`, execution report | implementation notes and initial verification evidence exist | `test` |
| `test` | Tester via Harness | diff, implementation notes, test plan | `04-test-plan.md`, `06-test-report.md`, execution report | verification status is recorded with evidence | `review` or `fix` |
| `review` | Reviewer via Harness | diff, test report, implementation notes | `07-review-report.md`, execution report | no unresolved blocker or major issue | `acceptance` or `fix` |
| `fix` | Developer via Harness | structured issue list | patch, updated implementation notes, execution report | fix is scoped to known issues and loop count is within limit | `test` |
| `acceptance` | Human with Supervisor recording | all artifacts and reports | `08-acceptance.md` | named human accepts result and residual risk | `done` |
| `blocked` | Supervisor and Human | blocker evidence | escalation decision | human decides continue, split, defer, or stop | selected state |

### State Machine Rules

- Every Worker Agent state must be executed through Harness.
- Every Harness run must produce `run-context.md`, `execution-report.md`, `tool-log.md`, and `permission-decisions.md`; runs that change files must also produce `diff-summary.md`; runs that execute commands or tests must also produce `test-log.md`.
- Supervisor cannot replace missing Worker Agent artifacts with its own summary.
- Any skipped state must record the reason and residual risk.
- Any conflict affecting scope, architecture, security, permissions, test validity, or acceptance must enter a Human Gate.
- `S2` work cannot start implementation until required Human Gate approvals are recorded.
- Any verification status other than `verified` must enter Human Gate before review approval or final acceptance.
- Final acceptance must name a Human accepter; `accepted_by: supervisor` or any Worker Agent is invalid.
- `fix` can run at most three times per task before escalation.

## 7. Task Classes

Task class determines workflow strength.

| Class | Use When | Required Agents | Required Artifacts | Human Gate |
|---|---|---|---|---|
| `S0 trivial` | text edits, comments, low-risk config, tiny reversible changes | Developer; Reviewer optional | brief, implementation notes, test evidence or not-verified reason, acceptance | final acceptance |
| `S1 normal` | normal feature, bugfix, local refactor, ordinary code review | Planner, Developer, Tester, Reviewer | requirements, tasks, implementation, test report, review report, acceptance | requirement acceptance, final acceptance |
| `S2 high-risk` | architecture, security, permissions, CI, data migration, cross-module changes | Planner, Architect, Developer, Tester, Reviewer | requirements, design or ADR, tasks, implementation, test report, review report, acceptance | requirement, architecture or risk approval before implementation, permission approval when needed, final human acceptance |
| `research-spike` | technical selection, unknown feasibility, comparative research | Researcher, Architect optional | research report, options comparison, recommendation, open questions | decision review |
| `incident` | urgent production or critical failure fix | Supervisor, Developer, Tester and Reviewer as needed | triage, minimal patch, smoke test, emergency approval, post-incident backfill | emergency approval, post-incident acceptance |

## 8. Context Pack Contract

Context Pack defines what the Agent should know. It does not define what the Agent is allowed to do.

```yaml
task_id:
workflow_hint:
selected_workflow:
selection_reason:
task_class:
agent_role:
goal:
current_state:
acceptance_criteria:
non_goals:
constraints:
relevant_specs:
relevant_decisions:
relevant_files:
previous_outputs:
known_risks:
forbidden_assumptions:
expected_output:
handoff_target:
```

### Context Rules

- Context Pack should contain the smallest sufficient context for the current Agent.
- Chat history can be used as a clue but must not become stable context unless written into an approved artifact.
- If sources conflict, the Agent must mark `context_conflict`.
- Source priority is: current code and test results, approved specs and ADRs, current task artifacts, stable project docs, then chat or issue discussion.

## 9. Harness Run Context Contract

Harness Run Context defines how this Agent execution is allowed to run.

```yaml
run_id:
task_id:
agent_role:
blueprint_path:
context_pack_path:
workspace_path:
allowed_read_paths:
allowed_write_paths:
denied_paths:
allowed_tools:
denied_tools:
network_policy:
secret_policy:
permission_policy:
budget:
timeout:
max_iterations:
required_evidence:
expected_artifacts:
log_paths:
```

### Harness Rules

- Harness is not an Agent and must not make semantic approval decisions.
- Harness records execution evidence for Supervisor and gates.
- Harness must capture command logs, tool logs, diff summary, test logs, permission decisions, and final execution report.
- High-risk actions must trigger permission checks before execution.
- Missing Harness evidence prevents approval.

## 10. Agent Blueprint Contracts

Each Agent Blueprint should follow the same structure:

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

### Planner

Responsibilities:

- clarify goal, scope, non-goals, constraints, and acceptance criteria;
- split work into executable tasks;
- identify missing information.

Required outputs:

- `01-requirements.md`;
- `03-tasks.md` when planning is requested.

Forbidden actions:

- writing implementation code;
- making architecture decisions beyond task planning;
- approving final completion.

### Architect

Responsibilities:

- define technical approach, architectural constraints, alternatives, and risks;
- create ADRs when the task changes durable architecture.

Required outputs:

- `02-design.md`;
- `decisions/ADR-*.md` when needed.

Forbidden actions:

- implementing the solution;
- bypassing Reviewer or Human Gate;
- treating design preference as approval.

### Developer

Responsibilities:

- implement scoped changes;
- run relevant local verification where possible;
- fix structured issues assigned through the workflow;
- write implementation notes and known limitations.

Required outputs:

- code diff;
- `05-implementation.md`;
- test command and result or not-verified reason;
- Harness execution report.

Forbidden actions:

- changing scope without updating requirements;
- changing architecture without design or ADR approval;
- approving final completion;
- hiding skipped verification.

### Tester

Responsibilities:

- design and execute verification;
- record coverage, environment, command, result, and defects;
- classify verification status.

Required outputs:

- `04-test-plan.md`;
- `06-test-report.md`;
- structured defect list if verification fails.

Forbidden actions:

- fixing implementation code;
- approving architecture or code quality;
- reporting pass without reproducible evidence.

### Reviewer

Responsibilities:

- review code, architecture fit, maintainability, security, and risk;
- classify findings by severity;
- decide whether changes are approved, approved with minor notes, changes requested, or blocked.

Required outputs:

- `07-review-report.md`;
- structured findings with evidence;
- decision and residual risk.

Forbidden actions:

- replacing Tester verification;
- performing broad rewrites;
- approving when blocker or major issues remain unresolved.

### Researcher

Responsibilities:

- gather and compare options;
- identify evidence, constraints, tradeoffs, and open questions;
- recommend a path for Architect or Human review.

Required outputs:

- research report;
- options comparison;
- recommendation;
- open questions.

Forbidden actions:

- making final architecture decisions;
- starting implementation;
- approving delivery.

## 11. Spec Template Contracts

The Skill should provide concise templates for each task artifact.

### `00-brief.md`

Required fields:

```yaml
task_id:
requested_by:
date:
goal:
background:
constraints:
initial_risks:
workflow_hint:
selected_workflow:
selection_reason:
```

### `01-requirements.md`

Required fields:

```yaml
status:
goal:
scope:
non_goals:
users_or_stakeholders:
acceptance_criteria:
constraints:
open_questions:
human_decisions:
```

### `02-design.md`

Required fields:

```yaml
status:
problem:
chosen_approach:
alternatives_considered:
architecture_constraints:
affected_components:
data_or_control_flow:
risks:
required_adrs:
human_decisions:
```

### `03-tasks.md`

Required fields:

```yaml
status:
task_class:
selected_workflow:
tasks:
dependencies:
target_files:
forbidden_actions:
acceptance_mapping:
verification_plan:
```

### `04-test-plan.md`

Required fields:

```yaml
status:
scope:
test_strategy:
test_commands:
test_data:
environment:
coverage_targets:
risks:
```

### `05-implementation.md`

Required fields:

```yaml
status:
changed_files:
rationale:
implementation_notes:
test_commands:
test_results:
known_limitations:
follow_up_needed:
```

### `06-test-report.md`

Required fields:

```yaml
status:
verification_status:
commands_run:
environment:
results:
coverage_scope:
defects:
skipped_checks:
residual_risk:
recommendation:
```

### `07-review-report.md`

Required fields:

```yaml
status:
review_scope:
evidence_reviewed:
findings:
blockers:
major_issues:
minor_notes:
security_notes:
architecture_notes:
decision:
residual_risk:
```

Allowed decisions:

```text
approved
approved_with_minor_notes
changes_requested
blocked
```

### `08-acceptance.md`

Required fields:

```yaml
status:
accepted_by_human:
accepted_at:
accepted_scope:
evidence_reviewed:
human_gate_decisions:
residual_risk_accepted:
merge_or_release_decision:
follow_up:
```

## 12. Quality Gate Contracts

Each gate must define required inputs, required outputs, pass condition, fail condition, evidence fields, human override rules, and escalation.

| Gate | Name | Pass Condition |
|---|---|---|
| `G1` | requirements accepted | scope, non-goals, constraints, and acceptance criteria are approved or explicitly accepted for lightweight work |
| `G2` | design accepted when required | high-risk or architecture-sensitive tasks have design or ADR approval |
| `G3` | task executable | tasks include inputs, outputs, target files, acceptance mapping, verification plan, and forbidden actions |
| `G4` | test evidence complete and reproducible | verification status is `verified`, or a named Human Gate accepts incomplete verification |
| `G5` | review has no unresolved blocker or major issue | G4 is passed or overridden by Human Gate, and Reviewer decision is `approved` or `approved_with_minor_notes` |
| `G6` | human accepts result | named Human has accepted final output and residual risk |

Verification status must be one of:

```text
verified
partially_verified
not_verified
blocked_by_environment
```

Any status other than `verified` must record gap, residual risk, recommended follow-up, and whether Human acceptance is allowed. It does not pass G4 without a named Human Gate override.

## 13. Human Gate Contracts

Human Gate type must be explicit.

| Type | Meaning | Typical Use |
|---|---|---|
| `approval_required` | work cannot continue without explicit approval | merge, release, production, secret access, database write, CI workflow change, destructive operation |
| `review_required` | human review is needed before a critical direction is locked | architecture, security, high-risk refactor |
| `info_required` | missing information blocks correct execution | ambiguous requirement, unclear acceptance criterion, conflicting business rule |
| `notify_only` | human is informed but workflow is not blocked | low-risk retry, status update, non-critical environment issue |

Human decisions must be written into requirements, design, ADR, or acceptance artifacts. Do not record Supervisor, Harness, Developer, Tester, Reviewer, or an unspecified agent as the Human decision owner.

## 14. Workflow Coverage

The first Skill version should define these workflows:

- `feature-dev`: full path from requirements to acceptance.
- `bugfix`: reproduce or characterize defect, implement fix, verify regression.
- `code-review`: review existing diff and produce structured findings.
- `refactor`: preserve behavior, require clear verification strategy.
- `research-spike`: produce evidence-backed recommendation, not implementation.
- `incident-fix`: triage, minimal patch, smoke test, emergency approval, post-incident backfill.

`release` can exist as a placeholder workflow in repo-local layout, but detailed release automation should be deferred.

## 15. Deferred Topics

The following topics should not block Skill authoring:

- Workflow DSL beyond Markdown or simple structured blocks.
- LangGraph or Microsoft Agent Framework prototype.
- Deep Codex CLI, Claude Code, or OpenHands adapter design.
- Enterprise RBAC, SSO, audit dashboard, or cost control.
- Automatic issue or PR listeners.
- Automatic release execution.

These should be revisited after the repo-local Skill has been used on real tasks and its rules have stabilized.

## 16. Open Decisions Before Skill Authoring

These decisions can be made while drafting the Skill package:

1. Whether `release` should be included as a minimal workflow or only referenced as future work.
2. Whether the Skill should generate empty `researcher.md` by default or only when `research-spike` is enabled.
3. Whether templates should be pure Markdown headings, YAML-frontmatter plus Markdown body, or YAML-like field blocks.
4. Whether a lightweight validation script is worth including after the first manual version.
5. Which real task should be used as the first validation run.
