# S-016 统一 Backlog 看板：技术方案

## 状态

✅ `confirmed`

## 需求来源

本方案基于 [需求确认记录](01-requirements.md) 和 S-016 Version `4`。

## Codebase Exploration Findings

- `src/skills/work-item-planning/SKILL.md` 已定义 `docs/backlog.md` 为权威 Backlog 路径，但当前只描述摘要职责，没有完整的四区块表格契约。
- `docs/backlog.md` 当前仍使用分区 checklist；其现有工作项顺序和 Dependency Table 必须保留，不能被本 Story 的实现机械重排。
- `docs/workflows/work-item-planning.md` 是业务说明，必须与执行 skill 的 Backlog 边界同步，但不取代 skill。
- `tests/work-item-planning-contract.sh` 是当前 Work Item Planning 执行规则的契约入口，适合增加 Backlog 所有权、字段和状态边界断言。

## 方案比较

### 最小变更方案

只更新 `docs/backlog.md` 的表格，不更新执行 skill。实现快，但目标仓库后续无法依赖统一规则生成或维护 Backlog，验收标准不闭环。

### 清晰分层方案

为 Backlog 单独新增 skill 和独立生成器。职责清晰，但会拆分已由 Work Item Planning 统一拥有的规划规则，增加安装结构和路由复杂度。

### ✅ Selected：务实平衡方案

在现有 Work Item Planning skill 中补充完整 Backlog 契约；把当前 `docs/backlog.md` 迁移为该契约的一个权威实例；同步业务说明和契约测试。历史合并信息继续由卡片 Change Log 承载，不把 Backlog 变成运行日志。

## 结构与边界

- 生命周期区块固定为 `进行中`、`待处理`、`已完成`、`已关闭`。
- 每个区块使用 `ID | Title | Version | Status | Priority` 五列；Title 使用相对路径链接到卡片。
- `待处理` 行顺序表达建议实施顺序；依赖、阻塞、Change Type、Size 和详细定义留在卡片或 Dependency Table。
- `Superseded` 和合并来源等历史事实保留在 `已关闭`说明或卡片 Change Log，不新增重复字段。
- 本 Story 不修改 `当前可并行实施表`，也不把 workflow 内部阶段投影到 Backlog。

## 测试策略

- 先在 `tests/work-item-planning-contract.sh` 增加 Backlog 规则的失败断言，再实现 skill 规则。
- 使用 `bash tests/work-item-planning-contract.sh` 验证执行规则；使用 `bash scripts/build.sh` 和 `bash scripts/check-all.sh` 验证 source/dist/package parity。
- 通过源文件检查确认 `docs/backlog.md` 四个区块和五列结构，不为自然语言正文增加脆弱措辞测试。

## 风险与约束

- `docs/backlog.md` 当前存在用户维护顺序，迁移表格时必须保持顺序。
- 两个并行 Story 共享最终版本号；本分支不修改根 `version`，由主代理在集成时统一升级。

