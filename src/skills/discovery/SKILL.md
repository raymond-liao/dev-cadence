---
name: discovery
description: Use when a user wants to explore a product idea or update an existing product-design baseline in a target project.
---

# Discovery

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

Use this skill to create the first durable product-design baseline or incrementally update an existing confirmed baseline for a target repository.

Discovery is a product workflow. It clarifies what product should exist and how it operates as a business system. It does not design the technical implementation or deliver application changes.

Use only vendored Superpowers skills from:

```text
.dev-cadence/vendor/superpowers/skills/
```

## Applicability

Use Discovery for:

- an incomplete product idea, feedback theme, business problem, or product direction;
- first-time product definition;
- first-time creation of a PRD;
- first-time creation of a Business Architecture;
- product exploration that must become durable repository documents before work-item planning;
- an explicit request to update, revise, reconcile, or extend an existing product-design baseline when repository discovery also finds at least one credible candidate product-design document.

Select `initial mode` for first-time product exploration and `incremental mode` only when both conditions are true:

1. the user expresses intent to update an existing product-design baseline; and
2. repository discovery finds at least one credible candidate User Journey, PRD, Business Architecture, or combined product-design document.

Incremental mode requires intent to update an existing product-design baseline and a credible candidate in the repository.

Repository state alone does not trigger incremental mode. An update request without a credible candidate must not silently fall back to initial or first-time Discovery. Explain that no existing product-design baseline was found and ask the user to provide an authoritative path or make a separate first-time creation request.

At workflow start, record in the conversation whether the default User Journey, PRD, and Business Architecture documents exist and scan the repository root and normal project documentation directories for candidates on every Discovery run, regardless of update intent. Identify candidates by content and responsibility, not only by path or file name. Exclude `.dev-cadence/`, `dist/`, `build/`, `vendor/`, `node_modules/`, and `.git/` from the scan. Incremental intent determines how a discovered candidate is used for update, revision, or reconciliation; it does not determine whether scanning occurs.

When the workflow-start snapshot finds any pre-existing authoritative or credible candidate User Journey, PRD, Business Architecture, or combined product-design asset, including a candidate at a non-default path, and the user has not explicitly requested update, revision, or reconciliation, do not select initial mode, do not write Version 1, and do not overwrite or replace the candidate. Explain the existing baseline and ask for explicit update intent and an authoritative path before proceeding. Only working drafts created by the current Discovery conversation are exempt from this stop rule.

Documents created as the working baseline by the current Discovery effort do not trigger this stop rule. During the same conversation and user goal, continue editing that current Discovery draft after feedback or rejection until the user confirms it or abandons the effort.

Direct requests for a clear feature, bug fix, or behavior-preserving refactor do not have to pass through Discovery. Route them to their matching installed delivery workflow.

## Configuration

Before producing user-facing product-design documents or summaries, read:

```text
.dev-cadence.yaml
```

Use `output_language` for product-design documents and user-facing summaries:

- `en`: English;
- `zh-CN`: Simplified Chinese.

If the configuration is missing or unsupported, use `en`.

## Generated Status Presentation

When writing a user-facing status summary, apply the shared status presentation mapping from `document-conventions`. Preserve the canonical status text and do not add workflow status fields to the product-design documents.

## Generated Document References

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit. Before User Journey Confirmation, verify only the Journey proposal's local links and references whose targets already exist; do not derive or create PRD, Business Architecture, or any authoritative asset for this check. Before Product Design Confirmation, verify all three product-design assets' local links as one proposed combination without writing any not-yet-confirmed authoritative asset. Keep the complete selection, identity, lifecycle, and URI contract in the shared skill rather than duplicating it here.

## Inputs And Source Precedence

Use all relevant available sources:

- current conversation;
- user-provided notes and handoffs;
- existing repository documents;
- product, business, architecture, constraint, risk, and rejected-direction discussions.

When sources disagree, prefer explicit user confirmations, then existing repository documents, then weaker notes or inferred context. Do not silently resolve a meaningful conflict. Preserve unresolved conflicts in `Open Questions` with enough context to understand their impact.

Do not invent facts, requirements, roles, processes, objects, states, or rules to make the documents look complete.

## Product And Technical Content Boundary

Apply this boundary consistently in initial mode and when incremental mode classifies new input or historical mixed content.

You must classify every relevant input by meaning and source, including its authority and intended owner. Use these categories:

- A `product requirement` describes why the product exists, who it serves, the value or outcome it must produce, a capability it must provide, or a user-visible result.
- `business architecture content` describes business actors, domains, capabilities, value streams, processes, business objects, states, rules, events, exceptions, or external business boundaries.
- An `external or product-level constraint` describes a required result or boundary the product must satisfy without selecting how it is implemented.
- An `implementation suggestion` describes a candidate mechanism for achieving a result and requires later technical evaluation.
- A technical question records unresolved implementation information without treating any candidate answer as selected.

Classify source-faithful input by what the user actually established. The presence of a concrete technical name, product, or term does not make it a confirmed product requirement or an accepted technical decision. Preserve whether the source stated a mandatory external constraint, a preference, an example, a question, or a candidate mechanism.

### ✅ Product-Design Content

The PRD may contain product goals, users and stakeholders, value, success criteria, scope, product capabilities, product requirements, user-visible outcomes, non-functional requirements, product constraints, confirmed assumptions, and external dependencies.

Allowed product constraints include data residency, regulatory restrictions, compatibility requirements, measurable performance targets, availability targets, and user-visible security requirements. They may be recorded as verifiable non-functional requirements. State the required result and evidence boundary; do not select an unconfirmed implementation mechanism at the same time.

Product-level constraints belong in the PRD, not Business Architecture.

Business Architecture may contain only the business operating model: business actors, business domains, business capabilities, value streams, processes, business objects, states, business rules, business events, exceptions, and external business boundaries.

User Journey, PRD, and Business Architecture retain their own in-scope `Open Questions`. Every such question must also be indexed in the repository-level Registry with the same stable `Q-nnn`; all Open Questions are therefore indexed in the Registry, and the Registry does not replace or empty the local sections.

### ❌ Implementation Content

Do not put concrete code modules, service decomposition, database products, frameworks, libraries, API paths, request or response schemas, protocol choices, algorithms, cloud services, infrastructure, deployment topology, retry or timeout implementation parameters, test implementation, Mock strategies, or operational implementation steps in the PRD or Business Architecture.

Candidate mechanisms include database, framework, protocol, cloud service, module, interface, and deployment suggestions even when they appear in the original request. Do not rewrite them as product constraints merely to retain them in the product-design baseline.

### Technical Input Disposition

Preserve technical input without making Discovery evaluate it:

1. When a Story, Technical Task, technical solution, Decision, or another durable technical document already owns the subject, write the input there or link to that authoritative source according to its maintenance rules.
2. When no suitable authoritative document or owner exists and the input should not be lost, use `.dev-cadence/skills/open-question-registry/SKILL.md` to register it in the Open Question Registry with its original status and suggested resolution stage.
3. Keep product or business questions that belong to the PRD or Business Architecture in that document's `Open Questions`; do not move them out merely because the Registry exists.

Moving, registering, linking, or excluding technical input must not be described as an accepted technical decision. Record it as preserved context for evaluation in the relevant technical-design stage.

Technical Input Disposition is supporting shared-asset maintenance, not one of the three primary Discovery outputs and not a Discovery process record. Update or link an existing authoritative Story, Technical Task, technical solution, Decision, or other technical asset only when that asset's maintenance rules allow it. When no suitable owner exists, invoke the shared Open Question Registry according to its own on-demand creation rules. Do not automatically create a Story, Technical Task, Decision, or another technical-design asset merely to dispose of Discovery input.

In incremental mode, the disposition rules above determine the proposed destination, but do not authorize an immediate write, link update, Registry registration, or Registry removal. Include every supporting asset change in the proposal and defer it until Product Design Confirmation.

## Workflow Boundary

### ✅ Discovery Must

- create the first product-design baseline or update a confirmed baseline through incremental mode;
- keep product and business design durable outside `.dev-cadence/`;
- preserve unresolved and rejected material visibly;
- keep analysis stages in the current conversation rather than persisting copies of the workflow process;
- enforce two confirmation gates: User Journey Confirmation before derivation, then Product Design Confirmation before changing PRD, Business Architecture, or supporting assets.

### ❌ Discovery Must Not

- Do not create Feature, Story, Bug, or Technical Task cards.
- Do not create or maintain a work-item Roadmap.
- Do not design technical architecture, modules, services, databases, APIs, or deployment topology.
- Do not create database migrations.
- Do not modify application code.
- Do not create a run manifest, stage records, confirmation records, or other persistent workflow-process copies.
- Do not require a dedicated branch, workflow checkpoint commits, empty commits, or checkpoint hash bookkeeping.
- Do not perform implementation, system testing, Business Acceptance, release, deployment, or branch finishing.

## Stage Sequence

```text
Background And Problem Exploration -> User Journey Analysis -> User Journey Confirmation -> PRD And Business Architecture Derivation -> Product Design Confirmation
```

Stages 1 and 2 form one continuous exploration in the current conversation. Stage 3 is the first confirmation gate and freezes the Journey revision used for derivation. Stage 4 derives the complete PRD and Business Architecture proposal from that confirmed Journey. Stage 5 is the second confirmation gate. Ask a question outside the two confirmation gates only when the answer materially affects the remaining product design.

## Persistence And Continuation

Discovery is an Asset Workflow. Its only primary new workflow outputs are:

```text
docs/product-design/user-journey.md
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

Do not create a run manifest, stage records, confirmation records, rejection records, or duplicate analysis documents. Keep analysis stages in the current conversation. Before User Journey Confirmation, keep the complete Journey proposal in the conversation and do not write the authoritative Journey path. After User Journey Confirmation, atomically write only the confirmed Journey revision. Before Product Design Confirmation, keep the complete PRD and Business Architecture proposal in the conversation and leave their authoritative paths and supporting assets unchanged. After Product Design Confirmation, atomically write only affected PRD and Business Architecture assets and confirmed supporting maintenance. Supporting shared-asset maintenance performed through Technical Input Disposition does not become a Discovery primary output.

Use the current conversation, the user's goal, and the authoritative product-design documents to determine whether a request continues the same Discovery effort. Do not depend on a process record to restore stage state. When conversation context is incomplete, inspect the current documents and ask only for information that materially affects the baseline.

Discovery must not require a dedicated branch or workflow checkpoint commits. When the user asks to commit or save product-design changes, follow the target repository's ordinary Git rules and the user's request. Do not describe ordinary commits as workflow checkpoints, and do not put commit hashes or Git audit fields in the product-design documents. A commit does not replace either confirmation gate.

## Product-Design Documents

The standard durable baseline consists of these primary documents:

```text
docs/product-design/user-journey.md
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

In initial mode, all three documents start with `Document Information` containing version `1` and `Last Updated`. In incremental mode, preserve each current version and history until a confirmed substantive change requires a new version. Each document contains its own `Change Log`; every row must use the exact `Version | Recorded At | Recorded By | Change | Reason` columns defined below. Do not put Git commit hashes in the product documents.

User Journey, PRD, and Business Architecture must each use this Change Log contract. The columns are exactly:

```text
Version | Recorded At | Recorded By | Change | Reason
```

`Recorded At` must be a timezone-aware ISO 8601 timestamp. Read `user.name` and `user.email` from repository-level Git config first, then fall back to global Git config. When an email is available, record `Name <email>`; when only a name is available, record the name. When both the Git username and email are missing, ask the user before writing the Change Log and do not infer an identity. `Recorded By` and `Recorded At` are Change Log fields only; they are not approval metadata or approval time.

User Journey, PRD, and Business Architecture versions are independent. Increment the User Journey only when a confirmed revision changes its business line, boundary, Journey Map, or Feature Definitions. When an input does not affect the User Journey, do not reconfirm, rewrite, or increment the User Journey; derive and confirm only the affected PRD, Business Architecture, and supporting maintenance.

PRD and Business Architecture versions are independent. With separate documents, increment only the affected document when its product intent, scope, success criteria, constraints, actors, domains, capabilities, processes, objects, states, rules, or other owned substantive content changes. When the user keeps a combined document, it must maintain separate `PRD Version` and `Business Architecture Version` fields, or equivalently explicit responsibility-version fields, plus Change Log entries labeled with the affected responsibility. Increment only the substantively changed responsibility version. A final review of a combined document reports one path with two responsibility versions; splitting it establishes one independent `Version` and Change Log in each resulting file. Pure spelling, formatting, path migration, file name changes, and link-only updates must not increment either document or responsibility version. Preserve all existing body content, `Rejected Directions`, `Future Scope`, and `Change Log` history unless the user explicitly confirms a substantive replacement or removal.

Use `Open Questions` as the only unresolved-material section. Do not create separate Draft Ideas or Pending Decisions sections. When an answer is confirmed, move the conclusion into the relevant body section. Keep an unresolved question only while it remains unresolved.

Preserve explicitly rejected product or business directions under `Rejected Directions`. Put intentionally deferred product work under PRD `Future Scope`.

The product-design documents must not contain workflow approval metadata. Do not add approval status, approver, approval timestamp, checkpoint commit, or run status fields.

### User Journey Contract

`docs/product-design/user-journey.md` owns the confirmed end-to-end business journey and the stable identities from which the other two assets are derived. Include:

```text
Document Information
Journey ID
Business Line And Boundary
Journey Map
Feature Definitions
Open Questions
Rejected Directions
Change Log
```

The Journey Map must be a normal Markdown Table. Rows represent roles, and columns represent the business sequence from left to right. Every contiguous run of empty column headers inherits the nearest non-empty stage header to its left.

Every Journey and Feature identity must be repository-globally unique. Use `J-nnn` for a Journey ID and `F-nnn` for a Feature ID, where `nnn` is a zero-padded three-digit sequence.

Before creating or modifying a Journey or Feature identity, scan the repository's product-design documents and credible product-design candidates for existing identities and their business meaning. Preserve every existing ID when its business identity remains the same. If the scan finds a collision, refuse the write. If the business identity cannot be determined or a conflict remains, keep the proposed identity and its disposition in `Open Questions` until the user resolves it. IDs must not be silently renumbered.

Feature Definitions must use these fixed fields:

```text
ID | Type | Title | Description
```

`Type` allows only `Offline` and `System`. When the business identity is unchanged, a rename or Type adjustment must retain the ID. When multiple roles use the same Feature, reuse that same Feature and its ID rather than defining role-specific duplicates.

Discovery is the sole owner of confirmed Journey and Feature identities. Work Item Planning and other workflows may only reference confirmed Feature Definitions; they must not redefine a Feature's ID, Type, Title, business identity, or Journey order. If another workflow discovers a missing identity or a meaning or sequence change, return the request to Discovery for confirmation and maintenance rather than editing the identity locally.

### PRD Contract

`docs/product-design/prd.md` owns product intent and required outcomes. Include:

```text
Document Information
Product Overview
Users And Stakeholders
Value Proposition
Goals And Success Criteria
Scope
Product Capabilities
Product Requirements
Non-Functional Requirements
Constraints And Assumptions
Open Questions
Rejected Directions
Future Scope
Change Log
```

The PRD must explain:

- product vision, goal, background, and problem statement;
- target users, roles, stakeholders, needs, and pain points;
- user value, business value, and expected outcomes;
- measurable success criteria and meaningful failure conditions;
- in-scope, out-of-scope, and product boundaries;
- core capabilities and their user-facing outcomes;
- functional, cross-capability, information, and product-level permission requirements;
- relevant security, privacy, performance, availability, accessibility, compliance, and observability requirements;
- business and product constraints, confirmed assumptions, and external dependencies.

Every Product Requirement must trace to its originating Journey and Feature IDs. Preserve that traceability when requirement wording or grouping changes.

Do not decompose capabilities into detailed work-item files in this workflow.

### Business Architecture Contract

`docs/product-design/business-architecture.md` owns how the product operates as a business system. Include:

```text
Document Information
Business Architecture Overview
Business Actors And Responsibilities
Business Domains And Boundaries
Business Capability Map
Value Streams And Business Processes
Business Objects And Relationships
State And Lifecycle Models
Business Rules And Policies
Business Events And External Boundaries
Exceptions And Edge Cases
Architecture Constraints
Open Questions
Rejected Directions
Change Log
```

The Business Architecture must explain:

- the business operating model and relationship to the PRD;
- internal and external actors, responsibilities, authority, and accountability boundaries;
- business domains, ownership, boundaries, and cross-domain relationships;
- core and supporting capabilities, ownership, and dependencies;
- end-to-end value streams, process triggers, outcomes, handoffs, and decision points;
- core business objects, definitions, ownership, relationships, and sources of truth;
- important object states, allowed transitions, conditions, terminal states, and exceptional states;
- business, validation, eligibility, permission, time, sequence, and consistency rules;
- important business events, external participants, external system boundaries, inputs, and outputs;
- known exceptions, edge cases, and external business-boundary constraints.

Business Architecture must trace relevant actors, processes, capabilities, objects, rules, and boundaries back to the originating Journey and Feature IDs.

Business Architecture is not technical architecture. Do not prescribe code modules, databases, protocols, infrastructure, deployment design, or product-level constraints.

## Stage Rules

### Incremental Baseline Selection And Preparation

Before changing an existing baseline:

1. Inspect each credible candidate's actual path, owned content, current version, `Last Updated`, and `Change Log`.
2. When multiple candidates exist, responsibilities are unclear, or sources conflict, explain the evidence and obtain one explicit user confirmation of the authoritative source before modification. Do not merge or overwrite competing candidates automatically.
3. For a non-standard path or file name, explain the current path, recommended standard path and file name, and affected repository references. Confirm the migration choice explicitly, but defer any move, rename, or reference update until the confirmation gate for that asset. If migration is declined, keep the proposal at the existing authoritative path and do not propose a competing duplicate. If approved, the final atomic application moves or renames the asset, updates repository references, and preserves its content, version, and `Change Log`.
4. When one combined document owns both PRD and Business Architecture responsibilities, confirm whether to keep it combined or split it. Do not split automatically or create split files before Product Design Confirmation. A confirmed split proposal preserves content and history and establishes one unambiguous authority for each responsibility when atomically applied. A retained combined document follows the independent responsibility-version contract above.
5. If an authoritative baseline contains historical mixed technical, workflow-status, approval, test-implementation, deployment, or operational content, explain the classification evidence, suggested authoritative destination, and affected references. Historical mixed content requires explicit user confirmation before removal or migration, and the selected cleanup remains part of the in-conversation proposal until Product Design Confirmation. Preserve necessary history and propose Registry disposition for unresolved ownerless technical items.
6. When a legacy baseline has a PRD and Business Architecture without a User Journey, treat both legacy assets as trusted input. First form and confirm the initial User Journey, then coordinate only the PRD, Business Architecture, references, and supporting assets actually affected by establishing Journey and Feature traceability.

In short: for a non-standard path, confirm migration; for a combined document, confirm the split choice; and never change historical mixed content without explicit confirmation.

These decisions and the proposed revised baseline remain in the current conversation before confirmation. Discovery must not create a manifest, stage record, confirmation record, draft file, proposal file, or another process artifact to store actual document paths, version combinations, migration choices, split choices, or proposed content.

### 1. Background And Problem Exploration

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Collect the source inventory, current situation, problem statement, affected users, observed evidence, assumptions, conflicts, motivation, goals, user value, business value, success criteria, scope, and non-scope in the current conversation. Carry confirmed facts into the Journey proposal and preserve unresolved product or business questions in the proposed owning asset's `Open Questions`.

### 2. User Journey Analysis

Define the Business Line And Boundary, roles, ordered business stages, Journey Map, and Feature Definitions in the current conversation. Assign stable, repository-global Journey and Feature IDs and verify that shared capabilities reuse one Feature identity across roles.

Before creating an initial baseline, run the Product And Technical Content Boundary classification over all source material and conclusions. Remove candidate implementation mechanisms from the product-design proposal only after their disposition is recorded. Do not discard technical context.

In initial mode, form a complete version-1 Journey proposal without writing `docs/product-design/user-journey.md`. In incremental mode, read the authoritative User Journey, PRD, Business Architecture, versions, and history without changing them. If new input affects the User Journey, form a complete proposed Journey revision. If new input does not affect the User Journey, do not reconfirm, rewrite, or increment the User Journey; proceed using the currently confirmed Journey and limit the later proposal to affected assets.

### 3. User Journey Confirmation

Present the complete User Journey proposal, including its actual path, version, Journey ID, business boundary, Journey Map, Feature Definitions, Open Questions, Rejected Directions, and Change Log effect. Ask for explicit confirmation of this complete revision.

Before User Journey Confirmation, keep the complete Journey proposal in the conversation and do not write the authoritative Journey path. If the user requests changes or rejects the proposal, edit only the current Discovery draft in the conversation and present the complete Journey proposal again. After User Journey Confirmation, atomically write only the confirmed Journey revision. Do not formally derive PRD and Business Architecture until the User Journey is confirmed.

### 4. PRD And Business Architecture Derivation

Derive the PRD and Business Architecture from the confirmed User Journey, current source material, and confirmed Discovery conclusions. Define product intent, users, value, outcomes, success criteria, scope, capabilities, requirements, non-functional requirements, actors, domains, processes, business objects, state lifecycles, rules, policies, constraints, risks, Open Questions, Rejected Directions, and Future Scope according to the two assets' ownership contracts. Preserve Journey and Feature traceability in both derived assets and do not fabricate completeness.

In incremental mode, classify each new input as an addition, business-architecture change, correction, replacement, rejection, Open Question, or Future Scope change, then identify whether it affects the PRD, Business Architecture, or both. Apply the Product And Technical Content Boundary and form a complete proposed revised baseline plus change summary in the conversation. In incremental mode, the proposal must not modify the authoritative PRD, Business Architecture, or supporting assets before confirmation; they remain byte-for-byte unchanged.

In the proposal, show confirmed questions removed from the relevant `Open Questions` and their conclusions placed in the correct body. Propose confirmed technical conclusions for their technical authority, not the product-design baseline. When a repository-level Registry entry represents the same resolved question, include the authoritative conclusion and the atomic Registry status update in the supporting asset maintenance proposal. Remove the question from the local `Open Questions` section after its conclusion is placed in the owning body, but retain its Registry entry in the applicable terminal status; the Registry terminal entry is retained.

Do not add a Registry Change Log.

Before Product Design Confirmation, keep the complete PRD and Business Architecture proposal in the conversation and leave their authoritative paths and supporting assets unchanged. Perform supporting asset maintenance only after the user confirms Product Design and as part of atomically applying the confirmed proposal.

Record potential impact on existing work items and active development tasks in the final review and hand it to `work-item-planning`. Do not silently modify Feature, Story, Bug, Technical Task, Roadmap, or active delivery state.

### 5. Product Design Confirmation

Present the complete proposed PRD and Business Architecture revision and one concise change summary containing:

- the confirmed Journey path, version, Journey ID, and Feature identities used for derivation;
- confirmed product goal, users, value, scope, and capabilities;
- business domains, actors, main processes, objects, states, and rules;
- important Open Questions and their impact;
- Rejected Directions and Future Scope;
- all actual authoritative document paths and responsibility version numbers, including the same path paired with both versions when a combined document is retained;
- for incremental mode, the previous and proposed independent version of each document and the reason for every increment or unchanged version;
- potential impacts to existing work items for later `work-item-planning` evaluation;
- the boundary before work-item planning and technical architecture.

The review must also summarize each material technical input excluded from the product-design baseline, its current authoritative document or Registry entry, and its suggested resolution stage. Describe this as a handoff for later evaluation, not as approval of the suggested implementation.

Ask for explicit Product Design Confirmation covering the complete PRD and Business Architecture proposal. This is the second of the two confirmation gates. A commit does not count as confirmation.

If the user requests changes or rejects the proposal, update only the in-conversation proposed revised baseline and related change summary, then present the complete proposal again when requested. The on-disk authoritative PRD, Business Architecture, and supporting assets remain unchanged. Do not create a draft file, process record, or separate Discovery run for feedback on the same baseline. If the feedback changes the User Journey, return to User Journey Analysis and obtain User Journey Confirmation for the revision before deriving again.

After the user confirms Product Design, atomically apply the complete confirmed proposal: write only affected PRD and Business Architecture assets and confirmed supporting maintenance, perform approved migration or splitting, increment only substantively changed document or responsibility versions, append responsibility-appropriate `Change Log` rows, and update affected references. State the confirmed three-asset path and version combination. In initial mode, this is version 1 of all three standard documents. If any required write fails, do not present a partially updated combination as the new baseline; restore or complete the confirmed combination before reporting success. Only this applied complete combination becomes the new planning baseline. Do not create a separate confirmation record or add approval metadata to any document. If the user rejects the baseline, do not claim it is confirmed, do not modify the authoritative assets, and do not create a separate rejection record; continue refining only the in-conversation proposal when the user requests changes.

## Completion Output

Return:

- authoritative product-design files created or updated, using their actual paths;
- version numbers;
- concise Journey, product, and business-architecture summary;
- important Open Questions, Rejected Directions, and Future Scope;
- final confirmation status;
- the next installed workflow, when one exists.

If `work-item-planning` is installed and the user wants decomposition, recommend it after confirmation. Otherwise stop with the confirmed baseline and do not invent or advertise an unavailable workflow.
