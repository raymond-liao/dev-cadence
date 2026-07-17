# S-016 统一 Backlog 看板：需求确认

## 状态

✅ `confirmed`

## 确认依据

用户于 2026-07-17 要求开始实施 S-016。工作项卡片 Version `4`、Status `Ready`，唯一依赖 S-015 Version `7`、Status `Done`。

## ✅ 纳入范围

- 将 `docs/backlog.md` 固化为全局工作项生命周期、优先级、关系、阻塞和建议顺序的汇总视图。
- 使用 `进行中`、`待处理`、`已完成`、`已关闭` 四个生命周期区块及统一 Markdown Table。
- 生命周期表只展示 `ID`、`Title`、`Version`、`Status`、`Priority`，Title 链接到权威卡片。
- 将 Backlog 的创建、结构、排序、增量更新和状态同步规则写入 `src/skills/work-item-planning/SKILL.md`。
- 同步业务说明、契约测试和构建分发结果。

## ❌ 排除范围

- 不实现 S-037 Work Item Analysis。
- 不修改 Story Map、Milestone、Iteration Plan 或 Size 估算规则。
- 不新增状态，不改变既有工作项定义、依赖或优先级。
- 不更新“当前可并行实施表”的排序。
- 不直接编辑 `dist/.dev-cadence/**`。

## 验收标准

1. `docs/backlog.md` 使用四个生命周期表格。
2. 四个表格使用五列：`ID`、`Title`、`Version`、`Status`、`Priority`。
3. `待处理` 行顺序继续表达建议实施顺序，不新增独立 `Order` 字段。
4. Backlog 不复制卡片详细定义或 Delivery Workflow 内部阶段。
5. Work Item Planning 明确 Backlog 所有权、增量更新边界和关系来源。
6. source、dist、安装包和契约测试保持同步。

## 开放问题与假设

- 已关闭列表的历史合并事件不增加生命周期表字段；由相关卡片 Change Log 和现有关闭说明承载。

## 需求来源

- `docs/stories/S-016-unified-backlog-board.md`
- `docs/backlog.md`
- `src/skills/work-item-planning/SKILL.md`

