# Dev Cadence 路线图

## 目的

本文是 Dev Cadence 当前剩余工作的稳定路线图。

后续询问“还剩什么计划”时，应以本文为准，而不是重新生成新的临时列表。完成一项工作后，只更新对应条目的状态、证据和备注；除非目标架构变化，不要新增一组替代性的同类计划。

## 状态约定

| 状态 | 含义 |
|---|---|
| `done` | 已实现、验证通过，并有提交或稳定证据 |
| `in_progress` | 正在实现，尚未达到完成定义 |
| `pending` | 尚未开始 |
| `blocked` | 有明确阻塞，需要用户决策或外部条件 |
| `deferred` | 已明确后置，不阻塞当前阶段 |

## 当前基线

截至当前基线，已经完成：

- 方案文档已中文化，并记录 Plugin 化目标、thin repo-local contract、Supervisor、Harness、Quality Gate、Human Gate 和 Adapter 模型。
- 单一 `skills/dev-cadence/` Skill 已作为当前 installer/maintenance 入口存在。
- Plugin-owned references 已落地，包括 delivery disciplines、workflow、task classes、agent blueprints、Harness、gates、review、verification、debugging、visual companion 等。
- `templates/spec/`、`templates/runs/` 和 `templates/prompts/` 已落地。
- Package self-check、discipline route check 和 artifact check 脚本已落地并通过。
- `specs/20260622-self-check-help/` 已作为一次内部 dry-run evidence 存在。

当前核心缺口是：资源和规则已经在单一 Skill 包内基本齐备，但目标多入口 Skill、repo-local 初始化器、delivery runtime、maintenance runtime 和 adapter reference 尚未全部实现。

## 路线图

### R1. 补齐 Adapter Reference

状态：`done`

目标：
补齐 `skills/dev-cadence/references/adapters.md`，让方案中的 Adapter 模型成为 Skill package 的稳定 reference，而不是只散落在设计文档和 `delivery-disciplines.md` 的边界说明中。

范围：

- 创建 `references/adapters.md`。
- 记录 adapter 的输入、输出、不可覆盖规则、证据缺口处理和选择策略。
- 更新 `SKILL.md` Reference Map。
- 更新 `check-discipline-routes.mjs`，确保 adapter reference 被索引和验证。

完成定义：

- `references/adapters.md` 存在且为英文。
- `SKILL.md` 和相关 route check 引用该文件。
- `check-skill-package.mjs` 和 `check-discipline-routes.mjs` 通过。

依赖：无。

备注：
已完成。`skills/dev-cadence/references/adapters.md` 已新增，并接入 `SKILL.md` Reference Map、`delivery-disciplines.md` state loading contract 和 `check-discipline-routes.mjs`。验证证据：`check-skill-package.mjs`、`check-discipline-routes.mjs`、`check-spec-artifacts.mjs specs`、`check-spec-artifacts.mjs skills/dev-cadence/templates`、`git diff --check`。

### R2. 实现 Artifact 初始化脚本

状态：`done`

目标：
提供一个最小脚本，用 bundled templates 初始化 `specs/{task_id}/` 和 `runs/{run_id}/`，避免 artifact contract 只停留在模板文件层。

范围：

- 新增脚本，例如 `scripts/init-task-artifacts.mjs`。
- 支持创建 `specs/{task_id}/` 下的 spec artifacts。
- 支持创建 `specs/{task_id}/runs/{run_id}/` 下的 Harness evidence artifacts。
- 默认不覆盖已有文件，除非显式参数允许。
- 更新 help 输出和 package self-check。

完成定义：

- 脚本能从 `templates/spec/` 和 `templates/runs/` 生成目标目录。
- 对已有文件的行为明确且可验证。
- 有至少一个 dry-run 或 fixture 验证。
- `check-skill-package.mjs`、`check-discipline-routes.mjs` 和 `check-spec-artifacts.mjs` 通过。

依赖：R1 可并行，但建议 R1 先完成。

备注：
已完成。`skills/dev-cadence/scripts/init-task-artifacts.mjs` 已新增，并接入 `SKILL.md` Reference Map 和 `check-skill-package.mjs` CLI help 验证。行为验证覆盖 help、dry-run、实际写入、重复运行 skip、`--overwrite`、非法 ID 拦截，以及对生成 fixture 运行 `check-spec-artifacts.mjs`。

### R3. 拆分入口 Skills

状态：`done`

目标：
把当前单一 `dev-cadence` Skill 拆成目标架构中的少量 user-facing skills。

范围：

- `dev-cadence-init`：初始化 thin repo-local contract。
- `dev-cadence-deliver`：已初始化仓库中的普通交付入口。
- `dev-cadence-maintain`：inspect、sync、repair、diagnose。
- `dev-cadence-authoring`：可选，维护 Dev Cadence 自身 package。
- 保持 shared references、templates、scripts 为 plugin-owned resources，不复制到目标仓库。

完成定义：

- 每个入口 Skill 有独立 `SKILL.md` 和 `agents/openai.yaml`。
- 触发边界符合 `docs/plugin-skill-modularization.md` 和 `docs/skill-authoring-prespec.md`。
- 初始化、交付、维护、框架编制的入口语义不互相污染。
- Package self-check 能识别多入口结构，或有明确过渡检查。

依赖：R1、R2。

备注：
已完成。当前 package 保留根 `dev-cadence` 兼容入口，同时新增 `skills/dev-cadence/skills/dev-cadence-init`、`dev-cadence-deliver`、`dev-cadence-maintain` 和 `dev-cadence-authoring` 四个 user-facing entrypoint skills。共享 references、templates 和 scripts 仍留在 package root。`check-skill-package.mjs` 已验证根入口和子入口 frontmatter/openai metadata，`check-discipline-routes.mjs` 已验证入口 skill resource 和 `skill-layout.md` 目标声明。

### R4. 实现 Thin Repo 初始化与维护 Runtime

状态：`done`

目标：
让 `dev-cadence-init` 和 `dev-cadence-maintain` 不只是规则说明，而能实际创建、检查和修复 thin repo-local contract。

范围：

- 生成或更新 root `AGENTS.md` 的 Dev Cadence 入口段落。
- 生成 `.ai/config.yaml`、`.ai/local.yaml`、`.ai/overrides/.gitkeep` 和 `specs/.gitkeep`。
- 更新 `.gitignore`，确保 `.ai/local.yaml` 被忽略。
- 实现 inspect/sync/repair/diagnose 的最小行为。
- 保留已有仓库指令和 local overlays。

完成定义：

- 在临时 fixture repo 中能初始化 thin contract。
- 重复运行具有幂等性。
- 不创建 task-specific specs，不修改产品代码。
- 维护模式能报告 drift、local overlay 和 manual review 项。

依赖：R3。

备注：
已完成。`skills/dev-cadence/scripts/sync-repo-contract.mjs` 已新增，支持 `inspect`、`init`、`sync`、`repair` 和 `diagnose`，写入边界限定为 thin repo-local contract。fixture 验证覆盖缺失仓库报错、空仓库 inspect、init 写入、重复 init 幂等、diagnose、local overlay 报告、marker conflict 阻断且不继续写其它文件。脚本已接入 `SKILL.md` Reference Map、`check-skill-package.mjs` CLI help 验证和 `check-discipline-routes.mjs` Reference Map 检查。

### R5. 实现 Delivery Runtime 最小闭环

状态：`done`

目标：
让 `dev-cadence-deliver` 能按当前规则执行一个最小交付闭环，而不是只依赖人工记忆流程。

范围：

- 读取 repo-local `AGENTS.md`、`.ai/config.yaml` 和 `.ai/overrides/**`。
- 推断 `selected_workflow` 和 `task_class`。
- 创建 `specs/{task_id}/` 和首个 Harness run。
- 使用 `delivery-disciplines.md` 路由状态。
- 记录 scope reconciliation、verification evidence 和 acceptance summary。

完成定义：

- 用一个小任务完成 intake -> requirements -> planning -> implementation evidence -> verification -> review -> acceptance 的 dry run。
- 生成 artifacts 与 `templates/spec/`、`templates/runs/` 兼容。
- 缺失验证、未命名 Human acceptance、unplanned diff 等情况能被阻断或记录为 blocked。

依赖：R2、R3、R4。

备注：
已完成。`skills/dev-cadence/scripts/run-delivery-dry-run.mjs` 已新增，支持在已初始化 fixture repo 中读取 thin contract、推断 `selected_workflow` 和 `task_class`、创建 task artifacts 和 Harness run evidence、记录 scope reconciliation、verification status、review decision 和 acceptance status。fixture 验证覆盖未初始化仓库报错、`feature-dev`/`S1` 推断、security goal 升级为 `S2`、无 named accepter 时 G6 blocked、提供 named accepter 时仅接受 dry-run scope，以及对生成 specs 运行 `check-spec-artifacts.mjs`。

### R6. 改善 Acceptance 展示体验

状态：`pending`

目标：
把需要 Human 验收的信息直接汇总展示给用户，而不是要求用户自己去多个 artifact 文件里寻找。

范围：

- 定义 acceptance summary 的最小格式。
- 汇总目标、范围、实际变更、验证证据、review 结论、残余风险和需要用户确认的事项。
- 明确哪些确认会写入 `08-acceptance.md`。

完成定义：

- 用户可以在对话里看到验收所需的完整摘要。
- `08-acceptance.md` 仍然是 durable source of truth。
- 不再把 Supervisor、Harness 或 Worker Agent 记录为 final accepter。

依赖：R5。

### R7. 真实验证 Visual Companion

状态：`pending`

目标：
用真实 intent/design 任务验证 visual companion 的 optional capability，不让它变成 G1 硬依赖。

范围：

- 选择一个 UI、diagram 或 visual comparison 任务。
- 验证 consent、fallback、event capture、session cleanup 和 Harness evidence。
- 记录没有浏览器或 Node 环境时的 text-only fallback。

完成定义：

- 完成一次真实 dry run。
- 证明 visual companion 可帮助澄清，但不可用时不会阻塞 G1。
- 更新 pressure test 或对应 artifact 证据。

依赖：R5 可后置；也可在 R5 前作为独立能力验证。

## 维护规则

- 不要把本路线图改写成新的同义 5 步计划。
- 完成一项时，把对应状态改为 `done`，补充提交或验证证据。
- 如果新增工作，使用新的 `R{n}` 编号，并说明来源和依赖。
- 如果删除或后置工作，改为 `deferred` 并写明原因，不要直接消失。
- 临时执行计划可以存在于任务 artifact 中，但长期剩余计划以本文为准。
