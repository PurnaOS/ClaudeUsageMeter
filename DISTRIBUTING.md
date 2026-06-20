# Distributing ClaudeUsageMeter

A macOS 13+ menu-bar app. It reads the Claude Code OAuth token from the macOS
Keychain (`Claude Code-credentials`) and calls `api.anthropic.com/api/oauth/usage`,
so a user must have **Claude Code installed and signed in** for it to show data.

## Build the distributable (you)

```
swift run MakeIcon          # render Branding/AppIcon.icns (once / when logo changes)
./scripts/make-zip.sh       # builds dist/ClaudeUsageMeter.app + dist/ClaudeUsageMeter-<ver>.zip
./scripts/make-zip.sh 0.2.0 # with a version
```

`make-app.sh` assembles the `.app` (icon, `LSUIElement` so it's a menu-bar agent,
bundle id `com.sriniraju.claudeusagemeter`) and **ad-hoc** signs it. `make-zip.sh`
zips it with `ditto` (preserves the signature).

## Install it (recipients)

The build is **ad-hoc signed, not notarized**, so Gatekeeper warns on first run:

1. Unzip → `ClaudeUsageMeter.app`. Move it to `/Applications`.
2. **First launch:** right-click (Control-click) the app → **Open** → **Open**.
   (Double-clicking an unsigned app just bounces.) Or:
   `xattr -dr com.apple.quarantine /Applications/ClaudeUsageMeter.app`
3. The gauge appears in the menu bar. Use **Launch at login** in its menu to keep
   it running.

## Notes

- **Launch at login** uses `SMAppService`, which needs the real `.app` bundle —
  it does **not** work from `swift run`, only from the packaged app.
- **Universal binary:** `make-app.sh` builds native arch only (Command Line Tools
  can't cross-build). For arm64+x86_64, build each arch on a Mac with full Xcode
  and `lipo -create` them before bundling.

## Going public later (not set up yet)

To distribute without the Gatekeeper warning you need an Apple Developer ID
($99/yr): Developer ID sign → `xcrun notarytool submit` → `xcrun stapler staple`,
then ship a DMG/zip or a Homebrew cask. The **Mac App Store is not viable** — its
sandbox forbids reading Claude Code's Keychain item.
