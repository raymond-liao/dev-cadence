---
name: work-item-analysis
description: Use when a user asks to analyze, clarify, or confirm Story, Task, or Bug definitions before downstream delivery work in a target project.
---

# Work Item Analysis

Use this skill when the user wants to analyze, clarify, or confirm one Story, Task, or Bug definition, or a user-selected batch of Story, Task, or Bug definitions, before downstream delivery work starts. This is an Asset Workflow.

Work Item Analysis must create or update only authoritative Story, Task, and Bug cards under `docs/`.
It must not create `build/dev-cadence/` run manifests, stage records, confirmation records, or checkpoint commits.
It must not copy the Delivery Workflow record chain used by `feature-dev`, `bug-fix`, or `refactor`.
Do not copy Delivery Workflow evidence into work-item assets.

Before reading, creating, or updating an owned asset Change Log, read and follow:

```text
.dev-cadence/references/contracts/change-log.md
```

Before creating or updating cards, read and follow:

```text
.dev-cadence/references/document-conventions/SKILL.md
```

## Configuration

Before producing workflow guidance, in-conversation analysis proposals, user-facing analysis summaries, or durable work-item updates, read `.dev-cadence.yaml` from the target repository root.

Apply the shared `Configuration Identity And Worktree Continuation` rules from `using-dev-cadence` before producing any listed analysis output. In a linked worktree, verify that the propagated configuration is present before continuing.

- `output_language: en` uses English.
- `output_language: zh-CN` uses Simplified Chinese.
- If the file or value is missing or unsupported, use English.

Use the selected language for workflow guidance, in-conversation analysis proposals, user-facing analysis summaries, and durable work-item updates.

Do not read user configuration from the replaceable `.dev-cadence/` package.

## Authoritative Assets

Work Item Analysis may create or update only these durable work-item assets:

- Story cards: `docs/stories/S-nnn-<slug>.md`
- Task cards: `docs/tasks/T-nnn-<slug>.md`
- Bug cards: `docs/bugs/B-nnn-<slug>.md`

When an authoritative Story, Task, or Bug card already exists, Work Item Analysis must reuse it instead of creating a parallel card.
When no authoritative card exists and the user wants Work Item Analysis rather than planning-only intake, it may create a lightweight card and complete it in the same confirmed analysis.
When Work Item Analysis creates a card that is not yet registered in `docs/backlog.md`, it must hand the card to `work-item-planning` for Backlog registration before downstream delivery.
Work Item Analysis must not add, remove, or reorder Backlog rows while creating or analyzing a missing card.

## Analysis Modes

Work Item Analysis must support both `single-item analysis` and `batch analysis`.

- `single-item analysis` handles one Story, Task, or Bug.
- `batch analysis` handles only the user explicitly selected set of Story, Task, or Bug cards.
- `batch analysis` must not expand to the entire Backlog unless the user explicitly selects that scope.
- Shared context may be reused across the batch, but each card must keep its own ID, Version, Status, body, and Change Log.

## Workflow Stages

Run the workflow in this sequence:

```text
Analysis Scope Confirmation -> Work Item Definition Analysis -> Work Item Confirmation
```

### Analysis Scope Confirmation

Confirm:

- whether the request is `single-item analysis` or `batch analysis`;
- the selected card or explicitly selected set;
- the current authoritative card path, Version, and visible facts for each selected item;
- the necessary product and planning inputs;
- out-of-scope items, related work, and any requested non-scope.

If the request needs product-level decisions, Story Map changes, Milestone changes, Size changes, Backlog reordering, diagnosis, or delivery implementation rather than work-item definition analysis, route to the correct workflow instead of forcing Work Item Analysis.

### Work Item Definition Analysis

Analyze each selected work item according to its type. Distinguish confirmed facts, assumptions, unresolved questions, and user-proposed alternatives.

For `batch analysis`, also inspect the selected set for duplicate scope, overlapping scope, dependencies, blockers, and conflicts. When overlap or conflict exists, present options and ask the user to decide; Work Item Analysis must not automatically delete, merge, or replace cards.

### Work Item Confirmation

Before confirmation, keep the complete proposal in the conversation and leave authoritative assets unchanged.
Present the proposed card path, current Version, proposed Version, type, goal, scope, status change, open questions, dependencies, and next workflow for each selected item.
The user may confirm only part of the proposal; unconfirmed cards must keep their current authoritative content.
After confirmation, atomically write only the confirmed card updates.

## Story Analysis

Story analysis must cover role, goal, value, included scope, excluded scope, observable behavior, business rules, dependencies, open questions, and acceptance conditions. When a Story has a confirmed primary System Feature or Story Map placement, analysis must retain that traceability; an independent Story without a Feature reference may still become `Ready`.

Story analysis must define, at minimum:

- the user or business role;
- the goal, scenario, and expected business value;
- when present, the confirmed primary System Feature or Story Map traceability;
- included scope and excluded scope;
- observable product behavior;
- applicable business rules and constraints;
- acceptance conditions;
- direct dependencies, open questions, and confirmed requirement decisions.

Story must use the shared included-scope and excluded-scope heading semantics from `document-conventions`.

Story must reach `Ready` before entering `feature-dev`.
Story may become `Ready` only when the role, goal, value, scope, observable behavior, acceptance conditions, direct dependencies, and development-blocking open questions are explicit and the user has confirmed the work-item definition.

A missing Feature reference or product-design baseline alone must not return Story analysis to `discovery`. Return to `discovery` only when the Story requires a new or changed product-level conclusion, including a User Journey, Feature, PRD, or Business Architecture conclusion. Work Item Analysis must not define or reinterpret Feature identity.

## Task Analysis

Task analysis must cover goal, necessity, scope, completion conditions, impact, constraints, dependencies, risks, open questions, and optional `Nature`.

Task analysis must define, at minimum:

- the goal and necessity;
- included scope and excluded scope;
- completion conditions;
- related Feature, Story, or impact area;
- constraints, dependencies, risks, and open questions;
- optional `Nature`.

Task does not need to reach `Ready` before a Delivery Workflow starts.
`Nature` is optional.

If the request is actually a new user-visible or business-visible behavior definition, do not disguise it as a Task. Create or connect the correct Story and analyze it as a Story instead.

## Bug Analysis

Bug analysis must cover expected behavior, observed behavior, impact, environment, reproduction information, affected references, and the current evidence classification.

Bug analysis must define, at minimum:

- expected behavior;
- observed behavior;
- impact and severity;
- known environment;
- reproduction information or equivalent failure evidence;
- affected Feature, Story, or related work-item references;
- whether the current evidence supports treating the item as a Bug, an expected-behavior change, or insufficient information.

Work Item Analysis must distinguish Bug, expected-behavior change, and insufficient information.
Work Item Analysis must not investigate or confirm technical root cause.
Bug may enter `bug-fix` without a `Ready` precondition and without a confirmed root cause.

Bug analysis may define what successful repair should restore from the user's perspective, but it must not claim a diagnosis, repair boundary, regression proof, or technical fix strategy. Those belong to `bug-fix`.

## Shared Card Rules

Work-item cards are shared assets across workflows. Work Item Analysis may update detailed definitions such as the goal, scope, expected behavior, acceptance or completion conditions, dependencies, and requirement decisions.

Use stable IDs, the card's existing title when still correct, and the card's own Version and Change Log.

Increment the Version when confirmed changes alter the card's goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions.
Do not increment the Version for spelling-only, formatting-only, link-only, execution-status-only, or size-only changes.

For every card Change Log, follow the shared Change Log contract.

When Work Item Analysis finds a Version or visible-fact conflict, it must stop and require a user decision before continuing.

Work Item Analysis must not modify Size, Story Map placement, Milestone membership, Iteration Plan content, or Backlog order. If the analysis shows those planning assets need updates, return to `work-item-planning`.

## Downstream Boundaries

Work Item Analysis may read Discovery assets, planning assets, existing work-item cards, and delivery evidence when they are relevant inputs, but it must not overwrite confirmed facts from another workflow silently.

Work Item Analysis must return to `discovery` when the selected item depends on a new or changed product-level conclusion.
Work Item Analysis must return to `work-item-planning` when the selected item needs Story Map, Milestone, Size, Iteration Plan, or Backlog-order changes.
Work Item Analysis does not replace `bug-fix` root cause analysis, repair-boundary definition, regression investigation, or repair verification.
Work Item Analysis must not design technical solutions, modify code, run delivery testing, or perform business acceptance.

## Confirmation Summary And Handoff

The confirmation summary must state, for each confirmed item:

- card path, current Version, and proposed Version;
- type, goal, included scope, excluded scope, and key conditions;
- status change, if any, and the reason;
- unresolved questions, dependencies, overlaps, or conflicts;
- required follow-up in `discovery` or `work-item-planning`, if any;
- downstream workflow handoff.

Default downstream handoff after confirmation:

- Ready Story -> `feature-dev`
- Task -> `feature-dev` / `bug-fix` / `refactor`
- Bug -> `bug-fix`

Batch analysis must not automatically start downstream workflows for every confirmed card. The user still decides which confirmed items to deliver next.

## Completion Check

Before declaring the work-item analysis complete, verify:

- the request was handled as `single-item analysis` or `batch analysis` without silent scope expansion;
- every selected card has a proposal with the fields required by its type;
- Story `Ready` decisions use the Story-only gate;
- Task and Bug are not blocked by a copied Story `Ready` gate;
- Bug analysis did not claim technical root cause or repair proof;
- any duplicate, overlap, dependency, blocker, or conflict was surfaced for user choice;
- only confirmed cards were written;
- authoritative updates stay under `docs/`;
- no delivery process records or copied delivery evidence were created.

## ⚠️ Red Flags

| Thought | Reality |
| --- | --- |
| "The card is light, so delivery can define it later." | Story definition and Story `Ready` belong in Work Item Analysis when the user asks for detailed work-item definition before delivery. |
| "This looks like a bug, so I should diagnose it now." | Root cause, repair boundary, and regression proof belong to `bug-fix`, not Work Item Analysis. |
| "Batch analysis can just sweep the whole Backlog." | The user must explicitly select the analysis set. |
| "I can update the Story Map or Backlog order while I am here." | Planning structure changes belong to `work-item-planning`. |
| "A Feature gap can be patched inside the Story." | Product-level identity and meaning belong to `discovery`. |
