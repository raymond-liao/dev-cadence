# Dev Cadence 路线图

> 历史归档：本文记录已经完成的阶段性路线图，不再作为当前执行计划。当前安装和卸载命令见 [../installation.md](../installation.md)，当前验证命令见 [../validation.md](../validation.md)。

## 目的

本文曾作为 Dev Cadence 阶段性剩余工作的稳定路线图。

历史阶段内，后续询问“还剩什么计划”时，以本文为准，而不是重新生成新的临时列表。当前维护工作不再从本文派生。

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
- 历史四入口 `dev-cadence-init`、`dev-cadence-deliver`、`dev-cadence-maintain` 和 `dev-cadence-authoring` 曾作为 user-facing 入口存在；当前已决定迁移到 `using-dev-cadence` + `cadence-*` 工作纪律 Skills。
- Plugin-owned references 已落地，包括 delivery disciplines、workflow、task classes、agent blueprints、Harness、gates、review、verification、debugging、visual companion 等。
- `templates/spec/`、`templates/runs/` 和 `templates/prompts/` 已落地。
- Package self-check、discipline route check 和 artifact check 脚本已落地并通过。
- 内部 dry-run evidence 已由自动化测试在临时目录生成；仓库不再长期追踪历史 `specs/` 运行产物。

当前阶段 R1-R7 已完成。后续如果新增工作，应追加新的路线图条目，而不是把历史已完成计划改写成新的临时列表。

## 路线图

### R1. 补齐 Adapter Reference

状态：`done`

目标：
补齐 `references/adapters.md`，让方案中的 Adapter 模型成为 Plugin package 的稳定 reference，而不是只散落在设计文档和 `delivery-disciplines.md` 的边界说明中。

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
已完成。`references/adapters.md` 已新增，并接入 Reference Map、`delivery-disciplines.md` state loading contract 和 `check-discipline-routes.mjs`。验证证据：`check-skill-package.mjs`、`check-discipline-routes.mjs`、`check-spec-artifacts.mjs templates`、临时 dry-run specs 检查和 `git diff --check`。

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
已完成。`scripts/init-task-artifacts.mjs` 已新增，并接入 `check-skill-package.mjs` CLI help 验证。行为验证覆盖 help、dry-run、实际写入、重复运行 skip、`--overwrite`、非法 ID 拦截，以及对生成 fixture 运行 `check-spec-artifacts.mjs`。

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
- 触发边界符合 `docs/codex-plugin-boundaries.md` 和 `docs/archive/skill-authoring-prespec.md`。
- 初始化、交付、维护、框架编制的入口语义不互相污染。
- Package self-check 能识别多入口结构，或有明确过渡检查。

依赖：R1、R2。

备注：
已完成。当前 package 包含 `skills/dev-cadence-init`、`skills/dev-cadence-deliver`、`skills/dev-cadence-maintain` 和 `skills/dev-cadence-authoring` 四个 user-facing entrypoint skills。共享 references、templates 和 scripts 位于 package root。`check-skill-package.mjs` 已验证入口 frontmatter/openai metadata，`check-discipline-routes.mjs` 已验证入口 skill resource 和 `skill-layout.md` 目标声明。

### R4. 实现 Thin Repo 初始化与维护 Runtime

状态：`done`

目标：
让 `dev-cadence-init` 和 `dev-cadence-maintain` 不只是规则说明，而能实际创建、检查和修复 thin repo-local contract。

范围：

- 生成或更新 root `AGENTS.md` 的 Dev Cadence 入口段落。
- 生成或维护 `specs/records/.gitkeep`。
- 可选生成 `.dev-cadence.yaml` 作为本地覆盖配置。
- 更新 `.gitignore`，确保 `.dev-cadence.yaml` 被忽略。
- 实现 inspect/sync/repair/diagnose 的最小行为。
- 保留已有仓库指令和 local overlays。

完成定义：

- 在临时 fixture repo 中能初始化 thin contract。
- 重复运行具有幂等性。
- 不创建 task-specific specs，不修改产品代码。
- 维护模式能报告 drift、local overlay 和 manual review 项。

依赖：R3。

备注：
已完成。`scripts/sync-repo-contract.mjs` 已新增，支持 `inspect`、`init`、`sync`、`repair` 和 `diagnose`，写入边界限定为 thin repo-local contract。fixture 验证覆盖缺失仓库报错、空仓库 inspect、init 写入、重复 init 幂等、diagnose、local overlay 报告、marker conflict 阻断且不继续写其它文件。脚本已接入 `check-skill-package.mjs` CLI help 验证和 `check-discipline-routes.mjs` Reference Map 检查。

### R5. 实现 Delivery Runtime 最小闭环

状态：`done`

目标：
让 `dev-cadence-deliver` 能按当前规则执行一个最小交付闭环，而不是只依赖人工记忆流程。

范围：

- 读取 repo-local `AGENTS.md`、`.dev-cadence.yaml` 和 legacy `.ai/**` overlay（如果存在）。
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
已完成。`scripts/run-delivery-dry-run.mjs` 已新增，支持在已初始化 fixture repo 中读取 thin contract、推断 `selected_workflow` 和 `task_class`、创建 task artifacts 和 Harness run evidence、记录 scope reconciliation、verification status、review decision 和 acceptance status。fixture 验证覆盖未初始化仓库报错、`feature-dev`/`S1` 推断、security goal 升级为 `S2`、无 named accepter 时 G6 blocked、提供 named accepter 时仅接受 dry-run scope，以及对生成 specs 运行 `check-spec-artifacts.mjs`。

### R6. 改善 Acceptance 展示体验

状态：`done`

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

备注：
已完成。`scripts/summarize-acceptance.mjs` 已新增，按 `task_id` 读取 task artifacts 和 Harness run evidence，输出面向 Human 的 Markdown 摘要或 JSON。摘要包含 goal、workflow、task class、implementation status、scope reconciliation、verification status、review decision、acceptance status、changed files、created artifacts、skipped checks、blockers、residual risk、available evidence，以及需要写入 `08-acceptance.md` 的 Human confirmation 字段。验证覆盖 blocked acceptance、已记录 named Human acceptance、JSON 输出和缺失 task 报错；脚本保持 read-only，不修改 `08-acceptance.md`。

### R7. 真实验证 Visual Companion

状态：`done`

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

备注：
已完成。稳定验证结论已迁移到 `docs/archive/validation-notes.md`：visual companion 能启动、渲染 clarification screen、记录 choice event、清理 session；sandbox localhost 可能受限并触发 fallback。结论保持 visual companion 为 optional capability；event 只是 clarification evidence，不是 G1 或 final acceptance。

### R8. 重构为 Bootstrap + Cadence Discipline Skills

状态：`done`

目标：
按 `docs/archive/dev-cadence-target-model.md`，把发布用 Skill 从旧的产品菜单式四入口迁移为 `using-dev-cadence` bootstrap 加 `cadence-*` 工作纪律 Skills。

范围：

- 新增 `using-dev-cadence` 入口 Skill。
- 将普通交付能力拆到 `cadence-clarify`、`cadence-plan`、`cadence-execute`、`cadence-tdd`、`cadence-debug`、`cadence-review` 和 `cadence-verify`。
- 将初始化、inspect、sync、repair、diagnose 迁移到 `cadence-sync`。
- 不再把 `dev-cadence-authoring` 作为普通用户发布 Skill。
- 更新 package checks、route checks、tests、README 和发布结构 reference。

完成定义：

- Codex package 只发布目标 Skill 集合。
- `using-dev-cadence` 作为唯一 Dev Cadence 入口 Skill，不再发布旧四入口菜单。
- `bash tests/run-all.sh` 通过。
- 本地发布包能通过 `scripts/package-codex-plugin.mjs --clean` 生成并通过 package checks。

依赖：`docs/archive/dev-cadence-target-model.md`。

备注：
已完成。发布用 Skill 已迁移为 `using-dev-cadence`、`cadence-clarify`、`cadence-plan`、`cadence-execute`、`cadence-tdd`、`cadence-debug`、`cadence-review`、`cadence-verify` 和 `cadence-sync`。旧四入口已从发布包移除，`dev-cadence-authoring` 不作为普通用户 Skill 发布。发布包不包含 hooks，依赖 Codex 原生 Skill 触发或用户显式要求使用 Dev Cadence。验证证据：`bash tests/run-all.sh` 和 `node scripts/package-codex-plugin.mjs --clean` 均通过。

## 维护规则

- 不要把本路线图改写成新的同义 5 步计划。
- 完成一项时，把对应状态改为 `done`，补充提交或验证证据。
- 如果新增工作，使用新的 `R{n}` 编号，并说明来源和依赖。
- 如果删除或后置工作，改为 `deferred` 并写明原因，不要直接消失。
- 临时执行计划可以存在于任务 artifact 中，但长期剩余计划以本文为准。
