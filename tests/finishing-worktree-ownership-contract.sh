#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFIER="$ROOT/src/vendor/superpowers/skills/finishing-a-development-branch/scripts/verify-worktree-ownership.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -x "$VERIFIER" ]] || fail "verifier file is missing or not executable: $VERIFIER"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/finishing-worktree-ownership.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

repo="$(cd "$TMP_ROOT" && pwd -P)/repo"
git init -q "$repo"
git -C "$repo" config user.name "Contract Test"
git -C "$repo" config user.email "contract@example.invalid"
git -C "$repo" commit -q --allow-empty -m "base"
base_sha="$(git -C "$repo" rev-parse HEAD)"

create_worktree() {
  branch_name="$1"
  workspace_path="$2"
  git -C "$repo" worktree add -q -b "$branch_name" "$repo/$workspace_path" "$base_sha"
}

assert_owned() {
  output="$("$VERIFIER" "$repo" yes "$workspace" "$branch_ref" "$creation_sha" "$current_sha")"
  [[ "$output" == owned ]] || fail "expected owned, got: $output"
}

assert_not_owned_and_preserved() {
  expected_reason="$1"
  expected_workspace="$2"
  shift 2
  set +e
  output="$("$VERIFIER" "$@")"
  status=$?
  set -e
  [[ "$status" -ne 0 ]] || fail "expected verifier rejection"
  [[ "$output" == "not_owned:$expected_reason" ]] || fail "unexpected reason: $output"
  git -C "$repo" worktree list --porcelain | rg -F "worktree $expected_workspace" >/dev/null ||
    fail "rejected worktree was removed"
}

REAL_GIT="$(command -v git)"
FAKE_GIT_BIN="$TMP_ROOT/fake-git-bin"
mkdir -p "$FAKE_GIT_BIN"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'if [[ "$#" -eq 6 && "$1" == -C && "$3" == worktree && "$4" == list && "$5" == --porcelain && "$6" == -z && "${INJECT_UNKNOWN_WORKTREE_FIELD:-}" == yes ]]; then' \
  '  printf "worktree %s\\0HEAD %s\\0branch %s\\0unknown-field injected\\0\\0" "$FIXTURE_WORKTREE" "$FIXTURE_HEAD" "$FIXTURE_BRANCH"' \
  '  exit 0' \
  'fi' \
  'exec "$REAL_GIT" "$@"' \
  > "$FAKE_GIT_BIN/git"
chmod +x "$FAKE_GIT_BIN/git"

assert_unknown_porcelain_field_rejected() {
  expected_workspace="$1"
  set +e
  output="$(
    PATH="$FAKE_GIT_BIN:$PATH" \
      REAL_GIT="$REAL_GIT" \
      INJECT_UNKNOWN_WORKTREE_FIELD=yes \
      FIXTURE_WORKTREE="$expected_workspace" \
      FIXTURE_HEAD="$base_sha" \
      FIXTURE_BRANCH="refs/heads/owned-default" \
      "$VERIFIER" "$repo" yes ".worktrees/owned-default" "refs/heads/owned-default" "$base_sha" "$base_sha"
  )"
  status=$?
  set -e
  [[ "$status" -ne 0 ]] || fail "expected verifier rejection for unknown porcelain field"
  [[ "$output" == "not_owned:unsupported_worktree_state" ]] || fail "unexpected reason: $output"
  git -C "$repo" worktree list --porcelain | rg -F "worktree $expected_workspace" >/dev/null ||
    fail "unknown-field rejection removed worktree"
}

create_worktree "owned-default" ".worktrees/owned-default"
workspace=".worktrees/owned-default"
branch_ref="refs/heads/owned-default"
creation_sha="$base_sha"
current_sha="$base_sha"
assert_owned

assert_unknown_porcelain_field_rejected "$repo/.worktrees/owned-default"

create_worktree "owned-custom" "custom-worktrees/owned-custom"
workspace="custom-worktrees/owned-custom"
branch_ref="refs/heads/owned-custom"
assert_owned

default_workspace="$repo/.worktrees/owned-default"
assert_not_owned_and_preserved missing_evidence "$default_workspace" \
  "$repo" yes ".worktrees/owned-default" "refs/heads/owned-default" "$base_sha"
assert_not_owned_and_preserved not_created_by_run "$default_workspace" \
  "$repo" no ".worktrees/owned-default" "refs/heads/owned-default" "$base_sha" "$base_sha"
assert_not_owned_and_preserved invalid_workspace_path "$default_workspace" \
  "$repo" yes "../escape" "refs/heads/owned-default" "$base_sha" "$base_sha"
assert_not_owned_and_preserved worktree_not_found "$default_workspace" \
  "$repo" yes ".worktrees/does-not-exist" "refs/heads/owned-default" "$base_sha" "$base_sha"

create_worktree "branch-mismatch" ".worktrees/branch-mismatch"
branch_mismatch_workspace="$repo/.worktrees/branch-mismatch"
assert_not_owned_and_preserved branch_mismatch "$branch_mismatch_workspace" \
  "$repo" yes ".worktrees/branch-mismatch" "refs/heads/owned-default" "$base_sha" "$base_sha"

create_worktree "head-mismatch" ".worktrees/head-mismatch"
git -C "$repo/.worktrees/head-mismatch" commit -q --allow-empty -m "advance head"
head_mismatch_workspace="$repo/.worktrees/head-mismatch"
assert_not_owned_and_preserved head_mismatch "$head_mismatch_workspace" \
  "$repo" yes ".worktrees/head-mismatch" "refs/heads/head-mismatch" "$base_sha" "$base_sha"

unrelated_tree="$(git -C "$repo" write-tree)"
unrelated_sha="$(printf 'unrelated creation\n' | git -C "$repo" commit-tree "$unrelated_tree")"
create_worktree "lineage-mismatch" ".worktrees/lineage-mismatch"
lineage_workspace="$repo/.worktrees/lineage-mismatch"
assert_not_owned_and_preserved creation_lineage_mismatch "$lineage_workspace" \
  "$repo" yes ".worktrees/lineage-mismatch" "refs/heads/lineage-mismatch" "$unrelated_sha" "$base_sha"

git -C "$repo" worktree add -q --detach "$repo/.worktrees/detached" "$base_sha"
detached_workspace="$repo/.worktrees/detached"
assert_not_owned_and_preserved branch_mismatch "$detached_workspace" \
  "$repo" yes ".worktrees/detached" "refs/heads/owned-default" "$base_sha" "$base_sha"

create_worktree "locked" ".worktrees/locked"
git -C "$repo" worktree lock --reason "contract fixture" "$repo/.worktrees/locked"
locked_workspace="$repo/.worktrees/locked"
assert_not_owned_and_preserved unsupported_worktree_state "$locked_workspace" \
  "$repo" yes ".worktrees/locked" "refs/heads/locked" "$base_sha" "$base_sha"

create_worktree "prunable" ".worktrees/prunable"
prunable_workspace="$repo/.worktrees/prunable"
rm -rf "$prunable_workspace"
assert_not_owned_and_preserved unsupported_worktree_state "$prunable_workspace" \
  "$repo" yes ".worktrees/prunable" "refs/heads/prunable" "$base_sha" "$base_sha"

create_worktree "nested-prunable" "removed-parent/nested"
nested_prunable_workspace="$repo/removed-parent/nested"
rm -rf "$repo/removed-parent"
assert_not_owned_and_preserved unsupported_worktree_state "$nested_prunable_workspace" \
  "$repo" yes "removed-parent/nested" "refs/heads/nested-prunable" "$base_sha" "$base_sha"

create_worktree "ambiguous" ".worktrees/ambiguous"
ambiguous_workspace="$repo/.worktrees/ambiguous"
ambiguous_admin="$(git -C "$ambiguous_workspace" rev-parse --git-dir)"
cp -R "$ambiguous_admin" "$repo/.git/worktrees/ambiguous-duplicate"
assert_not_owned_and_preserved ambiguous_worktree "$ambiguous_workspace" \
  "$repo" yes ".worktrees/ambiguous" "refs/heads/ambiguous" "$base_sha" "$base_sha"

printf 'Finishing worktree ownership contract checks passed.\n'
