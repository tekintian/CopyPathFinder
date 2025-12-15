# macOS 图标转换工具

这个目录包含了用于将PNG图像转换为macOS应用图标格式的工具，包括应用图标和状态栏图标。

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

### 2. create-status-icon.sh (状态栏图标)
专门为macOS状态栏创建优化的小图标。

```bash
# 基本用法（从app.png创建状态栏图标）
./scripts/create-status-icon.sh Assets/app.png

# 指定输入文件和输出名称
./scripts/create-status-icon.sh path/to/icon.png StatusIcon
```

**特点：**
- ✅ 专为状态栏优化的尺寸（16x16, 22x22）
- ✅ 自动优化小尺寸显示效果
- ✅ 支持Retina显示
- ✅ 模板图标（适应明暗主题）

### 3. convert-icon-imagemagick.sh (高级版)
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

# 3. 创建状态栏图标
./scripts/create-status-icon.sh Assets/your-icon.png

# 4. 重新构建应用
make build

# 5. 测试应用
open .build/CopyPathFinder.app
```

### 高质量转换
```bash
# 使用ImageMagick进行高质量转换
./scripts/convert-icon-imagemagick.sh Assets/your-icon.png AppIcon --high-quality

# 创建状态栏图标
./scripts/create-status-icon.sh Assets/your-icon.png

# 重新构建
make build
```

## 文件结构

转换后的文件结构：
```
Assets/
├── app.png               # 原始应用图标
├── AppIcon.icns          # 生成的应用图标
├── StatusIcon.png        # 状态栏图标 (16x16)
├── StatusIcon@2x.png     # 状态栏图标 Retina (22x22)
└── README.md
```

构建后的应用结构：
```
.build/CopyPathFinder.app/Contents/
├── Info.plist
├── MacOS/
│   └── CopyPathFinder
└── Resources/
    ├── AppIcon.icns      # 应用图标
    ├── StatusIcon.png    # 状态栏图标
    └── StatusIcon@2x.png # 状态栏Retina图标
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

### 应用图标
- **尺寸**: 推荐1024x1024像素
- **格式**: PNG，支持透明度
- **设计**: 简洁清晰，在小尺寸下仍可识别
- **对比度**: 确保在深色和浅色背景下都清晰可见
- **风格**: 与macOS设计语言保持一致

### 状态栏图标
- **尺寸**: 16x16像素（标准），22x22像素（Retina）
- **格式**: PNG，支持透明度
- **设计**: 极简设计，在16px尺寸下清晰可识别
- **颜色**: 单色设计，作为模板图标适应系统主题
- **识别性**: 确保在任何背景下都能快速识别

### 通用建议
- 使用简洁的几何形状
- 避免过于复杂的细节
- 确保重要元素在小尺寸下仍然可见
- 测试在不同背景下的显示效果

## 相关工具

- **sips**: macOS内置图像处理工具
- **iconutil**: macOS图标转换工具
- **ImageMagick**: 高级图像处理套件（可选）
- **Preview.app**: macOS内置图像查看和编辑工具

## 更多资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [macOS App Icon Design](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [Icon Design Best Practices](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/)