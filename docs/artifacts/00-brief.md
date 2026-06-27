# 00-brief.md

## 目的

`00-brief.md` 记录用户请求、目标、背景、约束、初始风险、假设、开放问题和初始 workflow classification。

## 写入阶段

`intake` 和 `classify`。

## 写入者

Supervisor 记录或协调这个 artifact。

## 必要输入

- 最新用户请求。
- 仓库指令和已知约束。
- 初始风险和 workflow signals。

## 记录内容

- `task_id`
- `requested_by`
- `goal`
- `background`
- `constraints`
- `workflow_hint`
- `selected_workflow`
- `selection_reason`
- lightweight path 使用时被跳过的状态

## Gate 影响

这个 artifact 支持 workflow selection 和 task-class classification。它本身不能让 G1 通过。

## 如何阅读

阅读它可以理解任务要达成什么，以及 Supervisor 为什么选择某个 workflow。

## 模板来源

- [templates/spec/00-brief.md](../../templates/spec/00-brief.md)
- [references/spec-templates.md](../../references/spec-templates.md)
