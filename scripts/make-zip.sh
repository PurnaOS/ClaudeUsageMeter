#!/bin/bash
# Build the .app and zip it for distribution. ditto (not zip) preserves the
# bundle's code signature and symlinks.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-0.1.0}"
"./scripts/make-app.sh" "${VERSION}"

OUT="dist/ClaudeUsageMeter-${VERSION}.zip"
rm -f "${OUT}"
ditto -c -k --keepParent "dist/ClaudeUsageMeter.app" "${OUT}"

echo "OK: ${OUT}"
echo "  share this zip. First run on another Mac: right-click the app > Open > Open."
