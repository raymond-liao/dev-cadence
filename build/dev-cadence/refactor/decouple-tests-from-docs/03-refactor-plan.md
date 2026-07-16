# 自动化测试解除 `docs/` 依赖实施计划

> **面向代理的要求：** 按任务逐项执行本计划。每项任务完成后运行列出的验证，再进入下一项。

**目标：** 删除自动化测试对仓库 `docs/` 文件和目录的直接输入依赖，同时保留对 `src/skills/**` 等权威规则源的契约检查。

**架构：** 只调整两个 shell 契约测试的输入边界。`tests/discovery-contract.sh` 继续读取 Discovery skill、入口 skill、安装片段和规则源；`tests/document-conventions-contract.sh` 继续读取共享文档约定和 workflow skill，但不再读取 docs 实例。没有生产代码、workflow 行为或文档资产变更。

**技术栈：** Bash、`rg`、仓库现有 `scripts/check-all.sh`。

## 全局约束

- 不读取、扫描或断言 `$ROOT_DIR/docs/**` 下的仓库文档。
- 不把 docs 文本复制成测试 fixture；本任务不需要文档解析 fixture。
- 保留 workflow 在 skill 中声明的 `docs/...` 目标路径字面量断言。
- 不修改 `src/skills/**`、`src/AGENTS-snippet.md`、`docs/**` 或 `src/vendor/superpowers/**`。
- 每个测试修改都使用现有通过基线进行绿色重构验证，不人为制造失败测试。

---

## Task Overview

| 任务 | 目标 | 文件 | 验证 |
| --- | --- | --- | --- |
| Task 1：解除 Discovery 测试的 docs 输入 | 删除 Discovery workflow、S-002 Story、Backlog 文档变量和断言 | `tests/discovery-contract.sh` | Discovery contract |
| Task 2：解除文档约定测试的 docs 扫描 | 删除工作项目录列表和 docs 实例扫描循环 | `tests/document-conventions-contract.sh` | Document conventions contract |
| Task 3：全量边界与回归验证 | 确认无 docs 输入残留且全仓检查通过 | `tests/*.sh`、`scripts/*.sh` | `rg`、whitespace、`check-all` |

## 详细任务

### Task 1：解除 Discovery 测试的 docs 输入

**文件：**

- 修改：`tests/discovery-contract.sh`
- 不修改：`src/skills/discovery/SKILL.md`、`src/skills/using-dev-cadence/SKILL.md`、`src/AGENTS-snippet.md`

**接口：**

- 保留：对 `DISCOVERY_SKILL`、`ENTRY_SKILL`、`AGENTS_SNIPPET` 的契约断言。
- 删除：`DISCOVERY_WORKFLOW`、`S002_STORY`、`BACKLOG` 三个 docs 路径变量及其唯一对应断言。

- [ ] **步骤 1：删除 docs 路径变量**

删除以下变量定义：

```bash
DISCOVERY_WORKFLOW="$ROOT_DIR/docs/workflows/discovery.md"
S002_STORY="$ROOT_DIR/docs/stories/S-002-discovery-prd-incremental-versioning.md"
BACKLOG="$ROOT_DIR/docs/backlog.md"
```

- [ ] **步骤 2：删除 docs 文本断言**

删除脚本末尾两条仅读取 docs 文档的断言：

```bash
assert_match "workflow proposal gate" '确认前.*权威.*保持原样|权威.*确认前.*保持原样' "$DISCOVERY_WORKFLOW"
assert_match "story proposal gate" '确认前.*权威.*保持原样|权威.*确认前.*保持原样' "$S002_STORY"
```

不得把这两条断言复制到测试内字符串。相关运行规则已经由本脚本对 `DISCOVERY_SKILL` 的源规则断言覆盖。

- [ ] **步骤 3：运行聚焦测试**

运行：

```bash
bash tests/discovery-contract.sh
```

预期：输出 `Discovery contract checks passed.`，退出码为 0。

### Task 2：解除文档约定测试的 docs 扫描

**文件：**

- 修改：`tests/document-conventions-contract.sh`
- 不修改：`.dev-cadence/skills/document-conventions/SKILL.md`、`src/skills/**`、`docs/**`

**接口：**

- 保留：对共享约定 skill、入口 skill、Discovery/Feature/Bug Fix/Refactor workflow skill 的规则断言。
- 删除：`WORK_ITEM_DIRS` 数组和遍历 `docs/features`、`docs/stories`、`docs/bugs`、`docs/tasks` 的检查循环。

- [ ] **步骤 1：删除工作项目录列表**

删除以下数组：

```bash
WORK_ITEM_DIRS=(
  "$ROOT_DIR/docs/features"
  "$ROOT_DIR/docs/stories"
  "$ROOT_DIR/docs/bugs"
  "$ROOT_DIR/docs/tasks"
)
```

- [ ] **步骤 2：删除 docs 实例扫描循环**

删除从 `for work_item_dir in "${WORK_ITEM_DIRS[@]}"; do` 开始、逐个文件断言 `## ✅ 范围` 和 `## ❌ 非范围` 的完整循环。

不要在测试中添加固定 Markdown 样本；共享 heading 语义已经由 `CONVENTIONS_SKILL` 的源文本断言覆盖。

- [ ] **步骤 3：运行聚焦测试**

运行：

```bash
bash tests/document-conventions-contract.sh
```

预期：输出 `Document conventions contract checks passed.`，退出码为 0。

### Task 3：全量边界与回归验证

**文件：**

- 检查：`tests/*.sh`
- 运行：`scripts/check-whitespace.sh`、`scripts/check-all.sh`

- [ ] **步骤 1：检查 docs 输入残留**

运行：

```bash
rg -n '\$ROOT_DIR/docs|DISCOVERY_WORKFLOW|S002_STORY|WORK_ITEM_DIRS|find .*docs' tests --glob '*.sh'
```

预期：无输出、退出码为 1；测试中不得保留仓库 docs 文件或目录作为输入。

- [ ] **步骤 2：运行格式检查**

运行：

```bash
bash scripts/check-whitespace.sh
```

预期：退出码为 0。

- [ ] **步骤 3：运行完整回归**

运行：

```bash
bash scripts/check-all.sh
```

预期：构建、契约、whitespace 和其他仓库检查全部通过，退出码为 0。

- [ ] **步骤 4：记录实现与审查证据**

在 `04-refactor-record.md` 记录修改文件、删除的 docs 输入、每个聚焦测试结果、完整回归结果和当前提交身份；在 `04-code-review-report.md` 记录完整 diff 审查结论。任何失败按 Refactor flow 的 failure classification 路由，不通过删除或放宽剩余源规则断言来隐藏失败。

## 完成条件

- 两个直接 docs 输入点已删除。
- 测试仍覆盖权威 `src/skills/**` 和安装/运行时契约。
- docs 输入残留检查无输出。
- 聚焦测试、whitespace 检查和 `bash scripts/check-all.sh` 均通过。
- 实现记录和代码审查记录可追溯到本计划和确认的方案。
