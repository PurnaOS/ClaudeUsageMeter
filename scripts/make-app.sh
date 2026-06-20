#!/bin/bash
# Build ClaudeUsageMeter.app -- a real macOS bundle (menu-bar agent, with icon).
# Ad-hoc signed so it runs locally. For distribution off this Mac, re-sign with a
# Developer ID and notarize (see README).
#
# ponytail: native-arch build -- a universal (arm64+x86_64) binary needs full
# Xcode's xcbuild; Command Line Tools can't. For universal, build each arch on a
# machine with Xcode and "lipo -create" the two binaries.
set -euo pipefail
cd "$(dirname "$0")/.."

APP="ClaudeUsageMeter"
BUNDLE_ID="com.sriniraju.claudeusagemeter"
VERSION="${1:-0.1.0}"
APPDIR="dist/${APP}.app"
CONTENTS="${APPDIR}/Contents"

ARCHFLAGS=()
if [ "${UNIVERSAL:-0}" = "1" ]; then
  ARCHFLAGS=(--arch arm64 --arch x86_64)
  echo "[1/4] building universal release binary (arm64 + x86_64)"
else
  echo "[1/4] building release binary (native arch)"
fi
swift build -c release ${ARCHFLAGS[@]+"${ARCHFLAGS[@]}"}
BIN="$(swift build -c release ${ARCHFLAGS[@]+"${ARCHFLAGS[@]}"} --show-bin-path)/${APP}"

echo "[2/4] assembling ${APPDIR}"
rm -rf "${APPDIR}"
mkdir -p "${CONTENTS}/MacOS" "${CONTENTS}/Resources"
cp "${BIN}" "${CONTENTS}/MacOS/${APP}"
if [ -f Branding/AppIcon.icns ]; then
  cp Branding/AppIcon.icns "${CONTENTS}/Resources/AppIcon.icns"
else
  echo "  warning: no Branding/AppIcon.icns -- run: swift run MakeIcon"
fi

echo "[3/4] writing Info.plist"
cat > "${CONTENTS}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>${APP}</string>
  <key>CFBundleDisplayName</key><string>Claude Usage Meter</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleExecutable</key><string>${APP}</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "[4/4] ad-hoc signing"
codesign --force --deep --sign - "${APPDIR}"

echo "OK: built ${APPDIR} (v${VERSION})"
echo "  run:     open ${APPDIR}"
echo "  install: cp -r ${APPDIR} /Applications/"
