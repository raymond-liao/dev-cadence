# S-042 技术方案

## 已确认需求来源

- [S-042 需求确认记录](01-requirements.md) (`build/dev-cadence/feature-dev/s-042-primary-subagent-delegation/01-requirements.md`)，已于 `2026-07-20T09:41:17+08:00` 确认。
- [S-042 Dev Cadence 全流程主执行子代理委派](../../../../docs/stories/S-042-dev-cadence-primary-subagent-delegation.md) (`docs/stories/S-042-dev-cadence-primary-subagent-delegation.md`)，Version `1`。

## 代码库探索发现

### 入口与角色边界

- `src/skills/using-dev-cadence/SKILL.md:8-10` 将所有被派发的子代理一概排除在入口 Skill 外，因此无法让一个子代理成为完整任务的主执行者。
- 同一文件 `:24-30` 要求在探索前选择 workflow，正好提供主会话在加载具体 workflow 前委派的边界。
- `:210-223` 已定义基于 Delivery manifest 或 Asset 权威资产的续跑规则，可作为主执行子代理失效后的恢复依据。
- `:62-72` 已规定受 Dev Cadence 管理的提交和子任务 brief 的约束；主执行子代理继续派发会提交的普通子任务时必须沿用这些约束。

### 已安装 Workflow 与终态门禁

- `src/skills/discovery/SKILL.md:8-10` 和 `src/skills/architecture-design/SKILL.md:8-10` 同样以“任何子代理停止”阻断完整委派；其余已安装 workflow 没有该 guard。
- `src/skills/feature-dev/SKILL.md:729-784`、`src/skills/bug-fix/SKILL.md:688-743`、`src/skills/refactor/SKILL.md:772-827` 已明确：委派不得生成、暗示或选择 Business Acceptance 或 Completion 决定。这些规则应保留，主执行子代理只能把选项与证据交回主会话。

### 分发与安装验证

- `scripts/build.sh:10-17` 会把 `src/skills` 整树复制至 `dist/.dev-cadence/skills`；不应直接编辑 `dist/`。
- `scripts/install.sh:21-34` 会先构建，再通过 staging 目录替换目标仓库安装包。
- `tests/package-contract.sh:84-87` 已验证 source 和 dist 的每个 Skill 文件一致；`tests/install-contract.sh:20-55` 已验证安装结果，可扩展为主执行委派相关 Skill 的直接一致性检查。

## 方案比较

### 方案 A：只修改入口 Skill

在入口中允许被派发子代理选择 workflow，不修改其他文件。

- 优点：改动最少。
- 缺点：Discovery 与 Architecture Design 仍会因为自己的 `SUBAGENT-STOP` 提前退出，不能覆盖全部已安装 workflow。
- 结论：❌ Rejected。无法满足 S-042 的全流程覆盖标准。

### 方案 B：集中委派协议加角色特定 guard

在 `using-dev-cadence` 定义三种角色和完整任务的委派/回传协议；把 Discovery 与 Architecture Design 的粗粒度子代理停止标记改成仅针对“普通子任务代理”的 guard。使用现有续跑规则、确认门、Git 门禁和构建/安装机制，不新增 workflow、Skill、配置项或脚本。

- 优点：入口是唯一委派所有者；覆盖 Asset 与 Delivery workflows；最小地消除两个阻塞 guard；不复制路由或终态规则。
- 缺点：主执行子代理身份通过平台调度 brief 传递，平台未提供内部子代理时只能执行 fallback。
- 结论：✅ Confirmed。用户于 `2026-07-20T10:04:40+08:00` 确认采用。

### 方案 C：把委派规则复制到每个 workflow

为每个已安装 workflow 写入相同的主会话、主执行子代理与普通子任务代理规则。

- 优点：单独阅读任一 workflow 时能看到完整说明。
- 缺点：多处所有者会造成路由、恢复和授权边界漂移，且每次新增 workflow 都要手动同步。
- 结论：❌ Rejected。违背入口 Skill 的单一跨流程路由责任。

## 推荐方案

✅ Confirmed：采用方案 B。

### 执行模型

1. 主会话读取 `using-dev-cadence` 后，若平台明确支持内部子代理且当前会话不是已指定的主执行子代理，则在读取候选 workflow 或探索仓库前委派完整任务。
2. 委派 brief 指定主执行子代理角色，携带原始用户目标、活跃任务续跑上下文和必要的提交约束；普通子任务 brief 必须显式标记为非主执行角色。
3. 主执行子代理读取同一入口 Skill，选择或恢复 workflow，连续执行调查、草拟、改动、测试、Review、验证、记录和既有授权范围内的 Git 操作；可继续派发边界明确的普通子任务。
4. 需要用户决定、用户输入阻塞或任务终态时，主执行子代理只交回当前结论、完整选项、选项影响、风险与证据路径。主会话展示这些内容并将用户回应交回原主执行子代理；其不可用时，新的主执行子代理按现有 Asset/Delivery 续跑证据恢复。
5. 未确认草稿可以使用临时或缓存位置，并显式标记为非权威；权威资产、Business Acceptance、Completion 以及 merge、PR、push、discard、分支删除的用户授权边界不变。
6. 平台不具备内部子代理能力时，主会话照现有 workflow 直接执行。

### 受影响文件

- `src/skills/using-dev-cadence/SKILL.md`：将通用停止标记替换为角色特定 guard，并新增入口拥有的主执行委派、回传、恢复、普通子任务和 fallback 规则。
- `src/skills/discovery/SKILL.md`：使主执行子代理可执行 Discovery，而普通子任务代理仍停止。
- `src/skills/architecture-design/SKILL.md`：同样细化其子代理 guard。
- `tests/routing-contract.sh`：锁定入口前委派、三角色边界、回传内容、恢复与 fallback，以及不加载具体 workflow 的要求。
- `tests/install-contract.sh`：锁定安装结果中的入口、Discovery 和 Architecture Design guard 与 source 一致。
- `README.md`、`README.zh-CN.md`：说明支持时的主执行委派与不支持时的 fallback，作为安装包用户可见行为说明。
- `version`：从 `0.26.5` 升至 `0.27.0`，反映可安装包新增行为。
- `dist/.dev-cadence/` 和当前 `.dev-cadence/`：由构建和安装生成，不直接编辑。

### 测试策略

- 先扩展现有 `tests/routing-contract.sh`，让旧规则缺少角色区分和委派协议时失败。
- 扩展 `tests/install-contract.sh`，验证首次安装和覆盖安装均含与 source 一致的三处关键 Skill。
- 实施后运行 focused contracts、`bash scripts/build.sh`、`bash scripts/check-whitespace.sh` 与 `bash scripts/check-all.sh`。
- 用 `rg --no-ignore` 验证 source、dist 和安装包均含关键规则；安装契约覆盖临时目标仓库。

## 风险与约束

- 平台能力必须是实际存在的内部子代理调度能力；本改动不模拟或实现缺失平台能力。
- 委派变更执行位置而非决策所有权；固定 Business Acceptance/Completion 菜单和所有 Git 授权仍必须由用户触发。
- 角色识别依赖调度 brief 的明确标记；契约测试将锁定此标记和普通子任务的非递归边界。
- source 文件修改会影响可安装包，因此必须构建、安装并提升版本；`dist/` 保持忽略状态。

## 阶段状态

✅ `confirmed`。用户于 `2026-07-20T10:04:40+08:00` 确认方案 B；尚未修改源规则，下一阶段为 Implementation Plan。
