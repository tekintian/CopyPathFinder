#!/bin/bash

# Simple DMG Creation Script (without fancy layout)
# Usage: ./scripts/create-simple-dmg.sh [app-path] [output-path]

set -e

APP_PATH="${1:-$(pwd)/.build/CopyPathFinder.app}"
OUTPUT_PATH="${2:-$(pwd)/CopyPathFinder-Simple.dmg}"

echo "🔥 Simple DMG Creation Tool"
echo "=========================="

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi

# Get app size
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
echo "📱 App size: ${APP_SIZE}MB"

# Create temporary directory
TEMP_DIR="/tmp/dmg_simple_$$"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/CopyPathFinder"

# Copy app to temporary directory
echo "📦 Copying app..."
cp -R "$APP_PATH" "$TEMP_DIR/CopyPathFinder/"

# Create Applications symbolic link
echo "🔗 Creating Applications link..."
ln -s /Applications "$TEMP_DIR/Applications"

# Create DMG
echo "💿 Creating DMG..."
echo "📊 Creating DMG..."
hdiutil create -volname "Copy Path Finder" -srcfolder "$TEMP_DIR" -ov -format UDZO "$OUTPUT_PATH"

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ Simple DMG created successfully!"
echo "📁 Location: $OUTPUT_PATH"
echo "📊 Size: $(du -sh "$OUTPUT_PATH" | cut -f1)"

# Test DMG
echo ""
echo "🧪 Testing DMG..."
if hdiutil attach "$OUTPUT_PATH" -readonly -nobrowse > /dev/null 2>&1; then
    echo "✅ DMG mounts correctly"
    hdiutil detach "/Volumes/Copy Path Finder" > /dev/null 2>&1
else
    echo "⚠️ DMG mounting failed"
fi