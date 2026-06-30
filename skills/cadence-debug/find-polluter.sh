#!/usr/bin/env bash
# Find which test creates unwanted files or state.
# Usage: find-polluter.sh <file_or_dir_to_check> <test_file_pattern> [test_command...]
# Example: skills/cadence-debug/find-polluter.sh '.git' 'src/**/*.test.ts' npm test --

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <file_or_dir_to_check> <test_file_pattern> [test_command...]" >&2
  echo "Example: $0 '.git' 'src/**/*.test.ts' npm test --" >&2
  exit 2
fi

pollution_check="$1"
test_pattern="$2"
shift 2

if [[ $# -eq 0 ]]; then
  test_command=(npm test --)
else
  test_command=("$@")
fi

mapfile -t test_files < <(find . -path "$test_pattern" -type f | sort)

echo "Searching for test that creates: $pollution_check"
echo "Test pattern: $test_pattern"
echo "Test command: ${test_command[*]} <test-file>"
echo "Found ${#test_files[@]} test files"
echo

if [[ ${#test_files[@]} -eq 0 ]]; then
  echo "No test files matched pattern: $test_pattern" >&2
  exit 2
fi

count=0
for test_file in "${test_files[@]}"; do
  count=$((count + 1))

  if [[ -e "$pollution_check" ]]; then
    echo "Pollution already exists before test $count/${#test_files[@]}: $test_file" >&2
    echo "Clean '$pollution_check' before continuing." >&2
    exit 2
  fi

  echo "[$count/${#test_files[@]}] Testing: $test_file"
  "${test_command[@]}" "$test_file" >/dev/null 2>&1 || true

  if [[ -e "$pollution_check" ]]; then
    echo
    echo "FOUND POLLUTER"
    echo "Test: $test_file"
    echo "Created: $pollution_check"
    echo
    echo "Pollution details:"
    ls -la "$pollution_check"
    echo
    echo "Investigate with:"
    printf '  %q' "${test_command[@]}"
    printf ' %q\n' "$test_file"
    exit 1
  fi
done

echo
echo "No polluter found - all tests clean."
