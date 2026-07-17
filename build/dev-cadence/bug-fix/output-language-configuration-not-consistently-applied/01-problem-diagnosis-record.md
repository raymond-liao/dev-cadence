# B-004 Problem Diagnosis

## Status

🔄 `in_progress`

## Input Identity

- Work item: `docs/bugs/B-004-output-language-configuration-not-consistently-applied.md`, Version `1`, Status `Draft`
- Workflow: `bug-fix`
- Repository: `dev-cadence`
- Branch: `codex/b-004-output-language-configuration-not-consistently-applied`
- Code identity: `9834d2e`
- Configuration: `.dev-cadence.yaml` contains `output_language: zh-CN` and `worktree.enabled: true`

## Reported Symptom

When the target repository configures `output_language: zh-CN`, some workflow documents and stage records still appear in English. The card reports variation by workflow, worktree, session recovery, and record type, but does not identify one generated artifact as the canonical reproduction.

## Expected Behavior

All configuration-constrained workflow documents and user-visible stage summaries must use Simplified Chinese. Main checkout, isolated worktree, and recovered sessions must use the same target-repository configuration source. Missing or unsupported configuration must use the documented default language and explain that fallback.

## Confirmed Evidence

1. The target config is intentionally local and ignored by Git: `.gitignore:26` ignores `.dev-cadence.yaml`.
2. The config is not part of the committed tree; only `src/.dev-cadence.example.yaml` is tracked.
3. The vendored worktree procedure creates a checkout with `git worktree add` and changes into it: `src/vendor/superpowers/skills/using-git-worktrees/SKILL.md:90-98`.
4. Direct reproduction in this run: the new B-004 worktree initially had no `.dev-cadence.yaml`; after explicit local setup, the file became available. This confirms the configuration does not propagate through Git worktree creation.
5. The delivery workflows read `.dev-cadence.yaml` relative to their current workspace and fall back to English when it is missing: `src/skills/feature-dev/SKILL.md:26-49`, `src/skills/bug-fix/SKILL.md:26-49`, and `src/skills/refactor/SKILL.md:26-49`.
6. A new agent or a resumed session operating from the uninitialized worktree can therefore select English without contradicting the current rules.
7. The existing symmetry test checks only for configuration wording, not propagation or generated output: `tests/workflow-symmetry.sh:499-502`.
8. `work-item-analysis` defines the language mapping but does not explicitly require using the selected language for its analysis proposals and summaries: `src/skills/work-item-analysis/SKILL.md:23-29`.

## Reproduction Evidence

The configuration-loss portion is reproducible: create a worktree from `main`, observe that `.dev-cadence.yaml` is absent, then provide the local config explicitly. The generated-document reproduction across a newly created worktree and a resumed session remains pending and belongs in the next diagnosis iteration or regression plan.

## Impact Scope

- Primary: `feature-dev`, `bug-fix`, and `refactor` when `worktree.enabled: true`.
- Related: work-item analysis summaries and continuation paths that rely on a new worktree without a durable configuration snapshot.
- Verification surfaces: stage records, manifests, plans, reports, and user-visible status summaries.
- Not implicated by current evidence: the supported language set, translation quality, workflow stage model, or record model.

## Root Cause Hypothesis

**High confidence hypothesis:** configuration ownership is local to the main checkout, but the workflow creates a separate Git worktree without propagating the ignored configuration. The workflow then treats the missing config as a normal default-to-English case. Session recovery makes the same boundary visible because the resumed workspace does not contain the original local config.

This is a root-cause hypothesis, not yet the final repair boundary: the exact generated artifact and stage transition still need direct verification.

## Secondary Rule Gaps

- The delivery workflow configuration sections do not explicitly state how the target repository's stable config source is retained when execution moves into a worktree.
- Fallback to English is specified, but no user-visible diagnostic or durable identity is required, so config loss is silent.
- `work-item-analysis` lacks a normative rule to use the selected language for its listed output surfaces.

## Open Questions

- Should the stable source be copied into each worktree, resolved from the main checkout, or captured as a workflow configuration snapshot?
- Which component owns propagation: the Dev Cadence workflow wrapper or the vendored worktree skill? Direct edits to `src/vendor/superpowers/skills/**` are outside the current repository change boundary unless explicitly treated as a vendored update.
- Does the target platform offer a native worktree implementation that already propagates ignored local files?
- Which exact generated record first demonstrates the English fallback after worktree creation or session recovery?

## Routing Decision

The card is sufficiently defined to continue through `bug-fix` Problem Diagnosis. The next business output is a confirmed diagnosis and then a Repair Solution; no implementation should start before those stages and the Repair Plan are confirmed.
