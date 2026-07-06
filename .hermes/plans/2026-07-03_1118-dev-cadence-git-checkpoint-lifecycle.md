# Dev Cadence Git Checkpoint Lifecycle Plan

| Skill | 需要用 Git 吗 | 需要用 Git 做什么 | 前提 / 授权 | 不应该做什么 |
|---|---:|---|---|---|
| `using-dev-cadence` | 需要 | 判断本次任务是否进入 branch / checkpoint / fix / finalization 流程；要求运行对应 preflight；区分代码反馈和非代码反馈 | Supervisor 负责路由；Human 或 Supervisor 负责最终风险/发布类决策 | 不写代码；不自我验收；不把 checkpoint 当最终完成；不让具体 Skill 绕过 Supervisor |
| `cadence-clarify` | 不需要 | 不直接使用 Git；只在上下文里理解当前变更背景 | Git 相关问题只作为澄清范围、风险、验收口径的输入 | 不 commit；不建分支；不决定 review range；不标记 gate/finalization |
| `cadence-plan` | 不需要 | 在计划里说明哪些 AC/task 未来可能需要 checkpoint 证据 | 只规划，不执行 | 不 commit；不建分支；不默认加入提交步骤；不标记 gate |
| `cadence-tdd` | 可能需要 | 为单个 AC/story slice 产生 Red / Green / Refactor 证据；准备 checkpoint candidate evidence | 只有 run context 明确允许时，才可执行 scoped checkpoint commit | 不默认 commit；不 merge/push/release；不声称 G5/G6/final done |
| `cadence-executing-plans` | 可能需要 | 按计划执行后报告 changed files、验证命令、checkpoint candidate evidence | 只有 run context 明确允许时，才可执行 scoped checkpoint/fix commit | 不自行选择 Git lifecycle；不默认 commit；不标记 workflow complete |
| `cadence-subagent-development` | 可能需要 | 为每个 Worker task 生成 task evidence；从 worktree diff 或 explicit range 打包 review package；返回 checkpoint candidate data | Worker 只能在自己的 run context 明确允许时执行 scoped commit | 不把 local progress 当 Harness evidence；不把 task-local review 当 G5；不 final merge/push/release |
| `cadence-request-code-review` | 需要，只读 | 对明确 diff/range 发起 review；返回 findings/verdict；把 findings 分成代码问题和非代码问题 | 必须有 explicit range/diff 和 dirty-state reconciliation | 不修代码；不 commit；不把 spec/design/acceptance/evidence/gate gap 送进 code-review fix path |
| `cadence-code-review` | 可能需要 | 处理已有 code review findings/PR comments；验证 finding；修有效代码问题；准备 tied-to-finding 的 fix evidence | 只有 run context 明确允许时，才可执行 scoped fix commit；fix 必须绑定 finding ID | 不处理泛化非代码反馈；不默认 commit；不 final merge/push/release；不拥有 G5/G6 |
| `cadence-verify` | 需要，只读 | 运行/读取 tests、gate checks、commit-readiness checks；汇总 dirty state、skipped checks、residual risk、Human acceptance request fields | 用于 positive claim、commit、PR、merge/push/release、acceptance request 前 | 不创建 commit；不写 Human acceptance；不标记 gate complete；不执行 finalization |
| `cadence-debug` | 可能需要，只读为主 | 调试时读取 diff/history；返回 root cause、repro、fix evidence | 只作为诊断证据；实际修复仍回 implementation/review/verify 流程 | 不拥有 checkpoint/fix/finalization；不跳过正常 review/verify |
| `cadence-research` | 不需要 | 不直接使用 Git；最多引用只读 repo 状态作为研究证据 | 研究结论交给 Human/Supervisor 决策 | 不改产品代码；不 commit；不做最终技术/业务/发布决策 |
| `cadence-dispatch-parallel` | 可能需要 | 派发独立 read-only 或 bounded Worker；汇总各 Worker 的 Git/conflict/risk notes | 并行结果必须回到 integration review / Supervisor 判断 | 不让并行 Worker final；不直接 merge 冲突修改；不跳过集成验证 |
| `cadence-sync` | 可能需要 | 检查/修复 Dev Cadence runtime/contract 文件；对比 Human/controller 提供的 source/bundle/version；报告 source/package Git 状态 | 只处理 Dev Cadence runtime/contract 同步，不处理产品交付 Git lifecycle | 不做产品 workflow commit；不自行发现上游新版本；不 final merge/push/release |

| Git 事情 | 谁负责决定 | 哪些 Skill 参与 | 必须满足什么条件 | 不允许什么 |
|---|---|---|---|---|
| 创建 delivery branch/worktree | Supervisor | `using-dev-cadence` 负责路由，Harness 负责执行/记录边界 | Human 或 Supervisor 选择 branch-based delivery | Worker 自己开分支并改变流程 |
| 产品编辑前检查 dirty worktree | Harness | `cadence-verify` 和实现类 Skill 可返回证据 | 产品源文件、测试、迁移、配置被编辑前 | 忽略 unrelated dirty files |
| 准备 checkpoint evidence | Worker Skill | `cadence-tdd`、`cadence-executing-plans`、`cadence-subagent-development` | AC/task slice 已有验证证据 | 把 evidence 当最终验收 |
| 创建 checkpoint commit | Supervisor 授权的执行方或显式授权 Worker | 实现类 Skill 仅在 run context 允许时参与 | `check-before-commit --intent checkpoint --task-id <id>` 通过 | 未授权 commit；pending/failed evidence 也 commit |
| 准备 fix evidence | `cadence-code-review` | `cadence-code-review` | finding 是有效代码/实现问题，fix 范围明确 | 把非代码 feedback 当 fix |
| 创建 fix commit | Supervisor 授权的执行方或显式授权 Worker | `cadence-code-review` 仅在 run context 允许时参与 | fix 绑定 finding ID，checkpoint readiness 通过 | 未绑定 finding 的泛化提交 |
| 请求 code review | Supervisor | `cadence-request-code-review` | 有明确 diff/range 和 dirty-state reconciliation | reviewer 猜测范围 |
| review diff/range | Reviewer Worker | `cadence-request-code-review` | reviewer 只读指定范围 | reviewer 修改代码或替 Human 接受风险 |
| fix 后 re-review | Supervisor | `cadence-request-code-review` | 提供 fix range 和原 finding IDs | 修完不复审 |
| final readiness check | Supervisor | `cadence-verify` | final commit/PR/merge/push/release 前 | 只看 checkpoint 证据就 final |
| final commit / merge / push / release | Supervisor 或具名 Human 授权 owner | `using-dev-cadence`、`cadence-verify` 只提供证据 | G5 可接受，G6 具名 Human acceptance 已记录，finalization decision 已记录 | Worker final；checkpoint 代替 final；无 Human acceptance 发布 |
| 删除 branch / 移除 worktree | Supervisor 或具名 Human 授权 owner | 具体行为 Skill 不参与决策 | 证据已保存，cleanup 明确授权 | 默认删除、丢失证据、用 cleanup 掩盖失败 |
