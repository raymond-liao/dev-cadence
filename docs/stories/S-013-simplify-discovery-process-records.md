# S-013 Discovery 过程记录简化

## 基本信息

- ID：`S-013`
- Version：`2`
- Status：`Done`
- Priority：`P1`
- Change Type：Refactor

## 目标

按照 Asset Workflow 记录契约简化现有 Discovery，使需求分析步骤继续作为会话内工作方法，但持久化产出只保留 PRD 和 Business Architecture，不再创建 manifest、阶段记录、确认记录或阶段 checkpoint。

## 背景

S-001 实现的 Discovery 当前创建 `build/dev-cadence/discovery/<discovery-slug>/manifest.md`、三个分析阶段记录和最终确认记录，同时又生成 `docs/product-design/prd.md` 与 `docs/product-design/business-architecture.md`。两组文档保存大量重叠信息，用户反馈和范围变化需要同时回写，容易形成状态不一致。

Discovery 的长期价值是经过确认的产品需求与业务架构。背景、目标、范围、风险、开放问题和拒绝方向都可以进入这两份权威文档；Git 历史可以记录文档变化，不需要模拟 Feature Dev 的实施审计结构。

## User Story

作为使用 Discovery 建立产品设计基线的用户，我希望最终只维护 PRD 和 Business Architecture，以便产品事实集中在长期权威文档中，而不会被临时 manifest 和阶段记录分散。

## ✅ 范围

- 保留 Discovery 的会话内分析顺序：背景与问题、目标与价值、范围与业务架构、产品设计基线、用户确认。
- 移除 Discovery 创建和维护 run manifest 的要求。
- 移除 `01-background-and-problem.md`、`02-goals-and-value.md`、`03-scope-and-business-architecture.md` 和 `05-product-design-confirmation-record.md` 阶段记录要求。
- 移除 Discovery 的专用分支、阶段 checkpoint、checkpoint hash 回写和终态 manifest 要求。
- Discovery 的持久化产出只保留 `docs/product-design/prd.md` 和 `docs/product-design/business-architecture.md`。
- 背景、目标、范围、非范围、业务角色、业务域、能力、流程、业务对象、约束和风险直接写入职责对应的权威文档。
- 未解决内容保存在 `Open Questions`，明确拒绝的方向保存在 `Rejected Directions`，暂不进入当前版本的内容保存在 `Future Scope`。
- 两份产品设计文档继续分别维护 Version、Last Updated 和 Change Log，不保存 Git commit hash、审批人、审批时间或 workflow 状态。
- 用户确认仍是 Discovery 完成门禁；用户要求修改时更新受影响的权威文档并重新展示完整基线，但不创建独立确认记录。
- 用户拒绝时不得声称产品设计基线已确认，也不得创建额外拒绝记录文件。
- Discovery 的继续执行通过当前会话、用户目标和现有产品设计文档判断，不通过 manifest 恢复阶段状态。
- 更新 Discovery skill、用户可见 workflow 说明、README 中受影响的行为说明、构建产物和契约测试。
- 验证 Discovery 不再生成过程记录，同时仍能建立职责分离、内容完整且经过用户确认的第一版产品设计基线。

## ❌ 非范围

- 不删除或迁移历史 Discovery run 记录。
- 不在本 Story 中实现已有产品设计基线的增量更新；该能力仍属于 S-002。
- 不改变 PRD 与 Business Architecture 的职责边界。
- 不把技术架构、工作项拆分、实施计划或应用代码加入 Discovery。
- 不弱化 Open Questions、Rejected Directions、Future Scope、Version 或 Change Log 契约。
- 不修改 Feature Dev、Bug Fix 或 Refactor 的过程记录。
- 不用 PRD 或 Business Architecture 保存审批元数据和 Git 审计字段。

## 验收标准

1. Discovery 保留现有分析顺序和最终用户确认门禁，但这些阶段只在会话内执行。
2. 新 Discovery 不创建 `build/dev-cadence/discovery/` manifest、阶段记录或确认记录。
3. Discovery 不要求专用分支、阶段 checkpoint、空提交或 checkpoint hash 回写。
4. 唯一持久化产出是 `docs/product-design/prd.md` 和 `docs/product-design/business-architecture.md`。
5. 产品目标、范围、业务架构、风险和约束进入职责对应的权威文档，不依赖过程记录补充完整语义。
6. 未决、拒绝和未来内容分别进入 Open Questions、Rejected Directions 和 Future Scope。
7. 两份文档继续独立维护 Version、Last Updated 和 Change Log，且不包含审批或 Git 运行元数据。
8. 用户确认前 workflow 不声明基线完成；修改反馈会更新完整基线并重新请求确认。
9. Discovery continuation 使用会话、用户目标和权威文档，不引用不存在的 manifest。
10. Discovery 仍保持首次基线边界，不覆盖已有产品设计文档，也不声称实现 S-002。
11. Source、dist 和安装包保持同步，README 与 workflow 说明不再描述 Discovery 过程记录。
12. 契约测试验证无过程记录、双权威产物、确认门禁、内容职责和现有 Discovery 边界。

## Story Relationships

- Follows：`S-012` Asset 与 Delivery Workflow 记录边界。
- Precedes：`S-002` 产品设计基线增量更新与版本治理。
- Related：`S-001` 首次 Discovery 与产品设计基线。

## 依赖

- `S-001` 首次 Discovery 与产品设计基线。
- `S-012` Asset 与 Delivery Workflow 记录边界。

## 后续工作

- S-002 在简化后的双文档模型上实现增量更新与版本治理。
- 后续 Discovery 能力不得重新引入与长期产品设计重复的过程记录。

## Open Questions

- 无。

## 相关文档

- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [S-002 产品设计基线增量更新与版本治理](S-002-discovery-prd-incremental-versioning.md)
- [S-012 Asset 与 Delivery Workflow 记录边界](S-012-asset-delivery-workflow-record-boundary.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 2 | 2026-07-14 | 完成 Discovery 过程记录简化并更新契约、说明与分发版本。 | 只保留 PRD 与 Business Architecture 两份权威资产，同时保留会话内分析和确认门禁。 |
| 1 | 2026-07-14 | 创建 Discovery 过程记录简化 Story。 | 将 Discovery 从实施型 run 模型调整为只维护 PRD 和 Business Architecture 的资产型 workflow。 |
