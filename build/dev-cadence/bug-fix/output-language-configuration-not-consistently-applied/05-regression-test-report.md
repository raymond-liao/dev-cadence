# B-004 Regression Test Report

## Verification Decision

⚠️ `ready_with_risk`

The executed repository evidence satisfies the configuration propagation and package contract scope. A real external AI host session was not available in this source repository, so generated-document language behavior remains a Business Acceptance residual risk.

## Verification Environment

- Repository: `dev-cadence`
- Branch: `codex/b-004-output-language-configuration-not-consistently-applied`
- Final implementation SHA: `4cf27b4`
- Configuration: `.dev-cadence.yaml`, `output_language: zh-CN`, `worktree.enabled: true`
- Workspace: `.worktrees/codex-b-004-output-language-configuration-not-consistently-applied`

## Original Problem Verification

| Scenario | Expected | Evidence | Result |
|---|---|---|---|
| Primary checkout config | `zh-CN` is resolved | Worktree config snapshot and configuration contract | ✅ `passed` |
| Fresh linked worktree | Ignored config is absent before propagation | Temporary Git fixture | ✅ `passed` |
| Config propagation | Stale `en` target is overwritten and becomes `zh-CN` | Fixture uses `cp -f`, `cmp -s`, and exact language assertion | ✅ `passed` |
| Config source resolution | Worktree locates primary checkout config through absolute `git-common-dir` | Temporary Git fixture | ✅ `passed` |
| Propagation failure | Workflow must stop instead of silently selecting English | Rule contract assertions | ✅ `passed` |
| Active run recovery | Snapshot has precedence over later fallback | Rule contract assertions and manifest snapshot | ✅ `passed` |

## Regression Checks

- `bash tests/configuration-contract.sh` - ✅ `passed`
- `bash tests/workflow-symmetry.sh` - ✅ `passed`
- `bash tests/work-item-planning-contract.sh` - ✅ `passed`
- `bash tests/work-item-analysis-contract.sh` - ✅ `passed`
- `bash tests/run-all.sh` - ✅ `passed`
- `bash scripts/check-all.sh` - ✅ `passed`
- `bash scripts/check-whitespace.sh` - ✅ `passed` through `check-all.sh`
- Package installed as Dev Cadence `0.22.0` in the install contract fixture - ✅ `passed`
- `git diff --check` - ✅ `passed`

## Acceptance Alignment

- Configured `zh-CN` is preserved across the tested Git worktree boundary.
- The supported language set, workflow stages, confirmation gates, record models, paths, IDs, commands, and canonical status values are unchanged.
- Missing or unsupported configuration behavior is explicit: English fallback is visible; propagation failure is blocking rather than silent.
- All workflow rule sources and generated package copies pass their contract checks.

## Skipped Or Unavailable Checks

- Real external AI host generation in a target repository: unavailable in this source-repository verification environment.
- Manual session recovery through an external host: unavailable in this source-repository verification environment.

## Residual Risk

Business Acceptance should confirm one real target-repository run that creates or resumes a workflow from the B-004 worktree and observes a Chinese user-facing record or summary. The repository-level implementation and regression checks are ready for that acceptance decision.
