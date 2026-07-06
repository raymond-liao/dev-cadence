# run-context.md

## 目的

`run-context.md` 记录一次 Harness run 的执行边界：谁在执行、读什么输入、能用哪些工具、能访问哪些路径，以及需要产出哪些证据。

## 写入阶段

每次 Harness run 开始前。

## 写入者

Harness，由 Supervisor 提供必要上下文。

## 记录内容

- stable labels: `Run ID`、`Task ID`、`Agent role`、`Status`
- `What this run is allowed to do`: blueprint/context/workspace、allowed read/write paths、forbidden paths
- `Git lifecycle context`: branch-based delivery runs record base branch、base commit、delivery branch、worktree path、allowed git actions、commit intent、authorization owner/source、forbidden finalization actions、review base/head/range、read-only review policy；checkpoint/fix authorization requires owner/source；non-branch runs record `N/A`/`none`/`not_applicable_*` rather than invented Git values
- `Tools and environment`: allowed/denied tools、network/secret/permission policy
- `Required evidence`: 本次 run 必须生成或引用的 evidence 文件
- `Limits`: budget、timeout、max iterations

## Gate 影响

`run-context.md` 支撑后续证据判断。缺少它时，Supervisor 和 gates 无法确认 run 是否在授权边界内执行。

## 如何阅读

先看 `What this run is allowed to do` 和 `Git lifecycle context`，确认 allowed write paths、forbidden paths、delivery branch/worktree、commit intent、authorization owner/source 和 forbidden finalization actions 是否清楚；若不是 branch-based delivery，确认相关字段明确为 `N/A`、`none` 或 `not_applicable_*`。再看 `Required evidence` 和 `Limits`，判断后续 claims 是否有足够证据支撑。
