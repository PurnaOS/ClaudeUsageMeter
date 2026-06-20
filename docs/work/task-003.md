---
type: Task
id: TASK-003
title: Run as background agent and launch at login
owner: Srini Raju
status: done
priority: should
code:
  - Sources/UsageCore/LoginItem.swift
  - Sources/ClaudeUsageMeter/LoginItemController.swift
  - Sources/ClaudeUsageMeter/ClaudeUsageMeterApp.swift
  - Sources/UsageCoreCheck/**
links:
  parent: [/work/story-003.md]
  implements: [/requirements/fr-0004.md]
  verified_by: [/tests/test-usage-core.md]
---

# TASK-003 — Run as background agent and launch at login

- `AppDelegate` sets `NSApp.setActivationPolicy(.accessory)` so the app runs as a
  menu-bar agent with no Dock icon.
- `LoginItemController` wraps `SMAppService.mainApp` (native, macOS 13+) for the
  launch-at-login toggle, with `UsageCore/LoginItem.menuTitle` driving the menu
  label.
- Always-on refresh is the existing 60s timer in `UsageModel` (STORY-001).

The pure title logic is verified by `LoginItem` assertions in
[TEST-usage-core](../tests/test-usage-core.md) (`swift run UsageCoreCheck`); the
`SMAppService` registration and activation policy are platform glue, runtime-only.
