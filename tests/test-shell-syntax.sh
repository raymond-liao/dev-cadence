#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

scripts=(
  "deploy-local.sh"
)

while IFS= read -r script_path; do
  scripts+=("${script_path#${ROOT_DIR}/}")
done < <(find "${ROOT_DIR}/skills/cadence-clarify/scripts" -type f -name '*.sh' | sort)

for script_path in "${scripts[@]}"; do
  bash -n "${ROOT_DIR}/${script_path}"
done

echo "shell syntax ok"
