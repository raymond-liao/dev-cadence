#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AGENTS_SECTION, EMBEDDED_RUNTIME_DIR, LOCAL_YAML, TARGET_BUNDLE_RUNTIME_PATHS } from './target-repo-contract.mjs';

const DEFAULT_OUTPUT = path.join('dist', 'target-repo');
const TARGET_BUNDLE_EXCLUDED_PATHS = [
  'references/source-maintenance',
];

function printHelp() {
  console.log(`Usage: package-target-repo-bundle.mjs [options]

Builds the repo-embedded Dev Cadence bundle for target repositories.

Options:
  --source-dir <dir>    Source repository directory. Defaults to current working directory.
  --output-dir <dir>    Bundle output directory. Defaults to ${DEFAULT_OUTPUT}.
  --clean               Remove output directory before packaging.
  --json                Print machine-readable JSON report.
  -h, --help            Show this help text.

The bundle creates .dev-cadence/ with runtime skills, references, templates,
scripts, VERSION, and manifest.json. It also writes root-level helper files
AGENTS.dev-cadence-section.md and .dev-cadence.yaml for sync tooling.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    sourceDir: process.cwd(),
    outputDir: DEFAULT_OUTPUT,
    clean: false,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--source-dir') {
      options.sourceDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--output-dir') {
      options.outputDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--clean') {
      options.clean = true;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  options.sourceDir = path.resolve(options.sourceDir);
  options.outputDir = path.resolve(options.outputDir);
  return options;
}

function readValue(argv, index, arg) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} requires a value`);
  }
  return value;
}

function rel(baseDir, filePath) {
  return path.relative(baseDir, filePath) || '.';
}

function ensureInsideOutputBoundary(sourceDir, outputDir) {
  const outputRelativeToSource = path.relative(sourceDir, outputDir);
  const outputInsideSource =
    outputRelativeToSource === '' ||
    (!outputRelativeToSource.startsWith('..') && !path.isAbsolute(outputRelativeToSource));

  if (outputInsideSource) {
    if (outputRelativeToSource === '') {
      throw new Error('Refusing to package into the source repository root');
    }
    if (!outputRelativeToSource.split(path.sep).includes('dist')) {
      throw new Error('Refusing to package inside source tree outside dist/');
    }
  }

  const sourceRelativeToOutput = path.relative(outputDir, sourceDir);
  const outputContainsSource =
    sourceRelativeToOutput !== '' &&
    !sourceRelativeToOutput.startsWith('..') &&
    !path.isAbsolute(sourceRelativeToOutput);
  if (outputContainsSource) {
    throw new Error('Refusing to package into a directory that contains the source repository');
  }
}

function shouldExcludeFromTargetBundle(sourceDir, sourcePath) {
  const relativePath = rel(sourceDir, sourcePath).replaceAll(path.sep, '/');
  return TARGET_BUNDLE_EXCLUDED_PATHS.some((excludedPath) => (
    relativePath === excludedPath || relativePath.startsWith(`${excludedPath}/`)
  ));
}

function transformTargetRuntimeFile(sourceDir, sourcePath, content) {
  const relativePath = rel(sourceDir, sourcePath).replaceAll(path.sep, '/');
  if (relativePath !== 'references/delivery-disciplines.md') {
    return content;
  }

  return content
    .toString('utf8')
    .replace(/\n\| Dev Cadence source maintenance in this repository \|[^\n]+\n/, '\n');
}

function copyRecursive(sourcePath, targetPath, copied, baseDir, sourceDir) {
  if (shouldExcludeFromTargetBundle(sourceDir, sourcePath)) {
    return;
  }
  const stat = fs.statSync(sourcePath);
  if (stat.isDirectory()) {
    fs.mkdirSync(targetPath, { recursive: true });
    for (const entry of fs.readdirSync(sourcePath, { withFileTypes: true })) {
      if (entry.name === '.DS_Store') continue;
      copyRecursive(path.join(sourcePath, entry.name), path.join(targetPath, entry.name), copied, baseDir, sourceDir);
    }
    return;
  }
  if (stat.isFile()) {
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.writeFileSync(targetPath, transformTargetRuntimeFile(sourceDir, sourcePath, fs.readFileSync(sourcePath)));
    fs.chmodSync(targetPath, stat.mode);
    copied.push(rel(baseDir, targetPath));
  }
}

function readManifest(sourceDir) {
  const manifestPath = path.join(sourceDir, '.codex-plugin', 'plugin.json');
  return JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
}

function runCheck(command, args, cwd) {
  const result = spawnSync(command, args, { cwd, encoding: 'utf8' });
  return {
    command: [command, ...args].join(' '),
    status: result.status,
    stdout: result.stdout.trim(),
    stderr: result.stderr.trim(),
  };
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const manifest = readManifest(options.sourceDir);
  const runtimeDir = path.join(options.outputDir, EMBEDDED_RUNTIME_DIR);
  const copied = [];
  const missing = [];

  ensureInsideOutputBoundary(options.sourceDir, options.outputDir);

  if (options.clean) {
    fs.rmSync(options.outputDir, { recursive: true, force: true });
  }
  fs.mkdirSync(options.outputDir, { recursive: true });
  fs.rmSync(runtimeDir, { recursive: true, force: true });

  for (const item of TARGET_BUNDLE_RUNTIME_PATHS) {
    const sourcePath = path.join(options.sourceDir, item);
    if (!fs.existsSync(sourcePath)) {
      missing.push(item);
      continue;
    }
    copyRecursive(sourcePath, path.join(runtimeDir, item), copied, options.outputDir, options.sourceDir);
  }

  fs.writeFileSync(path.join(runtimeDir, 'VERSION'), `${manifest.version}\n`);
  fs.writeFileSync(
    path.join(runtimeDir, 'manifest.json'),
    `${JSON.stringify({
      name: manifest.name,
      version: manifest.version,
      source: 'dev-cadence target-repo bundle',
      entrypoint: 'skills/using-dev-cadence/SKILL.md',
      runtime_paths: TARGET_BUNDLE_RUNTIME_PATHS,
      local_config: '../.dev-cadence.yaml',
      source_only_excluded_paths: TARGET_BUNDLE_EXCLUDED_PATHS,
    }, null, 2)}\n`,
  );
  fs.writeFileSync(path.join(options.outputDir, 'AGENTS.dev-cadence-section.md'), AGENTS_SECTION);
  fs.writeFileSync(path.join(options.outputDir, '.dev-cadence.yaml'), LOCAL_YAML);

  const generated = [
    path.join(EMBEDDED_RUNTIME_DIR, 'VERSION'),
    path.join(EMBEDDED_RUNTIME_DIR, 'manifest.json'),
    'AGENTS.dev-cadence-section.md',
    '.dev-cadence.yaml',
  ];
  copied.push(...generated);

  const checks = [
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-skill-package.mjs'), runtimeDir], options.sourceDir),
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-discipline-routes.mjs'), runtimeDir], options.sourceDir),
    runCheck(process.execPath, [path.join(runtimeDir, 'scripts', 'check-spec-artifacts.mjs'), path.join(runtimeDir, 'templates')], options.sourceDir),
  ];
  const failedChecks = checks.filter((check) => check.status !== 0);

  const report = {
    source_dir: options.sourceDir,
    output_dir: options.outputDir,
    runtime_dir: runtimeDir,
    clean: options.clean,
    runtime_paths: TARGET_BUNDLE_RUNTIME_PATHS,
    source_only_excluded_paths: TARGET_BUNDLE_EXCLUDED_PATHS,
    files_copied: copied.sort(),
    missing_paths: missing,
    checks,
  };

  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`Target repo bundle: ${options.outputDir}`);
    console.log(`Runtime: ${runtimeDir}`);
    console.log(`Files copied: ${report.files_copied.length}`);
    for (const check of checks) {
      console.log(`${check.status === 0 ? 'pass' : 'fail'}: ${check.command}`);
    }
  }

  if (missing.length > 0 || failedChecks.length > 0) {
    process.exit(1);
  }
}

try {
  main();
} catch (error) {
  console.error(`ERROR ${error.message}`);
  process.exit(1);
}
