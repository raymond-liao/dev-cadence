# Diff Summary

```yaml
run_id: 20260622-1553-developer-1
planned_files:
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
planned_artifact_files:
  - specs/20260622-self-check-help/**
files_changed:
  - skills/dev-cadence/scripts/check-skill-package.mjs
  - skills/dev-cadence/scripts/check-discipline-routes.mjs
created_artifact_files:
  - specs/20260622-self-check-help/**
unplanned_changed_files: []
deleted_files: []
added_components: []
scope_reconciliation_status: in_scope
behavior_changes:
  - Both scripts now exit 0 and print usage information for --help and -h.
non_behavior_changes: []
risk_notes:
  - Help output is intentionally simple and does not alter normal validation paths.
  - Artifact files are planned evidence for the dry run, not product scope expansion.
```
