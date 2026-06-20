---
type: Test
id: TEST-usage-core
title: UsageCore parse / select / format / token checks
owner: Srini Raju
status: passing
links:
  verifies: [/requirements/fr-0001.md, /requirements/fr-0002.md, /requirements/fr-0003.md, /requirements/fr-0004.md, /requirements/fr-0005.md, /requirements/fr-0006.md, /requirements/nfr-0002.md]
---

# TEST-usage-core

Self-check for the `UsageCore` library. Run command:

```
swift run UsageCoreCheck
```

Exits 0 (green) only when every assertion holds. Covers:

- **FR-0001** — decoding the OAuth usage body (flat and `rate_limits`-nested),
  `resets_at` epoch decode, `CLAUDE_CONFIG_DIR` credentials path, token
  extraction, and missing-token error.
- **FR-0002** — whole-percent formatting, clamped to 0–100.
- **FR-0003** — `mostUrgent` selects the higher of the two windows.
- **FR-0004** — `LoginItem.menuTitle` reflects the enabled/disabled state.
- **FR-0006** — `Pace.elapsedPercent` (with past-reset clamp) and `Pace.status`
  classification (on track / watch / hot).
- **FR-0005** — `Countdown.timeUntil` formatting (days+hours, hours+minutes,
  minutes, sub-minute, and past-reset "now"), relative to a fixed `now`.
- **NFR-0002** — garbage body and missing credentials yield typed errors, not
  crashes; the glance shows `—` when usage is unavailable.

Status `passing` recorded after watching `swift run UsageCoreCheck` exit 0 in
this session.
