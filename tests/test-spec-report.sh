#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(mktemp -d /private/tmp/dev-cadence-report.XXXXXX)"
TASK_ID="acceptance-login"
PENDING_TASK_ID="pending-acceptance"
ZH_TASK_ID="zh-report"
ZH_PENDING_TASK_ID="zh-pending-acceptance"
REPORT_JSON="${REPO_DIR}/report.json"
ZH_REPORT_JSON="${REPO_DIR}/zh-report.json"
trap 'rm -rf "${REPO_DIR}"' EXIT

node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" init --repo-dir "${REPO_DIR}" --json > /dev/null

node "${ROOT_DIR}/scripts/run-delivery-dry-run.mjs" \
  --repo-dir "${REPO_DIR}" \
  --plugin-dir "${ROOT_DIR}" \
  --task-id "${TASK_ID}" \
  --goal "Develop a login feature" \
  --requested-by "Raymond" \
  --accepted-by "Raymond" \
  --json > /dev/null

cp -R "${REPO_DIR}/specs/${TASK_ID}" "${REPO_DIR}/specs/${PENDING_TASK_ID}"
find "${REPO_DIR}/specs/${PENDING_TASK_ID}" -type f -name '*.md' -exec \
  perl -0pi -e "s/${TASK_ID}/${PENDING_TASK_ID}/g; s/Develop a login feature/Await human acceptance/g" {} +
cat > "${REPO_DIR}/specs/${PENDING_TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status:
accepted_by_human:
accepted_at:
accepted_scope:
evidence_reviewed:
human_gate_decisions:
residual_risk_accepted:
merge_or_release_decision:
follow_up:
```

## Gate G6

```yaml
gate_id: G6
status:
required_inputs:
evidence:
human_accepter:
decision:
residual_risk:
escalation:
```
EOF

mkdir -p "${REPO_DIR}/specs/incomplete"
cat > "${REPO_DIR}/specs/incomplete/00-brief.md" <<'EOF'
# Brief

```yaml
task_id: incomplete
goal: Missing downstream evidence should still render as unknown.
selected_workflow: feature-dev
task_class: S1
```
EOF

node "${ROOT_DIR}/scripts/generate-spec-report.mjs" \
  --specs-dir "${REPO_DIR}/specs" \
  --json > "${REPORT_JSON}"

test -f "${REPO_DIR}/specs/index.html"
test -f "${REPO_DIR}/specs/.dev-cadence-report/style.css"
test -f "${REPO_DIR}/specs/${TASK_ID}/index.html"
test -f "${REPO_DIR}/specs/${PENDING_TASK_ID}/index.html"
test -f "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.html"
test -f "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
test -f "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/test-log.html"
test -f "${REPO_DIR}/specs/incomplete/index.html"

grep -q "Dev Cadence Specs Report" "${REPO_DIR}/specs/index.html"
grep -q "${TASK_ID}" "${REPO_DIR}/specs/index.html"
grep -q "${PENDING_TASK_ID}" "${REPO_DIR}/specs/index.html"
grep -q "pending acceptance" "${REPO_DIR}/specs/index.html"
if grep -q "Summary of task artifacts" "${REPO_DIR}/specs/index.html"; then
  echo "index should not include a prose description under the title" >&2
  exit 1
fi
if grep -q "UTC" "${REPO_DIR}/specs/index.html"; then
  echo "dates should render in the local system timezone, not UTC" >&2
  exit 1
fi
if grep -Eq "Generated [0-9]{4}-[0-9]{2}-[0-9]{2}T.*Z" "${REPO_DIR}/specs/index.html"; then
  echo "generated timestamp should render in the local system timezone, not ISO UTC" >&2
  exit 1
fi
if grep -q "Develop a login feature" "${REPO_DIR}/specs/index.html"; then
  echo "index Element column should only show the task link, not the task goal" >&2
  exit 1
fi
if grep -q "Needs Attention" "${REPO_DIR}/specs/index.html"; then
  echo "index should be a compact table, not a dashboard" >&2
  exit 1
fi
if grep -q "Generated view only" "${REPO_DIR}/specs/index.html"; then
  echo "index should not include explanatory notice blocks" >&2
  exit 1
fi
grep -q "class=\"coverage\"" "${REPO_DIR}/specs/index.html"
grep -q ">Element<" "${REPO_DIR}/specs/index.html"
grep -q "class=\"el_task\"" "${REPO_DIR}/specs/index.html"
grep -q "href=\"${TASK_ID}/index.html\" class=\"el_task\"" "${REPO_DIR}/specs/index.html"
grep -q ">Gates<" "${REPO_DIR}/specs/index.html"
grep -q ">Issues<" "${REPO_DIR}/specs/index.html"
grep -q ">Runs<" "${REPO_DIR}/specs/index.html"
grep -q ">Updated<" "${REPO_DIR}/specs/index.html"
grep -q "href=\"incomplete/index.html#issues\"" "${REPO_DIR}/specs/index.html"
grep -q "href=\"${TASK_ID}/index.html#runs\"" "${REPO_DIR}/specs/index.html"
grep -q "class=\"problem-row\"" "${REPO_DIR}/specs/index.html"
grep -q "tr.problem-row" "${REPO_DIR}/specs/.dev-cadence-report/style.css"
grep -q "#ffe1de" "${REPO_DIR}/specs/.dev-cadence-report/style.css"
grep -q "data:image/svg+xml" "${REPO_DIR}/specs/.dev-cadence-report/style.css"
grep -q "text-decoration: underline" "${REPO_DIR}/specs/.dev-cadence-report/style.css"
grep -q "font-size: 1.45rem" "${REPO_DIR}/specs/.dev-cadence-report/style.css"
if grep -q "font-size: clamp" "${REPO_DIR}/specs/.dev-cadence-report/style.css"; then
  echo "report h1 should use compact report sizing, not hero sizing" >&2
  exit 1
fi
if grep -q "background-image: linear-gradient" "${REPO_DIR}/specs/.dev-cadence-report/style.css"; then
  echo "object markers should use icons, not color blocks" >&2
  exit 1
fi
if grep -q ">Artifacts<" "${REPO_DIR}/specs/index.html"; then
  echo "index should keep artifact links on task pages, not as a top-level column" >&2
  exit 1
fi
if grep -q "cell-link" "${REPO_DIR}/specs/index.html"; then
  echo "summary metrics must not be hidden drill-down links" >&2
  exit 1
fi

grep -q "Gate Summary" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "id=\"gate-G1\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "class=\"breadcrumb\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "id=\"breadcrumb\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "Specs Report</a> &gt; <span class=\"el_task\">${TASK_ID}</span>" "${REPO_DIR}/specs/${TASK_ID}/index.html"
if grep -q "class=\"info\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"; then
  echo "task breadcrumb should not show unexplained right-side shortcut icons" >&2
  exit 1
fi
grep -q "class=\"coverage\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "id=\"artifacts\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "id=\"runs\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "id=\"issues\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "class=\"el_artifact\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "class=\"el_run\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "Source Files" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "href=\"01-requirements.html\"" "${REPO_DIR}/specs/${TASK_ID}/index.html"
if grep -q "summary-grid" "${REPO_DIR}/specs/${TASK_ID}/index.html"; then
  echo "task page should use compact report tables, not dashboard cards" >&2
  exit 1
fi
grep -q "G1" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "G6" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "passed" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "href=\"01-requirements.html\">${TASK_ID}/01-requirements.md</a>" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "href=\"08-acceptance.html\" class=\"el_artifact\">08-acceptance.md</a>" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "08-acceptance.md" "${REPO_DIR}/specs/${TASK_ID}/index.html"
grep -q "${TASK_ID}-dry-run-1" "${REPO_DIR}/specs/${TASK_ID}/index.html"

grep -q "Specs Report</a> &gt; <a href=\"index.html\" class=\"el_task\">${TASK_ID}</a> &gt; <span class=\"el_artifact\">08-acceptance.md</span>" "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.html"
grep -q "Raw Markdown" "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.html"
grep -q "href=\"08-acceptance.md\"" "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.html"
grep -q "class=\"source-view\"" "${REPO_DIR}/specs/${TASK_ID}/08-acceptance.html"

grep -q "Run Evidence" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
grep -q "Specs Report</a> &gt; <a href=\"../../index.html\" class=\"el_task\">${TASK_ID}</a> &gt; <span class=\"el_run\">${TASK_ID}-dry-run-1</span>" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
grep -q "pre-implementation-status.md" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
grep -q "href=\"test-log.html\" class=\"el_artifact\">test-log.md</a>" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
grep -q "test-log.md" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"
if grep -q "class=\"info\"" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/index.html"; then
  echo "run breadcrumb should not show unexplained right-side shortcut icons" >&2
  exit 1
fi
grep -q "Specs Report</a> &gt; <a href=\"../../index.html\" class=\"el_task\">${TASK_ID}</a> &gt; <a href=\"index.html\" class=\"el_run\">${TASK_ID}-dry-run-1</a> &gt; <span class=\"el_artifact\">test-log.md</span>" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/test-log.html"
grep -q "Raw Markdown" "${REPO_DIR}/specs/${TASK_ID}/runs/${TASK_ID}-dry-run-1/test-log.html"

grep -q "unknown" "${REPO_DIR}/specs/incomplete/index.html"

ZH_REPORT_REPO="${REPO_DIR}/zh-repo"
mkdir -p "${ZH_REPORT_REPO}"
node "${ROOT_DIR}/scripts/sync-repo-contract.mjs" init --repo-dir "${ZH_REPORT_REPO}" --json > /dev/null
cat > "${ZH_REPORT_REPO}/.dev-cadence.yaml" <<'EOF'
dev_cadence:
  artifact_language: zh
EOF

node "${ROOT_DIR}/scripts/run-delivery-dry-run.mjs" \
  --repo-dir "${ZH_REPORT_REPO}" \
  --plugin-dir "${ROOT_DIR}" \
  --task-id "${ZH_TASK_ID}" \
  --goal "验证中文报告 UI" \
  --requested-by "Raymond" \
  --accepted-by "Raymond" \
  --json > /dev/null

cp -R "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}" "${ZH_REPORT_REPO}/specs/${ZH_PENDING_TASK_ID}"
find "${ZH_REPORT_REPO}/specs/${ZH_PENDING_TASK_ID}" -type f -name '*.md' -exec \
  perl -0pi -e "s/${ZH_TASK_ID}/${ZH_PENDING_TASK_ID}/g; s/验证中文报告 UI/验证中文待验收报告 UI/g" {} +
cat > "${ZH_REPORT_REPO}/specs/${ZH_PENDING_TASK_ID}/08-acceptance.md" <<'EOF'
# Acceptance

```yaml
status:
accepted_by_human:
accepted_at:
accepted_scope:
evidence_reviewed:
human_gate_decisions:
residual_risk_accepted:
merge_or_release_decision:
follow_up:
```

## Gate G6

```yaml
gate_id: G6
status:
required_inputs:
evidence:
human_accepter:
decision:
residual_risk:
escalation:
```
EOF

node "${ROOT_DIR}/scripts/generate-spec-report.mjs" \
  --specs-dir "${ZH_REPORT_REPO}/specs" \
  --json > "${ZH_REPORT_JSON}"

grep -q "任务汇总" "${ZH_REPORT_REPO}/specs/index.html"
grep -q ">问题<" "${ZH_REPORT_REPO}/specs/index.html"
grep -q ">运行<" "${ZH_REPORT_REPO}/specs/index.html"
grep -q "门禁汇总" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"
grep -q "未解决问题" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"
grep -q "源文件" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"
grep -q "原始 Markdown" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/08-acceptance.html"
grep -q "该任务类别不要求" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"
grep -q "最终 Human acceptance 待完成" "${ZH_REPORT_REPO}/specs/${ZH_PENDING_TASK_ID}/index.html"
if grep -q ">Issues<" "${ZH_REPORT_REPO}/specs/index.html"; then
  echo "zh report index must not render the Issues table header in English" >&2
  exit 1
fi
if grep -q "Open Issues" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"; then
  echo "zh report task page must not render the Open Issues heading in English" >&2
  exit 1
fi
if grep -q "not required for task class" "${ZH_REPORT_REPO}/specs/${ZH_TASK_ID}/index.html"; then
  echo "zh report task page must not render known gate evidence in English" >&2
  exit 1
fi
if grep -q "Final Human acceptance is pending" "${ZH_REPORT_REPO}/specs/${ZH_PENDING_TASK_ID}/index.html"; then
  echo "zh report pending acceptance warning must not render in English" >&2
  exit 1
fi

node --input-type=module - "${REPORT_JSON}" "${REPO_DIR}/specs" "${PENDING_TASK_ID}" <<'NODE'
import fs from 'node:fs';
import path from 'node:path';

const report = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const specsDir = process.argv[3];
const pendingTaskId = process.argv[4];

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(report.specs_dir === specsDir, 'report JSON must use requested specs dir');
assert(report.generated_files.includes('index.html'), 'report JSON must list root index');
assert(report.generated_files.includes('acceptance-login/index.html'), 'report JSON must list task page');
assert(report.generated_files.includes('acceptance-login/08-acceptance.html'), 'report JSON must list task artifact page');
assert(report.generated_files.includes('acceptance-login/runs/acceptance-login-dry-run-1/index.html'), 'report JSON must list run page');
assert(report.generated_files.includes('acceptance-login/runs/acceptance-login-dry-run-1/test-log.html'), 'report JSON must list run artifact page');

const login = report.tasks.find((task) => task.task_id === 'acceptance-login');
assert(login, 'report JSON must include dry-run task');
assert(login.gates.G1.status === 'passed', 'report JSON must include canonical G1 gate state');
assert(login.gates.G6.status === 'passed', 'report JSON must include canonical G6 gate state');

const incomplete = report.tasks.find((task) => task.task_id === 'incomplete');
assert(incomplete, 'report JSON must include incomplete task');
assert(incomplete.status === 'unknown', 'incomplete task must render without crashing');

const pending = report.tasks.find((task) => task.task_id === pendingTaskId);
assert(pending, 'report JSON must include pending acceptance task');
assert(pending.status === 'pending_acceptance', 'pending acceptance task must preserve pending status');

const indexHtml = fs.readFileSync(path.join(specsDir, 'index.html'), 'utf8');
const pendingRow = indexHtml.match(new RegExp(`<tr([^>]*)>\\s*<td><a href="${pendingTaskId}/index.html"`));
assert(pendingRow, 'index must include pending acceptance row');
assert(!pendingRow[1].includes('problem-row'), 'pending acceptance alone must not render as a red problem row');
const incompleteRow = indexHtml.match(/<tr([^>]*)>\s*<td><a href="incomplete\/index.html"/);
assert(incompleteRow && incompleteRow[1].includes('problem-row'), 'unknown incomplete task must render as a red problem row');

const generatedHtml = [];
for (const relative of report.generated_files) {
  if (relative.endsWith('.html')) generatedHtml.push(path.join(specsDir, relative));
}

for (const filePath of generatedHtml) {
  const html = fs.readFileSync(filePath, 'utf8');
  const hrefPattern = /href="([^"]+)"/g;
  for (const match of html.matchAll(hrefPattern)) {
    const href = match[1];
    if (href.startsWith('#') || href.startsWith('http:') || href.startsWith('https:') || href.startsWith('mailto:')) {
      continue;
    }
    const withoutHash = href.split('#')[0];
    if (!withoutHash) continue;
    const targetPath = path.resolve(path.dirname(filePath), withoutHash);
    assert(fs.existsSync(targetPath), `${path.relative(specsDir, filePath)} links to missing ${href}`);
  }
}

console.log('spec report ok');
NODE
