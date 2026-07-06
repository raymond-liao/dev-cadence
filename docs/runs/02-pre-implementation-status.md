# pre-implementation-status.md

## 目的

`pre-implementation-status.md` 记录 S1/S2 implementation 或 fix 前的 worktree baseline、授权目标文件、artifact 文件和 gate 状态。

## 写入阶段

S1/S2 的 implementation 或 fix run 修改产品文件、测试、migration、build script、deployment config 或 application config 之前。

## 写入者

Harness 或 Developer via Harness。

## 记录内容

- base branch、base commit、delivery branch、worktree path
- dirty preflight result、tracked 和 untracked worktree status
- unrelated local edits 以及 block/quarantine/Human decision 处理方式
- authorized target files
- artifact files
- G1、G2 when required、G3 status
- blocking questions 状态
- `implementation_authorized`
- `post_hoc_backfill`
- post-hoc Human override owner/reason when applicable
- residual risk

## Gate 影响

S1/S2 implementation 或 fix run 缺少这个文件，或它被标记为 `post_hoc_backfill: true` 且没有具名 Human override，会阻塞 G4 和 G5。

## 如何阅读

确认 `Implementation authorized: true` 且 `Post hoc backfill: false`，再检查 base revision、delivery branch/worktree 和 `Authorized target files` 是否覆盖实际修改范围。若 dirty preflight 发现 unrelated local edits，必须记录 block、quarantine 或 Human decision。若 `Post hoc backfill: true`，必须有具名 Human override 和 residual risk 说明。
