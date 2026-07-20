# S-029 Feature 持久化记录契约 - 技术方案

## 已确认需求来源

- [S-029 需求确认](01-requirements.md) (`build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract/01-requirements.md`)
- Requirements SHA-256: `c2d7bf764276a6fad74c48a504c8182d0fc071423c5e0ffbbdbd27622cd35729`
- Requirements Confirmation: 用户于 `2026-07-20T17:08:18+0800` 选择“确认当前版本并进入 Technical Solution”。

## Codebase Exploration Findings

### 1. Feature-dev 记录与恢复边界

- 关键文件：`src/workflows/feature-dev/SKILL.md:189-232`、`src/workflows/feature-dev/SKILL.md:305-365`、`src/workflows/feature-dev/SKILL.md:413-427`。
- 既有模式：manifest 已是 run index，Stage Table 已持有阶段状态、artifact、用户确认和 checkpoint；Requirements、Technical Solution 和新鲜度门禁都有既定职责。
- 缺口：没有已确认 Requirements/Solution 的路径与内容身份表，也没有恢复时按连续确认阶段验证并返回最早阶段的可执行步骤。
- 约束：不重建 Delivery record model；恢复身份验证必须与实施前新鲜度门禁分离，不能用记录摘要替代当前输入检查。

### 2. 可执行验证与 fixture 模式

- 关键文件：`src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh:55-160`、`tests/delivery-record-contract.sh:22-57`、`tests/delivery-record-contract.sh:236-318`。
- 既有模式：shell validator 从 manifest Stage Table 解析状态、artifact 和 checkpoint；fixture test 用临时 Git 仓库创建记录与提交，并断言成功或精确失败原因。
- 缺口：通用 validator 以全流程/终态证据为中心，不能表达“只有 Requirements 已确认是正常状态”或 feature 专属的记录字段和输入漂移判定。
- 约束：不把 feature 专属恢复规则扩散到 Bug Fix 或 Refactor，也不让记录文件存在本身等价于用户确认。

### 3. 分发与测试装配

- 关键文件：`scripts/build.sh:4-19`、`scripts/check-all.sh:4-10`、`tests/run-all.sh`、`docs/stories/S-029-feature-persistent-record-contract.md:25-61`。
- 既有模式：构建从 `src/workflows/**` 复制到忽略的 `dist/.dev-cadence/**`；`check-all` 先构建、再执行所有 shell 契约测试。
- 约束：权威实现必须写入 `src/`，不能直接编辑 `dist/`；测试必须作为 `tests/run-all.sh` 的一部分运行，且覆盖 Story 列出的真实恢复 fixture。

### 已阅读的必要文件

1. `docs/stories/S-029-feature-persistent-record-contract.md`
2. `build/dev-cadence/feature-dev/s-029-feature-persistent-record-contract/01-requirements.md`
3. `src/workflows/feature-dev/SKILL.md`
4. `src/workflows/using-dev-cadence/SKILL.md`
5. `src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh`
6. `tests/delivery-record-contract.sh`
7. `tests/run-all.sh`
8. `scripts/build.sh`
9. `scripts/check-all.sh`

## 备选方案

### 方案 A：仅补充 feature-dev 文本契约

- 优点：改动最少。
- 缺点：无法执行真实恢复 fixture，无法可靠发现摘要、字段或阶段矛盾回归。
- ❌ Rejected：不满足 S-029 的可执行契约测试验收标准。

### 方案 B：扩展通用 `validate-delivery-record.sh`

- 优点：复用既有 parser 与 validator 入口。
- 缺点：该脚本服务 feature-dev、bug-fix 和 refactor；把 feature-only 的 records、阶段名和恢复语义注入通用脚本会改变非范围 workflow 的契约并增加路由歧义。
- ❌ Rejected：不符合本 Story 的 feature-only 边界。

### 方案 C：新增跨 workflow 的共享恢复 capability

- 优点：理论上可供三个 Delivery workflow 复用。
- 缺点：当前仅 S-029 有独立目标与验收；Bug Fix/Refactor 的记录名称、确认语义和恢复规则尚未确认。共享 capability 会先于复用需求创建竞争所有者。
- ❌ Rejected：不满足 skill 准入与拆分原则。

### 方案 D：feature-dev 专属恢复校验脚本与契约测试

- 优点：沿用现有 manifest、Stage Table、阶段记录、构建和临时 Git fixture 模式；只对 feature-dev 生效；可用确定性脚本验证记录、SHA-256、连续确认阶段、checkpoint 或 `skipped` 身份，以及直接输入漂移。
- 缺点：新增一个 feature-dev 所属脚本和一个测试文件；未来 Bug Fix/Refactor 若有相同需求，需在确认复用前重新评估共享能力。
- Recommendation：这是最小且可验证的实现路径，等待用户确认后成为选定方案。

## 推荐实现设计

### 记录模型扩展

在 `src/workflows/feature-dev/SKILL.md` 的 manifest 规则中新增 `Confirmed Stage Record Identities` 表。该表只为已确认的 Requirements Confirmation 和 Technical Solution 保存：

| Stage | Record Path | SHA-256 |
| --- | --- | --- |
| Requirements Confirmation | `<repository-relative 01-requirements.md>` | `<lowercase SHA-256>` |
| Technical Solution | `<repository-relative 02-technical-solution.md>` | `<lowercase SHA-256>` |

- Stage Table 继续是用户确认与 checkpoint 的唯一运行事实；身份表不复制正文、不保存确认身份、确认时间或 checkpoint。
- `01-requirements.md` 的最小字段固定为工作项路径、类型、Version、Status、selected scope、目标、✅ 范围、❌ 非范围、验收标准、业务规则、假设、Open Questions、直接依赖输入身份。
- 直接依赖输入身份使用仓库相对路径与 SHA-256；这使恢复脚本能区分“已确认记录仍完整”和“当前输入已经漂移”。
- `02-technical-solution.md` 的最小字段固定为 requirements 路径与 SHA-256、已选方案与理由、备选方案或权衡及取舍理由、受影响边界、关键约束、Open Questions、验收标准到验证策略的映射。

### 恢复判定

新增 `src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh RUN_DIR`，仅进行只读验证并输出一个确定的 `Recovery Target` 与原因：

1. 读取 manifest 的 Stage Table；只接受从 Requirements Confirmation 起连续的 `confirmed` 前缀。后续阶段出现 `confirmed` 而先序阶段未确认时，返回最早不一致阶段。
2. Requirements 未确认时，返回 `Requirements Confirmation`，不要求两份阶段记录存在。
3. Requirements 已确认、Technical Solution 未确认时，验证 requirements 的 identity 表路径、SHA-256、最小字段和直接输入身份；通过后返回 `Technical Solution`。缺少 solution 文件在此状态是正常的。
4. Technical Solution 已确认时，先执行 requirements 验证，再验证 solution 路径、SHA-256、最小字段以及它引用的同一 requirements 路径与 SHA-256；通过后返回 `Implementation Plan`。
5. 对有 Git hash 的 checkpoint，验证该 checkpoint tree 含有相同路径的阶段记录；对于 `skipped` checkpoint，继续以 manifest SHA-256 验证工作区记录。任一记录问题都返回最早受影响阶段。
6. 当工作项或直接依赖输入 SHA-256 与 requirements 中已确认身份不符时，返回 `Requirements Confirmation`；当前 workflow 仍在进入实施前按既有新鲜度门禁复核影响范围。

该脚本不修改 manifest、不创建阶段记录、不选择 workflow，也不接受或替代用户确认。

### Workflow 接入

在 `src/workflows/feature-dev/SKILL.md` 添加恢复说明：恢复未完成的 feature-dev run 时，先读取 manifest 并执行该脚本；按输出目标恢复阶段，且在进入实施前仍执行既有 Pre-Implementation Design Freshness Gate。补充 Requirements 和 Technical Solution 的记录字段，以及确认后更新 manifest identity 表的时机与 SHA-256 计算方法。

### 测试设计

新增 `tests/feature-persistent-record-recovery-contract.sh` 并由 `tests/run-all.sh` 调用。该测试在临时 Git 仓库中创建真实 manifest、阶段记录、依赖输入和 checkpoint，覆盖：

| 验收标准 | Fixture / 验证 |
| --- | --- |
| 1-3 | 断言 source workflow 明确要求 identity 表与两种记录的最小字段；valid fixture 验证路径和 SHA-256。 |
| 4 | requirements-only 返回 `Technical Solution`；两阶段确认返回 `Implementation Plan`。 |
| 5 | 分别覆盖缺字段、摘要不符、solution 引用不符、manifest 阶段矛盾、工作项或依赖输入漂移，并断言最早恢复阶段。 |
| 6 | 一组 fixture 使用实际 checkpoint commit tree；另一组使用 `skipped: no tracked changes`，两者均验证成功。 |

## 受影响边界

- 修改：`src/workflows/feature-dev/SKILL.md`。
- 新增：`src/workflows/feature-dev/scripts/validate-persistent-record-recovery.sh`。
- 新增：`tests/feature-persistent-record-recovery-contract.sh`。
- 修改：`tests/run-all.sh`。
- 生成：`dist/.dev-cadence/workflows/feature-dev/**`，由 `bash scripts/build.sh` 同步，不提交。
- 不修改：`src/workflows/bug-fix/**`、`src/workflows/refactor/**`、`src/vendor/superpowers/**`、README、Story 定义和 Backlog。

## 关键约束与风险

- SHA-256 必须只使用仓库相对路径；记录中不得持久化本机绝对路径。
- 解析必须明确识别 canonical stage status，不能从文件存在、非空内容或 checkpoint 是否存在推断用户确认。
- `skipped` checkpoint 没有 Git tree 可查，因此记录内容 SHA-256 与输入身份仍是必要证据。
- 直接输入漂移的最早阶段可能由业务语义细化；本 Story 的默认保守返回点是 Requirements Confirmation，既有新鲜度门禁仍在进入实施前作最终分类。

## Open Questions

- 无。未来若 Bug Fix 或 Refactor 提出等价恢复需求，应按 skill 准入规则重新评估共享能力，不在本 Story 预先抽象。

## 验收标准到验证策略映射

| 验收标准 | 验证策略 |
| --- | --- |
| 1 | fixture 读取 manifest identity 表，验证已确认阶段路径与 SHA-256，且断言 manifest 未包含 requirements/solution 正文标记。 |
| 2 | source contract assertion 与有效 requirements fixture 的最小字段校验。 |
| 3 | source contract assertion 与有效 solution fixture 的 requirements 引用、SHA-256 和最小字段校验。 |
| 4 | requirements-only 与 requirements-plus-solution fixture 的 `Recovery Target` 断言。 |
| 5 | 每种无效 fixture 断言最早恢复阶段与明确失败原因。 |
| 6 | checkpoint-commit 与 `skipped: no tracked changes` fixture 各自通过；新测试纳入 `tests/run-all.sh`，并运行 `bash scripts/check-all.sh`。 |

## 阶段决定

- Status: 🔄 `in_progress`
- Recommendation: 方案 D，feature-dev 专属恢复校验脚本与契约测试。
- Decision: ❓ Decision Pending，等待用户确认；在确认前不写 Implementation Plan 或 workflow 代码。
