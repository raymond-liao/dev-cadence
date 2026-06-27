# Dev Cadence 目标形态方案草案

> 历史归档：本文是目标形态设计草案。当前稳定入口见 [../overview.md](../overview.md)、[../plugin-skill-modularization.md](../plugin-skill-modularization.md)、[../installation.md](../installation.md) 和 [../validation.md](../validation.md)。

## 目的

本文用于收敛 Dev Cadence 下一阶段的产品和 Skill 组织方式。

当前主要矛盾是：

- `dev-cadence-init`、`dev-cadence-deliver`、`dev-cadence-maintain`、`dev-cadence-authoring` 更像产品功能菜单；
- 但 Codex Skill 更适合作为 Agent 工作动作和工作纪律的触发单位；
- Dev Cadence 又不能简单变成一组通用工作纪律，因为它还有 `Supervisor`、`Harness`、`Quality Gate`、`Human Gate`、artifact 和 evidence 这些治理语义。

本文目标不是马上重构目录，而是先形成可评审的目标模型。

## 核心结论

Dev Cadence 第一版应定位为：

```text
带治理协议的 agent delivery workflow plugin
```

也就是说：

- 它不是纯框架论文，应该内置一套能跑通的默认交付工作流；
- 它也不是 Superpowers 改名版，必须保留自己的交付治理模型；
- 它不应该把 `init`、`deliver`、`maintain`、`authoring` 作为主要 Skill 入口；
- 它应该用一个强 bootstrap 加一组工作纪律 Skills，再由共享 references 承载治理协议。

推荐结构：

```text
Codex Plugin
  skills/
    using-dev-cadence
    clarifying-intent
    writing-delivery-plans
    executing-delivery-plans
    test-driven-development
    systematic-debugging
    requesting-code-review
    verification-before-completion
    syncing-repo-contract
  references/
    supervisor-state-machine.md
    harness.md
    quality-gates.md
    human-gates.md
    workflows.md
    task-classes.md
    artifact-policy.md
  templates/
  scripts/
```

实际发布时，Skill 名称应避免过长。概念上按工作动作命名；实现上使用短前缀避免和其他插件的同名 Skills 冲突，例如 `cadence-clarify`、`cadence-plan`、`cadence-tdd`、`cadence-review`、`cadence-verify` 和 `cadence-sync`。`using-dev-cadence` 可保留完整名称，因为它是 bootstrap 和治理入口。

## 与 Superpowers 的关系

Superpowers 的强项是按 Agent 工作动作组织 Skills，例如：

```text
using-superpowers
brainstorming
writing-plans
test-driven-development
systematic-debugging
requesting-code-review
verification-before-completion
```

Dev Cadence 应吸收这种组织方式，但不复制它的完整产品边界。

| 维度 | Superpowers | Dev Cadence 目标形态 |
|---|---|---|
| Skill 组织 | 按工作动作和纪律拆分 | 同样按工作动作和纪律拆分 |
| 启动方式 | skills-only 形态主要依赖 Skill 触发 | 依赖 Codex 原生 Skill 触发或用户显式要求使用 Dev Cadence |
| 核心价值 | 强制 Agent 使用成熟工作纪律 | 在工作纪律上叠加治理、证据和验收 |
| 过程记录 | 主要由计划和检查点驱动 | 由 task artifacts 和 Harness evidence 驱动 |
| Gate 语义 | Skill 内部纪律 | Dev Cadence Core 共享协议 |
| Repo 初始化 | 不是前置概念 | 按需同步薄仓库契约 |

因此，目标不是：

```text
Dev Cadence = Superpowers fork
```

而是：

```text
Dev Cadence = bootstrap + governance protocol + disciplined workflow skills
```

## 分层模型

### 1. Plugin 层

Plugin 负责发布和装载：

- `.codex-plugin/plugin.json`
- Skills
- references
- templates
- scripts

Plugin 层不应该表达业务流程细节。它只负责让 Codex 能发现、加载和执行 Dev Cadence。

### 2. Bootstrap 层

`using-dev-cadence` 是核心入口。

它的职责是：

- 作为 Dev Cadence 的唯一入口 Skill；
- 要求 Agent 在任何交付任务前检查相关 Skills；
- 识别当前用户请求属于开发、修复、调试、Review、验证、仓库契约同步，还是纯问答；
- 选择 workflow、task class、gates 和需要按顺序执行的 discipline Skills；
- 明确多个 discipline 是累积链路，不是互斥选项，例如 bugfix 通常需要 debug、execute/TDD、review、verify 和 Human acceptance；
- 保证 `Supervisor`、`Harness`、`Quality Gate`、`Human Gate` 不被绕过。

它不直接承载所有规则，而是加载必要 references。

### 3. 治理协议层

以下概念不应成为面向用户的 Skill：

- `Supervisor`
- `Harness`
- `Quality Gate`
- `Human Gate`
- `Context Pack`
- artifact schema
- task class policy

它们应保留为 `references/` 中的共享协议，由 bootstrap 和各 discipline Skills 引用。

原因：

- 用户不会主动说“使用 Harness”；
- Worker discipline 不能各自定义 gate 语义；
- evidence、权限和验收规则必须统一；
- 这些概念是 Dev Cadence 的运行协议，不是单次工作动作。

### 4. 工作纪律层

工作纪律 Skills 负责“某一步怎么做”。

候选集合：

| Skill | 触发场景 | Dev Cadence 约束 |
|---|---|---|
| `clarifying-intent` | 需求、范围、目标、验收不清 | 写入 requirements/design artifact；必要时进入 Human Gate |
| `writing-delivery-plans` | 已有设计，需要拆执行计划 | 输出可执行任务、验证方式、风险和文件范围 |
| `executing-delivery-plans` | 已有计划，需要实现 | 通过 Harness 执行，记录 evidence |
| `test-driven-development` | 可测试行为变更 | 默认 Red-Green-Refactor，并记录测试证据 |
| `systematic-debugging` | bugfix、incident、未知故障 | 先复现或刻画问题，再修复 |
| `requesting-code-review` | 实现后或任务间 review | 先查 spec compliance，再查 code quality |
| `verification-before-completion` | 声称完成前 | 必须有验证证据和残余风险说明 |
| `syncing-repo-contract` | 初始化、检查、修复仓库契约 | 只改薄契约，不改产品代码 |

这些 Skills 可以吸收成熟工作流中的 checklist、反例、prompt 和部分脚本，但输出必须接到 Dev Cadence 的 artifacts、Harness evidence 和 gates。

### 5. Repo Contract 层

仓库契约不应成为使用前置条件。

目标体验：

```text
插件装好 -> 立刻可用
需要 artifact -> 创建或使用 specs/
需要团队长期规则 -> 同步 AGENTS.md 和 .dev-cadence.yaml
```

`syncing-repo-contract` 是按需能力，不是顶层入口。

明确边界：

- 用户说“初始化 dev-cadence”时，触发 `syncing-repo-contract`；
- 用户直接说“开发登录功能”时，不应因为未初始化而阻塞；
- 如果需要写持久 artifact，但仓库没有 `specs/`，应根据风险自动创建或询问；
- `AGENTS.md` 只保存薄入口和项目特定约束，不复制完整框架规则；
- `.dev-cadence.yaml` 是本地偏好文件，默认加入 `.gitignore`。

## Artifact 轻重分级

Dev Cadence 不能让每个小改动都生成完整流程文件。

建议按任务等级控制记录强度：

| 等级 | 场景 | Artifact 策略 | Gate 策略 |
|---|---|---|---|
| `S0` tiny | 文案、简单配置、小范围低风险修复 | 可只记录简短 evidence；不强制完整 spec | 完成前验证即可 |
| `S1` normal | 普通功能、bugfix、refactor | 标准 task artifact 和 Harness evidence | 需要 Quality Gate，最终给 Human summary |
| `S2` high risk | 安全、数据、支付、权限、迁移、破坏性操作 | 完整 artifact、完整 evidence、明确风险记录 | Human Gate 更早介入，最终具名验收 |

最小 evidence 应包含：

```text
输入上下文
执行动作
变更摘要
验证命令和结果
未解决风险
```

Harness evidence 的价值是可追踪，不是文件越多越好。

## Skill 命名策略

需要避免两个极端：

- 全部命名为 `dev-cadence-init`、`dev-cadence-deliver` 这种产品菜单；
- 全部照搬通用名称，导致和其他插件的 Skill 冲突。

决策：

1. 概念文档中按动作命名，例如 `clarifying-intent`、`writing-delivery-plans`。
2. Codex 发布时使用短前缀，例如 `cadence-clarify`、`cadence-plan`、`cadence-tdd`、`cadence-review`、`cadence-verify` 和 `cadence-sync`。
3. `using-dev-cadence` 保持完整名称，因为它是 bootstrap 和治理入口。
4. `syncing-repo-contract` 的发布名可缩短为 `cadence-sync`，不再使用 `init` 或 `maintain`。

## 当前四个 Skills 的迁移关系

| 当前 Skill | 目标处理 |
|---|---|
| `dev-cadence-init` | 合并到 `syncing-repo-contract` 的初始化场景 |
| `dev-cadence-maintain` | 合并到 `syncing-repo-contract` 的 inspect/sync/repair/diagnose 场景 |
| `dev-cadence-deliver` | 拆成 `using-dev-cadence` 路由加多个工作纪律 Skills |
| `dev-cadence-authoring` | 不作为普通用户发布 Skill；保留为源码仓库内部文档、测试或维护流程 |

这不是删除能力，而是把能力放回更自然的 Skill 边界。

## 登录功能 Walkthrough

用户请求：

```text
开发一个登录功能，支持邮箱密码登录、错误提示、登录成功后跳转到首页
```

### 1. Bootstrap

Codex 通过原生 Skill 触发或用户显式要求使用 Dev Cadence 选择 `using-dev-cadence`。

Agent 收到请求后：

- 判断这是 `feature-dev`；
- 初步判断为 `S1 normal`；
- 检查是否已有 repo contract；
- 如果没有，也不阻塞任务；
- 若需要持久 artifact，则创建或询问创建 `specs/{task_id}/`。

### 2. Clarifying Intent

触发 `clarifying-intent`。

需要澄清的问题示例：

- 登录接口是否已有后端？
- 邮箱格式、密码规则、错误文案是否已有约定？
- 登录态保存方式是什么？
- 首页路由是什么？
- 是否需要记住登录状态？
- 是否有设计稿或现有页面风格？

输出：

```text
specs/{task_id}/00-brief.md
specs/{task_id}/01-requirements.md
specs/{task_id}/02-design.md
```

如果 UI 细节难以文字说明，可选用 visual companion；不可用时降级为文字澄清。

### 3. Planning

触发 `writing-delivery-plans`。

输出：

```text
specs/{task_id}/03-tasks.md
specs/{task_id}/04-test-plan.md
```

计划必须包含：

- 涉及文件；
- 每个任务的目标行为；
- 测试或验证命令；
- 风险和回滚点；
- 不做的范围。

### 4. Implementation

触发 `executing-delivery-plans`。

对于可测试行为，触发 `test-driven-development`：

```text
RED: 写失败测试并观察失败
GREEN: 写最小实现使测试通过
REFACTOR: 清理实现并保持测试通过
```

Harness 记录：

```text
specs/{task_id}/runs/{run_id}/run-context.md
specs/{task_id}/runs/{run_id}/tool-log.md
specs/{task_id}/runs/{run_id}/diff-summary.md
specs/{task_id}/runs/{run_id}/test-log.md
```

如果项目没有测试框架，必须记录替代验证方式，不能直接声称完成。

### 5. Review

触发 `requesting-code-review`。

Review 两层：

1. spec compliance：是否实现了计划中承诺的行为；
2. code quality：是否引入脆弱实现、重复、隐藏副作用或安全问题。

输出：

```text
specs/{task_id}/07-review-report.md
```

严重问题阻塞进入 completion。

### 6. Verification

触发 `verification-before-completion`。

检查：

- 测试是否执行；
- 验证命令是否成功；
- 变更范围是否符合计划；
- 是否存在未计划 diff；
- 是否有残余风险；
- 是否需要 Human Gate。

输出或更新：

```text
specs/{task_id}/06-test-report.md
```

### 7. Acceptance

Agent 在对话中展示验收摘要，而不是要求用户自己打开多个文件：

```text
目标
已实现范围
未实现范围
变更文件
验证证据
Review 结论
残余风险
需要你确认的事项
```

用户确认后，写入：

```text
specs/{task_id}/08-acceptance.md
```

最终 accepter 必须是具名 Human，不能是 Supervisor、Harness 或 Worker Agent。

## 第一阶段建议范围

不要一次性重构所有能力。建议第一阶段只做最小可用闭环：

```text
using-dev-cadence
clarifying-intent
writing-delivery-plans
test-driven-development
requesting-code-review
verification-before-completion
syncing-repo-contract
```

暂缓：

- `using-git-worktrees`
- `finishing-a-development-branch`
- `dispatching-parallel-agents`
- `subagent-driven-development`
- 面向普通用户发布 `authoring`

原因：

- commit/worktree 策略之前已决定先保持现状；
- 并行和 subagent 能力依赖运行时，不应成为第一版硬条件；
- authoring 是 Dev Cadence 自身维护能力，不是普通交付默认入口，因此不进入普通用户发布 Skill 集合。

## 已确认决策与待确认问题

已确认：

1. Skill 前缀不要太长。除 `using-dev-cadence` 外，发布名优先使用 `cadence-*` 短前缀。
2. `specs/` 保持当前逻辑，先不调整提交或忽略策略。`runs/` 是 `specs/{task_id}/runs/{run_id}/` 下的 Harness evidence 目录，本阶段不单独改变处理方式。
3. `S0` tiny 任务允许轻量 evidence，不强制完整 task artifact。
4. `syncing-repo-contract` 能直接创建低风险目录或文件时直接创建；遇到权限、已有内容冲突或高风险写入时再请求确认。
5. `dev-cadence-authoring` 不作为普通用户发布 Skill。相关能力只保留为源码仓库内部文档、测试或维护流程。
6. visual companion 按既有决策保留为 `clarifying-intent` 的 optional capability。它用于 UI、diagram、mockup 或视觉方案对齐；不可用时降级为 text-only clarification，不作为 G1 或任何交付 gate 的硬条件。

`S0` tiny 的默认判断规则：

```text
低风险
小范围
容易验证
不改变核心业务流程
不涉及安全、权限、支付、认证、数据迁移、删除操作
不需要复杂设计讨论
```

如果无法确定是否满足以上条件，默认升级为 `S1 normal`。

仍需后续实现时确认：

1. `S0` 轻量 evidence 的最小格式。
2. `cadence-*` 发布名和概念名之间的具体映射表。
3. repo contract 自动创建时的冲突检测和提示文案。

## 建议下一步

1. 先评审本文，确认目标形态。
2. 更新 `docs/plugin-skill-modularization.md`，废弃“按用户意图菜单拆四个 Skill”的旧结论。
3. 在 `docs/dev-cadence-roadmap.md` 追加 R8：Skill 目标模型重构。
4. 实现 `using-dev-cadence` 入口 Skill。
5. 将当前 `init/maintain` 能力迁移到 `syncing-repo-contract`。
6. 用“登录功能”做一次端到端 pressure test，再决定是否继续拆更多 discipline Skills。
