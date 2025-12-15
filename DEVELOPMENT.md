# Development Guide

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url> CopyPathFinder
cd CopyPathFinder

# Initialize development environment
make init

# Run development version
make dev

# Build release version
make build

# Install to Applications
make install
```

## Project Structure

```
CopyPathFinder/
├── Sources/CopyPathFinder/
│   ├── main.swift                 # Main application entry point
│   └── Info.plist                # App configuration
├── Scripts/
│   ├── build.sh                  # Build script
│   ├── dev.sh                    # Development script
│   └── install.sh                # Installation script
├── Assets/                       # App resources
├── .github/workflows/            # CI/CD configuration
├── Package.swift                 # Swift Package Manager
├── Makefile                      # Build automation
└── README.md                     # Project documentation
```

## Development Workflow

### 1. Make Changes
Edit the source files in `Sources/CopyPathFinder/`

### 2. Test Locally
```bash
# Build and run in development mode
make dev

# Or manually
swift build -c debug
./.build/debug/CopyPathFinder
```

### 3. Build Release
```bash
# Create release build with app bundle
make build

# Or manually
./scripts/build.sh release
```

### 4. Install
```bash
# Install to /Applications folder
make install

# Or manually
./scripts/install.sh
```

## Code Style

- Follow Swift standard conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

## Permissions

The app requires:
- Apple Events access to communicate with Finder
- Accessibility permissions for global shortcuts

These are automatically requested on first launch.

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
make clean
make build
```

### Permission Issues
1. Open System Preferences > Security & Privacy
2. Go to Privacy tab
3. Add CopyPathFinder to:
   - Automation (for Finder access)
   - Accessibility (for global shortcuts)

### Global Shortcut Not Working
1. Check Accessibility permissions
2. Ensure no other app uses ⌘⇧C
3. Restart the app

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Release Process

1. Update version in Info.plist
2. Create a git tag: `git tag v1.0.0`
3. Push tag: `git push origin v1.0.0`
4. GitHub Actions will automatically create a release

## Dependencies

The project uses minimal dependencies:
- Swift standard library
- AppKit (for macOS UI)
- SwiftUI (for menu interface)

No external package dependencies required.