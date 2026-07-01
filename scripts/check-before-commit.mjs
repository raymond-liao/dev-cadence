#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { defaultReportDirForSpecsDir, normalizeSpecsDir, resolveDefaultSpecsDir } from './specs-paths.mjs';

function printHelp() {
  console.log(`Usage: check-before-commit.mjs [options]

Checks Dev Cadence readiness before creating a Git commit.

Options:
  --task-id <id>       Task directory name under the specs directory. Use when
                       the commit candidate is part of a Dev Cadence workflow.
  --repo-dir <dir>     Target Git repository. Defaults to current working directory.
  --plugin-dir <dir>   dev-cadence plugin/source directory. Defaults to the
                       parent directory of this script.
  --specs-dir <dir>    Specs records directory. Defaults to <repo-dir>/specs/records,
                       or legacy <repo-dir>/specs when it already contains task dirs.
  --json               Print machine-readable JSON.
  -h, --help           Show this help text.

This command does not create commits and never creates specs. It treats the
dirty worktree as the commit candidate, regardless of staging state. It first
decides whether the candidate belongs to Dev Cadence workflow content. Outside
workflow candidates skip Dev Cadence gate checks. Dev Cadence contract/runtime
candidates validate the embedded runtime. Workflow candidates validate touched
spec artifacts, gates, Human acceptance, and any covered product paths. Use
--task-id when the candidate has product paths that are intentionally part of a
Dev Cadence task but the specs are not present in the dirty worktree.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const pluginDirDefault = path.resolve(path.join(import.meta.dirname, '..'));
  const options = {
    taskId: null,
    repoDir: process.cwd(),
    pluginDir: pluginDirDefault,
    specsDir: null,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--task-id') {
      options.taskId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--repo-dir') {
      options.repoDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--plugin-dir') {
      options.pluginDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--specs-dir') {
      options.specsDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  options.repoDir = path.resolve(options.repoDir);
  options.pluginDir = path.resolve(options.pluginDir);
  options.specsDir = options.specsDir
    ? normalizeSpecsDir(options.specsDir)
    : resolveDefaultSpecsDir(options.repoDir);
  if (options.taskId !== null) {
    validateId('task-id', options.taskId);
  }
  return options;
}

function readValue(argv, index, arg) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} requires a value`);
  }
  return value;
}

function validateId(label, value) {
  if (!value) {
    throw new Error(`Missing required --${label}`);
  }
  if (!/^[a-z0-9][a-z0-9._-]*$/.test(value)) {
    throw new Error(`Invalid ${label}: use lowercase letters, digits, dots, underscores, and hyphens only`);
  }
}

function run(command, args, cwd) {
  const result = spawnSync(command, args, { cwd, encoding: 'utf8' });
  return {
    command: [command, ...args].join(' '),
    status: result.status,
    stdout: result.stdout.trim(),
    stderr: result.stderr.trim(),
  };
}

function runBuffer(command, args, cwd) {
  const result = spawnSync(command, args, { cwd });
  return {
    command: [command, ...args].join(' '),
    status: result.status,
    stdout: result.stdout,
    stderr: result.stderr.toString('utf8').trim(),
  };
}

function gitStatus(repoDir) {
  const result = runBuffer('git', ['status', '--porcelain=v1', '-z', '--untracked-files=all'], repoDir);
  if (result.status !== 0) {
    throw new Error(`git status failed: ${result.stderr || result.stdout.toString('utf8')}`);
  }
  return parseStatusEntries(result.stdout);
}

function parseStatusEntries(output) {
  const entries = output.toString('utf8').split('\0').filter(Boolean);
  const result = [];
  for (let index = 0; index < entries.length; index += 1) {
    const entry = entries[index];
    const code = entry.slice(0, 2).padEnd(2, ' ');
    const filePath = entry.slice(3);
    if (!filePath) continue;
    if (code.startsWith('R') || code.startsWith('C')) {
      index += 1;
    }
    result.push({ code, path: filePath });
  }
  return result;
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

function cleanValue(value) {
  const trimmed = String(value).trim();
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
  const data = {};
  const lines = block.split('\n');
  let currentKey = null;

  for (const line of lines) {
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const keyValue = line.match(/^([A-Za-z0-9_-]+):(?:\s*(.*))?$/);
    if (keyValue) {
      currentKey = keyValue[1];
      const rawValue = keyValue[2] ?? '';
      data[currentKey] = rawValue.trim() === '' ? [] : cleanValue(rawValue);
      continue;
    }

    const listItem = line.match(/^\s+-\s+(.*)$/);
    if (listItem && currentKey) {
      if (!Array.isArray(data[currentKey])) {
        data[currentKey] = [];
      }
      data[currentKey].push(cleanValue(listItem[1]));
    }
  }

  return data;
}

function asList(value) {
  if (Array.isArray(value)) return value;
  if (value === null || value === undefined || value === '') return [];
  return [value];
}

function readArtifactYaml(filePath) {
  if (!fs.existsSync(filePath)) return {};
  return parseTopLevelYaml(firstYamlBlock(fs.readFileSync(filePath, 'utf8')));
}

function walkFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const result = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      result.push(...walkFiles(fullPath));
    } else if (entry.isFile()) {
      result.push(fullPath);
    }
  }
  return result;
}

function coverageEntries(taskDir, specsDir, repoDir) {
  const entries = new Set();
  const specFiles = [
    '03-tasks.md',
    '05-implementation.md',
  ];
  for (const file of specFiles) {
    addCoverageFromYaml(entries, readArtifactYaml(path.join(taskDir, file)));
  }

  const runsDir = path.join(taskDir, 'runs');
  for (const filePath of walkFiles(runsDir)) {
    if (!filePath.endsWith('.md')) continue;
    addCoverageFromYaml(entries, readArtifactYaml(filePath));
  }

  const taskArtifactRoot = path.relative(repoDir, taskDir).replaceAll(path.sep, '/');
  entries.add(taskArtifactRoot);
  entries.add(`${taskArtifactRoot}/**`);
  const reportDir = defaultReportDirForSpecsDir(specsDir);
  const taskReportRoot = path.relative(repoDir, path.join(reportDir, path.basename(taskDir))).replaceAll(path.sep, '/');
  const reportIndex = path.relative(repoDir, path.join(reportDir, 'index.html')).replaceAll(path.sep, '/');
  const reportAssets = path.relative(repoDir, path.join(reportDir, 'assets')).replaceAll(path.sep, '/');
  entries.add(taskReportRoot);
  entries.add(`${taskReportRoot}/**`);
  entries.add(reportIndex);
  entries.add(`${reportAssets}/**`);
  return [...entries].filter(Boolean);
}

function addCoverageFromYaml(entries, data) {
  const fields = [
    'target_files',
    'planned_files',
    'changed_files',
    'files_changed',
    'untracked_files',
    'created_artifact_files',
    'planned_artifact_files',
    'authorized_target_files',
    'authorized_artifact_files',
  ];
  for (const field of fields) {
    for (const value of asList(data[field])) {
      entries.add(normalizePath(String(value)));
    }
  }
}

function normalizePath(value) {
  return value.replaceAll('\\', '/').replace(/^\.\//, '');
}

function isCovered(filePath, entries) {
  const normalized = normalizePath(filePath);
  return entries.some((entry) => {
    const clean = normalizePath(entry);
    if (clean === normalized) return true;
    if (clean.endsWith('/**')) {
      return normalized.startsWith(clean.slice(0, -3));
    }
    if (clean.endsWith('/')) {
      return normalized.startsWith(clean);
    }
    return false;
  });
}

function isContractPath(filePath, options) {
  const normalized = normalizePath(filePath);
  const specsGitkeep = `${specsRel(options)}/.gitkeep`;
  const hasEmbeddedRuntime = fs.existsSync(path.join(options.repoDir, '.dev-cadence'));
  return (
    normalized === specsGitkeep
    || normalized.startsWith('.dev-cadence/')
    || (hasEmbeddedRuntime && (
      normalized === 'AGENTS.md'
      || normalized === '.gitignore'
      || normalized === '.dev-cadence.yaml'
    ))
  );
}

function specsRel(options) {
  return normalizePath(path.relative(options.repoDir, options.specsDir));
}

function isWorkflowSpecPath(filePath, options) {
  const normalized = normalizePath(filePath);
  const base = specsRel(options);
  if (normalized === `${base}/.gitkeep`) return false;
  return normalized.startsWith(`${base}/`);
}

function workflowSpecTaskIds(candidatePaths, options) {
  const base = specsRel(options);
  const result = new Set();
  for (const filePath of candidatePaths) {
    const normalized = normalizePath(filePath);
    if (!normalized.startsWith(`${base}/`)) continue;
    const rest = normalized.slice(base.length + 1);
    if (!rest || rest === '.gitkeep') continue;
    const taskId = rest.split('/')[0];
    if (taskId) {
      result.add(taskId);
    }
  }
  return [...result].sort();
}

function contractOnlyCheck(options) {
  const checks = [];
  checks.push(runChecker(
    path.join(options.pluginDir, 'scripts', 'check-skill-package.mjs'),
    [path.join(options.repoDir, '.dev-cadence')],
    options.repoDir,
  ));
  checks.push(runChecker(
    path.join(options.pluginDir, 'scripts', 'check-discipline-routes.mjs'),
    [path.join(options.repoDir, '.dev-cadence')],
    options.repoDir,
  ));
  checks.push(runChecker(
    path.join(options.pluginDir, 'scripts', 'check-spec-artifacts.mjs'),
    [path.join(options.repoDir, '.dev-cadence', 'templates')],
    options.repoDir,
  ));
  return checks;
}

function taskArtifactCheck(options, taskId) {
  return runChecker(
    path.join(options.pluginDir, 'scripts', 'check-spec-artifacts.mjs'),
    [path.join(options.specsDir, taskId), '--warnings-as-errors'],
    options.repoDir,
  );
}

function taskGateCheck(options, taskId) {
  return runChecker(
    path.join(options.pluginDir, 'scripts', 'check-gates.mjs'),
    ['--task-id', taskId, '--specs-dir', options.specsDir],
    options.repoDir,
  );
}

function taskChecks(options, taskId) {
  return [
    taskArtifactCheck(options, taskId),
    taskGateCheck(options, taskId),
  ];
}

function runChecker(scriptPath, args, cwd) {
  if (!fs.existsSync(scriptPath)) {
    throw new Error(`Required checker not found: ${scriptPath}`);
  }
  return run(process.execPath, [scriptPath, ...args], cwd);
}

function runAcceptanceSummary(options, taskId = options.taskId) {
  const scriptPath = path.join(options.pluginDir, 'scripts', 'summarize-acceptance.mjs');
  if (!fs.existsSync(scriptPath) || !taskId) return null;
  return runChecker(
    scriptPath,
    ['--task-id', taskId, '--specs-dir', options.specsDir, '--require-report'],
    options.repoDir,
  );
}

function check(options) {
  const dirty = gitStatus(options.repoDir);
  const candidatePaths = dirty.map((item) => item.path);
  const report = {
    repository: options.repoDir,
    task_id: options.taskId,
    specs_dir: options.specsDir,
    scope: 'product',
    candidate_paths: candidatePaths,
    status: 'passed',
    dirty_paths: dirty.map((item) => item.path),
    checks: [],
    uncovered_paths: [],
  };

  if (dirty.length === 0) {
    return report;
  }

  const contractPaths = candidatePaths.filter((filePath) => isContractPath(filePath, options));
  const workflowSpecPaths = candidatePaths.filter((filePath) => isWorkflowSpecPath(filePath, options));
  const outsidePaths = candidatePaths
    .filter((filePath) => !isContractPath(filePath, options) && !isWorkflowSpecPath(filePath, options));

  if (!options.taskId && candidatePaths.length > 0 && workflowSpecPaths.length === 0) {
    if (contractPaths.length > 0) {
      report.scope = outsidePaths.length > 0 ? 'mixed' : 'dev-cadence-contract';
      report.checks = contractOnlyCheck(options);
      report.skipped_gate_checks = outsidePaths.length > 0
        ? ['Outside Dev Cadence workflow paths are not checked by Dev Cadence gates.']
        : [];
    } else {
      report.scope = 'outside-dev-cadence';
      report.skipped_gate_checks = ['Commit candidate is outside Dev Cadence workflow; G1-G6 and Human Gate checks skipped.'];
    }
    const failed = report.checks.filter((checkResult) => checkResult.status !== 0);
    if (failed.length > 0) {
      report.status = 'failed';
      report.failures = ['Dev Cadence contract/runtime validation failed.'];
    }
    return report;
  }

  if (!options.taskId) {
    const taskIds = workflowSpecTaskIds(candidatePaths, options);
    report.workflow_task_ids = taskIds;
    report.scope = outsidePaths.length > 0 || contractPaths.length > 0 ? 'mixed' : 'dev-cadence-workflow';
    report.checks = [
      ...taskIds.flatMap((taskId) => taskChecks(options, taskId)),
      ...(contractPaths.length > 0 ? contractOnlyCheck(options) : []),
    ];
    const coverage = new Set();
    for (const taskId of taskIds) {
      for (const entry of coverageEntries(path.join(options.specsDir, taskId), options.specsDir, options.repoDir)) {
        coverage.add(entry);
      }
    }
    report.coverage_entries = [...coverage].filter(Boolean);
    report.uncovered_paths = outsidePaths.filter((filePath) => !isCovered(filePath, report.coverage_entries));
    if (taskIds.length === 0) {
      report.failures = ['Commit candidate contains Dev Cadence workflow paths, but no task directories were found.'];
    }
    const failed = report.checks.filter((checkResult) => checkResult.status !== 0);
    if (failed.length > 0 || report.uncovered_paths.length > 0 || (report.failures || []).length > 0) {
      report.status = 'failed';
      report.failures = report.failures || [];
      if (failed.some((checkResult) => checkResult.command.includes('check-spec-artifacts.mjs'))) {
        report.failures.push('Spec artifact validation failed.');
      }
      if (failed.some((checkResult) => checkResult.command.includes('check-gates.mjs'))) {
        report.failures.push('Quality Gate or Human Gate validation failed. Commit is blocked until G6 final Human acceptance is recorded.');
        report.acceptance_summaries = taskIds
          .map((taskId) => {
            const summary = runAcceptanceSummary(options, taskId);
            return summary && summary.stdout ? { task_id: taskId, summary: summary.stdout } : null;
          })
          .filter(Boolean);
      }
      if (failed.some((checkResult) => !checkResult.command.includes('check-spec-artifacts.mjs') && !checkResult.command.includes('check-gates.mjs'))) {
        report.failures.push('Dev Cadence contract/runtime validation failed.');
      }
      if (report.uncovered_paths.length > 0) {
        report.failures.push('Commit candidate paths are not covered by workflow task artifacts.');
      }
    }
    return report;
  }

  report.scope = 'dev-cadence-workflow';
  const taskDir = path.join(options.specsDir, options.taskId);
  if (!fs.existsSync(taskDir)) {
    report.status = 'failed';
    report.failures = [`Task artifacts not found: ${taskDir}`];
    return report;
  }

  const artifactCheck = runChecker(
    path.join(options.pluginDir, 'scripts', 'check-spec-artifacts.mjs'),
    [path.join(options.specsDir, options.taskId), '--warnings-as-errors'],
    options.repoDir,
  );
  report.checks.push(artifactCheck);

  const gateArgs = ['--task-id', options.taskId, '--specs-dir', options.specsDir];
  const gateCheck = runChecker(
    path.join(options.pluginDir, 'scripts', 'check-gates.mjs'),
    gateArgs,
    options.repoDir,
  );
  report.checks.push(gateCheck);

  const covered = coverageEntries(taskDir, options.specsDir, options.repoDir);
  report.coverage_entries = covered;
  report.uncovered_paths = candidatePaths.filter((filePath) => !isCovered(filePath, covered));

  if (
    artifactCheck.status !== 0
    || gateCheck.status !== 0
    || report.uncovered_paths.length > 0
  ) {
    report.status = 'failed';
    report.failures = [];
    if (artifactCheck.status !== 0) {
      report.failures.push('Spec artifact validation failed.');
    }
    if (gateCheck.status !== 0) {
      report.failures.push('Quality Gate or Human Gate validation failed. Commit is blocked until G6 final Human acceptance is recorded.');
      const acceptanceSummary = runAcceptanceSummary(options);
      if (acceptanceSummary && acceptanceSummary.stdout) {
        report.acceptance_summary = acceptanceSummary.stdout;
      }
    }
    if (report.uncovered_paths.length > 0) {
      report.failures.push('Dirty paths are not covered by selected task artifacts.');
    }
  }

  return report;
}

function printText(report) {
  console.log(`Repository: ${report.repository}`);
  console.log(`Task: ${report.task_id || 'not supplied'}`);
  if (report.workflow_task_ids && report.workflow_task_ids.length > 0) {
    console.log(`Workflow tasks: ${report.workflow_task_ids.join(', ')}`);
  }
  console.log(`Scope: ${report.scope || 'product'}`);
  console.log(`Commit readiness: ${report.status}`);
  if (report.dirty_paths.length === 0) {
    console.log('Dirty paths: none');
  } else {
    console.log('Dirty paths:');
    for (const filePath of report.dirty_paths) {
      console.log(`- ${filePath}`);
    }
  }
  if (report.candidate_paths && report.candidate_paths.length > 0) {
    console.log('Commit candidate paths:');
    for (const filePath of report.candidate_paths) {
      console.log(`- ${filePath}`);
    }
  }
  for (const check of report.checks || []) {
    console.log(`${check.status === 0 ? 'pass' : 'fail'}: ${check.command}`);
    if (check.status !== 0) {
      printCheckDetails(check);
    }
  }
  if (report.uncovered_paths && report.uncovered_paths.length > 0) {
    console.error('Uncovered dirty paths:');
    for (const filePath of report.uncovered_paths) {
      console.error(`- ${filePath}`);
    }
  }
  for (const skipped of report.skipped_gate_checks || []) {
    console.log(`SKIP ${skipped}`);
  }
  for (const failure of report.failures || []) {
    console.error(`FAIL ${failure}`);
  }
  if (report.acceptance_summary) {
    console.error('\nHuman acceptance summary:');
    console.error(report.acceptance_summary);
  }
  for (const acceptanceSummary of report.acceptance_summaries || []) {
    console.error(`\nHuman acceptance summary (${acceptanceSummary.task_id}):`);
    console.error(acceptanceSummary.summary);
  }
}

function printCheckDetails(check) {
  const lines = [check.stdout, check.stderr]
    .filter(Boolean)
    .join('\n')
    .split('\n')
    .map((line) => line.trimEnd())
    .filter((line) => /^(FAIL|WARN|ERROR)\b|^Gate status:|^G[1-6]:/.test(line));

  for (const line of lines) {
    console.error(`  ${line}`);
  }
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = check(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printText(report);
  }
  if (report.status !== 'passed') {
    process.exit(1);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
