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

echo "current contract terms ok"
