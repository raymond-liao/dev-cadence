# Run Context

```yaml
run_id: 20260622-1820-reviewer-1
task_id: 20260622-acceptance-guide
agent_role: reviewer
blueprint_path: skills/dev-cadence/references/review-discipline.md
context_pack_path: specs/20260622-acceptance-guide/
workspace_path: /Users/raymond/Desktop/AI/AIA/dev-cadence
allowed_read_paths:
  - docs/acceptance-guide.md
  - specs/20260622-acceptance-guide/
  - skills/dev-cadence/references/review-discipline.md
allowed_write_paths:
  - specs/20260622-acceptance-guide/07-review-report.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-reviewer-1/
denied_paths:
  - product source files
allowed_tools:
  - shell read commands
  - node validation scripts
  - git status/diff
denied_tools:
  - destructive operations
network_policy: restricted
secret_policy: do_not_access
permission_policy: no escalations requested
budget: current session
timeout: current session
max_iterations: 1
required_evidence:
  - run-context.md
  - execution-report.md
  - tool-log.md
  - permission-decisions.md
expected_artifacts:
  - specs/20260622-acceptance-guide/07-review-report.md
log_paths:
  - specs/20260622-acceptance-guide/runs/20260622-1820-reviewer-1/tool-log.md
```
