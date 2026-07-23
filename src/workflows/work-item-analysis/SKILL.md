---
name: work-item-analysis
description: Use when a user asks to analyze, clarify, or confirm one existing Story, Task, or Bug definition before downstream delivery work.
---

# Work Item Analysis

Use this workflow to analyze exactly one authoritative Story, Task, or Bug card before downstream delivery.

This is an Asset Workflow. It may update only the selected card and the matching mechanical status/Version summary in `docs/backlog.md`. It must not create `build/dev-cadence/` run manifests, stage records, confirmation records, checkpoint commits, or copies of Delivery Workflow evidence.

Before reading, creating, or updating an owned asset Change Log, read and follow:

```text
.dev-cadence/references/contracts/change-log.md
```

Before updating a card, read and follow:

```text
.dev-cadence/references/document-conventions/SKILL.md
```

## Applicability

Use Work Item Analysis when the user asks to analyze, clarify, or confirm one existing Story, Task, or Bug definition.

Do not use it to:

- analyze a batch, the whole Backlog, or a portfolio;
- create a missing card;
- admit a card into Backlog or change Backlog ordering;
- perform product discovery, Feature definition, Story Map, Milestone, MVP, or portfolio planning;
- investigate technical root cause, design a solution, implement code, test delivery, or perform business acceptance.

When no conforming authoritative card exists, route to `.dev-cadence/workflows/backlog/SKILL.md`. Backlog owns the standard New Request path and determines whether a supplied card can be admitted without recreation.

## Configuration

Before producing workflow guidance, in-conversation proposals, user-facing summaries, or card updates, read `.dev-cadence.yaml` from the target repository root.

Apply the shared `Configuration Identity And Worktree Continuation` rules from `using-dev-cadence`. In a linked worktree, verify that propagated configuration is present before continuing.

- `output_language: en` uses English.
- `output_language: zh-CN` uses Simplified Chinese.
- If the file or value is missing or unsupported, use English.

Use the selected language consistently for proposals, summaries, and durable card updates.

Do not read user configuration from the replaceable installed `.dev-cadence/` package.

## Authoritative Input

The selected card must already exist at one authoritative repository-relative path:

- Story: `docs/stories/S-nnn-<slug>.md`
- Task: `docs/tasks/T-nnn-<slug>.md`
- Bug: `docs/bugs/B-nnn-<slug>.md`

Read the selected card and its matching `docs/backlog.md` row. Confirm the stable ID, type, path, Version, Status, Priority, and visible facts before forming a proposal.

If the card does not satisfy the structural card contract, stop and return it to Backlog as a nonconforming intake. Do not normalize or recreate it inside Work Item Analysis.

Work Item Analysis must reuse the selected card. It must not create a parallel card, change its stable ID, or silently merge it with another item.

## Workflow Sequence

Use this sequence:

```text
Necessary Clarification -> Work Item Definition Proposal -> Work Item Confirmation
```

Necessary Clarification is not a formal confirmation gate. Ask only questions whose answers materially affect the selected card's goal, scope, expected behavior, completion conditions, dependencies, or delivery eligibility.

Before Work Item Confirmation, leave authoritative assets unchanged and present:

1. current analysis conclusion;
2. selected card path, current Version, Status, and type;
3. proposed goal, included scope, excluded scope, and type-specific conditions;
4. proposed Version and Status effect;
5. assumptions, dependencies, risks, and Open Questions;
6. downstream route or reason the item remains blocked;
7. repository-relative evidence paths.

At Work Item Confirmation:

- `confirm the proposed definition` atomically updates the selected card and its matching Backlog Version/Status summary;
- `request changes` leaves authoritative assets unchanged and revises the same proposal;
- confirmation applies to only this card and must not change unrelated cards or Backlog order.

## Story Analysis

Story analysis must define:

- user or business role;
- goal, scenario, and expected value;
- included scope and excluded scope;
- observable system behavior;
- applicable rules and constraints;
- acceptance conditions;
- direct dependencies;
- Open Questions and confirmed requirement decisions.

Use the shared included-scope and excluded-scope heading semantics from `document-conventions`.

A Story may become `Ready` only when the role, goal, value, scope, observable behavior, acceptance conditions, direct dependencies, and development-blocking Open Questions are explicit and the user confirms the definition.

Story does not require a Feature, User Journey, PRD, Story Map position, or other product-analysis reference to become `Ready`.

Story must reach `Ready` before entering `feature-dev`.

## Task Analysis

Task analysis must define:

- goal and necessity;
- included scope and excluded scope;
- completion conditions;
- affected system or work-item area;
- constraints, dependencies, risks, and Open Questions;
- optional `Nature` when useful.

Task does not need to reach `Ready` before a Delivery Workflow starts. The selected Delivery Workflow must still confirm goal, scope, and completion conditions before changing code.

If the request is actually new user-visible or system-visible behavior, do not disguise it as a Task. Return to Backlog to create or associate the correct Story.

## Bug Analysis

Bug analysis must define:

- expected behavior;
- observed behavior;
- impact and severity;
- known environment;
- reproduction information or equivalent failure evidence;
- affected system or related work-item references;
- whether evidence currently supports Bug, expected-behavior change, or insufficient information.

Work Item Analysis must not investigate or confirm technical root cause, repair boundary, regression proof, or technical fix strategy. Those belong to `bug-fix`.

A Bug may enter `bug-fix` without `Ready`, complete reproduction, or known root cause. Work Item Analysis may clarify the user-visible repair result without performing diagnosis.

If analysis shows the user intentionally wants changed expected behavior, return to Backlog to create or associate the correct Story instead of converting the Bug silently.

## Version, Status, And Conflicts

Increment card Version when confirmed changes alter goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions.

Do not increment Version for spelling-only, formatting-only, link-only, execution-status-only, Priority-only, or Backlog-order-only changes.

Follow the shared Change Log contract for every important definition or maturity event.

Immediately before writing, re-read the card Version and visible facts. If either changed since the proposal was formed, stop and form a new proposal. Never overwrite a newer card.

Work Item Analysis may change Status only among the definition-maturity statuses `Draft`, `Ready`, and `Blocked`. These statuses all remain in the Backlog `待处理` section. Story `Ready` must satisfy the Story maturity gate; Task and Bug do not acquire the Story `Ready` prerequisite.

Work Item Analysis must not set `In Progress`, `Done`, `Superseded`, or `Dropped`. Route execution and terminal lifecycle changes to the owning Delivery Workflow or `backlog` instead.

When confirmation changes an allowed maturity Status or Version, atomically synchronize only the matching Backlog row's Status and Version in `待处理`. Work Item Analysis must not add, remove, move, or reorder Backlog rows and must not increment Backlog `Ordering Version`.

## Workflow Boundaries

Work Item Analysis owns detailed work-item definition facts. It does not own card admission, Backlog structure, ordering, lifecycle placement, technical delivery, or product analysis.

When analysis discovers:

- a missing or nonconforming card: return to `backlog`;
- a needed Backlog admission, Priority, relationship, or ordering change: return to `backlog` after the analysis decision is confirmed;
- a Bug needing root-cause investigation: hand off to `bug-fix`;
- a Story ready for implementation: hand off to `feature-dev` only on an explicit implementation request;
- a Task ready for delivery: hand off to `feature-dev`, `bug-fix`, or `refactor` according to outcome;
- a requirement that cannot be resolved within one work item: keep the blocking question explicit and stop instead of starting product analysis inside Dev Cadence.

Default downstream routes are:

- Ready Story -> `feature-dev`
- Task -> `feature-dev` / `bug-fix` / `refactor`
- Bug -> `bug-fix`

Work Item Analysis must not automatically claim or start a downstream workflow after confirmation. The user must explicitly request implementation, repair, or refactor work.

## Completion Check

Before declaring analysis complete, verify:

- exactly one existing conforming card was analyzed;
- the proposal contains the type-specific required fields;
- Story `Ready` uses only the Story maturity gate;
- Task and Bug are not blocked by the Story `Ready` gate;
- Bug analysis does not claim root cause or repair proof;
- any Status change stays within `Draft`, `Ready`, and `Blocked`;
- only the confirmed card and matching mechanical Backlog summary were updated;
- no Backlog row was created, moved, removed, or reordered;
- no product-analysis or Delivery Workflow asset was created.

## Red Flags

| Thought | Reality |
| --- | --- |
| "I can analyze several related cards together." | This workflow analyzes exactly one card per run. |
| "The supplied card is incomplete, so fix its format here." | Nonconforming intake belongs to `backlog` and the New Request path. |
| "A Story needs a Feature before it can be Ready." | Story maturity depends on its own implementation definition, not product assets. |
| "This Bug needs a root cause before handoff." | Root cause belongs to `bug-fix` diagnosis. |
| "I can reorder Backlog while confirming the card." | Backlog ordering belongs to `backlog`. |
