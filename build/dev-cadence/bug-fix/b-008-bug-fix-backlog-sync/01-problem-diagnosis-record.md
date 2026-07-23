# B-008 问题诊断记录

- Status: `in_progress`
- Work Item: [B-008 Bug Fix 完成后未更新 Backlog](../../../../docs/delivery/bugs/B-008-bug-fix-completion-does-not-update-backlog.md)
- Workflow: `bug-fix`
- Diagnosis Branch: `codex/b-008-bug-fix-backlog-sync`
- Diagnosis Baseline: `ec0ee0c6b6dc07c30537c9fd1789c3af4165f6f3`

## 报告症状

Bug Fix 可以完成实现、回归验证、Business Acceptance 和 Completion 集成，但对应 Bug 在 `docs/backlog.md` 中仍可能保持 `Draft` 并留在“待处理”，需要人工修正。

## 预期行为

当 Bug Fix 通过 Business Acceptance 且用户在 Completion 中选择保留运行记录的成功集成动作时，应将对应 Bug 的 Backlog 汇总状态更新为 `Done`，并从“待处理”移动到“已完成”。Completion 未完成、被取消、被阻塞或 whole-run Discard 时，不应写入 `Done`。

## 实际行为

`src/skills/bug-fix/SKILL.md:661-706` 定义 Business Acceptance 记录，`src/skills/bug-fix/SKILL.md:708-744` 定义 Completion 和最终记录检查，但没有要求成功集成后定位对应 Bug、修改 `docs/backlog.md` 的状态和生命周期区段。相反，`src/skills/work-item-planning/SKILL.md:294-318` 只定义 Backlog 的结构、状态列和规划侧维护边界，没有承接 Bug Fix Completion 的回写动作。

历史证据显示 B-002 的 Backlog 移动是在后续文档/集成变更中完成的；这说明当前流程依赖人工或额外操作，而不是 bug-fix 完成规则的稳定契约。

## 影响范围

直接影响所有成功完成并保留运行记录的 Bug Fix，尤其是本地 merge、创建 PR 或保留分支的 Completion 路径。失败、取消、阻塞和 whole-run Discard 不应被标记为完成。问题影响 Backlog 汇总状态与 Bug 卡片状态的一致性，不改变 Bug Fix 的 Business Acceptance 固定菜单。

## 复现证据

1. 阅读 `bug-fix` 的 Business Acceptance 与 Completion 规则，找不到成功集成后更新 `docs/backlog.md` 的要求。
2. 阅读 Work Item Planning 的 Backlog 责任规则，只能确认 Backlog 是汇总视图和规划结构所有者，找不到 Delivery Completion 回写触发点。
3. 对比已完成 B-002 的集成提交与当前 Backlog 状态，Backlog 更新存在于额外文档/集成提交中，而不是由 `bug-fix` Completion 契约明确驱动。
4. 运行 `bash scripts/build.sh` 后执行 `bash tests/run-all.sh`，现有测试全部通过；现有测试没有验证成功集成、取消、阻塞和 whole-run Discard 的 Backlog 状态变化。

## 根因分析

### RC-001：Bug Fix Completion 没有定义 Backlog 回写责任

- 证据：Completion 规则记录分支、合并、PR、保留或丢弃结果，但没有定义成功集成后更新 Bug Backlog 行的动作。
- 结果：运行可以进入 `integrated`，而 Backlog 仍保留 `Draft`/“待处理”，需要人工同步。
- 置信度：高。

### RC-002：交付状态与规划汇总之间缺少成功集成触发边界

- 证据：Work Item Planning 定义 Backlog 结构，Delivery Workflow 定义交付结果，但两者之间没有“仅在 Completion 成功集成后回写 `Done`”的契约。
- 结果：简单把 Bug 卡片标为 `Done` 会错误覆盖未集成、取消或 whole-run Discard 的运行。
- 置信度：高。

### RC-003：现有契约测试没有验证终态分支的 Backlog 结果

- 证据：基线测试验证 Workflow 文本与安装包一致性，没有执行或模拟 Completion 分支并检查 Backlog 区段、状态和无关行不变。
- 结果：规则和测试全部通过仍不能证明 Backlog 与交付终态一致。
- 置信度：高。

## Bug 确认结论

当前证据足以确认 B-008 是 `bug-fix` Completion 与 Backlog 汇总之间的真实交付规则缺陷，不是单次 Backlog 手工录入错误。修复边界应只覆盖 Bug Fix，并以成功集成结果作为 `Done` 回写触发；不得修改 Business Acceptance 菜单、引入新的 Backlog 状态或将失败/取消/丢弃路径标为完成。

## 当前未决问题

- Repair Solution 需要确定回写动作由 `bug-fix` Completion 规则直接执行，还是由 finishing flow 以明确的成功结果回传后执行；两者都必须保留失败、取消、阻塞和 whole-run Discard 的不回写语义。
- 需要定义如何依据 Bug ID 和当前 Version 定位 Backlog 行，以及如何保护无关 Backlog 行和当前待处理排序。

## 2026-07-18 完成写回复核

- 后续事实：S-017 已增加共享 lifecycle writeback，要求卡片与 Backlog 原子、幂等更新。
- 剩余缺口：`Backlog Synchronization After Completion` 的具体步骤仍只写 Backlog 移动；专项测试也未断言 Bug 卡片 `Status`、修复结果/集成引用和 Change Log。
- 现场证据：B-005、B-007、B-008 的历史 manifest 已 `integrated`，但卡片和 Backlog 仍为 `Draft`。
- 结论：原 merge-only 触发规则有效，但卡片写回执行契约和验证仍不完整。
