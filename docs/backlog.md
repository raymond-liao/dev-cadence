# Backlog

按本文件顺序逐项处理。开始一个主任务前，先单独确认范围和实施计划；当前任务完成并验证后，再进入下一项。不要把多个待处理项合并为一次大范围修改。

## 进行中

- [ ] 补齐最小验证阶段门禁：为 `feature-dev`、`bug-fix` 和 `refactor` 增加对称的 `ready`、`ready_with_risk` 和 `not_ready` 决策；阻止 `not_ready` 进入 Business Acceptance，并定义返回最早受影响阶段的最小返工规则。范围以 `docs/superpowers/specs/2026-07-12-workflow-stage-reliability-design.md` 为准。

## 待处理

- [ ] 补齐 Business Acceptance 终态映射：让三个 workflow 的 `accepted`、`accepted_with_risk` 和 `rejected` 分别进入明确的 Completion 路径，并用对称契约测试验证每个决策的 manifest 终态和后续动作。
- [ ] 补齐 Bug `not-a-bug` 终态：让已确认并非缺陷的问题能够结束 bug-fix run，记录判断依据、用户确认和非 `pending` 的终态 manifest。
- [ ] 补齐 manual recovery 终态：当正常 Completion 无法继续时，允许三个 workflow 记录恢复原因、保留状态和最终 `abandoned` 结果；不要在此任务中处理具体 merge、discard 或 worktree 命令。
- [ ] 修复普通 Checkout 本地 Merge：在执行前固定 base branch、feature branch 和预期 SHA；安全处理离线仓库与 already-integrated 分支，并在合并后验证实际结果。
- [ ] 修复普通 Checkout Discard：在删除前确认精确 branch 和 commit 范围，处理当前分支与未提交改动，要求明确 discard 确认，并验证目标分支确实被删除或保留。
- [ ] 补齐 Worktree 所有权识别：使用创建来源而不是目录名称判断清理所有权，并支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。
- [ ] 保存 Worktree 运行记录：在删除 Dev Cadence 所有的 worktree 前，将必须保留的 manifest 和 stage record 保存到不会随 worktree 删除的位置，并验证记录仍可访问。
- [ ] 补齐 Detached HEAD Finishing：为外部管理的 detached HEAD 定义创建分支、创建 PR、保留和 discard 路径；不得假定当前存在可 push 或可删除的命名分支。
- [ ] 记录 Worktree 清理结果：Completion 后在 manifest 和业务验收记录中写明 worktree 是否删除、由谁管理以及 task branch 是否删除或保留。
- [ ] 绑定最终验证版本：记录精确 commit、branch 和 tracked working-tree 状态，防止代码变化后继续使用过期验证结论。
- [ ] 传递实施与 Review 风险到验证阶段：使用稳定 ID 将跳过的实施检查、未解决 review finding 和已接受 review 风险完整写入最终验证报告。
- [ ] 传递验证风险到 Business Acceptance：确保最终验证报告中仍未解决的稳定 ID、跳过检查和剩余风险全部出现在业务验收摘要与记录中。
- [ ] 补齐 Feature 持久化记录契约：确保 requirements 和 technical solution 记录能够在会话中断后重建已确认的范围、验收标准和方案约束。
- [ ] 补齐 Bug 诊断门禁：阻止根因未验证或问题仍有歧义的 bug fix 进入 Repair Solution。
- [ ] 补齐 Bug RED/GREEN 证据：当存在自动测试或可重复检查时，用稳定 proof ID 记录修复前失败、关联修改和修复后通过证据；无法直接复现时记录替代因果证据和原因。
- [ ] 补齐 Refactor 基线身份：将行为基线绑定到重构前版本，防止使用重构后的行为重新定义原始预期。
- [ ] 补齐 Refactor 迁移开始契约：仅在渐进迁移、兼容层或多调用方场景中记录调用方清单、兼容策略、迁移批次和待迁移范围。
- [ ] 补齐 Refactor 旧路径删除门禁：删除旧路径前验证剩余引用、迁移完成状态、适配器保留决策和删除安全证据。

## 已完成

- [x] 补齐 executing-plans 路径下实施提交的提交前审查机制。
- [x] 补齐 Refactor 测试敏感性检查：新增 characterization 或 contract test 时执行可逆 sensitivity check，并通过契约测试保护该规则。
