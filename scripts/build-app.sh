#!/bin/bash

# CopyPathFinder macOS 应用构建脚本
# 支持 macOS 10.15+ (Catalina)

set -e

# 解析命令行参数
BUILD_CONFIG="debug"
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            BUILD_CONFIG="release"
            shift
            ;;
        -d|--debug)
            BUILD_CONFIG="debug"
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  -r, --release  使用 release 配置构建"
            echo "  -d, --debug    使用 debug 配置构建 (默认)"
            echo "  -h, --help     显示此帮助信息"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 -h 查看帮助"
            exit 1
            ;;
    esac
done

echo "=== CopyPathFinder 应用构建脚本 ==="
echo "目标系统: macOS 10.15+"
echo "构建配置: $BUILD_CONFIG"
echo ""

# 检查构建环境
if ! command -v swift &> /dev/null; then
    echo "❌ 错误: 未找到 Swift 编译器"
    echo "请安装 Xcode Command Line Tools"
    exit 1
fi

# 清理之前的构建
echo "1. 清理之前的构建..."
rm -rf .build
rm -rf CopyPathFinder.app

# 编译项目
echo "2. 编译项目 ($BUILD_CONFIG 配置)..."
if swift build -c $BUILD_CONFIG; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 获取二进制文件路径
BIN_PATH=$(swift build -c $BUILD_CONFIG --show-bin-path 2>/dev/null || echo ".build/x86_64-apple-macosx/$BUILD_CONFIG")
EXECUTABLE_PATH="$BIN_PATH/CopyPathFinder"

# 创建应用包结构
echo "3. 创建应用包结构..."
mkdir -p CopyPathFinder.app/Contents/MacOS
mkdir -p CopyPathFinder.app/Contents/Resources

# 复制 Info.plist
echo "4. 复制 Info.plist..."
cp Sources/CopyPathFinder/Info.plist CopyPathFinder.app/Contents/

# 复制可执行文件
echo "5. 复制可执行文件..."
echo "查找路径: $EXECUTABLE_PATH"

if [ -f "$EXECUTABLE_PATH" ]; then
    cp "$EXECUTABLE_PATH" CopyPathFinder.app/Contents/MacOS/
    echo "✅ 可执行文件复制成功: $EXECUTABLE_PATH"
else
    echo "❌ 未找到可执行文件: $EXECUTABLE_PATH"
    echo "搜索可用的构建文件..."
    find .build -name "CopyPathFinder" -type f 2>/dev/null | while read file; do
        echo "找到: $file"
    done
    exit 1
fi

# 设置可执行权限
chmod +x CopyPathFinder.app/Contents/MacOS/CopyPathFinder

# 复制必要的资源文件
echo "6. 复制必要的资源文件..."
if [ -d "Assets" ]; then
    # 只复制应用实际使用的资源文件
    # 应用图标 (Info.plist中CFBundleIconFile指定)
    if [ -f "Assets/AppIcon.icns" ]; then
        cp "Assets/AppIcon.icns" CopyPathFinder.app/Contents/Resources/
        echo "  ✅ 复制应用图标: AppIcon.icns"
    fi
    
    # 状态栏图标
    if [ -f "Assets/StatusIcon.png" ]; then
        cp "Assets/StatusIcon.png" CopyPathFinder.app/Contents/Resources/
        echo "  ✅ 复制状态栏图标: StatusIcon.png"
    fi
    
    # Retina状态栏图标
    if [ -f "Assets/StatusIcon@2x.png" ]; then
        cp "Assets/StatusIcon@2x.png" CopyPathFinder.app/Contents/Resources/
        echo "  ✅ 复制Retina状态栏图标: StatusIcon@2x.png"
    fi
else
    echo "  ⚠️  Assets目录不存在，跳过资源复制"
fi

# 复制本地化资源
echo "7. 复制本地化资源..."
if [ -d "Sources/CopyPathFinder/Resources" ]; then
    cp -r Sources/CopyPathFinder/Resources/* CopyPathFinder.app/Contents/Resources/
    echo "  ✅ 复制本地化文件"
else
    echo "  ⚠️  本地化资源目录不存在"
fi

# 验证资源完整性
echo "7.1 验证资源完整性..."
REQUIRED_RESOURCES=("AppIcon.icns" "StatusIcon.png" "StatusIcon@2x.png")
MISSING_RESOURCES=()

for resource in "${REQUIRED_RESOURCES[@]}"; do
    if [ ! -f "CopyPathFinder.app/Contents/Resources/$resource" ]; then
        MISSING_RESOURCES+=("$resource")
    fi
done

if [ ${#MISSING_RESOURCES[@]} -eq 0 ]; then
    echo "  ✅ 所有必需资源已复制"
else
    echo "  ⚠️  缺少资源文件:"
    for missing in "${MISSING_RESOURCES[@]}"; do
        echo "     - $missing"
    done
fi

# 验证应用
echo "8. 验证应用..."
if [ -f "CopyPathFinder.app/Contents/MacOS/CopyPathFinder" ] && 
   [ -f "CopyPathFinder.app/Contents/Info.plist" ]; then
    echo "✅ 应用包创建成功"
else
    echo "❌ 应用包创建失败"
    exit 1
fi

# 检查兼容性信息
echo "9. 检查兼容性信息..."
min_version=$(defaults read $(pwd)/CopyPathFinder.app/Contents/Info.plist LSMinimumSystemVersion 2>/dev/null || echo "未知")
echo "最低系统版本: $min_version"

# 显示应用信息
echo ""
echo "=== 构建完成 ==="
echo "应用路径: $(pwd)/CopyPathFinder.app"
echo "应用大小: $(du -sh CopyPathFinder.app | cut -f1)"
echo ""

# 使用说明
echo "=== 使用说明 ==="
echo "1. 双击 CopyPathFinder.app 启动应用"
echo "2. 系统状态栏将显示应用图标"
echo "3. 点击图标打开功能菜单"
echo "4. 使用快捷键 ⌘⇧C 快速拷贝路径"
echo "5. 使用快捷键 ⌘⇧T 在终端中打开"
echo ""

echo "=== 故障排除 ==="
echo "如果应用无法启动，请检查："
echo "1. 系统安全设置: 系统偏好设置 > 安全性与隐私 > 允许从以下位置下载的应用"
echo "2. 应用权限: 确保应用有访问 Finder 的权限"
echo "3. 系统版本: 确保使用 macOS 10.15 或更高版本"
echo ""

echo "构建脚本执行完成！"