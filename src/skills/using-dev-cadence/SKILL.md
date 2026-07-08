---
name: using-dev-cadence
description: Use when working in a repository with Dev Cadence installed and the user asks for feature work, bug fixes, behavior changes, implementation, testing, verification, or development commits.
---

# Using Dev Cadence

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance an installed Dev Cadence flow applies to the user's development request, you ABSOLUTELY MUST read the matching flow skill.

IF A DEV CADENCE FLOW APPLIES TO THE TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

Use this skill before any development response or action in a repository with Dev Cadence installed.

Dev Cadence flows are explicit business workflows. Do not force a request into a flow just because the request is related to software.

## The Rule

Check installed Dev Cadence flows BEFORE any development response or action, including clarifying questions, repository exploration, implementation, test execution, commits, or status claims.

If an installed flow applies, read that flow skill completely and follow it exactly. If the selected flow turns out wrong for the situation, stop and choose the correct installed flow or handle the request normally.

If no installed flow applies, handle the request normally.

## Available Flows

| User request | Flow |
| --- | --- |
| Add a new user-visible or system-visible feature | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Change existing user-visible or system-visible feature behavior | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Report a bug, error, failing test, regression, or unexpected behavior | `.dev-cadence/skills/bug-fix/SKILL.md` |

## Flow Priority

When multiple flows might apply, choose the process flow before any implementation or domain skill.

Use `bug-fix` when the existing expected behavior should already work and the user reports that it does not.
Use `feature-dev` when the user asks to add behavior or intentionally change expected behavior.
If a request mixes a defect report with a requested behavior change, ask whether the user wants a bug fix or a feature change before choosing a flow.

## Decision Rules

1. If the request clearly matches an available flow, read that flow skill completely and follow it.
2. If the request might match an available flow but is ambiguous, ask one concise clarification question before choosing.
3. If the request does not match any available flow, do not use a Dev Cadence flow. Handle it as a normal request.

Then announce the selected Dev Cadence flow and follow the flow skill exactly.

## Red Flags

These thoughts mean STOP and check the installed Dev Cadence flows:

| Thought | Reality |
| --- | --- |
| "This is just a small development task." | Small development tasks still need flow checking. |
| "I need to inspect files before deciding." | Flow checking comes before repository exploration. |
| "This sounds related to features, so feature-dev applies." | `feature-dev` applies only to new features or changes to intended feature behavior. |
| "The user reported a bug, so feature-dev can handle it." | Bug reports use `bug-fix` unless the user asks to change intended behavior. |
| "The user asked for a fix, so I can patch it directly." | Bug fixes must go through `bug-fix` when that flow is installed. |
| "There is no exact flow, but feature-dev is close enough." | Do not force requests into a mismatched Dev Cadence flow. |
| "I can mention future flows as options." | Only mention installed flows. |
| "The request is unclear, but I can choose a flow anyway." | Ask one concise clarification question before choosing. |
