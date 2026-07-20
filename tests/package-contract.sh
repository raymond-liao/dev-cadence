#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist/.dev-cadence"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  test -f "$ROOT_DIR/$path" || fail "missing required file: $path"
}

assert_same_file() {
  local left="$1"
  local right="$2"
  cmp -s "$ROOT_DIR/$left" "$ROOT_DIR/$right" || fail "files differ: $left -> $right"
}

assert_same_tree() {
  local left="$1"
  local right="$2"
  diff -qr "$ROOT_DIR/$left" "$ROOT_DIR/$right" >/dev/null || fail "directory trees differ: $left -> $right"
}

assert_no_match() {
  local pattern="$1"
  local path="$2"
  if rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null; then
    fail "unexpected match for '$pattern' under $path"
  fi
}

assert_match() {
  local pattern="$1"
  local path="$2"
  rg --no-ignore -n "$pattern" "$ROOT_DIR/$path" >/dev/null || fail "missing match for '$pattern' under $path"
}

test -d "$DIST_DIR" || fail "missing dist package; run bash scripts/build.sh first"

required_files=(
  "dist/.dev-cadence/version"
  "dist/.dev-cadence/LICENSE"
  "dist/.dev-cadence/README.md"
  "dist/.dev-cadence/README.zh-CN.md"
  "dist/.dev-cadence/.dev-cadence.example.yaml"
  "dist/.dev-cadence/AGENTS-snippet.md"
  "dist/.dev-cadence/workflows/using-dev-cadence/SKILL.md"
  "dist/.dev-cadence/references/contracts/change-log.md"
  "dist/.dev-cadence/skills/git-commit/SKILL.md"
  "dist/.dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh"
  "dist/.dev-cadence/references/document-conventions/SKILL.md"
  "dist/.dev-cadence/skills/open-question-registry/SKILL.md"
  "dist/.dev-cadence/workflows/architecture-design/SKILL.md"
  "dist/.dev-cadence/workflows/discovery/SKILL.md"
  "dist/.dev-cadence/workflows/work-item-planning/SKILL.md"
  "dist/.dev-cadence/workflows/work-item-analysis/SKILL.md"
  "dist/.dev-cadence/workflows/feature-dev/SKILL.md"
  "dist/.dev-cadence/workflows/bug-fix/SKILL.md"
  "dist/.dev-cadence/workflows/refactor/SKILL.md"
  "dist/.dev-cadence/vendor/superpowers/LICENSE"
  "dist/.dev-cadence/vendor/superpowers/RELEASE-NOTES.md"
)

for path in "${required_files[@]}"; do
  assert_file "$path"
done

assert_same_file "README.md" "dist/.dev-cadence/README.md"
assert_same_file "README.zh-CN.md" "dist/.dev-cadence/README.zh-CN.md"
assert_same_file "version" "dist/.dev-cadence/version"
assert_same_file "LICENSE" "dist/.dev-cadence/LICENSE"
assert_same_file "src/.dev-cadence.example.yaml" "dist/.dev-cadence/.dev-cadence.example.yaml"
assert_same_file "src/AGENTS-snippet.md" "dist/.dev-cadence/AGENTS-snippet.md"
assert_same_tree "src/vendor" "dist/.dev-cadence/vendor"

assert_match ".dev-cadence/skills/git-commit/SKILL.md" "src/workflows/using-dev-cadence/SKILL.md"
assert_match "Use when using-dev-cadence delegates a Dev Cadence-managed commit" "src/skills/git-commit/SKILL.md"

while IFS= read -r -d '' source_file; do
  rel_path="${source_file#"$ROOT_DIR/src/skills/"}"
  assert_same_file "src/skills/$rel_path" "dist/.dev-cadence/skills/$rel_path"
done < <(find "$ROOT_DIR/src/skills" -type f -print0)

while IFS= read -r -d '' source_file; do
  rel_path="${source_file#"$ROOT_DIR/src/workflows/"}"
  assert_same_file "src/workflows/$rel_path" "dist/.dev-cadence/workflows/$rel_path"
done < <(find "$ROOT_DIR/src/workflows" -type f -print0)

while IFS= read -r -d '' source_file; do
  rel_path="${source_file#"$ROOT_DIR/src/references/"}"
  assert_same_file "src/references/$rel_path" "dist/.dev-cadence/references/$rel_path"
done < <(find "$ROOT_DIR/src/references" -type f -print0)

test ! -e "$DIST_DIR/skills/using-dev-cadence" || fail "package retained legacy workflow path"
test ! -e "$DIST_DIR/skills/contracts" || fail "package retained legacy reference path"

assert_same_file \
  "src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh" \
  "dist/.dev-cadence/workflows/using-dev-cadence/scripts/validate-delivery-record.sh"

assert_match "04-code-review-report.md" "src/workflows/feature-dev/SKILL.md"
assert_match "04-code-review-report.md" "src/workflows/bug-fix/SKILL.md"
assert_match "04-code-review-report.md" "src/workflows/refactor/SKILL.md"
assert_match "01-requirements.md" "src/workflows/feature-dev/SKILL.md"
assert_match "02-technical-solution.md" "src/workflows/feature-dev/SKILL.md"
assert_match "03-implementation-plan.md" "src/workflows/feature-dev/SKILL.md"
assert_match "Behavior Baseline" "src/workflows/refactor/SKILL.md"
assert_match "Common Refactoring Methods" "src/workflows/refactor/SKILL.md"
assert_match "Regression Verification" "src/workflows/refactor/SKILL.md"
assert_match "Task Overview" "src/workflows/feature-dev/SKILL.md"
assert_match "Task Overview" "src/workflows/bug-fix/SKILL.md"
assert_match "Task Overview" "src/workflows/refactor/SKILL.md"
assert_match "Before marking the run terminal" "src/workflows/feature-dev/SKILL.md"
assert_match "Before marking the run terminal" "src/workflows/bug-fix/SKILL.md"
assert_match "Before marking the run terminal" "src/workflows/refactor/SKILL.md"
assert_match "Business Acceptance" "src/workflows/feature-dev/SKILL.md"
assert_match "Business Acceptance" "src/workflows/bug-fix/SKILL.md"
assert_match "Business Acceptance" "src/workflows/refactor/SKILL.md"
assert_match "docs/open-questions.md" "src/skills/open-question-registry/SKILL.md"
assert_match "docs/product-planning/story-map.md" "src/workflows/work-item-planning/SKILL.md"
assert_match "docs/backlog.md" "src/workflows/work-item-planning/SKILL.md"
assert_match 'Story must reach `Ready` before entering `feature-dev`' "src/workflows/work-item-planning/SKILL.md"
assert_match 'Bug may enter `bug-fix` without a `Ready` precondition' "src/workflows/work-item-planning/SKILL.md"
assert_match 'Work Item Analysis must not investigate or confirm technical root cause' "src/workflows/work-item-analysis/SKILL.md"
assert_match 'Task does not need to reach `Ready` before a Delivery Workflow starts' "src/workflows/work-item-analysis/SKILL.md"
assert_match 'Ready Story -> `feature-dev`' "src/workflows/work-item-analysis/SKILL.md"

if find "$DIST_DIR" -path '*/build/dev-cadence/*' -print -quit | grep -q .; then
  fail "dist package contains old Dev Cadence run records"
fi

if find "$DIST_DIR" \( -name '.env' -o -name '.superpowers' -o -name 'visual-companion' -o -name '.DS_Store' -o -name '*.log' -o -name '*.tmp' \) -print -quit | grep -q .; then
  fail "dist package contains local temporary or environment artifacts"
fi

assert_no_match '/Users/raymond|/private/var/|/private/tmp|/tmp/dev-cadence|[A-Za-z]:\\Users\\' "dist/.dev-cadence"
assert_no_match '\.dev-cadence/visual-companion|service PID' "dist/.dev-cadence"

printf 'Package contract checks passed.\n'
