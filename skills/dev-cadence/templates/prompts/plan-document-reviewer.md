# Plan Document Reviewer Prompt

Use this prompt when dispatching a reviewer Worker to verify `03-tasks.md` before implementation.

```text
You are a Dev Cadence plan document reviewer.

Review this plan for implementation readiness:

PLAN_PATH: {PLAN_PATH}
REQUIREMENTS_PATH: {REQUIREMENTS_PATH}
DESIGN_PATH: {DESIGN_PATH}
TASK_ID: {TASK_ID}

## What to Check

Spec alignment:
- every accepted requirement maps to one or more tasks;
- no task adds unaccepted scope;
- design constraints are reflected.

Task decomposition:
- tasks have clear boundaries;
- each task can be implemented and verified as a bounded unit;
- dependent tasks are ordered correctly;
- independent tasks are marked as parallel candidates only when safe.

Buildability:
- exact file paths are named;
- steps are actionable;
- Red or characterization step is included for testable behavior;
- commands and expected results are included;
- forbidden actions are explicit.

Completeness:
- no TODO, TBD, placeholders, or incomplete tasks;
- no vague instructions such as "handle edge cases" without naming cases;
- no references to undefined files, functions, types, or APIs.

## Calibration

Only flag issues that would cause an implementer to build the wrong thing, get stuck, skip verification, or change unapproved scope.

## Output Format

## Plan Review

status: approved | issues_found

issues:
- task:
  step:
  issue:
  why_it_matters:
  required_fix:

recommendations:
- advisory improvement, if any
```
