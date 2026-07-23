# B-009 Repair Solution

- Workflow: `bug-fix`
- Work Item: [B-009 待处理排序与并行视图职责不一致](../../../../docs/delivery/bugs/B-009-pending-order-parallel-view-authority.md)
- Status: ✅ `confirmed`
- Confirmed scope source: 本次委派输入中的 B-009 范围确认

## Root Cause Being Fixed

Work Item Planning 没有把 `待处理` 行顺序声明为所有 Backlog 实施视图的唯一权威，并把并行表的排序和逐行入口门禁当作独立规划字段。

## Selected Repair Boundary

1. 更新 `src/skills/work-item-planning/SKILL.md`：明确待处理顺序唯一权威；规定并行表是派生视图、保持相对顺序且不得独立排序；规定首项不可推进时先确认调整排序；保留状态生命周期语义并把路由归还 `using-dev-cadence` 与对应 workflow skill。
2. 更新 `docs/backlog.md`：移除并行表的 `下一步 Workflow / 入口门禁` 列，按待处理顺序重排并行视图行，只保留依赖、并行分组和生命周期状态信息。
3. 更新 `docs/stories/S-017-work-item-development-workflow-integration.md`，使已确认的领取定义不再把并行表作为独立顺序来源。
4. 对齐 `docs/workflows/work-item-planning.md`，避免业务流程说明保留被修复的旧约束。
5. 更新契约测试和根版本，运行构建使 `dist/.dev-cadence` 从源文件同步生成；不直接编辑 `dist`。

## Related Behavior And Regression Scope

- Work Item Planning 仍是 Backlog 结构、生命周期区块和规划顺序的所有者。
- Backlog 五列生命周期表、工作项状态枚举、依赖表和用户授权语义保持不变。
- `using-dev-cadence` 仍是跨 workflow 路由入口；本修复不实现自动领取、自动排序或完整 S-017 接入。
- B-005、B-007、B-008 的历史状态和卡片正文不变。

## Acceptance Criteria

- 契约测试验证待处理顺序唯一权威和并行视图派生关系。
- 并行表无 `下一步 Workflow / 入口门禁` 列，也无逐行 workflow 路由复制。
- 并行视图按待处理顺序保持工作项相对顺序，并只补充依赖/并行分组。
- 首项不可推进时的“先确认调整排序、不得静默跳过”规则存在于源 skill。
- S-017 的领取定义、流程文档、测试和构建分发包彼此一致。

## Behavior That Must Remain Unchanged

- 不修改 B-009 已完成的领取提交或重复写入 `In Progress`。
- 不改变状态枚举、Priority、Dependency Table 语义和各 workflow 入口门禁。
- 不新增 skill，不实现完整 S-017 领取功能，不提交或修改本机配置和秘密文件。

## Tradeoff And Risk

并行表继续保留 `序号` 列作为派生的并行分组/阅读索引，但其行顺序和分组必须由待处理顺序与依赖推导，不能被维护成另一套实施顺序。这样保持既有 AI 读取结构，同时删除重复路由字段；测试会锁定来源关系而非具体算法。
