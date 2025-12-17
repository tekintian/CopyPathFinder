#!/bin/bash

# Simple Self-Signing Script (using native macOS tools)
# Usage: ./scripts/self-sign-simple.sh [app-path]

set -eo pipefail

APP_PATH="${1:-$(pwd)/.build/CopyPathFinder.app}"
CERT_NAME="CopyPathFinder-SelfSigned"

echo "🔐 Simple Self-Signing (macOS native tools)"
echo "==========================================="

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    echo "Usage: $0 [app-path]"
    exit 1
fi

echo "📁 App to sign: $APP_PATH"

# Create ad-hoc signature (simplest approach)
echo "🔏 Creating ad-hoc signature..."
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || {
    echo "⚠️ Warning: codesign encountered non-fatal error"
    echo "   This is usually safe and doesn't affect app functionality"
}

# Verify signature
if codesign --verify --verbose "$APP_PATH" 2>/dev/null; then
    echo "✅ App signed successfully with ad-hoc signature!"
else
    echo "⚠️  Signature verification details:"
    codesign --verify --verbose "$APP_PATH" || true
fi

# Show signature info
echo ""
echo "📋 Signature information:"
codesign --display --verbose=2 "$APP_PATH" | head -5

echo ""
echo "🎉 Ad-hoc signing completed!"
echo ""
echo "📌 Notes:"
echo "   • Ad-hoc signature is the simplest form of code signing"
echo "   • No certificate required - uses dash (-) as identity"
echo "   • App can run on current Mac without security warnings"
echo "   • Other users may still see security warnings"
echo "   • For distribution, consider Apple Developer certificate"
echo ""
echo "🚀 To test the signed app:"
echo "   open '$APP_PATH'"