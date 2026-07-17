# S-040 Open Question Registry 全量索引与引用契约

## 基本信息

- ID：`S-040`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Enhancement

## 目标

将 `docs/open-questions.md` 明确为仓库全部问题的统一 Registry，使用稳定编号、生命周期状态、总表导航和单一正文来源连接各权威资产，同时收紧所有 Dev Cadence 管理文档的快捷链接文本规则。

## 背景

S-005 已实现按需创建、单一正文来源和共享维护能力，但当前契约会在问题进入终态后删除索引条目，并依赖 Registry Change Log 保存迁移和移除历史。仓库中的工作项卡片、产品文档、架构文档和技术方案也可以各自保存 Open Questions，却没有统一要求所有问题进入仓库级索引并共享稳定编号。

现有文档引用规则要求链接文字有意义，但没有明确规定具有稳定 ID 和标题的资产应同时显示两者。只显示 ID 的快捷链接会迫使读者打开目标后才能理解内容，也会降低 Registry 作为问题导航入口的可读性。

本 Story 有意修改已经交付的 S-005 行为：终态问题不再删除，Registry 不再维护 Change Log，而是通过状态、结果和最终权威来源保留完整生命周期。该变化是确认后的需求增强，不追溯改写 S-005 的历史交付范围。

## User Story

作为持续维护需求和交付工作的用户，我希望从一份可导航的 Registry 查看仓库全部问题及其当前状态，并能直接前往唯一权威正文，以便理解仍需解决的事项、保留终态结果，同时避免重复维护问题详情。

## ✅ 范围

- `docs/open-questions.md` 是仓库全部 Open Questions 的统一 Registry；PRD、Business Architecture、架构文档、工作项卡片、技术方案和其他权威资产中的每个问题都必须进入该 Registry。
- 每个问题使用仓库全局稳定的 `Q-nnn` 编号，从 `Q-001` 开始递增；编号同时写入 Registry 和问题所在的权威资产，迁移、状态变化或文件移动时不得重新编号。
- Registry 顶部使用一张 `Questions` 总表，字段固定为 `ID | Status | Question | Authoritative Source`。
- 总表中的 `Open` 问题按 `Q-nnn` 升序排在前面，所有非 `Open` 问题再按 `Q-nnn` 升序排在后面。
- 问题状态使用最小集合 `Open`、`Resolved`、`Rejected`、`Invalid` 和 `Superseded`，不增加 workflow 过程状态。
- 总表 `ID` 字段使用只显示稳定 ID 的内部快捷链接，例如 `[Q-001](#q-001)`，并跳转到文档底部对应的 `### Q-001` 详情锚点。
- Registry 底部使用 `Question Details`，按 `Q-001` 到最新编号的顺序保留每个问题的详情入口，不因状态变化移动或删除条目。
- 已有权威承载位置的问题，其 Registry 详情只保存问题标题和使用 `ID + 标题` 的快捷链接；完整正文、上下文和结论只保存在对应权威资产中。
- 暂时没有权威承载位置的问题，由 Registry 详情临时保存完整正文、上下文、影响和已知约束，并将 Registry 标记为权威来源。
- 问题后续获得权威承载位置时，先将完整正文迁移到该资产并保留 `Q-nnn`，验证完成后再把 Registry 详情替换为快捷链接，不保留两份需要同步的完整正文。
- 问题解决、拒绝、失效或被替代后不从 Registry 删除；更新为对应终态，并在权威资产中保存结果，Registry 详情链接到保存最终结论的权威来源。
- Registry 不维护 Change Log；问题的实质历史和最终结论由权威资产负责，Registry 通过保留条目、状态和来源提供生命周期视图。
- 首次真实问题出现时按需创建 Registry；安装和没有问题的仓库不创建空文档。创建本地 Open Question 和首次 Registry 必须作为同一次一致性更新。
- 任何 workflow 创建、修改、迁移或改变 Open Question 状态时，必须在同一次确认后的原子更新中同步维护权威资产和 Registry。
- `document-conventions` 明确规定：显式 ID 字段可以只显示 ID；其他快捷链接在目标具有稳定 ID 和标题时必须显示 `ID + 标题`，没有稳定 ID 时必须使用能够表达目标内容或职责的标题。
- Open Question Registry 的 `Authoritative Source` 和 `Question Details` 快捷链接必须应用共享文档引用规则，不得复制一套可能漂移的链接语义。
- 更新 source、入口协作、构建、安装包和契约验证，使新规则在目标仓库可用并保持一致。

## ❌ 非范围

- 不在本 Story 中迁移当前 `docs/open-questions.md` 的格式或编号。
- 不在本 Story 中扫描并初始化当前仓库全部存量 Open Questions。
- 不批量重写仓库中与 Open Question 无关的历史快捷链接。
- 不创建独立 Decision Registry，也不解决工作项产生依据与 Decision 资产边界问题。
- 不自动回答问题、选择终态或替用户确认结论。
- 不新增业务 workflow；Open Question Registry 继续作为共享资产维护能力。
- 不复制问题完整正文到 Registry 和权威资产形成双重来源。

## 验收标准

1. Registry 使用仓库全局稳定的 `Q-nnn`，每个编号同时存在于总表、详情入口和对应权威资产。
2. `Questions` 总表只包含 `ID`、`Status`、`Question` 和 `Authoritative Source`，所有 `Open` 按 ID 升序排在前面，所有非 `Open` 再按 ID 升序排在后面。
3. 总表中的 ID 快捷链接能够跳转到只由稳定编号决定的详情锚点，不因问题标题修改而失效。
4. `Question Details` 按 ID 升序覆盖全部问题；有权威来源时只提供清晰快捷链接，无权威来源时由 Registry 临时保存完整正文。
5. 问题迁移后只有一个完整正文来源，Registry 和权威资产继续使用同一 `Q-nnn`。
6. `Resolved`、`Rejected`、`Invalid` 和 `Superseded` 问题保留在 Registry，状态、结果和最终权威来源可见，不再通过删除和 Change Log 保存历史。
7. Registry 不包含 Change Log，相关规则、模板和契约测试不再要求新增、迁移或移除日志。
8. 仓库中的所有 Open Questions 都能从 Registry 统一发现；新增或状态变化不会只更新局部权威资产而遗漏 Registry。
9. 显式 ID 字段允许 ID-only 链接，其他权威来源和详情快捷链接使用 `ID + 标题` 或无 ID 资产的明确标题。
10. source、安装包、入口协作和契约测试保持同步，并覆盖编号、排序、内部锚点、单一正文、终态保留、无 Change Log、全量同步和链接文字规则。
11. 当前 Registry 数据迁移、存量问题初始化和无关历史链接清理不会被本 Story 实施范围隐式执行。

## Story Relationships

- Follows：[S-005 全局 Open Question Registry](S-005-open-question-registry.md)。
- Follows：[S-010 文档引用快捷链接](S-010-document-reference-links.md)。
- Related：[S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)。

## 依赖

- [S-005 全局 Open Question Registry](S-005-open-question-registry.md)。
- [S-010 文档引用快捷链接](S-010-document-reference-links.md)。

## Open Questions

- 无。

## 相关文档

- [Open Question Registry](../open-questions.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
| ---: | --- | --- | --- | --- |
| 1 | 2026-07-17T11:53:25+08:00 | RaymondLiao <yaoyu.liao@highsoft.ltd> | 创建 Open Question Registry 全量索引与引用契约 Story。 | 用户确认统一索引、稳定编号、终态保留、总表与详情导航、单一正文来源、无 Change Log 和通用快捷链接规则。 |
| 1 | 2026-07-17T13:50:47+08:00 | RaymondLiao <yaoyu.liao@highsoft.ltd> | 实施、系统测试和 Business Acceptance 已完成，S-040 状态更新为 Done。 | 用户选择 `1. Accept`；无新增剩余风险。 |
