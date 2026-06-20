---
type: Task
id: TASK-006
title: Package as a .app bundle and a distributable zip
owner: Srini Raju
status: done
priority: should
code:
  - scripts/**
  - install.sh
  - .github/workflows/release.yml
  - DISTRIBUTING.md
links:
  parent: [/work/story-003.md]
  implements: [/requirements/fr-0004.md]
  verified_by: [/tests/test-package.md]
---

# TASK-006 — Package as a .app bundle and a distributable zip

- `scripts/make-app.sh` — assembles `ClaudeUsageMeter.app` (release binary,
  `AppIcon.icns`, `LSUIElement` Info.plist, bundle id
  `com.sriniraju.claudeusagemeter`) and ad-hoc signs it. The real bundle is what
  makes `SMAppService` launch-at-login (FR-0004) work — it can't from `swift run`.
- `scripts/make-zip.sh` — `ditto`-zips the bundle (signature preserved) for
  sharing.
- `install.sh` — builds from source and installs to `/Applications`. Because the
  app is built locally it isn't quarantined, so there is no Gatekeeper prompt —
  the intended "install via a Claude Code prompt" path (every user already has
  Claude Code).
- `DISTRIBUTING.md` — build + recipient (right-click → Open) instructions and the
  upgrade path to a notarized build.

Verified by [TEST-package](../tests/test-package.md): the bundle builds and
launches as a menu-bar agent.
