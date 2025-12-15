# Copy Path Finder

A lightweight macOS utility to copy file paths from Finder to clipboard with global shortcut.

## Features

- 🎯 **Simple & Fast**: Copy selected file/folder paths instantly
- ⌨️ **Global Shortcut**: Use `⌘⇧C` to copy paths from anywhere
- 📱 **Menu Bar App**: Minimal menu bar integration
- 🍎 **Native**: Built with Swift and SwiftUI for optimal performance
- 🔒 **Secure**: Minimal permissions required

## Installation

### Build from Source

```bash
git clone https://github.com/tekintian/CopyPathFinder.git
cd CopyPathFinder
swift build
open .build/release/CopyPathFinder
```

### Using Homebrew (Future)

```bash
brew install --cask copypathfinder
```

## Usage

1. Launch the app (appears in menu bar)
2. Select files/folders in Finder
3. Use `⌘⇧C` to copy path to clipboard
4. Or click the menu bar icon and select "Copy Path"

## Requirements

- macOS 13.0 or later
- Apple Events permission for Finder access

## Development

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release
```

### Running

```bash
# Run directly
swift run

# Run release build
swift run -c release
```

### Project Structure

```
CopyPathFinder/
├── Sources/CopyPathFinder/
│   ├── CopyPathFinderApp.swift    # Main application
│   └── Info.plist               # App configuration
├── Package.swift                  # Swift Package Manager
├── .github/workflows/            # GitHub Actions
│   └── ci.yml                    # CI/CD pipeline
└── README.md                     # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Based on the functionality of OpenInTerminal but simplified and modernized.