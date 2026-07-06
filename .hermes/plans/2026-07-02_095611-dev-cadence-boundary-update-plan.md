# Dev Cadence 边界与契约更新计划

> 计划文件，只描述后续修改步骤；不代表已修改 runtime/docs。

**Goal:** 修正 Dev Cadence 当前 docs / references / templates / skills / checks 之间的职责边界漂移，使四角色架构、code-review feedback 边界、artifact/Harness/gate ownership 和打包契约一致。

**Scope:** 当前只规划，不执行修改。后续实施应按阶段小步提交，每阶段先改最小闭环并跑对应检查。

---

## 当前问题总览

P0 必须先修：
1. `cadence-code-review` 把有效 code-review finding 的修复 ownership 路由出自身，和“code review feedback handling 留在 code-review path”冲突。
2. 多个 concrete Skills handoff 仍要求返回 `gate status`，暗示行为 Skill 拥有 gate 状态。
3. `cadence-clarify` 有 artifact authoring carveout，给 concrete Skill 留下 persistent write 口子。
4. `scripts/check-discipline-routes.mjs` 目前没有防止上述问题，部分检查还固化了旧边界。

P1 runtime contract 一致性：
1. `references/agent-blueprints.md` 的 Worker handoff 绕过 Supervisor。
2. `references/workflows.md` 的 phase/state 名称和 `references/supervisor-state-machine.md` 不一致。
3. `references/harness.md` 与 `templates/runs/execution-report.md` schema 漂移。
4. `references/quality-gates.md` 与 `templates/spec/*` gate sections 不一致。
5. `references/spec-templates.md` 有 `imple...ed` 字段 typo。

P2 docs 信息架构清理：
1. `docs/artifacts/README.md` 有 stale anchor。
2. `references/principles.md` 把 Gate 写得像架构角色。
3. `docs/roles/**` / `docs/artifacts/**` / `docs/runs/**` 的“写入者” wording 容易混淆 semantic producer 与 persistent recorder。
4. `docs/backlog.md` 陈旧。
5. release workflow placeholder 未在上层导航标注。

P3 packaging hardening：
1. 本地 `dist/target-repo` 曾出现 stale runtime；重新生成前不能作为事实源。
2. target bundle scripts 复制边界偏宽，需要 allowlist / denylist 或测试保护。

---

## Phase 0 — 建立安全基线

### Task 0.1: 确认工作树与当前检查状态

**Objective:** 确认后续修改不是叠在未知变更上。

**Files:** 无修改。

**Commands:**
- `git status --short`
- `node scripts/check-discipline-routes.mjs .`
- `bash tests/test-current-contract-terms.sh`

**Done when:** 当前 dirty files 清楚；现有检查结果已记录。

---

## Phase 1 — 修正 P0 行为边界

### Task 1.1: 修正 `cadence-code-review` ownership wording

**Objective:** 让 code-review feedback handling 留在 `cadence-code-review`，只把非 code-review feedback 交回 Supervisor 分类。

**Modify:**
- `skills/cadence-code-review/SKILL.md`
- `references/review-discipline.md`
- `scripts/check-discipline-routes.mjs`

**Required changes:**
- 删除/改写“valid finding requiring production/test changes -> return to `using-dev-cadence` so Supervisor routes to `cadence-tdd` or `cadence-executing-plans`”类 wording。
- 改成：有效 code-review finding 由 `cadence-code-review` 管理处理闭环；修复过程中必须满足相应 implementation/test evidence discipline，但不转移 feedback ownership。
- 保留：非 code-review feedback / requested changes 才返回 Supervisor 按 changed object 分类。

**Regression expectation:**
- checker 应禁止把有效 code-review finding 泛化路由出 `cadence-code-review`。
- checker 应继续允许 non-code feedback 返回 Supervisor。

**Validate:**
- `node scripts/check-discipline-routes.mjs .`
- `bash tests/test-current-contract-terms.sh`

---

### Task 1.2: 统一 concrete Skill handoff，不再返回 `gate status`

**Objective:** concrete behavior Skills 只返回 gate-relevant observations / evidence fields，不拥有 gate status。

**Modify:**
- `references/skill-layout.md`
- `skills/cadence-clarify/SKILL.md`
- `skills/cadence-executing-plans/SKILL.md`
- `skills/cadence-tdd/SKILL.md`
- `skills/cadence-debug/SKILL.md`
- `skills/cadence-request-code-review/SKILL.md`
- `skills/cadence-code-review/SKILL.md`
- `skills/cadence-research/SKILL.md`
- `skills/cadence-verify/SKILL.md` if it uses the generic handoff phrase
- `scripts/check-discipline-routes.mjs`

**Required wording pattern:**
- evidence produced
- unresolved blockers
- gate-relevant observations
- skipped checks / residual risk
- recommended next state

**Forbidden for concrete Skills:**
- “return gate status”
- “write/update gate status”
- wording implying the Skill passes/fails gates itself

**Validate:**
- `node scripts/check-discipline-routes.mjs .`
- targeted grep for `gate status` in concrete Skill handoff sections.

---

### Task 1.3: Remove `cadence-clarify` artifact authoring carveout

**Objective:** 防止 concrete Skill 被描述成 persistent artifact writer。

**Modify:**
- `skills/cadence-clarify/SKILL.md`
- `scripts/check-discipline-routes.mjs`

**Required changes:**
- 删除/收窄 `unless this Skill is explicitly being used as the artifact authoring action`。
- 改成：`cadence-clarify` returns artifact-ready requirements/design content for Supervisor/Harness recording when persistent artifacts are being used。
- 不引入新的 “artifact-authoring path” 作为隐含 owner；如果未来需要专门的 artifact authoring path，应先单独定义它和 Supervisor/Harness 的关系。

**Validate:**
- checker 禁止 concrete Skill 出现 artifact authoring carveout。
- `node scripts/check-discipline-routes.mjs .`

---

## Phase 2 — Runtime references/templates 契约对齐

### Task 2.1: Fix Worker handoff wording in `agent-blueprints`

**Objective:** Worker 不直接决定下游角色；Supervisor 决定下一步。

**Modify:**
- `references/agent-blueprints.md`

**Required changes:**
- Planner / Architect / Developer / Tester / Reviewer / Researcher handoff sections 改为返回 Supervisor/Harness。
- 保留 recommended next state，但不写“handoff directly to Tester/Developer/Human”。

**Validate:**
- 搜索 `Hand off .* to (Architect|Developer|Tester|Reviewer|Human)`，确认无直接路由 wording。

---

### Task 2.2: Align workflow phase labels with Supervisor state machine

**Objective:** 避免 workflow 文档把 phase label 伪装成 formal state。

**Modify:**
- `references/workflows.md`
- 可能同步 `docs/workflows/*.md`

**Required changes:**
- 对 `research`、`triage`、`emergency approval`、`smoke test`、`post-incident backfill` 标注为 workflow phase labels。
- 映射到 formal states：如 research spike 可映射到 requirements/design/acceptance 的特殊路径；incident triage 可映射到 intake/classify/requirements 或 blocked/Human Gate。
- 不建议新增一堆 formal states，除非后续明确要扩展 state machine。

**Validate:**
- 人工检查 workflow sequence 不再与 state machine 冲突。

---

### Task 2.3: Align Harness execution-report schema

**Objective:** reference schema 与 template 字段一致，避免 run evidence 缺 scope reconciliation 信息。

**Modify:**
- `references/harness.md`
- possibly `references/spec-templates.md`

**Required changes:**
- 将 `templates/runs/execution-report.md` 的 scope/baseline 字段补进 `references/harness.md`，或明确 template extends minimum schema。
- 推荐直接补齐关键字段：planned_files, planned_artifact_files, untracked_files, created_artifact_files, unplanned_changed_files, deleted_files, added_components, pre_implementation_status_path, implementation_authorized, post_hoc_backfill, scope_reconciliation_status。

**Validate:**
- schema comparison script / manual check。
- `node scripts/check-discipline-routes.mjs .`

---

### Task 2.4: Normalize gate record templates

**Objective:** G1-G6 gate sections 与 shared Quality Gate contract 一致。

**Modify:**
- `templates/spec/01-requirements.md`
- `templates/spec/02-design.md`
- `templates/spec/03-tasks.md`
- `templates/spec/06-test-report.md`
- `templates/spec/07-review-report.md`
- `templates/spec/08-acceptance.md`
- `references/quality-gates.md` if needed
- `references/spec-templates.md` if needed

**Required changes:**
- G1/G2/G3 不再只有空 heading，应有 YAML gate block。
- G4/G5/G6 保留 per-gate fields，同时包含 shared fields或明确 extension rule。

**Validate:**
- First confirm script usage with `node scripts/check-spec-artifacts.mjs --help` or by reading `scripts/check-spec-artifacts.mjs`; do not assume it accepts `templates` as an input directory.
- If the script supports template validation, run the targeted template check.
- If it only validates initialized task artifacts, use a temporary generated fixture or the existing dry-run path, then run the relevant artifact/gate checks.
- `bash tests/run-all.sh` after phase completion.

---

### Task 2.5: Fix `references/spec-templates.md` typo and baseline wording

**Objective:** 修 contract typo，并对齐 implementation authorization 条件。

**Modify:**
- `references/spec-templates.md`

**Required changes:**
- `imple...ed` -> `implementation_authorized`。
- Pre-Implementation Baseline section 加入 latest request reconciled 和 Requirements Readiness Check complete。

**Validate:**
- grep 确认无 `imple...ed`。
- `node scripts/check-discipline-routes.mjs .`

---

## Phase 3 — Docs 信息架构清理

### Task 3.1: Fix stale anchor in artifacts README

**Modify:**
- `docs/artifacts/README.md`

**Change:**
- `../architecture.md#事实源优先级` 改到 `../../references/principles.md#source-priority`，或保留中文说明但链接到实际存在 heading。

**Validate:**
- markdown relative link + anchor check。

---

### Task 3.2: Reword Gate mechanism boundary in principles

**Modify:**
- `references/principles.md`

**Change:**
- 不把 Quality Gate / Human Gate 写成 architecture roles。
- 表达为 gate mechanisms：Supervisor applies Quality Gate checks; Human owns Human Gate decisions。

**Validate:**
- 人工对照 `docs/architecture.md` 四角色模型。

---

### Task 3.3: Clarify producer vs recorder wording in role/artifact/run docs

**Modify likely:**
- `docs/roles/agents/*.md`
- `docs/artifacts/*.md`
- `docs/runs/*.md`

**Change:**
- Worker “写 artifact” -> “产出 artifact-ready content / evidence”。
- Supervisor/Harness “记录/协调写入/capture evidence”。
- Human decision owner 与 recorder 分开说明。

**Validate:**
- 搜索 `写入者`、`写 `、`记录`，抽查语义。

---

### Task 3.4: Update or archive stale backlog

**Modify:**
- `docs/backlog.md`

**Change:**
- 删除已完成/过期项。
- 改成当前真实 backlog：code-review boundary, gate-status wording, schema alignment, packaging hardening。

**Validate:**
- 不再与 `docs/skill-parity-improvement-plan.md` 冲突。

---

### Task 3.5: Mark release workflow as placeholder in workflow index

**Modify:**
- `docs/workflows/README.md`
- possibly `docs/workflows/07-release.md`

**Change:**
- 明确 release 当前只记录 readiness/decision/evidence，不执行发布自动化。

---

## Phase 4 — Packaging hardening

### Task 4.1: Regenerate and inspect target runtime bundle

**Objective:** 确认生成物不再包含 stale skill/resource layout。

**Commands:**
- `node scripts/package-target-repo-bundle.mjs --clean`
- inspect `dist/target-repo/.dev-cadence/skills/`

**Expected:**
- includes `cadence-code-review`
- does not include `cadence-review`
- includes required Skill-local resources
- does not move Skill-local prompt into shared templates unless intentionally designed

---

### Task 4.2: Add package boundary checks for target runtime

**Modify likely:**
- `tests/test-target-repo-bundle.sh`
- `scripts/check-skill-package.mjs` or package script tests if needed

**Checks to add:**
- target runtime does not contain stale `cadence-review`.
- target runtime contains expected skill set.
- target runtime excludes `references/source-maintenance/**`.
- source/package-only scripts are either allowlisted or explicitly denied.

---

## Final validation sequence

Run after all planned changes:

```bash
node scripts/check-discipline-routes.mjs .
node scripts/check-skill-package.mjs .
bash tests/test-current-contract-terms.sh
bash tests/test-target-repo-bundle.sh
bash tests/run-all.sh
git diff --check
```

Manual review:
- Verify code-review feedback handling stays in `cadence-code-review`.
- Verify concrete Skills return handoff fields, not gate status.
- Verify Worker handoffs return to Supervisor/Harness.
- Verify Gate/Harness schemas have one clear source of truth.
- Verify docs remain concise and do not reintroduce architecture nodes beyond the four roles.

---

## Suggested commit grouping

1. `docs/runtime: fix code-review and gate handoff boundaries`
2. `docs(runtime): align worker handoff and harness schemas`
3. `docs: clean dev cadence navigation and stale backlog`
4. `test: harden target runtime package boundary`

Do not mix Phase 4 generated dist changes into earlier conceptual boundary commits unless the repository intentionally tracks generated runtime artifacts.
