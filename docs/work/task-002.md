---
type: Task
id: TASK-002
title: Detail window with two gauges and time-to-reset
owner: Srini Raju
status: done
priority: should
code:
  - Sources/UsageCore/Countdown.swift
  - Sources/ClaudeUsageMeter/UsageDetailView.swift
  - Sources/UsageCoreCheck/**
links:
  parent: [/work/story-002.md]
  implements: [/requirements/fr-0005.md]
  verified_by: [/tests/test-usage-core.md]
---

# TASK-002 — Detail window with two gauges and time-to-reset

- `UsageCore/Countdown` — formats time-until-reset ("3d 4h", "2h 14m", "9m",
  "<1m", "now") for each window.
- `ClaudeUsageMeter/UsageDetailView` — the MenuBarExtra detail window
  (`.menuBarExtraStyle(.window)`): a native `Gauge` per window showing its
  percentage, plus "resets in …" beneath each. Shows "Usage unavailable" when
  there is no snapshot.

Verified by the `Countdown` assertions in
[TEST-usage-core](../tests/test-usage-core.md) (`swift run UsageCoreCheck`).
