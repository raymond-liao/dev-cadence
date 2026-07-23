# B-014 修复记录

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/delivery/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Confirmed Repair Plan: [B-014 修复计划](03-repair-plan.md)
- Implementation Base SHA: `5a97b61`
- Final Repair SHA: `be61691`
- Branch: `codex/parallel-b012-b010-b014`
- Status: ✅ `confirmed`

## RED / GREEN Evidence

- RED: `bash tests/work-item-planning-contract.sh` and `bash tests/confirmation-gates-contract.sh` failed because the baseline had no mode-specific stage branch and Direct Intake inherited the shared gates.
- GREEN: both focused contracts passed after the explicit Portfolio Planning/Direct Intake split.
- Regression during implementation: `bash scripts/build.sh`, package/install contracts, `bash scripts/check-whitespace.sh`, and `bash scripts/check-all.sh` passed.

## Changed Files

- `src/skills/work-item-planning/SKILL.md`
- `docs/workflows/work-item-planning.md`
- `tests/work-item-planning-contract.sh`
- `tests/confirmation-gates-contract.sh`

## Repair Notes

Portfolio Planning retains its two formal gates. Direct Intake now uses necessary clarification, a proposal, and one `Direct Intake Result Confirmation`; necessary clarification is explicitly not a formal gate. Card and necessary Backlog references remain one atomic confirmation unit, including ordering metadata when applicable.

## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (`build/dev-cadence/bug-fix/b-014-single-card-intake-duplicate-confirmation-gates/04-code-review-report.md`)
- Review decision: ✅ `passed`
- Critical findings: None
- Important findings: None
- Unresolved findings: None
