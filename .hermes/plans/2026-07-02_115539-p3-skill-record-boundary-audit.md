# P3 Skill Record Boundary Audit Plan

**Goal:** 横向复核所有入口 Skill（包括 `cadence-plan`）的 artifact / Harness / gate / record wording，确保 Skill 可以按 Supervisor/Harness 指定的 artifact targets 产出或写入文档，但不自选记录位置、不创建 workflow records、不直接拥有 Harness evidence 记录或 gate status 写入职责。

**Architecture:** 以职责边界作为基准：Supervisor/Harness 提供 artifact targets、模板/字段要求、allowed write scope 和后续 gate/evidence 检查需求；Skill 按自己的行为纪律产出内容，并可在明确授权时写入指定文档；Supervisor/Harness/checker 负责记录完整性和 Gate 状态判断。`cadence-plan` 不再作为免检基准，只作为对照样式之一，也必须检查同样的存储/记录边界。先做只读审计和逐 Skill 分类，再做最小 wording 收窄，最后用 `scripts/check-discipline-routes.mjs` 固化禁止回归的 contract。

**Tech Stack:** Markdown Skill 文档、Node.js contract checker、现有 shell regression：`bash tests/run-all.sh`。

## Global Constraints

- `cadence-plan` 也纳入审计；不把任何具体行为 Skill 作为免检基准。
- 审计范围固定为：
  - `skills/using-dev-cadence/SKILL.md`
  - `skills/cadence-clarify/SKILL.md`
  - `skills/cadence-plan/SKILL.md`
  - `skills/cadence-executing-plans/SKILL.md`
  - `skills/cadence-subagent-development/SKILL.md`
  - `skills/cadence-dispatch-parallel/SKILL.md`
  - `skills/cadence-tdd/SKILL.md`
  - `skills/cadence-debug/SKILL.md`
  - `skills/cadence-request-code-review/SKILL.md`
  - `skills/cadence-code-review/SKILL.md`
  - `skills/cadence-verify/SKILL.md`
  - `skills/cadence-research/SKILL.md`
  - `skills/cadence-sync/SKILL.md`
- 分类只用三类：`OK` / `需要收窄` / `允许例外`。
- `允许例外` 必须说明边界：例如 `using-dev-cadence` 作为 Supervisor 可以谈 gate status；`cadence-sync` 可以在 repo contract scope 内写 contract files；`cadence-verify` 可以运行检查并返回 test-report / acceptance-summary fields，但不能补写原始 Worker/Tester/Reviewer/Human evidence 或直接更新 persistent records。
- 具体行为 Skill 的目标 wording：`return`、`produce artifact-ready content`、`write/update specified artifact targets when Supervisor/Harness context authorizes it`、`provide fields for Supervisor/Harness recording`、`gate-relevant observations`。
- 避免 wording：`choose artifact paths`、`create workflow records`、`write/update persistent records`（无明确 target/authorization 时）、`record Harness evidence`、`record integration evidence`、`own gate status`、`mark gates complete`、泛化的 `gate status` handoff。
- 不做大规模重写；每个 Skill 只改和责任边界有关的句子。

## Revised Artifact-Writing Boundary

本轮讨论确认：不能把“Skill 不拥有持久记录职责”误写成“Skill 永远不能写文档”。更准确的边界是：

- Harness/Supervisor 告诉 Skill 本步骤需要哪些 artifacts、目标路径、模板/字段要求和 allowed write scope。
- Skill 可以把自己的产出写成文档，或返回完整 artifact-ready content；这两者都必须符合 Harness 指定的 artifact contract。
- Skill 不自选 artifact path，不创建新的 workflow record，不把写入文档等同于 Gate 通过或 Human acceptance。
- Gate status 和记录完整性由 Supervisor/Harness/checker 根据 artifacts 和 evidence 判断。

审计时要同时检查两类错误：

1. 过宽：Skill 自己决定存哪里、记录什么 Gate/Harness evidence、或标记 Gate/acceptance。
2. 过窄：把合理的“按 Supervisor/Harness 指定目标写 artifact 文档”也禁止掉，导致 handoff 到落盘之间容易丢数据。

## Initial Search Seeds

初始只读搜索已暴露这些需要复核的候选 wording，执行时必须逐文件确认上下文后再判断：

- `skills/cadence-clarify/SKILL.md`: `gate status` handoff wording。
- `skills/cadence-plan/SKILL.md`: 检查 plan content / `03-tasks.md` / `04-test-plan.md` wording 是否只表达 artifact-ready content 或 authorized artifact writes，不能自选 workflow records 或拥有 planning Gate 状态。
- `skills/cadence-executing-plans/SKILL.md`: `for Supervisor/Harness recording` 与 `gate status` handoff wording。
- `skills/cadence-subagent-development/SKILL.md`: 已有禁止写记录/mark gates 的 wording，重点确认是否为 `OK`。
- `skills/cadence-dispatch-parallel/SKILL.md`: `Return integration evidence ... for Supervisor/Harness recording`。
- `skills/cadence-tdd/SKILL.md`: `Supervisor/Harness recording`、`record that tests stayed green`、`gate status` handoff wording。
- `skills/cadence-debug/SKILL.md`: `gate status` handoff wording。
- `skills/cadence-request-code-review/SKILL.md`: `Supervisor/Harness recording`、`gate status` handoff wording。
- `skills/cadence-code-review/SKILL.md`: `gate status` handoff wording。
- `skills/cadence-verify/SKILL.md`: 允许运行 gate/report checks，但 `gate status` handoff 和 direct record boundary 必须明确。
- `skills/cadence-research/SKILL.md`: 已有 `Do not directly write...` 例外句，需判断是否过宽。
- `skills/cadence-sync/SKILL.md`: repo contract 写入可能是允许例外，需防止普通 artifact/gate 责任漂移。
- `skills/using-dev-cadence/SKILL.md`: Supervisor 例外，重点确认 concrete Skill 模板/路由 wording 没有把写记录责任下放。

### Task 1: 建立审计清单和基准

**Goal:** 明确基准 wording、目标文件和输出表格格式。

**Files:**
- Read: all target `skills/*/SKILL.md` listed above, including `skills/cadence-plan/SKILL.md`
- Read: `scripts/check-discipline-routes.mjs`
- Modify: none
- Test: not_applicable: read-only audit setup

**Interfaces:**
- Consumes: 当前各 Skill 的 handoff/artifact wording、现有 checker 的 `checkConcreteSkillResponsibilityBoundary()`。
- Produces: 本次审计的分类表草稿和替换规则清单。

**Acceptance Mapping:**
- Covers: P3 基准确认、范围确认、产出格式确认。

**Steps:**
- [ ] 读取 `skills/cadence-plan/SKILL.md`，将其纳入审计而不是作为免检基准；摘出其中 `Produce ... content`、`easy to place into ...`、`return ... handoff` 等 wording 供对照。
- [ ] 读取 13 个目标 Skill，按文件记录所有包含 `artifact`、`Harness`、`gate`、`record`、`persistent`、`handoff`、`return`、`write`、`update` 的句子。
- [ ] 读取 `scripts/check-discipline-routes.mjs` 中现有 forbidden patterns，记录当前已防护和未防护的边界。
- [ ] 建立输出表列：`Skill`、`分类`、`理由`、`需替换 wording`、`建议 wording`、`是否需要 checker 回归`。

**Expected Evidence:** 审计表草稿覆盖 13 个目标 Skill；没有跳过 `cadence-plan`、`using-dev-cadence`、`cadence-verify`、`cadence-sync` 这些容易被误判的角色。

### Task 2: 逐 Skill 分类并列出 wording 替换

**Goal:** 给每个目标 Skill 标记 `OK` / `需要收窄` / `允许例外`，并列出具体 wording 替换。

**Files:**
- Read: target Skill files
- Modify: none in this task
- Test: not_applicable: classification only

**Interfaces:**
- Consumes: Task 1 的句子摘录。
- Produces: 最终审计表，作为后续补丁依据。

**Acceptance Mapping:**
- Covers: P3 产出要求 “逐个 Skill 标记并列出具体 wording”。

**Classification Rules:**
- `OK`: 只说返回 handoff、artifact-ready content、evidence fields、gate-relevant observations，或在 Supervisor/Harness 明确提供 artifact targets 和授权时写入指定文档；没有把自选路径、记录创建、Harness evidence、Gate 状态决定归给 Skill。
- `需要收窄`: Skill 出现直接或含混的 `record`、无授权 `write/update persistent records`、自选 artifact path、创建 workflow records、`Harness evidence recording`、`gate status` handoff、`mark gates complete` 等 ownership wording；或过度禁止 Skill 按 Harness 指定目标写文档，造成 handoff 丢失风险。
- `允许例外`: Skill 角色本身包含 Supervisor/repo-contract/verification audit 职责，但仍必须写清边界和不能替代的职责。

**Steps:**
- [ ] 标记 `using-dev-cadence`：预计为 `允许例外`，因为它是 Supervisor entrypoint；确认它没有要求 concrete Skill 直接写 persistent records。
- [ ] 标记 `cadence-clarify`：重点检查 `gate status` handoff 是否需改成 `gate-relevant observations` 或 `required Human decisions`。
- [ ] 标记 `cadence-plan`：重点检查 plan content、`03-tasks.md`、`04-test-plan.md`、review checkpoint wording；允许它按 Supervisor/Harness 指定目标写计划文档，但不能自选 workflow records、标记 G3/Gate 通过、或把写入计划等同于 planning acceptance。
- [ ] 标记 `cadence-executing-plans`：重点检查 `for Supervisor/Harness recording` 和 `gate status` handoff 是否需收窄为返回 fields。
- [ ] 标记 `cadence-subagent-development`：重点确认禁止写记录/mark gates 的 wording 是否足够，若 handoff 仍含 `gate status` 则收窄。
- [ ] 标记 `cadence-dispatch-parallel`：重点检查 `Return integration evidence ... for Supervisor/Harness recording` 是否需改成 `Return integration-evidence fields ...`。
- [ ] 标记 `cadence-tdd`：重点检查 `record that tests stayed green`、`Supervisor/Harness recording`、`gate status`。
- [ ] 标记 `cadence-debug`：重点检查 `gate status` handoff。
- [ ] 标记 `cadence-request-code-review`：重点检查 review report handoff 和 `gate status` wording。
- [ ] 标记 `cadence-code-review`：重点检查 code-review-only边界下是否仍含 `gate status` ownership wording。
- [ ] 标记 `cadence-verify`：预计为 `允许例外/需要精修`，确认它只返回 test-report 和 acceptance-summary fields，不直接写/update persistent records。
- [ ] 标记 `cadence-research`：确认 artifact-ready content 例外是否因 “unless Supervisor explicitly selected artifact authoring action” 过宽；如过宽改为更明确的 handoff wording。
- [ ] 标记 `cadence-sync`：预计为 `允许例外`，限定在 repo contract files，不能泛化到 artifact/gate/evidence records。

**Expected Evidence:** 一张完整表格，13/13 个 Skill 有分类、理由和必要替换项；所有 `需要收窄` 都有 exact old wording 与 replacement wording。

### Task 3: 应用最小 Skill wording 收窄

**Goal:** 只修改审计确认需要收窄的句子，保持 Skill 行为职责不漂移。

**Files:**
- Modify: only target `skills/*/SKILL.md` files classified as `需要收窄` or exception boundary too broad
- Test: not_applicable: Markdown wording patch, covered by later checker/tests

**Interfaces:**
- Consumes: Task 2 的替换清单。
- Produces: Skill wording patch。

**Preferred Replacement Patterns:**
- `with evidence produced, unresolved blockers, gate status, and recommended next state`
  -> `with evidence fields produced, unresolved blockers, gate-relevant observations, and recommended next state`
- `for Supervisor/Harness recording`
  -> `as fields for Supervisor/Harness recording when persistent artifacts are being used`
- `record integration evidence`
  -> `return integration-evidence fields`
- `record that tests stayed green`
  -> `return evidence that tests stayed green`
- `gate status`
  -> `gate-relevant observations` unless the Skill is `using-dev-cadence` or another explicitly justified exception.
- `Leave concrete artifact writes to the Supervisor/Harness path.`
  -> `Write or update specified artifact targets only when Supervisor/Harness context provides the paths and authorizes this Skill as the artifact-writing action; otherwise return complete artifact-ready content.`
- Any wording implying Skill-created workflow records
  -> `Use the Supervisor/Harness-provided task_id, run_id, artifact targets, and allowed write scope.`

**Steps:**
- [ ] Patch one Skill at a time using exact old/new wording.
- [ ] Preserve existing headings, examples, and role boundaries.
- [ ] Do not introduce new artifact-writing responsibilities while trying to clarify wording.
- [ ] After patching each file, search that file for `record|write|update|persistent|Harness evidence|gate status|mark gates complete` and verify remaining matches are intended.

**Expected Evidence:** `git diff -- skills/...` shows only responsibility-boundary wording edits; no unrelated rewrites.

### Task 4: Strengthen regression checker

**Goal:** Update `scripts/check-discipline-routes.mjs` only if the audit finds uncovered drift patterns.

**Files:**
- Modify: `scripts/check-discipline-routes.mjs`
- Test: `node scripts/check-discipline-routes.mjs .`

**Interfaces:**
- Consumes: Task 2 list of phrases not currently blocked by `checkConcreteSkillResponsibilityBoundary()`.
- Produces: Contract checks that prevent concrete Skill wording from regressing.

**Checker Requirements:**
- Keep `using-dev-cadence`, `cadence-verify`, and `cadence-sync` out of generic concrete-behavior forbidden checks when their exception is intentional; keep `cadence-plan` inside the responsibility-boundary audit unless a narrower exception is explicitly justified.
- Add explicit checks for broad handoff phrase regressions in concrete Skills, especially generic `gate status` where the correct phrase is `gate-relevant observations`.
- Add checks that distinguish authorized artifact writes from ownership drift: concrete Skills may write/update specified artifact targets only when Supervisor/Harness context provides the target paths and authorization; they must not choose artifact paths, create workflow records, or mark gates complete.
- Consider adding targeted required phrases for exception Skills:
  - `cadence-verify`: must include “Return test-report and acceptance-summary fields...” and “Do not directly write or update persistent records...”
  - `cadence-sync`: must keep writes limited to repository contract files.
  - `using-dev-cadence`: may own routing/gate classification but must not instruct concrete Skills to write persistent records.

**Steps:**
- [ ] Compare current forbidden patterns against Task 2 uncovered phrases.
- [ ] Add regex checks for direct persistent-record ownership, Harness evidence recording, integration evidence recording, and concrete Skill `gate status` handoff drift.
- [ ] If adding new forbidden phrases, add failure messages that explain “return handoff fields, do not own Supervisor/Harness artifact work”。
- [ ] Keep existing contract checks stable; do not loosen unrelated route checks.

**Expected Evidence:** Checker fails on forbidden concrete Skill wording in an injected-temp mutation test, and passes on the current corrected repo.

### Task 5: Run targeted and full validation

**Goal:** Prove wording and checker changes satisfy existing repo contracts.

**Files:**
- Read/execute only unless failures require returning to Task 3 or 4

**Interfaces:**
- Consumes: patched Skill files and checker.
- Produces: verification output for handoff.

**Steps:**
- [ ] Run targeted route check:
  - Command: `node scripts/check-discipline-routes.mjs .`
  - Expected: `OK discipline routes verified for .`
- [ ] Run package check:
  - Command: `node scripts/check-skill-package.mjs .`
  - Expected: pass with no missing Skill/package resources.
- [ ] Run whitespace diff check:
  - Command: `git diff --check`
  - Expected: no whitespace errors.
- [ ] Run full regression:
  - Command: `bash tests/run-all.sh`
  - Expected: all regression checks pass.
- [ ] If `scripts/check-discipline-routes.mjs` changed, run an ad-hoc mutation verification using a temp copy or temp injected fixture to confirm a forbidden phrase is caught; label it as ad-hoc verification, not suite green.

**Expected Evidence:** Targeted checks, full regression, and any ad-hoc mutation test outputs are included in final handoff.

### Task 6: Final handoff

**Goal:** Return a concise, reviewable summary of the audit and changes.

**Files:**
- Read: `git diff -- skills scripts`
- Modify: none

**Interfaces:**
- Consumes: audit table, patches, validation output.
- Produces: final Supervisor/Human handoff.

**Final Handoff Must Include:**
- 13-row Skill classification table: `OK` / `需要收窄` / `允许例外`。
- Exact wording changes grouped by Skill。
- Checker changes, if any, with the new regression boundary explained。
- Commands run and results。
- Any skipped checks and residual risk。
- Explicit note that concrete Skills may produce or write specified artifact documents only under Supervisor/Harness-provided targets and authorization; they do not choose record paths, create workflow records, record Harness evidence, or own gate status writes。

**Expected Evidence:** Human can review the table and diff without reconstructing the whole audit from chat history。
