# Run Context

```yaml
run_id: 20260622-1820-tester-1
task_id: 20260622-acceptance-guide
agent_role: tester
blueprint_path: skills/dev-cadence/skills/dev-cadence-deliver/SKILL.md
context_pack_path: specs/20260622-acceptance-guide/
workspace_path: /Users/raymond/Desktop/AI/AIA/dev-cadence
allowed_read_paths:
  - docs/acceptance-guide.md
  - skills/dev-cadence/
  - specs/20260622-acceptance-guide/
allowed_write_paths:
  - specs/20260622-acceptance-guide/06-test-report.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-tester-1/
denied_paths:
  - product source files
allowed_tools:
  - node validation scripts
  - git diff/status
  - shell read commands
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
  - test-log.md
expected_artifacts:
  - specs/20260622-acceptance-guide/06-test-report.md
log_paths:
  - specs/20260622-acceptance-guide/runs/20260622-1820-tester-1/test-log.md
```
