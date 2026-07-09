# 仓库指南

## 仓库身份

- 本仓库是 Dev Cadence 源码仓库，不是安装后的目标仓库。
- Dev Cadence 是面向 AI 编程代理的软件交付治理规则包，核心资产是 workflow skill、安装片段、构建脚本和 vendored Superpowers 副本。
- 本仓库中的规则用于生成可安装的 `.dev-cadence` 包；目标仓库运行时配置和交付记录不属于 `.dev-cadence` 源码包。

## 目录职责

- `src/skills/using-dev-cadence/SKILL.md`：目标仓库中的工作流入口选择器。
- `src/skills/feature-dev/SKILL.md`：功能开发工作流规则源文件。
- `src/skills/bug-fix/SKILL.md`：Bug 修复工作流规则源文件。
- `src/AGENTS-snippet.md`：安装到目标仓库根 `AGENTS.md` 的片段，不等同于本仓库自己的 `AGENTS.md`。
- `src/.dev-cadence.example.yaml`：目标仓库运行时配置示例。
- `src/vendor/superpowers/`：固定版本的 vendored Superpowers 副本。
- `dist/.dev-cadence/`：由 `bash scripts/build.sh` 生成的分发包，默认不要直接编辑。
- `build/`：本地工作流产物或临时记录，默认不要提交。
- `docs/`：业务流程说明和设计资料；不要用它替代 workflow skill 的执行规则。

## 核心术语

- workflow：Dev Cadence 的业务交付流程，例如 `feature-dev` 和 `bug-fix`。
- stage：workflow 内的业务阶段，例如需求确认、技术方案、系统测试、业务验收。
- run manifest：一次 workflow 运行的索引文件，路径形如 `build/dev-cadence/<workflow>/<task-slug>/manifest.md`。
- stage record：某个阶段的持久化记录，例如 `implementation-record.md`、`system-test-report.md`。
- checkpoint commit：用户确认阶段输出后创建的 Git 检查点提交。
- target repository：安装并运行 Dev Cadence 的业务仓库。
- installed package：目标仓库中的 `.dev-cadence/` 目录。

## 修改入口

- 修改 feature 工作流时，优先改 `src/skills/feature-dev/SKILL.md`。
- 修改 bug fix 工作流时，优先改 `src/skills/bug-fix/SKILL.md`。
- 修改工作流入口选择规则时，改 `src/skills/using-dev-cadence/SKILL.md`。
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
- 当 feature-dev 和 bug-fix 具有同类治理规则时，应保持结构和措辞尽量对称。
- 新规则应说明适用范围，避免把复杂流程强加给简单、低风险任务。

## 构建与验证

- 修改 `src/skills/**` 后，运行 `bash scripts/build.sh` 同步 `dist/.dev-cadence`。
- 提交前运行 `git diff --check`。
- 如果修改了规则文本，应使用 `rg --no-ignore` 检查 `src/` 和 `dist/.dev-cadence/` 是否同步包含关键规则。
- `dist/` 和 `build/` 被忽略；不要为了提交分发产物而强制添加它们，除非用户明确要求。
- 如果只改本仓库 `AGENTS.md`，不需要运行构建脚本。

## Review 检查重点

- 是否把执行规则改在对应 workflow skill，而不是 README 或 demo 记录。
- 是否误改了 `dist/.dev-cadence/**` 而没有修改 `src/` 源文件。
- 是否误改了 `src/vendor/superpowers/**`。
- 修改 `src/skills/**` 后是否运行了 `bash scripts/build.sh`。
- feature-dev 和 bug-fix 中同类规则是否保持一致，差异是否有明确原因。
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
