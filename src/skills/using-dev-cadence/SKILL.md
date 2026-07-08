---
name: using-dev-cadence
description: Use when the user asks for development work in a repository with Dev Cadence installed.
---

# Using Dev Cadence

Use this skill before any development response or action in a repository with Dev Cadence installed.

Dev Cadence flows are explicit business workflows. Do not force a request into a flow just because the request is related to software.

## The Rule

Check installed Dev Cadence flows before repository exploration, implementation, or clarifying questions.

If an installed flow applies, you must use it.

If no installed flow applies, handle the request normally.

## Available Flows

| User request | Flow |
| --- | --- |
| Add a new user-visible or system-visible feature | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Change existing user-visible or system-visible feature behavior | `.dev-cadence/skills/feature-dev/SKILL.md` |

## Decision Rules

1. If the request clearly matches an available flow, read that flow skill completely and follow it.
2. If the request might match an available flow but is ambiguous, ask one concise clarification question before choosing.
3. If the request does not match any available flow, do not use a Dev Cadence flow. Handle it as a normal request.

## Red Flags

These thoughts mean STOP and check the installed Dev Cadence flows:

| Thought | Reality |
| --- | --- |
| "This is just a small development task." | Small development tasks still need flow checking. |
| "I need to inspect files before deciding." | Flow checking comes before repository exploration. |
| "This sounds related to features, so feature-dev applies." | `feature-dev` applies only to new features or changes to intended feature behavior. |
| "The user reported a bug, so feature-dev can handle it." | Bug reports do not use `feature-dev` unless the user asks to change intended behavior. |
| "There is no exact flow, but feature-dev is close enough." | Do not force requests into a mismatched Dev Cadence flow. |
| "I can mention future flows as options." | Only mention installed flows. |
| "The request is unclear, but I can choose a flow anyway." | Ask one concise clarification question before choosing. |
