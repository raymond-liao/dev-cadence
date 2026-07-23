#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/workflows/work-item-analysis/SKILL.md"
ENTRY="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_literal() {
  local label="$1" literal="$2" path="$3"
  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1" pattern="$2" path="$3"
  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1" pattern="$2" path="$3"
  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

test -f "$SKILL" || fail "missing work-item-analysis workflow"
assert_literal "description" "description: Use when a user asks to analyze, clarify, or confirm one existing Story, Task, or Bug definition before downstream delivery work." "$SKILL"
assert_literal "asset declaration" "This is an Asset Workflow." "$SKILL"
assert_match "no delivery records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$SKILL"
assert_match "one card" 'analyze exactly one authoritative Story, Task, or Bug card|exactly one existing conforming card' "$SKILL"
assert_literal "no batch" "- analyze a batch, the whole Backlog, or a portfolio;" "$SKILL"
assert_literal "no card creation" "- create a missing card;" "$SKILL"
assert_match "missing card handoff" 'no conforming authoritative card exists.*backlog/SKILL.md' "$SKILL"
assert_match "nonconforming handoff" 'does not satisfy the structural card contract.*return it to Backlog' "$SKILL"
assert_match "no normalization" 'Do not normalize or recreate it inside Work Item Analysis' "$SKILL"

assert_literal "sequence" "Necessary Clarification -> Work Item Definition Proposal -> Work Item Confirmation" "$SKILL"
assert_literal "clarification boundary" "Necessary Clarification is not a formal confirmation gate." "$SKILL"
assert_match "proposal remains uncommitted" 'Before Work Item Confirmation, leave authoritative assets unchanged' "$SKILL"
assert_match "single card confirmation" 'confirmation applies to only this card.*must not change unrelated cards or Backlog order' "$SKILL"

for field in role goal value scope 'observable system behavior' 'acceptance conditions' 'direct dependencies' 'Open Questions'; do
  assert_match "Story field $field" "$field" "$SKILL"
done
assert_match "Story maturity" 'Story may become `Ready` only when.*user confirms the definition' "$SKILL"
assert_literal "Story no product dependency" 'Story does not require a Feature, User Journey, PRD, Story Map position, or other product-analysis reference to become `Ready`.' "$SKILL"
assert_literal "Story delivery gate" 'Story must reach `Ready` before entering `feature-dev`.' "$SKILL"

assert_match "Task fields" 'goal and necessity|completion conditions|affected system or work-item area' "$SKILL"
assert_literal "Task no Ready gate" 'Task does not need to reach `Ready` before a Delivery Workflow starts.' "$SKILL"
assert_match "Bug fields" 'expected behavior|observed behavior|impact and severity|reproduction information' "$SKILL"
assert_literal "Bug no root cause" 'Work Item Analysis must not investigate or confirm technical root cause, repair boundary, regression proof, or technical fix strategy.' "$SKILL"
assert_literal "Bug direct route" 'A Bug may enter `bug-fix` without `Ready`, complete reproduction, or known root cause.' "$SKILL"

assert_match "conflict stop" 're-read the card Version and visible facts.*stop and form a new proposal' "$SKILL"
assert_match "mechanical backlog sync" 'atomically synchronize only the matching Backlog row.*Status and Version' "$SKILL"
assert_match "no backlog structure change" 'must not add, remove, move, or reorder Backlog rows' "$SKILL"
assert_literal "maturity statuses only" 'Work Item Analysis may change Status only among the definition-maturity statuses `Draft`, `Ready`, and `Blocked`.' "$SKILL"
assert_literal "maturity stays pending" 'These statuses all remain in the Backlog `待处理` section.' "$SKILL"
assert_literal "forbidden lifecycle statuses" 'Work Item Analysis must not set `In Progress`, `Done`, `Superseded`, or `Dropped`.' "$SKILL"
assert_match "pending-only status sync" 'allowed maturity Status or Version.*matching Backlog row.*in `待处理`' "$SKILL"
assert_literal "Ready Story handoff" 'Ready Story -> `feature-dev`' "$SKILL"
assert_literal "Bug handoff" 'Bug -> `bug-fix`' "$SKILL"
assert_match "no automatic delivery" 'must not automatically claim or start a downstream workflow' "$SKILL"

assert_literal "entry path" '.dev-cadence/workflows/work-item-analysis/SKILL.md' "$ENTRY"
assert_match "entry exact one" 'exactly one existing Story, Task, or Bug definition' "$ENTRY"
assert_not_match "removed planning route" 'work-item-planning' "$SKILL"
assert_not_match "batch route" 'selected batch|batch analysis' "$SKILL"
assert_not_match "personal paths" '/Users/|/private/tmp|/private/var|[A-Za-z]:\\Users\\' "$SKILL"

printf 'Work Item Analysis contract checks passed.\n'
