# Dev Cadence 工作流

本文说明 Dev Cadence 的 workflow、任务分级、loop、Quality Gate 和 Human Gate。运行时细则见 `references/` 中的 workflow、gate 和 discipline references。

## 标准工作流

标准开发工作流：

```text
Intake
  -> Requirements
  -> Design
  -> Planning
  -> Implementation
  -> Verification
  -> Review
  -> Acceptance
  -> Merge / Release
```

Supervisor 根据当前状态决定下一步，Harness 负责执行每个 Agent stage 并记录证据。Worker Agent 不能绕过 Supervisor 自行进入下一阶段。

## 状态机

| State | Owner | Output | Gate | Next |
|---|---|---|---|---|
| `intake` | Supervisor | `00-brief.md` | 目标、约束、任务类型已记录 | `classify` |
| `classify` | Supervisor | task class / workflow type | 已判定任务强度 | `requirements` 或 lightweight path |
| `requirements` | Planner | `01-requirements.md` | 范围和验收标准清楚 | `design` 或 `planning` |
| `design` | Architect / Planner | `02-design.md` / ADR | 高风险任务完成设计确认 | `planning` |
| `planning` | Planner | `03-tasks.md`、`04-test-plan.md` | 任务可执行，验证方式明确 | `implementation` |
| `implementation` | Developer via Harness | code diff、`05-implementation.md`、run evidence | 有 diff、说明和初步验证证据 | `verification` |
| `verification` | Tester / Developer via Harness | `06-test-report.md` | 测试或验证证据完整 | `review` 或 `fix` |
| `review` | Reviewer via Harness | `07-review-report.md` | 无 blocker / major，或进入修复 | `acceptance` 或 `fix` |
| `fix` | Developer via Harness | patch + run evidence | 修复针对明确 issue，未扩大范围 | `verification` |
| `acceptance` | Human + Supervisor | `08-acceptance.md` | 人确认风险并批准结束 | `done` |
| `blocked` | Supervisor + Human | escalation decision | 人决定继续、降级、拆分或终止 | selected state |

关键规则：

- 每个 Agent 执行状态都必须经过 Harness。
- 每个 Harness run 都必须生成 required evidence。
- Supervisor 只能根据产物和 gate 决定下一步，不能代替 Agent 产出内容。
- Human Gate 的决定必须写入 requirements、ADR 或 acceptance。
- `fix` 状态最多循环 3 次，超限进入 `blocked`。

## Workflow 路由

用户只需要描述目标、背景、约束和期望结果。Supervisor 根据请求内容和风险自动判定 `selected_workflow`，并记录 `selection_reason`。

支持的核心 workflow：

| Workflow | 适用场景 |
|---|---|
| `feature-dev` | 新功能或行为变更 |
| `bugfix` | 已知缺陷修复 |
| `refactor` | 行为不变的结构调整 |
| `code-review` | 审查已有 diff、PR 或提交 |
| `research-spike` | 技术选型、未知风险探索、方案比较 |
| `incident-fix` | 紧急生产修复或高压故障恢复 |
| `release` | 发布、打包、上线或发布前检查 |

如果用户明确说“只做 review”“先调研”“按 incident 处理”，该表达应作为 `workflow_hint` 记录，但最终仍由 Supervisor 校准风险和 gate。

## 任务分级

同一套框架应根据风险调整流程强度，而不是所有任务走同样重量的流程。

| Class | 适用场景 | 必需产物 | Human Gate |
|---|---|---|---|
| `S0 trivial` | 文案、注释、低风险配置、可快速回滚的小修 | brief、implementation、test evidence 或 not verified reason、acceptance | final acceptance |
| `S1 normal` | 普通 feature、bugfix、code-review、局部重构 | requirements、tasks、implementation、test_report、review_report、acceptance | requirement acceptance、final acceptance |
| `S2 high-risk` | 架构、安全、权限、CI、数据迁移、跨模块变更 | requirements、design/ADR、tasks、implementation、test_report、review_report、acceptance | 实现前 approval、permission approval、final acceptance |
| `research-spike` | 技术选型、未知风险探索、方案比较 | research report、options comparison、recommendation、open questions | decision review |
| `incident` | 紧急生产修复或高压故障恢复 | triage、minimal patch、smoke test、emergency approval、post-incident backfill | emergency approval、post-incident acceptance |

低风险任务可以轻量，但仍必须保留 diff、验证证据或不可验证说明，以及最终验收。高风险任务不能轻量化；必须启用更严格的设计、权限和 Harness policy。

## Incident 快速路径

`incident-fix` 不应照搬完整 feature-dev 流程。

```text
triage
  -> minimal safe patch
  -> smoke test
  -> human emergency approval
  -> deploy / merge
  -> post-incident review
  -> backfill spec / test / ADR if needed
```

incident-fix 的重点是快速恢复关键能力，同时记录临时绕过了哪些普通门禁、谁批准、何时批准、批准的风险是什么、回滚或降级方案是什么。

## Loop 设计

Dev Cadence 使用三层闭环：

```text
Micro Loop:
Developer -> run test -> fix -> run test

Quality Loop:
Developer -> Tester -> Reviewer -> Fix -> Tester -> Reviewer

Spec Loop:
Requirement / Design -> Human / Architect -> Revision
```

Loop 控制规则：

```yaml
max_fix_iterations: 3
no_peer_debate: true
all_rejections_require_evidence: true
unresolved_conflict_goes_to_human: true
```

Reviewer 或 Tester 反馈问题时，必须使用结构化格式：

```yaml
severity: blocker | major | minor
evidence:
reason:
required_change:
owner:
```

不接受只有“感觉不好”“建议优化”“可能有问题”这类没有证据、影响范围和修改要求的反馈。

## Quality Gate

最小质量门禁：

| Gate | 检查项 | 通过条件 |
|---|---|---|
| G1 | Requirements readiness | 范围、非目标、验收标准和验证方式已确认 |
| G2 | Design readiness | 高风险任务已有 design/ADR，且架构约束被确认 |
| G3 | Plan readiness | task 有输入、输出、目标文件、验收标准和 forbidden actions |
| G4 | Verification | 测试命令、环境、结果、覆盖范围、失败或跳过原因完整 |
| G5 | Review | Reviewer 给出结构化结论，且无 blocker / major 未解决 |
| G6 | Human acceptance | 人确认剩余风险并批准结束、合并或发布 |

验证状态不应只有 pass / fail：

```text
verified
partially_verified
not_verified
blocked_by_environment
```

任何非 `verified` 状态必须写明缺口、剩余风险、建议补测方式，以及是否允许进入人工验收。非 `verified` 状态不能自行通过质量门禁，必须由具名 Human 接受风险后才能继续。

## Human Gate

人不应该介入每一步，但必须控制高风险边界。

| 人介入点 | 原因 |
|---|---|
| 需求确认 | 防止 Agent 自行扩展范围 |
| 架构确认 | 防止错误方向被自动放大 |
| 权限批准 | 网络、数据库、生产环境、密钥、删除操作 |
| Merge | 最终责任仍在人 |
| Release | 生产风险需要人确认 |
| Loop 超限 | Agent 反复修不好时停止消耗 |

Human Gate 类型：

| Type | 含义 | 是否阻塞 |
|---|---|---|
| `approval_required` | 没有人明确批准不能继续 | 是 |
| `review_required` | 人需要审查方案或风险 | 通常阻塞关键阶段 |
| `info_required` | AI 缺少必要信息或业务取舍 | 阻塞相关阶段 |
| `notify_only` | 只需要告知人 | 否 |

AI 可以准备材料和建议，但不能越权批准。人的决策必须写入 spec、ADR 或 acceptance artifact。

## Review 结论

Reviewer 的结论只能是：

```text
approved
approved_with_minor_notes
changes_requested
blocked
```

对于 `changes_requested` 或 `blocked`，必须给出证据和修改要求。Review 不能替代 final Human acceptance。
