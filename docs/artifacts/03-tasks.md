# 03-tasks.md

## 目的

`03-tasks.md` 将已接受的 requirements 和 design constraints 转换为有边界、可执行的任务。它是 Markdown-first artifact，不是 YAML task list。

## 写入阶段

`planning`。

## 写入者

Planner。

## 必要输入

- [01-requirements.md](01-requirements.md)
- 存在时读取 [02-design.md](02-design.md)
- Task class 和 workflow

## 记录内容

- task class 和 selected workflow
- executable tasks
- dependencies
- planned components
- target files
- forbidden actions
- acceptance mapping
- verification plan
- verification coverage matrix
- Gate G3 record

任务本体必须使用稳定的 Markdown `Task N` heading，例如 `### Task 1: ...`。每个任务应保留 `**Files:**`、`**Interfaces:**` 和 checkbox execution steps，让 `cadence-subagent-development` 可以用 `task-brief` 抽取单个 Worker handoff，而不解析 YAML `tasks:`。

## Gate 影响

只有任务有边界、可执行、映射到 acceptance criteria，并包含 verification planning 和 escalation rules 时，G3 才能通过。

## 如何阅读

把它当作 implementation contract：哪些文件被授权修改、哪些工作被禁止、必须产出哪些证据。Human 或 Reviewer 应能直接阅读 Markdown 任务 section；checker 只读取必要的稳定 heading、labels、tables 和 checklist。Gate 状态仍由 Supervisor/Harness/checker 判断，`03-tasks.md` 只提供 G3 所需的计划证据。
