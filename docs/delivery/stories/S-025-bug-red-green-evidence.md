# S-025 Bug RED/GREEN 证据

## 基本信息

- ID：`S-025`
- Version：`2`
- Status：`Done`
- Priority：`P2`
- Change Type：Feature

## 目标

为 Bug 修复建立稳定 proof ID，将修复前失败、关联修改和修复后通过证据闭环；无法直接复现时记录替代因果证据和原因。

## 背景

仅记录最终测试通过无法证明修复针对原始缺陷。稳定的 RED/GREEN 证据可以连接问题复现、修复边界和验证结果，同时允许不可直接复现的问题使用明确的替代证据。

## 角色、场景和价值

- 角色：执行 Dev Cadence `bug-fix` workflow 的交付负责人。
- 场景：Bug 已在 Problem Diagnosis 中形成足够明确的问题边界，随后需要记录修复前证据、修复改动与最终验证之间的对应关系。
- 价值：业务验收和后续维护能够判断每个修复验收点是否真正针对原始缺陷，而不是只看到无来源的最终通过结果。

## ✅ 范围

- 为每个可独立验证的缺陷主张分配一个稳定 proof ID；一个 Bug 可以有 `1..n` 个 proof ID，proof ID 不按单份证据、单次命令、单个 commit 或单个测试用例拆分。
- proof ID 使用所属 Bug 卡片 ID 派生的 `B-nnn-P-nn` 格式。
- 在 `01-problem-diagnosis-record.md` 于问题边界形成后创建 proof ID，并记录 RED 证据，或记录无法直接复现时的替代因果证据、原因和局限。
- 在 `03-repair-plan.md` 记录同一 proof ID 的计划 RED/GREEN 检查；在 `04-repair-record.md` 记录实际证据、关联实现 commit 与 Changed Files；在 `05-regression-test-report.md` 记录关联的 `RV-*` 测试、Coverage 和验证结论。
- manifest 只维护简短 Proof Index：每个 proof ID 使用稳定 Markdown heading anchor，并链接到上述阶段记录中的源证据；其他阶段记录链接该 anchor，不复制证据正文。
- 可直接复现时，RED 与 GREEN 必须使用同一 proof ID。无法直接复现时必须明确标记 RED 不可获得，保留替代因果证据、原因和局限；不得伪造 RED。

## ❌ 非范围

- 不要求所有 Bug 都必须新增自动化测试。
- 不用推测性说明替代可获得的复现证据。
- 不决定替代因果证据是否足以通过 Problem Diagnosis，也不定义根因诊断门禁。
- 不在 manifest 或其他阶段记录中复制诊断、计划、实施或验证证据正文。

## 可观察行为与业务规则

1. 一个 Bug 中每个可独立验证的缺陷主张都有一个 `B-nnn-P-nn`；该 ID 可被同一主张的 RED/替代证据、修复改动和 GREEN/最终验证共同引用。
2. RED、实现 commit、Changed Files、GREEN 和 `RV-*` 是 proof ID 的关联证据，不各自创建 proof ID。一个证据确实同时支持多个独立主张时，必须显式引用每个相关 proof ID。
3. `01-problem-diagnosis-record.md`、`03-repair-plan.md`、`04-repair-record.md` 和 `05-regression-test-report.md` 各自维护本阶段产生的证据；manifest Proof Index 只提供 stable anchor 和导航链接。
4. 无法直接复现不会被写成已经执行的 RED。该 proof ID 必须保留替代因果证据、无法复现的原因和局限；本 Story 只记录已获得的诊断结论，不判定该证据是否充分。

## 验收标准

1. 每个可独立验证的缺陷主张恰有一个 `B-nnn-P-nn`，一个 Bug 的多条独立主张可分别使用 `1..n` 个 proof ID；单份证据、单次命令、commit 或测试用例不会单独生成 proof ID。
2. 可复现 Bug 的 `01-problem-diagnosis-record.md`、`03-repair-plan.md`、`04-repair-record.md` 和 `05-regression-test-report.md` 能以同一 proof ID 追溯 RED、计划检查、实际修复改动、GREEN 与 `RV-*` 最终验证。
3. `04-repair-record.md` 中每个 proof ID 的实现关联可追溯到实际 commit 和 Changed Files，`05-regression-test-report.md` 能以同一 ID 关联 Coverage 与验证结论。
4. 无法直接复现时，`01-problem-diagnosis-record.md` 明确标记 RED 不可获得，并记录替代因果证据、原因和局限；后续记录不得把该情形表述为已执行的 RED。
5. manifest Proof Index 为每个 proof ID 提供稳定 anchor 与阶段记录链接；阶段记录只链接该 index 和自身源证据，不复制其他阶段的证据正文。

## 已确认决策

- [Q-014 proof ID 跨阶段字段名称和最小格式](../open-questions.md#q-014)：每个可独立验证的缺陷主张使用 `B-nnn-P-nn`；proof ID 由 `01-problem-diagnosis-record.md` 创建，阶段记录保留源证据，manifest 仅维护 Proof Index 导航。

## 相关文档

- [Backlog](../backlog.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-14 | legacy: recorded-by unknown | 创建 Bug RED/GREEN 证据 Story。 | 建立修复前失败与修复后通过之间的稳定追溯链。 |
| 2 | 2026-07-21T15:21:48+0800 | Raymond Liao <raymond-liao@outlook.com> | 明确 proof ID 粒度、格式、跨阶段证据位置和 manifest Proof Index 契约。 | 使每个可独立验证的缺陷主张都能稳定追溯 RED/替代证据、修复改动和最终验证。 |
| 2 | 2026-07-21T15:21:48+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Ready。 | 用户已确认 Story 定义、范围、验收标准和 Q-014 决策。 |
| 2 | 2026-07-24T15:18:05+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 In Progress。 | 用户明确请求开始实施 S-025。 |
| 2 | 2026-07-24T15:21:03+0800 | Raymond Liao <raymond-liao@outlook.com> | 状态更新为 Done。 | 实现已集成；完整契约、安装和分发同步验证通过。 |
