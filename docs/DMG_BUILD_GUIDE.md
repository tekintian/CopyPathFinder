# DMG 构建说明

## 功能特性

`scripts/build.sh` 脚本创建简洁的 macOS DMG 安装包，包含以下核心内容：

### 1. 应用程序包
- 包含完整的 `CopyPathFinder.app`
- 包含所有必要的资源文件和图标

### 2. 拖拽安装功能
- 在 DMG 中创建指向 `/Applications` 文件夹的快捷方式
- 用户可以直接将 `CopyPathFinder.app` 拖拽到 Applications 文件夹进行安装
- 提供了直观的安装体验

### 3. 版本管理
- 自动从 `Info.plist` 读取版本号
- 生成带版本号的 DMG 文件名：`CopyPathFinder_v{版本}.dmg`

## 使用方法

### 基本构建
```bash
./scripts/build.sh release
```

### 输出文件
- DMG 文件位置：`.build/CopyPathFinder_v{版本号}.dmg`
- 版本号从 `Info.plist` 中的 `CFBundleShortVersionString` 读取

## 技术实现

### DMG 创建流程
1. **构建应用**：使用 Swift Package Manager 构建 Release 版本
2. **创建应用包结构**：生成标准的 macOS .app 包结构
3. **准备 DMG 内容**：
   - 复制应用到 DMG 目录
   - 创建 Applications 文件夹符号链接
4. **生成 DMG**：使用 `hdiutil create` 直接创建压缩的 UDZO 格式 DMG

### 文件结构
生成的 DMG 包含以下内容：
```
Copy Path Finder (DMG Volume)
├── Applications -> /Applications  # 应用程序文件夹快捷方式
└── CopyPathFinder.app           # 应用程序包
```

## 依赖项

- macOS 系统自带的工具：
  - `hdiutil` - DMG 创建和管理
  - `PlistBuddy` - Info.plist 读取

## 使用示例

### 构建 Release 版本
```bash
./scripts/build.sh release
```

### 构建 Debug 版本（不生成 DMG）
```bash
./scripts/build.sh debug
```

## 构建输出

成功构建后，你会看到类似输出：
```
🚀 Building Copy Path Finder (release)...
🧹 Cleaning previous builds...
🔨 Building...
📦 Creating app bundle...
✅ Build completed!
💿 Creating DMG...
✅ DMG contents prepared:
   - CopyPathFinder.app
   - Applications (shortcut)
📀 DMG created: .build/CopyPathFinder_v1.0.0.dmg
🎉 Done!
```

## 安装说明

用户打开 DMG 后可以：
1. 看到 `CopyPathFinder.app` 应用程序包
2. 看到 `Applications` 快捷方式
3. 拖拽应用到 Applications 文件夹进行安装

这种简洁的方式保证了最大的兼容性和可靠性。