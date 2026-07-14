---
name: discovery
description: Use when a user wants to explore an incomplete product idea, business problem, or product direction and create the first PRD and Business Architecture baseline in a target project.
---

# Discovery

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

Use this skill to turn incomplete product input into the first durable product-design baseline for a target repository.

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
- product exploration that must become durable repository documents before work-item planning.

Do not use this S-001 workflow to update or reconcile a product-design baseline that was already present before the current first-time Discovery effort started. At workflow start, record in the conversation whether either `docs/product-design/prd.md` or `docs/product-design/business-architecture.md` already exists. If either document is a pre-existing or previously confirmed baseline, stop before changing either file and explain that incremental update belongs to the later product-design versioning capability.

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

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit; check local links in both product-design documents before requesting final confirmation. Keep the complete selection, identity, lifecycle, and URI contract in the shared skill rather than duplicating it here.

## Inputs And Source Precedence

Use all relevant available sources:

- current conversation;
- user-provided notes and handoffs;
- existing repository documents;
- product, business, architecture, constraint, risk, and rejected-direction discussions.

When sources disagree, prefer explicit user confirmations, then existing repository documents, then weaker notes or inferred context. Do not silently resolve a meaningful conflict. Preserve unresolved conflicts in `Open Questions` with enough context to understand their impact.

Do not invent facts, requirements, roles, processes, objects, states, or rules to make the documents look complete.

## Product And Technical Content Boundary

Apply this boundary consistently when creating the first product-design baseline and when a later incremental Discovery capability classifies new input. The current workflow still stops when a baseline already exists; S-002 owns incremental reconciliation and version governance.

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

PRD and Business Architecture retain their own in-scope `Open Questions`. The repository-level Registry may index those questions when useful, but it must not replace or empty the local sections.

### ❌ Implementation Content

Do not put concrete code modules, service decomposition, database products, frameworks, libraries, API paths, request or response schemas, protocol choices, algorithms, cloud services, infrastructure, deployment topology, retry or timeout implementation parameters, test implementation, Mock strategies, or operational implementation steps in the PRD or Business Architecture.

Candidate mechanisms include database, framework, protocol, cloud service, module, interface, and deployment suggestions even when they appear in the original request. Do not rewrite them as product constraints merely to retain them in the product-design baseline.

### Technical Input Disposition

Preserve technical input without making Discovery evaluate it:

1. When a Story, Technical Task, technical solution, Decision, or another durable technical document already owns the subject, write the input there or link to that authoritative source according to its maintenance rules.
2. When no suitable authoritative document or owner exists and the input should not be lost, use `.dev-cadence/skills/open-question-registry/SKILL.md` to register it in the Open Question Registry with its original status and suggested resolution stage.
3. Keep product or business questions that belong to the PRD or Business Architecture in that document's `Open Questions`; do not move them out merely because the Registry exists.

Moving, registering, linking, or excluding technical input must not be described as an accepted technical decision. Record it as preserved context for evaluation in the relevant technical-design stage.

Technical Input Disposition is supporting shared-asset maintenance, not a third primary Discovery output and not a Discovery process record. Update or link an existing authoritative Story, Technical Task, technical solution, Decision, or other technical asset only when that asset's maintenance rules allow it. When no suitable owner exists, invoke the shared Open Question Registry according to its own on-demand creation rules. Do not automatically create a Story, Technical Task, Decision, or another technical-design asset merely to dispose of Discovery input.

## Workflow Boundary

### ✅ Discovery Must

- create only the first product-design baseline version;
- keep product and business design durable outside `.dev-cadence/`;
- preserve unresolved and rejected material visibly;
- keep analysis stages in the current conversation rather than persisting copies of the workflow process;
- finish with one consolidated user confirmation covering both product-design documents.

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
Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation
```

The first four stages form one continuous exploration in the current conversation. Do not request separate approval after every subsection. Ask a question only when the answer materially affects the remaining product design. Stage 5 presents both complete documents for one consolidated confirmation.

## Persistence And Continuation

Discovery is an Asset Workflow. Its only primary new workflow outputs are:

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

Do not create a run manifest, stage records, confirmation records, rejection records, or duplicate analysis documents. Background, goals, scope, constraints, risks, unresolved questions, rejected directions, and future scope must be written directly into the authoritative document that owns the content. Supporting shared-asset maintenance performed through Technical Input Disposition does not become a Discovery primary output.

Use the current conversation, the user's goal, and the authoritative product-design documents to determine whether a request continues the same Discovery effort. Do not depend on a process record to restore stage state. When conversation context is incomplete, inspect the current documents and ask only for information that materially affects the baseline.

Discovery must not require a dedicated branch or workflow checkpoint commits. When the user asks to commit or save product-design changes, follow the target repository's ordinary Git rules and the user's request. Do not describe ordinary commits as workflow checkpoints, and do not put commit hashes or Git audit fields in the product-design documents. A commit does not replace the final user-confirmation gate.

## Product-Design Documents

The durable baseline consists of exactly these primary documents:

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

Both documents start with `Document Information` containing version `1` and `Last Updated`, and each contains its own `Change Log`. Change Log rows record version, date, change, and reason. Do not put Git commit hashes in the product documents.

Use `Open Questions` as the only unresolved-material section. Do not create separate Draft Ideas or Pending Decisions sections. When an answer is confirmed, move the conclusion into the relevant body section. Keep an unresolved question only while it remains unresolved.

Preserve explicitly rejected product or business directions under `Rejected Directions`. Put intentionally deferred product work under PRD `Future Scope`.

The product-design documents must not contain workflow approval metadata. Do not add approval status, approver, approval timestamp, checkpoint commit, or run status fields.

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

Business Architecture is not technical architecture. Do not prescribe code modules, databases, protocols, infrastructure, deployment design, or product-level constraints.

## Stage Rules

### 1. Background And Problem Exploration

Use:

```text
.dev-cadence/vendor/superpowers/skills/brainstorming/SKILL.md
```

Collect the source inventory, current situation, problem statement, affected users, observed evidence, assumptions, conflicts, and motivation in the current conversation. Carry confirmed product facts into the PRD and unresolved product questions into its `Open Questions`.

### 2. Goal And Value Definition

Define intended outcomes, user value, business value, success criteria, and the cost of leaving the problem unresolved in the current conversation. Write confirmed results directly into the PRD.

### 3. Scope And Business Architecture Analysis

Define scope, non-scope, product boundaries, business actors, domains, capabilities, value streams, processes, business objects, state lifecycles, rules, policies, constraints, risks, Open Questions, Rejected Directions, and Future Scope in the current conversation. Write each conclusion directly into the PRD or Business Architecture according to its content responsibility.

### 4. Product Design Baseline Creation

Use the workflow-start snapshot to distinguish a pre-existing baseline from documents created by the current Discovery effort. If either product-design document was already present before this first-time Discovery started, stop without modifying either document. If the current effort created the working baseline, keep editing those same drafts through Product Design Confirmation feedback or rejection; do not mistake them for a pre-existing baseline and do not route that feedback to S-002.

Before creating the initial baseline, run the Product And Technical Content Boundary classification over all source material and conclusions from the conversational analysis stages. Remove candidate implementation mechanisms from the product-design draft only after their disposition is recorded. Do not discard technical context.

Create both version-1 documents from the source material and current conversational conclusions. Keep their responsibilities separate and cross-reference them where useful. Do not fabricate completeness.

A later incremental Discovery mode must apply the same boundary to new input. If an existing baseline contains historical mixed product and technical content, do not silently delete, rewrite, or move it; S-002 must coordinate the authoritative source, migration, version change, and user confirmation.

### 5. Product Design Confirmation

Present one concise review containing:

- confirmed product goal, users, value, scope, and capabilities;
- business domains, actors, main processes, objects, states, and rules;
- important Open Questions and their impact;
- Rejected Directions and Future Scope;
- both document paths and version numbers;
- the boundary before work-item planning and technical architecture.

The review must also summarize each material technical input excluded from the product-design baseline, its current authoritative document or Registry entry, and its suggested resolution stage. Describe this as a handoff for later evaluation, not as approval of the suggested implementation.

Ask for one consolidated user confirmation of both documents. A commit does not count as confirmation.

If the user requests changes, update the affected authoritative documents and any related `Open Questions`, `Rejected Directions`, or `Future Scope`, then present the complete baseline again. Do not create a process record or start a separate Discovery run for feedback on the same baseline.

After confirmation, state that the version-1 product-design baseline is confirmed. Do not create a separate confirmation record or add approval metadata to either document. If the user rejects the baseline, do not claim it is confirmed and do not create a separate rejection record; continue refining the same authoritative documents only when the user requests changes.

## Completion Output

Return:

- product-design files created;
- version numbers;
- concise product and business-architecture summary;
- important Open Questions, Rejected Directions, and Future Scope;
- final confirmation status;
- the next installed workflow, when one exists.

If `work-item-planning` is installed and the user wants decomposition, recommend it after confirmation. Otherwise stop with the confirmed baseline and do not invent or advertise an unavailable workflow.
