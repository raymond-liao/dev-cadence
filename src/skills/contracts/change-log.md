# Change Log Contract

## Applicability And Ownership

This supporting contract defines the shared Change Log rules for asset workflows. It is not a routable skill. Each asset workflow owns the decision about whether its own asset definition changed and must retain its owner-specific increment rules.

## Version Dimensions And Schema

Use this standard schema for a versioned asset:

```text
Version | Recorded At | Recorded By | Change | Reason
```

When an asset owner maintains a separately named version dimension, replace only the first column:

```text
<Named Version> | Recorded At | Recorded By | Change | Reason
```

## Field Semantics

`Version` or `<Named Version>` identifies the version in effect for the event. `Recorded At` identifies when the event occurred. `Recorded By` identifies the person whose identity was collected for the event. `Change` states what changed. `Reason` states why the event was recorded.

## Versioned Definition Changes

Increment the owned version by 1 before recording a confirmed definition change. Asset owners define which changes alter their owned definition.

## Non-Versioned Important Events

Record a status transition, delivery result, or important migration with the event's current version; do not increment the version solely for that event. Do not record spelling-only, formatting-only, or link-only changes that do not alter an owned responsibility.

## Ordering And Duplicate Versions

Multiple rows with the same version are valid when they describe different events. Append new records in event order. During historical migration, restore ascending order only when the evidence establishes it; otherwise preserve the historical relative order.

## Identity And Time

New records must use a timezone-offset ISO 8601 `Recorded At` value captured when the event occurs. Read `user.name` and `user.email` from repository-level Git config before global Git config. When both values are available, record `Name <email>`; when only one is available, retain that confirmed value. When both identity values are unavailable, ask the user before writing a new record.

## Legacy Migration

Use `legacy: recorded-at precision unknown; original YYYY-MM-DD` when the original date is known but its time or offset is unknown. Use `legacy: recorded-at unknown` when the original date is unknown. Use `legacy: recorded-by unknown` when the original author is unknown. Use these sentinel values only for historical migration; never use them for a new record. Do not infer historical identity from current Git configuration, invent a time or offset for a date-only value, or discard an important historical event.

## Forbidden Metadata

Do not record approval metadata, approver identity, approval timestamp, commit hashes, workflow stage, workflow run metadata, or runtime status as Change Log fields.

## Red Flags

Do not create a competing public schema in a consuming workflow. Do not treat a repeated version as an error solely because it is repeated. Do not use a process record as an asset Change Log.
