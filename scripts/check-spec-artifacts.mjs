#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { findNearestConfig, parseArtifactLanguage } from './artifact-language.mjs';

function printHelp() {
  console.log(`Usage: check-spec-artifacts.mjs [specs-dir]

Validates Dev Cadence task artifacts for basic YAML-like consistency.

Arguments:
  specs-dir  Specs directory to check. Defaults to specs in the current working
             directory.

Options:
  --warnings-as-errors
             Treat warnings, including artifact_language prose warnings, as
             failures.
  -h, --help Show this help text.

Checks:
  - fenced yaml blocks do not contain duplicate keys at the same indentation
    path
  - S1/S2 implementation or fix artifacts include a pre-implementation
    baseline before product edits can be treated as normally verified
  - diff summaries explicitly account for tracked and untracked files
  - when .dev-cadence.yaml sets artifact_language: zh, Markdown prose that
    appears to be English-only is reported as a warning`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    specsDir: 'specs',
    warningsAsErrors: false,
  };

  for (const arg of argv) {
    if (arg === '--warnings-as-errors') {
      options.warningsAsErrors = true;
    } else if (arg.startsWith('--')) {
      throw new Error(`Unknown option: ${arg}`);
    } else {
      options.specsDir = arg;
    }
  }

  options.specsDir = path.resolve(options.specsDir);
  return options;
}

let options;
try {
  options = parseArgs(process.argv.slice(2));
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}

const specsDir = options.specsDir;
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

function firstYamlBlock(text) {
  return yamlBlocks(text)[0] || '';
}

function parseScalar(value) {
  const trimmed = value.trim();
  if (trimmed === '') return '';
  if (trimmed === '[]') return [];
  if (trimmed === 'null') return null;
  if (trimmed === 'true') return true;
  if (trimmed === 'false') return false;
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"'))
    || (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

function parseTopLevelYaml(block) {
  const result = {};
  const lines = block.split('\n');
  let currentKey = null;

  for (const line of lines) {
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const keyMatch = line.match(/^([A-Za-z0-9_-]+):(?:\s*(.*))?$/);
    if (keyMatch) {
      currentKey = keyMatch[1];
      const rawValue = keyMatch[2] ?? '';
      result[currentKey] = rawValue.trim() === '' ? [] : parseScalar(rawValue);
      continue;
    }

    const listMatch = line.match(/^\s+-\s+(.*)$/);
    if (listMatch && currentKey) {
      if (!Array.isArray(result[currentKey])) {
        result[currentKey] = [];
      }
      result[currentKey].push(parseScalar(listMatch[1]));
    }
  }

  return result;
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

function taskDirectories(rootDir) {
  const directories = [];
  if (fs.existsSync(path.join(rootDir, '00-brief.md'))) {
    directories.push(rootDir);
  }
  const entries = fs.readdirSync(rootDir, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const taskDir = path.join(rootDir, entry.name);
    if (fs.existsSync(path.join(taskDir, '00-brief.md'))) {
      directories.push(taskDir);
    }
  }
  return directories;
}

function readArtifactYaml(filePath) {
  if (!fs.existsSync(filePath)) return null;
  return parseTopLevelYaml(firstYamlBlock(fs.readFileSync(filePath, 'utf8')));
}

function normalizeList(value) {
  if (Array.isArray(value)) return value;
  if (value === null || value === undefined || value === '') return [];
  return [value];
}

function taskClassFor(taskDir) {
  const tasks = readArtifactYaml(path.join(taskDir, '03-tasks.md')) || {};
  const brief = readArtifactYaml(path.join(taskDir, '00-brief.md')) || {};
  return String(tasks.task_class || brief.task_class || '').trim();
}

function selectedWorkflowFor(taskDir) {
  const tasks = readArtifactYaml(path.join(taskDir, '03-tasks.md')) || {};
  const brief = readArtifactYaml(path.join(taskDir, '00-brief.md')) || {};
  return String(tasks.selected_workflow || brief.selected_workflow || '').trim();
}

function hasImplementationEvidence(taskDir) {
  const implementation = readArtifactYaml(path.join(taskDir, '05-implementation.md'));
  if (!implementation) return false;
  const status = String(implementation.status || '').toLowerCase();
  const changedFiles = normalizeList(implementation.changed_files);
  return status.includes('implement') || changedFiles.length > 0;
}

function hasProductChangedFiles(taskDir) {
  const implementation = readArtifactYaml(path.join(taskDir, '05-implementation.md'));
  if (!implementation) return false;
  return normalizeList(implementation.changed_files).length > 0;
}

function runDirectories(taskDir) {
  const runsDir = path.join(taskDir, 'runs');
  if (!fs.existsSync(runsDir)) return [];
  return fs.readdirSync(runsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => path.join(runsDir, entry.name));
}

function checkPreImplementationBaseline(taskDir) {
  const taskClass = taskClassFor(taskDir);
  const workflow = selectedWorkflowFor(taskDir);
  if (!['S1', 'S2'].includes(taskClass)) return;
  if (workflow === 'incident-fix') return;
  if (!hasImplementationEvidence(taskDir)) return;
  const requiresProductAuthorization = hasProductChangedFiles(taskDir);

  const runs = runDirectories(taskDir);
  if (runs.length === 0) {
    fail(`${relative(taskDir)}: S1/S2 implementation evidence requires runs/{run_id}/pre-implementation-status.md`);
    return;
  }

  let foundBaseline = false;
  for (const runDir of runs) {
    const baselinePath = path.join(runDir, 'pre-implementation-status.md');
    if (!fs.existsSync(baselinePath)) continue;
    foundBaseline = true;
    const baseline = readArtifactYaml(baselinePath) || {};
    if (baseline.post_hoc_backfill === true || String(baseline.post_hoc_backfill).toLowerCase() === 'true') {
      const overrideBy = String(baseline.post_hoc_human_override_by || '').trim();
      if (!overrideBy) {
        fail(`${relative(baselinePath)}: post_hoc_backfill requires post_hoc_human_override_by; normal G4/G5 cannot pass`);
      }
    }
    if (
      requiresProductAuthorization
      && baseline.implementation_authorized !== true
      && String(baseline.implementation_authorized).toLowerCase() !== 'true'
    ) {
      fail(`${relative(baselinePath)}: implementation_authorized must be true before S1/S2 product edits`);
    }
  }

  if (!foundBaseline) {
    fail(`${relative(taskDir)}: S1/S2 implementation evidence requires runs/{run_id}/pre-implementation-status.md`);
  }
}

function checkDiffSummaries(taskDir) {
  for (const runDir of runDirectories(taskDir)) {
    const diffPath = path.join(runDir, 'diff-summary.md');
    if (!fs.existsSync(diffPath)) continue;
    const diff = readArtifactYaml(diffPath) || {};
    const hasFilesChanged = Object.hasOwn(diff, 'files_changed');
    const hasUntrackedFiles = Object.hasOwn(diff, 'untracked_files');
    if (hasFilesChanged && !hasUntrackedFiles) {
      fail(`${relative(diffPath)}: diff summary must include untracked_files, even when []`);
    }
  }
}

function checkTaskArtifacts(rootDir) {
  for (const taskDir of taskDirectories(rootDir)) {
    checkPreImplementationBaseline(taskDir);
    checkDiffSummaries(taskDir);
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

checkTaskArtifacts(specsDir);

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

if (options.warningsAsErrors && warnings.length > 0) {
  console.error(`\n${warnings.length} warning(s) treated as failure`);
  process.exit(1);
}

const warningSummary = warnings.length > 0 ? ` with ${warnings.length} warning(s)` : '';
console.log(`OK checked spec artifacts in ${relative(specsDir)}${warningSummary}`);
