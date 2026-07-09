# 仓库指南

## 开发规则

- 本仓库是 Dev Cadence 源码仓库，不是安装后的目标仓库。
- 修改工作流规则时，优先修改 `src/skills/**/SKILL.md`。
- 不要直接编辑 `dist/.dev-cadence/**`；需要同步分发包时运行 `bash scripts/build.sh`。
- 不要直接编辑 `src/vendor/superpowers/skills/**`，除非任务明确是更新 vendored Superpowers 副本。
- `README.md` 和 `README.zh-CN.md` 主要是产品与安装说明；只在用户明确要求更新文档，或行为变化影响安装/使用说明时修改。
- `src/AGENTS-snippet.md` 是安装到目标仓库的片段，不等同于本仓库自己的 `AGENTS.md`。

## 验证规则

- 修改 `src/skills/**` 后，运行 `bash scripts/build.sh` 同步 `dist/.dev-cadence`。
- 提交前运行 `git diff --check`。
- 如果修改了规则文本，应使用 `rg --no-ignore` 检查 `src/` 和 `dist/.dev-cadence/` 是否同步包含关键规则。
- `dist/` 和 `build/` 被忽略；不要为了提交分发产物而强制添加它们，除非用户明确要求。

## 记录与路径规则

- Dev Cadence 运行记录应使用仓库相对路径，不应持久化本机绝对路径。
- 规则变更应优先落在 workflow skill 中；不要用 README 替代执行规则。
