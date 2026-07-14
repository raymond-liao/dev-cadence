# Technical Solution

Requirement source: `build/dev-cadence/feature-dev/t-001-work-item-scope-markers/01-requirements.md`

## ✅ Selected: Shared Rule With Contract Enforcement

- Add one normative section to `src/skills/document-conventions/SKILL.md` defining the paired headings, their meaning, and their quality/acceptance boundary.
- Extend `tests/document-conventions-contract.sh` to verify the shared rule and scan existing work-item directories without locking body prose.
- Mechanically migrate existing Story headings; the existing Task card already uses the target headings.
- Build `dist/.dev-cadence`, install it into the current repository for dogfood verification, and bump the package minor version because this changes an installable user-visible authoring rule.

## Alternatives

- Update cards only: rejected because future generated work items would regress.
- Duplicate the rule into each workflow: rejected because `document-conventions` owns shared presentation semantics.

## Risks And Constraints

- The migration must not change work-item meaning or list content.
- The contract must tolerate absent future work-item directories while enforcing every Markdown card in directories that exist.

## Testing Strategy

- RED: contract fails because the shared headings are absent from the source rule.
- GREEN: focused contract passes after rule and card migration.
- System: whitespace check, build/package checks, full contract suite, source/dist/dogfood synchronization checks.
