#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const PLUGIN_NAME = 'dev-cadence';
const MARKETPLACE_NAME = 'dev-cadence-local';
const DEFAULT_OUTPUT = path.join('dist', 'codex');
const INCLUDED_PATHS = [
  '.codex-plugin',
  'skills',
  'references',
  'templates',
  'scripts',
];
const OPTIONAL_INCLUDED_PATHS = [
  'assets',
  '.mcp.json',
  '.app.json',
];

function printHelp() {
  console.log(`Usage: package-codex-plugin.mjs [options]

Builds the Codex Plugin publishing package for dev-cadence.

Options:
  --source-dir <dir>    Source repository directory. Defaults to current working directory.
  --output-dir <dir>    Marketplace root output directory. Defaults to ${DEFAULT_OUTPUT}.
  --clean               Remove output directory before packaging.
  --json                Print machine-readable JSON report.
  -h, --help            Show this help text.

The package creates .agents/plugins/marketplace.json and plugins/dev-cadence/.
The plugin payload includes .codex-plugin/, skills/, references/, templates/,
scripts/, and optional assets/, .mcp.json, and .app.json. It excludes repository
docs, hooks, tests, specs, research, Git metadata, and local development files.`);
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

function writeMarketplace(outputDir) {
  const marketplaceDir = path.join(outputDir, '.agents', 'plugins');
  const marketplaceFile = path.join(marketplaceDir, 'marketplace.json');
  const legacyMarketplaceFile = path.join(outputDir, 'marketplace.json');
  const marketplace = {
    name: MARKETPLACE_NAME,
    interface: {
      displayName: 'Dev Cadence Local',
    },
    plugins: [
      {
        name: PLUGIN_NAME,
        source: {
          source: 'local',
          path: `./plugins/${PLUGIN_NAME}`,
        },
        policy: {
          installation: 'AVAILABLE',
          authentication: 'ON_INSTALL',
        },
        category: 'Coding',
      },
    ],
  };

  if (fs.existsSync(legacyMarketplaceFile)) {
    const stat = fs.lstatSync(legacyMarketplaceFile);
    if (!stat.isFile() && !stat.isSymbolicLink()) {
      throw new Error('Refusing to replace legacy marketplace.json because it is not a file');
    }
    fs.rmSync(legacyMarketplaceFile);
  }

  fs.mkdirSync(marketplaceDir, { recursive: true });
  fs.writeFileSync(
    marketplaceFile,
    `${JSON.stringify(marketplace, null, 2)}\n`,
  );
  return marketplaceFile;
}

function copyRecursive(sourcePath, targetPath, copied) {
  const stat = fs.statSync(sourcePath);
  if (stat.isDirectory()) {
    fs.mkdirSync(targetPath, { recursive: true });
    for (const entry of fs.readdirSync(sourcePath, { withFileTypes: true })) {
      if (entry.name === '.DS_Store') continue;
      copyRecursive(path.join(sourcePath, entry.name), path.join(targetPath, entry.name), copied);
    }
    return;
  }
  if (stat.isFile()) {
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.copyFileSync(sourcePath, targetPath);
    fs.chmodSync(targetPath, stat.mode);
    copied.push(targetPath);
  }
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
  const copied = [];
  const missing = [];
  const pluginDir = path.join(options.outputDir, 'plugins', PLUGIN_NAME);

  ensureInsideOutputBoundary(options.sourceDir, options.outputDir);

  if (options.clean) {
    fs.rmSync(options.outputDir, { recursive: true, force: true });
  }
  fs.mkdirSync(options.outputDir, { recursive: true });
  fs.rmSync(pluginDir, { recursive: true, force: true });
  const marketplaceFile = writeMarketplace(options.outputDir);

  for (const item of INCLUDED_PATHS) {
    const sourcePath = path.join(options.sourceDir, item);
    if (!fs.existsSync(sourcePath)) {
      missing.push(item);
      continue;
    }
    copyRecursive(sourcePath, path.join(pluginDir, item), copied);
  }
  for (const item of OPTIONAL_INCLUDED_PATHS) {
    const sourcePath = path.join(options.sourceDir, item);
    if (fs.existsSync(sourcePath)) {
      copyRecursive(sourcePath, path.join(pluginDir, item), copied);
    }
  }

  const checks = [
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-skill-package.mjs'), pluginDir], options.sourceDir),
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-discipline-routes.mjs'), pluginDir], options.sourceDir),
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-spec-artifacts.mjs'), path.join(pluginDir, 'templates')], options.sourceDir),
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-gates.mjs'), '--help'], options.sourceDir),
    runCheck(process.execPath, [path.join(options.sourceDir, 'scripts', 'check-before-commit.mjs'), '--help'], options.sourceDir),
  ];

  const failedChecks = checks.filter((check) => check.status !== 0);
  const report = {
    source_dir: options.sourceDir,
    output_dir: options.outputDir,
    marketplace_file: marketplaceFile,
    marketplace_name: MARKETPLACE_NAME,
    plugin_dir: pluginDir,
    plugin_name: PLUGIN_NAME,
    clean: options.clean,
    included_paths: INCLUDED_PATHS,
    optional_included_paths: OPTIONAL_INCLUDED_PATHS,
    files_copied: copied.map((filePath) => rel(pluginDir, filePath)).sort(),
    missing_paths: missing,
    checks,
  };

  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`Marketplace package: ${options.outputDir}`);
    console.log(`Plugin: ${pluginDir}`);
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
