# Dev Cadence

Dev Cadence 是一套用于约束 AI 辅助功能开发的 workflow skill 包。

本仓库构建一个可复制到目标项目的 `.dev-cadence` 目录。第一版只覆盖 `feature-dev` 的乐观路径：

```text
需求确认 -> 制定技术方案 -> 制定计划 -> 开发实施 -> 系统测试 -> 业务验收
```

## 源码结构

```text
version
README.md
src/
  AGENTS-snippet.md
  skills/
    feature-dev/
      SKILL.md
  vendor/
    superpowers/
      LICENSE
      skills/
```

`src/vendor/superpowers/` 是 Dev Cadence 随仓库固定的 Superpowers 副本，避免外部 skill 后续变更影响验证结果。Superpowers 使用 MIT License，license 原文保留在 `src/vendor/superpowers/LICENSE`。

## 构建产物

```text
dist/
  .dev-cadence/
    version
    README.md
    AGENTS-snippet.md
    skills/
      feature-dev/
        SKILL.md
    vendor/
      superpowers/
        LICENSE
        skills/
```

## 构建命令

```bash
bash scripts/build.sh
```

构建脚本只删除 `dist/.dev-cadence`，不会删除整个 `dist`。

`dist/.dev-cadence/README.md` 是安装产物说明，由 `scripts/build.sh` 直接生成，不复制仓库根目录的 `README.md`。

## 复制到 Demo 项目

```bash
bash scripts/build.sh
cp -R dist/.dev-cadence /path/to/demo/.dev-cadence
```

复制后，需要把 `.dev-cadence/AGENTS-snippet.md` 中的 snippet 合并到目标仓库根目录的 `AGENTS.md`。
