---
type: Test
id: TEST-make-icon
title: Brand mark renders to an app icon
owner: Srini Raju
status: passing
links:
  verifies: [/requirements/nfr-0003.md]
---

# TEST-make-icon

Renders the `GaugeLogo` brand mark to assets. Run command:

```
swift run MakeIcon
```

Exits 0 only when it renders the logo to a `.iconset` and `iconutil` builds
`Branding/AppIcon.icns` (plus `Branding/logo.png`). Status `passing` recorded
after watching it write `Branding/AppIcon.icns` in this session; the rendered mark
was visually confirmed to read as a speedometer gauge.
