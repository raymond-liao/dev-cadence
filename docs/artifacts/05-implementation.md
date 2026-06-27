# 05-implementation.md

## 目的

`05-implementation.md` 记录实际改了什么、为什么改、scope 如何 reconcile、产出了哪些证据，以及还剩哪些限制。

## 写入阶段

`implementation` 和 `fix`。

## 写入者

Developer。

## 必要输入

- [03-tasks.md](03-tasks.md)
- 已批准的 requirements 和 design
- [Harness 运行证据](../runs/)
- 实际 diff 和 worktree status

## 记录内容

- planned files 和 changed files
- unplanned changed files 和 deleted files
- added components
- scope reconciliation
- implementation notes
- TDD 或 substitute-feedback 证据
- test commands 和 results
- known limitations 和 follow-up

## Gate 影响

这个 artifact 支撑 G4 和 G5。只有 implementation notes、diff summary 和 scope reconciliation 一致时，Review 才能安全 approve。

## 如何阅读

阅读它可以理解实际变更是什么，以及变更是否保持在已授权计划内。

## 模板来源

- [templates/spec/05-implementation.md](../../templates/spec/05-implementation.md)
- [references/spec-templates.md](../../references/spec-templates.md)
