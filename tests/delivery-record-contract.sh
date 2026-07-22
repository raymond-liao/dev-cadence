#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT_DIR/src/workflows/using-dev-cadence/scripts/validate-delivery-record.sh"
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

write_manual_recovery_record() {
  local repo="$1"
  local path="$2"

  write_file "$repo" "$path" "# Manual Recovery Record

- Blocking Category: \`git\`
- Blocking Evidence: merge identity mismatch reproduced.
- Blocked Completion Action: local merge to main.
- Recovery Attempt: refreshed merge identity and retried local merge.
- Recovery Result: failed; target branch changed outside this run.
- Why Further Recovery Is Not Viable: resolving target history requires external owner action.
- User Confirmation: explicit abandonment of normal Completion captured.
- Code Preservation: task branch preserved.
- Branch Preservation: preserved for follow-up owner.
- Worktree Preservation: preserved for follow-up owner.
- Run Record Preservation: preserved in the task worktree.
- Follow-up Owner: Delivery Contract.
- Next Step: owner reconciles target history before a new Completion attempt."
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
  local manual_recovery_path="$run_dir_rel/07-manual-recovery-record.md"
  local source_path="src/example.sh"
  local diag_sha solution_sha plan_sha implementation_sha implementation_record_sha verification_sha acceptance_sha borrowed_acceptance_sha unreachable_final_sha
  local verification_candidate_sha verification_final_value merge_add_sha merge_restore_sha merge_bridge_sha
  local implementation_record_text verification_text artifact_for_manifest checkpoint_for_manifest base_sha base_line
  local verification_head verification_branch verification_snapshot verification_state

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

  if [[ "$scenario" == *"no-tracked-changes"* || "$scenario" == "invalid-sdd-scratch" ]]; then
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

  if [[ "$scenario" == "invalid-final-verification-unapproved-code-commit" ]]; then
    write_file "$repo" "$source_path" "#!/usr/bin/env bash
echo candidate changed after verification"
  fi

  verification_candidate_sha="$implementation_sha"
  verification_final_value="$implementation_sha"
  if [[ "$scenario" == *"no-tracked-changes"* || "$scenario" == "invalid-sdd-scratch" ]]; then
    verification_candidate_sha="$base_sha"
    verification_final_value="skipped: no tracked changes"
  fi

  verification_head="$(git -C "$repo" rev-parse HEAD)"
  verification_branch="$(git -C "$repo" branch --show-current)"
  verification_snapshot="$(git -C "$repo" diff --binary "$verification_candidate_sha" -- . ":(exclude)$run_dir_rel" | git -C "$repo" hash-object --stdin)"
  if git -C "$repo" diff --quiet "$verification_candidate_sha" -- . ":(exclude)$run_dir_rel"; then
    verification_state="clean"
  else
    verification_state="dirty"
  fi

  verification_text="# Regression Test Report

- Test Result: \`passed\`
- Command: \`bash tests/delivery-record-contract.sh\`
- Verification Start HEAD: \`$verification_head\`
- Verification Start Branch: \`$verification_branch\`
- Verification Start FINAL_IMPLEMENTATION_SHA: \`$verification_final_value\`
- Verification Start Tracked Snapshot: \`$verification_snapshot\`
- Verification Start Tracked State: \`$verification_state\`
- Verification End HEAD: \`$verification_head\`
- Verification End Branch: \`$verification_branch\`
- Verification End FINAL_IMPLEMENTATION_SHA: \`$verification_final_value\`
- Verification End Tracked Snapshot: \`$verification_snapshot\`
- Verification End Tracked State: \`$verification_state\`"
  if [[ "$scenario" == "invalid-missing-test-result" ]]; then
    verification_text="# Regression Test Report

- Test Result: pending
- Command: \`bash tests/delivery-record-contract.sh\`
- Verification Start HEAD: \`$verification_head\`
- Verification Start Branch: \`$verification_branch\`
- Verification Start FINAL_IMPLEMENTATION_SHA: \`$implementation_sha\`
- Verification Start Tracked Snapshot: \`$verification_snapshot\`
- Verification Start Tracked State: \`$verification_state\`
- Verification End HEAD: \`$verification_head\`
- Verification End Branch: \`$verification_branch\`
- Verification End FINAL_IMPLEMENTATION_SHA: \`$implementation_sha\`
- Verification End Tracked Snapshot: \`$verification_snapshot\`
- Verification End Tracked State: \`$verification_state\`"
  fi
  write_file "$repo" "$verification_path" "$verification_text"
  verification_sha="$(commit_paths "$repo" "verification" "$verification_path")"

  write_file "$repo" "$acceptance_path" "# Business Acceptance

- User Decision: \`accepted\`
- Accepted Residual Risks: None"
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
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-missing-record)
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-rejected-decision)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak 's/User Decision: `accepted`/User Decision: `rejected`/' \
        "$repo/$acceptance_path"
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$acceptance_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-missing-field)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak '/^- Follow-up Owner:/d' "$repo/$manual_recovery_path"
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$manual_recovery_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-invalid-blocking-category)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak 's/Blocking Category: `git`/Blocking Category: `git_state`/' \
        "$repo/$manual_recovery_path"
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$manual_recovery_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-invalid-implementation)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak '/^- Final Implementation SHA:/d' "$repo/$implementation_path"
      sed -i.bak 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$implementation_path.bak" "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-missing-verification)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak \
        -e 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        -e '/| Regression Verification |/d' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-cross-run-acceptance)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      write_file "$repo" "build/dev-cadence/bug-fix/other-run/06-business-acceptance-record.md" "# Business Acceptance

- User Decision: \`accepted\`
- Accepted Residual Risks: None"
      borrowed_acceptance_sha="$(commit_paths "$repo" "other run acceptance" \
        "build/dev-cadence/bug-fix/other-run/06-business-acceptance-record.md")"
      sed -i.bak \
        -e 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        -e "s#\`$acceptance_path\` | \`confirmed\` | \`$acceptance_sha\`#\`build/dev-cadence/bug-fix/other-run/06-business-acceptance-record.md\` | \`confirmed\` | \`$borrowed_acceptance_sha\`#" \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-skipped-acceptance)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak \
        -e 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        -e 's/| Business Acceptance | `confirmed` |/| Business Acceptance | `skipped` |/' \
        -e 's/| `confirmed` | `[^`]*` | acceptance captured |$/| `skipped` | `skipped: abandoned` | acceptance captured |/' \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-abandoned-impersonated-acceptance)
      write_manual_recovery_record "$repo" "$manual_recovery_path"
      sed -i.bak \
        -e 's/Overall Status: `accepted`/Overall Status: `abandoned`/' \
        -e "s#| Regression Verification | .*#| Regression Verification | \`confirmed\` | \`$acceptance_path\` | \`confirmed\` | \`$acceptance_sha\` | impersonating acceptance evidence |#" \
        -e "s#| Business Acceptance | .*#| Business Acceptance | \`skipped\` | \`$verification_path\` | \`skipped\` | \`skipped: abandoned\` | skipped acceptance |#" \
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
    invalid-final-verification-missing-snapshot)
      sed -i.bak '/^- Verification Start Tracked Snapshot:/d' "$repo/$verification_path"
      rm "$repo/$verification_path.bak"
      ;;
    invalid-final-verification-inconsistent-snapshot)
      sed -i.bak 's/^- Verification End Branch:.*/- Verification End Branch: `other-branch`/' "$repo/$verification_path"
      rm "$repo/$verification_path.bak"
      ;;
    invalid-final-verification-unreachable-final-sha)
      git -C "$repo" branch snapshot-side "$implementation_record_sha"
      git -C "$repo" checkout -q snapshot-side
      git -C "$repo" commit -q --allow-empty -m "unreachable final"
      unreachable_final_sha="$(git -C "$repo" rev-parse --short HEAD)"
      git -C "$repo" checkout -q "$verification_branch"
      sed -i.bak "s/^- Final Implementation SHA:.*/- Final Implementation SHA: \`$unreachable_final_sha\`/" \
        "$repo/$implementation_path"
      rm "$repo/$implementation_path.bak"
      sed -i.bak \
        -e "s/^- Verification Start FINAL_IMPLEMENTATION_SHA:.*/- Verification Start FINAL_IMPLEMENTATION_SHA: \`$unreachable_final_sha\`/" \
        -e "s/^- Verification End FINAL_IMPLEMENTATION_SHA:.*/- Verification End FINAL_IMPLEMENTATION_SHA: \`$unreachable_final_sha\`/" \
        "$repo/$verification_path"
      rm "$repo/$verification_path.bak"
      ;;
    invalid-final-verification-branch-changed)
      git -C "$repo" checkout -q -b changed-branch
      ;;
    invalid-final-verification-tracked-snapshot-changed)
      write_file "$repo" "$source_path" "#!/usr/bin/env bash
echo tracked snapshot changed"
      ;;
    invalid-final-verification-unapproved-code-commit)
      commit_paths "$repo" "candidate code after verification" "$source_path" >/dev/null
      ;;
    invalid-no-tracked-changes-final-verification-branch-changed)
      git -C "$repo" checkout -q -b changed-no-tracked-branch
      ;;
    invalid-no-tracked-changes-final-verification-tracked-snapshot-changed)
      write_file "$repo" "$source_path" "#!/usr/bin/env bash
echo skipped candidate changed after verification"
      ;;
    invalid-final-verification-merge-checkpoint)
      git -C "$repo" checkout -q -b merge-add-side
      write_file "$repo" "src/merge-hidden.sh" "#!/usr/bin/env bash
echo hidden"
      commit_paths "$repo" "side adds hidden source" "src/merge-hidden.sh" >/dev/null
      git -C "$repo" checkout -q "$verification_branch"
      git -C "$repo" merge -q --no-ff merge-add-side -m "merge add side"
      merge_add_sha="$(git -C "$repo" rev-parse --short HEAD)"

      git -C "$repo" checkout -q -b merge-restore-side
      git -C "$repo" rm -q "src/merge-hidden.sh"
      git -C "$repo" commit -q -m "side restores source tree"
      git -C "$repo" checkout -q "$verification_branch"
      write_file "$repo" "$run_dir_rel/merge-bridge.md" "# Merge bridge"
      merge_bridge_sha="$(commit_paths "$repo" "record merge bridge" "$run_dir_rel/merge-bridge.md")"
      git -C "$repo" merge -q --no-ff merge-restore-side -m "merge restore side"
      merge_restore_sha="$(git -C "$repo" rev-parse --short HEAD)"

      sed -i.bak \
        -e "s/\`$diag_sha\` | diagnosis captured/\`$merge_add_sha\` | diagnosis captured/" \
        -e "s/\`$solution_sha\` | solution captured/\`$merge_bridge_sha\` | solution captured/" \
        -e "s/\`$plan_sha\` | plan captured/\`$merge_restore_sha\` | plan captured/" \
        "$repo/$run_dir_rel/manifest.md"
      rm "$repo/$run_dir_rel/manifest.md.bak"
      ;;
    invalid-final-verification-symbolic-head)
      sed -i.bak \
        -e 's/^- Verification Start HEAD:.*/- Verification Start HEAD: `HEAD`/' \
        -e 's/^- Verification End HEAD:.*/- Verification End HEAD: `HEAD`/' \
        "$repo/$verification_path"
      rm "$repo/$verification_path.bak"
      ;;
    invalid-final-verification-branch-ref-head)
      sed -i.bak \
        -e "s#^- Verification Start HEAD:.*#- Verification Start HEAD: \`refs/heads/$verification_branch\`#" \
        -e "s#^- Verification End HEAD:.*#- Verification End HEAD: \`refs/heads/$verification_branch\`#" \
        "$repo/$verification_path"
      rm "$repo/$verification_path.bak"
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

expect_validator_success() {
  local run_dir="$1"
  local mode="$2"
  local output

  if ! output="$(bash "$VALIDATOR" "$run_dir" "$mode" 2>&1)"; then
    fail "expected validator success for ${run_dir##*/} ($mode), got: $output"
  fi

  assert_contains "Delivery record validation passed:" "$output"
}

expect_validator_failure() {
  local run_dir="$1"
  local mode="$2"
  local expected_message="$3"
  local output

  if output="$(bash "$VALIDATOR" "$run_dir" "$mode" 2>&1)"; then
    fail "expected validator failure for ${run_dir##*/} ($mode), got success: $output"
  fi

  assert_contains "$expected_message" "$output"
}

run_validator() {
  local run_dir="$1"

  bash "$VALIDATOR" "$run_dir"
}

create_in_progress_fixture() {
  local scenario="${1:-in-progress-run}"
  local repo
  repo="$(init_repo "$scenario")"
  local run_dir_rel="build/dev-cadence/feature-dev/${scenario}"
  local run_dir="$repo/$run_dir_rel"
  local requirements_path="$run_dir_rel/01-requirements.md"
  local solution_path="$run_dir_rel/02-technical-solution.md"
  local plan_path="$run_dir_rel/03-implementation-plan.md"
  local implementation_path="$run_dir_rel/04-implementation-record.md"
  local verification_path="$run_dir_rel/05-system-test-report.md"
  local acceptance_path="$run_dir_rel/06-business-acceptance-record.md"
  local requirements_sha solution_sha

  write_file "$repo" "$requirements_path" "# Requirements Record

- Status: \`confirmed\`
- Scope: current run only."
  requirements_sha="$(commit_paths "$repo" "requirements" "$requirements_path")"

  write_file "$repo" "$solution_path" "# Technical Solution

- Status: \`confirmed\`
- Boundary: current run only."
  solution_sha="$(commit_paths "$repo" "solution" "$solution_path")"

  if [[ "$scenario" != "in-progress-missing-current-artifact" ]]; then
    write_file "$repo" "$plan_path" "# Implementation Plan

- Status: \`in_progress\`
- Method: test first."
  fi
  write_file "$repo" "$run_dir_rel/manifest.md" "# Delivery Run Manifest

- Workflow: \`feature-dev\`
- Task Slug: \`$scenario\`
- Overall Status: \`in_progress\`

## Stage Table

| Stage | Status | Artifact Path | User Confirmation | Checkpoint Commit | Notes |
| --- | --- | --- | --- | --- | --- |
| Requirements Confirmation | \`confirmed\` | \`$requirements_path\` | \`confirmed\` | \`$requirements_sha\` | requirements captured |
| Technical Solution | \`confirmed\` | \`$solution_path\` | \`confirmed\` | \`$solution_sha\` | solution captured |
| Implementation Plan | \`in_progress\` | \`$plan_path\` | \`pending\` | \`pending\` | plan in progress |
| Development Implementation | \`pending\` | \`$implementation_path\` | \`pending\` | \`pending\` | implementation pending |
| System Testing | \`pending\` | \`$verification_path\` | \`pending\` | \`pending\` | testing pending |
| Business Acceptance | \`pending\` | \`$acceptance_path\` | \`pending\` | \`pending\` | acceptance pending |"

  printf '%s\n' "$run_dir"
}

in_progress_run="$(create_in_progress_fixture)"
run_validator "$in_progress_run" || fail "in-progress manifest should validate structurally"

in_progress_missing_artifact_run="$(create_in_progress_fixture "in-progress-missing-current-artifact")"
if output="$(run_validator "$in_progress_missing_artifact_run" 2>&1)"; then
  fail "in-progress stage with a missing current artifact should fail validation"
fi
assert_contains "FAIL: artifact path does not exist" "$output"

valid_run="$(create_fixture "valid-run")"
run_expect_success "$valid_run"
expect_validator_success "$valid_run" --final-verification

valid_no_tracked_changes_run="$(create_fixture "valid-no-tracked-changes")"
run_expect_success "$valid_no_tracked_changes_run"
expect_validator_success "$valid_no_tracked_changes_run" --final-verification

skipped_branch_changed_run="$(create_fixture "invalid-no-tracked-changes-final-verification-branch-changed")"
expect_validator_failure "$skipped_branch_changed_run" --final-verification "FAIL: final verification branch changed"

skipped_snapshot_changed_run="$(create_fixture "invalid-no-tracked-changes-final-verification-tracked-snapshot-changed")"
expect_validator_failure "$skipped_snapshot_changed_run" --final-verification "FAIL: final verification tracked snapshot changed"

valid_abandoned_run="$(create_fixture "valid-abandoned")"
run_expect_success "$valid_abandoned_run"

missing_recovery_run="$(create_fixture "invalid-abandoned-missing-record")"
run_expect_failure "$missing_recovery_run" "FAIL: abandoned manifest is missing manual recovery record"

rejected_recovery_run="$(create_fixture "invalid-abandoned-rejected-decision")"
run_expect_failure "$rejected_recovery_run" "FAIL: abandoned manifest requires accepted Business Acceptance decision"

incomplete_recovery_run="$(create_fixture "invalid-abandoned-missing-field")"
run_expect_failure "$incomplete_recovery_run" "FAIL: manual recovery record is missing Follow-up Owner"

invalid_blocking_category_run="$(create_fixture "invalid-abandoned-invalid-blocking-category")"
run_expect_failure "$invalid_blocking_category_run" "FAIL: manual recovery record has invalid Blocking Category"

invalid_abandoned_implementation_run="$(create_fixture "invalid-abandoned-invalid-implementation")"
run_expect_failure "$invalid_abandoned_implementation_run" "FAIL: implementation record is missing final implementation SHA"

missing_abandoned_verification_run="$(create_fixture "invalid-abandoned-missing-verification")"
run_expect_failure "$missing_abandoned_verification_run" "FAIL: terminal manifest is missing verification record artifact"

cross_run_acceptance_run="$(create_fixture "invalid-abandoned-cross-run-acceptance")"
run_expect_failure "$cross_run_acceptance_run" "FAIL: abandoned manifest is missing Business Acceptance record"

skipped_acceptance_run="$(create_fixture "invalid-abandoned-skipped-acceptance")"
run_expect_failure "$skipped_acceptance_run" "FAIL: abandoned manifest requires confirmed Business Acceptance stage"

impersonated_acceptance_run="$(create_fixture "invalid-abandoned-impersonated-acceptance")"
run_expect_failure "$impersonated_acceptance_run" "FAIL: abandoned manifest is missing Business Acceptance record"

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

missing_snapshot_run="$(create_fixture "invalid-final-verification-missing-snapshot")"
expect_validator_failure "$missing_snapshot_run" --final-verification "FAIL: final verification record is missing Verification Start Tracked Snapshot"
run_expect_failure "$missing_snapshot_run" "FAIL: final verification record is missing Verification Start Tracked Snapshot"

inconsistent_snapshot_run="$(create_fixture "invalid-final-verification-inconsistent-snapshot")"
expect_validator_failure "$inconsistent_snapshot_run" --final-verification "FAIL: final verification start and end snapshots differ"

unreachable_final_sha_run="$(create_fixture "invalid-final-verification-unreachable-final-sha")"
expect_validator_failure "$unreachable_final_sha_run" --final-verification "FAIL: final verification final implementation SHA is not reachable"

branch_changed_run="$(create_fixture "invalid-final-verification-branch-changed")"
expect_validator_failure "$branch_changed_run" --final-verification "FAIL: final verification branch changed"

tracked_snapshot_changed_run="$(create_fixture "invalid-final-verification-tracked-snapshot-changed")"
expect_validator_failure "$tracked_snapshot_changed_run" --final-verification "FAIL: final verification tracked snapshot changed"

unapproved_code_commit_run="$(create_fixture "invalid-final-verification-unapproved-code-commit")"
expect_validator_failure "$unapproved_code_commit_run" --final-verification "FAIL: final verification contains unapproved commit after verification"

merge_checkpoint_run="$(create_fixture "invalid-final-verification-merge-checkpoint")"
expect_validator_failure "$merge_checkpoint_run" --final-verification "FAIL: final verification checkpoint changes outside run directory"

symbolic_head_run="$(create_fixture "invalid-final-verification-symbolic-head")"
expect_validator_failure "$symbolic_head_run" --final-verification "FAIL: final verification HEAD must be a full commit SHA"

branch_ref_head_run="$(create_fixture "invalid-final-verification-branch-ref-head")"
expect_validator_failure "$branch_ref_head_run" --final-verification "FAIL: final verification HEAD must be a full commit SHA"

printf 'Delivery record contract checks passed.\n'
