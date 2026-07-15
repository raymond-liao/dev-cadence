# Technical Solution

Confirmed requirement source: [01-requirements.md](01-requirements.md)

## Codebase Exploration Findings

- `src/skills/discovery/SKILL.md` owns product-design asset behavior and already contains the S-006 content boundary and S-013 no-process-record model.
- `src/skills/using-dev-cadence/SKILL.md` owns initial versus incremental routing.
- `tests/discovery-contract.sh`, `tests/routing-contract.sh`, and `tests/skill-description-contract.sh` enforce the installed contract.
- `docs/workflows/discovery.md`, README files, Story, Backlog, and `version` expose user-visible behavior and release state.

## Alternatives

- Minimal change: replace only the existing-baseline refusal. Rejected because it leaves discovery, version, migration, and handoff rules implicit.
- Clean architecture: introduce a shared product-design asset skill. Rejected because S-002 does not justify a new abstraction.
- Pragmatic balance: extend Discovery with explicit initial and incremental modes, shared boundaries, and mode-specific mutation rules; update entry routing and focused contracts. Selected.

## Testing Strategy

Add failing contract assertions first, implement the rules in `src`, build `dist`, then run focused contracts, build, whitespace, full checks, source/distribution parity checks, and full-diff review.

## Risks

- Reintroducing Discovery process records from the obsolete S-002 wording.
- Treating file presence alone as routing intent.
- Versioning path-only changes or silently cleaning historical mixed content.
