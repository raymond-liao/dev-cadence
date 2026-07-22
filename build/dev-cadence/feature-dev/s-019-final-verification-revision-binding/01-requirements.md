# S-019 需求确认

## 工作项身份

- Work Item: [S-019 最终验证版本绑定](../../../../../docs/stories/S-019-final-verification-revision-binding.md)
- Work Item Type: `Story`
- Work Item Version: `3`
- Current Status: 🔄 `in_progress`
- Selected Scope: S-019 的已确认严格最终验证版本绑定。

## 目标

让 Feature Dev、Bug Fix 与 Refactor 的最终验证结论只能用于仍与验证候选一致的交付；在 commit、branch、最终实施候选或 tracked working-tree 差异变化后，旧结论必须失效并按影响范围回退。

## ✅ 范围

- 在三条 Delivery workflow 的最终验证报告中记录验证开始与结束时的 `HEAD`、branch、`FINAL_IMPLEMENTATION_SHA`、相对最终实施提交的 tracked 候选快照身份，以及 clean/dirty 状态。
- tracked 快照使用相对 `FINAL_IMPLEMENTATION_SHA` 的原始二进制 diff，经 `git hash-object --stdin` 形成稳定身份，并排除当前 run 的 `build/dev-cadence/<workflow>/<slug>/` 证据路径。
- 验证开始与结束快照必须一致；进入 Business Acceptance 与 Completion 前必须重新计算并比较 branch、实施候选和 tracked 快照。
- 只允许已经登记、且只修改当前 run 证据路径的 stage checkpoint 在验证结束后推进 `HEAD` 而不使结论失效。
- 候选代码变化时回到实施阶段并重新 review 与最终验证；仅 branch 或证据链异常时至少回到最终验证阶段。
- Delivery record validator 拒绝缺失、失效或不满足 checkpoint 白名单的最终验证身份。

## ❌ 非范围

- 不记录未参与验证的 untracked 临时文件。
- 不重新定义 Implementation Base SHA、Final Implementation SHA、changed-files 范围或实施提交审查身份。
- 不实现 Refactor 的重构前行为基线。
- 不定义跨阶段风险传递、风险 ID 或 Business Acceptance 终态语义。
- 不把实现变更混入当前 run 的 stage checkpoint。

## 验收标准

1. 三个 Delivery workflow 的最终验证结论均记录开始/结束 `HEAD`、branch、`FINAL_IMPLEMENTATION_SHA`、tracked 快照身份与 clean/dirty 状态。
2. 验证期间、Business Acceptance 前或 Completion 前的候选代码变化会使旧结论失效，并按已确认规则重新 review 和验证。
3. 只有已登记且只修改当前 run 证据路径的 checkpoint 可以避免伪失效；其他 commit 均被识别为失效。
4. 三个 workflow 与 delivery record validator 使用对称、可执行的失效规则。

## 业务规则

- 原始二进制 diff 身份必须相对 `FINAL_IMPLEMENTATION_SHA` 计算，且不得以会规范化补丁内容的 `patch-id` 替代。
- `FINAL_IMPLEMENTATION_SHA` 不再可达时，旧最终验证结论不得复用。
- 被验证候选未变化时，已登记的同 run 证据 checkpoint 不得被当作候选代码变更。

## 假设

- 三条现有 Delivery workflow 已有最终验证阶段、`FINAL_IMPLEMENTATION_SHA` 与 stage checkpoint 机制，可在既有边界内扩展。
- 当前 run 证据目录可由 workflow slug 确定，并可从候选 diff 中排除。
- 规则源、validator 与相应契约测试均属于本卡实现边界；根目录 `version` 是否更新将在实现变更形成后按仓库规则评估。

## Open Questions

无。Q-009 已确认使用 Git 原生二进制 diff hash 作为 tracked working-tree 身份。

## Direct Input Identities

| Source | SHA-256 |
| --- | --- |
| `docs/stories/S-019-final-verification-revision-binding.md` | `123065caa5709bf4a1a0a0a272435420d98ea016fb6d03c136a33d9d5e5482b3` |
