# B-001 普通 Checkout 本地 Merge 安全性：修复实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

## 状态

✅ `confirmed`

用户确认：“好，可以，继续”。该确认包括固定 SHA、local-only Merge、分支移动即停止，以及 base branch 的确定性选择规则。

**Goal:** 修复 Finishing 的本地 Merge 路径，使它只合入完成门禁时确认的提交，并在离线、已集成、分支移动和合并失败场景下给出可验证且不破坏现场的结果。

**Architecture:** 将 Merge 身份作为 Completion 选择前的不可变快照保存到规则上下文，在执行前重新验证 base branch 和 feature branch 仍指向快照。local-only 路径只使用本地提交对象，以固定 SHA 执行 Merge；成功后用祖先关系、最终 HEAD 和工作区状态验证结果，再沿用已有清理顺序。

**Tech Stack:** Markdown-based vendored Superpowers skill, Bash contract tests, Git CLI, Dev Cadence build/install checks.

## Global Constraints

- 只修改权威源 `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`，不得直接编辑 `dist/.dev-cadence/**` 或 `.dev-cadence/vendor/**`。
- 根目录 `version` 必须从 `0.21.0` 更新为 `0.21.1`，构建后验证 source、dist 和安装包同步。
- 不修改远程 PR、push、Discard、detached HEAD、worktree 所有权或业务阶段语义。
- 所有记录使用 `output_language: zh-CN`，路径使用仓库相对路径。
- 每个实现提交前执行精确暂存和提交身份检查；stage checkpoint 不进入 implementation ledger。
- 生产规则修改必须遵循 TDD：先让 focused contract test 在当前版本失败，再修改规则使其通过。

---

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1: Merge 身份与失败安全契约 | 用失败先行的契约测试锁定固定 SHA、local-only、already-integrated、失败停止和结果验证，并修改 vendored Finishing 规则。 | `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`; `tests/finishing-a-development-branch-contract.sh`; `tests/run-all.sh` | focused contract RED -> GREEN；规则文本检查；`git diff --check` |
| Task 2: 版本与分发同步 | 发布安装包行为修复版本，重新构建分发包并验证安装结果与全量契约。 | `version`; generated `dist/.dev-cadence/**` | `bash scripts/build.sh`；source/dist comparison；`bash scripts/check-all.sh`；whitespace check |

## Detailed Tasks

### Task 1: Merge 身份与失败安全契约

**Files:**

- Create: `tests/finishing-a-development-branch-contract.sh`
- Modify: `tests/run-all.sh`
- Modify: `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`

**Interfaces:**

- Consumes: current Finishing environment detection, base branch selection, four-option Completion menu, and existing cleanup ownership rules.
- Produces: a documented `EXPECTED_FEATURE_SHA`/base identity contract that later Task 2 packages unchanged.

- [ ] **Step 1: Write the failing contract test**

Create `tests/finishing-a-development-branch-contract.sh` with `set -euo pipefail`, a `ROOT_DIR` calculation, and assertion helpers that fail with the missing contract name. Point `FINISHING_SKILL` at `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`.

The test must assert these exact source obligations:

```bash
assert_literal "feature branch snapshot" 'FEATURE_BRANCH=$(git branch --show-current)' "$FINISHING_SKILL"
assert_literal "expected feature SHA snapshot" 'EXPECTED_FEATURE_SHA=$(git rev-parse "$FEATURE_BRANCH")' "$FINISHING_SKILL"
assert_literal "base branch selection" 'BASE_BRANCH=main' "$FINISHING_SKILL"
assert_literal "base branch existence check" 'git show-ref --verify --quiet refs/heads/main' "$FINISHING_SKILL"
assert_literal "expected base SHA snapshot" 'EXPECTED_BASE_SHA=$(git rev-parse "$BASE_BRANCH")' "$FINISHING_SKILL"
assert_literal "feature identity recheck" 'test "$(git rev-parse "$FEATURE_BRANCH")" = "$EXPECTED_FEATURE_SHA"' "$FINISHING_SKILL"
assert_literal "base identity recheck" 'test "$(git rev-parse "$BASE_BRANCH")" = "$EXPECTED_BASE_SHA"' "$FINISHING_SKILL"
assert_literal "fixed SHA merge" 'git merge "$EXPECTED_FEATURE_SHA"' "$FINISHING_SKILL"
assert_literal "already integrated verification" 'git merge-base --is-ancestor "$EXPECTED_FEATURE_SHA" "$BASE_BRANCH"' "$FINISHING_SKILL"
assert_literal "already integrated result" 'already-integrated' "$FINISHING_SKILL"
assert_literal "post merge HEAD capture" 'FINAL_BASE_SHA=$(git rev-parse "$BASE_BRANCH")' "$FINISHING_SKILL"
assert_literal "local only wording" 'local-only' "$FINISHING_SKILL"
assert_match "failure stops cleanup" 'failure.*(stop|停止).*(cleanup|清理)|cleanup.*(stop|停止).*(failure|失败)' "$FINISHING_SKILL"
assert_match "identity failure preserves branch" '(branch|分支).*(preserve|保留).*(identity|身份|SHA)' "$FINISHING_SKILL"
assert_not_match "local merge does not pull" '^[[:space:]]*git pull([[:space:]]|$)' "$FINISHING_SKILL"
assert_not_match "local merge does not merge mutable branch" '^[[:space:]]*git merge <feature-branch>' "$FINISHING_SKILL"
```

Append `bash "$ROOT_DIR/tests/finishing-a-development-branch-contract.sh"` to `tests/run-all.sh` immediately after the package contract. Keep the test focused on the vendored Finishing source; do not assert unrelated workflow prose.

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
bash tests/finishing-a-development-branch-contract.sh
```

Expected: `FAIL` because the current skill has no frozen `EXPECTED_FEATURE_SHA`, still contains `git pull`, and still merges `<feature-branch>`. This failure proves the test detects the reported bug before any production rule change.

- [ ] **Step 3: Implement the minimal source-rule repair**

Update only the base-selection and Option 1 sections of `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`.

Before presenting Completion options, preserve the selected base branch and add this identity snapshot:

```bash
FEATURE_BRANCH=$(git branch --show-current)
EXPECTED_FEATURE_SHA=$(git rev-parse "$FEATURE_BRANCH")
EXPECTED_BASE_SHA=$(git rev-parse "$BASE_BRANCH")
```

Determine the base branch before taking the snapshot with this deterministic rule: use local `main` when `refs/heads/main` exists; otherwise use local `master` when `refs/heads/master` exists; if neither exists, stop and ask for the base branch. Run `git merge-base HEAD "$BASE_BRANCH"` as an ancestry check; if it fails, stop and ask for an explicit base decision. The merge-base output is evidence only and must not replace the branch name.

Document that any failed identity command, detached state, dirty tracked/untracked state, or ambiguous base stops the flow before presenting or executing local Merge. Immediately before switching to base, require:

```bash
test "$(git rev-parse "$FEATURE_BRANCH")" = "$EXPECTED_FEATURE_SHA"
test "$(git rev-parse "$BASE_BRANCH")" = "$EXPECTED_BASE_SHA"
```

Replace the current Option 1 command block with a local-only sequence that moves to the main repository root, checks the captured identities and target workspace, records `already-integrated` when the expected SHA is already an ancestor, otherwise runs `git merge "$EXPECTED_FEATURE_SHA"`, captures `FINAL_BASE_SHA`, verifies the expected SHA and workspace state, and only then runs tests and cleanup.

State explicitly that every failed command, conflict, identity mismatch, or post-merge verification failure stops the flow, preserves the branch/worktree, and must not report completion. Keep the existing cleanup ordering: remove an owned worktree only after verified Merge/test success, then delete the branch. Add a final feature identity check before branch deletion so a branch that moved after Merge is retained rather than deleted.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run:

```bash
bash tests/finishing-a-development-branch-contract.sh
git diff --check
bash scripts/check-whitespace.sh
```

Expected: all focused contract assertions pass; every command exits `0` with no whitespace or patch errors.

- [ ] **Step 5: Review Task 1 scope and create its implementation commit**

Stage only `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`, `tests/finishing-a-development-branch-contract.sh`, and `tests/run-all.sh`. Use the executing-plans commit identity gate with unit `plan-task-1`, then commit:

```bash
git commit -m "fix(finishing): bind local merge to verified commit"
```

Expected: the commit contains only Task 1 changes and its parent/tree identity matches the persisted review evidence.

### Task 2: 版本与分发同步

**Files:**

- Modify: `version`
- Generated by command: `dist/.dev-cadence/**`

**Interfaces:**

- Consumes: the verified Task 1 source-rule commit and focused contract result.
- Produces: version `0.21.1` and a distribution tree exactly synchronized with `src/`.

- [ ] **Step 1: Update the package version**

Change the single line in `version` from `0.21.0` to `0.21.1`. Do not edit generated `dist/` files manually.

- [ ] **Step 2: Build the distribution package**

Run:

```bash
bash scripts/build.sh
```

Expected: `dist/.dev-cadence` is regenerated, including the repaired vendored Finishing skill and version `0.21.1`.

- [ ] **Step 3: Verify source, distribution, and install contracts**

Run:

```bash
cmp -s src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md dist/.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md
cmp -s version dist/.dev-cadence/version
bash tests/finishing-a-development-branch-contract.sh
bash tests/package-contract.sh
bash tests/install-contract.sh
```

Expected: every command exits `0`; the package contains the repaired source and version `0.21.1`.

- [ ] **Step 4: Run the complete repository checks**

Run:

```bash
bash scripts/check-whitespace.sh
bash scripts/check-all.sh
```

Expected: all package, workflow, install, routing, symmetry, and whitespace contracts pass. Re-check the source/dist comparison after `scripts/check-all.sh` completes.

- [ ] **Step 5: Review Task 2 scope and create its implementation commit**

Stage only `version`. Generated `dist/` remains ignored and is verified on disk, not force-added. Use the executing-plans commit identity gate with unit `plan-task-2`, then commit:

```bash
git commit -m "chore(release): publish B-001 merge safety fix"
```

Expected: the commit contains only the version change; the repaired source and generated package remain synchronized on disk.

## Implementation Completion Conditions

- Focused contract test passed after failing against the baseline.
- Task 1 and Task 2 implementation commits have exact parent/tree evidence in the repair ledger.
- The repaired source contains no local Merge `git pull` or mutable `git merge <feature-branch>` command.
- Fixed SHA, branch/base identity rechecks, already-integrated result, post-merge verification, and failure-preservation rules are all present.
- `version` is `0.21.1` and `src/vendor` matches `dist/.dev-cadence/vendor`.
- `bash scripts/check-all.sh` and `bash scripts/check-whitespace.sh` pass.
- Repair Implementation record, code review report, and regression report can be written from fresh command evidence.

## Plan Self-Review

- Spec coverage: Task 1 covers the confirmed root cause and all repair acceptance areas; Task 2 covers version and source/dist/install synchronization.
- TDD coverage: the focused contract is added and run in RED before the source rule changes, then rerun in GREEN.
- Scope check: no task changes Discard, detached HEAD, PR, worktree ownership, or business workflow semantics.
- Placeholder scan: no `TODO`, `TBD`, or unspecified verification step remains in the detailed tasks.

## Execution Method

Use inline `superpowers:executing-plans` execution. The two tasks are coupled through one Markdown skill contract and one build/install surface; there is no independent implementation slice that would benefit from separate agents.
