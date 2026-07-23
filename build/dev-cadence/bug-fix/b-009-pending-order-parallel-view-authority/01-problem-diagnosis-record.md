# B-009 Problem Diagnosis

- Workflow: `bug-fix`
- Work Item: [B-009 待处理排序与并行视图职责不一致](../../../../docs/delivery/bugs/B-009-pending-order-parallel-view-authority.md)
- Status: ✅ `confirmed`
- Branch: `codex/fix-b009-pending-order-authority`
- Diagnosis date: `2026-07-18`

## Reported Symptom

同一份 `docs/backlog.md` 同时用 `待处理` 行顺序和 `当前可并行实施表` 的独立序号表达下一工作项；并行表还逐行复制 `下一步 Workflow / 入口门禁`，使 Backlog 维护了 workflow 路由的第二份来源。

## Expected Behavior

`待处理` 从上到下是唯一权威的建议实施顺序。并行表只能依据该顺序和 Dependency Table 形成派生视图，保持工作项相对顺序并补充并行关系。首项不能推进时，必须先通过 Work Item Planning 确认并调整顺序，不能静默跳过。并行表中的状态只表达生命周期，workflow 路由由 `using-dev-cadence` 和对应 workflow skill 判断。

## Actual Behavior

在基线 `6e18954624df1f45f9afd9141191b002605b724` 中，`待处理` 首项为 `S-041`；并行表仍使用自己的 `序号`，并包含 `B-009`、`S-041`、B-005/B-007/B-008 等不同的独立分组顺序。并行表列中还存在 `下一步 Workflow / 入口门禁`，逐行复制了路由和入口门禁语义。

领取提交已将 B-009 移到 `进行中`，本诊断不重复或修改该领取状态。

## Reproduction

1. 打开 `docs/backlog.md`。
2. 读取 `待处理` 表的行顺序，再读取 `当前可并行实施表` 的工作项顺序。
3. 比较两个视图的第一项和相对顺序。
4. 检查并行表的表头和逐行内容是否包含 `下一步 Workflow / 入口门禁`。
5. 对照 `src/skills/work-item-planning/SKILL.md` 的 `Parallel Work View Contract`。

在实现 RED 契约后，以下命令均按预期失败：

```text
FAIL: missing backlog pending order authority in src/skills/work-item-planning/SKILL.md
FAIL: missing derived pending order in src/skills/work-item-planning/SKILL.md
```

## Impact Scope

- Work Item Planning 的 Backlog 结构、排序和并行视图契约。
- `docs/backlog.md` 的并行视图展示和 AI 读取结果。
- S-017 中按 Backlog 继续实施时的领取顺序定义。
- source skill、安装构建生成的 `dist/.dev-cadence` 和契约验证。

## Root Cause And Confidence

根因已确认：规则只规定了 `待处理` 顺序的保留，却没有声明它是所有候选视图的唯一权威；同时旧规则明确把并行表视为不可重排的独立表，并将 workflow 入口字段纳入并行表。Backlog 示例和契约测试因此把两个责任混在一起。证据来自源规则第 `Parallel Work View Contract` 和 `Backlog And Planning Relationships`，以及基线 Backlog 的表头、行顺序和逐行门禁文本。置信度：高。

## Open Questions And Assumptions

- 无未决业务问题；用户委派已确认删除逐行 Workflow 列、保持状态为生命周期语义，并协调 S-017。
- 本次只修正规则、示例、契约和分发版本，不实现完整工作项领取能力，也不改变 B-005/B-007/B-008 历史状态。
