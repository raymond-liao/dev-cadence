# Review Discipline

Use this reference in `review` and after implementation checkpoints.

## Core Rule

Review implementation in two stages:

1. Spec compliance.
2. Code quality.

Do not run code quality review before spec compliance passes.

## Spec Compliance Review

Verify the implementation matches requirements, design, task plan, and acceptance criteria.

Check:

- all requested behavior is implemented;
- no accepted requirement is missing;
- no unaccepted scope was added;
- changed files match planned files or scope reconciliation explains deviations;
- implementation notes match the actual diff;
- acceptance mapping remains valid.

Do not trust implementer reports without checking code and evidence.

Use `templates/prompts/spec-compliance-reviewer.md` when dispatching a reviewer Worker.

## Code Quality Review

After spec compliance passes, review:

- correctness and edge cases;
- maintainability;
- separation of concerns;
- architecture fit;
- security and permissions;
- test quality;
- production readiness;
- documentation and migration needs when relevant.

Use `templates/prompts/code-quality-reviewer.md` or `templates/prompts/code-reviewer.md` when dispatching a reviewer Worker.

## Severity

Use these buckets:

- `blocker`: cannot continue; workflow blocked.
- `major`: must fix before approval unless named Human accepts risk.
- `minor`: can defer with recorded residual risk and follow-up.
- `note`: advisory only.

Critical or major findings require fix and re-review before acceptance.

## Receiving Review Feedback

Receiving review feedback is a separate action from producing review findings. Use `cadence-review` when Codex is asked to handle existing findings, requested changes, PR comments, or reviewer feedback. Use `cadence-request-review` to produce findings and review decisions.

Do not blindly apply feedback.

For each finding:

1. Verify it against code, tests, specs, and evidence.
2. Fix valid blocker and major issues before continuing.
3. Push back on invalid findings with concrete evidence.
4. Keep fixes scoped to the finding.
5. Re-run verification and review when required.
