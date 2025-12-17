<div align="center">

# 🎯 Copy Path Finder
# 📋 文件路径复制工具

[![Release](https://img.shields.io/github/release/tekintian/CopyPathFinder.svg)](https://github.com/tekintian/CopyPathFinder/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-10.15%2B--11.0%2B-brightgreen.svg)](https://www.apple.com/macos/)

**🚀 一键复制文件路径 | ⚡ 效率提升神器 | 🍎 Mac 原生体验**

*A lightweight macOS utility to copy file paths from Finder to clipboard with global shortcut.*

**🌟 轻量级 macOS 工具，通过全局快捷键一键复制 Finder 文件路径到剪贴板**

---

[中文介绍](#-项目简介) | [English Introduction](#-introduction)

</div>

<br>

## 🎨 项目简介 | Introduction

### 🇨🇳 中文介绍

厌倦了在 Mac 上反复手动输入文件路径？🤯  
**Copy Path Finder** 是你的效率救星！✨

🔹 **一键复制**：选中文件，按下 `⌘⇧C`，路径即刻到剪贴板  
🔹 **全局可用**：无论你在哪个应用，都能快速复制文件路径  
🔹 **原生体验**：纯 Swift 开发，完美融入 macOS 生态  
🔹 **界面简洁**：状态栏图标，不占用 Dock 空间  
🔹 **安全可靠**：最小权限要求，保护你的隐私  

🎯 **完美适用场景**：
- 开发者需要引用文件路径
- 设计师整理素材库
- 用户分享文件给同事
- 自动化脚本需要文件路径

**让文件路径复制变得像呼吸一样自然！** 🌬️

---

### 🇺🇸 English Introduction

Tired of manually typing file paths on Mac? 🤯  
**Copy Path Finder** is your efficiency savior! ✨

🔹 **One-Click Copy**: Select files, press `⌘⇧C`, path instantly copied  
🔹 **Global Access**: Copy file paths from anywhere, anytime  
🔹 **Native Experience**: Built with pure Swift, seamlessly integrates with macOS  
🔹 **Clean Interface**: Menu bar icon, doesn't clutter your Dock  
🔹 **Secure & Reliable**: Minimal permissions required, privacy protected  

🎯 **Perfect for**:
- Developers referencing file paths
- Designers organizing asset libraries  
- Users sharing files with colleagues
- Automation scripts needing file paths

**Make copying file paths as natural as breathing!** 🌬️

## ✨ 核心功能 | Core Features

### 🇨🇳 功能特色

| 功能图标 | 功能描述 | 快捷键 |
|---------|----------|--------|
| 🎯 | **智能识别** - 自动检测选中的文件、文件夹、应用 | `⌘⇧C` |
| ⚡ | **极速复制** - 毫秒级响应，即时复制到剪贴板 | - |
| 🌍 | **全局可用** - 在任何应用中都能快速复制文件路径 | - |
| 🎨 | **界面精美** - 状态栏图标，不影响工作空间 | - |
| 🛡️ | **安全可靠** - 最小权限，保护用户隐私 | - |
| 🔄 | **多格式支持** - 支持文件路径、文件夹路径、应用路径 | - |
| 📱 | **系统集成** - 完美融入 macOS 生态系统 | - |

### 🇺🇸 Feature Highlights

| Icon | Feature | Shortcut |
|------|---------|----------|
| 🎯 | **Smart Detection** - Automatically detects selected files, folders, apps | `⌘⇧C` |
| ⚡ | **Lightning Fast** - Millisecond response, instant clipboard copy | - |
| 🌍 | **Global Access** - Copy file paths from anywhere, anytime | - |
| 🎨 | **Beautiful UI** - Clean menu bar icon, no workspace clutter | - |
| 🛡️ | **Secure & Safe** - Minimal permissions, privacy protected | - |
| 🔄 | **Multi-Format Support** - File paths, folder paths, app paths | - |
| 📱 | **System Integration** - Perfectly integrated into macOS ecosystem | - |

---

## 🚀 快速开始 | Quick Start

### 📦 一键安装 | One-Click Install

<div align="center">

[![Download DMG](https://img.shields.io/badge/📥-Download%20DMG-blue?style=for-the-badge)](https://github.com/tekintian/CopyPathFinder/releases/latest)
[![Download ZIP](https://img.shields.io/badge/📦-Download%20ZIP-green?style=for-the-badge)](https://github.com/tekintian/CopyPathFinder/releases/latest)

</div>

### 🔧 使用步骤 | Usage Steps

1. **🚀 启动应用** - 应用图标出现在状态栏
2. **📁 选择文件** - 在 Finder 中选择目标文件或文件夹
3. **⌨️ 按下快捷键** - `⌘⇧C` 一键复制路径
4. **📋 粘贴使用** - 在任何地方粘贴路径

**就是这么简单！** 🎉

---

## 📸 界面预览 | Interface Preview

```
┌─────────────────────────────────────────────────────────────┐
│                    macOS Menu Bar                          │
│  📋 Copy Path Finder  🌐 🗓️  🔋  👤                        │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────┐
│ Copy Path Finder ▼                      │
├─────────────────────────────────────────┤
│ 📋 Copy Selected Path                  │
│ ⌨️ Shortcut: ⌘⇧C                      │
├─────────────────────────────────────────┤
│ ℹ️ About Copy Path Finder               │
│ ❌ Quit                                 │
└─────────────────────────────────────────┘
```

**🎯 工作流程演示:**

```
Finder 选择文件  →  按下 ⌘⇧C  →  路径复制到剪贴板

📁 /Users/yourname/Documents/Project/
         ↓
   ⌘⇧C
         ↓
📋 剪贴板: /Users/yourname/Documents/Project/
```

---

## 🎪 使用场景 | Use Cases

### 🇨🇳 实际应用

| 场景 | 描述 | 效率提升 |
|------|------|----------|
| 💻 **开发编程** | 复制文件路径到 IDE、终端 | ⚡⚡⚡ |
| 🎨 **设计工作** | 整理设计素材、资源文件 | ⚡⚡ |
| 📊 **办公文档** | 在邮件中分享文件位置 | ⚡⚡ |
| 🔧 **技术支持** | 帮助用户定位配置文件 | ⚡⚡⚡ |

### 🇺🇸 Real-World Applications

| Scenario | Description | Efficiency Boost |
|----------|-------------|-------------------|
| 💻 **Development** | Copy file paths to IDE, terminal | ⚡⚡⚡ |
| 🎨 **Design Work** | Organize design assets, resources | ⚡⚡ |
| 📊 **Office Work** | Share file locations in emails | ⚡⚡ |
| 🔧 **Tech Support** | Help users locate config files | ⚡⚡⚡ |

## 🏗️ 架构支持 | Architecture Support

Copy Path Finder 支持多架构，为不同 Mac 硬件提供最佳性能和兼容性：

### 📋 选择合适的版本

| 架构版本 | 支持系统 | 适用设备 | 下载文件 |
|---------|---------|---------|---------|
| **Intel (x86_64)** | macOS 10.15+ | Intel 芯片 Mac | `CopyPathFinder-Intel.dmg` |
| **Apple Silicon (ARM64)** | macOS 11.0+ | M123 芯片 Mac | `CopyPathFinder-ARM64.dmg` |

### 🎯 如何选择？

- **Intel Mac** (2019 年及之前型号): 下载 **Intel 版本**
- **Apple Silicon Mac** (M123 芯片): 下载 **ARM64 版本**
- **不确定设备型号**: 点击 Apple 菜单 → "关于本机" → 查看"芯片"或"处理器"信息

### 🚀 性能优势

- **Intel 版本**: 完全兼容 macOS 10.15 Catalina 及更新版本
- **ARM64 版本**: 为 Apple Silicon 优化，性能更佳，功耗更低
- **分别构建**: 避免通用二进制文件的兼容性问题，确保最佳稳定性

---

## Installation

### 📦 Download Release (Recommended)

Download the latest release from [GitHub Releases](https://github.com/tekintian/CopyPathFinder/releases):

- **Intel 版本**: `CopyPathFinder-Intel.dmg` (适用于 Intel 芯片 Mac)
- **ARM64 版本**: `CopyPathFinder-ARM64.dmg` (适用于 Apple Silicon Mac)

> ⚠️ **安全提示**: 应用使用自签名证书，首次运行需在"系统设置 > 隐私与安全性"中允许运行
> 
> 💡 **架构提示**: 请根据你的 Mac 芯片选择对应的版本，确保最佳兼容性

### 🔧 Build from Source

```bash
git clone https://github.com/tekintian/CopyPathFinder.git
cd CopyPathFinder

# Build with self-signing
./scripts/build.sh release simple

# Or build without signing
swift build -c release

# Run the app
open .build/CopyPathFinder.app
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

- **Intel 版本**: macOS 10.15 (Catalina) 或更高版本
- **ARM64 版本**: macOS 11.0 (Big Sur) 或更高版本
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

---

## 🌟 支持我们 | Support Us

<div align="center">

### 🙏 为什么选择 Copy Path Finder？

🔹 **开源免费** - 完全免费，源代码透明  
🔹 **持续更新** - 定期更新，不断优化体验  
🔹 **社区驱动** - 欢迎贡献，共同改进  
🔹 **轻量可靠** - 小巧体积，稳定运行  

---

### ⭐ 给个 Star 吧！

如果你觉得这个工具有用，请在 GitHub 上给我们一个 ⭐ Star！

这会激励我们继续开发和维护这个项目！🚀

[![GitHub stars](https://img.shields.io/github/stars/tekintian/CopyPathFinder.svg?style=social&label=Star)](https://github.com/tekintian/CopyPathFinder)

---

### 🤝 参与贡献 | Contributing

我们欢迎所有形式的贡献！🎉

#### 🇨🇳 贡献方式

1. **🐛 报告问题** - 发现 Bug 请提交 Issue
2. **💡 功能建议** - 提出新功能想法
3. **📝 改进文档** - 完善使用说明
4. **🔧 代码贡献** - 提交 Pull Request

#### 🇺🇸 How to Contribute

1. **🐛 Report Issues** - Found a bug? Open an issue
2. **💡 Feature Requests** - Share your ideas
3. **📝 Documentation** - Help improve docs  
4. **🔧 Code Contributions** - Submit Pull Requests

<div align="left">

```bash
# Fork 项目
git clone https://github.com/YOUR_USERNAME/CopyPathFinder.git

# 创建功能分支
git checkout -b feature/amazing-feature

# 提交更改
git commit -m 'Add amazing feature'

# 推送分支
git push origin feature/amazing-feature

# 提交 Pull Request
```

</div>

---

## 📄 许可证 | License

本项目采用 [MIT 许可证](LICENSE) - 欢迎自由使用和修改！

---

## 🔗 相关链接 | Links

- [📖 完整文档](docs/) - 详细使用指南
- [🔐 自签名指南](docs/SELF_SIGNING.md) - 安全配置说明  
- [🚀 发布流程](docs/GITHUB_RELEASE.md) - 自动化发布
- [🐛 问题反馈](https://github.com/tekintian/CopyPathFinder/issues) - Bug 报告
- [💡 功能建议](https://github.com/tekintian/CopyPathFinder/discussions) - 功能讨论

---

<div align="center">

**🎯 让文件路径复制变得简单高效！**

**⚡ Download now and boost your productivity!**

_Made with ❤️ by the Copy Path Finder Team_

---

### 👥 贡献者 | Contributors

感谢所有为这个项目做出贡献的开发者！🙏

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->

---

<div align="center">

**[⬆️ 回到顶部](#-copy-path-finder--文件路径复制工具)**

</div>

</div>

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Based on the functionality of OpenInTerminal but simplified and modernized.