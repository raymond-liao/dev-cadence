---
name: using-dev-cadence
description: Use when a Dev Cadence-installed repository receives product discovery, requirements, development work, active-task follow-up, testing, verification, or commit/checkpoint requests.
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

Use this skill before any product discovery, requirements, or development response or action in a repository with Dev Cadence installed.

Dev Cadence flows are explicit business workflows. Do not force a request into a flow just because the request is related to software.

## The Rule

Check installed Dev Cadence flows BEFORE any development response or action, including clarifying questions, repository exploration, implementation, test execution, commits, or status claims.

If an installed flow applies, read that flow skill completely and follow it exactly. If the selected flow turns out wrong for the situation, stop and choose the correct installed flow or handle the request normally.

If no installed flow applies, handle the request normally.

Before creating or updating Dev Cadence-managed Markdown documents, records, reports, examples, or summaries, read and follow:

```text
.dev-cadence/skills/document-conventions/SKILL.md
```

That shared skill owns common document presentation rules. Do not duplicate its complete semantic mapping in this entry skill or individual business workflow skills.

## Available Flows

| User request | Flow |
| --- | --- |
| Explore an incomplete product idea, business problem, or product direction and create the first PRD or Business Architecture | `.dev-cadence/skills/discovery/SKILL.md` |
| Add a new user-visible or system-visible feature | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Change existing user-visible or system-visible feature behavior | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Report a bug, error, failing test, regression, or unexpected behavior | `.dev-cadence/skills/bug-fix/SKILL.md` |
| Improve internal structure, modularity, maintainability, testability, or dependencies without intentionally changing expected behavior | `.dev-cadence/skills/refactor/SKILL.md` |

## Two-Stage Routing Decision

Route requests in two distinct stages:

1. **Stage 1: Discover candidates.** If there is even a 1% chance an installed workflow applies, identify and read each plausible candidate skill before taking development action.
2. **Stage 2: Select the action.** After reading the candidates, either select the matching workflow, choose a different matching workflow, ask one necessary routing clarification question, or handle the request normally when no installed workflow applies.

The 1% threshold is a candidate-reading rule. It does not automatically select or start a workflow. Base the final decision on the user's intended outcome and the candidate skills' boundaries, not on isolated keywords.

## Representative Routing Examples

These examples are representative intent decisions, not a keyword-matching list. The decision and reason remain authoritative when wording varies.

| Category | Representative request | Decision and reason |
| --- | --- | --- |
| Initial Discovery | "I have an incomplete product idea; help me explore it and create our first PRD." | ✅ Select `discovery` because the user wants product exploration and the first product-design baseline. |
| Incremental Discovery | "Update our existing PRD with the newly confirmed pricing model." | ❌ Do not use the installed initial `discovery` flow because an existing product-design baseline requires incremental reconciliation, which is not currently supported. Do not overwrite the baseline or pretend the missing workflow exists. |
| Feature | "Add an export command that produces a JSON report." | ✅ Select `feature-dev` because the user wants new system-visible behavior. |
| Bug Fix | "The export command is documented to include timestamps, but they are missing." | ✅ Select `bug-fix` because already expected behavior is not working. If the user instead asks to intentionally change expected behavior, select `feature-dev`. |
| Refactor | "Extract the parser into smaller modules without intentionally changing expected behavior." | ✅ Select `refactor` because the requested outcome is behavior-preserving structural improvement. If the request also adds behavior, route that behavior change through `feature-dev` or clarify the primary outcome. |
| Ordinary Request | "Explain what this configuration field means." | ❌ Handle normally because explanation alone does not request product discovery or a software change. |
| Repository State Only | "This repository has no PRD." | ❌ Do not start Discovery from repository state alone. A missing PRD does not establish product-exploration intent. Existing code, work-item cards, or tests likewise do not trigger a workflow without a matching user goal. |
| Ambiguous Mixed Intent | "Clean up this module and change how retries work." | ❓ Ask one necessary routing clarification question because the request mixes behavior-preserving cleanup and an expected-behavior change without identifying the primary outcome. |

Keep this entry selector as the single authority for cross-workflow routing examples. Individual workflow skills retain their own applicability, stop conditions, and necessary local Red Flags; they do not copy this complete matrix.

When adding a new workflow, review whether a representative request or adjacent boundary here needs one concise example. Do not add an example when the new workflow introduces no real routing ambiguity.

## Flow Priority

When multiple flows might apply, choose the process flow before any implementation or domain skill.

Use `discovery` for broad product ideas, business problems, first-time product definition, or first-time PRD or Business Architecture creation.
Do not force a clear Feature, Bug, or Refactor request through Discovery. Direct development requests continue to their matching delivery workflow.
This installed Discovery capability creates only the first product-design baseline. A request to update an existing PRD or existing product-design baseline is not supported by S-001; do not overwrite it or claim incremental versioning is available.

Use `bug-fix` when the existing expected behavior should already work and the user reports that it does not.
Use `feature-dev` when the user asks to add behavior or intentionally change expected behavior.
Use `refactor` when the user asks to improve internal structure without intentionally changing expected behavior.
If a request mixes two or more of a defect report, requested behavior change, and structural cleanup, ask which outcome is primary before choosing among `bug-fix`, `feature-dev`, and `refactor`. Do not require all three request types to be present before clarifying the flow.

## Active Workflow Continuation

Before choosing or starting a new Dev Cadence flow, check whether the conversation or existing run manifest indicates an unfinished Dev Cadence workflow for the current task.

If there is an unfinished workflow and the user's latest request is a change, clarification, product-design adjustment, implementation adjustment, test feedback, review feedback, or acceptance feedback for that same task, continue the current workflow run. Do not create a new workflow run, task slug, requirements document, solution document, diagnosis document, or repair solution document.

If there is an unfinished workflow and the user asks to commit, save, or checkpoint current changes, continue the current workflow run and read its Git Checkpoints rules. Commit the in-scope changes under the active workflow's Git rules, then continue from the same business stage; the commit does not confirm or complete the stage.

If the request clearly exceeds the confirmed scope or repair boundary of the unfinished workflow, ask whether the user wants to expand the current task or start a separate task before creating any new workflow run or document.

Only start a new Dev Cadence flow when there is no unfinished workflow for the current task, the user explicitly asks for a new task, or the user confirms that an out-of-scope request should be handled separately.

## Decision Rules

1. If the request clearly matches an available flow, read that flow skill completely and follow it.
2. If the request might match an available flow but is ambiguous, ask one concise clarification question before choosing.
3. If the request does not match any available flow, do not use a Dev Cadence flow. Handle it as a normal request.

Then announce the selected Dev Cadence flow and follow the flow skill exactly.

## ⚠️ Red Flags

These thoughts mean STOP and check the installed Dev Cadence flows:

| Thought | Reality |
| --- | --- |
| "This is just a small development task." | Small development tasks still need flow checking. |
| "This is only a broad product idea, so no workflow applies." | Initial product discovery uses `discovery`. |
| "The user wants an initial Business Architecture, so feature-dev is close enough." | First-time product-design baselines use `discovery`. |
| "An existing PRD needs changes, so I can run the initial Discovery flow again." | S-001 must not overwrite or incrementally reconcile an existing product-design baseline. |
| "I need to inspect files before deciding." | Flow checking comes before repository exploration. |
| "This sounds related to features, so feature-dev applies." | `feature-dev` applies only to new features or changes to intended feature behavior. |
| "The user reported a bug, so feature-dev can handle it." | Bug reports use `bug-fix` unless the user asks to change intended behavior. |
| "The user asked for a fix, so I can patch it directly." | Bug fixes must go through `bug-fix` when that flow is installed. |
| "The user said refactor, so feature-dev is close enough." | Behavior-preserving structural work uses `refactor`, not `feature-dev`. |
| "This refactor can include a small behavior improvement." | Intentional behavior changes must use `feature-dev`, or the user must split the work. |
| "There is no exact flow, but feature-dev is close enough." | Do not force requests into a mismatched Dev Cadence flow. |
| "I can mention future flows as options." | Only mention installed flows. |
| "The request is unclear, but I can choose a flow anyway." | Ask one concise clarification question before choosing. |
| "There is an active workflow, but this sounds like a fresh request." | Check whether it belongs to the unfinished task before starting anything new. |
| "The user asked to commit, so the active workflow is complete." | Commit the in-scope changes, then continue the unfinished workflow from its current stage. |
