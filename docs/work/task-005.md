---
type: Task
id: TASK-005
title: Gauge brand mark, menu-bar icon, and app icon render
owner: Srini Raju
status: done
priority: could
code:
  - Sources/MeterUI/**
  - Sources/MakeIcon/**
  - Sources/ClaudeUsageMeter/ClaudeUsageMeterApp.swift
  - Sources/ClaudeUsageMeter/UsageDetailView.swift
links:
  parent: [/work/story-001.md]
  implements: [/requirements/nfr-0003.md]
  verified_by: [/tests/test-make-icon.md]
---

# TASK-005 — Gauge brand mark, menu-bar icon, and app icon render

- `MeterUI/GaugeLogo` — the brand mark, a speedometer dial + needle drawn with
  SwiftUI shapes (shared by the app and the icon renderer).
- Menu bar shows the gauge SF Symbol + glance %; the detail-window header shows
  the `GaugeLogo`.
- `MakeIcon` — renders the mark via `ImageRenderer` into a `.iconset` and builds
  `Branding/AppIcon.icns` + `Branding/logo.png`.

Verified by [TEST-make-icon](../tests/test-make-icon.md) (`swift run MakeIcon`
writes the `.icns`); the mark was visually confirmed.
