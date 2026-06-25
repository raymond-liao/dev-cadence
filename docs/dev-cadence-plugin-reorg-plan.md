# `dev-cadence` Codex 发布结构重组计划

**目标**：将当前 `dev-cadence` 从“单个 Skill 外壳”调整为 root-level Codex Plugin 源码组织方式，并同步优化用户仓库契约。

> 状态提示：本文是历史重组计划，记录的是 root-level Plugin 迁移过程。当前发布 Skill 目标结构已迁移为 `using-dev-cadence` + `cadence-*`，以 [Dev Cadence 目标形态方案草案](dev-cadence-target-model.md) 和 [Dev Cadence 路线图](dev-cadence-roadmap.md) R8 为准。

**核心决策**：

- 本仓库是 `dev-cadence` 的源码仓库，当前优先支持 Codex Plugin 发布形态，不使用 `plugins/dev-cadence/` 作为开发目录。
- Plugin manifest 放在仓库根目录 `.codex-plugin/plugin.json`。
- 发布用 skills 放在仓库根目录 `skills/*`，共享资源放在仓库根目录 `references/`、`templates/`、`scripts/`。
- 用户仓库默认不创建 `.ai/`。仓库契约只包含 `AGENTS.md`、`.gitignore`、`specs/` 和可选的根目录 `.dev-cadence.yaml`。
- `.dev-cadence.yaml` 是本地覆盖配置，默认加入 `.gitignore`；默认配置由 `dev-cadence` 自身管理。
- `specs/` 是运行时生成目录，不作为源码仓库长期追踪内容。
- `research/` 是探索过程目录；稳定结论沉淀到 `docs/`。

## 目标目录

```text
dev-cadence/
  .codex-plugin/plugin.json
  skills/
    dev-cadence-init/
    dev-cadence-deliver/
    dev-cadence-maintain/
    dev-cadence-authoring/
  references/
  templates/
    spec/
    runs/
    prompts/
  scripts/
  docs/
```

## 执行计划

- [x] **任务 1：更新框架定位文档**
  - 修改 `README.md`、`docs/plugin-skill-modularization.md`、`docs/skill-authoring-prespec.md`。
  - 明确 Dev Cadence 近期交付形态是 Codex Plugin。
  - 明确 Core 是长期抽象，不在本轮实现多平台 adapter。
  - 明确目录结构采用 root-level publishing layout。

- [x] **任务 2：迁移目录结构**
  - 将 `skills/dev-cadence/skills/*` 移到根目录 `skills/*`。
  - 将 `skills/dev-cadence/references/` 移到根目录 `references/`。
  - 将 `skills/dev-cadence/templates/` 移到根目录 `templates/`。
  - 将 `skills/dev-cadence/scripts/` 移到根目录 `scripts/`。
  - 移除旧的外层 `skills/dev-cadence/SKILL.md` 和 `skills/dev-cadence/agents/openai.yaml` 包装层。
  - 保持各 Skill 内部 `agents/openai.yaml`。

- [x] **任务 3：新增 Codex Plugin manifest**
  - 新增 `.codex-plugin/plugin.json`。
  - 发布包不包含 hooks，避免安装确认和会话启动噪音。

- [x] **任务 4：改造用户仓库契约**
  - 修改 `scripts/sync-repo-contract.mjs`。
  - 停止创建 `.ai/config.yaml`、`.ai/local.yaml`、`.ai/overrides/.gitkeep`。
  - 初始化或修复时只处理 `AGENTS.md`、`.gitignore`、`specs/.gitkeep` 和可选 `.dev-cadence.yaml`。
  - `.gitignore` 只添加 `.dev-cadence.yaml`。
  - `AGENTS.md` 只负责把普通交付工作路由到 `dev-cadence`。

- [x] **任务 5：更新 Skill 与 reference 路径**
  - 更新 `skills/*/SKILL.md` 中的相对引用。
  - 更新 `references/*.md` 中关于 `.ai/`、旧 package 路径、旧脚本路径的描述。
  - 更新 `templates/**` 中引用旧路径或旧配置位置的内容。
  - 保持发布用 Skill 内容为英文。

- [x] **任务 6：更新验证脚本与验收文档**
  - 修改 `scripts/check-skill-package.mjs` 以验证 root-level publishing layout。
  - 修改 `scripts/check-discipline-routes.mjs` 的路径假设。
  - 修改 `docs/acceptance-guide.md`、`AGENTS.md` 中的命令路径。
  - 不依赖仓库根目录下的历史 `specs/**` 运行证据。

- [x] **任务 7：验证与提交**
  - 运行：
    - `node scripts/check-skill-package.mjs .`
    - `node scripts/check-discipline-routes.mjs .`
    - `node scripts/check-spec-artifacts.mjs templates`
    - `node scripts/sync-repo-contract.mjs init --repo-dir "$(mktemp -d)"`
  - 检查 `git diff`。
  - 使用 Conventional Commit 提交。

## 不做事项

- 不引入多平台 plugin adapter。
- 不修改用户仓库中的产品代码。
- 不把 `.dev-cadence.yaml` 设计成默认提交文件。
- 不批量重写旧验收记录。
- 不恢复 `.ai/` 目录作为默认契约。
