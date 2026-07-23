# S-017 工作项卡片与开发 Workflow 接入 - 需求确认

## 需求来源

- 工作项：[S-017 工作项卡片与开发 Workflow 接入](../../../../docs/delivery/stories/S-017-work-item-development-workflow-integration.md)
- 工作项版本：`5`
- 当前卡片状态：`In Progress`
- Backlog：[统一 Backlog](../../../../docs/delivery/backlog.md)
- 交付流程：`feature-dev`

## ✅ 确认范围

- 更新 `using-dev-cadence`，按用户意图、工作项类型和卡片成熟度选择 `work-item-planning`、`work-item-analysis` 或对应 Delivery Workflow。
- 对明确的实施请求增加工作项领取编排：复用现有卡片；在切换任务分支或创建 worktree 前，将选中卡片与 Backlog 投影同步为 `In Progress`。
- 当用户明确要求按 `docs/backlog.md` 继续实施时，以“待处理”行顺序为权威；“当前可并行实施表”仅辅助识别依赖和并行关系。
- 明确 `Draft Story -> work-item-analysis -> Ready Story -> feature-dev` 的默认路由和 Story 开发门禁。
- 明确 Task 和 Bug 的交付入口边界：Task 可由对应 Delivery Workflow 第一阶段补充目标、范围和完成条件；Bug 可直接进入 `bug-fix` 诊断，不因缺少 `Ready`、完整复现步骤或已知根因阻塞诊断启动。
- 明确缺卡时按当前意图选择创建职责：规划或登记进入 `work-item-planning`，定义分析进入 `work-item-analysis`，直接 Bug 调查由 `bug-fix` 创建或补充 Bug 卡片。
- 要求三个 Delivery Workflow 的第一阶段记录卡片精确路径、Version 和本次选定范围，并保持卡片与 Delivery 记录的权威职责边界。
- 要求运行中在使用卡片事实前检查当前 Version；卡片升版时由对应 Delivery Workflow 的 Active Task Change Handling 判断影响并返回最早受影响阶段。
- 在开始、返工、验收和 Completion 后按生命周期节点回写卡片状态、交付结果、交付引用和 Backlog 投影。
- 增加 source skill、安装包、构建同步和契约测试，覆盖入口路由、卡片复用、成熟度门禁、版本引用、状态回写、Backlog 顺序权威、重复领取防护和三个 Delivery Workflow 的对称契约。

## ❌ 非范围

- 不在本 Story 中实现工作项卡片创建 workflow。
- 不在本 Story 中实现 `work-item-analysis` 的分析规则。
- 不重新设计 Story Map、Backlog 看板或并行分组的规划算法。
- 不把 Workflow 内部阶段提升为工作项状态。
- 不新增独立的工作项领取 workflow 或 shared capability skill。
- 不审计或重构其他既有 skill 的数量与边界。
- 不修改 `src/vendor/superpowers/skills/**`，除非技术方案证明存在不可替代的必要性。

## 验收标准

1. 入口能够按用户意图、工作项类型和卡片成熟度选择 Planning、Analysis 或对应 Delivery Workflow。
2. `feature-dev` 只接收经过用户确认的 `Ready Story`，Task 和 Bug 使用各自明确的非统一门禁。
3. 已有卡片被复用；缺卡时由当前职责对应的 workflow 创建，不产生重复 ID 或平行卡片。
4. 每个开发 run 引用精确卡片路径、Version 和本次范围，不复制完整卡片形成第二份权威定义。
5. 工作项状态、交付结果和 Backlog 投影在关键生命周期节点正确回写。
6. 卡片升版后能够判断当前 run 是否受影响并路由到最早受影响阶段。
7. 用户明确要求按 Backlog 继续实施时，入口以“待处理”行顺序为权威；首项不能推进时先完成经确认的排序调整，不静默跳过，再同步更新选中卡片与 Backlog 为 `In Progress`，最后才切换任务分支、创建 worktree 或进入下游 workflow。
8. 讨论、评估、卡片维护和工作项分析不会触发工作项领取；同一请求不会重复领取已经处于 `In Progress` 的工作项。
9. 工作项领取规则由 `using-dev-cadence` 编排并复用既有能力，不新增未满足 Skill 准入原则的 skill。

## 当前确认的上下文

- S017 是 `Ready Story`，前置依赖 S015、S016 和 S037 已完成。
- 本次用户请求是明确的实施请求，因此允许领取 S017；它不是方案讨论、卡片维护或工作项分析请求。
- S017 卡片状态和 Backlog 投影已同步为 `In Progress`，卡片 Version 保持 `5`；执行状态变化不构成版本或 Change Log 变化。

## 假设与开放问题

- 假设：三个 Delivery Workflow 的现有阶段结构和记录契约继续作为实现边界，S017 只补充工作项接入和回写接口。
- 假设：构建脚本继续将 `src/skills/**` 同步到 `dist/.dev-cadence/**`，安装契约负责验证安装结果。
- 开放问题：无。若技术方案发现现有职责边界无法承载某项验收标准，应返回本阶段重新确认，而不是静默扩张范围。

## 阶段决定

- Status: ✅ `confirmed`
- User Confirmation: delegated by the user on `2026-07-18`; no intermediate confirmation gates are required for this run.
- 下一阶段：直接进入 Technical Solution and Implementation Plan, then Development Implementation.
