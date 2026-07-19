# B-010 修复计划

- Workflow: `bug-fix`
- Work Item: [B-010 Generated Records Do Not Enforce Navigational Document Links](../../../../docs/bugs/B-010-generated-record-document-links-not-enforced.md)
- Diagnosis: `build/dev-cadence/bug-fix/b-010-generated-record-document-links-not-enforced/01-problem-diagnosis-record.md`
- Repair Solution: `build/dev-cadence/bug-fix/b-010-generated-record-document-links-not-enforced/02-repair-solution.md`
- Confirmed solution: 模板修正、对称性契约与双表示 fixture（方案 A）
- Plan status: 🔄 `in_progress`
- Implementation worktree: `.worktrees/b010-generated-record-links`
- Implementation branch: `codex/b010-generated-record-links`
- Implementation base: `e96d344`

## Pre-Implementation Design Freshness Gate

- Card identity: `docs/bugs/B-010-generated-record-document-links-not-enforced.md`, Version `1`, Status `In Progress`
- Confirmed inputs: `01-problem-diagnosis-record.md`, `02-repair-solution.md`, this plan
- Current branch and commit: `codex/b010-generated-record-links` at `f03895b`
- Dependency/config state: `.dev-cadence.yaml` propagated and verified; baseline `bash scripts/check-all.sh` passed
- Conclusion: ✅ `confirmed`; diagnosis, solution, scope, acceptance criteria and task split remain valid
- Evidence summary: no material repository changes since plan confirmation; worktree is clean before implementation

## Task Overview

| Task | Goal | Files | Verification |
| --- | --- | --- | --- |
| Task 1: RED 模板形态契约 | 让三套裸路径模板在基线下失败 | `tests/workflow-symmetry.sh` | focused symmetry test fails |
| Task 2: 双表示模板与 fixture | 写入导航链接并保留精确审计路径，验证 validator 兼容 | `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, `src/skills/refactor/SKILL.md`, `tests/delivery-record-contract.sh` | focused tests pass |
| Task 3: 分发与全量回归 | 同步 source/dist 并覆盖安装与交付记录验证 | `dist/.dev-cadence/**`, `version` | build, package/install, `scripts/check-all.sh` |

## Detailed Tasks

### Task 1: RED 模板形态契约

1. 在 `tests/workflow-symmetry.sh` 为三套受治理 `Report` 行增加精确断言：同一行必须包含相对 `(04-code-review-report.md)` 链接和 workflow-specific 的反引号完整仓库路径。
2. 断言允许任意非空显示文本，不锁定语言；裸路径、链接-only 或错误 workflow 路径都必须失败。
3. 运行 `bash tests/workflow-symmetry.sh`，预期 RED：当前三套模板均为裸路径。
4. 记录失败输出作为 RED 证据。

### Task 2: 双表示模板与 fixture

1. 只修改三个 workflow source 模板的 `Code Review Evidence` `Report` 行，使用 source-relative Markdown link，并在同一行保留精确仓库相对路径。
2. 更新 `tests/delivery-record-contract.sh` 的有效 fixture 为链接 + 精确路径双表示，保留缺失 artifact、checkpoint tree、SHA、Changed Files 等负例。
3. 运行 `bash tests/workflow-symmetry.sh`、`bash tests/delivery-record-contract.sh` 和 `bash tests/document-conventions-contract.sh`，预期 GREEN。
4. 保持 `validate-delivery-record.sh` 不变，确认其仍从首个反引号提取审计路径。

### Task 3: 分发与全量回归

1. 运行 `bash scripts/build.sh`，由构建脚本同步 `dist/.dev-cadence`，不直接编辑 dist。
2. 运行 `bash tests/package-contract.sh`、`bash tests/install-contract.sh`、`bash scripts/check-whitespace.sh` 和 `bash scripts/check-all.sh`。
3. 用 `rg --no-ignore` 确认 source/dist 三处模板均为 link + exact path，旧 plain-only 整行零命中。
4. 检查 diff 不包含历史 records、Discovery 或共享 validator 规则变化。

## Completion Conditions

- RED 证据已记录，三套模板和双表示 fixture 的 focused/full tests 均通过。
- 审计路径、checkpoint、Changed Files 和 terminal validation 语义未改变。
- source、dist、安装验证和根版本（如行为变更需要）同步完成。
- 变更范围仅限确认的 B-010 修复边界，完成 self-review 后提交实施记录和 review evidence。

## Self-Review

- 检查每个 Report 行的链接目标相对当前 record 且路径精确可审计。
- 检查测试没有锁定本地化显示文本或将所有路径机械转换为链接。
- 检查 validator 现有负例和历史 records 未被批量改写。
