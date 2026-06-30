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

Use `skills/cadence-request-review/spec-compliance-reviewer.md` when dispatching a reviewer Worker.

Reviewer Workers are read-only. Provide task context, requirements, plan,
acceptance criteria, changed files, diff or git range, implementation notes, and
verification evidence. Do not pass the current chat history as reviewer context.
Reviewers must not mutate the working tree, index, branch state, specs, or run
evidence.

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

Use `skills/cadence-request-review/code-quality-reviewer.md` or `skills/cadence-request-review/code-reviewer.md` when dispatching a reviewer Worker.

Review output must include concrete findings, severity, affected locations when
available, why each issue matters, and an explicit verdict:
`approved`, `approved_with_minor_notes`, `changes_requested`, or `blocked`.

## Severity

Use these buckets:

- `blocker`: cannot continue; workflow blocked.
- `major`: must fix before approval unless named Human accepts risk.
- `minor`: can defer with recorded residual risk and follow-up.
- `note`: advisory only.

Critical or major findings require fix and re-review before acceptance.

## Receiving Review Feedback

Receiving review feedback is a separate action from producing review findings. Use `cadence-review` when Codex is asked to handle existing findings, requested changes, PR comments, or reviewer feedback. Use `cadence-request-review` to produce findings and review decisions.

Do not blindly apply feedback. Read all feedback first, clarify unclear items
before implementing, and verify each finding against code, tests, specs, and
evidence.

For each finding:

1. Understand the requested change.
2. Verify it against code, tests, specs, and evidence.
3. Evaluate whether it is technically correct for this repository.
4. Classify it as valid, partially valid, invalid, duplicate, or needs Human decision.
5. Fix valid blocker and major issues only through the appropriate implementation route.
6. Push back on invalid findings with concrete evidence.
7. Keep fixes scoped to the finding.
8. Re-run verification and review when required.

If a valid finding requires production behavior changes, test changes, mocks, or
test utilities, return to the Supervisor so the work can enter `cadence-tdd` or
`cadence-executing-plans` with implementation evidence. Review handling does
not own test-writing discipline.
