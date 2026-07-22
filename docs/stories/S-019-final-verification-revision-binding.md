# S-019 最终验证版本绑定

## 基本信息

- ID：`S-019`
- Version：`3`
- Status：`Done`
- Priority：`P2`
- Change Type：Feature

## 目标

将最终验证结论绑定到精确 commit、branch 和 tracked working-tree 状态，防止代码变化后继续使用过期结论。

## 背景

验证结果如果只关联模糊的“当前代码”，在 commit、分支或已跟踪文件变化后仍可能被误用。最终报告必须能判断被验证版本是否仍与交付候选一致。

## 角色、场景和价值

- 角色：执行 Dev Cadence Delivery Workflow 的交付负责人。
- 场景：最终验证完成后、进入 Business Acceptance 或 Completion 前，工作区可能出现新的提交、分支切换或 tracked 变更。
- 价值：业务验收只基于仍与验证证据一致的交付候选，且审计能够复现验证时的代码身份。

## ✅ 范围

- 在最终验证报告中记录验证开始和结束时的精确 `HEAD`、branch、既有 `FINAL_IMPLEMENTATION_SHA` 与 tracked 候选快照。
- tracked 候选快照使用相对 `FINAL_IMPLEMENTATION_SHA`、排除当前 run `build/dev-cadence/<workflow>/<slug>/` 证据路径的原始二进制 diff，并通过 `git hash-object --stdin` 记录稳定身份和 clean/dirty 状态。
- 验证开始和结束快照必须一致；不一致时，本次验证结论失效。
- 在进入 Business Acceptance 和 Completion 前重新计算 branch、实施候选和 tracked 快照。
- 允许已登记、且只修改当前 run 证据路径的 stage checkpoint 使 `HEAD` 前进；其他 commit、branch 变化、候选差异变化或 `FINAL_IMPLEMENTATION_SHA` 不再可达时，旧结论不得复用。
- 候选代码变化时返回实施阶段并重做 review 与最终验证；仅 branch 或证据链异常时至少返回最终验证阶段。
- 复用既有 Implementation Base SHA、Final Implementation SHA 和 changed-files 范围，不重新定义实施提交审查身份。

## ❌ 非范围

- 不要求记录 untracked 临时文件，除非它们参与验证。
- 不替代 Refactor 的重构前行为基线。
- 不在本 Story 中定义风险跨阶段传递。
- 不把当前 run 的 stage checkpoint 视为实施候选变化，也不允许将实施变更混入该 checkpoint。

## 可观察行为与业务规则

1. Feature Dev、Bug Fix 和 Refactor 的最终验证报告均包含相同的验证快照字段，并在验收和收尾前执行相同的重校验。
2. Delivery record validator 必须拒绝缺失、失效或不符合 checkpoint 白名单的最终验证身份。
3. 只有已登记的同 run 证据 checkpoint 可以出现在验证结束后；任何其他 commit 即使表面上不影响业务代码，也使精确提交绑定失效。

## 验收标准

1. 每个最终验证结论都记录开始/结束 `HEAD`、branch、`FINAL_IMPLEMENTATION_SHA`、tracked 快照身份和 clean/dirty 状态。
2. 验证期间、Business Acceptance 前或 Completion 前发生候选代码变化时，旧结论不能继续使用，并按确认的回退规则重新 review 和验证。
3. 仅已登记且只修改当前 run 证据路径的 stage checkpoint 不会造成伪失效；其他 commit 会被识别为失效。
4. 三个开发 workflow 和 delivery record validator 对版本失效采用对称、可执行的处理。

## 依赖

- 无强制前置依赖。

## 已确认决策

- [Q-009 tracked working-tree 差异身份](../open-questions.md#q-009)：使用相对 `FINAL_IMPLEMENTATION_SHA` 的原始二进制 diff，经 `git hash-object --stdin` 生成身份；不使用会规范化补丁内容的 `patch-id`。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建最终验证版本绑定 Story。 | 防止实现变化后继续沿用过期验证结论。 |
| 2 | 2026-07-19T20:05:58+0800 | Raymond Liao <raymond-liao@outlook.com> | 收敛为最终验证身份与失效检查。 | 实施提交范围已有身份契约；剩余缺口是验证执行版本、tracked 差异和进入验收前的一致性判断。 |
| 3 | 2026-07-20T17:50:06+0800 | Raymond Liao <raymond-liao@outlook.com> | 确认严格的最终验证候选快照与 checkpoint 白名单，并将 Story 标记为 Ready。 | 用户确认 Git 原生二进制 diff 身份、非白名单 commit 失效和三 workflow 对称处理。 |
| 3 | 2026-07-22T09:46:55+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 In Progress，并在 Backlog 中移入进行中。 | 用户明确启动 S-019 的 Feature Dev 交付；本次只改变执行状态。 |
| 3 | 2026-07-22T14:03:06+0800 | Raymond Liao <raymond-liao@outlook.com> | 记录 Business Acceptance 为 accepted，保持 In Progress 等待 Completion。 | 用户选择固定选项 1；候选分支尚未集成，Status 和 Backlog 保持不变。 |
| 3 | 2026-07-22T14:46:35+0800 | Raymond Liao <raymond-liao@outlook.com> | 在合并后复验的 Business Acceptance 通过后标记为 Done，并在 Backlog 中移入已完成。 | 候选已本地合入 main，新的精确分支验证已通过，用户再次选择固定选项 1。 |
