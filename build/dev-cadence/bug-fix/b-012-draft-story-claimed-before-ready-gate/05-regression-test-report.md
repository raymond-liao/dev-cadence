# B-012 回归测试报告

- Workflow: `bug-fix`
- Work Item: [B-012 Draft Story 在 Ready 门禁前被提前领取](../../../../docs/bugs/B-012-draft-story-claimed-before-ready-gate.md)
- Repair Record: [B-012 修复记录](04-repair-record.md)
- Status: ✅ `confirmed`

## Verification Scope

验证入口领取顺序、Draft/Ready Story、Task、Bug 四场景门禁、source/dist 同步、安装包契约和全量仓库回归。

## Commands And Results

- `bash tests/work-item-development-workflow-contract.sh`: ✅ `passed`
- `bash tests/work-item-analysis-contract.sh`: ✅ `passed`
- `bash tests/work-item-planning-contract.sh`: ✅ `passed`
- `bash tests/routing-contract.sh`: ✅ `passed`
- `bash tests/package-contract.sh`: ✅ `passed`
- `bash tests/install-contract.sh`: ✅ `passed`
- `bash scripts/check-whitespace.sh`: ✅ `passed`
- `bash scripts/check-all.sh`: ✅ `passed`
- `bash scripts/build.sh`: ✅ `passed`; source/dist ordered intake matrix matches

## Decision

✅ `passed`. Draft Story cannot be claimed before explicit Ready confirmation; Ready Story, Task, and Bug qualification behavior remains covered. No residual regression risk was found within the confirmed scope.
