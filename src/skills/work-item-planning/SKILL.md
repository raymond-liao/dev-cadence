---
name: work-item-planning
description: Use when a user asks to create, update, or review Story Map, milestone, or work-item planning assets in a target project.
---

# Work Item Planning

Use this skill to organize confirmed product-design facts into delivery-planning assets and lightweight work-item cards.

This is an Asset Workflow.

It creates or updates durable planning assets under `docs/`. It must not create `build/dev-cadence/` run manifests, stage records, confirmation records, checkpoint commits, or other persistent copies of the workflow process. It must not copy the Delivery Workflow record chain used by `feature-dev`, `bug-fix`, or `refactor`.

Use only vendored Superpowers skills from:

```text
.dev-cadence/vendor/superpowers/skills/
```

## Applicability

Use Work Item Planning when the user asks to:

- create or incrementally update a Story Map from confirmed product-design assets;
- create or update milestone slicing for planned work items;
- register a clear Story, Task, or Bug request as a lightweight card;
- coordinate confirmed product-design changes into Story Map placement, milestone membership, card relationships, or Backlog references;
- review or adjust delivery-planning structure, planning relationships, or recommended planning order without starting implementation.

Use one of these two modes:

- `portfolio planning`: create or incrementally update product-level planning assets from confirmed User Journey, PRD, and Business Architecture inputs.
- `direct intake`: create or reuse one clearly requested Story, Task, or Bug card and update only the necessary planning references.

Do not start this workflow from repository state alone. A missing Story Map, missing card, or missing Backlog entry does not by itself authorize planning changes.

## Configuration

Before producing user-facing planning documents or summaries, read:

```text
.dev-cadence.yaml
```

Use `output_language` for user-facing planning assets and summaries:

- `en`: English
- `zh-CN`: Simplified Chinese

This workflow must write its rule document updates, planning proposals, and planning assets in `zh-CN`. Do not fall back to `en` for this workflow. Shared configuration may continue to serve other workflows and surfaces under their own rules.

## Generated Status Presentation

When writing a user-facing status summary, apply the shared status presentation mapping from `document-conventions`. Preserve the canonical status text and do not create workflow-run status fields inside planning assets.

## Generated Document References

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit.

## Inputs And Source Precedence

Read inputs in this order:

1. current conversation and explicit user confirmations;
2. confirmed User Journey, PRD, and Business Architecture assets;
3. the current Story Map, Backlog, and existing Story / Task / Bug cards when they already exist;
4. relevant planning-impact notes handed off from other workflows.

When sources disagree, prefer explicit user confirmations, then authoritative repository assets, then weaker notes. Do not silently resolve a meaningful conflict.

## Durable Planning Assets

Work Item Planning may create or update only durable planning assets such as:

```text
docs/product-planning/story-map.md
docs/backlog.md
docs/stories/S-nnn-<slug>.md
docs/tasks/T-nnn-<slug>.md
docs/bugs/B-nnn-<slug>.md
```

Use repository-relative paths in documents. Do not persist machine-local absolute paths.

Current planning assets are long-lived business assets. Keep business facts in those assets through Version, Change Log, status, relationships, Open Questions, and Rejected Directions when applicable. Do not add approval timestamps, approver identities, commit hashes, checkpoint fields, or workflow-run metadata.

## Product-Design Ownership Boundary

Discovery is the sole owner of confirmed User Journey, PRD, Business Architecture, and Feature identities and conclusions. Work Item Planning may only reference confirmed Feature Definitions and must not redefine those product-design assets while planning.

Work Item Planning must not:

- create Feature cards;
- change a Feature ID, Type, Title, business identity, or Journey order;
- infer or patch missing product conclusions just to complete a plan.

If a Feature is missing, ambiguous, or needs a meaning or order change, return the request to `discovery`.

## Workflow Boundary

### ✅ Work Item Planning Must

- organize confirmed product-design facts into Story Map structure, milestone slicing, and lightweight work-item cards;
- support both `portfolio planning` and `direct intake`;
- keep proposal work in the conversation before confirmation;
- atomically write only the confirmed Story Map, milestone, card, and necessary Backlog changes after confirmation;
- reuse existing cards when the business identity is the same;
- check current card versions before writing and stop on version or fact conflicts.

### ❌ Work Item Planning Must Not

- do not create a `build/dev-cadence/` manifest, stage record, confirmation record, or checkpoint commit;
- do not duplicate Delivery Workflow requirements, diagnosis, solution, implementation, testing, review, acceptance, or cleanup records;
- do not create or modify User Journey, PRD, Business Architecture, or Feature ownership facts;
- do not force a direct-intake request into a full Story Map redraw;
- do not treat Story Map as an execution-status board or a workflow-run log;
- do not silently create duplicate cards, duplicate IDs, or parallel planning assets;
- do not implement standalone Work Item Analysis, standalone relative-size estimation, standalone iteration-capacity calibration, or unified Backlog redesign inside this skill.

## Modes

### Portfolio Planning

`portfolio planning` reads confirmed User Journey, PRD, and Business Architecture assets, then forms or incrementally updates the Story Map and related planning assets.

Before proposing changes, confirm:

- the authoritative input paths and their current versions;
- whether the request is a first full planning pass or an incremental adjustment;
- which assets are in scope and which assets must remain unchanged.

If the product-design baseline is not complete enough to support the requested planning change, stop and return to `discovery` rather than guessing missing requirements.

### Direct Intake

`direct intake` handles one clear Story, Task, or Bug request.

It may create or reuse a lightweight card and update only the necessary planning references. It must not automatically:

- redraw the full Story Map;
- reshuffle unrelated planning order;
- revise unrelated milestones;
- revise unrelated cards.

## Stage Sequence

Keep the business workflow in the current conversation:

```text
Planning Inputs And Scope Confirmation -> Planning Structure Proposal -> Planning Result Confirmation
```

Before confirmation, keep the complete proposal in the conversation and leave authoritative assets unchanged. After confirmation, atomically write only the affected assets. The user may confirm only part of the proposal; unconfirmed parts must keep their current authoritative content.

## Story Map Contract

The Story Map path is:

```text
docs/product-planning/story-map.md
```

Maintain one logical global Story Map. Do not create multiple competing Story Maps unless the user explicitly changes the repository contract.

### Backbone

The Story Map backbone must:

- reference all confirmed `Offline` and `System` Features from the User Journey in business order from left to right;
- display each Feature header with Type, Feature ID, and Title;
- keep `Offline` Features as business context only;
- allow Stories and only necessary Tasks under `System` Features;
- show the same Feature only once in the backbone even when multiple roles use it.

### Path Rules

The first column must be `Path`.

Allowed planning paths are:

- `Happy Path`
- `Alternative Path`
- `Sad Path`

Path is a Story Map planning classification, not a work-item type and not a lifecycle status. A work item appears at most once in the Story Map.

### Story Map Cell Rules

Each non-empty Story Map cell must contain exactly one Story or Task and show its stable ID and Title. Empty cells mean no work item exists there; they are not TODO placeholders.

Story Map position expresses planning order and grouping, but it must not be the only source of hard dependency meaning. Record hard dependencies explicitly in the relevant card or Backlog reference.

Bug cards do not enter the Story Map. They stay in the Backlog and relate to the affected Feature or Story.

## Milestone And MVP Contract

Work Item Planning may propose milestone slicing, but it must not present an unconfirmed slice as authoritative.

Milestones must use stable `M-nnn` IDs and include at least:

```text
ID | Title | Goal | Included Work Items | Derived From
```

`MVP` is the first user-confirmed milestone. It is not an automatically computed result.

`Included Work Items` must list explicit Story or Task IDs. A milestone must not dynamically reference an entire Path.

Work Item Planning may use `Happy Path`, `Alternative Path`, and `Sad Path` as proposal inputs, but the user may confirm a different slice. Do not silently rewrite milestone membership when new Path items appear later.

## Lightweight Card Contract

Story, Task, and Bug cards are long-lived authoritative assets.

Use repository-global stable IDs:

- Story: `S-nnn`
- Task: `T-nnn`
- Bug: `B-nnn`

Work Item Planning may create lightweight cards with the minimum fields:

```text
ID
Version
Status
Title
Goal or business result
Product or work-item references
Relationships
Change Log
```

`Relationships` is required. Dependencies, blockers, replacements, related items, and similar planning relationships must be recorded explicitly instead of being implied only by Story Map position or narrative text.

When the planning scope already includes a confirmed size field, the card may also include `Size`. Do not invent a standalone size-estimation process here.

Task cards may include optional `Nature`, but `Nature` does not create a new card type or a different lifecycle model.

## Work-Item Status Contract

Use these canonical work-item statuses:

- `Draft`
- `Ready`
- `In Progress`
- `Blocked`
- `Done`
- `Superseded`
- `Dropped`

Story must reach `Ready` before entering `feature-dev`.

Task does not need to reach `Ready` before a Delivery Workflow starts, but delivery work still must not modify code before that workflow confirms its own scope.

Bug may enter `bug-fix` without a `Ready` precondition and without a confirmed root cause.

If Task analysis reveals that the work actually needs new product behavior, stop treating it as a Task-only delivery item and create or associate the correct Story instead.

## Versioning, Reuse, And Concurrency

Every Story, Task, and Bug card must use an independent integer Version starting at `1`.

Increment the Version when confirmed changes alter the card's goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions.

Do not increment the Version for spelling-only, formatting-only, link-only, execution-status-only, or size-only changes.

Use this Change Log contract:

```text
Version | Recorded At | Recorded By | Change | Reason
```

Identity and timestamp rules must match the repository's other Asset Workflows.

When an existing card matches the same business identity, reuse it instead of creating a duplicate. Before writing any card change, check the current Version and visible facts. If the card changed since the current planning proposal was formed, stop and show the conflict instead of silently overwriting it.

## Backlog And Planning Relationships

The authoritative Backlog path is:

```text
docs/backlog.md
```

Backlog is the summary view for work-item status, priority, relationships, blockers, and suggested order. Story Map keeps business structure and slicing; it does not replace the Backlog.

Work Item Planning may update only the necessary Backlog references that belong to the confirmed planning change. It must not mechanically reorder unrelated items.

Task may relate to a Feature or a Story. A general Task without a clear product relationship may exist only in the Backlog. Bug relates to the affected Feature or Story and stays outside the Story Map.

## Product-Design Change Coordination

When `discovery` reports that confirmed product-design changes may affect planning assets, Work Item Planning must:

1. compare the affected Feature identities and order;
2. identify impacted Story Map positions, milestone membership, card relationships, and Backlog references;
3. propose keep, move, supersede, or remove-from-map dispositions for affected work items;
4. wait for user confirmation;
5. atomically write only the confirmed planning changes.

It must not automatically delete Story, Task, or Bug cards because product design changed.

## Handoff Boundary

Work Item Planning answers what work should exist and how planning assets relate.

It does not replace:

- `work-item-analysis` for detailed single-item scope and readiness analysis;
- `feature-dev` for implementation of Stories or feature-like Tasks;
- `bug-fix` for diagnosis and repair of Bugs;
- `refactor` for behavior-preserving structural Tasks.

After planning confirmation, hand the confirmed Story, Task, or Bug to the matching downstream workflow. Do not copy Delivery Workflow evidence into planning assets.
