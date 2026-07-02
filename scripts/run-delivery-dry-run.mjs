#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { resolveArtifactLanguage } from './artifact-language.mjs';
import { defaultRecordsDir } from './specs-paths.mjs';

let outputArtifactLanguage = 'en';

function printHelp() {
  console.log(`Usage: run-delivery-dry-run.mjs --task-id <task-id> --goal <goal> [options]

Creates a minimal Dev Cadence delivery dry run in an initialized repository.

Required:
  --task-id <id>          Task directory name under specs/records.
  --goal <text>           Requested task goal.

Options:
  --repo-dir <dir>        Target initialized repository. Defaults to current working directory.
  --plugin-dir <dir>      dev-cadence source directory. Defaults to parent directory.
  --skill-dir <dir>       Deprecated alias for --plugin-dir.
  --run-id <id>           Harness run id. Defaults to <task-id>-dry-run-1.
  --requested-by <name>   Requesting Human name. Defaults to Unknown.
  --accepted-by <name>    Named Human accepter. If omitted, G6 remains blocked.
  --json                  Print machine-readable JSON report.
  -h, --help              Show this help text.

This script does not modify product files. It initializes artifacts and records a
dry-run evidence loop for route, artifact, scope, verification, review, and
acceptance behavior.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    repoDir: process.cwd(),
    pluginDir: path.resolve(path.join(import.meta.dirname, '..')),
    taskId: null,
    runId: null,
    goal: null,
    requestedBy: 'Unknown',
    acceptedBy: null,
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--task-id') {
      options.taskId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--goal') {
      options.goal = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--repo-dir') {
      options.repoDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--plugin-dir') {
      options.pluginDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--skill-dir') {
      options.pluginDir = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--run-id') {
      options.runId = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--requested-by') {
      options.requestedBy = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--accepted-by') {
      options.acceptedBy = readValue(argv, index, arg);
      index += 1;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  validateId('task-id', options.taskId);
  if (!options.goal) {
    throw new Error('Missing required --goal');
  }
  if (!options.runId) {
    options.runId = `${options.taskId}-dry-run-1`;
  }
  validateId('run-id', options.runId);

  options.repoDir = path.resolve(options.repoDir);
  options.pluginDir = path.resolve(options.pluginDir);
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

function rel(baseDir, filePath) {
  return path.relative(baseDir, filePath) || '.';
}

function readText(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function writeText(filePath, text) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, localizeDryRunText(text, outputArtifactLanguage));
}

function assertInitialized(repoDir) {
  const required = [
    'AGENTS.md',
    '.dev-cadence.yaml',
    'specs',
  ];

  const missing = required.filter((item) => !fs.existsSync(path.join(repoDir, item)));
  if (missing.length > 0) {
    throw new Error(`Repository is not initialized with Dev Cadence repository contract: missing ${missing.join(', ')}`);
  }

  const agents = readText(path.join(repoDir, 'AGENTS.md'));
  if (!agents.includes('dev-cadence')) {
    throw new Error('Repository AGENTS.md does not route delivery to dev-cadence');
  }
}

function inferWorkflow(goal) {
  const text = goal.toLowerCase();
  if (/\b(review|code review|pr|pull request|diff|patch)\b/.test(text)) {
    return ['code-review', 'Goal mentions review, PR, diff, or patch.'];
  }
  if (/\b(bug|fix|defect|broken|incorrect|regression|error|failure)\b/.test(text)) {
    return ['bugfix', 'Goal mentions bugfix or incorrect behavior.'];
  }
  if (/\b(refactor|cleanup|rename|restructure|reorganize)\b/.test(text)) {
    return ['refactor', 'Goal mentions refactor or structural cleanup.'];
  }
  if (/\b(research|compare|evaluate|feasibility|recommend|spike)\b/.test(text)) {
    return ['research-spike', 'Goal asks for research, comparison, or recommendation.'];
  }
  if (/\b(incident|outage|production|critical|urgent)\b/.test(text)) {
    return ['incident-fix', 'Goal mentions incident, production, critical, or urgent recovery.'];
  }
  return ['feature-dev', 'Defaulted to feature development for new or changed behavior.'];
}

function inferTaskClass(goal) {
  const text = goal.toLowerCase();
  if (/\b(incident|outage|production|critical|urgent)\b/.test(text)) return 'incident';
  if (/\b(research|compare|evaluate|feasibility|recommend|spike)\b/.test(text)) return 'research-spike';
  if (/\b(security|permission|secret|database|migration|ci|deploy|release|architecture|public api|cross-module)\b/.test(text)) return 'S2';
  if (text.length < 80 && /\b(text|typo|comment|docs?|readme)\b/.test(text)) return 'S0';
  return 'S1';
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function now() {
  return new Date().toISOString();
}

function yamlValue(value) {
  if (value === null || value === undefined) return 'null';
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    return `\n${value.map((item) => `  - ${item}`).join('\n')}`;
  }
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') return String(value);
  const stringValue = String(value).replaceAll('"', '\\"');
  if (!stringValue || /[:#\n\[\]{}]|^\s|\s$/.test(stringValue)) {
    return `"${stringValue}"`;
  }
  return stringValue;
}

function block(title, fields, body = '') {
  const yaml = Object.entries(fields)
    .map(([key, value]) => `${key}: ${yamlValue(value)}`)
    .join('\n');
  return `# ${title}\n\n\`\`\`yaml\n${yaml}\n\`\`\`\n${body ? `\n${body.trim()}\n` : ''}`;
}

const ZH_REPLACEMENTS = [
  ['Delivery dry run generated by Dev Cadence runtime script.', 'Dev Cadence \u8fd0\u884c\u811a\u672c\u751f\u6210\u7684\u4ea4\u4ed8 dry run。'],
  ['No product files are changed by this dry run.', '\u6b64 dry run \u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['Dry run evidence does not prove product behavior.', 'dry run \u8bc1\u636e\u4e0d\u80fd\u8bc1\u660e\u4ea7\u54c1\u884c\u4e3a。'],
  ['Final acceptance requires a named Human accepter.', '\u6700\u7ec8\u9a8c\u6536\u9700\u8981\u5177\u540d Human accepter。'],
  ['This artifact set validates Dev Cadence delivery routing and evidence generation. It is not a product implementation.', '\u672c artifact \u96c6\u7528\u4e8e\u9a8c\u8bc1 Dev Cadence \u4ea4\u4ed8\u8def\u7531\u548c\u8bc1\u636e\u751f\u6210。\u5b83\u4e0d\u662f\u4ea7\u54c1\u5b9e\u73b0。'],
  ['Product implementation was skipped by design for dry-run validation.', '\u4e3a dry-run \u9a8c\u8bc1，\u6309\u8bbe\u8ba1\u8df3\u8fc7\u4ea7\u54c1\u5b9e\u73b0。'],
  ['Validate delivery runtime artifact generation.', '\u9a8c\u8bc1\u4ea4\u4ed8\u8fd0\u884c\u65f6 artifact \u751f\u6210。'],
  ['Modify product source files.', '\u4fee\u6539\u4ea7\u54c1\u6e90\u6587\u4ef6。'],
  ['Claim real product behavior is verified.', '\u58f0\u79f0\u771f\u5b9e\u4ea7\u54c1\u884c\u4e3a\u5df2\u9a8c\u8bc1。'],
  ['Task artifacts are generated from bundled templates.', '\u4efb\u52a1 artifact \u4ece\u5185\u7f6e\u6a21\u677f\u751f\u6210。'],
  ['Harness run evidence is generated.', 'Harness run evidence \u5df2\u751f\u6210。'],
  ['Workflow and task class are inferred.', 'workflow \u548c task class \u5df2\u63a8\u65ad。'],
  ['Final acceptance blocks without a named Human accepter.', '\u6ca1\u6709\u5177\u540d Human accepter \u65f6\u6700\u7ec8\u9a8c\u6536\u4fdd\u6301\u963b\u585e。'],
  ['Dry run only.', '\u4ec5 dry run。'],
  ['Who is the named Human accepter?', '\u5177\u540d Human accepter \u662f\u8c01？'],
  ['Generated from CLI inputs and Dev Cadence repository contract.', '\u751f\u6210\u81ea CLI \u8f93\u5165\u548c Dev Cadence \u4ed3\u5e93\u5951\u7ea6。'],
  ['Checked initialized repo contract.', '\u5df2\u68c0\u67e5\u521d\u59cb\u5316\u540e\u7684\u4ed3\u5e93\u5951\u7ea6。'],
  ['Inferred workflow and task class from goal text.', '\u5df2\u6839\u636e\u76ee\u6807\u6587\u672c\u63a8\u65ad workflow \u548c task class。'],
  ['dry_run_scope', 'dry_run_scope'],
  ['CLI --goal', 'CLI --goal'],
  ['Dev Cadence templates and references', 'Dev Cadence templates and references'],
  ['dry_run_cli_input', 'dry_run_cli_input'],
  ['dry_run_requirements_ready', 'dry_run_requirements_ready'],
  ['dry_run_scope_unknown', 'dry_run_scope_unknown'],
  ['G1 is treated as passed for the dry-run scope only.', 'G1 \u4ec5\u9488\u5bf9 dry-run scope \u89c6\u4e3a passed。'],
  ['Validate delivery runtime without product edits.', '\u5728\u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6\u7684\u524d\u63d0\u4e0b\u9a8c\u8bc1\u4ea4\u4ed8\u8fd0\u884c\u65f6。'],
  ['Generate minimal artifacts and Harness evidence using bundled templates.', '\u4f7f\u7528\u5185\u7f6e\u6a21\u677f\u751f\u6210\u6700\u5c0f artifact \u548c Harness evidence。'],
  ['Manual artifact writing', '\u624b\u52a8\u7f16\u5199 artifact'],
  ['Full product implementation', '\u5b8c\u6574\u4ea7\u54c1\u5b9e\u73b0'],
  ['Do not change product files.', '\u4e0d\u8981\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['Keep evidence explicit.', '\u4fdd\u6301\u8bc1\u636e\u660e\u786e。'],
  ['specs artifacts', 'specs artifacts'],
  ['Harness run artifacts', 'Harness run artifacts'],
  ['CLI input -> workflow inference -> template initialization -> artifact fill -> gate summary', 'CLI \u8f93\u5165 -> workflow \u63a8\u65ad -> \u6a21\u677f\u521d\u59cb\u5316 -> artifact \u586b\u5145 -> gate summary'],
  ['Dry run cannot verify product behavior.', 'dry run \u4e0d\u80fd\u9a8c\u8bc1\u4ea7\u54c1\u884c\u4e3a。'],
  ['The dry run validates orchestration surfaces before real Worker execution.', 'dry run \u5728\u771f\u5b9e Worker \u6267\u884c\u524d\u9a8c\u8bc1\u7f16\u6392\u63a5\u53e3。'],
  ['G2 is not required for this dry-run task unless real high-risk product work is added.', '\u9664\u975e\u52a0\u5165\u771f\u5b9e\u9ad8\u98ce\u9669\u4ea7\u54c1\u5de5\u4f5c，\u5426\u5219\u6b64 dry-run task \u4e0d\u9700\u8981 G2。'],
  ['> **For Dev Cadence Workers:** Use `cadence-subagent-development` or `cadence-executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.', '> **For Dev Cadence Workers:** \u4f7f\u7528 `cadence-subagent-development` \u6216 `cadence-executing-plans` \u6309 task \u6267\u884c\u6b64 plan。Steps \u4f7f\u7528 checkbox (`- [ ]`) \u8bed\u6cd5\u8ddf\u8e2a。'],
  ['Generate task artifacts and Harness run evidence without product edits.', '\u5728\u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6\u7684\u524d\u63d0\u4e0b\u751f\u6210 task artifacts \u548c Harness run evidence。'],
  ['Dev Cadence runtime scripts and Markdown artifacts.', 'Dev Cadence runtime scripts \u548c Markdown artifacts。'],
  ['Do not modify product files.', '\u4e0d\u8981\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['Do not claim product verification.', '\u4e0d\u8981\u58f0\u79f0\u4ea7\u54c1\u5df2\u9a8c\u8bc1。'],
  ['Consumes: CLI goal, requested_by, accepted_by, Dev Cadence repository contract.', 'Consumes: CLI goal、requested_by、accepted_by \u548c Dev Cadence \u4ed3\u5e93\u5951\u7ea6。'],
  ['Produces: task artifacts and Harness run evidence.', 'Produces: task artifacts \u548c Harness run evidence。'],
  ['Step 1: Run characterization before artifact fill', 'Step 1: \u5728 artifact \u586b\u5145\u524d\u8fd0\u884c characterization'],
  ['Expected: generated dry-run evidence is not yet populated.', 'Expected: \u751f\u6210\u7684 dry-run evidence \u5c1a\u672a\u586b\u5145。'],
  ['Step 2: Populate dry-run artifacts', 'Step 2: \u586b\u5145 dry-run artifacts'],
  ['Create task artifacts and run evidence under', '\u5728'],
  ['without product edits.', '\u4e0b\u521b\u5efa task artifacts \u548c run evidence，\u4e14\u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['Step 3: Run artifact verification', 'Step 3: \u8fd0\u884c artifact verification'],
  ['Expected: generated dry-run artifact structure is checkable.', 'Expected: \u751f\u6210\u7684 dry-run artifact \u7ed3\u6784\u53ef\u68c0\u67e5。'],
  ['Step 4: Run gate verification', 'Step 4: \u8fd0\u884c gate verification'],
  ['Expected: G3 passes for dry-run task execution.', 'Expected: G3 \u9488\u5bf9 dry-run task execution \u901a\u8fc7。'],
  ['complete_for_dry_run', 'complete_for_dry_run'],
  ['Initialize task and run artifacts.', '\u521d\u59cb\u5316 task \u548c run artifact。'],
  ['Record workflow and task class inference.', '\u8bb0\u5f55 workflow \u548c task class \u63a8\u65ad。'],
  ['Record dry-run implementation evidence.', '\u8bb0\u5f55 dry-run implementation evidence。'],
  ['Record verification and review evidence.', '\u8bb0\u5f55 verification \u548c review evidence。'],
  ['Block final acceptance when no named Human accepter is provided.', '\u672a\u63d0\u4f9b\u5177\u540d Human accepter \u65f6\u963b\u585e\u6700\u7ec8\u9a8c\u6536。'],
  ['Initialized Dev Cadence repository contract', '\u5df2\u521d\u59cb\u5316 Dev Cadence \u4ed3\u5e93\u5951\u7ea6'],
  ['specs artifact tree', 'specs artifact tree'],
  ['Modify product files', '\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6'],
  ['Claim product verification', '\u58f0\u79f0\u4ea7\u54c1\u5df2\u9a8c\u8bc1'],
  ['All generated artifacts are listed in implementation and diff summary.', '\u6240\u6709\u751f\u6210\u7684 artifact \u90fd\u5217\u5165 implementation \u548c diff summary。'],
  ['Run check-spec-artifacts on the generated specs directory.', '\u5bf9\u751f\u6210\u7684 specs \u76ee\u5f55\u8fd0\u884c check-spec-artifacts。'],
  ['artifact_schema: covered', 'artifact_schema: covered'],
  ['product_behavior: not_applicable', 'product_behavior: not_applicable'],
  ['Executed as delivery runtime dry run.', '\u4ee5\u4ea4\u4ed8\u8fd0\u884c\u65f6 dry run \u65b9\u5f0f\u6267\u884c。'],
  ['dry_run_tasks_are_executable', 'dry_run_tasks_are_executable'],
  ['dry_run_tasks_missing_scope_or_verification', 'dry_run_tasks_missing_scope_or_verification'],
  ['G3 passed for dry-run execution because tasks, artifacts, forbidden actions, and verification plan are explicit.', 'G3 \u9488\u5bf9 dry-run execution \u901a\u8fc7，\u56e0\u4e3a tasks、artifacts、forbidden actions \u548c verification plan \u90fd\u5df2\u660e\u786e。'],
  ['Generated artifacts and run evidence', '\u751f\u6210\u7684 artifact \u548c run evidence'],
  ['Validate YAML-like artifact blocks with check-spec-artifacts.mjs', '\u4f7f\u7528 check-spec-artifacts.mjs \u6821\u9a8c YAML-like artifact blocks'],
  ['local fixture repository', '\u672c\u5730 fixture \u4ed3\u5e93'],
  ['Task artifact schema', 'Task artifact schema'],
  ['Harness evidence schema', 'Harness evidence schema'],
  ['No product components changed', '\u672a\u4fee\u6539\u4ea7\u54c1\u7ec4\u4ef6'],
  ['Product behavior verification skipped by dry-run scope', 'dry-run scope \u8df3\u8fc7\u4ea7\u54c1\u884c\u4e3a\u9a8c\u8bc1'],
  ['Dry run can pass while product implementation remains untested.', 'dry run \u53ef\u80fd\u901a\u8fc7，\u4f46\u4ea7\u54c1\u5b9e\u73b0\u4ecd\u672a\u6d4b\u8bd5。'],
  ['Generated artifacts plus checker command output.', '\u751f\u6210\u7684 artifact \u548c checker \u547d\u4ee4\u8f93\u51fa。'],
  ['dry_run_complete', 'dry_run_complete'],
  ['passed_no_product_changes', 'passed_no_product_changes'],
  ['Validate delivery runtime artifact generation without product edits.', '\u5728\u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6\u7684\u524d\u63d0\u4e0b\u9a8c\u8bc1\u4ea4\u4ed8\u8fd0\u884c\u65f6 artifact \u751f\u6210。'],
  ['Initialized artifacts and populated dry-run evidence.', '\u5df2\u521d\u59cb\u5316 artifact \u5e76\u586b\u5145 dry-run evidence。'],
  ['Not applicable to dry-run orchestration.', '\u4e0d\u9002\u7528\u4e8e dry-run \u7f16\u6392。'],
  ['No product behavior implemented.', '\u672a\u5b9e\u73b0\u4ea7\u54c1\u884c\u4e3a。'],
  ['Artifact checker used as validation feedback.', '\u4f7f\u7528 artifact checker \u4f5c\u4e3a\u9a8c\u8bc1\u53cd\u9988。'],
  ['check-spec-artifacts on generated specs directory', '\u5bf9\u751f\u6210\u7684 specs \u76ee\u5f55\u8fd0\u884c check-spec-artifacts'],
  ['pending_until_checker_runs', 'pending_until_checker_runs'],
  ['No product behavior is verified.', '\u4ea7\u54c1\u884c\u4e3a\u672a\u7531 dry run \u9a8c\u8bc1。'],
  ['Run real delivery workflow for product work.', '\u5bf9\u4ea7\u54c1\u5de5\u4f5c\u8fd0\u884c\u771f\u5b9e\u4ea4\u4ed8 workflow。'],
  ['No product files changed. Artifact initialization report created', '\u672a\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。Artifact initialization report \u521b\u5efa\u4e86'],
  ['files and skipped', '\u4e2a\u6587\u4ef6，\u8df3\u8fc7\u4e86'],
  ['existing files.', '\u4e2a\u5df2\u6709\u6587\u4ef6。'],
  ['partially_verified', 'partially_verified'],
  ['Artifact structure is expected to be machine-checkable.', 'Artifact \u7ed3\u6784\u5e94\u53ef\u88ab\u673a\u5668\u68c0\u67e5。'],
  ['Artifact schema', 'Artifact schema'],
  ['Product tests were not run because dry run makes no product changes.', '\u672a\u8fd0\u884c\u4ea7\u54c1\u6d4b\u8bd5，\u56e0\u4e3a dry run \u4e0d\u505a\u4ea7\u54c1\u53d8\u66f4。'],
  ['Dry run evidence cannot prove product behavior.', 'dry run \u8bc1\u636e\u4e0d\u80fd\u8bc1\u660e\u4ea7\u54c1\u884c\u4e3a。'],
  ['Block final acceptance until named Human accepts dry-run residual risk.', '\u963b\u585e\u6700\u7ec8\u9a8c\u6536，\u76f4\u5230\u5177\u540d Human \u63a5\u53d7 dry-run residual risk。'],
  ['Accept dry-run scope only.', '\u4ec5\u63a5\u53d7 dry-run scope。'],
  ['Run `check-spec-artifacts.mjs` against the repository specs directory.', '\u5bf9\u4ed3\u5e93 specs \u76ee\u5f55\u8fd0\u884c `check-spec-artifacts.mjs`。'],
  ['Product behavior is not verified.', '\u4ea7\u54c1\u884c\u4e3a\u672a\u7531 dry run \u9a8c\u8bc1。'],
  ['named Human acceptance required', 'named Human acceptance required'],
  ['dry-run risk accepted by named Human', 'dry-run risk accepted by named Human'],
  ['blocked_pending_acceptance', 'blocked_pending_acceptance'],
  ['approved_for_dry_run_scope', 'approved_for_dry_run_scope'],
  ['Generated dry-run artifacts', '\u751f\u6210\u7684 dry-run artifacts'],
  ['Harness evidence', 'Harness evidence'],
  ['Final acceptance requires a named Human accepter.', '\u6700\u7ec8\u9a8c\u6536\u9700\u8981\u5177\u540d Human accepter。'],
  ['Dry run does not verify product behavior.', 'dry run \u4e0d\u9a8c\u8bc1\u4ea7\u54c1\u884c\u4e3a。'],
  ['Product behavior remains unverified.', '\u4ea7\u54c1\u884c\u4e3a\u4ecd\u672a\u9a8c\u8bc1。'],
  ['No code findings because no product files changed.', '\u6ca1\u6709\u4ee3\u7801 findings，\u56e0\u4e3a\u672a\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['blocked_pending_human_acceptance', 'blocked_pending_human_acceptance'],
  ['product_behavior_not_applicable_to_dry_run', 'product_behavior_not_applicable_to_dry_run'],
  ['none', 'none'],
  ['accepted_for_dry_run_scope', 'accepted_for_dry_run_scope'],
  ['Delivery runtime dry-run artifacts only', '\u4ec5\u4ea4\u4ed8\u8fd0\u884c\u65f6 dry-run artifacts'],
  ['accepted dry-run residual risk.', '\u5df2\u63a5\u53d7 dry-run residual risk。'],
  ['Product behavior not verified by dry run.', '\u4ea7\u54c1\u884c\u4e3a\u672a\u7531 dry run \u9a8c\u8bc1。'],
  ['Use real delivery workflow for product implementation.', '\u5bf9\u4ea7\u54c1\u5b9e\u73b0\u4f7f\u7528\u771f\u5b9e\u4ea4\u4ed8 workflow。'],
  ['Supervisor', 'Supervisor'],
  ['not_started_for_product_files', 'not_started_for_product_files'],
  ['passed_for_dry_run_scope', 'passed_for_dry_run_scope'],
  ['not_applicable_no_product_implementation', 'not_applicable_no_product_implementation'],
  ['not_required', 'not_required'],
  ['dry_run_no_product_edits', 'dry_run_no_product_edits'],
  ['No product implementation is authorized or performed by dry run.', 'dry run \u672a\u6388\u6743\u4e5f\u672a\u6267\u884c\u4ea7\u54c1\u5b9e\u73b0。'],
  ['delivery_dry_run', 'delivery_dry_run'],
  ['CLI goal', 'CLI goal'],
  ['Dev Cadence repository contract', 'Dev Cadence repository contract'],
  ['init-task-artifacts.mjs', 'init-task-artifacts.mjs'],
  ['check-spec-artifacts.mjs should be run after generation', '\u751f\u6210\u540e\u5e94\u8fd0\u884c check-spec-artifacts.mjs'],
  ['Product tests skipped; dry run has no product implementation.', '\u8df3\u8fc7\u4ea7\u54c1\u6d4b\u8bd5，\u56e0\u4e3a dry run \u6ca1\u6709\u4ea7\u54c1\u5b9e\u73b0。'],
  ['Product behavior is unverified.', '\u4ea7\u54c1\u884c\u4e3a\u672a\u9a8c\u8bc1。'],
  ['Human Gate G6', 'Human Gate G6'],
  ['Done for dry-run scope', 'Done for dry-run scope'],
  ['Task artifacts populated.', 'Task artifacts \u5df2\u586b\u5145。'],
  ['Harness run evidence populated.', 'Harness run evidence \u5df2\u586b\u5145。'],
  ['No product tool execution.', '\u6ca1\u6709\u4ea7\u54c1\u5de5\u5177\u6267\u884c。'],
  ['check-spec-artifacts.mjs specs/records', 'check-spec-artifacts.mjs specs/records'],
  ['pending_external_command_capture', 'pending_external_command_capture'],
  ['Product test suite skipped by dry-run scope.', 'dry-run scope \u8df3\u8fc7\u4ea7\u54c1\u6d4b\u8bd5\u5957\u4ef6。'],
  ['Generated delivery dry-run artifacts.', '\u751f\u6210\u4ea4\u4ed8 dry-run artifacts。'],
  ['No product behavior verified.', '\u672a\u9a8c\u8bc1\u4ea7\u54c1\u884c\u4e3a。'],
  ['No elevated permissions requested.', '\u672a\u8bf7\u6c42\u63d0\u5347\u6743\u9650。'],
  ['Provide --accepted-by <name> only when a named Human accepts dry-run residual risk.', '\u4ec5\u5f53\u5177\u540d Human \u63a5\u53d7 dry-run residual risk \u65f6\u63d0\u4f9b --accepted-by <name>。'],
  ['Dry-run scope accepted; use real delivery workflow for product implementation.', 'dry-run scope \u5df2\u63a5\u53d7；\u4ea7\u54c1\u5b9e\u73b0\u8bf7\u4f7f\u7528\u771f\u5b9e\u4ea4\u4ed8 workflow。'],
];

function localizeDryRunText(text, artifactLanguage) {
  if (artifactLanguage !== 'zh') return text;
  let result = text;
  for (const [english, chinese] of ZH_REPLACEMENTS) {
    result = result.replaceAll(english, chinese);
  }
  return result;
}

function initArtifacts(options) {
  const recordsDir = defaultRecordsDir(options.repoDir);
  const script = path.join(options.pluginDir, 'scripts', 'init-task-artifacts.mjs');
  const result = spawnSync(process.execPath, [
    script,
    '--task-id',
    options.taskId,
    '--run-id',
    options.runId,
    '--specs-dir',
    recordsDir,
    '--skill-dir',
    options.pluginDir,
    '--json',
  ], { encoding: 'utf8' });

  if (result.status !== 0) {
    throw new Error(`Artifact initialization failed: ${result.stderr || result.stdout}`);
  }

  return JSON.parse(result.stdout);
}

function writeArtifacts(options, workflow, selectionReason, taskClass, artifactReport) {
  const recordsDir = defaultRecordsDir(options.repoDir);
  const recordsLabel = 'specs/records';
  const taskDir = path.join(recordsDir, options.taskId);
  const runDir = path.join(taskDir, 'runs', options.runId);
  const artifactFiles = [
    '00-brief.md',
    '01-requirements.md',
    '02-design.md',
    '03-tasks.md',
    '04-test-plan.md',
    '05-implementation.md',
    '06-test-report.md',
    '07-review-report.md',
    '08-acceptance.md',
  ];
  const runFiles = [
    'run-context.md',
    'pre-implementation-status.md',
    'execution-report.md',
    'tool-log.md',
    'test-log.md',
    'diff-summary.md',
    'permission-decisions.md',
  ];
  const artifactPaths = artifactFiles.map((file) => `${recordsLabel}/${options.taskId}/${file}`);
  const runPaths = runFiles.map((file) => `${recordsLabel}/${options.taskId}/runs/${options.runId}/${file}`);
  const acceptanceBlocked = !options.acceptedBy;
  const timestamp = now();

  writeText(path.join(taskDir, '00-brief.md'), block('Brief', {
    task_id: options.taskId,
    requested_by: options.requestedBy,
    date: today(),
    artifact_language: options.artifactLanguage,
    goal: options.goal,
    background: 'Delivery dry run generated by Dev Cadence runtime script.',
    constraints: ['No product files are changed by this dry run.'],
    initial_risks: ['Dry run evidence does not prove product behavior.'],
    assumptions: [],
    open_questions: acceptanceBlocked ? ['Final acceptance requires a named Human accepter.'] : [],
    workflow_hint: null,
    selected_workflow: workflow,
    selection_reason: selectionReason,
    task_class: taskClass,
  }, `## Notes

This artifact set validates Dev Cadence delivery routing and evidence generation. It is not a product implementation.

## Skipped States

- Product implementation was skipped by design for dry-run validation.`));

  writeText(path.join(taskDir, '01-requirements.md'), block('Requirements', {
    status: 'accepted_for_dry_run',
    goal: options.goal,
    scope: ['Validate delivery runtime artifact generation.'],
    non_goals: ['Modify product source files.', 'Claim real product behavior is verified.'],
    users_or_stakeholders: [options.requestedBy],
    acceptance_criteria: [
      'Task artifacts are generated from bundled templates.',
      'Harness run evidence is generated.',
      'Workflow and task class are inferred.',
      'Final acceptance blocks without a named Human accepter.',
    ],
    constraints: ['Dry run only.'],
    assumptions: [],
    open_questions: acceptanceBlocked ? ['Who is the named Human accepter?'] : [],
    human_decisions: options.acceptedBy ? [`accepted_by_human: ${options.acceptedBy}`] : [],
  }, `## Source Notes

Generated from CLI inputs and Dev Cadence repository contract.

## Ambiguity Check

\`\`\`yaml
unresolved_ambiguity: false
material_to_implementation: false
clarification_required: false
analysis_performed:
  - Checked initialized repo contract.
  - Inferred workflow and task class from goal text.
evidence_paths:
  - AGENTS.md
  - .dev-cadence.yaml
candidate_interpretations: []
recommended_option: ${workflow}
clarified_by_human: ${yamlValue(options.requestedBy)}
clarified_at: ${timestamp}
decision: dry_run_scope
\`\`\`

## Requirements Readiness Check

\`\`\`yaml
expected_behavior_explicit: true
expected_behavior_source: CLI --goal
reference_behavior_explicit: true
reference_behavior_source: Dev Cadence templates and references
scope_confirmed: true
non_goals_confirmed: true
acceptance_criteria_confirmed: true
verification_approach_confirmed: true
accepted_by_human: ${yamlValue(options.requestedBy)}
human_decision_reference: dry_run_cli_input
ready_for_implementation: true
blocking_questions: []
\`\`\`

## Gate G1

\`\`\`yaml
gate_id: G1
status: passed
required_inputs:
  - 01-requirements.md
evidence:
  - specs/records/${options.taskId}/01-requirements.md
pass_condition: dry_run_requirements_ready
fail_condition: dry_run_scope_unknown
decision: passed
human_override: null
residual_risk: []
escalation: none
\`\`\`

G1 is treated as passed for the dry-run scope only.`));

  writeText(path.join(taskDir, '02-design.md'), block('Design', {
    status: taskClass === 'S2' ? 'required_for_real_work' : 'not_required_for_dry_run',
    problem: 'Validate delivery runtime without product edits.',
    chosen_approach: 'Generate minimal artifacts and Harness evidence using bundled templates.',
    alternatives_considered: ['Manual artifact writing', 'Full product implementation'],
    architecture_constraints: ['Do not change product files.', 'Keep evidence explicit.'],
    affected_components: ['specs artifacts', 'Harness run artifacts'],
    data_or_control_flow: ['CLI input -> workflow inference -> template initialization -> artifact fill -> gate summary'],
    risks: ['Dry run cannot verify product behavior.'],
    required_adrs: [],
    human_decisions: [],
  }, `## Rationale

The dry run validates orchestration surfaces before real Worker execution.

## Gate G2

G2 is not required for this dry-run task unless real high-risk product work is added.`));

  writeText(path.join(taskDir, '03-tasks.md'), `# Delivery Dry Run Implementation Plan

> **For Dev Cadence Workers:** Use \`cadence-subagent-development\` or \`cadence-executing-plans\` to implement this plan task-by-task. Steps use checkbox (\`- [ ]\`) syntax for tracking.

**Goal:** Validate delivery runtime artifact generation.

**Architecture:** Generate task artifacts and Harness run evidence without product edits.

**Tech Stack:** Dev Cadence runtime scripts and Markdown artifacts.

## Global Constraints

- Do not modify product files.
- Do not claim product verification.
- Task class: ${taskClass}
- Selected workflow: ${workflow}

---

### Task 1: Initialize delivery runtime artifacts

**Files:**
- Create: \`specs/records/${options.taskId}/**\`
- Modify: not_applicable: no product files.
- Test: \`specs/records/${options.taskId}/runs/${options.runId}/test-log.md\`

**Interfaces:**
- Consumes: CLI goal, requested_by, accepted_by, Dev Cadence repository contract.
- Produces: task artifacts and Harness run evidence.

- [ ] **Step 1: Run characterization before artifact fill**

Run: \`node scripts/check-spec-artifacts.mjs specs/records\`
Expected: generated dry-run evidence is not yet populated.

- [ ] **Step 2: Populate dry-run artifacts**

Create task artifacts and run evidence under \`specs/records/${options.taskId}/\` without product edits.

- [ ] **Step 3: Run artifact verification**

Run: \`node scripts/check-spec-artifacts.mjs specs/records\`
Expected: generated dry-run artifact structure is checkable.

- [ ] **Step 4: Run gate verification**

Run: \`node scripts/check-gates.mjs --task-id ${options.taskId}\`
Expected: G3 passes for dry-run task execution.

## Execution Notes

Status: complete_for_dry_run

Verification plan:
- Run check-spec-artifacts on the generated specs directory.

Executed as delivery runtime dry run.

## Gate G3

Status: passed
Required inputs:
- 03-tasks.md
Evidence:
- specs/records/${options.taskId}/03-tasks.md
Pass condition: dry_run_tasks_are_executable
Fail condition: dry_run_tasks_missing_scope_or_verification
Decision: passed
Human override: none
Residual risk:
- none
Escalation: none

G3 passed for dry-run execution because tasks, artifacts, forbidden actions, and verification plan are explicit.`);

  writeText(path.join(taskDir, '04-test-plan.md'), block('Test Plan', {
    status: 'complete_for_dry_run',
    scope: ['Generated artifacts and run evidence'],
    test_strategy: ['Validate YAML-like artifact blocks with check-spec-artifacts.mjs'],
    test_commands: [`node ${path.relative(options.repoDir, path.join(options.pluginDir, 'scripts', 'check-spec-artifacts.mjs'))} specs/records`],
    test_data: [`specs/records/${options.taskId}`],
    environment: ['local fixture repository'],
    coverage_targets: ['Task artifact schema', 'Harness evidence schema'],
    changed_component_coverage: ['No product components changed'],
    skipped_component_checks: ['Product behavior verification skipped by dry-run scope'],
    risks: ['Dry run can pass while product implementation remains untested.'],
  }, '## Planned Evidence\n\nGenerated artifacts plus checker command output.'));

  writeText(path.join(taskDir, '05-implementation.md'), block('Implementation', {
    status: 'dry_run_complete',
    planned_files: [],
    planned_artifact_files: artifactPaths,
    changed_files: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    scope_reconciliation: 'passed_no_product_changes',
    rationale: 'Validate delivery runtime artifact generation without product edits.',
    implementation_notes: ['Initialized artifacts and populated dry-run evidence.'],
    tdd_or_feedback_evidence: 'Not applicable to dry-run orchestration.',
    red_evidence: null,
    green_evidence: null,
    refactor_evidence: null,
    tdd_exception: 'No product behavior implemented.',
    substitute_feedback: ['Artifact checker used as validation feedback.'],
    test_commands: ['check-spec-artifacts on generated specs directory'],
    test_results: ['pending_until_checker_runs'],
    known_limitations: ['No product behavior is verified.'],
    follow_up_needed: ['Run real delivery workflow for product work.'],
  }, `## Diff Summary

No product files changed. Artifact initialization report created ${artifactReport.created.length} files and skipped ${artifactReport.skipped_existing.length} existing files.

## Harness Runs

- ${options.runId}`));

  writeText(path.join(taskDir, '06-test-report.md'), block('Test Report', {
    status: 'complete_for_dry_run',
    verification_status: 'partially_verified',
    commands_run: ['check-spec-artifacts on generated specs directory'],
    environment: ['local fixture repository'],
    results: ['Artifact structure is expected to be machine-checkable.'],
    coverage_scope: ['Artifact schema', 'Harness evidence schema'],
    changed_component_coverage: ['No product components changed'],
    skipped_component_checks: ['Product behavior verification'],
    defects: [],
    skipped_checks: ['Product tests were not run because dry run makes no product changes.'],
    residual_risk: ['Dry run evidence cannot prove product behavior.'],
    recommendation: acceptanceBlocked ? 'Block final acceptance until named Human accepts dry-run residual risk.' : 'Accept dry-run scope only.',
  }, `## Evidence

Run \`check-spec-artifacts.mjs\` against the repository specs directory.

## Gate G4

\`\`\`yaml
gate_id: G4
status: ${options.acceptedBy ? 'passed' : 'blocked'}
required_inputs:
  - 04-test-plan.md
  - 06-test-report.md
evidence:
  - specs/records/${options.taskId}
verification_status: partially_verified
component_coverage_complete: false
human_override: ${yamlValue(options.acceptedBy)}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'dry-run risk accepted by named Human'}
\`\`\``));

  writeText(path.join(taskDir, '07-review-report.md'), block('Review Report', {
    status: acceptanceBlocked ? 'blocked_pending_acceptance' : 'approved_for_dry_run_scope',
    review_scope: ['Generated dry-run artifacts', 'Harness evidence'],
    evidence_reviewed: [...artifactPaths, ...runPaths],
    scope_reconciliation_reviewed: true,
    verification_coverage_reviewed: true,
    findings: [],
    blockers: acceptanceBlocked ? ['Final acceptance requires a named Human accepter.'] : [],
    major_issues: [],
    minor_notes: ['Dry run does not verify product behavior.'],
    security_notes: [],
    architecture_notes: [],
    decision: acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes',
    residual_risk: ['Product behavior remains unverified.'],
  }, `## Findings

No code findings because no product files changed.

## Gate G5

\`\`\`yaml
gate_id: G5
status: ${acceptanceBlocked ? 'blocked' : 'passed'}
required_inputs:
  - 06-test-report.md
  - 07-review-report.md
evidence:
  - specs/records/${options.taskId}
g4_status: ${options.acceptedBy ? 'human_override_for_dry_run' : 'blocked_pending_human_acceptance'}
scope_reconciliation_status: passed_no_product_changes
verification_coverage_status: product_behavior_not_applicable_to_dry_run
decision: ${acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes'}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}
\`\`\``));

  writeText(path.join(taskDir, '08-acceptance.md'), block('Acceptance', {
    status: acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope',
    accepted_by_human: options.acceptedBy,
    accepted_at: options.acceptedBy ? timestamp : null,
    accepted_scope: options.acceptedBy ? ['Delivery runtime dry-run artifacts only'] : [],
    evidence_reviewed: options.acceptedBy ? [...artifactPaths, ...runPaths] : [],
    human_gate_decisions: options.acceptedBy ? [`${options.acceptedBy} accepted dry-run residual risk.`] : [],
    residual_risk_accepted: options.acceptedBy ? ['Product behavior not verified by dry run.'] : [],
    merge_or_release_decision: 'not_applicable',
    follow_up: ['Use real delivery workflow for product implementation.'],
  }, `## Gate G6

\`\`\`yaml
gate_id: G6
status: ${acceptanceBlocked ? 'blocked' : 'passed'}
required_inputs:
  - 08-acceptance.md
evidence:
  - specs/records/${options.taskId}
human_accepter: ${yamlValue(options.acceptedBy)}
decision: ${acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope'}
residual_risk:
  - Product behavior is not verified.
escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}
\`\`\``));

  writeText(path.join(runDir, 'run-context.md'), block('Run Context', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    blueprint_path: 'references/supervisor-state-machine.md',
    context_pack_path: `specs/records/${options.taskId}/00-brief.md`,
    workspace_path: rel(options.repoDir, options.repoDir),
    allowed_read_paths: ['AGENTS.md', '.dev-cadence.yaml', 'specs/records/**'],
    allowed_write_paths: [`specs/records/${options.taskId}/**`],
    denied_paths: ['product source files'],
    allowed_tools: ['node', 'filesystem writes under specs'],
    denied_tools: ['network', 'production actions', 'database writes'],
    network_policy: 'disabled',
    secret_policy: 'do_not_request_or_record_secrets',
    permission_policy: 'no elevated permissions required',
    budget: 'local dry run',
    timeout: 'not enforced',
    max_iterations: 1,
    required_evidence: runPaths,
    pre_implementation_status_path: `specs/records/${options.taskId}/runs/${options.runId}/pre-implementation-status.md`,
    expected_artifacts: artifactPaths,
    log_paths: runPaths,
  }));

  writeText(path.join(runDir, 'pre-implementation-status.md'), block('Pre-Implementation Status', {
    run_id: options.runId,
    task_id: options.taskId,
    captured_at: timestamp,
    task_class: taskClass,
    selected_workflow: workflow,
    implementation_state: 'not_started_for_product_files',
    git_status_before: [],
    untracked_files_before: [],
    authorized_target_files: [],
    authorized_artifact_files: artifactPaths,
    g1_status: 'passed_for_dry_run_scope',
    g2_status: taskClass === 'S2' ? 'not_applicable_no_product_implementation' : 'not_required',
    g3_status: 'passed_for_dry_run_scope',
    requirements_ready: true,
    blocking_questions: [],
    implementation_authorized: false,
    authorization_source: 'dry_run_no_product_edits',
    post_hoc_backfill: false,
    post_hoc_human_override_by: null,
    post_hoc_human_override_reason: null,
    residual_risk: ['No product implementation is authorized or performed by dry run.'],
  }));

  writeText(path.join(runDir, 'execution-report.md'), block('Execution Report', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    state: 'delivery_dry_run',
    started_at: timestamp,
    ended_at: timestamp,
    inputs: ['CLI goal', 'Dev Cadence repository contract'],
    outputs: [...artifactPaths, ...runPaths],
    planned_files: [],
    planned_artifact_files: artifactPaths,
    files_changed: [],
    untracked_files: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    pre_implementation_status_path: `specs/records/${options.taskId}/runs/${options.runId}/pre-implementation-status.md`,
    implementation_authorized: false,
    post_hoc_backfill: false,
    scope_reconciliation_status: 'passed_no_product_changes',
    commands_run: ['init-task-artifacts.mjs'],
    tests_run: ['check-spec-artifacts.mjs should be run after generation'],
    verification_status: 'partially_verified',
    permissions_requested: [],
    permissions_granted: [],
    permissions_denied: [],
    skipped_checks: ['Product tests skipped; dry run has no product implementation.'],
    errors: [],
    residual_risk: ['Product behavior is unverified.'],
    handoff_target: acceptanceBlocked ? 'Human Gate G6' : 'Done for dry-run scope',
  }));

  writeText(path.join(runDir, 'tool-log.md'), block('Tool Log', {
    run_id: options.runId,
    commands_or_tools: ['init-task-artifacts.mjs', 'run-delivery-dry-run.mjs'],
    outputs: ['Task artifacts populated.', 'Harness run evidence populated.'],
    errors: [],
    omissions: ['No product tool execution.'],
  }));

  writeText(path.join(runDir, 'test-log.md'), block('Test Log', {
    run_id: options.runId,
    commands: ['check-spec-artifacts.mjs specs/records'],
    environment: ['local fixture repository'],
    results: ['pending_external_command_capture'],
    failures: [],
    skipped: ['Product test suite skipped by dry-run scope.'],
  }));

  writeText(path.join(runDir, 'diff-summary.md'), block('Diff Summary', {
    run_id: options.runId,
    planned_files: [],
    planned_artifact_files: artifactPaths,
    files_changed: [],
    untracked_files: [],
    created_artifact_files: [...artifactPaths, ...runPaths],
    unplanned_changed_files: [],
    deleted_files: [],
    added_components: [],
    scope_reconciliation_status: 'passed_no_product_changes',
    behavior_changes: [],
    non_behavior_changes: ['Generated delivery dry-run artifacts.'],
    risk_notes: ['No product behavior verified.'],
  }));

  writeText(path.join(runDir, 'permission-decisions.md'), block('Permission Decisions', {
    run_id: options.runId,
    requests: [],
    decisions: [],
    denials: [],
    conditions: ['No elevated permissions requested.'],
    residual_risk: [],
  }));

  return { artifact_paths: artifactPaths, run_paths: runPaths, acceptance_blocked: acceptanceBlocked };
}

function run(options) {
  if (!fs.existsSync(options.repoDir)) {
    throw new Error(`Repository directory not found: ${options.repoDir}`);
  }
  assertInitialized(options.repoDir);
  options.artifactLanguage = resolveArtifactLanguage(options.repoDir).language;
  outputArtifactLanguage = options.artifactLanguage;

  const [workflow, selectionReason] = inferWorkflow(options.goal);
  const taskClass = inferTaskClass(options.goal);
  const artifactReport = initArtifacts(options);
  const writeReport = writeArtifacts(options, workflow, selectionReason, taskClass, artifactReport);

  return {
    task_id: options.taskId,
    run_id: options.runId,
    repository: options.repoDir,
    selected_workflow: workflow,
    selection_reason: selectionReason,
    task_class: taskClass,
    artifact_language: options.artifactLanguage,
    artifact_report: artifactReport,
    artifact_paths: writeReport.artifact_paths,
    run_paths: writeReport.run_paths,
    acceptance_status: writeReport.acceptance_blocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope',
    verification_status: 'partially_verified',
    scope_reconciliation_status: 'passed_no_product_changes',
    next_steps: writeReport.acceptance_blocked
      ? ['Provide --accepted-by <name> only when a named Human accepts dry-run residual risk.']
      : ['Dry-run scope accepted; use real delivery workflow for product implementation.'],
  };
}

function printReport(report) {
  console.log(`Task: ${report.task_id}`);
  console.log(`Run: ${report.run_id}`);
  console.log(`Workflow: ${report.selected_workflow}`);
  console.log(`Task class: ${report.task_class}`);
  console.log(`Acceptance: ${report.acceptance_status}`);
  console.log(`Verification: ${report.verification_status}`);
  console.log(`Scope reconciliation: ${report.scope_reconciliation_status}`);
  console.log('\nArtifacts:');
  for (const item of report.artifact_paths) console.log(`- ${item}`);
  console.log('\nRun evidence:');
  for (const item of report.run_paths) console.log(`- ${item}`);
  console.log('\nNext steps:');
  for (const item of report.next_steps) console.log(`- ${item}`);
}

try {
  const options = parseArgs(process.argv.slice(2));
  const report = run(options);
  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    printReport(report);
  }
} catch (error) {
  console.error(`ERROR ${error.message}`);
  console.error('Run with --help for usage.');
  process.exit(2);
}
