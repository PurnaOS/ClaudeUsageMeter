---
type: Story
id: STORY-001
title: Acquire usage and show percent in the menu bar
owner: Srini Raju
status: done
priority: must
links:
  parent: [/work/epic-001.md]
  implements: [/requirements/fr-0001.md, /requirements/fr-0002.md, /requirements/fr-0003.md]
  verified_by: [/tests/test-usage-core.md]
as_a: Claude Code subscriber
i_want: the menu bar to show how much of my limits I've used
so_that: I can see at a glance whether I'm close to being throttled
acceptance_criteria: See body.
---

# STORY-001 — Acquire usage and show percent in the menu bar

# Acceptance Criteria

- The app reads usage figures from the source chosen in SPIKE-001 on a regular
  interval.
- The menu bar item shows the percentage consumed for the more urgent of the two
  windows.
- The value updates without restarting the app.
- When data is unavailable, the item shows an "unavailable" state, not a wrong
  number.
