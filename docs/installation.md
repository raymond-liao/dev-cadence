# Dev Cadence 安装

推荐把 Dev Cadence 提交到业务仓库的 repo-embedded runtime，让团队成员从同一份业务仓库 `AGENTS.md` 进入流程。全局 Plugin 或业务仓库 marketplace 可以以后再作为辅助分发方式；当前主路径不依赖 Skill 自动发现。安装后的验证、打包检查和 smoke test 见 [Dev Cadence 当前验证](validation.md)。

## 业务仓库内置 Runtime

先在 Dev Cadence 源码仓库生成 target-repo bundle：

```bash
cd /path/to/dev-cadence
node scripts/package-target-repo-bundle.mjs --clean
```

同步到业务仓库：

```bash
node scripts/sync-target-repo-bundle.mjs --target /path/to/your/product-repo
```

同步后的业务仓库形态：

```text
your-product-repo/
  AGENTS.md
  .gitignore
  .dev-cadence.yaml
  .dev-cadence/
    VERSION
    manifest.json
    skills/
    references/
    templates/
    scripts/
  specs/
    records/
      .gitkeep
```

提交业务仓库中的 `AGENTS.md`、`.gitignore`、`.dev-cadence/` 和 `specs/records/.gitkeep`。`.dev-cadence.yaml` 继续作为用户本地偏好文件，默认加入 `.gitignore`。默认 artifact language 是 `en`；用户可以在本地取消注释改成 `zh`。

业务仓库 `AGENTS.md` 的 Dev Cadence 段落会要求普通交付任务先读取 `.dev-cadence/skills/using-dev-cadence/SKILL.md`，并把 `skills/...`、`references/...`、`templates/...` 和 `scripts/...` 解析到 `.dev-cadence/` 下。

## 可选 Codex Plugin 安装

维护者仍可生成 Codex Plugin marketplace package：

```bash
node scripts/package-codex-plugin.mjs --clean
```

生成的本地 marketplace root 位于 `dist/codex/`。这条路径保留给全局 Plugin 或 marketplace 方案，不作为当前流程稳定启动的前提。

## 维护者本机安装

维护者需要验证当前源码包时，可以在 Dev Cadence 源码仓库运行：

```bash
./deploy-local.sh
```

该脚本会生成 `dist/codex/` 本地 marketplace package，注册 marketplace，并安装 `dev-cadence@dev-cadence-local`。这条路径只用于本机开发、调试和 smoke test；团队使用应优先通过业务仓库内置 runtime 分发。

不要把源码仓库根目录直接作为插件安装源；打包产物位于 `dist/codex/`。

## 本机卸载

移除本仓库发布包安装的插件：

```bash
codex plugin remove dev-cadence@dev-cadence-local
codex plugin marketplace remove dev-cadence-local
```

第一条移除已安装插件和本地 cache；第二条移除本机 marketplace source。

如果是业务仓库内置 marketplace，把 `dev-cadence-local` 替换为该业务仓库 `marketplace.json` 里的 `name`，例如：

```bash
codex plugin remove dev-cadence@dev-cadence-health
codex plugin marketplace remove dev-cadence-health
```
