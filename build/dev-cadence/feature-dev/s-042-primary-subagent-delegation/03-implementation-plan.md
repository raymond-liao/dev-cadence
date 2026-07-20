# S-042 Primary Execution Subagent Delegation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every installed Dev Cadence workflow delegate its full non-interactive execution to a designated primary execution subagent when the platform supports internal subagents, without changing user decision or Git authorization boundaries.

**Architecture:** `using-dev-cadence` remains the sole owner of the three-role delegation protocol, dispatch timing, return shape, recovery, and no-capability fallback. Discovery and Architecture Design receive only role-specific stop guards so a designated primary can execute them while an ordinary bounded task agent cannot reroute or recursively delegate the whole request. Existing workflow gates and the package build/install pipeline remain the enforcement points for all other behavior.

**Tech Stack:** Markdown workflow skills, Bash contract tests, existing `scripts/build.sh` and `scripts/install.sh`.

## Global Constraints

- Modify only the confirmed files in this plan; do not modify root `AGENTS.md`, `src/AGENTS-snippet.md`, vendored Superpowers, or add a workflow, Skill, script, configuration item, public state, or `agents` directory.
- Keep `src/skills/using-dev-cadence/SKILL.md` as the single owner of cross-workflow delegation and routing policy; Discovery and Architecture Design may contain only their local role-specific stop guard.
- Preserve existing user confirmation, Business Acceptance, Completion, and explicit authorization rules for merge, PR, push, discard, and branch deletion.
- Treat temporary or cache drafts as non-authoritative and do not promise that they survive cleanup, machine changes, or a lost runtime.
- Bump `version` from `0.26.5` to `0.27.0` because this changes installed-package workflow behavior.
- Do not edit `dist/.dev-cadence/` directly; regenerate it with `bash scripts/build.sh`, then update the current target checkout with `bash scripts/install.sh .`.
- Keep generated `dist/` and `build/dev-cadence/` artifacts untracked. This repository's tracked `.dev-cadence/` directory is its dogfood installed package; after `bash scripts/install.sh .`, inspect and commit only the generated in-scope package files.

---

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: Role protocol contract and source rules | Add one entry-owned protocol, permit a designated primary in the two currently blocking Asset Workflows, and lock all acceptance boundaries in the routing contract. | `src/skills/using-dev-cadence/SKILL.md`, `src/skills/discovery/SKILL.md`, `src/skills/architecture-design/SKILL.md`, `tests/routing-contract.sh` | `bash tests/routing-contract.sh` fails before source changes and passes after them. |
| Task 2: Package-facing behavior and installation checks | Publish the behavior in both READMEs, bump the package version, and verify relevant source Skills survive fresh and replacement installation. | `README.md`, `README.zh-CN.md`, `version`, `tests/install-contract.sh` | `bash tests/install-contract.sh` and `bash tests/package-contract.sh` pass. |
| Task 3: Generated-package synchronization and implementation exit checks | Build and install the package, prove all three representations contain the protocol, and run the complete required checks. | Generated `dist/.dev-cadence/`, generated `.dev-cadence/`, `build/dev-cadence/feature-dev/s-042-primary-subagent-delegation/04-implementation-record.md` | Build, focused contracts, whitespace, full contracts, and explicit `rg` synchronization checks pass. |

## Detailed Tasks

### Task 1: Role Protocol Contract And Source Rules

**Files:**
- Modify: `tests/routing-contract.sh`
- Modify: `src/skills/using-dev-cadence/SKILL.md`
- Modify: `src/skills/discovery/SKILL.md`
- Modify: `src/skills/architecture-design/SKILL.md`

**Interfaces:**
- Consumes: the entry selector's existing pre-exploration routing boundary, Asset/Delivery continuation rules, and existing Delivery Git/terminal gates.
- Produces: an entry-owned `## Primary Execution Delegation` contract and an `ORDINARY-SUBAGENT-STOP` guard that lets only an explicitly designated primary execution subagent execute the two Asset Workflows that currently stop every subagent.

- [x] **Step 1: Add failing routing-contract assertions before changing a source Skill.**

Add a generic helper next to `assert_literal` so the test can inspect non-entry Skill files:

```bash
assert_literal_in() {
  local label="$1"
  local literal="$2"
  local path="$3"

  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}
```

Append assertions for these literal protocol sentences in `ENTRY_SKILL`:

```bash
assert_literal "primary delegation heading" "## Primary Execution Delegation"
assert_literal "dispatch before workflow loading" "Before reading a candidate workflow skill or exploring the repository, the user-facing main session must delegate the complete Dev Cadence request when the platform supports internal subagents."
assert_literal "primary role" "A primary execution subagent is explicitly designated in the dispatch brief to execute the complete Dev Cadence request."
assert_literal "ordinary role boundary" "An ordinary subtask agent must execute only its bounded brief; it must not select or restore a Dev Cadence workflow or recursively delegate the complete request."
assert_literal "continuous coverage" "The primary execution subagent must continuously perform all non-interactive work for every installed Dev Cadence workflow."
assert_literal "return conditions" "Return control to the main session only for a user decision, a blocker that requires user-provided information, or task completion."
assert_literal "return shape" "Return only the current conclusion, complete user options, the effect of each option, risks, and repository-relative evidence paths."
assert_literal "asset draft boundary" "An Asset Workflow may keep an unconfirmed draft only in a system temporary or cache location clearly marked non-authoritative; do not modify the authoritative asset before its existing user confirmation."
assert_literal "Git authorization boundary" "Existing explicit user authorization remains required for merge, PR, push, discard, and branch deletion."
assert_literal "response recovery" "Return a user response to the original primary execution subagent when it remains available; otherwise designate a new primary execution subagent and restore from the existing file evidence."
assert_literal "capability fallback" "When the platform does not support internal subagents, the main session must execute the existing workflow directly."
```

Assert the two local guards contain the same ordinary-agent instruction:

```bash
for skill in discovery architecture-design; do
  assert_literal_in \
    "ordinary-subtask guard in $skill" \
    "If you are an ordinary subtask agent and are not explicitly designated as the primary execution subagent for the complete Dev Cadence request, do not execute this workflow." \
    "$ROOT_DIR/src/skills/$skill/SKILL.md"
done
```

- [x] **Step 2: Run the focused contract and verify RED.**

Run: `bash tests/routing-contract.sh`

Expected: `FAIL: missing primary delegation heading in src/skills/using-dev-cadence/SKILL.md`. The failure must be caused by the absent new protocol, not a shell error.

- [x] **Step 3: Implement the minimal entry-owned protocol and replace the two broad stop guards.**

Replace the top-level `<SUBAGENT-STOP>` block in `src/skills/using-dev-cadence/SKILL.md` with this role-specific block, then insert the `## Primary Execution Delegation` section before `## The Rule`:

```markdown
<ORDINARY-SUBAGENT-STOP>
If you are an ordinary subtask agent and are not explicitly designated as the primary execution subagent for the complete Dev Cadence request, do not execute this entry skill. Execute only the bounded task brief.
</ORDINARY-SUBAGENT-STOP>

## Primary Execution Delegation

Before reading a candidate workflow skill or exploring the repository, the user-facing main session must delegate the complete Dev Cadence request when the platform supports internal subagents.

A primary execution subagent is explicitly designated in the dispatch brief to execute the complete Dev Cadence request. It must read this entry skill, select or restore the workflow, and may dispatch ordinary bounded subtasks with the role boundary and any applicable Dev Cadence commit constraints.

An ordinary subtask agent must execute only its bounded brief; it must not select or restore a Dev Cadence workflow or recursively delegate the complete request.

The primary execution subagent must continuously perform all non-interactive work for every installed Dev Cadence workflow, including investigation, draft preparation, repository changes, implementation, tests, review, verification, stage records, and Git operations already authorized by the active workflow.

Return control to the main session only for a user decision, a blocker that requires user-provided information, or task completion. Return only the current conclusion, complete user options, the effect of each option, risks, and repository-relative evidence paths. Do not return process logs, diffs, or intermediate reasoning.

An Asset Workflow may keep an unconfirmed draft only in a system temporary or cache location clearly marked non-authoritative; do not modify the authoritative asset before its existing user confirmation. Do not promise that this temporary or cache content survives cleanup, machine changes, or runtime loss.

Existing user confirmation, Business Acceptance, Completion, and Git authorization rules remain in force. Existing explicit user authorization remains required for merge, PR, push, discard, and branch deletion.

Return a user response to the original primary execution subagent when it remains available; otherwise designate a new primary execution subagent and restore from the existing file evidence.

When the platform does not support internal subagents, the main session must execute the existing workflow directly.
```

In both `src/skills/discovery/SKILL.md` and `src/skills/architecture-design/SKILL.md`, replace the old `SUBAGENT-STOP` block with:

```markdown
<ORDINARY-SUBAGENT-STOP>
If you are an ordinary subtask agent and are not explicitly designated as the primary execution subagent for the complete Dev Cadence request, do not execute this workflow. Execute only the bounded task brief.
</ORDINARY-SUBAGENT-STOP>
```

Do not add the protocol to any other workflow: the entry owns it, and the existing Feature Dev, Bug Fix, and Refactor terminal-decision guards remain unchanged.

- [x] **Step 4: Run the focused contract and verify GREEN.**

Run: `bash tests/routing-contract.sh`

Expected: `Routing contract checks passed.`

- [x] **Step 5: Review the complete Task 1 diff and create its implementation progress commit.**

Run: `git diff --check && git diff -- tests/routing-contract.sh src/skills/using-dev-cadence/SKILL.md src/skills/discovery/SKILL.md src/skills/architecture-design/SKILL.md`

Expected: no whitespace errors; the diff adds exactly one centralized delegation protocol, two local guards, and contract coverage without changing unrelated routing examples or terminal gates.

The Task 1 implementer must write its SDD report with RED/GREEN evidence, changed files, self-review, and commit identity. Stage only these four files, invoke `.dev-cadence/skills/git-commit/SKILL.md`, and create `feat(workflow): delegate full task to primary subagent`. After the commit, the controller must create a review package from the task base to its new HEAD and dispatch a read-only SDD task reviewer. Critical or Important findings require a fresh bounded fix subagent, updated report evidence, and re-review before Task 1 is complete.

### Task 2: Package-Facing Behavior And Installation Checks

**Files:**
- Modify: `tests/install-contract.sh`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `version`

**Interfaces:**
- Consumes: Task 1's three source Skills and the existing installer replacement contract.
- Produces: a minor-versioned installed package whose English and Chinese usage documentation explains the supported delegation/fallback behavior and whose installation test proves fresh and replacement installs preserve the relevant Skills.

- [x] **Step 1: Add failing installation assertions before changing package-facing files.**

Immediately after the first-install file checks in `tests/install-contract.sh`, add this loop:

```bash
for skill in using-dev-cadence discovery architecture-design; do
  test -f "$TARGET_REPO/.dev-cadence/skills/$skill/SKILL.md" ||
    fail "first install did not create $skill skill"
  cmp -s \
    "$ROOT_DIR/src/skills/$skill/SKILL.md" \
    "$TARGET_REPO/.dev-cadence/skills/$skill/SKILL.md" ||
    fail "first installed $skill skill differs from source"
done
```

Immediately before `printf 'Install contract checks passed.\n'`, add the equivalent loop with `updated` failure labels so the replacement install is checked as well:

```bash
for skill in using-dev-cadence discovery architecture-design; do
  cmp -s \
    "$ROOT_DIR/src/skills/$skill/SKILL.md" \
    "$TARGET_REPO/.dev-cadence/skills/$skill/SKILL.md" ||
    fail "updated installed $skill skill differs from source"
done
```

- [x] **Step 2: Run the full installer contract to verify its baseline remains green.**

Run: `bash tests/install-contract.sh`

Expected: `Install contract checks passed.` The new checks exercise both a fresh temporary target and a target whose package is replaced. This test remains green because Task 1 already created the source Skills; it validates the package surface rather than introducing a duplicate behavior test.

- [x] **Step 3: Document the externally visible behavior and bump the package version.**

Add one paragraph after the `How It Works`/`工作方式` description in each README. Use these exact facts:

```markdown
When the platform supports internal subagents, Dev Cadence delegates the complete non-interactive workflow to a designated primary execution subagent before workflow-specific investigation begins. The main session returns only for user decisions, input-dependent blockers, and completion; it retains all existing confirmation and Git authorization gates. On platforms without internal subagents, Dev Cadence runs the same workflow directly in the main session.
```

```markdown
当平台支持内部子代理时，Dev Cadence 会在进入 workflow 专属调查前，把完整的非交互流程交给明确指定的主执行子代理。主会话只在用户决定、依赖用户输入的阻塞和任务完成时返回，并保留全部既有确认门和 Git 授权门禁；不支持内部子代理的平台仍由主会话直接执行同一 workflow。
```

Replace the sole contents of `version` with:

```text
0.27.0
```

- [x] **Step 4: Run the relevant package checks.**

Run: `bash tests/install-contract.sh && bash tests/package-contract.sh`

Expected: both commands report `passed`; package contract verifies every source Skill equals its generated `dist` counterpart after the build performed by the test suite.

- [x] **Step 5: Review Task 2 and create its implementation progress commit.**

Run: `git diff --check && git diff -- README.md README.zh-CN.md version tests/install-contract.sh`

Expected: no whitespace errors; documentation describes only supported behavior and fallback, `version` is `0.27.0`, and install coverage checks both installation modes.

The Task 2 implementer must write its SDD report with its focused test evidence, changed files, self-review, and commit identity. Stage only these four files, invoke `.dev-cadence/skills/git-commit/SKILL.md`, and create `feat(package): publish primary delegation protocol`. After the commit, the controller must create a review package from the Task 2 base to its new HEAD and dispatch a read-only SDD task reviewer; resolve every Critical or Important finding with a fresh fix subagent and re-review before Task 2 is complete.

### Task 3: Generated-Package Synchronization And Implementation Exit Checks

**Files:**
- Generated: `dist/.dev-cadence/skills/using-dev-cadence/SKILL.md`
- Generated: `dist/.dev-cadence/skills/discovery/SKILL.md`
- Generated: `dist/.dev-cadence/skills/architecture-design/SKILL.md`
- Generated: `.dev-cadence/skills/using-dev-cadence/SKILL.md`
- Generated: `.dev-cadence/skills/discovery/SKILL.md`
- Generated: `.dev-cadence/skills/architecture-design/SKILL.md`
- Create: `build/dev-cadence/feature-dev/s-042-primary-subagent-delegation/04-implementation-record.md`

**Interfaces:**
- Consumes: Tasks 1-2's source changes and the existing build/installer behavior.
- Produces: synchronized generated packages and evidence that the working deliverable is ready for code review and System Testing, not a Business Acceptance or Completion decision.

- [x] **Step 1: Build from source without editing generated files.**

Run: `bash scripts/build.sh`

Expected: the command completes successfully and regenerates `dist/.dev-cadence/` from `src/`.

- [x] **Step 2: Replace the current worktree's installed package.**

Run: `bash scripts/install.sh .`

Expected: `Installed Dev Cadence 0.27.0 to .../.dev-cadence`; the installer rebuilds and replaces only the current task worktree's installed package. Do not manually edit any path under `dist/.dev-cadence/` or `.dev-cadence/`.

- [x] **Step 2a: Review and commit the tracked dogfood installation synchronization.**

Run:

```bash
git diff --check -- .dev-cadence
git diff --name-only -- .dev-cadence
```

Expected: exactly these six generated files, with no manual edits:

```text
.dev-cadence/README.md
.dev-cadence/README.zh-CN.md
.dev-cadence/skills/architecture-design/SKILL.md
.dev-cadence/skills/discovery/SKILL.md
.dev-cadence/skills/using-dev-cadence/SKILL.md
.dev-cadence/version
```

Stage only those six paths, inspect the staged diff under `.dev-cadence/skills/git-commit/SKILL.md`, and create:

```text
chore(package): sync dogfood installation
```

The commit must contain only installation output generated by `bash scripts/install.sh .`; do not stage `dist/`, `build/`, or any unrelated local package change. A fresh SDD task reviewer must review this commit before Task 3 is complete.

- [x] **Step 3: Prove source, distribution, and installed package carry the same role protocol.**

Run:

```bash
for path in \
  src/skills/using-dev-cadence/SKILL.md \
  dist/.dev-cadence/skills/using-dev-cadence/SKILL.md \
  .dev-cadence/skills/using-dev-cadence/SKILL.md
do
  rg --no-ignore -F -n -- \
    "Before reading a candidate workflow skill or exploring the repository, the user-facing main session must delegate the complete Dev Cadence request when the platform supports internal subagents." \
    "$path"
done

for root in src/skills dist/.dev-cadence/skills .dev-cadence/skills; do
  for skill in discovery architecture-design; do
    rg --no-ignore -F -n -- \
      "If you are an ordinary subtask agent and are not explicitly designated as the primary execution subagent for the complete Dev Cadence request, do not execute this workflow." \
      "$root/$skill/SKILL.md"
  done
done
```

Expected: six guard matches plus three entry-protocol matches, all at the planned source, distribution, and installed-package paths.

- [x] **Step 4: Run all implementation exit checks.**

Run: `bash tests/routing-contract.sh && bash tests/install-contract.sh && bash scripts/check-whitespace.sh && bash scripts/check-all.sh`

Expected: every command exits `0`; the full suite includes package, generated distribution, installation, workflow symmetry, and confirmation-gate contracts.

- [x] **Step 5: Create implementation evidence and leave the workflow at Development Implementation exit, not acceptance.**

Create `04-implementation-record.md` with the implementation base SHA, completed SDD task reports and review-package evidence, changed source/test/document/version paths, generated-package synchronization evidence, exact command outcomes, and residual risk that actual dispatch remains platform-provided. Update the manifest to mark Development Implementation complete only after the code review obligations in the active Feature Dev workflow are satisfied. Do not mark System Testing, Business Acceptance, or Completion complete and do not merge, create/update a PR, push, discard, or delete a branch without later explicit user authorization.

## Completion Conditions For Development Implementation

- The source entry owns the complete role protocol and has no broad "all subagents stop" rule.
- Discovery and Architecture Design accept the designated primary execution subagent while rejecting ordinary subtask agents.
- The routing contract covers all ten S-042 acceptance boundaries: early dispatch, three roles, workflow coverage, return conditions, non-authoritative drafts, return payload, Git gates, recovery, fallback, and package synchronization.
- Package version is `0.27.0`; source, generated distribution, and the current installed package contain the same protocol.
- All commands listed in Task 3 pass and the implementation record contains reproducible evidence.
- The implementation is reviewed under the selected Development Implementation execution method before entering System Testing.

## Plan Self-Review

- **Spec coverage:** Task 1 implements and tests acceptance criteria 1-9 through the single entry protocol plus the two Asset Workflow guards. Tasks 2-3 cover criterion 10, source/distribution/installation synchronization, versioning, documentation, and the required generated-package verification. Existing workflow rules retain Business Acceptance, Completion, and Git authorization ownership.
- **Placeholder scan:** No deferred marker, unspecified test, or incomplete implementation instruction remains. Each code/test modification names the exact file, literal content, command, and expected result.
- **Consistency:** The `primary execution subagent`, `ordinary subtask agent`, `main session`, the entry heading, and every asserted literal use the same spelling across tasks. Task 3 verifies exactly the entry and two guard files changed by Tasks 1-2.
- **Design freshness input:** Card `docs/stories/S-042-dev-cadence-primary-subagent-delegation.md` remains Version `1`, Requirements and Technical Solution are confirmed, task branch is `codex/feature-s042-primary-subagent-delegation` at `bf650908ba2a5b60f137f5e2c6ca1b96b6152844`, and main is `07d41f6f8c94c68c250a7b396c4fc5a9704451f1`. The only newer main change reorders Backlog display sections and is outside this plan's source boundary; it does not invalidate the design.

## Confirmed Plan Correction

- `2026-07-20T10:32:08+08:00`：用户确认继续使用 `subagent-driven-development`。
- 删除三处只适用于 `executing-plans` 的 ledger 要求，统一使用 SDD implementer report、review package、逐任务独立审查和最终全分支审查作为提交审查证据。
- Task 1 保持其已完成的范围与提交 `6060caa387ca4b73baaaa1bce636e6dad743ac9f`，但因审查发现过时 `<SUBAGENT-STOP>` 名称而重新打开，必须通过新的 bounded fix subagent 和复审关闭。
- 此修正不改变确认范围、源文件列表、验收标准、版本、测试命令或生成包同步策略。

## Confirmed Plan Correction 2

- `2026-07-20T11:40:05+08:00`：用户确认将仓库跟踪的 dogfood `.dev-cadence/` 安装输出纳入 Task 3 的独立提交和审查。
- `dist/` 和运行记录仍保持未跟踪；仅同步 `bash scripts/install.sh .` 生成的六个 in-scope `.dev-cadence/` 文件。
- 子代理环境缺少 `rg` 是执行环境 PATH 差异，不改变项目代码或测试；主执行环境在新证据下使用同一已确认同步命令完成未执行的检查和退出套件。

## Stage Status

✅ `confirmed`。用户于 `2026-07-20T10:09:35+08:00` 确认计划并选择子代理驱动实施，并于 `2026-07-20T10:32:08+08:00` 确认 SDD 证据修正、于 `2026-07-20T11:40:05+08:00` 确认 dogfood 安装包同步修正；三个任务均已完成实现、独立审查和所需验证。
