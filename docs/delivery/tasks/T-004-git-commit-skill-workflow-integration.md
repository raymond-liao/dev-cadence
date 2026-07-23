# T-004 Git 提交阶段接入 git-commit Skill

## 基本信息

- ID：`T-004`
- Version：`4`
- Status：`Done`
- Priority：`P1`
- Change Type：Workflow Governance

## 任务目标

将安装包内的 `git-commit` 定义为 Dev Cadence 内部共享提交能力，并由 `using-dev-cadence` 像路由 Document Conventions 一样统一规定调用边界。只有当前 commit 由 Dev Cadence Workflow 或 shared capability 管理时才能调用该能力；Dev Cadence 之外的普通提交不得调用。调用方负责提交时机、范围、精确暂存、检查和证据，`git-commit` 负责检查已暂存提交单元、生成 Conventional Commit 信息并执行一次提交。

## 背景

仓库已经有 `git-commit` skill，定义了 Conventional Commit、变更分析、文件暂存和敏感文件检查规则，但当前描述仍允许把它作为普通用户提交请求的独立入口。Dev Cadence 的入口已经负责选择或恢复业务 Workflow，各 Workflow 也已经拥有各自的提交时机、范围、检查和记录语义。

如果只在各 Workflow 中分别写接入规则，适用边界、固定路径和子代理传递要求会重复并产生漂移。调用边界应集中在 `using-dev-cadence`，完整提交规则应保留在 `git-commit`，业务 Workflow 只保留其拥有的提交语义。`git-commit` 不得重新暂存，否则可能改变 Workflow 已经审查并冻结的 tree。

## ✅ 范围

- 在 `using-dev-cadence` 中定义共享提交能力的唯一调用边界和固定安装路径 `.dev-cadence/skills/git-commit/SKILL.md`。
- 只有当前 commit 由已选中或恢复的 Dev Cadence Workflow，或由入口明确路由的 Dev Cadence shared capability 管理时，才允许调用安装包内的 `git-commit`。
- 将该边界覆盖到所有已安装 Dev Cadence Workflow，不锁定 Workflow 数量；各 Workflow 继续保留自己的 Asset 或 Delivery 记录模型及提交语义。
- 对 Open Question Registry 等可由入口直接路由、无需启动业务 Workflow 的 shared capability，只有其当前资产操作需要创建 commit 时才调用 `git-commit`。
- 当普通提交请求不属于任何 Dev Cadence Workflow 或 shared capability 时，按目标仓库的普通 Git 规则处理，不调用安装包内的 `git-commit`。
- 将 `git-commit` 改为只处理已经精确暂存的单一提交单元，不执行任何 `git add`，不扩大、缩小或自行拆分提交范围。
- 敏感文件、无已暂存变更或范围混杂必须在提交前阻断，并将控制权返回调用 Workflow。
- 由调用 Workflow 在提交前完成范围、检查、精确暂存和必要的 parent/tree 身份验证；提交后捕获完整 commit SHA、验证适用身份并更新自己的记录。
- 对允许创建提交但不会重新读取 `using-dev-cadence` 的子代理，由主代理在 dispatch context 中传递固定 skill 路径和相同调用约束。
- 修正 `git-commit` 中与内部共享能力冲突或彼此不一致的 Conventional Commit 规则：scope 保持可选，`style` 只表示不改变含义的格式修改，保留 `build` 和 `ci` 类型，提交描述优先准确表达意图和影响且不机械禁止必要技术术语。
- 保持敏感文件检查为提交前阻断，并移除 push、amend、reset 等越过当前 Dev Cadence 上下文的提交后建议。
- 更新入口、shared skill、子代理传递、package 和 install 契约检查，验证 source、dist、安装包同步，并更新根目录 `version`。

## ❌ 非范围

- 不改变 workflow 的阶段顺序、用户确认门或 checkpoint 状态模型。
- 不把 merge、push、branch、worktree 或 PR 操作纳入本任务。
- 不改变 T-003 定义的实施提交审查、ledger 和身份验证规则。
- 不修改 vendored Superpowers 副本。
- 不让 `git-commit` 选择或恢复业务 Workflow。
- 不让 `git-commit` 决定提交时机、业务范围、测试、分支、worktree、manifest 或交付证据。
- 不修改目标仓库之外的个人全局 `git-commit` skill 或其他仓库外配置。
- 不允许 `git-commit` 输出 push、amend、reset 或其他会越过当前 Workflow 门禁的后续操作建议。

## 完成条件

1. `using-dev-cadence` 明确要求先确认当前 commit 由 Dev Cadence Workflow 或 shared capability 管理，再读取固定路径 `.dev-cadence/skills/git-commit/SKILL.md`。
2. 不属于任何 Dev Cadence Workflow 或 shared capability 的普通提交请求不会路由到安装包内的 `git-commit`。
3. 所有已安装 Dev Cadence Workflow 均可在自身管理的 commit 节点使用共享能力，同时保留各自的提交时机、范围、检查和记录模型。
4. `git-commit` 不再作为独立入口，不执行 `git add`，不改变或自行拆分调用方已暂存的提交单元。
5. 敏感文件、无已暂存变更或范围混杂都会在创建提交前停止并返回调用 Workflow。
6. Delivery Workflow 的提交前后身份、hash、ledger、stage record 和 manifest 责任不被 shared skill 取代；Asset Workflow 不因此创建 Delivery 运行记录。
7. 允许提交的子代理通过 dispatch context 获得固定 skill 路径和相同约束，且无需修改 vendor。
8. `git-commit` 的 scope、`style`、`build`、`ci` 和描述原则与 Conventional Commit 规则一致，必要技术术语不会被机械禁止。
9. `git-commit` 不输出越过当前 Dev Cadence Workflow 或 shared capability 的后续建议。
10. 契约检查覆盖入口边界、安装路径、外部禁止调用、shared capability、子代理传递和安装结果。
11. source、dist、安装包和根版本保持一致，空白检查与完整契约验证通过。

## Task Relationships

- Related：[`S-017 工作项卡片与开发 Workflow 接入`](../stories/S-017-work-item-development-workflow-integration.md)。
- Follows：[`T-003 Executing-Plans 实施提交前审查`](T-003-executing-plans-pre-commit-review.md)。

## 依赖

- 无强制前置依赖。

## Open Questions

- 无。入口集中路由覆盖所有已安装 Dev Cadence Workflow 和入口明确路由的 shared capability；Dev Cadence 之外不得调用，仓库外个人全局 skill 不属于本任务。

## 相关文档

- [`S-017 工作项卡片与开发 Workflow 接入`](../stories/S-017-work-item-development-workflow-integration.md)
- [`T-003 Executing-Plans 实施提交前审查`](T-003-executing-plans-pre-commit-review.md)
- [`工作项规划流程`](../../workflows/work-item-planning.md)
- [`Backlog`](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 创建 Git 提交 skill 接入任务。 | 确保流程进入提交节点时真正使用统一的提交规则。 |
| 2 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 明确 Workflow 与 `git-commit` 的职责边界、pre-staged 调用顺序及适用提交类型。 | 防止 `git-commit` 重新暂存后改变已审查的实施 tree，并覆盖 SDD 与活动 Workflow 提交。 |
| 3 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 将 `git-commit` 收敛为由 `using-dev-cadence` 集中路由的内部共享能力。 | 用户明确要求不得在 Dev Cadence 之外调用，并选择与 Document Conventions 相同的入口共享能力模式。 |
| 4 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 将调用边界扩展为所有已安装 Workflow 和入口路由的 shared capability，并固化提交信息规则。 | 避免遗漏 Work Item Analysis 与无需启动业务 Workflow 的共享资产能力，同时防止确认决策只存在于临时技术记录。 |
