#!/usr/bin/env bash
set -euo pipefail

reject() {
  printf 'not_owned:%s\n' "$1"
  exit 1
}

[[ "$#" -eq 6 ]] || reject missing_evidence
primary_root="$1"
created_by_run="$2"
workspace_path="$3"
task_branch_ref="$4"
creation_head="$5"
expected_current_head="$6"
[[ "$created_by_run" == yes ]] || reject not_created_by_run
[[ "$workspace_path" != /* && "$workspace_path" != .. && "$workspace_path" != ../* && "$workspace_path" != */../* ]] || reject invalid_workspace_path
[[ "$task_branch_ref" == refs/heads/* ]] || reject missing_evidence
[[ "$creation_head" =~ ^[0-9a-f]{40}$ && "$expected_current_head" =~ ^[0-9a-f]{40}$ ]] || reject missing_evidence

canonicalize_path() {
  candidate="$1"
  if [[ -d "$candidate" ]]; then
    (cd "$candidate" 2>/dev/null && pwd -P)
    return
  fi

  candidate_parent="${candidate%/*}"
  candidate_name="${candidate##*/}"
  canonical_parent="$(cd "$candidate_parent" 2>/dev/null && pwd -P)" || return 1
  printf '%s/%s\n' "$canonical_parent" "$candidate_name"
}

canonical_primary="$(canonicalize_path "$primary_root")" || reject worktree_not_found
canonical_workspace="$(canonicalize_path "$canonical_primary/$workspace_path")" || reject worktree_not_found
case "$canonical_workspace" in
  "$canonical_primary"/*) ;;
  *) reject invalid_workspace_path ;;
esac

match_count=0
matched_head=""
matched_branch=""
matched_bare=""
matched_detached=""
matched_locked=""
matched_prunable=""

stanza_worktree=""
stanza_head=""
stanza_branch=""
stanza_bare=""
stanza_detached=""
stanza_locked=""
stanza_prunable=""

record_stanza() {
  [[ -n "$stanza_worktree" ]] || return 0
  if stanza_canonical="$(canonicalize_path "$stanza_worktree")" &&
    [[ "$stanza_canonical" == "$canonical_workspace" ]]; then
    match_count=$((match_count + 1))
    if [[ "$match_count" -eq 1 ]]; then
      matched_head="$stanza_head"
      matched_branch="$stanza_branch"
      matched_bare="$stanza_bare"
      matched_detached="$stanza_detached"
      matched_locked="$stanza_locked"
      matched_prunable="$stanza_prunable"
    fi
  fi
}

reset_stanza() {
  stanza_worktree=""
  stanza_head=""
  stanza_branch=""
  stanza_bare=""
  stanza_detached=""
  stanza_locked=""
  stanza_prunable=""
}

while IFS= read -r -d '' field; do
  case "$field" in
    "")
      record_stanza
      reset_stanza
      ;;
    "worktree "*) stanza_worktree="${field#worktree }" ;;
    "HEAD "*) stanza_head="${field#HEAD }" ;;
    "branch "*) stanza_branch="${field#branch }" ;;
    bare) stanza_bare=1 ;;
    detached) stanza_detached=1 ;;
    locked | "locked "*) stanza_locked=1 ;;
    prunable | "prunable "*) stanza_prunable=1 ;;
  esac
done < <(git -C "$canonical_primary" worktree list --porcelain -z 2>/dev/null)
record_stanza

[[ "$match_count" -gt 0 ]] || reject worktree_not_found
[[ "$match_count" -eq 1 ]] || reject ambiguous_worktree
[[ "$matched_branch" == "$task_branch_ref" ]] || reject branch_mismatch
[[ -z "$matched_bare$matched_detached$matched_locked$matched_prunable" ]] || reject unsupported_worktree_state
branch_head="$(git -C "$primary_root" rev-parse --verify "$task_branch_ref^{commit}" 2>/dev/null)" || reject head_mismatch
[[ "$matched_head" == "$expected_current_head" && "$branch_head" == "$expected_current_head" ]] || reject head_mismatch
git -C "$primary_root" merge-base --is-ancestor "$creation_head" "$expected_current_head" 2>/dev/null || reject creation_lineage_mismatch
printf 'owned\n'
