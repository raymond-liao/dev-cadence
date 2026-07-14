# S-005 全局 Open Question Registry

## 基本信息

- ID：`S-005`
- Version：`2`
- Status：`Ready`
- Priority：`P1`
- Change Type：Enhancement

## 目标

为目标仓库提供统一的 Open Question Registry，使用户能够从一个入口了解全部遗留和未解决问题，同时保证每个问题只有一个权威正文来源，并避免各 workflow 分别实现文档创建和维护逻辑。

## 背景

PRD、Business Architecture、Story、Technical Task 和技术方案都可能拥有自身的 Open Questions；需求讨论中也可能出现当前流程产物无法合理承载、但不应丢失的问题。如果只把问题保存在各自文档中，用户难以获得仓库级全貌；如果在全局文档和所属文档中重复维护正文，又会产生状态和答案不一致。

因此需要一个独立的共享治理能力：使用 `docs/open-questions.md` 提供全局索引，问题正文仍由最合适的权威文档负责；尚无合适承载位置的问题由 Registry 暂时保存完整内容。

## User Story

作为持续维护软件需求和交付工作的用户，我希望从一个入口看到仓库中全部未解决问题及其归属，以便评估遗留事项，同时避免同一个问题在多个文档中重复维护。

## 范围

- 新增独立的共享 `open-question-registry` skill；它不是业务 workflow，不创建单独的 workflow run。
- `docs/open-questions.md` 采用按需创建：安装 Dev Cadence、启动会话或启动 workflow 时不预先创建，首次确实需要登记全局问题时才创建。
- 创建或使用 Registry 前扫描仓库中已有的 Open Question 清单，避免覆盖已有文档或创建相互竞争的全局索引。
- Registry 索引仓库中全部仍需关注的未解决问题，包括 Product、Business、Technical 和 Cross-cutting 类型。
- 每个问题使用稳定 ID，并记录简短标题、类型、状态、Owner、权威来源链接、影响范围和建议解决阶段。
- 已有明确权威文档的问题，其完整上下文和处理结论只保存在 PRD、Business Architecture、Feature、Story、Bug、Technical Task、技术方案或其他对应文档中；Registry 只保存摘要、状态和链接。
- 当前没有合适权威文档的问题，由 Registry 暂时保存完整上下文、影响和建议下一步。
- 问题后续获得明确归属时，将完整正文迁移到对应权威文档，并将 Registry 条目更新为该文档的索引，不保留两份需要同步维护的正文。
- 问题得到确认或解决后，将结论写入对应权威文档，并从 Registry 的当前 Open Questions 索引中移除，不把已确认事项继续保留为 Open Question。
- 问题被拒绝、失效或替代时，从当前索引中移除，并在对应权威文档中保存适用的结论或历史。
- `docs/open-questions.md` 必须维护自身的 Change Log，记录问题新增、迁移、移除及最终承载位置；Change Log 用于保留索引变化历史，不重复保存问题完整正文。
- PRD 和 Business Architecture 继续保留各自的 `Open Questions`，不被 Registry 替代。
- 各 workflow 发现当前产物无法合理承载、但不应丢失的未决事项时，复用共享 Registry 能力，不各自定义全局问题文档创建规则。
- 用户直接要求查看、登记、迁移、整理或解决仓库级遗留问题时，`using-dev-cadence` 能够路由到该共享能力。
- 为 Registry 文档格式、按需创建、单一正文来源、迁移和入口路由增加契约验证。

## 非范围

- 不把所有问题正文集中复制到 `docs/open-questions.md`。
- 不移除 PRD、Business Architecture、工作项或技术方案自身的 Open Questions。
- 不在安装脚本中创建或覆盖目标仓库的 `docs/open-questions.md`。
- 不自动回答、确认或关闭问题。
- 不因为登记问题而自动创建 Feature、Story、Bug 或 Technical Task。
- 不在本 Story 中实现产品设计增量版本治理或工作项规划。

## 验收标准

1. Dev Cadence 提供独立的共享 Open Question Registry 能力，各业务 workflow 无需分别实现全局索引的创建和维护规则。
2. `docs/open-questions.md` 仅在首次确实需要登记问题时按需创建，安装和无问题的 workflow 不会产生空文档。
3. Registry 能列出仓库中全部仍需关注的问题，并显示稳定 ID、类型、状态、Owner、权威来源、影响和建议解决阶段。
4. 已有明确归属的问题只在对应权威文档维护完整正文，Registry 只保存摘要和链接。
5. 尚无权威承载位置的问题可以在 Registry 中暂存完整内容，且不会因为 workflow 运行记录被忽略或清理而丢失。
6. 问题获得明确归属后，正文能够迁移到对应文档，Registry 更新链接且不留下两份需要同步维护的正文。
7. PRD 和 Business Architecture 继续独立维护各自范围内的 Open Questions。
8. 问题得到确认、解决、拒绝、失效或被替代后，会从当前 Open Questions 索引移除，不继续伪装成未解决问题。
9. 仓库已有候选 Open Question 清单时不会被静默覆盖，也不会自动创建竞争性全局索引。
10. 用户能够直接请求查看或维护仓库级 Open Questions，其他 workflow 也能够复用同一能力登记无法由当前产物承载的问题。
11. Registry 自身的 Change Log 能追溯问题新增、迁移、移除及最终承载位置，同时不复制问题完整正文。
12. 契约测试覆盖按需创建、全局索引、单一正文来源、问题迁移、问题移除、Change Log 和入口路由规则。

## Story Relationships

- Precedes：`S-002` 产品设计基线增量更新与版本治理。
- Related：Work Item Planning workflow、工作项卡片与现有开发 workflow 接入任务。

## 依赖

- 无硬性前置 Story。

## 后续工作

- `S-002` 在产品设计增量更新时复用 Registry，登记无法由 PRD 或 Business Architecture 承载的问题。
- Work Item Planning 在创建或更新工作项时迁移、关联或登记相关问题。
- 开发 workflow 在需求确认和技术方案阶段读取相关问题，并按权威归属更新状态。

## Open Questions

- 无。

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建全局 Open Question Registry Story。 | 为跨文档未决问题提供统一全局视图和共享维护能力，同时避免重复正文及各 workflow 分别实现创建逻辑。 |
| 2 | 2026-07-14 | 增加已确认问题移除和 Registry Change Log 规则。 | 当前索引应只呈现仍未解决的问题，同时需要通过 Change Log 保留问题新增、迁移和移除历史。 |
