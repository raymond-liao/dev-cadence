# Run Context

```yaml
run_id: 20260622-1553-reviewer-1
task_id: 20260622-self-check-help
agent_role: Reviewer
blueprint_path: skills/dev-cadence/references/agent-blueprints.md
context_pack_path: specs/20260622-self-check-help/07-review-report.md
workspace_path: /Users/raymond/Desktop/AI/AIA/dev-cadence
allowed_read_paths:
  - .
allowed_write_paths:
  - specs/20260622-self-check-help/**
denied_paths:
  - .git/**
allowed_tools:
  - shell read commands
  - node
  - git diff
  - rg
denied_tools:
  - network
network_policy: restricted
secret_policy: do not read secrets
permission_policy: request approval for destructive actions, network access, or writes outside allowed paths
budget: current turn
timeout: current turn
max_iterations: 1
required_evidence:
  - run-context.md
  - execution-report.md
  - tool-log.md
  - permission-decisions.md
expected_artifacts:
  - specs/20260622-self-check-help/07-review-report.md
log_paths:
  - specs/20260622-self-check-help/runs/20260622-1553-reviewer-1/tool-log.md
```
