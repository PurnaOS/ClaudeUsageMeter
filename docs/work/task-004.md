---
type: Task
id: TASK-004
title: Pace (token% vs time%) and detail-window redesign
owner: Srini Raju
status: done
priority: should
code:
  - Sources/UsageCore/Pace.swift
  - Sources/ClaudeUsageMeter/UsageDetailView.swift
  - Sources/ClaudeUsageMeter/ClaudeUsageMeterApp.swift
  - Sources/UsageProbe/**
links:
  parent: [/work/story-002.md]
  implements: [/requirements/fr-0006.md]
  verified_by: [/tests/test-usage-core.md]
---

# TASK-004 — Pace (token% vs time%) and detail-window redesign

- `UsageCore/Pace` — time-elapsed% per window (5h / 7d spans) and a burn
  classification (`onTrack` / `watch` / `hot`) from `used% − elapsed%`.
- `UsageDetailView` redesign — per-window card with a header + pace badge, a
  single bar showing tokens used (colored by pace) with a vertical tick marking
  time elapsed, and a `NN% tokens · NN% time · resets …` line. New left-aligned,
  hover-highlighted footer rows replace the centered buttons.

Verified by the `Pace` assertions in
[TEST-usage-core](../tests/test-usage-core.md) (`swift run UsageCoreCheck`), and
live via `swift run UsageProbe` (5-hour 20% tokens / 33% time → On track).
