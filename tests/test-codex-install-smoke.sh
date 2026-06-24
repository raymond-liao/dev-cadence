#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${RUN_CODEX_INSTALL_TEST:-}" != "1" ]]; then
  echo "skip: set RUN_CODEX_INSTALL_TEST=1 to run real Codex install smoke test"
  exit 0
fi

if ! command -v codex > /dev/null 2>&1; then
  echo "codex CLI not found" >&2
  exit 1
fi

PACKAGE_DIR="$(mktemp -d /private/tmp/dev-cadence-codex-marketplace.XXXXXX)"
CODEX_HOME_DIR="$(mktemp -d /private/tmp/dev-cadence-codex-home.XXXXXX)"
MARKETPLACE_OUTPUT="$(mktemp /private/tmp/dev-cadence-codex-marketplace-add.XXXXXX.json)"
PLUGIN_OUTPUT="$(mktemp /private/tmp/dev-cadence-codex-plugin-add.XXXXXX.json)"
trap 'rm -rf "${PACKAGE_DIR}" "${CODEX_HOME_DIR}"; rm -f "${MARKETPLACE_OUTPUT}" "${PLUGIN_OUTPUT}"' EXIT

node "${ROOT_DIR}/scripts/package-codex-plugin.mjs" \
  --output-dir "${PACKAGE_DIR}" \
  --clean \
  --json > /dev/null

CODEX_HOME="${CODEX_HOME_DIR}" codex plugin marketplace add "${PACKAGE_DIR}" --json > "${MARKETPLACE_OUTPUT}"
CODEX_HOME="${CODEX_HOME_DIR}" codex plugin add dev-cadence@dev-cadence-local --json > "${PLUGIN_OUTPUT}"

node --input-type=module - "${MARKETPLACE_OUTPUT}" "${PLUGIN_OUTPUT}" "${CODEX_HOME_DIR}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const marketplaceOutputPath = process.argv[2];
const pluginOutputPath = process.argv[3];
const codexHome = process.argv[4];

function readJson(filePath) {
  const content = fs.readFileSync(filePath, 'utf8').trim();
  if (!content) {
    throw new Error(`empty JSON output: ${filePath}`);
  }
  return JSON.parse(content);
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

const marketplaceOutput = readJson(marketplaceOutputPath);
const pluginOutput = readJson(pluginOutputPath);
const combinedOutput = JSON.stringify([marketplaceOutput, pluginOutput]);

assert(combinedOutput.includes('dev-cadence-local'), 'Codex output must mention dev-cadence-local marketplace');
assert(combinedOutput.includes('dev-cadence'), 'Codex output must mention dev-cadence plugin');

const homeExists = fs.existsSync(codexHome);
assert(homeExists, 'temporary CODEX_HOME must exist');

const installedCandidates = [
  path.join(codexHome, 'plugins'),
  path.join(codexHome, '.plugins'),
  path.join(codexHome, 'skills'),
  path.join(codexHome, '.agents'),
].filter((candidate) => fs.existsSync(candidate));

assert(installedCandidates.length > 0, 'Codex install should write only inside temporary CODEX_HOME');

console.log('real Codex install smoke ok');
NODE
