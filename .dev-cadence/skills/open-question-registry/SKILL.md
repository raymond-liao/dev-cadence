---
name: open-question-registry
description: Use when a user or another Dev Cadence skill needs to view, register, migrate, organize, or remove repository-level unresolved questions.
---

# Open Question Registry

Use this shared capability to maintain one repository-level view of unresolved questions that cross document or workflow boundaries.

This is an auxiliary asset-maintenance skill. It is not a business delivery workflow and does not create a Dev Cadence run, stage records, checkpoint commits, or work items. When another Dev Cadence workflow is active, return to that workflow after the Registry operation.

Before creating or updating Registry Markdown, read and follow:

```text
.dev-cadence/skills/document-conventions/SKILL.md
```

## Applicability

Use this skill when:

- the user directly asks to view, register, migrate, organize, resolve, reject, invalidate, or supersede repository-level Open Questions;
- an active workflow finds an unresolved question that its current artifact cannot reasonably hold and losing the question would create delivery risk;
- an unresolved question must move from temporary Registry ownership to a durable authoritative document.

Do not use this skill to answer a question, confirm a decision, create a Feature, Story, Bug, or Technical Task, or replace the local `Open Questions` section in a PRD, Business Architecture, work item, design, or other authoritative document.

## Registry Discovery

The canonical Registry path is:

```text
docs/open-questions.md
```

Before creating that file, search the repository for an existing candidate Registry or repository-level unresolved-question document. Inspect filenames, headings, links, and document responsibility rather than matching one exact name.

If one existing candidate clearly owns the repository-level index, use it and preserve its path and established structure where compatible with this contract. Do not create a competing index.

If multiple candidates exist, ownership is ambiguous, or the canonical path already contains unrelated content, block the write and ask one necessary clarification question. Do not overwrite, silently merge, rename, or replace an existing candidate.

## On-Demand Creation

Create `docs/open-questions.md` only when the first real question must be registered and no existing candidate Registry owns the responsibility.

Do not create an empty Registry during installation, workflow startup, repository inspection, or a run that has no question to register. Installation must not create or overwrite `docs/open-questions.md`.

When creating the Registry, include these sections:

```markdown
# Open Question Registry

## Current Open Questions

| ID | Type | Status | Owner | Summary | Authoritative Source | Impact | Suggested Resolution Stage |
| --- | --- | --- | --- | --- | --- | --- | --- |

## Unassigned Question Details

## Change Log

| Date | ID | Change | Final Location |
| --- | --- | --- | --- |
```

Do not add placeholder question rows. Add the first real entry in the same change that creates the document.

## Entry Contract

Every current entry must expose:

- a stable `ID` that is not renumbered when entries move or are removed;
- `Type`;
- current `Status`;
- `Owner`, using an explicit `Unassigned` value when no owner is known;
- a concise `Summary`;
- `Authoritative Source`, using a verified repository Markdown link when one exists, or explicit `Registry temporary body` when it does not;
- `Impact`;
- `Suggested Resolution Stage`.

The current index lists only questions that still need attention. Do not use it as a decision log, completed-work archive, or substitute backlog.

## Single Body Source

When an authoritative PRD, Business Architecture, Feature, Story, Bug, Technical Task, technical solution, Decision, or other durable document already owns the question, keep the full body and complete context only in that authoritative source. The Registry stores a concise summary, current metadata, and a link; it must not duplicate the complete question body.

When no authoritative source exists, the Registry may temporarily own the full body under `Unassigned Question Details`. Identify the entry by its stable ID and include the context, impact, known constraints, and suggested next step needed to prevent information loss.

There must be one body source. Do not keep two full bodies that require synchronization.

PRD and Business Architecture documents continue to maintain their own in-scope `Open Questions`. The Registry indexes them when repository-level visibility is useful; it does not replace or empty those sections.

## Migration

When an unassigned question gains a clear authoritative owner:

1. Add the full body and relevant context to the authoritative document.
2. Verify the authoritative document contains the complete migrated material.
3. Replace the Registry temporary body with a concise index entry and verified link to the authoritative source.
4. Record the migration and final location in the Registry `Change Log`.
5. Verify no second full body remains.

Do not delete the temporary body before the authoritative source has been written and verified.

## Terminal Outcomes

When a question is resolved, rejected, invalid, or superseded:

1. Write the applicable conclusion or history to its authoritative source. If the Registry temporarily owns the question, first choose a durable final location for the conclusion.
2. Remove the entry from the current index, `Current Open Questions`, and remove any Registry temporary body.
3. Record the removal, terminal outcome, and final location in the Registry `Change Log`.

Do not leave a terminal item in the current index with a closed-looking status. Current Open Questions must remain a truthful unresolved-work view.

## Change Log

The `Change Log` records index addition, migration, and removal events with the stable question ID and final location when applicable.

Use it to preserve Registry history without copying the full body, complete context, or complete resolution text. Durable conclusions belong in the authoritative source.

## Updating Existing Registries

Before every write:

- re-read the Registry and referenced authoritative source;
- preserve stable IDs and existing unrelated entries;
- verify local Markdown links according to `document-conventions`;
- make only the requested registration, metadata update, migration, or removal;
- do not infer that a question is resolved from code changes, workflow progress, or missing discussion alone.

If the requested change conflicts with the authoritative source, stop and surface the conflict instead of silently choosing one version.

## Completion Report

After a Registry operation, report:

- whether the Registry was created or an existing candidate was used;
- affected stable IDs;
- whether each affected question is indexed or temporarily Registry-owned;
- authoritative source and final location changes;
- validation performed, including duplicate-body and local-link checks.

### ⚠️ Red Flags

| Thought | Reality |
| --- | --- |
| "Create the standard file now so it is ready later." | Creation is on demand. No real question means no Registry file. |
| "Copy the whole question into the index for convenience." | An assigned question has one full body in its authoritative source. |
| "Keep resolved questions in the table for history." | Remove terminal questions from the current index and use the Change Log plus authoritative source for history. |
| "This filename looks close enough; replace it." | Candidate ownership must be inspected. Ambiguity blocks writes. |
| "Registering the question means I should create a work item." | Registry maintenance does not create delivery work items automatically. |
