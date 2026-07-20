# S-029 Feature 持久化记录契约 - 需求确认

## 工作项身份

- 工作项：[S-029 Feature 持久化记录契约](../../../docs/stories/S-029-feature-persistent-record-contract.md) (`docs/stories/S-029-feature-persistent-record-contract.md`)
- 工作项类型：`Story`
- 工作项 Version：`4`
- 当前 Status：`In Progress`
- selected scope：为 `feature-dev` 的 Requirements Confirmation 和 Technical Solution 建立可恢复记录契约及其可执行验证。
- Backlog 投影：[Backlog](../../../docs/backlog.md) (`docs/backlog.md`)，`进行中`，Version `4`，Status `In Progress`。

## 目标

确保 `feature-dev` 会话在 Requirements Confirmation 或 Technical Solution 已获确认后中断时，后续代理只依赖仓库中的当前 run 记录，即可恢复已确认的交付边界、验收标准和方案约束，并在记录或输入失效时回到最早受影响阶段。

## ✅ 范围

- 为 manifest 中已确认的 Requirements Confirmation 和 Technical Solution 阶段保存对应阶段记录的仓库相对路径与 SHA-256；manifest 不复制阶段正文。
- 定义 `01-requirements.md` 的最小恢复字段：工作项身份与 selected scope、目标、✅ 范围、❌ 非范围、验收标准、业务规则、假设、Open Questions 和直接依赖输入身份。
- 定义 `02-technical-solution.md` 的最小恢复字段：已确认 requirements 的路径与 SHA-256、已选方案及理由、备选方案或权衡及取舍理由、受影响边界、关键约束、Open Questions，以及验收标准到验证策略的映射。
- 定义恢复算法：先读 manifest，只承认连续的已确认阶段；当 Requirements 未确认、仅 Requirements 已确认、两个阶段均已确认时，分别以正确的阶段继续；记录、字段、路径、摘要、关联或阶段状态不一致时，回到最早受影响阶段。
- 将工作项或直接依赖的实质漂移交给既有新鲜度门禁决定最早回退阶段；旧记录摘要匹配不代表当前输入仍然有效。
- 为字段、身份、连续阶段、正常缺少后续记录、失效回退、新鲜度，以及 checkpoint 与 `skipped` 身份路径添加可执行契约测试。
- 修改 `src/` 权威规则并通过构建同步到忽略的 `dist/.dev-cadence/`，不直接编辑分发包。

## ❌ 非范围

- 不复制完整聊天记录，不将 requirements 或 technical solution 正文复制到 manifest。
- 不新建持久化记录类型或重建 Delivery record model。
- 不改变 `bug-fix` 或 `refactor` 的记录契约。
- 不实现工作项卡片接入，也不改变 S-029 以外的 Backlog 排序或状态。
- 不修改 `src/vendor/superpowers/skills/**`。

## 验收标准

1. 每个已确认的 Requirements 或 Technical Solution 阶段在 manifest 中都保存阶段记录的仓库相对路径与 SHA-256，且 manifest 不复制记录正文。
2. requirements 记录包含工作项路径、类型、Version、Status、selected scope、目标、✅ 范围、❌ 非范围、验收标准、业务规则、假设、Open Questions 和直接依赖输入身份。
3. technical solution 引用已确认 requirements 的路径和 SHA-256，并包含已选方案与理由、备选方案或权衡及取舍理由、受影响边界、关键约束、Open Questions，以及每项验收标准到验证策略的映射。
4. 仅 Requirements 已确认时，恢复在验证 requirements 后从 Technical Solution 继续，且不把缺少 solution 记录当作损坏；两个阶段均已确认时，恢复验证两份记录及它们与 manifest 的身份关联后才进入后续阶段。
5. 缺失记录、缺失最小字段、路径或摘要不符、solution 未引用已确认 requirements、manifest 阶段不连续或矛盾、工作项或直接依赖实质漂移时，阻止沿用旧确认并返回最早受影响阶段。
6. 契约测试使用真实恢复 fixture 覆盖 requirements-only、两个阶段均确认、缺字段、摘要不符、manifest 阶段矛盾、工作项或依赖漂移，以及 checkpoint 和 `skipped` 两种记录身份校验路径。

## 业务规则

- manifest 只持有 run 索引、阶段状态、用户确认、checkpoint 身份与已确认阶段记录的路径和 SHA-256；requirements 持有需求边界，technical solution 持有方案决定。
- 阶段记录文件存在不能证明用户已确认；只有 manifest 中连续的已确认阶段才能继续被沿用。
- 当 manifest 只表示 Requirements 已确认时，`02-technical-solution.md` 缺失是正常状态；当 manifest 表示 Technical Solution 已确认时，该文件和其 requirements 引用必须有效。
- 任一身份或最小字段验证失败必须返回最早受影响阶段，不能静默继续或扩大已确认范围。
- 恢复记录验证与当前输入新鲜度是两道不同门禁，必须都通过才能沿用确认结果。

## 直接依赖输入身份

| 输入 | 身份 | 使用方式 |
| --- | --- | --- |
| [S-017 工作项卡片与开发 Workflow 接入](../../../docs/stories/S-017-work-item-development-workflow-integration.md) | Story Version `5`, Status `Done` | 提供现有卡片引用、阶段记录和生命周期边界。 |
| [S-029 Feature 持久化记录契约](../../../docs/stories/S-029-feature-persistent-record-contract.md) | Story Version `4`, Status `In Progress` | 本次交付的权威需求来源。 |
| [Backlog](../../../docs/backlog.md) | S-029 位于 `进行中`, Version `4`, Status `In Progress` | 验证工作项投影与领取状态。 |

## 假设与 Open Questions

- 假设：现有 `feature-dev` manifest、阶段表、确认门禁和新鲜度门禁可被增量扩展，无需新增 workflow 或记录类型。
- 假设：SHA-256 只用于证明已确认记录内容身份，不替代后续对工作项和依赖当前状态的新鲜度检查。
- Open Questions：无。技术方案必须证明现有 shell 契约测试结构可以承载真实 fixture，或在不改变本 Story 范围的前提下说明最小替代验证方式。

## 阶段决定

- Status: ✅ `confirmed`
- User Confirmation: 用户于 `2026-07-20T17:08:18+0800` 选择“确认当前版本并进入 Technical Solution”。
- 下一阶段：Technical Solution。实施计划和代码仍需要在后续阶段分别确认后才能开始。
