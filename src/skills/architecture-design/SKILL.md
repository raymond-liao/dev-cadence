---
name: architecture-design
description: Use when a user explicitly asks for architecture design, an architecture proposal, or an architecture review for a stated goal.
---

# Architecture Design

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

Use this skill only when the user explicitly asks to design, propose, or review architecture for a stated goal. This is an Asset Workflow. It produces one durable, authoritative architecture document and does not perform software delivery.

Do not start Architecture Design merely because a repository contains technical content, a Discovery discussion mentions implementation, a delivery task needs a local solution, or architecture documentation is absent. Repository state and adjacent workflow activity must not automatically trigger this workflow.

Before creating or updating the architecture document, read and follow:

```text
.dev-cadence/skills/document-conventions/SKILL.md
```

## Configuration

Before producing the architecture document or user-facing summaries, read `.dev-cadence.yaml` from the target repository root.

- `output_language: en` uses English.
- `output_language: zh-CN` uses Simplified Chinese.
- If the file or value is missing or unsupported, use English.

Do not read user configuration from the replaceable `.dev-cadence/` package.

## Confirm The Design Goal

Before investigating or drafting, confirm the following as one coherent design brief:

- architecture goal and intended decision or outcome;
- design object;
- scope and non-scope;
- key constraints and quality expectations;
- expected detail level;
- output name derived from the goal.

Ask only questions whose answers materially change the design. When the user has explicitly delegated decisions, make conservative in-scope choices, record them as assumptions, and continue without manufacturing a confirmation interaction.

Generate `<goal-slug>` from the confirmed goal as a clear, portable kebab-case filename. The directory already expresses the document type, so do not append `architecture` by default. Retain that word only when it is necessary to avoid ambiguity. Confirm the proposed path before writing unless the user has delegated naming authority.

## Investigate The Necessary Current State

Investigate only the evidence needed to satisfy the confirmed goal. Depending on the target, inspect:

- current code;
- existing documentation;
- component boundaries;
- data and interfaces;
- external dependencies;
- deployment environment;
- quality attributes and operational constraints.

Trace important claims to available repository evidence. If the target repository or necessary current state is unavailable, continue from the user's background when a useful design is still possible, but state the missing evidence and record consequential assumptions in the architecture document.

Do not expand this investigation into product discovery, work-item decomposition, implementation planning, code changes, system testing, or deployment execution.

## Compare Meaningful Options

When materially different choices exist, compare two or three meaningful options. Explain the boundary, tradeoffs, constraints, risks, and fit with the confirmed goal for each option.

Do not invent alternatives merely to reach an option count. When no meaningful alternative exists, explain why and proceed with a single design.

Apply the shared solution-choice semantics exactly:

- `✅ Selected` identifies an option the user has confirmed or that delegated authority has explicitly selected;
- `❌ Rejected` identifies an option the user explicitly rejected;
- `❓ Decision Pending` identifies an unresolved choice;
- an unselected option that remains viable stays neutral.

A recommendation is not a selection. A recommended option must not be marked `✅ Selected` before user confirmation unless the user explicitly delegated the selection decision.

## Produce The Architecture Asset

The single required core output is:

```text
docs/architecture/<goal-slug>.md
```

Use repository-relative links and the shared document-reference rules. The document should contain only sections needed to understand and review the current goal. Relevant subjects can include:

- architecture goal, scope, and non-scope;
- current state and evidence;
- drivers, constraints, and assumptions;
- options and decision status;
- selected architecture;
- component responsibilities;
- data, interfaces, and interaction flows;
- external boundaries and dependencies;
- key technical decisions;
- quality attributes;
- risks, open questions, and validation approach.

Omit subjects that are not applicable. Do not create empty sections to imitate a fixed template.

Architecture diagrams are part of the architecture document, not a separate core output. Prefer Mermaid for diagrams. Use another diagram asset only when Mermaid cannot express the design clearly, and link or embed it from the same architecture document.

Before confirmation, the document must not claim that the architecture is approved. Preserve unresolved decisions as `❓ Decision Pending` or in `Open Questions`, and keep viable unselected options neutral.

## Confirmation And Changes

Present one consolidated confirmation summary containing the output path, selected option or pending decision, key decisions, and open questions. When confirmation changes the design, update the same architecture document rather than creating a process record or parallel authority.

For later changes to the same architecture goal, use the conversation and authoritative architecture document to restore context. Preserve durable history in the document's own Version and Change Log when the repository's document policy calls for them. Do not add workflow execution metadata to the asset.

## Record And Delivery Boundaries

Architecture Design must not create a `build/dev-cadence/` run manifest, stage records, confirmation records, checkpoint commits, or persistent copies of the workflow process. Its ordinary Git commits follow the user's request and the target repository's repository rules; do not describe them as workflow checkpoints.

Architecture Design must not modify code, create an implementation plan, decompose work items, run delivery testing, or perform release and deployment work.

This workflow does not replace a Delivery Workflow's Technical Solution, Repair Solution, or Refactor Solution. Those records remain scoped to the current delivery task and bind its implementation and verification evidence. An existing architecture asset may inform a delivery solution, but it does not confirm or complete that delivery stage.

## Completion Check

Before declaring the architecture design complete, verify:

- the confirmed goal, scope, non-scope, constraints, detail level, and output name are represented;
- necessary current-state evidence or explicit assumptions are present;
- option count reflects meaningful choices rather than a quota;
- choice markers match actual decision state;
- boundaries, responsibilities, interactions, decisions, risks, and validation are sufficient for the goal;
- diagrams add information and use Mermaid where practical;
- the only required core asset is `docs/architecture/<goal-slug>.md`;
- the document does not claim approval before confirmation;
- no delivery implementation or workflow process records were created.

## ⚠️ Red Flags

| Thought | Reality |
| --- | --- |
| "Architecture might help this feature, so start this workflow." | Architecture Design requires an explicit architecture goal and does not replace the feature's Technical Solution. |
| "The repository has no architecture document, so create one." | Missing repository state does not authorize an Asset Workflow. |
| "A recommendation is probably what the user wants." | Recommendation remains unselected until confirmation or explicit delegated authority. |
| "Every design needs three options." | Compare two or three only when materially different choices exist. |
| "A diagram can be the deliverable." | The diagram is part of the architecture document; it is not the sole core asset. |
| "A manifest would make this easier to resume." | Asset continuation uses the conversation, user goal, and authoritative asset, not duplicate process records. |
