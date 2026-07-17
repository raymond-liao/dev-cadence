# B-004 Business Acceptance Record

## Status

✅ `accepted`

## Accepted Problem Source

- Confirmed diagnosis: [B-004 Problem Diagnosis](01-problem-diagnosis-record.md)
- Confirmed repair solution: [B-004 Repair Solution](02-repair-solution.md)

## Regression Test Report Source

- [B-004 Regression Test Report](05-regression-test-report.md)
- Verification decision: ⚠️ `ready_with_risk`

## User Decision

✅ `accepted`

The user selected fixed option `1. Accept` after the residual risk was presented.

## Decision By

`Raymond Liao <raymond-liao@outlook.com>`

## Decision At

`2026-07-17T22:51:54+08:00`

## Accepted Result

The user accepted the B-004 repair that preserves the configured output language across linked Git worktrees and active-run continuation, makes fallback visible, blocks continuation when configuration propagation fails, aligns workflow language rules, and adds a real Git worktree regression fixture.

## Accepted Residual Risks

- Real external AI host generation and manual host-session recovery were not executed in this source-repository environment.
- The user accepted this residual risk based on the repository-level configuration propagation, package, workflow contract, installation, and regression evidence.

## Final Follow-Up Actions

- Verified feature commit `8cc4e3e46d64c8a5b627970b084657cab2e13923` was locally merged into `main` by merge commit `b1280cac705b5e1ded28cea2036b5592d072239d`.
- The `version` conflict was resolved to `0.22.0`, preserving the B-004 minor release over the `0.21.1` patch already on `main`.
- `bash scripts/check-all.sh` passed on the merged `main` result.
- The worktree `.worktrees/codex-b-004-output-language-configuration-not-consistently-applied` was removed after successful verification.
- The task branch `codex/b-004-output-language-configuration-not-consistently-applied` was deleted after its verified commit was confirmed as an ancestor of `main`.
- No push or pull request was performed.
