# B-007 问题诊断记录

- Status: `in_progress`
- Work Item: [B-007 当前可并行实施表混用卡片状态与流程入口资格](../../../../docs/bugs/B-007-parallel-work-table-entry-qualification.md)
- Workflow: `bug-fix`
- Diagnosis Branch: `codex/b-007-parallel-work-table-qualification`
- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`

## 报告症状

当前可并行实施表用一个 `状态` 字段同时呈现工作项生命周期、依赖阻塞和是否可以启动下游 Workflow。`Draft` Bug 实际可以进入 `bug-fix` 问题诊断，但表尾的统一说明又将 `Draft` 概括为不能进入实施，用户无法判断可以启动哪一层流程。

## 预期行为

并行视图应保留规范工作项状态，同时单独表达下一步 Workflow 和入口门禁。`Draft Bug` 可以进入 `bug-fix` 诊断，但不能跳过 Repair Solution、Repair Plan 或直接修改代码；Story、Task 和 Bug 继续遵循各自的入口规则。`Blocked` 只表示依赖阻塞，不代表卡片成熟度。

## 实际行为

`docs/backlog.md:148-150` 的表头只有“状态”，序号 3 的 B-005、B-007、B-008 显示为 `Draft`；`docs/backlog.md:168` 又说明 `Draft` 不能直接进入实施。与此同时，`src/skills/work-item-planning/SKILL.md:268-272` 明确规定 Story、Task、Bug 的入口差异，其中 Bug 可在没有 `Ready` 前置条件且没有确认根因时进入 `bug-fix`。

## 影响范围

直接影响 Backlog 并行视图的阅读和 Workflow 路由判断，至少覆盖 Draft Story、Draft Task、Draft Bug 以及 Blocked 工作项。问题不改变规范状态枚举、依赖关系、并行序号、用户授权要求或各下游 Workflow 的实际门禁；它使这些规则无法在同一视图中被准确表达。

## 复现证据

1. 打开 `docs/backlog.md` 的“当前可并行实施表”。
2. 观察表格只有 `序号 | 可并行工作项 | 前置条件 | 状态` 四列，不能从字段识别下一步 Workflow。
3. 对照表尾 `Draft` 说明与 `src/skills/work-item-planning/SKILL.md:272` 的 Bug 入口规则，得到同一状态在视图说明中表示“不能进入实施”、在入口规则中却允许启动诊断的冲突。
4. 运行 `bash scripts/build.sh` 后执行 `bash tests/run-all.sh`，现有测试全部通过；现有测试没有覆盖并行视图字段语义。

## 根因分析

### RC-001：并行视图缺少入口资格维度

- 证据：表头仅有一个 `状态` 字段，既没有卡片类型/下一步 Workflow，也没有入口门禁字段。
- 结果：用户必须把 Backlog 状态说明、卡片正文和 Workflow 规则手工拼接，容易把“可启动诊断”误读成“可直接实施”。
- 置信度：高。

### RC-002：视图标题和表尾说明只表达了实施候选，未表达流程推进候选

- 证据：表名为“当前可并行实施表”，表尾只定义 `Draft` 和 `Blocked` 的状态含义，未说明候选项可以停在哪个 Workflow 阶段。
- 结果：`Draft Bug` 的合法诊断入口无法被视图直接识别。
- 置信度：高。

### RC-003：契约测试分别验证状态和入口，没有验证视图组合

- 证据：`tests/work-item-planning-contract.sh` 验证规范状态及 Bug 入口，但没有读取或断言 `docs/backlog.md` 的并行表列和行语义。
- 结果：规则契约测试全绿仍无法阻止视图出现语义混用。
- 置信度：高。

## Bug 确认结论

当前证据足以确认 B-007 是真实的 Backlog 并行视图契约缺陷，不是状态枚举或 Bug Fix 入口规则本身错误。修复应增加独立的入口资格表达，同时保持既有状态、依赖、排序和授权边界不变。

## 当前未决问题

- 需要在 Repair Solution 中确认并行视图保留原名称还是改为“当前可并行推进表”；此前建议保留原名称并增加独立的入口资格列。
- 需要为 Story、Task、Bug 和 Blocked 行定义最小、可直接阅读的入口资格文本与契约断言。

