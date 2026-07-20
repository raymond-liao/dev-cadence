#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/src/workflows/work-item-analysis/SKILL.md"
ENTRY_SKILL="$ROOT_DIR/src/workflows/using-dev-cadence/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  test -f "$1" || fail "missing ${1#"$ROOT_DIR/"}"
}

assert_literal() {
  local label="$1"
  local literal="$2"
  local path="$3"

  rg --no-ignore -F -n -- "$literal" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  rg --no-ignore -n "$pattern" "$path" >/dev/null ||
    fail "missing $label in ${path#"$ROOT_DIR/"}"
}

assert_not_match() {
  local label="$1"
  local pattern="$2"
  local path="$3"

  if rg --no-ignore -n "$pattern" "$path" >/dev/null; then
    fail "unexpected $label in ${path#"$ROOT_DIR/"}"
  fi
}

assert_file "$SKILL"
assert_literal \
  "description" \
  "description: Use when a user asks to analyze, clarify, or confirm Story, Task, or Bug definitions before downstream delivery work in a target project." \
  "$SKILL"
assert_literal "workflow heading" "# Work Item Analysis" "$SKILL"
assert_literal "asset declaration" "This is an Asset Workflow." "$SKILL"
assert_match "no delivery records" 'must not create `build/dev-cadence/` run manifests?.*stage records?.*confirmation records?.*checkpoint commits?' "$SKILL"
assert_match "docs-only asset scope" 'create or update only authoritative Story, Task, and Bug cards under `docs/`|authoritative Story, Task, and Bug cards under `docs/`' "$SKILL"
assert_match "no delivery evidence copy" 'must not copy the Delivery Workflow record chain|Do not copy Delivery Workflow evidence into work-item assets' "$SKILL"

assert_literal \
  "target repository output language config" \
  'Before producing workflow guidance, in-conversation analysis proposals, user-facing analysis summaries, or durable work-item updates, read `.dev-cadence.yaml` from the target repository root.' \
  "$SKILL"
assert_literal "english output language" '- `output_language: en` uses English.' "$SKILL"
assert_literal "simplified chinese output language" '- `output_language: zh-CN` uses Simplified Chinese.' "$SKILL"
assert_literal "output language fallback" '- If the file or value is missing or unsupported, use English.' "$SKILL"

assert_match "single-item mode" '`single-item analysis`|single-item analysis' "$SKILL"
assert_match "batch mode" '`batch analysis`|batch analysis' "$SKILL"
assert_match "batch explicit selection" 'user explicitly selects|explicitly selected.*set|must not expand.*entire Backlog' "$SKILL"
assert_match "analysis scope confirmation stage" 'Analysis Scope Confirmation' "$SKILL"
assert_match "definition analysis stage" 'Work Item Definition Analysis' "$SKILL"
assert_match "work item confirmation stage" 'Work Item Confirmation' "$SKILL"

assert_literal \
  "conditional Feature traceability" \
  'When a Story has a confirmed primary System Feature or Story Map placement, analysis must retain that traceability; an independent Story without a Feature reference may still become `Ready`.' \
  "$SKILL"
assert_match "story scope headings" 'included scope|excluded scope|in-scope|out-of-scope' "$SKILL"
assert_literal "story ready gate" 'Story must reach `Ready` before entering `feature-dev`.' "$SKILL"
assert_literal \
  "story ready without Feature" \
  'Story may become `Ready` only when the role, goal, value, scope, observable behavior, acceptance conditions, direct dependencies, and development-blocking open questions are explicit and the user has confirmed the work-item definition.' \
  "$SKILL"
assert_literal \
  "missing Feature alone does not route Discovery" \
  'A missing Feature reference or product-design baseline alone must not return Story analysis to `discovery`.' \
  "$SKILL"
assert_literal \
  "Discovery requires product conclusion" \
  'Return to `discovery` only when the Story requires a new or changed product-level conclusion, including a User Journey, Feature, PRD, or Business Architecture conclusion.' \
  "$SKILL"

assert_match "task fields" 'Task.*goal.*necessity.*scope.*completion conditions.*impact' "$SKILL"
assert_literal "task no ready hard gate" 'Task does not need to reach `Ready` before a Delivery Workflow starts.' "$SKILL"
assert_match "task nature optional" 'optional `Nature`|`Nature` is optional' "$SKILL"

assert_match "bug fields" 'Bug.*expected behavior.*observed behavior.*impact.*environment.*reproduction' "$SKILL"
assert_match "bug classification boundary" 'distinguish Bug, expected-behavior change, and insufficient information|expected-behavior change.*insufficient information' "$SKILL"
assert_literal "bug no root cause analysis" 'Work Item Analysis must not investigate or confirm technical root cause.' "$SKILL"
assert_literal "bug direct handoff" 'Bug may enter `bug-fix` without a `Ready` precondition and without a confirmed root cause.' "$SKILL"

assert_literal "card reuse" 'When an authoritative Story, Task, or Bug card already exists, Work Item Analysis must reuse it instead of creating a parallel card.' "$SKILL"
assert_match "lightweight card creation" 'create a lightweight card and complete it in the same confirmed analysis|lightweight card.*same confirmed analysis' "$SKILL"
assert_literal "missing-card backlog handoff" 'When Work Item Analysis creates a card that is not yet registered in `docs/backlog.md`, it must hand the card to `work-item-planning` for Backlog registration before downstream delivery.' "$SKILL"
assert_literal "missing-card no order write" 'Work Item Analysis must not add, remove, or reorder Backlog rows while creating or analyzing a missing card.' "$SKILL"
assert_literal "shared card conflict stop" 'When Work Item Analysis finds a Version or visible-fact conflict, it must stop and require a user decision before continuing.' "$SKILL"
assert_literal "shared Change Log contract read" '.dev-cadence/references/contracts/change-log.md' "$SKILL"
assert_literal "card Change Log follows shared contract" 'For every card Change Log, follow the shared Change Log contract.' "$SKILL"
assert_match "substantive version increments" 'Increment the Version when confirmed changes alter the card'\''s goal, scope, expected behavior, acceptance or completion conditions, key dependencies, or requirement decisions' "$SKILL"
assert_match "non substantive no increment" 'Do not increment the Version for spelling-only, formatting-only, link-only, execution-status-only, or size-only changes' "$SKILL"
assert_match "duplicate overlap dependency conflict" 'duplicate.*overlap.*dependenc.*conflict|dependenc.*duplicate.*overlap.*conflict' "$SKILL"
assert_match "user decides conflict outcome" 'user.*decide|must not automatically delete, merge, or replace' "$SKILL"

assert_match "product boundary discovery" 'return to `discovery`|Discovery.*Feature identities|must not define or reinterpret Feature' "$SKILL"
assert_match "planning boundary" 'return to `work-item-planning`|Story Map.*Milestone.*Backlog order|must not modify Size' "$SKILL"
assert_match "delivery boundary" 'must not design technical solutions, modify code, run delivery testing, or perform business acceptance' "$SKILL"
assert_match "bug-fix boundary" 'does not replace `bug-fix`|`bug-fix`.*root cause.*repair boundary' "$SKILL"

assert_match "proposal before confirmation" 'Before confirmation, keep the complete proposal in the conversation and leave authoritative assets unchanged' "$SKILL"
assert_match "atomic confirmed write" 'atomically write only the confirmed card updates\.|atomically write only confirmed Story, Task, and Bug updates' "$SKILL"
assert_match "partial confirmation" 'The user may confirm only part of the proposal|unconfirmed cards must keep their current authoritative content' "$SKILL"
assert_match "downstream handoff" 'Ready Story -> `feature-dev`|Task -> `feature-dev` / `bug-fix` / `refactor`|Bug -> `bug-fix`' "$SKILL"
assert_not_match "delivery build records" '04-code-review-report\.md|01-requirements\.md|02-technical-solution\.md|03-implementation-plan\.md|Business Acceptance' "$SKILL"
assert_not_match "personal absolute paths" '/Users/|/private/tmp|/private/var|[A-Za-z]:\\Users\\' "$SKILL"

assert_literal "entry route path" '.dev-cadence/workflows/work-item-analysis/SKILL.md' "$ENTRY_SKILL"
assert_match "entry route row" 'analyze, clarify, or confirm one Story, Task, or Bug definition|selected batch of Story, Task, or Bug definitions' "$ENTRY_SKILL"
assert_match "entry routing boundary" 'after analysis, hand confirmed work items to `feature-dev`, `bug-fix`, or `refactor`|does not replace downstream delivery workflows' "$ENTRY_SKILL"

printf 'Work item analysis contract checks passed.\n'
