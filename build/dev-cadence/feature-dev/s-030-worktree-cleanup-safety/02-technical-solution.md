# S-030 Worktree 清理安全与证据 - 技术方案

## 已确认需求来源

- 已确认需求来源: `build/dev-cadence/feature-dev/s-030-worktree-cleanup-safety/01-requirements.md`
- 导航：[S-030 需求确认](01-requirements.md)
- Requirements SHA-256: `0aa18011bb6845e285c1303adeb30284abc63520ec94aa9bce3a0ea093e1a5d3`
- Requirements Checkpoint: `2aa3e65`
- User Confirmation Commit: `4b75a4e`
- Work Item: [S-030 Worktree 清理安全与证据](../../../../docs/delivery/stories/S-030-worktree-ownership-detection.md), Version `4`, Status `In Progress`

## 当前结论

- Status: ✅ `confirmed`
- Decision: ✅ `selected`
- 推荐方案：方案 C，在既有职责边界内增加一个由 `finishing-a-development-branch` 所有的确定性 worktree ownership verifier；入口产生不可变创建证据，三个 Delivery workflow 对称持久化并传递，正常 Completion 和 `whole-run discard` 在删除前复用同一验证门禁。
- 技术边界、证据模型和验证策略已确认；允许开始 Implementation Plan，尚未进行实现代码修改。

## Codebase Exploration Findings

### 视角一：Completion 与 Discard 清理执行链

关键发现：

- `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md:40-55` 识别 normal checkout、named worktree 与 detached HEAD；named worktree 最终进入 Step 6。
- 同文件 `:120-162` 的本地 Merge 在合并成功后先执行 Step 6，再删除 task branch；ownership 失败时必须同时保留仍被 worktree 占用的 branch。
- 同文件 `:179-245` 的 `whole-run discard` 已要求 current-run evidence 与 `git worktree list --porcelain` 一致，并禁止删除 external/unknown worktree，但没有可执行、可复用的精确校验器。
- 同文件 `:272-293` 的普通 Completion Step 6 仍以 worktree 路径位于 `.worktrees/` 或 `worktrees/` 下推断所有权。该规则会误删恰好位于这些目录的外部 worktree，也会漏掉配置在自定义项目内目录的 Dev Cadence worktree。
- 普通 Completion 与 `whole-run discard` 当前使用两套所有权逻辑；S-030 需要统一删除资格门禁，但不改变 merge、discard 或 branch 删除命令本身。

已读取的核心文件：

1. `docs/stories/S-030-worktree-ownership-detection.md`
2. `build/dev-cadence/feature-dev/s-030-worktree-cleanup-safety/01-requirements.md`
3. `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
4. `src/vendor/superpowers/skills/using-git-worktrees/SKILL.md`
5. `src/workflows/using-dev-cadence/SKILL.md`
6. `tests/finishing-a-development-branch-contract.sh`
7. `tests/finishing-discard-contract.sh`
8. `tests/work-item-development-workflow-contract.sh`

主要风险：删除前验证与删除命令之间存在 TOCTOU；ownership 失败后若仍执行 branch 删除会破坏保守保留语义；普通非 Dev Cadence 的 Superpowers 调用不应被本 Story 意外扩域。

### 视角二：创建证据生产、持久化与传递链

关键发现：

- `src/workflows/using-dev-cadence/SKILL.md:206-220` 是 claim 与 workspace bootstrap 的唯一入口所有者，但现有 `create or verify` 未结构化区分“本次创建”“复用既存”或“平台管理”。
- `src/workflows/feature-dev/SKILL.md:189-245`、`src/workflows/bug-fix/SKILL.md:173-215` 和 `src/workflows/refactor/SKILL.md:218-260` 分别拥有自己的 manifest；三者只要求粗粒度的 Workspace path 与 `Worktree created by this run`，没有完整不可变创建 tuple。
- 三个 workflow 的 Completion 分别在 feature `:806-825`、bug-fix `:739-758`、refactor `:821-840` 将 current-run context 传给 finishing；因此同一证据模型必须保持对称，不能只修改 feature-dev。
- 当前 S-030 manifest 已证明 creation HEAD 与 current HEAD 会自然分离：worktree 创建于 `c340758`，workflow 记录提交已继续推进分支。若要求 creation HEAD 与实时 porcelain HEAD 等值，第一次正常提交后就会产生永久 false negative。
- manifest 是创建证据唯一权威来源；stage record 可提供业务阶段证据，但不能成为 worktree 创建来源的备选所有者。

已读取的核心文件：

1. `src/workflows/using-dev-cadence/SKILL.md`
2. `src/workflows/feature-dev/SKILL.md`
3. `src/workflows/bug-fix/SKILL.md`
4. `src/workflows/refactor/SKILL.md`
5. `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`
6. `tests/work-item-development-workflow-contract.sh`
7. `tests/workflow-symmetry.sh`
8. `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`
9. `tests/delivery-record-contract.sh`

主要风险：manifest 自身提交会推进 HEAD，不能把“写入同一 manifest 的 current HEAD”设计成删除时必须精确相等的自引用字段；full branch ref 与短分支名混用也会造成错误匹配。

### 视角三：测试、构建与分发边界

关键发现：

- `tests/finishing-discard-contract.sh:26-49` 和 `tests/finishing-a-development-branch-contract.sh:44-60` 主要锁定文字契约，没有真实 Git worktree fixture 覆盖 path/ref/HEAD 冲突和自定义目录。
- `tests/work-item-development-workflow-contract.sh:69-145` 已有临时 Git 仓库和真实 worktree fixture，可复用其测试风格验证创建证据 handoff。
- `tests/workflow-symmetry.sh:732-765` 已负责三个 Delivery workflow 的 Completion 上下文对称性，适合扩展精确 schema 和 manifest-only 来源断言。
- `scripts/build.sh:4-19` 会复制整个 `src/vendor` 到 `dist/.dev-cadence/vendor`；`tests/package-contract.sh:43-80` 验证分发树与源树一致，因此新增 finishing supporting script 会自动进入包，但应增加显式存在性与安装验证。
- `scripts/check-all.sh:8-10` 统一执行 build、whitespace 和 `tests/run-all.sh`；新增动态 contract test 必须接入 `tests/run-all.sh`。
- 该变更会改变可安装包的 Completion 行为，根 `version` 应从 `0.29.1` 提升到 `0.30.0`；不需要修改 README，因为安装接口和用户操作菜单不变。

已读取的核心文件：

1. `scripts/build.sh`
2. `scripts/check-all.sh`
3. `tests/run-all.sh`
4. `tests/package-contract.sh`
5. `tests/install-contract.sh`
6. `tests/workflow-symmetry.sh`
7. `tests/work-item-development-workflow-contract.sh`
8. `version`

主要风险：只增加文本断言无法证明 porcelain 解析和身份比较正确；直接编辑 `dist/.dev-cadence/**` 会绕过源文件；新增脚本若未验证 executable mode 或安装结果，会在目标仓库中不可用。

## 备选方案与方案比较

### 方案 A：最小文字规则修改

在 finishing 和三个 Delivery workflow 中补充精确说明，继续由代理在运行时手工解析 `git worktree list --porcelain`，并扩展现有静态文本断言。

优点：改动文件少，不新增脚本接口。

缺点：路径 canonicalization、porcelain stanza 解析、full ref 与 HEAD 比较仍由每次执行临时实现；正常 Completion 与 discard 容易再次分叉，测试不能证明真实 Git 行为。该方案不足以支撑 P0 删除安全。

### 方案 B：新增独立共享 skill 或顶层 ownership contract

创建新的 worktree ownership skill 或共享 capability，让入口、三个 Delivery workflow 和 finishing 都路由到它。

优点：表面上集中规则，未来可扩展其他 workspace 类型。

缺点：worktree 删除资格已有唯一自然所有者 `finishing-a-development-branch`；新增 skill 会增加路由、上下文加载和职责竞争，不满足本仓库 Skill 准入标准。当前只有一个清理消费者，不需要新的公共能力。

### 方案 C：现有 finishing 所有者内的确定性 verifier（✅ Selected）

保留现有 workflow 和 finishing 职责，新增 `src/vendor/superpowers/skills/finishing-a-development-branch/scripts/verify-worktree-ownership.sh` 作为 supporting script。`using-dev-cadence` 生产创建证据，三个 Delivery workflow 对称持久化和传递，finishing 的普通 Dev Cadence Completion 与 `whole-run discard` 在删除前调用同一 verifier。

优点：没有新 skill 或竞争所有者；确定性解析和校验可由真实 Git fixture 测试；自定义项目内目录自然适用；normal 与 discard 共用同一判定。

代价：需要对仓库内 vendored finishing 副本做一个明确、局部的 Dev Cadence 适配，并同步更新三个 Delivery workflow 与多项 contract tests。该 vendored skill 已承载 B-002 的 Dev Cadence-specific whole-run discard 规则，因此它仍是现有行为所有者；用户确认本技术方案即明确授权这次局部 vendor 修改，不代表升级或重同步整套 Superpowers。

## 已选方案

- Status: ✅ `selected`
- Selected Approach: 方案 C。
- Selection Evidence: 用户于 `2026-07-20T21:37:43+0800` 选择选项 1，确认当前 Technical Solution，并授权在 Implementation Plan 中纳入限定的 vendored finishing 修改。
- Selection Effect: 允许进入 Implementation Plan；在 Implementation Plan 单独确认前仍不创建 verifier、不修改 workflow 源规则、测试或版本号。

## 推荐方案设计

### 1. 职责边界

- `using-dev-cadence` 继续唯一拥有 claim 后的 workspace 创建或验证。它在 workspace preparation 完成时产生一次结构化 handoff，不新增 workflow 或 skill。
- `feature-dev`、`bug-fix` 和 `refactor` 各自继续拥有自己的 manifest。初始 manifest 必须原样持久化入口 handoff，之后不得将不可变创建证据改写为当前 HEAD。
- `finishing-a-development-branch` 继续唯一拥有删除资格判定和 `git worktree remove` 前门禁。supporting verifier 只读，不执行删除、branch 操作、记录归档或结果写入。
- `dist/.dev-cadence/**` 只由 `bash scripts/build.sh` 生成，不直接编辑；当前仓库的 `.dev-cadence/**` 安装副本不作为本次源修改入口。

### 2. 不可变 Worktree Creation Evidence

入口只在本次运行实际创建 worktree，并立即从新增的 exact `git worktree list --porcelain` stanza 验证成功时，记录 `Created By Current Run: yes`。复用既存 worktree、无法证明新建来源、平台外部管理 workspace 或 `worktree.enabled: false` 均记录 `no`，不得因配置值或目录名称推断为 `yes`。

每个 Delivery manifest 使用同一字段：

```text
## Worktree Creation Evidence

- Created By Current Run: `yes|no`
- Workspace Path: `<repository-relative path or not_applicable>`
- Task Branch Ref: `<refs/heads/... or not_applicable>`
- Creation HEAD SHA: `<full 40-hex SHA or not_applicable>`
```

约束：

- `Workspace Path` 必须是 target repository root 下的仓库相对项目内路径，不允许绝对路径或 `..` 逃逸；配置的自定义项目内目录有效。
- `Task Branch Ref` 使用 full ref，避免短名称歧义。
- `Creation HEAD SHA` 是 worktree 创建后 stanza 中的初始 HEAD，只记录一次并保持不可变。
- `Created By Current Run: no` 时其余三个字段使用明确的 `not_applicable` 或经过验证的非所有权观察值，但不能形成删除资格。
- manifest 是该 tuple 的唯一权威来源；stage records 不复制或覆盖它。

### 3. 删除前运行时身份与 verifier

`Creation HEAD SHA` 与当前 HEAD 具有不同职责：前者证明创建起点，后者证明删除目标现在仍是已冻结的 task worktree。finishing 在既有 Completion identity snapshot 中冻结 current task branch SHA，作为 `Expected Current HEAD SHA`；不尝试把它写回同一个 manifest 后再要求自引用等值。

Verifier 接收：primary repository root、manifest 的四个不可变字段，以及 finishing 冻结的 `Expected Current HEAD SHA`。它必须：

1. 验证必填字段、40-hex SHA、full branch ref、repository-relative workspace path 和 `Created By Current Run: yes`。
2. 在内存中相对 primary root canonicalize workspace；不持久化绝对路径。
3. 使用 `git worktree list --porcelain -z` 结构化解析全部 stanza，并要求精确匹配唯一 workspace record；不得使用路径 substring、basename 或目录 allowlist。
4. 要求 stanza 的 branch 与 manifest full ref 精确相等。
5. 要求 stanza HEAD、task branch ref 当前解析值与 finishing 冻结的 Expected Current HEAD 三者精确相等。
6. 要求 Creation HEAD 是有效 commit，并且是 Expected Current HEAD 的祖先；重写、替换或不相关历史必须保守失败。
7. 对 detached、bare、prunable、locked、缺字段、重复或不一致 stanza 保守失败。
8. 仅输出稳定的 `owned` 或 `not_owned:<reason>` 结果并使用明确 exit status；不得修改 Git 或文件系统。

Verifier 必须在每次 `git worktree remove` 紧前调用。`whole-run discard` 在最终用户确认后沿用既有规则再次执行完整身份快照和 verifier；任何变化返回 `discard_blocked`。

### 4. 正常 Completion 与 whole-run discard 行为

- Dev Cadence 本地 Merge 或普通 Completion cleanup：只有 verifier 返回 `owned` 才进入既有 Step 6 删除命令。返回 `not_owned` 时保留 worktree，同时保留仍被该 worktree 引用的 task branch，明确报告未执行 cleanup；已成功的 merge 结果不被伪装成 cleanup 成功。
- Dev Cadence `whole-run discard`：只有 verifier 返回 `owned` 才允许 worktree 进入既有删除集合。缺失或冲突返回现有 `discard_blocked`，不增加新持久化状态。
- 非 Dev Cadence caller：本 Story 不扩展其上下文或菜单；现有 ordinary 行为保持不变。Dev Cadence caller 不得在 verifier 失败后回退到 `.worktrees/`/`worktrees/` 路径推断。
- PR 与 Keep 继续保留 worktree，不新增无意义的 ownership 验证。
- 删除 Dev Cadence-owned worktree 时，active run records 可随 worktree 删除；不归档、不创建 cleanup/audit 记录，也不新增清理结果字段。

### 5. 错误处理与保守语义

稳定失败原因至少区分：`missing_evidence`、`not_created_by_run`、`invalid_workspace_path`、`worktree_not_found`、`ambiguous_worktree`、`path_mismatch`、`branch_mismatch`、`head_mismatch`、`creation_lineage_mismatch` 和 `unsupported_worktree_state`。

所有失败都必须 fail closed：

- verifier 不删除任何对象；
- normal cleanup 保留 worktree 与相关 task branch；
- whole-run discard 返回 `discard_blocked`；
- 不通过二次路径推断自动升级为 owned；
- 日志可在当前会话解释原因，但不得形成 cleanup/audit 持久化记录。

## 受影响边界

预计实现文件：

- `src/workflows/using-dev-cadence/SKILL.md`：创建/复用判定、exact handoff 与路由前验证。
- `src/workflows/feature-dev/SKILL.md`
- `src/workflows/bug-fix/SKILL.md`
- `src/workflows/refactor/SKILL.md`：对称 manifest schema、manifest-only 来源和 Completion handoff。
- `src/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`：normal/discard 共用门禁、失败后的 worktree/branch 保留语义。
- `src/vendor/superpowers/skills/finishing-a-development-branch/scripts/verify-worktree-ownership.sh`：只读 verifier。
- `tests/finishing-worktree-ownership-contract.sh`：真实临时 Git worktree fixture 和允许/拒绝矩阵。
- `tests/work-item-development-workflow-contract.sh`：入口 evidence handoff 契约。
- `tests/workflow-symmetry.sh`：三个 Delivery workflow 对称 schema 与传递契约。
- `tests/run-all.sh`、`tests/package-contract.sh`、`tests/install-contract.sh`：测试接入、分发和安装验证。
- `version`：`0.29.1` -> `0.30.0`。

不修改：

- `README.md`、`README.zh-CN.md`：安装接口和用户菜单未变化。
- `src/vendor/superpowers/RELEASE-NOTES.md`：这不是完整 vendor 版本升级。
- `scripts/build.sh`：现有递归复制已覆盖新增脚本。
- `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`：它验证 Delivery record 完整性，不应成为实时 Git worktree ownership 判定所有者。
- `docs/stories/S-030-worktree-ownership-detection.md` 和 `docs/backlog.md`：当前阶段不改变已确认业务定义或生命周期状态。

## 关键约束

- 不新增 skill；finishing 保持 cleanup ownership 的唯一所有者。
- 不直接编辑 `.dev-cadence/**` 或 `dist/.dev-cadence/**`。
- 不把配置目录、目录名称、路径前缀或 worktree-enabled 状态当作 ownership 证据。
- 不把 immutable Creation HEAD 与 mutable current HEAD 直接等值比较。
- 不使用 stage record 作为 manifest 创建证据的备选来源。
- 不改变 merge、discard、branch delete 的具体命令；只控制是否允许到达现有删除路径。
- 不归档 active run records，不新增 cleanup/audit 记录，不持久化清理结果。
- 所有清理前验证必须紧邻 destructive command，并在用户最终确认后重新验证。
- feature-dev、bug-fix、refactor 的同类 manifest 和 Completion 规则必须结构及措辞对称。

## 测试策略

遵循 TDD，在实现规则前先增加失败测试：

- 动态 verifier fixture：本次创建的默认目录 worktree 通过；自定义项目内目录 worktree 通过。
- 失败矩阵：created flag 缺失/`no`、路径冲突、branch ref 冲突、current HEAD 冲突、creation ancestry 冲突、外部或复用 worktree、detached/locked/prunable 状态全部返回 `not_owned`，并验证 worktree 仍存在。
- 共享消费契约：静态断言 normal Dev Cadence cleanup 与 `whole-run discard` 都调用同一 verifier，且 Dev Cadence 失败不得回退到目录推断。
- 入口契约：验证 create 与 reuse 分流、creation tuple 捕获和下游 handoff 发生在路由前。
- workflow 对称性：三个 Delivery workflow 都要求同一 manifest schema、manifest-only 来源和 Completion 参数。
- 包验证：build 后 source/dist tree 一致，新增 verifier 存在且 executable；安装 fixture 中脚本存在并与 source 相同。
- 完整回归：`bash scripts/check-whitespace.sh` 与 `bash scripts/check-all.sh`。

## 验收标准到验证策略映射

| 验收标准 | 验证策略 |
| --- | --- |
| AC1：删除资格由 manifest 创建证据与实时 Git identity 决定 | 动态 owned fixture + normal/discard 共用 verifier 契约 + 禁止 Dev Cadence 路径推断断言。 |
| AC2：证据缺失或 path/branch/Git identity 冲突时不删除 | 动态 missing/path/ref/HEAD/ancestry 失败矩阵；每个 case 验证 `not_owned` 且 worktree registration 仍存在。 |
| AC3：自定义 worktree 目录保持有效 | 在非 `.worktrees`/`worktrees` 的项目内自定义目录创建真实 worktree并验证 `owned`。 |
| AC4：外部、历史或无法证明来源的 worktree 不删除 | `Created By Current Run: no`、复用既存和 unsupported state fixtures 验证 fail closed。 |
| AC5：normal Completion 与 whole-run discard 不归档或新增 cleanup 记录 | workflow/finishing 静态契约验证只控制删除门禁；反向断言不新增 archive、cleanup/audit 或结果持久化字段。 |
| AC6：权威规则与自动化契约覆盖完整矩阵 | 新动态 contract test、入口 contract、workflow symmetry、package/install checks 与完整 `check-all`。 |

## Open Questions

- 无阻塞 Open Question。
- 已收敛决定：current identity 由 finishing 在运行时冻结，不写回 immutable creation tuple；Creation HEAD 只通过 ancestry 约束参与验证。
- 已收敛决定：verifier 归属现有 finishing skill，而不是新增 shared skill 或扩展 delivery-record validator。

## 阶段决定

- Status: ✅ `confirmed`
- User Confirmation: `confirmed: user selected option 1 at 2026-07-20T21:37:43+0800`
- 下一阶段：进入 Implementation Plan。计划确认前不创建 verifier，不修改 workflow 源规则、测试或版本号。
