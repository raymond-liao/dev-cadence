# Open Question Registry

## Questions

| ID | Status | Question | Authoritative Source |
| --- | --- | --- | --- |
| [Q-001](#q-001) | Open | 工作项应如何记录产生依据，以及何时需要独立的 Decision 资产？ | Registry temporary body |
| [Q-002](#q-002) | Open | 哪些具体 workflow、阶段记录或用户可见摘要稳定复现语言回退？ | [B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md) |
| [Q-003](#q-003) | Open | 失效时实际读取的是目标仓库配置、源仓库配置还是默认值？ | [B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md) |
| [Q-004](#q-004) | Open | worktree 和会话恢复是否改变了配置查找根目录？ | [B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md) |
| [Q-006](#q-006) | Open | 是否需要在后续 Story 中为连续失败设置统一最大恢复轮次，还是由各 workflow 根据风险和失败类型决定？ | [S-004 实施与测试失败分类和阶段返回](stories/S-004-failure-classification-stage-routing.md) |
| [Q-015](#q-015) | Invalid | 未提交但已跟踪的基线差异应如何形成稳定身份？ | Registry temporary body |
| [Q-022](#q-022) | Open | 哪些代表性路径足以覆盖升级兼容，而不会把测试固化为单一实现？ | [T-002 需求治理端到端验证与安装契约](tasks/T-002-requirements-governance-end-to-end-validation.md) |
| [Q-005](#q-005) | Resolved | 并行视图最终采用“当前可并行推进表”还是保留原名称，并将入口资格作为独立列展示？ | [B-007 当前可并行实施表混用卡片状态与流程入口资格](bugs/B-007-parallel-work-table-entry-qualification.md) |
| [Q-007](#q-007) | Resolved | 已关闭列表如何在保持五列表格的同时呈现历史合并事件的来源卡片、目标卡片和合并原因？ | [S-016 统一 Backlog 看板](stories/S-016-unified-backlog-board.md) |
| [Q-008](#q-008) | Resolved | `rejected` 应返回返工阶段还是进入独立关闭终态，是否需要按原因区分？ | [S-018 Delivery 终态映射与 Manual Recovery](stories/S-018-business-acceptance-terminal-mapping.md) |
| [Q-009](#q-009) | Resolved | tracked working-tree 差异使用 patch hash 还是其他稳定身份表达？ | [S-019 最终验证版本绑定](stories/S-019-final-verification-revision-binding.md) |
| [Q-010](#q-010) | Resolved | 不同阶段的风险 ID 是否共享统一命名空间？ | [T-005 最终验证带入限制呈现](tasks/T-005-final-verification-carried-limitations.md) |
| [Q-011](#q-011) | Invalid | manifest 使用 `not_a_bug` 还是更通用的关闭状态？ | [S-024 Bug 诊断门禁](stories/S-024-bug-diagnosis-gate.md) |
| [Q-012](#q-012) | Resolved | 哪些失败类别允许进入 manual recovery，哪些必须继续阻塞？ | [S-018 Delivery 终态映射与 Manual Recovery](stories/S-018-business-acceptance-terminal-mapping.md) |
| [Q-013](#q-013) | Invalid | 哪些替代因果证据足以在无法完全复现时通过门禁？ | [S-024 Bug 诊断门禁](stories/S-024-bug-diagnosis-gate.md) |
| [Q-014](#q-014) | Resolved | proof ID 的跨阶段字段名称和最小格式是什么？ | [S-025 Bug RED/GREEN 证据](stories/S-025-bug-red-green-evidence.md) |
| [Q-016](#q-016) | Resolved | 迁移状态应保存在实施记录还是独立清单中？ | [S-027 Refactor 迁移与旧路径删除契约](stories/S-027-refactor-migration-start-contract.md) |
| [Q-017](#q-017) | Resolved | 所有权证据应保存在 manifest、配置派生记录还是独立元数据中？ | [S-030 Worktree 清理安全与证据](stories/S-030-worktree-ownership-detection.md) |
| [Q-018](#q-018) | Invalid | 多 worktree 并行运行时，保存目录如何避免任务 slug 冲突？ | [S-030 Worktree 清理安全与证据](stories/S-030-worktree-ownership-detection.md) |
| [Q-019](#q-019) | Invalid | 外部环境是否需要提供可持久化的 workspace identity？ | [S-032 Detached Head 收尾](stories/S-032-detached-head-finishing.md) |
| [Q-020](#q-020) | Superseded | 发布、部署、生产验证和事故处置应拆成几个 workflow？ | [S-034 发布与生产交付能力规划](stories/S-034-release-and-production-delivery-capability.md) |
| [Q-021](#q-021) | Superseded | 首个实施切片应优先覆盖哪类交付环境？ | [S-034 发布与生产交付能力规划](stories/S-034-release-and-production-delivery-capability.md) |
| [Q-023](#q-023) | Resolved | 历史 Change Log 缺少准确时间、时间精度或作者时应如何迁移？ | [S-041 Change Log 共享契约与历史记录治理](stories/S-041-change-log-contract-and-history-governance.md) |

## Question Details

### Q-001

#### Context

Backlog 中的 `Depends On` 只表达实施前置关系，不能说明工作项为什么产生。现有卡片通常通过背景、目标和 Change Log Reason 描述问题，但没有统一、可验证的来源追溯规则。

集中式 Decision 文档可以提高跨卡片决策的可发现性，但如果复制 PRD、Business Architecture、架构文档、工作项卡片或 Delivery 方案已经拥有的结论，会形成需要同步的重复权威来源。

#### Unresolved Question

- 工作项是否必须记录产生它的权威事实、决策、上游工作项或缺陷证据？
- 只影响一张卡片的决策是否应由该卡片自身持有？
- 同时影响多张卡片、多个 workflow 或长期架构边界的决策应由现有权威资产、独立 Decision 文档还是决策索引持有？
- 如果引入 `docs/decisions.md`，它的所有者、适用范围、状态模型和维护触发点应如何定义？
- Open Question 解决并产生工作项后，如何保留从问题、确认结论到工作项的追溯，同时避免复制完整正文？

#### Impact

在该问题解决前，新增卡片可能继续缺少一致的产生依据；后续维护者难以判断卡片是否仍然有效、上游结论变化会影响哪些卡片，以及某项工作为什么被单独拆分。直接增加全局 Decision 文档也存在职责重叠和内容失真的风险。

#### Known Constraints

- `Depends On` 继续只表达实施依赖，不承担产生依据或决策追溯职责。
- 一个事实或问题必须只有一个完整正文来源，其他资产只保存必要摘要和链接。
- 未确认方向不得写成已接受决策或强制卡片契约。
- 新增 Decision 资产前必须先定义所有者、用途和维护方式。
- Open Question Registry 只维护未解决问题，不作为已确认决策历史或 Backlog 的替代品。

#### Suggested Next Step

在 Work Item Analysis 与资产治理设计中比较卡片内持有、独立 Decision 权威资产和决策索引三种方式，确认最小适用边界、单一正文来源和跨 workflow 维护责任后，再决定是否修改卡片契约或新增 `docs/decisions.md`。

### Q-002

[B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md)

### Q-003

[B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md)

### Q-004

[B-004 输出语言配置一致性](bugs/B-004-output-language-configuration-not-consistently-applied.md)

### Q-005

[B-007 当前可并行实施表混用卡片状态与流程入口资格](bugs/B-007-parallel-work-table-entry-qualification.md)

### Q-006

[S-004 实施与测试失败分类和阶段返回](stories/S-004-failure-classification-stage-routing.md)

### Q-007

[S-016 统一 Backlog 看板](stories/S-016-unified-backlog-board.md)

### Q-008

[S-018 Delivery 终态映射与 Manual Recovery](stories/S-018-business-acceptance-terminal-mapping.md)

### Q-009

[S-019 最终验证版本绑定](stories/S-019-final-verification-revision-binding.md)

### Q-010

[T-005 最终验证带入限制呈现](tasks/T-005-final-verification-carried-limitations.md)

### Q-011

[S-024 Bug 诊断门禁](stories/S-024-bug-diagnosis-gate.md)

### Q-012

[S-018 Delivery 终态映射与 Manual Recovery](stories/S-018-business-acceptance-terminal-mapping.md)

### Q-013

[S-024 Bug 诊断门禁](stories/S-024-bug-diagnosis-gate.md)

### Q-014

[S-025 Bug RED/GREEN 证据](stories/S-025-bug-red-green-evidence.md)

### Q-015

#### Context

该问题原由已删除的 S-026 提出，用于决定 Refactor 是否需要为未提交但已跟踪的基线差异建立稳定身份。

#### Conclusion

用户已确认不再推进 S-026；当前没有工作项或 workflow 要求处理 dirty baseline 身份。因此本问题不再是活跃需求，状态为 `Invalid`。若未来重新引入该目标，必须由新的权威资产重新登记问题，而不是恢复已删除卡片的链接。

### Q-016

[S-027 Refactor 迁移与旧路径删除契约](stories/S-027-refactor-migration-start-contract.md)

### Q-017

[S-030 Worktree 清理安全与证据](stories/S-030-worktree-ownership-detection.md)

### Q-018

[S-030 Worktree 清理安全与证据](stories/S-030-worktree-ownership-detection.md)

### Q-019

[S-032 Detached Head 收尾](stories/S-032-detached-head-finishing.md)

### Q-020

[S-034 发布与生产交付能力规划](stories/S-034-release-and-production-delivery-capability.md)

### Q-021

[S-034 发布与生产交付能力规划](stories/S-034-release-and-production-delivery-capability.md)

### Q-022

[T-002 需求治理端到端验证与安装契约](tasks/T-002-requirements-governance-end-to-end-validation.md)

### Q-023

[S-041 Change Log 共享契约与历史记录治理](stories/S-041-change-log-contract-and-history-governance.md)
