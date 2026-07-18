# S-017 工作项卡片与开发 Workflow 接入

## 基本信息

- ID：`S-017`
- Version：`4`
- Status：`Blocked`
- Priority：`P1`
- Change Type：Feature

## 目标

打通 Work Item Planning、Work Item Analysis、工作项卡片与 `feature-dev`、`bug-fix`、`refactor`，实现按意图路由、版本引用、职责边界和生命周期回写。

## 背景

工作项卡片只有被入口选择器和开发 workflow 稳定消费，才能成为长期权威定义。当前开发流程尚未统一检查卡片、引用版本或回写交付状态。

## ✅ 范围

- 更新 `using-dev-cadence`，根据用户目标、工作项类型、现有卡片和成熟度选择 Work Item Planning、Work Item Analysis 或 Delivery Workflow。
- 当用户明确要求按 `docs/backlog.md` 继续实施时，由 `using-dev-cadence` 以“待处理”行顺序为权威，在路由下游 workflow 前选择第一张可推进的工作项；“当前可并行实施表”只辅助识别依赖和并行关系，不形成另一套领取顺序。
- 工作项被选中后、切换任务分支或创建 worktree 前，必须将卡片状态更新为 `In Progress`，并将对应 Backlog 行移动到“进行中”；卡片与 Backlog 必须保持一致。
- 工作项领取属于 `using-dev-cadence` 的入口编排步骤。规则较长时可拆为该 skill 按需读取的 supporting reference；除非满足仓库 Skill 准入原则，否则不新增 workflow skill 或共享能力 skill。
- 只有明确的实施请求可以触发工作项领取；方案讨论、卡片维护、工作项分析、普通状态查询或仅评估是否建卡不得把工作项更新为 `In Progress`。
- 明确 `Draft Story -> work-item-analysis -> Ready Story -> feature-dev` 的默认路由和 Story 开发门禁。
- Task 可以选择先进入 Work Item Analysis，也可以在对应 Delivery Workflow 第一阶段补充并确认目标、范围和完成条件。
- Bug 可以选择先进入 Work Item Analysis，也可以直接进入 `bug-fix`；缺少 `Ready`、完整复现步骤或已知根因不得阻止诊断启动。
- 缺少卡片时按当前意图选择创建入口：规划或登记进入 Work Item Planning，定义分析进入 Work Item Analysis，直接 Bug 调查由 Bug Fix 创建或补充 Bug 卡片。
- 在开发 workflow 第一阶段记录卡片路径、版本和本次选定范围。
- 明确卡片与第一阶段记录的权威职责边界。
- 写回前检查当前卡片版本；运行中卡片升版由选中的 Delivery Workflow 通过 Active Task Change Handling 判断影响，并在实施前方案新鲜度门禁或最早受影响阶段重新确认。
- 在开始、返工、验收和 Completion 后回写状态与交付引用。
- 对三个开发 workflow 建立类型和路由契约。

## ❌ 非范围

- 不在本 Story 中实现卡片创建 workflow。
- 不在本 Story 中实现 Work Item Analysis 的分析规则。
- 不重新设计 Story Map 或 Backlog 看板。
- 不把 workflow 内部阶段提升为工作项状态。
- 不新增独立的工作项领取 workflow 或 shared capability skill。
- 不在本 Story 中审计或重构其他既有 skill 的数量与边界。

## 验收标准

1. 入口能够按用户意图、工作项类型和卡片成熟度选择 Planning、Analysis 或对应 Delivery Workflow。
2. `feature-dev` 只接收经过用户确认的 `Ready Story`，Task 和 Bug 使用各自明确的非统一门禁。
3. 已有卡片被复用；缺卡时由当前职责对应的 workflow 创建，不产生重复 ID 或平行卡片。
4. 每个开发 run 引用精确卡片路径、版本和本次范围，不复制完整卡片形成第二份权威定义。
5. 工作项状态、交付结果和 Backlog 投影在关键生命周期节点正确回写。
6. 卡片升版后能够判断当前 run 是否受影响并路由到最早受影响阶段。
7. 用户明确要求按 Backlog 继续实施时，入口以“待处理”行顺序为权威；首项不能推进时先完成经确认的排序调整，不静默跳过，再同步更新选中卡片与 Backlog 为 `In Progress`，最后才切换任务分支、创建 worktree 或进入下游 workflow。
8. 讨论、评估、卡片维护和工作项分析不会触发工作项领取；同一请求不会重复领取已经处于 `In Progress` 的工作项。
9. 工作项领取规则由 `using-dev-cadence` 编排并复用既有能力，不新增未满足 Skill 准入原则的 skill。

## Story Relationships

- Follows：`S-015` 工作项规划 Workflow 与工作项契约。
- Follows：`S-016` 统一 Backlog 看板。
- Follows：`S-037` 工作项分析 Workflow。
- Follows：`B-009` 待处理排序与并行视图职责不一致。
- Precedes：`T-002` 需求治理端到端验证与安装契约。

## 依赖

- `S-015` 工作项规划 Workflow 与工作项契约。
- `S-016` 统一 Backlog 看板。
- `S-037` 工作项分析 Workflow。
- `B-009` 待处理排序与并行视图职责不一致。

## Open Questions

- 无。

## 相关文档

- [工作项规划流程](../workflows/work-item-planning.md)
- [S-015 工作项规划 Workflow 与工作项契约](S-015-work-item-planning-workflow-contract.md)
- [S-016 统一 Backlog 看板](S-016-unified-backlog-board.md)
- [S-037 工作项分析 Workflow](S-037-work-item-analysis-workflow.md)
- [B-009 待处理排序与并行视图职责不一致](../bugs/B-009-pending-order-parallel-view-authority.md)
- [T-002 需求治理端到端验证与安装契约](../tasks/T-002-requirements-governance-end-to-end-validation.md)
- [Backlog](../backlog.md)

## Change Log

| Version | Date | Change | Reason |
|---:|---|---|---|
| 1 | 2026-07-14 | 创建工作项卡片与开发 Workflow 接入 Story。 | 建立工作项权威定义到开发交付的完整消费和回写链路。 |
| 2 | 2026-07-15 | 增加 Work Item Analysis、按类型启动门禁、缺卡职责路由和版本变化处理，并将状态更新为 Blocked。 | 工作项规划与分析方案已经确认共享卡片维护权，开发入口不能继续把所有缺卡请求机械路由到 Planning。 |
| 3 | 2026-07-18 | 增加按当前可并行实施表领取工作项、启动前同步卡片与 Backlog、入口编排所有权和 Skill 准入边界；删除“开发 run 进行中卡片升版时由哪个 workflow 阶段负责影响判断”和“领取工作项时如何处理 Git 落盘”两项 Open Question；将状态更新为 Ready。 | 卡片升版由选中的 Delivery Workflow 通过 Active Task Change Handling 处理，并在实施前方案新鲜度门禁或最早受影响阶段重新确认；领取动作由 `using-dev-cadence` 在分支或 worktree 准备前编排，具体 Git 落盘方式属于技术方案。两项问题均已闭环，不再阻塞工作项定义。 |
| 4 | 2026-07-18 | 将工作项领取顺序改为以待处理行序为权威，增加 B-009 前置依赖，并将状态更新为 Blocked。 | 并行表只是待处理顺序的辅助视图；S-017 必须等待 B-009 统一排序权威和视图职责后再实施。 |
