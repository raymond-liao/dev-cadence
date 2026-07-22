# S-038 技术方案

## 已确认需求来源

- Requirements: `build/dev-cadence/feature-dev/s-038-work-item-relative-size-estimation/01-requirements.md`
- Requirements SHA-256: `b55f1f9ffaee8506f03f8924af7987318cdabe4263222885b311680d5ff26bc2`

## Codebase Exploration Findings

- Work Item Planning 已拥有 Story Map、卡片、Backlog、确认门和计划资产同步的权威边界；Size 不能成为竞争性的独立 skill。
- Story Map 只承载 Story 和 Task；Bug 必须保留在 Backlog。Backlog 生命周期表固定为五列，不能把 Size 塞入该表或改变排序契约。
- Work Item Analysis 已禁止自行修改 Size；Delivery workflow 对卡片实质范围变化的处理可补充为只标记重新估算需要。
- `tests/work-item-planning-contract.sh` 已覆盖卡片、版本和 Backlog 契约，是 Size planning 行为的主测试入口。

## 备选方案

### 方案 A：Planning 内的条件性 Relative Size Estimation（推荐）

在既有 Story Map 形成或增量更新后，提出 `M` 基准候选并等待用户确认；随后生成相对 Size 提案，并在现有 Planning Result Confirmation 中原子写入 Planning 资产。

优点：复用 Planning 所有权与确认门，避免引入新 workflow、容量模型或平行资产。

### 方案 B：给所有 Backlog 生命周期表增加 Size 列

优点：一眼可见。缺点：破坏五列表与 Backlog 只做卡片摘要的既有契约，扩大全部生命周期写回范围。

### 方案 C：只在卡片和 Story Map 保存 Size

优点：改动最小。缺点：不满足 Size 在 Backlog 同步和独立 Task/Bug 可审阅的验收标准。

## ✅ 选定方案

采用方案 A。

### Size 与基准契约

- 唯一等级为 `XS | S | M | L | XL | ?`；它表示相对工作量、复杂度和已知不确定性，不映射人日或工期。
- Planning 提出范围清楚、规模适中、代表性足够的基准卡候选及理由；用户确认后该卡为 `M`。
- Story Map 记录 Baseline Work Item、Baseline Card Version、选择理由和 `Needs Size Re-estimation: yes|no`。这只是 planning 提示，不新增工作项状态。
- 卡片记录 `Size`；失效时记录 `Needs Size Re-estimation: yes` 与原因。Size 确认、失效与重新估算写入 Change Log，但不递增卡片 Version。

### 投影与失效

- Story Map 显示 Story/必要 Task 的 Size、Path/Milestone 分布，以及 `XL`、`?` 和显著不确定性。
- Bug 和独立 Task 不进入 Story Map；当其位于明确的估算范围或将进入 Iteration Plan 时，仍使用同一基准估算。
- Backlog 保持原五列生命周期表，新增独立 `Size Summary` 投影，列为 `ID | Size | Needs Re-estimation`。
- 基准卡删除、`Superseded` 或 Version 与基准快照不一致时，必须重新选择并确认基准。非基准卡实质范围变化时，改变该卡的 workflow 只设置重新估算标记并移交 Planning，不得自行改 Size。

## 受影响边界

- `src/workflows/work-item-planning/SKILL.md`
- `src/workflows/feature-dev/SKILL.md`
- `src/workflows/bug-fix/SKILL.md`
- `src/workflows/refactor/SKILL.md`
- `src/workflows/work-item-analysis/SKILL.md`
- `tests/work-item-planning-contract.sh`
- `tests/work-item-analysis-contract.sh`
- `tests/workflow-symmetry.sh`

不创建 Iteration Plan、容量模型、独立估算 skill，且不改 `S-039` 的范围。

## 验证策略

扩展 Planning 契约测试，覆盖首次估算、基准复用、基准失效、`?` 保留、`XL` 与不确定性呈现、三处投影同步、Size-only 不升版本、Backlog 五列表不变和独立 Size Summary。扩展 Analysis 与 workflow symmetry 测试，验证其他 workflow 只标记而不修改 Size。最终运行构建、全量检查与 whitespace 检查。

## Open Questions

无。
