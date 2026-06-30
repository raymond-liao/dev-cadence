# Verification Discipline

Use this shared reference before any completion, fixed, passing, approval, or
acceptance claim. This reference defines shared verification gate semantics. For
the executable verification workflow, use `skills/cadence-verify/SKILL.md`.

## Core Rule

```text
No completion claims without fresh verification evidence.
```

Evidence comes before claims. Confidence is not evidence.
Unverified completion claims are process failures, not efficiency.

## Gate Function

Before claiming any work state:

1. Identify which command, check, or artifact proves the claim.
2. Run the full relevant command or perform the documented check against the
   current candidate.
3. Read the full output and exit code.
4. Compare the result to the claim.
5. State the claim only with evidence, or state the actual incomplete status.

Skipping a step means the workflow is not verified.

Fresh evidence means evidence produced after the final relevant change. After a
file change, old output is stale for affected claims.

When task artifacts exist, run
`scripts/check-gates.mjs --task-id <task_id>` before claiming fixed, complete,
approved, accepted, or ready. Before creating a Git commit, run
`scripts/check-before-commit.mjs` against the full dirty worktree, regardless
of staging state. The checker is read-only and must not create specs.

If the candidate is outside Dev Cadence workflow scope, G1-G6 and Human Gate
checks are skipped. If the candidate is Dev Cadence contract/runtime-only, the
checker validates the embedded runtime instead of borrowing an unrelated
product task id. If the candidate includes Dev Cadence workflow specs, or the
user supplies `--task-id <task_id>` for product paths that belong to an existing
workflow, the checker validates artifact structure, artifact language warnings,
G1-G6/Human acceptance, and candidate path coverage. If G6 final Human
acceptance is pending for that workflow, do not commit; report the required
Human acceptance fields instead.

## Claim Matrix

| Claim | Requires | Not sufficient |
|---|---|---|
| Tests pass | fresh test output with zero relevant failures | prior run, expectation |
| Linter clean | linter output with zero relevant errors | formatter only, partial check |
| Build succeeds | build command exit 0 | linter only |
| Bug fixed | original symptom or regression check passes | code changed |
| Regression test works | Red-Green verification or equivalent failing-before-fix evidence | test passes once |
| Requirement met | acceptance mapping checked | tests unrelated to requirement |
| Review approved | reviewer decision and evidence | implementer self-report |
| Worker or delegated task completed | Worker report plus independent diff/artifact verification | Worker says "done" |
| Task complete | required artifacts and gates complete | "looks done" |

## Red Flags

Stop before saying success words when you notice:

- "should";
- "probably";
- "seems";
- "looks good";
- "done" before verification;
- expressing satisfaction before verification;
- about to commit, open a PR, merge, or ask for acceptance without verification;
- trusting Worker success reports;
- relying on partial verification;
- thinking "just this once";
- wanting to finish because tired or rushed.
- any wording that implies success without current evidence.

## Rationalization Prevention

| Rationalization | Reality |
|---|---|
| "It should pass now." | Run the verification. |
| "I am confident." | Confidence is not evidence. |
| "The linter passed." | Lint does not prove tests or build pass. |
| "The Worker said it is done." | Verify the diff and artifacts independently. |
| "Partial check is enough." | Partial check supports only a partial claim. |

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

## Bottom Line

No shortcuts for verification. Run the command or documented check, read the
output, compare it to the claim, then state the result.
