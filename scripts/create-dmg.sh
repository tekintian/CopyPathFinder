#!/bin/bash

# Custom DMG Creation Script
# Usage: ./scripts/create-dmg.sh [app-path] [output-path]

set -e

APP_PATH="${1:-$(pwd)/.build/CopyPathFinder.app}"
OUTPUT_PATH="${2:-$(pwd)/CopyPathFinder.dmg}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="/tmp/dmg_temp_$$"
DMG_NAME="Copy Path Finder"
APP_NAME="CopyPathFinder"

echo "🔥 Custom DMG Creation Tool"
echo "============================"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi

# Get app size
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
echo "📱 App size: ${APP_SIZE}MB"

# Calculate DMG size (app size + 50MB buffer, minimum 100MB)
DMG_SIZE=$((APP_SIZE + 50))
if [ $DMG_SIZE -lt 100 ]; then
    DMG_SIZE=100
fi
echo "💿 DMG size: ${DMG_SIZE}MB"

# Clean up any existing temporary directory
rm -rf "$TEMP_DIR"

# Create temporary directory structure
echo "📁 Creating DMG structure..."
mkdir -p "$TEMP_DIR/$APP_NAME"
mkdir -p "$TEMP_DIR/.background"

# Copy app to temporary directory
echo "📦 Copying app..."
cp -R "$APP_PATH" "$TEMP_DIR/$APP_NAME/"

# Create Applications symbolic link
echo "🔗 Creating Applications link..."
ln -s /Applications "$TEMP_DIR/Applications"

# Copy background image if available
if [ -f "$PROJECT_DIR/Assets/macapp_bg.png" ]; then
    echo "🖼️ Adding background image..."
    cp "$PROJECT_DIR/Assets/macapp_bg.png" "$TEMP_DIR/.background/"
fi

# Create custom icon positioning AppleScript
cat > "$TEMP_DIR/.background/set-window-size.applescript" << 'EOF'
tell application "Finder"
    set theWindow to make new Finder window
    set target of theWindow to folder "CopyPathFinder" of disk "Copy Path Finder"
    set current view of theWindow to icon view
    set toolbar visible of theWindow to false
    set statusbar visible of theWindow to false
    set bounds of theWindow to {400, 100, 920, 440}
    
    -- Position app icon
    set position of item "CopyPathFinder" of theWindow to {130, 220}
    
    -- Position Applications link
    set position of item "Applications" of theWindow to {380, 220}
    
    -- Set window size and background
    set current view of theWindow to icon view
    set theOptions to the icon view options of theWindow
    set arrangement of theOptions to not arranged
    set icon size of theOptions to 128
    
    -- Set background if image exists
    try
        set background picture of theOptions to file ".background:macapp_bg.png"
    end try
end tell
EOF

# Create the DMG
echo "💿 Creating DMG..."
cd "$TEMP_DIR"

# Create read-only DMG
hdiutil create -volname "$DMG_NAME" -srcfolder . -ov -format UDZO -size "${DMG_SIZE}m" "$OUTPUT_PATH"

# Mount DMG to apply custom layout
echo "🎨 Applying custom layout..."
DMG_DEVICE=$(hdiutil attach "$OUTPUT_PATH" -readwrite -nobrowse | grep -E '/dev/disk[0-9]+' | cut -f1)

# Apply layout
if [ -f ".background/set-window-size.applescript" ]; then
    osascript ".background/set-window-size.applescript"
fi

# Set custom volume icon if available
if [ -f "$PROJECT_DIR/Assets/AppIcon.icns" ]; then
    # Apply custom icon to DMG volume
    sudo cp "$PROJECT_DIR/Assets/AppIcon.icns" "/Volumes/$DMG_NAME/.VolumeIcon.icns" 2>/dev/null || true
    SetFile -a C "/Volumes/$DMG_NAME" 2>/dev/null || true
fi

# Unmount DMG
hdiutil detach "$DMG_DEVICE"

# Make DMG internet-enabled (optional)
hdiutil internet-enable -yes "$OUTPUT_PATH" 2>/dev/null || true

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ DMG created successfully!"
echo "📁 Location: $OUTPUT_PATH"
echo "📊 Size: $(du -sh "$OUTPUT_PATH" | cut -f1)"

# Get final DMG info
echo ""
echo "📋 DMG Information:"
echo "   App size: ${APP_SIZE}MB"
echo "   DMG size: $(du -sh "$OUTPUT_PATH" | cut -f1)"
echo "   Volume name: $DMG_NAME"

# Test DMG
echo ""
echo "🧪 Testing DMG..."
if hdiutil attach "$OUTPUT_PATH" -readonly -nobrowse > /dev/null 2>&1; then
    echo "✅ DMG mounts correctly"
    hdiutil detach "/Volumes/$DMG_NAME" > /dev/null 2>&1
else
    echo "⚠️ DMG mounting failed"
fi