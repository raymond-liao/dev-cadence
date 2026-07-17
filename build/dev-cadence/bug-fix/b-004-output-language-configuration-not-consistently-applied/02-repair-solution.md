# B-004 Repair Solution

## Status

🔄 `in_progress`

## Confirmed Diagnosis

The target repository's `.dev-cadence.yaml` is a local ignored file. Git worktree creation copies committed content but not this configuration, so a new worktree or a recovered session can observe a missing config and silently use the English fallback. The repair must preserve one resolved configuration identity across checkout changes and session continuation.

## Repair Objective

When a workflow starts with `output_language: zh-CN`, every later worktree, stage, and resumed session in that workflow must continue using the same resolved configuration. A genuinely missing or unsupported configuration must remain on the documented English fallback path and make that fallback visible.

## Candidate Approaches

### Option A: Propagate the Local Config Into Each Worktree

After creating or entering a project-local worktree, copy the target checkout's `.dev-cadence.yaml` into the worktree when it exists, then verify the file and resolved values before generating records. On recovery, the worktree-local config remains the first source.

Advantages: preserves the existing config-file contract, keeps each worktree self-contained, and directly addresses the observed failure. Risks: the propagation owner must be explicit; changing vendored worktree instructions would expand the vendored-copy scope, while duplicating the rule across workflows increases maintenance.

### Option B: Capture And Reuse A Workflow Configuration Snapshot

Resolve the target config before isolation, record the selected language and relevant configuration identity in the workflow manifest, and require every later stage and resumed session to reuse that snapshot instead of treating a missing worktree file as English.

Advantages: makes session recovery auditable and avoids copying the whole local config. Risks: ignored build records may not be available in a freshly created worktree, and a snapshot can become stale when the user intentionally changes configuration during a run.

### Option C: Make The Config A Tracked Repository File

Remove the ignore rule and require `.dev-cadence.yaml` to travel through Git with the repository.

Advantages: Git worktrees inherit the file automatically. Risks: conflicts with the existing machine-local configuration contract, may expose personal preferences, and changes repository policy beyond this bug's intended behavior.

## Recommended Boundary

❓ `Decision Pending`: use Option A as the primary repair, with a minimal resolved-language identity recorded for continuation and diagnostics. Keep Option C out of scope. The implementation should be Dev Cadence-owned; modifying the vendored Superpowers copy is only justified if the shared worktree procedure is the sole practical propagation point and the user accepts that vendored-scope expansion.

## Likely Change Surface

- `src/skills/using-dev-cadence/SKILL.md`: define stable configuration identity and continuation behavior.
- `src/skills/feature-dev/SKILL.md`, `src/skills/bug-fix/SKILL.md`, and `src/skills/refactor/SKILL.md`: require configuration verification after worktree setup and visible fallback handling.
- `src/skills/discovery/SKILL.md`, `src/skills/architecture-design/SKILL.md`, `src/skills/work-item-planning/SKILL.md`, and `src/skills/work-item-analysis/SKILL.md`: align all user-visible output surfaces with the selected language where applicable.
- Contract tests: verify source rules, propagation instructions, fallback visibility, and package synchronization without asserting translation wording.
- `version`: evaluate a release increment because the installed workflow behavior changes.

## Regression Scope

- Main checkout with `output_language: zh-CN`.
- Newly created project-local worktree with the same config.
- Resumed workflow from the worktree.
- Missing config and unsupported language fallback, including visible explanation.
- `en` and `zh-CN` across Delivery and Asset workflow user-facing outputs.
- Exact machine-readable paths, IDs, commands, and canonical statuses remain unchanged.

## Acceptance Criteria

1. A configured `zh-CN` workflow does not silently switch to English after worktree creation or recovery.
2. The selected configuration source and resolved language are identifiable at each continuation boundary.
3. Missing or unsupported config continues to use English and reports why.
4. Existing workflow stages, confirmation gates, record models, paths, IDs, commands, and status enums remain unchanged.
5. Contract checks fail when propagation, fallback visibility, or workflow language coverage is removed.

## User Decision Needed

Please confirm whether the recommended Option A plus a minimal language identity snapshot is the intended repair boundary. Do not enter Repair Plan or implementation until this decision is confirmed.
