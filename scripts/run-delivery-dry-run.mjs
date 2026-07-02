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

function markdownValue(value) {
  if (value === null || value === undefined) return 'null';
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    return `\n${value.map((item) => `- ${item}`).join('\n')}`;
  }
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  return String(value);
}

function labelForKey(key) {
  return key
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function markdownBlock(title, fields, body = '') {
  const labels = Object.entries(fields)
    .map(([key, value]) => `${labelForKey(key)}: ${markdownValue(value)}`)
    .join('\n');
  return `# ${title}\n\n${labels}\n${body ? `\n${body.trim()}\n` : ''}`;
}

const ZH_REPLACEMENTS = [
  ['Delivery dry run generated by Dev Cadence runtime script.', 'Dev Cadence \u8fd0\u884c\u811a\u672c\u751f\u6210\u7684\u4ea4\u4ed8 dry run。'],
  ['No product files are changed by this dry run.', '\u6b64 dry run \u4e0d\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['Dry run evidence does not prove product behavior.', 'dry run \u8bc1\u636e\u4e0d\u80fd\u8bc1\u660e\u4ea7\u54c1\u884c\u4e3a。'],
  ['Final acceptance requires a named Human accepter.', '\u6700\u7ec8\u9a8c\u6536\u9700\u8981\u5177\u540d Human accepter。'],
  ['This artifact set validates Dev Cadence delivery routing and evidence generation. It is not a product implementation.', '\u672c artifact \u96c6\u7528\u4e8e\u9a8c\u8bc1 Dev Cadence \u4ea4\u4ed8\u8def\u7531\u548c\u8bc1\u636e\u751f\u6210。\u5b83\u4e0d\u662f\u4ea7\u54c1\u5b9e\u73b0。'],
  ['Product implementation was skipped by design for dry-run validation.', '\u4e3a dry-run \u9a8c\u8bc1，\u6309\u8bbe\u8ba1\u8df3\u8fc7\u4ea7\u54c1\u5b9e\u73b0。'],
  ['The initialized repository contract is the input boundary.', '\u5df2\u521d\u59cb\u5316\u7684\u4ed3\u5e93\u5951\u7ea6\u662f\u8f93\u5165\u8fb9\u754c。'],
  ['Workflow and task class are inferred from CLI goal text.', '\u6839\u636e CLI goal \u6587\u672c\u63a8\u65ad workflow \u548c task class。'],
  ['None for accepted dry-run scope.', '\u5df2\u9a8c\u6536\u7684 dry-run scope \u65e0\u5f85\u89e3\u95ee\u9898。'],
  ['The dry run should create a complete, checkable Dev Cadence artifact set without touching product files.', 'dry run \u5e94\u5728\u4e0d\u89e6\u78b0\u4ea7\u54c1\u6587\u4ef6\u7684\u524d\u63d0\u4e0b\u521b\u5efa\u5b8c\u6574\u4e14\u53ef\u68c0\u67e5\u7684 Dev Cadence artifact \u96c6。'],
  ['Generate Harness run evidence for the dry-run execution path.', '\u4e3a dry-run \u6267\u884c\u8def\u5f84\u751f\u6210 Harness run evidence。'],
  ['Infer workflow and task class from the CLI goal.', '\u4ece CLI goal \u63a8\u65ad workflow \u548c task class。'],
  ['Final acceptance is recorded by a named Human accepter.', '\u7531\u5177\u540d Human accepter \u8bb0\u5f55\u6700\u7ec8\u9a8c\u6536。'],
  ['Keep evidence explicit and path-based.', '\u4fdd\u6301\u8bc1\u636e\u660e\u786e\u4e14\u57fa\u4e8e\u8def\u5f84。'],
  ['Generate the minimal task artifacts and Harness evidence using bundled templates, then run artifact and gate checks against the generated record.', '\u4f7f\u7528\u5185\u7f6e\u6a21\u677f\u751f\u6210\u6700\u5c0f task artifacts \u548c Harness evidence，\u7136\u540e\u5bf9\u751f\u6210\u8bb0\u5f55\u8fd0\u884c artifact \u548c gate \u68c0\u67e5。'],
  ['None for dry-run orchestration.', 'dry-run \u7f16\u6392\u65e0\u9700 ADR。'],
  ['The dry run validates orchestration surfaces before real Worker execution while preserving the boundary that only real delivery work can verify product behavior.', 'dry run \u5728\u771f\u5b9e Worker \u6267\u884c\u524d\u9a8c\u8bc1\u7f16\u6392\u63a5\u53e3，\u540c\u65f6\u4fdd\u7559\u53ea\u6709\u771f\u5b9e\u4ea4\u4ed8\u5de5\u4f5c\u624d\u80fd\u9a8c\u8bc1\u4ea7\u54c1\u884c\u4e3a\u7684\u8fb9\u754c。'],
  ['The generated task artifacts and Harness run evidence are present, Markdown-first, and machine-checkable without requiring product file changes.', '\u751f\u6210\u7684 task artifacts \u548c Harness run evidence \u5df2\u5b58\u5728，\u91c7\u7528 Markdown-first \u5f62\u6001，\u5e76\u4e14\u65e0\u9700\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6\u5373\u53ef\u673a\u5668\u68c0\u67e5。'],
  ['Use the artifact checker and gate checker as runtime feedback for dry-run scope. Product behavior tests are out of scope because no product behavior is implemented.', '\u4f7f\u7528 artifact checker \u548c gate checker \u4f5c\u4e3a dry-run scope \u7684\u8fd0\u884c\u65f6\u53cd\u9988。\u7531\u4e8e\u6ca1\u6709\u5b9e\u73b0\u4ea7\u54c1\u884c\u4e3a，\u4ea7\u54c1\u884c\u4e3a\u6d4b\u8bd5\u4e0d\u5728 scope \u5185。'],
  ['Initialized and populated Dev Cadence task artifacts plus one Harness run evidence directory for dry-run validation. No product files were changed.', '\u5df2\u521d\u59cb\u5316\u5e76\u586b\u5145 Dev Cadence task artifacts \u548c\u4e00\u4e2a Harness run evidence \u76ee\u5f55\u7528\u4e8e dry-run \u9a8c\u8bc1。\u672a\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['No product files were planned.', '\u672a\u8ba1\u5212\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。'],
  ['The dry run stayed inside artifact generation scope and made no product changes.', 'dry run \u4fdd\u6301\u5728 artifact \u751f\u6210 scope \u5185，\u672a\u8fdb\u884c\u4ea7\u54c1\u53d8\u66f4。'],
  ['No product files changed. See run-level diff summary for generated artifact evidence.', '\u672a\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6。\u751f\u6210 artifact \u8bc1\u636e\u89c1 run-level diff summary。'],
  ['The dry-run artifact structure is expected to be machine-checkable. Product behavior remains unverified because no product behavior was implemented.', 'dry-run artifact \u7ed3\u6784\u5e94\u53ef\u88ab\u673a\u5668\u68c0\u67e5。\u7531\u4e8e\u672a\u5b9e\u73b0\u4ea7\u54c1\u884c\u4e3a，\u4ea7\u54c1\u884c\u4e3a\u4ecd\u672a\u9a8c\u8bc1。'],
  ['Reviewed generated dry-run artifacts and Harness evidence. No product code was reviewed because no product files changed.', '\u5df2\u5ba1\u67e5\u751f\u6210\u7684 dry-run artifacts \u548c Harness evidence。\u7531\u4e8e\u672a\u4fee\u6539\u4ea7\u54c1\u6587\u4ef6，\u672a\u5ba1\u67e5\u4ea7\u54c1\u4ee3\u7801。'],
  ['Dry-run evidence is artifact/runtime evidence only, not product acceptance.', 'dry-run \u8bc1\u636e\u53ea\u662f artifact/runtime \u8bc1\u636e，\u4e0d\u662f\u4ea7\u54c1\u9a8c\u6536。'],
  ['accepted the dry-run scope and its residual risk.', '\u5df2\u63a5\u53d7 dry-run scope \u53ca\u5176 residual risk。'],
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
  ['Validate Markdown artifact labels with check-spec-artifacts.mjs', '\u4f7f\u7528 check-spec-artifacts.mjs \u6821\u9a8c Markdown artifact labels'],
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

  writeText(path.join(taskDir, '00-brief.md'), markdownBlock('Brief', {
    task_id: options.taskId,
    requested_by: options.requestedBy,
    date: today(),
    artifact_language: options.artifactLanguage,
    selected_workflow: workflow,
    task_class: taskClass,
    workflow_hint: null,
    goal: options.goal,
  }, `## Why this task exists

Delivery dry run generated by Dev Cadence runtime script.

## Background

This artifact set validates Dev Cadence delivery routing and evidence generation. It is not a product implementation.

## Delivery boundary

- In scope: generated task artifacts and Harness run evidence.
- Out of scope: product source changes and claims about real product behavior.
- Allowed write areas: \`specs/records/${options.taskId}/**\`.
- Forbidden actions: modify product files; claim product verification.

## Initial risks and assumptions

### Risks

- Dry run evidence does not prove product behavior.

### Assumptions

- The initialized repository contract is the input boundary.
- Workflow and task class are inferred from CLI goal text.

## Open questions

${acceptanceBlocked ? '- Final acceptance requires a named Human accepter.' : '- None for accepted dry-run scope.'}

## Notes

Selection reason: ${selectionReason}

## Skipped states

- Product implementation was skipped by design for dry-run validation.`));

  writeText(path.join(taskDir, '01-requirements.md'), markdownBlock('Requirements', {
    status: 'accepted_for_dry_run',
    goal: options.goal,
  }, `## User-facing outcome

The dry run should create a complete, checkable Dev Cadence artifact set without touching product files.

## Scope

### In scope

- Validate delivery runtime artifact generation.
- Generate Harness run evidence for the dry-run execution path.
- Infer workflow and task class from the CLI goal.

### Non-goals

- Modify product source files.
- Claim real product behavior is verified.

### Users / stakeholders

- ${options.requestedBy}

## Acceptance criteria

- [x] Task artifacts are generated from bundled templates.
- [x] Harness run evidence is generated.
- [x] Workflow and task class are inferred.
- [${acceptanceBlocked ? ' ' : 'x'}] Final acceptance is recorded by a named Human accepter.

## Constraints

- Dry run only.
- Keep evidence explicit and path-based.

## Source notes

Generated from CLI inputs and Dev Cadence repository contract.

## Ambiguity Check

Unresolved ambiguity: false
Material to implementation: false
Clarification required: false
Analysis performed:
- Checked initialized repo contract.
- Inferred workflow and task class from goal text.
Evidence paths:
- AGENTS.md
- .dev-cadence.yaml
Candidate interpretations: []
Recommended option: ${workflow}
Clarified by human: ${options.requestedBy}
Clarified at: ${timestamp}
Decision: dry_run_scope

## Requirements Readiness Check

Expected behavior explicit: true
Expected behavior source: CLI --goal
Reference behavior explicit: true
Reference behavior source: Dev Cadence templates and references
Scope confirmed: true
Non goals confirmed: true
Acceptance criteria confirmed: true
Verification approach confirmed: true
Accepted by human: ${options.requestedBy}
Human decision reference: dry_run_cli_input
Ready for implementation: true
Blocking questions: []

## Gate G1

Status: passed
Required inputs:
- 01-requirements.md
Evidence:
- specs/records/${options.taskId}/01-requirements.md
Pass condition: dry_run_requirements_ready
Fail condition: dry_run_scope_unknown
Decision: passed
Human override: null
Residual risk: []
Escalation: none

G1 is treated as passed for the dry-run scope only.`));

  writeText(path.join(taskDir, '02-design.md'), markdownBlock('Design', {
    status: taskClass === 'S2' ? 'required_for_real_work' : 'not_required_for_dry_run',
  }, `## Problem

Validate the delivery runtime without product edits.

## Chosen approach

Generate the minimal task artifacts and Harness evidence using bundled templates, then run artifact and gate checks against the generated record.

## Alternatives considered

| Option | Why not chosen | Risk |
|---|---|---|
| Manual artifact writing | It would not verify the runtime generator path. | Could miss generator regressions. |
| Full product implementation | Dry run scope explicitly avoids product edits. | Would overstate verification. |

## Architecture constraints

- Do not change product files.
- Keep evidence explicit and path-based.

## Affected components

- specs artifacts
- Harness run artifacts

## Data / control flow

- CLI input -> workflow inference -> template initialization -> artifact fill -> gate summary

## Risks

- Dry run cannot verify product behavior.

## Required ADRs

- None for dry-run orchestration.

## Human decisions

- ${options.acceptedBy ? `${options.acceptedBy} accepted dry-run residual risk.` : 'Named Human acceptance is still required.'}

## Rationale

The dry run validates orchestration surfaces before real Worker execution while preserving the boundary that only real delivery work can verify product behavior.

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

  writeText(path.join(taskDir, '04-test-plan.md'), markdownBlock('Test Plan', {
    status: 'complete_for_dry_run',
  }, `## What must be proven

The generated task artifacts and Harness run evidence are present, Markdown-first, and machine-checkable without requiring product file changes.

## Strategy

Use the artifact checker and gate checker as runtime feedback for dry-run scope. Product behavior tests are out of scope because no product behavior is implemented.

## Commands

| Command | Expected result | Covers |
|---|---|---|
| \`node ${path.relative(options.repoDir, path.join(options.pluginDir, 'scripts', 'check-spec-artifacts.mjs'))} specs/records\` | generated artifact structure is checkable | Task artifact schema; Harness evidence schema |
| \`node ${path.relative(options.repoDir, path.join(options.pluginDir, 'scripts', 'check-gates.mjs'))} --task-id ${options.taskId}\` | G3-G6 state matches dry-run scope | Gate summary and Human acceptance path |

## Test data and environment

- Test data: \`specs/records/${options.taskId}\`.
- Environment: local fixture repository.
- Required services or fixtures: initialized Dev Cadence repository contract.

## Coverage targets

- Generated artifacts and run evidence.
- Task artifact schema.
- Harness evidence schema.

## Skipped checks and risk

| Skipped check | Why skipped | Residual risk | Human decision needed? |
|---|---|---|---|
| Product behavior verification | Dry run makes no product changes. | Product behavior remains unverified. | Only if someone wants to treat dry-run evidence as product acceptance. |

## Planned evidence

Generated artifacts plus checker command output.`));

  writeText(path.join(taskDir, '05-implementation.md'), markdownBlock('Implementation', {
    status: 'dry_run_complete',
    scope_reconciliation: 'passed_no_product_changes',
    rationale: 'Validate delivery runtime artifact generation without product edits.',
  }, `## What changed

Initialized and populated Dev Cadence task artifacts plus one Harness run evidence directory for dry-run validation. No product files were changed.

## Planned files

- No product files were planned.

## Changed files

| File | Planned? | Change summary |
|---|---|---|

## Created artifact files

${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

## Scope reconciliation

The dry run stayed inside artifact generation scope and made no product changes.

Unplanned changed files: []
Deleted files: []
Added components: []

## Implementation notes

- Artifact initialization report created ${artifactReport.created.length} files and skipped ${artifactReport.skipped_existing.length} existing files.

## Discipline evidence

### TDD or feedback evidence

Red evidence: null
Green evidence: null
Refactor evidence: null
TDD exception: No product behavior implemented.
Substitute feedback:
- Artifact checker used as validation feedback.

## Verification performed during implementation

Test commands:
- check-spec-artifacts on generated specs directory

Test results:
- pending_until_checker_runs

## Known limitations

- No product behavior is verified.

## Follow-up needed

- Run real delivery workflow for product work.

## Diff summary

No product files changed. See run-level diff summary for generated artifact evidence.

## Harness runs

- ${options.runId}`));

  writeText(path.join(taskDir, '06-test-report.md'), markdownBlock('Test Report', {
    status: 'complete_for_dry_run',
    verification_status: 'partially_verified',
    recommendation: acceptanceBlocked ? 'Block final acceptance until named Human accepts dry-run residual risk.' : 'Accept dry-run scope only.',
  }, `## Verification summary

The dry-run artifact structure is expected to be machine-checkable. Product behavior remains unverified because no product behavior was implemented.

## Commands run

| Command | Result | Evidence |
|---|---|---|
| check-spec-artifacts on generated specs directory | pending_until_checker_runs | specs/records/${options.taskId} |

## Environment

- local fixture repository

## Results

- Artifact structure is expected to be machine-checkable.

## Coverage

Coverage scope:
- Artifact schema
- Harness evidence schema

Changed component coverage:
- No product components changed

## Skipped checks

Skipped component checks:
- Product behavior verification

Skipped checks:
- Product tests were not run because dry run makes no product changes.

## Failures / blockers

Defects: []

## Residual risk

- Dry run evidence cannot prove product behavior.

## Evidence

- specs/records/${options.taskId}

## Gate G4

Status: ${options.acceptedBy ? 'passed' : 'blocked'}
Required inputs:
- 04-test-plan.md
- 06-test-report.md
Evidence:
- specs/records/${options.taskId}
Verification status: partially_verified
Component coverage complete: false
Human override: ${options.acceptedBy || 'null'}
Residual risk:
- Product behavior is not verified.
Escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'dry-run risk accepted by named Human'}`));

  writeText(path.join(taskDir, '07-review-report.md'), markdownBlock('Review Report', {
    status: acceptanceBlocked ? 'blocked_pending_acceptance' : 'approved_for_dry_run_scope',
    decision: acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes',
    scope_reconciliation_reviewed: true,
    verification_coverage_reviewed: true,
  }, `## Review scope

Reviewed generated dry-run artifacts and Harness evidence. No product code was reviewed because no product files changed.

## Evidence reviewed

${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

## Findings

| Severity | Finding | Evidence | Required action |
|---|---|---|---|

No code findings because no product files changed.

## Blockers

Blockers: ${acceptanceBlocked ? '\n- Final acceptance requires a named Human accepter.' : '[]'}

Major issues: []

## Notes

Minor notes:
- Dry run does not verify product behavior.

Security notes:
- None.

Architecture notes:
- Dry-run evidence is artifact/runtime evidence only, not product acceptance.

## Residual risk

- Product behavior remains unverified.

## Gate G5

Status: ${acceptanceBlocked ? 'blocked' : 'passed'}
Required inputs:
- 06-test-report.md
- 07-review-report.md
Evidence:
- specs/records/${options.taskId}
G4 status: ${options.acceptedBy ? 'human_override_for_dry_run' : 'blocked_pending_human_acceptance'}
Scope reconciliation status: passed_no_product_changes
Verification coverage status: product_behavior_not_applicable_to_dry_run
Decision: ${acceptanceBlocked ? 'blocked' : 'approved_with_minor_notes'}
Residual risk:
- Product behavior is not verified.
Escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}`));

  writeText(path.join(taskDir, '08-acceptance.md'), markdownBlock('Acceptance', {
    status: acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope',
    accepted_by_human: options.acceptedBy,
    accepted_at: options.acceptedBy ? timestamp : null,
    merge_or_release_decision: 'not_applicable',
  }, `## Acceptance decision

${options.acceptedBy ? `${options.acceptedBy} accepted the dry-run scope and its residual risk.` : 'A named Human acceptance is still required before G6 can pass.'}

## Accepted scope

${options.acceptedBy ? '- Delivery runtime dry-run artifacts only.' : '- Not accepted yet.'}

## Evidence reviewed

${options.acceptedBy ? [...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n') : '- Pending named Human review.'}

## Human gate decisions

${options.acceptedBy ? `- ${options.acceptedBy} accepted dry-run residual risk.` : '- Pending named Human decision.'}

## Residual risk accepted

${options.acceptedBy ? '- Product behavior not verified by dry run.' : '- Not accepted yet.'}

## Follow-up

- Use real delivery workflow for product implementation.

## Gate G6

Status: ${acceptanceBlocked ? 'blocked' : 'passed'}
Required inputs:
- 08-acceptance.md
Evidence:
- specs/records/${options.taskId}
Human accepter: ${options.acceptedBy || 'null'}
Decision: ${acceptanceBlocked ? 'blocked_pending_named_human' : 'accepted_for_dry_run_scope'}
Residual risk:
- Product behavior is not verified.
Escalation: ${acceptanceBlocked ? 'named Human acceptance required' : 'none'}`));
  writeText(path.join(runDir, 'run-context.md'), markdownBlock('Run Context', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    status: 'dry_run_scope',
  }, `## What this run is allowed to do

Blueprint path: references/supervisor-state-machine.md
Context pack path: specs/records/${options.taskId}/00-brief.md
Workspace path: ${rel(options.repoDir, options.repoDir)}

Allowed read paths:
- AGENTS.md
- .dev-cadence.yaml
- specs/records/**

Allowed write paths:
- specs/records/${options.taskId}/**

Forbidden paths:
- product_source_files

## Tools and environment

Allowed tools:
- node
- filesystem_writes_under_specs

Denied tools:
- network
- production_actions
- database_writes

Network policy: disabled
Secret policy: do_not_request_or_record_secrets
Permission policy: no_elevated_permissions_required

## Required evidence

${runPaths.map((item) => `- ${item}`).join('\n')}

Pre-implementation status path: specs/records/${options.taskId}/runs/${options.runId}/pre-implementation-status.md
Expected artifacts:
${artifactPaths.map((item) => `- ${item}`).join('\n')}

Log paths:
${runPaths.map((item) => `- ${item}`).join('\n')}

## Limits

Budget: local_dry_run
Timeout: not_enforced
Max iterations: 1`));

  writeText(path.join(runDir, 'pre-implementation-status.md'), markdownBlock('Pre-Implementation Status', {
    run_id: options.runId,
    task_id: options.taskId,
    captured_at: timestamp,
    task_class: taskClass,
    selected_workflow: workflow,
    implementation_state: 'not_started_for_product_files',
    implementation_authorized: false,
    authorization_source: 'dry_run_no_product_edits',
    post_hoc_backfill: false,
  }, `## Worktree before implementation

Git status before: []
Untracked files before: []

## Authorized scope

Authorized target files: []
Authorized artifact files:
${artifactPaths.map((item) => `- ${item}`).join('\n')}

## Gate-relevant baseline

G1 status: passed_for_dry_run_scope
G2 status: ${taskClass === 'S2' ? 'not_applicable_no_product_implementation' : 'not_required'}
G3 status: passed_for_dry_run_scope
Requirements ready: true
Blocking questions: []

## Human override, if post-hoc

Override by: null
Override reason: null
Post hoc human override by: null
Post hoc human override reason: null

## Residual risk

Residual risk:
- dry_run_no_product_implementation_authorized`));

  writeText(path.join(runDir, 'execution-report.md'), markdownBlock('Execution Report', {
    run_id: options.runId,
    task_id: options.taskId,
    agent_role: 'Supervisor',
    status: 'delivery_dry_run',
    state: 'delivery_dry_run',
    started_at: timestamp,
    ended_at: timestamp,
  }, `## What happened

Inputs:
- cli_goal
- dev_cadence_repository_contract

Outputs:
${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

## Files changed

| File | Planned? | Change summary |
|---|---|---|

Planned files: []
Planned artifact files:
${artifactPaths.map((item) => `- ${item}`).join('\n')}

Files changed: []
Untracked files: []
Created artifact files:
${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

Unplanned changed files: []
Deleted files: []
Added components: []
Scope reconciliation status: passed_no_product_changes

## Authorization baseline

Pre-implementation status path: specs/records/${options.taskId}/runs/${options.runId}/pre-implementation-status.md
Implementation authorized: false
Post hoc backfill: false

## Artifacts created or updated

${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

## Verification run

Commands run:
- init-task-artifacts.mjs

Tests run:
- check_spec_artifacts_pending_after_generation

Verification status: partially_verified

## Permission activity

Permissions requested: []
Permissions granted: []
Permissions denied: []

## Skipped checks

Skipped checks:
- product_tests_skipped_no_product_implementation

## Errors and blockers

Errors: []

## Residual risk

Residual risk:
- product_behavior_unverified

## Handoff

Handoff target: ${acceptanceBlocked ? 'Human Gate G6' : 'Done for dry-run scope'}`));

  writeText(path.join(runDir, 'tool-log.md'), markdownBlock('Tool Log', {
    run_id: options.runId,
    task_id: options.taskId,
  }, `## Commands and tools used

| Time | Tool/command | Purpose | Result | Evidence path |
|---|---|---|---|---|
| ${timestamp} | init-task-artifacts.mjs | initialize_artifacts | created_or_skipped | specs/records/${options.taskId} |
| ${timestamp} | run-delivery-dry-run.mjs | populate_dry_run_evidence | completed | specs/records/${options.taskId}/runs/${options.runId} |

Commands or tools:
- init-task-artifacts.mjs
- run-delivery-dry-run.mjs

## Notable output

Outputs:
- task_artifacts_populated
- harness_run_evidence_populated

Errors: []
Omissions:
- no_product_tool_execution`));

  writeText(path.join(runDir, 'test-log.md'), markdownBlock('Test Log', {
    run_id: options.runId,
    task_id: options.taskId,
    verification_status: 'partially_verified',
  }, `## Commands run

| Command | Result | Evidence | Covers |
|---|---|---|---|
| check-spec-artifacts.mjs specs/records | pending_external_command_capture | specs/records/${options.taskId} | artifact_schema |

Commands:
- check-spec-artifacts.mjs specs/records

## Environment

- local_fixture_repository

## Results

- pending_external_command_capture

## Skipped checks

Skipped:
- product_test_suite_skipped_by_dry_run_scope

## Failures

Failures: []

## Residual risk

Residual risk:
- product_behavior_unverified`));

  writeText(path.join(runDir, 'diff-summary.md'), markdownBlock('Diff Summary', {
    run_id: options.runId,
    task_id: options.taskId,
    scope_reconciliation_status: 'passed_no_product_changes',
  }, `## Planned changes

Planned files: []
Planned artifact files:
${artifactPaths.map((item) => `- ${item}`).join('\n')}

## Actual changes

Files changed: []
Untracked files: []
Created artifact files:
${[...artifactPaths, ...runPaths].map((item) => `- ${item}`).join('\n')}

Added components: []

## Unplanned changes

Unplanned changed files: []

## Deleted files

Deleted files: []

## Behavior changes

Behavior changes: []

## Non-behavior changes

Non behavior changes:
- generated_delivery_dry_run_artifacts

## Risk areas

Risk notes:
- no_product_behavior_verified

## Rollback notes

- delete_generated_dry_run_artifacts_if_unneeded`));

  writeText(path.join(runDir, 'permission-decisions.md'), markdownBlock('Permission Decisions', {
    run_id: options.runId,
    task_id: options.taskId,
  }, `## Decisions

| Request | Risk | Decision | Decider | Time | Reason |
|---|---|---|---|---|---|

Requests: []
Decisions: []
Conditions:
- no_elevated_permissions_requested

## Deferred or denied requests

Denials: []

## Residual risk

Residual risk: []`));

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
