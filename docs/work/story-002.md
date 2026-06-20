---
type: Story
id: STORY-002
title: Detail window with both gauges and time-to-reset
owner: Srini Raju
status: in_review
priority: should
links:
  parent: [/work/epic-001.md]
  implements: [/requirements/fr-0005.md]
  verified_by: [/tests/test-usage-core.md]
as_a: Claude Code subscriber
i_want: a window showing both windows' usage and when they reset
so_that: I can read a high percentage in context of how soon it clears
acceptance_criteria: See body.
---

# STORY-002 — Detail window with both gauges and time-to-reset

# Acceptance Criteria

- Clicking the menu bar item opens a window with a gauge for the 5-hour window
  and a gauge for the weekly (7-day) window, each showing its percentage.
- Each gauge shows the time remaining until that window resets.
- The window reflects the latest figures when opened.
