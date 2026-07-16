# 重构实施记录：解除自动化测试对 `docs/` 的依赖

## 状态

✅ `confirmed` - 实施修改已完成，代码审查无发现。

## 实施基线

- 实施基线提交：`2bf044694cd70e543d782880fdd7cec3f6a6030f`
- 工作区：`.worktrees/decouple-tests-from-docs`
- 分支：`codex/decouple-tests-from-docs-worktree`
- 方案来源：[重构方案](02-refactor-solution.md)
- 计划来源：[重构计划](03-refactor-plan.md)

## 修改内容

- `tests/discovery-contract.sh`
  - 删除 `DISCOVERY_WORKFLOW`、`S002_STORY`、`BACKLOG` 三个 `docs/` 路径变量。
  - 删除读取 Discovery workflow 和 S-002 Story 的两条自然语言断言。
  - 保留对 `src/skills/**`、`src/AGENTS-snippet.md` 和其他运行时契约的断言。
- `tests/document-conventions-contract.sh`
  - 删除 `WORK_ITEM_DIRS` 数组。
  - 删除扫描 `docs/features`、`docs/stories`、`docs/bugs`、`docs/tasks` 的工作项实例检查循环。
  - 保留对共享文档约定 skill 和 workflow skill 源规则的断言。

没有新增 fixture、生产代码、workflow 行为或 docs 文档变更。

## 验证证据

已通过：

- `bash tests/discovery-contract.sh`
- `bash tests/document-conventions-contract.sh`
- `bash scripts/check-whitespace.sh`
- `bash scripts/check-all.sh`
- `rg -n '\\$ROOT_DIR/docs|DISCOVERY_WORKFLOW|S002_STORY|WORK_ITEM_DIRS|find .*docs' tests --glob '*.sh'` 无输出，退出码为 1。

## 风险与处理

- docs 实例不再作为自动化测试输入；这是确认方案要求的行为。
- 未发现需要迁移到测试内 Markdown fixture 的可执行解析行为。
- 最终回归报告已补充，业务验收尚未完成。

## Executing-Plans Commit Review Ledger

本次变更在单一实现提交中完成。提交前已执行聚焦测试、whitespace 和完整 `check-all`；提交后的代码审查将以实现基线到实现提交的完整 diff 为范围，并在本记录中补充实际提交身份和审查结论。

| Review ID | 单元 | 状态 | Identity | Expected parent | Reviewed tree | Commit hash | 决定 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `review-implementation-1` | `plan-tasks-1-and-2` | ✅ `verified` | `retrospective` | `2bf044694cd70e543d782880fdd7cec3f6a6030f` | `b3b1b43fa1d318e1d5f515bcd3ba3978d45888a5` | `fe6997d26c363063fd6d948cfa41379fb05f7014` | 独立审查无 Critical/Important/Minor 发现；为提交后回顾证据。 |
