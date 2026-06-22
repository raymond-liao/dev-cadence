# Run Context

```yaml
run_id: 20260622-1553-developer-1
task_id: 20260622-self-check-help
agent_role: Developer
blueprint_path: skills/dev-cadence/references/agent-blueprints.md
context_pack_path: specs/20260622-self-check-help/01-requirements.md
workspace_path: /Users/raymond/Desktop/AI/AIA/dev-cadence
allowed_read_paths:
  - .
allowed_write_paths:
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
  - specs/20260622-self-check-help/**
denied_paths:
  - .git/**
allowed_tools:
  - shell read commands
  - apply_patch
  - node
  - rg
  - git diff
denied_tools:
  - network
network_policy: restricted
secret_policy: do not read secrets
permission_policy: request approval for destructive actions, network access, or writes outside allowed paths
budget: current turn
timeout: current turn
max_iterations: 3
required_evidence:
  - run-context.md
  - execution-report.md
  - tool-log.md
  - permission-decisions.md
  - diff-summary.md
  - test-log.md
expected_artifacts:
  - specs/20260622-self-check-help/05-implementation.md
log_paths:
  - specs/20260622-self-check-help/runs/20260622-1553-developer-1/tool-log.md
  - specs/20260622-self-check-help/runs/20260622-1553-developer-1/test-log.md
```
