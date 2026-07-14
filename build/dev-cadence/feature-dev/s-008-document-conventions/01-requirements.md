# S-008 Requirements Confirmation

## Requirement Source

- [S-008 Skill 语义视觉规范](../../../../docs/stories/S-008-skill-semantic-visual-markers.md), Version `2`
- Current conversation clarifying that semantic emoji apply to skill examples, paired boundary sections, Red Flags, and other high-value comparison blocks.

## Confirmed Scope

1. Create `src/skills/document-conventions/SKILL.md` as a shared auxiliary skill and include it in the built `.dev-cadence` package.
2. Define `document-conventions` as the authoritative source for common presentation rules used by Dev Cadence-managed Markdown documents. It is not a business workflow and does not create a workflow run.
3. Define these stable semantic markers:
   - `✅`: required, applicable, correct, or passed;
   - `❌`: forbidden, not applicable, incorrect, or failed;
   - `❓`: ambiguous, unresolved, or requiring clarification;
   - `⚠️`: risk, exception, warning, or conditional execution;
   - `ℹ️`: necessary supplementary information.
4. Require every marker to appear with explicit text, decision, or reason. Emoji must not be the only source of meaning.
5. Apply markers selectively to high-value comparison and decision structures, including Must/Must Not, Allowed/Forbidden, positive/negative/ambiguous examples, Passed/Failed, and Red Flags.
6. Avoid mechanical decoration of ordinary prose and ordinary list items.
7. Do not put emoji in filenames, paths, commands, IDs, configuration values, Git references, machine-consumed values, or canonical status enums.
8. Update `using-dev-cadence` so a workflow must read `document-conventions` before creating or updating Dev Cadence-managed Markdown. The entry skill must not duplicate the complete semantic mapping.
9. Apply the shared semantics to representative high-value sections in the currently installed workflow skills without changing their business rules, stages, confirmation gates, or status machines.
10. Add contract coverage for the shared skill, package inclusion, entry integration, stable marker meanings, accompanying text, and representative workflow usage.
11. Update the installable package and evaluate the repository version because this changes installed workflow behavior.

## Non-Goals

- Do not implement S-009 status presentation for manifests, reports, or user summaries.
- Do not implement S-010 document-link conventions or link-integrity checking.
- Do not add emoji to every heading, paragraph, or list item.
- Do not replace normative words such as `must`, `do not`, `when`, `before`, or `after` with visual markers.
- Do not change workflow routing, stage order, confirmation requirements, status values, or completion semantics.
- Do not add a new business workflow, workflow run type, or route in the Available Flows table.
- Do not modify vendored Superpowers files.

## Acceptance Criteria

1. `src/skills/document-conventions/SKILL.md` exists and is installed at `.dev-cadence/skills/document-conventions/SKILL.md` after build/install.
2. The shared skill explicitly states that it is an auxiliary document convention, not a business workflow, and creates no run.
3. The five markers have stable, non-conflicting meanings and always retain accompanying text.
4. Must/Must Not, positive/negative/ambiguous examples, and Red Flags can use consistent markers for rapid scanning.
5. Ordinary prose and machine-sensitive literals are not mechanically decorated.
6. `using-dev-cadence` requires reading the shared convention before writing Dev Cadence-managed Markdown and does not duplicate the full mapping.
7. Discovery, Feature Dev, Bug Fix, and Refactor contain representative high-value semantic markers without business-rule changes.
8. Source skills and the built distribution contain the same rules.
9. Contract tests verify shared-skill packaging, entry integration, stable semantics, and representative usage without locking all natural-language wording.
10. Existing repository checks pass, and the version is updated consistently with the installed behavior change.

## Assumptions

- The current build process already copies every directory under `src/skills`, so a new skill directory requires contract coverage but no build-script redesign.
- Representative workflow updates are sufficient for S-008; exhaustive visual restyling is intentionally excluded.
- S-009 and S-010 will extend the same shared skill in later backlog tasks.

## Open Questions

- None.
