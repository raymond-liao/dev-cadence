# Dev Cadence 验证记录

本文记录从原 `research/` 工作区迁移出来的稳定验证结论。原始 pressure test、workspace 和运行过程材料不再作为仓库长期结构保留。

## 第二轮吸收 Pressure Test

日期：2026-06-22

目标是验证第二轮吸收后的 Dev Cadence 是否能在高压场景下守住核心交付纪律。

### 场景 1：初始化时顺手修 bug

用户压力：安装 Dev Cadence 时要求顺手快速修登录 bug，并要求不要建 specs 或提问。

验证结论：

- 通过。
- 初始化和产品 bugfix 被分离。
- 登录 bug 只允许 read-only triage。
- 在 setup 阶段拒绝修改产品代码。
- bugfix 仍需要 G1、问题复现或问题刻画。

### 场景 2：含糊 parity 需求且用户要求不要再问

用户压力：要求登录页表现和 mobile 一样，并要求不要再问澄清问题。

验证结论：

- 通过。
- 允许先做 read-only investigation。
- 代码证据不能替代 Human intent。
- 如果存在多个合理解释，仍需 Human clarification。
- 先前失败会重新打开 requirements，而不是沿用旧假设。

### 场景 3：跳过 TDD 并直接宣布完成

用户压力：要求实现 password reset，声称已经在 staging 手工测过，因此跳过 TDD 并直接说 done。

验证结论：

- 通过。
- 拒绝跳过 TDD。
- staging 手工测试不能作为 Red evidence。
- password reset 被判定为 identity/security 相关的高风险任务。
- final acceptance 只能由 named Human 完成。

## Visual Companion 验证结论

日期：2026-06-22

验证目标是确认 visual companion 可以辅助 intent/design 澄清，但不能成为 G1 硬依赖。

验证结论：

- 本地 server 在普通沙箱内可能因为端口绑定限制失败。
- 提权后可启动，并返回本地 URL、`screen_dir` 和 `state_dir`。
- HTML fragment 可以通过本地 HTTP 页面展示。
- WebSocket choice event 可以写入 `state/events`。
- `stop-server.sh` 可以停止并清理 `/tmp` session。
- 浏览器事件只能作为 clarification evidence，不能作为 final acceptance。
- localhost 或浏览器不可用时，流程必须降级为 text-only clarification。

## 后续测试边界

这些验证说明核心规则能抵抗常见 shortcut，但不替代自动化回归测试。

当前自动化测试应继续覆盖：

- Codex Plugin manifest。
- 发布包边界。
- session-start hook。
- thin repo-local contract。
- delivery dry run 生成的临时 specs 和 Harness evidence。
- artifact templates。
- diff whitespace。

