#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const CHECK_GATES_SCRIPT = path.join(SCRIPT_DIR, 'check-gates.mjs');
const REPORT_DIR = '.dev-cadence-report';
const STYLE_FILE = 'style.css';

const SPEC_FILES = {
  brief: { fileName: '00-brief.md', title: 'Brief', gate: null },
  requirements: { fileName: '01-requirements.md', title: 'Requirements', gate: 'G1' },
  design: { fileName: '02-design.md', title: 'Design', gate: 'G2' },
  tasks: { fileName: '03-tasks.md', title: 'Tasks', gate: 'G3' },
  testPlan: { fileName: '04-test-plan.md', title: 'Test Plan', gate: null },
  implementation: { fileName: '05-implementation.md', title: 'Implementation', gate: null },
  testReport: { fileName: '06-test-report.md', title: 'Test Report', gate: 'G4' },
  reviewReport: { fileName: '07-review-report.md', title: 'Review Report', gate: 'G5' },
  acceptance: { fileName: '08-acceptance.md', title: 'Acceptance', gate: 'G6' },
};

const RUN_FILES = {
  context: { fileName: 'run-context.md', title: 'Run Context' },
  baseline: { fileName: 'pre-implementation-status.md', title: 'Pre-Implementation Status' },
  execution: { fileName: 'execution-report.md', title: 'Execution Report' },
  toolLog: { fileName: 'tool-log.md', title: 'Tool Log' },
  testLog: { fileName: 'test-log.md', title: 'Test Log' },
  diffSummary: { fileName: 'diff-summary.md', title: 'Diff Summary' },
  permissions: { fileName: 'permission-decisions.md', title: 'Permission Decisions' },
};

const GATE_IDS = ['G1', 'G2', 'G3', 'G4', 'G5', 'G6'];

function printHelp() {
  console.log(`Usage: generate-spec-report.mjs [options]

Generates a static Dev Cadence specs HTML report from existing task artifacts.

Options:
  --specs-dir <dir>    Specs directory. Defaults to specs.
  --json               Print machine-readable JSON report.
  -h, --help           Show this help text.

The generated HTML is a derived browsing view. Markdown and YAML task
artifacts remain the source of truth for gates, review, and acceptance.`);
}

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  printHelp();
  process.exit(0);
}

function parseArgs(argv) {
  const options = {
    specsDir: path.resolve('specs'),
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--specs-dir') {
      options.specsDir = path.resolve(readValue(argv, index, arg));
      index += 1;
    } else if (arg === '--json') {
      options.json = true;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
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

function rel(baseDir, filePath) {
  return path.relative(baseDir, filePath) || '.';
}

function toPosix(relativePath) {
  return relativePath.split(path.sep).join('/');
}

function href(relativePath) {
  return toPosix(relativePath)
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/');
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
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
  if (Array.isArray(value)) return value.filter((item) => item !== '');
  if (value === null || value === undefined || value === '') return [];
  return [value];
}

function nonEmpty(value) {
  if (Array.isArray(value)) return value.length > 0;
  if (value === null || value === undefined) return false;
  if (typeof value === 'boolean') return value;
  return String(value).trim() !== '';
}

function firstNonEmpty(...values) {
  return values.find((value) => nonEmpty(value));
}

function readMarkdown(filePath, specsDir) {
  if (!fs.existsSync(filePath)) {
    return {
      path: filePath,
      relativePath: toPosix(rel(specsDir, filePath)),
      exists: false,
      text: '',
      data: {},
      mtimeMs: 0,
    };
  }

  const text = fs.readFileSync(filePath, 'utf8');
  return {
    path: filePath,
    relativePath: toPosix(rel(specsDir, filePath)),
    exists: true,
    text,
    data: parseTopLevelYaml(firstYamlBlock(text)),
    mtimeMs: fs.statSync(filePath).mtimeMs,
  };
}

function taskDirs(specsDir) {
  if (!fs.existsSync(specsDir)) return [];
  return fs.readdirSync(specsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .filter((entry) => entry.name !== REPORT_DIR)
    .map((entry) => path.join(specsDir, entry.name))
    .filter((dirPath) => fs.existsSync(path.join(dirPath, SPEC_FILES.brief.fileName)))
    .sort();
}

function runDirs(taskDir) {
  const runsDir = path.join(taskDir, 'runs');
  if (!fs.existsSync(runsDir)) return [];
  return fs.readdirSync(runsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => path.join(runsDir, entry.name))
    .sort();
}

function gateReport(specsDir, taskDirName) {
  const fallback = {
    task_id: taskDirName,
    task_dir: taskDirName,
    status: 'unknown',
    pending_acceptance: false,
    gates: {},
    failures: [],
    warnings: [],
  };

  if (!fs.existsSync(CHECK_GATES_SCRIPT)) {
    return {
      ...fallback,
      warnings: [{ gate_id: 'report', message: 'scripts/check-gates.mjs is not available', evidence: [] }],
    };
  }

  const result = spawnSync(
    process.execPath,
    [
      CHECK_GATES_SCRIPT,
      '--specs-dir',
      specsDir,
      '--task-id',
      taskDirName,
      '--allow-pending-acceptance',
      '--json',
    ],
    { encoding: 'utf8' },
  );

  try {
    const parsed = JSON.parse(result.stdout || '{}');
    return {
      ...fallback,
      ...parsed,
      gates: parsed.gates || {},
      failures: parsed.failures || [],
      warnings: parsed.warnings || [],
      checker_status: result.status,
    };
  } catch {
    return {
      ...fallback,
      checker_status: result.status,
      failures: [
        {
          gate_id: 'report',
          message: 'Unable to parse check-gates JSON output',
          evidence: [result.stderr || result.stdout || 'no output'],
        },
      ],
    };
  }
}

function normalizeGates(report) {
  const gates = {};
  for (const gateId of GATE_IDS) {
    gates[gateId] = report.gates[gateId] || { status: 'unknown', evidence: [] };
    gates[gateId].status = String(gates[gateId].status || 'unknown');
    gates[gateId].evidence = asList(gates[gateId].evidence);
  }
  return gates;
}

function buildRun(specsDir, taskDir, runDir) {
  const artifacts = {};
  for (const [key, config] of Object.entries(RUN_FILES)) {
    artifacts[key] = readMarkdown(path.join(runDir, config.fileName), specsDir);
  }

  const context = artifacts.context.data;
  const execution = artifacts.execution.data;
  const baseline = artifacts.baseline.data;
  const runId = firstNonEmpty(context.run_id, execution.run_id, baseline.run_id, path.basename(runDir));
  const mtimeMs = Math.max(0, ...Object.values(artifacts).map((artifact) => artifact.mtimeMs));

  return {
    run_id: String(runId),
    dir_name: path.basename(runDir),
    dir_path: runDir,
    relative_path: toPosix(rel(specsDir, runDir)),
    artifacts,
    agent_role: firstNonEmpty(context.agent_role, execution.agent_role, 'unknown'),
    state: firstNonEmpty(execution.state, 'unknown'),
    verification_status: firstNonEmpty(execution.verification_status, 'unknown'),
    commands_run: asList(execution.commands_run),
    tests_run: asList(execution.tests_run),
    files_changed: asList(execution.files_changed),
    permissions_requested: asList(execution.permissions_requested),
    permissions_granted: asList(execution.permissions_granted),
    residual_risk: [
      ...asList(execution.residual_risk),
      ...asList(baseline.residual_risk),
    ],
    last_updated: mtimeMs,
  };
}

function buildTask(specsDir, taskDir) {
  const artifacts = {};
  for (const [key, config] of Object.entries(SPEC_FILES)) {
    artifacts[key] = readMarkdown(path.join(taskDir, config.fileName), specsDir);
  }

  const dirName = path.basename(taskDir);
  const brief = artifacts.brief.data;
  const requirements = artifacts.requirements.data;
  const tasks = artifacts.tasks.data;
  const implementation = artifacts.implementation.data;
  const testReport = artifacts.testReport.data;
  const reviewReport = artifacts.reviewReport.data;
  const acceptance = artifacts.acceptance.data;
  const report = gateReport(specsDir, dirName);
  const gates = normalizeGates(report);
  const runs = runDirs(taskDir).map((runDir) => buildRun(specsDir, taskDir, runDir));
  const taskId = String(firstNonEmpty(brief.task_id, requirements.task_id, tasks.task_id, dirName));
  const mtimeMs = Math.max(
    0,
    ...Object.values(artifacts).map((artifact) => artifact.mtimeMs),
    ...runs.map((run) => run.last_updated),
  );

  return {
    task_id: taskId,
    dir_name: dirName,
    dir_path: taskDir,
    relative_path: toPosix(rel(specsDir, taskDir)),
    goal: String(firstNonEmpty(brief.goal, requirements.goal, '(no goal recorded)')),
    workflow: String(firstNonEmpty(brief.selected_workflow, tasks.selected_workflow, 'unknown')),
    task_class: String(firstNonEmpty(brief.task_class, tasks.task_class, report.task_class, 'unknown')),
    verification_status: String(firstNonEmpty(testReport.verification_status, implementation.verification_status, 'unknown')),
    review_decision: String(firstNonEmpty(reviewReport.decision, reviewReport.status, 'unknown')),
    acceptance_status: String(firstNonEmpty(acceptance.status, 'unknown')),
    accepted_by: String(firstNonEmpty(acceptance.accepted_by_human, acceptance.accepted_by) || ''),
    changed_files: asList(implementation.changed_files),
    created_artifact_files: asList(implementation.created_artifact_files),
    deleted_files: asList(implementation.deleted_files),
    unplanned_changed_files: asList(implementation.unplanned_changed_files),
    residual_risk: [
      ...asList(implementation.residual_risk),
      ...asList(implementation.known_limitations),
      ...asList(testReport.residual_risk),
      ...asList(reviewReport.residual_risk),
      ...asList(acceptance.residual_risk),
      ...asList(acceptance.residual_risk_accepted),
    ],
    artifacts,
    gates,
    gate_failures: report.failures || [],
    gate_warnings: report.warnings || [],
    gate_checker_status: report.checker_status,
    pending_acceptance: Boolean(report.pending_acceptance),
    runs,
    last_updated: mtimeMs,
  };
}

function taskHasOnlyBrief(task) {
  return Object.entries(task.artifacts)
    .filter(([key]) => key !== 'brief')
    .every(([, artifact]) => !artifact.exists);
}

function deriveStatus(task) {
  if (taskHasOnlyBrief(task)) return 'unknown';
  const gateStatuses = Object.values(task.gates).map((gate) => gate.status.toLowerCase());
  if (gateStatuses.some((status) => ['failed', 'blocked'].includes(status))) return 'blocked';
  if (task.gate_failures.length > 0) return 'blocked';
  if (task.pending_acceptance) return 'pending_acceptance';
  if (task.gates.G6.status.toLowerCase() === 'passed') return 'accepted';
  if (String(task.review_decision).toLowerCase().includes('approved')) return 'reviewed';
  if (String(task.verification_status).toLowerCase().includes('verified')) return 'verified';
  if (task.artifacts.implementation.exists && nonEmpty(task.artifacts.implementation.data.status)) return 'implemented';
  return 'unknown';
}

function statusRank(status) {
  const ranks = {
    blocked: 0,
    failed: 0,
    unknown: 1,
    pending_acceptance: 2,
    implemented: 3,
    verified: 4,
    reviewed: 5,
    accepted: 6,
  };
  return ranks[status] ?? 1;
}

function statusLabel(status) {
  return String(status).replaceAll('_', ' ');
}

function statusClass(status) {
  const normalized = String(status || 'unknown').toLowerCase();
  if (['passed', 'accepted', 'verified', 'reviewed', 'approved'].includes(normalized)) return 'ok';
  if (['failed', 'blocked', 'rejected', 'changes_requested'].includes(normalized)) return 'bad';
  if (['warning', 'pending', 'pending_acceptance', 'implemented'].includes(normalized)) return 'warn';
  if (normalized === 'skipped') return 'skip';
  return 'unknown';
}

function badge(status, label = status) {
  return `<span class="badge badge-${statusClass(status)}">${escapeHtml(label ?? status ?? 'unknown')}</span>`;
}

function listHtml(items, emptyText = 'none') {
  const values = asList(items);
  if (values.length === 0) return `<span class="muted">${escapeHtml(emptyText)}</span>`;
  return `<ul class="compact-list">${values.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul>`;
}

function inlineList(items, emptyText = 'none') {
  const values = asList(items);
  if (values.length === 0) return `<span class="muted">${escapeHtml(emptyText)}</span>`;
  return values.map((item) => `<code>${escapeHtml(item)}</code>`).join(' ');
}

function formatDate(mtimeMs) {
  if (!mtimeMs) return 'unknown';
  const date = new Date(mtimeMs);
  const pad = (value) => String(value).padStart(2, '0');
  const offsetMinutes = -date.getTimezoneOffset();
  const sign = offsetMinutes >= 0 ? '+' : '-';
  const absoluteOffset = Math.abs(offsetMinutes);
  const offset = `${sign}${pad(Math.floor(absoluteOffset / 60))}:${pad(absoluteOffset % 60)}`;
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())} ${offset}`;
}

function htmlFileName(fileName) {
  return `${fileName.replace(/\.md$/i, '')}.html`;
}

function page(title, stylesheetHref, body) {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <link rel="stylesheet" href="${escapeHtml(stylesheetHref)}">
</head>
<body>
${body}
</body>
</html>
`;
}

function sourceNotice() {
  return `<aside class="notice">
  Generated view only. Markdown and YAML artifacts remain the source of truth for gates, review, and Human acceptance.
</aside>`;
}

function taskIssueCount(task) {
  return blockingIssues(task).length;
}

function isPendingAcceptanceWarning(issue) {
  return issue.gate_id === 'G6'
    && String(issue.message || '').includes('Final Human acceptance is pending');
}

function blockingIssues(task) {
  return [
    ...task.gate_failures,
    ...task.gate_warnings.filter((warning) => !isPendingAcceptanceWarning(warning)),
  ];
}

function taskNeedsAttention(task) {
  const gateStatuses = Object.values(task.gates).map((gate) => String(gate.status || 'unknown').toLowerCase());
  return blockingIssues(task).length > 0
    || ['blocked', 'unknown'].includes(task.status)
    || gateStatuses.some((status) => ['failed', 'blocked', 'unknown'].includes(status));
}

function gateSummary(task) {
  const clearCount = GATE_IDS.filter((gateId) => {
    const status = String(task.gates[gateId]?.status || 'unknown').toLowerCase();
    return ['passed', 'skipped'].includes(status);
  }).length;
  return `${clearCount}/${GATE_IDS.length} clear`;
}

function renderIndex(specsDir, tasks) {
  const rows = tasks.map((task) => {
    const taskHref = href(path.join(task.dir_name, 'index.html'));
    const issueCount = taskIssueCount(task);
    const rowClass = taskNeedsAttention(task) ? ' class="problem-row"' : '';
    const issueCell = issueCount > 0
      ? `<a href="${taskHref}#issues" class="count-link el_issue">${issueCount} issue${issueCount === 1 ? '' : 's'}</a>`
      : '<span class="muted">none</span>';
    const runCell = task.runs.length > 0
      ? `<a href="${taskHref}#runs" class="count-link el_run">${task.runs.length} run${task.runs.length === 1 ? '' : 's'}</a>`
      : '<span class="muted">none</span>';
    return `<tr${rowClass}>
    <td><a href="${taskHref}" class="el_task"><strong>${escapeHtml(task.task_id)}</strong></a></td>
    <td>${badge(task.status, statusLabel(task.status))}</td>
    <td><a href="${taskHref}" class="count-link">${escapeHtml(gateSummary(task))}</a></td>
    <td>${issueCell}</td>
    <td>${runCell}</td>
    <td>${formatDate(task.last_updated)}</td>
  </tr>`;
  }).join('');

  const content = `<main class="page-shell">
  <header class="page-header">
    <p class="eyebrow">Dev Cadence</p>
    <h1>Dev Cadence Specs Report</h1>
  </header>
  <section class="panel">
    <div class="section-heading">
      <h2>Task Summary</h2>
      <span class="muted">Generated ${escapeHtml(formatDate(Date.now()))}</span>
    </div>
    <div class="table-wrap">
      <table class="coverage">
        <thead>
          <tr>
            <th>Element</th>
            <th>Status</th>
            <th>Gates</th>
            <th>Issues</th>
            <th>Runs</th>
            <th>Updated</th>
          </tr>
        </thead>
        <tbody>
          ${rows || '<tr><td colspan="6" class="empty">No task artifacts found.</td></tr>'}
        </tbody>
      </table>
    </div>
  </section>
</main>`;

  return page('Dev Cadence Specs Report', href(path.join(REPORT_DIR, STYLE_FILE)), content);
}

function artifactRows(task, fromDir) {
  return Object.entries(SPEC_FILES).map(([key, config]) => {
    const artifact = task.artifacts[key];
    const link = artifact.exists
      ? `<a href="${href(htmlFileName(config.fileName))}" class="el_artifact">${escapeHtml(config.fileName)}</a>`
      : `<span class="muted">${escapeHtml(config.fileName)}</span>`;
    return `<tr>
      <td>${link}</td>
      <td>${config.gate ? escapeHtml(config.gate) : '<span class="muted">n/a</span>'}</td>
      <td>${artifact.exists ? formatDate(artifact.mtimeMs) : '<span class="muted">missing</span>'}</td>
    </tr>`;
  }).join('');
}

function gateRows(task, fromDir, specsDir) {
  return GATE_IDS.map((gateId) => {
    const gate = task.gates[gateId] || { status: 'unknown', evidence: [] };
    const issues = [
      ...task.gate_failures.filter((failure) => failure.gate_id === gateId),
      ...task.gate_warnings.filter((warning) => warning.gate_id === gateId),
    ];
    const blocking = issues.filter((issue) => !isPendingAcceptanceWarning(issue));
    const evidence = asList(gate.evidence)
      .map((item) => evidenceLink(item, fromDir, specsDir))
      .join('') || '<span class="muted">none</span>';
    const status = String(gate.status || 'unknown').toLowerCase();
    const rowClass = blocking.length > 0 || ['failed', 'blocked', 'unknown'].includes(status)
      ? ' class="problem-row"'
      : '';
    return `<tr id="gate-${gateId}"${rowClass}>
      <td><strong>${gateId}</strong></td>
      <td>${badge(gate.status)}</td>
      <td>${evidence}</td>
      <td>${issues.length ? listHtml(issues.map((issue) => issue.message)) : '<span class="muted">none</span>'}</td>
    </tr>`;
  }).join('');
}

function evidenceLink(item, fromDir, specsDir) {
  const text = String(item);
  const candidate = path.join(specsDir, text);
  if (fs.existsSync(candidate)) {
    const target = text.endsWith('.md')
      ? path.join(path.dirname(candidate), htmlFileName(path.basename(candidate)))
      : candidate;
    return `<a class="source-link" href="${href(path.relative(fromDir, target))}">${escapeHtml(text)}</a>`;
  }
  return `<span class="source-link muted">${escapeHtml(text)}</span>`;
}

function runRows(task) {
  if (task.runs.length === 0) {
    return '<tr><td colspan="5" class="empty">No run evidence directories found.</td></tr>';
  }
  return task.runs.map((run) => `<tr>
    <td><a href="${href(path.join('runs', run.dir_name, 'index.html'))}" class="el_run"><strong>${escapeHtml(run.run_id)}</strong></a></td>
    <td>${escapeHtml(run.agent_role)}</td>
    <td>${escapeHtml(run.state)}</td>
    <td>${escapeHtml(run.verification_status)}</td>
    <td>${formatDate(run.last_updated)}</td>
  </tr>`).join('');
}

function issueRows(task, fromDir, specsDir) {
  const issues = blockingIssues(task);
  if (issues.length === 0) {
    return '<tr><td colspan="3" class="empty">No open gate issues.</td></tr>';
  }

  return issues.map((issue) => {
    const evidence = asList(issue.evidence)
      .map((item) => evidenceLink(item, fromDir, specsDir))
      .join('') || '<span class="muted">none</span>';
    return `<tr class="problem-row">
      <td><span class="el_issue">${escapeHtml(issue.gate_id || 'report')}</span></td>
      <td>${escapeHtml(issue.message || 'unknown issue')}</td>
      <td>${evidence}</td>
    </tr>`;
  }).join('');
}

function renderTaskArtifact(task, config, artifact) {
  const content = `<main class="page-shell">
  <div class="breadcrumb" id="breadcrumb"><a href="../index.html" class="el_report">Specs Report</a> &gt; <a href="index.html" class="el_task">${escapeHtml(task.task_id)}</a> &gt; <span class="el_artifact">${escapeHtml(config.fileName)}</span></div>
  <header class="page-header">
    <p class="eyebrow">Artifact Detail</p>
    <h1>${escapeHtml(config.title)}</h1>
    <div class="status-line"><a href="${href(config.fileName)}" class="el_artifact">Raw Markdown</a><span class="muted">Updated ${formatDate(artifact.mtimeMs)}</span></div>
  </header>
  <section class="panel">
    <pre class="source-view"><code>${escapeHtml(artifact.text)}</code></pre>
  </section>
</main>`;

  return page(`${task.task_id} / ${config.fileName} - Dev Cadence Specs Report`, href(path.join('..', REPORT_DIR, STYLE_FILE)), content);
}

function renderTask(specsDir, task) {
  const fromDir = task.dir_path;

  const content = `<main class="page-shell">
  <div class="breadcrumb" id="breadcrumb"><a href="../index.html" class="el_report">Specs Report</a> &gt; <span class="el_task">${escapeHtml(task.task_id)}</span></div>
  <header class="page-header">
    <p class="eyebrow">Task Detail</p>
    <h1>${escapeHtml(task.task_id)}</h1>
    <p class="lede">${escapeHtml(task.goal)}</p>
    <div class="status-line">${badge(task.status, statusLabel(task.status))}<span class="muted">Updated ${formatDate(task.last_updated)}</span></div>
  </header>
  <section class="panel">
    <div class="section-heading"><h2>Gate Summary</h2><span class="muted">${escapeHtml(gateSummary(task))}</span></div>
    <div class="table-wrap">
      <table class="coverage">
        <thead><tr><th>Gate</th><th>Status</th><th>Evidence</th><th>Issues</th></tr></thead>
        <tbody>${gateRows(task, fromDir, specsDir)}</tbody>
      </table>
    </div>
  </section>
  <section class="panel" id="artifacts">
    <div class="section-heading"><h2>Source Files</h2></div>
    <div class="table-wrap">
      <table class="coverage">
        <thead><tr><th>Element</th><th>Gate</th><th>Updated</th></tr></thead>
        <tbody>${artifactRows(task, fromDir)}</tbody>
      </table>
    </div>
  </section>
  <section class="panel" id="runs">
    <div class="section-heading"><h2>Runs</h2><span class="muted">${task.runs.length} run(s)</span></div>
    <div class="table-wrap">
      <table class="coverage">
        <thead><tr><th>Run</th><th>Role</th><th>State</th><th>Verification</th><th>Updated</th></tr></thead>
        <tbody>${runRows(task)}</tbody>
      </table>
    </div>
  </section>
  <section class="panel" id="issues">
    <div class="section-heading"><h2>Open Issues</h2><span class="muted">${taskIssueCount(task)} issue(s)</span></div>
    <div class="table-wrap">
      <table class="coverage">
        <thead><tr><th>Gate</th><th>Issue</th><th>Evidence</th></tr></thead>
        <tbody>${issueRows(task, fromDir, specsDir)}</tbody>
      </table>
    </div>
  </section>
</main>`;

  return page(`${task.task_id} - Dev Cadence Specs Report`, href(path.join('..', REPORT_DIR, STYLE_FILE)), content);
}

function renderRunArtifact(task, run, config, artifact) {
  const content = `<main class="page-shell">
  <div class="breadcrumb" id="breadcrumb"><a href="../../../index.html" class="el_report">Specs Report</a> &gt; <a href="../../index.html" class="el_task">${escapeHtml(task.task_id)}</a> &gt; <a href="index.html" class="el_run">${escapeHtml(run.run_id)}</a> &gt; <span class="el_artifact">${escapeHtml(config.fileName)}</span></div>
  <header class="page-header">
    <p class="eyebrow">Run Artifact Detail</p>
    <h1>${escapeHtml(config.title)}</h1>
    <div class="status-line"><a href="${href(config.fileName)}" class="el_artifact">Raw Markdown</a><span class="muted">Updated ${formatDate(artifact.mtimeMs)}</span></div>
  </header>
  <section class="panel">
    <pre class="source-view"><code>${escapeHtml(artifact.text)}</code></pre>
  </section>
</main>`;

  return page(`${run.run_id} / ${config.fileName} - Dev Cadence Specs Report`, href(path.join('..', '..', '..', REPORT_DIR, STYLE_FILE)), content);
}

function runArtifactRows(run, fromDir) {
  return Object.entries(RUN_FILES).map(([key, config]) => {
    const artifact = run.artifacts[key];
    const link = artifact.exists
      ? `<a href="${href(htmlFileName(config.fileName))}" class="el_artifact">${escapeHtml(config.fileName)}</a>`
      : `<span class="muted">${escapeHtml(config.fileName)}</span>`;
    return `<tr>
      <td>${link}</td>
      <td>${artifact.exists ? formatDate(artifact.mtimeMs) : '<span class="muted">missing</span>'}</td>
    </tr>`;
  }).join('');
}

function renderRun(run, task) {
  const fromDir = run.dir_path;
  const execution = run.artifacts.execution.data;
  const baseline = run.artifacts.baseline.data;
  const permissions = [
    ...asList(execution.permissions_requested),
    ...asList(execution.permissions_granted),
    ...asList(execution.permissions_denied),
  ];

  const content = `<main class="page-shell">
  <div class="breadcrumb" id="breadcrumb"><a href="../../../index.html" class="el_report">Specs Report</a> &gt; <a href="../../index.html" class="el_task">${escapeHtml(task.task_id)}</a> &gt; <span class="el_run">${escapeHtml(run.run_id)}</span></div>
  <header class="page-header">
    <p class="eyebrow">Run Detail</p>
    <h1>${escapeHtml(run.run_id)}</h1>
    <p class="lede">Harness evidence for ${escapeHtml(task.task_id)}.</p>
    <div class="status-line">${badge(run.verification_status)}<span class="muted">Updated ${formatDate(run.last_updated)}</span></div>
  </header>
  ${sourceNotice()}
  <section class="summary-grid" aria-label="Run summary">
    <div class="metric"><span class="metric-value text">${escapeHtml(run.agent_role)}</span><span class="metric-label">Role</span></div>
    <div class="metric"><span class="metric-value text">${escapeHtml(run.state)}</span><span class="metric-label">State</span></div>
    <div class="metric"><span class="metric-value text">${escapeHtml(run.verification_status)}</span><span class="metric-label">Verification</span></div>
    <div class="metric"><span class="metric-value text">${permissions.length}</span><span class="metric-label">Permission Entries</span></div>
  </section>
  <section class="panel" id="run-evidence">
    <div class="section-heading"><h2>Run Evidence</h2></div>
    <div class="table-wrap">
      <table class="coverage">
        <thead><tr><th>Element</th><th>Updated</th></tr></thead>
        <tbody>${runArtifactRows(run, fromDir)}</tbody>
      </table>
    </div>
  </section>
  <section class="two-column" id="commands">
    <div class="panel">
      <h2>Commands and Tests</h2>
      <h3>Commands</h3>
      ${listHtml(run.commands_run)}
      <h3>Tests</h3>
      ${listHtml(run.tests_run)}
    </div>
    <div class="panel">
      <h2>Files Changed</h2>
      ${listHtml(run.files_changed)}
    </div>
  </section>
  <section class="two-column">
    <div class="panel">
      <h2>Baseline</h2>
      <dl class="kv">
        <dt>Authorized</dt><dd>${escapeHtml(firstNonEmpty(baseline.implementation_authorized, 'unknown'))}</dd>
        <dt>Post-hoc Backfill</dt><dd>${escapeHtml(firstNonEmpty(baseline.post_hoc_backfill, 'unknown'))}</dd>
        <dt>G1</dt><dd>${escapeHtml(firstNonEmpty(baseline.g1_status, 'unknown'))}</dd>
        <dt>G3</dt><dd>${escapeHtml(firstNonEmpty(baseline.g3_status, 'unknown'))}</dd>
      </dl>
    </div>
    <div class="panel">
      <h2>Residual Risk</h2>
      ${listHtml(run.residual_risk)}
    </div>
  </section>
  <section class="panel">
    <h2>Permissions</h2>
    ${permissions.length ? inlineList(permissions) : '<span class="muted">none</span>'}
  </section>
</main>`;

  return page(`${run.run_id} - Dev Cadence Specs Report`, href(path.join('..', '..', '..', REPORT_DIR, STYLE_FILE)), content);
}

function stylesheet() {
  return `:root {
  color-scheme: light;
  --bg: #f7f8fa;
  --panel: #ffffff;
  --text: #17202a;
  --muted: #657282;
  --line: #d8dee8;
  --line-strong: #b8c1cf;
  --accent: #0f766e;
  --accent-dark: #115e59;
  --ok-bg: #dff4e6;
  --ok-fg: #17633b;
  --warn-bg: #fff0c2;
  --warn-fg: #7a4b00;
  --bad-bg: #ffe1de;
  --bad-fg: #a33125;
  --skip-bg: #eef1f5;
  --skip-fg: #576271;
  --unknown-bg: #edf0f4;
  --unknown-fg: #47505e;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font: 14px/1.5 ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

a {
  color: var(--accent-dark);
  text-decoration: underline;
  text-underline-offset: 2px;
}

a:hover {
  color: var(--accent);
}

code {
  border: 1px solid var(--line);
  border-radius: 4px;
  background: #f3f5f8;
  padding: 0.1rem 0.3rem;
  font-size: 0.9em;
}

.page-shell {
  width: min(1320px, calc(100vw - 32px));
  margin: 0 auto;
  padding: 28px 0 48px;
}

.page-header {
  margin-bottom: 18px;
}

.eyebrow {
  margin: 0 0 4px;
  color: var(--accent-dark);
  font-weight: 700;
  text-transform: uppercase;
  font-size: 0.74rem;
  letter-spacing: 0;
}

h1 {
  margin: 0;
  font-size: 1.45rem;
  line-height: 1.2;
  letter-spacing: 0;
}

h2 {
  margin: 0 0 14px;
  font-size: 1.05rem;
}

h3 {
  margin: 18px 0 8px;
  font-size: 0.94rem;
}

.lede {
  max-width: 880px;
  margin: 10px 0 0;
  color: var(--muted);
  font-size: 1rem;
}

.breadcrumb {
  min-height: 28px;
  border: 1px solid var(--line-strong);
  border-radius: 3px;
  background: #fff;
  padding: 4px 8px;
  margin-bottom: 18px;
  color: var(--muted);
  overflow: hidden;
}

.notice {
  border: 1px solid #b7d9d4;
  border-left: 4px solid var(--accent);
  border-radius: 6px;
  background: #ecf8f6;
  color: #164e47;
  padding: 12px 14px;
  margin: 18px 0;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin: 18px 0;
}

.metric,
.panel {
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.metric {
  padding: 16px;
  min-width: 0;
}

.metric-value {
  display: block;
  font-size: 2rem;
  font-weight: 760;
  line-height: 1.05;
}

.metric-value.text {
  font-size: 1rem;
  line-height: 1.2;
  overflow-wrap: anywhere;
}

.metric-label,
.muted,
.subtle {
  color: var(--muted);
}

.metric-label {
  display: block;
  margin-top: 5px;
  font-size: 0.82rem;
}

.panel {
  padding: 18px;
  margin-top: 16px;
}

.section-heading {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: baseline;
}

.two-column {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.table-wrap {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  min-width: 760px;
}

table.coverage tbody tr:hover {
  background: #f7f7df;
}

table.coverage tbody tr.problem-row {
  background: #ffe1de;
}

table.coverage tbody tr.problem-row:hover {
  background: #ffd2cc;
}

th,
td {
  border-bottom: 1px solid var(--line);
  padding: 10px 8px;
  text-align: left;
  vertical-align: top;
}

th {
  color: #3f4b59;
  font-size: 0.76rem;
  text-transform: uppercase;
}

tr:last-child td {
  border-bottom: 0;
}

.badge,
.gate-pill {
  display: inline-flex;
  align-items: center;
  border-radius: 999px;
  padding: 0.22rem 0.55rem;
  font-size: 0.78rem;
  font-weight: 700;
  white-space: nowrap;
}

.badge-ok,
.gate-ok {
  background: var(--ok-bg);
  color: var(--ok-fg);
}

.badge-warn,
.gate-warn {
  background: var(--warn-bg);
  color: var(--warn-fg);
}

.badge-bad,
.gate-bad {
  background: var(--bad-bg);
  color: var(--bad-fg);
}

.badge-skip,
.gate-skip {
  background: var(--skip-bg);
  color: var(--skip-fg);
}

.badge-unknown,
.gate-unknown {
  background: var(--unknown-bg);
  color: var(--unknown-fg);
}

.gate-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  min-width: 260px;
}

.gate-pill {
  gap: 5px;
  border-radius: 6px;
}

.gate-pill span {
  opacity: 0.8;
}

.status-line {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  margin-top: 14px;
}

.compact-list {
  margin: 0;
  padding-left: 1.2rem;
}

.compact-list li + li {
  margin-top: 3px;
}

.kv {
  display: grid;
  grid-template-columns: max-content minmax(0, 1fr);
  gap: 8px 18px;
  margin: 0;
}

.kv dt {
  color: var(--muted);
}

.kv dd {
  margin: 0;
  overflow-wrap: anywhere;
}

.source-link {
  display: inline-block;
  margin: 0 6px 4px 0;
}

.source-view {
  margin: 0;
  overflow-x: auto;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  font: 0.88rem/1.55 ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
}

.count-link {
  color: var(--accent-dark);
  font-weight: 700;
  white-space: nowrap;
}

.el_report,
.el_task,
.el_artifact,
.el_run,
.el_issue {
  padding-left: 20px;
  background-position: left center;
  background-repeat: no-repeat;
  background-size: 14px 14px;
}

.el_report {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Crect x='1' y='1' width='12' height='12' rx='1' fill='%23f5f7fb' stroke='%237b8794'/%3E%3Crect x='3' y='8' width='2' height='3' fill='%232b6cb0'/%3E%3Crect x='6' y='5' width='2' height='6' fill='%232b6cb0'/%3E%3Crect x='9' y='3' width='2' height='8' fill='%232b6cb0'/%3E%3C/svg%3E");
}

.el_task {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Crect x='3' y='2' width='8' height='11' rx='1' fill='%23ffffff' stroke='%230b5f58'/%3E%3Crect x='5' y='1' width='4' height='3' rx='1' fill='%230f766e'/%3E%3Cpath d='M5 6.5l1 1 2-2' fill='none' stroke='%230f766e' stroke-width='1.2' stroke-linecap='round' stroke-linejoin='round'/%3E%3Cpath d='M5 10h4' stroke='%230f766e' stroke-width='1.1' stroke-linecap='round'/%3E%3C/svg%3E");
}

.el_artifact {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Cpath d='M3 1h5l3 3v9H3z' fill='%23ffffff' stroke='%236b7280'/%3E%3Cpath d='M8 1v4h3' fill='%23d7dde5'/%3E%3Cpath d='M5 7h5M5 9h5M5 11h4' stroke='%236b7280' stroke-width='1'/%3E%3C/svg%3E");
}

.el_run {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Ccircle cx='7' cy='7' r='6' fill='%237c3aed'/%3E%3Cpath d='M5.5 4.2v5.6L10 7z' fill='%23ffffff'/%3E%3C/svg%3E");
}

.el_issue {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Cpath d='M7 1l6 11H1z' fill='%23dc2626'/%3E%3Crect x='6.4' y='4.5' width='1.2' height='4.2' fill='%23ffffff'/%3E%3Ccircle cx='7' cy='10.3' r='.7' fill='%23ffffff'/%3E%3C/svg%3E");
}

.empty {
  color: var(--muted);
  text-align: center;
  padding: 28px;
}

@media (max-width: 860px) {
  .summary-grid,
  .two-column {
    grid-template-columns: 1fr;
  }

  .page-shell {
    width: min(100vw - 20px, 1320px);
    padding-top: 18px;
  }

  .section-heading {
    display: block;
  }
}
`;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function writeFile(filePath, content, specsDir, generated) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content);
  generated.push(toPosix(rel(specsDir, filePath)));
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(options.specsDir)) {
    throw new Error(`Specs directory does not exist: ${options.specsDir}`);
  }

  const generated = [];
  const tasks = taskDirs(options.specsDir)
    .map((taskDir) => buildTask(options.specsDir, taskDir))
    .map((task) => ({ ...task, status: deriveStatus(task) }))
    .sort((left, right) => {
      const rankDiff = statusRank(left.status) - statusRank(right.status);
      if (rankDiff !== 0) return rankDiff;
      return right.last_updated - left.last_updated;
    });

  writeFile(path.join(options.specsDir, REPORT_DIR, STYLE_FILE), stylesheet(), options.specsDir, generated);
  writeFile(path.join(options.specsDir, 'index.html'), renderIndex(options.specsDir, tasks), options.specsDir, generated);

  for (const task of tasks) {
    writeFile(path.join(task.dir_path, 'index.html'), renderTask(options.specsDir, task), options.specsDir, generated);
    for (const [key, config] of Object.entries(SPEC_FILES)) {
      const artifact = task.artifacts[key];
      if (artifact.exists) {
        writeFile(
          path.join(task.dir_path, htmlFileName(config.fileName)),
          renderTaskArtifact(task, config, artifact),
          options.specsDir,
          generated,
        );
      }
    }
    for (const run of task.runs) {
      writeFile(path.join(run.dir_path, 'index.html'), renderRun(run, task), options.specsDir, generated);
      for (const [key, config] of Object.entries(RUN_FILES)) {
        const artifact = run.artifacts[key];
        if (artifact.exists) {
          writeFile(
            path.join(run.dir_path, htmlFileName(config.fileName)),
            renderRunArtifact(task, run, config, artifact),
            options.specsDir,
            generated,
          );
        }
      }
    }
  }

  const report = {
    specs_dir: options.specsDir,
    generated_at: new Date().toISOString(),
    generated_files: generated.sort(),
    tasks: tasks.map((task) => ({
      task_id: task.task_id,
      task_dir: task.dir_name,
      status: task.status,
      goal: task.goal,
      workflow: task.workflow,
      task_class: task.task_class,
      verification_status: task.verification_status,
      review_decision: task.review_decision,
      acceptance_status: task.acceptance_status,
      accepted_by: task.accepted_by,
      gates: task.gates,
      gate_failures: task.gate_failures,
      gate_warnings: task.gate_warnings,
      runs: task.runs.map((run) => ({
        run_id: run.run_id,
        run_dir: run.relative_path,
        agent_role: run.agent_role,
        state: run.state,
        verification_status: run.verification_status,
      })),
    })),
  };

  if (options.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`Specs report: ${path.join(options.specsDir, 'index.html')}`);
    console.log(`Tasks: ${tasks.length}`);
    console.log(`Generated files: ${generated.length}`);
  }
}

try {
  main();
} catch (error) {
  console.error(`ERROR ${error.message}`);
  process.exit(1);
}
