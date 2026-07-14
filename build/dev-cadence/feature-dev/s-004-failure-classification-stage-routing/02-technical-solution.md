# S-004 Technical Solution

## Sources

- Confirmed requirements: [01-requirements.md](01-requirements.md)
- Work item: [S-004](../../../../docs/stories/S-004-failure-classification-stage-routing.md), version `1`
- Existing rollback semantics: `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, and `src/skills/refactor/SKILL.md`

## Codebase Exploration Findings

### Perspective 1: Workflow Stage And Record Boundaries

- Key files: `src/skills/feature-dev/SKILL.md:377`, `src/skills/bug-fix/SKILL.md:336`, `src/skills/refactor/SKILL.md:403`.
- Established pattern: each workflow owns its stage names and stage records, while structurally equivalent governance rules remain symmetric.
- Constraint: failure details belong in the stage record that observed the failure; the manifest contains only the current routing or blocking summary.
- Risk: a shared rule written with feature-only stage names would break bug-fix and refactor semantics.
- Essential files read: the three workflow skills, `src/skills/using-dev-cadence/SKILL.md`, `src/skills/document-conventions/SKILL.md`.

### Perspective 2: Rollback And Verification State

- Key files: `src/skills/feature-dev/SKILL.md:393`, `src/skills/feature-dev/SKILL.md:620`, `src/skills/bug-fix/SKILL.md:352`, `src/skills/refactor/SKILL.md:419`.
- Established pattern: returning to an earlier stage sets the earliest affected stage to `in_progress`, later affected stages to `pending`, and invalid evidence to `superseded`.
- Constraint: `environment_issue` blocks the current stage without changing the overall run from `in_progress`; failure lifecycle results are not Backlog or work-item statuses.
- Risk: recording a false `passed`, `failed`, or `ready` decision would bypass existing Verification Decision Gates.
- Essential files read: the freshness and verification sections of all three workflow skills, plus the S-003 story and S-004 requirements.

### Perspective 3: Contract Testing And Packaging

- Key files: `tests/workflow-symmetry.sh:569`, `tests/package-contract.sh:75`, `scripts/build.sh:1`, `scripts/check-all.sh:1`.
- Established pattern: executable Markdown contracts are tested with symmetric assertions, then copied from `src/skills/` to `dist/.dev-cadence/` by the build.
- Constraint: tests should assert stable semantics and canonical values, not entire prose blocks.
- Risk: source-only changes can leave the installable package stale unless `scripts/build.sh` runs.
- Essential files read: `tests/workflow-symmetry.sh`, `tests/package-contract.sh`, `tests/run-all.sh`, `scripts/build.sh`, `scripts/check-all.sh`, and root `version`.

## Architecture Alternatives

### Option A: Minimal Change

Add a short routing table independently to each implementation and verification section.

- Advantage: small diff.
- Tradeoff: record fields, retry gate, review linkage, and rollback semantics would remain fragmented and easy to drift.

### Option B: Clean Architecture

Create a new shared installed skill that owns a complete failure lifecycle and make all workflows delegate to it.

- Advantage: one canonical source.
- Tradeoff: introduces a new runtime abstraction, routing dependency, and ownership boundary beyond S-004's current scope.

### ✅ Selected: Option C - Pragmatic Balance

Add an identically named `Failure Classification And Stage Routing` contract to each workflow, keeping the canonical classification set, record schema, retry gate, result values, review linkage, and rollback behavior textually symmetric. Keep only workflow-specific stage mappings different. Extend `tests/workflow-symmetry.sh` to verify the shared contract and each mapping.

This option matches the repository's existing workflow-symmetry pattern, avoids a new skill, and keeps each workflow authoritative for its own stage records.

## Detailed Design

### Trigger And Identity

The lifecycle applies to blocking failures from implementation, build or compilation, automated tests, regression verification, System Testing, and implementation-stage code review. Each failure receives a stable ID that survives remediation, reruns, and reclassification.

### Canonical Classification

All workflows use exactly:

`implementation_bug`, `test_bug`, `environment_issue`, `unclear_requirement`, `design_conflict`, `architecture_conflict`, `missing_dependency`.

Classification must cite inspectable evidence. A failure record includes stable ID, evidence, classification rationale, remediation round, return target, result, and source finding ID when created from review.

### Routing

- `implementation_bug`: corresponding Implementation stage.
- `test_bug`: test asset owner or the testing correction step within the corresponding Implementation stage; effective tests must not be deleted, skipped, or weakened to hide an implementation failure.
- `unclear_requirement`: the earliest requirement or diagnosis stage.
- `design_conflict`: corresponding Solution stage.
- `architecture_conflict`: corresponding Solution stage plus reassessment of relevant Architecture and Decision sources.
- `environment_issue`: current business stage becomes `blocked`; overall run stays `in_progress`; the record states reproducible evidence and unblock conditions.
- `missing_dependency`: earliest stage able to resolve it; when outside task control, block the current run and state owner and unblock conditions.

Failure lifecycle results are limited to `closed`, `reclassified`, and `blocked`. They are internal record results and must not become Backlog or work-item statuses.

### Retry And Rollback

The same failure must not be retried without new evidence, a corrective action, or an environment change. After remediation, rerun the check associated with the stable failure ID and record the result.

Returning earlier reuses S-003 semantics: earliest affected stage `in_progress`, later affected stages `pending`, invalid evidence `superseded`, and required records refreshed and reconfirmed before proceeding.

### Review Integration

Only validated blocking review findings enter the failure lifecycle. The failure record keeps both its stable failure ID and the original source finding ID. Non-blocking or unvalidated findings remain in the existing review evidence model.

## Affected Modules And Boundaries

- Modify: `src/skills/feature-dev/SKILL.md`.
- Modify: `src/skills/bug-fix/SKILL.md`.
- Modify: `src/skills/refactor/SKILL.md`.
- Modify: `tests/workflow-symmetry.sh`.
- Modify: root `version` because installed workflow behavior changes.
- Generate only: `dist/.dev-cadence/**` through `bash scripts/build.sh`.
- Do not modify: `src/vendor/superpowers/**`, README files, Backlog status model, or work-item status values.

## Testing Strategy

1. Add symmetric contract assertions first and observe `tests/workflow-symmetry.sh` fail.
2. Add the minimum workflow rules and rerun the focused contract until green.
3. Build the installable package and use `rg --no-ignore` to verify canonical values and routing terms in both `src/` and `dist/.dev-cadence/`.
4. Run `bash scripts/check-whitespace.sh` and `bash scripts/check-all.sh`.

## Risks And Constraints

- The rules are intentionally duplicated across three authoritative workflow files; symmetry tests control drift.
- No global retry limit is introduced.
- No environment automation or external test-owner workflow is introduced.
- Business Acceptance and Completion risk propagation remain follow-up work.

## Technical Solution Decision

- Decision: ✅ `confirmed` under the user's delegated authority on 2026-07-14.
- Selected approach: Option C - Pragmatic Balance.
