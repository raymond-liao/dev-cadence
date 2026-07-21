# S-018 Delivery 终态映射与 Manual Recovery - 需求确认

## 工作项身份

- 工作项：[S-018 Delivery 终态映射与 Manual Recovery](../../../../docs/stories/S-018-business-acceptance-terminal-mapping.md) (`docs/stories/S-018-business-acceptance-terminal-mapping.md`)
- 工作项类型：`Story`
- 工作项 Version：`4`
- 当前 Status：`In Progress`
- selected scope：为 `feature-dev`、`bug-fix` 和 `refactor` 建立一致、可审计的业务验收终态与例外 manual recovery 路径，并扩展对应记录验证和契约测试。
- Backlog 投影：[Backlog](../../../../docs/backlog.md) (`docs/backlog.md`)，`进行中`，Version `4`，Status `In Progress`。

## 目标

让三个 Delivery workflow 的每项 Business Acceptance 决定都进入明确且不混淆的后续路径；当已接受的 run 因不可在当前 run 内恢复的 Completion 阻断无法正常收尾时，保留足够证据和责任信息，以 `abandoned` 明确结束，而不伪造成功或遗留 `pending` 终态。

## ✅ 范围

- 保持 Business Acceptance 的三项固定决策枚举不变，并为 `accepted`、`rejected`、`accepted_with_risk` 分别定义可观察的 manifest 状态和后续动作。
- 让 `accepted` 与 `accepted_with_risk` 都进入既有正常 Completion；只有实际集成结果才可把整体状态改为 `integrated`。
- 要求 `accepted_with_risk` 逐项保留稳定风险引用、说明和后续责任；后续 `integrated` 不得抹去原业务验收决定或风险事实。
- 要求 `rejected` 记录拒绝理由，依据理由返回最早受影响的业务阶段；理由不足以定位返工阶段时，停在 Business Acceptance 请求澄清，且不进入 Completion 或报告成功。
- 仅为已经 `accepted` 或 `accepted_with_risk`、且正常 Completion 已有不可恢复 Git、分支、worktree、权限或外部环境阻断证据的 run 定义 manual recovery。
- 要求 manual recovery 在 `abandoned` 前记录阻断证据、至少一次失败恢复尝试、继续恢复不可行的原因、用户明确确认、代码/分支/worktree/run 记录的保留状态、后续责任与下一步；终态不得包含 `pending` 阶段或 checkpoint。
- 修改权威 `src/` workflow、record validator 和对称契约测试，并通过构建同步忽略的 `dist/.dev-cadence/`；不直接编辑分发包。

## ❌ 非范围

- 不改变 Business Acceptance 的决策枚举，也不替用户选择验收结果、Completion 动作或 manual recovery。
- 不将仍可正常恢复的失败、验证或 Review 失败、普通返工、未完成验收或用户请求 discard 伪装为 manual recovery。
- 不处理 Bug `not-a-bug` 的专属终态。
- 不修改具体 merge、discard 或 worktree 命令，也不删除人工恢复所需证据。
- 不新增 workflow、work-item 状态或长期业务资产，不修改 `src/vendor/superpowers/skills/**`。

## 验收标准

1. 三种 Business Acceptance 决策在三个 Delivery workflow 中具有明确、互不混淆且对称的后续行为。
2. `accepted` 与 `accepted_with_risk` 都进入正常 Completion；若完成实际集成，manifest 与业务验收记录仍能识别原验收决定，且后者保留每项风险引用、说明和责任人。
3. `rejected` 不进入 Completion、不报告成功、不成为 `integrated`；理由充分时回到最早受影响阶段，理由不足时留在 Business Acceptance 澄清。
4. 只有已接受 run 的正常 Completion 因不可恢复的 Git、worktree、权限或外部环境阻断，并有失败恢复尝试和用户明确确认时，才可形成 `abandoned`。
5. `abandoned` 的记录包含阻断、尝试、用户确认、资产保留、后续责任和下一步，并且 manifest 没有 `pending` 阶段或 checkpoint。
6. 可恢复失败、验证或 Review 失败、普通返工、未完成验收和 discard 不能绕过正常路径进入 manual recovery。
7. 契约测试覆盖三种决策映射、风险保留、拒绝回退、允许及禁止的 manual recovery 条件、`abandoned` 最小记录，以及三个 workflow 的对称性。

## 业务规则

- `accepted` 和 `accepted_with_risk` 表示业务验收决定；`integrated` 只表示 Completion 的实际集成结果，二者必须可同时追溯。
- `rejected` 是返工信号而非 Completion 输入。拒绝理由必须可映射到最早受影响阶段，否则不能猜测并继续。
- manual recovery 是完成正常 Completion 的例外关闭路径，不是实现、验证、Review、验收或 discard 的替代流程。
- `abandoned` 是有完整人工恢复交接证据的终态；它不得丢失 run、代码、分支或 worktree 的保留事实，也不得保留 `pending` 终态字段。
- 三个 Delivery workflow 对同一终态规则使用对称约束；validator 与契约测试必须验证该不变量，而非只匹配单一 workflow 的措辞。

## 假设与 Open Questions

- 假设：S-018 Version 4 已经由工作项分析确认，可作为本次 Requirements Confirmation 的权威输入。
- 假设：现有 Business Acceptance、Completion、manifest、业务验收记录和 delivery-record validator 可增量扩展，不需要新增 workflow 或独立 work-item。
- Open Questions：无需求级阻塞问题。具体字段位置、失败分类衔接、测试 fixture 和最小实现拆分由 Technical Solution 决定。

## 直接依赖输入身份

| Path | SHA-256 | 使用方式 |
| --- | --- | --- |
| docs/stories/S-018-business-acceptance-terminal-mapping.md | 3405669a6c06a40151f004f21301f996b3eee38ab7a0f0a379976fcd16b1c3d0 | Story Version `4`、Status `In Progress`；本次交付的权威需求和验收来源。 |
| docs/backlog.md | 5710f74571f0a1d6acd3727e676709f017a2141211a2bf23488836bfbda94c30 | 验证 S-018 已从 `待处理` 原子领取到 `进行中`。 |
| .dev-cadence.yaml | 9ba610320f36b3d0b18536daa896113584f7b6be679b1a6f118b8232516dc83b | 固定 `zh-CN`、隔离 worktree 与 `.worktrees` 目录。 |
| src/workflows/feature-dev/SKILL.md | 1f8bd64de73addf361d2d531d8783956862d80db66ef00780bdb052c3ad52279 | Feature Delivery 的当前验收和 Completion 基线。 |
| src/workflows/bug-fix/SKILL.md | 31849c6d1efcd13679072728b18c4fb6447b59d253879c42ee98587f2017c15e | Bug Fix 的当前验收和 Completion 基线。 |
| src/workflows/refactor/SKILL.md | 76ed1580dd0958b1f8e8358deedff6142a5c38625b34ecc29f14dbdd1836629c | Refactor 的当前验收和 Completion 基线。 |
| src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh | 12a0faba9aaf3ef3f7880b0405601e2dadfe41ebd926affcaf84e2fce868df2d | 现有 manifest 终态和 checkpoint 验证基线。 |
| tests/delivery-record-contract.sh | 8c9a531746c521f95dda66678d629b6197ed5d3d70b2a2ba8af62e78d4e36bbd | 终态记录 fixture 的可执行验证基线。 |
| tests/workflow-symmetry.sh | 2a75802a7bc0886380d170f0fe102885b4a323c68ee54b744bd9a03aa716dd4d | 三个 Delivery workflow 对称性验证基线。 |

## 阶段决定

- Status: 🔄 `in_progress`
- Prior Confirmation: superseded because the direct-input table encoded both paths and SHA-256 values as Markdown code; validator-readable fields are raw values. Requirements scope and input identities are unchanged.
- User Confirmation: `pending`。修复后的记录需要重新确认后才可开始 Technical Solution。
- 下一阶段：Requirements Confirmation；Technical Solution、Implementation Plan 和代码修改均已停止。
