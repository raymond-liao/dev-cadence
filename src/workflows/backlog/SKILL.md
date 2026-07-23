---
name: backlog
description: Use when a user asks to create or register a Story, Task, or Bug card, admit an existing card, or maintain the delivery Backlog without starting implementation.
---

# Backlog

Use this workflow to admit implementation work into Dev Cadence and maintain the authoritative delivery Backlog.

This is an Asset Workflow. It creates or updates only authoritative Story, Task, and Bug cards plus `docs/backlog.md`. It must not create `build/dev-cadence/` run manifests, stage records, confirmation records, checkpoint commits, or copies of Delivery Workflow evidence.

Before reading, creating, or updating an owned asset Change Log, read and follow:

```text
.dev-cadence/references/contracts/change-log.md
```

Before creating or updating cards or Backlog content, read and follow:

```text
.dev-cadence/references/document-conventions/SKILL.md
```

## Applicability

Use Backlog when the user asks to:

- create one Story, Task, or Bug card from a new request;
- register an existing conforming Story, Task, or Bug card in `docs/backlog.md`;
- review whether an existing card satisfies the Dev Cadence card contract;
- maintain card Priority, relationships, lifecycle placement, or recommended pending order;
- drop, supersede, or replace a work item without starting implementation.

Do not use Backlog for product discovery, PRD creation, User Journey or Feature definition, Story Map, Milestone, MVP, portfolio planning, detailed single-card analysis, technical design, diagnosis, implementation, testing, or business acceptance.

Repository state alone does not authorize an asset change. A missing card or Backlog row is evidence for an explicit intake request, not permission to create one automatically.

## Configuration

Before producing workflow guidance, in-conversation proposals, user-facing summaries, cards, or Backlog updates, read `.dev-cadence.yaml` from the target repository root.

Apply the shared `Configuration Identity And Worktree Continuation` rules from `using-dev-cadence`. In a linked worktree, verify that propagated configuration is present before continuing.

- `output_language: en` uses English.
- `output_language: zh-CN` uses Simplified Chinese.
- If the file or value is missing or unsupported, use English.

Do not read user configuration from the replaceable installed `.dev-cadence/` package.

## Authoritative Assets

Backlog owns these asset locations:

```text
docs/backlog.md
docs/stories/S-nnn-<slug>.md
docs/tasks/T-nnn-<slug>.md
docs/bugs/B-nnn-<slug>.md
```

Use repository-global stable IDs:

- Story: `S-nnn`
- Task: `T-nnn`
- Bug: `B-nnn`

Backlog is the authoritative owner of Backlog structure, lifecycle sections, and recommended pending order. Work-item cards remain shared assets: Backlog owns admission, Priority, planning relationships, and lifecycle placement; Work Item Analysis owns detailed definitions; Delivery Workflows own delivery facts and results.

Do not create Feature cards, product-design assets, Story Maps, Milestones, iteration plans, or competing Backlogs.

## Card Contract

Every Dev Cadence card must have one unambiguous repository-relative path whose directory and stable ID match its type. It must contain:

```text
ID
Version
Status
Priority
Title
Goal, task goal, or problem goal
Included scope
Excluded scope
Type-specific completion or acceptance conditions
Relationships
Open Questions
Change Log
```

These are semantic fields, not mandatory English heading strings. `Title` may be the level-one heading; goal, scope, conditions, relationships, and Open Questions may use localized or type-specific headings allowed by `document-conventions`. Relationships and Open Questions must still be explicit, including an explicit `none` when no value exists.

Use these canonical work-item statuses only:

- `Draft`
- `Ready`
- `In Progress`
- `Blocked`
- `Done`
- `Superseded`
- `Dropped`

Do not add workflow stage names as work-item statuses.

Type-specific minimums are:

- Story: role, goal, value, observable behavior, included scope, excluded scope, acceptance conditions, dependencies, and development-blocking Open Questions.
- Task: goal, necessity, included scope, excluded scope, completion conditions, impact area, constraints, dependencies, risks, and Open Questions.
- Bug: expected behavior, observed behavior, impact, known environment, reproduction information or equivalent failure evidence, affected references, and current evidence classification. Root cause is not required.

A Story is eligible for `feature-dev` only when its definition is user-confirmed and its Status is `Ready`. A Task does not require `Ready`, but its goal, scope, and completion conditions must be sufficient for its Delivery Workflow to confirm before code changes. A Bug may enter `bug-fix` without `Ready`, complete reproduction, or known root cause because diagnosis owns those questions.

## Intake Classification

Classify an intake as exactly one of these paths.

### New Request

When the user provides a request without a conforming authoritative card:

1. resolve Story, Task, or Bug from the intended delivery outcome;
2. scan conforming authoritative cards for the same implementation identity and reuse one when it exists;
3. scan all existing card and supplied-source IDs and paths, including nonconforming sources, before allocating a new repository-global unused ID and path;
4. propose one new lightweight card and its necessary Backlog row when no conforming authoritative card exists;
5. keep the proposal in the conversation until confirmation;
6. atomically create the confirmed card and Backlog row;
7. route the card to `work-item-analysis` only when detailed definition is still needed before delivery.

Do not create multiple candidate cards for one request. Do not disguise requested user-visible behavior as a Task or an existing-behavior defect as a Story.

Only a conforming authoritative card may be reused as the Dev Cadence card for the same implementation identity. A nonconforming source's embedded ID or filename does not become authoritative, but it counts as occupied for collision avoidance and must not be reused for the new card.

### Conforming Existing Card

An existing card may bypass card creation and Work Item Analysis only when:

- its path, type, stable ID, required fields, Version, Status, and Change Log satisfy this contract;
- its visible facts have no unresolved conflict with the current request;
- its type-specific content and maturity are sufficient for the requested downstream route; and
- the user identifies it as the intended implementation item.

For a conforming card that is not yet in `docs/backlog.md`, propose only the necessary Backlog registration. After confirmation, atomically register the existing card without rewriting it, and do not repeat Work Item Analysis.

Registration never bypasses Backlog. A card that is ready for implementation but absent from Backlog must enter Backlog before it can be claimed.

### Nonconforming Existing Card

When an existing or externally supplied card fails this contract:

- do not convert it in place;
- do not add compatibility fields, field mappings, external-ID mappings, or synchronization metadata;
- do not overwrite or delete the supplied source;
- treat its content as input to the standard New Request path;
- create or reuse the Dev Cadence card through normal confirmation;
- use `work-item-analysis` only when the new Dev Cadence card still needs detailed definition.

The supplied card does not become an authoritative Dev Cadence card merely because it exists under `docs/`.

If the supplied source already occupies a canonical-looking path under `docs/stories/`, `docs/tasks/`, or `docs/bugs/`, leave that file untouched and exclude it from Backlog. Allocate a fresh unused ID and path for the new Dev Cadence card. Do not rename, move, normalize, or replace the source as part of intake.

## Workflow Sequence

Use one lightweight sequence for card intake and Backlog maintenance:

```text
Necessary Clarification -> Backlog Proposal -> Backlog Result Confirmation
```

Necessary Clarification is not a formal confirmation gate. Ask only questions needed to determine the card identity, contract result, requested Backlog change, or ordering effect. Do not ask the user to reconfirm clear inputs.

Before Backlog Result Confirmation, leave authoritative assets unchanged and present:

1. current conclusion;
2. included card and Backlog changes;
3. explicitly excluded unrelated cards and delivery work;
4. contract failures, conflicts, dependencies, or Open Questions;
5. repository-relative evidence paths;
6. the exact effect of confirming or revising the proposal.

At Backlog Result Confirmation:

- `confirm the proposed result` atomically writes the named card and necessary Backlog changes;
- `request changes` leaves authoritative assets unchanged and revises the same proposal;
- a partial confirmation must not create an orphaned card or orphaned Backlog row;
- an ordering change must include the complete ordering atomic unit defined below.

Do not add a separate input-and-scope confirmation gate for a single-card intake.

## Card Reuse, Versioning, And Conflicts

Every card has an independent integer Version starting at `1`.

Increment Version when confirmed changes alter goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions.

Do not increment Version for spelling-only, formatting-only, link-only, execution-status-only, or Backlog-order-only changes.

Before writing, re-read the current card Version and visible facts. If either changed since the proposal was formed, stop and form a new proposal. Never silently overwrite a newer conforming authoritative card or create a parallel authoritative card for the same implementation identity. A preserved nonconforming source is input evidence, not a second authoritative card.

Follow the shared Change Log contract for every important card event. Backlog lifecycle synchronization must not duplicate a Delivery Workflow event already recorded for the same transition.

## Backlog Contract

The authoritative path is:

```text
docs/backlog.md
```

Use exactly these lifecycle sections in this order:

1. `进行中`
2. `待处理`
3. `已完成`
4. `已关闭`

Each lifecycle table must use exactly:

```text
ID | Title | Version | Status | Priority
```

Backlog rows summarize cards only. Do not duplicate card body, acceptance conditions, Change Log, workflow stages, run evidence, or delivery reports.

The row order in `待处理` is the sole authoritative suggested implementation order. Preserve unrelated row order unless the user confirms an ordering change. Priority does not independently override row order.

Card creation or admission and its necessary Backlog row are one atomic unit. Lifecycle writeback from a Delivery Workflow must atomically synchronize the card and its Backlog source/destination sections while preserving unrelated pending order.

Map card Status to lifecycle section exactly:

- `Draft`, `Ready`, or `Blocked` -> `待处理`;
- `In Progress` -> `进行中`;
- `Done` -> `已完成`;
- `Superseded` or `Dropped` -> `已关闭`.

Any Status change across lifecycle sections must atomically update the card and move its Backlog row to the mapped section. A status-only change within the same section updates the existing row without moving it.

Removing a pending item through confirmed deletion, `Dropped`, or unreplaced `Superseded` must atomically remove active references and append a compact historical row under `已关闭`. Preserve the stable ID, terminal disposition, and user-confirmed reason. Do not link to a deleted card.

## Ordering Version And History

`Ordering Version` identifies the latest user-confirmed pending-order decision, not the entire Backlog.

An ordering proposal must snapshot:

- current `Ordering Version`;
- complete `待处理` ID order;
- affected IDs and proposed relative positions;
- the user's reason.

Immediately before writing, re-read `Ordering Version` and the complete pending order. If either changed, stop and form a new proposal.

After confirmation, atomically update `待处理`, increment `Ordering Version`, and append one `Ordering Change Log` event only when the confirmed result changes order by inserting, removing, reordering, or changing an ordering exception.

Lifecycle synchronization, completed-item movement, title/Version/Priority synchronization, derived-view refresh, formatting, and link-only changes must not increment `Ordering Version`.

## Workflow Boundaries

Backlog must not:

- analyze or define product direction;
- create or maintain product-analysis or portfolio-planning assets;
- perform detailed Work Item Analysis inside this workflow;
- diagnose a Bug or choose a technical solution;
- modify code, run delivery tests, or perform business acceptance;
- create Delivery Workflow process records;
- claim a work item solely because it was registered.

After a confirmed result:

- a Story needing detailed definition routes to `work-item-analysis`;
- a confirmed Ready Story may route to `feature-dev` only on an explicit implementation request;
- a Task routes to `feature-dev`, `bug-fix`, or `refactor` according to its intended outcome;
- a Bug routes to `bug-fix` on an explicit repair request;
- card maintenance without implementation stops after the authoritative asset update.

## Completion Check

Before declaring Backlog work complete, verify:

- exactly one intake path was used;
- no duplicate authoritative implementation identity, stable ID, or path was created;
- a conforming existing card was not recreated or reanalyzed;
- a nonconforming supplied card was preserved, excluded from Backlog, and handled through New Request with a fresh unused ID and path;
- every active card change has its necessary Backlog row;
- card and Backlog writes were atomic;
- pending order changed only with confirmed ordering history;
- no product-analysis, portfolio-planning, or Delivery Workflow evidence was created.

## Red Flags

| Thought | Reality |
| --- | --- |
| "This external card looks close enough." | It must satisfy the complete card and maturity contract before bypassing creation or analysis. |
| "Register the card after implementation starts." | Every implementation item must enter Backlog before claim. |
| "Normalize the supplied card in place." | A nonconforming card is preserved and treated as New Request input. |
| "Analyze the card while admitting it." | Detailed definition belongs to `work-item-analysis`; Backlog owns admission. |
| "Priority tells me which item to claim." | The row order in `待处理` is the authoritative suggested order. |
