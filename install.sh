#!/bin/bash
# One-shot: build Claude Usage Meter from source and install it to /Applications.
# Building locally means the app is not quarantined -> no Gatekeeper prompt,
# no notarization needed. Re-run any time to update.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v swift >/dev/null 2>&1; then
  echo "Swift toolchain not found. Install the Command Line Tools first:"
  echo "  xcode-select --install"
  exit 1
fi

VERSION="${1:-0.1.0}"
APP="/Applications/ClaudeUsageMeter.app"

echo "[1/3] rendering app icon"
swift run MakeIcon >/dev/null

echo "[2/3] building app (release)"
./scripts/make-app.sh "${VERSION}" >/dev/null

echo "[3/3] installing to /Applications"
# Quit a running copy so the bundle can be replaced.
osascript -e 'quit app "ClaudeUsageMeter"' >/dev/null 2>&1 || true
rm -rf "${APP}"
cp -R "dist/ClaudeUsageMeter.app" "${APP}"
open "${APP}"

echo "OK: installed and launched ${APP} (v${VERSION})."
echo "Look for the gauge in your menu bar. Turn on 'Launch at login' to keep it."
