export const START_MARKER = '<!-- dev-cadence:start -->';
export const END_MARKER = '<!-- dev-cadence:end -->';
export const EMBEDDED_RUNTIME_DIR = '.dev-cadence';
export const ENTRYPOINT_SKILL = '.dev-cadence/skills/using-dev-cadence/SKILL.md';
export const TARGET_BUNDLE_RUNTIME_PATHS = [
  'skills',
  'references',
  'templates',
  'scripts',
];

export const AGENTS_SECTION = `${START_MARKER}
## AI Delivery Workflow

For implementation, debugging, planning, research, review, verification, acceptance, or commit-related delivery work in this repository, use the repo-embedded Dev Cadence runtime.

Before answering, asking clarification questions, reading files, running commands, editing code, reviewing, verifying, or committing for delivery work, read and apply:

\`${ENTRYPOINT_SKILL}\`

Follow the matching workflow Skill under \`.dev-cadence/skills/\`. Resolve Dev Cadence paths such as \`skills/...\`, \`references/...\`, \`templates/...\`, and \`scripts/...\` relative to \`.dev-cadence/\`. Do not rely on global plugin or Skill auto-discovery for Dev Cadence activation in this repository.

Read root \`.dev-cadence.yaml\` when present for local overrides. It is user-local and ignored by Git by default. Write task artifacts and Harness evidence under \`specs/records/{task_id}/\`. Generated HTML reports live under \`specs/report/\`.

Use direct execution without task specs only for explicitly trivial questions or non-delivery requests.
${END_MARKER}
`;

export const LOCAL_YAML = `# Local Dev Cadence preferences.
# Uncomment and change this value to override generated artifact prose language for your local work.
# Supported values:
# - en: English
# - zh: Chinese, Simplified Chinese by default
# dev_cadence:
#   artifact_language: en
#   specs_dir: specs/records
#   report_dir: specs/report
#   implementation_discipline: default
#   verification_discipline: default
#   review_profile: normal
`;

export function updateAgentsContent(existing) {
  const normalized = existing || '';
  const start = normalized.indexOf(START_MARKER);
  const end = normalized.indexOf(END_MARKER);

  if (start !== -1 && end !== -1 && end > start) {
    const before = normalized.slice(0, start).trimEnd();
    const after = normalized.slice(end + END_MARKER.length).trimStart();
    return [before, AGENTS_SECTION.trimEnd(), after].filter(Boolean).join('\n\n') + '\n';
  }

  if (start !== -1 || end !== -1) {
    return null;
  }

  const prefix = normalized.trimEnd();
  return [prefix, AGENTS_SECTION.trimEnd()].filter(Boolean).join('\n\n') + '\n';
}
