# T-004 Git 提交阶段接入 git-commit Skill：需求确认

## 状态

✅ `confirmed`

## 确认依据

用户要求直接修改 `git-commit` 接入方式，并进一步澄清：“不要独立模式”是指不得在 Dev Cadence 之外调用。用户随后选择由 `using-dev-cadence` 入口集中定义该共享能力的调用边界，方式与 Document Conventions 相同。

## ✅ 纳入范围

- 将安装包内的 `git-commit` 定义为 Dev Cadence 内部共享能力，而不是可由普通用户提交请求直接触发的独立入口。
- 由 `using-dev-cadence` 统一规定调用时机、适用边界和安装包内的固定 skill 路径。
- 所有已安装 Dev Cadence Workflow，以及由入口直接路由的 Dev Cadence shared capability，在创建其管理范围内的 Git commit 时使用该共享能力。
- 各 Workflow 继续负责提交时机、业务范围、精确暂存、适用检查、阶段门禁和持久化证据。
- `git-commit` 负责检查已暂存提交单元、阻断敏感文件、生成 Conventional Commit 信息并执行一次提交。
- 当普通提交请求不属于任何 Dev Cadence Workflow 或 shared capability 时，按目标仓库的普通 Git 规则处理，不调用安装包内的 `git-commit`。
- 对允许创建提交但不会读取 `using-dev-cadence` 的子代理，入口规则必须要求主代理在 dispatch context 中传递共享能力路径和调用约束。
- 修正 `git-commit` 当前与上述边界冲突或自相矛盾的提交信息、安全检查和后续建议规则：scope 保持可选，`style` 只表示不改变含义的格式修改，保留 `build` 和 `ci`，且不机械禁止必要技术术语。
- 增加入口、shared skill、安装包、子代理传递和 source/dist 同步契约，并更新根版本。

## ❌ 排除范围

- 不修改目标仓库之外的个人全局 `git-commit` skill 或其他仓库外配置。
- 不改变任何 Workflow 的业务阶段、用户确认门、Business Acceptance 或 Completion 语义。
- 不让 `git-commit` 选择或恢复业务 Workflow。
- 不让 `git-commit` 决定提交范围、执行测试、创建分支或 worktree、维护 manifest 或记录交付证据。
- 不纳入 merge、push、pull、PR、branch cleanup、discard 或历史改写操作。
- 不直接编辑 `dist/.dev-cadence/**`；分发包通过构建脚本同步。

## 验收标准

1. `using-dev-cadence` 明确要求：只有当前 commit 由 Dev Cadence Workflow 或 shared capability 管理时，才可读取并调用 `.dev-cadence/skills/git-commit/SKILL.md`。
2. 不属于任何 Dev Cadence Workflow 或 shared capability 的普通提交请求不会路由到安装包内的 `git-commit`。
3. Asset Workflow 与 Delivery Workflow 保留各自的提交时机、记录模型和证据责任，不被 shared skill 改写。
4. `git-commit` 只提交调用方已经精确暂存的内容，不执行 `git add`，不扩大、缩小或拆分提交单元。
5. 敏感文件或范围异常会在提交前阻断；无已暂存变更时不会创建空提交。
6. 提交信息遵循一致且无内部冲突的 Conventional Commit 规则，包括可选 scope、正确的 `style` 语义、`build`/`ci` 类型和必要技术术语的准确使用。
7. `git-commit` 提交后立即把控制权交还调用 Workflow，不提示越过 Workflow 门禁的 push、amend、reset 或其他操作。
8. SDD 等允许提交的子代理能够从 dispatch context 获得固定 skill 路径和相同约束，无需修改 vendored Superpowers 副本。
9. source、dist、安装结果、入口和关键契约测试保持同步，根版本已更新，完整检查通过。

## 开放问题与假设

- 无。入口集中路由适用于所有已安装 Dev Cadence Workflow 和入口直接路由的 shared capability；个人全局 skill 不属于本仓库实施范围。

## 需求来源

- `docs/tasks/T-004-git-commit-skill-workflow-integration.md`
- `src/skills/using-dev-cadence/SKILL.md`
- `src/skills/git-commit/SKILL.md`
- `src/skills/document-conventions/SKILL.md`
