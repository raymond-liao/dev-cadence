# S-002 PRD 增量更新与版本治理

## 基本信息

- ID：`S-002`
- Version：`3`
- Status：`Blocked`
- Priority：`P1`
- Change Type：Enhancement

## 目标

让 `discovery` 能够在已有 PRD 基线上持续接收新需求、反馈和范围变化，形成可追溯的新版本，同时保留既有决策和需求历史。

## 背景

PRD 不是一次性文档。首次需求探索完成后，产品目标、范围、约束和决策会继续变化。如果没有明确的增量更新和版本治理规则，代理可能直接覆盖既有需求、丢失历史，或者把未确认内容写成正式基线。

## User Story

作为持续维护软件需求的用户，我希望需求变化能够保留原有共识和变化原因，以便团队始终根据最新确认的需求开展后续工作。

## 范围

- 读取已有 PRD 及其当前版本。
- 支持 `discovery` 的增量更新模式。
- 对新需求、修正、替代、拒绝和未来范围变化进行分类。
- 实质变化时递增 PRD 版本并更新 Change Log。
- 非实质的拼写、排版和链接修正不升版。
- 保留已有 Decision 及其 Accepted、Rejected 或 Superseded 历史。
- 保持 Draft 和 Open Question 的未确认状态。
- 识别 PRD 变化对现有工作项和活动开发任务的潜在影响。
- 获取用户对新 PRD 版本的重新确认。
- 将工作项调整交给后续 `work-item-planning`，不直接静默改写卡片。

## 非范围

- 不重新实现首次 PRD 建立流程。
- 不创建或直接修改 Feature、Story、Bug、Technical Task 和 Roadmap。
- 不决定受影响工作项的最终拆分、状态或实施顺序。
- 不修改目标仓库应用代码。

## 验收标准

1. `discovery` 可以读取现有 PRD 版本，并基于新输入形成增量变更。
2. 业务目标、范围、成功标准、业务规则、约束或产品级 Decision 发生实质变化时，PRD 只递增一个版本并记录变化原因。
3. 只有拼写、排版或链接变化时，PRD 版本保持不变。
4. 既有 Accepted、Rejected 和 Superseded Decision 历史不会被删除或重写成当前决定。
5. Draft 和 Open Question 不会在缺少用户确认时变为 Confirmed。
6. 新 PRD 版本得到用户确认前，不成为后续规划的正式基线。
7. 发现现有工作项可能受影响时，workflow 记录影响并移交 `work-item-planning`，不直接静默修改卡片。

## Story Relationships

- Extends：`S-001` 首次 Discovery 与 PRD 基线。
- Depends On：`S-001` 首次 Discovery 与 PRD 基线。

## 依赖

- `S-001` 首次 Discovery 与 PRD 基线。

## 后续工作

- Work Item Planning workflow 根据确认后的 PRD 版本增量维护 Feature、Story、Bug、Technical Task 和 Roadmap。

## Open Questions

- 无直接开放问题；当前仅被尚未实现的 `S-001` 阻塞。

## 相关文档

- [需求探索流程](../workflows/discovery.md)
- [S-001 首次 Discovery 与 PRD 基线](S-001-initial-discovery-prd-baseline.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-13 | 创建 PRD 增量更新与版本治理 Story。 | 将增量需求治理从首次 Discovery 能力中拆出，形成可独立实施和验证的后续 Story。 |
| 2 | 2026-07-13 | 将状态改为 Blocked，并补充 User Story、Story Relationships 和 Open Questions。 | S-002 依赖尚未实现的 S-001，不能标记为可进入开发。 |
| 3 | 2026-07-13 | 重写 User Story，移除 Dev Cadence、PRD 和 workflow 实现表述。 | User Story 应表达用户目标和价值，而不是内部实现方式或交付物。 |
