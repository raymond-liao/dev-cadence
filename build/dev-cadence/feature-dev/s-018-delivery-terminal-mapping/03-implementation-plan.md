# S-018 Delivery 终态映射与 Manual Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为三个 Delivery workflow 提供可审计的验收终态映射和受限的 manual recovery，并以 validator 与契约测试防止错误的 `abandoned` 终态。

**Architecture:** 三份 workflow 分别拥有其 Business Acceptance、Completion 和 run record 规则，保持同构文字与不同领域名词。共享的 `validate-delivery-record.sh` 只验证 terminal evidence，`tests/delivery-record-contract.sh` 提供真实 fixture，`tests/workflow-symmetry.sh` 防止三份 workflow 漂移；不新增 workflow、skill 或 vendored 行为。

**Tech Stack:** Bash、Markdown workflow skills、Git、现有 shell contract tests。

## Global Constraints

- 仅修改 `src/` 权威 workflow、validator、现有 contract tests 和根 `version`；运行 `bash scripts/build.sh` 同步 `dist/.dev-cadence/`，不得直接编辑 `dist/`。
- 不修改 `src/vendor/superpowers/skills/**`，也不改变具体 merge、discard 或 worktree 命令。
- Business Acceptance 选项保持 `Accept`、`Reject`、`Accept with residual risk`；记录的规范化值使用 `accepted`、`rejected`、`accepted_with_risk`。
- `accepted_with_risk` 的每项风险必须包含稳定 Risk ID、说明和责任人；`integrated` 不得抹去该事实。
- `rejected` 只有理由可定位最早受影响阶段时才回退；理由不足时留在 Business Acceptance，不进入 Completion。
- manual recovery 只适用于已 `accepted` 或 `accepted_with_risk`、正常 Completion 经不可恢复 Git/分支/worktree/权限/外部环境阻断和失败恢复尝试证明无法继续的 run；不得覆盖可恢复失败、验证或 Review 失败、普通返工、未完成验收或用户 discard。
- `abandoned` 必须保留 `07-manual-recovery-record.md` 的最小证据，且 manifest 没有 pending stage 或 checkpoint。
- 所有 S-018 实现提交使用 Dev Cadence 的 staged-only pre-commit review gate；每次只提交一个计划任务的文件。

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Terminal evidence validator | 先用真实 fixture 锁定有效与无效 `abandoned`，再收紧 validator。 | `tests/delivery-record-contract.sh`, `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh` | `bash tests/delivery-record-contract.sh` |
| Task 2: Symmetric workflow mapping | 先锁定三份 workflow 的终态文字契约，再写入一致的验收、返工和 recovery 规则。 | `tests/workflow-symmetry.sh`, `src/workflows/{feature-dev,bug-fix,refactor}/SKILL.md` | `bash tests/workflow-symmetry.sh` |
| Task 3: Package release verification | 升级可安装包版本、构建分发包并验证 source/distribution 与完整契约。 | `version`, `dist/.dev-cadence/**` generated | `bash scripts/check-all.sh`, source/dist `rg` |

## Pre-Implementation Gate

在任何 Task 开始前，执行并记录以下新鲜度检查。若任一检查显示 Story Version、Requirements/Technical Solution SHA、当前工作区代码或本任务依赖发生实质漂移，按 feature-dev 的 Pre-Implementation Design Freshness Gate 回到最早受影响阶段，不执行本计划。

```bash
bash .dev-cadence/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh \
  build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping
git rev-parse HEAD
git rev-parse main
sha256sum docs/stories/S-018-business-acceptance-terminal-mapping.md \
  build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/01-requirements.md \
  build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/02-technical-solution.md
git diff --name-status eb5ec356f451b5e9f55bd04d96efdacc975910d2..main
```

Expected: persistent-record recovery succeeds; S-018 remains Version `4` and `In Progress`; changes outside the selected source/test boundary are recorded as unrelated rather than silently merged into scope.

## Detailed Tasks

### Task 1: Terminal Evidence Validator

**Files:**
- Modify: `tests/delivery-record-contract.sh:59-294`
- Modify: `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh:90-180`

**Interfaces:**
- Consumes: Stage Table rows, Business Acceptance artifact, Overall Status, and `07-manual-recovery-record.md` in a Delivery run.
- Produces: `validate-delivery-record.sh RUN_DIR --terminal` accepts only an `abandoned` run with accepted Business Acceptance, terminal stages/checkpoints, and all required manual-recovery fields.

- [ ] **Step 1: Extend the terminal fixture with accepted Business Acceptance and a complete recovery record**

In `create_fixture`, declare the record path next to `acceptance_path`, make the acceptance record expose the normalized field consumed by the validator, then add a helper that writes the complete `07` evidence file:

```bash
local manual_recovery_path="$run_dir_rel/07-manual-recovery-record.md"

write_file "$repo" "$acceptance_path" "# Business Acceptance

- User Decision: \`accepted\`
- Accepted Residual Risks: None"

write_manual_recovery_record() {
  local repo="$1"
  local path="$2"
  write_file "$repo" "$path" "# Manual Recovery Record

- Blocking Category: \`git_state\`
- Blocking Evidence: merge identity mismatch reproduced.
- Blocked Completion Action: local merge to main.
- Recovery Attempt: refreshed merge identity and retried local merge.
- Recovery Result: failed; target branch changed outside this run.
- Why Further Recovery Is Not Viable: resolving target history requires external owner action.
- User Confirmation: explicit abandonment of normal Completion captured.
- Code Preservation: task branch preserved.
- Branch Preservation: preserved for follow-up owner.
- Worktree Preservation: preserved for follow-up owner.
- Run Record Preservation: preserved in the task worktree.
- Follow-up Owner: Delivery Contract.
- Next Step: owner reconciles target history before a new Completion attempt."
}
```

- [ ] **Step 2: Add failing `abandoned` scenarios and run the focused contract**

For `valid-abandoned`, retain confirmed implementation, verification and Business Acceptance rows; write the recovery record and change only `Overall Status` to `abandoned`. Add the exact cases below before the final fixture output:

```bash
valid-abandoned)
  write_manual_recovery_record "$repo" "$manual_recovery_path"
  sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
    "$repo/$run_dir_rel/manifest.md"
  rm "$repo/$run_dir_rel/manifest.md.bak"
  ;;
invalid-abandoned-missing-record)
  sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
    "$repo/$run_dir_rel/manifest.md"
  rm "$repo/$run_dir_rel/manifest.md.bak"
  ;;
invalid-abandoned-rejected-decision)
  write_manual_recovery_record "$repo" "$manual_recovery_path"
  sed -i.bak 's/User Decision: `accepted`/User Decision: `rejected`/' \
    "$repo/$acceptance_path"
  sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
    "$repo/$run_dir_rel/manifest.md"
  rm "$repo/$acceptance_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
  ;;
invalid-abandoned-missing-field)
  write_manual_recovery_record "$repo" "$manual_recovery_path"
  sed -i.bak '/^- Follow-up Owner:/d' "$repo/$manual_recovery_path"
  sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
    "$repo/$run_dir_rel/manifest.md"
  rm "$repo/$manual_recovery_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
  ;;
```

Add expectations:

```bash
valid_abandoned_run="$(create_fixture "valid-abandoned")"
run_expect_success "$valid_abandoned_run"

missing_recovery_run="$(create_fixture "invalid-abandoned-missing-record")"
run_expect_failure "$missing_recovery_run" "FAIL: abandoned manifest is missing manual recovery record"

rejected_recovery_run="$(create_fixture "invalid-abandoned-rejected-decision")"
run_expect_failure "$rejected_recovery_run" "FAIL: abandoned manifest requires accepted Business Acceptance decision"

incomplete_recovery_run="$(create_fixture "invalid-abandoned-missing-field")"
run_expect_failure "$incomplete_recovery_run" "FAIL: manual recovery record is missing Follow-up Owner"
```

Run: `bash tests/delivery-record-contract.sh`

Expected: FAIL before validator changes because the current validator accepts `abandoned` before checking Business Acceptance or `07` evidence.

- [ ] **Step 3: Implement minimal abandoned-evidence validation**

Capture the Business Acceptance artifact while parsing the Stage Table, then replace the early `abandoned` success path with explicit checks. Add helpers near existing `extract_status_value`:

```bash
require_manual_recovery_field() {
  local record_path="$1"
  local field="$2"
  rg -q "^- ${field}: .+" "$record_path" ||
    fail "manual recovery record is missing ${field}"
}

require_abandoned_evidence() {
  local acceptance_path="$1"
  local recovery_path="$2"
  [[ -n "$acceptance_path" && -f "$acceptance_path" ]] ||
    fail "abandoned manifest is missing Business Acceptance record"
  decision="$(rg -n '^- User Decision:' "$acceptance_path" | head -n 1 | sed 's/^[0-9]*:- User Decision: *//')"
  case "$decision" in
    \`accepted\`|\`accepted_with_risk\`) ;;
    *) fail "abandoned manifest requires accepted Business Acceptance decision" ;;
  esac
  [[ -f "$recovery_path" ]] || fail "abandoned manifest is missing manual recovery record"
  for field in "Blocking Category" "Blocking Evidence" "Blocked Completion Action" \
    "Recovery Attempt" "Recovery Result" "Why Further Recovery Is Not Viable" \
    "User Confirmation" "Code Preservation" "Branch Preservation" \
    "Worktree Preservation" "Run Record Preservation" "Follow-up Owner" "Next Step"; do
    require_manual_recovery_field "$recovery_path" "$field"
  done
}
```

Call `require_abandoned_evidence` only after the terminal stage-gap and checkpoint checks have run. Derive `recovery_path` as `"$run_dir/07-manual-recovery-record.md"` and do not bypass implementation or verification evidence for an accepted run.

- [ ] **Step 4: Run the terminal validator contract to green**

Run: `bash tests/delivery-record-contract.sh`

Expected: PASS, including all new valid and invalid abandoned fixtures.

- [ ] **Step 5: Review and commit the validator task**

Review staged `tests/delivery-record-contract.sh` and `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh` against the confirmed requirement, then commit only this task:

```bash
git add tests/delivery-record-contract.sh src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh
git commit -m "feat(flow): validate abandoned recovery evidence"
```

Expected: one reviewed implementation commit with the focused contract passing.

### Task 2: Symmetric Workflow Mapping

**Files:**
- Modify: `tests/workflow-symmetry.sh:760-842`
- Modify: `src/workflows/feature-dev/SKILL.md:768-865`
- Modify: `src/workflows/bug-fix/SKILL.md:701-814`
- Modify: `src/workflows/refactor/SKILL.md:782-895`

**Interfaces:**
- Consumes: the fixed three-option Business Acceptance menu and normalized Completion results.
- Produces: all Delivery workflows use the same terminal-state contract while retaining feature, repair, and refactor-specific source labels.

- [ ] **Step 1: Add failing symmetry assertions for the S-018 contract**

Append assertions next to the existing Business Acceptance and Completion checks:

```bash
assert_workflows "accepted decision enters Completion" \
  'accepted.*normal Completion' 'accepted.*normal Completion' 'accepted.*normal Completion'
assert_workflows "risk acceptance preserves responsibility" \
  'accepted_with_risk.*Risk ID.*description.*owner' \
  'accepted_with_risk.*Risk ID.*description.*owner' \
  'accepted_with_risk.*Risk ID.*description.*owner'
assert_workflows "rejection returns to earliest stage" \
  'rejected.*earliest affected stage.*in_progress.*must not enter Completion' \
  'rejected.*earliest affected stage.*in_progress.*must not enter Completion' \
  'rejected.*earliest affected stage.*in_progress.*must not enter Completion'
assert_workflows "manual recovery eligibility" \
  'manual recovery.*accepted_with_risk.*unrecoverable.*Recovery Attempt.*User Confirmation' \
  'manual recovery.*accepted_with_risk.*unrecoverable.*Recovery Attempt.*User Confirmation' \
  'manual recovery.*accepted_with_risk.*unrecoverable.*Recovery Attempt.*User Confirmation'
assert_workflows "manual recovery record" \
  '07-manual-recovery-record\\.md' '07-manual-recovery-record\\.md' '07-manual-recovery-record\\.md'
```

Run: `bash tests/workflow-symmetry.sh`

Expected: FAIL because the current workflow text lacks these mappings and record contract.

- [ ] **Step 2: Add the same Business Acceptance mapping to all three workflow skills**

Immediately after each fixed menu, add the same semantic sequence with the workflow's existing stage names:

```text
- Map `Accept` to `accepted`, record it, set the manifest overall status to `accepted`, and enter normal Completion.
- Map `Accept with residual risk` to `accepted_with_risk`; require a table of stable Risk ID, description, and owner before entering normal Completion, and preserve that table after integration.
- For `Reject`, require a rejection reason. When it identifies the earliest affected stage, record `rejected`, set that stage to `in_progress`, set later affected stages to `pending`, mark invalidated evidence superseded, and return there. When it does not identify a stage, remain in Business Acceptance and request clarification.
- `rejected` must not enter Completion, report success, or set `integrated`.
```

Update each Business Acceptance record contract so `User Decision` lists `accepted`, `rejected`, `accepted_with_risk`; add `Accepted Risk Register` with Risk ID, Description, Owner; and add `Rejection Reason and Return Target` with an explicit `None` value where not applicable.

- [ ] **Step 3: Add the same Completion/manual recovery contract to all three workflow skills**

Before each terminal readiness checklist, add a `Manual Recovery` subsection that requires accepted status, a proved unrecoverable allowed blocker, a failed recovery attempt, reason that normal recovery cannot continue, and explicit user confirmation. Specify the `07-manual-recovery-record.md` path and every field validated by Task 1. State that manual recovery is forbidden for retryable tool failures, verification/Review failures, ordinary rework, incomplete acceptance, discard, and recoverable Completion cases; retain all code/branch/worktree/run evidence and mark `abandoned` only after every stage/checkpoint is terminal.

- [ ] **Step 4: Run symmetry assertions to green**

Run: `bash tests/workflow-symmetry.sh`

Expected: PASS; all three workflows expose the same S-018 terminal mapping and manual recovery boundaries.

- [ ] **Step 5: Review and commit the workflow task**

Review the complete staged diff for symmetry, user-decision authority, and non-expansion into vendored commands. Then commit only the test and three source workflow files:

```bash
git add tests/workflow-symmetry.sh src/workflows/feature-dev/SKILL.md \
  src/workflows/bug-fix/SKILL.md src/workflows/refactor/SKILL.md
git commit -m "feat(flow): map delivery acceptance terminal states"
```

Expected: one reviewed implementation commit with the symmetry contract passing.

### Task 3: Package Release Verification

**Files:**
- Modify: `version`
- Generated: `dist/.dev-cadence/**`

**Interfaces:**
- Consumes: the reviewed source workflow, validator, and contract-test changes from Tasks 1-2.
- Produces: source version `0.31.0` and a synchronized, verified installed package; generated `dist/` remains ignored.

- [ ] **Step 1: Update the package version**

Replace the complete contents of `version` with:

```text
0.31.0
```

Run: `test "$(<version)" = "0.31.0"`

Expected: exit status `0`.

- [ ] **Step 2: Build the distribution and check source/distribution synchronization**

Run:

```bash
bash scripts/build.sh
rg --no-ignore -n "accepted_with_risk|07-manual-recovery-record.md|manual recovery" \
  src/workflows src/workflows/using-dev-cadence/scripts \
  dist/.dev-cadence/workflows dist/.dev-cadence/workflows/using-dev-cadence/scripts
```

Expected: each key terminal rule appears in its source and generated installed-package counterpart.

- [ ] **Step 3: Run focused and full verification**

Run:

```bash
bash tests/delivery-record-contract.sh
bash tests/workflow-symmetry.sh
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: all commands pass. If any command fails, classify the evidence under the existing Failure Classification And Stage Routing rules before changing implementation or tests.

- [ ] **Step 4: Review and commit release-source changes**

Review `version` and confirm generated `dist/` remains ignored. Commit only the tracked source version file:

```bash
git add version
git commit -m "chore(release): prepare dev cadence 0.31.0"
```

Expected: one reviewed release commit; `git status --short` contains no tracked S-018 implementation change.

## Plan Self-Review

- Spec coverage: Task 2 covers three decision mappings, risk responsibility, rejection return, eligibility and forbidden manual recovery paths. Task 1 verifies accepted-run evidence and no-pending terminal invariants. Task 3 covers versioning, build synchronization and full validation.
- Placeholder scan: no deferred implementation placeholders or unspecified test commands remain.
- Interface consistency: Task 1 establishes `User Decision` and the exact `07` fields; Task 2 requires the same names in every workflow; Task 3 verifies generated package propagation.

## Recovery Refresh

- Requirements and Technical Solution have been reconfirmed with validator-readable record identities. The selected scope, three task boundaries, file list, test-first cycles, version target and verification commands remain unchanged.
- The prior Implementation Plan confirmation and `Subagent-Driven` selection were superseded by Requirements recovery. This refreshed plan requires a new plan confirmation and a new execution-mode selection before any Task starts.
- The persistent-record recovery validator now reaches Implementation Plan only after validating the refreshed Requirements and Technical Solution identities. The formal Pre-Implementation Design Freshness Gate remains mandatory immediately before Development Implementation.

## 阶段决定

- Status: 🔄 `in_progress`
- Prior Confirmation: superseded by Requirements recovery; this refreshed plan preserves the same tasks and test-first verification.
- User Confirmation: `pending`。需要确认刷新后的 Implementation Plan 后才可开始 Development Implementation。
- Implementation Mode: `pending`; choose `Subagent-Driven` or `Inline Execution` with plan confirmation.
- 下一阶段：Implementation Plan；不得开始 Development Implementation。
