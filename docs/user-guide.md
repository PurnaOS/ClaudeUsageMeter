---
type: Guide
title: Claude Usage Meter — End-User Guide
audience: end-user
status: published
version: 0.1.0
applies_to: ClaudeUsageMeter 0.1.0 (macOS 13+)
---

# Claude Usage Meter — End-User Guide

A small menu-bar app that shows how much of your Claude Code rate limits you've
used, so you can pace your work and never get cut off mid-task.

## What it tells you

Claude Code subscriptions have two rolling limits: a **5-hour** window and a
**weekly** (7-day) window. The app shows, for each:

- **% tokens** — how much of that window's allowance you've spent.
- **% time** — how far through the window's clock you are.
- **Pace** — whether you're spending tokens faster or slower than the clock.
- **Resets in** — how long until that window clears.

### Reading the pace

The single most useful number is **tokens vs. time**:

| Pace badge | Meaning |
|---|---|
| 🟢 **On track** | You're using tokens *slower* than the clock — you have headroom. |
| 🟠 **Watch pace** | You're a bit ahead of the clock — ease up or you may run short. |
| 🔴 **Burning hot** | You're spending far faster than time — you'll likely hit the limit before it resets. |

On each bar, the colored fill is **tokens used** and the vertical tick is **time
elapsed**. If the fill is *behind* the tick, you're in good shape:

```
 5-hour                            [ On track ]
 ▓▓▓▓▓▓▓░░░░░░│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 20% tokens · 33% time · resets 3h 21m
```

> Example: **20% tokens at 33% time** is comfortable. **20% tokens at 5% time**
> means you're burning hot — slow down.

## Requirements

- macOS 13 (Ventura) or newer.
- **Claude Code installed and signed in** with a paid subscription. The app reads
  your usage through Claude Code's own login — it never asks for a password and
  never sends your token anywhere except Anthropic.

## Install

1. Download `ClaudeUsageMeter-<version>.zip` and unzip it.
2. Drag **ClaudeUsageMeter.app** into your **Applications** folder.
3. **First launch:** right-click (or Control-click) the app icon → **Open** →
   **Open**. (macOS warns the first time because the app isn't notarized;
   double-clicking just bounces.)
4. The gauge appears in your menu bar showing a percentage.

## Using it

- **Glance:** the menu-bar item shows the more urgent of the two windows.
- **Details:** click the menu-bar item to open the window with both gauges,
  the pace badges, and reset times.
- **Refresh now:** forces an immediate update (it refreshes on its own every
  minute).
- **Launch at login:** turn this on so the meter is always there after a restart.
- **Quit:** stops the app.

## Troubleshooting

**It shows `—` or "Usage unavailable."**
- Make sure **Claude Code is installed and signed in** (open Claude Code and run a
  prompt). The app reads the login Claude Code stores.
- If you only use an **API key** (no subscription login), there's no usage to
  show — the app needs a subscription (OAuth) sign-in.
- Anthropic briefly rate-limits the usage endpoint; the app keeps showing the last
  good value and recovers on the next minute.

**The percentage looks stale.**
- It updates once a minute. Click **Refresh now** to update immediately.

**"App can't be opened because it is from an unidentified developer."**
- Right-click the app → **Open** → **Open** (only needed the first time). This is
  expected for an app that isn't notarized.

## Uninstall

1. Quit the app (menu → **Quit**).
2. If you enabled launch-at-login, turn it off first, or remove it under
   **System Settings → General → Login Items**.
3. Drag **ClaudeUsageMeter.app** from Applications to the Trash.

The app stores no data of its own and never writes your token.

## Frequently asked

**Is there a 1-hour limit?** No. Claude Code subscription limits are 5-hour and
weekly only.

**Does it use my tokens / cost anything?** No. Reading your usage doesn't consume
tokens; it's a tiny status check.

**Where does my token go?** Nowhere new. The app reads the token Claude Code
already stored on your Mac and uses it only to ask Anthropic for your usage.
