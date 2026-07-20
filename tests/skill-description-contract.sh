#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

description_for() {
  local path="$1"
  sed -n 's/^description: //p' "$ROOT_DIR/$path"
}

assert_description() {
  local path="$1"
  local expected="$2"
  local actual

  actual="$(description_for "$path")"
  [[ "$actual" == "$expected" ]] || fail "unexpected description in $path: $actual"
}

assert_no_process_summary() {
  local path="$1"
  local description

  description="$(description_for "$path")"
  [[ "$description" == Use\ when* ]] || fail "description must start with 'Use when' in $path"

  if [[ "$description" =~ (workflow|manifest|brainstorming|writing-plans|TDD|stage|record) ]]; then
    fail "description contains process summary wording in $path: $description"
  fi
}

assert_description \
  "src/workflows/using-dev-cadence/SKILL.md" \
  "Use when a Dev Cadence-installed repository receives product discovery, architecture design, requirements, development work, active-task follow-up, testing, verification, or commit/checkpoint requests."

assert_description \
  "src/references/document-conventions/SKILL.md" \
  "Use when creating or updating Dev Cadence-managed Markdown documents, examples, reports, or summaries."

assert_description \
  "src/skills/open-question-registry/SKILL.md" \
  "Use when a user or another Dev Cadence skill needs to view, register, migrate, organize, or update the status of repository-level unresolved questions."

assert_description \
  "src/workflows/discovery/SKILL.md" \
  "Use when a user wants to explore a product idea or update an existing product-design baseline in a target project."

assert_description \
  "src/workflows/work-item-planning/SKILL.md" \
  "Use when a user asks to create, update, or review Story Map, milestone, or work-item planning assets in a target project."

assert_description \
  "src/workflows/work-item-analysis/SKILL.md" \
  "Use when a user asks to analyze, clarify, or confirm Story, Task, or Bug definitions before downstream delivery work in a target project."

assert_description \
  "src/workflows/architecture-design/SKILL.md" \
  "Use when a user explicitly asks for architecture design, an architecture proposal, or an architecture review for a stated goal."

assert_description \
  "src/workflows/feature-dev/SKILL.md" \
  "Use when a user asks to add a capability or intentionally change expected user-visible or system-visible behavior in a target project."

assert_description \
  "src/workflows/bug-fix/SKILL.md" \
  "Use when a user reports or asks to fix a bug, error, crash, regression, failing test, broken expected behavior, or unexpected behavior in a target project."

assert_description \
  "src/workflows/refactor/SKILL.md" \
  "Use when a user asks to improve internal code structure, modularity, maintainability, testability, or dependencies without intentionally changing expected behavior in a target project."

assert_description \
  "src/skills/git-commit/SKILL.md" \
  "Use when using-dev-cadence delegates a Dev Cadence-managed commit."

assert_no_process_summary "src/workflows/using-dev-cadence/SKILL.md"
assert_no_process_summary "src/references/document-conventions/SKILL.md"
assert_no_process_summary "src/skills/open-question-registry/SKILL.md"
assert_no_process_summary "src/workflows/discovery/SKILL.md"
assert_no_process_summary "src/workflows/work-item-planning/SKILL.md"
assert_no_process_summary "src/workflows/work-item-analysis/SKILL.md"
assert_no_process_summary "src/workflows/architecture-design/SKILL.md"
assert_no_process_summary "src/workflows/feature-dev/SKILL.md"
assert_no_process_summary "src/workflows/bug-fix/SKILL.md"
assert_no_process_summary "src/workflows/refactor/SKILL.md"
assert_no_process_summary "src/skills/git-commit/SKILL.md"

printf 'Skill description contract checks passed.\n'
