# Quick Toggle 功能文档

## 功能概述

Quick Toggle 是 CopyPathFinder 的一个重要功能，参考了 OpenInTerminal 项目的设计理念，为用户提供更高效的交互方式。启用 Quick Toggle 后，用户可以通过左键点击状态栏图标直接执行预设操作，而右键则显示传统的下拉菜单。

## 核心实现

### 1. 数据模型

#### QuickToggleType 枚举
```swift
public enum QuickToggleType: String, CaseIterable {
    case copyPath
    case copyFileName
    case openInTerminal
    
    public var name: String { /* 本地化名称 */ }
    public var action: Selector { /* 对应的 AppDelegate 方法 */ }
}
```

支持的快速切换操作：
- **拷贝路径** (`copyPath`) - 复制选中文件的完整路径
- **拷贝文件名** (`copyFileName`) - 仅复制文件名
- **在终端中打开** (`openInTerminal`) - 在终端中打开选中位置

### 2. 状态管理

#### SettingsManager 集成
```swift
// Quick Toggle Settings
@Published var isQuickToggle: Bool = false
@Published var quickToggleType: QuickToggleType = .copyPath
```

所有配置通过 UserDefaults 持久化存储：
- `IsQuickToggle` - 是否启用 Quick Toggle
- `QuickToggleType` - 选定的操作类型

### 3. 状态栏交互逻辑

#### AppDelegate 实现
```swift
func setStatusToggle() {
    if settingsManager.isQuickToggle {
        // Quick Toggle 模式
        statusItem?.menu = nil
        button.action = #selector(statusBarButtonClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    } else {
        // 传统菜单模式
        button.action = #selector(togglePopover)
    }
}

@objc func statusBarButtonClicked(sender: NSStatusBarButton) {
    let event = NSApp.currentEvent!
    if event.type == .rightMouseDown || event.modifierFlags.contains(.control) {
        // 右键：显示菜单
        togglePopover()
    } else if event.type == .leftMouseUp {
        // 左键：执行 Quick Toggle 动作
        performQuickToggleAction()
    }
}
```

### 4. 设置界面

#### QuickToggleSettingsView
专用的设置界面，包含：
- Quick Toggle 开关
- 操作类型选择器
- 功能说明文字

集成在主设置窗口的"快速切换"标签页中。

### 5. 国际化支持

完整的中英文本地化：
- 中文：简体中文界面
- 英文：English interface
- 所有用户界面文本都支持动态切换

## 用户体验

### 交互模式

#### Quick Toggle 模式（启用时）
- **左键点击**：直接执行选定的操作
- **右键点击**：显示传统菜单
- **Ctrl+点击**：显示传统菜单

#### 传统模式（禁用时）
- **左键点击**：显示弹出菜单
- **右键点击**：显示弹出菜单

### 设置流程

1. 右键点击状态栏图标
2. 选择"设置"
3. 切换到"快速切换"标签页
4. 启用 Quick Toggle 功能
5. 选择需要的操作类型
6. 设置立即生效

## 技术特点

### 1. 类型安全
- 使用 Swift 枚举确保操作类型的类型安全
- 编译时检查，避免运行时错误

### 2. 状态持久化
- 使用 UserDefaults 统一管理配置
- 应用重启后保持用户设置

### 3. 即时生效
- 设置更改后立即应用到状态栏行为
- 无需重启应用

### 4. 兼容性设计
- 保持传统菜单模式的完整功能
- 用户可以自由切换交互模式

### 5. 架构清晰
- 遵循单一职责原则
- 模块化设计，易于维护和扩展

## 文件结构

```
Sources/CopyPathFinder/
├── QuickToggleType.swift              # 快速切换类型定义
├── QuickToggleSettingsView.swift     # 快速切换设置界面
├── SettingsManager.swift              # 设置管理器（已扩展）
├── AppDelegate.swift                  # 应用委托（已扩展）
├── SettingsView.swift                 # 主设置界面（已扩展）
└── Resources/
    ├── zh-Hans.lproj/
    │   └── Localizable.strings        # 中文本地化（已扩展）
    └── en.lproj/
        └── Localizable.strings        # 英文本地化（已扩展）
```

## 测试验证

### 功能测试
- ✅ Quick Toggle 开关功能
- ✅ 三种操作类型切换
- ✅ 状态栏左键/右键交互
- ✅ 设置持久化
- ✅ 国际化文本显示

### 兼容性测试
- ✅ 传统菜单模式保持不变
- ✅ 设置界面正常工作
- ✅ 通知功能正常
- ✅ 快捷键功能正常

## 未来扩展

该实现为未来扩展提供了良好的基础：
- 可以轻松添加新的操作类型
- 支持更复杂的交互逻辑
- 可以集成更多用户偏好设置
- 为 API 升级预留了扩展空间

## 参考资料

- OpenInTerminal 项目的 Quick Toggle 实现
- Apple Human Interface Guidelines
- SwiftUI 最佳实践