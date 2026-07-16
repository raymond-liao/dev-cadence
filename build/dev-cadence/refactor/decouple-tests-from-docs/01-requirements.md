# Requirements Confirmation: Decouple Automated Tests From `docs/`

## Status

🔄 `in_progress` - awaiting user confirmation.

## Structural Goal

Remove automated-test dependencies on repository files and directories under `docs/`. Tests must validate executable or machine-consumed sources directly. When a test needs representative Markdown content, it must create a fixed test-local sample instead of reading a human-facing repository document as a fixture.

## Evidence

The current suite has two direct `docs/` input dependencies:

- `tests/discovery-contract.sh` reads `docs/workflows/discovery.md` and `docs/stories/S-002-discovery-prd-incremental-versioning.md`, then asserts selected natural-language patterns.
- `tests/document-conventions-contract.sh` scans work-item cards under `docs/features`, `docs/stories`, `docs/bugs`, and `docs/tasks`, then asserts headings in those human-facing documents.

This conflicts with the repository's Documentation Test Boundary, which states that automated tests must not be added or modified solely to lock human-facing documentation wording.

## Included Scope

- Remove direct reads and scans of repository files under `docs/` from automated tests.
- Delete assertions whose only purpose is to lock explanatory document wording.
- Preserve tests of `src/skills/**`, `src/AGENTS-snippet.md`, scripts, configuration, package contents, and other executable or machine-consumed assets.
- Preserve assertions that a workflow declares a target output path under `docs/`; such assertions test the workflow contract string, not a repository document.
- Use test-local fixed Markdown samples only when a parser, checker, or executable behavior genuinely requires document-shaped input.
- Verify that no automated test retains a repository `docs/` file or directory as input.

## Excluded Scope

- Reorganizing or editing the documents under `docs/`.
- Changing workflow behavior or target-repository artifact paths.
- Rewriting unrelated contract tests.
- Adding tests for human-facing wording, links, formatting preferences, or documentation completeness.
- Changing `src/vendor/superpowers/**`.

## Behavior To Preserve

- Contract checks for runtime workflow rules and installed package behavior continue to run.
- `bash scripts/check-all.sh` remains the repository-wide verification entry point.
- Workflow-declared target paths such as `docs/product-design/prd.md` remain testable as literal runtime contracts.
- Work-item heading semantics remain covered at their machine-consumed rule source rather than through repository documentation instances.

## Success Criteria

1. `rg` finds no test that opens, scans, or asserts against `$ROOT_DIR/docs/**`.
2. The two existing direct dependencies are removed or replaced without weakening checks of executable rule sources.
3. Any document-shaped fixture required by executable test logic is owned by the test itself.
4. Focused affected tests pass.
5. `bash scripts/check-all.sh` passes.

## Risks And Assumptions

- Removing explanatory-document assertions may reveal that some intended rule is not asserted at its authoritative source. Such a rule should be tested against `src/skills/**`, not copied from `docs/` merely to retain assertion count.
- `tests/document-conventions-contract.sh` currently checks both authoritative skill rules and concrete docs instances. Removing the instance scan intentionally stops treating current work-item documents as test fixtures.
- No open question remains for this bounded requirement.
