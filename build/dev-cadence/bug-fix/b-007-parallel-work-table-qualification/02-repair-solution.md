# B-007 修复方案

- Status: `confirmed`
- Work Item: [B-007 当前可并行实施表混用卡片状态与流程入口资格](../../../../docs/bugs/B-007-parallel-work-table-entry-qualification.md)
- Diagnosis Source: [B-007 问题诊断记录](01-problem-diagnosis-record.md)
- Decision Authority: `delegated continuation authority from user instruction`

## 根因与修复边界

根因是并行视图只有一个 `状态` 字段，且标题/说明只描述未完成工作项和依赖状态，没有独立表达下一步 Workflow 与入口门禁。修复只调整 Backlog 视图契约、`work-item-planning` 源规则和契约测试，不新增全局状态、不改变真实 Workflow 入口、不自动启动工作项。

## ✅ Selected 修复方法：保留原表名并新增入口资格列

保留 `当前可并行实施表` 名称，将表明确为“工作项候选视图”，并将列扩展为：

`序号 | 可并行工作项 | 前置条件 | 状态 | 下一步 Workflow / 入口门禁`

其中 `状态` 只保留卡片生命周期状态；`下一步 Workflow / 入口门禁` 单独说明：

- Story：进入 `feature-dev` 前必须达到 `Ready`。
- Task：可根据目标进入 `feature-dev`、`bug-fix` 或 `refactor`，但必须先由对应 Workflow 确认范围，不能直接改代码。
- Bug：可进入 `bug-fix` 的 Problem Diagnosis，即使卡片仍是 `Draft`；诊断不等于进入修复实施。
- `Blocked`：表示依赖未满足，与卡片自身成熟度分开解释。

## 备选方案与取舍

### 改名为“当前可并行推进表”

不选择。改名能弱化“实施”歧义，但不能单独表达不同卡片类型的入口门禁，仍需增加独立列；保留既有名称可减少无关引用变更。

### 新增全局 `可启动` 或 `可实施` 状态

不选择。卡片状态枚举必须保持七个规范值，新增派生状态会把 Workflow 内部阶段提升为规划状态。

### ✅ Selected 独立入口资格列

选择此方案。它最小化 Backlog 结构变化，同时直接解决 `Draft Bug` 可以启动诊断但不能直接修改代码的表达问题，并保留既有排序、依赖和用户授权。

## 受影响文件与边界

- 修改 `src/skills/work-item-planning/SKILL.md`，新增 Parallel Work View Contract。
- 修改 `docs/backlog.md` 当前并行表表头、各行入口资格和说明；不重排序号或无关工作项。
- 修改 `tests/work-item-planning-contract.sh` 或新增专项契约脚本，验证源规则和实际 Backlog 视图。
- 运行 `bash scripts/build.sh` 同步安装包；本项不再次递增根目录版本，继承本批次由 B-005 统一递增的 `0.23.0`。

## 修复验收标准

- 并行视图不再用单一状态字段承载入口资格。
- Draft Bug 明确显示 `bug-fix` 诊断入口及“不可直接修改代码”。
- Draft Story、Draft Task、Draft Bug 的入口差异可直接阅读。
- Blocked 明确表示依赖阻塞。
- 七个规范状态、依赖表、序号、排序和授权语义不变。

## 风险

- 现有并行表行按序号合并多个工作项，入口资格列必须覆盖同一行中的所有卡片类型，不能只解释 B-007。
- Backlog 是长期规划资产，不能在列中复制卡片正文或 Workflow 运行记录。

