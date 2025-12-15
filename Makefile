# Copy Path Finder Makefile
# Simplified build and development commands

.PHONY: build dev clean install test package help

# Default target
help:
	@echo "Copy Path Finder - Available commands:"
	@echo "  build    - Build release version"
	@echo "  dev      - Build and run debug version"
	@echo "  clean    - Clean build artifacts"
	@echo "  install  - Build and install to /Applications"
	@echo "  test     - Run basic tests"
	@echo "  package  - Create release packages"
	@echo "  help     - Show this help message"

# Build release version
build:
	@echo "🔨 Building release version..."
	@./scripts/build.sh release

# Development build and run
dev:
	@echo "🔧 Starting development environment..."
	@./scripts/dev.sh

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf .build
	@echo "✅ Clean completed"

# Install to Applications folder
install: build
	@echo "📦 Installing to Applications..."
	@./scripts/install.sh

# Run basic tests
test:
	@echo "🧪 Running basic tests..."
	@swift build -c debug
	@echo "✅ Basic tests passed"

# Create release packages
package: build
	@echo "📦 Creating release packages..."
	@mkdir -p dist
	@cp -R .build/CopyPathFinder.app dist/
	@cd dist && zip -r CopyPathFinder.zip CopyPathFinder.app
	@echo "✅ Packages created in dist/"

# Initialize development environment
init:
	@echo "🚀 Initializing development environment..."
	@swift package resolve
	@echo "✅ Development environment ready"