# 03-tasks.md

## 目的

`03-tasks.md` 将已接受的 requirements 和 design constraints 转换为有边界、可执行的任务。

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

## Gate 影响

只有任务有边界、可执行、映射到 acceptance criteria，并包含 verification planning 和 escalation rules 时，G3 才能通过。

## 如何阅读

把它当作 implementation contract：哪些文件被授权修改、哪些工作被禁止、必须产出哪些证据。

## 模板来源

- [templates/spec/03-tasks.md](../../templates/spec/03-tasks.md)
- [references/spec-templates.md](../../references/spec-templates.md)
