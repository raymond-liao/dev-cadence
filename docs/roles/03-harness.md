# Harness

## 目的

Harness 是 Supervisor 和具体执行器之间的执行边界。它把一次 Agent run 变成可控、可审计、能产出证据的执行单元。

## 职责

- 装载 Agent Blueprint 和 Context Pack。
- 建立 workspace、sandbox、tool policy 和 permission policy。
- 记录 commands、tool use、logs、diff、tests 和 permission decisions。
- 产出 Harness 运行证据。

## 输入

- Harness Run Context。
- Context Pack。
- allowed / denied tools 或 paths。
- budget、timeout 和必需证据。

## 输出

- [run-context.md](../runs/01-run-context.md)
- [execution-report.md](../runs/03-execution-report.md)
- [tool-log.md](../runs/04-tool-log.md)
- 执行测试或命令时写 [test-log.md](../runs/05-test-log.md)
- 文件变更时写 [diff-summary.md](../runs/06-diff-summary.md)
- [permission-decisions.md](../runs/07-permission-decisions.md)

## 禁止事项

- 定义需求。
- 做架构决策。
- 作为语义负责人写业务代码。
- 判断最终完成。
- 替代 Reviewer 或 Human Gate approval。

## 升级条件

当权限、工具、环境或 policy 阻止安全执行时，Harness 记录 blocked 或 incomplete evidence 状态。

## 相关产物

- [05-implementation.md](../artifacts/05-implementation.md)
- [06-test-report.md](../artifacts/06-test-report.md)
- [07-review-report.md](../artifacts/07-review-report.md)
- [Runs](../runs/)
