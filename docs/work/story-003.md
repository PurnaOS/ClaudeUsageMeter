---
type: Story
id: STORY-003
title: Run always-on and launch at login
owner: Srini Raju
status: in_review
priority: should
links:
  parent: [/work/epic-001.md]
  implements: [/requirements/fr-0004.md]
  verified_by: [/tests/test-usage-core.md]
as_a: Claude Code subscriber
i_want: the app to run by itself in the background
so_that: the reading is always there without me starting it
acceptance_criteria: See body.
---

# STORY-003 — Run always-on and launch at login

# Acceptance Criteria

- The app runs as a menu-bar/background app with no Dock icon churn.
- An option enables launch at login.
- It keeps running and refreshing without user interaction.
