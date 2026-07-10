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
  "src/skills/using-dev-cadence/SKILL.md" \
  "Use when a Dev Cadence-installed repository receives development work, active-task follow-up, testing, verification, or commit/checkpoint requests."

assert_description \
  "src/skills/feature-dev/SKILL.md" \
  "Use when a user asks to add a capability or intentionally change expected user-visible or system-visible behavior in a target project."

assert_description \
  "src/skills/bug-fix/SKILL.md" \
  "Use when a user reports or asks to fix a bug, error, crash, regression, failing test, broken expected behavior, or unexpected behavior in a target project."

assert_no_process_summary "src/skills/using-dev-cadence/SKILL.md"
assert_no_process_summary "src/skills/feature-dev/SKILL.md"
assert_no_process_summary "src/skills/bug-fix/SKILL.md"

printf 'Skill description contract checks passed.\n'
