#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT_DIR/src/skills/using-dev-cadence/scripts/validate-delivery-record.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/delivery-record-contract.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  if ! printf '%s' "$haystack" | rg -F -- "$needle" >/dev/null; then
    fail "expected output to contain '$needle', got: $haystack"
  fi
}

init_repo() {
  local name="$1"
  local repo="$TMP_ROOT/$name"

  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.name "Delivery Contract"
  git -C "$repo" config user.email "delivery-contract@example.com"

  printf '# fixture\n' >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m "seed"

  printf '%s\n' "$repo"
}

write_file() {
  local repo="$1"
  local relative_path="$2"
  shift 2

  mkdir -p "$(dirname "$repo/$relative_path")"
  cat >"$repo/$relative_path" <<EOF
$*
EOF
}

commit_paths() {
  local repo="$1"
  local message="$2"
  shift 2

  git -C "$repo" add "$@"
  git -C "$repo" commit -q -m "$message"
  git -C "$repo" rev-parse --short HEAD
}

create_fixture() {
  local scenario="$1"
  local repo
  repo="$(init_repo "$scenario")"
  local run_dir_rel="build/dev-cadence/bug-fix/${scenario}"
  local run_dir="$repo/$run_dir_rel"
  local diag_path="$run_dir_rel/01-problem-diagnosis-record.md"
  local solution_path="$run_dir_rel/02-repair-solution.md"
  local plan_path="$run_dir_rel/03-repair-plan.md"
  local implementation_path="$run_dir_rel/04-repair-record.md"
  local verification_path="$run_dir_rel/05-regression-test-report.md"
  local acceptance_path="$run_dir_rel/06-business-acceptance-record.md"
  local source_path="src/example.sh"
  local diag_sha solution_sha plan_sha implementation_sha implementation_record_sha verification_sha acceptance_sha
  local implementation_record_text verification_text artifact_for_manifest checkpoint_for_manifest base_sha base_line

  write_file "$repo" "$diag_path" "# Problem Diagnosis

- Status: \`confirmed\`
- Evidence: diagnosis captured."
  diag_sha="$(commit_paths "$repo" "diagnosis" "$diag_path")"

  write_file "$repo" "$solution_path" "# Repair Solution

- Status: \`confirmed\`
- Boundary: current run only."
  solution_sha="$(commit_paths "$repo" "solution" "$solution_path")"

  write_file "$repo" "$plan_path" "# Repair Plan

- Status: \`confirmed\`
- Method: test first."
  plan_sha="$(commit_paths "$repo" "plan" "$plan_path")"

  if [[ "$scenario" == "invalid-multi-range" ]]; then
    write_file "$repo" "src/earlier.sh" "#!/usr/bin/env bash
echo earlier"
    commit_paths "$repo" "earlier implementation" "src/earlier.sh" >/dev/null
  fi

  write_file "$repo" "$source_path" "#!/usr/bin/env bash
echo repaired"
  write_file "$repo" "$implementation_path" "# Repair Record

- Final Implementation SHA: \`pending\`
- Final Review: \`approved\`

## Changed Files

- \`src/example.sh\`"
  implementation_sha="$(commit_paths "$repo" "implementation" "$source_path" "$implementation_path")"

  implementation_record_text="# Repair Record


- Implementation Base SHA: \`$plan_sha\`
- Final Implementation SHA: \`$implementation_sha\`
- Final Review: \`approved\`

## Changed Files

- \`src/example.sh\`

## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (\`$run_dir_rel/04-code-review-report.md\`)"

  case "$scenario" in
    invalid-placeholder)
      implementation_record_text="# Repair Record


- Implementation Base SHA: \`$plan_sha\`
- Final Implementation SHA: \`$implementation_sha\`
- Final Review: \`approved\`

## Changed Files

pending"
      ;;
    invalid-review)
      implementation_record_text="# Repair Record


- Implementation Base SHA: \`$plan_sha\`
- Final Implementation SHA: \`$implementation_sha\`
- Final Review: \`pending\`

## Changed Files

- \`src/example.sh\`"
      ;;
    invalid-missing-review)
      implementation_record_text="# Repair Record

- Implementation Base SHA: \`$plan_sha\`
- Final Implementation SHA: \`$implementation_sha\`
- Final Review:

## Changed Files

- \`src/example.sh\`"
      ;;
  esac

  base_sha="$implementation_sha"

  if [[ "$scenario" == "valid-no-tracked-changes" || "$scenario" == "invalid-no-tracked-changes" || "$scenario" == "invalid-sdd-scratch" ]]; then
    base_sha="$(git -C "$repo" rev-parse --short HEAD)"

    if [[ "$scenario" == "invalid-no-tracked-changes" ]]; then
      write_file "$repo" "$source_path" "#!/usr/bin/env bash
echo changed after skipped"
      commit_paths "$repo" "unexpected implementation change" "$source_path" >/dev/null
    fi

    implementation_record_text="# Repair Record

- Implementation Base SHA: \`$base_sha\`
- Final Implementation SHA: \`skipped: no tracked changes\`
- Final Review: \`approved\`

## Changed Files

- \`skipped: no tracked changes\`

## Code Review Evidence

- Report: [Code review report](04-code-review-report.md) (\`$run_dir_rel/04-code-review-report.md\`)"

    if [[ "$scenario" == "invalid-sdd-scratch" ]]; then
      implementation_record_text="# Repair Record

- Implementation Base SHA: \`$base_sha\`
- Final Implementation SHA: \`skipped: no tracked changes\`
- Final Review: \`approved\`
- Terminal Evidence: \`sdd/progress.md\`

## Changed Files

- \`skipped: no tracked changes\`"
    fi
  fi

  write_file "$repo" "$implementation_path" "$implementation_record_text"
  implementation_record_sha="$(commit_paths "$repo" "implementation record" "$implementation_path")"

  verification_text="# Regression Test Report

- Test Result: \`passed\`
- Command: \`bash tests/delivery-record-contract.sh\`"
  if [[ "$scenario" == "invalid-missing-test-result" ]]; then
    verification_text="# Regression Test Report

- Test Result: pending
- Command: \`bash tests/delivery-record-contract.sh\`"
  fi
  write_file "$repo" "$verification_path" "$verification_text"
  verification_sha="$(commit_paths "$repo" "verification" "$verification_path")"

  write_file "$repo" "$acceptance_path" "# Business Acceptance

- Decision: \`accepted\`"
  acceptance_sha="$(commit_paths "$repo" "acceptance" "$acceptance_path")"

  artifact_for_manifest="$implementation_path"
  checkpoint_for_manifest="$implementation_record_sha"

  case "$scenario" in
    invalid-link)
      artifact_for_manifest="$run_dir_rel/04-missing-record.md"
      ;;
    invalid-tree)
      checkpoint_for_manifest="$plan_sha"
      ;;
  esac

  write_file "$repo" "$run_dir_rel/manifest.md" "# Delivery Run Manifest

- Workflow: \`bug-fix\`
- Task Slug: \`$scenario\`
- Repository: \`fixture\`
- Branch: \`$(git -C "$repo" branch --show-current)\`
- Current Stage: Business Acceptance
- Overall Status: \`accepted\`

## Stage Table

| Stage | Status | Artifact | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Problem Diagnosis | \`confirmed\` | \`$diag_path\` | \`confirmed\` | \`$diag_sha\` | diagnosis captured |
| Repair Solution | \`confirmed\` | \`$solution_path\` | \`confirmed\` | \`$solution_sha\` | solution captured |
| Repair Plan | \`confirmed\` | \`$plan_path\` | \`confirmed\` | \`$plan_sha\` | plan captured |
| Repair Implementation | \`confirmed\` | \`$artifact_for_manifest\` | \`confirmed\` | \`$checkpoint_for_manifest\` | implementation captured |
| Regression Verification | \`confirmed\` | \`$verification_path\` | \`confirmed\` | \`$verification_sha\` | test report captured |
| Business Acceptance | \`confirmed\` | \`$acceptance_path\` | \`confirmed\` | \`$acceptance_sha\` | acceptance captured |"

  case "$scenario" in
    invalid-terminal-stage)
      sed -i.bak 's/| Business Acceptance | `confirmed`/| Business Acceptance | `pending`/' "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-final-sha)
      sed -i.bak 's/Final Implementation SHA: `[^`]*`/Final Implementation SHA: `deadbeef`/' "$repo/$implementation_path"
      rm "$repo/$implementation_path.bak"
      ;;
    invalid-changed-files)
      sed -i.bak 's/`src\/example.sh`/`README.md`/' "$repo/$implementation_path"
      rm "$repo/$implementation_path.bak"
      ;;
    invalid-missing-verification)
      sed -i.bak '/| Regression Verification |/d' "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    valid-abandoned)
      sed -i.bak \
        -e 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        -e "s#| Repair Implementation | .*#| Repair Implementation | \`skipped\` | pending | \`skipped\` | \`skipped: abandoned\` | abandoned before implementation |#" \
        -e "s#| Regression Verification | .*#| Regression Verification | \`skipped\` | pending | \`skipped\` | \`skipped: abandoned\` | abandoned before verification |#" \
        -e "s#| Business Acceptance | .*#| Business Acceptance | \`skipped\` | pending | \`skipped\` | \`skipped: abandoned\` | abandoned before acceptance |#" \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-skipped-pending)
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/; s/| Business Acceptance | `confirmed` |/| Business Acceptance | `skipped` |/; s/| `confirmed` | `[^`]*` | acceptance captured |$/| `skipped` | `pending` | acceptance captured |/' "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-pending)
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      sed -i.bak 's/| Business Acceptance | `confirmed` |/| Business Acceptance | `pending` |/; s/| `confirmed` | `[^`]*` | acceptance captured |$/| pending | pending | acceptance captured |/' "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
  esac

  printf '%s\n' "$run_dir"
}

run_expect_success() {
  local run_dir="$1"
  local output

  if ! output="$(bash "$VALIDATOR" "$run_dir" --terminal 2>&1)"; then
    fail "expected validator success for ${run_dir##*/}, got: $output"
  fi

  assert_contains "Delivery record validation passed:" "$output"
}

run_expect_failure() {
  local run_dir="$1"
  local expected_message="$2"
  local output

  if output="$(bash "$VALIDATOR" "$run_dir" --terminal 2>&1)"; then
    fail "expected validator failure for ${run_dir##*/}, got success: $output"
  fi

  assert_contains "$expected_message" "$output"
}

valid_run="$(create_fixture "valid-run")"
run_expect_success "$valid_run"

valid_no_tracked_changes_run="$(create_fixture "valid-no-tracked-changes")"
run_expect_success "$valid_no_tracked_changes_run"

valid_abandoned_run="$(create_fixture "valid-abandoned")"
run_expect_success "$valid_abandoned_run"

placeholder_run="$(create_fixture "invalid-placeholder")"
run_expect_failure "$placeholder_run" "FAIL: implementation record has pending Changed Files"

missing_artifact_run="$(create_fixture "invalid-link")"
run_expect_failure "$missing_artifact_run" "FAIL: artifact path does not exist"

tree_mismatch_run="$(create_fixture "invalid-tree")"
run_expect_failure "$tree_mismatch_run" "FAIL: checkpoint tree is missing stage artifact"

pending_review_run="$(create_fixture "invalid-review")"
run_expect_failure "$pending_review_run" "FAIL: terminal implementation record is missing final review conclusion"

sdd_scratch_run="$(create_fixture "invalid-sdd-scratch")"
run_expect_failure "$sdd_scratch_run" "FAIL: terminal implementation record depends on ignored SDD scratch evidence"

invalid_no_tracked_changes_run="$(create_fixture "invalid-no-tracked-changes")"
run_expect_failure "$invalid_no_tracked_changes_run" "FAIL: skipped no-tracked-changes proof found non-record changes"

invalid_terminal_stage_run="$(create_fixture "invalid-terminal-stage")"
run_expect_failure "$invalid_terminal_stage_run" "FAIL: terminal manifest has non-terminal stage"

invalid_final_sha_run="$(create_fixture "invalid-final-sha")"
run_expect_failure "$invalid_final_sha_run" "FAIL: implementation record references unknown final implementation SHA"

invalid_changed_files_run="$(create_fixture "invalid-changed-files")"
run_expect_failure "$invalid_changed_files_run" "FAIL: Changed Files do not match final implementation commit range"

invalid_missing_verification_run="$(create_fixture "invalid-missing-verification")"
run_expect_failure "$invalid_missing_verification_run" "FAIL: terminal manifest is missing verification record artifact"

invalid_multi_range_run="$(create_fixture "invalid-multi-range")"
run_expect_failure "$invalid_multi_range_run" "FAIL: Changed Files do not match final implementation commit range"

invalid_missing_review_run="$(create_fixture "invalid-missing-review")"
run_expect_failure "$invalid_missing_review_run" "FAIL: terminal implementation record is missing final review conclusion"

invalid_missing_test_result_run="$(create_fixture "invalid-missing-test-result")"
run_expect_failure "$invalid_missing_test_result_run" "FAIL: terminal verification record is missing test conclusion"

invalid_skipped_pending_run="$(create_fixture "invalid-skipped-pending")"
run_expect_failure "$invalid_skipped_pending_run" "FAIL: stage 'Business Acceptance' has terminal status 'skipped' but pending checkpoint"

invalid_abandoned_pending_run="$(create_fixture "invalid-abandoned-pending")"
run_expect_failure "$invalid_abandoned_pending_run" "FAIL: terminal manifest has non-terminal stage: Business Acceptance (pending)"

printf 'Delivery record contract checks passed.\n'
