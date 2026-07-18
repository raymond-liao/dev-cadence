# S-017 工作项卡片与开发 Workflow 接入 - 技术方案

## 需求来源

- Confirmed requirements: [S017 需求确认](01-requirements.md)
- Work item: [S017 工作项卡片与开发 Workflow 接入](../../../../docs/stories/S-017-work-item-development-workflow-integration.md), Version `5`
- Baseline: `8315c1e0e5bb6df037cd3865618fe5303da391ba`

## Codebase Exploration Findings

### 入口路由与资产职责

- `src/skills/using-dev-cadence/SKILL.md` already owns two-stage routing, active-run continuation, work-item planning, work-item analysis, and Delivery handoff. It is the only suitable owner for explicit implementation-time work-item claiming.
- `src/skills/work-item-planning/SKILL.md` owns durable planning assets, Backlog ordering, card schema, and shared ownership boundaries; it explicitly excludes S017 cross-workflow writeback.
- `src/skills/work-item-analysis/SKILL.md` owns detailed card definition and Story `Ready` decisions; it must remain an Asset Workflow without Delivery run records.

### Delivery workflow symmetry

- `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, and `src/skills/refactor/SKILL.md` share configuration, worktree, manifest, freshness, implementation, review, verification, acceptance, and Completion contracts.
- Existing card references are generic and do not consistently state card type gates, exact Version capture, lifecycle writeback, or Backlog projection behavior.
- `bug-fix` already has a dedicated post-Completion Backlog synchronization contract; Feature Dev and Refactor need symmetric lifecycle ownership without copying Bug-specific diagnosis rules.

### Contract-test and packaging boundaries

- `tests/routing-contract.sh` protects centralized entry routing.
- `tests/workflow-symmetry.sh` protects shared delivery contracts across the three Delivery Workflows.
- `tests/work-item-planning-contract.sh` and `tests/work-item-analysis-contract.sh` protect the upstream card owners and explicitly leave S017 writeback to Delivery integration.
- `scripts/build.sh` copies `src/skills` into `dist/.dev-cadence`; `tests/run-all.sh` already validates package, install, routing, symmetry, and whitespace contracts.

## Options

### Minimal-change: entry-only orchestration

Add claiming and route selection only to `using-dev-cadence`, leaving Delivery skills mostly unchanged.

- Advantage: smallest patch.
- Tradeoff: fails to give each Delivery Workflow an owned Version freshness and lifecycle writeback contract; acceptance criteria 4-6 would remain implicit.

### Clean-architecture: new shared work-item lifecycle skill

Create a reusable `work-item-lifecycle` skill and route all workflows through it.

- Advantage: centralizes shared mechanics.
- Tradeoff: creates a new shared capability with one natural owner and adds a new routing/package surface, contrary to S017's explicit no-new-skill scope and repository Skill admission rules.

### Pragmatic balance: entry orchestration plus symmetric Delivery contracts

Keep selection and claiming in `using-dev-cadence`; add compact, workflow-specific card integration sections to Feature Dev, Bug Fix, and Refactor; extend the existing routing and symmetry contracts with one focused S017 contract test.

- Advantage: preserves ownership boundaries, keeps Bug diagnosis unique, and makes all Delivery consumers enforce the same card identity/version/writeback invariants.
- Tradeoff: shared wording is repeated in the three authoritative Delivery skills, but the repetition is intentionally constrained by the existing symmetry contract and each workflow's distinct terminal semantics.

## ✅ Selected Approach

Use the pragmatic-balance approach.

## Design

1. `using-dev-cadence` performs implementation-time claiming only for explicit implementation requests. It first resolves the selected existing card and route; when the user asks to continue from Backlog, it reads `待处理` row order as the only selection order and uses the parallel view only for dependency context. It refuses silent skipping, duplicate claiming, and claiming for discussion, planning, analysis, or status-only requests.
2. The claim operation is a pre-branch/worktree orchestration step. It atomically updates the card's execution status and the matching Backlog row to `In Progress`, preserving the card Version and Change Log for execution-status-only changes, then prepares the dedicated branch/worktree and routes downstream.
3. `feature-dev` accepts only a user-confirmed `Ready Story`; `Task` may be scoped in its first stage; `Bug` remains in `bug-fix` and is not routed through Feature Dev. Each Delivery run records exact card path, type, Version, visible status, and selected scope without copying the card body.
4. All three Delivery Workflows check the current card Version before using card facts. A substantive card revision invokes existing Active Task Change Handling and returns to the earliest affected stage; a status-only transition does not create a new card Version.
5. At start, rework, Business Acceptance, and Completion, the owning Delivery Workflow records the card status, delivery result/reference, Backlog source/destination sections, and parallel-view projection. Writes are idempotent and stop on Version or visible-fact conflicts. No workflow advances its own internal stage into the card's status enum.
6. Terminal `Done`/Backlog movement remains tied to actual accepted/integrated delivery results. Branch keep, PR, cancelled discard, blocked discard, and whole-run discard do not falsely mark the card `Done`.

## Affected Modules And Boundaries

- Entry ownership: `src/skills/using-dev-cadence/SKILL.md`.
- Delivery consumers: `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`.
- Executable contract coverage: `tests/routing-contract.sh`, `tests/workflow-symmetry.sh`, and a new `tests/work-item-development-workflow-contract.sh`.
- Distribution/version: `scripts/build.sh` output and root `version` (`0.24.0 -> 0.25.0`).
- Durable work-item assets remain under `docs/`; run evidence remains under `build/dev-cadence/feature-dev/...`; no new skill or vendored Superpowers change.

## Testing Strategy

- Add RED contract assertions for the entry claim protocol, type/maturity gates, card identity/version fields, lifecycle writeback, conflict/idempotency rules, and Backlog ordering.
- Add symmetric assertions that all three Delivery skills expose the shared card integration contract while retaining workflow-specific boundaries.
- Run focused routing, workflow, and new S017 contracts during implementation, then build and run the complete `bash tests/run-all.sh` suite plus whitespace and source/dist synchronization checks.

## Risks And Constraints

- The rules are executable Markdown contracts; a wording mismatch can produce an apparently complete package with a broken workflow. Tests must assert stable normative phrases and ownership boundaries, not every prose sentence.
- Backlog and card writes are durable asset changes; the implementation must preserve row order, avoid duplicate rows, and stop on visible-fact conflicts.
- The current main checkout and task worktree must both expose the initial `In Progress` claim. The main projection checkpoint is `fe19bf5`; the task branch starts from `8315c1e` with equivalent card content.

## Stage Decision

- Status: ✅ `confirmed`
- Confirmation: delegated by the user on `2026-07-18`.
- Next: execute the TDD implementation plan.

