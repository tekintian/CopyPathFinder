#!/bin/bash

# Copy Path Finder Build Script
# Usage: ./scripts/build.sh [debug|release] [sign-method]
# Examples:
#   ./scripts/build.sh debug         # Debug build
#   ./scripts/build.sh release       # Release build without signing
#   ./scripts/build.sh release simple    # Release build with simple ad-hoc signing
#   ./scripts/build.sh release full      # Release build with full certificate signing

set -e

BUILD_TYPE=${1:-release}
SIGN_APP=${2:-false}
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

# Copy localization files
echo "🌐 Copying localization files..."
if [ -d "$PROJECT_DIR/Sources/CopyPathFinder/Resources" ]; then
    cp -R "$PROJECT_DIR/Sources/CopyPathFinder/Resources/"* "$RESOURCES_DIR/"
    echo "   ✅ Localization files copied"
else
    echo "   ⚠️  Warning: Resources directory not found"
fi

echo "✅ Build completed!"
echo "App bundle: $APP_DIR"

# Sign app if requested
if [ "$SIGN_APP" = "simple" ]; then
    echo "🔐 Simple ad-hoc signing..."
    "$PROJECT_DIR/scripts/self-sign-simple.sh" "$APP_DIR"
elif [ "$SIGN_APP" = "full" ]; then
    echo "🔐 Full certificate signing..."
    "$PROJECT_DIR/scripts/self-sign.sh" --sign-only "$APP_DIR"
fi

if [ "$BUILD_TYPE" = "release" ]; then
    # Create simple DMG with app and Applications shortcut
    echo "💿 Creating DMG..."
    
    # Get version from Info.plist
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$CONTENTS_DIR/Info.plist" 2>/dev/null || echo "1.0.0")
    DMG_NAME="CopyPathFinder_v${VERSION}"
    DMG_PATH="$BUILD_DIR/${DMG_NAME}.dmg"
    DMG_DIR="$BUILD_DIR/dmg"
    
    # Clean and create DMG directory
    rm -rf "$DMG_DIR"
    mkdir -p "$DMG_DIR"
    
    # Copy app to DMG directory
    cp -R "$APP_DIR" "$DMG_DIR/"
    
    # Create Applications folder symbolic link
    ln -s /Applications "$DMG_DIR/Applications"
    
    echo "✅ DMG contents prepared:"
    echo "   - CopyPathFinder.app"
    echo "   - Applications (shortcut)"
    
    # Create DMG
    cd "$BUILD_DIR"
    hdiutil create -volname "Copy Path Finder" -srcfolder dmg -ov -format UDZO "$DMG_PATH"
    
    echo "📀 DMG created: $DMG_PATH"
fi

echo "🎉 Done!"