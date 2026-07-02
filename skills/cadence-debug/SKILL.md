---
name: cadence-debug
description: Diagnose bugs, incidents, failing tests, build failures, regressions, performance problems, integration problems, flaky async behavior, invalid data, and unclear root causes before proposing or implementing fixes.
---

# Cadence Debug

Use this Skill for any technical issue where behavior is unexpected, failing,
or not yet explained. Do not change production code, tests, configuration, or
workflow behavior for a bug until the failure and root cause investigation are
complete enough to justify the fix.

## Core Rule

Random fixes waste time and create new bugs. Quick patches hide underlying
failures.

```text
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you have not completed Phase 1, you cannot propose fixes. If the Human
explicitly accepts an emergency shortcut, return the named Human decision,
reason, residual risk, and follow-up evidence gap before proceeding.

## Required Resources

Load these when the condition applies:

- `root-cause-tracing.md` when the symptom appears deep in a call stack, the
  origin is unclear, or a bad value/state must be traced backward.
- `condition-based-waiting.md` when tests are flaky, async timing is involved,
  or arbitrary sleeps/timeouts appear in test code.
- `defense-in-depth.md` when the bug involves invalid data, unsafe state, a
  dangerous operation, or missing boundary checks.
- `../../references/harness.md` when persistent run evidence is required.
- `../../references/quality-gates.md` when deciding whether evidence is enough
  to move forward.
- `../../references/spec-templates.md` when task artifact content is required.

## Example Code Boundary

Examples are illustrative only. Always adapt diagnostics, tests, and fixes to
the target repository's existing language, framework, tooling, and conventions.
Do not introduce a language, framework, toolchain, or dependency only because
an example uses it.

## When to Use

Use this for:

- test failures;
- production bugs or incidents;
- unexpected behavior;
- performance problems;
- build failures;
- integration failures;
- flaky async behavior;
- invalid data or unsafe state;
- any case where the root cause is not proven.

Use this especially when:

- time pressure makes guessing tempting;
- a quick fix seems obvious;
- previous fixes failed;
- multiple attempted fixes have accumulated;
- you do not fully understand why the issue happens.

Do not skip this process because the issue looks simple. Simple bugs still have
root causes.

## Four Phases

You MUST complete each phase before proceeding to the next. If a phase is
blocked, state the blocker and ask for the missing evidence or Human decision
instead of guessing.

### Phase 1: Root Cause Investigation

Before proposing any fix:

1. Read error messages, stack traces, logs, warnings, and failure output
   completely. Preserve line numbers, file paths, error codes, and exact
   messages.
2. Reproduce consistently. If the issue is not reproducible, characterize what
   is known and gather more data instead of guessing.
3. Check recent changes: diffs, commits, dependencies, config, environment,
   test data, and platform differences.
4. In multi-component systems, gather boundary evidence before proposing fixes:
   log what enters and leaves each component, verify config/environment
   propagation, and identify which layer first breaks.
5. Trace data flow backward when the symptom is far from the trigger. Find the
   first bad value, wrong state transition, missing invariant, or bypassed
   validation.

Success criteria: you can state what is failing, why it is failing, and where
the failure first becomes possible.

### Phase 2: Pattern Analysis

Find the pattern before changing behavior:

1. Locate similar working code in the same repository.
2. Read relevant reference implementations completely when applying a known
   pattern.
3. List meaningful differences between working and broken paths. Do not assume
   a small difference cannot matter.
4. Identify dependencies, configuration, environment, data shape, ordering, and
   lifecycle assumptions.

Success criteria: you know what working behavior looks like and which
differences could explain the failure.

### Phase 3: Hypothesis and Testing

Use one hypothesis at a time:

```text
I think X is the root cause because Y.
```

Test the hypothesis with the smallest useful diagnostic or change. Vary one
thing at a time. If the hypothesis fails, record what it ruled out and form a
new hypothesis. Do not stack fixes on top of a failed hypothesis.

When you do not understand a result, say what is unknown and gather more
evidence. Do not pretend a guess is a diagnosis.

Success criteria: the evidence confirms the root cause or clearly narrows the
next investigation step.

### Phase 4: Implementation

Fix the root cause, not the symptom:

1. Create a failing regression test, characterization test, or minimal
   reproduction when possible. Use `cadence-tdd` for testable code changes.
2. Implement one fix that addresses the proven root cause.
3. Avoid unrelated refactors, opportunistic cleanup, and bundled behavior
   changes.
4. Verify the original symptom is resolved and relevant regression checks pass.
5. Record skipped checks, residual risk, and remaining uncertainty.

If the fix does not work, stop and return to Phase 1 with the new evidence.
If three fix attempts fail, stop and question the architecture or assumptions
before attempting a fourth fix. Discuss the decision with the Human instead of
continuing to patch symptoms.

## When Investigation Finds No Root Cause

If investigation indicates the issue is environmental, external, or genuinely
timing-dependent:

1. Return what was investigated.
2. Return what evidence ruled out local causes.
3. Implement handling appropriate to the proven failure mode, such as retry,
   timeout, diagnostics, or clearer error reporting.
4. Recommend monitoring or evidence capture for future investigation.

Treat "no root cause" as suspicious until the investigation is documented.

## Red Flags

Stop and return to Phase 1 when you catch any of these:

- "quick fix for now";
- "just try changing X";
- "it is probably X";
- proposing solutions before tracing data flow;
- adding multiple changes before testing;
- skipping reproduction;
- skipping the regression test when one is feasible;
- not understanding why a fix worked;
- adapting a pattern without reading it fully;
- trying one more fix after repeated failures;
- each fix reveals a new problem in a different place.

## Human Correction Signals

If the Human asks questions such as these, treat it as a process failure signal
and return to investigation:

- "Is that not happening?"
- "Will it show us...?"
- "Stop guessing."
- "Think deeper about the fundamentals."
- "Are we stuck?"

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Issue is simple, no process needed." | Simple issues still have root causes. |
| "There is no time for process." | Guess-and-check is usually slower than evidence. |
| "Try this first, then investigate." | The first change sets the pattern. Investigate first. |
| "I will write the test after confirming the fix." | A passing-only test may not prove the intended behavior. |
| "Multiple fixes at once saves time." | It hides what worked and creates new risk. |
| "The reference is long, I can skim it." | Partial understanding is a common bug source. |
| "I see the symptom, so I know the fix." | A symptom is not a root cause. |
| "One more attempt after several failures." | Repeated failed fixes mean the assumptions need review. |

## Evidence

When artifacts are being written, return:

- exact reproduction or characterization steps;
- observed behavior and expected behavior;
- relevant logs, stack traces, commands, environment, and versions;
- root cause and propagation path;
- hypotheses tested and results;
- fix strategy and changed files;
- verification commands and outputs;
- skipped checks and residual risk.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with
evidence fields produced, unresolved blockers, gate-relevant observations, and
recommended next state. Do not select the next cadence Skill from here.
