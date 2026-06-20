---
type: Task
id: TASK-007
title: Disk cache and resilient states for transient failures
owner: Srini Raju
status: done
priority: must
code:
  - Sources/UsageCore/UsageCache.swift
  - Sources/UsageCore/Model.swift
  - Sources/ClaudeUsageMeter/ClaudeUsageMeterApp.swift
  - Sources/ClaudeUsageMeter/UsageDetailView.swift
  - Sources/UsageCoreCheck/**
links:
  parent: [/work/story-001.md]
  implements: [/requirements/nfr-0002.md]
  verified_by: [/tests/test-usage-core.md]
---

# TASK-007 — Disk cache and resilient states for transient failures

Closes the deferred 429/offline handling (NFR-0002), found missing when a cold
launch during a rate-limit window showed nothing.

- `UsageCore/UsageCache` — persists the last good `UsageSnapshot` + `fetchedAt`
  to `~/Library/Caches/<bundle-id>/usage.json`.
- `UsageModel` — loads the cache on launch (instant display before the first
  call), saves on every success, keeps the last value on error, and retries
  sooner (30s) after a failure.
- `UsageError.userMessage` + the detail view — show *why* ("Rate limited —
  retrying", "Sign in to Claude Code") and an "updated Xm ago" freshness line,
  instead of a generic "unavailable".

Verified by the cache round-trip and error-message assertions in
[TEST-usage-core](../tests/test-usage-core.md), and live: recovered from an active
HTTP 429 and cached `5-hour 3% / weekly 8%`.
