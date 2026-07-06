# Simplify Code Review Skill Boundary Plan

**Goal:** Make Dev Cadence code review responsibilities match the simple upstream-style split: task-local review stays inside `cadence-subagent-development`, `cadence-request-code-review` uses only one whole-diff reviewer prompt, and `cadence-code-review` keeps its current feedback-handling role for now.

**Scope:** Planning only. Do not rename `cadence-code-review` in this pass.

## Target Model

1. `cadence-subagent-development`
   - Owns per-task isolated Worker execution and per-task review.
   - Uses only Skill-local resources for per-task review, especially `skills/cadence-subagent-development/task-reviewer-prompt.md`.
   - Does not reuse or reference `skills/cadence-request-code-review/spec-compliance-reviewer.md`.

2. `cadence-request-code-review`
   - Requests/dispatches review of completed implementation work and produces review findings/verdicts.
   - Keeps only `skills/cadence-request-code-review/code-reviewer.md` as the prompt template.
   - Uses the single reviewer prompt for checkpoint, final, whole-diff, or branch review.
   - Does not maintain separate `spec-compliance-reviewer.md` or `code-quality-reviewer.md` files.

3. `cadence-code-review`
   - Keeps current responsibility: handle existing code review feedback, PR comments, or reviewer findings.
   - Verifies findings, fixes or routes valid issues, pushes back on invalid findings, and returns to `cadence-request-code-review` for re-review.
   - Rename is explicitly out of scope for this pass.

## Current Problem

`cadence-request-code-review` currently mixes two review models:

- staged review prompts:
  - `skills/cadence-request-code-review/spec-compliance-reviewer.md`
  - `skills/cadence-request-code-review/code-quality-reviewer.md`
- composite review prompt:
  - `skills/cadence-request-code-review/code-reviewer.md`

This creates overlap because `code-reviewer.md` already covers both requirement alignment and code quality. The simpler split should match the upstream Superpowers shape more closely:

- per-task task review belongs to subagent-driven development;
- final/checkpoint whole-diff review belongs to requesting-code-review;
- review feedback handling belongs to receiving/code-review handling.

## Files Likely to Change

### Delete

- `skills/cadence-request-code-review/spec-compliance-reviewer.md`
- `skills/cadence-request-code-review/code-quality-reviewer.md`

### Modify

- `skills/cadence-request-code-review/SKILL.md`
  - Remove staged prompt selection.
  - State that `code-reviewer.md` is the only reviewer prompt for this Skill.
  - Keep the rule that this Skill produces findings/verdicts and does not fix feedback.
  - Preserve precise context, read-only reviewer, concrete target, actual diff/files/evidence, severity, and verdict requirements.

- `skills/cadence-request-code-review/code-reviewer.md`
  - Ensure it clearly covers both requirement/plan alignment and code quality.
  - Keep read-only constraints and no-chat-history rule.
  - Keep Dev Cadence verdict vocabulary.
  - Avoid implying final Human acceptance or gate completion.

- `references/review-discipline.md`
  - Reframe review as checking both alignment and quality, without requiring two separate prompt files under `cadence-request-code-review`.
  - If keeping the phrase “spec compliance before code quality”, define it as ordering inside the reviewer’s evaluation/report, not as separate prompt files for this Skill.
  - Keep `cadence-code-review` vs `cadence-request-code-review` boundary: producing findings vs handling existing feedback.

- `references/agent-blueprints.md`
  - Replace references to `spec-compliance-reviewer.md` and `code-quality-reviewer.md` with `skills/cadence-request-code-review/code-reviewer.md` for whole-diff/checkpoint/final reviewer dispatch.
  - Do not change `cadence-subagent-development` task reviewer ownership.

- `references/execution-orchestration.md`
  - Keep per-task review sequencing where needed, but route task-local review to `skills/cadence-subagent-development/task-reviewer-prompt.md` when discussing subagent-style execution.
  - Avoid saying `cadence-request-code-review` owns per-task staged prompts.

- `references/skill-layout.md`
  - Remove deleted prompt files from examples if present.
  - Keep Skill-local resource rule.

- `references/delivery-disciplines.md`
  - Update prompt examples if they mention removed files.

- `docs/codex-plugin-boundaries.md`
  - Adjust `cadence-request-code-review` description if it implies separate staged prompt resources.
  - Keep `cadence-subagent-development` as owner of per-task review.

- `docs/roles/agents/05-reviewer.md`
  - If needed, clarify that reviewer checks alignment before quality, but the prompt resource depends on owning Skill: task-local prompt for `cadence-subagent-development`, whole-diff prompt for `cadence-request-code-review`.

- `docs/artifacts/07-review-report.md`
  - If needed, keep artifact fields for both spec compliance and code quality findings without requiring separate reviewer prompt files.

- `tests/test-codex-plugin-package.sh`
  - Remove `assert_exists` for deleted staged reviewer prompt files.
  - Keep `assert_exists "skills/cadence-request-code-review/code-reviewer.md"`.

- `scripts/check-discipline-routes.mjs`
  - Remove deleted staged prompt files from required prompt lists.
  - Update contract checks so `cadence-request-code-review/SKILL.md` requires `code-reviewer.md` as the single prompt.
  - Remove or rewrite `checkStagedReviewerPromptContract()`.
  - Add/keep checks that prevent reintroducing direct dependency from `cadence-subagent-development` to `cadence-request-code-review` staged prompts.

- Other docs/tests discovered by search for:
  - `spec-compliance-reviewer.md`
  - `code-quality-reviewer.md`
  - `Review in two stages`
  - `Do not run code quality review before spec compliance passes`
  - `skills/cadence-request-code-review/spec-compliance-reviewer.md`
  - `skills/cadence-request-code-review/code-quality-reviewer.md`

## Implementation Steps

### Task 1: Confirm reference surface

1. Search the repo for removed prompt names and staged review wording.
2. Record all active references outside `docs/archive/`.
3. Do not edit archive files unless they affect active checks.

Expected searches:

```bash
rg "spec-compliance-reviewer\.md|code-quality-reviewer\.md|Review in two stages|Do not run code quality review before spec compliance" README.md docs references skills scripts tests .codex-plugin
```

### Task 2: Simplify `cadence-request-code-review`

1. Edit `skills/cadence-request-code-review/SKILL.md`:
   - remove the staged prompt selection section;
   - make `code-reviewer.md` the only prompt template;
   - keep reviewer context and output requirements;
   - keep “does not implement fixes”.
2. Delete the two staged prompt files.
3. Inspect `code-reviewer.md` and adjust only if needed to preserve alignment + quality coverage.

### Task 3: Update shared references and docs

1. Update active references to point to `code-reviewer.md` for `cadence-request-code-review`.
2. Keep task-local review under `cadence-subagent-development/task-reviewer-prompt.md`.
3. Preserve the conceptual distinction: review should check requirement alignment and code quality; this no longer requires separate prompt files in `cadence-request-code-review`.

### Task 4: Update package and discipline checks

1. Update `tests/test-codex-plugin-package.sh` package boundary expectations.
2. Update `scripts/check-discipline-routes.mjs` required prompt checks and reviewer prompt contract checks.
3. Add or preserve guardrails:
   - `cadence-request-code-review` must reference `code-reviewer.md`;
   - deleted staged prompt files must not be required;
   - `cadence-code-review` remains feedback-handling only;
   - `cadence-subagent-development` uses Skill-local task reviewer resources.

### Task 5: Verify

Run targeted checks first:

```bash
node scripts/check-discipline-routes.mjs .
node scripts/check-skill-package.mjs .
git diff --check
```

Then run full regression because package boundaries and runtime contracts changed:

```bash
bash tests/run-all.sh
```

If `scripts/check-discipline-routes.mjs` changes and an external gate requests fresh focused evidence, create an ad-hoc `hermes-verify-*` temp script that asserts the new contract and mutation-fails on a forbidden old reference. Clean it up and report it as ad-hoc verification, not suite green.

## Acceptance Criteria

- `skills/cadence-request-code-review/` contains only:
  - `SKILL.md`
  - `code-reviewer.md`
- No active non-archive reference requires:
  - `skills/cadence-request-code-review/spec-compliance-reviewer.md`
  - `skills/cadence-request-code-review/code-quality-reviewer.md`
- `cadence-request-code-review` clearly means: dispatch/request review and produce findings/verdicts; do not fix findings.
- `cadence-code-review` clearly remains: handle existing code review feedback/findings; do not rename in this pass.
- `cadence-subagent-development` does not depend on `cadence-request-code-review` staged reviewer prompts.
- Package and discipline checks pass.
- Full regression passes.

## Out of Scope

- Renaming `cadence-code-review`.
- Changing `cadence-code-review` behavior beyond preserving the existing feedback-handling boundary.
- Reworking artifact schemas beyond wording needed to remove deleted prompt-file assumptions.
- Changing `cadence-subagent-development/task-reviewer-prompt.md` unless a direct stale reference requires it.
- Editing `docs/archive/**` unless an active test requires it.

## Risks and Notes

- Some docs may use “two-stage review” to mean conceptual review ordering rather than separate prompt files. Preserve the useful concept only where it does not imply `cadence-request-code-review` owns staged prompt resources.
- `code-reviewer.md` must stay strong enough to cover both requirement alignment and code quality so deleting the staged prompts does not weaken review coverage.
- Keep the feedback-handling boundary intact: do not broaden `cadence-code-review` into a generic requested-change handler.
