# Authoring Discipline

Use this reference only when creating or changing Dev Cadence's own skills, references, templates, adapters, or policies.

Do not load this for ordinary product delivery unless the product task itself is about authoring a skill or process rule.

## Core Rule

Treat process documentation like code. Test discipline-enforcing rules with realistic pressure scenarios before relying on them.

## RED-GREEN-REFACTOR for Skill Behavior

### RED: Baseline

Before changing a discipline rule when feasible:

- define pressure scenarios;
- run or reason from a baseline where the current rule fails;
- document exact failures, loopholes, or rationalizations;
- identify which pressure makes the rule fail.

### GREEN: Minimal Rule Change

Make the smallest change that addresses the observed failure. Avoid broad doctrine that does not answer the actual loophole.

### REFACTOR: Close Loopholes

After validation:

- capture new rationalizations;
- add explicit counters;
- update red flags;
- improve routing or loading instructions;
- re-test when practical.

## Pressure Scenario Design

Good scenarios include multiple pressures:

- time pressure;
- sunk cost;
- authority;
- fatigue;
- business urgency;
- social pressure;
- "pragmatic" shortcut temptation.

Force concrete choices. Avoid academic questions that only ask the agent to recite rules.

## Authoring Checklist

Before shipping a Dev Cadence behavior change:

- triggering context is clear;
- loading contract is explicit;
- rule is concise but hard to rationalize away;
- examples are reusable, not narrative-only;
- required evidence is named;
- exceptions require named Human decision when appropriate;
- references are one level from `SKILL.md` or routed by a direct reference;
- validation evidence exists or deferral is recorded.

Use `skill-pressure-testing.md` for the detailed testing method.
