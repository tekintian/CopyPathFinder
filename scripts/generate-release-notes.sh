#!/bin/bash

# Generate Release Notes Script
# Usage: ./scripts/generate-release-notes.sh [version]

set -e

VERSION=${1:-"latest"}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📋 Generating release notes for $VERSION..."

# Get last tag for changelog
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commits since last tag
if [ -n "$LAST_TAG" ]; then
    COMMITS=$(git log --oneline --no-merges "$LAST_TAG"..HEAD 2>/dev/null || echo "")
else
    COMMITS=$(git log --oneline --no-merges -10 2>/dev/null || echo "")
fi

# Generate changelog section
CHANGELOG=""
if [ -n "$COMMITS" ]; then
    CHANGELOG="## 🎯 版本更新

### ✨ 新增功能
$COMMITS" | grep -E "(feat|add|new)" | sed 's/^[a-f0-9]* \[\?[a-z]*\]\?/ - /' || echo " - 本版本的功能更新"

    echo "
### 🐛 问题修复
$COMMITS" | grep -E "(fix|bug)" | sed 's/^[a-f0-9]* \[\?[a-z]*\]\?/ - /' || echo " - 修复的已知问题"

    echo "
### ⚡ 性能优化
$COMMITS" | grep -E "(perf|improve|update)" | sed 's/^[a-f0-9]* \[\?[a-z]*\]\?/ - /' || echo " - 性能和稳定性改进"
fi

# Generate full release notes
cat > "$PROJECT_DIR/.github/release_notes.md" << EOF
# 🚀 Copy Path Finder $VERSION

## 📦 下载说明

### 🔧 安装方法

1. **DMG 安装包** (推荐)
   - 下载 \`CopyPathFinder.dmg\`
   - 双击挂载，拖拽应用到 Applications 文件夹
   - 首次运行可能需要允许运行

2. **ZIP 压缩包**
   - 下载 \`CopyPathFinder.zip\`
   - 解压后将 \`CopyPathFinder.app\` 复制到 Applications 文件夹

### 🔐 安全提示

本版本使用自签名证书，首次运行时可能看到安全提示：

**解决方法：**
- 右键点击应用 → "打开" → 在弹出的警告中点击"打开"
- 或在"系统设置 > 隐私与安全性"中点击"仍要打开"

**命令行方式：**
\`\`\`bash
# 移除隔离属性
xattr -d com.apple.quarantine /Applications/CopyPathFinder.app
\`\`\`

### ✨ 功能特性

- 📋 一键复制文件路径
- 🎯 支持 Finder 和访达
- 🍎 专为 macOS 设计
- 📱 状态栏图标，随时可用
- 🌍 支持中英文界面
- ⚡ 轻量快速，占用资源少
- 🎨 简洁美观的用户界面

### 🖥️ 系统要求

- macOS 10.15 或更高版本
- 需要授予 Apple Events 权限

### 📝 使用方法

1. 启动应用后，状态栏会显示图标
2. 在 Finder 中选中文件或文件夹
3. 点击状态栏图标或使用快捷键
4. 文件路径将自动复制到剪贴板

### 🔑 权限设置

首次使用时，需要授予以下权限：

1. **Apple Events 权限**
   - 系统设置 > 隐私与安全性 > 自动化
   - 找到 CopyPathFinder，允许控制 Finder

2. **辅助功能权限** (如需要)
   - 系统设置 > 隐私与安全性 > 辅助功能
   - 添加 CopyPathFinder 到允许列表

### 🔗 相关链接

- [📖 完整文档](https://github.com/tekintian/CopyPathFinder/blob/main/README.md)
- [🔐 自签名指南](https://github.com/tekintian/CopyPathFinder/blob/main/docs/SELF_SIGNING.md)
- [🐛 问题反馈](https://github.com/tekintian/CopyPathFinder/issues)
- [💡 功能建议](https://github.com/tekintian/CopyPathFinder/discussions)

---

## 📊 文件校验

为确保下载文件的完整性，请使用 SHA256 校验和：

\`\`\`bash
# 验证 DMG 文件
sha256sum -c CopyPathFinder.dmg.sha256

# 验证 ZIP 文件  
sha256sum -c CopyPathFinder.zip.sha256
\`\`\`

$CHANGELOG

---

## ⚠️ 免责声明

本软件仅供学习和个人使用，使用风险自负。作者不对因使用本软件造成的任何损失承担责任。

## 📄 许可证

本软件采用 MIT 许可证，详见 [LICENSE](https://github.com/tekintian/CopyPathFinder/blob/main/LICENSE) 文件。

---

**🙏 感谢使用 Copy Path Finder！**

如果觉得有用，请给个 ⭐ Star 支持一下！
EOF

echo "✅ Release notes generated: $PROJECT_DIR/.github/release_notes.md"
echo "📋 Chelog based on $([ -n "$LAST_TAG" ] && echo "commits since $LAST_TAG" || echo "recent commits")"