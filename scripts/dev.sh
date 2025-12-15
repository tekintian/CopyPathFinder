#!/bin/bash

# Copy Path Finder Development Script
# Usage: ./scripts/dev.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CopyPathFinder"

echo "🔧 Starting development environment for $APP_NAME..."

# Kill any existing instances
echo "🔄 Stopping existing instances..."
pkill -f "$APP_NAME" 2>/dev/null || true

# Build and run in debug mode
echo "🏗️  Building debug version..."
cd "$PROJECT_DIR"
swift build -c debug

echo "🚀 Launching app..."
"$PROJECT_DIR/.build/debug/$APP_NAME" &

echo "✅ Development environment ready!"
echo "App is running. Check your menu bar for the Copy Path Finder icon."
echo ""
echo "🎯 To test:"
echo "1. Select files in Finder"
echo "2. Press ⌘⇧C to copy paths"
echo "3. Or click the menu bar icon"
echo ""
echo "🛑 To stop: pkill -f '$APP_NAME'"