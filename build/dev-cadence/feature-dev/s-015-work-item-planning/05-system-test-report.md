# S-015 工作项规划 Workflow 与工作项契约：系统测试报告

## 状态

✅ `ready`

## Verification Commands

| Command | Result |
| --- | --- |
| `bash scripts/build.sh` | ✅ `passed` |
| `bash tests/work-item-planning-contract.sh` | ✅ `passed` |
| `bash tests/routing-contract.sh` | ✅ `passed` |
| `bash tests/asset-delivery-record-contract.sh` | ✅ `passed` |
| `bash tests/skill-description-contract.sh` | ✅ `passed` |
| `bash tests/package-contract.sh` | ✅ `passed` after `S015-T3-PKG-001` remediation |
| `bash scripts/check-whitespace.sh` | ✅ `passed` |
| `bash scripts/check-all.sh` | ✅ `passed` after `S015-T3-PKG-001` remediation |
| source/dist `cmp -s` for new skill and entry | ✅ `passed` |

## Acceptance Coverage

| S-015 criterion | Evidence |
| ---: | --- |
| 1-2 | New installed skill and central route cover Asset Workflow, portfolio planning, and direct intake. |
| 3 | Contract covers stable IDs, Version, Status, Relationships, Change Log, reuse, and conflict checks. |
| 4-5 | Skill and contract cover Story Map path, Offline/System backbone, Path, Milestone, MVP, and Feature order. |
| 6-8 | Discovery ownership, return-to-Discovery boundary, single-item non-expansion, and non-Delivery Story Map boundary are covered. |
| 9-10 | Shared card edits, status/version rules, proposal-only pre-confirmation, and atomic post-confirmation writeback are covered. |
| 11-12 | Handoff, source/dist sync, package, route, description, and full contract checks pass. |

## Residual Risks

- Business Acceptance was accepted by the user on 2026-07-16.
- This source repository does not contain actual target product-design baseline documents; the implementation defines rules only and does not claim a complete Story Map.
