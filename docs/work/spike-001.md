---
type: Spike
id: SPIKE-001
title: Determine a viable source for per-window usage figures
owner: Srini Raju
status: done
priority: must
timebox: 2 days
links:
  parent: [/work/epic-001.md]
  informs: [/requirements/fr-0001.md]
---

# SPIKE-001 — Determine a viable source for per-window usage figures

**Resolved.** Source = the authenticated OAuth usage endpoint. Recommendation
written into [FR-0001](../requirements/fr-0001.md).

## Findings

Three candidate sources, from research into existing tools (yasb Claude widget,
cc-usage-monitor, ccusage):

1. **OAuth usage API** — `GET https://api.anthropic.com/api/oauth/usage`, headers
   `Authorization: Bearer <token>` + `anthropic-beta: oauth-2025-04-20`. Token
   from `~/.claude/.credentials.json` (`claudeAiOauth.accessToken`, honoring
   `CLAUDE_CONFIG_DIR`). Returns `used_percentage` + `resets_at` for the
   `five_hour` and `seven_day` windows. Rate-limited (429) → cache to disk with a
   TTL, serve last good on error. **Chosen** — authoritative, works for a
   standalone always-on app, matches the stated preference.
2. **Statusline `rate_limits` JSON** — Claude Code pipes the same `five_hour` /
   `seven_day` `used_percentage` + `resets_at` over stdin to a statusline command
   each assistant turn. Zero auth, but only updates *during active Claude Code
   turns* — forces the app to be a statusline plugin, not standalone. Rejected for
   this app; useful as a future fallback.
3. **Local JSONL parse (ccusage-style)** — `~/.claude/projects/**/*.jsonl` gives
   token *counts* only, not official limit %/reset. Cannot produce the gauge
   without knowing the limits. Rejected.

## Key correction

Subscription rolling windows are **5-hour and weekly (7-day)** — there is **no
1-hour subscription window**. All artifacts retargeted from "1-hour" to "weekly".
A 1-hour figure only exists for API-tier rate limits, out of scope here.

## Exit criteria — met

- Source yielding both percentage and reset per window, and how to read it: OAuth
  usage API (above).
- Refresh/poll cost and auth: low-frequency poll; bearer token from credentials
  file; 429-aware disk cache.
- Recommendation recorded in FR-0001.
