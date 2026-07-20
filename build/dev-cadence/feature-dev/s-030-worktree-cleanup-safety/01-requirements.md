# S-030 Worktree 清理安全与证据 - 需求确认

## 工作项身份

- 工作项：[S-030 Worktree 清理安全与证据](../../../../docs/stories/S-030-worktree-ownership-detection.md) (`docs/stories/S-030-worktree-ownership-detection.md`)
- 工作项类型：`Story`
- 工作项 Version：`4`
- 当前 Status：`In Progress`
- selected scope：以当前运行 manifest 的创建证据与实时 Git worktree 身份一致性决定清理资格；覆盖配置的自定义 worktree 目录、正常 Completion 与 `whole-run discard`，排除运行记录归档和清理结果持久化。
- Backlog 投影：[Backlog](../../../../docs/backlog.md) (`docs/backlog.md`)，`进行中`，Version `4`，Status `In Progress`。

## 目标

在 Dev Cadence 清理 task worktree 前，以可验证的当前运行创建来源和实时 Git 身份判定所有权，只允许删除由本次运行创建且验证一致的 worktree，避免目录命名推断导致误删外部工作区。

## ✅ 范围

- 当前运行的 manifest 保存 worktree 创建证据，至少包括仓库相对 workspace 路径、task branch ref、创建时 Git 身份和“由本次运行创建”的明确结论。
- 清理前读取当前运行 manifest 的创建证据，并与 `git worktree list --porcelain` 返回的实际路径、branch ref 和当前 Git 身份逐项验证。
- 清理资格由证据一致性决定，不依赖 `.worktrees/`、`worktrees/`、目录名称、branch 名称或其他路径约定。
- `.dev-cadence.yaml` 的自定义 worktree 目录使用同一证据模型和验证规则。
- manifest 创建证据缺失，或路径、branch ref、Git 身份任一缺失或冲突时，必须保留 worktree，并进入既有阻断或明确确认路径；不得将不一致降级为可自动删除。
- 外部管理、历史来源不明或无法验证为当前运行创建的 worktree 不属于 Dev Cadence 自动删除范围。
- 同一所有权验证规则适用于正常 Completion 清理和 Dev Cadence `whole-run discard` 清理。
- 修改权威 `src/` 规则与可执行契约测试，并通过构建同步忽略的 `dist/.dev-cadence/`；不直接编辑分发包。

## ❌ 非范围

- 不自动接管或补认历史上来源不明的 worktree。
- 不改变外部管理 worktree 的清理责任。
- 不保存、复制、迁移或归档 manifest、stage record 或其他 active run record；删除 Dev Cadence-owned worktree 时，源记录可随 worktree 一并删除。
- 不创建 cleanup、audit 或资源结果的持久化记录，也不要求 manifest 或业务验收记录新增清理结果字段。
- 不修改具体 merge 或 discard 命令。
- 不定义 detached HEAD 的完整 Finishing 路径。
- 不在本阶段决定具体规则文件、脚本接口、测试 fixture 或实现拆分；这些属于 Technical Solution 和 Implementation Plan。

## 验收标准

1. worktree 的删除资格由当前运行 manifest 创建证据与实时 Git worktree 路径、branch ref、Git 身份的一致性决定，而不是目录名称或路径约定。
2. manifest 证据或实时 Git 身份的路径、branch ref、Git 身份任一缺失或冲突时，Dev Cadence 不删除该 worktree，并进入既有阻断或明确确认路径。
3. 配置自定义 worktree 目录时，所有权识别和保守失败行为保持有效。
4. 外部管理、历史来源不明或无法验证为当前运行创建的 worktree 不会被 Dev Cadence 删除。
5. 正常 Completion 和 `whole-run discard` 均不归档 active run records 或创建 cleanup/audit 记录；删除 Dev Cadence-owned worktree 时，源记录可随 worktree 删除。
6. 权威源规则和自动化契约验证能够覆盖允许删除、证据缺失、三类身份冲突、自定义目录、外部 worktree，以及正常 Completion 与 `whole-run discard` 两条清理路径。

## 业务规则

- 当前运行 manifest 是创建证据的唯一权威来源；配置派生路径、目录位置、目录名称和独立元数据都不能单独证明所有权。
- “由本次运行创建”与“当前 Git 身份仍匹配”是两个必须同时成立的条件；任一条件无法证明时均保守保留 worktree。
- 实时身份检查必须来自 Git 的 worktree 枚举结果，不能只检查目录是否存在或 task branch 是否存在。
- 自定义 worktree 目录只改变 workspace 位置，不改变证据字段、比较维度或失败语义。
- 所有权验证只控制既有清理路径是否可以处理 worktree，不扩大 merge、discard、branch 删除或 detached HEAD 的业务范围。
- 运行记录保存与清理结果持久化已由 Story Version 4 明确排除，不得以“证据闭环”为由重新引入。

## 直接依赖输入身份

| Path | SHA-256 |
| --- | --- |
| docs/stories/S-030-worktree-ownership-detection.md | 57a6d5d324a2f60c4ee2de35a678dc7fbcee47e25bebda32d2ae92cd0b36f079 |
| docs/backlog.md | 3b881b8509bf70162528e1d0c7bc05cf8327041060843154eda598d584d6f632 |
| .dev-cadence.yaml | 9ba610320f36b3d0b18536daa896113584f7b6be679b1a6f118b8232516dc83b |
| .dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md | de8e5398ea7bb2fbe586df322e9d13a486b780984a4fc6e9a0fa8c736a866b24 |

### 输入用途

- [S-030 Worktree 清理安全与证据](../../../../docs/stories/S-030-worktree-ownership-detection.md)：Story Version `4`、Status `In Progress`；本次交付的权威需求来源与范围边界。
- [Backlog](../../../../docs/backlog.md)：验证 S-030 位于 `进行中`、Version `4`、Status `In Progress`。
- `.dev-cadence.yaml`：固定 `output_language: zh-CN`、`worktree.enabled: true` 和 `worktree.directory: .worktrees`。
- `.dev-cadence/vendor/superpowers/skills/finishing-a-development-branch/SKILL.md`：baseline commit `c340758`；提供现有 Completion 与 `whole-run discard` 清理行为，具体源修改归 Technical Solution 决定。

## 假设与 Open Questions

- 假设：Story Version 4 已完成工作项分析并由用户确认，可直接作为 Requirements Confirmation 的需求来源。
- 假设：现有 Completion 和 `whole-run discard` 的阻断、确认及删除路径可被增量加固，无需新增 workflow 或持久化资产。
- Open Questions：无需求级阻塞问题。具体比较规范、规则所有者和测试边界必须在 Technical Solution 中通过代码库探索确定。

## 阶段决定

- Status: ✅ `confirmed`
- User Confirmation: 用户于 `2026-07-20T21:04:26+0800` 选择“确认当前版本并进入 Technical Solution”。
- 下一阶段：Technical Solution。Implementation Plan 和代码修改仍需在后续阶段分别确认后才能开始。
