# S-009 生成文档状态呈现

## 基本信息

- ID：`S-009`
- Version：`2`
- Status：`Ready`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 Dev Cadence 生成的 manifest、阶段记录、测试报告、验收摘要和用户输出使用统一的状态视觉标识，使已完成、进行中、待处理、阻塞、风险、失败和跳过等状态能够被快速识别，同时保留正式状态值。

## 背景

Dev Cadence 的运行记录包含大量 `confirmed`、`in_progress`、`pending`、`blocked`、`ready_with_risk` 和 `skipped` 等文字状态。正式状态值适合精确记录和搜索，但在较长的阶段表、验证报告和验收摘要中辨识度有限。

如果各 workflow 自行选择图标，同一状态可能出现不同视觉表达；如果用 emoji 替换正式状态值，又会破坏既有契约、搜索和后续自动处理。因此需要统一采用“emoji + canonical status”的显示形式，并限定适用范围。

## User Story

作为查看 Dev Cadence 交付状态的用户，我希望从文档和摘要中一眼区分已完成、进行中、待处理、阻塞和风险状态，以便快速理解当前进度和需要关注的事项。

## 范围

- 在 S-008 创建的 `document-conventions` 共享 skill 中增加用户可见状态映射，不在各 workflow 或 `using-dev-cadence` 中复制完整映射。
- 各 workflow 创建或更新 manifest、阶段记录、报告和用户可见 Markdown 摘要时，通过入口规则读取并遵守 `document-conventions`。
- 使用稳定映射：`✅` 对应 confirmed、completed、accepted、passed、resolved 和 integrated；`🟢` 对应 ready；`🔄` 对应 in_progress；`⏳` 对应 pending；`⛔` 对应 blocked 和 not_ready；`⚠️` 对应 ready_with_risk、accepted_with_risk 和其他明确风险状态；`❌` 对应 failed 和 rejected；`⏭️` 对应 skipped。
- 正式状态枚举保持不变，用户可见显示采用 `emoji + canonical status`，例如 `🔄 in_progress`；在 Markdown 文档中 canonical status 应使用行内代码格式。
- Manifest 的整体状态、阶段表和当前阶段摘要使用统一映射。
- Requirements、Solution、Plan、Implementation、Review、Testing、Verification、Business Acceptance 和 Completion 等阶段记录中的状态摘要使用统一映射。
- 测试报告、coverage、review finding、风险传递和最终结论中已有明确状态分类的位置使用统一映射。
- 用户可见的进度更新、确认请求和完成摘要在列举状态时使用相同映射。
- Backlog 和 Story 状态在不破坏 Markdown checkbox、优先级和正式状态字段的前提下使用一致视觉语义；避免同时堆叠多个含义重复的图标。
- Emoji 只增强状态显示，不写入状态枚举定义、配置值、文件名、路径、ID、Git 引用或命令。
- 无法映射到既有状态的普通说明不强行添加图标；新增状态必须先确定语义分类再选择视觉标识。
- 更新 feature-dev、bug-fix、refactor、discovery 及共享入口中与生成状态相关的规则，保持同类结构和措辞对称。
- 更新契约测试，验证共享映射、正式状态值保留和各 workflow 的关键输出位置，同时不锁死每一行生成文案。

## 非范围

- 不改变任何 workflow 的正式状态值、允许转换、终态或业务语义。
- 不把 emoji 作为机器解析状态的唯一来源。
- 不要求普通正文、Change Log、路径列表和命令输出都使用 emoji。
- 不在本 Story 中重写 workflow 阶段或状态机。
- 不在本 Story 中定义 skill 正反例和边界区块的视觉规范；这些由 S-008 负责。

## 验收标准

1. `document-conventions` 定义唯一的用户可见状态与 emoji 映射，并由全部已实现 workflow 复用。
2. 已完成、就绪、进行中、待处理、阻塞、风险、失败和跳过状态可以被快速区分。
3. 每个视觉状态仍显示对应 canonical status，正式状态枚举和业务语义保持不变。
4. Manifest、阶段表、测试报告、验收摘要和用户状态摘要中的关键状态使用统一映射。
5. Feature、Bug Fix、Refactor 和 Discovery 的同类状态呈现保持对称。
6. Emoji 不进入文件名、路径、ID、配置值、Git 引用、命令或正式枚举定义。
7. Backlog 和 Story 状态不会因为 emoji 与既有 checkbox、优先级或状态字段产生重复噪声。
8. 各 workflow 通过共享规范接入状态映射，不分别维护可能冲突的完整映射副本。
9. 契约测试验证共享 skill 中的状态映射、入口接入、canonical status 保留和关键输出覆盖，同时避免锁死全部生成文案。

## Story Relationships

- Follows：`S-008` Skill 语义视觉规范。
- Precedes：`S-010` 文档引用快捷链接。
- Related：`S-007` Workflow 入口路由示例、现有 workflow 的 manifest 和阶段记录契约。

## 依赖

- `S-008` Skill 语义视觉规范。

## 后续工作

- 后续新增 workflow 直接复用共享状态映射，不自行定义冲突图标。
- 现有运行记录不要求批量重写；新运行和后续被更新的记录使用新规范。

## Open Questions

- 无。

## 相关文档

- [S-007 Workflow 入口路由示例](S-007-workflow-routing-examples.md)
- [S-008 Skill 语义视觉规范](S-008-skill-semantic-visual-markers.md)
- [S-010 文档引用快捷链接](S-010-document-reference-links.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建生成文档状态呈现 Story。 | 使用统一视觉标识提高运行记录和用户摘要的状态辨识度，同时保留正式状态值和现有业务语义。 |
| 2 | 2026-07-14 | 明确状态映射扩展 S-008 创建的 `document-conventions` 共享 skill。 | 公共状态呈现规则需要集中维护，各 workflow 只接入和遵守，不能复制多套映射。 |
