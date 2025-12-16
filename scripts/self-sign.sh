#!/bin/bash

# Copy Path Finder Self-Signing Script
# This script creates a self-signed certificate and signs the app
# Usage: ./scripts/self-sign.sh [--create-cert] [--sign-only] [app-path]

set -e

# Parse arguments
CREATE_CERT=false
SIGN_ONLY=false
APP_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --create-cert)
            CREATE_CERT=true
            shift
            ;;
        --sign-only)
            SIGN_ONLY=true
            shift
            ;;
        *)
            APP_PATH="$1"
            shift
            ;;
    esac
done

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default app path if not provided
if [ -z "$APP_PATH" ]; then
    APP_PATH="$PROJECT_DIR/.build/CopyPathFinder.app"
fi

# Certificate details
CERT_NAME="CopyPathFinder-SelfSigned"
CERT_SUBJECT="CN=CopyPathFinder Self-Signed, OU=Development, O=CopyPathFinder, C=US"
CERT_P12="$PROJECT_DIR/.build/CopyPathFinder.p12"

echo "🔐 Copy Path Finder Self-Signing Tool"
echo "====================================="

# Function to create self-signed certificate
create_certificate() {
    echo "📋 Creating self-signed certificate..."
    
    # Create .build directory if it doesn't exist
    mkdir -p "$(dirname "$CERT_P12")"
    
    # Create temporary keychain
    TEMP_KEYCHAIN="$HOME/Library/Keychains/self-sign.keychain-db"
    security create-keychain -p "self-sign" "$TEMP_KEYCHAIN" 2>/dev/null || true
    security unlock-keychain -p "self-sign" "$TEMP_KEYCHAIN"
    security set-keychain-settings -t 3600 -u "$TEMP_KEYCHAIN"
    
    # Create certificate authority and code signing certificate
    cat > "$PROJECT_DIR/.build/cert.conf" << 'EOF'
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
CN = CopyPathFinder Self-Signed

[v3_ca]
basicConstraints = critical,CA:true
keyUsage = critical,digitalSignature,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF

    # Generate private key and certificate
    openssl req -x509 -newkey rsa:2048 -keyout "$PROJECT_DIR/.build/private.key" -out "$PROJECT_DIR/.build/certificate.crt" -days 365 -nodes -config "$PROJECT_DIR/.build/cert.conf"
    
    # Create PKCS12 file
    openssl pkcs12 -export -out "$CERT_P12" -inkey "$PROJECT_DIR/.build/private.key" -in "$PROJECT_DIR/.build/certificate.crt" -password pass:copypathfinder
    
    # Import certificate to keychain
    security import "$CERT_P12" -k "$TEMP_KEYCHAIN" -P "copypathfinder" -T /usr/bin/codesign
    
    # Trust the certificate
    security add-trusted-cert -d -r trustRoot -k "$TEMP_KEYCHAIN" "$PROJECT_DIR/.build/certificate.crt"
    
    echo "✅ Certificate created and imported successfully!"
    echo "   Certificate name: $CERT_NAME"
    echo "   Certificate file: $CERT_P12"
    
    # Clean up temporary files
    rm -f "$PROJECT_DIR/.build/cert.conf"
}

# Function to sign the app
sign_app() {
    echo "📝 Signing application..."
    
    if [ ! -d "$APP_PATH" ]; then
        echo "❌ Error: App not found at $APP_PATH"
        exit 1
    fi
    
    # Try to use the certificate from keychain first
    if security find-identity -v -p codesigning | grep -q "$CERT_NAME"; then
        echo "🔍 Found existing certificate in keychain"
        CERT_IDENTITY="$CERT_NAME"
    else
        echo "🔍 Using certificate from file"
        CERT_IDENTITY="$CERT_P12"
    fi
    
    # Sign the app
    echo "   Signing with identity: $CERT_IDENTITY"
    codesign --force --deep --sign "$CERT_IDENTITY" "$APP_PATH"
    
    # Verify signature
    if codesign --verify --verbose "$APP_PATH" 2>&1 | grep -q "valid on disk"; then
        echo "✅ App signed successfully!"
        echo "   Signed app: $APP_PATH"
    else
        echo "⚠️  Warning: Signature verification failed"
        codesign --verify --verbose "$APP_PATH"
    fi
    
    # Show signature details
    echo "📋 Signature details:"
    codesign --display --verbose=4 "$APP_PATH" | head -10
}

# Function to notarize (optional - requires Apple Developer account)
notarize_app() {
    echo "🏛️  Note: Notarization requires Apple Developer account"
    echo "   Skipping notarization for self-signed certificate"
    echo "   For distribution, consider enrolling in Apple Developer Program"
}

# Main execution
if [ "$SIGN_ONLY" = false ] && [ "$CREATE_CERT" = false ]; then
    # Default behavior: create certificate and sign
    create_certificate
    sign_app
    notarize_app
elif [ "$CREATE_CERT" = true ]; then
    create_certificate
elif [ "$SIGN_ONLY" = true ]; then
    sign_app
    notarize_app
fi

echo ""
echo "🎉 Self-signing process completed!"
echo ""
echo "📌 Important notes:"
echo "   • Self-signed certificates are trusted only on this machine"
echo "   • Other users will see a security warning when running the app"
echo "   • For distribution, use an Apple Developer certificate"
echo "   • The app may need to be allowed in System Settings > Privacy & Security"
echo ""
echo "🚀 To run the app:"
echo "   1. Double-click the app"
echo "   2. If prompted with security warning, click 'Open Anyway'"
echo "   3. Or use: open '$APP_PATH'"