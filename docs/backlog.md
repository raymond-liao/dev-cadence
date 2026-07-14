# Backlog

按本文件顺序逐项处理。开始一个主任务前，先单独确认范围和实施计划；当前任务完成并验证后，再进入下一项。不要把多个待处理项合并为一次大范围修改。

## 进行中

- [ ] [P1] [S-008 Skill 语义视觉规范](stories/S-008-skill-semantic-visual-markers.md)

## 待处理

- [ ] [P1] [S-007 Workflow 入口路由示例](stories/S-007-workflow-routing-examples.md)
- [ ] [P1] [S-009 生成文档状态呈现](stories/S-009-generated-status-presentation.md)
- [ ] [P1] [S-010 文档引用快捷链接](stories/S-010-document-reference-links.md)
- [ ] [P1] [S-005 全局 Open Question Registry](stories/S-005-open-question-registry.md)
- [ ] [P1] [S-006 Discovery 产品与技术内容边界](stories/S-006-discovery-product-technical-content-boundary.md)
- [ ] [P1] [S-002 产品设计基线增量更新与版本治理](stories/S-002-discovery-prd-incremental-versioning.md)
- [ ] [P1] 实现 Work Item Planning workflow 和工作项契约：新增 `work-item-planning` skill，支持组合规划和单项登记；定义 `F/S/B/T` 卡片的 ID、结构、版本、状态、关系和 Roadmap，并将该 workflow 作为唯一建卡入口及开发 workflow 的移交方。
- [ ] [P1] 打通工作项卡片与现有开发 workflow：更新 `using-dev-cadence`、`feature-dev`、`bug-fix` 和 `refactor`，实现卡片检查、缺卡路由、卡片版本引用、卡片与第一阶段记录的职责边界，以及开始、返工、验收和 Completion 后的状态与交付引用回写。
- [ ] [P1] [S-003 实施前方案新鲜度门禁](stories/S-003-implementation-design-freshness-gate.md)
- [ ] [P2] [S-004 实施与测试失败分类和阶段返回](stories/S-004-failure-classification-stage-routing.md)
- [ ] [P2] 补齐需求治理端到端验证和安装契约：验证从想法、PRD、工作项规划到 `feature-dev`、`bug-fix`、`refactor` 交付及 Roadmap 回写的完整链路，并覆盖构建、安装包、入口路由和现有目标仓库兼容。
- [ ] [P1] 补齐 Business Acceptance 终态映射：让三个 workflow 的 `accepted`、`accepted_with_risk` 和 `rejected` 分别进入明确的 Completion 路径，并用对称契约测试验证每个决策的 manifest 终态和后续动作。
- [ ] [P2] 绑定最终验证版本：记录精确 commit、branch 和 tracked working-tree 状态，防止代码变化后继续使用过期验证结论。
- [ ] [P2] 传递实施与 Review 风险到验证阶段：使用稳定 ID 将跳过的实施检查、未解决 review finding 和已接受 review 风险完整写入最终验证报告。
- [ ] [P2] 传递验证风险到 Business Acceptance：确保最终验证报告中仍未解决的稳定 ID、跳过检查和剩余风险全部出现在业务验收摘要与记录中。
- [ ] [P0] 修复普通 Checkout 本地 Merge：在执行前固定 base branch、feature branch 和预期 SHA；安全处理离线仓库与 already-integrated 分支，并在合并后验证实际结果。
- [ ] [P0] 修复普通 Checkout Discard：在删除前确认精确 branch 和 commit 范围，处理当前分支与未提交改动，要求明确 discard 确认，并验证目标分支确实被删除或保留。
- [ ] [P1] 补齐 Bug `not-a-bug` 终态：让已确认并非缺陷的问题能够结束 bug-fix run，记录判断依据、用户确认和非 `pending` 的终态 manifest。
- [ ] [P1] 补齐 manual recovery 终态：当正常 Completion 无法继续时，允许三个 workflow 记录恢复原因、保留状态和最终 `abandoned` 结果；不要在此任务中处理具体 merge、discard 或 worktree 命令。
- [ ] [P2] 补齐 Bug 诊断门禁：阻止根因未验证或问题仍有歧义的 bug fix 进入 Repair Solution。
- [ ] [P2] 补齐 Bug RED/GREEN 证据：当存在自动测试或可重复检查时，用稳定 proof ID 记录修复前失败、关联修改和修复后通过证据；无法直接复现时记录替代因果证据和原因。
- [ ] [P2] 补齐 Refactor 基线身份：将行为基线绑定到重构前版本，防止使用重构后的行为重新定义原始预期。
- [ ] [P2] 补齐 Refactor 迁移开始契约：仅在渐进迁移、兼容层或多调用方场景中记录调用方清单、兼容策略、迁移批次和待迁移范围。
- [ ] [P2] 补齐 Refactor 旧路径删除门禁：删除旧路径前验证剩余引用、迁移完成状态、适配器保留决策和删除安全证据。
- [ ] [P3] 补齐 Feature 持久化记录契约：确保 requirements 和 technical solution 记录能够在会话中断后重建已确认的范围、验收标准和方案约束。
- [ ] [P0] 补齐 Worktree 所有权识别：使用创建来源而不是目录名称判断清理所有权，并支持 `.dev-cadence.yaml` 配置的自定义 worktree 目录。
- [ ] [P0] 保存 Worktree 运行记录：在删除 Dev Cadence 所有的 worktree 前，将必须保留的 manifest 和 stage record 保存到不会随 worktree 删除的位置，并验证记录仍可访问。
- [ ] [P1] 补齐 Detached HEAD Finishing：为外部管理的 detached HEAD 定义创建分支、创建 PR、保留和 discard 路径；不得假定当前存在可 push 或可删除的命名分支。
- [ ] [P1] 记录 Worktree 清理结果：Completion 后在 manifest 和业务验收记录中写明 worktree 是否删除、由谁管理以及 task branch 是否删除或保留。
- [ ] [P3] 规划发布与生产交付能力：后续设计 Release、Deployment、Post-deploy Verification 和 Incident/Hotfix workflow；当前只保留方向，不进入实施。

## 已完成

- [x] [P1] [S-001 首次 Discovery 与产品设计基线](stories/S-001-initial-discovery-prd-baseline.md)
- [x] [P1] 补齐 executing-plans 路径下实施提交的提交前审查机制。
- [x] [P2] 补齐 Refactor 测试敏感性检查：新增 characterization 或 contract test 时执行可逆 sensitivity check，并通过契约测试保护该规则。
- [x] [P2] 补齐最小验证阶段门禁：为 `feature-dev`、`bug-fix` 和 `refactor` 增加对称的 `ready`、`ready_with_risk` 和 `not_ready` 决策；阻止 `not_ready` 进入 Business Acceptance，并定义返回最早受影响阶段的最小返工规则。
- [x] [P1] 修正 Refactor 公共契约矛盾：只允许收窄内部接口；公共 API 和外部数据形状必须保持兼容，主动契约变更转入 feature-dev 或 bug-fix。

## 已关闭

- [Superseded] 实现 Discovery workflow 和 PRD 契约：原任务已拆分为 [S-001 首次 Discovery 与产品设计基线](stories/S-001-initial-discovery-prd-baseline.md) 和 [S-002 产品设计基线增量更新与版本治理](stories/S-002-discovery-prd-incremental-versioning.md)。该条目的 Superseded 状态只说明任务被拆分；S-001 的实际完成状态以 Story 和运行记录为准。

## 评级说明

待处理项从上到下按建议实施顺序排列。排序综合覆盖面、对后续任务的解锁作用、当前收益、风险和触发概率；`P` 标签只表示未处理时的风险等级，不决定列表位置。

- `P0`：可能造成不可逆 Git 状态、数据丢失或运行记录丢失的问题。
- `P1`：会阻止 workflow 可靠闭环，或使特殊环境无法完成交付的问题。
- `P2`：会使验证、风险或行为保护证据失效、不完整或不可追溯的问题。
- `P3`：改善会话恢复和长期审计质量，但不直接造成不安全交付的问题。
