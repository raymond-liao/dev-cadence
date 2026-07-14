# S-008 Skill 语义视觉规范

## 基本信息

- ID：`S-008`
- Version：`5`
- Status：`In Progress`
- Priority：`P1`
- Change Type：Enhancement

## 目标

为 Dev Cadence skill 建立一致、克制的语义视觉规范，让代理和维护者能够快速识别必须执行、禁止执行、风险、歧义和示例结论，同时保留规则文本的精确性和可搜索性。

## 背景

现有 workflow skill 包含大量 Must、Must Not、Red Flags、正反例、状态判断和风险规则，但主要依赖相似的文字标题和长列表区分。阅读者需要逐行确认内容属于职责、禁止项还是例外，扫描效率较低。

Emoji 适合强化具有稳定语义的规则区块，但不适合装饰所有正文。缺少统一规范时，各 skill 可能使用不同图标表达相同含义，或者把 emoji 写入命令、路径和正式状态值，反而降低规则精确性。

## User Story

作为维护和使用 Dev Cadence workflow 的用户，我希望关键规则区块具有一致的视觉标识，以便快速识别必须执行、禁止执行、风险和待澄清内容，而不需要逐段辨认相似文字。

## 范围

- 新增共享辅助 skill `src/skills/document-conventions/SKILL.md`，构建后安装为 `.dev-cadence/skills/document-conventions/SKILL.md`；它不是业务 workflow，不创建独立 run。
- `document-conventions` 作为 Dev Cadence 管理的 Markdown 文档公共呈现规则权威来源，首先包含 skill 语义视觉规范，并由 S-009、S-010 继续扩展。
- `using-dev-cadence` 只规定：任何 workflow 创建或更新 Dev Cadence 管理的 Markdown 文档前，必须读取 `document-conventions`；入口不重复维护完整视觉映射。
- 使用稳定语义：`✅` 表示必须、适用、正确或通过；`❌` 表示禁止、不适用、错误或失败；`❓` 表示歧义、待确认或需要澄清；`⚠️` 表示风险、例外或有条件执行；`ℹ️` 表示确有必要的补充说明。
- Emoji 必须与明确文字标题、决定或原因一起使用，不能作为唯一语义来源。
- 对 Must/Must Not、Allowed/Forbidden、Positive/Negative、Passed/Failed 等成对规则区块使用相应视觉标识。
- 正例、反例和歧义例分别使用 `✅`、`❌` 和 `❓`，并保留预期决定及原因。
- 技术方案或其他多方案比较文档在用户选定方案后，必须使用 `✅ Selected` 明确标识选定项；未选但仍有效的备选方案保持中性，只有明确拒绝的方案才使用 `❌ Rejected`，尚未决策时使用 `❓ Decision Pending`。
- Red Flags、风险接受、例外路径和有条件规则使用 `⚠️`，不得把普通注意事项全部升级为风险标识。
- 只在能够显著改善扫描和对比的标题、表格单元格或示例结论中使用 emoji，不对普通段落和每个普通列表项机械添加。
- 不在文件名、路径、命令、ID、配置项、Git 引用、机器解析值或正式状态枚举中加入 emoji。
- 优先改造已实现 workflow 中高价值的边界、正反例、风险和决策区块，不进行不加判断的全局文本替换。
- 新增或修改 workflow 时复用统一语义，不允许为相同含义自行选择冲突图标。
- 更新契约测试，验证共享语义表和关键区块使用规则，同时避免锁定所有自然语言或要求每个标题都有 emoji。

## 非范围

- 不要求 skill 中的所有标题、段落和列表项都使用 emoji。
- 不用 emoji 替代 `must`、`do not`、`when`、`before` 和 `after` 等规范性措辞。
- 不改变 workflow 的业务阶段、状态机、确认门禁或职责边界。
- 不在本 Story 中规定 manifest、测试报告和用户摘要的状态显示格式；这些由 S-009 负责。
- 不在本 Story 中实现新的 workflow 或业务能力。

## 验收标准

1. Dev Cadence 提供独立的 `document-conventions` 共享辅助 skill，作为 Markdown 公共呈现规则的唯一权威来源。
2. `✅`、`❌`、`❓`、`⚠️` 和 `ℹ️` 各自具有明确且不冲突的使用范围。
3. Emoji 始终与文字标题、决定或原因共同出现，不成为唯一语义来源。
4. Must/Must Not、正例/反例/歧义例和 Red Flags 等高价值区块能够使用一致标识提高扫描效率。
5. 多方案比较文档能够一眼识别 `✅ Selected` 方案，不会把所有未选方案误标为 `❌`，也不会把推荐方案未经确认标成已选定。
6. 普通规则正文、文件路径、命令、ID、配置项和正式枚举值不会被机械加入 emoji。
7. 已实现 workflow 的关键视觉区块使用统一语义，不出现相同图标表达冲突含义。
8. `using-dev-cadence` 要求 workflow 在创建或更新 Dev Cadence 管理的 Markdown 前读取共享规范，但不复制完整语义表。
9. 构建和安装包包含 `document-conventions`，契约测试验证共享语义表、入口接入和代表性关键区块，同时不锁死全部自然语言或要求无差别装饰。

## Story Relationships

- Precedes：`S-007` Workflow 入口路由示例。
- Precedes：`S-009` 生成文档状态呈现。

## 依赖

- 无硬性前置 Story。

## 后续工作

- S-007 使用本 Story 的正例、反例和歧义标识完善入口路由示例。
- S-009 在不改变正式状态值的前提下扩展用户可见状态映射。

## Open Questions

- 无。

## 相关文档

- [S-007 Workflow 入口路由示例](S-007-workflow-routing-examples.md)
- [S-009 生成文档状态呈现](S-009-generated-status-presentation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建 Skill 语义视觉规范 Story。 | 使用一致且克制的 emoji 语义提高关键规则区块的扫描效率，同时保持执行规则精确。 |
| 2 | 2026-07-14 | 将语义视觉规范的权威位置调整为共享 `document-conventions` skill。 | 文档公共规范不属于 workflow 路由职责，需要由独立辅助能力集中维护并供后续状态和链接规则扩展。 |
| 3 | 2026-07-14 | 将状态更新为 In Progress，并在 Backlog 中移入进行中。 | S-008 已启动对应的 feature-dev workflow run，工作项状态应与实际交付阶段一致。 |
| 4 | 2026-07-14 | 将状态更新为 Done，并在 Backlog 中移入已完成。 | S-008 已通过完整验证和用户 Business Acceptance。 |
| 5 | 2026-07-14 | 增加多方案文档的选定方案视觉标识，并将状态返回 In Progress。 | 用户在 Completion 前发现技术方案等多方案文档无法快速识别最终选项，原验收结论被本次反馈 supersede。 |
