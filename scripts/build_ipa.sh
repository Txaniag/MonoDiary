#!/bin/bash
# Build an unsigned IPA for MonoDiary on macOS.
# Usage: ./scripts/build_ipa.sh
set -euo pipefail
cd "$(dirname "$0")/.."

OUT_DIR="build/ipa"
ARCHIVE_PATH="build/MonoDiary.xcarchive"

echo "▸ Archiving MonoDiary (unsigned)..."
xcodebuild \
  -project MonoDiary.xcodeproj \
  -scheme MonoDiary \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  archive

echo "▸ Packaging IPA..."
rm -rf "$OUT_DIR" build/Payload
mkdir -p "$OUT_DIR" build/Payload
cp -R "$ARCHIVE_PATH/Products/Applications/MonoDiary.app" build/Payload/
cd build
zip -qry "ipa/MonoDiary-unsigned.ipa" Payload
cd ..
rm -rf build/Payload

echo "✅ IPA ready: $OUT_DIR/MonoDiary-unsigned.ipa"
echo "   使用 Sideloadly / AltStore / 爱思助手 等工具签名后即可安装。"