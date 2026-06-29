#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { RECORDS_DIR, SPECS_ROOT_DIR } from './specs-paths.mjs';
import { EMBEDDED_RUNTIME_DIR, LOCAL_YAML, START_MARKER, END_MARKER, updateAgentsContent } from './target-repo-contract.mjs';

const DEFAULT_BUNDLE_DIR = path.join('dist', 'target-repo');

function printHelp() {
  console.log(`Usage: sync-target-repo-bundle.mjs --target <repo-dir> [options]

Syncs a repo-embedded Dev Cadence bundle into a target repository.

Options:
  --target <dir>      Target repository directory.
  --bundle-dir <dir>  Bundle directory. Defaults to ${DEFAULT_BUNDLE_DIR}.
  --dry-run           Report planned writes without changing files.
  --json              Print machine-readable JSON report.
  -h, --help          Show this help text.

Writes are limited to .dev-cadence/, root AGENTS.md, root .gitignore,
root .dev-cadence.yaml when missing, and specs/records/.gitkeep.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    targetDir: null,
    bundleDir: DEFAULT_BUNDLE_DIR,
    dryRun: false,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--target') {
      options.targetDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--bundle-dir') {
      options.bundleDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--dry-run') {
      options.dryRun = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  if (!options.targetDir) {
    throw new Error('--target is required');
  }

  options.targetDir = path.resolve(options.targetDir);
  options.bundleDir = path.resolve(options.bundleDir);
  return options;
}

function readValue(argv, index, arg) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} requires a value`);
  }
  return value;
}

function rel(repoDir, filePath) {
  return path.relative(repoDir, filePath) || '.';
}

function readIfExists(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : null;
}

function ensureParent(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function createReport(options) {
  return {
    target_dir: options.targetDir,
    bundle_dir: options.bundleDir,
    dry_run: options.dryRun,
    metadata: {
      runtime_dir: EMBEDDED_RUNTIME_DIR,
      start_marker: START_MARKER,
      end_marker: END_MARKER,
    },
    files_added: [],
    files_updated: [],
    files_preserved: [],
    files_removed: [],
    conflicts: [],
    manual_review_required: [],
    verification: [],
  };
}

function record(report, field, repoDir, filePath) {
  const value = rel(repoDir, filePath);
  if (!report[field].includes(value)) {
    report[field].push(value);
  }
}

function writeFileIfNeeded(options, report, filePath, content) {
  const current = fs.existsSync(filePath) ? fs.readFileSync(filePath) : null;
  const next = Buffer.isBuffer(content) ? content : Buffer.from(content);

  if (current && Buffer.compare(current, next) === 0) {
    record(report, 'files_preserved', options.targetDir, filePath);
    return;
  }

  if (current === null) {
    record(report, 'files_added', options.targetDir, filePath);
  } else {
    record(report, 'files_updated', options.targetDir, filePath);
  }

  if (!options.dryRun) {
    ensureParent(filePath);
    fs.writeFileSync(filePath, next);
  }
}

function copyRecursive(options, report, sourcePath, targetPath) {
  const stat = fs.statSync(sourcePath);
  if (stat.isDirectory()) {
    if (!options.dryRun) {
      fs.mkdirSync(targetPath, { recursive: true });
    }
    for (const entry of fs.readdirSync(sourcePath, { withFileTypes: true })) {
      copyRecursive(options, report, path.join(sourcePath, entry.name), path.join(targetPath, entry.name));
    }
    return;
  }
  if (stat.isFile()) {
    writeFileIfNeeded(options, report, targetPath, fs.readFileSync(sourcePath));
    if (!options.dryRun) {
      fs.chmodSync(targetPath, stat.mode);
    }
  }
}

function listRelativeFiles(dir) {
  const files = [];
  if (!fs.existsSync(dir)) return files;
  function walk(current) {
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const fullPath = path.join(current, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile()) {
        files.push(path.relative(dir, fullPath));
      }
    }
  }
  walk(dir);
  return files;
}

function removeStaleRuntimeFiles(options, report, bundleRuntimeDir, targetRuntimeDir) {
  const bundleFiles = new Set(listRelativeFiles(bundleRuntimeDir));
  for (const relativeFile of listRelativeFiles(targetRuntimeDir)) {
    if (bundleFiles.has(relativeFile)) continue;
    const targetPath = path.join(targetRuntimeDir, relativeFile);
    record(report, 'files_removed', options.targetDir, targetPath);
    if (!options.dryRun) {
      fs.rmSync(targetPath);
    }
  }
}

function reconcileAgents(options, report) {
  const agentsPath = path.join(options.targetDir, 'AGENTS.md');
  const next = updateAgentsContent(readIfExists(agentsPath));

  if (next === null) {
    report.conflicts.push('AGENTS.md has only one Dev Cadence marker');
    report.manual_review_required.push('Repair AGENTS.md marker pair before automatic sync');
    return false;
  }

  writeFileIfNeeded(options, report, agentsPath, next);
  return true;
}

function reconcileGitignore(options, report) {
  const gitignorePath = path.join(options.targetDir, '.gitignore');
  const existing = readIfExists(gitignorePath);
  const lines = existing ? existing.split(/\r?\n/) : [];
  const hasEntry = lines.some((line) => line.trim() === '.dev-cadence.yaml');

  if (hasEntry) {
    record(report, 'files_preserved', options.targetDir, gitignorePath);
    return;
  }

  const base = existing === null ? '' : existing.trimEnd();
  writeFileIfNeeded(options, report, gitignorePath, `${base}${base ? '\n' : ''}.dev-cadence.yaml\n`);
}

function reconcileLocalYaml(options, report) {
  const localPath = path.join(options.targetDir, '.dev-cadence.yaml');
  if (fs.existsSync(localPath)) {
    record(report, 'files_preserved', options.targetDir, localPath);
    return;
  }
  writeFileIfNeeded(options, report, localPath, LOCAL_YAML);
}

function reconcileGitkeep(options, report) {
  const gitkeepPath = path.join(options.targetDir, SPECS_ROOT_DIR, RECORDS_DIR, '.gitkeep');
  if (fs.existsSync(gitkeepPath)) {
    record(report, 'files_preserved', options.targetDir, gitkeepPath);
    return;
  }
  writeFileIfNeeded(options, report, gitkeepPath, '');
}

function verify(options, report) {
  const agents = readIfExists(path.join(options.targetDir, 'AGENTS.md')) || '';
  const gitignore = readIfExists(path.join(options.targetDir, '.gitignore')) || '';
  const runtimeDir = path.join(options.targetDir, EMBEDDED_RUNTIME_DIR);

  report.verification.push({
    check: 'AGENTS.md requires repo-embedded Dev Cadence entrypoint',
    status: agents.includes(`${EMBEDDED_RUNTIME_DIR}/skills/using-dev-cadence/SKILL.md`) ? 'pass' : 'missing',
  });
  report.verification.push({
    check: '.dev-cadence runtime exists',
    status: fs.existsSync(path.join(runtimeDir, 'manifest.json')) &&
      fs.existsSync(path.join(runtimeDir, 'skills', 'using-dev-cadence', 'SKILL.md')) ? 'pass' : 'missing',
  });
  report.verification.push({
    check: '.dev-cadence.yaml exists and is ignored',
    status: fs.existsSync(path.join(options.targetDir, '.dev-cadence.yaml')) &&
      gitignore.split(/\r?\n/).some((line) => line.trim() === '.dev-cadence.yaml') ? 'pass' : 'missing',
  });
  report.verification.push({
    check: 'specs/records exists',
    status: fs.existsSync(path.join(options.targetDir, SPECS_ROOT_DIR, RECORDS_DIR)) ? 'pass' : 'missing',
  });
}

function sync(options) {
  if (!fs.existsSync(options.targetDir) || !fs.statSync(options.targetDir).isDirectory()) {
    throw new Error(`Target repository directory not found: ${options.targetDir}`);
  }

  const bundleRuntimeDir = path.join(options.bundleDir, EMBEDDED_RUNTIME_DIR);
  if (!fs.existsSync(bundleRuntimeDir) || !fs.statSync(bundleRuntimeDir).isDirectory()) {
    throw new Error(`Bundle runtime directory not found: ${bundleRuntimeDir}`);
  }

  const report = createReport(options);
  const targetRuntimeDir = path.join(options.targetDir, EMBEDDED_RUNTIME_DIR);

  if (!options.dryRun) {
    fs.mkdirSync(targetRuntimeDir, { recursive: true });
  }
  copyRecursive(options, report, bundleRuntimeDir, targetRuntimeDir);
  removeStaleRuntimeFiles(options, report, bundleRuntimeDir, targetRuntimeDir);

  if (reconcileAgents(options, report)) {
    reconcileGitignore(options, report);
    reconcileLocalYaml(options, report);
    reconcileGitkeep(options, report);
  }
  verify(options, report);
  return report;
}

function printReport(report) {
  console.log(`Target: ${report.target_dir}`);
  console.log(`Bundle: ${report.bundle_dir}${report.dry_run ? ' (dry-run)' : ''}`);
  for (const field of ['files_added', 'files_updated', 'files_preserved', 'files_removed', 'conflicts', 'manual_review_required']) {
    const values = report[field];
    if (!values || values.length === 0) continue;
    console.log(`\n${field}:`);
    for (const value of values) {
      console.log(`- ${value}`);
    }
  }
  console.log('\nverification:');
  for (const item of report.verification) {
    console.log(`- ${item.status}: ${item.check}`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = sync(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printReport(report);
  }
  if (report.conflicts.length > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  process.exit(2);
}
