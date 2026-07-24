---
name: open-question-registry
description: Use when a user or another Dev Cadence skill needs to view, register, migrate, organize, or update the status of repository-level unresolved questions.
---

# Open Question Registry

Use this shared capability to maintain one repository-level view of unresolved questions that cross document or workflow boundaries.

This is an auxiliary asset-maintenance skill. It is not a business delivery workflow and does not create a Dev Cadence run, stage records, checkpoint commits, or work items. When another Dev Cadence workflow is active, return to that workflow after the Registry operation.

Before creating or updating Registry Markdown, read and follow:

```text
.dev-cadence/references/document-conventions/SKILL.md
```

## Applicability

Use this skill when:

- the user directly asks to view, register, migrate, organize, resolve, reject, invalidate, or supersede repository-level Open Questions;
- an active workflow finds an unresolved question that its current artifact cannot reasonably hold and losing the question would create delivery risk;
- an unresolved question must move from temporary Registry ownership to a durable authoritative document.

Do not use this skill to answer a question, confirm a decision, create a Story, Bug, or Technical Task, or replace the local `Open Questions` section in a Dev Cadence-owned work item, architecture document, delivery design, stage record, or other authoritative delivery asset.

## Registry Discovery

The canonical Registry path is:

```text
docs/delivery/open-questions.md
```

Before creating that file, search the repository for an existing candidate Registry or repository-level unresolved-question document. Inspect filenames, headings, links, and document responsibility rather than matching one exact name.

If one existing candidate clearly owns the repository-level index, use it and preserve its path and established structure where compatible with this contract. Do not create a competing index.

If multiple candidates exist, ownership is ambiguous, or the canonical path already contains unrelated content, block the write and ask one necessary clarification question. Do not overwrite, silently merge, rename, or replace an existing candidate.

## On-Demand Creation

Create `docs/delivery/open-questions.md` only when the first real question must be registered and no existing candidate Registry owns the responsibility.

Do not create an empty Registry during installation, workflow startup, repository inspection, or a run that has no question to register. Installation must not create or overwrite `docs/delivery/open-questions.md`.

When creating the Registry, include these sections:

```markdown
# Open Question Registry

## Questions

| ID | Status | Question | Authoritative Source |
| --- | --- | --- | --- |
| [Q-001](#q-001) | Open | Which durable asset should own this question? | Registry temporary body |

## Question Details

### Q-001
```

The example row represents the first real question registered in the same operation that creates the Registry. Do not create an empty Registry or add placeholder question rows.

## Entry Contract

Before assigning an ID, scan the complete Registry, including terminal entries, to determine the existing maximum `Q-nnn` ID. New IDs start at `Q-001` when no ID exists and increment from the existing maximum. IDs are global and terminal IDs must not be reused.

Every entry must contain exactly `ID`, `Status`, `Question`, and `Authoritative Source`. Valid statuses are `Open`, `Resolved`, `Rejected`, `Invalid`, and `Superseded`.

The Open group appears first in ascending ID order. The non-Open group appears after the Open group in ascending ID order. Question Details cover every question and are ordered by ascending ID.

Question Details must include a `### Q-nnn` heading for every ID. When a durable authoritative asset owns a question, the Registry keeps only its title and a verified Markdown link to that asset; its Question Details entry contains no full body. Its `Authoritative Source` is the durable asset link. When no durable authority exists, the Registry temporarily owns the full body in Question Details and its `Authoritative Source` is `Registry temporary body`.

The Registry must not contain a Change Log.

## Single Body Source

There must be one full-body source. Do not keep two full bodies that require synchronization.

Dev Cadence-owned authoritative assets, such as work-item cards, architecture documents, delivery designs, and stage records, continue to maintain their own in-scope `Open Questions`. Every such local question must also be indexed in the Registry under the same stable `Q-nnn` ID; the Registry does not replace or empty those local sections.

Do not inspect, index, update, or migrate Open Questions from PRDs, Business Architecture, User Journeys, Features, Story Maps, or other product-analysis assets. Those assets remain outside Dev Cadence even when they exist in the target repository.

## Migration

When a Registry-temporary question gains a durable authoritative owner:

1. Add the full body and relevant context to the authoritative document.
2. Verify the authoritative document contains the complete migrated material.
3. Replace the Registry temporary body with the question title and a verified link to the authoritative source.
4. Verify no second full body remains.

Do not delete the temporary body before the authoritative source has been written and verified.

## Terminal Outcomes

When a question becomes `Resolved`, `Rejected`, `Invalid`, or `Superseded`:

1. Write the applicable conclusion or history to its authoritative source. If the Registry temporarily owns the question, first choose a durable final location for the conclusion.
2. After the conclusion is written, change the Registry entry to the terminal status.
3. A terminal entry remains in Questions, and its Registry-owned detail remains only when no durable authority owns the body.

By default, do not remove terminal entries from Questions. The status and authoritative source must preserve their final location and outcome.

## Explicit Historical Pruning

An explicit historical-pruning operation is the only exception to terminal retention. Apply it only when all of these conditions hold:

- the user explicitly requests historical pruning and confirms the affected `Q-nnn` IDs;
- every affected entry is already terminal; an `Open` entry must never be pruned;
- each affected question belongs to a deleted, retired, or out-of-scope Dev Cadence delivery asset;
- at least one higher-numbered ID remains after pruning, so the Registry's maximum assigned ID and ID high-water mark do not decrease; the current maximum ID must never be pruned;
- the same atomic update removes the Questions row, removes the matching Question Details entry, and repairs active references without changing unrelated entries.

Pruning does not make an ID reusable. New IDs still increment from the preserved maximum. Report the deleted IDs, the references repaired, and that Git history is the recovery path.

## Updating Existing Registries

Before every write:

- re-read the Registry and referenced authoritative source;
- preserve global IDs and existing unrelated entries;
- verify local Markdown links according to `document-conventions`;
- make only the requested registration, metadata update, migration, or status change;
- do not infer that a question is resolved from code changes, workflow progress, or missing discussion alone.

If the requested change conflicts with the authoritative source, stop and surface the conflict instead of silently choosing one version.

## Completion Report

After a Registry operation, report:

- whether the Registry was created or an existing candidate was used;
- affected global IDs;
- any explicitly pruned IDs and their Git recovery path;
- whether each affected question is indexed or temporarily Registry-owned;
- authoritative source, status, and final location changes;
- validation performed, including duplicate-body and local-link checks.

### ⚠️ Red Flags

| Thought | Reality |
| --- | --- |
| "Create the standard file now so it is ready later." | Creation is on demand. No real question means no Registry file. |
| "Copy the whole question into the index for convenience." | An assigned question has one full body in its authoritative source. |
| "Remove resolved questions from the table for clarity." | Retain terminal questions by default. Pruning requires an explicit user-confirmed historical cleanup and must preserve the ID high-water mark. |
| "This filename looks close enough; replace it." | Candidate ownership must be inspected. Ambiguity blocks writes. |
| "Registering the question means I should create a work item." | Registry maintenance does not create delivery work items automatically. |
