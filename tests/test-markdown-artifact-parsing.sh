#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
REPO_DIR="$(mktemp -d "${TMP_ROOT}/dev-cadence-markdown-artifacts.XXXXXX")"
TASK_ID="markdown-parsing"
RUN_ID="markdown-run-1"
SPECS_DIR="${REPO_DIR}/specs/records"
TASK_DIR="${SPECS_DIR}/${TASK_ID}"
RUN_DIR="${TASK_DIR}/runs/${RUN_ID}"
SUMMARY_FILE="${REPO_DIR}/summary.md"
trap 'rm -rf "${REPO_DIR}"' EXIT

mkdir -p "${RUN_DIR}"

cat > "${TASK_DIR}/00-brief.md" <<'EOF'
# Brief

Task ID: markdown-parsing
Selected workflow: bugfix
Task class: S1
Goal: Fix Markdown artifact parsing.
EOF

cat > "${TASK_DIR}/01-requirements.md" <<'EOF'
# Requirements

Status: ready_for_implementation

## Goal

Fix Markdown artifact parsing.

## Requirements Readiness Check

Ready for implementation: true
Accepted by human: Raymond
Blocking questions: []

## Gate G1

Status: passed
Decision: passed
EOF

cat > "${TASK_DIR}/03-tasks.md" <<'EOF'
# Tasks

Task class: S1
Selected workflow: bugfix

## Ordered Tasks

### Task 1: Parse Markdown artifact labels

**Goal:** Read stable Markdown labels before YAML fallback.

**Files:**
- Modify: `scripts/check-gates.mjs`
- Modify: `scripts/check-spec-artifacts.mjs`
- Modify: `scripts/summarize-acceptance.mjs`

**Acceptance Mapping:**
- Covers: Markdown-only artifacts remain checker-readable.

**Test-First Plan:**
- Characterization: Markdown-only fixture should pass gates.
- Command: `bash tests/test-markdown-artifact-parsing.sh`

**Implementation Detail:**
- Parse labels, lists, and gate sections outside fenced YAML.

**Expected Evidence:**
- Gate checker and acceptance summary read Markdown-only fixture fields.

## Execution Notes

Status: executable
Verification plan:
- inspect Markdown fixture

## Gate G3

Status: passed
Decision: passed
EOF

cat > "${TASK_DIR}/05-implementation.md" <<'EOF'
# Implementation

Status: implemented
Changed files:
- src/app.txt
Created artifact files: []
Unplanned changed files: []
Deleted files: []
Scope reconciliation: passed
EOF

cat > "${TASK_DIR}/06-test-report.md" <<'EOF'
# Test Report

Status: complete
Verification status: verified
Commands run:
- inspect fixture
Skipped checks: []
Residual risk: []

## Gate G4

Status: passed
Decision: passed
EOF

cat > "${TASK_DIR}/07-review-report.md" <<'EOF'
# Review Report

Status: approved
Decision: approved
Blockers: []
Major issues: []
Residual risk: []

## Gate G5

Status: passed
Decision: approved
EOF

cat > "${TASK_DIR}/08-acceptance.md" <<'EOF'
# Acceptance

Status: accepted
Accepted by human: Raymond
Accepted scope:
- fixture behavior
Evidence reviewed:
- specs/records/markdown-parsing
Residual risk accepted: []

## Gate G6

Status: passed
Human accepter: Raymond
Decision: accepted
EOF

cat > "${RUN_DIR}/run-context.md" <<'EOF'
# Run Context

Run ID: markdown-run-1
Task ID: markdown-parsing
EOF

cat > "${RUN_DIR}/pre-implementation-status.md" <<'EOF'
# Pre-Implementation Status

Run ID: markdown-run-1
Task ID: markdown-parsing
Implementation authorized: true
Post hoc backfill: false
EOF

cat > "${RUN_DIR}/execution-report.md" <<'EOF'
# Execution Report

Run ID: markdown-run-1
Task ID: markdown-parsing
Files changed:
- src/app.txt
Untracked files: []
Implementation authorized: true
EOF

cat > "${RUN_DIR}/tool-log.md" <<'EOF'
# Tool Log

Run ID: markdown-run-1
Commands or tools:
- fixture
EOF

cat > "${RUN_DIR}/permission-decisions.md" <<'EOF'
# Permission Decisions

Run ID: markdown-run-1
Requests: []
Decisions: []
EOF

cat > "${RUN_DIR}/diff-summary.md" <<'EOF'
# Diff Summary

Run ID: markdown-run-1
Files changed:
- src/app.txt
Untracked files: []
Scope reconciliation status: passed
EOF

node "${ROOT_DIR}/scripts/check-spec-artifacts.mjs" "${SPECS_DIR}"
node "${ROOT_DIR}/scripts/check-gates.mjs" \
  --specs-dir "${SPECS_DIR}" \
  --task-id "${TASK_ID}" > "${REPO_DIR}/gates.out"
grep -Fq "Gate status: passed" "${REPO_DIR}/gates.out"
grep -Fq "Class: S1" "${REPO_DIR}/gates.out"
grep -Fq "Workflow: bugfix" "${REPO_DIR}/gates.out"

node "${ROOT_DIR}/scripts/summarize-acceptance.mjs" \
  --specs-dir "${SPECS_DIR}" \
  --task-id "${TASK_ID}" > "${SUMMARY_FILE}"
grep -Fq "Goal: Fix Markdown artifact parsing." "${SUMMARY_FILE}"
grep -Fq "Workflow: bugfix" "${SUMMARY_FILE}"
grep -Fq "Task class: S1" "${SUMMARY_FILE}"
grep -Fq "Accepted by: Raymond" "${SUMMARY_FILE}"
