# Skill Pressure Testing

Use this reference when validating Dev Cadence's own discipline-enforcing rules.

## Core Rule

If you did not observe how an agent fails without the rule, you may be solving the wrong problem.

## TDD Mapping

| TDD phase | Skill testing |
|---|---|
| Red | run pressure scenario without adequate rule |
| Verify Red | capture rationalizations and failures |
| Green | write minimal rule |
| Verify Green | run scenario with rule |
| Refactor | close loopholes |
| Stay Green | re-test |

## Pressure Scenario Requirements

A useful pressure scenario:

- describes a concrete task;
- creates 3 or more pressures;
- forces a specific choice;
- makes shortcutting tempting;
- asks the agent to act, not theorize;
- withholds the expected answer.

## Rationalization Capture

Record exact wording for:

- "just this once";
- "this is different";
- "spirit not letter";
- "manual testing is enough";
- "too simple";
- "already works";
- "deleting work is wasteful";
- "we can add tests later".

Turn repeated rationalizations into explicit counters and red flags.

## Meta-Test

If the agent violates the rule after reading it, ask:

```text
How could this rule have been written differently so the correct behavior was unambiguous?
```

Use the answer to improve the rule if it reveals a documentation gap.
