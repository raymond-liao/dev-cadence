# T-004 Dev Cadence 内部 Git 提交能力 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `git-commit` 收敛为只能由 Dev Cadence Workflow 或 shared capability 调用的 staged-only 共享提交能力，并由 `using-dev-cadence` 集中定义调用边界。

**Architecture:** `using-dev-cadence` 负责判断当前 commit 是否属于 Dev Cadence 管理上下文并路由固定安装路径；`git-commit` 只检查调用方已暂存的单一提交单元、生成 Conventional Commit message 并执行一次 commit。业务 Workflow 和 shared capability 继续拥有提交时机、范围、检查、暂存和证据，允许提交的子代理通过 dispatch context 接收相同约束。

**Tech Stack:** Markdown workflow skills、Bash contract tests、`rg`、Git、现有 build/install shell scripts。

## Global Constraints

- 只有当前 commit 由 Dev Cadence Workflow 或入口直接路由的 shared capability 管理时，才能调用 `.dev-cadence/skills/git-commit/SKILL.md`。
- 普通仓库提交不得调用安装包内的 `git-commit`。
- `git-commit` 不执行 `git add`，不决定业务范围，不执行测试，不维护 Workflow 记录。
- scope 可选；`style` 仅表示不改变含义的格式修改；保留 `build` 和 `ci`；必要技术术语可以用于准确描述意图和影响。
- 敏感文件、无暂存内容和范围混杂必须在 commit 前阻断。
- 不修改 `src/vendor/superpowers/**`，不直接编辑 `dist/.dev-cadence/**`，不修改仓库外个人全局 skill。
- 影响安装包行为，根 `version` 从 `0.21.0` 更新为 `0.22.0`。

---

### Task 1: Shared commit capability contract and implementation

**Files:**
- Create: `tests/git-commit-contract.sh`
- Modify: `tests/run-all.sh`
- Modify: `tests/skill-description-contract.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `src/skills/git-commit/SKILL.md`

**Interfaces:**
- Consumes: `using-dev-cadence` 的现有两阶段路由、活动 Workflow 恢复和 `<SUBAGENT-STOP>` 边界。
- Produces: 固定路径 `.dev-cadence/skills/git-commit/SKILL.md`、Dev Cadence managed commit context、staged-only shared skill contract。

- [ ] **Step 1: 写入失败契约测试**

创建 `tests/git-commit-contract.sh`，使用现有 `rg` 契约模式验证入口与 shared skill：

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="$ROOT_DIR/src/skills/using-dev-cadence/SKILL.md"
COMMIT_SKILL="$ROOT_DIR/src/skills/git-commit/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null || fail "missing $label"
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null || fail "missing $label"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label"
  fi
}

assert_literal "shared commit section" "## Shared Commit Capability" "$ENTRY"
assert_literal "installed commit skill path" ".dev-cadence/skills/git-commit/SKILL.md" "$ENTRY"
assert_match "managed context boundary" 'Workflow.*shared capability|shared capability.*Workflow' "$ENTRY"
assert_match "ordinary commit exclusion" 'ordinary.*commit.*[Dd]o not.*git-commit|[Dd]o not.*git-commit.*ordinary.*commit' "$ENTRY"
assert_match "subagent dispatch propagation" 'subagent.*task brief.*git-commit|git-commit.*subagent.*task brief' "$ENTRY"

assert_match "internal-only description" '^description: Use when using-dev-cadence delegates a Dev Cadence-managed commit\.$' "$COMMIT_SKILL"
assert_match "delegated context required" '[Rr]efuse.*direct|direct.*[Rr]efuse|must be delegated' "$COMMIT_SKILL"
assert_match "cached diff inspection" 'git diff (--cached|--staged)' "$COMMIT_SKILL"
assert_match "no staging rule" 'must not.*git add|[Dd]o not.*git add' "$COMMIT_SKILL"
assert_not_match "git add command" '^[[:space:]]*git add([[:space:]]|$)' "$COMMIT_SKILL"
assert_match "sensitive files block" '[Ss]ensitive.*block|block.*[Ss]ensitive' "$COMMIT_SKILL"
assert_match "optional scope" 'scope.*optional|optional.*scope' "$COMMIT_SKILL"
assert_match "style means formatting" 'style.*format|format.*style' "$COMMIT_SKILL"
assert_match "build and ci types" '`build`.*`ci`|`ci`.*`build`' "$COMMIT_SKILL"
assert_match "technical language allowed" 'technical.*when.*accura|accura.*technical' "$COMMIT_SKILL"
assert_match "control returns to caller" 'return.*caller|caller.*control' "$COMMIT_SKILL"
assert_match "no follow-up git suggestions" 'must not suggest.*push.*amend.*reset|[Dd]o not suggest.*push.*amend.*reset' "$COMMIT_SKILL"

printf 'Git commit contract checks passed.\n'
```

在 `tests/run-all.sh` 的 routing contract 后加入：

```bash
bash "$ROOT_DIR/tests/git-commit-contract.sh"
```

在 `tests/skill-description-contract.sh` 中加入：

```bash
assert_description \
  "src/skills/git-commit/SKILL.md" \
  "Use when using-dev-cadence delegates a Dev Cadence-managed commit."
assert_no_process_summary "src/skills/git-commit/SKILL.md"
```

- [ ] **Step 2: 运行 focused test 并确认 RED**

Run: `bash tests/git-commit-contract.sh`

Expected: FAIL，首个失败为缺少 `## Shared Commit Capability`，证明现有入口尚未路由共享提交能力。

- [ ] **Step 3: 在入口增加集中路由规则**

在 `src/skills/using-dev-cadence/SKILL.md` 的 Document Conventions 规则之后增加 `## Shared Commit Capability`，完整表达：

````markdown
## Shared Commit Capability

After selecting or restoring a Dev Cadence workflow, or directly routing a Dev Cadence shared capability, use the installed shared commit capability for every commit managed by that context:

```text
.dev-cadence/skills/git-commit/SKILL.md
```

The owning workflow or shared capability must determine commit timing and scope, run applicable checks, and stage exactly one commit unit before invoking `git-commit`. The shared capability must not select a workflow, stage files, run tests, or replace workflow records and evidence.

Do not invoke the installed `git-commit` for an ordinary repository commit that is not managed by a Dev Cadence workflow or shared capability. Handle that request through the target repository's ordinary Git rules.

When dispatching a subagent that may create a commit, include the installed skill path, the owning Dev Cadence context, and the staged-only constraint in the subagent task brief. The `<SUBAGENT-STOP>` routing boundary does not remove this dispatch responsibility.
````

- [ ] **Step 4: 将 git-commit 重写为 staged-only 内部能力**

修改 `src/skills/git-commit/SKILL.md`，至少包含以下精确契约：

```markdown
---
name: git-commit
description: Use when using-dev-cadence delegates a Dev Cadence-managed commit.
allowed-tools: Bash, Read, Grep
---

# Dev Cadence Git Commit

Use this shared capability only when `using-dev-cadence` delegates a commit owned by a Dev Cadence workflow or shared capability. Refuse direct use without that delegated context.

The caller owns commit timing, scope, checks, exact staging, and workflow evidence. This skill must not run `git add`, select or advance a workflow, run tests, create branches, or update manifests and stage records.

## Allowed Git Operations

- `git status`
- `git diff --cached`
- `git commit -m <message>`

Do not run `git add`. Inspect only the staged commit unit. If no staged changes exist, return without creating a commit.

## Commit Gate

1. Read the delegated Dev Cadence context and the caller's declared commit unit.
2. Inspect `git status --short`, `git diff --cached --stat`, and the complete `git diff --cached`.
3. Stop and return control to the caller when the staged set is empty, contains unrelated changes, or cannot form one atomic commit.
4. Sensitive staged files or credential-like staged content block the commit. Do not downgrade this result to a warning.
5. Generate one Conventional Commit message, show the message and staged files, then execute one `git commit -m` without requesting a second confirmation.
6. Return the commit result to the caller. The caller captures the full hash, verifies applicable identity, updates evidence, and continues the owning context.

## Message Rules

- Use `<type>[optional scope]: <description>`; scope is optional.
- Use `feat`, `fix`, `perf`, `refactor`, `style`, `docs`, `test`, `build`, `ci`, or `chore` according to the staged intent.
- `style` means formatting-only changes that do not change behavior; user-interface behavior or appearance changes use the type matching their actual intent.
- Describe the change's intent and impact accurately. Use technical terms when they are necessary for accuracy.
- Use an optional body for motivation and an optional footer for issue references or breaking changes.
- Do not add tool attribution.

## Return Boundary

Return control immediately after the commit result. Do not suggest `push`, `amend`, `reset`, merge, branch cleanup, or any other follow-up Git operation.
```

- [ ] **Step 5: 运行 focused 和相邻契约并确认 GREEN**

Run: `bash tests/git-commit-contract.sh`

Expected: `Git commit contract checks passed.`

Run: `bash tests/routing-contract.sh && bash tests/skill-description-contract.sh`

Expected: routing 与 description checks 均通过。

- [ ] **Step 6: 创建实施提交**

```bash
git add tests/git-commit-contract.sh tests/run-all.sh tests/skill-description-contract.sh src/skills/using-dev-cadence/SKILL.md src/skills/git-commit/SKILL.md
git commit -m "feat(flow): route managed commits through shared capability"
```

### Task 2: Package, installation, version, and full verification

**Files:**
- Modify: `tests/package-contract.sh`
- Modify: `tests/install-contract.sh`
- Modify: `version`
- Generated: `dist/.dev-cadence/**` through `bash scripts/build.sh`

**Interfaces:**
- Consumes: Task 1 的入口固定路径和 `git-commit` source contract。
- Produces: Version `0.22.0` 的 source/dist/install 一致性和安装结果点验。

- [ ] **Step 1: 增加 package 与 install 明确点验**

在 `tests/package-contract.sh` 的 `required_files` 中加入：

```bash
"dist/.dev-cadence/skills/git-commit/SKILL.md"
```

并加入：

```bash
assert_match ".dev-cadence/skills/git-commit/SKILL.md" "src/skills/using-dev-cadence/SKILL.md"
assert_match "Use when using-dev-cadence delegates a Dev Cadence-managed commit" "src/skills/git-commit/SKILL.md"
```

在 `tests/install-contract.sh` 首次安装检查中加入：

```bash
test -f "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "first install did not create git-commit skill"
```

在更新安装比较中加入：

```bash
cmp -s \
  "$ROOT_DIR/src/skills/git-commit/SKILL.md" \
  "$TARGET_REPO/.dev-cadence/skills/git-commit/SKILL.md" || fail "installed git-commit skill differs from source"
```

- [ ] **Step 2: 更新版本并构建分发包**

将根 `version` 精确更新为：

```text
0.22.0
```

Run: `bash scripts/build.sh`

Expected: `dist/.dev-cadence/version` 为 `0.22.0`，source 与 dist skills 内容一致。

- [ ] **Step 3: 运行 package 和 install checks**

Run: `bash tests/package-contract.sh && bash tests/install-contract.sh`

Expected: `Package contract checks passed.` 和 `Install contract checks passed.`

- [ ] **Step 4: 检查关键规则同步**

Run: `rg --no-ignore -n 'Shared Commit Capability|Dev Cadence-managed commit|git diff --cached' src/skills dist/.dev-cadence/skills`

Expected: `using-dev-cadence` 与 `git-commit` 的关键规则同时出现在 source 和 dist，不出现仅一侧匹配。

- [ ] **Step 5: 运行完整验证**

Run: `bash scripts/check-whitespace.sh`

Expected: exit `0`。

Run: `bash scripts/check-all.sh`

Expected: 所有 package、Asset/Delivery、workflow、routing、git-commit、install 和 whitespace contract checks 通过。

- [ ] **Step 6: 创建 package 提交**

```bash
git add tests/package-contract.sh tests/install-contract.sh version
git commit -m "chore(release): package managed commit capability"
```

## Plan Self-Review

- Spec coverage: 入口边界、所有 Workflow、shared capability、Dev Cadence 外禁止调用、staged-only、SDD 传递、Conventional Commit 规则、package/install 和版本均有对应任务。
- Placeholder scan: 每个修改步骤都包含精确内容、命令和预期结果，没有待补内容。
- Interface consistency: 两个任务使用同一固定路径 `.dev-cadence/skills/git-commit/SKILL.md` 和同一 managed commit context。
