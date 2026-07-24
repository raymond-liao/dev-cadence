---
name: using-dev-cadence
description: Use when a Dev Cadence-installed repository receives work-item intake, single-card analysis, architecture design, development work, active-task follow-up, testing, verification, or commit/checkpoint requests.
---

# Using Dev Cadence

<ORDINARY-SUBAGENT-STOP>
If you are an ordinary subtask agent and are not explicitly designated as the primary execution subagent for the complete Dev Cadence request, do not execute this entry skill. Execute only the bounded task brief.
</ORDINARY-SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance an installed Dev Cadence flow applies to the user's development request, you ABSOLUTELY MUST read the matching flow skill.

IF A DEV CADENCE FLOW APPLIES TO THE TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

Use this skill before any work-item intake, requirements analysis, architecture design, development, testing, verification, or managed Git response or action in a repository with Dev Cadence installed.

Dev Cadence governs implementation work. It does not perform product discovery, PRD creation, User Journey analysis, Feature definition, Story Map, Milestone, MVP, or portfolio planning. Handle those requests outside Dev Cadence unless another installed system owns them.

## Primary Execution Delegation

Before reading a candidate workflow skill or exploring the repository, the user-facing main session must delegate the complete Dev Cadence request when the platform supports internal subagents.

A primary execution subagent is explicitly designated in the dispatch brief to execute the complete Dev Cadence request. It must read this entry skill, select or restore the workflow, and may dispatch ordinary bounded subtasks with the role boundary and applicable commit constraints.

An ordinary subtask agent must execute only its bounded brief; it must not select or restore a Dev Cadence workflow or recursively delegate the complete request.

The primary execution subagent must continuously perform all non-interactive work for every installed Dev Cadence workflow. This includes investigation, draft preparation, repository changes, implementation, tests, review, verification, stage records, and Git operations already authorized by the active workflow.

Return control to the main session only for a user decision, a blocker that requires user-provided information, or task completion. Return only the current conclusion, complete user options, the effect of each option, risks, and repository-relative evidence paths. Do not return process logs, diffs, or intermediate reasoning.

An Asset Workflow may keep an unconfirmed draft only in a system temporary or cache location clearly marked non-authoritative. Do not modify an authoritative asset before its required user confirmation. Do not promise that temporary or cache content survives cleanup, machine changes, or runtime loss.

Existing user confirmation, Business Acceptance, Completion, and Git authorization rules remain in force. Explicit user authorization remains required for merge, PR, push, discard, and branch deletion.

Return a user response to the original primary execution subagent when it remains available; otherwise designate a new primary execution subagent and restore from existing file evidence.

When the platform does not support internal subagents, the main session must execute the workflow directly.

## The Rule

Check installed Dev Cadence flows before any covered response or action, including clarification questions, repository exploration, implementation, tests, commits, or status claims.

If an installed flow applies, read it completely and follow it. If no installed flow applies, handle the request normally.

## Configuration Identity And Worktree Continuation

Before any workflow produces user-facing guidance, documents, records, or summaries, resolve `.dev-cadence.yaml` from the target repository configuration source.

When the current workspace is the primary checkout, use `.dev-cadence.yaml` at that checkout root. When the current workspace is a linked worktree, resolve the primary checkout with:

```bash
COMMON_GIT_DIR="$(git rev-parse --path-format=absolute --git-common-dir)"
PRIMARY_ROOT="$(dirname "$COMMON_GIT_DIR")"
CONFIG_SOURCE="$PRIMARY_ROOT/.dev-cadence.yaml"
```

Use this precedence for a Delivery Workflow: active run snapshot, primary checkout configuration, current checkout configuration when it is the primary checkout, then documented fallback.

When the primary configuration exists and the current workspace is a different worktree, set `CONFIG_TARGET="$PWD/.dev-cadence.yaml"`. If absent or different, run `cp -f "$CONFIG_SOURCE" "$CONFIG_TARGET"`, then verify `test -f "$CONFIG_TARGET" && cmp -s "$CONFIG_SOURCE" "$CONFIG_TARGET"`. Propagation failure must stop workflow output; use an active snapshot if one exists, otherwise report the environment failure. Do not copy config into `.dev-cadence/` or commit it.

For an active Delivery Workflow, record resolved `output_language`, configuration identity as `target repository root/.dev-cadence.yaml`, and whether worktree propagation occurred in the manifest. A resumed run uses this snapshot first.

If no valid config or snapshot exists, use English and make the fallback visible in the first user-visible summary by stating that the config was missing or unsupported and the default `en` was selected.

Before creating or updating Dev Cadence-managed Markdown documents, records, reports, examples, or summaries, read and follow:

```text
.dev-cadence/references/document-conventions/SKILL.md
```

That shared skill owns common document presentation rules. Do not duplicate its complete semantic mapping in this entry skill or individual business workflow skills.

## Shared Commit Capability

After selecting or restoring a workflow or shared capability, use:

```text
.dev-cadence/skills/git-commit/SKILL.md
```

for every managed commit. The owning context determines timing and scope, runs checks, and stages exactly one commit unit before invoking `git-commit`. The commit capability must not select a workflow, stage files, run tests, or replace workflow records.

Use `.dev-cadence/skills/git-commit/SKILL.md` only for a commit managed by a Dev Cadence Workflow or shared capability.

Do not invoke the installed `git-commit` for an ordinary repository commit that is not managed by a Dev Cadence workflow or shared capability. Handle that request through the target repository's ordinary Git rules.

When dispatching a subagent that may create a commit, include `.dev-cadence/skills/git-commit/SKILL.md`, the owning Dev Cadence context, and the staged-only constraint in the subagent task brief.

## Shared Question Capability

For repository-level unresolved-question maintenance, use:

```text
.dev-cadence/skills/open-question-registry/SKILL.md
```

That shared capability owns Registry discovery, on-demand creation, entry fields, single-body ownership, migration, terminal retention, and no-Change-Log rules. Do not duplicate its complete lifecycle contract in this entry skill or individual business workflows.

Registry maintenance covers only Dev Cadence-owned delivery and architecture assets; it does not authorize reading or modifying product-analysis assets.

## Available Flows

| User request | Flow |
| --- | --- |
| Create one Story, Task, or Bug; register a conforming existing card; or maintain Backlog order or lifecycle | `.dev-cadence/workflows/backlog/SKILL.md` |
| Analyze, clarify, or confirm exactly one existing Story, Task, or Bug definition | `.dev-cadence/workflows/work-item-analysis/SKILL.md` |
| Explicitly design, propose, or review architecture for a stated goal | `.dev-cadence/workflows/architecture-design/SKILL.md` |
| Add or intentionally change user-visible or system-visible behavior | `.dev-cadence/workflows/feature-dev/SKILL.md` |
| Repair existing expected behavior that is not working | `.dev-cadence/workflows/bug-fix/SKILL.md` |
| Improve internal structure without intentionally changing expected behavior | `.dev-cadence/workflows/refactor/SKILL.md` |

## Workflow Record Models

Every Dev Cadence workflow belongs to exactly one record model:

- **Asset Workflow:** Backlog, Work Item Analysis, Architecture Design.
- **Delivery Workflow:** Feature Dev, Bug Fix, Refactor.

Asset Workflows only create or update durable authoritative assets under `docs/`. They may use analysis steps and user confirmation gates in the current conversation, but they must not create `build/dev-cadence/` run manifests, stage records, confirmation records, checkpoint commits, or other persistent copies of the workflow process.

Asset business facts belong in the authoritative asset itself. Use the asset's Version, Change Log, status, relationships, Open Questions, and Rejected Directions to preserve current conclusions, changes, unresolved issues, rejected choices, and durable context. Asset Workflows must not write commit hashes, approver identities, approval timestamps, or workflow run status into business assets. Their Git commits follow the user's request and the target repository's ordinary commit rules; do not describe those commits as workflow checkpoints.

Delivery Workflows maintain a complete delivery evidence chain under `build/dev-cadence/<workflow>/<task-slug>/`. Keep requirements, diagnosis, or refactor-scope records as part of the active delivery run, together with solution, implementation plan, implementation, review, testing, business acceptance, Git integration, and cleanup evidence. These records restore the implementation context and bind confirmed inputs to code and verification; they are not competing long-term business assets.

When adding a new workflow, classify it as exactly one record model before defining its records. It must not mix the models by persisting both a durable authoritative asset and duplicate process facts for the same Asset Workflow, or by removing evidence required to recover and verify a Delivery Workflow.

## Shared Asset Capabilities

Open Question Registry maintenance is a shared asset capability, not a business workflow.

- When the user directly asks to view or maintain repository-level Open Questions, read `.dev-cadence/skills/open-question-registry/SKILL.md` and perform that bounded asset operation without starting a Delivery Workflow or Backlog solely for the maintenance request.
- When an active workflow finds a question that the current artifact cannot reasonably hold, reuse the Registry skill and then return to the active workflow.
- If the request also asks to admit work, change behavior, fix a defect, or refactor code, select the matching workflow first; Registry maintenance remains a supporting operation within that workflow.
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

| Category | Representative request | Decision |
| --- | --- | --- |
| New Work Item | "Register a Story for exporting reports." | ✅ Select `backlog` to create the card and its Backlog row. |
| Conforming Existing Card | "This Ready Story already follows our card format; add it and implement it." | ✅ Select `backlog` to validate and register it before claim; do not recreate or reanalyze it. |
| Nonconforming Existing Card | "Use this external ticket, but it does not match our card contract." | ✅ Select `backlog`, preserve the source, and use the standard New Request path. |
| Single-card Analysis | "Clarify S-042 and determine whether it is Ready." | ✅ Select `work-item-analysis`; analyze only that card. |
| Product Analysis | "Create a PRD, User Journey, and Story Map." | ❌ No Dev Cadence workflow applies; product analysis is outside this package. |
| Architecture Design | "Design the target architecture for payment ingestion." | ✅ Select `architecture-design`. |
| Architecture Repository State | "This repository has no architecture document." | ❌ Do not start `architecture-design`; repository state does not establish an architecture goal. |
| Feature | "Implement an export command." | ✅ Ensure one admitted card exists, then select `feature-dev`. |
| Bug Fix | "The export command omits timestamps." | ✅ Ensure one admitted Bug exists, then select `bug-fix`. |
| Refactor | "Extract the parser without behavior change." | ✅ Ensure one admitted card exists, then select `refactor`. |
| Ordinary Request | "Explain this configuration field." | ❌ Handle normally because explanation alone does not request implementation work. |
| Open Question Registry | "Show me the repository-level Open Questions." | ✅ Use the shared `open-question-registry` capability. |
| Mixed Intent | "Clean up retries and change their behavior." | ❓ Ask one necessary routing clarification question before selecting a Delivery Workflow. |

Keep this entry selector as the single authority for cross-workflow routing examples. Individual workflow skills retain their own applicability, stop conditions, and necessary local Red Flags; they do not copy this complete matrix.

When adding a new workflow, review whether a representative request or adjacent boundary here needs one concise example. Do not add an example when the new workflow introduces no real routing ambiguity.

## Flow Priority

Use `backlog` for work-item admission and Backlog maintenance. It owns card creation, existing-card contract validation, Backlog registration, Priority, planning relationships, lifecycle sections, and pending order. It does not perform detailed single-card analysis or delivery.

Use `work-item-analysis` only for exactly one existing conforming card. It owns detailed definition and Story `Ready` decisions, Task maturity clarification, and Bug intake clarification without technical root cause. It does not create missing cards or change Backlog order.

A conforming existing card may bypass creation and Work Item Analysis only when `backlog` verifies its complete card contract and downstream maturity. It must still enter Backlog before claim. A nonconforming supplied card is preserved and treated as New Request input; do not normalize it in place.

Use `architecture-design` only when the user explicitly asks for Architecture Design, an architecture proposal, or an architecture review for a stated goal. Repository state does not establish that goal. The standalone asset may inform delivery work, but `architecture-design` does not replace Feature Dev's Technical Solution, Bug Fix's Repair Solution, or Refactor's Refactor Solution.

Use `bug-fix` for broken existing expected behavior, `feature-dev` for new or intentionally changed behavior, and `refactor` to improve internal structure without intentionally changing expected behavior.

If a request mixes two or more of a defect report, requested behavior change, and structural cleanup, ask which outcome is primary before choosing among `bug-fix`, `feature-dev`, and `refactor`.

## Work Item Intake And Claiming

Work-item claiming is an entry orchestration step owned by `using-dev-cadence`. It must reuse `backlog`, `work-item-analysis`, and the existing Delivery Workflows; it must not create a new claiming workflow or shared claiming skill.

Only an explicit implementation, repair, or refactor request may claim a work item. Discussion, evaluation, Backlog maintenance, ordinary status queries, and Work Item Analysis must not claim or change a card to `In Progress`.

Before claim, verify that one conforming authoritative card and matching `docs/delivery/backlog.md` row exist. If either is absent, route to `backlog`. If a supplied card is nonconforming, route it to `backlog` and use the standard New Request path. Do not create or repair a card inside a Delivery Workflow.

When a user explicitly asks to continue implementation from `docs/delivery/backlog.md`, the row order in `待处理` is the sole authoritative selection order. If the first pending item cannot proceed, complete a confirmed `backlog` reorder before selecting a later item; do not silently skip it.

Before any claim write, use this ordered intake matrix: selection -> resolve its work-item type, visible status, and (for a Story) maturity -> determine eligibility -> claim only an eligible item. A `Draft Story` must enter `work-item-analysis` and must not be claimed or changed to `In Progress` before analysis and explicit user confirmation of `Ready Story`. A user-confirmed `Ready Story` is eligible to claim for an explicit implementation request and routes to `feature-dev`; `feature-dev` accepts only a user-confirmed `Ready Story`. A `Task` does not need `Ready` and is eligible for its explicit Delivery request; its Delivery Workflow confirms goal, scope, and completion conditions in the first stage. A `Bug` is eligible for a direct repair request without `Ready`, complete reproduction, or a known root cause; it may enter `bug-fix` without `Ready` because diagnosis owns those questions. Discussion, evaluation, Backlog maintenance, status queries, and Work Item Analysis are ineligible and must not claim.

After the item is selected and before switching a task branch or creating a worktree, resolve and verify the authoritative base branch/ref configured for the target repository; do not infer it from the primary checkout directory. Then claim it by atomically synchronizing the authoritative card and `docs/delivery/backlog.md` row to `In Progress` in that primary checkout regardless of `worktree.enabled`. A claim uses the current card Version for its Change Log important event and does not increment the card Version for an execution-status-only change. A claim must be idempotent and must not append a duplicate Change Log event. A card already `In Progress` must not be claimed again in the same request. Before either task workspace is created, write and record a verifiable claim commit containing the atomic card and Backlog claim, then verify that the recorded claim commit advances that exact authoritative base ref; this lifecycle handoff commit is neither an implementation commit nor a stage checkpoint commit.

The workspace preparation must complete before the entry routes downstream. When `worktree.enabled: true`, perform the primary checkout claim write, persist the claim commit, verify that the claim commit advances the authoritative base ref, then immediately create or verify the task worktree from that claim commit. Handle the create-worktree path separately from the reuse-worktree path. Only when this run actually creates the worktree successfully, then validates the exact newly-created `git worktree list --porcelain` stanza, may the handoff say `Created By Current Run: yes`. Capture the repository-relative workspace path, full `refs/heads/...` branch ref, and creation HEAD SHA from that exact newly-created stanza before routing to the Delivery Workflow. Reuse, externally managed workspace, disabled worktree, or any unprovable creation result must hand off `Created By Current Run: no`. Do not infer creation ownership from `worktree.enabled`, configured directory, workspace location, branch name, or a pre-existing worktree registration. When `worktree.enabled: false`, perform the primary checkout claim write, persist the claim commit, verify that the claim commit advances the authoritative base ref, then immediately prepare the dedicated task branch from that claim commit and must not create a worktree. Any failure of primary-checkout writing, claim persistence or commit, authoritative-base-ref advancement, workspace baseline, card Version, `In Progress` status, or matching Backlog row verification must stop: when `worktree.enabled: true`, do not create or verify a worktree and do not route downstream; when `worktree.enabled: false`, do not prepare a dedicated branch and do not route downstream. Verify in the selected workspace that the claimed card Version matches the authoritative card Version, along with `In Progress` status and the matching Backlog row, before routing any downstream Delivery Workflow. Do not begin Requirements, Solution, Plan, checkpoint, or implementation work before this handoff completes.

Pass this immutable creation-evidence handoff to the selected Delivery Workflow:

```text
Created By Current Run: yes|no
Workspace Path: <repository-relative path|not_applicable>
Task Branch Ref: <refs/heads/...|not_applicable>
Creation HEAD SHA: <full SHA|not_applicable>
Evidence Source: git worktree list --porcelain
```

For `Created By Current Run: no`, use `not_applicable` for the ownership tuple values; do not reconstruct them from reuse state. This tuple must not authorize deletion. When a cleanup verifier rejects it as `not_owned`, follow deny semantics: return `discard_blocked` and retain the worktree, task branch, and active run records.

Each Delivery Workflow must preserve this immutable creation-evidence handoff separately from its Current-run Discard context. `Workspace Path` is created-worktree provenance only. For `Created By Current Run: no`, its `not_applicable` value must not populate or replace the Current-run Discard context's actual `Workspace path` classification.

Claim the item before switching the task branch. Claim the item before creating the worktree. The card and Backlog must be updated atomically.

Use the default Story route `Draft Story -> work-item-analysis -> Ready Story -> feature-dev`; the matrix above governs when a claim may occur along that route.

The selected downstream Delivery Workflow must record the exact card path, work-item type, current Version, Status, and selected scope in its first stage record. Card Version or visible-fact conflicts stop the run for a user decision; later substantive card revisions use Active Task Change Handling to return to the earliest affected stage. Delivery lifecycle writeback must preserve unrelated pending order, remain atomic and idempotent, and never turn a Workflow's internal stage into a work-item status.

## Active Workflow Continuation

Before choosing or starting a new Dev Cadence workflow, identify its record model and check for an unfinished Dev Cadence workflow using the matching continuation source.

- Delivery Workflow: restore from conversation and run manifest.
- Asset Workflow: restore from conversation, user goal, and authoritative asset without creating process records.

If there is an unfinished workflow and the user's latest request is a change, clarification, work-item adjustment, implementation adjustment, test feedback, review feedback, or acceptance feedback for that same task, continue the current workflow run. Do not create a new workflow run, task slug, requirements document, solution document, diagnosis document, or repair solution document.

If a request clearly exceeds the confirmed scope or repair boundary of the unfinished workflow, ask whether the user wants to expand the current task or start a separate task before creating records.

If there is an unfinished Delivery Workflow and the user asks to commit, save, or checkpoint current changes, continue the current workflow run and read its Git Checkpoints rules. Commit the in-scope changes under the active workflow's Git rules, then continue from the same business stage; the commit does not confirm or complete the stage.

If there is an unfinished Asset Workflow and the user asks to commit or save the asset changes, follow the target repository's ordinary Git rules and the user's request. Do not create a checkpoint record or add workflow metadata to the asset. The commit does not replace any user confirmation gate required by the Asset Workflow.

Only start a new Dev Cadence workflow when there is no unfinished workflow for the current task, the user explicitly asks for a new task, or the user confirms that an out-of-scope request should be handled separately.

## Decision Rules

1. If the request clearly matches an available workflow, read that workflow skill completely and follow it.
2. If the request might match an available workflow but is ambiguous, ask one concise clarification question before choosing.
3. If the request does not match any available workflow, handle it normally.

## ⚠️ Red Flags

| Thought | Reality |
| --- | --- |
| "This request needs a PRD first." | Product analysis is outside Dev Cadence; implementation admission depends on the card contract. |
| "The external card exists, so claim it." | `backlog` must validate and register it before claim. |
| "The card is close enough; normalize it." | Nonconforming cards use the standard New Request path. |
| "Analyze the whole Backlog." | Work Item Analysis handles exactly one card. |
| "A Bug can be created inside Bug Fix." | Missing cards route to `backlog` before Delivery. |
| "Priority lets me skip the first pending row." | `待处理` row order is authoritative until a confirmed reorder. |
| "This small change can skip the matching Delivery Workflow." | Installed workflows route by intended outcome, not perceived size. |
| "The user asked to commit, so the active workflow is complete." | A commit preserves progress; it does not replace the current business-stage confirmation. |
