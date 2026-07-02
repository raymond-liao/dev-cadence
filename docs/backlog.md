## Backlog

## User Experience Priorities

- [ ] P0 — 优化任务开始体验：在进入计划或执行前，AI 应主动给出简短的任务理解回显，帮助用户快速确认目标、范围、关键假设和会影响交付方向的问题；避免让用户填写重表单。
- [ ] P1 — 优化任务结束体验：形成稳定的交付摘要格式，让用户能快速看到完成内容、验证结果、未覆盖项、剩余风险和需要 Human 验收的内容。
- [ ] P2 — 优化报告体验：让 `specs/report/` 成为可读的 AI 交付记录入口，突出任务目标、当前状态、变更范围、验证证据、Review 结果、未覆盖项、剩余风险和 Human acceptance。
- [ ] P3 — 优化流程轻重感知：让 Dev Cadence 自动选择轻量或完整路径，并用一句话解释为什么当前任务需要对应程度的流程。
- [ ] P4 — 优化过程可见性：在长任务中提供简短阶段状态，例如当前阶段、已完成事项、下一步和阻塞点，避免暴露完整内部术语。
- [ ] P5 — 优化提问体验：少问开放式表单问题，多暴露 AI 的当前假设；优先询问会影响实现、验证或风险接受的关键问题。

- [ ] TDD 要求小步快跑，如果不加入 git commit，可能会出现一个任务一次做完产生太多变更：TDD、Subagent Development
- [ ] docs 需要进一步重构优化
- [ ] skill 中出现有些 skill 互相引用的情况，需要全面排查
- [ ] [cadence-request-code-review](../skills/cadence-request-code-review) 与期望严重不符
- [ ] [cadence-subagent-development](../skills/cadence-subagent-development) 能力缺失
- [ ] [cadence-debug](../skills/cadence-debug) 能力缺失
- [ ] [cadence-clarify](../skills/cadence-clarify) 可能需要进一步增强，以保证 AI 与用户的理解一致，保证后续产出正确
