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
  "dist/.dev-cadence/skills/using-dev-cadence/SKILL.md"
  "dist/.dev-cadence/skills/document-conventions/SKILL.md"
  "dist/.dev-cadence/skills/open-question-registry/SKILL.md"
  "dist/.dev-cadence/skills/architecture-design/SKILL.md"
  "dist/.dev-cadence/skills/discovery/SKILL.md"
  "dist/.dev-cadence/skills/work-item-planning/SKILL.md"
  "dist/.dev-cadence/skills/feature-dev/SKILL.md"
  "dist/.dev-cadence/skills/bug-fix/SKILL.md"
  "dist/.dev-cadence/skills/refactor/SKILL.md"
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

while IFS= read -r -d '' source_file; do
  rel_path="${source_file#"$ROOT_DIR/src/skills/"}"
  assert_same_file "src/skills/$rel_path" "dist/.dev-cadence/skills/$rel_path"
done < <(find "$ROOT_DIR/src/skills" -type f -print0)

assert_match "04-code-review-report.md" "src/skills/feature-dev/SKILL.md"
assert_match "04-code-review-report.md" "src/skills/bug-fix/SKILL.md"
assert_match "04-code-review-report.md" "src/skills/refactor/SKILL.md"
assert_match "01-requirements.md" "src/skills/feature-dev/SKILL.md"
assert_match "02-technical-solution.md" "src/skills/feature-dev/SKILL.md"
assert_match "03-implementation-plan.md" "src/skills/feature-dev/SKILL.md"
assert_match "Behavior Baseline" "src/skills/refactor/SKILL.md"
assert_match "Common Refactoring Methods" "src/skills/refactor/SKILL.md"
assert_match "Regression Verification" "src/skills/refactor/SKILL.md"
assert_match "Task Overview" "src/skills/feature-dev/SKILL.md"
assert_match "Task Overview" "src/skills/bug-fix/SKILL.md"
assert_match "Task Overview" "src/skills/refactor/SKILL.md"
assert_match "Before marking the run terminal" "src/skills/feature-dev/SKILL.md"
assert_match "Before marking the run terminal" "src/skills/bug-fix/SKILL.md"
assert_match "Before marking the run terminal" "src/skills/refactor/SKILL.md"
assert_match "Business Acceptance" "src/skills/feature-dev/SKILL.md"
assert_match "Business Acceptance" "src/skills/bug-fix/SKILL.md"
assert_match "Business Acceptance" "src/skills/refactor/SKILL.md"
assert_match "docs/open-questions.md" "src/skills/open-question-registry/SKILL.md"
assert_match "docs/product-planning/story-map.md" "src/skills/work-item-planning/SKILL.md"
assert_match "docs/backlog.md" "src/skills/work-item-planning/SKILL.md"
assert_match "Story must reach `Ready` before entering `feature-dev`" "src/skills/work-item-planning/SKILL.md"
assert_match "Bug may enter `bug-fix` without a `Ready` precondition" "src/skills/work-item-planning/SKILL.md"

if find "$DIST_DIR" -path '*/build/dev-cadence/*' -print -quit | grep -q .; then
  fail "dist package contains old Dev Cadence run records"
fi

if find "$DIST_DIR" \( -name '.env' -o -name '.superpowers' -o -name 'visual-companion' -o -name '.DS_Store' -o -name '*.log' -o -name '*.tmp' \) -print -quit | grep -q .; then
  fail "dist package contains local temporary or environment artifacts"
fi

assert_no_match '/Users/raymond|/private/var/|/private/tmp|/tmp/dev-cadence|[A-Za-z]:\\Users\\' "dist/.dev-cadence"
assert_no_match '\.dev-cadence/visual-companion|service PID' "dist/.dev-cadence"

printf 'Package contract checks passed.\n'
