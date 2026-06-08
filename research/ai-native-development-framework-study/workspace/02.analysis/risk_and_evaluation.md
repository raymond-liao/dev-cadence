# Risk and Evaluation Analysis

## Input Artifacts

| Artifact | Status | Usage |
|---|---:|---|
| `references/methodology/research-overview.md` | 已读取 | 确认研究目标、MVP 取向、排除范围和核心问题。 |
| `references/methodology/analysis-methods.md` | 已读取 | 确认本分析应输出风险、实验、指标、质量门禁和人工升级规则。 |
| `workspace/01.materials/framework_map.md` | 已读取 | 作为框架结构、角色边界、工作流、上下文、MVP 和演进路线的主要内部分析依据。 |
| `workspace/02.analysis/comparative_analysis.md` | 已读取 | 使用 `ANA-CMP-*` 结论补强任务分级、状态机、Human Gate、验证状态、incident-fix 和 Skill-first 风险判断。 |
| `workspace/02.analysis/skill_delivery_design.md` | 已读取 | 使用 `ANA-SKILL-*` 结论补强 Skill MVP 边界、四角色三工作流六产物、文件化门禁、Context Pack 和证据不足处理。 |
| `workspace/01.materials/external_sources.md` | 已读取，补充使用 | 用于支撑对 HITL、状态持久化、工具审批、追踪、评测和失败模式分析的风险判断。 |
| `SRC-PROPOSAL-README` | 已读取，权威来源 | 作为当前框架方案的事实来源，尤其是角色边界、质量门禁、Loop、Context Pack、Skill 和 MVP 方案。 |

## Risk Matrix

| Risk | Probability | Impact | Detection Signal | Prevention Mechanism | Escalation Rule |
|---|---:|---:|---|---|---|
| Supervisor 越权写代码、改设计或代替 Reviewer 放行 | 中 | 高 | Supervisor 输出包含代码 diff、架构决策、approval 结论，或跳过 Worker 产物 | 在 Supervisor Blueprint 和 `.ai/policies/quality-gates.md` 中写入硬性禁止事项；每个阶段只允许读取/检查/调度/升级 | 任一越权行为直接转人工确认，并要求重跑受影响阶段 |
| Developer 自审自批，声明“已完成”但缺少测试或 Review 证据 | 高 | 高 | implementation 只有结论，没有 test command、test result、changed files、known limitations | 保持 README 的 Developer 必交字段为 Gate 4 前置条件；缺少任一字段不得进入 Review | 缺证据时退回 Developer 一次；重复缺失升级给人 |
| Tester 或 Reviewer  rubber-stamping，仅给出泛化 approval | 中 | 高 | review/test report 无文件、测试、spec 引用；没有 blocker/major/minor 分类；只写“看起来可以” | 使用结构化 issue 格式和固定 Review 结论枚举；要求每个 approval 至少说明检查范围和证据 | 连续两次无证据 approval 时人工抽检，并暂停该 Reviewer-Tester 配置 |
| Spec drift：实现偏离 requirements/design/tasks | 高 | 高 | diff 修改了未列入 task 的范围；实现说明引入未批准需求；测试用例不覆盖验收标准 | Context Pack 必须包含 acceptance criteria、constraints、forbidden actions；Review Gate 增加 spec-diff 检查 | 涉及范围变更时进入 Spec Loop，由人确认需求或设计修订 |
| Context pollution：聊天内容或未确认结论进入长期记忆 | 中 | 高 | Agent 引用聊天中的口头决定，但 spec、ADR、test_report、review_report 中无记录 | 维持 README 的 Source of Truth 规则；长期记忆只接受确认后的 requirements、design、ADR、review conclusion、test result、acceptance decision | 发现污染时冻结当前 run state，人工选择写入正式产物或丢弃该上下文 |
| Fix Loop 无边界，反复修复消耗成本并扩大改动范围 | 中 | 高 | fix iteration 超过 3；每轮改动文件数增长；同一 blocker 重复出现 | 强制 `max_fix_iterations = 3`；每轮 Fix 必须引用上一轮 issue ID 和 required_change | 第 3 次仍未通过时停止自动修复，交给人决定重构、降级范围或终止 |
| Tool permission abuse：越权访问网络、数据库、密钥、生产环境或删除文件 | 中 | 高 | 工具调用触及 workspace 外路径、外部网络、凭证、数据库写操作、删除命令 | `.ai/policies/permission-policy.md` 按工具和路径定义 approve/edit/reject；高风险工具默认人工审批 | 任一高风险工具调用必须人工批准；未批准调用视为 workflow blocker |
| Missing test evidence：测试未跑、测试不可复现或结果无法追踪 | 高 | 高 | test_report 缺少命令、环境、结果摘要、失败日志、不可测说明 | Gate 4 要求 test command、test result、覆盖范围和不可测限制；CI 可用时优先使用 CI 结果 | 无法测试必须由人接受风险；关键路径无测试证据不得 merge |
| Workflow overhead 过高，小任务也被迫走完整流程 | 高 | 中 | 小改动 cycle time 明显高于人工基线；文档时间超过实现时间；Agent 产物大量重复 | README 增加任务分级：trivial/small/standard/high-risk；小任务使用轻量 gate，大任务使用完整 gate | 连续 3 个小任务出现负收益时调整工作流模板并记录例外规则 |
| Skill 规则陈旧，与真实 repo、工具版本或团队习惯脱节 | 中 | 中 | Agent 反复违反同一规则；模板字段长期空置；Review 频繁要求手工补充固定信息 | Skill 像代码一样版本化；每次规则变更记录原因、影响工作流和回归样例 | 月度或每 10 个任务复盘一次；关键规则失效时发布 Skill patch 版本 |
| Platformization before process validation：在流程有效性未证实前建设平台 | 中 | 高 | 先讨论 LangGraph/MAF/RBAC/SSO/审计平台，而没有 MVP 任务数据 | 严守 README Level 1/Skill-first 路线；平台需求必须来自稳定、高频、可度量的 repo-local 流程 | 没有 MVP 指标达标前冻结平台实现，只允许改进 Skill 和模板 |
| Repo-local 规则冲突：`.ai/` 规则与既有 `CONTRIBUTING`、CI、代码所有权或安全策略不一致 | 中 | 高 | Agent 在 `.ai/`、README、ADR、CI 或本地安全策略之间选择性引用；Review 反复指出流程冲突 | Skill 初始化时检查本地规则；README/Skill 增加 Source of Truth 优先级、冲突标记和人工裁决规则 | 任一治理冲突进入人工裁决，并将裁决写入 `.ai/policies/*`、ADR 或 acceptance |

## MVP Experiments

| Experiment | Design | Success Criteria | Related Metrics |
|---|---|---|---|
| E1: 单 Agent 基线对比 | 选取 6-9 个真实小型任务，覆盖 `feature-dev`、`bugfix`、`code-review`。一组使用现有单 Agent/人工协作，一组使用 MVP 流程 `Supervisor + Planner + Developer + Reviewer-Tester`。 | 在缺陷逃逸不升高的前提下，MVP 组在可追踪性和 Review blocker 发现率上明显更好；cycle time 不超过基线 1.5 倍。 | task cycle time、defect escape rate、review blocker discovery、test evidence completeness |
| E2: 质量门禁有效性实验 | 在可控任务中注入常见问题：缺少测试、偏离验收标准、过度修改文件、未记录限制。观察 Reviewer-Tester 是否拦截。 | 至少 80% 注入问题被 Gate 4/Gate 5 捕获；所有 blocker 都包含 evidence 和 required_change。 | blocker detection rate、evidence completeness、false approval count |
| E3: Context Pack 最小化实验 | 同类任务分别使用完整聊天记录和最小 Context Pack；比较漂移、错误引用和产物质量。 | 最小 Context Pack 的 spec drift 不高于完整聊天，且上下文包大小减少 40% 以上。 | context pack size、spec drift count、irrelevant context ratio |
| E4: Fix Loop 压力测试 | 选择需要多轮修复的缺陷任务，强制记录每轮 issue、patch、test 和 review 结果。 | 平均 fix loop count 不超过 2；超过 3 次时 100% 升级给人。 | fix loop count、repeat blocker rate、human escalation correctness |
| E5: 权限门禁演练 | 设计涉及网络、数据库、敏感配置、删除操作或 workspace 外写入的模拟请求。 | 高风险工具调用 100% 被拦截并要求人工审批；低风险命令不被过度阻断。 | permission escalation rate、unauthorized tool attempt count、approval latency |
| E6: Skill 规则可维护性试运行 | 将 README 中的规则整理为手工执行清单，在 2-3 个 repo-local 任务中使用，但不建设平台。 | 规则字段实际填写率超过 80%；团队能指出应删除、合并或新增的规则。 | template field completion、workflow friction score、rule change count |

## Evaluation Metrics

| Metric | Definition | Measurement Method | Initial MVP Target |
|---|---|---|---|
| Task cycle time | 从 `00-brief` 或需求确认到 human acceptance 的耗时 | 记录每阶段开始/结束时间，使用 median 和 p75 | standard 小任务 p75 不超过人工/单 Agent 基线 1.5 倍 |
| Defect escape rate | 通过 Review/Gate 后仍被人或后续测试发现的缺陷比例 | `escaped_defects / accepted_tasks` | MVP 前 10 个任务低于基线，或至少不高于基线 |
| Review blocker discovery | Reviewer-Tester 发现真实 blocker/major 的比例 | `confirmed_blockers / reviewed_tasks`，人工抽样确认 | 有风险任务中 blocker/major 发现率可解释且证据完整 |
| Test evidence completeness | test_report 是否包含命令、环境、结果、失败/限制说明 | 按字段打分：0-100% | 每个 merge 候选任务达到 100%；不可测项必须人工接受 |
| Human intervention frequency | 每个任务触发人工确认或升级的次数 | run state 中记录 Requirement、Architecture、Permission、Loop、Merge、Release | 高风险任务允许较高；低风险小任务目标不超过 2 次 |
| Context pack size | 每个 Agent 接收的上下文字符数、文件数和引用数 | 统计 Context Pack 字段和附件 | 比完整聊天记录减少 40% 以上，且不增加 spec drift |
| Fix loop count | 从首次 Review/Test 失败到通过或升级的迭代次数 | 每轮记录 issue ID、owner、patch、test result | 平均不超过 2；硬上限 3 |
| Spec change count | 实现阶段后 requirements/design/tasks 被修改的次数 | 对 spec 文件版本或变更记录计数 | 标准任务不超过 1；高于 1 需复盘需求澄清质量 |
| Permission escalation rate | 触发权限审批的工具调用占比 | 按工具调用日志分类 | 高风险操作 100% 审批；普通测试/读取不过度审批 |
| Workflow friction score | 开发者对流程负担的评分 | 每任务 1-5 分，1=低摩擦，5=高摩擦，并记录原因 | median 不超过 3 |
| Artifact completion rate | 必需产物是否按工作流生成并包含必要字段 | requirements/design/tasks/implementation/test_report/review_report 字段检查 | MVP 任务达到 90% 以上 |
| Rule change count | 每轮试运行后 Skill/README 规则需要调整的数量 | 复盘记录新增、删除、合并、改写规则 | 前期允许较高；连续两轮下降说明规则趋稳 |

## Quality Gate Recommendations

1. 将 README 的最小质量门禁扩展为可执行检查清单，而不是只保留原则描述。每个 Gate 应定义 `required_inputs`、`required_outputs`、`pass_condition`、`fail_condition`、`human_override` 和 `evidence_fields`。

2. 在 Gate 3 和 Gate 4 之间增加 “scope guard”。Developer 开始实现前必须确认 `target_files`、`forbidden_actions`、`acceptance_criteria` 和 `known_constraints`；实现中触碰范围外文件应自动进入 Review warning 或人工确认。

3. 将 Reviewer-Tester 的 approval 规则写得更严格：`approved` 必须包含检查范围、测试证据和未覆盖风险；`approved_with_minor_notes` 不能包含任何 blocker/major；`changes_requested` 和 `blocked` 必须使用 README 第 7.4 节的结构化 issue 格式。

4. 将 “测试通过” 改为 “测试证据完整且可复现”。Gate 4 不只检查 pass/fail，还要检查 test command、运行环境、覆盖范围、失败日志、跳过测试原因和 known limitations。

5. 为任务分级定义不同门禁强度，避免 MVP 因流程过重失败。结合 `ANA-CMP-001` 和 `ANA-SKILL-002`，建议 README/Skill 增加 `S0 trivial`、`S1 normal`、`S2 high-risk`、`incident` 四类任务，并规定哪些任务可合并 Planner/Architect、哪些任务必须单独 architecture approval。

6. 将 `max_fix_iterations = 3` 落到每个 `specs/{task_id}` 的 run state 中。每次 Fix Loop 必须记录 `iteration_number`、`source_issue_id`、`changed_files`、`test_result` 和 `remaining_risk`。

7. 在 Skill MVP 中优先沉淀 policy 和模板，而不是脚手架或平台能力。结合 `ANA-SKILL-001` 和 `ANA-SKILL-003`，最小可交付内容应包括 agent blueprints、workflow definitions、quality gates、permission policy、context policy、escalation policy、acceptance record 和 spec templates。

8. 在 README 的 “从 Skill 到平台” 部分增加平台化准入条件：至少完成一轮 MVP 实验、指标可被记录、规则变化趋稳、人工门禁有效、团队确认流程摩擦可接受。

## Human Escalation Rules

| Trigger | Escalation Owner | Required Human Decision | Required Artifact Update |
|---|---|---|---|
| 需求或设计有歧义，Agent 需要自行解释目标 | Human + Planner | 明确范围、非目标和验收标准 | `requirements.md` 或 `design.md` |
| 实现需要修改未列入任务范围的文件或行为 | Human + Reviewer | 批准范围变更、拆分任务或拒绝变更 | `tasks.md`、`design.md` 或 ADR |
| 权限涉及网络、数据库、密钥、生产环境、删除操作、workspace 外写入 | Human | approve/edit/reject 工具调用 | `permission decision` 或 run state |
| Fix Loop 达到 3 次仍未通过 | Human + Reviewer-Tester | 继续、降级范围、重做设计、转人工实现或终止 | `review_report.md` 和 `acceptance.md` |
| Reviewer-Tester 无法给出证据但倾向放行 | Human + Reviewer-Tester | 接受风险、要求补测或更换 Reviewer | `review_report.md` |
| 测试无法运行或关键测试缺失 | Human + Developer | 接受不可测风险、补充测试环境或阻止合并 | `test_report.md` 和 `acceptance.md` |
| Agent 之间结论冲突且都有证据 | Human + Supervisor | 选择结论、要求补充实验或拆分决策 | ADR 或 `acceptance.md` |
| 成本、上下文或时间预算超限 | Human + Supervisor | 继续投入、缩小范围或停止任务 | run state 和 `tasks.md` |
| Skill 规则与项目实际冲突 | Human + framework owner | 临时例外、规则修订或版本升级 | `.ai/policies/*` 或 Skill 版本记录 |
| 准备进入平台实现阶段 | Human + team lead | 是否满足平台化准入条件 | roadmap 或 ADR |

## Findings

### [ANA-RISK-001] 角色边界是 MVP 的首要风险控制点

**Evidence**: `SRC-PROPOSAL-README` 明确规定 Supervisor 不写代码、不代替 Reviewer 放行；Developer 不能自行宣布完成；Tester 和 Reviewer 独立于 Developer。`framework_map.md` 也将这些边界列为 Agent Role Map 和 Quality Gate Map 的核心内容。

**Reasoning**: 多 Agent 流程的质量收益来自职责分离。如果 Supervisor 或 Developer 能直接越过测试、Review 和人工合并，框架会退化为单 Agent 自动交付，并保留多 Agent 的额外成本。

**Implication**: MVP 不应优先追求更多 Agent，而应先验证 Planner、Developer、Reviewer-Tester 和 Supervisor 的边界能否被稳定执行。

**Recommendation**: 在 README 或 Skill MVP 中把角色禁止事项转成可检查 gate：Supervisor 输出不得包含 code diff 或 approval，Developer 输出不得包含最终完成声明，Reviewer-Tester approval 必须包含证据。

### [ANA-RISK-002] “测试通过”不足以作为质量门禁，必须升级为可复现证据门禁

**Evidence**: `SRC-PROPOSAL-README` 要求 Developer 提交 test commands、test result 和 known limitations，并禁止无测试证据的质量声明。`external_sources.md` 中 SRC-007、SRC-008、SRC-009 均说明真实软件任务需要长上下文、真实仓库验证和失败模式追踪，不能只依赖模型自信判断。

**Reasoning**: AI Agent 容易给出看似完成的结论。若 test_report 不能复现，Reviewer 和人都无法判断风险，后续 defect escape rate 也无法度量。

**Implication**: 没有测试证据的任务即使 diff 看起来合理，也不应进入 merge acceptance。

**Recommendation**: 将 Gate 4 从 `tests pass` 改写为 `test evidence complete and reproducible`，并要求记录命令、环境、覆盖范围、失败日志、跳过原因和限制。

### [ANA-RISK-003] Context Pack 既是效率机制，也是防漂移机制

**Evidence**: `SRC-PROPOSAL-README` 第 9 节要求每个 Agent 使用最小必要 Context Pack，并规定 chat 不是事实来源；`framework_map.md` 将 Source of Truth、Run State、Retrieval Context、Ephemeral Context 区分为四层。

**Reasoning**: 完整聊天记录会把未确认假设、临时想法和过期决策带入执行阶段；上下文过少又会导致实现偏离验收标准。MVP 需要验证 Context Pack 字段是否足以约束 Developer 和 Reviewer-Tester。

**Implication**: 如果不度量 context pack size 和 spec drift，团队无法知道上下文策略是在降噪还是在丢失关键信息。

**Recommendation**: MVP 每个任务记录 Context Pack 大小、引用文件数、spec drift count 和人工补充上下文次数；长期记忆只接受已产物化并确认的内容。

### [ANA-RISK-004] Fix Loop 必须硬性封顶，否则成本和范围会失控

**Evidence**: `SRC-PROPOSAL-README` 明确 `max_fix_iterations = 3`，失败后升级给人；`framework_map.md` 也把最多 3 次 Fix Loop 作为 MVP 闭环规则。

**Reasoning**: 自动修复很容易在同一缺陷上反复尝试，或为了消除一个问题扩大改动范围。硬性上限能暴露需求、设计或测试本身的问题。

**Implication**: Loop 上限不是效率优化，而是人类控制边界；超过上限说明当前任务已不适合继续自动推进。

**Recommendation**: 在每个 `specs/{task_id}` 中记录 fix iteration；第 3 次仍未通过时强制停止并由人决定重做设计、拆分任务、转人工或终止。

### [ANA-RISK-005] MVP 最大的采用风险可能是流程负担，而不是技术不可行

**Evidence**: `research-overview.md` 要求不要默认多 Agent 有价值，必须评估质量收益和流程成本。`SRC-PROPOSAL-README` 定义了 requirements、design、tasks、implementation、test_report、review_report 等 MVP 产物。`ANA-CMP-001` 和 `ANA-SKILL-002` 均建议通过任务分级控制 MVP 成本。

**Reasoning**: 对小任务强制完整 spec、design、test、review 可能导致 cycle time 变长，开发者绕过流程，最终使规则失效。

**Implication**: 若不按任务风险分级，框架可能在高风险任务上有价值，但在日常小改动中被视为负担。

**Recommendation**: README/Skill 增加任务分级和轻量工作流：`S0 trivial` 可只要求 task note、implementation、test evidence 或 not verified reason；`S1 normal` 使用核心产物；`S2 high-risk` 必须增加 design/ADR、架构和权限人工确认；`incident` 使用紧急批准和事后补偿路径。

### [ANA-RISK-006] Skill-first 路线需要平台化准入指标

**Evidence**: `SRC-PROPOSAL-README` 明确第一阶段应交付团队 Skill，不应一开始做完整平台，并给出 Level 1 到 Level 5 的演进路线。`framework_map.md` 也将 “Platformization before process validation” 列为需要关注的演进风险。`ANA-CMP-007` 和 `ANA-SKILL-001` 进一步指出 Skill-first 路径应保持文件系统边界，避免“文档包伪平台化”和过早平台化。

**Reasoning**: 平台会固化流程。如果流程规则尚未经过真实任务验证，平台化会放大错误抽象，并增加 RBAC、审计、成本统计、Agent 版本管理等非 MVP 复杂度。

**Implication**: 过早平台化会让研究目标从“验证协作框架”转移到“建设工具系统”，与 MVP-oriented systematic study 冲突。

**Recommendation**: 在 README 的演进路线中增加平台化准入条件：完成至少 6-9 个 MVP 任务、关键指标可记录、规则变更趋稳、缺陷逃逸不高于基线、团队摩擦评分可接受。

### [ANA-RISK-007] Skill 门禁必须文件化，否则会退化为角色提示词

**Evidence**: `ANA-SKILL-003` 指出 Skill 必须生成 `.ai/policies/permissions.md`、`.ai/policies/escalation.md`、`.ai/policies/quality-gates.md` 和 `specs/{task_id}/acceptance.md`。`SRC-PROPOSAL-README` 也要求人的决策必须写入 spec、ADR 或 acceptance 产物，不能只停留在聊天记录。

**Reasoning**: 如果 Skill 只包含 Agent prompt 和流程说明，AI 仍可以在长对话中“扮演”角色，但团队无法审计权限批准、循环超限、Review blocker、测试缺口和人类验收。文件化门禁把关键决策从聊天状态转成可复盘事实。

**Implication**: 没有 policy 和 acceptance 文件，框架会保留多 Agent 的复杂度，却失去 Artifact-first 和 Human-controlled 的治理收益。

**Recommendation**: Skill MVP 必须默认生成权限、升级、质量门禁和验收记录模板；任何人工豁免、未验证放行或循环超限决策都必须写入 `acceptance.md` 或对应 policy/run-state 产物。
