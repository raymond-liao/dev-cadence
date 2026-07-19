# B-010 Generated Records Do Not Enforce Navigational Document Links

## Basic Information

- ID: `B-010`
- Version: `1`
- Status: `In Progress`
- Priority: `P2`
- Change Type: Bug

## Problem Goal

Ensure Dev Cadence-generated records use clickable Markdown links when they reference existing repository documents for reading navigation, while retaining exact repository-relative paths wherever audit identity is also required.

## Expected Behavior

Generated manifests and stage records should follow the document-reference contract defined by [S-010 Document Reference Links](../stories/S-010-document-reference-links.md): an existing document referenced for navigation is presented with meaningful link text, and records that also require an auditable file identity retain the exact repository-relative path alongside the link.

## Observed Behavior

The shared `document-conventions` rule is present, but the Feature Dev, Bug Fix, and Refactor code-review evidence templates still demonstrate a plain repository path. Current contract tests verify that the rule text exists, and delivery-record validation verifies that recorded artifact paths exist, but neither detects a navigational reference that was written only as plain text. Records created after S-010 can therefore still contain non-clickable references.

## ✅ Included Scope

- Correct generated-record templates that currently demonstrate plain paths for navigational document references.
- Add deterministic contract coverage that detects relevant existing-document references which omit a Markdown navigation link.
- Preserve exact repository-relative paths when they are required for audit identity or machine-readable validation.
- Verify that Feature Dev, Bug Fix, and Refactor apply the same reference behavior.

## ❌ Excluded Scope

- Do not mechanically convert every path into a Markdown link.
- Do not batch-rewrite unrelated historical workflow records.
- Do not convert command arguments, configuration values, output locations, code examples, planned paths, or machine-readable file identities into links.
- Do not create links to targets that do not exist.
- Do not require a full Markdown AST or heading-anchor parser unless the confirmed repair solution demonstrates that it is necessary.

## Acceptance Criteria

1. Generated-record templates use a meaningful Markdown link for an existing document referenced for reading navigation.
2. A manifest or stage record that also needs auditable file identity keeps both the navigation link and the exact repository-relative path.
3. Automated contract coverage fails when a governed generated-record template regresses to a plain-path-only navigational reference.
4. Delivery-record validation continues to parse and verify exact artifact paths after links are added.
5. Feature Dev, Bug Fix, and Refactor use symmetric document-reference behavior.
6. Unrelated historical workflow records are not batch-rewritten as part of this Bug.

## Known Reproduction Conditions

- Generate a delivery repair or implementation record from the current `Code Review Evidence` template.
- Populate the `Report` field using the demonstrated repository path.
- Run the existing document-conventions and delivery-record contract tests; they pass even though the report reference is not clickable.

## Relationships

- Follows: [S-010 Document Reference Links](../stories/S-010-document-reference-links.md).
- Related: [B-006 Delivery Record Evidence Completeness](B-006-delivery-record-evidence-completeness.md).
- Blocks: None.

## Open Questions

- None.

## Related Documents

- [Backlog](../backlog.md)
- [S-010 Document Reference Links](../stories/S-010-document-reference-links.md)
- [B-006 Delivery Record Evidence Completeness](B-006-delivery-record-evidence-completeness.md)

## Change Log

| Version | Recorded At | Recorded By | Change | Reason |
|---:|---|---|---|---|
| 1 | 2026-07-18T20:20:30+0800 | Raymond Liao <raymond-liao@outlook.com> | Created the Bug card with status `Draft`. | Generated records can still use plain-path-only navigational references after S-010 because templates and automated enforcement do not close the contract. |
| 1 | 2026-07-19T15:03:31+08:00 | Raymond Liao <raymond-liao@outlook.com> | Updated the status to `In Progress`. | The user explicitly requested parallel repair of B-012, B-010, and B-014; this changes execution status only and does not revise the card definition. |
