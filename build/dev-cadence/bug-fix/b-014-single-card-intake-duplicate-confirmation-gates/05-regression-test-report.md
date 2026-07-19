# B-014 回归测试报告

- Workflow: `bug-fix`
- Work Item: [B-014 单项建卡被错误套用双确认门](../../../../docs/bugs/B-014-single-card-intake-duplicate-confirmation-gates.md)
- Repair Record: [B-014 修复记录](04-repair-record.md)
- Status: ✅ `confirmed`

## Verification Scope

验证 Direct Intake 单一正式确认、必要澄清边界、Portfolio Planning 双确认门、命名子集原子写入语义、source/dist 同步和全量仓库回归。

## Commands And Results

- `bash tests/work-item-planning-contract.sh`: ✅ `passed`
- `bash tests/confirmation-gates-contract.sh`: ✅ `passed`
- `bash tests/package-contract.sh`: ✅ `passed`
- `bash tests/install-contract.sh`: ✅ `passed`
- `bash scripts/check-whitespace.sh`: ✅ `passed`
- `bash scripts/check-all.sh`: ✅ `passed`
- `bash scripts/build.sh`: ✅ `passed`; source/dist 模式分支和门禁语义一致

## Decision

✅ `passed`. Direct Intake 只有一个正式结果确认，Portfolio Planning 双门保持不变，必要卡片与 Backlog 引用仍为原子单元；未发现残余回归风险。
