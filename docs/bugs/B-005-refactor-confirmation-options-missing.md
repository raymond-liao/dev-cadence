# B-005 已安装 Workflow 用户确认门摘要、选项与结果语义不完整

## 基本信息

- ID：`B-005`
- Version：`4`
- Status：`Done`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修复六个已安装 Workflow 在部分用户确认门只丢出文件或只要求“确认”，却没有先总结待确认内容、完整展示实际可选决策及其后果的问题。Refactor 是最先暴露问题的 Workflow，但 Discovery、Work Item Planning、Architecture Design、Feature Dev 和 Bug Fix 也存在同类缺口。

## 预期行为

当已安装 Workflow 到达真实用户决策门时，用户可见确认请求必须先总结当前阶段的结论、范围、非范围、关键风险或未决问题，再展示该门实际支持的明确选项，并说明每个选项对下一阶段、资产写入、运行记录、状态和再次确认的影响。完整记录作为证据链接提供，不能由文件路径替代会话摘要。不同门禁保留各自业务语义，不强制使用同一套通用选项。

## 已观察行为

用户最先在 Refactor workflow 中观察到确认门没有提供可直接选择的选项。进一步审计确认：

- 部分确认请求直接把阶段记录文件丢给用户，缺少对实际待确认内容的会话级总结。
- Feature Dev、Bug Fix 和 Refactor 的前置阶段通常只要求用户确认，没有明确展示“确认并前进”与“修改并停留重提”的选择及结果。
- Discovery、Work Item Planning 和 Architecture Design 也有未完整呈现选项的决策门，但包含权威来源、部分确认、MVP 切片、迁移、方案选择和 Decision Pending 等专用语义，不能机械套用 Delivery Workflow 的选项。
- 已有规则为 Business Acceptance 和 Completion 定义了固定菜单，但本次 S-017 用户验收时实际提示未展示可选项，用户无法按固定选项作出可归一化的验收决策；本卡记录该提示与既有契约不一致的现象，不重新定义终态语义。
- 现有测试主要验证确认门存在，没有系统验证“门、选项、结果”三者一致。

## ✅ 范围

- 覆盖 Discovery、Work Item Planning、Architecture Design、Feature Dev、Bug Fix 和 Refactor 的全部真实用户决策门。
- 要求每个真实确认门在文件链接前提供当前阶段结论、范围、非范围、关键风险或未决问题的精炼摘要。
- 为每个门规定用户可见的明确选择，以及每个选择对下一阶段、资产写入、记录、状态和再次确认的影响。
- 将完整记录作为可追溯证据链接保留，但不把文件路径本身当作确认内容。
- 对三个 Delivery Workflow 的前置阶段建立对称的最小选择语义，同时保留各自阶段名称和业务内容。
- 保留 Asset Workflow 的部分确认、候选方案、迁移、拆分和 Decision Pending 等领域语义。
- 保留 Refactor 的行为变化路由和 Behavior Baseline 风险决策，以及三个 Delivery Workflow 的 Review 风险决策。
- 明确 Dev Cadence 阶段确认与 vendored 方案选择、执行模式选择、worktree consent、Business Acceptance 和 Completion 菜单之间的边界。
- 扩展契约测试，按语义验证选项及结果，不锁定整段自然语言措辞。
- 实施时同步构建 `dist/.dev-cadence`，并评估更新根目录 `version`。

## ❌ 非范围

- 不取消任何已有用户确认门禁。
- 不增加新的 Workflow 阶段、状态或终态。
- 不要求所有确认门使用同一组选项、相同编号或相同措辞。
- 不定义 S-018、S-022 或 S-023 已拥有的终态行为。
- 不修改 vendored Superpowers 副本。
- 不给验证证据判定、普通进度摘要、一般澄清问题或其他非决策节点增加确认菜单。
- 不把含糊的“拒绝”映射到尚未实现的停止、回滚或关闭行为。

## 验收标准

1. 六个已安装 Workflow 的每个真实用户决策门都先展示阶段摘要，再展示实际支持的明确选项及结果。
2. Delivery Workflow 的前置阶段至少明确“确认当前版本并进入下一阶段”和“要求修改并停留当前阶段重提”的行为。
3. 确认摘要至少覆盖当前结论、范围、非范围、关键风险或未决问题、证据路径和下一步影响。
4. 部分确认、方案选择、风险接受、行为路由和 Git 集成保留各自专用语义。
5. Business Acceptance 和 Completion 的现有固定选项不被重复、合并或弱化。
6. 不出现没有记录、状态或后续处理支撑的虚假选项。
7. 普通非终态确认可接受明确自然语言；只有终态、高风险或破坏性操作继续要求编号或精确文本。
8. 契约测试覆盖六个 Workflow，并验证“摘要、门、选项、结果”四者一致。
9. source、dist、安装包和版本处理保持一致，完整契约验证通过。

## 已知复现条件

- 执行任一已安装 Workflow，并到达其规则要求用户作出决定的阶段。
- 用户可见提示只要求“确认”或“选择”，没有展示该门实际支持的决策集合，或没有说明选择后的记录、状态与下一步。
- 已确认提示来源位于各 owning Workflow skill 及其调用的 vendored skill；未发现独立运行时模板。

## 依赖

- 无强制前置依赖。Business Acceptance 终态映射仍由 S-018 负责，Bug Fix 的 `not-a-bug` 与通用停止语义分别留给其既有工作项。

## Open Questions

- 无。共性原则由各 owning Workflow 落地；不同门禁使用已有行为支持的专用选项，不新增通用“停止 Workflow”语义。

## 相关文档

- [Backlog](../backlog.md)
- [Discovery 流程](../workflows/discovery.md)
- [工作项规划流程](../workflows/work-item-planning.md)
- [架构设计流程](../workflows/architecture-design.md)
- [Feature Dev 流程](../workflows/feature-dev.md)
- [Bug Fix 流程](../workflows/bug-fix.md)
- [Refactor 流程](../workflows/refactor.md)

## Relationships

- Related Story: [S-017 工作项卡片与开发 Workflow 接入](../stories/S-017-work-item-development-workflow-integration.md)。
- Related Story: [S-018 Delivery 终态映射与 Manual Recovery](../stories/S-018-business-acceptance-terminal-mapping.md)。

## 交付结果

- Repair Result：Delivery Workflow 的 Business Acceptance 与 Completion 菜单现在必须在同一用户可见消息中完整展示，delegated continuation 不得创建或选择终态决定。
- Repair Reference：`0f0857ddedd8a1c09ae0c6c3b2648c9ab393315c`。
- Integration Reference：任务分支已 fast-forward 合并到 `main` 的 `e11ae7854d60d984e0637c3aafbbf3614b5798ea`；合并后完整验证通过，任务 worktree 和分支已删除，未执行 push。

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | 创建 Refactor 确认阶段缺少用户选项 Bug。 | 记录确认门禁未提供可选择决策的问题，等待诊断。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 将问题从 Refactor 扩展为六个已安装 Workflow 的确认门选项与结果语义缺口。 | 跨 Workflow 审计确认问题并非 Refactor 单点，同时不同门禁不能机械使用同一菜单。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 将确认门问题扩展为“先展示内容摘要，再提供选项和结果语义”，并明确文件只能作为证据链接。 | 用户指出每次确认时直接丢阶段文件，用户无法快速判断实际需要确认的内容。 |
| 4 | legacy: recorded-at precision unknown; original 2026-07-18 | legacy: recorded-by unknown | 补充 S-017 用户验收提示未展示可选项的现象，并关联 S-017 与 S-018。 | 实际用户验收时无法看到已有固定菜单，说明用户可见提示与既有 Business Acceptance 契约不一致。 |
| 4 | legacy: recorded-at precision unknown; original 2026-07-18 | legacy: recorded-by unknown | 完成当前终态菜单补强交付并将状态更新为 `Done`。 | 当前补强已完成回归验证、业务验收、本地集成和清理。 |
