# B-004 Repair Record

## Status

✅ `confirmed`

## Implementation Identity

- Implementation base SHA: `85e485e29546feec35b7e60c57cc2b77131d9d76`
- Final implementation SHA under review: `4cf27b4b93b573e662403b8ef3e0e3065a5bd6dd`
- Branch: `codex/b-004-output-language-configuration-not-consistently-applied`
- Workspace: `.worktrees/codex-b-004-output-language-configuration-not-consistently-applied`

## Completed Plan Tasks

- ✅ Task 1: Added the shared configuration propagation contract and Delivery Workflow references.
- ✅ Task 2: Aligned language coverage across Asset and Work Item workflows.
- ✅ Task 3: Added the ignored-config Git worktree fixture and registered the configuration contract test.
- ✅ Task 4: Bumped the package version to `0.22.0` and verified the rebuilt distribution package.

## Changed Files

- `src/skills/using-dev-cadence/SKILL.md`
- `src/skills/feature-dev/SKILL.md`
- `src/skills/bug-fix/SKILL.md`
- `src/skills/refactor/SKILL.md`
- `src/skills/discovery/SKILL.md`
- `src/skills/architecture-design/SKILL.md`
- `src/skills/work-item-planning/SKILL.md`
- `src/skills/work-item-analysis/SKILL.md`
- `tests/configuration-contract.sh`
- `tests/run-all.sh`
- `version`

## Reproduction And Repair Evidence

- A fresh B-004 worktree created from `main` initially had no `.dev-cadence.yaml`.
- The local `zh-CN` config was explicitly placed in the worktree for this run.
- The new fixture reproduces the Git behavior in a temporary repository: the ignored config is absent from the linked worktree, while `git rev-parse --path-format=absolute --git-common-dir` identifies the primary checkout containing the config.
- The repair adds a shared propagation rule, records the resolved language identity for Delivery continuation, and makes missing/unsupported fallback visible.

## Tests And Checks

- `bash tests/configuration-contract.sh` - ✅ `passed`
- `bash tests/workflow-symmetry.sh` - ✅ `passed`
- `bash tests/work-item-planning-contract.sh` - ✅ `passed`
- `bash tests/work-item-analysis-contract.sh` - ✅ `passed`
- `bash tests/run-all.sh` - ✅ `passed` after building the package
- `bash scripts/check-all.sh` - ✅ `passed` with package version `0.22.0`
- `git diff --check` - ✅ `passed`

## Executing-Plans Commit Review Ledger

Pre-commit review snapshots were not persisted before the first implementation commit. The entries below are therefore retrospective and use actual commit ancestry and tree identities; they do not claim pre-commit evidence.

| Review ID | Unit | Type | State | Expected parent | Reviewed tree | Commit | Committed parent | Committed tree | Identity | Checks | Findings |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `B004-impl-1` | `plan-task-1` | plan task | `verified` | `85e485e29546feec35b7e60c57cc2b77131d9d76` | `e2ec002a1ca98d80008e575a5c14f41d948a94bc` | `473116984f7f482a33e399dcc00587f9f677347f` | `85e485e29546feec35b7e60c57cc2b77131d9d76` | `e2ec002a1ca98d80008e575a5c14f41d948a94bc` | retrospective | configuration contract passed | None known |
| `B004-impl-2` | `plan-task-2` | plan task | `verified` | `473116984f7f482a33e399dcc00587f9f677347f` | `d028010e92061313af525ee9a98097e6f1a50c6b` | `2829dd74f52b24d33c36f762eaa70f9fb4761ad5` | `473116984f7f482a33e399dcc00587f9f677347f` | `d028010e92061313af525ee9a98097e6f1a50c6b` | retrospective | configuration, symmetry, planning, and analysis contracts passed | None known |
| `B004-impl-3` | `plan-task-3` | plan task | `verified` | `2829dd74f52b24d33c36f762eaa70f9fb4761ad5` | `5a21b905232fcb295aea3583bdad2a54997b955e` | `932e1d3edb950a85629eb1a7ae6674248c74384d` | `2829dd74f52b24d33c36f762eaa70f9fb4761ad5` | `5a21b905232fcb295aea3583bdad2a54997b955e` | retrospective | full `tests/run-all.sh` passed after package build | None known |
| `B004-impl-4` | `plan-task-4` | plan task | `verified` | `932e1d3edb950a85629eb1a7ae6674248c74384d` | `9c031b95fd3274201f6e96559e70606faeb48686` | `0623621194baf382a1a07e09ff198f7361e1f5f0` | `932e1d3edb950a85629eb1a7ae6674248c74384d` | `9c031b95fd3274201f6e96559e70606faeb48686` | retrospective | `bash scripts/check-all.sh` passed with `0.22.0` | None known |
| `B004-review-fix-1` | `final-review-fix-1` | final review fix | `verified` | `0623621194baf382a1a07e09ff198f7361e1f5f0` | `e80c7888d370f842270808ba8211ffbba17e28dc` | `4cf27b4b93b573e662403b8ef3e0e3065a5bd6dd` | `0623621194baf382a1a07e09ff198f7361e1f5f0` | `e80c7888d370f842270808ba8211ffbba17e28dc` | exact | configuration contract, workflow symmetry, Work Item Analysis contract, and `bash scripts/check-all.sh` passed | I-1 and I-2 fixed; final whole-repair review recorded |

## Code Review Evidence

- Report: [B-004 Code Review Report](04-code-review-report.md)
- Review decision: ✅ `ready`
- Critical findings: `0`
- Important findings: `2 fixed` (`I-1`, `I-2`)
- Unresolved findings: `None`

## Regression Verification Evidence

- Report: [B-004 Regression Test Report](05-regression-test-report.md)
- Verification decision: ⚠️ `ready_with_risk`
- Fresh verification: `bash scripts/check-all.sh` passed.
- Residual risk: real external AI host generation and session recovery require Business Acceptance.

## Skipped Checks

- None for the confirmed repair scope.

## Repair Notes And Residual Risks

- The repair is a workflow-rule and contract-test change; it cannot execute AI-generated documents inside every possible host session.
- The worktree fixture verifies Git configuration propagation mechanics and the rule contract. End-to-end generation in a real external target repository remains a Business Acceptance consideration.
- The vendored Superpowers worktree skill was not modified.
