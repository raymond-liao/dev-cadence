# T-004 Git 提交阶段接入 git-commit Skill：技术方案

## 状态

✅ `confirmed`

## 需求来源

本方案基于 [T-004 需求确认](01-requirements.md) 和用户确认的入口集中路由方向。

## Codebase Exploration Findings

- `src/skills/using-dev-cadence/SKILL.md` 已经集中拥有业务 Workflow 路由、活动 Workflow 恢复和 commit/checkpoint 请求的优先级，适合像 Document Conventions 一样拥有 shared capability 的调用边界。
- `src/skills/document-conventions/SKILL.md` 展示了现有共享能力模式：入口规定何时读取固定安装路径，共享 skill 拥有完整规则，业务 Workflow 只保留自身语义。
- `src/skills/git-commit/SKILL.md` 当前仍描述普通用户提交触发，允许自行暂存，并在提交后建议 push、amend 和 reset；这些行为与内部共享能力边界冲突。
- Delivery Workflow 已经拥有专用分支、提交范围、检查、checkpoint 证据和提交后 hash 记录；`executing-plans` 还会冻结 Expected parent 与 Reviewed tree，shared skill 不得在最终身份检查后重新暂存。
- Asset Workflow 不创建 Delivery checkpoint 或运行记录，但其已确认资产变更仍可在入口统一约束下使用相同提交能力，同时保持普通 Asset Workflow Git 语义。
- SDD implementer 根据 dispatch task brief 创建提交，并因子代理边界不会重新执行入口路由；入口必须要求主代理显式传递 shared capability contract。
- 构建会复制整个 `src/skills`，但现有 package/install 测试没有明确点验 `git-commit` 的安装存在性和入口引用。

## 方案比较

### 在各 Workflow 中分别接入

每个 Workflow 分别引用 `git-commit`。规则直观，但会重复适用边界、固定路径和子代理传递要求，后续容易漂移。

### ✅ Selected：入口集中路由共享能力

由 `using-dev-cadence` 定义唯一调用边界和固定安装路径，`git-commit` 定义完整提交契约，各 Workflow 保留自己已有的提交时机、范围、检查和证据责任。这与 Document Conventions 的共享能力结构一致，也自然保证 Dev Cadence 外部不调用。

### 新增独立 commit-policy skill

拆分 message policy 与提交执行能力，边界最细，但会新增 skill、路由和安装资产；当前只有一个提交能力消费者契约，不足以证明额外抽象的必要性。

## 组件职责

### `using-dev-cadence`

- 先选择或恢复业务 Workflow，或直接路由 Dev Cadence shared capability，再处理其管理范围内的 commit 请求。
- 只有当前提交属于 Dev Cadence Workflow 或入口直接路由的 shared capability 时，才要求读取 `.dev-cadence/skills/git-commit/SKILL.md`。
- 明确不属于任何 Dev Cadence Workflow 或 shared capability 的普通提交按目标仓库普通 Git 规则处理，不调用该 shared skill。
- 要求允许提交的子代理 task brief 携带固定 skill 路径、调用上下文和禁止重新暂存的约束。

### `git-commit`

- 声明自己是 Dev Cadence 内部共享能力，拒绝缺少 Dev Cadence Workflow 调用上下文的直接调用。
- 只检查 `git status`、`git diff --cached` 和调用方给出的提交单元；不执行 `git add`。
- 敏感文件、无暂存内容、范围混杂或无法形成一个原子提交时停止并返回调用 Workflow。
- 生成 Conventional Commit message 并执行一次 `git commit`。
- scope 保持可选；`style` 只用于不改变含义的格式修改；保留 `build` 和 `ci` 类型；提交描述优先准确表达意图和影响，不机械禁止必要技术术语。
- 提交后只返回提交结果，由调用 Workflow 捕获完整 hash 和适用身份、更新记录并决定下一步。

### 业务 Workflow

- Asset Workflow 保留确认后写入权威资产、普通 Git 集成和无 Delivery 记录的模型。
- Delivery Workflow 保留 dedicated branch、stage checkpoint、用户请求进度提交、检查、manifest、ledger、parent/tree 和后续阶段责任。
- Workflow 必须在调用 shared skill 前精确暂存一个提交单元；`executing-plans` 在最终 identity check 后立即调用，返回后验证 committed parent/tree。

## 调用数据流

```text
用户请求、Workflow checkpoint 或 shared capability 资产提交
-> using-dev-cadence 确认 Dev Cadence 管理上下文
-> 调用方确定提交时机、范围和检查
-> 调用方精确暂存一个提交单元
-> 必要时冻结并复核 parent/tree
-> 读取 .dev-cadence/skills/git-commit/SKILL.md
-> staged-only 检查、敏感文件阻断、message 生成、一次 commit
-> 控制权返回调用方
-> 调用方捕获 hash、验证适用身份并继续原上下文
```

## 错误处理

- 不属于任何 Dev Cadence Workflow 或 shared capability：不调用 shared skill，返回普通仓库 Git 处理。
- 无已暂存内容：不创建 commit，返回 Workflow 记录适用的 skipped 结果。
- 敏感文件或范围混杂：阻断提交，Workflow 重新确定范围或请求必要用户决定。
- parent/tree 在提交前变化：`executing-plans` 重跑完整身份门禁，不得继续提交。
- 提交失败：保留当前 Workflow 阶段和已暂存内容，记录错误，不把失败解释为 checkpoint 或阶段确认。

## 测试策略

- 新增 focused contract test，先证明现有入口缺少 shared capability 路由、现有 `git-commit` 仍允许独立调用和重新暂存。
- 验证入口的活动 Workflow 前置条件、固定安装路径、外部不调用和子代理传递规则。
- 验证 `git-commit` 的 staged-only、敏感文件阻断、无独立触发、Conventional Commit 分类和控制权返回规则。
- 扩展 package/install contract，点验安装后的 `git-commit` 及入口引用。
- 运行构建、focused tests、source/dist 关键规则检查、空白检查和完整 `scripts/check-all.sh`。

## 风险与约束

- 入口规则必须表达“当前 commit 由 Dev Cadence Workflow 或 shared capability 管理”而不是“只要仓库安装了 Dev Cadence”，否则普通提交仍可能误触发。
- 单纯依赖 skill 名称可能命中个人全局旧版本，因此必须使用安装包内固定路径。
- SDD 子代理不经过入口是唯一的上下文传播例外，必须由 dispatch contract 明确覆盖。
- 本变更影响安装包行为，必须更新根 `version` 并构建同步 `dist`。
- 主 checkout 可能由其他任务占用；T-004 必须继续只在专用 worktree 中修改，Completion 不得覆盖或丢弃其他任务状态。
