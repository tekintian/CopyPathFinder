#!/bin/bash

# macOS Icon Converter Tool
# Converts PNG files to ICNS format for macOS applications
# Usage: ./scripts/convert-icon.sh /path/to/image.png [output-name]

set -e

# Input validation
if [ $# -lt 1 ]; then
    echo "❌ Usage: $0 <input-png-file> [output-name]"
    echo "Example: $0 Assets/app.png AppIcon"
    echo "Example: $0 /path/to/icon.png"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_NAME="${2:-AppIcon}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Check if input is PNG
if [[ "$INPUT_FILE" != *.png ]]; then
    echo "❌ Error: Input file must be a PNG image"
    exit 1
fi

# Get directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$(mktemp -d)"

echo "🎨 Converting icon: $INPUT_FILE"
echo "📁 Output name: $OUTPUT_NAME"
echo "📂 Working directory: $WORK_DIR"

# Create iconset directory
ICONSET_DIR="$WORK_DIR/${OUTPUT_NAME}.iconset"
mkdir -p "$ICONSET_DIR"

# Convert to different sizes using sips
echo "🔧 Generating icon sizes..."

# Generate all required sizes for macOS
sips -z 16 16 "$INPUT_FILE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1
sips -z 32 32 "$INPUT_FILE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1
sips -z 32 32 "$INPUT_FILE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1
sips -z 64 64 "$INPUT_FILE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1
sips -z 128 128 "$INPUT_FILE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1
sips -z 256 256 "$INPUT_FILE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1
sips -z 256 256 "$INPUT_FILE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1
sips -z 512 512 "$INPUT_FILE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1
sips -z 512 512 "$INPUT_FILE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1
sips -z 1024 1024 "$INPUT_FILE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

# Convert iconset to ICNS
echo "🔄 Creating ICNS file..."
iconutil -c icns "$ICONSET_DIR"

# Copy result to Assets directory
ASSETS_DIR="$PROJECT_DIR/Assets"
mkdir -p "$ASSETS_DIR"
cp "$WORK_DIR/${OUTPUT_NAME}.icns" "$ASSETS_DIR/"

# Clean up
rm -rf "$WORK_DIR"

echo "✅ Icon conversion completed!"
echo "📦 Output: $ASSETS_DIR/${OUTPUT_NAME}.icns"
echo ""
echo "📝 Next steps:"
echo "   1. Make sure Info.plist references the icon name:"
echo "      <key>CFBundleIconFile</key>"
echo "      <string>${OUTPUT_NAME}</string>"
echo "   2. Rebuild your app: make build"
echo ""
echo "🎉 Your app is now ready with the new icon!"