#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$ROOT_DIR/dist/.dev-cadence"

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

cp "$ROOT_DIR/version" "$TARGET_DIR/version"
cp "$ROOT_DIR/src/config.md" "$TARGET_DIR/config.md"
cat > "$TARGET_DIR/README.md" <<'README'
# Dev Cadence

Dev Cadence 用来约束 AI 按固定流程处理功能开发请求。

## 接入方式

把 `.dev-cadence/AGENTS-snippet.md` 里的内容合并到仓库根目录的 `AGENTS.md`。

合并后，当用户提出功能开发请求时，AI 会先读取：

```text
.dev-cadence/skills/feature-dev/SKILL.md
```

具体流程、阶段顺序、确认节点和配套 skill 使用规则都由这个文件控制。

## 内容

- `version`: Dev Cadence 版本。
- `config.md`: Dev Cadence 配置。
- `AGENTS-snippet.md`: 需要合并到 `AGENTS.md` 的入口片段。
- `skills/feature-dev/SKILL.md`: 功能开发流程。
- `vendor/superpowers/skills/`: 固定版本的 Superpowers skills。

## 约定

- `.dev-cadence` 只放流程约束和依赖 skill。
- 需求、方案、计划、实施记录、测试报告和验收记录应写在项目自己的工作区，不要写入 `.dev-cadence`。
- 不直接修改 `vendor/superpowers/skills/`。需要升级时，从 Dev Cadence 源仓库重新构建。
README
cp "$ROOT_DIR/src/AGENTS-snippet.md" "$TARGET_DIR/AGENTS-snippet.md"
cp -R "$ROOT_DIR/src/skills" "$TARGET_DIR/skills"
cp -R "$ROOT_DIR/src/vendor" "$TARGET_DIR/vendor"
