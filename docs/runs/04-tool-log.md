# tool-log.md

## 目的

`tool-log.md` 记录工具调用、命令和关键日志索引，帮助审查 run 中实际执行过什么。

## 写入阶段

Harness run 执行期间持续记录，run 结束时完成。

## 写入者

Harness。

## 记录内容

- tool calls
- shell commands
- key output references
- errors or notable logs
- timestamps when available

## Gate 影响

当 claims 依赖命令、工具或外部操作时，`tool-log.md` 提供可审查证据。缺少必要 tool 证据会影响 G4、G5 或 Human Gate 判断。

## 如何阅读

用它核对 execution report 中的 claims 是否有对应命令或工具证据。
