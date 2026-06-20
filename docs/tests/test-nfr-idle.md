---
type: Test
id: TEST-nfr-idle
title: Idle footprint accepted by design review
owner: Srini Raju
status: passing
links:
  verifies: [/requirements/nfr-0001.md]
---

# TEST-nfr-idle

**Manual design-review check, not an automated measurement.** Records the
acceptance of [NFR-0001](../requirements/nfr-0001.md) on design grounds.

Reviewed (2026-06-20): the app does no work between polls — a single 60-second
`Timer`, no busy loop; each poll is one small HTTPS request whose result is held
in memory; it runs as an `.accessory` agent and renders nothing while the menu is
closed. On that basis idle CPU/memory is judged negligible. `passing` reflects the
review conclusion, not a measured threshold.

If idle cost ever needs hard numbers, replace this with a measured test (sample
CPU/RSS of the running agent over several minutes against a threshold).
