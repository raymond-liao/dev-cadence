# S-029 Feature 持久化记录契约

## 基本信息

- ID：`S-029`
- Version：`4`
- Status：`Ready`
- Priority：`P3`
- Change Type：Feature

## 目标

确保 feature-dev 的 requirements 和 technical solution 记录能够在会话中断后重建已确认范围、验收标准和方案约束。

## 背景

现有 feature-dev 已经使用独立的 requirements、technical solution 和 manifest 记录，但最小恢复字段与中断恢复验证尚未形成明确、可检验的契约。恢复运行时仍可能无法判断用户确认了什么，进而错误扩大范围或采用过期方案。

## 角色、场景与业务价值

- 角色：维护 Dev Cadence 交付 workflow 的交付负责人。
- 场景：`feature-dev` 的 Requirements Confirmation 或 Technical Solution 已被确认后，会话中断，需要由后续代理仅依据仓库中的当前 run 记录恢复工作。
- 业务价值：恢复过程能够重建用户已确认的交付边界与方案约束，避免扩大范围、遗漏验收条件或采用已过期的方案。

## ✅ 范围

- 在 manifest 中为已确认的 Requirements 和 Technical Solution 阶段保存对应记录的仓库相对路径和 SHA-256；manifest 继续只保存 run 索引、阶段状态、用户确认和 checkpoint 身份。
- 定义 `01-requirements.md` 恢复已确认需求边界所需的最小字段。
- 定义 `02-technical-solution.md` 恢复已确认方案决定所需的最小字段。
- 定义中断后基于连续已确认阶段恢复、正常缺少后续记录与异常记录失效的判定规则。
- 复用现有 stage record 路径和既有新鲜度门禁，不重新设计 Delivery 记录模型。
- 为上述字段、记录身份、恢复顺序、回退和新鲜度判定增加可执行契约测试。

## ❌ 非范围

- 不复制完整聊天记录。
- 不改变 Bug Fix 或 Refactor 的记录契约。
- 不在本 Story 中实现工作项卡片接入。
- 不把用户确认身份、确认时间或 checkpoint commit 复制到 requirements 或 technical solution；这些运行元数据继续由 manifest 持有。
- 不新建持久化记录类型，或复制 requirements、technical solution 正文到 manifest。

## 可观察行为与业务规则

- 已确认的 Requirements 或 Technical Solution 阶段必须在 manifest 中保存其记录的仓库相对路径和 SHA-256。manifest 不复制阶段正文，继续保存 run 索引、阶段状态、用户确认和 checkpoint 身份。
- `01-requirements.md` 必须记录工作项路径、类型、Version、Status 和本次 selected scope，以及目标、✅ 范围、❌ 非范围、验收标准、业务规则、假设、Open Questions 和直接依赖输入的身份，使后续代理无需聊天记录即可恢复需求边界。
- `02-technical-solution.md` 必须记录所依据的 requirements 路径和 SHA-256，以及已选方案与理由、备选方案或权衡（包括不采用替代方案的理由）、受影响边界、关键约束、Open Questions 和每项验收标准到验证策略的映射，使后续代理能够恢复方案决定而非重新猜测。
- 恢复 feature-dev run 时，代理必须先读取 manifest，并且只能把连续已确认阶段视为已确认；不得仅因某个阶段记录文件存在而视为用户已经确认该阶段。
- Requirements 尚未确认时，代理必须从 Requirements 开始，且不得要求 `01-requirements.md` 或 `02-technical-solution.md` 已存在。Requirements 已确认而 Technical Solution 尚未确认时，`02-technical-solution.md` 缺失是正常状态，代理必须在验证 requirements 后从 Technical Solution 继续。
- manifest 表示 Requirements 已确认时，代理必须验证 `01-requirements.md` 存在、最小字段完整、路径与 SHA-256 和 manifest 一致；缺失、字段不完整、路径或摘要不符时，必须返回 Requirements Confirmation。
- manifest 表示 Technical Solution 已确认时，代理必须先完成 requirements 验证，再验证 `02-technical-solution.md` 存在、最小字段完整、路径与 SHA-256 和 manifest 一致，并且引用同一份已确认 requirements 的路径和 SHA-256；任一验证失败，必须返回最早受影响阶段。manifest 的阶段状态出现不连续或矛盾时，必须返回最早不一致阶段。
- 当工作项或直接依赖输入发生实质漂移时，恢复必须复用既有新鲜度门禁判定影响范围，并返回其确定的最早受影响阶段；不得把旧记录身份校验通过误判为当前输入仍然有效。
- requirements、technical solution 与 manifest 保持职责分离：前两者分别保存业务范围和方案决定，manifest 保存阶段与运行身份。

## 验收标准

1. 对每个已确认的 Requirements 或 Technical Solution 阶段，manifest 都保存该阶段记录的仓库相对路径和 SHA-256，同时不复制记录正文。
2. requirements 记录包含工作项路径、类型、Version、Status、selected scope、目标、✅ 范围、❌ 非范围、验收标准、业务规则、假设、Open Questions 和直接依赖输入身份，足以恢复已确认的需求边界。
3. technical solution 记录引用已确认 requirements 的路径和 SHA-256，并包含已选方案及理由、备选方案或权衡及其取舍理由、受影响边界、关键约束、Open Questions，以及验收标准到验证策略的映射。
4. 当仅 Requirements 已确认时，恢复验证 requirements 后从 Technical Solution 继续，且不把缺少 solution 记录当作损坏；当两个阶段均已确认时，恢复验证两份记录及它们与 manifest 的身份关联后才进入后续阶段。
5. 缺失记录、缺失最小字段、路径或摘要不符、solution 未引用已确认 requirements、manifest 阶段不连续或矛盾、工作项或直接依赖实质漂移时，会阻止沿用旧确认并返回最早受影响阶段。
6. 契约测试使用真实恢复 fixture 覆盖 requirements-only、两个阶段均确认、缺字段、摘要不符、manifest 阶段矛盾、工作项或依赖漂移，以及 checkpoint 和 `skipped` 两种记录身份校验路径。

## 依赖

- `S-017` 工作项卡片与开发 Workflow 接入已完成，提供卡片引用、阶段记录和生命周期边界的当前基线；不存在剩余阻塞依赖。

## Open Questions

- 无。

## 相关文档

- [S-017 工作项卡片与开发 Workflow 接入](S-017-work-item-development-workflow-integration.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Feature 持久化记录契约 Story。 | 提升会话中断后的可靠恢复和审计质量。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 收敛为现有 Feature 持久化记录的字段契约与恢复验证。 | 当前 workflow 已具备独立记录模型，剩余缺口是可恢复字段和契约测试，而不是重建记录体系。 |
| 3 | 2026-07-20T15:29:02+0800 | Raymond Liao <raymond-liao@outlook.com> | 明确恢复角色、场景、最小字段、恢复顺序、缺失字段阻断和记录职责边界，并将 Story 标记为 `Ready`。 | 用户确认完成 S-029 的工作项分析；定义已满足进入 feature-dev 前的 Ready 门禁。 |
| 4 | 2026-07-20T16:17:30+0800 | Raymond Liao <raymond-liao@outlook.com> | 明确已确认阶段的记录身份、连续阶段恢复、正常缺少后续记录与异常失效的边界，并补全新鲜度和 fixture 验收条件。 | 用户确认以 manifest 保存阶段记录路径与 SHA-256、requirements 和 solution 分别持有需求及方案内容的恢复契约；定义已满足进入 feature-dev 前的 Ready 门禁。 |
