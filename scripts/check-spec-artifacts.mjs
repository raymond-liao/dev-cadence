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
    path
  - when .dev-cadence.yaml sets artifact_language: zh, Markdown prose that
    appears to be English-only is reported as a warning`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

const specsDir = path.resolve(process.argv[2] || 'specs');
const errors = [];
const warnings = [];

function fail(message) {
  errors.push(message);
}

function warn(message) {
  warnings.push(message);
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
  const relativePath = path.relative(process.cwd(), filePath);
  if (!relativePath || relativePath.startsWith('..') || path.isAbsolute(relativePath)) {
    return filePath;
  }
  return relativePath;
}

function yamlBlocks(text) {
  const blocks = [];
  const pattern = /```ya?ml\n([\s\S]*?)```/g;
  for (const match of text.matchAll(pattern)) {
    blocks.push(match[1]);
  }
  return blocks;
}

function findNearestConfig(startPath) {
  let current = fs.existsSync(startPath) && fs.statSync(startPath).isDirectory()
    ? startPath
    : path.dirname(startPath);

  while (true) {
    const candidate = path.join(current, '.dev-cadence.yaml');
    if (fs.existsSync(candidate)) {
      return candidate;
    }
    const parent = path.dirname(current);
    if (parent === current) {
      return null;
    }
    current = parent;
  }
}

function parseArtifactLanguage(configPath) {
  if (!configPath) return 'en';
  const text = fs.readFileSync(configPath, 'utf8');
  const lines = text.split(/\r?\n/);
  let inDevCadence = false;
  let devCadenceIndent = -1;

  for (const line of lines) {
    if (!line.trim() || line.trim().startsWith('#')) continue;
    const indent = line.match(/^\s*/)[0].length;
    const keyMatch = line.match(/^(\s*)dev_cadence:\s*(?:#.*)?$/);
    if (keyMatch) {
      inDevCadence = true;
      devCadenceIndent = indent;
      continue;
    }

    if (inDevCadence && indent <= devCadenceIndent) {
      inDevCadence = false;
      devCadenceIndent = -1;
    }

    if (inDevCadence) {
      const languageMatch = line.match(/^\s*artifact_language:\s*([A-Za-z_-]+)\s*(?:#.*)?$/);
      if (languageMatch) {
        return ['en', 'zh'].includes(languageMatch[1]) ? languageMatch[1] : 'en';
      }
    }
  }

  return 'en';
}

function shouldCheckArtifactLanguage(configPath, targetDir) {
  if (!configPath) return false;
  const repoDir = path.dirname(configPath);
  const relativeTarget = path.relative(repoDir, targetDir);
  if (relativeTarget === 'specs') return true;
  return relativeTarget.split(path.sep)[0] === 'specs';
}

function markdownProseLines(text) {
  const lines = [];
  let inFence = false;
  const sourceLines = text.split('\n');

  for (let index = 0; index < sourceLines.length; index += 1) {
    const line = sourceLines[index];
    if (line.trim().startsWith('```')) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;

    const trimmed = line.trim();
    if (!trimmed) continue;
    if (trimmed.startsWith('#')) continue;
    if (trimmed.startsWith('|')) continue;
    if (/^[-*_]{3,}$/.test(trimmed)) continue;
    if (/^<!--.*-->$/.test(trimmed)) continue;

    lines.push({ number: index + 1, text: trimmed });
  }

  return lines;
}

function proseSignal(line) {
  let text = line
    .replace(/`[^`]*`/g, ' ')
    .replace(/\[[^\]]*\]\([^)]*\)/g, ' ')
    .replace(/https?:\/\/\S+/g, ' ')
    .replace(/[A-Za-z0-9_./-]+\.(?:kt|java|py|md|yaml|yml|json|sh|mjs|ts|tsx|js|jsx|xml|gradle)\b/g, ' ')
    .replace(/^\s*[-*+]\s+/, ' ')
    .replace(/^\s*\d+\.\s+/, ' ')
    .trim();

  const cjkChars = (text.match(/[\u3400-\u9fff]/g) || []).length;
  const englishWords = (text.match(/\b[A-Za-z][A-Za-z'-]{2,}\b/g) || []).length;
  text = text.replace(/[^A-Za-z\u3400-\u9fff]+/g, '');

  return {
    cjkChars,
    englishWords,
    signalChars: text.length,
  };
}

function checkZhProse(filePath, text) {
  for (const line of markdownProseLines(text)) {
    const signal = proseSignal(line.text);
    if (signal.signalChars < 18) continue;
    if (signal.cjkChars > 0) continue;
    if (signal.englishWords < 4) continue;

    warn(`${relative(filePath)}:${line.number}: English-looking prose in zh artifact_language: ${line.text}`);
  }
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

const configPath = findNearestConfig(specsDir);
const artifactLanguage = shouldCheckArtifactLanguage(configPath, specsDir)
  ? parseArtifactLanguage(configPath)
  : 'en';

for (const filePath of walk(specsDir)) {
  if (!filePath.endsWith('.md')) continue;
  const text = fs.readFileSync(filePath, 'utf8');
  yamlBlocks(text).forEach((block, index) => checkDuplicateKeys(filePath, block, index));
  if (artifactLanguage === 'zh') {
    checkZhProse(filePath, text);
  }
}

if (errors.length > 0) {
  for (const message of errors) {
    console.error(`FAIL ${message}`);
  }
  console.error(`\n${errors.length} failure(s)`);
  process.exit(1);
}

for (const message of warnings) {
  console.error(`WARN ${message}`);
}

const warningSummary = warnings.length > 0 ? ` with ${warnings.length} warning(s)` : '';
console.log(`OK checked spec artifacts in ${relative(specsDir)}${warningSummary}`);
