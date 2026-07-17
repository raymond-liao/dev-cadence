# B-001 普通 Checkout 本地 Merge 安全性：回归测试报告

## 状态

⚠️ `ready_with_risk`

回归证据已执行，Business Acceptance 尚未开始。

## Problem And Repair Sources

- Problem Diagnosis: `01-problem-diagnosis-record.md`
- Repair Solution: `02-repair-solution.md`
- Repair Plan: `03-repair-plan.md`
- Repair Implementation: `04-repair-record.md`
- Code Review: `04-code-review-report.md`

## Test Environment

- Repository: `dev-cadence`
- Branch: `codex/b-001-normal-checkout-local-merge-safety`
- Final implementation SHA: `64020b253d04acfc8d4879272e9848a238e02e6b`
- Package version: `0.21.1`
- Configuration: `output_language: zh-CN`, `worktree.enabled: true`
- Runtime: local Bash and Git CLI; temporary repositories for command-sequence tests

## Test Cases

| ID | Scenario | Type | Execution | Result | Evidence |
|---|---|---|---|---|---|
| RT-01 | Baseline repository contracts before repair | Baseline | `bash scripts/check-all.sh` before implementation | ✅ `passed` | Initial baseline output in diagnosis context |
| RT-02 | Original contract fails before source repair | TDD RED | `bash tests/finishing-a-development-branch-contract.sh` before source change | ✅ `passed` | Expected `FAIL: missing feature branch snapshot` |
| RT-03 | Fixed SHA and local-only source contract | Contract | `bash tests/finishing-a-development-branch-contract.sh` after repair | ✅ `passed` | `Finishing local merge contract checks passed.` |
| RT-04 | Feature branch moves after confirmation | Manual Git regression | Temporary repo: compare captured feature SHA with moved branch tip | ✅ `passed` | `branch_drift=blocked` |
| RT-05 | Offline local-only Merge | Manual Git regression | Temporary repo without remote tracking; merge captured SHA without pull/fetch | ✅ `passed` | `local_only_merge=passed` |
| RT-06 | Already-integrated expected SHA | Manual Git regression | Temporary repo where expected SHA is already an ancestor of base | ✅ `passed` | `already_integrated=already-integrated` |
| RT-07 | Source and distribution vendored skill synchronization | Package/source inspection | `cmp -s src/vendor/.../SKILL.md dist/.dev-cadence/vendor/.../SKILL.md` | ✅ `passed` | Exit status `0` |
| RT-08 | Package contract | Package contract | `bash tests/package-contract.sh` | ✅ `passed` | `Package contract checks passed.` |
| RT-09 | Installation contract and version | Install contract | `bash tests/install-contract.sh` | ✅ `passed` | Installed Dev Cadence `0.21.1`; `Install contract checks passed.` |
| RT-10 | Complete repository contracts | Full regression | `bash scripts/check-all.sh` after final implementation | ✅ `passed` | All package, workflow, install, routing, symmetry, skill, and whitespace checks passed |
| RT-11 | Final whitespace and source/dist identity | Repository check | `bash scripts/check-whitespace.sh` plus final `cmp` checks | ✅ `passed` | Exit status `0` |
| RT-12 | Initial manual probe command syntax | Test harness correction | First probe used invalid `git switch -cq feature` | ❌ `failed`, then closed as `test_bug` | Corrected to `git switch -q -c feature`; rerun covered RT-04 to RT-06 |
| RT-13 | Live agent-driven Finishing interaction | Manual integration | Not run; this repository packages Markdown rules rather than an executable Finishing engine | ⏭️ `skipped` | Residual risk recorded below |

## Bug Fix Coverage

| Repair point | Test cases | Status |
|---|---|---|
| Reviewed feature tip can move after Completion | RT-02, RT-03, RT-04 | `covered` |
| Base and feature branch identity snapshots | RT-03, RT-04 | `covered` |
| local-only Merge without remote dependency | RT-03, RT-05 | `covered` |
| already-integrated result | RT-03, RT-06 | `covered` |
| Post-Merge expected SHA and final base verification | RT-03, RT-05, RT-06 | `covered` |
| Source, distribution, installation, and version synchronization | RT-07, RT-08, RT-09, RT-10, RT-11 | `covered` |

## Impact Scope Coverage

| Impact area | Test cases | Status |
|---|---|---|
| Normal checkout local Merge path | RT-03, RT-04, RT-05, RT-06 | `covered` |
| Named-branch cleanup ordering remains in the source rule | RT-03, RT-10 | `covered` |
| Keep As-Is, Pull Request, Discard, and detached HEAD boundaries remain unchanged | RT-03, RT-10 | `covered` by source inspection and full contracts |
| Installed package carries the repaired vendored rule | RT-07, RT-08, RT-09 | `covered` |

## Failed Or Skipped Checks

- `T-B001-MANUAL-001`: initial manual probe command had invalid `git switch -cq feature` syntax; classified as `test_bug`, corrected, and closed. It did not exercise or alter the implementation.
- RT-13 was skipped because no executable agent-driven Finishing engine exists in this repository. The rule text, contract, and equivalent Git command sequence were still verified.

## Residual Risks

- A real agent may still misunderstand prose despite the explicit command contract; no live agent-driven Finishing session was run.
- No remote PR or push behavior was changed or tested; those paths are outside this Bug.

## Verification Decision

⚠️ `ready_with_risk`

The confirmed bug is covered by RED/GREEN contract evidence and fixed command-sequence regression tests. The only remaining non-blocking gap is the skipped live agent-driven Finishing interaction.

## Recommendation

The fix may enter Business Acceptance with the residual risk above explicitly presented.
