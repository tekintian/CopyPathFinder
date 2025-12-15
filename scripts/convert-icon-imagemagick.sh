#!/bin/bash

# Advanced macOS Icon Converter Tool (ImageMagick version)
# Converts PNG to ICNS with better quality and additional options
# Usage: ./scripts/convert-icon-imagemagick.sh input.png [output-name] [options]

set -e

# Check dependencies
if ! command -v convert >/dev/null 2>&1; then
    echo "❌ ImageMagick not found. Install with: brew install imagemagick"
    echo "💡 Or use the basic sips-based converter: ./scripts/convert-icon.sh"
    exit 1
fi

if ! command -v iconutil >/dev/null 2>&1; then
    echo "❌ iconutil not found. This is a macOS tool that should be available."
    exit 1
fi

# Input validation
if [ $# -lt 1 ]; then
    echo "❌ Usage: $0 <input-png-file> [output-name] [options]"
    echo "Options:"
    echo "  --high-quality   Use higher quality resampling (slower)"
    echo "  --background=#   Set background color for transparent images"
    echo "  --round          Apply rounded corners"
    echo ""
    echo "Examples:"
    echo "  $0 Assets/app.png AppIcon"
    echo "  $0 icon.png MyIcon --high-quality --round"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_NAME="${2:-AppIcon}"
HIGH_QUALITY=false
BACKGROUND_COLOR=""
ROUNDED=false

# Parse additional options
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        --high-quality)
            HIGH_QUALITY=true
            shift
            ;;
        --background=*)
            BACKGROUND_COLOR="${1#*=}"
            shift
            ;;
        --round)
            ROUNDED=true
            shift
            ;;
        *)
            echo "⚠️  Unknown option: $1"
            shift
            ;;
    esac
done

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Get image info
IMAGE_INFO=$(identify "$INPUT_FILE")
IMAGE_WIDTH=$(echo "$IMAGE_INFO" | awk '{print $3}' | cut -d'x' -f1)
IMAGE_HEIGHT=$(echo "$IMAGE_INFO" | awk '{print $3}' | cut -d'x' -f2)

echo "🎨 Converting icon: $INPUT_FILE"
echo "📏 Original size: ${IMAGE_WIDTH}x${IMAGE_HEIGHT}"
echo "📁 Output name: $OUTPUT_NAME"
echo "⚙️  High quality: $HIGH_QUALITY"
echo "🎨 Background: ${BACKGROUND_COLOR:-transparent}"
echo "🔘 Rounded corners: $ROUNDED"

# Get directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$(mktemp -d)"

# Create iconset directory
ICONSET_DIR="$WORK_DIR/${OUTPUT_NAME}.iconset"
mkdir -p "$ICONSET_DIR"

# Prepare convert options
CONVERT_OPTS=""
if [ "$HIGH_QUALITY" = true ]; then
    CONVERT_OPTS="$CONVERT_OPTS -filter Lanczos -density 300"
fi

if [ -n "$BACKGROUND_COLOR" ]; then
    CONVERT_OPTS="$CONVERT_OPTS -background '$BACKGROUND_COLOR' -flatten"
fi

if [ "$ROUNDED" = true ]; then
    CONVERT_OPTS="$CONVERT_OPTS -define distort:viewport=%[fx:w]x%[fx:h] -distort SRT 0 +clone -alpha extract -fill white -colorize 100% -fill black -draw 'circle %[fx:w/2],%[fx:h/2] %[fx:w/2],0' -alpha off -compose copy_opacity -composite"
fi

# Function to convert size
convert_size() {
    local size=$1
    local output=$2
    
    if [ "$HIGH_QUALITY" = true ]; then
        convert "$INPUT_FILE" $CONVERT_OPTS -resize ${size}x${size} "$output"
    else
        sips -z $size $size "$INPUT_FILE" --out "$output" >/dev/null 2>&1
    fi
}

# Generate all required sizes
echo "🔧 Generating icon sizes..."

# All required sizes for macOS app icons
SIZES=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

for size_info in "${SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    convert_size "$size" "$ICONSET_DIR/$filename"
    echo "  ✓ ${size}x${size} → $filename"
done

# Convert iconset to ICNS
echo "🔄 Creating ICNS file..."
iconutil -c icns "$ICONSET_DIR"

# Copy result to Assets directory
ASSETS_DIR="$PROJECT_DIR/Assets"
mkdir -p "$ASSETS_DIR"
cp "$WORK_DIR/${OUTPUT_NAME}.icns" "$ASSETS_DIR/"

# Clean up
rm -rf "$WORK_DIR"

# Show file size
ICNS_SIZE=$(du -h "$ASSETS_DIR/${OUTPUT_NAME}.icns" | cut -f1)

echo ""
echo "✅ Icon conversion completed!"
echo "📦 Output: $ASSETS_DIR/${OUTPUT_NAME}.icns ($ICNS_SIZE)"
echo ""
echo "📝 Next steps:"
echo "   1. Make sure Info.plist references the icon name:"
echo "      <key>CFBundleIconFile</key>"
echo "      <string>${OUTPUT_NAME}</string>"
echo "   2. Rebuild your app: make build"
echo ""
echo "🎉 Your app is now ready with the new icon!"