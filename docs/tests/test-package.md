---
type: Test
id: TEST-package
title: App bundles and launches as a menu-bar agent
owner: Srini Raju
status: passing
links:
  verifies: [/requirements/fr-0004.md]
---

# TEST-package

Builds the distributable and confirms it runs. Run command:

```
./scripts/make-zip.sh
```

Exits 0 only when it produces `dist/ClaudeUsageMeter.app` (with icon + LSUIElement
Info.plist, ad-hoc signed) and `dist/ClaudeUsageMeter-<ver>.zip`. Status `passing`
recorded after, in this session, `open dist/ClaudeUsageMeter.app` launched the app
as a background agent (`pgrep ClaudeUsageMeter` matched, no Dock icon).
