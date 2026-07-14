---
name: document-conventions
description: Use when creating or updating Dev Cadence-managed Markdown documents, examples, reports, or summaries.
---

# Document Conventions

Use this shared skill for common presentation rules in Dev Cadence-managed Markdown.

This is an auxiliary document-authoring skill. It is not a business workflow and does not create a workflow run. Business workflow selection remains in `using-dev-cadence` and the selected workflow skill.

## Applicability

Read and follow this skill before creating or updating Dev Cadence-managed Markdown, including workflow records, product-design documents, work-item documents, reports, examples, and user-facing Markdown summaries.

Do not use this skill to decide which business workflow applies, change workflow stages, or replace a workflow-specific document contract.

## Semantic Visual Markers

Use these meanings consistently:

| Marker | Meaning |
| --- | --- |
| ✅ | Required, applicable, correct, or passed |
| ❌ | Forbidden, not applicable, incorrect, or failed |
| ❓ | Ambiguous, unresolved, or requiring clarification |
| ⚠️ | Risk, exception, warning, or conditional execution |
| ℹ️ | Necessary supplementary information |

Every marker must retain explicit text, a decision, or a reason. Emoji must never be the only source of meaning.

## Selective Use

Use semantic markers when they materially improve scanning or comparison, especially for:

- paired `Must` and `Must Not` or `Allowed` and `Forbidden` sections;
- positive, negative, and ambiguous examples;
- passed and failed decisions;
- Red Flags, risks, exceptions, and conditional paths;
- compact tables where the accompanying text still states the meaning.

Prefer one marker on a section heading over repeating the same marker on every ordinary list item beneath it.

## Solution Choice Markers

When a technical solution or another document compares multiple options, make the confirmed decision easy to scan without misrepresenting the alternatives:

- use `✅ Selected` only for the option the user has confirmed;
- keep unselected but still viable alternatives neutral, without a positive or negative marker;
- use `❌ Rejected` only when the option was explicitly rejected;
- use `❓ Decision Pending` while no option has been confirmed.

A recommendation is not a selection. Do not mark a recommended option as `✅ Selected` until the user confirms it or the active workflow has explicit delegated authority to make that decision.

Use the marker in the option heading or decision column and retain the option name and decision text. Do not repeat it on every paragraph describing the option.

## Work Item Scope Headings

Feature, Story, Bug, and Task work-item cards must use paired included-scope and excluded-scope headings when they define delivery boundaries. Keep the markers fixed, but localize the heading text to the configured `output_language` or the document's established language.

```markdown
## ✅ Scope

## ❌ Out of Scope
```

For `zh-CN`, use `## ✅ 范围` and `## ❌ 非范围`. `✅` means the content is included in or applicable to the current work item. `❌` means the content is explicitly excluded from or not applicable to the current work item. These markers do not express content quality, completion, verification, or acceptance status.

Keep the marker on the section heading and retain the heading text. Do not mechanically repeat the marker on ordinary list items beneath either section.

## Precision Boundaries

Do not add emoji mechanically to ordinary prose, ordinary headings, or ordinary list items.

Do not put emoji in:

- filenames or paths;
- commands or code examples where the emoji is not literal input;
- IDs, configuration values, Git references, or machine-consumed values;
- canonical status enums or other exact contract values.

Keep normative wording such as `must`, `do not`, `when`, `before`, and `after`. A visual marker reinforces the rule; it does not replace the rule.

## Examples

### ✅ Must

- Keep the exact normative requirement in text.
- Pair the marker with a meaningful heading or decision.

### ❌ Must Not

- Do not rely on the marker as the only explanation.
- Do not decorate every paragraph merely because emoji are available.

### ❓ Ambiguous Example

When the available information does not determine one outcome, label the example as ambiguous and state the clarification needed.

### ⚠️ Red Flag

Use a warning marker only when the content identifies a real risk, exception, or likely reasoning failure.

### ℹ️ Supplementary Information

Use an information marker sparingly for context that improves understanding but does not change the required action.
