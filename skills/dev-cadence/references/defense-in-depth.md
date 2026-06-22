# Defense-in-Depth Validation

Use this reference when a bug is caused by invalid data, unsafe state, or missing boundary checks.

## Core Rule

Validate at every layer where invalid data can enter, transform, or become dangerous. Make the bug structurally difficult to reintroduce.

## Layers

### Entry Point Validation

Reject obviously invalid input at API, CLI, UI, or public function boundaries.

### Business Logic Validation

Check that data still makes sense for the operation being performed.

### Environment Guards

Prevent dangerous operations in context-specific environments such as tests, CI, production, or migrations.

### Diagnostic Evidence

Add logging or structured evidence when future failure would be hard to diagnose.

## Process

1. Trace the data flow.
2. List every checkpoint the data passes through.
3. Add validation at the source and at dangerous downstream boundaries.
4. Test attempts to bypass earlier layers.
5. Record which layer catches which failure.

## Warning

One validation point often feels sufficient but can be bypassed by different code paths, mocks, or future refactors. Add enough layers that the same class of bug cannot silently reach the dangerous operation.
