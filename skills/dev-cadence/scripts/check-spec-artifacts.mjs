#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function printHelp() {
  console.log(`Usage: check-spec-artifacts.mjs [specs-dir]

Validates Dev Cadence task artifacts for basic YAML-like consistency.

Arguments:
  specs-dir  Specs directory to check. Defaults to specs in the current working
             directory.

Checks:
  - fenced yaml blocks do not contain duplicate keys at the same indentation
    path`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const specsDir = path.resolve(process.argv[2] || 'specs');
const errors = [];

function fail(message) {
  errors.push(message);
}

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
}

function relative(filePath) {
  return path.relative(process.cwd(), filePath) || filePath;
}

function yamlBlocks(text) {
  const blocks = [];
  const pattern = /```ya?ml\n([\s\S]*?)```/g;
  for (const match of text.matchAll(pattern)) {
    blocks.push(match[1]);
  }
  return blocks;
}

function checkDuplicateKeys(filePath, block, blockIndex) {
  const scopes = [{ indent: -1, keys: new Set(), path: [] }];
  const lines = block.split('\n');

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const listItem = line.match(/^(\s*)-\s+(.*)$/);
    if (listItem) {
      const indent = listItem[1].length;
      while (scopes.length > 1 && indent <= scopes[scopes.length - 1].indent) {
        scopes.pop();
      }

      const parent = scopes[scopes.length - 1];
      const itemScope = { indent, keys: new Set(), path: [...parent.path, '[]'] };
      scopes.push(itemScope);

      const inlineKey = listItem[2].match(/^([A-Za-z0-9_-]+):(?:\s|$)/);
      if (inlineKey) {
        itemScope.keys.add(inlineKey[1]);
      }
      continue;
    }

    const match = line.match(/^(\s*)([A-Za-z0-9_-]+):(?:\s|$)/);
    if (!match) continue;

    const indent = match[1].length;
    const key = match[2];
    while (scopes.length > 1 && indent <= scopes[scopes.length - 1].indent) {
      scopes.pop();
    }

    const scope = scopes[scopes.length - 1];
    if (scope.keys.has(key)) {
      const scopePath = scope.path.length > 0 ? `${scope.path.join('.')}.` : '';
      fail(`${relative(filePath)}: duplicate yaml key '${scopePath}${key}' in block ${blockIndex + 1}, line ${index + 1}`);
    } else {
      scope.keys.add(key);
    }

    scopes.push({ indent, keys: new Set(), path: [...scope.path, key] });
  }
}

if (!fs.existsSync(specsDir)) {
  console.error(`Specs directory not found: ${specsDir}`);
  process.exit(2);
}

for (const filePath of walk(specsDir)) {
  if (!filePath.endsWith('.md')) continue;
  const text = fs.readFileSync(filePath, 'utf8');
  yamlBlocks(text).forEach((block, index) => checkDuplicateKeys(filePath, block, index));
}

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

console.log(`OK checked spec artifacts in ${path.relative(process.cwd(), specsDir) || specsDir}`);
