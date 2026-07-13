# Technical Solution: S-001 Initial Discovery And PRD Baseline

## Confirmed Requirement Source

- `build/dev-cadence/feature-dev/s-001-discovery-prd-baseline/01-requirements.md`
- Work Item: `docs/stories/S-001-initial-discovery-prd-baseline.md`, version `4`

## Codebase Exploration Findings

### Perspective 1: Workflow Entry And Business Boundary

Key findings:

- `src/skills/using-dev-cadence/SKILL.md:20-39` currently limits Dev Cadence entry to development work and lists only `feature-dev`, `bug-fix`, and `refactor`.
- `src/skills/using-dev-cadence/SKILL.md:41-68` selects a delivery workflow directly; it needs an explicit initial-discovery route without claiming the later S-002 update capability.
- `src/AGENTS-snippet.md:12-18` tells target repositories to check Dev Cadence only for development work, so product ideas and requirement exploration may never reach the selector.
- `docs/workflows/discovery.md:7-63` already defines the human-facing five-stage business flow; its terminal decision must be broadened from PRD-only confirmation to confirmation of the complete product-design baseline.
- `README.md:27-43` and `README.zh-CN.md:25-41` describe Dev Cadence as starting only from development requests and must be updated because workflow availability is user-visible.

Established pattern:

- The entry skill owns flow selection; individual flow skills own stage execution.
- Human workflow documentation explains intent, while `SKILL.md` is the runtime authority.

Constraints and risks:

- S-001 must not advertise incremental PRD update behavior reserved for S-002.
- Existing active-run continuation must remain intact for the three delivery workflows.
- Discovery must not become a hidden prerequisite for direct development requests.

Essential files read:

- `src/skills/using-dev-cadence/SKILL.md`
- `src/AGENTS-snippet.md`
- `docs/workflows/discovery.md`
- `README.md`
- `README.zh-CN.md`

### Perspective 2: Workflow Records And Product-Design Ownership

Key findings:

- Existing workflows keep run manifests and stage records under `build/dev-cadence/<workflow>/<task-slug>/` and keep durable business assets outside `.dev-cadence`.
- `src/skills/feature-dev/SKILL.md:133-190` provides the portable manifest and stage-record pattern that Discovery should follow without inheriting implementation, system-testing, or Completion stages.
- `src/skills/feature-dev/SKILL.md:251-325` provides the consolidated brainstorming confirmation pattern. Discovery should use one final product-design confirmation rather than adding a confirmation gate after every exploratory subsection.
- Root-level Markdown and `docs/**` are exempt from new or updated automated tests; the product-design documents are human-facing, while the Discovery skill and routing behavior remain executable and testable.

Recommended artifact ownership:

- Durable product-design baseline:
  - `docs/product-design/prd.md`;
  - `docs/product-design/business-architecture.md`.
- Discovery run directory: `build/dev-cadence/discovery/<discovery-slug>/`.
- Run records:
  - `01-background-and-problem.md`
  - `02-goals-and-value.md`
  - `03-scope-and-business-architecture.md`
  - `05-product-design-confirmation-record.md`
- Stage 4 points to both durable product-design documents rather than copying either document into the run directory.

PRD version-1 structure:

- document version and last-updated metadata;
- product goal and problem statement;
- users and intended value;
- success criteria;
- scope and non-scope;
- product capabilities and requirements;
- non-functional requirements;
- constraints and risks;
- Open Questions, Rejected Directions, and Future Scope;
- Change Log.

Business Architecture version-1 structure:

- business architecture overview;
- business actors and responsibilities;
- business domains and boundaries;
- business capability map;
- value streams and business processes;
- business objects and relationships;
- state and lifecycle models;
- business rules and policies;
- business events and external boundaries;
- exceptions, architecture constraints, Open Questions, and Rejected Directions;
- Change Log.

Constraints and risks:

- If either product-design document already exists, S-001 must not overwrite it or pretend to support incremental reconciliation. It must stop and report that incremental update belongs to the later S-002 capability.
- Exploratory stage records must not compete with the two durable product-design documents as the product baseline.
- Approval metadata belongs only in the Discovery run record. The product-design documents contain Change Logs but no workflow approval fields.
- The final consolidated confirmation must cover both documents as one product-design baseline, not individual subsections in isolation.

Essential files read:

- `src/skills/feature-dev/SKILL.md`
- `docs/workflows/discovery.md`
- `docs/stories/S-001-initial-discovery-prd-baseline.md`
- `src/.dev-cadence.example.yaml`
- `AGENTS.md`

### Perspective 3: Packaging And Verification

Key findings:

- `scripts/build.sh:10-17` copies the complete `src/skills` tree, so adding `src/skills/discovery/SKILL.md` automatically reaches `dist`.
- `tests/package-contract.sh:45-71` has an explicit required-file list and source-to-dist equality check; Discovery must be added to the required list.
- `tests/skill-description-contract.sh:37-56` explicitly validates every skill description and must add Discovery.
- `tests/install-contract.sh:20-30` verifies package replacement and version equality but does not need Discovery-specific logic if the package contract verifies the file.
- `tests/run-all.sh:6-10` is the central test entry and can include a focused Discovery contract without expanding `workflow-symmetry.sh` further.

Recommended verification ownership:

- Add `tests/discovery-contract.sh` for executable Discovery rules and entry routing.
- Keep `tests/workflow-symmetry.sh` focused on the three delivery workflows.
- Do not add tests for generated product-design documents, `docs/workflows/discovery.md`, README prose, or Story prose.

Essential files read:

- `scripts/build.sh`
- `scripts/install.sh`
- `scripts/check-all.sh`
- `tests/run-all.sh`
- `tests/package-contract.sh`
- `tests/skill-description-contract.sh`
- `tests/install-contract.sh`

### Perspective 4: OC Discovery Skill Comparison

Key findings from the OC repository's `.codex/skills/discovery-to-prd/SKILL.md`:

- OC turns existing discovery material into a broad repository baseline spanning product, architecture, decisions, testing, current state, workflow, handoff, and agent instructions.
- Its strongest reusable rules are source precedence, preservation of unresolved conflicts and rejected directions, a review gate, and a strict boundary before story decomposition or application code.
- OC's single `docs/architecture.md` includes both business and technical concerns. Dev Cadence should preserve business architecture in Discovery while leaving technical architecture to later technical-solution work.
- OC's many-document baseline is broader than S-001. Dev Cadence should adopt only the product-design subset needed to make later work-item planning independent of the original chat.

Adopted from OC:

- use chat, handoffs, notes, and existing repository documents as discovery inputs;
- prefer explicit user confirmation and repository sources when inputs conflict, while preserving unresolved conflicts as Open Questions;
- preserve rejected directions so later agents do not reintroduce them;
- require future planning to be possible from durable product-design documents without rereading the original conversation;
- prohibit detailed work-item decomposition, technical implementation, migrations, and application-code changes.

Deliberately not adopted:

- separate architecture, decisions, open-questions, testing, current-state, workflow, handoff, and AGENTS documents;
- technical architecture as a mandatory Discovery output;
- approval metadata inside product-design documents.

## Architecture Alternatives

### Option A: Minimal-Change Clone

Copy `feature-dev/SKILL.md`, remove implementation stages, and rename the remaining sections for Discovery.

Advantages:

- Fastest initial authoring path.
- Reuses familiar manifest, checkpoint, and confirmation wording.

Disadvantages:

- Carries a large amount of irrelevant delivery logic and creates another long workflow skill.
- High risk of stale references to code implementation, testing, worktrees, Business Acceptance, or Completion.
- Repeats the workflow-length problem that motivated a separate Discovery flow.

Decision: rejected.

### Option B: Shared Workflow Framework

Extract configuration, Git checkpoint, manifest, confirmation, and path rules into shared helpers or a common base skill, then compose Discovery and the existing workflows from it.

Advantages:

- Reduces repeated governance language.
- Could support future `work-item-planning`, Release, and Deployment workflows.

Disadvantages:

- Broad refactor across four existing workflows before Discovery delivers user value.
- Increases installation and skill-loading complexity.
- Exceeds S-001 scope and risks destabilizing current workflows.

Decision: deferred as a possible later refactor only after more workflow shapes exist.

### Option C: Focused Standalone Discovery Skill

Create a concise standalone `discovery` skill that reuses only established concepts: configuration, portable records, checkpoints, manifest updates, consolidated brainstorming confirmation, and explicit routing boundaries.

Advantages:

- Delivers the complete S-001 capability without changing existing delivery workflow internals.
- Keeps Discovery smaller and understandable.
- Provides a concrete second workflow shape before considering shared abstractions.
- Supports focused executable contract tests.

Disadvantages:

- Duplicates a limited amount of governance wording.
- Future common-rule changes may require symmetric updates until a justified shared abstraction exists.

Decision: recommended.

## Recommended Design

### Discovery Skill

Add:

```text
src/skills/discovery/SKILL.md
```

The skill will:

- trigger only for initial product/system discovery, broad ideas, problem exploration, or first-time product-design baseline creation;
- use vendored Superpowers `brainstorming` as its exploration method;
- read `.dev-cadence.yaml` for `output_language`, using the existing fallback behavior;
- use `build/dev-cadence/discovery/<discovery-slug>/` for manifest and stage records;
- keep the durable product-design baseline at `docs/product-design/prd.md` and `docs/product-design/business-architecture.md`;
- implement the five stages from `docs/workflows/discovery.md`;
- use one consolidated user confirmation for the complete two-document product-design baseline;
- stop before work-item decomposition, technical implementation, application changes, system testing, Business Acceptance, or branch finishing;
- refuse to overwrite either existing product-design document because incremental update belongs to S-002.

The stage sequence will be:

```text
Background And Problem Exploration
-> Goal And Value Definition
-> Scope And Business Architecture Analysis
-> Product Design Baseline Creation
-> Product Design Confirmation
```

The first four stages prepare one coherent product-design baseline. The final confirmation covers both version-1 documents and, once confirmed, marks the preceding Discovery evidence current for that baseline.

### Entry Routing

Update `using-dev-cadence` so that:

- broad product ideas, business problems, first-time product definition, and requests to create an initial PRD or business architecture route to `discovery`;
- direct feature, bug, and refactor requests continue to route to existing workflows without passing through Discovery;
- requests to update an existing PRD are not claimed as supported by S-001;
- active Discovery follow-up continues the existing Discovery run.

Update `src/AGENTS-snippet.md` so target repositories check Dev Cadence for product discovery and requirement work as well as development work.

### Product Design Document Contract

Use these default durable paths:

```text
docs/product-design/prd.md
docs/product-design/business-architecture.md
```

The PRD owns product intent and required outcomes:

- product overview, goal, background, and problem statement;
- users, stakeholders, needs, value, goals, and success criteria;
- scope, non-scope, product boundaries, capabilities, and product requirements;
- non-functional requirements, constraints, assumptions, and external dependencies;
- Open Questions, Rejected Directions, Future Scope, and Change Log.

The Business Architecture owns how the product operates as a business system:

- business actors and responsibilities;
- business domains, boundaries, capabilities, ownership, and dependencies;
- value streams, processes, triggers, outcomes, handoffs, and decision points;
- business objects, relationships, ownership, and sources of truth;
- states, lifecycle transitions, business rules, policies, permissions, events, exceptions, and external boundaries;
- architecture constraints, Open Questions, Rejected Directions, and Change Log.

Both documents use `Open Questions` for unresolved material. They do not add separate `Draft Ideas` or `Pending Decisions` sections. Confirmed answers move into the relevant body section; explicitly rejected directions remain preserved; deferred work belongs in PRD Future Scope.

The documents do not contain baseline approval fields. User confirmation, timestamps, checkpoint commits, and evidence belong only in `build/dev-cadence/discovery/<discovery-slug>/manifest.md` and the final confirmation record.

S-001 creates only version 1 of both documents. It does not define version increment or reconciliation behavior beyond the Change Log structure needed by S-002.

### Packaging And Public Documentation

Update:

- `tests/package-contract.sh` required file list;
- `tests/skill-description-contract.sh`;
- `tests/run-all.sh`;
- `README.md` and `README.zh-CN.md` workflow overview;
- `src/AGENTS-snippet.md` trigger wording;
- `version` with a patch release;
- `docs/backlog.md` and the S-001 Story status only after implementation and verification.

No `scripts/build.sh` change is needed because it already copies `src/skills` recursively.

## Testing Strategy

### RED/GREEN Contract Test

Add `tests/discovery-contract.sh` before the skill implementation. It will fail while Discovery is missing, then verify:

- `src/skills/discovery/SKILL.md` exists with the expected trigger description;
- the five-stage sequence and run directory are defined;
- both `docs/product-design/prd.md` and `docs/product-design/business-architecture.md` are durable output paths;
- the required PRD and Business Architecture content boundaries exist;
- unresolved material uses Open Questions without separate Draft Ideas or Pending Decisions sections;
- workflow approval metadata is kept out of product-design documents;
- overwrite of either existing product-design document is forbidden;
- Feature, Story, Bug, and Technical Task creation is excluded;
- application code modification and delivery-stage behavior are excluded;
- `using-dev-cadence` routes initial discovery requests correctly without forcing direct development through Discovery.

### Existing Contracts

- `tests/package-contract.sh`: Discovery is present and source/dist remain synchronized.
- `tests/skill-description-contract.sh`: the description is trigger-only and contains no process summary.
- `tests/install-contract.sh`: the updated package replaces an older installation cleanly.
- `scripts/check-all.sh`: build, whitespace, package, skill, Discovery, installation, and existing workflow contracts pass.

Human-facing Markdown under the repository root and `docs/**` will not receive new content tests.

## Risks And Constraints

- Entry wording may become too broad and route ordinary development into Discovery. The selector must explicitly preserve direct delivery routes.
- A single final confirmation can hide unresolved material unless Open Questions and document boundaries are mandatory and visible.
- Existing-product-design handling must fail safely until S-002 exists; silent overwrite would destroy requirement and business-architecture history.
- Repeating common manifest and checkpoint rules creates some maintenance cost, but extracting a framework now would create a larger and less verifiable change.
- README updates are required for user-visible workflow availability but do not require new tests.

## Files Expected To Change

- Add `src/skills/discovery/SKILL.md`.
- Modify `src/skills/using-dev-cadence/SKILL.md`.
- Modify `src/AGENTS-snippet.md`.
- Add `tests/discovery-contract.sh`.
- Modify `tests/run-all.sh`.
- Modify `tests/package-contract.sh`.
- Modify `tests/skill-description-contract.sh`.
- Modify `README.md`.
- Modify `README.zh-CN.md`.
- Modify `version`.
- After implementation verification, modify `docs/stories/S-001-initial-discovery-prd-baseline.md` and `docs/backlog.md`.

## Technical Solution Decision

- Recommended option: focused standalone Discovery skill.
- Status: `awaiting user confirmation`.
- Stage checkpoint: `skipped: no tracked changes`.
