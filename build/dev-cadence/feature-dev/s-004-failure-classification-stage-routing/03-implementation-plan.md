# S-004 Implementation Plan

## Sources

- Requirements: [01-requirements.md](01-requirements.md)
- Technical Solution: [02-technical-solution.md](02-technical-solution.md)
- Work item: `docs/stories/S-004-failure-classification-stage-routing.md`, version `1`

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Add symmetric failure lifecycle contract | Define and package the canonical classification, evidence, routing, retry, review-linkage, and rollback rules across all three development workflows. | `tests/workflow-symmetry.sh`, `src/skills/{feature-dev,bug-fix,refactor}/SKILL.md`, `version`, generated `dist/.dev-cadence/**` | RED/GREEN focused contract, source/distribution `rg`, whitespace check, full `check-all` |

## Detailed Tasks

### Task 1: Add Symmetric Failure Lifecycle Contract

**Files:**

- Modify: `tests/workflow-symmetry.sh`
- Modify: `src/skills/feature-dev/SKILL.md`
- Modify: `src/skills/bug-fix/SKILL.md`
- Modify: `src/skills/refactor/SKILL.md`
- Modify: `version`
- Generate: `dist/.dev-cadence/**` via `bash scripts/build.sh`

**Step 1: Write the failing symmetric contract**

- [ ] Add assertions for the exact seven canonical classifications.
- [ ] Add assertions for stable failure identity and required record fields.
- [ ] Add assertions for all routing categories, the no-weakening test rule, retry prerequisites, rerun results, blocking semantics, review source linkage, and S-003 rollback semantics.
- [ ] Assert that lifecycle results are not Backlog or work-item statuses.

**Step 2: Verify RED**

- [ ] Run `bash tests/workflow-symmetry.sh`.
- [ ] Expected: failure because the new `Failure Classification And Stage Routing` sections and canonical terms do not exist.

**Step 3: Implement the minimum workflow rules**

- [ ] Add the same contract structure to feature-dev, bug-fix, and refactor.
- [ ] Keep only workflow-specific stage names different.
- [ ] Place complete failure records in the observing stage record and only routing/blocking summaries in the manifest.
- [ ] Preserve overall `in_progress` for environment or externally blocked dependency handling.
- [ ] Link validated blocking review findings using their source finding IDs.

**Step 4: Verify GREEN and refactor**

- [ ] Run `bash tests/workflow-symmetry.sh`.
- [ ] Expected: all workflow symmetry checks pass.
- [ ] Review the three sections side by side and remove avoidable semantic drift while keeping stage names correct.

**Step 5: Update package version and build**

- [ ] Change root `version` from `0.11.0` to `0.12.0` because installed workflow behavior changes additively.
- [ ] Run `bash scripts/build.sh`.
- [ ] Verify canonical rules in `src/` and `dist/.dev-cadence/` with `rg --no-ignore`.

**Step 6: Development verification and self-review**

- [ ] Run `bash scripts/check-whitespace.sh`.
- [ ] Run `bash scripts/check-all.sh`.
- [ ] Review the staged diff against the requirements, solution, AGENTS.md, and acceptance criteria.
- [ ] Commit only the implementation files after the executing-plans identity gate passes.

## Development Implementation Completion Conditions

- [ ] All acceptance criteria have executable contract coverage or explicit source/distribution verification.
- [ ] The focused RED/GREEN cycle is recorded.
- [ ] All three workflow sections are symmetric apart from stage mappings.
- [ ] `dist/.dev-cadence/` is regenerated, not directly edited.
- [ ] Version is `0.12.0` in source and generated package.
- [ ] No Critical or Important review finding remains unresolved.

## Pre-Implementation Design Freshness Gate

- Work item identity: `docs/stories/S-004-failure-classification-stage-routing.md`, version `1`.
- Requirements identity: `build/dev-cadence/feature-dev/s-004-failure-classification-stage-routing/01-requirements.md`, confirmed by user on 2026-07-14.
- Technical Solution identity: `build/dev-cadence/feature-dev/s-004-failure-classification-stage-routing/02-technical-solution.md`, delegated confirmation on 2026-07-14.
- Plan identity: this file.
- Branch and code state before plan checkpoint: `codex/s-004-failure-classification-stage-routing` at `a095aab`.
- Dependency state: S-003 behavior is present in all three workflow skills; no external dependency is required.
- Material repository changes since confirmation: only S-004 workflow records; no source or contract changes in the affected boundary.
- Conclusion: 🟢 `ready`. Requirements, architecture assumptions, task split, files, and verification steps remain current.

## Plan Decision

- Decision: ✅ `confirmed` under the user's delegated authority on 2026-07-14.
