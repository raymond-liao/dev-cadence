# B-004 `output_language` 中文配置未稳定生效

## 基本信息

- ID：`B-004`
- Version：`1`
- Status：`Done`
- Priority：`P1`
- Change Type：Bug

## 问题目标

修复 Dev Cadence 在 `.dev-cadence.yaml` 配置 `output_language: zh-CN` 时未稳定使用中文生成 workflow 文档、记录和用户可见阶段摘要的问题。

## 预期行为

当目标仓库根目录的 `.dev-cadence.yaml` 配置为：

```yaml
output_language: zh-CN
```

当前 workflow 应一致读取该配置，并将其要求生成的文档、记录和用户可见阶段摘要使用简体中文；不应因 workflow、worktree、会话恢复或记录类型不同而随机回退为英文。

## 已观察行为

用户观察到 `output_language: zh-CN` 在实际使用中经常不生效，部分 workflow 文档或阶段记录仍出现英文。当前卡片尚未完成逐阶段复现和根因诊断。

## ✅ 范围

- 追踪 `.dev-cadence.yaml` 的读取、解析和配置传递路径。
- 覆盖 workflow 阶段记录、manifest、报告和用户可见状态摘要的语言选择。
- 覆盖主 checkout、隔离 worktree 和会话恢复等可能改变配置读取位置的场景。
- 为已确认的配置生效边界增加最小回归检查。

## ❌ 非范围

- 不改变 `output_language` 支持的语言集合。
- 不重写现有中文文案或翻译质量。
- 不改变 workflow 阶段、确认门禁或记录模型。
- 不处理与语言配置无关的文档路径或模板问题。

## 验收标准

1. 配置为 `zh-CN` 时，所有受配置约束的 workflow 文档和用户可见摘要一致使用简体中文。
2. 主 checkout、worktree 和恢复运行时使用同一个目标仓库配置来源。
3. 配置缺失或不支持时仍按既定默认语言处理，并有可解释的结果。
4. 回归检查能够发现配置未被读取、读取了错误工作区配置或生成内容语言错误的情况。

## 已知复现条件

- 目标仓库存在 `.dev-cadence.yaml` 且设置 `output_language: zh-CN`。
- 执行 refactor 等需要生成 workflow 记录的流程时，部分输出仍使用英文。
- 具体失效阶段、工作区和配置读取路径待 Problem Diagnosis 阶段确认。

## 依赖

- 无强制前置依赖。

## Open Questions

- Q-002：哪些具体 workflow、阶段记录或用户可见摘要稳定复现语言回退？
- Q-003：失效时实际读取的是目标仓库配置、源仓库配置还是默认值？
- Q-004：worktree 和会话恢复是否改变了配置查找根目录？

## 相关文档

- [Backlog](../backlog.md)
- [Bug 修复流程](../../workflows/bug-fix.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | legacy: recorded-at precision unknown; original 2026-07-16 | legacy: recorded-by unknown | 创建 `output_language` 配置未稳定生效 Bug。 | 记录中文配置在 workflow 输出中经常未生效的问题，等待诊断。 |
| 1 | legacy: recorded-at precision unknown; original 2026-07-17 | legacy: recorded-by unknown | 交付完成，状态更新为 `Done`。 | B-004 已完成实现、回归验证、Business Acceptance 并合并到 `main`。 |
