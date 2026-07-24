#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_UNDER_TEST="$ROOT_DIR/src/vendor/superpowers/skills/systematic-debugging/find-polluter.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local output="$1"
  local expected="$2"
  local description="$3"

  printf '%s' "$output" | rg -F -- "$expected" >/dev/null ||
    fail "$description: expected output to contain $expected"
}

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/find-polluter.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
PROJECT="$TEST_ROOT/project"
mkdir -p "$PROJECT/src/feature" "$PROJECT/bin"
printf "test('top')\n" > "$PROJECT/src/top.test.ts"
printf "test('nested')\n" > "$PROJECT/src/feature/nested.test.ts"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'touch pollution.marker' \
  > "$PROJECT/bin/npm"
chmod +x "$PROJECT/bin/npm"

run_polluter() {
  local pattern="$1"
  rm -f "$PROJECT/pollution.marker"
  (
    cd "$PROJECT"
    PATH="$PROJECT/bin:$PATH" "$SCRIPT_UNDER_TEST" pollution.marker "$pattern" 2>&1
  ) || true
}

output="$(run_polluter 'src/**/*.test.ts')"
assert_contains "$output" 'Found 2 test files' 'documented pattern includes top-level and nested tests'
assert_contains "$output" 'FOUND POLLUTER' 'documented pattern identifies pollution'

output="$(run_polluter './src/**/*.test.ts')"
assert_contains "$output" 'Found 2 test files' 'leading ./ pattern is accepted'

output="$(run_polluter 'nomatch/**/*.test.ts')"
assert_contains "$output" 'Found 0 test files' 'empty pattern reports zero files'
assert_contains "$output" 'No polluter found' 'empty pattern exits cleanly'

printf 'Systematic debugging find-polluter checks passed.\n'
