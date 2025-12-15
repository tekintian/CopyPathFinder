#!/bin/bash

# Copy Path Finder Build Script
# Usage: ./scripts/build.sh [debug|release]

set -e

BUILD_TYPE=${1:-release}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"

echo "🚀 Building Copy Path Finder ($BUILD_TYPE)..."
echo "Project directory: $PROJECT_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"

# Build
echo "🔨 Building..."
if [ "$BUILD_TYPE" = "debug" ]; then
    swift build -c debug
else
    swift build -c release
fi

# Create app bundle
echo "📦 Creating app bundle..."
BINARY_PATH="$BUILD_DIR/$BUILD_TYPE/CopyPathFinder"
APP_DIR="$BUILD_DIR/CopyPathFinder.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BINARY_PATH" "$MACOS_DIR/"
cp "$PROJECT_DIR/Sources/CopyPathFinder/Info.plist" "$CONTENTS_DIR/"

# Set executable permissions
chmod +x "$MACOS_DIR/CopyPathFinder"

# Copy app icon if available
if [ -f "$PROJECT_DIR/Assets/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/Assets/AppIcon.icns" "$RESOURCES_DIR/"
fi

# Copy status bar icons if available
if [ -f "$PROJECT_DIR/Assets/StatusIcon.png" ]; then
    cp "$PROJECT_DIR/Assets/StatusIcon.png" "$RESOURCES_DIR/"
fi
if [ -f "$PROJECT_DIR/Assets/StatusIcon@2x.png" ]; then
    cp "$PROJECT_DIR/Assets/StatusIcon@2x.png" "$RESOURCES_DIR/"
fi

echo "✅ Build completed!"
echo "App bundle: $APP_DIR"

if [ "$BUILD_TYPE" = "release" ]; then
    # Create DMG
    echo "💿 Creating DMG..."
    DMG_DIR="$BUILD_DIR/dmg"
    mkdir -p "$DMG_DIR/CopyPathFinder"
    cp -R "$APP_DIR" "$DMG_DIR/CopyPathFinder/"
    
    cd "$BUILD_DIR"
    hdiutil create -volname "Copy Path Finder" -srcfolder dmg -ov -format UDZO CopyPathFinder.dmg
    
    echo "📀 DMG created: $BUILD_DIR/CopyPathFinder.dmg"
fi

echo "🎉 Done!"