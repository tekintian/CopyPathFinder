# macOS 图标转换工具

这个目录包含了用于将PNG图像转换为macOS应用图标格式的工具。

## 工具概览

### 1. convert-icon.sh (推荐)
基于macOS内置的`sips`工具，无需额外依赖。

```bash
# 基本用法
./scripts/convert-icon.sh Assets/app.png

# 指定输出名称
./scripts/convert-icon.sh Assets/app.png AppIcon
```

**特点：**
- ✅ 无需额外依赖
- ✅ 快速简单
- ✅ 适合大多数场景

### 2. convert-icon-imagemagick.sh (高级版)
基于ImageMagick，提供更多选项和更好的质量。

```bash
# 安装依赖（如果需要）
brew install imagemagick

# 基本用法
./scripts/convert-icon-imagemagick.sh Assets/app.png

# 高质量转换
./scripts/convert-icon-imagemagick.sh Assets/app.png AppIcon --high-quality

# 圆角图标
./scripts/convert-icon-imagemagick.sh Assets/app.png AppIcon --round

# 设置背景色（处理透明图片）
./scripts/convert-icon-imagemagick.sh Assets/app.png AppIcon --background=#ffffff

# 组合选项
./scripts/convert-icon-imagemagick.sh Assets/app.png AppIcon --high-quality --round --background=#f0f0f0
```

**特点：**
- ✅ 更高质量的图像处理
- ✅ 支持圆角处理
- ✅ 支持背景色设置
- ✅ Lanczos重采样算法
- ❌ 需要安装ImageMagick

## 支持的输入格式

- PNG图像文件
- 推荐尺寸：1024x1024或更大
- 支持透明背景

## 生成的图标尺寸

工具会自动生成macOS应用所需的所有尺寸：

| 尺寸 | 用途 |
|------|------|
| 16x16 | Dock最小尺寸 |
| 32x32 | Dock标准尺寸 |
| 128x128 | Finder列表视图 |
| 256x256 | Finder图标视图 |
| 512x512 | Launchpad和Quick Look |
| 1024x1024 | Retina显示支持 |

## 使用工作流程

### 快速开始
```bash
# 1. 准备PNG图标文件（推荐1024x1024或更大）
# 2. 转换为ICNS格式
./scripts/convert-icon.sh Assets/your-icon.png

# 3. 重新构建应用
make build

# 4. 测试应用
open .build/CopyPathFinder.app
```

### 高质量转换
```bash
# 使用ImageMagick进行高质量转换
./scripts/convert-icon-imagemagick.sh Assets/your-icon.png AppIcon --high-quality

# 重新构建
make build
```

## 文件结构

转换后的文件结构：
```
Assets/
├── your-icon.png          # 原始文件
├── AppIcon.icns          # 生成的图标文件
└── README.md
```

构建后的应用结构：
```
.build/CopyPathFinder.app/Contents/
├── Info.plist
├── MacOS/
│   └── CopyPathFinder
└── Resources/
    └── AppIcon.icns      # 图标文件
```

## Info.plist 配置

确保Info.plist包含以下配置：

```xml
<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

## 故障排除

### 常见问题

1. **图标未显示**
   - 检查Info.plist中的CFBundleIconFile配置
   - 确保ICNS文件存在于Resources目录
   - 重启Finder或注销重新登录

2. **转换失败**
   - 检查输入文件是否为PNG格式
   - 确保文件路径正确
   - 检查文件权限

3. **图标质量不佳**
   - 使用高分辨率原始图像（1024x1024或更大）
   - 尝试使用ImageMagick版本的高质量选项
   - 确保原始图像质量良好

### 权限问题

如果遇到权限问题：
```bash
chmod +x scripts/convert-icon.sh
chmod +x scripts/convert-icon-imagemagick.sh
```

## 图标设计建议

- **尺寸**: 推荐1024x1024像素
- **格式**: PNG，支持透明度
- **设计**: 简洁清晰，在小尺寸下仍可识别
- **对比度**: 确保在深色和浅色背景下都清晰可见
- **风格**: 与macOS设计语言保持一致

## 相关工具

- **sips**: macOS内置图像处理工具
- **iconutil**: macOS图标转换工具
- **ImageMagick**: 高级图像处理套件（可选）
- **Preview.app**: macOS内置图像查看和编辑工具

## 更多资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [macOS App Icon Design](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [Icon Design Best Practices](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/)