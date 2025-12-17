#!/bin/bash

# AppleScript 调试脚本
# 用于测试和调试 CopyPathFinder 的 AppleScript 代码

echo "🔍 AppleScript 调试工具"
echo "======================="

# 创建测试脚本
TEST_SCRIPT='tell application "Finder"
    try
        set theSelection to selection
        if theSelection is {} then
            set thePath to (target of front Finder window) as alias
        else
            set thePath to item 1 of theSelection as alias
        end if
        return POSIX path of thePath
    on error errMsg
        return "Error: " & errMsg
    end try
end tell'

echo "📝 测试脚本内容："
echo "$TEST_SCRIPT"
echo ""

echo "🚀 执行测试脚本..."
echo "----------------"

# 使用 osascript 执行测试
RESULT=$(echo "$TEST_SCRIPT" | osascript 2>&1)
EXIT_CODE=$?

echo "📊 执行结果："
echo "退出代码: $EXIT_CODE"
echo "输出: $RESULT"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ AppleScript 执行成功"
    echo "📋 获取到的路径: $RESULT"
else
    echo "❌ AppleScript 执行失败"
    echo "🔍 错误分析："
    
    if [[ $RESULT == *"not authorized"* ]]; then
        echo "   - 权限问题：需要 Apple Events 权限"
    elif [[ $RESULT == *"not running"* ]]; then
        echo "   - Finder 未运行"
    elif [[ $RESULT == *"doesn't understand"* ]]; then
        echo "   - AppleScript 语法错误"
    else
        echo "   - 未知错误: $RESULT"
    fi
fi

echo ""
echo "💡 权限检查："
echo "------------"
echo "请在 系统设置 > 隐私与安全性 > 自动化 中检查："
echo "- CopyPathFinder 是否被列出"
echo "- '允许控制 Finder' 是否已开启"

echo ""
echo "📚 更多帮助："
echo "https://github.com/tekintian/CopyPathFinder#权限设置"