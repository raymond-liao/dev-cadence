# Codex Plugin 模块边界

## 目的

这页是 `dev-cadence` Codex Plugin 的维护者边界说明。它回答三个问题：

- 当前为什么采用 `using-dev-cadence` + `cadence-*` Skill 结构；
- `skills/`、`references/`、`templates/` 和 `scripts/` 分别承载什么；
- thin repo-local contract、repo-scoped plugin payload 和 Dev Cadence Core 如何分层。

安装命令见 [Dev Cadence 安装](installation.md)，验证命令见 [Dev Cadence 当前验证](validation.md)。运行时可加载或调用的稳定材料以 `skills/`、`references/`、`templates/` 和 `scripts/` 为准。

## 核心决策

```text
Dev Cadence Core
  -> 定义平台无关 workflow、roles、gates、Harness、artifacts 和 adapter contract

dev-cadence Codex Plugin
  -> 当前 Codex 发布形态
  -> 持有可复用 workflow rules、gates、templates、scripts 和 adapters
  -> 通过 thin repo-local contract 接入目标仓库
```

目标仓库里的任务产物仍然是持久事实源。Dev Cadence Core 规则通过 Codex Plugin 的 references、templates、scripts 和 adapters 在 Codex 中落地，不把完整框架复制进每个目标仓库。后续其他 agent runtime 可以实现同一 Core contract，而不必继承 Codex Plugin 的目录和触发机制。

## 发布与分发边界

| 层级 | 位置 | 职责 |
|---|---|---|
| 源码布局 | `.codex-plugin/`、`skills/`、`references/`、`templates/`、`scripts/` | 维护当前插件源码和运行时材料 |
| 本地打包产物 | `dist/codex/plugins/dev-cadence/` | 由 `scripts/package-codex-plugin.mjs` 生成的 plugin payload |
| 业务仓库分发 | `.agents/plugins/dev-cadence/` | 可提交到业务仓库的 repo-scoped plugin payload |
| 业务仓库 marketplace | `.agents/plugins/marketplace.json` | 指向业务仓库内的 plugin payload |
| thin repo-local contract | `AGENTS.md`、`.gitignore`、`.dev-cadence.yaml`、`specs/records/.gitkeep` | 让目标仓库路由到 Dev Cadence，并保留本地偏好和 artifact space |

`skills/`、`references/`、`templates/` 和 `scripts/` 不属于 thin repo-local contract。它们可以作为 repo-scoped plugin payload 提交到业务仓库用于团队分发，但不应被 `cadence-sync` 复制成普通目标仓库规则。

## Skill 边界

不要为 `requirements-gate`、`planning-gate`、`harness-run`、`quality-gate` 或 `human-gate` 这类内部状态创建 Codex Skill。它们是 Supervisor 状态和框架治理模块，不是用户直接请求的能力。

模块化规则：

```text
Bootstrap owns Supervisor routing and discipline sequencing.
Skill boundaries follow agent work actions and delivery disciplines.
Reference boundaries follow workflow internals and governance protocols.
Template boundaries follow artifact types.
Adapter boundaries follow replaceable execution techniques.
```

当前发布 Skill：

| Skill | 职责 |
|---|---|
| `using-dev-cadence` | Dev Cadence 入口，负责 Supervisor 路由、workflow state、task class、gate 和 discipline sequencing |
| `cadence-clarify` | 澄清目标、范围、非目标、验收和验证 |
| `cadence-plan` | 把已澄清需求转成可执行计划和验证步骤 |
| `cadence-executing-plans` | 在 Harness evidence 约束下执行已批准计划 |
| `cadence-subagent-development` | 用隔离 Worker 顺序执行已批准任务，并逐任务通过 spec compliance 与 code quality review |
| `cadence-dispatch-parallel` | 对独立问题域并行派发 Worker，并整合冲突检查和总体验证 |
| `cadence-tdd` | 对 testable behavior changes 执行 Red-Green-Refactor |
| `cadence-debug` | 诊断 bug、incident、失败测试、回归和未知根因 |
| `cadence-request-review` | 请求或执行 spec compliance 和 code quality review |
| `cadence-review` | 验证并处理已有 review feedback，然后回到 re-review |
| `cadence-verify` | 完成前核验证据、范围、跳过项、剩余风险和 Human acceptance |
| `cadence-sync` | 初始化、检查、同步、修复或诊断 thin repo-local contract |

`Supervisor`、`Harness`、`Quality Gate`、`Human Gate`、Context Pack、artifact schema 和 task class policy 保持为 shared references，不作为用户 Skill 发布。Dev Cadence authoring 不进入普通用户发布 Skill 集合。

## 发布资源边界

| 目录 | 职责 | 维护入口 |
|---|---|---|
| `skills/` | Codex Skill 入口和工作纪律触发面 | `skills/*/SKILL.md` |
| `references/` | workflow、gate、Harness、agent、adapter 和 discipline 的运行时规则 | [references/skill-layout.md](../references/skill-layout.md) |
| `templates/spec/` | task artifact 模板 | [references/spec-templates.md](../references/spec-templates.md) |
| `templates/runs/` | Harness evidence 模板 | [references/spec-templates.md](../references/spec-templates.md) |
| `templates/prompts/` | Worker、reviewer 和文档审查 prompt 模板 | [references/agent-blueprints.md](../references/agent-blueprints.md) |
| `scripts/` | 打包、检查、artifact 初始化、报告生成、repo contract 同步和 optional visual companion | [validation.md](validation.md) |

`delivery-disciplines.md` 是默认交付纪律的路由入口；细节按状态拆到 clarify、planning、TDD、debugging、review、verification 和 authoring discipline references。

`repository-rule-sync.md` 定义 thin repo-local contract 的初始化、检查、同步和修复规则。`scripts/` 提供对应检查和生成命令；具体脚本清单以 `scripts/` 目录和 package boundary 测试为准。

`visual-companion.md` 和 `scripts/visual-companion/` 提供可选浏览器视觉对齐能力。它可以帮助 Human 和 AI 对齐 mockup、diagram 和视觉方案，但不能成为 G1 的硬条件。

## Thin Repo-Local Contract

初始化目标仓库时，默认只创建或维护最小持久契约：

```text
AGENTS.md
.gitignore
.dev-cadence.yaml

specs/
  records/
    .gitkeep
```

`AGENTS.md` 把 Codex 中的普通交付工作路由到 `dev-cadence` Codex Plugin，不承载完整框架规则。

`.dev-cadence.yaml` 保存用户本地覆盖配置，并保持 Git 忽略。默认配置由插件持有。`specs/records/{task_id}/` 是任务产物、Harness evidence 和 Human acceptance 的持久来源；`specs/report/` 是可重新生成的 HTML 浏览视图。

Repo-scoped marketplace 和 `.agents/plugins/dev-cadence/` plugin payload 是团队分发方式，不是 thin repo-local contract。`cadence-sync` 不应默认创建或更新这部分分发包。

## 运行时权威

运行时规则按以下层级解析：

1. 当前用户请求和显式仓库指令。
2. 仓库本地 `AGENTS.md` 和 `.dev-cadence.yaml`。
3. `specs/records/{task_id}/` 下的任务产物。
4. `dev-cadence` 的 references、templates、内置交付纪律和 adapters。
5. 被显式配置的外部 adapter。

Repo-local overlays 可以增加更严格或更项目化的约束，但不能削弱 Dev Cadence Core 定义的 named Human acceptance、证据要求、权限门禁或 Quality Gate 语义。

## Adapter 边界

Dev Cadence 默认使用内置交付纪律。Adapter 是未来替换某个 Worker 执行技术的扩展点，不是默认纪律的来源。

Supervisor 和 Harness 仍由 Dev Cadence 拥有。Adapter 只控制某个 bounded Worker state 如何执行，不能改变 gate、证据、权限、scope reconciliation 或最终验收语义。完整 adapter 契约见 [references/adapters.md](../references/adapters.md)。
