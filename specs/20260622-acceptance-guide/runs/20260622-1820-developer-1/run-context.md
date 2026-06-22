# Run Context

```yaml
run_id: 20260622-1820-developer-1
task_id: 20260622-acceptance-guide
agent_role: developer
blueprint_path: skills/dev-cadence/skills/dev-cadence-deliver/SKILL.md
context_pack_path: specs/20260622-acceptance-guide/
workspace_path: /Users/raymond/Desktop/AI/AIA/dev-cadence
allowed_read_paths:
  - README.md
  - docs/
  - skills/dev-cadence/
  - specs/
allowed_write_paths:
  - docs/acceptance-guide.md
  - specs/20260622-acceptance-guide/
denied_paths:
  - product source files
  - skills/dev-cadence runtime behavior files unless verification reveals required fix
allowed_tools:
  - shell read commands
  - node validation scripts
  - apply_patch
  - git diff/status/log
denied_tools:
  - destructive git operations
  - network access
  - production or release actions
network_policy: restricted
secret_policy: do_not_access
permission_policy: require human approval for destructive operations or writes outside planned paths
budget: current session
timeout: current session
max_iterations: 3
required_evidence:
  - run-context.md
  - execution-report.md
  - tool-log.md
  - permission-decisions.md
  - diff-summary.md
  - test-log.md
expected_artifacts:
  - docs/acceptance-guide.md
  - specs/20260622-acceptance-guide/05-implementation.md
  - specs/20260622-acceptance-guide/06-test-report.md
  - specs/20260622-acceptance-guide/07-review-report.md
  - specs/20260622-acceptance-guide/08-acceptance.md
log_paths:
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/tool-log.md
  - specs/20260622-acceptance-guide/runs/20260622-1820-developer-1/test-log.md
```
