# 仓库指南

## 仓库身份

- 本仓库是 Dev Cadence 源码仓库，不是安装后的目标仓库。
- Dev Cadence 是面向 AI 编程代理的软件交付治理规则包，核心资产是 workflow skill、安装片段、构建脚本和 vendored Superpowers 副本。
- 本仓库中的规则用于生成可安装的 `.dev-cadence` 包；目标仓库运行时配置和交付记录不属于 `.dev-cadence` 源码包。

## 目录职责

- `src/workflows/using-dev-cadence/SKILL.md`：目标仓库中的工作流入口选择器。
- `src/workflows/feature-dev/SKILL.md`：功能开发工作流规则源文件。
- `src/workflows/bug-fix/SKILL.md`：Bug 修复工作流规则源文件。
- `src/workflows/refactor/SKILL.md`：保持行为不变的重构工作流规则源文件。
- `src/references/`：跨 workflow 复用的 contracts 与文档约定。
- `src/AGENTS-snippet.md`：安装到目标仓库根 `AGENTS.md` 的片段，不等同于本仓库自己的 `AGENTS.md`。
- `src/.dev-cadence.example.yaml`：目标仓库运行时配置示例。
- `src/vendor/superpowers/`：固定版本的 vendored Superpowers 副本。
- `dist/.dev-cadence/`：由 `bash scripts/build.sh` 生成的分发包，默认不要直接编辑。
- `scripts/install.sh`：构建并替换目标仓库中的 `.dev-cadence` 安装包。
- `build/`：Dev Cadence 工作流运行记录和短期执行产物。
- `docs/`：业务流程说明和设计资料；不要用它替代 workflow skill 的执行规则。

## 核心术语

- workflow：Dev Cadence 的业务交付流程，例如 `feature-dev`、`bug-fix` 和 `refactor`。
- stage：workflow 内的业务阶段，例如需求确认、技术方案、系统测试、业务验收。
- run manifest：一次 workflow 运行的索引文件，路径形如 `build/dev-cadence/<workflow>/<task-slug>/manifest.md`。
- stage record：某个阶段的持久化记录，例如 `03-implementation-record.md`、`04-system-test-report.md`。
- checkpoint commit：用户确认阶段输出后创建的 Git 检查点提交。
- target repository：安装并运行 Dev Cadence 的业务仓库。
- installed package：目标仓库中的 `.dev-cadence/` 目录。

## 修改入口

- 修改 feature 工作流时，优先改 `src/workflows/feature-dev/SKILL.md`。
- 修改 bug fix 工作流时，优先改 `src/workflows/bug-fix/SKILL.md`。
- 修改 refactor 工作流时，优先改 `src/workflows/refactor/SKILL.md`。
- 修改工作流入口选择规则时，改 `src/workflows/using-dev-cadence/SKILL.md`。
- 修改目标仓库接入说明片段时，改 `src/AGENTS-snippet.md`。
- 修改目标仓库默认配置示例时，改 `src/.dev-cadence.example.yaml`。
- 不要直接编辑 `dist/.dev-cadence/**`；需要同步分发包时运行构建脚本。
- 不要直接编辑 `src/vendor/superpowers/skills/**`，除非任务明确是更新 vendored Superpowers 副本。
- `README.md` 和 `README.zh-CN.md` 主要是产品与安装说明；只有用户明确要求更新文档，或行为变化影响安装/使用说明时才修改。

## 规则文档风格

- workflow skill 是执行规则的权威来源；不要用 README、聊天记录或 demo 记录替代执行规则。
- 规则应写成明确的操作约束，优先使用 `must`、`do not`、`when`、`before`、`after` 这类可执行表述。
- 阶段边界要清楚：哪些阶段需要用户确认、哪些记录必须存在、什么时候可以进入下一阶段。
- 记录文件路径要具体，优先使用仓库相对路径。
- 当 feature-dev、bug-fix 和 refactor 具有同类治理规则时，应保持结构和措辞尽量对称。
- 新规则应说明适用范围，避免把复杂流程强加给简单、低风险任务。

## Skill 准入与拆分原则

- 不以减少或增加 skill 数量为目标；每个新增 skill 都必须证明其独立职责带来的隔离、复用或安全收益高于新增路由、上下文加载、所有权协调和测试成本。
- 新增 workflow skill 时，必须同时具备独立用户目标、明确触发条件、自己的阶段或决策过程，以及独立的权威资产或交付证据所有权；另一个 workflow 的步骤、前置动作或状态同步不得单独提升为 workflow skill。
- 新增共享能力 skill 时，必须能够被多个独立调用者复用或由用户直接调用，并具有稳定的输入输出、独立的不变量以及明确的失败、幂等或补偿语义；如果既有 skill 已拥有该行为或资产，不得创建竞争所有者。
- 只有一个自然调用入口、所有者或使用场景的规则，优先保留在负责它的现有 skill 中。规则较长但仍属于同一职责时，拆为该 skill 按需读取的 supporting reference，而不是新增 skill。
- 确定性的检查、解析、同步和校验逻辑优先实现为所属 skill 的脚本；不要仅因为操作步骤较多就创建 skill。
- 新增 skill 前，必须盘点现有 workflow、共享能力、supporting reference 和脚本，说明为什么不能扩展或复用既有所有者。评审时应检查新 skill 是否只是转发到另一个 skill、复制既有契约或制造新的路由歧义。
- 当既有 skill 出现职责重叠、重复契约或调用边界不清时，使用同一准入标准重新评估；不要仅为减少数量合并具有独立用户目标和所有权的 skill。

## 讨论与规则设计边界

- 当用户要求分析、讨论、评估或继续收敛设计时，只进行只读分析；除非用户明确要求创建、修改、记录、建卡或实现，否则不要编辑文件、更新 Backlog、创建工作项或执行 Git 变更。
- 不要把用户在讨论中的可能性表达、举例、疑问或“可以”自动解释为实施授权。无法确定用户是否要求落盘时，继续讨论或询问一个必要的澄清问题。
- 一次只解决用户当前指定的问题。不要未经确认扩展到相邻 workflow、资产、状态模型、同步机制或治理规则。
- 明确区分已确认需求、用户提出的候选方向和代理建议。代理推断不得直接写成已确认规则，也不得以补充完整性为理由擅自增加约束。
- 规则优先写在负责该行为或资产的 workflow skill 中。新增 Story Map、Backlog、User Journey 或其他资产时，先定义其所有者、用途和维护方式；不要默认向所有既有 workflow skill 扩散“禁止修改该资产”的条款。
- 只有当既有 workflow 确实需要路由、读取、更新该资产，或已经存在需要移除的冲突行为时，才修改该 workflow；不要为了防御尚未发生的误用建立跨 workflow 黑名单。
- 用户质疑方案时，应说明原方案依据、暴露出的错误假设和修正后的最小结论；不要只用笼统的认同替代分析。
- 沟通过程中再次出现可能形成通用协作规则的类似问题时，先向用户说明拟增加的规则并确认是否更新本仓库 `AGENTS.md`；未经明确确认，不要自行修改 `AGENTS.md`。
- 状态模型应保持满足当前需求的最小集合。不要未经用户确认增加状态，也不要把 workflow 内部阶段、临时等待状态或实现细节自动提升为 Backlog、工作项卡片或其他上层资产的状态。

## 子代理协作边界

- “内部子代理”指隶属于当前会话、由平台子代理调度能力创建的委派执行单元；用户说“用子代理”“用子线程”或要求把实现交给子代理时，默认使用内部子代理，不创建侧边栏中的独立 Codex 任务。
- 内部子代理可以继承当前会话上下文，并在隔离工作区中执行明确、边界独立的任务；主代理仍保留 Dev Cadence 路由和门禁、用户确认、集成审查、最终验证、Git 集成和最终汇报责任。
- `create_thread` 这类独立 Codex thread 只用于用户明确要求创建另一个用户可见、可独立跟进的任务或会话；不得把它当作普通实现子任务的默认调度方式。
- 实施 `docs/backlog.md` 中的工作项时，在平台支持且任务边界可独立委派的情况下，优先由子代理执行已确认范围内的实现。
- 主代理保留 Dev Cadence 路由和门禁、用户确认、集成审查、最终验证、Git 集成和最终汇报责任；子代理可按已确认实施方法创建任务级进度提交，但不独立执行合并、push、业务验收或分支清理。
- 使用内部子代理不自动创建用户可见的新任务；只有用户明确要求独立 Codex thread 时才创建。

## 构建与验证

- 修改 `src/workflows/**`、`src/references/**` 或 `src/skills/**` 后，运行 `bash scripts/build.sh` 同步 `dist/.dev-cadence`。
- 根目录 `*.md` 和 `docs/**` 下的文件不要求新增或修改自动化测试；不要仅因这些文档变化而编写锁定自然语言措辞的测试。同一任务同时改变可执行行为时，只测试该可执行行为。
- 提交前运行 `bash scripts/check-whitespace.sh`。
- 提交前运行 `bash scripts/check-all.sh` 完成构建和契约验证。
- 如果修改了规则文本，应使用 `rg --no-ignore` 检查 `src/` 和 `dist/.dev-cadence/` 是否同步包含关键规则。
- `dist/` 被忽略；不要为了提交分发产物而强制添加它，除非用户明确要求。
- 如果只改本仓库 `AGENTS.md`，不需要运行构建脚本。
- 当修改会影响可安装 `.dev-cadence` 包、workflow 行为、安装片段、默认配置或用户可见交付规则时，提交前必须评估并更新根目录 `version`；如果决定不更新版本号，需要在最终说明中写明原因。

## Review 检查重点

- 是否把执行规则改在对应 workflow skill，而不是 README 或 demo 记录。
- 是否误改了 `dist/.dev-cadence/**` 而没有修改 `src/` 源文件。
- 是否误改了 `src/vendor/superpowers/**`。
- 修改 `src/workflows/**`、`src/references/**` 或 `src/skills/**` 后是否运行了 `bash scripts/build.sh`。
- 影响可安装包或 workflow 行为的修改是否同步更新了根目录 `version`，或明确说明不更新版本号的理由。
- feature-dev、bug-fix 和 refactor 中同类规则是否保持一致，差异是否有明确原因。
- manifest、stage record、review evidence、coverage、business acceptance 等记录要求是否闭环。
- 是否引入本机绝对路径、个人目录、临时 URL、token、密钥或其他不可移植信息。
- 是否把被 `.gitignore` 忽略的本地产物强制纳入提交。

## 记录与路径规则

- Dev Cadence 运行记录应使用仓库相对路径，不应持久化本机绝对路径。
- 仓库身份优先使用仓库名、origin URL、分支和 commit hash 表达。
- 工作区在主 checkout 时可记录为 `.` 或 `target repository root`。
- 项目内 worktree 应记录为 `.worktrees/<branch-or-task-slug>` 或 `worktrees/<branch-or-task-slug>`。
- `.superpowers/`、本地服务状态、visual companion server state 等运行状态不应作为正式阶段记录的唯一证据。

## Git 提交规则

- 提交信息使用 Conventional Commit，例如 `feat(flow): ...`、`fix(flow): ...`、`docs: ...`。
- 不要 push，除非用户明确要求。
- 不要修改历史或 amend，除非用户明确要求。
- 提交前确认只暂存与当前任务相关的文件。

## 禁止事项

- 不要把目标仓库的业务运行记录写进 `.dev-cadence/` 包内。
- 不要在未确认适用范围时把规则同时扩散到 feature-dev 和 bug-fix。
- 不要为了修 demo 个例而绕过 workflow skill 的规则源。
- 不要提交 `.dev-cadence.yaml`、`.env`、临时日志、服务 PID、个人路径或密钥。
