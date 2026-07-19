---
name: using-dev-cadence
description: Use when a Dev Cadence-installed repository receives product discovery, architecture design, requirements, development work, active-task follow-up, testing, verification, or commit/checkpoint requests.
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

## Configuration Identity And Worktree Continuation

Before any workflow produces user-facing guidance, documents, records, or summaries, resolve `.dev-cadence.yaml` from the target repository configuration source.

When the current workspace is the primary checkout, use `.dev-cadence.yaml` at that checkout root. When the current workspace is a linked worktree, resolve the primary checkout's Git location with:

```bash
COMMON_GIT_DIR="$(git rev-parse --path-format=absolute --git-common-dir)"
PRIMARY_ROOT="$(dirname "$COMMON_GIT_DIR")"
CONFIG_SOURCE="$PRIMARY_ROOT/.dev-cadence.yaml"
```

Use the following configuration precedence for a Delivery Workflow: the active run snapshot first, then the primary checkout configuration, then the current checkout configuration when it is the primary checkout, and finally the documented fallback.

When the primary checkout configuration exists and the current workspace is a different worktree, set `CONFIG_TARGET="$PWD/.dev-cadence.yaml"`. If `CONFIG_TARGET` is absent or differs from `CONFIG_SOURCE`, run `cp -f "$CONFIG_SOURCE" "$CONFIG_TARGET"`, then verify the result with `test -f "$CONFIG_TARGET" && cmp -s "$CONFIG_SOURCE" "$CONFIG_TARGET"`. A propagation failure must stop workflow output; use the active run snapshot if one exists, otherwise report the environment failure instead of silently selecting English. Do not copy the config into `.dev-cadence/` or commit it.

For an active Delivery Workflow, record the resolved `output_language`, configuration source identity as `target repository root/.dev-cadence.yaml`, and whether worktree propagation occurred in the manifest. A resumed run must use this snapshot before applying any other source or fallback rule.

If no valid config is available and no active snapshot exists, use English and make the fallback visible in the first user-visible summary by stating that the config was missing or unsupported and the default `en` was selected.

Before creating or updating Dev Cadence-managed Markdown documents, records, reports, examples, or summaries, read and follow:

```text
.dev-cadence/skills/document-conventions/SKILL.md
```

That shared skill owns common document presentation rules. Do not duplicate its complete semantic mapping in this entry skill or individual business workflow skills.

## Shared Commit Capability

After selecting or restoring a Dev Cadence workflow, or directly routing a Dev Cadence shared capability, use the installed shared commit capability for every commit managed by that context:

```text
.dev-cadence/skills/git-commit/SKILL.md
```

The owning Workflow or shared capability must determine commit timing and scope, run applicable checks, and stage exactly one commit unit before invoking `git-commit`. The shared capability must not select a workflow, stage files, run tests, or replace workflow records and evidence.

Do not invoke the installed `git-commit` for an ordinary repository commit that is not managed by a Dev Cadence workflow or shared capability. Handle that request through the target repository's ordinary Git rules.

When dispatching a subagent that may create a commit, include `.dev-cadence/skills/git-commit/SKILL.md`, the owning Dev Cadence context, and the staged-only constraint in the subagent task brief. The `<SUBAGENT-STOP>` routing boundary does not remove this dispatch responsibility.

For repository-level unresolved-question maintenance, read and follow:

```text
.dev-cadence/skills/open-question-registry/SKILL.md
```

That shared capability owns Registry discovery, on-demand creation, entry fields, single-body ownership, migration, terminal retention, and no-Change-Log rules. Do not duplicate its complete lifecycle contract in this entry skill or individual business workflows.

## Available Flows

| User request | Flow |
| --- | --- |
| Explore a product idea, create the first PRD or Business Architecture, update an existing product-design baseline, or create or maintain a product-level User Journey and its Feature Definitions through Discovery | `.dev-cadence/skills/discovery/SKILL.md` |
| Plan a portfolio from confirmed User Journey, PRD, and Business Architecture assets, maintain a Story Map, or register a single clear Story, Task, or Bug work item | `.dev-cadence/skills/work-item-planning/SKILL.md` |
| Analyze, clarify, or confirm one Story, Task, or Bug definition, or a selected batch of Story, Task, or Bug definitions, before downstream delivery work | `.dev-cadence/skills/work-item-analysis/SKILL.md` |
| Explicitly design, propose, or review architecture for a stated goal | `.dev-cadence/skills/architecture-design/SKILL.md` |
| Add a new user-visible or system-visible feature | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Change existing user-visible or system-visible feature behavior | `.dev-cadence/skills/feature-dev/SKILL.md` |
| Report a bug, error, failing test, regression, or unexpected behavior | `.dev-cadence/skills/bug-fix/SKILL.md` |
| Improve internal structure, modularity, maintainability, testability, or dependencies without intentionally changing expected behavior | `.dev-cadence/skills/refactor/SKILL.md` |

## Workflow Record Models

Every Dev Cadence workflow belongs to exactly one record model:

- **Asset Workflow:** Discovery, Work Item Planning, Work Item Analysis, and Architecture Design.
- **Delivery Workflow:** Feature Dev, Bug Fix, and Refactor.

Asset Workflows only create or update durable authoritative assets under `docs/`. They may use analysis steps and user confirmation gates in the current conversation, but they must not create `build/dev-cadence/` run manifests, stage records, confirmation records, checkpoint commits, or other persistent copies of the workflow process.

Asset business facts belong in the authoritative asset itself. Use the asset's Version, Change Log, status, relationships, Open Questions, and Rejected Directions to preserve current conclusions, changes, unresolved issues, rejected choices, and durable context. Asset Workflows must not write commit hashes, approver identities, approval timestamps, or workflow run status into business assets. Their Git commits follow the user's request and the target repository's ordinary commit rules; do not describe those commits as workflow checkpoints.

Delivery Workflows maintain a complete delivery evidence chain under `build/dev-cadence/<workflow>/<task-slug>/`. Keep requirements, diagnosis, or refactor-scope records as part of the active delivery run, together with solution, implementation plan, implementation, review, testing, business acceptance, Git integration, and cleanup evidence. These records restore the implementation context and bind confirmed inputs to code and verification; they are not competing long-term business assets.

When adding a new workflow, classify it as exactly one record model before defining its records. It must not mix the models by persisting both a durable authoritative asset and duplicate process facts for the same Asset Workflow, or by removing evidence required to recover and verify a Delivery Workflow.

## Shared Asset Capabilities

Open Question Registry maintenance is a shared asset capability, not a six-stage business workflow.

- When the user directly asks to view or maintain repository-level Open Questions, read `.dev-cadence/skills/open-question-registry/SKILL.md` and perform that bounded asset operation without starting feature-dev, bug-fix, refactor, or discovery solely for the maintenance request.
- When an active workflow finds a question that the current artifact cannot reasonably hold, reuse the Registry skill and then return to the active workflow.
- If the request also asks to change product behavior, fix a defect, refactor code, or create the first product-design baseline, select the matching business workflow first; Registry maintenance remains a supporting operation within that workflow.
- The Registry and authoritative asset must be updated in the same operation when any active workflow performs a create, modify, migrate, or status change for an Open Question in a confirmed asset update. It must not advance the current confirmation gate with only one side updated.
- A Delivery Workflow record under `build/` must not become the Registry's long-lived authoritative source. When no durable authority exists, the Registry temporarily owns the full body and the delivery record keeps the same `Q-nnn` plus a Registry link.
- Do not promote an assumption, risk, or review finding to an Open Question unless the workflow explicitly identifies it as a question that must be tracked.
- Do not infer a Registry operation merely because unresolved questions exist in repository documents. Repository state alone does not authorize asset changes.

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
| Incremental Discovery | "Update our existing PRD with the newly confirmed pricing model." | ✅ Select `discovery` when repository discovery also finds a credible product-design candidate; the skill then confirms the authoritative source before editing. If no credible candidate exists, do not silently switch to initial Discovery. |
| Product Journey | "Define the checkout journey and the product capabilities it requires." | ✅ Select `discovery` to create or maintain the product-level User Journey and its Feature Definitions because Discovery owns that product-design baseline. |
| Work Item Portfolio Planning | "Use our confirmed User Journey, PRD, and Business Architecture to plan the Story Map, Milestones, and next batch of Stories." | ✅ Select `work-item-planning` because the user wants portfolio planning based on confirmed product-design assets. `work-item-planning` is an Asset Workflow and must not create Delivery run records. |
| Direct Work Item Intake | "Register a clear Bug card and attach it to the existing Backlog." | ✅ Select `work-item-planning` when the requested outcome is creating or maintaining a single clear Story, Task, or Bug card rather than implementing the change. |
| Work Item Analysis | "Analyze, clarify, or confirm one Story, Task, or Bug definition, or a selected batch of Story, Task, or Bug definitions before implementation." | ✅ Select `work-item-analysis` because the user wants detailed work-item definition analysis rather than portfolio planning or delivery execution. After analysis, hand confirmed work items to `feature-dev`, `bug-fix`, or `refactor`; `work-item-analysis` does not replace downstream delivery workflows. |
| Discovery Boundary | "The business meaning of this Feature is still unclear; define the Feature first, then split the Stories." | ✅ Select `discovery` because Discovery owns product-design baselines, User Journey, and Feature identity. `work-item-planning` only references confirmed Features and must not define or reinterpret them. |
| Architecture Design | "Design the target architecture for our payment-event ingestion goal." | ✅ Select `architecture-design` because the user explicitly requests architecture for a stated goal. |
| Architecture Repository State | "This repository has no architecture document." | ❌ Do not start `architecture-design` because repository state does not establish an architecture-design goal. |
| Delivery Handoff | "These Stories are confirmed; start implementing the export command." | ✅ Select `feature-dev`, `bug-fix`, or `refactor` after the work item is confirmed and the user now wants delivery. `work-item-planning` prepares and hands off work items; it does not replace delivery workflows' implementation, diagnosis, or refactor records. |
| Delivery Solution | "Add payment-event ingestion and design its implementation." | ✅ Select `feature-dev`; `architecture-design` does not replace the delivery workflow's task-scoped Technical Solution. |
| Feature | "Please implement a Feature that adds an export command producing a JSON report." | ✅ Select `feature-dev` because the user wants new system-visible behavior. |
| Bug Fix | "The export command is documented to include timestamps, but they are missing." | ✅ Select `bug-fix` because already expected behavior is not working. If the user instead asks to intentionally change expected behavior, select `feature-dev`. |
| Refactor | "Extract the parser into smaller modules without intentionally changing expected behavior." | ✅ Select `refactor` because the requested outcome is behavior-preserving structural improvement. If the request also adds behavior, route that behavior change through `feature-dev` or clarify the primary outcome. |
| Ordinary Request | "Explain what this configuration field means." | ❌ Handle normally because explanation alone does not request product discovery or a software change. |
| Open Question Registry | "Show me the repository-level Open Questions and register this cross-document issue." | ✅ Use the shared `open-question-registry` capability because the requested outcome is bounded maintenance of the unresolved-question index, not a delivery workflow. |
| Repository State Only | "This repository has no PRD." | ❌ Do not start Discovery from repository state alone. A missing PRD does not establish product-exploration intent. Existing code, work-item cards, or tests likewise do not trigger a workflow without a matching user goal. |
| Ambiguous Mixed Intent | "Clean up this module and change how retries work." | ❓ Ask one necessary routing clarification question because the request mixes behavior-preserving cleanup and an expected-behavior change without identifying the primary outcome. |

Keep this entry selector as the single authority for cross-workflow routing examples. Individual workflow skills retain their own applicability, stop conditions, and necessary local Red Flags; they do not copy this complete matrix.

When adding a new workflow, review whether a representative request or adjacent boundary here needs one concise example. Do not add an example when the new workflow introduces no real routing ambiguity.

## Flow Priority

When multiple flows might apply, choose the process flow before any implementation or domain skill.

Use `discovery` for broad product ideas, business problems, first-time product definition, first-time PRD or Business Architecture creation, or an explicit intent to update an existing product-design baseline when repository discovery finds a credible candidate. Incremental Discovery requires both update intent and a credible or trusted candidate; repository state alone does not trigger it. If update intent exists but no candidate is found, do not silently switch to initial Discovery.
Creating or maintaining a product-level User Journey and its Feature Definitions selects `discovery`; Discovery owns that product-design baseline.
Do not force a clear Feature, Bug, or Refactor request through Discovery. Direct development requests continue to their matching delivery workflow.
Discovery owns both initial creation and confirmed incremental product-design updates. Read its skill before selecting a mode; do not infer authority from a file name alone.
If the user wants to change Feature meaning, User Journey order, PRD conclusions, or Business Architecture content before planning work items, return to `discovery` instead of patching product-design facts inside `work-item-planning`.

Use `architecture-design` only when the user explicitly asks for architecture design, an architecture proposal, or an architecture review for a stated goal. Do not infer it from repository state, technical content, Discovery activity, or a delivery workflow's need for a local solution. The standalone asset may inform delivery work, but `architecture-design` does not replace Feature Dev's Technical Solution, Bug Fix's Repair Solution, or Refactor's Refactor Solution.

Use `work-item-planning` when the user wants an Asset Workflow that turns confirmed product-design assets into planning assets, such as Story Map, Milestone, or Story/Task/Bug cards, or when the user wants to register one clear work item without starting delivery. Do not auto-start `work-item-planning` merely because the repository already contains Story cards, Task cards, Bug cards, Backlog entries, or a Story Map; repository state alone does not trigger the workflow.
`work-item-planning` owns planning assets and work-item registration, not Feature definition or delivery execution. Keep the full cross-workflow routing matrix only in this entry skill; do not copy the complete matrix into `.dev-cadence/skills/work-item-planning/SKILL.md`.
After a work item is confirmed and the user asks to implement, repair, or refactor it, hand off to `feature-dev`, `bug-fix`, or `refactor` according to the requested delivery outcome.

Use `work-item-analysis` when the user wants an Asset Workflow that analyzes, clarifies, or confirms one Story, Task, or Bug definition, or a selected batch of Story, Task, or Bug definitions, before downstream delivery. `work-item-analysis` owns detailed work-item definition analysis, Story `Ready` decisions, Task maturity clarification, and Bug intake clarification without technical root cause analysis. It does not replace `work-item-planning` portfolio structure, Story Map or Backlog ordering, `discovery` product-level Feature definition, or downstream `feature-dev`, `bug-fix`, and `refactor` execution. After analysis, hand confirmed work items to `feature-dev`, `bug-fix`, or `refactor` according to the requested delivery outcome.

Use `bug-fix` when the existing expected behavior should already work and the user reports that it does not.
Use `feature-dev` when the user asks to implement a Feature, add behavior, or intentionally change expected behavior.
Use `refactor` when the user asks to improve internal structure without intentionally changing expected behavior.
For Feature requests, intent determines the route: route by the requested outcome, not by the isolated word "Feature".
If a request mixes two or more of a defect report, requested behavior change, and structural cleanup, ask which outcome is primary before choosing among `bug-fix`, `feature-dev`, and `refactor`. Do not require all three request types to be present before clarifying the flow.

## Work Item Intake And Claiming

Work-item claiming is an entry orchestration step owned by `using-dev-cadence`. It must reuse `work-item-planning`, `work-item-analysis`, and the existing Delivery Workflows; it must not create a new claiming workflow or shared claiming skill.

Only an explicit implementation, repair, or refactor request may claim a work item. Discussion, evaluation, work-item planning, card maintenance, ordinary status queries, and work-item analysis must not claim or change a card to `In Progress`.

When a user explicitly asks to continue implementation from `docs/backlog.md`, the row order in `待处理` is the sole authoritative selection order. If the first pending item cannot proceed, complete a confirmed planning reorder before selecting a later item; do not silently skip it.

After the item is selected and before switching a task branch or creating a worktree, claim it by atomically synchronizing the authoritative card and its Backlog row to `In Progress`. A claim uses the current card Version for its Change Log important event and does not increment the card Version for an execution-status-only change. When the status transition is important, append that event according to `.dev-cadence/skills/contracts/change-log.md`; a claim must be idempotent and must not append a duplicate Change Log event. A card already in `In Progress` must not be claimed again in the same request. Only after the card and Backlog write succeeds may the entry prepare the dedicated branch or worktree and route to the downstream workflow.

Claim the item before switching the task branch. Claim the item before creating the worktree. The card and Backlog must be updated atomically.

Use the default Story route `Draft Story -> work-item-analysis -> Ready Story -> feature-dev`. `feature-dev` accepts only a user-confirmed `Ready Story`. A Task does not need to reach `Ready`; its Delivery Workflow must confirm its goal, scope, and completion conditions in the first stage. A Bug may enter `bug-fix` without `Ready`, complete reproduction, or a known root cause because diagnosis owns those questions.

When a requested implementation is missing a card, route by intent: planning or registration goes to `work-item-planning`, work-item definition analysis goes to `work-item-analysis`, and direct Bug investigation goes to `bug-fix` to create or complete its Bug card. Do not create a duplicate ID or parallel card when an authoritative card exists.

The selected downstream Delivery Workflow must record the exact card path, work-item type, current Version, and selected scope in its first stage record. Card Version or visible-fact conflicts stop the run for a user decision; later substantive card revisions use Active Task Change Handling to return to the earliest affected stage. Delivery lifecycle writeback must preserve Backlog row order, remain idempotent, and never turn a Workflow's internal stage into a work-item status.

## Active Workflow Continuation

Before choosing or starting a new Dev Cadence flow, identify its record model and check for an unfinished Dev Cadence workflow using the matching continuation source.

- For a Delivery Workflow, use the conversation and existing run manifest to restore the current task, confirmed records, stage, code identity, verification evidence, and integration state.
- For an Asset Workflow, use the current conversation, user goal, and authoritative asset to identify whether the request continues the same asset change. Do not create a manifest or process record solely to make continuation possible.

If there is an unfinished workflow and the user's latest request is a change, clarification, product-design adjustment, implementation adjustment, test feedback, review feedback, or acceptance feedback for that same task, continue the current workflow run. Do not create a new workflow run, task slug, requirements document, solution document, diagnosis document, or repair solution document.

If there is an unfinished Delivery Workflow and the user asks to commit, save, or checkpoint current changes, continue the current workflow run and read its Git Checkpoints rules. Commit the in-scope changes under the active workflow's Git rules, then continue from the same business stage; the commit does not confirm or complete the stage.

If there is an unfinished Asset Workflow and the user asks to commit or save the asset changes, follow the target repository's ordinary Git rules and the user's request. Do not create a checkpoint record or add workflow metadata to the asset. The commit does not replace any user confirmation gate required by the Asset Workflow.

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
