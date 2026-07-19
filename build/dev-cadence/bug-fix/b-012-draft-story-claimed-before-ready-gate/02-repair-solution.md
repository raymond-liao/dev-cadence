# B-012 修复方案

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Card Version: `1`
- Diagnosis source: `build/dev-cadence/bug-fix/b-012-draft-story-claimed-before-ready-gate/01-problem-diagnosis-record.md`
- Decision: ❓ `pending`

## 根因与修复边界

根因是 `using-dev-cadence` 将“明确实施意图”和“Story 成熟度”写成两个顺序未约束的入口条件，claim 写入位于 Draft Story 路由之后。修复应在唯一入口所有者内建立不可跳步的领取资格矩阵：选择工作项 -> 读取类型、状态和成熟度 -> 判定路由与领取资格 -> 仅对合格项原子 claim -> 准备 branch/worktree -> 进入 Delivery Workflow。

## 方案比较

### 方案 A：增加最小前置保护句

在 claim 规则前增加“任何 claim 前必须先解析类型、状态和成熟度”的硬门禁，并补充顺序测试。修改面小，但分类与 claim 仍分散在相邻条款中，未来编辑可能重新制造歧义。

### 方案 B：入口内建立有序领取资格矩阵（推荐，待确认）

在 `src/skills/using-dev-cadence/SKILL.md` 的 `Work Item Intake And Claiming` 内集中表达四类场景：Draft Story 先进入 `work-item-analysis` 且确认前不 claim；Ready Story 可 claim 并进入 `feature-dev`；Task 无需 Ready；Bug 无需 Ready、完整复现或已知根因。测试同时锁定场景和文本顺序。

该方案直接修复已确认根因，保持规则所有权不变，推荐作为当前修复方案。

### 方案 C：抽取领取资格 supporting reference

新增入口 supporting reference 保存资格矩阵，由入口在 claim 前读取。隔离性较好，但当前规则规模不足以抵消新增引用、加载和双文件协调成本，并增加漏读 reference 的失败模式。

## 预计修改与影响

- 可能修改：`src/skills/using-dev-cadence/SKILL.md`、`tests/work-item-development-workflow-contract.sh`，必要时补充 `tests/install-contract.sh` 断言；通过 `bash scripts/build.sh` 同步 `dist/.dev-cadence`，并按行为变化评估根目录 `version`。
- 不修改：`src/skills/work-item-analysis/SKILL.md`、`src/skills/feature-dev/SKILL.md`、`src/skills/work-item-planning/SKILL.md`、B-011 相关 worktree 时点规则和历史卡片。
- 相关影响：入口路由、卡片与 Backlog claim 时点、source/dist/安装包一致性。

## 必须保持不变

- 只有明确 implementation、repair、refactor 请求可 claim；待处理顺序仍是唯一选择权威。
- claim 仍在 branch/worktree 准备之前，且继续原子同步卡片与 Backlog、保持幂等和 Version/Change Log 语义。
- Work Item Analysis 独占 Story 定义与 Ready 决策，Ready 写入不等于 claim。
- Task 和 Bug 不复制 Story Ready 门禁；不新增 workflow 或工作项状态。

## 回归范围与验收标准

- Draft Story 的成熟度路由和“不 claim、不改 `In Progress`”必须出现在首次 claim 写入之前。
- Ready Story、Task、Bug 分别保留正向 claim 路径。
- 现有 claim、顺序、分析、安装和 source/dist 同步契约继续通过。
- 计划回归：`tests/work-item-development-workflow-contract.sh`、`tests/work-item-analysis-contract.sh`、`tests/work-item-planning-contract.sh`、`tests/routing-contract.sh`、`tests/package-contract.sh`、`tests/install-contract.sh`、`scripts/check-all.sh`。

## 风险与用户决策

主要风险是入口条款和顺序测试再次只检查“存在”而未检查编排顺序；方案 B 通过场景块和相对位置断言缓解。需要用户确认是否采用方案 B；未确认前不创建 Repair Plan 或修改源码。
