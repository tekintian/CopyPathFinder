#!/bin/bash

# 优化应用图标大小
# 用法: ./scripts/optimize-icon.sh [--max-size=256|512]

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_FILE="$PROJECT_DIR/Assets/AppIcon.icns"
MAX_SIZE="512"  # Default max size

# Parse optional max-size parameter
for arg in "$@"; do
    case $arg in
        --max-size=*)
            MAX_SIZE="${arg#*=}"
            if [[ "$MAX_SIZE" != "256" && "$MAX_SIZE" != "512" ]]; then
                echo "❌ Error: --max-size must be 256 or 512"
                exit 1
            fi
            ;;
        --help|-h)
            echo "用法: $0 [--max-size=256|512]"
            echo ""
            echo "选项:"
            echo "  --max-size=256  优化为最大256x256 (推荐，文件最小)"
            echo "  --max-size=512  最大512x512 (默认)"
            echo "  --help          显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0               # 使用默认512设置"
            echo "  $0 --max-size=256 # 优化为更小文件"
            exit 0
            ;;
    esac
done

if [ ! -f "$ICON_FILE" ]; then
    echo "❌ 找不到图标文件: $ICON_FILE"
    exit 1
fi

echo "🔍 检查原始图标大小..."
ORIGINAL_SIZE=$(du -h "$ICON_FILE" | cut -f1)
echo "原始大小: $ORIGINAL_SIZE"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
ICONSET_DIR="$TEMP_DIR/AppIcon.iconset"

# 提取iconset
echo "📦 提取图标集..."
iconutil -c iconset "$ICON_FILE" -o "$TEMP_DIR"

# 根据优化设置移除不需要的文件
if [ "$MAX_SIZE" = "256" ]; then
    echo "🗑️  移除512x512和1024x1024分辨率图标..."
    rm -f "$ICONSET_DIR/icon_512x512.png" "$ICONSET_DIR/icon_512x512@2x.png"
    echo "⚡ 使用最大256x256分辨率 (最佳优化)"
else
    echo "🗑️  移除过大的1024x1024分辨率图标..."
    rm -f "$ICONSET_DIR/icon_512x512@2x.png"
    echo "⚡ 使用最大512x512分辨率 (标准优化)"
fi

# 重新生成优化的icns
echo "⚡ 生成优化后的图标..."
OPTIMIZED_ICON="$TEMP_DIR/AppIcon_optimized.icns"
iconutil -c icns "$ICONSET_DIR" -o "$OPTIMIZED_ICON"

# 备份原文件
BACKUP_FILE="$ICON_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "💾 备份原文件到: $BACKUP_FILE"
cp "$ICON_FILE" "$BACKUP_FILE"

# 替换为优化版本
echo "🔄 替换为优化版本..."
cp "$OPTIMIZED_ICON" "$ICON_FILE"

# 显示结果
OPTIMIZED_SIZE=$(du -h "$ICON_FILE" | cut -f1)
SAVING=$(( ($(stat -f%z "$BACKUP_FILE") - $(stat -f%z "$ICON_FILE")) / 1024 ))
echo "✅ 优化完成!"
echo "   原始大小: $ORIGINAL_SIZE"
echo "   优化后: $OPTIMIZED_SIZE"
echo "   节省: ${SAVING}KB"
echo "   备份: $BACKUP_FILE"

# 清理
rm -rf "$TEMP_DIR"

echo "🎉 图标优化完成!"
echo ""
echo "💡 提示:"
if [ "$MAX_SIZE" = "256" ]; then
    echo "   - 使用256x256最大分辨率，适用于大多数应用"
    echo "   - 如需更高分辨率，可运行: $0 --max-size=512"
else
    echo "   - 使用512x512最大分辨率，保持高质量"
    echo "   - 如需更小文件，可运行: $0 --max-size=256"
fi