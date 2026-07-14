# 实施计划

## Task Overview

| Task | Goal | Files | Verification |
|---|---|---|---|
| Task 1 | 建立 RED 对称契约 | `tests/workflow-symmetry.sh` | 测试因缺少 freshness gate 失败 |
| Task 2 | 实现三个对称门禁 | `src/skills/*/SKILL.md`; `docs/workflows/*.md` | symmetry 测试通过 |
| Task 3 | 同步安装包并完整验证 | `version`; `.dev-cadence/**`; `dist/**` | `bash scripts/check-all.sh` |

## Detailed Tasks

- [x] 添加门禁、输入身份、返回层级、superseded 和无关变化放行断言。
- [x] 在 Feature、Bug Fix、Refactor 实现入口前加入对称规则。
- [x] 更新用户可见 workflow 说明并将版本升至 0.11.0。
- [x] 构建、安装 dogfood 并运行完整检查。
