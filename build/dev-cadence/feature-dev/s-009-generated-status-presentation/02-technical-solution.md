# Technical Solution

Confirmed requirement source: [01-requirements.md](01-requirements.md)

## Codebase Exploration Findings

### Shared convention ownership

- `src/skills/document-conventions/SKILL.md` already owns semantic marker presentation and machine-sensitive exclusions.
- The correct extension point is a dedicated status section in that skill, not duplicated mapping tables.

### Workflow integration

- `src/skills/using-dev-cadence/SKILL.md` already requires reading the shared skill before managed Markdown is written.
- Feature Dev, Bug Fix, Refactor, and Discovery contain the concrete manifest/report contracts; each needs a short symmetric rule naming the generated surfaces.

### Build and testing

- `tests/document-conventions-contract.sh` is the focused contract suite.
- `scripts/build.sh` copies `src/` into `dist/.dev-cadence`; `scripts/install.sh` supports dogfood installation.
- Root `version` must change because installable workflow behavior changes.

## Options

### Minimal change

Only add the mapping to `document-conventions`. This centralizes the data but leaves key output coverage implicit and weakly testable.

### Clean architecture

Introduce templates or a status-rendering helper consumed by all workflows. This is unnecessary because the assets are declarative Markdown skills rather than executable renderers.

### ✅ Selected: Pragmatic balance

Define the complete mapping once in `document-conventions`, add symmetric adoption rules to each workflow, and extend focused contract tests. This preserves single ownership while making output coverage explicit.

## Affected Boundaries

- Shared presentation contract: `src/skills/document-conventions/SKILL.md`
- Workflow output contracts: `src/skills/{feature-dev,bug-fix,refactor,discovery}/SKILL.md`
- Contract verification: `tests/document-conventions-contract.sh`
- User documentation and packaging: `README.md`, `README.zh-CN.md`, `version`, generated `dist/.dev-cadence/`

## Testing Strategy

- RED: extend the focused contract test and prove it fails before source changes.
- GREEN: implement the shared mapping and symmetric adoption rules.
- Run focused contracts, whitespace checks, build, source/distribution synchronization checks, dogfood installation, and the full repository check suite.

## Risks

- Emoji may accidentally become part of machine-consumed enums; explicit inline-code and exclusion rules prevent this.
- Workflow copies may drift; tests require adoption wording but keep the complete table only in the shared skill.

## Confirmation

Selected under the delegated authority in the user's parallel-execution instruction.
