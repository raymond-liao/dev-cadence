#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
REPO_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates.XXXXXX")"
OUTPUT_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-output.XXXXXX")"
LANG_REPO="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-language.XXXXXX")"
OUTSIDE_REPO="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-outside.XXXXXX")"
LOCAL_STATE_REPO="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-local-state.XXXXXX")"
CONTRACT_REPO="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-contract.XXXXXX")"
CONTRACT_BUNDLE="$(mktemp -d "${TMP_ROOT}/dev-cadence-gates-bundle.XXXXXX")"
SPECS_DIR="${REPO_DIR}/specs/records"
LANG_SPECS_DIR="${LANG_REPO}/specs/records"
CONTRACT_SPECS_DIR="${CONTRACT_REPO}/specs/records"
RESEARCH_SPECS_DIR="${OUTPUT_DIR}/research-specs"
TASK_ID="gate-fixture"
RESEARCH_TASK_ID="research-fixture"
RUN_ID="gate-fixture-run-1"
trap 'rm -rf "${REPO_DIR}" "${OUTPUT_DIR}" "${LANG_REPO}" "${OUTSIDE_REPO}" "${LOCAL_STATE_REPO}" "${CONTRACT_REPO}" "${CONTRACT_BUNDLE}"' EXIT

assert_command_fails_with() {
  local expected_text="$1"
  shift
  local output_file="${OUTPUT_DIR}/failure.out"

  if "$@" > "${output_file}" 2>&1; then
    echo "expected command to fail: $*" >&2
    exit 1
  fi

  grep -Fq "${expected_text}" "${output_file}" || {
    echo "expected failure text: ${expected_text}" >&2
    cat "${output_file}" >&2
    exit 1
  }
}

mkdir -p "${OUTSIDE_REPO}/src"
git -C "${OUTSIDE_REPO}" init -q
cat > "${OUTSIDE_REPO}/src/app.txt" <<'EOF'
before
EOF
git -C "${OUTSIDE_REPO}" add src/app.txt
git -C "${OUTSIDE_REPO}" commit -q -m "test: seed outside fixture"
printf 'after\n' > "${OUTSIDE_REPO}/src/app.txt"

node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${OUTSIDE_REPO}" \
  --plugin-dir "${ROOT_DIR}" > "${OUTPUT_DIR}/outside-ready.out"
grep -Fq "Scope: outside-dev-cadence" "${OUTPUT_DIR}/outside-ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/outside-ready.out"
grep -Fq "SKIP Commit candidate is outside Dev Cadence workflow; G1-G6 and Human Gate checks skipped." "${OUTPUT_DIR}/outside-ready.out"

mkdir -p "${LOCAL_STATE_REPO}/docs" "${LOCAL_STATE_REPO}/.dev-cadence/sdd"
git -C "${LOCAL_STATE_REPO}" init -q
cat > "${LOCAL_STATE_REPO}/AGENTS.md" <<'EOF'
# Test Agent Rules

No embedded Dev Cadence runtime is configured here.
EOF
cat > "${LOCAL_STATE_REPO}/docs/backlog.md" <<'EOF'
# Backlog
EOF
cat > "${LOCAL_STATE_REPO}/.gitignore" <<'EOF'
.dev-cadence/
EOF
printf 'local state\n' > "${LOCAL_STATE_REPO}/.dev-cadence/sdd/state.txt"
git -C "${LOCAL_STATE_REPO}" add AGENTS.md docs/backlog.md .gitignore
git -C "${LOCAL_STATE_REPO}" commit -q -m "test: seed local state fixture"
printf '\nLocal source repo guidance.\n' >> "${LOCAL_STATE_REPO}/AGENTS.md"
printf '\n- backlog update\n' >> "${LOCAL_STATE_REPO}/docs/backlog.md"

node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${LOCAL_STATE_REPO}" \
  --plugin-dir "${ROOT_DIR}" > "${OUTPUT_DIR}/local-state-ready.out"
grep -Fq "Scope: outside-dev-cadence" "${OUTPUT_DIR}/local-state-ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/local-state-ready.out"
grep -Fq "SKIP Commit candidate is outside Dev Cadence workflow; G1-G6 and Human Gate checks skipped." "${OUTPUT_DIR}/local-state-ready.out"

mkdir -p "${REPO_DIR}/src" "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}"
git -C "${REPO_DIR}" init -q
cat > "${REPO_DIR}/src/app.txt" <<'EOF'
before
EOF
git -C "${REPO_DIR}" add src/app.txt
git -C "${REPO_DIR}" commit -q -m "test: seed fixture"

cat > "${SPECS_DIR}/${TASK_ID}/00-brief.md" <<'EOF'
# Brief

```yaml
task_id: gate-fixture
selected_workflow: bugfix
task_class: S1
goal: Fix fixture behavior.
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/01-requirements.md" <<'EOF'
# Requirements

```yaml
status: ready_for_implementation
goal: Fix fixture behavior.
scope:
  - src/app.txt
non_goals: []
acceptance_criteria:
  - fixture gate checks pass
open_questions: []
```

## Requirements Readiness Check

```yaml
ready_for_implementation: true
accepted_by_human: Raymond
blocking_questions: []
```

## Gate G1

```yaml
gate_id: G1
status: passed
decision: passed
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/03-tasks.md" <<'EOF'
# Tasks

```yaml
status: executable
task_class: S1
selected_workflow: bugfix
target_files:
  - src/app.txt
verification_plan:
  - inspect fixture
```

## Gate G3

```yaml
gate_id: G3
status: passed
decision: passed
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/05-implementation.md" <<'EOF'
# Implementation

```yaml
status: implemented
planned_files:
  - src/app.txt
changed_files:
  - src/app.txt
created_artifact_files: []
unplanned_changed_files: []
deleted_files: []
scope_reconciliation: passed
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/06-test-report.md" <<'EOF'
# Test Report

```yaml
status: complete
verification_status: not_verified
commands_run: []
residual_risk:
  - verification intentionally missing
```

## Gate G4

```yaml
gate_id: G4
status: blocked
verification_status: not_verified
human_override: null
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/07-review-report.md" <<'EOF'
# Review Report

```yaml
status: blocked
decision: blocked
blockers:
  - verification missing
major_issues: []
residual_risk: []
```

## Gate G5

```yaml
gate_id: G5
status: blocked
decision: blocked
g4_status: blocked
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status: blocked_pending_named_human
accepted_by_human:
accepted_scope: []
evidence_reviewed: []
residual_risk_accepted: []
```

## Gate G6

```yaml
gate_id: G6
status: blocked
human_accepter:
decision: blocked_pending_named_human
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/run-context.md" <<'EOF'
# Run Context

```yaml
run_id: gate-fixture-run-1
task_id: gate-fixture
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/pre-implementation-status.md" <<'EOF'
# Pre-Implementation Status

```yaml
run_id: gate-fixture-run-1
task_id: gate-fixture
implementation_authorized: true
post_hoc_backfill: false
authorized_target_files:
  - src/app.txt
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/execution-report.md" <<'EOF'
# Execution Report

```yaml
run_id: gate-fixture-run-1
task_id: gate-fixture
files_changed:
  - src/app.txt
untracked_files: []
implementation_authorized: true
post_hoc_backfill: false
verification_status: verified
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/tool-log.md" <<'EOF'
# Tool Log

```yaml
run_id: gate-fixture-run-1
commands_or_tools: []
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/permission-decisions.md" <<'EOF'
# Permission Decisions

```yaml
run_id: gate-fixture-run-1
requests: []
decisions: []
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}/diff-summary.md" <<'EOF'
# Diff Summary

```yaml
run_id: gate-fixture-run-1
planned_files:
  - src/app.txt
files_changed:
  - src/app.txt
untracked_files: []
scope_reconciliation_status: passed
```
EOF

assert_command_fails_with \
  "Gate G4 must have status: passed" \
  node "${ROOT_DIR}/scripts/check-gates.mjs" \
    --specs-dir "${SPECS_DIR}" \
    --task-id "${TASK_ID}"

mkdir -p "${RESEARCH_SPECS_DIR}/${RESEARCH_TASK_ID}"
cat > "${RESEARCH_SPECS_DIR}/${RESEARCH_TASK_ID}/00-brief.md" <<'EOF'
# Brief

```yaml
task_id: research-fixture
selected_workflow: research-spike
task_class: research-spike
goal: Compare storage options.
```
EOF

cat > "${RESEARCH_SPECS_DIR}/${RESEARCH_TASK_ID}/01-requirements.md" <<'EOF'
# Requirements

```yaml
status: ready_for_research
goal: Compare storage options.
scope:
  - storage options
non_goals:
  - implementation
acceptance_criteria:
  - recommendation is evidence-backed
open_questions: []
```
EOF

cat > "${RESEARCH_SPECS_DIR}/${RESEARCH_TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status: accepted
accepted_by_human: Raymond
accepted_scope:
  - research recommendation
evidence_reviewed:
  - specs/records/research-fixture/research-report.md
residual_risk_accepted: []
```

## Gate G6

```yaml
gate_id: G6
status: passed
human_accepter: Raymond
decision: accepted
```
EOF

assert_command_fails_with \
  "Missing required artifact research-report.md" \
  node "${ROOT_DIR}/scripts/check-gates.mjs" \
    --specs-dir "${RESEARCH_SPECS_DIR}" \
    --task-id "${RESEARCH_TASK_ID}"

cat > "${RESEARCH_SPECS_DIR}/${RESEARCH_TASK_ID}/research-report.md" <<'EOF'
# Research Report

```yaml
status: complete
research_question: Compare storage options.
constraints:
  - no implementation
non_goals:
  - product code changes
decision_boundary: recommendation only
sources_reviewed:
  - README.md
comparison_criteria:
  - operational fit
options:
  - SQLite
  - Postgres
recommendation: Postgres for multi-user workloads.
confidence: medium
evidence_gaps: []
risks: []
open_questions: []
human_decisions:
  - Raymond accepted the research recommendation.
follow_up_delivery_needed: true
```

## Evidence

## Options Comparison

## Recommendation
EOF

node "${ROOT_DIR}/scripts/check-gates.mjs" \
  --specs-dir "${RESEARCH_SPECS_DIR}" \
  --task-id "${RESEARCH_TASK_ID}" > "${OUTPUT_DIR}/research.out"
grep -Fq "Gate status: passed" "${OUTPUT_DIR}/research.out"
grep -Fq "G4: skipped" "${OUTPUT_DIR}/research.out"
grep -Fq "G5: skipped" "${OUTPUT_DIR}/research.out"

cat > "${SPECS_DIR}/${TASK_ID}/01-requirements.md" <<'EOF'
# Requirements

```yaml
status: ready_for_implementation
goal: Fix fixture behavior.
scope:
  - src/app.txt
non_goals: []
acceptance_criteria:
  - fixture gate checks pass
open_questions: []
```

## Requirements Readiness Check

```yaml
ready_for_implementation: true
accepted_by_human: true
blocking_questions: []
```

## Gate G1

```yaml
gate_id: G1
status: passed
decision: passed
```
EOF

assert_command_fails_with \
  "Requirements Readiness Check must name accepted_by_human" \
  node "${ROOT_DIR}/scripts/check-gates.mjs" \
    --specs-dir "${SPECS_DIR}" \
    --task-id "${TASK_ID}" \
    --allow-pending-acceptance

cat > "${SPECS_DIR}/${TASK_ID}/01-requirements.md" <<'EOF'
# Requirements

```yaml
status: ready_for_implementation
goal: Fix fixture behavior.
scope:
  - src/app.txt
non_goals: []
acceptance_criteria:
  - fixture gate checks pass
open_questions: []
```

## Requirements Readiness Check

```yaml
ready_for_implementation: true
accepted_by_human: Raymond
blocking_questions: []
```

## Gate G1

```yaml
gate_id: G1
status: passed
decision: passed
```
EOF

printf 'after\n' > "${REPO_DIR}/src/app.txt"

mkdir -p "${CONTRACT_REPO}/.dev-cadence" "${CONTRACT_SPECS_DIR}"
node "${ROOT_DIR}/scripts/package-target-repo-bundle.mjs" \
  --output-dir "${CONTRACT_BUNDLE}" \
  --clean \
  --json > "${OUTPUT_DIR}/contract-bundle.json"
git -C "${CONTRACT_REPO}" init -q
cp -R "${CONTRACT_BUNDLE}/.dev-cadence/." "${CONTRACT_REPO}/.dev-cadence/"
{
  printf '# Test Agent Rules\n\n'
  cat "${CONTRACT_BUNDLE}/AGENTS.dev-cadence-section.md"
} > "${CONTRACT_REPO}/AGENTS.md"
cat > "${CONTRACT_REPO}/.gitignore" <<'EOF'
.dev-cadence.yaml
EOF
touch "${CONTRACT_SPECS_DIR}/.gitkeep"
git -C "${CONTRACT_REPO}" add .dev-cadence AGENTS.md .gitignore specs/records/.gitkeep
git -C "${CONTRACT_REPO}" commit -q -m "test: seed contract fixture"

printf '\n# local contract update\n' >> "${CONTRACT_REPO}/AGENTS.md"
printf '\n# runtime update\n' >> "${CONTRACT_REPO}/.dev-cadence/references/human-gates.md"

node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${CONTRACT_REPO}" \
  --plugin-dir "${ROOT_DIR}" > "${OUTPUT_DIR}/contract-ready.out"
grep -Fq "Scope: dev-cadence-contract" "${OUTPUT_DIR}/contract-ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/contract-ready.out"

mkdir -p "${CONTRACT_REPO}/src"
printf 'product\n' > "${CONTRACT_REPO}/src/app.txt"
node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${CONTRACT_REPO}" \
  --plugin-dir "${ROOT_DIR}" > "${OUTPUT_DIR}/mixed-ready.out"
grep -Fq "Scope: mixed" "${OUTPUT_DIR}/mixed-ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/mixed-ready.out"
grep -Fq "SKIP Outside Dev Cadence workflow paths are not checked by Dev Cadence gates." "${OUTPUT_DIR}/mixed-ready.out"

cat > "${SPECS_DIR}/${TASK_ID}/06-test-report.md" <<'EOF'
# Test Report

```yaml
status: complete
verification_status: verified
commands_run:
  - inspect fixture
residual_risk: []
```

## Gate G4

```yaml
gate_id: G4
status: passed
verification_status: verified
human_override: null
```
EOF

cat > "${SPECS_DIR}/${TASK_ID}/07-review-report.md" <<'EOF'
# Review Report

```yaml
status: approved
decision: approved
blockers: []
major_issues: []
residual_risk: []
```

## Gate G5

```yaml
gate_id: G5
status: passed
decision: approved
g4_status: passed
```
EOF

node "${ROOT_DIR}/scripts/check-gates.mjs" \
  --specs-dir "${SPECS_DIR}" \
  --task-id "${TASK_ID}" \
  --allow-pending-acceptance > "${OUTPUT_DIR}/pending.out"
grep -Fq "Gate status: pending_acceptance" "${OUTPUT_DIR}/pending.out"
node "${ROOT_DIR}/scripts/generate-spec-report.mjs" \
  --specs-dir "${SPECS_DIR}" \
  --report-dir "${REPO_DIR}/specs/report" > "${OUTPUT_DIR}/pending-report.out"

assert_command_fails_with \
  "Commit is blocked until G6 final Human acceptance is recorded" \
  node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
    --repo-dir "${REPO_DIR}" \
    --plugin-dir "${ROOT_DIR}" \
    --task-id "${TASK_ID}"
grep -Fq "FAIL G6: Gate G6 must have status: passed" "${OUTPUT_DIR}/failure.out" || {
  echo "expected G6 failure details in commit readiness output" >&2
  cat "${OUTPUT_DIR}/failure.out" >&2
  exit 1
}
grep -Fq "Acceptance Summary: gate-fixture" "${OUTPUT_DIR}/failure.out"
grep -Fq "Goal: Fix fixture behavior." "${OUTPUT_DIR}/failure.out"
grep -Fq "Verification: verified" "${OUTPUT_DIR}/failure.out"
grep -Fq "Review decision: approved" "${OUTPUT_DIR}/failure.out"
grep -Fq "Residual Risk" "${OUTPUT_DIR}/failure.out"
grep -Fq "A named Human acceptance is still required" "${OUTPUT_DIR}/failure.out"
grep -Fq "accepted_by_human" "${OUTPUT_DIR}/failure.out"
grep -Fq "08-acceptance.md" "${OUTPUT_DIR}/failure.out"
grep -Fq "specs/report/gate-fixture/index.html" "${OUTPUT_DIR}/failure.out"
if grep -Fq "Acceptance is already recorded for" "${OUTPUT_DIR}/failure.out"; then
  echo "pending acceptance summary must not report acceptance as recorded" >&2
  cat "${OUTPUT_DIR}/failure.out" >&2
  exit 1
fi

cat > "${SPECS_DIR}/${TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status: accepted
accepted_by_human: true
accepted_scope:
  - fixture behavior
evidence_reviewed:
  - specs/records/gate-fixture
residual_risk_accepted: []
```

## Gate G6

```yaml
gate_id: G6
status: passed
human_accepter: true
decision: accepted
```
EOF

assert_command_fails_with \
  "Acceptance must name accepted_by_human or Gate G6 human_accepter" \
  node "${ROOT_DIR}/scripts/check-gates.mjs" \
    --specs-dir "${SPECS_DIR}" \
    --task-id "${TASK_ID}"

cat > "${SPECS_DIR}/${TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status: blocked_pending_named_human
accepted_by_human:
accepted_scope: []
evidence_reviewed: []
residual_risk_accepted: []
```

## Gate G6

```yaml
gate_id: G6
status: blocked
human_accepter:
decision: blocked_pending_named_human
```
EOF

mkdir -p "${LANG_SPECS_DIR}/${TASK_ID}/runs/${RUN_ID}"
git -C "${LANG_REPO}" init -q
mkdir -p "${LANG_REPO}/src"
cat > "${LANG_REPO}/.dev-cadence.yaml" <<'EOF'
dev_cadence:
  artifact_language: zh
EOF
cat > "${LANG_REPO}/src/app.txt" <<'EOF'
before
EOF
git -C "${LANG_REPO}" add .dev-cadence.yaml src/app.txt
git -C "${LANG_REPO}" commit -q -m "test: seed language fixture"
cp -R "${SPECS_DIR}/${TASK_ID}/." "${LANG_SPECS_DIR}/${TASK_ID}/"
cat > "${LANG_SPECS_DIR}/${TASK_ID}/00-brief.md" <<'EOF'
# Brief

This English prose should fail commit readiness when artifact_language is zh.

```yaml
task_id: gate-fixture
selected_workflow: bugfix
task_class: S1
goal: Fix fixture behavior.
```
EOF
printf 'after\n' > "${LANG_REPO}/src/app.txt"
assert_command_fails_with \
  "Spec artifact validation failed" \
  node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
    --repo-dir "${LANG_REPO}" \
    --plugin-dir "${ROOT_DIR}" \
    --task-id "${TASK_ID}"

printf 'scratch\n' > "${REPO_DIR}/src/extra.txt"
assert_command_fails_with \
  "Dirty paths are not covered" \
  node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
    --repo-dir "${REPO_DIR}" \
    --plugin-dir "${ROOT_DIR}" \
    --task-id "${TASK_ID}"
rm -f "${REPO_DIR}/src/extra.txt"

cat > "${SPECS_DIR}/${TASK_ID}/05-implementation.md" <<'EOF'
# Implementation

```yaml
status: implemented
planned_files:
  - src/app.txt
changed_files:
  - src/app.txt
created_artifact_files: []
unplanned_changed_files:
  - src/extra.txt
deleted_files: []
scope_reconciliation: failed
```
EOF
printf 'scratch\n' > "${REPO_DIR}/src/extra.txt"

assert_command_fails_with \
  "Implementation artifact has unplanned_changed_files" \
  node "${ROOT_DIR}/scripts/check-gates.mjs" \
    --specs-dir "${SPECS_DIR}" \
    --task-id "${TASK_ID}" \
    --allow-pending-acceptance

assert_command_fails_with \
  "Implementation artifact has unplanned_changed_files" \
  node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
    --repo-dir "${REPO_DIR}" \
    --plugin-dir "${ROOT_DIR}" \
    --task-id "${TASK_ID}"
rm -f "${REPO_DIR}/src/extra.txt"

cat > "${SPECS_DIR}/${TASK_ID}/05-implementation.md" <<'EOF'
# Implementation

```yaml
status: implemented
planned_files:
  - src/app.txt
  - src/file with spaces.txt
changed_files:
  - src/app.txt
  - src/file with spaces.txt
created_artifact_files: []
unplanned_changed_files: []
deleted_files: []
scope_reconciliation: passed
```
EOF

printf 'planned special path\n' > "${REPO_DIR}/src/file with spaces.txt"

cat > "${SPECS_DIR}/${TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status: accepted
accepted_by_human: Raymond
accepted_scope:
  - fixture behavior
evidence_reviewed:
  - specs/records/gate-fixture
residual_risk_accepted: []
```

## Gate G6

```yaml
gate_id: G6
status: passed
human_accepter: Raymond
decision: accepted
```
EOF

node "${ROOT_DIR}/scripts/check-gates.mjs" \
  --specs-dir "${SPECS_DIR}" \
  --task-id "${TASK_ID}" > "${OUTPUT_DIR}/accepted.out"
grep -Fq "Gate status: passed" "${OUTPUT_DIR}/accepted.out"

node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${REPO_DIR}" \
  --plugin-dir "${ROOT_DIR}" \
  --task-id "${TASK_ID}" > "${OUTPUT_DIR}/ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/ready.out"

node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
  --repo-dir "${REPO_DIR}" \
  --plugin-dir "${ROOT_DIR}" > "${OUTPUT_DIR}/workflow-ready.out"
grep -Fq "Workflow tasks: ${TASK_ID}" "${OUTPUT_DIR}/workflow-ready.out"
grep -Fq "Scope: mixed" "${OUTPUT_DIR}/workflow-ready.out"
grep -Fq "Commit readiness: passed" "${OUTPUT_DIR}/workflow-ready.out"
grep -Fq "src/file with spaces.txt" "${OUTPUT_DIR}/workflow-ready.out"

printf 'scratch\n' > "${REPO_DIR}/src/extra.txt"
assert_command_fails_with \
  "Commit candidate paths are not covered by workflow task artifacts" \
  node "${ROOT_DIR}/scripts/check-before-commit.mjs" \
    --repo-dir "${REPO_DIR}" \
    --plugin-dir "${ROOT_DIR}"
rm -f "${REPO_DIR}/src/extra.txt"

echo "gate enforcement ok"
