# T-001 工作项范围章节语义标识

## 基本信息

- ID：`T-001`
- Version：`2`
- Status：`Done`
- Priority：`P2`
- Change Type：Documentation Governance

## 任务目标

统一 Feature、Story、Bug 和 Task 工作项卡片中范围与非范围章节的视觉语义，使用 `## ✅ 范围` 表示当前工作项包含的内容，使用 `## ❌ 非范围` 表示当前工作项明确排除的内容，使读者能够快速识别交付边界。

## 背景

现有 Story 卡统一使用 `## 范围` 和 `## 非范围`，未来 Feature、Bug 和 Task 卡也需要表达相同边界，但标题缺少已经由 `document-conventions` 定义的正反语义标识。范围表示适用于当前工作项，非范围表示不适用于当前工作项，分别与 `✅ applicable` 和 `❌ not applicable` 的共享语义一致。

标识应集中在章节标题，不应重复添加到每个普通列表条目，否则较长的工作项卡片会产生不必要的视觉噪声。

## ✅ 范围

- 在共享 `document-conventions` skill 中增加工作项范围章节规则。
- 规定 Feature、Story、Bug 和 Task 卡使用固定的 `✅` / `❌` 语义标识，标题文字遵守 `output_language` 或文档既有语言；当前 `zh-CN` 仓库使用 `## ✅ 范围` 和 `## ❌ 非范围`。
- 明确 `✅` 表示包含或适用于当前工作项，`❌` 表示明确排除或不适用于当前工作项，不表示内容质量判断。
- 标识只放在章节标题，不要求给范围和非范围中的普通列表条目逐项添加 emoji。
- 批量更新 `docs/delivery/stories/` 下现有 Story 卡和 `docs/delivery/tasks/` 下现有 Task 卡的范围与非范围标题。
- 更新已存在的工作项模板、示例或工作项契约，使后续 Feature、Story、Bug 和 Task 自动使用统一标题。
- 保持标题文字存在，不能只用 emoji 表达章节含义。
- 共享规则使用语言中性的标题占位符和 `Thought` / `Reality` Red Flags 表，不枚举具体人类语言或把当前仓库的标题文字提升为跨仓库契约。
- 更新契约测试，验证共享规则和现有工作项标题保持一致，同时避免锁死工作项正文措辞。
- 运行构建和安装包同步，使 source、dist 和 dogfood 安装包包含相同规则。

## ❌ 非范围

- 不给范围或非范围中的每个普通列表条目重复添加 emoji。
- 不把 `✅` 解释为内容已经验证、完成或通过验收。
- 不把 `❌` 解释为内容错误、失败或被用户拒绝。
- 不修改工作项的业务范围、优先级、状态、依赖或验收标准。
- 不要求 PRD、Architecture、manifest 或实施阶段记录使用相同章节标题。
- 不在文件名、ID、状态枚举、命令或其他机器读取值中加入 emoji。
- 不在本任务中建立新的文档标识体系或修改其他既有语义。

## 验收标准

1. `document-conventions` 明确要求 Feature、Story、Bug 和 Task 工作项卡片使用本地化的 `✅` included-scope 和 `❌` excluded-scope 标题，不把任何具体人类语言的标题写成共享契约。
2. 共享规则明确说明两个标识分别表示当前工作项的包含范围和明确排除范围，不表达质量或验收判断。
3. `docs/delivery/stories/` 和 `docs/delivery/tasks/` 下所有现有工作项卡片使用统一的范围章节标题。
4. 普通范围与非范围列表条目不会被机械添加重复 emoji。
5. 工作项正文、业务边界、状态、优先级、依赖和验收标准不会因标题迁移发生语义变化。
6. 后续 Feature、Story、Bug 和 Task 模板、示例或工作项契约要求生成相同标题。
7. Source、dist 和 dogfood 安装包中的共享文档规则保持同步。
8. 契约测试覆盖共享规则和工作项标题一致性，但不锁死工作项正文自然语言。
9. 空白检查和完整契约验证通过。

## Task Relationships

- Follows：`S-008` Skill 语义视觉规范。
- Related：`S-009` 生成文档状态呈现。
- Related：`S-010` 文档引用快捷链接。

## 依赖

- `S-008` Skill 语义视觉规范。

## 后续工作

- Work Item Planning workflow 实现时，将该标题规则纳入所有工作项卡片生成契约。
- 后续如果其他文档存在稳定的正反章节对，应单独评估语义是否完全一致，不机械扩散本任务规则。

## Open Questions

- 无。

## 相关文档

- [S-008 Skill 语义视觉规范](../stories/S-008-skill-semantic-visual-markers.md)
- [S-009 生成文档状态呈现](../stories/S-009-generated-status-presentation.md)
- [S-010 文档引用快捷链接](../stories/S-010-document-reference-links.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建工作项范围章节语义标识任务。 | 使用共享正反语义提升 Feature、Story、Bug 和 Task 边界的扫描效率，同时避免逐项装饰造成视觉噪声。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 修正范围标题的语言边界并返回实施状态。 | 用户验收发现共享规则错误地把简体中文标题强制用于英文输出；标识语义应固定，标题文字必须本地化。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 通过修正后的业务验收。 | 语言中性规则和 `Thought` / `Reality` Red Flags 已验证并获接受。 Legacy migration: original Version 3; normalized to Version 2. |
| 2 | 2026-07-19T13:07:24+0800 | Raymond Liao <raymond-liao@outlook.com> | Normalized legacy status and delivery events to reuse the active definition Version. | Old current 3 -> new current 2; original row versions 1,2,3 -> normalized row versions 1,2,2. |
