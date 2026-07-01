#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if rg -n 'specs/[.]gitkeep' README.md AGENTS.md docs references skills templates scripts tests .codex-plugin; then
  echo "ERROR old thin contract path found; use specs/records/.gitkeep" >&2
  exit 1
fi

if rg -n 'plugin-skill-modularization[.]md' README.md AGENTS.md docs references skills templates scripts tests .codex-plugin; then
  echo "ERROR old boundary document path found; use docs/codex-plugin-boundaries.md" >&2
  exit 1
fi

if rg -n 'specs/\{task_id\}' README.md AGENTS.md docs references skills templates scripts .codex-plugin --glob '!docs/archive/**'; then
  echo "ERROR old task artifact path found in current content; use specs/records/{task_id}" >&2
  exit 1
fi

if rg -n 'cadence-address-review' references skills templates scripts .codex-plugin docs README.md; then
  echo "ERROR old review feedback Skill name found; use cadence-review" >&2
  exit 1
fi

if rg -n 'cadence-request-review' references skills templates scripts .codex-plugin docs README.md; then
  echo "ERROR old code review request Skill name found; use cadence-request-code-review" >&2
  exit 1
fi

if rg -n 'cadence-execute([^a-z-]|$)' references skills templates scripts .codex-plugin docs README.md; then
  echo "ERROR old plan execution Skill name found; use cadence-executing-plans" >&2
  exit 1
fi

if rg -n 'superpowers|Superpowers|SUPERPOWERS|super powers|Super Powers|using-superpowers|brainstorming|writing-plans|test-driven-development|systematic-debugging' \
  skills references templates scripts .codex-plugin README.md docs \
  --glob '!docs/archive/**' \
  --glob '!docs/skill-parity-improvement-plan.md'; then
  echo "ERROR external product or source-project references found in current Dev Cadence content" >&2
  exit 1
fi

echo "current contract terms ok"
