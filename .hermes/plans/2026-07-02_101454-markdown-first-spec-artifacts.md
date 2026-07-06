# Markdown-first Spec Artifacts Plan

**Goal:** 将 `templates/spec/` 下的任务/交付 artifacts 从 YAML 表单导向 Markdown-first 文档，先解决 `cadence-subagent-development` 需要 Markdown `Task N` 的格式断层；同时明确 `templates/runs/` 不能继续只是 YAML schema stub，而应成为可读、可审查、checker 可解析的 run evidence 文档。

**Architecture:** Spec artifacts 应优先服务 Human/Supervisor 可读审阅；机器校验只读取必要的稳定字段，且应尽量从 Markdown heading、label、table、checklist 中提取。Run artifacts 不是用户第一阅读入口，但必须像 audit note / evidence log 一样能被 Human、Reviewer、Verifier 看懂：先回答“这次允许做什么、实际做了什么、有没有越界、验证和风险是什么”，再保留 checker-critical stable labels/tables/log blocks。`cadence-subagent-development` 继续以 Markdown `Task N` section 作为 Worker task brief 来源，不回退到 YAML task list。

**Scope:** 本计划覆盖 Dev Cadence runtime artifact 格式、生成器、checker、测试和文档说明，包括 `templates/spec/` 的 Markdown-first 转换，以及 `templates/runs/` 的 human-readable evidence policy；不改变 Supervisor/Harness/Worker 责任边界，不让 concrete Skills 直接写持久记录或拥有 gate status。

## Current Context

- `skills/cadence-subagent-development/SKILL.md` 明确要求 approved Markdown plan，并通过 `skills/cadence-subagent-development/scripts/task-brief` 提取 `Task N` section。
- `skills/cadence-subagent-development/scripts/task-brief` 只识别 Markdown heading，例如 `## Task 1` / `### Task 1: ...`，不解析 YAML `tasks:`。
- `skills/cadence-plan/SKILL.md` 已经定义 Markdown task shape：`### Task N`、`**Goal:**`、`**Files:**`、`**Interfaces:**`、`**Acceptance Mapping:**`、`**Test-First Plan:**`、`**Implementation Detail:**`、`**Steps:**`、`**Expected Evidence:**`。
- `templates/spec/03-tasks.md` 当前仍是 YAML-only skeleton，无法直接支持 `task-brief`。
- `scripts/run-delivery-dry-run.mjs` 也会生成 YAML-style `03-tasks.md`。
- `scripts/check-spec-artifacts.mjs`、`scripts/check-gates.mjs`、`scripts/summarize-acceptance.mjs` 目前依赖 fenced YAML block 读取部分字段。
- `templates/runs/*.md` 当前基本是 YAML key list，例如 `run-context.md`、`pre-implementation-status.md`、`execution-report.md`。它们虽然名义上是 Harness run evidence，但对 Human/Reviewer 来说不可读，不能直接回答“这次执行边界是什么、实际发生了什么、证据和风险是什么”。

## Desired Direction

1. `03-tasks.md` 先变成 Markdown-first，作为 P0。
2. 其它 `templates/spec/*.md` 后续分批 Markdown 化，减少 YAML 表单。
3. `templates/runs/` 采用 audit-note-style Markdown / schema-lite：不作为默认用户阅读路径，但必须 Human-readable、Reviewer-readable，并保留 checker-critical stable fields。
4. Checker/report 逐步支持 Markdown extraction，同时兼容旧 YAML artifacts。
5. Gate/status 仍由 Supervisor/Harness/checker 判断；artifact 文档只提供人可读证据和必要字段。

## Non-goals

- 不在本次计划中直接改代码。
- 不改变 `.dev-cadence.yaml` 本地配置文件格式；它仍是配置文件，保留 YAML 合理。
- 不在 Phase 1 同步改完 `templates/runs/`；但本计划会明确它们的目标形态，避免继续把 run evidence 当成只有机器能读的 schema stub。
- 不让 `cadence-subagent-development` 支持 YAML task list；正确方向是让前置 plan artifact 产出 Markdown tasks。
- 不把 concrete Skills 写成 artifact writer 或 gate owner。

## Spec vs Run Artifact Boundary

`templates/spec/` 和 `templates/runs/` 都是 Dev Cadence evidence，但不是同一种记录。

- `templates/spec/` 是 task delivery record / case file：说明任务是什么、为什么做、需求/设计/计划是什么、最终验证/Review/验收状态如何。它是用户和 Supervisor 的第一阅读路径，应该强 Markdown-first。
- `templates/runs/` 是 execution provenance / evidence exhibits：说明某一次 Worker/agent run 在什么边界下执行、被允许改什么、实际改了什么、跑了哪些命令、跳过了什么、风险和权限决策是什么。它不是默认用户入口，但必须能被 Human 打开后看懂，不能只是 YAML 字段清单。

因此 run artifacts 的目标不是“完全去机器字段”，而是：

- Human-readable sections 先行：`What this run was allowed to do`、`What happened`、`Files changed`、`Verification run`、`Skipped checks and risk`、`Handoff`。
- Stable labels/tables/log blocks 保留：`Run ID:`、`Task ID:`、`Status:`、`Allowed write paths:`、`Command | Result | Evidence` 等。
- Fenced YAML 只作为 legacy compatibility 或很小的 machine block；不应继续是整份 run template 的主体。

用户日常看 `specs/records/{task_id}/` 的主 artifacts；当需要追问“这条结论的执行证据是什么、Worker 有没有越界、命令到底跑没跑”时，才下钻到 `runs/{run_id}/`。

## Implementation Phases

### Phase 1: Make `03-tasks.md` Markdown-first

**Files likely to change:**

- `templates/spec/03-tasks.md`
- `scripts/run-delivery-dry-run.mjs`
- `scripts/check-discipline-routes.mjs`
- `tests/test-dry-run.sh`
- Possibly `tests/test-gate-enforcement.sh`

**Plan:**

1. Replace `templates/spec/03-tasks.md` YAML-only template with a readable Markdown executable plan template.

   Target shape:

   ```markdown
   # Tasks

   ## Planning Summary

   Status:
   Task class:
   Selected workflow:
   Required extra gates:

   ## File Structure Map

   - Create:
   - Modify:
   - Test:
   - Artifact files:

   ## Global Constraints

   - Forbidden actions:
   - Dependencies:
   - Risks:

   ## Ordered Tasks

   ### Task 1: [Component or behavior name]

   **Goal:**

   **Files:**
   - Create:
   - Modify:
   - Test:

   **Interfaces:**
   - Consumes:
   - Produces:

   **Acceptance Mapping:**
   - Covers:

   **Test-First Plan:**
   - Red behavior or characterization:
   - Red command:
   - Expected Red result:
   - Green command:
   - Expected Green result:
   - Neighboring checks:

   **Implementation Detail:**
   - Test detail:
   - Code detail:
   - New/changed surface:

   **Steps:**
   - [ ] Write the failing test or characterization check.
   - [ ] Implement the minimal change.
   - [ ] Run focused verification.
   - [ ] Run neighboring/regression checks.
   - [ ] Record review checkpoint notes.

   **Dependencies:**

   **Risk:**

   **Expected Evidence:**
   ```

2. Prefer removing the YAML block from `03-tasks.md` template entirely.

   Compatibility note:
   - `check-spec-artifacts.mjs` currently gets `task_class` and `selected_workflow` from `03-tasks.md` first, then `00-brief.md`.
   - Since `00-brief.md` already carries these fields, update checker logic if needed so missing YAML in `03-tasks.md` is acceptable.

3. Update `scripts/run-delivery-dry-run.mjs` so dry-run generated `03-tasks.md` includes real Markdown task sections.

   Minimum dry-run task body:
   - `### Task 1: Initialize delivery runtime artifacts`
   - Goal, files, acceptance mapping, verification command, expected evidence.

4. Update `scripts/check-discipline-routes.mjs` to enforce this contract.

   Add checks that:
   - `templates/spec/03-tasks.md` includes `## Ordered Tasks`.
   - It includes a `Task N` heading example compatible with `task-brief`.
   - It includes task anchors required by `cadence-plan`: `**Goal:**`, `**Files:**`, `**Acceptance Mapping:**`, `**Test-First Plan:**`, `**Implementation Detail:**`, `**Expected Evidence:**`.

5. Add or update a smoke test that proves `task-brief` works against a generated or fixture `03-tasks.md`.

   Suggested test location:
   - Existing: `tests/test-dry-run.sh`, if using dry-run generated artifact.
   - Or new small test: `tests/test-subagent-task-brief.sh` if clearer.

   Assertion shape:
   - Generate or create a `03-tasks.md` with `### Task 1: ...`.
   - Run `skills/cadence-subagent-development/scripts/task-brief <plan> 1 <outfile>`.
   - Assert output contains the Task 1 heading and does not include Task 2.

6. Run targeted checks:

   ```bash
   node scripts/check-discipline-routes.mjs .
   node scripts/check-spec-artifacts.mjs templates
   bash tests/test-dry-run.sh
   ```

7. Run full regression:

   ```bash
   bash tests/run-all.sh
   ```

### Phase 2: Make checkers Markdown-aware while preserving old YAML compatibility

**Files likely to change:**

- `scripts/check-spec-artifacts.mjs`
- `scripts/check-gates.mjs`
- `scripts/summarize-acceptance.mjs`
- Tests under `tests/`

**Plan:**

1. Add helper parsing utilities for Markdown labels/tables.

   Examples:
   - `readLabel(text, 'Task class')`
   - `readLabel(text, 'Selected workflow')`
   - `sectionText(text, 'Gate G3')`
   - `hasTaskHeading(text, 1)`

2. Keep YAML parser as compatibility fallback.

   Read order should become:
   - Markdown-first for new templates.
   - YAML fallback for existing artifacts and legacy fixtures.

3. For `03-tasks.md`, checker should not require fenced YAML.

   It should validate:
   - Task class and workflow available from `00-brief.md` or readable Markdown labels.
   - At least one `Task N` section for executable implementation plans.
   - Required task anchors exist for non-trivial implementation plans.

4. Keep gate ownership separate.

   Checker can report gate-relevant status, but Skills/artifacts should not claim they “own” gate status.

5. Update tests that hard-code YAML-only fixtures only where necessary.

   Avoid rewriting every old fixture immediately; old YAML compatibility is useful.

### Phase 3: Convert remaining `templates/spec/*.md` to human-readable Markdown

**Files likely to change:**

- `templates/spec/00-brief.md`
- `templates/spec/01-requirements.md`
- `templates/spec/02-design.md`
- `templates/spec/research-report.md`
- `templates/spec/04-test-plan.md`
- `templates/spec/05-implementation.md`
- `templates/spec/06-test-report.md`
- `templates/spec/07-review-report.md`
- `templates/spec/08-acceptance.md`
- `references/spec-templates.md`
- `scripts/run-delivery-dry-run.mjs`
- Report/checker tests as needed

**Recommended artifact shapes:**

1. `00-brief.md`

   ```markdown
   # Brief

   Task ID:
   Requested by:
   Date:
   Selected workflow:
   Task class:

   ## Goal

   ## Background

   ## Constraints

   ## Initial Risks

   ## Assumptions

   ## Open Questions
   ```

2. `01-requirements.md`

   ```markdown
   # Requirements

   Status:

   ## Goal

   ## Scope

   ## Non-goals

   ## Users / Stakeholders

   ## Acceptance Criteria

   - [ ] ...

   ## Constraints

   ## Ambiguity Check

   Unresolved ambiguity:
   Material to implementation:
   Clarification required:

   ## Requirements Readiness

   Ready for implementation:
   Blocking questions:
   ```

3. `02-design.md`

   ```markdown
   # Design

   Status:

   ## Problem

   ## Chosen Approach

   ## Alternatives Considered

   ## Architecture Constraints

   ## Affected Components

   ## Data / Control Flow

   ## Risks

   ## Human Decisions
   ```

4. `04-test-plan.md`

   ```markdown
   # Test Plan

   Status:

   ## Scope

   ## Strategy

   ## Commands

   | Command | Expected result | Covers |
   |---|---|---|

   ## Test Data

   ## Environment

   ## Coverage Targets

   ## Skipped Checks and Risks
   ```

5. `05-implementation.md`

   ```markdown
   # Implementation

   Status:

   ## Planned Files

   ## Changed Files

   ## Created Artifact Files

   ## Scope Reconciliation

   ## Implementation Notes

   ## Feedback Evidence

   ## Known Limitations

   ## Follow-up Needed
   ```

6. `06-test-report.md`

   ```markdown
   # Test Report

   Status:
   Verification status:

   ## Commands Run

   | Command | Result | Evidence |
   |---|---|---|

   ## Coverage

   ## Skipped Checks

   ## Failures / Blockers

   ## Residual Risk

   ## Gate G4 Notes
   ```

7. `07-review-report.md`

   ```markdown
   # Review Report

   Status:
   Decision:

   ## Review Scope

   ## Evidence Reviewed

   ## Findings

   | Severity | Finding | Evidence | Required action |
   |---|---|---|---|

   ## Blockers

   ## Residual Risk

   ## Gate G5 Notes
   ```

8. `08-acceptance.md`

   ```markdown
   # Acceptance

   Status:
   Accepted by Human:
   Accepted at:

   ## Accepted Scope

   ## Evidence Reviewed

   ## Human Gate Decisions

   ## Residual Risk Accepted

   ## Merge / Release Decision

   ## Follow-up

   ## Gate G6 Notes
   ```

**Important:** Keep status values, workflow IDs, gate IDs, and command identifiers in English even when artifact prose language is `zh`, matching repository language boundary rules.

### Phase 3.5: Convert `templates/runs/*.md` from schema stubs to readable evidence notes

**Files likely to change:**

- `templates/runs/run-context.md`
- `templates/runs/pre-implementation-status.md`
- `templates/runs/execution-report.md`
- `templates/runs/tool-log.md`
- `templates/runs/test-log.md`
- `templates/runs/diff-summary.md`
- `templates/runs/permission-decisions.md`
- `docs/runs/*.md`
- `references/harness.md`
- `references/spec-templates.md`
- `scripts/check-spec-artifacts.mjs` / `scripts/check-gates.mjs` only where parser expectations need Markdown labels/tables

**Goal:** Keep run evidence audit-first and checker-friendly, but make every run artifact answer a Human-readable question instead of presenting only a YAML key list.

**Target policy:**

- Run artifacts are not the default user-facing summary; spec artifacts are.
- Run artifacts must still be readable when a Human, Reviewer, or Verifier opens them.
- Use stable Markdown labels, tables, checklists, and command/log blocks as the primary shape.
- Keep only the minimum machine-compatible fields required by checkers and gates.
- Preserve old YAML parsing as a compatibility fallback while generated templates move to Markdown/schema-lite.

**Recommended run artifact shapes:**

1. `run-context.md`

   ```markdown
   # Run Context

   Run ID:
   Task ID:
   Agent role:
   Status:

   ## What this run is allowed to do

   Allowed read paths:
   - ...

   Allowed write paths:
   - ...

   Forbidden paths:
   - ...

   ## Tools and environment

   Allowed tools:
   Denied tools:
   Network policy:
   Secret policy:

   ## Required evidence

   - pre-implementation status
   - execution report
   - tool/test logs
   - diff summary

   ## Limits

   Budget:
   Timeout:
   Max iterations:
   ```

2. `pre-implementation-status.md`

   Keep this stricter than other run docs because it gates S1/S2 edits:

   ```markdown
   # Pre-Implementation Status

   Run ID:
   Task ID:
   Captured at:
   Task class:
   Selected workflow:
   Implementation authorized: true | false
   Post-hoc backfill: true | false

   ## Worktree before implementation

   Git status before:
   Untracked files before:

   ## Authorized scope

   Authorized target files:
   - ...

   Authorized artifact files:
   - ...

   ## Gate-relevant baseline

   G1 status:
   G2 status:
   G3 status:
   Requirements ready:
   Blocking questions:

   ## Human override, if post-hoc

   Override by:
   Override reason:

   ## Residual risk
   ```

3. `execution-report.md`

   ```markdown
   # Execution Report

   Run ID:
   Task ID:
   Agent role:
   Status:
   Started at:
   Ended at:

   ## What happened

   ## Files changed

   | File | Planned? | Change summary |
   |---|---|---|

   ## Artifacts created or updated

   ## Verification run

   ## Skipped checks

   ## Errors and blockers

   ## Residual risk

   ## Handoff
   ```

4. `tool-log.md`

   ```markdown
   # Tool Log

   Run ID:
   Task ID:

   ## Commands and tools used

   | Time | Tool/command | Purpose | Result | Evidence path |
   |---|---|---|---|---|

   ## Notable output
   ```

5. `test-log.md`

   ```markdown
   # Test Log

   Run ID:
   Task ID:
   Verification status:

   ## Commands run

   | Command | Result | Evidence | Covers |
   |---|---|---|---|

   ## Skipped checks
   ## Failures
   ## Residual risk
   ```

6. `diff-summary.md`

   ```markdown
   # Diff Summary

   Run ID:
   Task ID:
   Scope reconciliation status:

   ## Planned changes
   ## Actual changes
   ## Unplanned changes
   ## Deleted files
   ## Behavior changes
   ## Risk areas
   ## Rollback notes
   ```

7. `permission-decisions.md`

   ```markdown
   # Permission Decisions

   Run ID:
   Task ID:

   ## Decisions

   | Request | Risk | Decision | Decider | Time | Reason |
   |---|---|---|---|---|---|

   ## Deferred or denied requests
   ## Residual risk
   ```

**Checker implications:**

- `check-gates.mjs` and related checks should read stable Markdown labels/tables first, then fallback to fenced YAML for existing records.
- G4/G5 should not require users to read raw run logs by default; they should use run evidence to support summaries in `06-test-report.md` and `07-review-report.md`.
- Missing run evidence should remain gate-relevant, but failure messages should name the human question that cannot be answered, e.g. “cannot verify allowed write scope” instead of only “missing allowed_write_paths”.

### Phase 4: Update docs and contract language

**Files likely to change:**

- `references/spec-templates.md`
- `references/planning-discipline.md`
- `skills/cadence-plan/SKILL.md` only if wording needs alignment
- `skills/cadence-subagent-development/SKILL.md` only if it needs a clearer pointer to `03-tasks.md`
- Possibly `docs/artifacts/` if present and describing YAML artifacts

**Plan:**

1. Update `references/spec-templates.md` from “Prefer YAML-like field blocks plus concise Markdown notes” to “Prefer Markdown-first artifacts with stable labels/tables/checklists; use fenced YAML only for local config examples or compatibility-only schemas.”

2. Clarify that `03-tasks.md` is the source of executable Markdown `Task N` sections.

3. Preserve role boundaries:
   - Artifact templates define evidence shape.
   - Supervisor/Harness/checkers evaluate gate state.
   - Concrete Skills return handoff data; they do not own persistent record writing or gate status.

4. Add contract checks to prevent regression back to YAML-only `03-tasks.md`.

## Validation Plan

Targeted commands:

```bash
node scripts/check-discipline-routes.mjs .
node scripts/check-spec-artifacts.mjs templates
bash tests/test-dry-run.sh
bash tests/test-gate-enforcement.sh
```

Full regression:

```bash
bash tests/run-all.sh
```

Manual validation:

1. Open `templates/spec/03-tasks.md` and confirm it is readable as Markdown without understanding YAML.
2. Run `task-brief` against a generated `03-tasks.md` and confirm Task 1 extraction is correct.
3. Inspect dry-run generated `specs/records/{task_id}/03-tasks.md` and confirm it contains `### Task 1`.
4. Confirm checkers still accept existing YAML-style fixtures where compatibility is intended.

## Risks and Tradeoffs

- Removing YAML too quickly can break `check-gates.mjs`, `check-spec-artifacts.mjs`, or `summarize-acceptance.mjs` because they currently parse fenced YAML blocks.
- Keeping YAML forever makes artifacts hard for Humans to review and blocks clean `cadence-subagent-development` task extraction.
- Best tradeoff: Markdown-first templates now, parser compatibility during transition, then progressively retire YAML assumptions.

## Open Questions for Human Decision

1. Should Phase 1 remove YAML from `03-tasks.md` completely, or allow a tiny compatibility label block during transition?

   Recommendation: remove fenced YAML from `03-tasks.md`; rely on `00-brief.md` and Markdown labels for machine fields.

2. Should all `templates/spec/*.md` be converted in one PR/change, or split after `03-tasks.md`?

   Recommendation: split. First fix `03-tasks.md` + subagent support; then convert the rest once checker parsing is Markdown-aware.

3. Should `templates/runs/` remain YAML/schema-like longer than `templates/spec/`?

   Recommendation: no, not as YAML-only schema stubs. They can stay more structured than spec artifacts, but should become audit-note-style Markdown/schema-lite. Run evidence is more machine/checker oriented than spec artifacts, but it must still be readable enough for a Human/Reviewer to understand the execution boundary, actual actions, verification, skipped checks, and residual risk.

## Suggested Acceptance Criteria

- `templates/spec/03-tasks.md` is Markdown-first and contains a `Task N` section shape compatible with `task-brief`.
- Dry-run generated `03-tasks.md` contains at least one Markdown `Task N` section.
- `task-brief` smoke test passes on a generated or fixture `03-tasks.md`.
- Existing gate/check/report tests still pass.
- `references/spec-templates.md` no longer presents YAML-like spec templates as the preferred artifact style.
- The plan defines a separate `templates/runs/` policy: run artifacts are not the default user summary, but they must be human-readable audit notes with stable machine-readable labels/tables/log blocks.
- Full `bash tests/run-all.sh` passes.
