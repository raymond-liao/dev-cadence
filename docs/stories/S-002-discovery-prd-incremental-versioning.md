# S-002 产品设计基线增量更新与版本治理

## 基本信息

- ID：`S-002`
- Version：`5`
- Status：`Ready`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 `discovery` 能够在已有 PRD 和 Business Architecture 基线上持续接收新需求、反馈和范围变化，形成可追溯的新版本，同时保留既有产品设计历史。

## 背景

产品设计基线不是一次性文档。首次需求探索完成后，产品目标、范围、业务角色、流程、对象、规则和约束会继续变化。如果没有明确的增量更新和版本治理规则，代理可能直接覆盖既有设计、丢失历史，或者把未解决内容写进正式正文。

## User Story

作为持续维护软件需求的用户，我希望需求变化能够保留原有共识和变化原因，以便团队始终根据最新确认的需求开展后续工作。

## 范围

- 读取已有 PRD、Business Architecture 及其当前版本。
- 支持 `discovery` 的增量更新模式。
- 对新需求、业务架构变化、修正、替代、拒绝、开放问题和未来范围变化进行分类。
- 识别变化应写入 PRD、Business Architecture 或两者。
- 实质变化时递增受影响文档的版本并更新对应 Change Log。
- 非实质的拼写、排版和链接修正不升版。
- 保留已有正文、Rejected Directions、Future Scope 和 Change Log 历史。
- 保持 Open Questions 的未解决状态。
- 识别产品设计变化对现有工作项和活动开发任务的潜在影响。
- 获取用户对更新后两文档基线的一次重新确认。
- 将工作项调整交给后续 `work-item-planning`，不直接静默改写卡片。

## 非范围

- 不重新实现首次产品设计基线建立流程。
- 不创建或直接修改 Feature、Story、Bug、Technical Task 和 Roadmap。
- 不决定受影响工作项的最终拆分、状态或实施顺序。
- 不修改目标仓库应用代码。

## 验收标准

1. `discovery` 可以读取现有 PRD 和 Business Architecture 版本，并基于新输入形成一次协调的增量变更。
2. 产品目标、范围、成功标准、业务角色、业务域、流程、对象、状态、规则或约束发生实质变化时，受影响文档递增版本并记录变化原因。
3. 只有拼写、排版或链接变化时，对应文档版本保持不变。
4. 既有正文、Rejected Directions、Future Scope 和 Change Log 历史不会被静默删除或改写。
5. Open Questions 不会在缺少用户确认时被写成已确定正文。
6. 更新后的产品设计基线得到用户确认前，不成为后续规划的正式基线。
7. 发现现有工作项可能受影响时，workflow 记录影响并移交 `work-item-planning`，不直接静默修改卡片。

## Story Relationships

- Extends：`S-001` 首次 Discovery 与产品设计基线。
- Depends On：`S-001` 首次 Discovery 与产品设计基线（已完成）。

## 依赖

- `S-001` 首次 Discovery 与产品设计基线（已完成）。

## 后续工作

- Work Item Planning workflow 根据确认后的产品设计基线增量维护 Feature、Story、Bug、Technical Task 和 Roadmap。

## Open Questions

- 当一次变化只影响 PRD 或 Business Architecture 之一时，两份文档应独立升版，还是保持共享的产品设计基线版本？

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [S-001 首次 Discovery 与产品设计基线](S-001-initial-discovery-prd-baseline.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-13 | 创建 PRD 增量更新与版本治理 Story。 | 将增量需求治理从首次 Discovery 能力中拆出，形成可独立实施和验证的后续 Story。 |
| 2 | 2026-07-13 | 将状态改为 Blocked，并补充 User Story、Story Relationships 和 Open Questions。 | S-002 依赖尚未实现的 S-001，不能标记为可进入开发。 |
| 3 | 2026-07-13 | 重写 User Story，移除 Dev Cadence、PRD 和 workflow 实现表述。 | User Story 应表达用户目标和价值，而不是内部实现方式或交付物。 |
| 4 | 2026-07-13 | 将增量治理范围对齐到 PRD 与 Business Architecture 两文档基线。 | S-001 已确定两份文档共同构成产品设计基线，后续增量流程不能继续使用单一 PRD 模型。 |
| 5 | 2026-07-14 | 将状态更新为 Ready。 | S-001 已通过 Business Acceptance，前置依赖满足。 |
