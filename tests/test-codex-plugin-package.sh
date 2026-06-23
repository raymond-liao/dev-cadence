#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$(mktemp -d /private/tmp/dev-cadence-codex-plugin.XXXXXX)"
trap 'rm -rf "${PACKAGE_DIR}"' EXIT

copy_path() {
  local relative_path="$1"
  mkdir -p "${PACKAGE_DIR}/$(dirname "${relative_path}")"
  cp -R "${ROOT_DIR}/${relative_path}" "${PACKAGE_DIR}/${relative_path}"
}

assert_exists() {
  local relative_path="$1"
  test -e "${PACKAGE_DIR}/${relative_path}" || {
    echo "missing expected package path: ${relative_path}" >&2
    exit 1
  }
}

assert_absent() {
  local relative_path="$1"
  test ! -e "${PACKAGE_DIR}/${relative_path}" || {
    echo "unexpected package path: ${relative_path}" >&2
    exit 1
  }
}

copy_path ".codex-plugin"
copy_path "hooks"
copy_path "skills"
copy_path "references"
copy_path "templates"
copy_path "scripts"

find "${PACKAGE_DIR}" -name ".DS_Store" -delete

assert_exists ".codex-plugin/plugin.json"
assert_exists "hooks/hooks-codex.json"
assert_exists "hooks/session-start-codex"
assert_exists "hooks/run-hook.cmd"
assert_exists "skills/dev-cadence-init/SKILL.md"
assert_exists "skills/dev-cadence-deliver/SKILL.md"
assert_exists "skills/dev-cadence-maintain/SKILL.md"
assert_exists "skills/dev-cadence-authoring/SKILL.md"
assert_exists "references/skill-layout.md"
assert_exists "references/delivery-disciplines.md"
assert_exists "templates/spec/00-brief.md"
assert_exists "templates/runs/run-context.md"
assert_exists "templates/prompts/implementer.md"
assert_exists "scripts/sync-repo-contract.mjs"
assert_exists "scripts/run-delivery-dry-run.mjs"
assert_exists "scripts/visual-companion/server.cjs"

assert_absent "docs"
assert_absent "research"
assert_absent "specs"
assert_absent "tests"
assert_absent "AGENTS.md"
assert_absent "README.md"
assert_absent ".git"
assert_absent ".idea"
assert_absent ".gitignore"

node "${ROOT_DIR}/scripts/check-skill-package.mjs" "${PACKAGE_DIR}" > /dev/null
node "${ROOT_DIR}/scripts/check-discipline-routes.mjs" "${PACKAGE_DIR}" > /dev/null

node --input-type=module - "${PACKAGE_DIR}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const packageDir = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(path.join(packageDir, '.codex-plugin/plugin.json'), 'utf8'));

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(manifest.name === 'dev-cadence', 'package manifest name must be dev-cadence');
assert(manifest.skills === './skills/', 'package manifest must point at bundled skills');
assert(manifest.hooks === './hooks/hooks-codex.json', 'package manifest must point at bundled hooks');

const shippedFiles = [];
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(fullPath);
    } else {
      shippedFiles.push(path.relative(packageDir, fullPath));
    }
  }
}
walk(packageDir);

assert(!shippedFiles.some((file) => file.startsWith('docs/')), 'package must exclude docs');
assert(!shippedFiles.some((file) => file.startsWith('research/')), 'package must exclude research');
assert(!shippedFiles.some((file) => file.startsWith('specs/')), 'package must exclude historical specs');
assert(!shippedFiles.some((file) => file.startsWith('tests/')), 'package must exclude tests');
assert(!shippedFiles.includes('AGENTS.md'), 'package must exclude repo-local AGENTS.md');
assert(!shippedFiles.includes('README.md'), 'package must exclude project README');

console.log('codex plugin package contract ok');
NODE
