#!/bin/bash

# Copy Path Finder Installation Script
# Usage: ./scripts/install.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CopyPathFinder"
INSTALL_DIR="/Applications"
APP_BUNDLE="$APP_NAME.app"

echo "📦 Installing $APP_NAME to Applications folder..."

# Build release version
echo "🔨 Building release version..."
cd "$PROJECT_DIR"
./scripts/build.sh release

# Check if app bundle exists
APP_PATH="$PROJECT_DIR/.build/$APP_BUNDLE"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App bundle not found at $APP_PATH"
    exit 1
fi

# Remove existing installation
if [ -d "$INSTALL_DIR/$APP_BUNDLE" ]; then
    echo "🗑️  Removing existing installation..."
    rm -rf "$INSTALL_DIR/$APP_BUNDLE"
fi

# Copy to Applications
echo "📋 Copying to Applications..."
cp -R "$APP_PATH" "$INSTALL_DIR/"

echo "✅ Installation completed!"
echo ""
echo "🎉 $APP_NAME has been installed to /Applications/"
echo ""
echo "🚀 To launch:"
echo "1. Open Launchpad or Applications folder"
echo "2. Click on $APP_NAME"
echo "3. Grant Apple Events permissions when prompted"
echo ""
echo "⚠️  Note: You'll need to grant Apple Events permissions on first launch."