# diff-summary.md

## 目的

`diff-summary.md` 记录文件变更、行为变化、风险区域和回滚提示。

## 写入阶段

Run 中发生文件变更时。

## 写入者

Harness 或 Developer via Harness。

## 记录内容

- planned files
- changed files
- untracked task files
- deleted files
- behavior changes
- risk areas
- rollback notes
- scope reconciliation notes

## Gate 影响

`diff-summary.md` 支撑 scope reconciliation、G4 和 G5。缺少 tracked 或 untracked task files 会阻塞 review approval。

## 如何阅读

将 changed files 与 [03-tasks.md](../artifacts/03-tasks.md)、[05-implementation.md](../artifacts/05-implementation.md) 和实际 worktree status 对比，确认是否超出计划范围。

## 模板来源

- [templates/runs/diff-summary.md](../../templates/runs/diff-summary.md)
- [references/spec-templates.md](../../references/spec-templates.md)
