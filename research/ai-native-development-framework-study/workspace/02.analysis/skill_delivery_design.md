# Skill Delivery Design

## Skill Purpose

本 Skill 的定位是把 `Human + Multi-Agent Team` 的研发协作框架交付为一个团队可复用的轻量操作包，而不是企业级平台或自动化编排系统。它应帮助团队在现有代码仓库中建立可审计、可复盘、以产物为中心的 AI 协作方式。

Skill 应响应以下用户意图：

- 为某个代码仓库初始化 AI Native 研发协作规则。
- 为 feature、bugfix、code review 或 research spike 创建结构化任务产物。
- 引导 Supervisor、Planner、Developer、Reviewer-Tester 等角色按边界协作。
- 根据仓库现状生成最小必要的需求、设计、任务、测试、Review 模板。
- 帮助团队把人工确认点、质量门禁和升级规则显式写入文件。

Skill 应检查的项目状态包括：

- 是否已有 `.ai/`、`specs/`、`docs/adr/`、`CONTRIBUTING`、CI 配置、测试脚本和代码风格规则。
- 当前仓库的主要语言、构建工具、测试入口、包管理器和目录结构。
- 当前任务是否已有 issue、PR、设计文档、验收标准或用户提供的上下文。
- 是否存在与 Skill 默认规则冲突的本地规范。
- 当前工作区是否有未提交变更；Skill 应提醒但不自动重置或覆盖。

Skill 应生成的产物是 repo-local 协作文件和任务文件，而不是平台服务：

- `.ai/` 下的 Agent 蓝图、工作流规则、策略和模板。
- `specs/{task_id}/` 下的需求、设计、任务、实现说明、测试报告和 Review 报告。
- 必要时生成 ADR、上下文包、人工审批记录和质量门禁清单。

Skill 必须延后给人类决策的事项包括：

- 需求是否接受。
- 架构方案是否接受。
- 是否允许高风险命令、外部服务访问、凭据操作或大规模重构。
- 测试不足时是否仍然合并。
- Review blocker 是否可以豁免。
- 任务失败或循环超限后的取舍。
- Skill 版本升级是否在当前仓库启用。

## Trigger Scenarios

MVP 阶段建议支持以下触发场景：

| 场景 | 典型请求 | Skill 行为 |
|---|---|---|
| 仓库初始化 | “在这个仓库启用 AI Native Development Framework” | 读取仓库结构，提出 `.ai/` 与 `specs/` 初始化计划，生成最小规则和模板 |
| 新功能开发 | “按 AI Native 流程做这个 feature” | 创建 `specs/{task_id}/requirements.md`、`design.md`、`tasks.md`，要求人工确认后进入实现 |
| 缺陷修复 | “用该框架处理这个 bug” | 生成问题复现、影响范围、修复任务、测试回归和 Review 记录 |
| 代码审查 | “按框架 review 这次改动” | 使用 Reviewer-Tester 清单输出 blocker、major、minor 与测试缺口 |
| 研究 Spike | “先研究这个技术方案再决定” | 生成研究问题、证据记录、方案比较和建议，不直接进入代码实现 |
| 工作流恢复 | “继续上次的 AI Native 任务” | 读取 `specs/{task_id}/` 状态，定位下一步、阻塞项和人工决策点 |

不建议在 MVP 阶段把以下请求作为自动触发：

- 自动监听所有 issue 或 PR 并自行调度 Agent。
- 自动修改 CI、权限、发布流水线或组织级策略。
- 跨仓库同步 Skill 版本和工作流状态。
- 无人工确认地执行 merge、release 或生产变更。

## Skill Package Structure

建议 Skill 包采用“说明入口 + 参考规则 + 模板 + 可选脚本”的结构：

```text
ai-native-development-framework/
  SKILL.md
  references/
    principles.md
    agent-roles.md
    workflows.md
    quality-gates.md
    context-pack.md
    human-control-points.md
    versioning-policy.md
  templates/
    ai/
      agents/
        supervisor.md
        planner.md
        developer.md
        reviewer-tester.md
      workflows/
        feature-dev.md
        bugfix.md
        code-review.md
      policies/
        permissions.md
        escalation.md
        quality-gates.md
    specs/
      requirements.md
      design.md
      tasks.md
      implementation.md
      test_report.md
      review_report.md
      acceptance.md
  scripts/
    inspect_repo.sh
    validate_task_structure.sh
```

`SKILL.md` 范围说明应明确：

- 触发描述：当用户要求在仓库内建立或执行 AI Native 多 Agent 研发协作流程时使用。
- 适用范围：单仓库、人工监督、产物优先、质量门禁驱动的软件交付任务。
- 不适用范围：企业编排平台、自动发布系统、权限控制平台、模型评测平台和跨组织治理系统。
- 执行约束：先检查已有项目规则；生成前列出计划；不得覆盖用户已有文件；高风险步骤必须请求人工确认。

Reference 文件应承载稳定原则，模板应承载可复制结构，脚本仅用于检查和校验，不应在 MVP 中承担平台编排职责。

## Generated Repository Structure

Skill 在目标仓库中建议生成以下 repo-local 结构：

```text
.ai/
  agents/
    supervisor.md
    planner.md
    developer.md
    reviewer-tester.md
  workflows/
    feature-dev.md
    bugfix.md
    code-review.md
  policies/
    permissions.md
    task-classes.md
    quality-gates.md
    escalation.md
  templates/
    context-pack.md
    task-status.md

specs/
  {task_id}/
    requirements.md
    design.md
    tasks.md
    implementation.md
    test_report.md
    review_report.md
    acceptance.md
```

各目录职责如下：

| 路径 | 职责 | MVP 要求 |
|---|---|---|
| `.ai/agents/` | 定义 repo-local Agent 角色、输入、输出、禁止事项 | 必需 |
| `.ai/workflows/` | 定义任务类型、阶段、门禁、循环次数 | 必需 |
| `.ai/policies/` | 定义权限、质量门禁、升级规则 | 必需 |
| `.ai/templates/` | 定义上下文包和任务状态模板 | 可选但推荐 |
| `specs/{task_id}/` | 保存每个任务的可审计交付产物 | 必需 |

MVP 应提供任务分级，避免所有变更都套用同一重量流程：

| 分级 | 适用任务 | 最小产物 | 人工门禁 |
|---|---|---|---|
| `S0 trivial` | 文案、注释、低风险配置、小型修复 | task note、implementation、test evidence 或 not verified reason | 验收确认 |
| `S1 normal` | 普通 feature、bugfix、code-review | requirements、tasks、implementation、test_report、review_report | 需求确认、验收确认 |
| `S2 high-risk` | 架构、权限、安全、CI、数据迁移、跨模块变更 | requirements、design 或 ADR、tasks、test_report、review_report、acceptance | 需求确认、设计确认、权限确认、合并确认 |
| `incident` | 紧急生产修复 | triage note、minimal patch、smoke test、emergency approval、post-incident backfill | 紧急批准、事后复盘 |

MVP 任务状态建议使用简单枚举：

```text
draft
requirements_review
design_review
implementation
test_review
changes_requested
human_acceptance
done
blocked
```

每个任务至少应记录：

- `task_id`
- `goal`
- `acceptance_criteria`
- `current_stage`
- `owner_role`
- `changed_files`
- `test_commands`
- `test_results`
- `review_decision`
- `human_decisions`
- `known_limitations`

## MVP Skill Scope

MVP Skill 应聚焦“单仓库、低平台依赖、人工监督、产物协作”的可验证闭环。

MVP 必须包含：

- 初始化或检查 `.ai/` 与 `specs/` 结构的能力。
- 四个角色蓝图：Supervisor、Planner、Developer、Reviewer-Tester。
- 三个工作流：`feature-dev`、`bugfix`、`code-review`。
- 六类核心任务产物：`requirements.md`、`design.md`、`tasks.md`、`implementation.md`、`test_report.md`、`review_report.md`。
- 任务分级矩阵：`S0 trivial`、`S1 normal`、`S2 high-risk`、`incident`。
- 明确的人工门禁：需求确认、设计确认、权限确认、合并确认。
- 明确的 Human Gate 类型：`approval_required`、`review_required`、`info_required`、`notify_only`。
- 明确的质量门禁：验收标准存在、测试已执行或明确说明未执行、Review 无 blocker、循环次数未超限。
- 明确的验证状态：`verified`、`partially_verified`、`not_verified`、`blocked_by_environment`。
- Developer 输出约束：必须列出改动文件、实现理由、测试命令、测试结果和已知限制。
- Reviewer-Tester 输出约束：结论只能是 `approved`、`approved_with_minor_notes`、`changes_requested`、`blocked`。
- 循环控制：Developer 与 Reviewer-Tester 最多往返 3 次，超限后升级给人。

MVP 不应包含：

- 独立的企业控制台。
- 后台任务调度服务。
- 自动监听 issue、PR 或 CI 事件。
- 跨仓库知识库和全局 Agent 版本控制。
- 自动合并、自动发布或自动审批。
- 对特定技术栈的强绑定工程结构。

MVP 成功标准建议为：

- 团队能在一个真实仓库中完成至少 3 类任务闭环。
- 每个任务都有可追踪的 spec、实现、测试和 Review 记录。
- 人工审批点没有被 AI 产物替代。
- Reviewer-Tester 能发现至少一类 Developer 未主动暴露的问题，或明确证明没有 blocker。
- 团队能判断流程成本是否低于质量收益。

## Deferred Scope

后续能力应按层级延后，而不是全部塞进 Skill：

| 能力 | 分类 | 延后理由 |
|---|---|---|
| 独立 Architect Agent | Advanced Skill | MVP 可先由 Planner 承担轻量设计，复杂项目再拆分 |
| 独立 Tester Agent | Advanced Skill | MVP 可用 Reviewer-Tester 合并角色验证闭环，规模扩大后再分离 |
| ADR 自动生成与索引 | Advanced Skill | 有价值但会增加流程负担，适合架构变更较多的团队 |
| 自动读取 issue/PR 并调度流程 | Workflow automation | 需要平台事件集成和权限治理 |
| 自动运行完整测试矩阵 | Workflow automation | 依赖 CI、环境和成本策略 |
| Agent 调用链审计和成本统计 | Platform feature | 需要统一运行时和日志模型 |
| Prompt、Workflow、Agent 版本注册表 | Platform feature | 单仓库可先用文件版本，跨仓库再平台化 |
| SSO、RBAC、组织策略、审批矩阵 | Enterprise control plane feature | 属于企业治理，不应由 Skill 文件系统模板承担 |
| 跨仓库知识库、MCP/A2A 集成 | Enterprise control plane feature | 涉及权限、数据边界、检索质量和安全控制 |
| 自动发布与生产变更控制 | Enterprise control plane feature | 风险高，必须依赖组织级发布治理 |

核心原则是：Skill 负责把协作方式变成可复制的文件和规则；自动化负责减少重复动作；平台负责统一运行时、审计和权限；企业控制面负责跨团队治理。

## Versioning and Governance

Skill 版本治理应覆盖三层：

| 层级 | 示例 | 治理方式 |
|---|---|---|
| Skill 包版本 | `ai-native-development-framework@0.1.0` | 语义化版本；发布说明记录模板和规则变化 |
| Repo-local 配置版本 | `.ai/version.md` | 记录当前仓库采用的 Skill 版本、本地覆盖项和升级日期 |
| Task 产物版本 | `specs/{task_id}/` | 随 Git 历史追踪，不单独建立复杂版本系统 |

建议版本规则：

- `0.x` 阶段只承诺模板和工作流的实验稳定性，不承诺跨仓库兼容。
- patch 版本只修正文档、模板措辞和校验脚本问题。
- minor 版本可以新增工作流、模板字段或角色蓝图。
- major 版本才允许改变默认目录结构、任务状态机或门禁语义。

升级治理规则：

- Skill 升级必须先生成差异说明，不自动覆盖本地修改。
- `.ai/` 下文件若已被团队修改，升级时应生成冲突报告，由人决定保留、合并或跳过。
- 对质量门禁、权限策略、人工审批点的变更必须显式列为 breaking change 或 governance change。
- 团队应保留失败案例和 Review 争议，用于后续模板修订。

最低治理产物：

```text
.ai/version.md
.ai/policies/quality-gates.md
.ai/policies/escalation.md
.ai/policies/permissions.md
specs/{task_id}/acceptance.md
```

## Findings

### [ANA-SKILL-001] Skill 是合适的第一交付形态，但必须保持文件系统边界

**Evidence**:
`framework_map.md` 将最终共享产物定义为 `AI Native Development Framework Skill`，并明确 Skill 不负责替代项目管理系统、企业级 Agent 编排平台、CI、代码平台或发布系统。`research-overview.md` 也将“实现 team Skill”和“构建平台原型”排除在研究范围之外。`comparative_analysis.md` 的 [ANA-CMP-007] 指出 Skill-first 路径务实，但必须避免“文档包伪平台化”。

**Reasoning**:
当前框架的关键价值在于角色边界、结构化产物、质量门禁和人工控制点。它们可以先通过 Skill、模板和 repo-local 文件落地，不需要先建设平台。

**Implication**:
如果 MVP 直接追求平台化，会把研究验证问题转化为工程平台建设问题，掩盖框架本身是否有效。

**Recommendation**:
第一版 Skill 只设计和生成文件、模板、流程说明和校验清单；自动调度、权限、审计和跨仓库治理延后到平台阶段。

### [ANA-SKILL-002] MVP 应收敛为四角色、三工作流、六产物

**Evidence**:
`framework_map.md` 的 MVP Map 建议使用 Supervisor、Planner、Developer、Reviewer-Tester，并支持 `feature-dev`、`bugfix`、`code-review`。其 MVP 文档产物包括 `requirements.md`、`design.md`、`tasks.md`、`implementation.md`、`test_report.md`、`review_report.md`。`comparative_analysis.md` 的 [ANA-CMP-001] 进一步要求用任务分级控制 MVP 成本。

**Reasoning**:
四角色足以验证需求澄清、任务拆分、实现、测试和 Review 闭环。三工作流覆盖最常见的软件交付场景。六产物能提供最小可审计链路。任务分级可避免低风险变更被完整流程拖慢，也能让高风险变更自动触发更严格门禁。

**Implication**:
MVP 不需要独立 Architect、独立 Tester、发布 Agent 或平台控制面。过早拆分角色会提高流程成本并削弱采用意愿。

**Recommendation**:
MVP Skill 默认生成四个 Agent 蓝图、三个 workflow 文件和六个任务模板；复杂任务可允许 Planner 产出轻量设计，后续再演进独立 Architect。

### [ANA-SKILL-003] Skill 必须把人工决策点做成文件化门禁

**Evidence**:
`framework_map.md` 指出需求确认、架构确认、权限批准、Merge、Release 和循环超限必须由人控制，并强调人的决策必须写入 spec、ADR 或 acceptance 产物，不能只停留在聊天记录。

**Reasoning**:
多 Agent 协作的主要风险不是缺少自动化，而是 AI 在未被察觉时越过需求、架构、权限或合并边界。文件化门禁可以让团队复盘谁在何时接受了什么风险。

**Implication**:
如果 Skill 只生成 Agent prompt，而不生成 acceptance、escalation 和 permissions 记录，框架会退化为角色扮演提示词集合。

**Recommendation**:
MVP Skill 必须生成 `.ai/policies/permissions.md`、`.ai/policies/escalation.md`、`.ai/policies/quality-gates.md` 和 `specs/{task_id}/acceptance.md`。

### [ANA-SKILL-004] Context Pack 应作为任务输入契约，而不是长期记忆替代品

**Evidence**:
`framework_map.md` 定义 Context Pack 字段包括 `task_id`、`goal`、`acceptance_criteria`、`relevant_specs`、`relevant_files`、`constraints`、`previous_decisions`、`forbidden_actions` 和 `expected_output`。同一材料还指出长期记忆只接受已产物化并确认的内容。

**Reasoning**:
Context Pack 的作用是给每轮 Agent 提供最小必要上下文。若把它扩展为自由追加的长期记忆，会增加上下文漂移和历史误用风险。

**Implication**:
Skill 需要提供 Context Pack 模板和填写规则，但不应在 MVP 中建立复杂 memory 系统。

**Recommendation**:
MVP Skill 在 `.ai/templates/context-pack.md` 中定义输入契约，并要求 Context Pack 引用已确认的 spec、ADR、测试报告或 Review 结论。

### [ANA-SKILL-005] Reviewer-Tester 合并适合 MVP，但必须保留独立判断语义

**Evidence**:
`framework_map.md` 的 MVP Map 使用 Reviewer-Tester 合并角色，同时质量门禁要求测试通过、Reviewer 无 blocker 或 major issue。Agent Role Map 又强调 Tester 不修代码，Reviewer 不替代 Tester。

**Reasoning**:
合并角色可降低 MVP 复杂度，但测试验证和代码审查仍是两种不同判断。若输出混在一起，团队难以区分“没有测试证据”和“代码设计不合格”。

**Implication**:
Reviewer-Tester 角色如果没有结构化输出，可能让测试缺口被 Review 结论掩盖。

**Recommendation**:
MVP 的 `review_report.md` 应分为 test evidence、review findings、blocking decision 和 residual risk 四部分；结论仍限定为 `approved`、`approved_with_minor_notes`、`changes_requested`、`blocked`。

### [ANA-SKILL-006] Skill MVP 需要显式处理证据不足，而不是只允许通过或失败

**Evidence**:
`framework_map.md` 的质量门禁要求 tests pass、Reviewer 无 blocker，并要求 Developer 提交测试命令、测试结果和已知限制。`comparative_analysis.md` 的 [ANA-CMP-006] 指出真实项目中会出现不可验证、部分验证、环境阻塞和 flaky CI，质量门禁不能只有 pass/fail。

**Reasoning**:
AI 交付失败常被包装成“已完成但未充分验证”。如果 Skill 只要求填写测试结果，Agent 可能把未执行、无法执行和部分验证混为一类。

**Implication**:
没有证据状态分类时，Reviewer 和人类验收很难判断剩余风险，质量门禁也会流于形式。

**Recommendation**:
MVP Skill 应在 `test_report.md` 和 `review_report.md` 中固定验证状态字段：`verified`、`partially_verified`、`not_verified`、`blocked_by_environment`。任何非 `verified` 状态必须说明缺口、风险、补测建议和是否允许进入人工验收。

## Open Decisions

1. MVP 是否默认生成独立 `design.md`，还是仅在任务复杂度达到阈值时生成。
2. Architect 是否在 MVP 中保持为 Planner 的职责，还是作为可选高级 Agent 蓝图随 Skill 一起提供。
3. Reviewer-Tester 合并角色的输出是否应拆成两个文件：`test_report.md` 和 `review_report.md`。
4. `.ai/` 规则与现有 `CONTRIBUTING`、CI、代码所有权或安全策略冲突时，默认优先级如何确定。
5. Skill 初始化是否应自动推断测试命令，还是只生成待人工填写的占位项。
6. 循环超限次数是否固定为 3 次，还是允许团队在 `.ai/policies/escalation.md` 中配置。
7. 是否要求每个任务都有 `acceptance.md`，或允许小型 bugfix 在 `review_report.md` 中内嵌验收记录。
8. Skill 的团队分发方式采用本地 skill 包、内部 Git 仓库、模板仓库，还是未来接入平台注册表。
9. 是否在 MVP 中提供校验脚本；如果提供，脚本只校验文件结构，还是也校验必填字段。
10. `incident` 分级是否进入 MVP 默认工作流，还是只作为模板中的保留扩展。
