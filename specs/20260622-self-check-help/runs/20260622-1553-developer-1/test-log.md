# Test Log

```yaml
run_id: 20260622-1553-developer-1
commands:
  - command: node skills/dev-cadence/scripts/check-skill-package.mjs --help
    phase: RED
    exit_code: 2
    output: "Skill directory not found: /Users/raymond/Desktop/AI/AIA/dev-cadence/--help"
    expected_failure: true
    failure_reason: The script treats --help as the target skill directory before help handling exists.
  - command: node skills/dev-cadence/scripts/check-discipline-routes.mjs --help
    phase: RED
    exit_code: 2
    output: "Skill directory not found or missing SKILL.md: /Users/raymond/Desktop/AI/AIA/dev-cadence/--help"
    expected_failure: true
    failure_reason: The script treats --help as the target skill directory before help handling exists.
environment:
  - local shell
  - node runtime
results:
  - RED evidence captured for both scripts.
failures:
  - expected
skipped: []
```
