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

Do not use this S-001 workflow to update or reconcile an existing product-design baseline. If either `docs/product-design/prd.md` or `docs/product-design/business-architecture.md` already exists, stop before changing either file and explain that incremental update belongs to the later product-design versioning capability.

Direct requests for a clear feature, bug fix, or behavior-preserving refactor do not have to pass through Discovery. Route them to their matching installed delivery workflow.

## Configuration

Before producing user-facing workflow documents or records, read:

```text
.dev-cadence.yaml
```

Use `output_language` for product-design documents, stage records, manifest content, and user-facing summaries:

- `en`: English;
- `zh-CN`: Simplified Chinese.

If the configuration is missing or unsupported, use `en`.

## Generated Status Presentation

When writing or updating user-visible status summaries, apply the shared status presentation mapping from `document-conventions`. Use it consistently for the manifest and stage table, stage records and reports, review and test conclusions, coverage, verification, business acceptance, Completion, and user-facing progress summaries while preserving every canonical status value.

## Generated Document References

Apply the shared document-reference rules from `document-conventions` to every Dev Cadence-managed Markdown document. Check local links in all tracked Markdown before each commit; check local links in all generated documents for the current run before Completion. Keep the complete selection, identity, lifecycle, and URI contract in the shared skill rather than duplicating it here.

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

## Workflow Boundary

### ✅ Discovery Must

- create only the first product-design baseline version;
- keep product and business design durable outside `.dev-cadence/`;
- preserve unresolved and rejected material visibly;
- finish with one consolidated user confirmation covering both product-design documents.

### ❌ Discovery Must Not

- Do not create Feature, Story, Bug, or Technical Task cards.
- Do not create or maintain a work-item Roadmap.
- Do not design technical architecture, modules, services, databases, APIs, or deployment topology.
- Do not create database migrations.
- Do not modify application code.
- Do not perform implementation, system testing, Business Acceptance, release, deployment, or branch finishing.

## Stage Sequence

```text
Background And Problem Exploration -> Goal And Value Definition -> Scope And Business Architecture Analysis -> Product Design Baseline Creation -> Product Design Confirmation
```

The first four stages form one continuous exploration. Do not request separate approval after every subsection. Ask a question only when the answer materially affects the remaining product design. Stage 5 presents both complete documents for one consolidated confirmation.

## Run Records

Use one repository-relative run directory:

```text
build/dev-cadence/discovery/<discovery-slug>/
```

Create and maintain:

```text
build/dev-cadence/discovery/<discovery-slug>/manifest.md
build/dev-cadence/discovery/<discovery-slug>/01-background-and-problem.md
build/dev-cadence/discovery/<discovery-slug>/02-goals-and-value.md
build/dev-cadence/discovery/<discovery-slug>/03-scope-and-business-architecture.md
build/dev-cadence/discovery/<discovery-slug>/05-product-design-confirmation-record.md
```

Stage 4 writes the durable product-design documents directly. Do not create duplicate PRD or Business Architecture copies in the run directory.

The manifest must include:

- workflow, discovery slug, repository, workspace, branch, started at, current stage, and overall status;
- both durable product-design document paths and version `1`;
- a stage table with status, artifact, user confirmation, checkpoint commit, and notes;
- important Open Questions and residual product-design risks;
- the final user decision once available.

Use repository-relative paths. Do not persist machine-specific absolute paths, temporary service state, tokens, or secrets.

Use stage status values `pending`, `in_progress`, `confirmed`, `blocked`, or `skipped`. Use overall status values `in_progress`, `confirmed`, `rejected`, or `abandoned`.

## Git Checkpoints

Before creating a checkpoint, ensure the work is on a dedicated branch and include only files related to the active Discovery run. Run checks appropriate to the changed files and report the commit hash.

Create a checkpoint when a stage produces reviewable tracked changes. If ignored run records are the only stage output, do not force-add ignored run records; record `skipped: no tracked changes` in the manifest. Do not create empty commits.

A checkpoint commit does not count as user confirmation. Record the final user decision separately in the manifest and confirmation record.

Do not push unless the user explicitly asks. Do not merge, discard, rewrite history, or delete a branch as part of Discovery.

## Product-Design Documents

The durable baseline consists of exactly these primary documents:

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

Both documents start with `Document Information` containing version `1` and `Last Updated`, and each contains its own `Change Log`. Change Log rows record version, date, change, and reason. Do not put Git commit hashes in the product documents.

Use `Open Questions` as the only unresolved-material section. Do not create separate Draft Ideas or Pending Decisions sections. When an answer is confirmed, move the conclusion into the relevant body section. Keep an unresolved question only while it remains unresolved.

Preserve explicitly rejected product or business directions under `Rejected Directions`. Put intentionally deferred product work under PRD `Future Scope`.

The product-design documents must not contain workflow approval metadata. Do not add approval status, approver, approval timestamp, checkpoint commit, or run status fields. Those belong only in the Discovery manifest and confirmation record.

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

Collect the source inventory, current situation, problem statement, affected users, observed evidence, assumptions, conflicts, and motivation. Write `01-background-and-problem.md` and update the manifest.

### 2. Goal And Value Definition

Define intended outcomes, user value, business value, success criteria, and the cost of leaving the problem unresolved. Write `02-goals-and-value.md` and update the manifest.

### 3. Scope And Business Architecture Analysis

Define scope, non-scope, product boundaries, business actors, domains, capabilities, value streams, processes, business objects, state lifecycles, rules, policies, constraints, risks, Open Questions, Rejected Directions, and Future Scope. Write `03-scope-and-business-architecture.md` and update the manifest.

### 4. Product Design Baseline Creation

Before writing, verify that neither product-design document exists. If either exists, stop without modifying either document.

Before creating the initial baseline, run the Product And Technical Content Boundary classification over the source material and all stage records. Remove candidate implementation mechanisms from the product-design draft only after their disposition is recorded. Do not discard technical context.

Create both version-1 documents from the current stage records and source material. Keep their responsibilities separate and cross-reference them where useful. Do not fabricate completeness. Update the manifest to point to both durable documents.

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

Ask for one consolidated user confirmation of both documents. A commit or checkpoint does not count as confirmation.

If the user requests changes, update the earliest affected stage record and both durable documents as needed, then present the complete baseline again. Do not start a separate Discovery run for feedback on the same baseline.

After confirmation, write `05-product-design-confirmation-record.md`, record the user decision in the manifest, and set overall status to `confirmed`. If rejected, record the rejection without claiming the baseline is ready.

## Completion Output

Return:

- product-design files created;
- version numbers;
- concise product and business-architecture summary;
- important Open Questions, Rejected Directions, and Future Scope;
- final confirmation status;
- the next installed workflow, when one exists.

If `work-item-planning` is installed and the user wants decomposition, recommend it after confirmation. Otherwise stop with the confirmed baseline and do not invent or advertise an unavailable workflow.
