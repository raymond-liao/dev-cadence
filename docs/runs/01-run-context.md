# run-context.md

## 目的

`run-context.md` 记录一次 Harness run 的执行边界：谁在执行、读什么输入、能用哪些工具、能访问哪些路径，以及需要产出哪些证据。

## 写入阶段

每次 Harness run 开始前。

## 写入者

Harness，由 Supervisor 提供必要上下文。

## 记录内容

- `run_id`
- `agent_role`
- `blueprint_path`
- `context_pack_path`
- `workspace_path`
- `allowed_tools`
- `denied_tools`
- `allowed_paths`
- `denied_paths`
- `network_policy`
- `secret_policy`
- `budget`
- `timeout`
- `max_iterations`
- `required_evidence`

## Gate 影响

`run-context.md` 支撑后续证据判断。缺少它时，Supervisor 和 gates 无法确认 run 是否在授权边界内执行。

## 如何阅读

先看 `agent_role`、`allowed_paths`、`denied_paths` 和 `required_evidence`，确认本次执行是否有清楚边界。
