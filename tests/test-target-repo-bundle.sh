#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="$(mktemp -d /private/tmp/dev-cadence-target-bundle.XXXXXX)"
TARGET_DIR="$(mktemp -d /private/tmp/dev-cadence-target-repo.XXXXXX)"
REPORT_JSON="$(mktemp /private/tmp/dev-cadence-target-bundle-report.XXXXXX.json)"
SYNC_JSON="${TARGET_DIR}/sync-report.json"
SYNC_AGAIN_JSON="${TARGET_DIR}/sync-again-report.json"
trap 'rm -rf "${BUNDLE_DIR}" "${TARGET_DIR}" "${REPORT_JSON}"' EXIT

node "${ROOT_DIR}/scripts/package-target-repo-bundle.mjs" \
  --output-dir "${BUNDLE_DIR}" \
  --clean \
  --json > "${REPORT_JSON}"

test -d "${BUNDLE_DIR}/.dev-cadence"
test -f "${BUNDLE_DIR}/.dev-cadence/VERSION"
test -f "${BUNDLE_DIR}/.dev-cadence/manifest.json"
test -f "${BUNDLE_DIR}/.dev-cadence/skills/using-dev-cadence/SKILL.md"
test -f "${BUNDLE_DIR}/.dev-cadence/skills/cadence-debug/root-cause-tracing.md"
test -f "${BUNDLE_DIR}/.dev-cadence/skills/cadence-debug/condition-based-waiting.md"
test -f "${BUNDLE_DIR}/.dev-cadence/skills/cadence-debug/defense-in-depth.md"
runtime_agents_dir="$(find "${BUNDLE_DIR}/.dev-cadence/skills" -path '*/agents' -type d -print -quit)"
test -z "${runtime_agents_dir}" || {
  echo "unexpected skill-local agents directory in target runtime: ${runtime_agents_dir#${BUNDLE_DIR}/}" >&2
  exit 1
}
test -f "${BUNDLE_DIR}/.dev-cadence/references/skill-layout.md"
test ! -e "${BUNDLE_DIR}/.dev-cadence/references/root-cause-tracing.md"
test ! -e "${BUNDLE_DIR}/.dev-cadence/references/condition-based-waiting.md"
test ! -e "${BUNDLE_DIR}/.dev-cadence/references/defense-in-depth.md"
test ! -e "${BUNDLE_DIR}/.dev-cadence/references/source-maintenance"
test -f "${BUNDLE_DIR}/.dev-cadence/templates/spec/00-brief.md"
test -f "${BUNDLE_DIR}/.dev-cadence/scripts/check-gates.mjs"
test -f "${BUNDLE_DIR}/AGENTS.dev-cadence-section.md"
test -f "${BUNDLE_DIR}/.dev-cadence.yaml"
! grep -q "references/source-maintenance" "${BUNDLE_DIR}/.dev-cadence/references/delivery-disciplines.md"
test ! -e "${BUNDLE_DIR}/.codex-plugin"
test ! -e "${BUNDLE_DIR}/docs"
test ! -e "${BUNDLE_DIR}/tests"

node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${BUNDLE_DIR}/.dev-cadence" > /dev/null
node "${ROOT_DIR}/scripts/check-discipline-routes.mjs" "${BUNDLE_DIR}/.dev-cadence" > /dev/null

cat > "${TARGET_DIR}/AGENTS.md" <<'EOF'
# Product Agent Rules

Preserve product-specific instructions.
EOF

node "${ROOT_DIR}/scripts/sync-target-repo-bundle.mjs" \
  --target "${TARGET_DIR}" \
  --bundle-dir "${BUNDLE_DIR}" \
  --json > "${SYNC_JSON}"

test -d "${TARGET_DIR}/.dev-cadence"
test -f "${TARGET_DIR}/.dev-cadence/manifest.json"
test -f "${TARGET_DIR}/.dev-cadence/VERSION"
test -f "${TARGET_DIR}/.dev-cadence/skills/using-dev-cadence/SKILL.md"
test -f "${TARGET_DIR}/.dev-cadence.yaml"
test -f "${TARGET_DIR}/specs/records/.gitkeep"
grep -q "Preserve product-specific instructions" "${TARGET_DIR}/AGENTS.md"
grep -q ".dev-cadence/skills/using-dev-cadence/SKILL.md" "${TARGET_DIR}/AGENTS.md"
grep -q "Do not rely on global plugin or Skill auto-discovery" "${TARGET_DIR}/AGENTS.md"
grep -qx ".dev-cadence.yaml" "${TARGET_DIR}/.gitignore"

cat > "${TARGET_DIR}/.dev-cadence.yaml" <<'EOF'
dev_cadence:
  artifact_language: zh
EOF

mkdir -p "${TARGET_DIR}/.dev-cadence/references/source-maintenance"
cat > "${TARGET_DIR}/.dev-cadence/references/source-maintenance/stale.md" <<'EOF'
stale source-only runtime content
EOF

node "${ROOT_DIR}/scripts/sync-target-repo-bundle.mjs" \
  --target "${TARGET_DIR}" \
  --bundle-dir "${BUNDLE_DIR}" \
  --json > "${SYNC_AGAIN_JSON}"

grep -q "artifact_language: zh" "${TARGET_DIR}/.dev-cadence.yaml"
test ! -e "${TARGET_DIR}/.dev-cadence/references/source-maintenance"

node --input-type=module - "${REPORT_JSON}" "${SYNC_JSON}" "${SYNC_AGAIN_JSON}" "${TARGET_DIR}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const [reportPath, syncPath, syncAgainPath, targetDir] = process.argv.slice(2);
const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
const sync = JSON.parse(fs.readFileSync(syncPath, 'utf8'));
const syncAgain = JSON.parse(fs.readFileSync(syncAgainPath, 'utf8'));
const manifest = JSON.parse(fs.readFileSync(path.join(targetDir, '.dev-cadence/manifest.json'), 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(report.files_copied.includes('.dev-cadence/manifest.json'), 'bundle report must include runtime manifest');
assert(report.files_copied.includes('AGENTS.dev-cadence-section.md'), 'bundle report must include AGENTS section');
assert(report.checks.every((check) => check.status === 0), 'bundle checks must pass');
assert(manifest.name === 'dev-cadence', 'embedded manifest name must be dev-cadence');
assert(manifest.entrypoint === 'skills/using-dev-cadence/SKILL.md', 'embedded manifest entrypoint must be set');
assert(sync.files_added.includes('.dev-cadence/skills/using-dev-cadence/SKILL.md'), 'sync must add embedded entrypoint');
assert(sync.files_updated.includes('AGENTS.md'), 'sync must update AGENTS.md');
assert(sync.files_added.includes('.dev-cadence.yaml'), 'sync must add local yaml when missing');
assert(sync.files_added.includes('specs/records/.gitkeep'), 'sync must add specs records gitkeep');
assert(sync.verification.every((item) => item.status === 'pass'), 'sync verification must pass');
assert(syncAgain.files_preserved.includes('.dev-cadence.yaml'), 'second sync must preserve local yaml override');
assert(syncAgain.files_removed.includes('.dev-cadence/references/source-maintenance'), 'second sync must remove stale source-only runtime references');
assert(syncAgain.verification.every((item) => item.status === 'pass'), 'second sync verification must pass');

console.log('target repo bundle ok');
NODE
