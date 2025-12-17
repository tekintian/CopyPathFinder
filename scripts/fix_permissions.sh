#!/bin/bash

# CopyPathFinder 权限设置助手
# 用于快速检查和修复 Apple Events 权限问题

echo "🔍 CopyPathFinder 权限检查工具"
echo "================================"

# 检查应用是否正在运行
if pgrep -f "CopyPathFinder" > /dev/null; then
    echo "✅ CopyPathFinder 正在运行"
else
    echo "❌ CopyPathFinder 未运行，请先启动应用"
    exit 1
fi

# 检查是否有权限问题
echo ""
echo "🔧 权限问题解决方案："
echo ""

echo "方法 1: 手动授权 (推荐)"
echo "------------------------"
echo "1. 打开 系统设置 > 隐私与安全性 > 自动化"
echo "2. 找到 CopyPathFinder"
echo "3. 开启'允许控制 Finder'选项"
echo ""

echo "方法 2: 使用命令行移除隔离属性"
echo "--------------------------------"
APP_PATH="/Applications/CopyPathFinder.app"
if [ -d "$APP_PATH" ]; then
    echo "执行命令: xattr -d com.apple.quarantine \"$APP_PATH\""
    sudo xattr -d com.apple.quarantine "$APP_PATH" 2>/dev/null || echo "需要管理员权限或文件可能没有隔离属性"
else
    echo "未找到应用: $APP_PATH"
fi

echo ""
echo "方法 3: 重启 Finder"
echo "-------------------"
echo "执行命令: killall Finder && sleep 2"
killall Finder 2>/dev/null || echo "Finder 未运行或需要手动重启"
sleep 2

echo ""
echo "⚡ 快速测试"
echo "----------"
echo "请按以下步骤测试："
echo "1. 打开 Finder"
echo "2. 选中任意文件或文件夹"
echo "3. 点击 CopyPathFinder 状态栏图标"
echo "4. 点击'拷贝路径'"
echo "5. 检查剪贴板是否已复制路径"

echo ""
echo "📚 如果仍有问题，请访问:"
echo "https://github.com/tekintian/CopyPathFinder/issues"

echo ""
echo "✅ 权限检查完成！"