#!/bin/bash
# Full clean rebuild script for Bầu Cua Tôm Cá
# Usage: ./rebuild.sh

set -e

echo "=== Regenerating Xcode project (xcodegen) ==="
xcodegen generate

echo "=== Cleaning build artifacts ==="
xcodebuild clean -project BauCua.xcodeproj -scheme BauCua -quiet 2>/dev/null || true

echo "=== Building for simulator ==="
xcodebuild -project BauCua.xcodeproj \
    -scheme BauCua \
    -destination 'generic/platform=iOS Simulator' \
    -quiet build

echo "=== Building for device (archive) ==="
xcodebuild -project BauCua.xcodeproj \
    -scheme BauCua \
    -destination 'generic/platform=iOS' \
    -quiet build

echo "=== BUILD SUCCEEDED ==="
echo "To archive for App Store: open Xcode → Product → Archive"
echo "Make sure target is 'Any iOS Device (arm64)'"
