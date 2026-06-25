# Verification Discipline

Use this reference before any completion, fixed, passing, approval, or acceptance claim.

## Core Rule

```text
No completion claims without fresh verification evidence.
```

Evidence comes before claims. Confidence is not evidence.

## Gate Function

Before claiming any work state:

1. Identify which command, check, or artifact proves the claim.
2. Run the full relevant command or perform the documented check.
3. Read the full output and exit code.
4. Compare the result to the claim.
5. State the claim only with evidence, or state the actual incomplete status.

Skipping a step means the workflow is not verified.

When task artifacts exist, run
`scripts/check-gates.mjs --task-id <task_id>` before claiming fixed, complete,
approved, accepted, or ready. Before creating a Git commit for a dirty
worktree, run `scripts/check-before-commit.mjs --task-id <task_id>`; this also
treats selected-task artifact language warnings as failures. If G6 final Human
acceptance is pending, do not commit; report the required Human acceptance
fields instead.

## Claim Matrix

| Claim | Requires | Not sufficient |
|---|---|---|
| Tests pass | fresh test output with zero relevant failures | prior run, expectation |
| Build succeeds | build command exit 0 | linter only |
| Bug fixed | original symptom or regression check passes | code changed |
| Requirement met | acceptance mapping checked | tests unrelated to requirement |
| Review approved | reviewer decision and evidence | implementer self-report |
| Task complete | required artifacts and gates complete | "looks done" |

## Red Flags

Stop before saying success words when you notice:

- "should";
- "probably";
- "seems";
- "looks good";
- "done" before verification;
- trusting Worker success reports;
- relying on partial verification;
- wanting to finish because tired or rushed.

## Incomplete Verification

If verification cannot run:

```yaml
verification_status: blocked_by_environment
skipped_checks:
reason:
residual_risk:
recommended_follow_up:
human_gate_required:
```

Do not pass G4 or G6 until a named Human accepts the gap.
