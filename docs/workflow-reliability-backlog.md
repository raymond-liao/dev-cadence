# Workflow Reliability Backlog

按顺序逐项处理。开始一个主任务前，先为该任务单独确认范围和实施计划；当前任务完成并验证后，再进入下一项。

- [x] 补齐 executing-plans 路径下实施提交的提交前审查机制。
- [ ] 修复 Completion 状态机：让 accepted、accepted with risk、rejected、not-a-bug 和 manual recovery 都有明确终态。
- [ ] 修复普通 Checkout 的 Finishing 流程：处理安全 merge、discard、SHA 校验、离线仓库和 already-integrated 场景。
- [ ] 修复 Worktree 生命周期：处理 worktree 所有权、记录保存、清理、自定义目录和 detached HEAD。
- [ ] 补齐各 Workflow 的专属可靠性规则：分别检查 feature-dev、bug-fix 和 refactor 的阶段门禁及终态规则。
- [ ] 完成整体契约验证与发布同步：补齐测试，验证三个 workflow 的对称性，并同步 dist、README 和版本号。
