---
name: cadence-verify
description: Verify Dev Cadence work before any completion claim. Use before saying fixed, done, passing, approved, complete, ready, or accepted, and whenever verification evidence, skipped checks, residual risk, or Human acceptance must be summarized.
---

# Cadence Verify

Use this Skill before any completion claim, positive status claim, handoff that
implies success, commit, PR, merge, or final acceptance request.

Core principle: evidence before claims, always.

Unverified completion claims are a process failure, not efficiency. Violating
the letter of this rule violates the spirit of it.

## Core Rule

```text
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you have not run or checked the verification for the current candidate, do
not say it is fixed, done, passing, approved, ready, complete, or accepted.
If the claim depends on a command, and that command has not run for this
candidate, you cannot claim the command passes.

## Required References

- `../../references/verification-discipline.md`
- `../../references/quality-gates.md`
- `../../references/human-gates.md`
- `../../references/spec-templates.md`

## Required Behavior

### Gate Function

Before claiming any work state:

1. IDENTIFY: what command, artifact, or documented check proves the claim.
2. RUN: execute the full relevant command, or perform the documented check,
   against the current candidate.
3. READ: inspect the full output, exit code, failure count, skipped checks, and
   artifact contents.
4. COMPARE: decide whether the evidence actually proves the claim.
5. STATE: report the verified result with evidence, or report the actual
   incomplete status.

If any step is missing, do not make the claim.

### Claim Matrix

| Claim | Requires | Not sufficient |
|---|---|---|
| tests pass | fresh test output with zero relevant failures | previous run, expectation, partial log |
| linter clean | linter output with zero relevant errors | formatter only, partial check, extrapolation |
| build succeeds | build command exit 0 | linter only, compile not run |
| bug fixed | original symptom or regression check passes | code changed |
| regression test works | Red-Green verification or equivalent failing-before-fix evidence | test passes once |
| requirement met | acceptance mapping checked against implementation | unrelated tests pass |
| review approved | reviewer decision and evidence | implementer self-report |
| Worker or delegated task completed | Worker report plus independent diff/artifact verification | Worker says "done" |
| task complete | required artifacts, gates, verification, review, and Human acceptance when required | "looks done" |

### Fresh Evidence Rules

- Run verification after the final relevant file change.
- After any file change, old verification output is stale for affected claims.
- Do not reuse a previous command result unless it still applies to the exact
  current candidate and you state why.
- Do not trust Worker, reviewer, or tool summaries without checking the
  underlying diff, artifacts, command output, or gate result.
- Partial verification proves only the part that ran.

### Required Checks

Verify:

- required tests or commands ran and results are known;
- skipped checks are named with reasons;
- changed files match planned scope;
- unplanned diffs are explained or reverted with permission;
- residual risks are explicit;
- final acceptance, when required, names a Human accepter.

### Commit and Gate Verification

When persistent artifacts exist, run `scripts/check-gates.mjs --task-id
<task_id>` and include the Gate Summary in the handoff. Before creating a Git
commit, run `scripts/check-before-commit.mjs` against the commit candidate. Add
`--task-id <task_id>` when committing product paths that intentionally belong to
an existing Dev Cadence workflow but the workflow specs are not in the same
candidate.

`scripts/check-before-commit.mjs` is read-only and must not create specs. If G6
final Human acceptance is pending for a workflow candidate, block the commit and
ask the Human to accept the result and residual risk before committing.

### Human Acceptance Summary

When G6 is pending, the user-facing handoff must state what is being accepted.
Refresh the browsable report with
`scripts/generate-spec-report.mjs --specs-dir specs/records --report-dir specs/report`,
then run `scripts/summarize-acceptance.mjs --task-id <task_id> --require-report`
or provide the same fields directly: goal, changed scope, verification status,
skipped checks, review decision, blockers, residual risk, evidence available,
the `specs/report/{task_id}/index.html` review entry, and the fields to record
in `08-acceptance.md`. Do not merely say "G6 is pending".

Return test-report and acceptance-summary fields for Supervisor/Harness recording when persistent artifacts are being used. Do not directly write or update persistent records from this Skill; missing Tester, Reviewer, Worker, or Human evidence must remain a gap until the responsible path provides it.

### Incomplete Verification

If verification cannot run, return:

```yaml
verification_status: blocked_by_environment
skipped_checks:
reason:
residual_risk:
recommended_follow_up:
human_gate_required:
```

Do not treat `partially_verified`, `not_verified`, or `blocked_by_environment`
as complete unless a named Human accepts the gap.

## Red Flags

Stop before claiming success when you notice:

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
- wanting to finish because the task is tedious or late.
- any wording that implies success without current evidence.

## Rationalization Prevention

| Rationalization | Reality |
|---|---|
| "It should pass now." | Run the verification. |
| "I am confident." | Confidence is not evidence. |
| "Just this once." | No exception without a named Human accepting the gap. |
| "The linter passed." | Lint does not prove tests or build pass. |
| "The Worker said it is done." | Verify the diff and artifacts independently. |
| "Only docs changed." | Verify the relevant docs/package checks. |
| "Partial check is enough." | Partial check supports only a partial claim. |
| "Different wording avoids the rule." | Any implication of success requires evidence. |

## Key Patterns

**Tests:**

```text
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**

```text
✅ Write -> Run (pass) -> Revert fix -> Run (MUST FAIL) -> Restore -> Run (pass)
❌ "I have written a regression test" without Red-Green verification
```

**Build:**

```text
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" when build or compile did not run
```

**Requirements:**

```text
✅ Re-read plan -> Create checklist -> Verify each -> Report gaps or completion
❌ "Tests pass, phase complete"
```

**Delegated Work:**

```text
✅ Worker reports success -> Check diff -> Verify artifacts -> Report actual state
❌ Trust Worker report
```

**Bug Fix:**

```text
✅ Reproduce symptom -> Apply fix -> Run regression check -> Report result
❌ "I changed the code, so the bug is fixed"
```

## When to Apply

Always use this Skill before:

- any completion, fixed, passing, ready, approved, accepted, or done claim;
- any expression of satisfaction about work state;
- any positive status statement about implementation, tests, build, review, or
  acceptance;
- committing, opening a PR, merging, or handing off for final acceptance;
- moving to the next task after delegated work;
- summarizing Worker or reviewer output as complete;
- asking the Human to accept final results or residual risk.

The rule applies to exact words, synonyms, paraphrases, and implications of
success. If the message would make a Human believe the work is complete or
correct, verify first.

## Why This Matters

False completion claims cause:

- broken or incomplete work to be accepted;
- missing requirements to be treated as finished;
- stale test output to hide regressions;
- Human review time to be wasted on preventable rework;
- trust in the workflow evidence to degrade.

## Bottom Line

No shortcuts for verification. Run the command or documented check, read the
output, compare it to the claim, then state the result.

## Handoff Evidence

Return:

- claim being verified;
- commands or checks run;
- exit codes and relevant output summary;
- artifacts inspected;
- gate status;
- skipped checks and reasons;
- residual risks;
- whether named Human acceptance is required or already recorded;
- recommended next state.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence produced, unresolved blockers, gate status, and recommended next state. Do not select the next cadence Skill from here.
