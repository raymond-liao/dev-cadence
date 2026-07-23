# B-012 修复记录

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/delivery/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Confirmed Repair Plan: [B-012 修复计划](03-repair-plan.md)
- Implementation Base SHA: `dc82cbd`
- Final Repair SHA: `b3addaa`
- Branch: `codex/parallel-b012-b010-b014`
- Status: ✅ `confirmed`

## RED / GREEN Evidence

- RED: `bash tests/work-item-development-workflow-contract.sh` failed with `missing ordered intake matrix` before the source rule change.
- GREEN: the same focused contract passed after the ordered intake matrix was added.
- Regression during implementation: `bash scripts/build.sh`, related routing/planning/package/install contracts, `bash scripts/check-whitespace.sh`, and `bash scripts/check-all.sh` passed.

## Changed Files

- `src/skills/using-dev-cadence/SKILL.md`
- `tests/work-item-development-workflow-contract.sh`

## Repair Notes

The entry skill now resolves type, visible status, and Story maturity before any claim write, explicitly blocks Draft Story claims before user-confirmed Ready, and preserves Ready Story, Task, and Bug qualification differences. The claim remains atomic, idempotent, and before branch/worktree preparation.

## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (`build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/04-code-review-report.md`)
- Review decision: ✅ `passed`
- Critical findings: None
- Important findings: None
- Unresolved findings: None
