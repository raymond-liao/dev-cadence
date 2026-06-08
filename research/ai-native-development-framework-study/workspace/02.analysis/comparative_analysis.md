# Comparative Analysis

## Input Artifacts

本分析依据以下输入产物完成：

| Artifact | 用途 |
|---|---|
| `references/methodology/research-overview.md` | 明确研究目标、MVP-oriented systematic study 立场、核心问题和输出语言要求。 |
| `references/methodology/analysis-methods.md` | 明确比较分析目的、证据引用要求、发现 ID 格式和“收益与代价并重”的质量要求。 |
| `workspace/01.materials/framework_map.md` | 提供当前方案的核心命题、架构层次、Agent 分工、工作流、上下文、质量门禁、Human Gate、Skill 交付和 MVP 范围。 |
| `workspace/01.materials/external_sources.md` | 提供外部证据源 `SRC-001` 至 `SRC-012`，覆盖多智能体编排、HITL、guardrails、tracing、SWE-bench、GitHub Copilot agent workflow 等。 |

关键证据锚点：

- `SRC-PROPOSAL-README`：当前 README 提案，经 `framework_map.md` 提取。
- `ANA-MAP` prior artifact：`framework_map.md` 中的 Architecture Map、Agent Role Map、Workflow and Artifact Map、Quality Gate Map、MVP Map、Open Questions。
- `SRC-001`、`SRC-002`、`SRC-003`、`SRC-004`、`SRC-005`、`SRC-006`：支持状态持久化、HITL、编排、guardrails、tracing 的外部框架证据。
- `SRC-007`、`SRC-008`、`SRC-009`：支持真实软件工程任务复杂性、动态评测和失败模式分析。
- `SRC-011`、`SRC-012`：支持以 PR、日志、CI 权限和人工 Review 为边界的产品化 AI coding agent 工作流。

## Comparison Matrix

| 比较维度 | 当前方案说了什么 | 类似的成熟工程实践 | 强于临时 AI 编码之处 | 可能引入的开销 | 实践落地缺口 |
|---|---|---|---|---|---|
| Requirements and scope control | Planner 负责需求理解、澄清、验收标准；Human 确认需求；产物包括 `requirements.md`、`tasks.md`。证据：`SRC-PROPOSAL-README`、`framework_map.md`。 | SDLC 需求分析、用户故事、验收标准、Definition of Done。 | 避免直接把一句需求交给编码 Agent，降低需求漂移。 | 小修复也写完整需求文档会拖慢节奏。 | 需要定义任务分级：微小修复、普通功能、高风险变更分别需要哪些产物。 |
| Architecture decision management | Architect 输出 `design.md` 和 ADR；架构确认是 Human Gate；MVP 仍存在 Architect 是否并入 Planner 的开放问题。 | ADR、架构评审、技术方案评审。 | 将架构选择从代码生成中分离，减少 Agent 擅自改架构。 | 每个任务都要求设计审查会造成过度流程化。 | 需要 README 明确何时必须生成 ADR，何时只需轻量 design note。 |
| Task planning and decomposition | 标准流程包含 Requirement Spec、Architecture Decision、Task Breakdown；Supervisor 选择工作流、分配 Agent。 | WBS、迭代计划、ticket 分解、Kanban/Scrum 状态流。 | 让 AI 按任务单工作，而不是在长对话中隐式规划。 | Supervisor 角色若仅靠 prompt 执行，可能成为额外协调负担。 | 需要最小任务单字段、状态机、循环上限和升级规则的可执行模板。 |
| Coding execution | Developer 只负责实现、必要测试、缺陷修复和实现说明；不能自行改需求、改架构或宣布完成。 | 分支开发、PR 提交、CI 前置验证。 | 降低“生成代码后直接视为完成”的风险。 | Developer 交付字段较多，简单改动成本偏高。 | 需要定义 Developer 输出格式、允许命令、禁止文件范围和失败时证据要求。 |
| Testing and verification | Tester 独立设计和执行测试；MVP 可合并为 Reviewer-Tester；质量门禁要求 tests pass。 | QA、测试计划、回归测试、CI pipeline。 | 将“跑没跑测试”和“怎么验证”从 Agent 自述变成门禁材料。 | 独立 Tester 对 MVP 人力和 token 成本较高。 | 需要区分手动验证、单元测试、集成测试、CI 检查和不可验证场景的处理规则。 |
| Review and approval | Reviewer 独立做 Code Review、架构一致性、安全质量和门禁判断；结论限定为 approved / changes_requested / blocked 等。 | PR Review、branch protection、required reviews。 | 对 AI 代码建立独立二次判断，符合 `SRC-012` 中 Copilot 输出仍需严格 Review 的原则。 | Review Agent 可能重复 Developer 分析，且无真实权限约束时容易流于形式。 | 需要把 Reviewer blocker 分类、严重度和必查清单写成 README 可复用模板。 |
| Incident or urgent fix handling | 工作流类型包含 `incident-fix`，但当前 map 未展开其快速路径和事后补偿。 | Incident management、hotfix、postmortem、emergency change approval。 | 至少承认紧急修复不同于普通 feature-dev。 | 若仍强制完整 spec/design/test/review 流程，会影响恢复速度。 | 需要定义紧急路径：最小审批、最小验证、发布后补文档、复盘和回滚要求。 |
| Context and knowledge management | 定义 Source of Truth、Run State、Retrieval Context、Ephemeral Context；长期记忆只接受已产物化并确认内容；Context Pack 有标准字段。 | 需求仓库、ADR、知识库、runbook、代码索引、checkpoint。 | 比临时对话更可追踪，减少上下文污染。`SRC-001` 支持 checkpoint 对 HITL 和恢复的重要性。 | 维护 context pack 和长期记忆需要持续治理。 | 需要说明 Context Pack 由谁生成、如何校验、何时更新、与现有项目文档冲突时谁优先。 |
| Human approval and governance | 人控制需求、架构、权限、merge、release、loop 超限；AI 不能越权批准；人的决策必须产物化。 | Change approval、权限控制、审计、合规发布。 | 把人从“随时盯聊天”转为关键边界审批，符合 `SRC-002`、`SRC-012` 的 HITL / 权限门思想。 | 过多人工点会让流程变慢，审批也可能变成橡皮章。 | 需要明确哪些动作必须人批、哪些可自动通过，以及审批记录格式和审计保留方式。 |
| Tooling and platformization | 六层架构包含 Execution Layer 和 Governance Layer；第一阶段交付 Skill，不做完整平台。 | 平台工程、CI/CD、内部开发者平台、Agent runtime。 | 避免一开始建设重平台，先用 Skill 固化协作规范。 | Skill 若没有项目探测和可执行脚本，可能只停留在文档。 | 需要定义 Skill MVP 的 repo-local 生成物、检测脚本、版本升级和与 CI/PR 工具的接口边界。 |

## Findings

### [ANA-CMP-001] Artifact-first 模型与 SDLC/PR 流程高度一致，但需要任务分级以控制 MVP 成本

**Evidence**: `framework_map.md` 显示当前方案采用 Artifact-First、Spec-Driven、Quality-Gated 模式，要求 requirements、design、tasks、implementation、test_report、review_report 等产物；`research-overview.md` 要求以 MVP 和务实落地为研究立场；`SRC-011` 和 `SRC-012` 显示产品化 coding agent 仍围绕 branch、PR、logs、review 和 CI 权限运行。

**Reasoning**: 当前方案把 AI coding 从“对话生成代码”提升为“通过可审查产物推进交付”，这与成熟 SDLC、PR review、CI gate 一致。该设计能提升可追踪性和质量控制，但如果所有任务都强制完整产物链，MVP 会在小修复、文案调整、低风险配置变更上承担不成比例的流程成本。

**Implication**: 方案强点是真正面向团队交付，而不是单人 prompt 技巧；风险是把企业级流程提前压到所有任务，导致团队放弃执行或绕开流程。

**Recommendation**: README 应新增“任务分级与最小产物表”：例如 `S0 trivial` 只需任务说明、diff、测试证据；`S1 normal` 需要 requirements、tasks、implementation、review_report；`S2 high-risk` 才强制 design/ADR、独立 Tester、Human architecture approval 和 release approval。

### [ANA-CMP-002] Supervisor-Controlled 编排符合多智能体框架方向，但当前缺少可执行状态机

**Evidence**: `framework_map.md` 描述 Supervisor 负责识别任务、选择工作流、调度 Agent、控制上下文、执行门禁和升级给人；`SRC-003` 列出 Sequential、Concurrent、Handoff、Group Chat、Magentic 等编排模式；`SRC-004` 强调应用侧拥有 orchestration、tool execution、approvals 和 state；`SRC-001` 指出 checkpoint/persistence 支持 HITL、恢复和调试。

**Reasoning**: 当前方案选择 Supervisor + artifact handoff，而不是自由群聊，这比松散多 Agent 对话更接近工程可控编排。不过 README 层面若只描述职责，没有状态、转移、失败条件、最大循环次数和恢复点，Supervisor 很容易退化为一个长 prompt，而不是可复用流程。

**Implication**: 方案方向正确，但要成为团队 Skill，必须把“编排意图”压缩成 repo-local 可执行或半可执行的 workflow 定义。

**Recommendation**: README 应补充 MVP workflow 状态机：`intake -> planning -> implementation -> verification -> review -> fix_loop -> acceptance`，并为每个状态定义输入、输出、允许 Agent、门禁条件、失败退出、人工升级条件和最大循环次数。

### [ANA-CMP-003] 角色边界能降低 AI 交付失控，但 MVP 中 Reviewer-Tester 合并会削弱独立验证

**Evidence**: `framework_map.md` 明确 Planner、Architect、Developer、Tester、Reviewer 的产物和禁止事项，并指出 MVP Agent 为 Supervisor、Planner、Developer、Reviewer-Tester；`SRC-009` 将 LLM 修复 GitHub issue 的失败分布到多个 repair pipeline 阶段；`SRC-012` 要求 Copilot PR 像其他贡献一样严格 review。

**Reasoning**: 独立角色边界是当前方案最有价值的部分之一，尤其是 Developer 不能自行改需求、改架构或宣布完成。MVP 合并 Reviewer 与 Tester 可以降成本，但测试设计与代码审查的关注点不同：测试关注行为覆盖和回归，Review 关注代码质量、架构一致性、安全和可维护性。合并后如果没有明确 checklist，会形成“同一个 Agent 快速看一遍”的弱门禁。

**Implication**: MVP 可以合并角色，但不能合并责任。否则质量门禁看似存在，实际只是一段自我确认文本。

**Recommendation**: README 应将 MVP 角色命名为 `Reviewer-Tester`，但要求其输出分成两个独立章节：`Verification` 和 `Review`。同时定义 blocker 清单，例如未运行关键测试、修改超出需求范围、触及权限/CI/安全文件、架构偏离 design、无法解释变更影响。

### [ANA-CMP-004] Human Gate 设计符合 HITL 最佳实践，但需要区分审批、咨询和通知

**Evidence**: `framework_map.md` 要求人控制需求、架构、权限、Merge、Release 和 Loop 超限，并把人的决策写入 spec、ADR 或 acceptance 产物；`SRC-002` 描述 HITL 中 approve、edit、reject、respond 等不同决策；`SRC-005` 显示 guardrails 需要分布在输入、输出和工具调用边界；`SRC-006` 强调 tracing 可记录工具调用、handoff 和 guardrails。

**Reasoning**: 当前方案避免 AI 越权批准，是面向真实团队的必要边界。但“Human approval”如果定义过宽，会导致所有节点都等待人；如果定义过窄，又可能让 AI 绕过高风险操作。成熟做法不是处处审批，而是按动作风险定义不同人类参与方式。

**Implication**: 人类控制点必须可执行、可审计、可区分；否则会在效率和治理之间两头失效。

**Recommendation**: README 应新增 Human Gate 分类：`approval_required`、`review_required`、`info_required`、`notify_only`。对权限提升、merge、release、CI workflow 修改设为 `approval_required`；对需求歧义设为 `info_required`；对低风险测试失败重跑设为 `notify_only` 或自动处理。

### [ANA-CMP-005] 上下文与记忆模型成熟，但需要冲突解析和更新机制

**Evidence**: `framework_map.md` 定义 Source of Truth、Run State、Retrieval Context、Ephemeral Context，并要求长期记忆只接受已产物化并确认的内容；`SRC-001` 支持 checkpoint、memory、time travel 和 fault-tolerant execution；`SRC-006` 显示 tracing 可帮助监控 agent workflow，但也提示敏感数据处理风险。

**Reasoning**: 当前上下文模型比临时 AI coding 强，因为它限制 Agent 只使用必要上下文，并把长期记忆建立在确认产物上。不过实践中最常见的问题不是没有上下文，而是上下文冲突：README、ADR、代码、CI、issue 和聊天确认可能不一致。若缺少优先级和更新机制，Agent 会选择最方便的上下文解释。

**Implication**: Context Pack 是 MVP 必需能力，但必须配套冲突处理；否则会把错误上下文更稳定地传给多个 Agent。

**Recommendation**: README 应定义 Source of Truth 优先级和冲突规则：例如当前代码与旧文档冲突时必须标记 `context_conflict`；已批准 ADR 高于普通建议；Human acceptance 高于 Agent 结论；任何长期记忆更新必须引用来源、时间和批准者。

### [ANA-CMP-006] 质量门禁覆盖主路径，但缺少“不可验证”和“证据不足”的处理

**Evidence**: `framework_map.md` 的最小质量门禁包括 requirements accepted、design accepted、acceptance criteria、tests pass、reviewer no blocker、human approves merge；Developer 必须提交 changed files、rationale、test commands、test result、known limitations；`SRC-007` 说明真实 GitHub issue 需要长上下文和跨文件修改；`SRC-008` 说明静态 benchmark 可能过时并需要动态评测；`SRC-009` 支持失败模式与 repair-loop 分析。

**Reasoning**: 当前门禁适合防止“没测试就交付”和“没审查就合并”。但真实项目常出现测试环境不可用、外部服务不可访问、缺少 fixture、无法复现、CI flaky、需求验收不可自动化等情况。如果 README 只写 `tests pass`，Agent 可能把未验证包装成通过，或者因为不能验证而停滞。

**Implication**: 质量门禁需要处理灰度状态，而不是只有通过/失败。MVP 的可信度取决于能否诚实表达证据不足。

**Recommendation**: README 应加入验证状态：`verified`、`partially_verified`、`not_verified`、`blocked_by_environment`。任何非 `verified` 状态必须附带缺口、风险、建议补测命令和是否允许进入人工验收。

### [ANA-CMP-007] Skill-first 交付路径务实，但必须避免“文档包伪平台化”

**Evidence**: `framework_map.md` 把最终共享产物定义为 `AI Native Development Framework Skill`，明确第一阶段不替代项目管理系统、不实现企业级 Agent 编排平台、不替代 CI/代码平台/发布系统；`research-overview.md` 排除实现 LangGraph、Microsoft Agent Framework 或平台原型；`SRC-004` 和 `SRC-003` 表明平台和 SDK 能力存在，但不等于本研究必须选型落地。

**Reasoning**: Skill 是合理 MVP，因为它能以低成本标准化 Agent Blueprint、workflow、template 和 gate。问题是如果 Skill 只有说明文档，没有初始化目录、模板、检查脚本或执行约束，它对团队行为的改变有限；反过来，如果 Skill 过早包含 runtime、RBAC、SSO、审计和成本控制，又会滑向平台建设。

**Implication**: 当前方案的交付边界正确，但 README 需要更硬地定义 Skill MVP 的可交付内容和非目标。

**Recommendation**: README 应把 Skill MVP 限定为：`SKILL.md`、agent blueprints、workflow templates、quality gate checklist、context pack template、spec/ADR/review/test templates、repo initialization guide、optional validation script。明确不包含 Agent runtime、长期数据库、统一控制台、企业权限系统和自动发布系统。

### [ANA-CMP-008] Incident-fix 被列入工作流类型，但尚不足以支持紧急生产变更

**Evidence**: `framework_map.md` 将 `incident-fix` 列为主要工作流类型之一，但标准流程仍是 Intake、Requirement Spec、Architecture Decision、Task Breakdown、Implementation、Test、Review、Fix Loop、Acceptance、Merge/Release；Open Questions 关注质量门禁、Loop 超限和平台化前收益成本统计；`SRC-012` 强调 workflow/CI 权限变更需要特别谨慎。

**Reasoning**: Incident 修复通常需要优先恢复服务，流程应比普通功能更短，但事后补偿更强。当前提案没有区分紧急修复的最小上下文、临时授权、回滚、发布后复盘和补充测试。如果照搬完整 feature-dev 流程，会降低响应速度；如果完全跳过门禁，又会放大 AI 在高压场景下的错误。

**Implication**: `incident-fix` 不能只是工作流名称，需要单独定义快速路径和补偿路径。

**Recommendation**: README 应新增 `incident-fix` MVP 流程：`triage -> minimal safe patch -> smoke test -> human emergency approval -> deploy/merge -> post-incident review -> backfill spec/test/ADR if needed`。同时要求记录绕过了哪些普通门禁、谁批准、何时补齐。

## Gaps

1. 缺少任务复杂度与风险分级，导致同一套门禁可能同时过重和不足。证据：`framework_map.md` 的 MVP Map 与 Open Questions。
2. 缺少可执行 workflow 状态机；当前已有阶段名称和角色，但还没有每阶段输入、输出、转移、失败和升级规则。证据：`framework_map.md`、`SRC-001`、`SRC-003`。
3. 缺少 Context Pack 生成、校验、冲突解析和长期记忆更新规则。证据：`framework_map.md` 的 Context and Memory Map。
4. 缺少针对不可验证、部分验证、环境阻塞和 flaky CI 的门禁结果分类。证据：`framework_map.md` 的 Quality Gate Map、`SRC-007` 至 `SRC-009`。
5. 缺少 Reviewer-Tester 合并后的独立责任清单，MVP 可能降低质量独立性。证据：`framework_map.md` 的 MVP Map 与 Agent Role Map。
6. 缺少 incident-fix 的快速路径、回滚、补偿文档和 postmortem 要求。证据：`framework_map.md` 的 Workflow Map。
7. 缺少 Skill MVP 的精确定义：哪些是必须文件，哪些是可选脚本，哪些明确属于平台阶段。证据：`framework_map.md` 的 Skill Delivery Map 和 Enterprise Evolution Map。
8. 缺少 adoption metrics，用于判断流程是否真的优于 ad hoc AI coding。证据：`research-overview.md` 核心问题 6、`SRC-008` 对动态评测的强调。

## Recommendations for Proposal Revision

1. 在 README 中新增“任务分级矩阵”，按 `trivial / normal / high-risk / incident` 定义必需 Agent、必需产物、质量门禁和人工审批点。
2. 将 MVP Agent 固定为 `Supervisor`、`Planner`、`Developer`、`Reviewer-Tester`，但要求 `Reviewer-Tester` 输出测试验证和代码审查两个独立结论。
3. 把标准 workflow 改写为状态机表格，每个状态列出输入、输出、负责人、允许工具、通过条件、失败条件和升级条件。
4. 为 Human Gate 增加四类参与方式：`approval_required`、`review_required`、`info_required`、`notify_only`，避免所有人类参与都被理解为阻塞审批。
5. 扩展质量门禁结果，不只允许 pass/fail，还应支持 `partially_verified`、`not_verified`、`blocked_by_environment`，并要求附带证据和剩余风险。
6. 在 Context Pack 章节加入 Source of Truth 优先级、冲突标记规则、长期记忆更新规则和敏感信息处理要求。
7. 为 `incident-fix` 单独定义 MVP 流程，强调最小修复、人工紧急批准、smoke test、回滚准备和事后补齐文档/测试。
8. 将 Skill MVP 明确为可共享“规则和模板包”，包含 agent blueprints、workflow templates、context pack、quality gates、spec/ADR/test/review templates 和初始化说明；明确排除 runtime 平台、RBAC、SSO、成本控制面板和自动发布系统。
9. 增加评估指标：任务完成率、Review blocker 数、返工轮次、测试证据完整度、人工审批等待时间、需求漂移次数、未验证交付次数、incident 修复后补偿完成率。
10. 增加“何时不使用完整流程”的说明：对低风险、低影响、可快速回滚的变更允许轻量路径，但仍必须保留 diff、测试证据和最终人工验收。
