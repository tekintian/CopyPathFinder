# 问题修复说明

## 问题 1: 路径始终返回桌面路径

### 问题描述
在之前的实现中，AppleScript 使用了 `on error` 块来捕获所有错误，并在发生任何错误时返回桌面路径。这导致即使有轻微的错误，也会返回桌面路径而不是正确的选中路径。

### 原因分析
```applescript
try
    tell application "Finder"
        set theSelection to selection
        if theSelection is {} then
            set thePath to (target of front Finder window) as alias
        else
            set thePath to item 1 of theSelection as alias
        end if
        POSIX path of thePath
    end tell
on error errMsg
    POSIX path of (path to desktop)  -- ← 问题：任何错误都返回桌面
end try
```

### 修复方案
1. 移除 AppleScript 中的 `on error` 块，将错误处理移到 Swift 代码中
2. AppleScript 内部使用 `try...on error` 结构，在错误时返回错误信息而不是桌面路径
3. Swift 代码正确解析返回值，区分正常路径和错误信息

### 修复后的代码
```applescript
tell application "Finder"
    try
        set theSelection to selection
        if theSelection is {} then
            set thePath to (target of front Finder window) as alias
        else
            set thePath to item 1 of theSelection as alias
        end if
        return POSIX path of thePath
    on error errMsg
        return "error:" & errMsg  -- ← 返回错误信息而不是桌面路径
    end try
end tell
```

### Swift 错误处理
```swift
let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)

// 检查 AppleScript 是否返回了错误（以 "error:" 开头）
if trimmedPath.hasPrefix("error:") {
    let errorMessage = String(trimmedPath.dropFirst(6))
    
    var localizedDescription = "获取路径失败"
    
    if errorMessage.contains("Not authorized") || errorMessage.contains("permission") {
        localizedDescription = "需要授权控制 Finder。请在系统设置 > 隐私与安全性 > 自动化中允许 CopyPathFinder 控制 Finder。"
    } else if errorMessage.contains("not running") {
        localizedDescription = "Finder 未运行。请确保 Finder 处于运行状态。"
    }
    
    throw NSError(domain: "ScriptError", code: -3, userInfo: [
        NSLocalizedDescriptionKey: localizedDescription,
        "OriginalError": errorMessage
    ])
}

return trimmedPath
```

### 修复效果
- ✅ 正确返回选中的文件/文件夹路径
- ✅ 在权限问题时显示正确的错误提示
- ✅ 在其他错误时显示具体的错误信息
- ✅ 不再静默返回桌面路径

---

## 问题 2: 每次拷贝都弹出通知提示

### 问题描述
用户报告每次拷贝操作都会弹出通知，即使不需要通知。

### 原因分析
1. `showNotifications` 的默认值设置为 `true`
2. 通知检查逻辑正确实现，但用户没有在设置中关闭通知
3. 开发环境中的通知会打印到控制台而不是显示系统通知

### 通知检查逻辑
```swift
private func showNotification(_ title: String, message: String) {
    // 检查是否启用了通知
    guard settingsManager.showNotifications else {
        if settingsManager.enableDebugMode {
            print("Notification disabled: \(title) - \(message)")
        }
        return
    }
    
    // 检查是否在应用包环境中运行
    guard Bundle.main.bundleURL.pathExtension == "app" else {
        print("Notification: \(title) - \(message)")  // ← 开发环境只打印
        return
    }
    
    // 显示系统通知
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = message
    content.sound = UNNotificationSound.default
    // ...
}
```

### 解决方案
用户可以在设置中关闭通知：

1. 右键点击状态栏图标
2. 选择"设置"
3. 在"通用"标签页中
4. 取消勾选"显示通知"

### 可选优化
如果需要改变默认行为，可以修改 `SettingsManager.swift` 中的默认值：

```swift
@Published var showNotifications: Bool = false  // 改为 false 作为默认值
```

### 修复效果
- ✅ 用户可以在设置中完全关闭通知
- ✅ 调试模式下可以看到通知被禁用的日志
- ✅ 开发环境中通知只打印到控制台
- ✅ 保持灵活性和用户控制

---

## 测试验证

### 测试路径功能
1. 在 Finder 中选中一个文件或文件夹
2. 使用 Quick Toggle 或菜单功能拷贝路径
3. 验证返回的是正确的路径而不是桌面路径

### 测试通知功能
1. 打开应用设置
2. 切换"显示通知"开关
3. 验证通知根据设置正确显示或隐藏

### 测试错误处理
1. 模拟权限问题（撤销 Finder 自动化权限）
2. 尝试拷贝路径
3. 验证显示正确的错误提示而不是桌面路径

## 修改的文件

- `Sources/CopyPathFinder/FinderIntegration.swift` - 修复路径问题
- `Sources/CopyPathFinder/SettingsManager.swift` - 通知默认值（可选）

## 相关文档

- `test_fixes.sh` - 测试脚本
- `docs/QUICK_TOGGLE_FEATURE.md` - Quick Toggle 功能文档
