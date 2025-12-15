#!/bin/bash

# Status Bar Icon Creator
# Creates optimized status bar icons from app icon
# Usage: ./scripts/create-status-icon.sh [input-file] [output-name]

set -e

INPUT_FILE="${1:-Assets/app.png}"
OUTPUT_NAME="${2:-StatusIcon}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Get directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$(mktemp -d)"

echo "🎨 Creating status bar icon from: $INPUT_FILE"
echo "📁 Output name: $OUTPUT_NAME"

# Function to create status icon with better quality
create_status_icon() {
    local size=$1
    local output=$2
    
    # Use better resampling for small icons
    sips -z $size $size -s format png "$INPUT_FILE" --out "$output" >/dev/null 2>&1
    
    # Add padding and optimize for status bar visibility
    if command -v convert >/dev/null 2>&1; then
        # If ImageMagick is available, apply additional optimizations
        convert "$output" \
            -alpha off \
            -background none \
            -gravity center \
            -extent ${size}x${size} \
            "$output.tmp"
        mv "$output.tmp" "$output"
    fi
}

# Create standard size (16x16)
create_status_icon 16 "$WORK_DIR/${OUTPUT_NAME}.png"
echo "  ✓ Created 16x16 icon"

# Create retina size (22x22 for better display quality on Retina)
create_status_icon 22 "$WORK_DIR/${OUTPUT_NAME}@2x.png"
echo "  ✓ Created 22x22 retina icon"

# Copy to Assets directory
ASSETS_DIR="$PROJECT_DIR/Assets"
mkdir -p "$ASSETS_DIR"
cp "$WORK_DIR/${OUTPUT_NAME}.png" "$ASSETS_DIR/"
cp "$WORK_DIR/${OUTPUT_NAME}@2x.png" "$ASSETS_DIR/"

# Clean up
rm -rf "$WORK_DIR"

echo "✅ Status bar icon creation completed!"
echo "📦 Output files:"
echo "   $ASSETS_DIR/${OUTPUT_NAME}.png"
echo "   $ASSETS_DIR/${OUTPUT_NAME}@2x.png"
echo ""
echo "📝 Next steps:"
echo "   1. Rebuild your app: make build"
echo "   2. The status bar icon will automatically load if available"
echo ""
echo "💡 Tips:"
echo "   - Status bar icons should be simple and recognizable at small sizes"
echo "   - Consider using a monochrome design for better visibility"
echo "   - The icon will be treated as a template (adapts to light/dark mode)"