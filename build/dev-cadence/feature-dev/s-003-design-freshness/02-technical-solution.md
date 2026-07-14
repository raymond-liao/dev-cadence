# 技术方案

- Requirement Source: `build/dev-cadence/feature-dev/s-003-design-freshness/01-requirements.md`
- Confirmation: delegated by user launch instruction.

## ✅ Selected: 对称 workflow 内嵌门禁

在三个 Delivery skill 的实现阶段入口前加入同结构规则，分别映射到 Requirements/Diagnosis、Solution 和 Plan 阶段。门禁记录卡片、阶段文档、计划、代码、权威资料和依赖身份；无关变化直接放行，失效时标记后续证据为 superseded。

## ❌ Rejected: 只在 using-dev-cadence 中定义

入口无法访问各 run 的阶段名称和记录职责，会造成规则不可执行。

## ❌ Rejected: 只依赖 Git diff

无法覆盖产品设计、Decision、依赖状态和卡片版本变化。

## Testing

扩展 `tests/workflow-symmetry.sh`，对三份 source skill 验证相同门禁能力；完整构建验证 source、dist、dogfood 一致。
