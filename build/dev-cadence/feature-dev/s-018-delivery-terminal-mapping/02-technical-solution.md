# S-018 Delivery 终态映射与 Manual Recovery - 技术方案

## 已确认需求来源

- Requirements Confirmation：[S-018 需求确认](01-requirements.md) (`build/dev-cadence/feature-dev/s-018-delivery-terminal-mapping/01-requirements.md`)
- Requirements SHA-256：`4348982eabe9414956c9edb92cc62926a0b30eef07b4f3fd785c50fd3470c16e`
- 工作项：[S-018 Delivery 终态映射与 Manual Recovery](../../../../docs/stories/S-018-business-acceptance-terminal-mapping.md) (`docs/stories/S-018-business-acceptance-terminal-mapping.md`)，Version `4`，Status `In Progress`。

## Codebase Exploration Findings

### 业务验收与 Completion 规则

- `src/workflows/feature-dev/SKILL.md:768-865`、`src/workflows/bug-fix/SKILL.md:701-814` 与 `src/workflows/refactor/SKILL.md:782-895` 已有相同的三项用户验收菜单及 Completion 入口，但只将 `accepted` 描述为 Completion 前提，未映射 `rejected` 的返工或 `accepted_with_risk` 的责任保留。
- 三份 workflow 都已要求 Completion 仅在其实际结果为 merge、pull request 或 keep 时更新 manifest 和验收记录；`whole_run_discarded`、`discard_cancelled` 和 `discard_blocked` 不可伪装为成功。这是 manual recovery 只能在正常 Completion 已被证据证明不可继续后才可介入的现有边界。
- `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md:1-300` 管理正常 Completion 的环境、集成、保留和 discard 命令；S-018 只在调用者发现不可恢复阻断后定义交接记录，不改动该 vendored 命令行为。

### 终态记录与验证

- `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh:105-180` 已验证 terminal manifest 中阶段均为 `confirmed` 或 `skipped`、checkpoint 非 `pending`，并列出 `abandoned` 为可能状态；但 `abandoned` 在第 160 行提前返回，未要求已接受的 Business Acceptance 或 manual recovery 证据。
- `tests/delivery-record-contract.sh:245-372` 的 fixture 已能制造 terminal stage 与 checkpoint 失败，但当前 `valid-abandoned` 甚至会把实施、验证和验收标为 skipped，因此不能证明 S-018 的接受前提和最小记录。
- `tests/workflow-symmetry.sh:760-842` 已是三条 Delivery workflow 的对称断言入口，应扩展为检查终态映射、拒绝回退、风险责任和 manual recovery 的同构规则，而不是复制三套独立测试逻辑。

### 变更和发布边界

- 根 `version` 当前为 `0.30.0`；本 Story 改变可安装 package 的 workflow 行为、记录格式和 validator，因此实施应将它更新为 `0.31.0`。
- `scripts/build.sh` 从 `src/` 生成忽略的 `dist/.dev-cadence/`。权威修改必须落在 `src/`，构建负责同步；不得直接编辑 `dist/` 或 `src/vendor/superpowers/skills/**`。

## 方案备选

### 方案 A：最小文字映射

仅在三个 Business Acceptance 小节补充决策说明和验收记录字段，不增加 validator 或 fixture。

- 优点：改动最少。
- 缺点：无法阻止未验收、可恢复或无证据的 `abandoned`；风险责任与拒绝回退无法得到可执行验证。

### 方案 B：新的共享终态 workflow 或 skill

创建独立 terminal-state workflow/skill，由三个 Delivery workflow 转发至该所有者。

- 优点：共享文字可集中维护。
- 缺点：没有独立用户目标或资产所有权，增加路由、上下文和终态协调成本，违反仓库的 Skill 准入边界。

### 方案 C：务实对称扩展

在三个现有 Delivery workflow 的 Business Acceptance 与 Completion 中放置相同结构的决策映射和 manual recovery 契约；增加每个 run 的 `07-manual-recovery-record.md`，由现有 delivery-record validator 验证 `abandoned` 最小证据，并在现有 shell 契约测试中覆盖正反案例。

- 优点：每条 workflow 保持自身终态与记录所有权；不新建路由；validator 可以阻止无验收或无证据的 `abandoned`；对称测试避免漂移。
- 缺点：三份受控的对称规则需要同步维护。

## ❓ Decision Pending：推荐方案 C

此前对方案 C 的确认随 Requirements recovery 被 superseded。恢复后的需求范围和输入内容未变，方案 C 仍以现有 workflow 为自然所有者，满足 S-018 对对称性的要求，同时以 validator 和 fixture 将 `abandoned` 从宽松枚举值收紧为可审计例外，不扩大到 merge、discard 或 worktree 命令实现；等待新的 Technical Solution 确认。

## 设计细节

### Business Acceptance 决策映射

三个 workflow 都使用相同的规范化记录值和后续动作：

| 用户选择 | 规范化决定 | Manifest 与后续动作 |
| --- | --- | --- |
| Accept | `accepted` | 记录验收决定，整体状态为 `accepted`，进入正常 Completion；只有实际集成结果可改为 `integrated`。 |
| Accept with residual risk | `accepted_with_risk` | 每项风险写入稳定 Risk ID、说明和责任人；整体状态为 `accepted_with_risk`，进入正常 Completion；任何集成结果保留原决定和风险表。 |
| Reject | `rejected` | 先取得拒绝理由。理由可定位时，业务验收记录保留决定和理由，manifest 回到最早受影响阶段的 `in_progress`，后续阶段与失效证据标为 `pending` 或 superseded；理由不可定位时留在 Business Acceptance 澄清，不进入 Completion。 |

`rejected` 不把 manifest 作为 terminal `rejected` 结束，也不报告成功或 `integrated`。Risk ID 仅在当前 Business Acceptance record 中提供稳定可引用标识，不创建新的全局风险资产或工作项状态。

### Manual Recovery 例外路径

仅当 Business Acceptance 已记录 `accepted` 或 `accepted_with_risk`，正常 Completion 的 Git、分支、worktree、必要权限或外部环境阻断已经可复现，且至少一次恢复尝试失败并说明为何当前 run 无法继续时，才展示 manual recovery 的明确确认。

确认放弃正常 Completion 后，写入同 run 的：

```text
build/dev-cadence/<workflow>/<task-slug>/07-manual-recovery-record.md
```

该记录必须包含阻断类别与证据、被阻断的正常 Completion 动作、恢复尝试及结果、继续恢复不可行的原因、用户明确确认、代码/分支/worktree/run 记录的保留状态、后续责任人与下一步。随后才可把 manifest 置为 `abandoned`；所有既有业务阶段必须已是 `confirmed` 或 `skipped`，且没有 `pending` checkpoint。可重试工具故障、验证或 Review 失败、普通返工、未完成验收、用户 discard 及可恢复情况明确拒绝进入该路径。

### Validator 与测试

在 `--terminal` 且 Overall Status 为 `abandoned` 时，现有 validator 不再提前成功。它必须验证：

1. Business Acceptance stage 与其 artifact 存在、已确认并有非 pending checkpoint。
2. 验收记录的 `User Decision` 是 `accepted` 或 `accepted_with_risk`。
3. `07-manual-recovery-record.md` 存在且含有完整的最小字段集合。
4. 所有 stage 均为终态，且没有 pending checkpoint。

`tests/delivery-record-contract.sh` 将创建完整的 accepted fixture 与 manual recovery record，覆盖有效 `abandoned`、缺少 recovery record、非接受验收决定、缺少必要字段和 pending stage/checkpoint。`tests/workflow-symmetry.sh` 将为三条 workflow 断言相同的规范化决策、拒绝回退、风险责任、允许/禁止 manual recovery、`07` record 和 terminal validator 规则。

## 受影响边界

- `src/workflows/feature-dev/SKILL.md`：Feature 的业务验收、Business Acceptance record 和 Completion/manual recovery 规则。
- `src/workflows/bug-fix/SKILL.md`：对称的 Bug Fix 规则，保留其 Backlog Synchronization 所有权。
- `src/workflows/refactor/SKILL.md`：对称的 Refactor 规则，保留其 Behavior Baseline 语义。
- `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`：`abandoned` terminal evidence 验证。
- `tests/delivery-record-contract.sh` 与 `tests/workflow-symmetry.sh`：正反 fixture 和对称性断言。
- `version`：可安装行为变化后的版本评估与更新。

## 关键约束与风险

- 不得把阶段、失败生命周期或 manual recovery 结果变成 Backlog/work-item 状态。
- 不得用 manual recovery 绕过正常 Completion、用户验收或可恢复问题；完整记录也不能补偿不符合资格的情形。
- 不得修改 vendored finishing skill、具体 merge/discard/worktree 命令或 `dist/.dev-cadence/` 源文件。
- `abandoned` 仍必须保留已接受决定与资产事实；它不等于成功集成，也不授权删除任何证据。
- 三份 workflow 的结构性文本和 test pattern 必须保持一致；各 workflow 的领域名词可以不同。

## 验收标准到验证策略映射

| 验收标准 | 验证策略 |
| --- | --- |
| 三种决策具有明确且对称的后续行为 | `tests/workflow-symmetry.sh` 断言三份 workflow 的映射和禁止条件。 |
| accepted / accepted_with_risk 进入正常 Completion 且保留原决定 | 对称契约断言 record 字段、风险表与 Completion 前提；人工检查 workflow 语义。 |
| rejected 返工或澄清，不进入 Completion | 对称契约断言理由、最早阶段回退、superseded 和不进入 Completion。 |
| 仅允许合格的 manual recovery | `tests/delivery-record-contract.sh` 覆盖 accepted fixture、阻断记录和禁止情形；对称契约断言资格文本。 |
| abandoned 有完整记录且无 pending | validator 的正反 fixture 验证 `07-manual-recovery-record.md`、接受决定和 terminal stage/checkpoint。 |
| 构建后的可安装包同步 | `bash scripts/build.sh`、`rg --no-ignore` 比对 `src/` 与 `dist/.dev-cadence/`，再运行 `bash scripts/check-all.sh`。 |

## Open Questions

- 无。拒绝理由如何映射到当前 run 的最早受影响阶段是 Business Acceptance 的运行时用户输入，不是本次技术方案的未决设计。

## Recovery Refresh

- Requirements recovery 将 Direct Input Identities 编码规范为 validator 可读的原始值，更新了 Requirements record SHA-256，但未改变 Story Version、Status、范围、验收标准或直接输入内容。
- `validate-persistent-record-recovery.sh` 已在刷新前返回 `Recovery Target: Technical Solution`、`requirements identity is valid`。
- 主分支从计划基线新增的提交只触及 Backlog、Open Questions 和 Bug Story，不触及本方案的 workflow、validator、test 或 version 边界；Implementation 前仍会重新执行正式新鲜度门。

## 阶段决定

- Status: 🔄 `in_progress`
- Prior Confirmation: superseded by Requirements recovery; this refreshed version keeps the same recommended approach and refreshed Requirements SHA-256.
- User Confirmation: `pending`。需要确认方案 C 后才可开始刷新后的 Implementation Plan。
- 下一阶段：Technical Solution；Implementation Plan 和代码修改仍需后续确认。
