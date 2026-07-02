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
- `Tools and environment`: allowed/denied tools、network/secret/permission policy
- `Required evidence`: 本次 run 必须生成或引用的 evidence 文件
- `Limits`: budget、timeout、max iterations

## Gate 影响

`run-context.md` 支撑后续证据判断。缺少它时，Supervisor 和 gates 无法确认 run 是否在授权边界内执行。

## 如何阅读

先看 `What this run is allowed to do`，确认 allowed write paths 和 forbidden paths 是否清楚；再看 `Required evidence` 和 `Limits`，判断后续 claims 是否有足够证据支撑。
