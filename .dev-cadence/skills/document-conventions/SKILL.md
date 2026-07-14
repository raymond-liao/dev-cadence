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
