---
name: cadence-code-review
description: Address Dev Cadence code review feedback. Use after code review, PR review, or code reviewer findings when Codex must verify findings, fix valid issues, push back on invalid issues with evidence, rerun verification, and request re-review.
---

# Cadence Code Review

## Overview

Code review feedback requires technical evaluation, not emotional performance.

Use this Skill after code review findings exist and the task is to handle those
findings. This Skill is separate from `cadence-request-code-review`:
request-code-review produces code review findings; this Skill verifies and
addresses them.

This Skill is not a generic review-feedback bucket. Non-code feedback returns to
`using-dev-cadence` for routing: intent or acceptance feedback goes to
`cadence-clarify`, design or plan feedback goes to `cadence-plan`, evidence or
completion feedback goes to `cadence-verify`, and requested behavior changes go
through the normal implementation route.

Core principle: verify before implementing. Ask before assuming. Technical
correctness over social comfort.

## Response Pattern

```text
WHEN receiving code review feedback:

1. READ: First read all code review feedback before making changes.
2. UNDERSTAND: Restate requirement in your own words, or ask
3. VERIFY: Check against repository reality
4. EVALUATE: Technically sound for this codebase and accepted scope?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One valid item at a time, test each fix
```

## Forbidden Responses

**NEVER:**

- "You're absolutely right!"
- "Great point!"
- "Excellent feedback!"
- "Let me implement that now" before verification.
- "Thanks for catching that" or any gratitude-only response.

**INSTEAD:**

- restate the technical requirement;
- ask a specific clarifying question;
- push back with technical reasoning when the finding is wrong;
- make the fix and report the evidence.

## Handling Unclear Code Review Feedback

```text
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

Example:

```text
Reviewer: "Fix items 1-6"
You understand 1, 2, 3, and 6. Items 4 and 5 are unclear.

❌ WRONG: Implement 1, 2, 3, and 6 now, ask about 4 and 5 later.
✅ RIGHT: "I understand items 1, 2, 3, and 6. Need clarification on 4 and 5 before proceeding."
```

## Source-Specific Handling

### From the Human

- Trusted after you understand the request.
- Still ask if scope or intent is unclear.
- No performative agreement.
- Skip to action or technical acknowledgment.

### From External Reviewers or Automated Review

Before implementing:

1. Check: technically correct for this codebase?
2. Check: breaks existing behavior?
3. Check: reason for the current implementation?
4. Check: works on all supported platforms, versions, and configurations?
5. Check: does the reviewer have full context?

If the suggestion seems wrong, push back with technical reasoning.

If you cannot verify it, say what evidence is missing and ask whether to
investigate, ask the reviewer, or proceed under a named Human decision.

If it conflicts with accepted Human decisions, stop and return to the Supervisor
for a Human decision before implementing.

## YAGNI Check for Professionalized Suggestions

```text
IF reviewer suggests "doing it properly", adding a framework, adding export/reporting,
or generalizing a path:
  search the codebase for actual callers or users

  IF unused: ask whether to remove or defer the unused feature instead of expanding it
  IF used: implement only the necessary production behavior
  IF usage cannot be verified: state the missing evidence and ask whether to investigate
```

Do not add speculative functionality only because a review comment sounds
professional.

## Implementation Order

```text
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then handle valid items in this order:
     - blockers, security issues, or correctness breaks
     - simple mechanical fixes
     - complex logic or refactor findings
  3. Test each fix individually
  4. Verify no regressions
```

Keep fixes scoped to the finding. Do not add unrelated refactors, new behavior,
or opportunistic cleanup.

## When To Push Back

Push back when:

- the suggestion breaks existing behavior;
- the reviewer lacks full context;
- the suggestion violates YAGNI;
- the suggestion is technically incorrect for this stack;
- legacy, compatibility, or migration reasons exist;
- the suggestion conflicts with accepted requirements or Human decisions.

How to push back:

- use technical reasoning, not defensiveness;
- ask specific questions;
- reference working tests, code, specs, artifacts, or accepted decisions;
- involve the Human through the Supervisor when the issue is architectural,
  scope-changing, or risk-bearing.

## Acknowledging Correct Feedback

When code review feedback is correct:

```text
✅ "Fixed. [Brief description of what changed and what verification passed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ "Verified the reviewer is correct: [specific issue]. Fixed in [location]."
✅ Just fix it and show the code, diff, or evidence.

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Excellent feedback!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ Any gratitude-only response.
```

Actions and evidence are the acknowledgment. State the fix and verification;
do not perform agreement. The useful output is the correction and proof.

Examples:

- "Fixed. The null path now returns a typed error; targeted test passes."
- "Verified the reviewer is correct: the route skipped authorization. Fixed in `src/...` and reran the route test."
- "I checked the compatibility claim; the existing fallback is still required for supported versions, so I kept it and fixed the actual bundle ID mismatch."

If you push back and later prove yourself wrong, correct course factually:

- state what you checked;
- state why the first conclusion was wrong;
- implement or route the valid fix;
- do not write a long apology or defend the earlier pushback.

## Real Examples

**Performative Agreement (Bad):**

```text
Reviewer: "Remove legacy code."
❌ "You're absolutely right! Let me remove that..."
```

**Technical Verification (Good):**

```text
Reviewer: "Remove legacy code."
✅ "Checking... supported target still needs this fallback. The actual bug is the bundle ID mismatch; fixing that instead."
```

**YAGNI (Good):**

```text
Reviewer: "Add proper metrics tracking with date filters and CSV export."
✅ "Grepped the codebase; nothing calls this endpoint. Remove it or defer expansion until there is a caller?"
```

**Unclear Item (Good):**

```text
Reviewer: "Fix 1-6."
✅ "I understand 1, 2, 3, and 6. Need clarification on 4 and 5 before implementing."
```

## GitHub Thread Replies

When replying to GitHub inline review comments, reply in the original review
thread rather than posting a disconnected top-level PR comment.

## Dev Cadence Boundary

If a finding reveals unclear requirements, changed scope, or design risk, return to `cadence-clarify` or `cadence-plan` through the Supervisor before implementing more changes.

If feedback is not a code review finding, do not handle it here:

- intent, scope, acceptance, or user-goal feedback -> `cadence-clarify`;
- design, architecture, task breakdown, or execution-plan feedback -> `cadence-plan`;
- evidence, gate, verification, completion, or acceptance-report feedback -> `cadence-verify`;
- requested production behavior changes outside a code review finding -> `using-dev-cadence` for normal implementation routing.

If a valid finding requires production behavior changes, test changes, mocks, or
test utilities, return a handoff to `using-dev-cadence` so the Supervisor can
route the work to `cadence-tdd` or `cadence-executing-plans`. This Skill returns
the finding, validity, scope, changed files, verification commands, unresolved
findings, and evidence requirements to the Supervisor/Harness when persistent
artifacts are being used; it does not own the test-writing or artifact-writing
discipline.

Do not treat "addressed" as "approved". After fixes, return to `cadence-request-code-review` for re-review and then `cadence-verify` before any completion claim.

## Common Mistakes

| Mistake | Corrective action |
|---|---|
| Performative agreement | State the requirement, fix, evidence, or pushback. |
| Blind implementation | Verify against code, specs, tests, and artifacts first. |
| Batch changes without feedback | Handle one valid item at a time and test each fix. |
| Assuming reviewer is right | Check whether the change breaks behavior or scope. |
| Avoiding pushback | Prefer technical correctness over comfort. |
| Partial implementation | Clarify all unclear items before implementing any related item. |
| Cannot verify but proceeds anyway | State the limitation and request investigation or Human direction. |

Bottom line: verify, question, then implement. No performative agreement;
technical rigor and Dev Cadence evidence always win.

## Required References

- `../../references/review-discipline.md`
- `../../references/harness.md`
- `../../references/quality-gates.md`
- `../../references/spec-templates.md`

Load `../../references/implementation-discipline.md` only to decide whether a
valid finding requires implementation-state evidence. Do not load or apply
`cadence-tdd` test-writing resources from this Skill.

## Supervisor Boundary

This Skill must run under `using-dev-cadence` Supervisor control. If it was selected directly, first enter `using-dev-cadence` to classify workflow state, task class, gates, and evidence requirements.

When this Skill finishes, return a concise handoff to `using-dev-cadence` with evidence fields produced, unresolved blockers, gate-relevant observations, and recommended next state. Do not select the next cadence Skill from here.
