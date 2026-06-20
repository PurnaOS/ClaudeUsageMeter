---
type: Task
id: TASK-001
title: Usage API client, percent compute, and menu-bar glance
owner: Srini Raju
status: done
priority: must
code:
  - Sources/UsageCore/**
  - Sources/ClaudeUsageMeter/**
  - Sources/UsageCoreCheck/**
  - Sources/UsageProbe/**
  - Package.swift
links:
  parent: [/work/story-001.md]
  implements: [/requirements/fr-0001.md, /requirements/fr-0002.md, /requirements/fr-0003.md]
  verified_by: [/tests/test-usage-core.md]
---

# TASK-001 — Usage API client, percent compute, and menu-bar glance

Swift package `ClaudeUsageMeter`:

- `UsageCore` — reads the OAuth token from the macOS Keychain
  (`Claude Code-credentials`), falling back to `~/.claude/.credentials.json`;
  calls `GET /api/oauth/usage` with the bearer + `anthropic-beta` headers,
  decodes `five_hour` / `seven_day` (`utilization`, ISO-8601 `resets_at`),
  selects the most-urgent window, and formats the glance string (with an
  unavailable marker).
- `UsageProbe` — a live smoke test (`swift run UsageProbe`) that makes one real
  call and prints both windows; used to confirm the decoder against the actual
  response. Verified live: HTTP 200, `5-hour 11% / weekly 2%`, decoder matches.
- `ClaudeUsageMeter` — `MenuBarExtra` shell that polls on a 60s timer and shows
  the most-urgent percentage; keeps the last good value on error.
- `UsageCoreCheck` — assert-based self-check ([TEST-usage-core](../tests/test-usage-core.md)).

The detail window with both gauges and time-to-reset is STORY-002; this task is
the acquire + compute + menu-bar glance (FR-0001/0002/0003).
